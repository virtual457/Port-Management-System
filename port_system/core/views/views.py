from django.shortcuts import render, redirect
from django.db import connection
from django.contrib.auth.hashers import check_password, make_password
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator
from django.contrib import messages


def login_view(request):
    if request.method == 'POST':
        email = request.POST['email']
        password = request.POST['password']

        with connection.cursor() as cursor:
            cursor.execute("SELECT user_id, password FROM users WHERE email = %s", [email])
            user = cursor.fetchone()

            if user and check_password(password, user[1]):
                request.session['user_id'] = user[0]

                # Check how many roles user has
                cursor.execute("SELECT r.role_name FROM user_roles ur JOIN roles r ON ur.role_id = r.role_id WHERE ur.user_id = %s", [user[0]])
                roles = [row[0] for row in cursor.fetchall()]

                if len(roles) == 1:
                    request.session['selected_role'] = roles[0]
                    return redirect(f'/{roles[0]}/dashboard')
                else:
                    request.session['available_roles'] = roles
                    return redirect('choose-role')
            else:
                return render(request, 'login.html', {'error': 'Invalid email or password'})

    return render(request, 'login.html')


def signup_view(request):
    if request.method == 'POST':
        email = request.POST['email']
        password = request.POST['password']
        username = request.POST['username']
        first_name = request.POST['first_name']
        last_name = request.POST['last_name']
        phone_number = request.POST['phone_number']
        hashed_password = make_password(password)

        with connection.cursor() as cursor:
            cursor.execute("SELECT user_id FROM users WHERE email = %s", [email])
            user_exists = cursor.fetchone()

            if user_exists:
                return render(request, 'signup.html', {'error': 'Email already registered'})

            # Insert user
            cursor.execute("INSERT INTO users (username, first_name, last_name, phone_number, email, password) VALUES (%s, %s, %s, %s, %s, %s)",
                [username, first_name, last_name, phone_number, email, hashed_password])   
            user_id = cursor.lastrowid


            # Assign default role (customer)
            cursor.execute("SELECT role_id FROM roles WHERE role_name = 'customer'")
            role_id = cursor.fetchone()[0]
            cursor.execute("INSERT INTO user_roles (user_id, role_id) VALUES (%s, %s)", [user_id, role_id])

        return render(request, 'signup.html', {'success': 'Account created successfully!'})

    return render(request, 'signup.html')


def forgot_password_view(request):
    if request.method == 'POST':
        email = request.POST['email']
        new_password = request.POST['new_password']
        hashed_password = make_password(new_password)

        with connection.cursor() as cursor:
            cursor.execute("SELECT user_id FROM users WHERE email = %s", [email])
            user = cursor.fetchone()

            if not user:
                return render(request, 'forgot_password.html', {'error': 'Email not found'})

            cursor.execute("UPDATE users SET password = %s WHERE email = %s", [hashed_password, email])

        return render(request, 'forgot_password.html', {'success': 'Password updated successfully!'})

    return render(request, 'forgot_password.html')


def choose_role_view(request):
    if request.method == 'POST':
        selected_role = request.POST.get('role')
        request.session['selected_role'] = selected_role
        return redirect(f'/{selected_role}/dashboard')

    roles = request.session.get('available_roles', [])
    return render(request, 'choose_role.html', {'roles': roles})


def dashboard(request):
    if not request.session.get('user_id'):
        return redirect('login')

    selected_role = request.session.get('selected_role')
    if not selected_role:
        return redirect('choose-role')

    return render(request, 'dashboard.html', {'role': selected_role})


def logout_view(request):
    request.session.flush()
    return redirect('login')




# Utility to check role
def role_required(expected_role):
    def wrapper(view_func):
        def inner(request, *args, **kwargs):
            if request.session.get('selected_role') != expected_role:
                return redirect('login')  # or a 403 page
            return view_func(request, *args, **kwargs)
        return inner
    return wrapper

@role_required('admin')
def admin_dashboard(request):
    print("comming here")
    return render(request, 'admin_dashboard.html')

@role_required('manager')
def manager_dashboard(request):
    return render(request, 'manager_dashboard.html')

@role_required('staff')
def staff_dashboard(request):
    return render(request, 'staff_dashboard.html')

