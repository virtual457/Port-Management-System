from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.contrib import messages
from django.db import connection
from django.core.paginator import Paginator
from django.views.decorators.http import require_http_methods
from datetime import datetime, timedelta
import json

# Import the role_required decorator
from ..views import role_required




@role_required('customer')
def customer_support(request):
    """
    View function for the customer support page.
    
    This page displays humorous maritime-themed support content,
    including contact methods, FAQs, and a support ticket form.
    """
    # Get the logged-in user's username to display in the navbar
    username = request.user.username
    
    # You can add any context data needed for the template
    context = {
        'username': username,
        # Add other context variables as needed
        'page_title': 'S.O.S. Support Center',
    }
    
    return render(request, 'customer_support.html', context)

@role_required('customer')
def find_shipping_options(request):
    """
    View for customers to search for shipping options.
    Handles both direct and connecting routes with up to 2 connections.
    """
    print("=== Starting find_shipping_options ===")
    user_id = request.session.get('user_id')
    print(f"User ID: {user_id}")
    is_search_submitted = False
    shipping_options = []
    direct_routes = []
    connected_routes = []
    
    # Get all available ports for the origin/destination dropdowns
    print("=== Fetching ports ===")
    with connection.cursor() as cursor:
        # Use stored procedure for getting ports
        cursor.callproc('get_active_ports')
        
        # Get the result set
        result = cursor.fetchall()
        
        ports = [
            {
                'id': row[0],
                'name': row[1],
                'country': row[2],
                'lat': row[3],
                'lng': row[4]
            }
            for row in result
        ]
        print(f"Found {len(ports)} ports")

        # Get user's cargo items using stored procedure
        print("=== Fetching user cargo ===")
        cursor.callproc('get_user_cargo', [user_id])
        
        # Get the result set
        result = cursor.fetchall()
        
        user_cargo = [
            {
                'id': row[0],
                'description': row[1],
                'type': row[2],
                'weight': row[3],
                'dimensions': row[4]
            }
            for row in result
        ]
        print(f"Found {len(user_cargo)} cargo items")
        
        # Get username for display using stored procedure
        print("=== Fetching username ===")
        cursor.callproc('get_user_username', [user_id])
        
        # Get the result set
        username_result = cursor.fetchone()
        username = username_result[0] if username_result else "Customer"
        print(f"Username: {username}")
    
    # If search form is submitted
    if request.GET.get('origin') and request.GET.get('destination') and request.GET.get('cargo_id'):
        print("=== Search form submitted ===")
        is_search_submitted = True
        origin_port_id = request.GET.get('origin')
        destination_port_id = request.GET.get('destination')
        cargo_id = request.GET.get('cargo_id')
        earliest_date = request.GET.get('earliest_date')
        latest_date = request.GET.get('latest_date')
        max_connections = int(request.GET.get('max_connections', 1)) if 'allow_connections' in request.GET else 0
        
        print(f"Search parameters - Origin: {origin_port_id}, Destination: {destination_port_id}, Cargo: {cargo_id}")
        print(f"Date range - From: {earliest_date}, To: {latest_date}")
        print(f"Max connections: {max_connections}")
        
        try:
            # Call the find_all_routes procedure
            print("=== Calling find_all_routes ===")
            with connection.cursor() as cursor:
                cursor.callproc('find_all_routes', [
                    origin_port_id,
                    destination_port_id,
                    earliest_date,
                    latest_date,
                    cargo_id,
                    max_connections
                ])
                
                # Process result set
                if cursor.description:  # Check if we have results
                    columns = [col[0] for col in cursor.description]
                    for row in cursor.fetchall():
                        route_dict = dict(zip(columns, row))
                        # Only add to direct_routes if the route_type is actually 'direct'
                        if route_dict['route_type'] == 'direct':
                            direct_routes.append(route_dict)
                        # If it's a connected route, process it and add to connected_routes
                        elif route_dict['route_type'] == 'connected':
                            # Get segment details for connected routes
                            segments = get_connected_route_segments(route_dict['schedule_ids'])
                            route_dict['segments'] = segments
                            
                            # Calculate total duration and connection time
                            if segments and len(segments) >= 2:
                                first_departure = segments[0]['departure_date']
                                last_arrival = segments[-1]['arrival_date']
                                
                                # Add first and last port names and total duration
                                route_dict['first_origin'] = segments[0]['origin_port']
                                route_dict['last_destination'] = segments[-1]['destination_port']
                                route_dict['first_departure'] = first_departure
                                route_dict['last_arrival'] = last_arrival
                                route_dict['total_duration'] = (last_arrival - first_departure).days
                                
                                # Calculate total connection time
                                total_connection_time = 0
                                for i in range(len(segments) - 1):
                                    if 'connection_time' in segments[i]:
                                        total_connection_time += segments[i]['connection_time']
                                
                                route_dict['total_connection_time'] = total_connection_time
                            
                            connected_routes.append(route_dict)
                
                print(f"Found {len(direct_routes)} direct routes and {len(connected_routes)} connected routes")
            
            # Combine all routes for the global shipping_options list
            shipping_options = direct_routes + connected_routes
            print(f"Total shipping options: {len(shipping_options)}")
        
        except Exception as e:
            print(f"Error in find_shipping_options: {str(e)}")
            print(f"Error type: {type(e)}")
            messages.error(request, f"Error searching for shipping options: {str(e)}")

        with connection.cursor() as cursor:
            for route in direct_routes:
                if 'origin_lat' not in route or 'origin_lng' not in route or 'destination_lat' not in route or 'destination_lng' not in route:
                    cursor.execute("""
                        SELECT 
                            ST_Y(op.location) AS origin_lat,
                            ST_X(op.location) AS origin_lng,
                            ST_Y(dp.location) AS destination_lat,
                            ST_X(dp.location) AS destination_lng
                        FROM 
                            routes r
                        JOIN 
                            ports op ON r.origin_port_id = op.port_id
                        JOIN 
                            ports dp ON r.destination_port_id = dp.port_id
                        WHERE 
                            r.route_id = %s
                    """, [route.get('route_id')])
                    
                    loc_data = cursor.fetchone()
                    if loc_data:
                        route['origin_lat'] = loc_data[0]
                        route['origin_lng'] = loc_data[1]
                        route['destination_lat'] = loc_data[2]
                        route['destination_lng'] = loc_data[3]
    
    context = {
        'username': username,
        'ports': ports,
        'user_cargo': user_cargo,
        'is_search_submitted': is_search_submitted,
        'shipping_options': shipping_options,
        'direct_routes': direct_routes,
        'connected_routes': connected_routes
    }
    
    return render(request, 'find_shipping_options.html', context)

