from ..views import role_required

from django.shortcuts import render
from django.http import JsonResponse
from django.contrib import messages
from django.db import connection
from datetime import datetime, timedelta
import json

from decimal import Decimal
from json import JSONEncoder

class DecimalEncoder(JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

@role_required('shipowner')
def shipowner_reports(request):
    user_id = request.session.get('user_id')
    time_range = request.GET.get('range', '30')
    
    try:
        with connection.cursor() as cursor:
            cursor.callproc('get_shipowner_dashboard_stats', [user_id])
            
            stats = {}
            result = cursor.fetchone()
            stats['ship_count'] = result[0] if result else 0
            
            cursor.nextset()
            result = cursor.fetchone()
            stats['active_routes'] = result[0] if result else 0
            
            cursor.nextset()
            result = cursor.fetchone()
            stats['scheduled_voyages'] = result[0] if result else 0
            
            cursor.nextset()
            result = cursor.fetchone()
            stats['in_transit_voyages'] = result[0] if result else 0
            
            cursor.nextset()
            result = cursor.fetchone()
            stats['total_revenue'] = result[0] if result else 0
            
            cursor.callproc('get_shipowner_recent_bookings', [user_id, 10])
            columns = [col[0] for col in cursor.description]
            recent_bookings = []
            
            for booking in cursor.fetchall():
                booking_dict = dict(zip(columns, booking))
                
                if 'booking_date' in booking_dict and booking_dict['booking_date']:
                    booking_dict['formatted_date'] = booking_dict['booking_date'].strftime('%b %d, %Y')
                else:
                    booking_dict['formatted_date'] = ''
                    
                recent_bookings.append(booking_dict)
            
            cursor.callproc('get_shipowner_upcoming_voyages', [user_id, 5])
            columns = [col[0] for col in cursor.description]
            upcoming_voyages = []
            
            for voyage in cursor.fetchall():
                voyage_dict = dict(zip(columns, voyage))
                if 'departure_date' in voyage_dict and voyage_dict['departure_date']:
                    voyage_dict['formatted_departure'] = voyage_dict['departure_date'].strftime('%b %d, %Y')
                else:
                    voyage_dict['formatted_departure'] = ''
                    
                if 'arrival_date' in voyage_dict and voyage_dict['arrival_date']:
                    voyage_dict['formatted_arrival'] = voyage_dict['arrival_date'].strftime('%b %d, %Y')
                else:
                    voyage_dict['formatted_arrival'] = ''
                    
                upcoming_voyages.append(voyage_dict)
            
            cursor.callproc('get_ship_utilization', [user_id])
            
            ship_utilization_data = {
                'labels': [],
                'data': []
            }
            
            for row in cursor.fetchall():
                ship_utilization_data['labels'].append(row[0])
                ship_utilization_data['data'].append(float(row[1]) if row[1] is not None else 0)
            
            cursor.callproc('get_revenue_by_route', [user_id])
            
            revenue_by_route_data = {
                'labels': [],
                'data': []
            }
            
            for row in cursor.fetchall():
                revenue_by_route_data['labels'].append(row[0])
                revenue_by_route_data['data'].append(float(row[1]) if row[1] is not None else 0)
            
            cursor.execute("SELECT username FROM users WHERE user_id = %s", [user_id])
            username = cursor.fetchone()[0]
        
            if time_range == 'all':
                days_back = 365
            else:
                try:
                    days_back = int(time_range)
                except ValueError:
                    days_back = 30
            
            cursor.callproc('get_monthly_shipping_revenue', [user_id, days_back])
            
            monthly_data = cursor.fetchall()
            
            if monthly_data:
                monthly_revenue_data = {
                    'labels': [],
                    'bookings': [],
                    'revenue': []
                }
                
                for row in monthly_data:
                    try:
                        month_year = datetime.strptime(row[0], '%Y-%m')
                        month_name = month_year.strftime('%b')
                    except (ValueError, TypeError):
                        month_name = str(row[0])
                    
                    monthly_revenue_data['labels'].append(month_name)
                    monthly_revenue_data['bookings'].append(row[1])
                    monthly_revenue_data['revenue'].append(float(row[2]) if row[2] is not None else 0)
            else:
                current_month = datetime.now()
                months = []
                booking_counts = []
                revenue_data = []
                
                for i in range(6):
                    month_date = current_month - timedelta(days=30*i)
                    months.insert(0, month_date.strftime('%b'))
                    booking_counts.insert(0, 0)
                    revenue_data.insert(0, 0)
                
                monthly_revenue_data = {
                    'labels': months,
                    'bookings': booking_counts,
                    'revenue': revenue_data
                }
        
    except Exception as e:
        messages.error(request, f"Error generating reports: {str(e)}")
        return render(request, 'shipowner_reports.html', {'username': 'Shipowner'})
    
    context = {
        'username': username,
        'stats': stats,
        'recent_bookings': recent_bookings,
        'upcoming_voyages': upcoming_voyages,
        'ship_utilization_data': json.dumps(ship_utilization_data, cls=DecimalEncoder),
        'revenue_by_route_data': json.dumps(revenue_by_route_data, cls=DecimalEncoder),
        'monthly_revenue_data': json.dumps(monthly_revenue_data, cls=DecimalEncoder),
        'selected_range': time_range
    }
    
    return render(request, 'shipowner_reports.html', context)