import json
from django.shortcuts import render, redirect
from django.db import connection
from django.core.paginator import Paginator
from django.contrib import messages
from django.http import JsonResponse
from django.db import connection

from .views import role_required  # Import the role_required decorator from your main views

from datetime import datetime, timedelta

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
               COALESCE(p.name, 'At Sea') as current_port, p.port_id as current_port_id, 
               s.status, s.year_built, s.flag, s.imo_number,
               r.route_id, r.origin_port_id, r.destination_port_id
        FROM ships s
        LEFT JOIN ports p ON s.current_port_id = p.port_id
        LEFT JOIN routes r ON s.ship_id = r.ship_id AND r.status != 'deleted'
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
    ships_list = []
    for row in ships_raw:
        ship_dict = {
            'id': row[0],
            'name': row[1],
            'type': row[2],
            'capacity': row[3],
            'current_port': row[4],
            'current_port_id': row[5],
            'status': row[6],
            'year_built': row[7],
            'flag': row[8],
            'imo_number': row[9]
        }
        
        # Add route information if available
        if row[10]:  # If route_id is not None
            ship_dict['route'] = {
                'id': row[10],
                'origin_port_id': row[11],
                'destination_port_id': row[12]
            }
        
        ships_list.append(ship_dict)
    
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
        cost_per_kg = request.POST.get('cost_per_kg') or 0.00
        from_port = request.POST.get('from_port') or None
        to_port = request.POST.get('to_port') or None
        
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
                
                ship_id = cursor.lastrowid
                
                # If both from_port and to_port are provided, create a route for this ship
                if from_port and to_port and from_port != to_port:
                    # Calculate approximate distance and duration based on ports
                    # This is a simplified version - in a real app, you might use a more complex algorithm
                    
                    # First, get the coordinates for both ports
                    cursor.execute("""
                        SELECT ST_Y(location) AS lat1, ST_X(location) AS lng1 FROM ports WHERE port_id = %s
                    """, [from_port])
                    origin_coords = cursor.fetchone()
                    
                    cursor.execute("""
                        SELECT ST_Y(location) AS lat2, ST_X(location) AS lng2 FROM ports WHERE port_id = %s
                    """, [to_port])
                    dest_coords = cursor.fetchone()
                    
                    if origin_coords and dest_coords:
                        # Simple distance calculation (very approximate)
                        # In a real app, you would use a proper geospatial calculation
                        from math import radians, cos, sin, sqrt, atan2
                        
                        lat1, lng1 = radians(origin_coords[0]), radians(origin_coords[1])
                        lat2, lng2 = radians(dest_coords[0]), radians(dest_coords[1])
                        
                        # Haversine formula
                        dlon = lng2 - lng1
                        dlat = lat2 - lat1
                        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
                        c = 2 * atan2(sqrt(a), sqrt(1-a))
                        # Earth radius in nautical miles
                        radius = 3440.065  
                        distance = radius * c
                        
                        # Approximate duration (assuming average speed of 20 knots)
                        duration = distance / 20 / 24  # in days
                        
                        # Create a default route name
                        route_name = f"Route for {name}"
                        
                        # Insert route with the ship_id and cost_per_kg
                        cursor.execute("""
                            INSERT INTO routes (
                                name, origin_port_id, destination_port_id, 
                                distance, duration, status, owner_id, ship_id, cost_per_kg
                            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                        """, [route_name, from_port, to_port, distance, duration, 'active', user_id, ship_id, cost_per_kg])
                    
            messages.success(request, f"Ship '{name}' added successfully!")
            # Add additional message if route was created
            if from_port and to_port and from_port != to_port:
                messages.success(request, f"Default route created for ship '{name}'.")
                
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
        cost_per_kg = request.POST.get('cost_per_kg') or 0.00
        from_port = request.POST.get('from_port') or None
        to_port = request.POST.get('to_port') or None
        
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
                
                # Check if ship has an existing route
                cursor.execute("SELECT route_id FROM routes WHERE ship_id = %s", [ship_id])
                existing_route = cursor.fetchone()
                
                if existing_route and from_port and to_port and from_port != to_port:
                    # Update existing route
                    route_id = existing_route[0]
                    
                    # Calculate new distance and duration based on ports
                    cursor.execute("""
                        SELECT ST_Y(location) AS lat1, ST_X(location) AS lng1 FROM ports WHERE port_id = %s
                    """, [from_port])
                    origin_coords = cursor.fetchone()
                    
                    cursor.execute("""
                        SELECT ST_Y(location) AS lat2, ST_X(location) AS lng2 FROM ports WHERE port_id = %s
                    """, [to_port])
                    dest_coords = cursor.fetchone()
                    
                    if origin_coords and dest_coords:
                        # Simple distance calculation (very approximate)
                        from math import radians, cos, sin, sqrt, atan2
                        
                        lat1, lng1 = radians(origin_coords[0]), radians(origin_coords[1])
                        lat2, lng2 = radians(dest_coords[0]), radians(dest_coords[1])
                        
                        # Haversine formula
                        dlon = lng2 - lng1
                        dlat = lat2 - lat1
                        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
                        c = 2 * atan2(sqrt(a), sqrt(1-a))
                        # Earth radius in nautical miles
                        radius = 3440.065  
                        distance = radius * c
                        
                        # Approximate duration (assuming average speed of 20 knots)
                        duration = distance / 20 / 24  # in days
                        
                        # Update route
                        cursor.execute("""
                            UPDATE routes SET 
                                origin_port_id = %s, destination_port_id = %s,
                                distance = %s, duration = %s, cost_per_kg = %s
                            WHERE route_id = %s
                        """, [from_port, to_port, distance, duration, cost_per_kg, route_id])
                        
                elif not existing_route and from_port and to_port and from_port != to_port:
                    # Create new route
                    # Similar to add_ship logic for creating a route
                    cursor.execute("""
                        SELECT ST_Y(location) AS lat1, ST_X(location) AS lng1 FROM ports WHERE port_id = %s
                    """, [from_port])
                    origin_coords = cursor.fetchone()
                    
                    cursor.execute("""
                        SELECT ST_Y(location) AS lat2, ST_X(location) AS lng2 FROM ports WHERE port_id = %s
                    """, [to_port])
                    dest_coords = cursor.fetchone()
                    
                    if origin_coords and dest_coords:
                        from math import radians, cos, sin, sqrt, atan2
                        
                        lat1, lng1 = radians(origin_coords[0]), radians(origin_coords[1])
                        lat2, lng2 = radians(dest_coords[0]), radians(dest_coords[1])
                        
                        dlon = lng2 - lng1
                        dlat = lat2 - lat1
                        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
                        c = 2 * atan2(sqrt(a), sqrt(1-a))
                        radius = 3440.065
                        distance = radius * c
                        
                        duration = distance / 20 / 24
                        
                        route_name = f"Route for {name}"
                        
                        cursor.execute("""
                            INSERT INTO routes (
                                name, origin_port_id, destination_port_id, 
                                distance, duration, status, owner_id, ship_id, cost_per_kg
                            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                        """, [route_name, from_port, to_port, distance, duration, 'active', user_id, ship_id, cost_per_kg])
                
                # If existing route but no from/to port provided, update just the cost_per_kg
                elif existing_route:
                    route_id = existing_route[0]
                    cursor.execute("""
                        UPDATE routes SET cost_per_kg = %s WHERE route_id = %s
                    """, [cost_per_kg, route_id])
                
            messages.success(request, f"Ship '{name}' updated successfully!")
            
            # Add additional message if route was created or updated
            if from_port and to_port and from_port != to_port:
                if existing_route:
                    messages.success(request, "Route updated successfully.")
                else:
                    messages.success(request, "New route created successfully.")
                    
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
               r.distance, r.duration, r.status, r.cost_per_kg, r.ship_id
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
        
        # Get all ships for the route forms
        cursor.execute("""
            SELECT ship_id, name
            FROM ships
            WHERE owner_id = %s AND status != 'deleted'
            ORDER BY name
        """, [user_id])
        ships_raw = cursor.fetchall()
    
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
            'status': row[12],
            'cost_per_kg': row[13],
            'ship_id': row[14]
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
    
    ships_list = [
        {
            'id': row[0],
            'name': row[1]
        }
        for row in ships_raw
    ]
    
    # Apply pagination
    paginator = Paginator(routes_list, 5)  # Show 5 routes per page
    routes_page = paginator.get_page(page_number)
    
    context = {
        'routes': routes_page,
        'ports': ports_list,
        'ships': ships_list,
        'username': username
    }
    
    return render(request, 'manage_routes.html', context)

