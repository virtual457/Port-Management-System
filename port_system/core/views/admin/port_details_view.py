from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.db import connection
from django.http import HttpResponseRedirect
from django.urls import reverse


def port_details(request, port_id):
    """
    View for displaying detailed information about a port including its berths
    """
    # Get port information
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT port_id, name, country, 
                   ST_X(location) as longitude, 
                   ST_Y(location) as latitude, 
                   status, created_at 
            FROM ports 
            WHERE port_id = %s
        """, [port_id])
        
        port_data = cursor.fetchone()
        
        if not port_data:
            messages.error(request, "Port not found.")
            return redirect('manage-ports')
            
        port = {
            'id': port_data[0],
            'name': port_data[1],
            'country': port_data[2],
            'longitude': port_data[3],
            'latitude': port_data[4],
            'status': port_data[5],
            'created_at': port_data[6]
        }
        
        # Get berths for this port
        cursor.execute("""
            SELECT berth_id, berth_number, type, length, width, depth, status
            FROM berths
            WHERE port_id = %s
            ORDER BY berth_number
        """, [port_id])
        
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
        
        # Calculate berth type statistics
        berth_types = {'container': 0, 'bulk': 0, 'tanker': 0, 'passenger': 0, 'multipurpose': 0}
        berth_statuses = {'active': 0, 'maintenance': 0, 'occupied': 0, 'inactive': 0}
        
        for berth in berths:
            if berth['type'] in berth_types:
                berth_types[berth['type']] += 1
            
            if berth['status'] in berth_statuses:
                berth_statuses[berth['status']] += 1
        
        # Track whether we have berths of each type
        has_container_berths = berth_types['container'] > 0
        has_bulk_berths = berth_types['bulk'] > 0
        has_tanker_berths = berth_types['tanker'] > 0
        has_passenger_berths = berth_types['passenger'] > 0
        has_multipurpose_berths = berth_types['multipurpose'] > 0
        
        # Count available berths (active status)
        available_berths_count = berth_statuses['active']
    
    context = {
        'port': port,
        'berths': berths,
        'berth_types': berth_types,
        'berth_statuses': berth_statuses,
        'total_berths': len(berths),
        'available_berths_count': available_berths_count,
        'has_container_berths': has_container_berths,
        'has_bulk_berths': has_bulk_berths,
        'has_tanker_berths': has_tanker_berths,
        'has_passenger_berths': has_passenger_berths,
        'has_multipurpose_berths': has_multipurpose_berths
    }
    
    return render(request, 'port_details.html', context)