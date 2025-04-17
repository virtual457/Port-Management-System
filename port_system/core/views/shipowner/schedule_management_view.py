from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection
from django.core.paginator import Paginator
from datetime import datetime

def manage_schedules(request):
    """
    View for managing schedules with berth information
    """
    user_id = request.session.get('user_id')
    if not user_id:
        messages.error(request, "You must be logged in to access this page")
        return redirect('login')
    
    ship_name = request.GET.get('ship_name', '')
    port_name = request.GET.get('port_name', '')
    status = request.GET.get('status', '')
    date_from = request.GET.get('date_from', '')
    date_to = request.GET.get('date_to', '')
    berth_number = request.GET.get('berth_number', '')
    
    query_params = [user_id]
    filter_clauses = []
    
    base_query = """
        SELECT 
            s.schedule_id,
            s.ship_id,
            ships.name AS ship_name,
            ships.ship_type AS ship_type,
            s.route_id,
            r.name AS route_name,
            op.name AS origin_port,
            dp.name AS destination_port,
            s.departure_date,
            s.arrival_date,
            s.status AS status,  -- Explicitly aliasing status column
            s.max_cargo,
            s.notes,
            s.origin_berth_id,
            ob.berth_number AS origin_berth_number,
            ob.type AS origin_berth_type,
            s.origin_berth_start,
            s.origin_berth_end,
            s.destination_berth_id,
            db.berth_number AS destination_berth_number,
            db.type AS destination_berth_type,
            s.destination_berth_start,
            s.destination_berth_end
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
        LEFT JOIN 
            berths ob ON s.origin_berth_id = ob.berth_id
        LEFT JOIN 
            berths db ON s.destination_berth_id = db.berth_id
        WHERE 
            ships.owner_id = %s
    """
    
    if ship_name:
        filter_clauses.append("ships.name LIKE %s")
        query_params.append(f"%{ship_name}%")
    
    if port_name:
        filter_clauses.append("(op.name LIKE %s OR dp.name LIKE %s)")
        query_params.append(f"%{port_name}%")
        query_params.append(f"%{port_name}%")
    
    if status:
        filter_clauses.append("s.status = %s")
        query_params.append(status)
    
    if date_from:
        filter_clauses.append("(s.departure_date >= %s OR s.arrival_date >= %s)")
        query_params.append(date_from)
        query_params.append(date_from)
    
    if date_to:
        filter_clauses.append("(s.departure_date <= %s OR s.arrival_date <= %s)")
        query_params.append(date_to)
        query_params.append(date_to)
    
    if berth_number:
        filter_clauses.append("(ob.berth_number LIKE %s OR db.berth_number LIKE %s)")
        query_params.append(f"%{berth_number}%")
        query_params.append(f"%{berth_number}%")
    
    # Add filter clauses to query
    if filter_clauses:
        base_query += " AND " + " AND ".join(filter_clauses)
    
    # Add order by clause
    base_query += " ORDER BY s.departure_date DESC"
    
    # Execute query
    with connection.cursor() as cursor:
        cursor.execute(base_query, query_params)
        
        columns = [col[0] for col in cursor.description]
        schedules_data = [dict(zip(columns, row)) for row in cursor.fetchall()]
        
        cursor.execute("""
            SELECT s.status, COUNT(*) FROM schedules s
            JOIN ships ON s.ship_id = ships.ship_id
            WHERE ships.owner_id = %s
            GROUP BY s.status
        """, [user_id])
        
        status_counts = dict(cursor.fetchall())
        
        scheduled_count = status_counts.get('scheduled', 0)
        in_progress_count = status_counts.get('in_progress', 0)
        completed_count = status_counts.get('completed', 0)
        delayed_count = status_counts.get('delayed', 0)
        cancelled_count = status_counts.get('cancelled', 0)
        issues_count = delayed_count + cancelled_count
    
    # Pagination
    page = request.GET.get('page', 1)
    paginator = Paginator(schedules_data, 10)
    schedules = paginator.get_page(page)
    
    context = {
        'schedules': schedules,
        'username': request.session.get('username', 'User'),
        'scheduled_count': scheduled_count,
        'in_progress_count': in_progress_count,
        'completed_count': completed_count,
        'issues_count': issues_count
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
            # Update schedule status
            cursor.execute("""
                UPDATE schedules SET status = %s 
                WHERE schedule_id = %s
            """, [new_status, schedule_id])
            
            # Check if status_logs table exists
            cursor.execute("""
                SELECT COUNT(*) 
                FROM information_schema.tables 
                WHERE table_schema = DATABASE() 
                AND table_name = 'schedule_status_logs'
            """)
            logs_table_exists = cursor.fetchone()[0] > 0
            
            # Log the status change if table exists
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
            
            # Free up reserved berths if not already completed
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
            
            # Delete the schedule
            cursor.execute("DELETE FROM schedules WHERE schedule_id = %s", [schedule_id])
            
        messages.success(request, "Schedule deleted successfully")
    except Exception as e:
        messages.error(request, f"Error deleting schedule: {str(e)}")
    
    return redirect('manage-schedules')