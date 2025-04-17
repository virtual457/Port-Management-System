from django.shortcuts import render
from django.http import JsonResponse
from django.contrib import messages
from django.db import connection
from datetime import datetime, timedelta
import json
from decimal import Decimal
import logging

from ..views import role_required

logger = logging.getLogger(__name__)

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def dictfetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]

@role_required('admin')
def admin_reports(request):
    time_range = request.GET.get('range', '30')
    
    context = {
        'role_stats': [],
        'cargo_stats': [],
        'ship_stats': [],
        'booking_stats': [],
        'port_stats': [],
        'total_revenue': 0,
        'total_calculated_revenue': 0,
        'top_routes': [],
        'cargo_types': [],
        'cargo_status': [],
        'conversion_rate': 0,
        'recent_users': [],
        'recent_direct_bookings': [],
        'recent_connected_bookings': [],
        'recent_schedules': [],
        'selected_range': time_range,
        'aggregated_revenue': {'direct': 0, 'connected': 0},
        'error': False
    }
    
    try:
        if time_range == 'all':
            days_back = 365
        else:
            try:
                days_back = int(time_range)
            except ValueError:
                days_back = 30
                context['selected_range'] = '30'
        
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT 
    r.role_name,
    COUNT(DISTINCT ur.user_id) as user_count
FROM 
    roles r
LEFT JOIN 
    user_roles ur ON r.role_id = ur.role_id
GROUP BY 
    r.role_name
