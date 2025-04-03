
from django.shortcuts import render, redirect
from django.db import connection
from django.core.paginator import Paginator
from django.contrib import messages
from .views import role_required  # Import the role_required decorator from your main views

# Utility to check if user is a shipowner
def shipowner_required(view_func):
    return role_required('shipowner')(view_func)

@shipowner_required
def shipowner_dashboard(request):
    """
    View function for the shipowner dashboard.
    Shows statistics and recent activities.
    """
    with connection.cursor() as cursor:
        # Get shipowner ID
        user_id = request.session.get('user_id')
        
        # Get ships count
        
        
        # Get username
        cursor.execute("SELECT get_username(%s)", [user_id])
        username = cursor.fetchone()[0]
    
    context = {
        
        'username': username
    }
    
    return render(request, 'shipowner_dashboard.html', context)

@shipowner_required
def manage_ships(request):
    """
    View function for managing ships.
    Lists all ships owned by the shipowner with filtering.
    """
    # Get filter parameters from request
    name = request.GET.get('name', '').strip() or None
    ship_type = request.GET.get('type', '').strip() or None
    status = request.GET.get('status', '').strip() or None
    page_number = request.GET.get('page', 1)
    
    # Get user_id from session
    user_id = request.session.get('user_id')
    
    # Get all ships owned by the shipowner
    query = """
        SELECT s.ship_id, s.name, s.ship_type, s.capacity, 
               COALESCE(p.name, 'At Sea') as current_port, s.status,
               s.year_built, s.flag, s.imo_number
        FROM ships s
        LEFT JOIN ports p ON s.current_port_id = p.port_id
        WHERE s.owner_id = %s
          AND s.status != 'deleted'
          AND (%s IS NULL OR s.name LIKE CONCAT('%%', %s, '%%'))
          AND (%s IS NULL OR s.ship_type = %s)
          AND (%s IS NULL OR s.status = %s)
        ORDER BY s.created_at DESC
    """
    
    params = [user_id, name, name, ship_type, ship_type, status, status]
    
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        ships_raw = cursor.fetchall()
        
        # Get username
        cursor.execute("SELECT get_username(%s)", [user_id])
        username = cursor.fetchone()[0]
    
    # Transform raw data to dictionary list
    ships_list = [
        {
            'id': row[0],
            'name': row[1],
            'type': row[2],
            'capacity': row[3],
            'current_port': row[4],
            'status': row[5],
            'year_built': row[6],
            'flag': row[7],
            'imo_number': row[8]
        }
        for row in ships_raw
    ]
    
    # Apply pagination
    paginator = Paginator(ships_list, 5)  # Show 5 ships per page
    ships_page = paginator.get_page(page_number)
    
    # Get all ports for the add ship form
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT port_id, name, country, ST_Y(location) AS lat, ST_X(location) AS lng
            FROM ports 
            WHERE status = 'active'
            ORDER BY name
        """)
        ports_raw = cursor.fetchall()
        ports_list = [
        {
            'id': row[0],
            'name': row[1],
            'country': row[2],
            'lat': row[3],
            'lng': row[4]
        }
        for row in ports_raw
    ]
    
    context = {
        'ships': ships_page,
        'ports': ports_list,
        'username': username
    }
    
    return render(request, 'manage_ships.html', context)

@shipowner_required
def add_ship(request):
    """
    View function for adding a new ship.
    Inserts ship information into the database.
    """
    if request.method == 'POST':
        name = request.POST.get('name')
        ship_type = request.POST.get('type')
        capacity = request.POST.get('capacity')
        current_port = request.POST.get('current_port') or None
        imo_number = request.POST.get('imo_number')
        flag = request.POST.get('flag')
        year_built = request.POST.get('year_built')
        status = request.POST.get('status')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        if not (name and ship_type and capacity and imo_number and flag and year_built and status):
            messages.error(request, "Required fields are missing.")
            return redirect('manage-ships')
        
        try:
            with connection.cursor() as cursor:
                # Check if IMO number already exists
                cursor.execute("SELECT ship_id FROM ships WHERE imo_number = %s", [imo_number])
                if cursor.fetchone():
                    messages.error(request, f"IMO number '{imo_number}' is already registered.")
                    return redirect('manage-ships')
                
                # Insert ship
                cursor.execute("""
                    INSERT INTO ships (
                        name, ship_type, capacity, current_port_id, 
                        imo_number, flag, year_built, status, owner_id
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, [name, ship_type, capacity, current_port, imo_number, flag, year_built, status, user_id])
                
            messages.success(request, f"Ship '{name}' added successfully!")
        except Exception as e:
            messages.error(request, f"Error adding ship: {str(e)}")
        
        return redirect('manage-ships')
    
    # If not POST, redirect back to manage ships page
    return redirect('manage-ships')

