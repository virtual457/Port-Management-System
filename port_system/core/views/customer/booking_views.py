from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.contrib import messages
from django.db import connection
from django.views.decorators.http import require_http_methods
from datetime import datetime, timedelta

# Import the role_required decorator
from ..views import role_required

@role_required('customer')
def book_cargo(request, schedule_id):
    """
    Handle booking cargo on a direct route.
    """
    if request.method not in ['GET', 'POST']:
        return redirect('find-shipping-options')
    
    user_id = request.session.get('user_id')
    cargo_id = request.GET.get('cargo_id')
    
    if not cargo_id:
        messages.error(request, "No cargo selected for booking")
        return redirect('find-shipping-options')
    
    # If form is submitted to confirm booking
    if request.method == 'POST':
        try:
            with connection.cursor() as cursor:
                # Get price information
                cursor.execute("""
                    SELECT 
                        r.cost_per_kg,
                        c.weight,
                        r.cost_per_kg * c.weight AS total_price
                    FROM 
                        schedules s
                    JOIN 
                        routes r ON s.route_id = r.route_id
                    JOIN 
                        cargo c ON c.cargo_id = %s
                    WHERE 
                        s.schedule_id = %s
                """, [cargo_id, schedule_id])
                
                price_info = cursor.fetchone()
                if not price_info:
                    messages.error(request, "Could not calculate booking price")
                    return redirect('find-shipping-options')
                
                total_price = price_info[2]
                
                # Create the booking
                cursor.execute("""
                    INSERT INTO cargo_bookings (
                        cargo_id, schedule_id, user_id, 
                        booking_date, booking_status, payment_status, 
                        price, notes
                    ) VALUES (
                        %s, %s, %s, 
                        NOW(), 'confirmed', 'paid', 
                        %s, %s
                    )
                """, [
                    cargo_id, schedule_id, user_id,
                    total_price, request.POST.get('notes', '')
                ])
                
                # Update cargo status
                cursor.execute("""
                    UPDATE cargo 
                    SET status = 'booked'
                    WHERE cargo_id = %s AND user_id = %s
                """, [cargo_id, user_id])
                
                # Update schedule available capacity
                cursor.execute("""
                    UPDATE schedules
                    SET max_cargo = max_cargo - %s
                    WHERE schedule_id = %s
                """, [price_info[1], schedule_id])
                
                booking_id = cursor.lastrowid
                messages.success(request, f"Cargo booked successfully! Booking ID: {booking_id}")
                
                return redirect('customer-bookings')  # Redirect to bookings page
        
        except Exception as e:
            messages.error(request, f"Error booking cargo: {str(e)}")
            return redirect('find-shipping-options')
    
    # Display booking confirmation page
    try:
        with connection.cursor() as cursor:
            # Get schedule details
            cursor.execute("""
                SELECT 
                    s.schedule_id,
                    s.ship_id,
                    ships.name AS ship_name,
                    ships.ship_type,
                    r.route_id,
                    r.name AS route_name,
                    op.name AS origin_port,
                    dp.name AS destination_port,
                    s.departure_date,
                    s.arrival_date,
                    r.cost_per_kg,
                    r.distance,
                    ST_Y(op.location) AS origin_lat, 
                    ST_X(op.location) AS origin_lng,
                    ST_Y(dp.location) AS destination_lat, 
                    ST_X(dp.location) AS destination_lng
                FROM 
                    schedules s
                JOIN 
                    routes r ON s.route_id = r.route_id
                JOIN 
                    ships ON s.ship_id = ships.ship_id
                JOIN 
                    ports op ON r.origin_port_id = op.port_id
                JOIN 
                    ports dp ON r.destination_port_id = dp.port_id
                WHERE 
                    s.schedule_id = %s
            """, [schedule_id])
            
            schedule_data = cursor.fetchone()
            if not schedule_data:
                messages.error(request, "Schedule not found")
                return redirect('find-shipping-options')
            
            schedule_columns = [col[0] for col in cursor.description]
            schedule = dict(zip(schedule_columns, schedule_data))
            
            # Get cargo details
            cursor.execute("""
                SELECT 
                    cargo_id, description, cargo_type, weight, dimensions
                FROM 
                    cargo
                WHERE 
                    cargo_id = %s AND user_id = %s
            """, [cargo_id, user_id])
            
            cargo_data = cursor.fetchone()
            if not cargo_data:
                messages.error(request, "Cargo not found or does not belong to you")
                return redirect('find-shipping-options')
            
            cargo_columns = [col[0] for col in cursor.description]
            cargo = dict(zip(cargo_columns, cargo_data))
            
            # Calculate total price
            total_price = schedule['cost_per_kg'] * cargo['weight']
            
            # Get username
            cursor.execute("SELECT username FROM users WHERE user_id = %s", [user_id])
            username = cursor.fetchone()[0]
    
    except Exception as e:
        messages.error(request, f"Error retrieving booking details: {str(e)}")
        return redirect('find-shipping-options')
    
    context = {
        'username': username,
        'schedule': schedule,
        'cargo': cargo,
        'total_price': total_price,
        'booking_type': 'direct'
    }
    
    return render(request, 'book_cargo.html', context)


