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

            cursor.execute("INSERT INTO users (username, first_name, last_name, phone_number, email, password) VALUES (%s, %s, %s, %s, %s, %s)",
                [username, first_name, last_name, phone_number, email, hashed_password])   
            user_id = cursor.lastrowid


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




def role_required(expected_role):
    def wrapper(view_func):
        def inner(request, *args, **kwargs):
            if request.session.get('selected_role') != expected_role:
                return redirect('login') 
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
    user_id = request.session.get('user_id')
    
    if not user_id:
        return redirect('login')
    
    selected_role = request.session.get('selected_role')
    if selected_role != 'customer':
        return redirect('unauthorized')
    
    with connection.cursor() as cursor:
        cursor.execute("SELECT username FROM users WHERE user_id = %s", [user_id])
        result = cursor.fetchone()
        username = result[0] if result else "Customer"
    
    print(user_id)
    print(username)
    context = {
        'username': username,
        'cargo_count': 0,
        'active_bookings': 0,
        'in_transit': 0,
        'completed_shipments': 0,
        'recent_bookings': [],
        'upcoming_shipments': [],
        'popular_routes': []
    }
    
    with connection.cursor() as cursor:
        cursor.callproc('get_customer_dashboard_stats', [user_id])
        
        result = cursor.fetchone()
        if result:
            context['cargo_count'] = result[0]
        
        cursor.nextset()
        result = cursor.fetchone()
        direct_bookings = result[0] if result else 0
        
        cursor.nextset()
        result = cursor.fetchone()
        connected_bookings = result[0] if result else 0
        
        context['active_bookings'] = direct_bookings + connected_bookings
        
        cursor.nextset()
        result = cursor.fetchone()
        if result:
            context['in_transit'] = result[0]
        
        cursor.nextset()
        result = cursor.fetchone()
        if result:
            context['completed_shipments'] = result[0]
        
        cursor.callproc('get_customer_recent_bookings', [user_id, 5])
        recent_bookings = []
        for row in cursor.fetchall():
            recent_bookings.append({
                'type': row[0],
                'booking_id': row[1],
                'cargo_description': row[2],
                'cargo_type': row[3],
                'origin_port': row[4],
                'destination_port': row[5],
                'departure_date': row[6],
                'first_departure': row[7],
                'booking_status': row[8],
                'connected_booking_id': row[9]
            })
        context['recent_bookings'] = recent_bookings
        
        cursor.nextset() 
        cursor.callproc('get_customer_upcoming_shipments', [user_id, 3])
        upcoming_shipments = []
        for row in cursor.fetchall():
            upcoming_shipments.append({
                'cargo_description': row[0],
                'origin_port': row[1],
                'destination_port': row[2],
                'departure_date': row[3],
                'days_until': row[4]
            })
        context['upcoming_shipments'] = upcoming_shipments
        
        cursor.nextset()
        cursor.callproc('get_popular_shipping_routes', [5])
        popular_routes = []
        for row in cursor.fetchall():
            popular_routes.append({
                'route_id': row[0],
                'origin_id': row[1],
                'destination_id': row[2],
                'origin_port': row[3],
                'destination_port': row[4],
                'duration': row[5],
                'available_ships': row[6],
                'avg_cost_per_kg': round(float(row[7]), 2)
            })
        context['popular_routes'] = popular_routes
    print(context)
    return render(request, 'customer_dashboard.html', context)


@role_required('admin')
def admin_manage_users(request):
    username = request.GET.get('username', '').strip() or None
    email = request.GET.get('email', '').strip() or None
    role = request.GET.get('role', '').strip() or None
    page_number = request.GET.get('page', 1)

    with connection.cursor() as cursor:
        cursor.callproc('filter_users_advanced', [username, email, role])
        users_raw = cursor.fetchall()
    users_list = []
    for row in users_raw:
        role_list = row[3].split(', ') if row[3] else []
        users_list.append({
            'user_id': row[0], 
            'username': row[1], 
            'email': row[2], 
            'role': row[3], 
            'role_list': role_list 
        })

    paginator = Paginator(users_list, 5) 
    users_page = paginator.get_page(page_number)

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
        
        hashed_password = make_password(password)
        print("hashed password")
        
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT user_id FROM users WHERE email = %s", [email])
                if cursor.fetchone():
                    messages.error(request, f"Email '{email}' is already in use.")
                    return redirect('manage-users')
                
                cursor.execute("""
                    INSERT INTO users (username, email, password, first_name, last_name, phone_number)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, [username, email, hashed_password, first_name, last_name, phone_number])
                print("User inserted into database successfully")
                user_id = cursor.lastrowid
                
                cursor.execute("SELECT role_id FROM roles WHERE role_name = %s", [role])
                role_id_result = cursor.fetchone()
                
                if not role_id_result:
                    print("Error: Role not found")
                    Exception(f"Role '{role}' does not exist in the database.")    
                else:
                    role_id = role_id_result[0]
                
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
    
    return redirect('manage-users')

@role_required('admin')
def admin_users_edit(request):
    if request.method == 'POST':
        user_id = request.POST.get('id')
        username = request.POST.get('username')
        email = request.POST.get('email')
        roles = request.POST.getlist('roles[]')
        password = request.POST.get('password')
        
        if not (user_id and username and email):
            messages.error(request, "Username and email are required.")
            return redirect('manage-users')
        
        if not roles:
            messages.error(request, "At least one role must be selected.")
            return redirect('manage-users')
        
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT user_id FROM users WHERE email = %s AND user_id != %s", 
                    [email, user_id]
                )
                if cursor.fetchone():
                    messages.error(request, f"Email '{email}' is already in use by another user.")
                    return redirect('manage-users')
                
                if password and password.strip():
                    hashed_password = make_password(password)
                    cursor.execute(
                        "UPDATE users SET username = %s, email = %s, password = %s WHERE user_id = %s",
                        [username, email, hashed_password, user_id]
                    )
                else:
                    cursor.execute(
                        "UPDATE users SET username = %s, email = %s WHERE user_id = %s",
                        [username, email, user_id]
                    )
                
                cursor.execute("DELETE FROM user_roles WHERE user_id = %s", [user_id])
                
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
        
        with connection.cursor() as cursor:
            cursor.execute("SELECT username FROM users WHERE user_id = %s", [user_id])
            result = cursor.fetchone()
            username = result[0] if result else "Unknown user"
        
        if int(user_id) == int(request.session.get('user_id', 0)):
            messages.error(request, "You cannot delete your own account.")
            return redirect('manage-users')
        
        try:
            with connection.cursor() as cursor:
               
                cursor.execute("DELETE FROM user_roles WHERE user_id = %s", [user_id])
                
                cursor.execute("DELETE FROM users WHERE user_id = %s", [user_id])
                
            messages.success(request, f"User '{username}' deleted successfully!")
        except Exception as e:
            messages.error(request, f"Error deleting user: {str(e)}")
        
        return redirect('manage-users')
    
    return redirect('manage-users')



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
        location_point = f"POINT({lng} {lat})"

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
        return redirect('manage-ports') 

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
        

        lat, lng = location.split(',')
        location_point = f"POINT({lng} {lat})"  

        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE ports 
                SET name = %s, country = %s, location = ST_GeomFromText(%s), status = %s
                WHERE port_id = %s
            """, [name, country, location_point, status, port_id])
        
        messages.success(request, f"Port '{name}' updated successfully!")
        return redirect('manage-ports')
    
    return redirect('manage-ports')