ORDER BY 
    user_count DESC;
            """)
            context['role_stats'] = dictfetchall(cursor)
            cursor.execute("SELECT COUNT(DISTINCT user_id) as total_users FROM user_roles;")
            context['total_users'] = cursor.fetchone()[0]
            
            cursor.execute("""
                SELECT 
                    status,
                    COUNT(*) as cargo_count
                FROM 
                    cargo
                GROUP BY 
                    status
                ORDER BY 
                    cargo_count DESC;
            """)
            context['cargo_stats'] = dictfetchall(cursor)
            
            cursor.execute("SELECT COUNT(*) as total_cargo FROM cargo;")
            context['total_cargo'] = cursor.fetchone()[0]
            
            cursor.execute("""
                SELECT 
                    status,
                    COUNT(*) as port_count
                FROM 
                    ports
                GROUP BY 
                    status
                ORDER BY 
                    port_count DESC;
            """)
            context['port_stats'] = dictfetchall(cursor)
            
            cursor.execute("SELECT COUNT(*) as total_ports FROM ports;")
            context['total_ports'] = cursor.fetchone()[0]
            
            cursor.execute("""
                SELECT 
                    'direct' as booking_type,
                    SUM(CASE WHEN booking_status != 'cancelled' THEN price ELSE 0 END) as revenue
                FROM 
                    cargo_bookings;
            """)
            direct_revenue = cursor.fetchone()[1] or 0
            
            cursor.execute("""
                SELECT 
                    'connected' as booking_type,
                    SUM(CASE WHEN booking_status != 'cancelled' THEN total_price ELSE 0 END) as revenue
                FROM 
                    connected_bookings;
            """)
            connected_revenue = cursor.fetchone()[1] or 0
            
            context['aggregated_revenue'] = {
                'direct': float(direct_revenue),
                'connected': float(connected_revenue)
            }
            context['total_calculated_revenue'] = float(direct_revenue) + float(connected_revenue)
            
            cursor.callproc('get_admin_booking_trends', [days_back])
            
            daily_bookings = {}
            for row in dictfetchall(cursor):
                date_str = row['booking_day'].strftime('%Y-%m-%d')
                if date_str not in daily_bookings:
                    daily_bookings[date_str] = {'direct': 0, 'connected': 0}
                daily_bookings[date_str][row['booking_type']] = row['booking_count']
            
            all_dates = []
            if daily_bookings:
                start_date = min(datetime.strptime(date_str, '%Y-%m-%d') for date_str in daily_bookings.keys())
                end_date = max(datetime.strptime(date_str, '%Y-%m-%d') for date_str in daily_bookings.keys())
                
                current_date = start_date
                while current_date <= end_date:
                    date_str = current_date.strftime('%Y-%m-%d')
                    all_dates.append(date_str)
                    if date_str not in daily_bookings:
                        daily_bookings[date_str] = {'direct': 0, 'connected': 0}
                    current_date += timedelta(days=1)
            
            daily_data = {
                'dates': [],
                'direct': [],
                'connected': []
            }
            
            for date_str in sorted(all_dates):
                daily_data['dates'].append(date_str)
                daily_data['direct'].append(daily_bookings[date_str]['direct'])
                daily_data['connected'].append(daily_bookings[date_str]['connected'])
            
            cursor.nextset()
            weekly_bookings = {}
            for row in dictfetchall(cursor):
                week_str = str(row['booking_week'])
                if week_str not in weekly_bookings:
                    weekly_bookings[week_str] = {
                        'direct_count': 0, 
                        'connected_count': 0,
                        'direct_revenue': 0,
                        'connected_revenue': 0
                    }
                
                if row['booking_type'] == 'direct':
                    weekly_bookings[week_str]['direct_count'] = row['booking_count']
                    weekly_bookings[week_str]['direct_revenue'] = float(row['revenue'] or 0)
                else:
                    weekly_bookings[week_str]['connected_count'] = row['booking_count']
                    weekly_bookings[week_str]['connected_revenue'] = float(row['revenue'] or 0)
            
            weekly_data = {
                'weeks': [],
                'direct_count': [],
                'connected_count': [],
                'direct_revenue': [],
                'connected_revenue': []
            }
            
            for week_str in sorted(weekly_bookings.keys()):
                weekly_data['weeks'].append(f"Week {week_str[-2:]}")
                weekly_data['direct_count'].append(weekly_bookings[week_str]['direct_count'])
                weekly_data['connected_count'].append(weekly_bookings[week_str]['connected_count'])
                weekly_data['direct_revenue'].append(weekly_bookings[week_str]['direct_revenue'])
                weekly_data['connected_revenue'].append(weekly_bookings[week_str]['connected_revenue'])
            
            cursor.nextset()
            monthly_bookings = {}
            for row in dictfetchall(cursor):
                month_str = row['booking_month']
                if month_str not in monthly_bookings:
                    monthly_bookings[month_str] = {
                        'direct_count': 0, 
                        'connected_count': 0,
                        'direct_revenue': 0,
                        'connected_revenue': 0
                    }
                
                if row['booking_type'] == 'direct':
                    monthly_bookings[month_str]['direct_count'] = row['booking_count']
                    monthly_bookings[month_str]['direct_revenue'] = float(row['revenue'] or 0)
                else:
                    monthly_bookings[month_str]['connected_count'] = row['booking_count']
                    monthly_bookings[month_str]['connected_revenue'] = float(row['revenue'] or 0)
            
            monthly_data = {
                'months': [],
                'direct_count': [],
                'connected_count': [],
                'direct_revenue': [],
                'connected_revenue': []
            }
            
            for month_str in sorted(monthly_bookings.keys()):
                try:
                    date_obj = datetime.strptime(month_str, '%Y-%m')
                    formatted_month = date_obj.strftime('%b %Y')
                except ValueError:
                    formatted_month = month_str
                
                monthly_data['months'].append(formatted_month)
                monthly_data['direct_count'].append(monthly_bookings[month_str]['direct_count'])
                monthly_data['connected_count'].append(monthly_bookings[month_str]['connected_count'])
                monthly_data['direct_revenue'].append(monthly_bookings[month_str]['direct_revenue'])
                monthly_data['connected_revenue'].append(monthly_bookings[month_str]['connected_revenue'])
            
            cursor.callproc('get_admin_top_routes', [10])
            context['top_routes'] = dictfetchall(cursor)
            
            cursor.callproc('get_admin_cargo_stats', [])
            context['cargo_types'] = dictfetchall(cursor)
            
            cursor.nextset()
            context['cargo_status'] = dictfetchall(cursor)
            
            cursor.nextset()
            cargo_conversion = cursor.fetchone()
            context['conversion_rate'] = cargo_conversion[3] if cargo_conversion else 0
            
            cursor.callproc('get_admin_recent_activities', [20])
            
            recent_users = []
            for row in dictfetchall(cursor):
                if row.get('activity_time'):
                    row['formatted_time'] = row['activity_time'].strftime('%b %d, %Y %H:%M')
                recent_users.append(row)
            context['recent_users'] = recent_users
            
            cursor.nextset()
            recent_direct_bookings = []
            for row in dictfetchall(cursor):
                if row.get('activity_time'):
                    row['formatted_time'] = row['activity_time'].strftime('%b %d, %Y %H:%M')
                recent_direct_bookings.append(row)
            context['recent_direct_bookings'] = recent_direct_bookings
            
            cursor.nextset()
            recent_connected_bookings = []
            for row in dictfetchall(cursor):
                if row.get('activity_time'):
                    row['formatted_time'] = row['activity_time'].strftime('%b %d, %Y %H:%M')
                recent_connected_bookings.append(row)
            context['recent_connected_bookings'] = recent_connected_bookings
            
            cursor.nextset()
            recent_schedules = []
            for row in dictfetchall(cursor):
                if row.get('departure_date'):
                    row['formatted_departure'] = row['departure_date'].strftime('%b %d, %Y')
                if row.get('arrival_date'):
                    row['formatted_arrival'] = row['arrival_date'].strftime('%b %d, %Y')
                if row.get('activity_time'):
                    row['formatted_time'] = row['activity_time'].strftime('%b %d, %Y %H:%M')
                recent_schedules.append(row)
            context['recent_schedules'] = recent_schedules
            
            context['daily_booking_data'] = json.dumps(daily_data, cls=DecimalEncoder)
            context['weekly_booking_data'] = json.dumps(weekly_data, cls=DecimalEncoder)
            context['monthly_booking_data'] = json.dumps(monthly_data, cls=DecimalEncoder)
            
    except Exception as e:
        logger.exception(f"Error generating admin dashboard: {str(e)}")
        messages.error(request, f"Error generating admin dashboard: {str(e)}")
        context['error'] = True
    
    return render(request, 'admin_report.html', context)