@role_required('customer')
def book_connected_route(request, schedule_ids):
    """
    Handle booking cargo on a connected route with multiple segments.
    """
    if request.method not in ['GET', 'POST']:
        return redirect('find-shipping-options')
    
    user_id = request.session.get('user_id')
    cargo_id = request.GET.get('cargo_id')
    
    if not cargo_id:
        messages.error(request, "No cargo selected for booking")
        return redirect('find-shipping-options')
    
    # If form is submitted to confirm booking
    if request.method == 'POST':
        try:
            with connection.cursor() as cursor:
                # Parse the schedule IDs
                schedule_id_list = schedule_ids.split(',')
                
                # Get origin and destination port IDs
                cursor.execute("""
                    SELECT 
                        r1.origin_port_id AS origin_port_id,
                        r2.destination_port_id AS destination_port_id
                    FROM 
                        schedules s1
                    JOIN 
                        routes r1 ON s1.route_id = r1.route_id
                    JOIN 
                        schedules s2 ON s2.schedule_id = %s
                    JOIN 
                        routes r2 ON s2.route_id = r2.route_id
                    WHERE 
                        s1.schedule_id = %s
                """, [schedule_id_list[-1], schedule_id_list[0]])
                
                port_data = cursor.fetchone()
                if not port_data:
                    messages.error(request, "Could not determine route endpoints")
                    return redirect('find-shipping-options')
                
                origin_port_id, destination_port_id = port_data
                
                # Get total price by summing segment prices
                placeholders = ','.join(['%s'] * len(schedule_id_list))
                query = f"""
                    SELECT 
                        SUM(r.cost_per_kg * c.weight) AS total_price,
                        c.weight
                    FROM 
                        cargo c
                    JOIN (
                        SELECT 
                            schedule_id, 
                            route_id
                        FROM 
                            schedules
                        WHERE 
                            schedule_id IN ({placeholders})
                    ) s ON 1=1
                    JOIN 
                        routes r ON s.route_id = r.route_id
                    WHERE 
                        c.cargo_id = %s
                    GROUP BY 
                        c.weight
                """
                
                cursor.execute(query, schedule_id_list + [cargo_id])
                
                price_data = cursor.fetchone()
                if not price_data:
                    messages.error(request, "Could not calculate booking price")
                    return redirect('find-shipping-options')
                
                total_price, cargo_weight = price_data
                
                # Create the connected booking
                cursor.execute("""
                    INSERT INTO connected_bookings (
                        cargo_id, user_id, origin_port_id, destination_port_id,
                        booking_date, booking_status, payment_status, 
                        total_price, notes
                    ) VALUES (
                        %s, %s, %s, %s,
                        NOW(), 'confirmed', 'paid', 
                        %s, %s
                    )
                """, [
                    cargo_id, user_id, origin_port_id, destination_port_id,
                    total_price, request.POST.get('notes', '')
                ])
                
                connected_booking_id = cursor.lastrowid
                
                # Add each segment to the connected_booking_segments table
                for i, schedule_id in enumerate(schedule_id_list):
                    # Calculate segment price
                    cursor.execute("""
                        SELECT 
                            r.cost_per_kg * %s AS segment_price
                        FROM 
                            schedules s
                        JOIN 
                            routes r ON s.route_id = r.route_id
                        WHERE 
                            s.schedule_id = %s
                    """, [cargo_weight, schedule_id])
                    
                    segment_price = cursor.fetchone()[0]
                    
                    # Insert segment
                    cursor.execute("""
                        INSERT INTO connected_booking_segments (
                            connected_booking_id, schedule_id, segment_order, segment_price
                        ) VALUES (
                            %s, %s, %s, %s
                        )
                    """, [connected_booking_id, schedule_id, i + 1, segment_price])
                    
                    # Update schedule available capacity
                    cursor.execute("""
                        UPDATE schedules
                        SET max_cargo = max_cargo - %s
                        WHERE schedule_id = %s
                    """, [cargo_weight, schedule_id])
                
                # Update cargo status
                cursor.execute("""
                    UPDATE cargo 
                    SET status = 'booked'
                    WHERE cargo_id = %s AND user_id = %s
                """, [cargo_id, user_id])
                
                messages.success(request, f"Connected route booked successfully! Booking ID: {connected_booking_id}")
                
                return redirect('customer-bookings')  # Redirect to bookings page
        
        except Exception as e:
            messages.error(request, f"Error booking connected route: {str(e)}")
            return redirect('find-shipping-options')
    
    # Display booking confirmation page
    try:
        with connection.cursor() as cursor:
            # Parse the schedule IDs
            schedule_id_list = schedule_ids.split(',')
            
            # Get cargo details
            cursor.execute("""
                SELECT 
                    cargo_id, description, cargo_type, weight, dimensions
                FROM 
                    cargo
                WHERE 
                    cargo_id = %s AND user_id = %s
            """, [cargo_id, user_id])
            
            cargo_data = cursor.fetchone()
            if not cargo_data:
                messages.error(request, "Cargo not found or does not belong to you")
                return redirect('find-shipping-options')
            
            cargo_columns = [col[0] for col in cursor.description]
            cargo = dict(zip(cargo_columns, cargo_data))
            
            # Get segments data
            segments = []
            total_price = 0
            
            for schedule_id in schedule_id_list:
                cursor.execute("""
                    SELECT
                        s.schedule_id,
                        s.ship_id,
                        ships.name AS ship_name,
                        ships.ship_type,
                        r.origin_port_id,
                        op.name AS origin_port,
                        ST_Y(op.location) AS origin_lat,
                        ST_X(op.location) AS origin_lng,
                        r.destination_port_id,
                        dp.name AS destination_port,
                        ST_Y(dp.location) AS destination_lat,
                        ST_X(dp.location) AS destination_lng,
                        s.departure_date,
                        s.arrival_date,
                        r.cost_per_kg,
                        r.distance
                    FROM
                        schedules s
                    JOIN
                        routes r ON s.route_id = r.route_id
                    JOIN
                        ships ON s.ship_id = ships.ship_id
                    JOIN
                        ports op ON r.origin_port_id = op.port_id
                    JOIN
                        ports dp ON r.destination_port_id = dp.port_id
                    WHERE
                        s.schedule_id = %s
                """, [schedule_id])
                
                segment_data = cursor.fetchone()
                if segment_data:
                    segment_columns = [col[0] for col in cursor.description]
                    segment = dict(zip(segment_columns, segment_data))
                    
                    # Calculate segment price
                    segment_price = segment['cost_per_kg'] * cargo['weight']
                    segment['segment_price'] = segment_price
                    total_price += segment_price
                    
                    # Calculate duration in days
                    duration = (segment['arrival_date'] - segment['departure_date']).days
                    segment['duration'] = duration
                    
                    segments.append(segment)
            
            # Calculate connection times between segments
            for i in range(len(segments) - 1):
                current_segment = segments[i]
                next_segment = segments[i + 1]
                
                connection_time = (next_segment['departure_date'] - current_segment['arrival_date']).days
                current_segment['connection_time'] = connection_time
            
            # Get first departure and last arrival
            first_departure = segments[0]['departure_date'] if segments else None
            last_arrival = segments[-1]['arrival_date'] if segments else None
            total_duration = (last_arrival - first_departure).days if first_departure and last_arrival else 0
            
            # Get username
            cursor.execute("SELECT username FROM users WHERE user_id = %s", [user_id])
            username = cursor.fetchone()[0]
    
    except Exception as e:
        messages.error(request, f"Error retrieving booking details: {str(e)}")
        return redirect('find-shipping-options')
    
    context = {
        'username': username,
        'segments': segments,
        'cargo': cargo,
        'total_price': total_price,
        'first_departure': first_departure,
        'last_arrival': last_arrival,
        'total_duration': total_duration,
        'booking_type': 'connected',
        'schedule_ids': schedule_ids
    }
    
    return render(request, 'book_cargo.html', context)