@shipowner_required
def add_route(request):
    """
    View function for adding a new route.
    Uses a stored procedure to add the route with proper validation.
    """
    if request.method == 'POST':
        # Get all form fields
        name = request.POST.get('name')
        origin_port = request.POST.get('origin_port')
        destination_port = request.POST.get('destination_port')
        distance = request.POST.get('distance')
        duration = request.POST.get('duration')
        status = request.POST.get('status')
        cost_per_kg = request.POST.get('cost_per_kg') or 0.00
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        if not (name and origin_port and destination_port and distance and duration and status):
            messages.error(request, "Required fields are missing.")
            return redirect('manage-routes')
        
        try:
            with connection.cursor() as cursor:

                cursor.execute("SET @route_id = 0, @success = FALSE, @message = '';")
                # Call the stored procedure to add the route
                cursor.execute("""
                    CALL add_route(%s, %s, %s, %s, %s, %s, %s, %s, @route_id, @success, @message)
                """, [name, origin_port, destination_port, distance, duration, status, cost_per_kg, user_id])
                
                # Get the results from the stored procedure
                cursor.execute("SELECT @route_id, @success, @message")
                result = cursor.fetchone()
                route_id, success, message = result
                
                if success:
                    messages.success(request, message)
                else:
                    messages.error(request, message)
                
            return redirect('manage-routes')
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
        cost_per_kg = request.POST.get('cost_per_kg') or 0.00
        
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
                
                # Update route - Note: Removed ship_id from the update
                cursor.execute("""
                    UPDATE routes SET 
                        name = %s, origin_port_id = %s, destination_port_id = %s,
                        distance = %s, duration = %s, status = %s, cost_per_kg = %s
                    WHERE route_id = %s AND owner_id = %s
                """, [name, origin_port, destination_port, distance, duration, status, cost_per_kg, route_id, user_id])
                
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