@role_required('customer')
def customer_dashboard(request):
    return render(request, 'customer_dashboard.html')


#can be optimized using a limit and offset for pagination in the stored procedure.
@role_required('admin')
def admin_manage_users(request):
    username = request.GET.get('username', '').strip() or None
    email = request.GET.get('email', '').strip() or None
    role = request.GET.get('role', '').strip() or None
    page_number = request.GET.get('page', 1)

    with connection.cursor() as cursor:
        # Call the stored procedure to get all filtered users
        cursor.callproc('filter_users_advanced', [username, email, role])
        users_raw = cursor.fetchall()

    # Prepare user list with role split into a list
    users_list = []
    for row in users_raw:
        role_list = row[3].split(', ') if row[3] else []
        users_list.append({
            'user_id': row[0], 
            'username': row[1], 
            'email': row[2], 
            'role': row[3],  # Keep the original role string
            'role_list': role_list  # Add the split list
        })

    # Apply pagination in Python
    paginator = Paginator(users_list, 5)  # Show 5 users per page
    users_page = paginator.get_page(page_number)

    # Get all available roles from the database
    with connection.cursor() as cursor:
        cursor.execute("SELECT role_id, role_name FROM roles ORDER BY role_name")
        roles_raw = cursor.fetchall()
    
    roles_list = [
        {
            'id': row[0],
            'name': row[1]
        }
        for row in roles_raw
    ]

    return render(request, 'manage_users.html', {
        'users': users_page,
        'roles': roles_list,
    })