@role_required('customer')
def view_bookings(request):
    """
    View for displaying a customer's bookings (both direct and connected).
    """
    user_id = request.session.get('user_id')
    direct_bookings = []
    connected_bookings = []
    
    try:
        with connection.cursor() as cursor:
            # Get direct bookings
            cursor.execute("""
                SELECT 
                    b.booking_id,
                    b.cargo_id,
                    c.description AS cargo_description,
                    b.schedule_id,
                    s.departure_date,
                    s.arrival_date,
                    r.name AS route_name,
                    op.name AS origin_port,
                    dp.name AS destination_port,
                    b.booking_status,
                    b.payment_status,
                    b.price,
                    b.booking_date,
                    ships.name AS ship_name
                FROM 
                    cargo_bookings b
                JOIN 
                    cargo c ON b.cargo_id = c.cargo_id
                JOIN 
                    schedules s ON b.schedule_id = s.schedule_id
                JOIN 
                    routes r ON s.route_id = r.route_id
                JOIN 
                    ships ON s.ship_id = ships.ship_id
                JOIN 
                    ports op ON r.origin_port_id = op.port_id
                JOIN 
                    ports dp ON r.destination_port_id = dp.port_id
                WHERE 
                    b.user_id = %s
                ORDER BY 
                    b.booking_date DESC
            """, [user_id])
            
            columns = [col[0] for col in cursor.description]
            direct_bookings = [dict(zip(columns, row)) for row in cursor.fetchall()]
            
            # Get connected bookings
            cursor.execute("""
                SELECT 
                    cb.connected_booking_id,
                    cb.cargo_id,
                    c.description AS cargo_description,
                    op.name AS origin_port,
                    dp.name AS destination_port,
                    cb.booking_status,
                    cb.payment_status,
                    cb.total_price,
                    cb.booking_date,
                    COUNT(cbs.segment_id) AS total_segments
                FROM 
                    connected_bookings cb
                JOIN 
                    cargo c ON cb.cargo_id = c.cargo_id
                JOIN 
                    ports op ON cb.origin_port_id = op.port_id
                JOIN 
                    ports dp ON cb.destination_port_id = dp.port_id
                JOIN 
                    connected_booking_segments cbs ON cb.connected_booking_id = cbs.connected_booking_id
                WHERE 
                    cb.user_id = %s
                GROUP BY 
                    cb.connected_booking_id, cb.cargo_id, c.description, op.name, dp.name,
                    cb.booking_status, cb.payment_status, cb.total_price, cb.booking_date
                ORDER BY 
                    cb.booking_date DESC
            """, [user_id])
            
            columns = [col[0] for col in cursor.description]
            connected_bookings = [dict(zip(columns, row)) for row in cursor.fetchall()]
            
            # For each connected booking, get first departure and last arrival
            for booking in connected_bookings:
                cursor.execute("""
                    SELECT 
                        MIN(s.departure_date) AS first_departure,
                        MAX(s.arrival_date) AS last_arrival
                    FROM 
                        connected_booking_segments cbs
                    JOIN 
                        schedules s ON cbs.schedule_id = s.schedule_id
                    WHERE 
                        cbs.connected_booking_id = %s
                """, [booking['connected_booking_id']])
                
                dates = cursor.fetchone()
                if dates:
                    booking['first_departure'] = dates[0]
                    booking['last_arrival'] = dates[1]
            
            # Get username
            cursor.execute("SELECT username FROM users WHERE user_id = %s", [user_id])
            username = cursor.fetchone()[0]
    
    except Exception as e:
        messages.error(request, f"Error retrieving bookings: {str(e)}")
    
    context = {
        'username': username,
        'direct_bookings': direct_bookings,
        'connected_bookings': connected_bookings
    }
    
    return render(request, 'customer_booking.html', context)


