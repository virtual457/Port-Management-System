from django.urls import path
from . import views
from . import shipowner_views

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

    #cutomer specific paths
    path('customer/cargo/', views.customer_manage_cargo, name='customer-manage-cargo'),
    path('customer/cargo/add/', views.customer_add_cargo, name='customer-add-cargo'),
    path('customer/cargo/edit/', views.customer_edit_cargo, name='customer-edit-cargo'),
    path('customer/cargo/delete/', views.customer_delete_cargo, name='customer-delete-cargo'),

    #admin port related paths
    path('admin/ports/edit/', views.admin_ports_edit, name='edit-ports'),
    path('admin/ports/delete/', views.admin_ports_delete, name='delete-ports'),

    # Admin user management paths
    path('admin/users/edit/', views.admin_users_edit, name='edit-users'),
    path('admin/users/delete/', views.admin_users_delete, name='delete-users'),
    path('admin/users/add/', views.admin_users_add, name='add-users'),
    

    # Dashboards (each view checks for correct role)
    path('admin/dashboard/', views.admin_dashboard, name='admin-dashboard'),
    path('manager/dashboard/', views.manager_dashboard, name='manager-dashboard'),
    path('staff/dashboard/', views.staff_dashboard, name='staff-dashboard'),
    path('customer/dashboard/', views.customer_dashboard, name='customer-dashboard'),
    path('admin/manage-users/', views.admin_manage_users, name='manage-users'), 
    path('admin/manage-ports/', views.admin_manage_ports, name='manage-ports'), 
    path('admin/ports/add/', views.admin_ports_add, name='add-ports'),

# Shipowner dashboard
    path('shipowner/dashboard/', shipowner_views.shipowner_dashboard, name='shipowner-dashboard'),

# Ships management
    path('shipowner/ships/', shipowner_views.manage_ships, name='manage-ships'),
    path('shipowner/ships/add/', shipowner_views.add_ship, name='add-ship'),
    path('shipowner/ships/edit/', shipowner_views.edit_ship, name='edit-ship'),
    path('shipowner/ships/delete/', shipowner_views.delete_ship, name='delete-ship'),

    # Routes management
    path('shipowner/routes/', shipowner_views.manage_routes, name='manage-routes'),
    path('shipowner/routes/add/', shipowner_views.add_route, name='add-route'),
    path('shipowner/routes/edit/', shipowner_views.edit_route, name='edit-route'),
    path('shipowner/routes/delete/', shipowner_views.delete_route, name='delete-route'),

    
]
