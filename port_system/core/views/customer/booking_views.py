from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.contrib import messages
from django.db import connection
from django.views.decorators.http import require_http_methods
from datetime import datetime, timedelta

from ..views import role_required

@role_required('customer')
def book_cargo(request, schedule_id):
    if request.method not in ['GET', 'POST']:
        return redirect('find-shipping-options')
    
    user_id = request.session.get('user_id')
    cargo_id = request.GET.get('cargo_id')
    
    if not cargo_id:
        messages.error(request, "No cargo selected for booking")
        return redirect('find-shipping-options')
    
    if request.method == 'POST':
        try:
            with connection.cursor() as cursor:
                cursor.callproc('create_direct_booking', [
                    cargo_id, 
                    schedule_id, 
                    user_id, 
                    request.POST.get('notes', '')
                ])
                
                for result in cursor.stored_results():
                    result_set = result.fetchone()
                    booking_id = result_set[0]
                    success = bool(result_set[1])
                    message = result_set[2]
                
                if success:
                    messages.success(request, message)
                    return redirect('customer-bookings')
                else:
                    messages.error(request, message)
                    return redirect('find-shipping-options')
                
        except Exception as e:
            messages.error(request, f"Error booking cargo: {str(e)}")
            return redirect('find-shipping-options')
    
    try:
        with connection.cursor() as cursor:
            cursor.callproc('get_direct_booking_details', [schedule_id, cargo_id, user_id])
            
            results = list(cursor.stored_results())
            
            schedule_data = results[0].fetchone()
            schedule_columns = [col[0] for col in results[0].description]
            schedule = dict(zip(schedule_columns, schedule_data))
            
            cargo_data = results[1].fetchone()
            cargo_columns = [col[0] for col in results[1].description]
            cargo = dict(zip(cargo_columns, cargo_data))
            
            username = results[2].fetchone()[0]
            
            total_price = schedule['cost_per_kg'] * cargo['weight']
    
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
    if request.method not in ['GET', 'POST']:
        return redirect('find-shipping-options')
    
    user_id = request.session.get('user_id')
    cargo_id = request.GET.get('cargo_id')
    
    if not cargo_id:
        messages.error(request, "No cargo selected for booking")
        return redirect('find-shipping-options')
    
    if request.method == 'POST':
        try:
            with connection.cursor() as cursor:
                cursor.callproc('create_connected_booking', [
                    cargo_id, 
                    user_id, 
                    schedule_ids, 
                    request.POST.get('notes', '')
                ])
                
                for result in cursor.stored_results():
                    result_set = result.fetchone()
                    connected_booking_id = result_set[0]
                    success = bool(result_set[1])
                    message = result_set[2]
                
                if success:
                    messages.success(request, message)
                    return redirect('customer-bookings')
                else:
                    messages.error(request, message)
                    return redirect('find-shipping-options')
                
        except Exception as e:
            messages.error(request, f"Error booking connected route: {str(e)}")
            return redirect('find-shipping-options')
    
    try:
        with connection.cursor() as cursor:
            cursor.callproc('get_connected_booking_details', [schedule_ids, cargo_id, user_id])
            
            results = list(cursor.stored_results())
            
            cargo_data = results[0].fetchone()
            cargo_columns = [col[0] for col in results[0].description]
            cargo = dict(zip(cargo_columns, cargo_data))
            
            segments = []
            segment_columns = [col[0] for col in results[1].description]
            segment_rows = results[1].fetchall()
            
            total_price = 0
            for row in segment_rows:
                segment = dict(zip(segment_columns, row))
                
                segment_price = segment['cost_per_kg'] * cargo['weight']
                segment['segment_price'] = segment_price
                total_price += segment_price
                
                duration = (segment['arrival_date'] - segment['departure_date']).days
                segment['duration'] = duration
                
                segments.append(segment)
            
            for i in range(len(segments) - 1):
                current_segment = segments[i]
                next_segment = segments[i + 1]
                
                connection_time = (next_segment['departure_date'] - current_segment['arrival_date']).days
                current_segment['connection_time'] = connection_time
            
            first_departure = segments[0]['departure_date'] if segments else None
            last_arrival = segments[-1]['arrival_date'] if segments else None
            total_duration = (last_arrival - first_departure).days if first_departure and last_arrival else 0
            
            username = results[2].fetchone()[0]
    
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
    user_id = request.session.get('user_id')
    direct_bookings = []
    connected_bookings = []
    
    try:
        with connection.cursor() as cursor:
            cursor.callproc('get_user_bookings', [user_id])
            
            results = list(cursor.stored_results())
            
            direct_columns = [col[0] for col in results[0].description]
            direct_rows = results[0].fetchall()
            direct_bookings = [dict(zip(direct_columns, row)) for row in direct_rows]
            
            connected_columns = [col[0] for col in results[1].description]
            connected_rows = results[1].fetchall()
            connected_bookings = [dict(zip(connected_columns, row)) for row in connected_rows]
            
            username = results[2].fetchone()[0]
    
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
    user_id = request.session.get('user_id')
    
    try:
        with connection.cursor() as cursor:
            if booking_type == 'direct':
                cursor.callproc('get_direct_booking_by_id', [booking_id, user_id])
                
                results = list(cursor.stored_results())
                
                booking_data = results[0].fetchone()
                if not booking_data:
                    messages.error(request, "Booking not found or does not belong to you")
                    return redirect('customer-bookings')
                
                columns = [col[0] for col in results[0].description]
                booking = dict(zip(columns, booking_data))
                segments = None
                
                username = results[1].fetchone()[0]
                
            else:
                cursor.callproc('get_connected_booking_by_id', [booking_id, user_id])
                
                results = list(cursor.stored_results())
                
                booking_data = results[0].fetchone()
                if not booking_data:
                    messages.error(request, "Booking not found or does not belong to you")
                    return redirect('customer-bookings')
                
                columns = [col[0] for col in results[0].description]
                booking = dict(zip(columns, booking_data))
                
                segment_columns = [col[0] for col in results[1].description]
                segment_rows = results[1].fetchall()
                segments = [dict(zip(segment_columns, row)) for row in segment_rows]
                
                username = results[2].fetchone()[0]
    
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
    if request.method != 'POST':
        return redirect('customer-bookings')
    
    user_id = request.session.get('user_id')
    
    try:
        with connection.cursor() as cursor:
            if booking_type == 'direct':
                cursor.callproc('cancel_direct_booking', [booking_id, user_id])
                
                for result in cursor.stored_results():
                    result_set = result.fetchone()
                    success = bool(result_set[0])
                    message = result_set[1]
                
                if success:
                    messages.success(request, message)
                else:
                    messages.error(request, message)
            
            else:  
                cursor.callproc('cancel_connected_booking', [booking_id, user_id])
            
            for result in cursor.stored_results():
                result_set = result.fetchone()
                success = bool(result_set[0])
                message = result_set[1]
            
            if success:
                messages.success(request, message)
            else:
                messages.error(request, message)
    
    except Exception as e:
        messages.error(request, f"Error cancelling booking: {str(e)}")
    
    return redirect('customer-bookings')