def get_connected_route_segments(schedule_ids):
    """
    Helper function to get detailed information about each segment in a connected route.
    """
    segments = []
    
    with connection.cursor() as cursor:
        # Convert comma-separated schedule IDs to list
        schedule_id_list = schedule_ids.split(',')
        
        for i, schedule_id in enumerate(schedule_id_list):
            # Use stored procedure to get segment details
            cursor.callproc('get_route_segment_details', [schedule_id])
            
            # Get the result set
            segment_data = cursor.fetchone()
            if segment_data:
                columns = [col[0] for col in cursor.description]
                segment = dict(zip(columns, segment_data))
                
                # Calculate connection time to next segment (if not the last segment)
                if i < len(schedule_id_list) - 1:
                    # Use stored procedure to get connection time
                    cursor.callproc('get_connection_time', [
                        schedule_id,
                        schedule_id_list[i + 1]
                    ])
                    
                    # Get the result set
                    connection_time = cursor.fetchone()
                    segment['connection_time'] = round(connection_time[0], 1) if connection_time else 0
                
                segments.append(segment)
    
    return segments

@role_required('customer')
def book_direct_cargo(request, schedule_id):
    """
    Handle booking cargo on a direct route.
    """
    if request.method != 'GET' and request.method != 'POST':
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
                # Set up OUT parameters in the database session
                cursor.execute("SET @p_booking_id = 0")
                cursor.execute("SET @p_success = FALSE")
                cursor.execute("SET @p_message = ''")
                
                # Call the stored procedure with properly prepared parameters
                cursor.execute("""
                    CALL create_direct_booking(
                        %s, %s, %s, %s, 
                        @p_booking_id, @p_success, @p_message
                    )
                """, [
                    cargo_id,
                    schedule_id,
                    user_id,
                    request.POST.get('notes', '')
                ])
                
                # Retrieve the output parameters
                cursor.execute("SELECT @p_booking_id, @p_success, @p_message")
                result = cursor.fetchone()
                
                if result:
                    booking_id = result[0]
                    success = bool(result[1])
                    message = result[2]
                    
                    if success:
                        messages.success(request, message)
                        return redirect('customer-bookings')
                    else:
                        messages.error(request, message)
                        return redirect('find-shipping-options')
                else:
                    messages.error(request, "Error processing booking")
                    return redirect('find-shipping-options')
        
        except Exception as e:
            messages.error(request, f"Error booking cargo: {str(e)}")
            return redirect('find-shipping-options')
    
    # Display booking confirmation page
    try:
        with connection.cursor() as cursor:
            # Use stored procedure to get schedule details
            cursor.callproc('get_schedule_details', [schedule_id])
            
            # Get the result set
            schedule_data = cursor.fetchone()
            if not schedule_data:
                messages.error(request, "Schedule not found")
                return redirect('find-shipping-options')
            
            # Create dictionary from result
            schedule_columns = [col[0] for col in cursor.description]
            schedule = dict(zip(schedule_columns, schedule_data))
            
            # Use stored procedure to get cargo details
            cursor.callproc('get_cargo_details', [cargo_id, user_id])
            
            # Get the result set
            cargo_data = cursor.fetchone()
            if not cargo_data:
                messages.error(request, "Cargo not found or does not belong to you")
                return redirect('find-shipping-options')
            
            # Create dictionary from result
            cargo_columns = [col[0] for col in cursor.description]
            cargo = dict(zip(cargo_columns, cargo_data))
            
            # Calculate total price
            total_price = schedule['cost_per_kg'] * cargo['weight']
            
            # Get username
            cursor.callproc('get_user_username', [user_id])
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
def book_connected_route(request, route_id):
    """
    Handle booking cargo on a connected route with multiple segments.
    """
    if request.method != 'GET' and request.method != 'POST':
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
                # Schedule IDs from route_id
                schedule_ids = route_id.split(',')
                
                # Use stored procedure to get route endpoints
                cursor.callproc('get_connected_route_endpoints', [
                    schedule_ids[0],
                    schedule_ids[-1]
                ])
                
                # Get the result set
                port_data = cursor.fetchone()
                if not port_data:
                    messages.error(request, "Could not determine route endpoints")
                    return redirect('find-shipping-options')
                
                # Extract data
                origin_port_id, destination_port_id = port_data
                
                schedule_ids_str = ','.join(schedule_ids)
                cursor.execute(f"CALL calculate_connected_route_price('{schedule_ids_str}', {cargo_id})")
                
                # Get the result set
                price_data = cursor.fetchone()
                if not price_data:
                    messages.error(request, "Could not calculate booking price")
                    return redirect('find-shipping-options')
                
                # Extract data
                total_price, cargo_weight = price_data
                
                # Use stored procedure to create connected booking
                cursor.callproc('create_connected_booking', [
                    cargo_id,
                    user_id,
                    origin_port_id,
                    destination_port_id,
                    total_price,
                    request.POST.get('notes', '')
                ])
                
                # Get the output parameter (booking_id)
                connected_booking_id = cursor.fetchone()[0]
                
                # Add each segment to the connected_booking_segments table
                for i, schedule_id in enumerate(schedule_ids):
                    # Use stored procedure to create booking segment
                    cursor.callproc('create_booking_segment', [
                        connected_booking_id,
                        schedule_id,
                        i + 1,
                        cargo_weight
                    ])
                
                # Use stored procedure to update cargo status
                cursor.callproc('update_cargo_status', [cargo_id, user_id, 'booked'])
                
                messages.success(request, f"Connected route booked successfully! Booking ID: {connected_booking_id}")
                
                return redirect('customer-bookings')  # Redirect to bookings page
        
        except Exception as e:
            messages.error(request, f"Error booking connected route: {str(e)}")
            return redirect('find-shipping-options')
    
    # Display booking confirmation page
    try:
        with connection.cursor() as cursor:
            # Use stored procedure to get cargo details
            cursor.callproc('get_cargo_details', [cargo_id, user_id])
            
            # Get the result set
            cargo_data = cursor.fetchone()
            if not cargo_data:
                messages.error(request, "Cargo not found or does not belong to you")
                return redirect('find-shipping-options')
            
            # Create dictionary from result
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
            cursor.callproc('get_user_username', [user_id])
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
            # Use stored procedure to get direct bookings
            cursor.callproc('get_user_direct_bookings', [user_id])
            
            # Get the result set
            direct_results = cursor.fetchall()
            direct_columns = [col[0] for col in cursor.description]
            direct_bookings = [dict(zip(direct_columns, row)) for row in direct_results]
            
            # Use stored procedure to get connected bookings
            cursor.callproc('get_user_connected_bookings', [user_id])
            
            # Get the result set
            connected_results = cursor.fetchall()
            connected_columns = [col[0] for col in cursor.description]
            connected_bookings = [dict(zip(connected_columns, row)) for row in connected_results]
            
            # For each connected booking, get first departure and last arrival
            for booking in connected_bookings:
                # Use stored procedure to get booking dates
                cursor.callproc('get_connected_booking_dates', [booking['connected_booking_id']])
                
                # Get the result set
                dates = cursor.fetchone()
                if dates:
                    booking['first_departure'] = dates[0]
                    booking['last_arrival'] = dates[1]
            
            # Get username
            cursor.callproc('get_user_username', [user_id])
            username = cursor.fetchone()[0]
    
    except Exception as e:
        messages.error(request, f"Error retrieving bookings: {str(e)}")
    
    context = {
        'username': username,
        'direct_bookings': direct_bookings,
        'connected_bookings': connected_bookings
    }
    
    return render(request, 'customer_bookings.html', context)