from django.http import JsonResponse
from django.db import connection
import json

@shipowner_required
def get_ship_details(request, ship_id):
    """
    API view to get ship details including route information.
    Returns JSON data for the specified ship.
    """
    user_id = request.session.get('user_id')
    
    with connection.cursor() as cursor:
        # Check ownership of the ship
        cursor.execute("""
            SELECT s.ship_id, s.name, s.ship_type, s.capacity, 
                   s.current_port_id, s.imo_number, s.flag, 
                   s.year_built, s.status, s.owner_id
            FROM ships s
            WHERE s.ship_id = %s AND s.owner_id = %s
        """, [ship_id, user_id])
        
        ship_row = cursor.fetchone()
        
        if not ship_row:
            return JsonResponse({'error': 'Ship not found or access denied'}, status=404)
        
        # Get route information for this ship
        cursor.execute("""
            SELECT r.route_id, r.name, r.origin_port_id, r.destination_port_id, 
                   r.distance, r.duration, r.cost_per_kg
            FROM routes r
            WHERE r.ship_id = %s AND r.status != 'deleted'
        """, [ship_id])
        
        route_row = cursor.fetchone()
    
    # Create ship data dictionary
    ship_data = {
        'id': ship_row[0],
        'name': ship_row[1],
        'type': ship_row[2],
        'capacity': float(ship_row[3]),
        'current_port_id': ship_row[4],
        'imo_number': ship_row[5],
        'flag': ship_row[6],
        'year_built': ship_row[7],
        'status': ship_row[8]
    }
    
    # Add route data if it exists
    if route_row:
        ship_data['route'] = {
            'id': route_row[0],
            'name': route_row[1],
            'origin_port_id': route_row[2],
            'destination_port_id': route_row[3],
            'distance': float(route_row[4]),
            'duration': float(route_row[5]),
            'cost_per_kg': float(route_row[6])
        }
    
    return JsonResponse(ship_data)