@shipowner_required
def edit_ship(request):
    """
    View function for editing a ship.
    Updates ship information in the database.
    """
    if request.method == 'POST':
        ship_id = request.POST.get('id')
        name = request.POST.get('name')
        ship_type = request.POST.get('type')
        capacity = request.POST.get('capacity')
        current_port = request.POST.get('current_port') or None
        imo_number = request.POST.get('imo_number')
        flag = request.POST.get('flag')
        year_built = request.POST.get('year_built')
        status = request.POST.get('status')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        if not (ship_id and name and ship_type and capacity and imo_number and flag and year_built and status):
            messages.error(request, "Required fields are missing.")
            return redirect('manage-ships')
        
        try:
            with connection.cursor() as cursor:
                # Check ownership
                cursor.execute("SELECT owner_id FROM ships WHERE ship_id = %s", [ship_id])
                row = cursor.fetchone()
                if not row or row[0] != user_id:
                    messages.error(request, "You do not have permission to edit this ship.")
                    return redirect('manage-ships')
                
                # Check if IMO number already exists for another ship
                cursor.execute(
                    "SELECT ship_id FROM ships WHERE imo_number = %s AND ship_id != %s", 
                    [imo_number, ship_id]
                )
                if cursor.fetchone():
                    messages.error(request, f"IMO number '{imo_number}' is already registered to another ship.")
                    return redirect('manage-ships')
                
                # Update ship
                cursor.execute("""
                    UPDATE ships SET 
                        name = %s, ship_type = %s, capacity = %s, current_port_id = %s,
                        imo_number = %s, flag = %s, year_built = %s, status = %s
                    WHERE ship_id = %s AND owner_id = %s
                """, [name, ship_type, capacity, current_port, imo_number, flag, year_built, status, ship_id, user_id])
                
            messages.success(request, f"Ship '{name}' updated successfully!")
        except Exception as e:
            messages.error(request, f"Error updating ship: {str(e)}")
        
        return redirect('manage-ships')
    
    # If not POST, redirect back to manage ships page
    return redirect('manage-ships')

@shipowner_required
def delete_ship(request):
    """
    View function for deleting a ship.
    Marks ship as deleted in the database.
    """
    if request.method == 'POST':
        ship_id = request.POST.get('id')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        if not ship_id:
            messages.error(request, "No ship specified.")
            return redirect('manage-ships')
        
        try:
            with connection.cursor() as cursor:
                # Check ownership
                cursor.execute("SELECT name, owner_id FROM ships WHERE ship_id = %s", [ship_id])
                row = cursor.fetchone()
                if not row or row[1] != user_id:
                    messages.error(request, "You do not have permission to delete this ship.")
                    return redirect('manage-ships')
                
                ship_name = row[0]
                
                # Check if ship is in use in schedules
                cursor.execute("""
                    SELECT COUNT(*) FROM schedules 
                    WHERE ship_id = %s AND departure_date > NOW()
                """, [ship_id])
                if cursor.fetchone()[0] > 0:
                    messages.error(request, f"Cannot delete ship '{ship_name}' as it has upcoming schedules.")
                    return redirect('manage-ships')
                
                # Soft delete by updating status
                cursor.execute("UPDATE ships SET status = 'deleted' WHERE ship_id = %s AND owner_id = %s", [ship_id, user_id])
                
            messages.success(request, f"Ship '{ship_name}' deleted successfully!")
        except Exception as e:
            messages.error(request, f"Error deleting ship: {str(e)}")
        
        return redirect('manage-ships')
    
    # If not POST, redirect back to manage ships page
    return redirect('manage-ships')

