from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection
from django.http import JsonResponse
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
    
    # Check if berths are available for the selected times
    with connection.cursor() as cursor:
        # Check origin berth availability
        cursor.execute("""
            SELECT COUNT(*) FROM schedules 
            WHERE origin_berth_id = %s AND (
                (origin_berth_start <= %s AND origin_berth_end >= %s) OR
                (origin_berth_start <= %s AND origin_berth_end >= %s) OR
                (origin_berth_start >= %s AND origin_berth_end <= %s)
            )
        """, [
            origin_berth_id, 
            origin_berth_start, origin_berth_start,  # Starts during existing booking
            origin_berth_end, origin_berth_end,      # Ends during existing booking
            origin_berth_start, origin_berth_end     # Completely contains existing booking
        ])
        
        origin_conflicts = cursor.fetchone()[0]
        
        # Check destination berth availability
        cursor.execute("""
            SELECT COUNT(*) FROM schedules 
            WHERE destination_berth_id = %s AND (
                (destination_berth_start <= %s AND destination_berth_end >= %s) OR
                (destination_berth_start <= %s AND destination_berth_end >= %s) OR
                (destination_berth_start >= %s AND destination_berth_end <= %s)
            )
        """, [
            destination_berth_id, 
            destination_berth_start, destination_berth_start,  # Starts during existing booking
            destination_berth_end, destination_berth_end,      # Ends during existing booking
            destination_berth_start, destination_berth_end     # Completely contains existing booking
        ])
        
        destination_conflicts = cursor.fetchone()[0]
        
        if origin_conflicts > 0:
            messages.error(request, "The selected origin berth is not available for the specified time period")
            return redirect('create-schedule-form')
        
        if destination_conflicts > 0:
            messages.error(request, "The selected destination berth is not available for the specified time period")
            return redirect('create-schedule-form')
        
        try:
            # Create the schedule with berth assignments
            cursor.execute("""
                INSERT INTO schedules (
                    ship_id, route_id, max_cargo, status, notes,
                    departure_date, arrival_date,
                    origin_berth_id, origin_berth_start, origin_berth_end,
                    destination_berth_id, destination_berth_start, destination_berth_end
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, [
                ship_id, route_id, max_cargo, status, notes,
                departure_date, arrival_date,
                origin_berth_id, origin_berth_start, origin_berth_end,
                destination_berth_id, destination_berth_start, destination_berth_end
            ])
            
            # Update ship status if it's currently docked
            cursor.execute("""
                UPDATE ships SET status = 'in_transit' 
                WHERE ship_id = %s AND status = 'docked'
            """, [ship_id])
            
            # Update berth status to 'reserved' for future dates
            current_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            
            # For origin berth
            if origin_berth_start > current_datetime:
                cursor.execute("""
                    UPDATE berths SET status = 'reserved'
                    WHERE berth_id = %s AND status = 'active'
                """, [origin_berth_id])
            
            # For destination berth
            if destination_berth_start > current_datetime:
                cursor.execute("""
                    UPDATE berths SET status = 'reserved'
                    WHERE berth_id = %s AND status = 'active'
                """, [destination_berth_id])
            
            messages.success(request, "Schedule created successfully")
            return redirect('manage-schedules')
            
        except Exception as e:
            messages.error(request, f"Error creating schedule: {str(e)}")
            return redirect('create-schedule-form')
        
    return redirect('manage-schedules')

def get_available_berths(request, port_id):
    """
    API view to get available berths for a port with time-based filtering
    """
    start_time = request.GET.get('start')
    end_time = request.GET.get('end')
    ship_type = request.GET.get('ship_type')
    
    if not all([start_time, end_time]):
        return JsonResponse({'error': 'Start and end times are required'}, status=400)
    
    # Query berths compatible with ship type and available during the specified time
    with connection.cursor() as cursor:
        # Get all berths for the port that match the ship type
        if ship_type == 'container':
            type_filter = "AND (type = 'container' OR type = 'multipurpose')"
        elif ship_type == 'bulk':
            type_filter = "AND (type = 'bulk' OR type = 'multipurpose')"
        elif ship_type == 'tanker':
            type_filter = "AND type = 'tanker'"
        else:
            type_filter = ""
        
        cursor.execute(f"""
            SELECT berth_id, berth_number, type, length, width, depth, status
            FROM berths
            WHERE port_id = %s {type_filter} AND status = 'active'
        """, [port_id])
        
        all_berths = [
            {
                'id': row[0],
                'berth_number': row[1],
                'type': row[2],
                'length': row[3],
                'width': row[4],
                'depth': row[5],
                'status': row[6]
            }
            for row in cursor.fetchall()
        ]
        
        # Check for time conflicts with existing schedules
        available_berths = []
        for berth in all_berths:
            # Check if this berth is already booked during the requested time
            cursor.execute("""
                SELECT COUNT(*) FROM schedules 
                WHERE (
                    (origin_berth_id = %s AND (
                        (origin_berth_start <= %s AND origin_berth_end >= %s) OR
                        (origin_berth_start <= %s AND origin_berth_end >= %s) OR
                        (origin_berth_start >= %s AND origin_berth_end <= %s)
                    )) OR
                    (destination_berth_id = %s AND (
                        (destination_berth_start <= %s AND destination_berth_end >= %s) OR
                        (destination_berth_start <= %s AND destination_berth_end >= %s) OR
                        (destination_berth_start >= %s AND destination_berth_end <= %s)
                    ))
                )
            """, [
                berth['id'], 
                start_time, start_time,  # Starts during existing booking
                end_time, end_time,      # Ends during existing booking
                start_time, end_time,    # Completely contains existing booking
                berth['id'],
                start_time, start_time,  # Same checks for destination berth
                end_time, end_time,
                start_time, end_time
            ])
            
            conflicts = cursor.fetchone()[0]
            
            if conflicts == 0:
                berth['available'] = True
                available_berths.append(berth)
            else:
                berth['available'] = False
                berth['reason'] = "Already booked during this time"
    
    return JsonResponse({
        'berths': available_berths,
        'total_available': len(available_berths),
        'port_id': port_id
    })