@shipowner_required
@shipowner_required
def manage_schedules(request):
    """
    View function for managing ship schedules.
    Lists all schedules created by the shipowner with filtering.
    """
    # Get filter parameters from request
    ship_name = request.GET.get('ship_name', '').strip() or None
    port_name = request.GET.get('port_name', '').strip() or None
    status = request.GET.get('status', '').strip() or None
    date_from = request.GET.get('date_from', '').strip() or None
    date_to = request.GET.get('date_to', '').strip() or None
    page_number = request.GET.get('page', 1)
    
    # Get user_id from session
    user_id = request.session.get('user_id')
    
    # Convert date strings to proper format for SQL query
    if date_from:
        try:
            date_from = datetime.strptime(date_from, '%Y-%m-%d').strftime('%Y-%m-%d')
        except ValueError:
            date_from = None
    
    if date_to:
        try:
            date_to = datetime.strptime(date_to, '%Y-%m-%d').strftime('%Y-%m-%d')
        except ValueError:
            date_to = None
    
    # Get all schedules created by the shipowner
    query = """
        SELECT sc.schedule_id, sc.departure_date, sc.arrival_date, sc.status,
               sc.actual_departure, sc.actual_arrival,
               s.ship_id, s.name AS ship_name, s.ship_type,
               r.route_id, r.name AS route_name,
               po.name AS origin_port, po.port_id AS origin_port_id,
               pd.name AS destination_port, pd.port_id AS destination_port_id,
               r.distance, r.duration
        FROM schedules sc
        JOIN ships s ON sc.ship_id = s.ship_id
        JOIN routes r ON sc.route_id = r.route_id
        JOIN ports po ON r.origin_port_id = po.port_id
        JOIN ports pd ON r.destination_port_id = pd.port_id
        WHERE s.owner_id = %s
          AND (%s IS NULL OR s.name LIKE CONCAT('%%', %s, '%%'))
          AND (%s IS NULL OR po.name LIKE CONCAT('%%', %s, '%%') OR pd.name LIKE CONCAT('%%', %s, '%%'))
          AND (%s IS NULL OR sc.status = %s)
          AND (%s IS NULL OR sc.departure_date >= %s)
          AND (%s IS NULL OR sc.departure_date <= %s)
        ORDER BY sc.departure_date DESC
    """
    
    params = [user_id, ship_name, ship_name, port_name, port_name, port_name, 
              status, status, date_from, date_from, date_to, date_to]
    
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        schedules_raw = cursor.fetchall()
        
        # Get username
        cursor.execute("SELECT get_username(%s)", [user_id])
        username = cursor.fetchone()[0]
        
        # Get all active ships for filter dropdown
        cursor.execute("""
            SELECT ship_id, name
            FROM ships
            WHERE owner_id = %s AND status != 'deleted'
            ORDER BY name
        """, [user_id])
        ships_raw = cursor.fetchall()
        
        # Get all ports for filter dropdown
        cursor.execute("""
            SELECT port_id, name
            FROM ports 
            WHERE status = 'active'
            ORDER BY name
        """)
        ports_raw = cursor.fetchall()
    
    # Transform raw data to dictionary list
    schedules_list = []
    for row in schedules_raw:
        # Format dates for display
        departure_date = row[1].strftime('%Y-%m-%d %H:%M') if row[1] else None
        arrival_date = row[2].strftime('%Y-%m-%d %H:%M') if row[2] else None
        actual_departure = row[4].strftime('%Y-%m-%d %H:%M') if row[4] else None
        actual_arrival = row[5].strftime('%Y-%m-%d %H:%M') if row[5] else None
        
        schedules_list.append({
            'id': row[0],
            'departure_date': departure_date,
            'arrival_date': arrival_date,
            'status': row[3],
            'actual_departure': actual_departure,
            'actual_arrival': actual_arrival,
            'max_cargo': 0,  # Default value since we don't have this in the DB yet
            'ship_id': row[6],
            'ship_name': row[7],
            'ship_type': row[8],
            'route_id': row[9],
            'route_name': row[10],
            'origin_port': row[11],
            'origin_port_id': row[12],
            'destination_port': row[13],
            'destination_port_id': row[14],
            'distance': row[15],
            'duration': row[16],
            'notes': ''  # Default empty string since we don't have this yet
        })
    
    ships_list = [
        {
            'id': row[0],
            'name': row[1]
        }
        for row in ships_raw
    ]
    
    ports_list = [
        {
            'id': row[0],
            'name': row[1]
        }
        for row in ports_raw
    ]
    
    # Apply pagination
    paginator = Paginator(schedules_list, 5)  # Show 5 schedules per page
    schedules_page = paginator.get_page(page_number)
    
    context = {
        'schedules': schedules_page,
        'ships': ships_list,
        'ports': ports_list,
        'username': username,
        'statuses': ['scheduled', 'in_progress', 'completed', 'delayed', 'cancelled']
    }
    
    return render(request, 'manage_schedules.html', context)


