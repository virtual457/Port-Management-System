from django.urls import path
from . import views
from . import shipowner_views
from .views.admin import *;
from .views.shipowner.schedule_views import *;
from .views.shipowner.schedule_management_view import *;
from .views.admin import berth_views;
from .views.customer import shipping_views;

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

    # Port details view
    path('admin/manage-berths/', berth_views.manage_berths, name='manage-berths'),
    path('admin/berths/add/', berth_views.add_berth, name='add-berth'),
    path('admin/berths/edit/', berth_views.edit_berth, name='edit-berth'),
    path('admin/berths/delete/', berth_views.delete_berth, name='delete-berth'),
    path('admin/ports/<int:port_id>/', port_details_view.port_details, name='port-details'),
    

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
    
    # API endpoint for ship details
    path('api/ships/<int:ship_id>/', shipowner_views.get_ship_details, name='get-ship-details'),

    # Routes management
    path('shipowner/routes/', shipowner_views.manage_routes, name='manage-routes'),
    path('shipowner/routes/add/', shipowner_views.add_route, name='add-route'),
    path('shipowner/routes/edit/', shipowner_views.edit_route, name='edit-route'),
    path('shipowner/routes/delete/', shipowner_views.delete_route, name='delete-route'),
        
    # Schedules management
    path('shipowner/schedules/', manage_schedules, name='manage-schedules'),
    path('shipowner/schedules/add-page/', shipowner_views.add_schedule_page, name='add-schedule-page'),
    path('shipowner/schedules/add/', shipowner_views.add_schedule, name='add-schedule'),
    path('shipowner/schedules/edit/', shipowner_views.edit_schedule, name='edit-schedule'),
    path('shipowner/schedules/delete/', shipowner_views.delete_schedule, name='delete-schedule'),

    path('shipowner/schedules/create/', create_schedule_form, name='create-schedule-form'),
    path('shipowner/schedules/add/', create_schedule, name='create-schedule'),
    path('shipowner/schedules/update-status/', update_schedule_status, name='update-schedule-status'),
    path('shipowner/schedules/delete/', delete_schedule, name='delete-schedule'),
    path('api/ports/<int:port_id>/available-berths/', get_available_berths, name='get-available-berths'),


    # Shipping search and booking URLs
path('customer/find-shipping/', shipping_views.find_shipping_options, name='find-shipping-options'),
path('customer/book-cargo/<int:schedule_id>/', shipping_views.book_direct_cargo, name='book-direct-cargo'),
path('customer/book-connected-route/<str:route_id>/<int:cargo_id>/<str:booking_type>/', shipping_views.book_connected_route, name='book-connected-route'),
path('customer/bookings/', shipping_views.view_bookings, name='customer-bookings'),
path('customer/booking/<int:booking_id>/<str:booking_type>/', shipping_views.view_booking_details, name='booking-details'),
path('customer/cancel-booking/<int:booking_id>/<str:booking_type>/', shipping_views.cancel_booking, name='cancel-booking'),
path('api/cargo/<int:cargo_id>/', shipping_views.get_cargo_details, name='get-cargo-details'),
path('test-connected-routes/', shipping_views.test_connected_routes, name='test-connected-routes'),
]