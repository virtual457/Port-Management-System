from django.urls import path
from . import views

urlpatterns = [
    path('', views.login_view, name='login'),
    path('login/', views.login_view, name='login'),
    path('signup/', views.signup_view, name='signup'),
    path('forgot-password/', views.forgot_password_view, name='forgot-password'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('logout/', views.logout_view, name='logout'),
    path('admin/', views.logout_view, name='admin'),

    # Role selection
    path('choose-role/', views.choose_role_view, name='choose-role'),

    # Dashboards (each view checks for correct role)
    path('admin/dashboard/', views.admin_dashboard, name='admin-dashboard'),
    path('manager/dashboard/', views.manager_dashboard, name='manager-dashboard'),
    path('staff/dashboard/', views.staff_dashboard, name='staff-dashboard'),
    path('customer/dashboard/', views.customer_dashboard, name='customer-dashboard'),
    path('admin/manage-users/', views.customer_dashboard, name='manage-users'), 

    
]