@role_required('customer')
def view_booking_details(request, booking_id, booking_type):
    """
    View for displaying detailed information about a specific booking.
    """
    user_id = request.session.get('user_id')
    
    try:
        with connection.cursor() as cursor:
            if booking_type == 'direct':
                # Use stored procedure to get direct booking details
                cursor.callproc('get_direct_booking_details', [booking_id, user_id])
                
                # Get the result set
                result = cursor.fetchone()
                if not result:
                    messages.error(request, "Booking not found or does not belong to you")
                    return redirect('customer-bookings')
                
                # Create dictionary from result
                columns = [col[0] for col in cursor.description]
                booking = dict(zip(columns, result))
                segments = None
                
            else:  # Connected booking
                # Use stored procedure to get connected booking details
                cursor.callproc('get_connected_booking_details', [booking_id, user_id])
                
                # Get the result set
                result = cursor.fetchone()
                if not result:
                    messages.error(request, "Connected booking not found or does not belong to you")
                    return redirect('customer-bookings')
                
                # Create dictionary from result
                columns = [col[0] for col in cursor.description]
                booking = dict(zip(columns, result))
                
                # Use stored procedure to get segment details
                cursor.callproc('get_connected_booking_segments', [booking_id])
                
                # Get the result set
                segment_results = cursor.fetchall()
                segment_columns = [col[0] for col in cursor.description]
                segments = [dict(zip(segment_columns, row)) for row in segment_results]
                
                # Calculate connection times
                for i in range(len(segments) - 1):
                    current_segment = segments[i]
                    next_segment = segments[i + 1]
                    
                    current_arrival = current_segment['arrival_date']
                    next_departure = next_segment['departure_date']
                    
                    connection_hours = (next_departure - current_arrival).total_seconds() / 3600
                    current_segment['connection_time'] = round(connection_hours / 24, 1)  # Convert to days
            
            # Get username
            cursor.callproc('get_user_username', [user_id])
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
    Handle cancellation of a booking using stored procedures.
    """
    if request.method != 'POST':
        return redirect('customer-bookings')
    
    user_id = request.session.get('user_id')
    success = False
    message = ''
    
    try:
        with connection.cursor() as cursor:
            if booking_type == 'direct':
                # Call the new stored procedure for direct bookings
                args = [booking_id, user_id, 0, '']  # Last two are OUT params
                result_args = cursor.callproc('cancel_booking_direct', args)
                
                # Process result
                cursor.execute('SELECT @_cancel_booking_direct_2, @_cancel_booking_direct_3')
                result = cursor.fetchone()
                if result:
                    success = bool(result[0])
                    message = result[1]
            
            else:  # Connected booking
                # Call the new stored procedure for connected bookings
                args = [booking_id, user_id, 0, '']
                result_args = cursor.callproc('cancel_booking_connected', args)
                
                # Process result
                cursor.execute('SELECT @_cancel_booking_connected_2, @_cancel_booking_connected_3')
                result = cursor.fetchone()
                if result:
                    success = bool(result[0])
                    message = result[1]
        
        # Display appropriate message based on result
        if success:
            messages.success(request, message)
        else:
            messages.error(request, message if message else "An error occurred during cancellation.")
    
    except Exception as e:
        messages.error(request, f"Error cancelling booking: {str(e)}")
    
    return redirect('customer-bookings')


@role_required('customer')
def get_cargo_details(request, cargo_id):
    """
    API endpoint to get cargo details for the search interface.
    """
    user_id = request.session.get('user_id')
    
    try:
        with connection.cursor() as cursor:
            # Use stored procedure to get cargo details
            cursor.callproc('get_cargo_details_api', [cargo_id, user_id])
            
            # Get the result set
            cargo_data = cursor.fetchone()
            if not cargo_data:
                return JsonResponse({'error': 'Cargo not found'}, status=404)
            
            # Create dictionary from result
            columns = [col[0] for col in cursor.description]
            cargo = dict(zip(columns, cargo_data))
            
            return JsonResponse(cargo)
    
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)






