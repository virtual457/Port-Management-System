-- Drop existing procedures
DROP PROCEDURE IF EXISTS find_all_routes;
DROP PROCEDURE IF EXISTS find_direct_routes;
DROP PROCEDURE IF EXISTS find_connected_routes;

DELIMITER //

-- Procedure to find direct routes between ports
CREATE PROCEDURE find_direct_routes(
    IN p_origin_port_id INT,
    IN p_destination_port_id INT,
    IN p_earliest_date VARCHAR(50),
    IN p_latest_date VARCHAR(50),
    IN p_cargo_id INT
)
BEGIN
    DECLARE cargo_weight DECIMAL(10,2);
    DECLARE cargo_type VARCHAR(50);
    
    -- Get cargo details
    SELECT weight, cargo_type INTO cargo_weight, cargo_type
    FROM cargo
    WHERE cargo_id = p_cargo_id;
    
    -- Find direct routes
    SELECT 
        'direct' AS route_type,
        s.schedule_id,
        ships.name AS ship_name,
        ships.ship_type,
        r.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        s.departure_date,
        s.arrival_date,
        TIMESTAMPDIFF(DAY, s.departure_date, s.arrival_date) AS duration,
        r.distance,
        s.max_cargo,
        cargo_weight,
        r.cost_per_kg,
        (cargo_weight * r.cost_per_kg) AS total_cost,
        p_cargo_id AS cargo_id
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
    ORDER BY 
        s.departure_date, total_cost;
END //

-- Procedure to find connected routes between ports
CREATE PROCEDURE find_connected_routes(
    IN p_origin_port_id INT,
    IN p_destination_port_id INT,
    IN p_earliest_date VARCHAR(50),
    IN p_latest_date VARCHAR(50),
    IN p_cargo_id INT
)
BEGIN
    DECLARE cargo_weight DECIMAL(10,2);
    DECLARE cargo_type VARCHAR(50);
    
    -- Get cargo details
    SELECT weight, cargo_type INTO cargo_weight, cargo_type
    FROM cargo
    WHERE cargo_id = p_cargo_id;
    
    -- Create temporary tables for valid schedules
    DROP TEMPORARY TABLE IF EXISTS valid_schedules_first;
    DROP TEMPORARY TABLE IF EXISTS valid_schedules_second;
    
    -- First segment schedules
    CREATE TEMPORARY TABLE valid_schedules_first AS
    SELECT 
        s.schedule_id,
        s.route_id,
        r.origin_port_id,
        r.destination_port_id,
        s.departure_date,
        s.arrival_date,
        r.cost_per_kg,
        s.max_cargo
    FROM 
        schedules s
    JOIN 
        routes r ON s.route_id = r.route_id
    WHERE 
        DATE(s.departure_date) >= DATE(p_earliest_date)
        AND DATE(s.arrival_date) <= DATE(p_latest_date)
        AND s.status IN ('scheduled', 'in_progress')
        AND s.max_cargo >= cargo_weight;
    
    -- Second segment schedules
    CREATE TEMPORARY TABLE valid_schedules_second AS
    SELECT 
        s.schedule_id,
        s.route_id,
        r.origin_port_id,
        r.destination_port_id,
        s.departure_date,
        s.arrival_date,
        r.cost_per_kg,
        s.max_cargo
    FROM 
        schedules s
    JOIN 
        routes r ON s.route_id = r.route_id
    WHERE 
        DATE(s.departure_date) >= DATE(p_earliest_date)
        AND DATE(s.arrival_date) <= DATE(p_latest_date)
        AND s.status IN ('scheduled', 'in_progress')
        AND s.max_cargo >= cargo_weight;
    
    -- Find two-segment routes
    SELECT 
        'connected' AS route_type,
        CONCAT(s1.schedule_id, ',', s2.schedule_id) AS schedule_ids,
        2 AS total_segments,
        op1.name AS origin_port,
        dp2.name AS destination_port,
        s1.departure_date AS first_departure,
        s2.arrival_date AS last_arrival,
        TIMESTAMPDIFF(DAY, s1.departure_date, s2.arrival_date) AS total_duration,
        (r1.distance + r2.distance) AS total_distance,
        cargo_weight,
        (cargo_weight * (r1.cost_per_kg + r2.cost_per_kg)) AS total_cost,
        p_cargo_id AS cargo_id
    FROM 
        valid_schedules_first s1
    JOIN 
        routes r1 ON s1.route_id = r1.route_id
    JOIN 
        valid_schedules_second s2 ON s1.destination_port_id = s2.origin_port_id
        AND s2.departure_date >= s1.arrival_date
    JOIN 
        routes r2 ON s2.route_id = r2.route_id
    JOIN 
        ports op1 ON r1.origin_port_id = op1.port_id
    JOIN 
        ports dp2 ON r2.destination_port_id = dp2.port_id
    WHERE 
        r1.origin_port_id = p_origin_port_id
        AND r2.destination_port_id = p_destination_port_id;
        
    -- Clean up temporary tables
    DROP TEMPORARY TABLE IF EXISTS valid_schedules_first;
    DROP TEMPORARY TABLE IF EXISTS valid_schedules_second;
END //

-- Main procedure to find all possible routes (direct and connected)
CREATE PROCEDURE find_all_routes(
    IN p_origin_port_id INT,
    IN p_destination_port_id INT,
    IN p_earliest_date VARCHAR(50),
    IN p_latest_date VARCHAR(50),
    IN p_cargo_id INT,
    IN p_max_connections INT
)
BEGIN
    -- First, find direct routes
    CALL find_direct_routes(
        p_origin_port_id,
        p_destination_port_id,
        p_earliest_date,
        p_latest_date,
        p_cargo_id
    );
    
    -- If connections are allowed, find connected routes
    IF p_max_connections > 0 THEN
        CALL find_connected_routes(
            p_origin_port_id,
            p_destination_port_id,
            p_earliest_date,
            p_latest_date,
            p_cargo_id
        );
    END IF;
END //

DELIMITER ;

show tables;
-- Example test calls
/*
-- Test direct route
CALL find_all_routes(1, 2, '2024-03-01', '2024-03-11', 1, 0);

-- Test connected route
CALL find_all_routes(1, 4, '2024-03-01', '2024-04-21', 1, 2);
*/ 