@role_required('admin')
def admin_users_add(request):
    """
    View function for adding a new user.
    Inserts user information into the database.
    """
    print("entering admin_users_add view")
    if request.method == 'POST':
        print("Received POST request to add user")
        username = request.POST.get('username')
        email = request.POST.get('email')
        role = request.POST.get('role')
        password = request.POST.get('password')
        first_name = request.POST.get('first_name', '')
        last_name = request.POST.get('last_name', '')
        phone_number = request.POST.get('phone_number', '')
        
        if not (username and email and role and password):
            messages.error(request, "Required fields are missing.")
            return redirect('manage-users')
        
        # Hash the password
        hashed_password = make_password(password)
        print("hashed password")
        
        try:
            with connection.cursor() as cursor:
                # Check if email already exists
                cursor.execute("SELECT user_id FROM users WHERE email = %s", [email])
                if cursor.fetchone():
                    messages.error(request, f"Email '{email}' is already in use.")
                    return redirect('manage-users')
                
                # Insert user
                cursor.execute("""
                    INSERT INTO users (username, email, password, first_name, last_name, phone_number)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, [username, email, hashed_password, first_name, last_name, phone_number])
                print("User inserted into database successfully")
                # Get the user_id of the newly inserted user
                user_id = cursor.lastrowid
                
                # Get role_id
                cursor.execute("SELECT role_id FROM roles WHERE role_name = %s", [role])
                role_id_result = cursor.fetchone()
                
                if not role_id_result:
                    # If role doesn't exist, create it (fallback, should rarely happen)
                    print("Error: Role not found")
                    Exception(f"Role '{role}' does not exist in the database.")    
                else:
                    role_id = role_id_result[0]
                
                # Assign role to user
                cursor.execute(
                    "INSERT INTO user_roles (user_id, role_id) VALUES (%s, %s)",
                    [user_id, role_id]
                )
                print("Role assigned to user successfully")
            messages.success(request, f"User '{username}' added successfully!")
        except Exception as e:
            messages.error(request, f"Error adding user: {str(e)}")
            print(e)
        
        return redirect('manage-users')
    
    # If not POST, redirect back to manage users page
    return redirect('manage-users')

@role_required('admin')
def admin_users_edit(request):
    if request.method == 'POST':
        user_id = request.POST.get('id')
        username = request.POST.get('username')
        email = request.POST.get('email')
        roles = request.POST.getlist('roles[]')  # Get all selected roles
        password = request.POST.get('password')
        
        if not (user_id and username and email):
            messages.error(request, "Username and email are required.")
            return redirect('manage-users')
        
        if not roles:
            messages.error(request, "At least one role must be selected.")
            return redirect('manage-users')
        
        try:
            with connection.cursor() as cursor:
                # Check if email already exists for another user
                cursor.execute(
                    "SELECT user_id FROM users WHERE email = %s AND user_id != %s", 
                    [email, user_id]
                )
                if cursor.fetchone():
                    messages.error(request, f"Email '{email}' is already in use by another user.")
                    return redirect('manage-users')
                
                # Update user information
                if password and password.strip():
                    # If a new password is provided, hash it and update all fields
                    hashed_password = make_password(password)
                    cursor.execute(
                        "UPDATE users SET username = %s, email = %s, password = %s WHERE user_id = %s",
                        [username, email, hashed_password, user_id]
                    )
                else:
                    # Otherwise, update only username and email
                    cursor.execute(
                        "UPDATE users SET username = %s, email = %s WHERE user_id = %s",
                        [username, email, user_id]
                    )
                
                # Delete existing roles for this user
                cursor.execute("DELETE FROM user_roles WHERE user_id = %s", [user_id])
                
                # Add each selected role
                for role in roles:
                    cursor.execute("SELECT role_id FROM roles WHERE role_name = %s", [role])
                    role_id_result = cursor.fetchone()
                    
                    if role_id_result:
                        role_id = role_id_result[0]
                        cursor.execute(
                            "INSERT INTO user_roles (user_id, role_id) VALUES (%s, %s)",
                            [user_id, role_id]
                        )
                
            messages.success(request, f"User '{username}' updated successfully!")
        except Exception as e:
            messages.error(request, f"Error updating user: {str(e)}")
        
        return redirect('manage-users')
    
    # If not POST, redirect back to manage users page
    return redirect('manage-users')

@role_required('admin')
def admin_users_delete(request):
    """
    View function for deleting a user.
    Removes user from the database.
    """
    if request.method == 'POST':
        user_id = request.POST.get('id')
        
        if not user_id:
            messages.error(request, "No user specified.")
            return redirect('manage-users')
        
        # Get username for success message
        with connection.cursor() as cursor:
            cursor.execute("SELECT username FROM users WHERE user_id = %s", [user_id])
            result = cursor.fetchone()
            username = result[0] if result else "Unknown user"
        
        # Don't allow deletion of the current user
        if int(user_id) == int(request.session.get('user_id', 0)):
            messages.error(request, "You cannot delete your own account.")
            return redirect('manage-users')
        
        try:
            with connection.cursor() as cursor:
                # Check if user has any associated data before deletion
                # This would be more comprehensive in a real application
                # checking all related tables
                
                # First delete from user_roles
                cursor.execute("DELETE FROM user_roles WHERE user_id = %s", [user_id])
                
                # Then delete the user
                cursor.execute("DELETE FROM users WHERE user_id = %s", [user_id])
                
            messages.success(request, f"User '{username}' deleted successfully!")
        except Exception as e:
            messages.error(request, f"Error deleting user: {str(e)}")
        
        return redirect('manage-users')
    
    # If not POST, redirect back to manage users page
    return redirect('manage-users')
# Admin port management views


@role_required('admin')
def admin_manage_ports(request):
    name = request.GET.get('name', '').strip() or None
    country = request.GET.get('country', '').strip() or None
    status = request.GET.get('status', '').strip() or None
    page_number = request.GET.get('page', 1)

    query = """
        SELECT port_id, name, country, ST_Y(location) AS lat, ST_X(location) AS lng, status
        FROM ports
        WHERE (%s IS NULL OR name LIKE CONCAT('%%', %s, '%%'))
          AND (%s IS NULL OR country LIKE CONCAT('%%', %s, '%%'))
          AND (%s IS NULL OR status = %s)
        ORDER BY created_at DESC
    """

    params = [name, name, country, country, status, status]

    with connection.cursor() as cursor:
        cursor.execute(query, params)
        ports_raw = cursor.fetchall()

    ports_list = [
        {
            'id': row[0],
            'name': row[1],
            'country': row[2],
            'lat': row[3],
            'lng': row[4],
            'status': row[5]
        }
        for row in ports_raw
    ]

    print(ports_list)

    paginator = Paginator(ports_list, 5)
    ports_page = paginator.get_page(page_number)

    return render(request, 'manage_ports.html', {
        'ports': ports_page
    })

@role_required('admin')
def admin_ports_add(request):
    if request.method == 'POST':
        name = request.POST.get('name')
        country = request.POST.get('country')
        lat, lng = request.POST.get('location').split(',')
        location_point = f"POINT({lng} {lat})"  # Note: lng first, then lat (MySQL syntax)

        status = request.POST.get('status')

        print("got thesse values from the form", name, country, location_point, status)
        if not (name and country and location_point and status):
            messages.error(request, "All fields are required.")
            return render(request, 'add_ports.html')

        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO ports (name, country, location, status)
                VALUES (%s, %s, ST_GeomFromText(%s), %s)
                """, [name, country, location_point, status])


        messages.success(request, f"Port '{name}' added successfully!")
        return redirect('manage-ports')  # Update this URL name based on your routes

    return render(request, 'add_ports.html')

