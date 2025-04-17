from django.shortcuts import render, redirect
from django.contrib import messages
from django.core.paginator import Paginator
from django.db import connection
from django.http import HttpResponseRedirect
from django.urls import reverse


def manage_berths(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT port_id, name, country FROM ports WHERE status = 'active' ORDER BY name")
        ports = [{'id': row[0], 'name': row[1], 'country': row[2]} for row in cursor.fetchall()]
    
    selected_port = request.GET.get('port_id')
    berths = []
    selected_port_name = ""
    
    if selected_port:
        with connection.cursor() as cursor:
            cursor.execute("SELECT name FROM ports WHERE port_id = %s", [selected_port])
            port_data = cursor.fetchone()
            if port_data:
                selected_port_name = port_data[0]
        
        berth_type = request.GET.get('type')
        status = request.GET.get('status')
        
        query = """
            SELECT berth_id, berth_number, type, length, width, depth, status
            FROM berths
            WHERE port_id = %s
        """
        params = [selected_port]
        
        if berth_type:
            query += " AND type = %s"
            params.append(berth_type)
        
        if status:
            query += " AND status = %s"
            params.append(status)
        
        query += " ORDER BY berth_number"
        
        with connection.cursor() as cursor:
            cursor.execute(query, params)
            berths = [
                {
                    'berth_id': row[0],
                    'berth_number': row[1],
                    'type': row[2],
                    'length': row[3],
                    'width': row[4],
                    'depth': row[5],
                    'status': row[6]
                }
                for row in cursor.fetchall()
            ]
        
        page = request.GET.get('page', 1)
        paginator = Paginator(berths, 10)
        berths = paginator.get_page(page)
    
    context = {
        'ports': ports,
        'selected_port': selected_port,
        'selected_port_name': selected_port_name,
        'berths': berths
    }
    
    return render(request, 'manage_berths.html', context)


def add_berth(request):
    if request.method == 'POST':
        port_id = request.POST.get('port_id')
        berth_number = request.POST.get('berth_number')
        berth_type = request.POST.get('type')
        length = request.POST.get('length')
        width = request.POST.get('width')
        depth = request.POST.get('depth')
        status = request.POST.get('status')
        
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT COUNT(*) FROM berths WHERE port_id = %s AND berth_number = %s",
                    [port_id, berth_number]
                )
                if cursor.fetchone()[0] > 0:
                    messages.error(request, f"Berth number {berth_number} already exists for this port.")
                    return redirect(f'/admin/manage-berths?port_id={port_id}')
                
                cursor.execute(
                    """
                    INSERT INTO berths 
                    (port_id, berth_number, type, length, width, depth, status)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """,
                    [port_id, berth_number, berth_type, length, width, depth, status]
                )
                
                messages.success(request, f"Berth {berth_number} has been added successfully.")
        except Exception as e:
            messages.error(request, f"Error adding berth: {str(e)}")
        
        return redirect(f'/admin/manage-berths?port_id={port_id}')
    
    return redirect('/admin/manage-berths')


def edit_berth(request):
    if request.method == 'POST':
        berth_id = request.POST.get('berth_id')
        port_id = request.POST.get('port_id')
        berth_number = request.POST.get('berth_number')
        berth_type = request.POST.get('type')
        length = request.POST.get('length')
        width = request.POST.get('width')
        depth = request.POST.get('depth')
        status = request.POST.get('status')
        
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT COUNT(*) FROM berths 
                    WHERE port_id = %s AND berth_number = %s AND berth_id != %s
                    """,
                    [port_id, berth_number, berth_id]
                )
                if cursor.fetchone()[0] > 0:
                    messages.error(request, f"Berth number {berth_number} is already in use by another berth.")
                    return redirect(f'/admin/manage-berths?port_id={port_id}')
                
                cursor.execute(
                    """
                    UPDATE berths 
                    SET berth_number = %s, type = %s, length = %s, width = %s, depth = %s, status = %s
                    WHERE berth_id = %s
                    """,
                    [berth_number, berth_type, length, width, depth, status, berth_id]
                )
                
                messages.success(request, f"Berth {berth_number} has been updated successfully.")
        except Exception as e:
            messages.error(request, f"Error updating berth: {str(e)}")
        
        return redirect(f'/admin/manage-berths?port_id={port_id}')
    
    return redirect('/admin/manage-berths')


def delete_berth(request):
    if request.method == 'POST':
        berth_id = request.POST.get('berth_id')
        port_id = request.POST.get('port_id')
        
        try:
            berth_number = ""
            with connection.cursor() as cursor:
                cursor.execute("SELECT berth_number FROM berths WHERE berth_id = %s", [berth_id])
                result = cursor.fetchone()
                if result:
                    berth_number = result[0]
                
                cursor.execute("SELECT status FROM berths WHERE berth_id = %s", [berth_id])
                result = cursor.fetchone()
                if result and result[0] == 'occupied':
                    messages.error(request, f"Cannot delete berth {berth_number} because it is currently occupied.")
                    return redirect(f'/admin/manage-berths?port_id={port_id}')
                
                cursor.execute("DELETE FROM berths WHERE berth_id = %s", [berth_id])
                
                messages.success(request, f"Berth {berth_number} has been deleted successfully.")
        except Exception as e:
            messages.error(request, f"Error deleting berth: {str(e)}")
        
        return redirect(f'/admin/manage-berths?port_id={port_id}')
    
    return redirect('/admin/manage-berths')