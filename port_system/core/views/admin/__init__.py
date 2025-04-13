# Import admin-specific views to make them accessible via views.admin

from .berth_views import manage_berths, add_berth, edit_berth, delete_berth

from .port_details_view import port_details