@shipowner_required
def manage_routes(request):
    """
    View function for managing routes.
    Lists all routes owned by the shipowner with filtering.
    """
    # Get filter parameters from request
    origin = request.GET.get('origin', '').strip() or None
    destination = request.GET.get('destination', '').strip() or None
    status = request.GET.get('status', '').strip() or None
    page_number = request.GET.get('page', 1)
    
    # Get user_id from session
    user_id = request.session.get('user_id')
    
    # Get all routes owned by the shipowner
    query = """
        SELECT r.route_id, r.name, 
               op.name as origin_port, op.port_id as origin_id, ST_Y(op.location) as origin_lat, ST_X(op.location) as origin_lng,
               dp.name as destination_port, dp.port_id as destination_id, ST_Y(dp.location) as destination_lat, ST_X(dp.location) as destination_lng,
               r.distance, r.duration, r.status
        FROM routes r
        JOIN ports op ON r.origin_port_id = op.port_id
        JOIN ports dp ON r.destination_port_id = dp.port_id
        WHERE r.owner_id = %s
          AND r.status != 'deleted'
          AND (%s IS NULL OR op.name LIKE CONCAT('%%', %s, '%%'))
          AND (%s IS NULL OR dp.name LIKE CONCAT('%%', %s, '%%'))
          AND (%s IS NULL OR r.status = %s)
        ORDER BY r.created_at DESC
    """
    
    params = [user_id, origin, origin, destination, destination, status, status]
    
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        routes_raw = cursor.fetchall()
        
        # Get username
        cursor.execute("SELECT get_username(%s)", [user_id])
        username = cursor.fetchone()[0]
        
        # Get all active ports for the route forms
        cursor.execute("""
            SELECT port_id, name, country, ST_Y(location) AS lat, ST_X(location) AS lng
            FROM ports 
            WHERE status = 'active'
            ORDER BY name
        """)
        ports_raw = cursor.fetchall()
    
    # Transform raw data to dictionary list
    routes_list = [
        {
            'id': row[0],
            'name': row[1],
            'origin_port': row[2],
            'origin_id': row[3],
            'origin_lat': row[4],
            'origin_lng': row[5],
            'destination_port': row[6],
            'destination_id': row[7],
            'destination_lat': row[8],
            'destination_lng': row[9],
            'distance': row[10],
            'duration': row[11],
            'status': row[12]
        }
        for row in routes_raw
    ]
    
    ports_list = [
        {
            'id': row[0],
            'name': row[1],
            'country': row[2],
            'lat': row[3],
            'lng': row[4]
        }
        for row in ports_raw
    ]
    
    # Apply pagination
    paginator = Paginator(routes_list, 5)  # Show 5 routes per page
    routes_page = paginator.get_page(page_number)
    
    context = {
        'routes': routes_page,
        'ports': ports_list,
        'username': username
    }
    
    return render(request, 'manage_routes.html', context)