@role_required('customer')
def view_booking_details(request, booking_id, booking_type):
    """
    View for displaying detailed information about a specific booking.
    """
    user_id = request.session.get('user_id')
    
    try:
        with connection.cursor() as cursor:
            if booking_type == 'direct':
                # Get direct booking details
                cursor.execute("""
                    SELECT 
                        b.booking_id,
                        b.cargo_id,
                        c.description AS cargo_description,
                        c.cargo_type,
                        c.weight AS cargo_weight,
                        c.dimensions AS cargo_dimensions,
                        b.schedule_id,
                        s.departure_date,
                        s.arrival_date,
                        r.name AS route_name,
                        op.name AS origin_port,
                        ST_Y(op.location) AS origin_lat,
                        ST_X(op.location) AS origin_lng,
                        dp.name AS destination_port,
                        ST_Y(dp.location) AS destination_lat,
                        ST_X(dp.location) AS destination_lng,
                        r.distance,
                        b.booking_status,
                        b.payment_status,
                        b.price,
                        b.booking_date,
                        b.notes,
                        ships.name AS ship_name,
                        ships.ship_type
                    FROM 
                        cargo_bookings b
                    JOIN 
                        cargo c ON b.cargo_id = c.cargo_id
                    JOIN 
                        schedules s ON b.schedule_id = s.schedule_id
                    JOIN 
                        routes r ON s.route_id = r.route_id
                    JOIN 
                        ships ON s.ship_id = ships.ship_id
                    JOIN 
                        ports op ON r.origin_port_id = op.port_id
                    JOIN 
                        ports dp ON r.destination_port_id = dp.port_id
                    WHERE 
                        b.booking_id = %s AND b.user_id = %s
                """, [booking_id, user_id])
                
                result = cursor.fetchone()
                if not result:
                    messages.error(request, "Booking not found or does not belong to you")
                    return redirect('customer-bookings')
                
                columns = [col[0] for col in cursor.description]
                booking = dict(zip(columns, result))
                segments = None
                
            else:  # Connected booking
                # Get connected booking details
                cursor.execute("""
                    SELECT 
                        cb.connected_booking_id,
                        cb.cargo_id,
                        c.description AS cargo_description,
                        c.cargo_type,
                        c.weight AS cargo_weight,
                        c.dimensions AS cargo_dimensions,
                        op.name AS origin_port,
                        dp.name AS destination_port,
                        cb.booking_status,
                        cb.payment_status,
                        cb.total_price,
                        cb.booking_date,
                        cb.notes
                    FROM 
                        connected_bookings cb
                    JOIN 
                        cargo c ON cb.cargo_id = c.cargo_id
                    JOIN 
                        ports op ON cb.origin_port_id = op.port_id
                    JOIN 
                        ports dp ON cb.destination_port_id = dp.port_id
                    WHERE 
                        cb.connected_booking_id = %s AND cb.user_id = %s
                """, [booking_id, user_id])
                
                result = cursor.fetchone()
                if not result:
                    messages.error(request, "Connected booking not found or does not belong to you")
                    return redirect('customer-bookings')
                
                columns = [col[0] for col in cursor.description]
                booking = dict(zip(columns, result))
                
                # Get segment details for this connected booking
                cursor.execute("""
                    SELECT 
                        cbs.segment_id,
                        cbs.segment_order,
                        cbs.schedule_id,
                        cbs.segment_price,
                        s.departure_date,
                        s.arrival_date,
                        r.name AS route_name,
                        op.name AS origin_port,
                        op.port_id AS origin_port_id,
                        ST_Y(op.location) AS origin_lat,
                        ST_X(op.location) AS origin_lng,
                        dp.name AS destination_port,
                        dp.port_id AS destination_port_id,
                        ST_Y(dp.location) AS destination_lat,
                        ST_X(dp.location) AS destination_lng,
                        r.distance,
                        ships.name AS ship_name,
                        ships.ship_type
                    FROM 
                        connected_booking_segments cbs
                    JOIN 
                        schedules s ON cbs.schedule_id = s.schedule_id
                    JOIN 
                        routes r ON s.route_id = r.route_id
                    JOIN 
                        ships ON s.ship_id = ships.ship_id
                    JOIN 
                        ports op ON r.origin_port_id = op.port_id
                    JOIN 
                        ports dp ON r.destination_port_id = dp.port_id
                    WHERE 
                        cbs.connected_booking_id = %s
                    ORDER BY 
                        cbs.segment_order
                """, [booking_id])
                
                columns = [col[0] for col in cursor.description]
                segments = [dict(zip(columns, row)) for row in cursor.fetchall()]
                
                # Calculate connection times
                for i in range(len(segments) - 1):
                    current_segment = segments[i]
                    next_segment = segments[i + 1]
                    
                    current_arrival = current_segment['arrival_date']
                    next_departure = next_segment['departure_date']
                    
                    connection_hours = (next_departure - current_arrival).total_seconds() / 3600
                    current_segment['connection_time'] = round(connection_hours / 24, 1)  # Convert to days
            
            # Get username
            cursor.execute("SELECT username FROM users WHERE user_id = %s", [user_id])
            username = cursor.fetchone()[0]
    
    except Exception as e:
        messages.error(request, f"Error retrieving booking details: {str(e)}")
        return redirect('customer-bookings')
    
    context = {
        'username': username,
        'booking': booking,
        'segments': segments,
        'booking_type': booking_type
    }
    
    return render(request, 'booking_details.html', context)


