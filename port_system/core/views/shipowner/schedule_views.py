from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection
from django.http import JsonResponse
import json
from datetime import datetime

def create_schedule_form(request):
    """
    View for displaying the schedule creation form
    """
    # Get ships owned by the current user
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT ship_id, name, ship_type, capacity, 
                   (SELECT ports.name FROM ports WHERE ports.port_id = ships.current_port_id) as current_port
            FROM ships 
            WHERE owner_id = %s AND status != 'deleted'
            ORDER BY name
        """, [request.session.get('user_id')])
        
        ships = [
            {
                'id': row[0],
                'name': row[1],
                'type': row[2],
                'capacity': row[3],
                'current_port': row[4] or 'At Sea'
            }
            for row in cursor.fetchall()
        ]
        
        # Get routes available to the user
        cursor.execute("""
            SELECT r.route_id, r.name, 
                   r.origin_port_id, op.name as origin_port_name,
                   r.destination_port_id, dp.name as destination_port_name,
                   r.distance, r.duration
            FROM routes r
            JOIN ports op ON r.origin_port_id = op.port_id
            JOIN ports dp ON r.destination_port_id = dp.port_id
            WHERE r.owner_id = %s AND r.status != 'deleted'
            ORDER BY r.name
        """, [request.session.get('user_id')])
        
        routes = [
            {
                'id': row[0],
                'name': row[1],
                'origin_port_id': row[2],
                'origin_port': row[3],
                'destination_port_id': row[4],
                'destination_port': row[5],
                'distance': row[6],
                'duration': row[7]
            }
            for row in cursor.fetchall()
        ]
    
    context = {
        'ships': ships,
        'routes': routes,
        'username': request.session.get('username', 'User')
    }
    
    return render(request, 'create_schedule.html', context)

def create_schedule(request):
    """
    Handle the POST request for creating a new schedule with berth bookings
    """
    if request.method != 'POST':
        return redirect('create-schedule-form')
    
    # Get form data
    ship_id = request.POST.get('ship_id')
    route_id = request.POST.get('route_id')
    max_cargo = request.POST.get('max_cargo')
    status = request.POST.get('status')
    notes = request.POST.get('notes', '')
    
    # Departure and arrival times
    departure_date = request.POST.get('departure_date')
    arrival_date = request.POST.get('arrival_date')
    
    # Berth booking details
    origin_berth_id = request.POST.get('origin_berth_id')
    origin_berth_start = request.POST.get('origin_berth_start')
    origin_berth_end = request.POST.get('origin_berth_end')
    
    destination_berth_id = request.POST.get('destination_berth_id')
    destination_berth_start = request.POST.get('destination_berth_start')
    destination_berth_end = request.POST.get('destination_berth_end')
    
    # Validate required fields
    if not all([ship_id, route_id, departure_date, arrival_date, 
                origin_berth_id, origin_berth_start, origin_berth_end,
                destination_berth_id, destination_berth_start, destination_berth_end]):
        messages.error(request, "All fields are required")
        return redirect('create-schedule-form')
    
    # Validate time ranges
    try:
        # Convert string dates to datetime objects
        from datetime import datetime
        o_start = datetime.strptime(origin_berth_start, '%Y-%m-%d %H:%M')
        o_end = datetime.strptime(origin_berth_end, '%Y-%m-%d %H:%M')
        d_start = datetime.strptime(destination_berth_start, '%Y-%m-%d %H:%M')
        d_end = datetime.strptime(destination_berth_end, '%Y-%m-%d %H:%M')
        
        # Validate origin berth times
        if o_start >= o_end:
            messages.error(request, "Origin berth booking: Start time must be earlier than end time")
            return redirect('create-schedule-form')
        
        # Validate destination berth times
        if d_start >= d_end:
            messages.error(request, "Destination berth booking: Start time must be earlier than end time")
            return redirect('create-schedule-form')
            
    except ValueError as e:
        messages.error(request, f"Invalid date format: {str(e)}")
        return redirect('create-schedule-form')
    
    print("calling create schedule with berths")
    # Use stored procedure to create schedule with berth assignments
    with connection.cursor() as cursor:
        try:
            # Set up OUT parameters
            cursor.execute("SET @p_schedule_id = 0, @p_success = FALSE, @p_message = '';")

            # Escape notes to prevent SQL injection
            import pymysql
            safe_notes = pymysql.converters.escape_string(notes)
            
            # Call the stored procedure
            cursor.execute(f"""
            CALL create_schedule_with_berths(
                {ship_id}, {route_id}, {max_cargo}, '{status}', '{safe_notes}',
                '{departure_date}', '{arrival_date}',
                {origin_berth_id}, '{origin_berth_start}', '{origin_berth_end}',
                {destination_berth_id}, '{destination_berth_start}', '{destination_berth_end}',
                @p_schedule_id, @p_success, @p_message
            );
            """)
            
            # Get output parameters
            cursor.execute('SELECT @p_schedule_id, @p_success, @p_message;')
            schedule_id, success, message = cursor.fetchone()
            print("schedule_id", schedule_id)
            print("success", success)
            print("message", message)
            
            if success:
                messages.success(request, message)
                return redirect('manage-schedules')
            else:
                messages.error(request, message)
                return redirect('create-schedule-form')
                
        except Exception as e:
            # Log the error for debugging
            print(f"Error creating schedule: {str(e)}")
            
            # Handle constraint violation specifically
            if "valid_assignment_times" in str(e):
                messages.error(request, "Berth booking times are invalid: arrival time must be earlier than departure time")
            else:
                messages.error(request, f"Error creating schedule: {str(e)}")
            
            return redirect('create-schedule-form')

def get_available_berths(request, port_id):
    """
    API endpoint to get available berths for a port
    """
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid request method'}, status=400)
    
    try:
        # Parse JSON data
        data = json.loads(request.body)
        start_time = data.get('start_time')
        end_time = data.get('end_time')
        ship_type = data.get('ship_type')
        
        # Use stored procedure to get available berths
        with connection.cursor() as cursor:
            cursor.callproc('get_available_berths', [port_id, start_time, end_time])
            
            # Fetch results
            results = cursor.fetchall()
            
            berths = []
            for row in results:
                berth = {
                    'id': row[0],
                    'berth_number': row[1],
                    'type': row[2],
                    'length': row[3],
                    'width': row[4],
                    'depth': row[5],
                    'status': row[6]
                }
                
                # Filter by ship type if needed
                if ship_type:
                    # Match berths compatible with ship type
                    if (ship_type == 'container' and berth['type'] in ['container', 'multipurpose']) or \
                       (ship_type == 'bulk' and berth['type'] in ['bulk', 'multipurpose']) or \
                       (ship_type == 'tanker' and berth['type'] == 'tanker') or \
                       (ship_type == 'roro' and berth['type'] in ['roro', 'multipurpose']):
                        berths.append(berth)
                else:
                    berths.append(berth)
            
            return JsonResponse({'berths': berths})
            
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
    

def check_berth_availability_ajax(request):
    """
    AJAX endpoint to check berth availability
    """
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid request method'}, status=400)
    
    try:
        data = json.loads(request.body)
        berth_id = data.get('berth_id')
        start_time = data.get('start_time')
        end_time = data.get('end_time')
        
        if not all([berth_id, start_time, end_time]):
            return JsonResponse({'error': 'Missing required parameters'}, status=400)
        
        # Convert string dates to datetime objects if needed
        try:
            start_time = datetime.strptime(start_time, '%Y-%m-%d %H:%M')
            end_time = datetime.strptime(end_time, '%Y-%m-%d %H:%M')
        except (ValueError, TypeError):
            # Already in datetime format or invalid
            pass
        
        with connection.cursor() as cursor:

            cursor.execute("SET @p_is_available = 0, @p_conflict_details = '';")

    # Step 2: Call the procedure using those session variables
            cursor.execute(f"""
                CALL check_berth_availability(
                {berth_id}, 
                '{start_time}', 
                '{end_time}', 
                @p_is_available, 
                @p_conflict_details
                );
                """)

    # Step 3: Retrieve OUT parameters
            cursor.execute("SELECT @p_is_available, @p_conflict_details;")
            is_available, conflict_details = cursor.fetchone()

            print("is_available", is_available)
            print("conflict_details", conflict_details)

            return JsonResponse({
                'is_available': bool(is_available),
                'message': conflict_details
            })

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)