@shipowner_required
def add_route(request):
    """
    View function for adding a new route.
    Inserts route information into the database.
    """
    if request.method == 'POST':
        name = request.POST.get('name')
        origin_port = request.POST.get('origin_port')
        destination_port = request.POST.get('destination_port')
        distance = request.POST.get('distance')
        duration = request.POST.get('duration')
        status = request.POST.get('status')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        if not (name and origin_port and destination_port and distance and duration and status):
            messages.error(request, "Required fields are missing.")
            return redirect('manage-routes')
        
        # Check if origin and destination are different
        if origin_port == destination_port:
            messages.error(request, "Origin and destination ports cannot be the same.")
            return redirect('manage-routes')
        
        try:
            with connection.cursor() as cursor:
                # Insert route
                cursor.execute("""
                    INSERT INTO routes (
                        name, origin_port_id, destination_port_id, 
                        distance, duration, status, owner_id
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                """, [name, origin_port, destination_port, distance, duration, status, user_id])
                
            messages.success(request, f"Route '{name}' added successfully!")
        except Exception as e:
            messages.error(request, f"Error adding route: {str(e)}")
        
        return redirect('manage-routes')
    
    # If not POST, redirect back to manage routes page
    return redirect('manage-routes')

@shipowner_required
def edit_route(request):
    """
    View function for editing a route.
    Updates route information in the database.
    """
    if request.method == 'POST':
        route_id = request.POST.get('id')
        name = request.POST.get('name')
        origin_port = request.POST.get('origin_port')
        destination_port = request.POST.get('destination_port')
        distance = request.POST.get('distance')
        duration = request.POST.get('duration')
        status = request.POST.get('status')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        if not (route_id and name and origin_port and destination_port and distance and duration and status):
            messages.error(request, "Required fields are missing.")
            return redirect('manage-routes')
        
        # Check if origin and destination are different
        if origin_port == destination_port:
            messages.error(request, "Origin and destination ports cannot be the same.")
            return redirect('manage-routes')
        
        try:
            with connection.cursor() as cursor:
                # Check ownership
                cursor.execute("SELECT owner_id FROM routes WHERE route_id = %s", [route_id])
                row = cursor.fetchone()
                if not row or row[0] != user_id:
                    messages.error(request, "You do not have permission to edit this route.")
                    return redirect('manage-routes')
                
                # Update route
                cursor.execute("""
                    UPDATE routes SET 
                        name = %s, origin_port_id = %s, destination_port_id = %s,
                        distance = %s, duration = %s, status = %s
                    WHERE route_id = %s AND owner_id = %s
                """, [name, origin_port, destination_port, distance, duration, status, route_id, user_id])
                
            messages.success(request, f"Route '{name}' updated successfully!")
        except Exception as e:
            messages.error(request, f"Error updating route: {str(e)}")
        
        return redirect('manage-routes')
    
    # If not POST, redirect back to manage routes page
    return redirect('manage-routes')

@shipowner_required
def delete_route(request):
    """
    View function for deleting a route.
    Marks route as deleted in the database.
    """
    if request.method == 'POST':
        route_id = request.POST.get('id')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        if not route_id:
            messages.error(request, "No route specified.")
            return redirect('manage-routes')
        
        try:
            with connection.cursor() as cursor:
                # Check ownership
                cursor.execute("SELECT name, owner_id FROM routes WHERE route_id = %s", [route_id])
                row = cursor.fetchone()
                if not row or row[1] != user_id:
                    messages.error(request, "You do not have permission to delete this route.")
                    return redirect('manage-routes')
                
                route_name = row[0]
                
                # Check if route is in use in schedules
                cursor.execute("""
                    SELECT COUNT(*) FROM schedules 
                    WHERE route_id = %s AND departure_date > NOW()
                """, [route_id])
                if cursor.fetchone()[0] > 0:
                    messages.error(request, f"Cannot delete route '{route_name}' as it has upcoming schedules.")
                    return redirect('manage-routes')
                
                # Soft delete by updating status
                cursor.execute("UPDATE routes SET status = 'deleted' WHERE route_id = %s AND owner_id = %s", [route_id, user_id])
                
            messages.success(request, f"Route '{route_name}' deleted successfully!")
        except Exception as e:
            messages.error(request, f"Error deleting route: {str(e)}")
        
        return redirect('manage-routes')
    
    # If not POST, redirect back to manage routes page
    return redirect('manage-routes')