@role_required('admin')
def admin_ports_edit(request):
    if request.method == 'POST':
        port_id = request.POST.get('id')
        name = request.POST.get('name')
        country = request.POST.get('country')
        status = request.POST.get('status')
        location = request.POST.get('location')
        
        if not (port_id and name and country and status and location):
            messages.error(request, "All fields are required.")
            return redirect('manage-ports')
        
        # Parse location
        lat, lng = location.split(',')
        location_point = f"POINT({lng} {lat})"  # Note: lng first, then lat (MySQL syntax)
        
        # Update port in database
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE ports 
                SET name = %s, country = %s, location = ST_GeomFromText(%s), status = %s
                WHERE port_id = %s
            """, [name, country, location_point, status, port_id])
        
        messages.success(request, f"Port '{name}' updated successfully!")
        return redirect('manage-ports')
    
    # If not POST, redirect back to manage ports page
    return redirect('manage-ports')

@role_required('admin')
def admin_ports_delete(request):
    if request.method == 'POST':
        port_id = request.POST.get('id')
        
        if not port_id:
            messages.error(request, "No port specified.")
            return redirect('manage-ports')
        
        # Get port name for success message
        with connection.cursor() as cursor:
            cursor.execute("SELECT name FROM ports WHERE port_id = %s", [port_id])
            result = cursor.fetchone()
            port_name = result[0] if result else "Unknown port"
        
        # Delete port from database
        try:
            with connection.cursor() as cursor:
                # You might want to check if port is in use before deletion
                cursor.execute("SELECT COUNT(*) FROM schedules WHERE port_id = %s", [port_id])
                count = cursor.fetchone()[0]
                
                if count > 0:
                    messages.error(request, f"Cannot delete '{port_name}'. It is used in {count} schedule(s).")
                    return redirect('manage-ports')
                
                cursor.execute("DELETE FROM ports WHERE port_id = %s", [port_id])
                
            messages.success(request, f"Port '{port_name}' deleted successfully!")
        except Exception as e:
            messages.error(request, f"Error deleting port: {str(e)}")
        
        return redirect('manage-ports')
    
    # If not POST, redirect back to manage ports page
    return redirect('manage-ports')


#Customer specific view to cargo
from django.shortcuts import render, redirect
from django.db import connection
from django.core.paginator import Paginator
from django.contrib import messages
from django.http import JsonResponse
import json

# Import your role_required decorator
from .views import role_required  # Adjust the import path as needed


@role_required('customer')
def customer_manage_cargo(request):
    """
    View function for managing customer cargo.
    Uses stored procedure to filter and retrieve cargo items.
    """
    # Get filter parameters from request
    description = request.GET.get('description', '').strip() or None
    cargo_type = request.GET.get('type', '').strip() or None
    status = request.GET.get('status', '').strip() or None
    page_number = request.GET.get('page', 1)
    
    # Get user_id from session
    user_id = request.session.get('user_id')
    
    with connection.cursor() as cursor:
        # Call the stored procedure to get filtered cargo items
        cursor.callproc('get_customer_cargo', [user_id, description, cargo_type, status])
        cargo_raw = cursor.fetchall()
    
    # Transform raw data to dictionary list
    cargos_list = [
        {
            'id': row[0],
            'description': row[1],
            'type': row[2],
            'weight': row[3],
            'dimensions': row[4],
            'special_instructions': row[5],
            'status': row[6],
            'created_at': row[7]
        }
        for row in cargo_raw
    ]
    
    # Apply pagination
    paginator = Paginator(cargos_list, 5)  # Show 5 cargo items per page
    cargos_page = paginator.get_page(page_number)
    
    # Get username for display in navbar
    with connection.cursor() as cursor:
        cursor.execute("SELECT get_username(%s)", [user_id])
        username = cursor.fetchone()[0]
    
    context = {
        'cargos': cargos_page,
        'username': username
    }
    
    return render(request, 'customer_manage_cargo.html', context)


@role_required('customer')
def customer_add_cargo(request):
    """
    View function to add a new cargo item.
    Uses stored procedure to insert cargo.
    """
    if request.method == 'POST':
        # Get form data
        description = request.POST.get('description')
        cargo_type = request.POST.get('type')
        weight = request.POST.get('weight')
        dimensions = request.POST.get('dimensions', '')
        special_instructions = request.POST.get('special_instructions', '')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        # Validate required fields
        if not (description and cargo_type and weight):
            messages.error(request, "Required fields are missing.")
            return redirect('customer-manage-cargo')
        
        # Call stored procedure to add cargo
        with connection.cursor() as cursor:
            cursor.callproc('add_customer_cargo', [
                user_id, 
                description, 
                cargo_type, 
                weight, 
                dimensions, 
                special_instructions
            ])
            # Get result - some DBs return status, others may not need this line
            result = cursor.fetchone() 
        
        messages.success(request, f"Cargo '{description}' added successfully!")
        return redirect('customer-manage-cargo')
    
    # If not POST, redirect back to manage page
    return redirect('customer-manage-cargo')


@role_required('customer')
def customer_edit_cargo(request):
    """
    View function to edit an existing cargo item.
    Uses stored procedure to update cargo.
    """
    if request.method == 'POST':
        # Get form data
        cargo_id = request.POST.get('id')
        description = request.POST.get('description')
        cargo_type = request.POST.get('type')
        weight = request.POST.get('weight')
        dimensions = request.POST.get('dimensions', '')
        special_instructions = request.POST.get('special_instructions', '')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        # Validate required fields
        if not (cargo_id and description and cargo_type and weight):
            messages.error(request, "Required fields are missing.")
            return redirect('customer-manage-cargo')
        
        # Call stored procedure to update cargo
        with connection.cursor() as cursor:
            cursor.callproc('update_customer_cargo', [
                cargo_id,
                user_id,
                description, 
                cargo_type, 
                weight, 
                dimensions, 
                special_instructions
            ])
            
            # Get result status from procedure
            result = cursor.fetchone()
            
            # Check if update was successful (procedure returns 1 for success, 0 for failure)
            if result and result[0] == 0:
                messages.error(request, "Failed to update cargo. Either it doesn't exist or you don't have permission.")
                return redirect('customer-manage-cargo')
        
        messages.success(request, f"Cargo '{description}' updated successfully!")
        return redirect('customer-manage-cargo')
    
    # If not POST, redirect back to manage page
    return redirect('customer-manage-cargo')


@role_required('customer')
def customer_delete_cargo(request):
    """
    View function to delete a cargo item.
    Uses stored procedure to delete cargo.
    """
    if request.method == 'POST':
        cargo_id = request.POST.get('id')
        user_id = request.session.get('user_id')
        
        if not cargo_id:
            messages.error(request, "No cargo specified.")
            return redirect('customer-manage-cargo')
        
        # Call stored procedure to delete cargo
        with connection.cursor() as cursor:
            cursor.callproc('delete_customer_cargo', [cargo_id, user_id])
            
            # Get result status from procedure
            result = cursor.fetchone()
            
            # Procedure returns status code and message
            if result:
                status_code = result[0]
                
                if status_code == 0:
                    messages.error(request, "Cannot delete this cargo. It may not exist, you may not have permission, or it's already booked.")
                elif status_code == 1:
                    messages.success(request, "Cargo deleted successfully!")
            else:
                messages.error(request, "An error occurred while trying to delete cargo.")
        
        return redirect('customer-manage-cargo')
    
    # If not POST, redirect back to manage page
    return redirect('customer-manage-cargo')