@shipowner_required
def add_schedule(request):
    """
    View function for adding a new schedule.
    Inserts schedule information into the database.
    """
    if request.method == 'POST':
        ship_id = request.POST.get('ship_id')
        route_id = request.POST.get('route_id')
        departure_date = request.POST.get('departure_date')
        arrival_date = request.POST.get('arrival_date')
        status = request.POST.get('status', 'scheduled')
        
        # We're not saving these values since the columns don't exist yet
        # max_cargo = request.POST.get('max_cargo', 0)
        # notes = request.POST.get('notes', '')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        if not (ship_id and route_id and departure_date and arrival_date):
            messages.error(request, "Required fields are missing.")
            return redirect('create-schedule-form')
        
        try:
            # Parse dates
            departure_datetime = datetime.strptime(departure_date, '%Y-%m-%d %H:%M')
            arrival_datetime = datetime.strptime(arrival_date, '%Y-%m-%d %H:%M')
            
            # Validate that arrival is after departure
            if arrival_datetime <= departure_datetime:
                messages.error(request, "Arrival date must be after departure date.")
                return redirect('create-schedule-form')
            
            with connection.cursor() as cursor:
                # Check if ship belongs to user
                cursor.execute("SELECT COUNT(*) FROM ships WHERE ship_id = %s AND owner_id = %s", [ship_id, user_id])
                if cursor.fetchone()[0] == 0:
                    messages.error(request, "You don't have permission to schedule this ship.")
                    return redirect('create-schedule-form')
                
                # Check if route belongs to user
                cursor.execute("SELECT COUNT(*) FROM routes WHERE route_id = %s AND owner_id = %s", [route_id, user_id])
                if cursor.fetchone()[0] == 0:
                    messages.error(request, "You don't have permission to use this route.")
                    return redirect('create-schedule-form')
                
                # Check for scheduling conflicts (overlapping schedules for the same ship)
                cursor.execute("""
                    SELECT COUNT(*) FROM schedules 
                    WHERE ship_id = %s
                    AND (
                        (departure_date <= %s AND arrival_date >= %s) OR
                        (departure_date <= %s AND arrival_date >= %s) OR
                        (departure_date >= %s AND arrival_date <= %s)
                    )
                    AND status != 'cancelled'
                """, [ship_id, departure_datetime, departure_datetime, arrival_datetime, arrival_datetime, 
                      departure_datetime, arrival_datetime])
                
                if cursor.fetchone()[0] > 0:
                    messages.error(request, "This ship is already scheduled during the selected time period.")
                    return redirect('create-schedule-form')
                
                # Get ship details
                cursor.execute("""
                    SELECT name, current_port_id
                    FROM ships
                    WHERE ship_id = %s
                """, [ship_id])
                ship_data = cursor.fetchone()
                ship_name = ship_data[0]
                current_port_id = ship_data[1]
                
                # Get route details
                cursor.execute("""
                    SELECT origin_port_id, po.name as origin_name, destination_port_id, pd.name as dest_name
                    FROM routes r
                    JOIN ports po ON r.origin_port_id = po.port_id
                    JOIN ports pd ON r.destination_port_id = pd.port_id
                    WHERE route_id = %s
                """, [route_id])
                route_data = cursor.fetchone()
                origin_port_id = route_data[0]
                origin_port_name = route_data[1]
                destination_port_id = route_data[2]
                destination_port_name = route_data[3]
                
                # Insert the schedule (removed max_cargo and notes)
                cursor.execute("""
                    INSERT INTO schedules (
                        ship_id, route_id, departure_date, arrival_date, status
                    ) VALUES (%s, %s, %s, %s, %s)
                """, [ship_id, route_id, departure_datetime, arrival_datetime, status])
                
                # Update the ship status based on the schedule
                if status == 'scheduled':
                    if current_port_id == origin_port_id:
                        # If ship is already at the origin port, it's ready
                        update_status = 'docked'
                    else:
                        # If ship needs to be repositioned, mark it for repositioning
                        update_status = 'maintenance'
                elif status == 'in_progress':
                    update_status = 'in_transit'
                else:
                    update_status = 'active'
                
                cursor.execute("""
                    UPDATE ships
                    SET status = %s
                    WHERE ship_id = %s
                """, [update_status, ship_id])
                
            # Set success message
            success_message = f"Schedule created successfully for {ship_name} from {origin_port_name} to {destination_port_name}."
            
            # Add a note if the ship needs repositioning
            if status == 'scheduled' and current_port_id != origin_port_id:
                success_message += " Note: The ship needs to be repositioned to the origin port before departure."
            
            messages.success(request, success_message)
            
        except ValueError as e:
            # Handle date parsing errors
            messages.error(request, f"Invalid date format: {str(e)}")
            return redirect('add-schedule-page')
        except Exception as e:
            # Handle general errors
            messages.error(request, f"Error creating schedule: {str(e)}")
            return redirect('add-schedule-page')
        
        # Redirect to the schedules list page
        return redirect('manage-schedules')
    
    # If not POST, redirect to the add schedule form page
    return redirect('create-schedule-form')

