from ..views import role_required

from django.shortcuts import render
from django.http import JsonResponse
from django.contrib import messages
from django.db import connection
from datetime import datetime, timedelta
import json

@role_required('customer')
def customer_reports(request):
    """
    View for displaying customer shipping reports and analytics.
    Uses stored procedures to fetch all data.
    """
    user_id = request.session.get('user_id')
    time_range = request.GET.get('range', '30')  # Default to 30 days
    
    try:
        with connection.cursor() as cursor:
            # Get dashboard statistics using stored procedure
            cursor.callproc('get_customer_dashboard_stats', [user_id])
            
            # Fetch all result sets
            stats = {}
            # First result: cargo count
            result = cursor.fetchone()
            stats['cargo_count'] = result[0] if result else 0
            
            # Next result: direct active bookings
            cursor.nextset()
            result = cursor.fetchone()
            stats['direct_active_bookings'] = result[0] if result else 0
            
            # Next result: connected active bookings
            cursor.nextset()
            result = cursor.fetchone()
            stats['connected_active_bookings'] = result[0] if result else 0
            
            # Next result: in transit count
            cursor.nextset()
            result = cursor.fetchone()
            stats['in_transit_count'] = result[0] if result else 0
            
            # Last result: completed count
            cursor.nextset()
            result = cursor.fetchone()
            stats['completed_count'] = result[0] if result else 0
            
            # Calculate total active bookings
            stats['active_bookings'] = stats['direct_active_bookings'] + stats['connected_active_bookings']
            
            # Get recent bookings using stored procedure
            cursor.callproc('get_customer_recent_bookings', [user_id, 10])  # Limit to 10 recent bookings
            columns = [col[0] for col in cursor.description]
            recent_bookings_temp = cursor.fetchall()
            
            # Process and enhance recent bookings data
            recent_bookings = []
            for booking in recent_bookings_temp:
                booking_dict = dict(zip(columns, booking))
                
                # Get booking details including price and date based on booking type
                if booking_dict['type'] == 'direct':
                    cursor.execute("""
                        SELECT price, booking_date 
                        FROM cargo_bookings 
                        WHERE booking_id = %s
                    """, [booking_dict['booking_id']])
                    price_date = cursor.fetchone()
                    if price_date:
                        booking_dict['price'] = price_date[0]
                        booking_dict['booking_date'] = price_date[1]
                        # Format date in Python instead of MySQL
                        if booking_dict['booking_date']:
                            booking_dict['formatted_date'] = booking_dict['booking_date'].strftime('%b %d, %Y')
                        else:
                            booking_dict['formatted_date'] = ''
                    else:
                        booking_dict['price'] = 0
                        booking_dict['formatted_date'] = ''
                else:  # connected booking
                    cursor.execute("""
                        SELECT total_price, booking_date
                        FROM connected_bookings 
                        WHERE connected_booking_id = %s
                    """, [booking_dict['connected_booking_id']])
                    price_date = cursor.fetchone()
                    if price_date:
                        booking_dict['price'] = price_date[0]
                        booking_dict['booking_date'] = price_date[1]
                        # Format date in Python instead of MySQL
                        if booking_dict['booking_date']:
                            booking_dict['formatted_date'] = booking_dict['booking_date'].strftime('%b %d, %Y')
                        else:
                            booking_dict['formatted_date'] = ''
                    else:
                        booking_dict['price'] = 0
                        booking_dict['formatted_date'] = ''
                        
                recent_bookings.append(booking_dict)
            
            # Get upcoming shipments using stored procedure
            cursor.callproc('get_customer_upcoming_shipments', [user_id, 5])  # Limit to 5 upcoming shipments
            columns = [col[0] for col in cursor.description]
            upcoming_shipments_temp = cursor.fetchall()
            
            # Process upcoming shipments data and format dates
            upcoming_shipments = []
            for shipment in upcoming_shipments_temp:
                shipment_dict = dict(zip(columns, shipment))
                if 'departure_date' in shipment_dict and shipment_dict['departure_date']:
                    # Format date in Python
                    shipment_dict['formatted_departure'] = shipment_dict['departure_date'].strftime('%b %d, %Y')
                else:
                    shipment_dict['formatted_departure'] = ''
                upcoming_shipments.append(shipment_dict)
            
            # Get cargo by type data using stored procedure
            cursor.callproc('get_cargo_by_type', [user_id])
            
            cargo_type_data = {
                'labels': [],
                'data': []
            }
            
            for row in cursor.fetchall():
                cargo_type_data['labels'].append(row[0].title())
                cargo_type_data['data'].append(row[1])
            
            # Get booking status data using stored procedure
            cursor.callproc('get_booking_status_counts', [user_id])
            
            status_counts = {}
            for row in cursor.fetchall():
                status = row[1].title()
                if status in status_counts:
                    status_counts[status] += row[2]
                else:
                    status_counts[status] = row[2]
            
            booking_status_data = {
                'labels': list(status_counts.keys()),
                'data': list(status_counts.values())
            }
            
            # Get username
            cursor.execute("SELECT username FROM users WHERE user_id = %s", [user_id])
            username = cursor.fetchone()[0]
        
            # Handle the 'all' case for time_range
            if time_range == 'all':
                days_back = 365  # Use 1 year of data as a reasonable default for 'all'
            else:
                try:
                    days_back = int(time_range)
                except ValueError:
                    # If conversion fails, default to 30 days
                    days_back = 30
            
            # Get monthly activity data using stored procedure
            cursor.callproc('get_monthly_shipping_activity', [user_id, days_back])
            
            monthly_data = cursor.fetchall()
            
            if monthly_data:
                monthly_activity_data = {
                    'labels': [],
                    'bookings': [],
                    'weight': []
                }
                
                for row in monthly_data:
                    # Convert YYYY-MM format to Month name (e.g., Jan, Feb)
                    try:
                        month_year = datetime.strptime(row[0], '%Y-%m')
                        month_name = month_year.strftime('%b')
                    except (ValueError, TypeError):
                        month_name = str(row[0])
                    
                    monthly_activity_data['labels'].append(month_name)
                    monthly_activity_data['bookings'].append(row[1])
                    monthly_activity_data['weight'].append(float(row[2]) if row[2] is not None else 0)
            else:
                # Fallback if no data is returned
                current_month = datetime.now()
                months = []
                booking_counts = []
                weight_data = []
                
                # Generate the last 6 months as fallback
                for i in range(6):
                    month_date = current_month - timedelta(days=30*i)
                    months.insert(0, month_date.strftime('%b'))
                    booking_counts.insert(0, 0)
                    weight_data.insert(0, 0)
                
                monthly_activity_data = {
                    'labels': months,
                    'bookings': booking_counts,
                    'weight': weight_data
                }
        
    except Exception as e:
        messages.error(request, f"Error generating reports: {str(e)}")
        return render(request, 'customer_reports.html', {'username': 'Customer'})
    
    context = {
        'username': username,
        'stats': stats,
        'recent_bookings': recent_bookings,
        'upcoming_shipments': upcoming_shipments,
        'cargo_type_data': json.dumps(cargo_type_data),
        'booking_status_data': json.dumps(booking_status_data),
        'monthly_activity_data': json.dumps(monthly_activity_data),
        'selected_range': time_range
    }
    
    return render(request, 'customer_reports.html', context)