@role_required('admin')
def admin_ports_delete(request):
    if request.method == 'POST':
        port_id = request.POST.get('id')
        
        if not port_id:
            messages.error(request, "No port specified.")
            return redirect('manage-ports')
        
        try:
            with connection.cursor() as cursor:
                cursor.callproc('delete_port', [port_id, 0, ''])
                cursor.execute('SELECT @_delete_port_1, @_delete_port_2')
                status, message = cursor.fetchone()
                
                if status:
                    messages.success(request, message)
                else:
                    messages.error(request, message)
                    
        except Exception as e:
            messages.error(request, f"Error deleting port: {str(e)}")
        
        return redirect('manage-ports')
    
    return redirect('manage-ports')


from django.shortcuts import render, redirect
from django.db import connection
from django.core.paginator import Paginator
from django.contrib import messages
from django.http import JsonResponse
import json


from .views import role_required


@role_required('customer')
def customer_manage_cargo(request):
    """
    View function for managing customer cargo.
    Uses stored procedure to filter and retrieve cargo items.
    """
    description = request.GET.get('description', '').strip() or None
    cargo_type = request.GET.get('type', '').strip() or None
    status = request.GET.get('status', '').strip() or None
    page_number = request.GET.get('page', 1)

    user_id = request.session.get('user_id')
    
    with connection.cursor() as cursor:
        cursor.callproc('get_customer_cargo', [user_id, description, cargo_type, status])
        cargo_raw = cursor.fetchall()
    

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
    
    paginator = Paginator(cargos_list, 5)
    cargos_page = paginator.get_page(page_number)
    
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
        description = request.POST.get('description')
        cargo_type = request.POST.get('type')
        weight = request.POST.get('weight')
        dimensions = request.POST.get('dimensions', '')
        special_instructions = request.POST.get('special_instructions', '')
        
        user_id = request.session.get('user_id')
        
        if not (description and cargo_type and weight):
            messages.error(request, "Required fields are missing.")
            return redirect('customer-manage-cargo')
        
        with connection.cursor() as cursor:
            cursor.callproc('add_customer_cargo', [
                user_id, 
                description, 
                cargo_type, 
                weight, 
                dimensions, 
                special_instructions
            ])
            result = cursor.fetchone() 
        
        messages.success(request, f"Cargo '{description}' added successfully!")
        return redirect('customer-manage-cargo')
    
    return redirect('customer-manage-cargo')


@role_required('customer')
def customer_edit_cargo(request):
    """
    View function to edit an existing cargo item.
    Uses stored procedure to update cargo.
    """
    if request.method == 'POST':
        cargo_id = request.POST.get('id')
        description = request.POST.get('description')
        cargo_type = request.POST.get('type')
        weight = request.POST.get('weight')
        dimensions = request.POST.get('dimensions', '')
        special_instructions = request.POST.get('special_instructions', '')
        
        user_id = request.session.get('user_id')
        
        if not (cargo_id and description and cargo_type and weight):
            messages.error(request, "Required fields are missing.")
            return redirect('customer-manage-cargo')
        
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
            
            result = cursor.fetchone()
            if result and result[0] == 0:
                messages.error(request, "Failed to update cargo. Either it doesn't exist or you don't have permission.")
                return redirect('customer-manage-cargo')
        
        messages.success(request, f"Cargo '{description}' updated successfully!")
        return redirect('customer-manage-cargo')
    
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
        
        with connection.cursor() as cursor:
            cursor.callproc('delete_customer_cargo', [cargo_id, user_id])
            
            result = cursor.fetchone()
            
            if result:
                status_code = result[0]
                
                if status_code == 0:
                    messages.error(request, "Cannot delete this cargo. It may not exist, you may not have permission, or it's already booked.")
                elif status_code == 1:
                    messages.success(request, "Cargo deleted successfully!")
            else:
                messages.error(request, "An error occurred while trying to delete cargo.")
        
        return redirect('customer-manage-cargo')
    
    return redirect('customer-manage-cargo')
