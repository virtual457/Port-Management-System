from django.shortcuts import render, redirect
from django.db import connection
from django.contrib.auth.hashers import check_password, make_password
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required

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