@shipowner_required
def edit_schedule(request):
    """
    View function for editing a schedule.
    Updates schedule information in the database.
    """
    if request.method == 'POST':
        schedule_id = request.POST.get('id')
        departure_date = request.POST.get('departure_date')
        arrival_date = request.POST.get('arrival_date')
        status = request.POST.get('status')
        actual_departure = request.POST.get('actual_departure') or None
        actual_arrival = request.POST.get('actual_arrival') or None
        max_cargo = request.POST.get('max_cargo', 0)
        notes = request.POST.get('notes', '')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        if not (schedule_id and departure_date and arrival_date and status):
            messages.error(request, "Required fields are missing.")
            return redirect('manage-schedules')
        
        try:
            # Parse dates
            departure_datetime = datetime.strptime(departure_date, '%Y-%m-%d %H:%M')
            arrival_datetime = datetime.strptime(arrival_date, '%Y-%m-%d %H:%M')
            
            if actual_departure:
                actual_departure_datetime = datetime.strptime(actual_departure, '%Y-%m-%d %H:%M')
            else:
                actual_departure_datetime = None
                
            if actual_arrival:
                actual_arrival_datetime = datetime.strptime(actual_arrival, '%Y-%m-%d %H:%M')
            else:
                actual_arrival_datetime = None
            
            # Validate that arrival is after departure
            if arrival_datetime <= departure_datetime:
                messages.error(request, "Arrival date must be after departure date.")
                return redirect('manage-schedules')
            
            with connection.cursor() as cursor:
                # Check if schedule exists and is associated with a ship owned by the user
                cursor.execute("""
                    SELECT sc.ship_id, s.name as ship_name, s.current_port_id, 
                           r.origin_port_id, po.name as origin_name, 
                           r.destination_port_id, pd.name as dest_name,
                           sc.status as current_status
                    FROM schedules sc
                    JOIN ships s ON sc.ship_id = s.ship_id
                    JOIN routes r ON sc.route_id = r.route_id
                    JOIN ports po ON r.origin_port_id = po.port_id
                    JOIN ports pd ON r.destination_port_id = pd.port_id
                    WHERE sc.schedule_id = %s AND s.owner_id = %s
                """, [schedule_id, user_id])
                
                schedule_data = cursor.fetchone()
                
                if not schedule_data:
                    messages.error(request, "Schedule not found or you don't have permission to edit it.")
                    return redirect('manage-schedules')
                
                ship_id = schedule_data[0]
                ship_name = schedule_data[1]
                current_port_id = schedule_data[2]
                origin_port_id = schedule_data[3]
                origin_port_name = schedule_data[4]
                destination_port_id = schedule_data[5]
                destination_port_name = schedule_data[6]
                current_status = schedule_data[7]
                
                # Check for scheduling conflicts with other schedules (excluding this one)
                cursor.execute("""
                    SELECT COUNT(*) FROM schedules 
                    WHERE ship_id = %s
                    AND schedule_id != %s
                    AND (
                        (departure_date <= %s AND arrival_date >= %s) OR
                        (departure_date <= %s AND arrival_date >= %s) OR
                        (departure_date >= %s AND arrival_date <= %s)
                    )
                    AND status != 'cancelled'
                """, [ship_id, schedule_id, departure_datetime, departure_datetime, 
                      arrival_datetime, arrival_datetime, departure_datetime, arrival_datetime])
                
                if cursor.fetchone()[0] > 0:
                    messages.error(request, "This ship is already scheduled during the selected time period.")
                    return redirect('manage-schedules')
                
                # Update the schedule
                cursor.execute("""
                    UPDATE schedules
                    SET departure_date = %s, arrival_date = %s, status = %s,
                        actual_departure = %s, actual_arrival = %s,
                        max_cargo = %s, notes = %s
                    WHERE schedule_id = %s
                """, [departure_datetime, arrival_datetime, status, 
                      actual_departure_datetime, actual_arrival_datetime,
                      max_cargo, notes, schedule_id])
                
                # Update the ship status if schedule status has changed
                if status != current_status:
                    if status == 'scheduled':
                        if current_port_id == origin_port_id:
                            update_status = 'docked'
                        else:
                            update_status = 'maintenance'
                    elif status == 'in_progress':
                        update_status = 'in_transit'
                    elif status == 'completed':
                        # If completed, move the ship to the destination port
                        cursor.execute("""
                            UPDATE ships
                            SET status = 'docked', current_port_id = %s
                            WHERE ship_id = %s
                        """, [destination_port_id, ship_id])
                    else:
                        update_status = 'active'
                    
                    if status != 'completed':
                        cursor.execute("""
                            UPDATE ships
                            SET status = %s
                            WHERE ship_id = %s
                        """, [update_status, ship_id])
                
            messages.success(request, f"Schedule for {ship_name} updated successfully.")
            
        except ValueError as e:
            # Handle date parsing errors
            messages.error(request, f"Invalid date format: {str(e)}")
        except Exception as e:
            # Handle general errors
            messages.error(request, f"Error updating schedule: {str(e)}")
        
        return redirect('manage-schedules')
    
    # If not POST, redirect back to manage schedules page
    return redirect('manage-schedules')

