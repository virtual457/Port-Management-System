-- Drop existing procedures
DROP PROCEDURE IF EXISTS find_all_routes;
DROP PROCEDURE IF EXISTS find_direct_routes;
DROP PROCEDURE IF EXISTS find_connected_routes;

DELIMITER //

-- Main procedure to find all possible routes (direct and connected) using CTEs
CREATE PROCEDURE find_all_routes(
    IN p_origin_port_id INT,
    IN p_destination_port_id INT,
    IN p_earliest_date VARCHAR(50),
    IN p_latest_date VARCHAR(50),
    IN p_cargo_id INT,
    IN p_max_connections INT
)
BEGIN
    DECLARE cargo_weight DECIMAL(10,2);
    DECLARE cargo_type VARCHAR(50);
    
    -- Get cargo details
    SELECT weight, cargo_type INTO cargo_weight, cargo_type
    FROM cargo
    WHERE cargo_id = p_cargo_id;
    
    -- Use Common Table Expressions (CTE) to organize the query
    WITH 
    -- CTE for direct routes
    direct_routes AS (
        SELECT 
            'direct' AS route_type,
            CAST(s.schedule_id AS CHAR) AS schedule_ids,
            1 AS total_segments,
            op.name AS origin_port,
            dp.name AS destination_port,
            s.departure_date,
            s.arrival_date,
            TIMESTAMPDIFF(DAY, s.departure_date, s.arrival_date) AS duration,
            r.distance,
            cargo_weight AS cargo_weight,
            (cargo_weight * r.cost_per_kg) AS total_cost,
            p_cargo_id AS cargo_id,
            ships.name AS ship_name,
            ships.ship_type,
            r.name AS route_name,
            r.route_id,
            s.schedule_id,
            r.cost_per_kg,
            s.max_cargo
        FROM 
            schedules s
        JOIN 
            routes r ON s.route_id = r.route_id
        JOIN 
            ships ON s.ship_id = ships.ship_id
        JOIN 
            ports op ON r.origin_port_id = op.port_id
        JOIN 
            ports dp ON r.destination_port_id = dp.port_id
        WHERE 
            r.origin_port_id = p_origin_port_id
            AND r.destination_port_id = p_destination_port_id
            AND DATE(s.departure_date) >= DATE(p_earliest_date)
            AND DATE(s.arrival_date) <= DATE(p_latest_date)
            AND s.status IN ('scheduled', 'in_progress')
            AND s.max_cargo >= cargo_weight
    ),
    -- CTE for first segment schedules
    first_segments AS (
        SELECT 
            s.schedule_id,
            s.route_id,
            r.origin_port_id,
            r.destination_port_id,
            s.departure_date,
            s.arrival_date,
            r.cost_per_kg,
            r.distance,
            s.max_cargo,
            r.name AS route_name,
            ships.name AS ship_name,
            ships.ship_type,
            op.name AS origin_port,
            dp.name AS destination_port
        FROM 
            schedules s
        JOIN 
            routes r ON s.route_id = r.route_id
        JOIN 
            ships ON s.ship_id = ships.ship_id
        JOIN 
            ports op ON r.origin_port_id = op.port_id
        JOIN 
            ports dp ON r.destination_port_id = dp.port_id
        WHERE 
            r.origin_port_id = p_origin_port_id
            AND DATE(s.departure_date) >= DATE(p_earliest_date)
            AND DATE(s.arrival_date) <= DATE(p_latest_date)
            AND s.status IN ('scheduled', 'in_progress')
            AND s.max_cargo >= cargo_weight
    ),
    -- CTE for second segment schedules
    second_segments AS (
        SELECT 
            s.schedule_id,
            s.route_id,
            r.origin_port_id,
            r.destination_port_id,
            s.departure_date,
            s.arrival_date,
            r.cost_per_kg,
            r.distance,
            s.max_cargo,
            r.name AS route_name,
            ships.name AS ship_name, 
            ships.ship_type,
            op.name AS origin_port,
            dp.name AS destination_port
        FROM 
            schedules s
        JOIN 
            routes r ON s.route_id = r.route_id
        JOIN 
            ships ON s.ship_id = ships.ship_id
        JOIN 
            ports op ON r.origin_port_id = op.port_id
        JOIN 
            ports dp ON r.destination_port_id = dp.port_id
        WHERE 
            r.destination_port_id = p_destination_port_id
            AND DATE(s.departure_date) >= DATE(p_earliest_date)
            AND DATE(s.arrival_date) <= DATE(p_latest_date)
            AND s.status IN ('scheduled', 'in_progress')
            AND s.max_cargo >= cargo_weight
    ),
    -- CTE for connected routes
    connected_routes AS (
        SELECT 
            'connected' AS route_type,
            CONCAT(s1.schedule_id, ',', s2.schedule_id) AS schedule_ids,
            2 AS total_segments,
            s1.origin_port AS origin_port,
            s2.destination_port AS destination_port,
            s1.departure_date,
            s2.arrival_date,
            TIMESTAMPDIFF(DAY, s1.departure_date, s2.arrival_date) AS duration,
            (s1.distance + s2.distance) AS distance,
            cargo_weight AS cargo_weight,
            (cargo_weight * (s1.cost_per_kg + s2.cost_per_kg)) AS total_cost,
            p_cargo_id AS cargo_id,
            CONCAT(s1.ship_name, ' / ', s2.ship_name) AS ship_name,
            CONCAT(s1.ship_type, ' / ', s2.ship_type) AS ship_type,
            CONCAT(s1.route_name, ' + ', s2.route_name) AS route_name,
            NULL AS route_id, -- No single route ID for connected routes
            NULL AS schedule_id, -- No single schedule ID for connected routes
            (s1.cost_per_kg + s2.cost_per_kg) AS cost_per_kg,
            LEAST(s1.max_cargo, s2.max_cargo) AS max_cargo
        FROM 
            first_segments s1
        JOIN 
            second_segments s2 ON s1.destination_port_id = s2.origin_port_id
            AND s2.departure_date >= s1.arrival_date
        WHERE
            s1.origin_port_id = p_origin_port_id
            AND s2.destination_port_id = p_destination_port_id
    )
    
    -- Select direct routes
    SELECT * FROM direct_routes
    
    -- Add connected routes if requested
    UNION ALL
    SELECT * FROM connected_routes WHERE p_max_connections > 0
    
    -- Order the combined results
    ORDER BY departure_date, total_cost, total_segments;
END //

DELIMITER ;

select * from ports;
-- Example test calls
select * from routes;
-- Test direct route only
CALL find_all_routes(1, 3, '2024-03-01', '2024-03-11', 1, 0);

-- Test both direct and connected routes
CALL find_all_routes(1, 3, '2024-03-01', '2024-04-21', 1, 2);