@role_required('customer')
def cancel_booking(request, booking_id, booking_type):
    """
    Handle cancellation of a booking.
    """
    if request.method != 'POST':
        return redirect('customer-bookings')
    
    user_id = request.session.get('user_id')
    
    try:
        with connection.cursor() as cursor:
            if booking_type == 'direct':
                # Get cargo ID and schedule ID for this booking
                cursor.execute("""
                    SELECT cargo_id, schedule_id
                    FROM cargo_bookings
                    WHERE booking_id = %s AND user_id = %s
                """, [booking_id, user_id])
                
                booking_data = cursor.fetchone()
                if not booking_data:
                    messages.error(request, "Booking not found or does not belong to you")
                    return redirect('customer-bookings')
                
                cargo_id, schedule_id = booking_data
                
                # Get cargo weight to restore schedule capacity
                cursor.execute("SELECT weight FROM cargo WHERE cargo_id = %s", [cargo_id])
                cargo_weight = cursor.fetchone()[0]
                
                # Update booking status
                cursor.execute("""
                    UPDATE cargo_bookings 
                    SET booking_status = 'cancelled', payment_status = 'refunded'
                    WHERE booking_id = %s AND user_id = %s
                """, [booking_id, user_id])
                
                # Update cargo status back to pending
                cursor.execute("""
                    UPDATE cargo 
                    SET status = 'pending'
                    WHERE cargo_id = %s
                """, [cargo_id])
                
                # Restore schedule capacity
                cursor.execute("""
                    UPDATE schedules
                    SET max_cargo = max_cargo + %s
                    WHERE schedule_id = %s
                """, [cargo_weight, schedule_id])
                
                messages.success(request, "Booking cancelled successfully. Your payment will be refunded.")
            
            else:  # Connected booking
                # Get cargo ID and all schedule IDs for this booking
                cursor.execute("""
                    SELECT cb.cargo_id, cbs.schedule_id
                    FROM connected_bookings cb
                    JOIN connected_booking_segments cbs ON cb.connected_booking_id = cbs.connected_booking_id
                    WHERE cb.connected_booking_id = %s AND cb.user_id = %s
                """, [booking_id, user_id])
                
                booking_data = cursor.fetchall()
                if not booking_data:
                    messages.error(request, "Booking not found or does not belong to you")
                    return redirect('customer-bookings')
                
                cargo_id = booking_data[0][0]
                schedule_ids = [row[1] for row in booking_data]
                
                # Get cargo weight to restore schedule capacity
                cursor.execute("SELECT weight FROM cargo WHERE cargo_id = %s", [cargo_id])
                cargo_weight = cursor.fetchone()[0]
                
                # Update connected booking status
                cursor.execute("""
                    UPDATE connected_bookings 
                    SET booking_status = 'cancelled', payment_status = 'refunded'
                    WHERE connected_booking_id = %s AND user_id = %s
                """, [booking_id, user_id])
                
                # Update cargo status back to pending
                cursor.execute("""
                    UPDATE cargo 
                    SET status = 'pending'
                    WHERE cargo_id = %s
                """, [cargo_id])
                
                # Restore schedule capacity for all segments
                for schedule_id in schedule_ids:
                    cursor.execute("""
                        UPDATE schedules
                        SET max_cargo = max_cargo + %s
                        WHERE schedule_id = %s
                    """, [cargo_weight, schedule_id])
                
                messages.success(request, "Connected booking cancelled successfully. Your payment will be refunded.")
    
    except Exception as e:
        messages.error(request, f"Error cancelling booking: {str(e)}")
    
    return redirect('customer-bookings')