@shipowner_required
def delete_schedule(request):
    """
    View function for deleting a schedule.
    Removes the schedule from the database.
    """
    if request.method == 'POST':
        schedule_id = request.POST.get('id')
        
        # Get user_id from session
        user_id = request.session.get('user_id')
        
        if not schedule_id:
            messages.error(request, "No schedule specified.")
            return redirect('manage-schedules')
        
        try:
            with connection.cursor() as cursor:
                # Check if schedule exists and is associated with a ship owned by the user
                cursor.execute("""
                    SELECT sc.ship_id, s.name as ship_name
                    FROM schedules sc
                    JOIN ships s ON sc.ship_id = s.ship_id
                    WHERE sc.schedule_id = %s AND s.owner_id = %s
                """, [schedule_id, user_id])
                
                schedule_data = cursor.fetchone()
                
                if not schedule_data:
                    messages.error(request, "Schedule not found or you don't have permission to delete it.")
                    return redirect('manage-schedules')
                
                ship_name = schedule_data[1]
                
                # Delete the schedule
                cursor.execute("DELETE FROM schedules WHERE schedule_id = %s", [schedule_id])
                
            messages.success(request, f"Schedule for {ship_name} deleted successfully.")
            
        except Exception as e:
            messages.error(request, f"Error deleting schedule: {str(e)}")
        
        return redirect('manage-schedules')
    
    # If not POST, redirect back to manage schedules page
    return redirect('manage-schedules')