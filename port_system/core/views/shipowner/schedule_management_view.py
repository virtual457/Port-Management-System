from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection
from django.core.paginator import Paginator
from datetime import datetime

def manage_schedules(request):
    """
    View for managing schedules - simplified to just show schedules
    """
    user_id = request.session.get('user_id')
    if not user_id:
        messages.error(request, "You must be logged in to access this page")
        return redirect('login')
    
    query = """
        SELECT 
            s.schedule_id,
            ships.name AS ship_name,
            op.name AS origin_port,
            dp.name AS destination_port,
            s.departure_date,
            s.arrival_date,
            s.status
        FROM 
            schedules s
        JOIN 
            ships ON s.ship_id = ships.ship_id
        JOIN 
            routes r ON s.route_id = r.route_id
        JOIN 
            ports op ON r.origin_port_id = op.port_id
        JOIN 
            ports dp ON r.destination_port_id = dp.port_id
        WHERE 
            ships.owner_id = %s
        ORDER BY 
            s.departure_date DESC
    """
    
    with connection.cursor() as cursor:
        cursor.execute(query, [user_id])
        columns = [col[0] for col in cursor.description]
        schedules = [dict(zip(columns, row)) for row in cursor.fetchall()]
    
    context = {
        'schedules': schedules,
        'username': request.session.get('username', 'User')
    }
    
    return render(request, 'manage_schedules.html', context)

def update_schedule_status(request):
    """
    Handle updating a schedule's status
    """
    if request.method != 'POST':
        return redirect('manage-schedules')
    
    schedule_id = request.POST.get('id')
    new_status = request.POST.get('status')
    reason = request.POST.get('reason')
    
    if not all([schedule_id, new_status, reason]):
        messages.error(request, "All fields are required")
        return redirect('manage-schedules')
    
    try:
        with connection.cursor() as cursor:

            cursor.execute("""
                UPDATE schedules SET status = %s 
                WHERE schedule_id = %s
            """, [new_status, schedule_id])
            

            cursor.execute("""
                SELECT COUNT(*) 
                FROM information_schema.tables 
                WHERE table_schema = DATABASE() 
                AND table_name = 'schedule_status_logs'
            """)
            logs_table_exists = cursor.fetchone()[0] > 0
            
            if logs_table_exists:
                cursor.execute("""
                    INSERT INTO schedule_status_logs 
                    (schedule_id, old_status, new_status, reason, changed_by, changed_at)
                    SELECT s.schedule_id, s.status, %s, %s, %s, NOW()
                    FROM schedules s
                    WHERE s.schedule_id = %s
                """, [new_status, reason, request.session.get('user_id'), schedule_id])
            
            if new_status == 'completed':
                cursor.execute("""
                    UPDATE berths 
                    SET status = 'active'
                    WHERE berth_id IN (
                        SELECT destination_berth_id FROM schedules 
                        WHERE schedule_id = %s
                    ) AND status = 'occupied'
                """, [schedule_id])
                
                cursor.execute("""
                    UPDATE ships 
                    SET status = 'docked', 
                        current_port_id = (
                            SELECT r.destination_port_id 
                            FROM schedules s
                            JOIN routes r ON s.route_id = r.route_id
                            WHERE s.schedule_id = %s
                        )
                    WHERE ship_id = (
                        SELECT ship_id FROM schedules 
                        WHERE schedule_id = %s
                    )
                """, [schedule_id, schedule_id])
                
            elif new_status == 'in_progress':
                cursor.execute("""
                    UPDATE berths 
                    SET status = 'active'
                    WHERE berth_id IN (
                        SELECT origin_berth_id FROM schedules 
                        WHERE schedule_id = %s
                    ) AND status = 'occupied'
                """, [schedule_id])
                
                cursor.execute("""
                    UPDATE ships 
                    SET status = 'in_transit', 
                        current_port_id = NULL
                    WHERE ship_id = (
                        SELECT ship_id FROM schedules 
                        WHERE schedule_id = %s
                    )
                """, [schedule_id])
                
            elif new_status == 'cancelled':
                cursor.execute("""
                    UPDATE berths 
                    SET status = 'active'
                    WHERE berth_id IN (
                        SELECT origin_berth_id FROM schedules 
                        WHERE schedule_id = %s
                        UNION
                        SELECT destination_berth_id FROM schedules 
                        WHERE schedule_id = %s
                    ) AND status IN ('occupied', 'reserved')
                """, [schedule_id, schedule_id])
            
        messages.success(request, f"Schedule status updated to {new_status}")
    except Exception as e:
        messages.error(request, f"Error updating status: {str(e)}")
    
    return redirect('manage-schedules')

def delete_schedule(request):
    """
    Handle deleting a schedule
    """
    if request.method != 'POST':
        return redirect('manage-schedules')
    
    schedule_id = request.POST.get('id')
    
    if not schedule_id:
        messages.error(request, "Schedule ID is required")
        return redirect('manage-schedules')
    
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT ship_id, status, origin_berth_id, destination_berth_id
                FROM schedules
                WHERE schedule_id = %s
            """, [schedule_id])
            
            result = cursor.fetchone()
            if not result:
                messages.error(request, "Schedule not found")
                return redirect('manage-schedules')
            
            ship_id, status, origin_berth_id, destination_berth_id = result
            
            if status != 'completed':
                if origin_berth_id:
                    cursor.execute("""
                        UPDATE berths 
                        SET status = 'active'
                        WHERE berth_id = %s AND status IN ('reserved', 'occupied')
                    """, [origin_berth_id])
                
                if destination_berth_id:
                    cursor.execute("""
                        UPDATE berths 
                        SET status = 'active'
                        WHERE berth_id = %s AND status IN ('reserved', 'occupied')
                    """, [destination_berth_id])
            
            cursor.execute("DELETE FROM schedules WHERE schedule_id = %s", [schedule_id])
            
        messages.success(request, "Schedule deleted successfully")
    except Exception as e:
        messages.error(request, f"Error deleting schedule: {str(e)}")
    
    return redirect('manage-schedules')