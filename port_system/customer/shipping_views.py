@role_required('customer')
def book_connected_route(request, route_id, cargo_id, booking_type):
    """
    Handle booking cargo on a connected route with multiple segments.
    """
    if request.method != 'GET' and request.method != 'POST':
        return redirect('find-shipping-options')
    
    user_id = request.session.get('user_id')
    
    if not cargo_id:
        messages.error(request, "No cargo selected for booking")
        return redirect('find-shipping-options')
    
    # If form is submitted to confirm booking
    if request.method == 'POST':
        try:
            with connection.cursor() as cursor:
                # First, we need to get all the schedule IDs for this route
                schedule_ids = route_id.split(',')  # Route ID contains concatenated schedule IDs
                
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
                """, [schedule_ids[-1], schedule_ids[0]])
                
                port_data = cursor.fetchone()
                if not port_data:
                    messages.error(request, "Could not determine route endpoints")
                    return redirect('find-shipping-options')
                
                origin_port_id, destination_port_id = port_data
                
                # Get total price by summing segment prices
                cursor.execute("""
                    SELECT 
                        SUM(r.cost_per_kg * c.weight) AS total_price,
                        c.weight
                    FROM 
                        cargo c
                    JOIN (SELECT schedule_id, route_id FROM schedules WHERE schedule_id IN ({0})) s ON 1=1
                    JOIN routes r ON s.route_id = r.route_id
                    WHERE c.cargo_id = %s
                    GROUP BY c.weight
                """.format(','.join(['%s'] * len(schedule_ids))), schedule_ids + [cargo_id])
                
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
                for i, schedule_id in enumerate(schedule_ids):
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
            # Get schedule IDs for this route
            schedule_ids = route_id.split(',')
            
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
            segments = get_connected_route_segments(route_id)
            
            # Calculate total price and journey details
            total_price = 0
            for segment in segments:
                segment_price = segment['cost_per_kg'] * cargo['weight'] if 'cost_per_kg' in segment else 0
                segment['segment_price'] = segment_price
                total_price += segment_price
            
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
        'route_id': route_id
    }
    
    return render(request, 'book_cargo.html', context) 