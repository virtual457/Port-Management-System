-- Active: 1744521332564@@127.0.0.1@3306@port
-- Drop and recreate the database
DROP DATABASE IF EXISTS port;
CREATE DATABASE port;
USE port;

-- Drop existing procedures and functions if they exist
DROP PROCEDURE IF EXISTS add_new_user;
DROP PROCEDURE IF EXISTS filter_users_advanced;
DROP PROCEDURE IF EXISTS get_customer_cargo;
DROP PROCEDURE IF EXISTS add_customer_cargo;
DROP PROCEDURE IF EXISTS update_customer_cargo;
DROP PROCEDURE IF EXISTS delete_customer_cargo;
DROP FUNCTION IF EXISTS get_full_name;
DROP FUNCTION IF EXISTS get_username;

-- Users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50), 
    phone_number VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Roles table (admin, manager, staff, guest, etc.)
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO roles (role_name) VALUES ('admin'), ('manager'), ('staff'), ('customer'), ('shipowner');

-- User-Roles (many-to-many)
CREATE TABLE user_roles (
    user_id INT,
    role_id INT,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
);

DELIMITER //
CREATE FUNCTION get_full_name(uid INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE full_name VARCHAR(100);
    SELECT CONCAT(first_name, ' ', last_name) INTO full_name FROM users WHERE user_id = uid;
    RETURN full_name;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE add_new_user(IN uname VARCHAR(50), IN email VARCHAR(100))
BEGIN
    INSERT INTO users (username, email, password) VALUES (uname, email, 'default123');
END//
DELIMITER ;

DELIMITER //

DROP PROCEDURE IF EXISTS filter_users_advanced //

CREATE PROCEDURE filter_users_advanced(
    IN username_filter VARCHAR(100),
    IN email_filter VARCHAR(100),
    IN role_filter VARCHAR(50)
)
BEGIN
    SELECT 
        u.user_id, 
        u.username, 
        u.email, 
        GROUP_CONCAT(r.role_name SEPARATOR ', ') as role_name
    FROM 
        users u
    JOIN 
        user_roles ur ON u.user_id = ur.user_id
    JOIN 
        roles r ON ur.role_id = r.role_id
    WHERE 
        (username_filter IS NULL OR u.username LIKE CONCAT('%', username_filter, '%')) AND
        (email_filter IS NULL OR u.email LIKE CONCAT('%', email_filter, '%')) AND
        (role_filter IS NULL OR r.role_name = role_filter)
    GROUP BY 
        u.user_id, u.username, u.email
    ORDER BY 
        u.created_at DESC;
END//

DELIMITER ;

-- Ports table
DROP TABLE IF EXISTS ports;
CREATE TABLE ports (
    port_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    location POINT NOT NULL,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    SPATIAL INDEX(location)
);

-- Customer create tables and procedures to manage the cargo
-- Stored procedure to get username by user_id
DELIMITER //
CREATE FUNCTION get_username(p_user_id INT) 
RETURNS VARCHAR(255)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE username VARCHAR(255);
    
    SELECT u.username INTO username
    FROM users u
    WHERE u.user_id = p_user_id;
    
    RETURN username;
END//
DELIMITER ;

-- Stored procedure to get filtered cargo for a customer
DELIMITER //
CREATE PROCEDURE get_customer_cargo(
    IN p_user_id INT,
    IN p_description VARCHAR(255),
    IN p_cargo_type VARCHAR(50),
    IN p_status VARCHAR(50)
)
BEGIN
    SELECT 
        cargo_id, 
        description, 
        cargo_type, 
        weight, 
        dimensions, 
        special_instructions, 
        status,
        created_at
    FROM cargo
    WHERE user_id = p_user_id
      AND (p_description IS NULL OR description LIKE CONCAT('%', p_description, '%'))
      AND (p_cargo_type IS NULL OR cargo_type = p_cargo_type)
      AND (p_status IS NULL OR status = p_status)
    ORDER BY created_at DESC;
END//
DELIMITER ;

-- Stored procedure to add new cargo
DELIMITER //
CREATE PROCEDURE add_customer_cargo(
    IN p_user_id INT,
    IN p_description VARCHAR(255),
    IN p_cargo_type VARCHAR(50),
    IN p_weight DECIMAL(10,2),
    IN p_dimensions VARCHAR(100),
    IN p_special_instructions TEXT
)
BEGIN
    INSERT INTO cargo (
        user_id, 
        description, 
        cargo_type, 
        weight, 
        dimensions, 
        special_instructions, 
        status
    ) VALUES (
        p_user_id, 
        p_description, 
        p_cargo_type, 
        p_weight, 
        p_dimensions, 
        p_special_instructions, 
        'pending'
    );
    
    -- Return the ID of the newly created cargo
    SELECT LAST_INSERT_ID() AS cargo_id;
END//
DELIMITER ;

-- Stored procedure to update cargo
DELIMITER //
CREATE PROCEDURE update_customer_cargo(
    IN p_cargo_id INT,
    IN p_user_id INT,
    IN p_description VARCHAR(255),
    IN p_cargo_type VARCHAR(50),
    IN p_weight DECIMAL(10,2),
    IN p_dimensions VARCHAR(100),
    IN p_special_instructions TEXT
)
BEGIN
    DECLARE cargo_exists INT;
    DECLARE update_allowed INT;
    
    -- Check if cargo exists and belongs to the user
    SELECT COUNT(*) INTO cargo_exists
    FROM cargo
    WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
    
    -- Check if cargo is in a state that allows updates
    SELECT COUNT(*) INTO update_allowed
    FROM cargo
    WHERE cargo_id = p_cargo_id 
      AND user_id = p_user_id
      AND (status = 'pending' OR status = 'booked');
    
    -- Only update if cargo exists, belongs to the user, and is in an updatable state
    IF cargo_exists > 0 AND update_allowed > 0 THEN
        UPDATE cargo 
        SET description = p_description,
            cargo_type = p_cargo_type,
            weight = p_weight,
            dimensions = p_dimensions,
            special_instructions = p_special_instructions
        WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
        
        -- Return success code
        SELECT 1 AS status;
    ELSE
        -- Return failure code
        SELECT 0 AS status;
    END IF;
END//
DELIMITER ;

-- Stored procedure to delete cargo
DELIMITER //
CREATE PROCEDURE delete_customer_cargo(
    IN p_cargo_id INT,
    IN p_user_id INT
)
BEGIN
    DECLARE cargo_exists INT;
    DECLARE delete_allowed INT;
    
    -- Check if cargo exists and belongs to the user
    SELECT COUNT(*) INTO cargo_exists
    FROM cargo
    WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
    
    -- Check if cargo is in a state that allows deletion (only pending)
    SELECT COUNT(*) INTO delete_allowed
    FROM cargo
    WHERE cargo_id = p_cargo_id 
      AND user_id = p_user_id
      AND status = 'pending';
    
    -- Only delete if cargo exists, belongs to the user, and is in a deletable state
    IF cargo_exists > 0 AND delete_allowed > 0 THEN
        DELETE FROM cargo 
        WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
        
        -- Return success code
        SELECT 1 AS status;
    ELSE
        -- Return failure code
        SELECT 0 AS status;
    END IF;
END//
DELIMITER ;

-- Cargo table creation script (if needed)
DROP TABLE IF EXISTS cargo;
CREATE TABLE cargo (
    cargo_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    description VARCHAR(255) NOT NULL,
    cargo_type VARCHAR(50) NOT NULL,
    weight DECIMAL(10,2) NOT NULL,
    dimensions VARCHAR(100),
    special_instructions TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Use the port database
USE port;

-- Insert sample users
-- Password for Chandan is hashed value of 'Chandan@1998'
INSERT INTO users (username, first_name, last_name, phone_number, email, password) VALUES
('harsh', 'Harsh', 'Raj', '+19876543210', 'harsh777111raj@gmail.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('chandan', 'Chandan', 'Keelara', '+19876543210', 'chandan.keelara@gmail.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('johndoe', 'John', 'Doe', '+12345678901', 'john.doe@example.com', '$2y$10$JKfHS9jYpfLNIx.G5hZTNO1UbFT9ZVrJvzJ4Ly6o4BWvdmZl5xM3K'),
('janedoe', 'Jane', 'Doe', '+12345678902', 'jane.doe@example.com', '$2y$10$bXIQxIBbDR4hPWLIzl7i/evWPl2HBceztg5Afr/VSzCsKxURZj0ji'),
('bobsmith', 'Bob', 'Smith', '+12345678903', 'bob.smith@example.com', '$2y$10$JGLPMmUQu5PDW0aNUVT.3.MhlHlzz9JZVWBtlALGsAgMjWnhCKVXy'),
('alicejones', 'Alice', 'Jones', '+12345678904', 'alice.jones@example.com', '$2y$10$6yJrUoP21JYpRCENzRvdJuzyvOFZElvMxCb7LtJ.JUgEEQvdLNqyy'),
('mikebrown', 'Mike', 'Brown', '+12345678905', 'mike.brown@example.com', '$2y$10$bpY6rEsHlIKP7n76UW1n9OO8jmNpQCHZDSApLRlXvSSfY1PkKxjqi');

-- Assign roles to users
-- Assign all roles to Chandan
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1), -- harsh - admin
(1, 2), -- harsh - manager
(1, 3), -- harsh - staff
(1, 4), -- harsh - customer
(1, 5), -- harsh - shipowner
(2, 1), -- chandan - admin
(2, 2), -- chandan - manager
(2, 3), -- chandan - staff
(2, 4), -- chandan - customer
(2, 5), -- chandan - shipowner
(3, 1), -- johndoe - admin
(4, 2), -- janedoe - manager
(5, 3), -- bobsmith - staff
(6, 4), -- alicejones - customer
(7, 4); -- mikebrown - customer

-- Insert sample ports
INSERT INTO ports (name, country, location, status) VALUES
('Port of New York', 'USA', POINT(-74.0060, 40.7128), 'active'),
('Port of Los Angeles', 'USA', POINT(-118.2437, 33.7701), 'active'),
('Port of Rotterdam', 'Netherlands', POINT(4.4059, 51.9244), 'active'),
('Port of Shanghai', 'China', POINT(121.8947, 30.8718), 'active'),
('Port of Singapore', 'Singapore', POINT(103.8198, 1.2649), 'active'),
('Port of Santos', 'Brazil', POINT(-46.3130, -23.9619), 'active'),
('Port of Dubai', 'UAE', POINT(55.2708, 25.2048), 'active'),
('Port of Sydney', 'Australia', POINT(151.2093, -33.8688), 'active'),
('Port of Cape Town', 'South Africa', POINT(18.4241, -33.9249), 'active'),
('Port of Mombasa', 'Kenya', POINT(39.6682, -4.0435), 'inactive');

-- Insert sample cargo for different customers
INSERT INTO cargo (user_id, description, cargo_type, weight, dimensions, special_instructions, status) VALUES
(1, 'Electronics Shipment', 'container', 5000.00, '20x8x8.5', 'Handle with care. Keep dry.', 'pending'),
(1, 'Machine Parts', 'container', 12000.50, '40x8x8.5', 'Heavy equipment inside.', 'booked'),
(1, 'Refrigerated Goods', 'container', 8000.75, '40x8x8.5', 'Maintain temperature between 2-4°C', 'in_transit'),
(5, 'Furniture Set', 'container', 3500.00, '20×8×8.5', 'Fragile items inside.', 'pending'),
(5, 'Office Supplies', 'bulk', 1200.00, '8×6×4', 'Standard handling.', 'booked'),
(5, 'Textiles', 'bulk', 750.50, '5×4×3', 'Keep away from moisture.', 'delivered'),
(6, 'Construction Materials', 'bulk', 15000.00, '30×10×5', 'Heavy materials.', 'pending'),
(6, 'Vehicles - 3 Cars', 'vehicle', 5200.00, '40×8×8.5', 'Luxury vehicles, special handling required.', 'booked'),
(6, 'Industrial Chemicals', 'liquid', 12000.00, '20×8×8.5', 'Hazardous materials. Follow safety protocols.', 'in_transit'),
(6, 'Medical Supplies', 'container', 2800.00, '20×8×8.5', 'Priority shipment. Temperature controlled.', 'delivered');

-- Add more varied cargo types for filtering demo
INSERT INTO cargo (user_id, description, cargo_type, weight, dimensions, special_instructions, status) VALUES
(1, 'Crude Oil Shipment', 'liquid', 25000.00, '40×8×8.5', 'Flammable liquid.', 'pending'),
(1, 'Luxury Yacht', 'vehicle', 18000.00, '60×15×20', 'High-value item. Special insurance.', 'pending'),
(5, 'Grain Shipment', 'bulk', 22000.00, '40×8×8.5', 'Keep dry. Avoid contamination.', 'pending'),
(5, 'Automotive Parts', 'container', 8500.00, '20×8×8.5', 'OEM parts for assembly line.', 'booked'),
(6, 'Wine Barrels', 'container', 4200.00, '20×8×8.5', 'Temperature controlled. Handle with care.', 'pending'),
(6, 'Milk Products', 'liquid', 10000.00, '20×8×8.5', 'Refrigerated transport required.', 'booked');

-- Tables for shipowner
-- Table for ships
DROP TABLE IF EXISTS ships;
CREATE TABLE ships (
    ship_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    ship_type ENUM('container', 'bulk', 'tanker', 'roro') NOT NULL,
    capacity DECIMAL(12, 2) NOT NULL,
    current_port_id INT,
    imo_number VARCHAR(20) NOT NULL UNIQUE,
    flag VARCHAR(50) NOT NULL,
    year_built INT NOT NULL,
    status ENUM('active', 'maintenance', 'docked', 'in_transit', 'deleted') NOT NULL,
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (current_port_id) REFERENCES ports(port_id),
    FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

-- Table for routes
-- Drop existing routes table if it exists
DROP TABLE IF EXISTS routes;

-- Create routes table with new columns
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    origin_port_id INT NOT NULL,
    destination_port_id INT NOT NULL,
    distance DECIMAL(10, 2) NOT NULL COMMENT 'Distance in nautical miles',
    duration DECIMAL(6, 2) NOT NULL COMMENT 'Duration in days',
    status ENUM('active', 'inactive', 'seasonal', 'deleted') NOT NULL DEFAULT 'active',
    owner_id INT NOT NULL,
    ship_id INT,
    cost_per_kg DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (origin_port_id) REFERENCES ports(port_id),
    FOREIGN KEY (destination_port_id) REFERENCES ports(port_id),
    FOREIGN KEY (owner_id) REFERENCES users(user_id),
    FOREIGN KEY (ship_id) REFERENCES ships(ship_id),
    
    CONSTRAINT different_ports CHECK (origin_port_id != destination_port_id),
    CONSTRAINT positive_distance CHECK (distance > 0),
    CONSTRAINT positive_duration CHECK (duration > 0),
    CONSTRAINT non_negative_cost CHECK (cost_per_kg >= 0)
);

-- Table for voyage schedules
-- Drop the existing schedules table (this will delete all existing data)
DROP TABLE IF EXISTS schedules;

-- Create the updated schedules table with max_cargo and notes columns
CREATE TABLE schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    ship_id INT NOT NULL,
    route_id INT NOT NULL,
    departure_date DATETIME NOT NULL,
    arrival_date DATETIME NOT NULL,
    actual_departure DATETIME,
    actual_arrival DATETIME,
    status ENUM('scheduled', 'in_progress', 'completed', 'cancelled', 'delayed') NOT NULL,
    max_cargo DECIMAL(12, 2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ship_id) REFERENCES ships(ship_id) ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE,
    CONSTRAINT valid_dates CHECK (arrival_date > departure_date)
);

-- Create berths table
-- Create berths table
DROP TABLE IF EXISTS berths;
CREATE TABLE berths (
    berth_id INT AUTO_INCREMENT PRIMARY KEY,
    berth_number VARCHAR(20) NOT NULL,
    port_id INT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'container',  -- Changed from berth_type to type
    length DECIMAL(10, 2) NOT NULL,  -- Added length field instead of capacity
    width DECIMAL(10, 2) NOT NULL,   -- Added width field
    depth DECIMAL(10, 2) NOT NULL,   -- Added depth field
    status VARCHAR(20) NOT NULL DEFAULT 'active',  -- Changed from ENUM to VARCHAR
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (port_id) REFERENCES ports(port_id) ON DELETE CASCADE
);

-- Create berth assignments table
DROP TABLE IF EXISTS berth_assignments;
CREATE TABLE berth_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    berth_id INT NOT NULL,
    ship_id INT NOT NULL,
    schedule_id INT NOT NULL,
    arrival_time DATETIME NOT NULL,
    departure_time DATETIME NOT NULL,
    status ENUM('scheduled', 'current', 'completed', 'cancelled') NOT NULL DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (berth_id) REFERENCES berths(berth_id) ON DELETE CASCADE,
    FOREIGN KEY (ship_id) REFERENCES ships(ship_id) ON DELETE CASCADE,
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id) ON DELETE CASCADE
);

-- Add some sample data for berths
INSERT INTO berths (berth_number, port_id, type, length, width, depth, status) VALUES
('B001', 1, 'container', 300.00, 50.00, 15.00, 'active'),
('B002', 1, 'bulk', 250.00, 40.00, 12.00, 'active'),
('B003', 1, 'tanker', 350.00, 60.00, 18.00, 'maintenance'),
('B004', 2, 'container', 300.00, 50.00, 15.00, 'active'),
('B005', 2, 'bulk', 250.00, 40.00, 12.00, 'active'),
('B006', 3, 'container', 320.00, 55.00, 16.00, 'active'),
('B007', 3, 'tanker', 360.00, 65.00, 19.00, 'active'),
('B008', 4, 'container', 305.00, 52.00, 15.50, 'active'),
('B009', 5, 'roro', 280.00, 60.00, 12.00, 'active'),
('B010', 6, 'container', 310.00, 53.00, 16.00, 'active');

-- Create stored procedure to get berth assignments for a specific ship
DELIMITER //
CREATE PROCEDURE get_ship_berth_assignments(
    IN p_ship_id INT
)
BEGIN
    SELECT 
        ba.assignment_id,
        ba.berth_id,
        b.berth_number,
        p.name AS port_name,
        p.country AS port_country,
        ba.arrival_time,
        ba.departure_time,
        ba.status,
        s.ship_id,
        s.name AS ship_name,
        sc.schedule_id,
        r.name AS route_name
    FROM berth_assignments ba
    JOIN berths b ON ba.berth_id = b.berth_id
    JOIN ports p ON b.port_id = p.port_id
    JOIN ships s ON ba.ship_id = s.ship_id
    JOIN schedules sc ON ba.schedule_id = sc.schedule_id
    JOIN routes r ON sc.route_id = r.route_id
    WHERE ba.ship_id = p_ship_id
    ORDER BY ba.arrival_time DESC;
END//
DELIMITER ;

-- Create stored procedure to get all berth assignments
DELIMITER //
CREATE PROCEDURE get_all_berth_assignments()
BEGIN
    SELECT 
        ba.assignment_id,
        ba.berth_id,
        b.berth_number,
        p.name AS port_name,
        p.country AS port_country,
        ba.arrival_time,
        ba.departure_time,
        ba.status,
        s.ship_id,
        s.name AS ship_name,
        s.owner_id,
        sc.schedule_id,
        r.name AS route_name
    FROM berth_assignments ba
    JOIN berths b ON ba.berth_id = b.berth_id
    JOIN ports p ON b.port_id = p.port_id
    JOIN ships s ON ba.ship_id = s.ship_id
    JOIN schedules sc ON ba.schedule_id = sc.schedule_id
    JOIN routes r ON sc.route_id = r.route_id
    ORDER BY ba.arrival_time DESC;
END//
DELIMITER ;



-- New ADditions
CREATE TABLE connected_bookings (
    connected_booking_id INT AUTO_INCREMENT PRIMARY KEY,
    cargo_id INT NOT NULL,
    user_id INT NOT NULL,
    origin_port_id INT NOT NULL,
    destination_port_id INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_status ENUM('pending', 'confirmed', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
    payment_status ENUM('unpaid', 'paid', 'refunded') NOT NULL DEFAULT 'unpaid',
    total_price DECIMAL(12, 2) NOT NULL,
    notes TEXT,
    FOREIGN KEY (cargo_id) REFERENCES cargo(cargo_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (origin_port_id) REFERENCES ports(port_id),
    FOREIGN KEY (destination_port_id) REFERENCES ports(port_id)
);

CREATE TABLE connected_booking_segments (
    segment_id INT AUTO_INCREMENT PRIMARY KEY,
    connected_booking_id INT NOT NULL,
    schedule_id INT NOT NULL,
    segment_order INT NOT NULL,
    segment_price DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (connected_booking_id) REFERENCES connected_bookings(connected_booking_id),
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id)
);

USE port;

DROP PROCEDURE IF EXISTS find_direct_routes;

DELIMITER //

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
        AND s.departure_date >= STR_TO_DATE(p_earliest_date, '%Y-%m-%d')
        AND s.arrival_date <= STR_TO_DATE(p_latest_date, '%Y-%m-%d 23:59:59')
        AND s.status IN ('scheduled', 'in_progress')
        AND s.max_cargo >= cargo_weight
    ORDER BY 
        s.departure_date, total_cost;
END //

DELIMITER ;

-- Test the procedure
CALL find_direct_routes(
    1,              -- NY
    3,              -- Rotterdam
    '2023-10-01',   -- Start date
    '2023-12-31',   -- End date
    1               -- Cargo ID (Electronics)
); 

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

-- Create cargo_bookings table if it doesn't exist
-- Create cargo_bookings table if it doesn't exist
CREATE TABLE IF NOT EXISTS cargo_bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    cargo_id INT NOT NULL,
    schedule_id INT NOT NULL,
    user_id INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_status ENUM('pending', 'confirmed', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
    payment_status ENUM('unpaid', 'paid', 'refunded') NOT NULL DEFAULT 'unpaid',
    price DECIMAL(12, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cargo_id) REFERENCES cargo(cargo_id) ON DELETE CASCADE,
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_cargo_bookings_user ON cargo_bookings(user_id);
CREATE INDEX idx_cargo_bookings_cargo ON cargo_bookings(cargo_id);
CREATE INDEX idx_cargo_bookings_schedule ON cargo_bookings(schedule_id);
CREATE INDEX idx_cargo_bookings_status ON cargo_bookings(booking_status);

-- Create connected_bookings table if it doesn't exist (for multi-segment routes)
CREATE TABLE IF NOT EXISTS connected_bookings (
    connected_booking_id INT AUTO_INCREMENT PRIMARY KEY,
    cargo_id INT NOT NULL,
    user_id INT NOT NULL,
    origin_port_id INT NOT NULL,
    destination_port_id INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_status ENUM('pending', 'confirmed', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
    payment_status ENUM('unpaid', 'paid', 'refunded') NOT NULL DEFAULT 'unpaid',
    total_price DECIMAL(12, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cargo_id) REFERENCES cargo(cargo_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (origin_port_id) REFERENCES ports(port_id) ON DELETE CASCADE,
    FOREIGN KEY (destination_port_id) REFERENCES ports(port_id) ON DELETE CASCADE
);

-- Create indexes for connected_bookings
CREATE INDEX idx_connected_bookings_user ON connected_bookings(user_id);
CREATE INDEX idx_connected_bookings_cargo ON connected_bookings(cargo_id);
CREATE INDEX idx_connected_bookings_status ON connected_bookings(booking_status);

-- Create connected_booking_segments table to store individual segments of a connected booking
CREATE TABLE IF NOT EXISTS connected_booking_segments (
    segment_id INT AUTO_INCREMENT PRIMARY KEY,
    connected_booking_id INT NOT NULL,
    schedule_id INT NOT NULL,
    segment_order INT NOT NULL,
    segment_price DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (connected_booking_id) REFERENCES connected_bookings(connected_booking_id) ON DELETE CASCADE,
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id) ON DELETE CASCADE
);

-- Create indexes for connected_booking_segments
CREATE INDEX idx_segment_booking ON connected_booking_segments(connected_booking_id);
CREATE INDEX idx_segment_schedule ON connected_booking_segments(schedule_id);
CREATE INDEX idx_segment_order ON connected_booking_segments(segment_order);

-- Create stored procedure to get booking details
DELIMITER //
CREATE PROCEDURE get_booking_details(IN p_booking_id INT, IN p_user_id INT)
BEGIN
    SELECT 
        b.booking_id,
        b.cargo_id,
        c.description AS cargo_description,
        c.cargo_type,
        c.weight AS cargo_weight,
        c.dimensions AS cargo_dimensions,
        b.schedule_id,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        b.booking_status,
        b.payment_status,
        b.price,
        b.booking_date,
        b.notes,
        ships.name AS ship_name,
        ships.ship_type
    FROM 
        cargo_bookings b
    JOIN 
        cargo c ON b.cargo_id = c.cargo_id
    JOIN 
        schedules s ON b.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        b.booking_id = p_booking_id AND b.user_id = p_user_id;
END//
DELIMITER ;

-- Create stored procedure to get connected booking details
DELIMITER //
CREATE PROCEDURE get_connected_booking_details(IN p_booking_id INT, IN p_user_id INT)
BEGIN
    -- Get main booking info
    SELECT 
        cb.connected_booking_id,
        cb.cargo_id,
        c.description AS cargo_description,
        c.cargo_type,
        c.weight AS cargo_weight,
        c.dimensions AS cargo_dimensions,
        op.name AS origin_port,
        dp.name AS destination_port,
        cb.booking_status,
        cb.payment_status,
        cb.total_price,
        cb.booking_date,
        cb.notes
    FROM 
        connected_bookings cb
    JOIN 
        cargo c ON cb.cargo_id = c.cargo_id
    JOIN 
        ports op ON cb.origin_port_id = op.port_id
    JOIN 
        ports dp ON cb.destination_port_id = dp.port_id
    WHERE 
        cb.connected_booking_id = p_booking_id AND cb.user_id = p_user_id;
    
    -- Get segment details in a separate result set
    SELECT 
        cbs.segment_id,
        cbs.segment_order,
        cbs.schedule_id,
        cbs.segment_price,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        TIMESTAMPDIFF(DAY, s.departure_date, s.arrival_date) AS duration,
        ships.name AS ship_name,
        ships.ship_type
    FROM 
        connected_booking_segments cbs
    JOIN 
        schedules s ON cbs.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        cbs.connected_booking_id = p_booking_id
    ORDER BY 
        cbs.segment_order;
END//
DELIMITER ;

-- Create trigger to handle cargo status updates when a booking is made
DELIMITER //
CREATE TRIGGER after_booking_insert
AFTER INSERT ON cargo_bookings
FOR EACH ROW
BEGIN
    -- Update cargo status to 'booked'
    UPDATE cargo 
    SET status = 'booked'
    WHERE cargo_id = NEW.cargo_id;
END//
DELIMITER ;

-- Create trigger to handle cargo status updates when a connected booking is made
DELIMITER //
CREATE TRIGGER after_connected_booking_insert
AFTER INSERT ON connected_bookings
FOR EACH ROW
BEGIN
    -- Update cargo status to 'booked'
    UPDATE cargo 
    SET status = 'booked'
    WHERE cargo_id = NEW.cargo_id;
END//
DELIMITER ;

-- Create trigger to handle cargo status updates when a booking is cancelled
DELIMITER //
CREATE TRIGGER after_booking_update
AFTER UPDATE ON cargo_bookings
FOR EACH ROW
BEGIN
    IF NEW.booking_status = 'cancelled' AND OLD.booking_status != 'cancelled' THEN
        -- Update cargo status back to 'pending'
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = NEW.cargo_id;
    END IF;
END//
DELIMITER ;

-- Create trigger to handle cargo status updates when a connected booking is cancelled
DELIMITER //
CREATE TRIGGER after_connected_booking_update
AFTER UPDATE ON connected_bookings
FOR EACH ROW
BEGIN
    IF NEW.booking_status = 'cancelled' AND OLD.booking_status != 'cancelled' THEN
        -- Update cargo status back to 'pending'
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = NEW.cargo_id;
    END IF;
END//
DELIMITER ;


-- Stored procedure to get customer dashboard statistics
DROP PROCEDURE IF EXISTS get_customer_dashboard_stats;
DELIMITER //
CREATE PROCEDURE get_customer_dashboard_stats(
    IN p_user_id INT
)
BEGIN
    -- Get cargo count
    SELECT COUNT(*) AS cargo_count FROM cargo WHERE user_id = p_user_id;
    
    -- Get active bookings count (direct bookings)
    SELECT COUNT(*) AS direct_active_bookings 
    FROM cargo_bookings 
    WHERE user_id = p_user_id AND booking_status IN ('pending', 'confirmed');
    
    -- Get active bookings count (connected bookings)
    SELECT COUNT(*) AS connected_active_bookings 
    FROM connected_bookings 
    WHERE user_id = p_user_id AND booking_status IN ('pending', 'confirmed');
    
    -- Get shipments in transit
    SELECT COUNT(*) AS in_transit_count 
    FROM cargo 
    WHERE user_id = p_user_id AND status = 'in_transit';
    
    -- Get completed shipments
    SELECT COUNT(*) AS completed_count 
    FROM cargo 
    WHERE user_id = p_user_id AND status = 'delivered';
END//
DELIMITER ;

-- Stored procedure to get recent bookings for dashboard
DROP PROCEDURE IF EXISTS get_customer_recent_bookings;
DELIMITER //
CREATE PROCEDURE get_customer_recent_bookings(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    -- Using UNION to combine direct and connected bookings
    (SELECT 
        'direct' as type,
        b.booking_id,
        c.description as cargo_description,
        c.cargo_type,
        p1.name as origin_port,
        p2.name as destination_port,
        s.departure_date,
        NULL as first_departure,
        b.booking_status,
        b.booking_id as connected_booking_id
    FROM cargo_bookings b
    JOIN cargo c ON b.cargo_id = c.cargo_id
    JOIN schedules s ON b.schedule_id = s.schedule_id
    JOIN routes r ON s.route_id = r.route_id
    JOIN ports p1 ON r.origin_port_id = p1.port_id
    JOIN ports p2 ON r.destination_port_id = p2.port_id
    WHERE b.user_id = p_user_id)
    
    UNION ALL
    
    (SELECT 
        'connected' as type,
        cb.connected_booking_id as booking_id,
        c.description as cargo_description,
        c.cargo_type,
        p1.name as origin_port,
        p2.name as destination_port,
        NULL as departure_date,
        (SELECT MIN(s.departure_date) 
         FROM connected_booking_segments cbs
         JOIN schedules s ON cbs.schedule_id = s.schedule_id
         WHERE cbs.connected_booking_id = cb.connected_booking_id) as first_departure,
        cb.booking_status,
        cb.connected_booking_id
    FROM connected_bookings cb
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    JOIN ports p1 ON cb.origin_port_id = p1.port_id
    JOIN ports p2 ON cb.destination_port_id = p2.port_id
    WHERE cb.user_id = p_user_id)
    
    ORDER BY booking_status = 'confirmed' DESC, 
             booking_status = 'pending' DESC,
             booking_status = 'completed' DESC,
             COALESCE(departure_date, first_departure) DESC
    LIMIT p_limit;
END//
DELIMITER ;

-- Stored procedure to get upcoming shipments for dashboard
DROP PROCEDURE IF EXISTS get_customer_upcoming_shipments;
DELIMITER //



CREATE PROCEDURE get_customer_upcoming_shipments(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    (SELECT 
        c.description as cargo_description,
        p1.name as origin_port,
        p2.name as destination_port,
        s.departure_date,
        DATEDIFF(s.departure_date, NOW()) as days_until
    FROM cargo_bookings b
    JOIN cargo c ON b.cargo_id = c.cargo_id
    JOIN schedules s ON b.schedule_id = s.schedule_id
    JOIN routes r ON s.route_id = r.route_id
    JOIN ports p1 ON r.origin_port_id = p1.port_id
    JOIN ports p2 ON r.destination_port_id = p2.port_id
    WHERE b.user_id = p_user_id AND b.booking_status = 'confirmed' 
    AND s.departure_date > CURRENT_DATE())
    
    UNION ALL
    
    (SELECT 
        c.description as cargo_description,
        p1.name as origin_port,
        p2.name as destination_port,
        (SELECT MIN(s.departure_date) 
         FROM connected_booking_segments cbs
         JOIN schedules s ON cbs.schedule_id = s.schedule_id
         WHERE cbs.connected_booking_id = cb.connected_booking_id
         AND s.departure_date > NOW()) as departure_date,
        DATEDIFF((SELECT MIN(s.departure_date) 
                  FROM connected_booking_segments cbs
                  JOIN schedules s ON cbs.schedule_id = s.schedule_id
                  WHERE cbs.connected_booking_id = cb.connected_booking_id
                  AND s.departure_date > NOW()), NOW()) as days_until
    FROM connected_bookings cb
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    JOIN ports p1 ON cb.origin_port_id = p1.port_id
    JOIN ports p2 ON cb.destination_port_id = p2.port_id
    WHERE cb.user_id = p_user_id AND cb.booking_status = 'confirmed'
    HAVING departure_date IS NOT NULL)
    
    ORDER BY days_until ASC
    LIMIT p_limit;
END//
DELIMITER ;

-- Stored procedure to get popular shipping routes
DROP PROCEDURE IF EXISTS get_popular_shipping_routes;
DELIMITER //
CREATE PROCEDURE get_popular_shipping_routes(
    IN p_limit INT
)
BEGIN
    SELECT 
        r.route_id,
        op.port_id as origin_id,
        dp.port_id as destination_id,
        op.name as origin_port,
        dp.name as destination_port,
        r.duration,
        COUNT(DISTINCT s.ship_id) as available_ships,
        AVG(r.cost_per_kg) as avg_cost_per_kg
    FROM 
        routes r
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    LEFT JOIN 
        schedules s ON r.route_id = s.route_id AND 
                       s.departure_date > NOW() AND
                       s.status = 'scheduled'
    WHERE 
        r.status = 'active'
    GROUP BY 
        r.route_id, op.name, dp.name, r.duration
    ORDER BY 
        COUNT(DISTINCT s.schedule_id) DESC, 
        AVG(r.cost_per_kg) ASC
    LIMIT p_limit;
END//
DELIMITER ;

DELIMITER //

DROP PROCEDURE IF EXISTS delete_port //

CREATE PROCEDURE delete_port(
    IN p_port_id INT,
    OUT p_status BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE berth_count INT DEFAULT 0;
    DECLARE route_count INT DEFAULT 0;
    DECLARE port_name VARCHAR(100);
    
    -- Get port name for message
    SELECT name INTO port_name FROM ports WHERE port_id = p_port_id;
    
    IF port_name IS NULL THEN
        SET p_status = FALSE;
        SET p_message = 'Port not found.';
    ELSE
        -- Check if port has berths
        SELECT COUNT(*) INTO berth_count FROM berths WHERE port_id = p_port_id;
        
        -- Check if port is used in routes (as origin or destination)
        SELECT COUNT(*) INTO route_count 
        FROM routes 
        WHERE origin_port_id = p_port_id OR destination_port_id = p_port_id;
        
        -- Only delete if no dependencies exist
        IF berth_count > 0 THEN
            SET p_status = FALSE;
            SET p_message = CONCAT('Cannot delete port "', port_name, '". It has ', berth_count, ' berth(s) associated with it. Please delete them first.');
        ELSEIF route_count > 0 THEN
            SET p_status = FALSE;
            SET p_message = CONCAT('Cannot delete port "', port_name, '". It is used in ', route_count, ' route(s). Please delete them first.');
        ELSE
            -- Safe to delete
            DELETE FROM ports WHERE port_id = p_port_id;
            SET p_status = TRUE;
            SET p_message = CONCAT('Port "', port_name, '" deleted successfully!');
        END IF;
    END IF;
END//

DELIMITER ;


-- Drop the table if it exists
DROP TABLE IF EXISTS berth_assignments;


CREATE TABLE berth_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    berth_id INT NOT NULL,
    ship_id INT NOT NULL,
    schedule_id INT NOT NULL,
    arrival_time DATETIME NOT NULL,
    departure_time DATETIME NOT NULL,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE berth_assignments
ADD CONSTRAINT fk_berth
    FOREIGN KEY (berth_id) REFERENCES berths(berth_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_ship
    FOREIGN KEY (ship_id) REFERENCES ships(ship_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_schedule
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id) ON DELETE CASCADE;


ALTER TABLE berth_assignments
ADD CONSTRAINT valid_assignment_times
CHECK (arrival_time < departure_time);


show create table berth_assignments;


DELIMITER //

DROP PROCEDURE IF EXISTS get_available_berths //

CREATE PROCEDURE get_available_berths(
    IN p_port_id INT,
    IN p_start_time DATETIME,
    IN p_end_time DATETIME
)
BEGIN
    -- Get all available berths from the specified port
    -- that are marked as active
    -- and are not already booked during the requested time period
    SELECT 
        b.berth_id,
        b.berth_number,
        b.type,
        b.length,
        b.width,
        b.depth,
        b.status
    FROM 
        berths b
    WHERE 
        b.port_id = p_port_id
        AND b.status = 'active'
        AND NOT EXISTS (
            -- Check for overlapping berth assignments
            SELECT 1
            FROM berth_assignments ba
            WHERE ba.berth_id = b.berth_id
              AND ba.status = 'active'
              AND (
                  -- New booking starts during existing booking
                  (p_start_time BETWEEN ba.arrival_time AND ba.departure_time)
                  -- New booking ends during existing booking
                  OR (p_end_time BETWEEN ba.arrival_time AND ba.departure_time)
                  -- New booking completely contains existing booking
                  OR (p_start_time <= ba.arrival_time AND p_end_time >= ba.departure_time)
              )
        )
    ORDER BY 
        b.berth_number;
END//

DELIMITER ;

CALL get_available_berths(
    1, 
    '2025-04-20 08:00:00', 
    '2025-04-20 18:00:00'
);


DELIMITER //

DROP PROCEDURE IF EXISTS check_berth_availability //

CREATE PROCEDURE check_berth_availability(
    IN p_berth_id INT,
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    OUT p_is_available BOOLEAN,
    OUT p_conflict_details VARCHAR(255)
)
BEGIN
    DECLARE conflict_count INT;
    DECLARE berth_status VARCHAR(20);
    DECLARE conflict_start DATETIME;
    DECLARE conflict_end DATETIME;
    DECLARE conflict_ship VARCHAR(100);
    
    -- First, check if the berth exists and is active
    SELECT status INTO berth_status
    FROM berths
    WHERE berth_id = p_berth_id;
    
    IF berth_status IS NULL THEN
        SET p_is_available = FALSE;
        SET p_conflict_details = 'Berth does not exist';
    ELSEIF berth_status != 'active' THEN
        SET p_is_available = FALSE;
        SET p_conflict_details = CONCAT('Berth is not active (current status: ', berth_status, ')');
    ELSE
        -- Check for overlapping berth assignments
        SELECT COUNT(*), 
               MIN(ba.arrival_time),
               MIN(ba.departure_time),
               (SELECT name FROM ships WHERE ship_id = MIN(ba.ship_id))
        INTO conflict_count, conflict_start, conflict_end, conflict_ship
        FROM berth_assignments ba
        WHERE ba.berth_id = p_berth_id
          AND ba.status = 'active'
          AND (
              -- New booking starts during existing booking
              (p_start_time BETWEEN ba.arrival_time AND ba.departure_time)
              -- New booking ends during existing booking
              OR (p_end_time BETWEEN ba.arrival_time AND ba.departure_time)
              -- New booking completely contains existing booking
              OR (p_start_time <= ba.arrival_time AND p_end_time >= ba.departure_time)
          );
        
        IF conflict_count > 0 THEN
            SET p_is_available = FALSE;
            SET p_conflict_details = CONCAT(
                'Berth already booked by ', 
                conflict_ship, 
                ' from ', 
                DATE_FORMAT(conflict_start, '%Y-%m-%d %H:%i'),
                ' to ',
                DATE_FORMAT(conflict_end, '%Y-%m-%d %H:%i')
            );
        ELSE
            SET p_is_available = TRUE;
            SET p_conflict_details = 'Berth is available for the requested time period';
        END IF;
    END IF;
END//

DELIMITER ;

-- Step 1: Declare variables-- Step 1: Define the OUT parameters
SET @is_available = NULL;
SET @conflict_details = NULL;

-- Step 2: Call the procedure with your inputs
CALL check_berth_availability(
    17,                                      -- p_berth_id
    '2025-04-16 16:38:00',                   -- p_start_time
    '2025-04-18 16:40:00',                   -- p_end_time
    @is_available,                          -- OUT: availability flag
    @conflict_details                       -- OUT: details if conflict exists
);

-- Step 3: Retrieve the OUT values
SELECT @is_available AS is_available, @conflict_details AS conflict_details;



DELIMITER //

DROP PROCEDURE IF EXISTS create_schedule_with_berths //

CREATE PROCEDURE create_schedule_with_berths(
    IN p_ship_id INT,
    IN p_route_id INT,
    IN p_max_cargo DECIMAL(12, 2),
    IN p_status VARCHAR(20),
    IN p_notes TEXT,
    IN p_departure_date DATETIME,
    IN p_arrival_date DATETIME,
    IN p_origin_berth_id INT,
    IN p_origin_berth_start DATETIME,
    IN p_origin_berth_end DATETIME,
    IN p_destination_berth_id INT,
    IN p_destination_berth_start DATETIME,
    IN p_destination_berth_end DATETIME,
    OUT p_schedule_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE origin_available BOOLEAN;
    DECLARE destination_available BOOLEAN;
    DECLARE origin_conflict VARCHAR(255);
    DECLARE destination_conflict VARCHAR(255);
    
    -- Check berth availability
    CALL check_berth_availability(p_origin_berth_id, p_origin_berth_start, p_origin_berth_end, origin_available, origin_conflict);
    CALL check_berth_availability(p_destination_berth_id, p_destination_berth_start, p_destination_berth_end, destination_available, destination_conflict);
    
    -- If both berths are available, create the schedule and berth assignments
    IF origin_available = TRUE AND destination_available = TRUE THEN
        START TRANSACTION;
        
        -- Insert the schedule
        INSERT INTO schedules (
            ship_id, 
            route_id, 
            departure_date, 
            arrival_date, 
            status, 
            max_cargo, 
            notes, 
            created_at, 
            updated_at
        ) VALUES (
            p_ship_id,
            p_route_id,
            p_departure_date,
            p_arrival_date,
            p_status,
            p_max_cargo,
            p_notes,
            NOW(),
            NOW()
        );
        
        -- Get the newly created schedule ID
        SET p_schedule_id = LAST_INSERT_ID();
        
        -- Create berth assignments
        -- Origin berth assignment
        INSERT INTO berth_assignments (
            berth_id,
            ship_id,
            schedule_id,
            arrival_time,
            departure_time,
            status,
            created_at,
            updated_at
        ) VALUES (
            p_origin_berth_id,
            p_ship_id,
            p_schedule_id,
            p_origin_berth_start,
            p_origin_berth_end,
            'active',
            NOW(),
            NOW()
        );
        
        -- Destination berth assignment
        INSERT INTO berth_assignments (
            berth_id,
            ship_id,
            schedule_id,
            arrival_time,
            departure_time,
            status,
            created_at,
            updated_at
        ) VALUES (
            p_destination_berth_id,
            p_ship_id,
            p_schedule_id,
            p_destination_berth_start,
            p_destination_berth_end,
            'active',
            NOW(),
            NOW()
        );
        
        COMMIT;
        
        SET p_success = TRUE;
        SET p_message = 'Schedule created successfully with berth assignments';
    ELSE
        -- Return error message if berths are not available
        SET p_success = FALSE;
        IF origin_available = FALSE THEN
            SET p_message = CONCAT('Origin berth issue: ', origin_conflict);
        ELSE
            SET p_message = CONCAT('Destination berth issue: ', destination_conflict);
        END IF;
    END IF;
END//

DELIMITER ;

DELIMITER //

DROP PROCEDURE IF EXISTS get_schedule_berth_assignments //

CREATE PROCEDURE get_schedule_berth_assignments(
    IN p_schedule_id INT
)
BEGIN
    SELECT 
        ba.assignment_id,
        ba.berth_id,
        b.berth_number,
        p.name AS port_name,
        ba.ship_id,
        s.name AS ship_name,
        ba.arrival_time,
        ba.departure_time,
        ba.status AS assignment_status,
        CASE
            WHEN ba.status = 'inactive' THEN 'cancelled'
            WHEN NOW() < ba.arrival_time THEN 'scheduled'
            WHEN NOW() BETWEEN ba.arrival_time AND ba.departure_time THEN 'current'
            ELSE 'completed'
        END AS operational_status
    FROM 
        berth_assignments ba
    JOIN 
        berths b ON ba.berth_id = b.berth_id
    JOIN 
        ports p ON b.port_id = p.port_id
    JOIN 
        ships s ON ba.ship_id = s.ship_id
    WHERE 
        ba.schedule_id = p_schedule_id
    ORDER BY 
        ba.arrival_time;
END//

DELIMITER ;

DELIMITER //

DROP PROCEDURE IF EXISTS add_route //

CREATE PROCEDURE add_route(
    IN p_name VARCHAR(100),
    IN p_origin_port_id INT,
    IN p_destination_port_id INT,
    IN p_distance DECIMAL(10, 2),
    IN p_duration DECIMAL(6, 2),
    IN p_status VARCHAR(20),
    IN p_cost_per_kg DECIMAL(10, 2),
    IN p_owner_id INT,
    OUT p_route_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE valid_ports INT;
    DECLARE route_exists INT;
    
    -- Check if both ports exist and are active
    SELECT COUNT(*) INTO valid_ports 
    FROM ports p1, ports p2
    WHERE p1.port_id = p_origin_port_id 
      AND p2.port_id = p_destination_port_id
      AND p1.status = 'active'
      AND p2.status = 'active';
    
    -- Check if this route already exists for this owner
    SELECT COUNT(*) INTO route_exists
    FROM routes
    WHERE owner_id = p_owner_id
      AND origin_port_id = p_origin_port_id
      AND destination_port_id = p_destination_port_id
      AND status != 'deleted';
      
    -- Begin validation checks
    IF p_origin_port_id = p_destination_port_id THEN
        SET p_success = FALSE;
        SET p_message = 'Origin and destination ports cannot be the same.';
    ELSEIF valid_ports < 1 THEN
        SET p_success = FALSE;
        SET p_message = 'One or both ports do not exist or are not active.';
    ELSEIF p_distance <= 0 THEN
        SET p_success = FALSE;
        SET p_message = 'Distance must be greater than zero.';
    ELSEIF p_duration <= 0 THEN
        SET p_success = FALSE;
        SET p_message = 'Duration must be greater than zero.';
    ELSEIF route_exists > 0 THEN
        SET p_success = FALSE;
        SET p_message = 'A route between these ports already exists. Please edit the existing route instead.';
    ELSEIF p_cost_per_kg <= 0 THEN
        SET p_success = FALSE;
        SET p_message = 'Cost per kg cannot be negative or zero. You might loose a lot of money.';
    ELSE
        -- All validations passed, insert the route
        INSERT INTO routes (
            name, 
            origin_port_id, 
            destination_port_id, 
            distance, 
            duration, 
            status, 
            owner_id, 
            cost_per_kg
        ) VALUES (
            p_name,
            p_origin_port_id,
            p_destination_port_id,
            p_distance,
            p_duration,
            p_status,
            p_owner_id,
            p_cost_per_kg
        );
        
        SET p_route_id = LAST_INSERT_ID();
        SET p_success = TRUE;
        SET p_message = CONCAT('Route "', p_name, '" created successfully!');
    END IF;
END//

DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_cargo_by_type(
    IN p_user_id INT
)
BEGIN
    SELECT 
        cargo_type, 
        COUNT(*) as count
    FROM 
        cargo
    WHERE 
        user_id = p_user_id
    GROUP BY 
        cargo_type
    ORDER BY 
        count DESC;
END//
DELIMITER ;

-- Suggestion for a new stored procedure
DELIMITER //
CREATE PROCEDURE get_booking_status_counts(
    IN p_user_id INT
)
BEGIN
    SELECT 
        'direct' as type,
        booking_status,
        COUNT(*) as count
    FROM 
        cargo_bookings
    WHERE 
        user_id = p_user_id
    GROUP BY 
        booking_status
    
    UNION ALL
    
    SELECT 
        'connected' as type,
        booking_status,
        COUNT(*) as count
    FROM 
        connected_bookings
    WHERE 
        user_id = p_user_id
    GROUP BY 
        booking_status;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_monthly_shipping_activity(
    IN p_user_id INT,
    IN p_days_back INT
)
BEGIN
    -- Calculate start date
    SET @start_date = DATE_SUB(CURDATE(), INTERVAL p_days_back DAY);
    
    SELECT 
        DATE_FORMAT(booking_date, '%Y-%m') as month,
        COUNT(*) as booking_count,
        SUM(c.weight) as total_weight
    FROM 
        (
            SELECT 
                cb.booking_date,
                cb.cargo_id
            FROM 
                cargo_bookings cb
            WHERE 
                cb.user_id = p_user_id AND
                cb.booking_date >= @start_date
                
            UNION ALL
            
            SELECT 
                cnb.booking_date,
                cnb.cargo_id
            FROM 
                connected_bookings cnb
            WHERE 
                cnb.user_id = p_user_id AND
                cnb.booking_date >= @start_date
        ) as bookings
    JOIN 
        cargo c ON bookings.cargo_id = c.cargo_id
    GROUP BY 
        DATE_FORMAT(booking_date, '%Y-%m')
    ORDER BY 
        month;
END//
DELIMITER ;


-- Drop existing procedures if they exist
DROP PROCEDURE IF EXISTS get_shipowner_dashboard_stats;
DROP PROCEDURE IF EXISTS get_shipowner_recent_bookings;
DROP PROCEDURE IF EXISTS get_shipowner_upcoming_voyages;
DROP PROCEDURE IF EXISTS get_ship_utilization;
DROP PROCEDURE IF EXISTS get_revenue_by_route;
DROP PROCEDURE IF EXISTS get_monthly_shipping_revenue;

-- Stored procedure to get shipowner dashboard statistics
DELIMITER //
DROP PROCEDURE IF EXISTS get_shipowner_dashboard_stats//
CREATE PROCEDURE get_shipowner_dashboard_stats(
    IN p_user_id INT
)
BEGIN
    -- Get total ships count
    SELECT COUNT(*) AS ship_count 
    FROM ships 
    WHERE owner_id = p_user_id AND status != 'deleted';
    
    -- Get active routes count
    SELECT COUNT(*) AS active_routes 
    FROM routes 
    WHERE owner_id = p_user_id AND status = 'active';
    
    -- Get scheduled voyages count
    SELECT COUNT(*) AS scheduled_voyages 
    FROM schedules s
    JOIN ships sh ON s.ship_id = sh.ship_id
    WHERE sh.owner_id = p_user_id AND s.status = 'scheduled';
    
    -- Get in-transit voyages count
    SELECT COUNT(*) AS in_transit_voyages 
    FROM schedules s
    JOIN ships sh ON s.ship_id = sh.ship_id
    WHERE sh.owner_id = p_user_id AND s.status = 'in_progress';
    
    -- Get total revenue (from direct AND connected bookings)
    SELECT (
        -- Revenue from direct bookings
        (SELECT COALESCE(SUM(cb.price), 0)
        FROM cargo_bookings cb
        JOIN schedules s ON cb.schedule_id = s.schedule_id
        JOIN ships sh ON s.ship_id = sh.ship_id
        WHERE sh.owner_id = p_user_id 
          AND cb.booking_status != 'cancelled'
          AND cb.payment_status = 'paid')
        +
        -- Revenue from connected bookings
        (SELECT COALESCE(SUM(cbs.segment_price), 0)
        FROM connected_booking_segments cbs
        JOIN schedules s ON cbs.schedule_id = s.schedule_id
        JOIN ships sh ON s.ship_id = sh.ship_id
        JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
        WHERE sh.owner_id = p_user_id
          AND cb.booking_status != 'cancelled'
          AND cb.payment_status = 'paid')
    ) AS total_revenue;
END//
DELIMITER ;

-- Stored procedure to get recent bookings for shipowner
DELIMITER //
CREATE PROCEDURE get_shipowner_recent_bookings(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    -- Combine direct and connected bookings in a UNION query
    (SELECT 
        'direct' AS booking_type,
        cb.booking_id AS id,
        s.schedule_id,
        sh.name AS ship_name,
        r.name AS route_name,
        u.username AS customer_name,
        c.description AS cargo_description,
        cb.booking_status,
        cb.price AS revenue,
        cb.booking_date
    FROM cargo_bookings cb
    JOIN schedules s ON cb.schedule_id = s.schedule_id
    JOIN ships sh ON s.ship_id = sh.ship_id
    JOIN routes r ON s.route_id = r.route_id
    JOIN users u ON cb.user_id = u.user_id
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    WHERE sh.owner_id = p_user_id)
    
    UNION ALL
    
    (SELECT 
        'connected' AS booking_type,
        cb.connected_booking_id AS id,
        cbs.schedule_id,
        sh.name AS ship_name,
        r.name AS route_name,
        u.username AS customer_name,
        c.description AS cargo_description,
        cb.booking_status,
        cbs.segment_price AS revenue,
        cb.booking_date
    FROM connected_booking_segments cbs
    JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
    JOIN schedules s ON cbs.schedule_id = s.schedule_id
    JOIN ships sh ON s.ship_id = sh.ship_id
    JOIN routes r ON s.route_id = r.route_id
    JOIN users u ON cb.user_id = u.user_id
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    WHERE sh.owner_id = p_user_id)
    
    ORDER BY booking_date DESC
    LIMIT p_limit;
END//
DELIMITER ;


DELIMITER //
DROP PROCEDURE IF EXISTS get_shipowner_upcoming_voyages//
CREATE PROCEDURE get_shipowner_upcoming_voyages(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    SELECT 
        s.schedule_id,
        sh.name AS ship_name, 
        r.name AS route_name,
        s.departure_date,
        s.arrival_date,
        s.status,
        -- Count bookings for this schedule (both direct and connected)
        (
            (SELECT COUNT(*) FROM cargo_bookings 
             WHERE schedule_id = s.schedule_id AND booking_status != 'cancelled')
            +
            (SELECT COUNT(*) FROM connected_booking_segments cbs
             JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
             WHERE cbs.schedule_id = s.schedule_id AND cb.booking_status != 'cancelled')
        ) AS booking_count,
        -- Calculate utilization percentage
        ROUND(
            COALESCE(
                (
                    -- Get weight from direct bookings
                    (SELECT COALESCE(SUM(c.weight), 0) 
                     FROM cargo_bookings cb
                     JOIN cargo c ON cb.cargo_id = c.cargo_id 
                     WHERE cb.schedule_id = s.schedule_id AND cb.booking_status != 'cancelled')
                    +
                    -- Get weight from connected bookings
                    (SELECT COALESCE(SUM(c.weight), 0) 
                     FROM connected_booking_segments cbs
                     JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
                     JOIN cargo c ON cb.cargo_id = c.cargo_id 
                     WHERE cbs.schedule_id = s.schedule_id AND cb.booking_status != 'cancelled')
                ) / NULLIF(s.max_cargo, 0) * 100,
            0)
        ) AS utilization_percent
    FROM schedules s
    JOIN ships sh ON s.ship_id = sh.ship_id
    JOIN routes r ON s.route_id = r.route_id
    WHERE sh.owner_id = p_user_id
      AND s.status IN ('scheduled', 'in_progress')  
      AND s.departure_date >= CURRENT_DATE()
    ORDER BY s.departure_date ASC
    LIMIT p_limit;
END//
DELIMITER ;

-- Stored procedure to get ship utilization data
DELIMITER //
DROP PROCEDURE IF EXISTS get_ship_utilization//
CREATE PROCEDURE get_ship_utilization(
    IN p_user_id INT
)
BEGIN
    SELECT 
        sh.name,
        COALESCE(
            ROUND(
                (
                    /* Calculate total weight from direct bookings */
                    (SELECT COALESCE(SUM(c.weight), 0) 
                     FROM cargo_bookings cb
                     JOIN cargo c ON cb.cargo_id = c.cargo_id 
                     JOIN schedules s ON cb.schedule_id = s.schedule_id
                     WHERE s.ship_id = sh.ship_id 
                       AND cb.booking_status != 'cancelled'
                       AND s.status IN ('scheduled', 'in_progress'))
                    +
                    /* Add weight from connected bookings */
                    (SELECT COALESCE(SUM(c.weight), 0)
                     FROM connected_booking_segments cbs
                     JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
                     JOIN cargo c ON cb.cargo_id = c.cargo_id
                     JOIN schedules s ON cbs.schedule_id = s.schedule_id
                     WHERE s.ship_id = sh.ship_id
                       AND cb.booking_status != 'cancelled'
                       AND s.status IN ('scheduled', 'in_progress'))
                ) / 
                /* Divide by total capacity */
                (SELECT COALESCE(SUM(s.max_cargo), 1) 
                 FROM schedules s 
                 WHERE s.ship_id = sh.ship_id 
                   AND s.status IN ('scheduled', 'in_progress')) * 100,
            0)
        ) AS utilization_percent
    FROM ships sh
    WHERE sh.owner_id = p_user_id
      AND sh.status != 'deleted'
      AND EXISTS (
          SELECT 1 FROM schedules s 
          WHERE s.ship_id = sh.ship_id 
            AND s.status IN ('scheduled', 'in_progress')
      )
    ORDER BY utilization_percent DESC;
END//
DELIMITER ;

-- Stored procedure to get revenue by route
DELIMITER //
DROP PROCEDURE IF EXISTS get_revenue_by_route//
CREATE PROCEDURE get_revenue_by_route(
    IN p_user_id INT
)
BEGIN
    SELECT 
        r.name,
        (
            /* Revenue from direct bookings */
            (SELECT COALESCE(SUM(cb.price), 0)
             FROM schedules s
             JOIN cargo_bookings cb ON s.schedule_id = cb.schedule_id
             WHERE s.route_id = r.route_id
               AND cb.booking_status != 'cancelled')
            +
            /* Revenue from connected booking segments */
            (SELECT COALESCE(SUM(cbs.segment_price), 0)
             FROM schedules s
             JOIN connected_booking_segments cbs ON s.schedule_id = cbs.schedule_id
             JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
             WHERE s.route_id = r.route_id
               AND cb.booking_status != 'cancelled')
        ) AS total_revenue
    FROM routes r
    WHERE r.owner_id = p_user_id
      AND r.status = 'active'
    HAVING total_revenue > 0
    ORDER BY total_revenue DESC;
END//
DELIMITER ;

-- Stored procedure to get monthly shipping revenue
DELIMITER //
DROP PROCEDURE IF EXISTS get_monthly_shipping_revenue//
CREATE PROCEDURE get_monthly_shipping_revenue(
    IN p_user_id INT,
    IN p_days_back INT
)
BEGIN
    -- Calculate start date
    SET @start_date = DATE_SUB(CURDATE(), INTERVAL p_days_back DAY);
    
    -- Create temporary table to hold combined revenue data
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_monthly_revenue (
        month VARCHAR(7),
        booking_count INT,
        total_revenue DOUBLE  -- Change from DECIMAL to DOUBLE for JSON compatibility
    );
    
    -- Insert direct booking revenue
    INSERT INTO temp_monthly_revenue
    SELECT 
        DATE_FORMAT(cb.booking_date, '%Y-%m') as month,
        COUNT(*) as booking_count,
        SUM(cb.price) as total_revenue
    FROM cargo_bookings cb
    JOIN schedules s ON cb.schedule_id = s.schedule_id
    JOIN ships sh ON s.ship_id = sh.ship_id
    WHERE sh.owner_id = p_user_id
      AND cb.booking_date >= @start_date
      AND cb.booking_status != 'cancelled'
    GROUP BY month;
    
    -- Insert connected booking segment revenue
    INSERT INTO temp_monthly_revenue
    SELECT 
        DATE_FORMAT(cb.booking_date, '%Y-%m') as month,
        COUNT(DISTINCT cb.connected_booking_id) as booking_count,
        SUM(cbs.segment_price) as total_revenue
    FROM connected_booking_segments cbs
    JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
    JOIN schedules s ON cbs.schedule_id = s.schedule_id
    JOIN ships sh ON s.ship_id = sh.ship_id
    WHERE sh.owner_id = p_user_id
      AND cb.booking_date >= @start_date
      AND cb.booking_status != 'cancelled'
    GROUP BY month;
    
    -- Return aggregated results
    SELECT 
        month,
        SUM(booking_count) as booking_count,
        SUM(total_revenue) as total_revenue
    FROM temp_monthly_revenue
    GROUP BY month
    ORDER BY month;
    
    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS temp_monthly_revenue;
END//
DELIMITER ;




---- admin related


DELIMITER //
DROP PROCEDURE IF EXISTS get_admin_dashboard_stats//
CREATE PROCEDURE get_admin_dashboard_stats()
BEGIN
    -- Get total users count by role
    SELECT 
        r.role_name,
        COUNT(ur.user_id) as user_count
    FROM roles r
    LEFT JOIN user_roles ur ON r.role_id = ur.role_id
    GROUP BY r.role_name
    ORDER BY user_count DESC;
    
    -- Get total cargo count by status
    SELECT 
        status,
        COUNT(*) as cargo_count
    FROM cargo
    GROUP BY status;
    
    -- Get total ships by type and status
    SELECT 
        ship_type,
        status,
        COUNT(*) as ship_count
    FROM ships
    WHERE status != 'deleted'
    GROUP BY ship_type, status;
    
    -- Get booking statistics (both direct and connected)
    SELECT 
        'direct' as booking_type,
        booking_status,
        COUNT(*) as booking_count,
        SUM(price) as total_revenue
    FROM cargo_bookings
    GROUP BY booking_status
    
    UNION ALL
    
    SELECT 
        'connected' as booking_type,
        booking_status,
        COUNT(*) as booking_count,
        SUM(total_price) as total_revenue
    FROM connected_bookings
    GROUP BY booking_status;
    
    -- Get ports by status
    SELECT 
        status,
        COUNT(*) as port_count
    FROM ports
    GROUP BY status;
    
    -- Get total system revenue
    SELECT 
        (SELECT COALESCE(SUM(price), 0) FROM cargo_bookings WHERE booking_status != 'cancelled' AND payment_status = 'paid')
        +
        (SELECT COALESCE(SUM(total_price), 0) FROM connected_bookings WHERE booking_status != 'cancelled' AND payment_status = 'paid')
        AS total_system_revenue;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_admin_booking_trends(
    IN p_days_back INT
)
BEGIN
    -- Calculate start date
    SET @start_date = DATE_SUB(CURDATE(), INTERVAL p_days_back DAY);
    
    -- Get daily booking data (direct and connected)
    SELECT 
        DATE(booking_date) as booking_day,
        COUNT(*) as booking_count,
        'direct' as booking_type
    FROM cargo_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_day
    
    UNION ALL
    
    SELECT 
        DATE(booking_date) as booking_day,
        COUNT(*) as booking_count,
        'connected' as booking_type
    FROM connected_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_day
    
    ORDER BY booking_day;
    
    -- Get weekly booking data
    SELECT 
        YEARWEEK(booking_date) as booking_week,
        COUNT(*) as booking_count,
        SUM(price) as revenue,
        'direct' as booking_type
    FROM cargo_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_week
    
    UNION ALL
    
    SELECT 
        YEARWEEK(booking_date) as booking_week,
        COUNT(*) as booking_count,
        SUM(total_price) as revenue,
        'connected' as booking_type
    FROM connected_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_week
    
    ORDER BY booking_week;
    
    -- Get monthly booking data
    SELECT 
        DATE_FORMAT(booking_date, '%Y-%m') as booking_month,
        COUNT(*) as booking_count,
        SUM(price) as revenue,
        'direct' as booking_type
    FROM cargo_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_month
    
    UNION ALL
    
    SELECT 
        DATE_FORMAT(booking_date, '%Y-%m') as booking_month,
        COUNT(*) as booking_count,
        SUM(total_price) as revenue,
        'connected' as booking_type
    FROM connected_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_month
    
    ORDER BY booking_month;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS get_admin_top_routes//
CREATE PROCEDURE get_admin_top_routes(
    IN p_limit INT
)
BEGIN
    -- Create temporary tables to store direct and connected booking data
    DROP TEMPORARY TABLE IF EXISTS temp_direct_route_revenue;
    CREATE TEMPORARY TABLE temp_direct_route_revenue (
        route_id INT,
        route_name VARCHAR(100),
        origin_port VARCHAR(100),
        destination_port VARCHAR(100),
        booking_count INT,
        revenue DOUBLE
    );
    
    DROP TEMPORARY TABLE IF EXISTS temp_connected_route_revenue;
    CREATE TEMPORARY TABLE temp_connected_route_revenue (
        route_id INT,
        route_name VARCHAR(100),
        origin_port VARCHAR(100),
        destination_port VARCHAR(100),
        booking_count INT,
        revenue DOUBLE
    );
    
    DROP TEMPORARY TABLE IF EXISTS temp_all_routes;
    CREATE TEMPORARY TABLE temp_all_routes (
        route_id INT,
        route_name VARCHAR(100),
        origin_port VARCHAR(100),
        destination_port VARCHAR(100)
    );
    
    -- Get top routes by direct booking revenue
    INSERT INTO temp_direct_route_revenue
    SELECT 
        r.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        COUNT(cb.booking_id) AS booking_count,
        SUM(cb.price) AS revenue
    FROM routes r
    JOIN ports op ON r.origin_port_id = op.port_id
    JOIN ports dp ON r.destination_port_id = dp.port_id
    JOIN schedules s ON r.route_id = s.route_id
    JOIN cargo_bookings cb ON s.schedule_id = cb.schedule_id
    WHERE cb.booking_status != 'cancelled'
    GROUP BY r.route_id, r.name, op.name, dp.name;
    
    -- Get top routes by connected booking revenue
    INSERT INTO temp_connected_route_revenue
    SELECT 
        r.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        COUNT(DISTINCT cbs.connected_booking_id) AS booking_count,
        SUM(cbs.segment_price) AS revenue
    FROM routes r
    JOIN ports op ON r.origin_port_id = op.port_id
    JOIN ports dp ON r.destination_port_id = dp.port_id
    JOIN schedules s ON r.route_id = s.route_id
    JOIN connected_booking_segments cbs ON s.schedule_id = cbs.schedule_id
    JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
    WHERE cb.booking_status != 'cancelled'
    GROUP BY r.route_id, r.name, op.name, dp.name;
    
    -- Get all routes that have either direct or connected bookings
    INSERT INTO temp_all_routes
    SELECT DISTINCT route_id, route_name, origin_port, destination_port 
    FROM temp_direct_route_revenue
    
    UNION
    
    SELECT DISTINCT route_id, route_name, origin_port, destination_port 
    FROM temp_connected_route_revenue;
    
    -- Select the top routes with combined revenue
    SELECT 
        r.route_id,
        r.route_name,
        r.origin_port,
        r.destination_port,
        COALESCE(d.booking_count, 0) + COALESCE(c.booking_count, 0) AS total_bookings,
        COALESCE(d.revenue, 0) + COALESCE(c.revenue, 0) AS total_revenue
    FROM temp_all_routes r
    LEFT JOIN temp_direct_route_revenue d ON r.route_id = d.route_id
    LEFT JOIN temp_connected_route_revenue c ON r.route_id = c.route_id
    ORDER BY total_revenue DESC
    LIMIT p_limit;
    
    -- Clean up temporary tables
    DROP TEMPORARY TABLE IF EXISTS temp_direct_route_revenue;
    DROP TEMPORARY TABLE IF EXISTS temp_connected_route_revenue;
    DROP TEMPORARY TABLE IF EXISTS temp_all_routes;
END//
DELIMITER ;


DELIMITER ;

DELIMITER //
CREATE PROCEDURE get_admin_recent_activities(
    IN p_limit INT
)
BEGIN
    -- Get recent user registrations
    SELECT 
        'user_registration' as activity_type,
        user_id,
        username,
        email,
        created_at as activity_time
    FROM users
    ORDER BY created_at DESC
    LIMIT p_limit;
    
    -- Get recent direct bookings
    SELECT 
        'direct_booking' as activity_type,
        cb.booking_id as id,
        u.username,
        c.description as cargo_description,
        cb.price as amount,
        cb.booking_status as status,
        cb.booking_date as activity_time
    FROM cargo_bookings cb
    JOIN users u ON cb.user_id = u.user_id
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    ORDER BY cb.booking_date DESC
    LIMIT p_limit;
    
    -- Get recent connected bookings
    SELECT 
        'connected_booking' as activity_type,
        cb.connected_booking_id as id,
        u.username,
        c.description as cargo_description,
        cb.total_price as amount,
        cb.booking_status as status,
        cb.booking_date as activity_time
    FROM connected_bookings cb
    JOIN users u ON cb.user_id = u.user_id
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    ORDER BY cb.booking_date DESC
    LIMIT p_limit;
    
    -- Get recent schedule creations
    SELECT 
        'schedule_creation' as activity_type,
        s.schedule_id as id,
        sh.name as ship_name,
        r.name as route_name,
        s.departure_date,
        s.arrival_date,
        s.created_at as activity_time
    FROM schedules s
    JOIN ships sh ON s.ship_id = sh.ship_id
    JOIN routes r ON s.route_id = r.route_id
    ORDER BY s.created_at DESC
    LIMIT p_limit;
END//
DELIMITER ;


select sum(price) from cargo_bookings where payment_status = 'paid';

CALL get_admin_booking_trends(7);


-- Fixed get_admin_dashboard_stats procedure with better calculation
DELIMITER //
DROP PROCEDURE IF EXISTS get_admin_dashboard_stats//
CREATE PROCEDURE get_admin_dashboard_stats()
BEGIN
    -- Get total users count by role
    SELECT 
        r.role_name,
        COUNT(DISTINCT ur.user_id) as user_count
    FROM roles r
    LEFT JOIN user_roles ur ON r.role_id = ur.role_id
    GROUP BY r.role_name
    ORDER BY user_count DESC;
    
    -- Get total cargo count by status
    SELECT 
        status,
        COUNT(*) as cargo_count
    FROM cargo
    GROUP BY status
    ORDER BY cargo_count DESC;
    
    -- Get total ships by type and status
    SELECT 
        ship_type,
        status,
        COUNT(*) as ship_count
    FROM ships
    WHERE status != 'deleted'
    GROUP BY ship_type, status
    ORDER BY ship_type, status;
    
    -- Get booking statistics (both direct and connected)
    SELECT 
        'direct' as booking_type,
        booking_status,
        COUNT(*) as booking_count,
        COALESCE(SUM(price), 0) as total_revenue
    FROM cargo_bookings
    GROUP BY booking_status
    
    UNION ALL
    
    SELECT 
        'connected' as booking_type,
        booking_status,
        COUNT(*) as booking_count,
        COALESCE(SUM(total_price), 0) as total_revenue
    FROM connected_bookings
    GROUP BY booking_status
    ORDER BY booking_type, booking_status;
    
    -- Get ports by status
    SELECT 
        status,
        COUNT(*) as port_count
    FROM ports
    GROUP BY status
    ORDER BY port_count DESC;
    
    -- Get total system revenue - make this match the sum in the booking stats
    SELECT 
        (
            SELECT COALESCE(SUM(price), 0) 
            FROM cargo_bookings 
            WHERE booking_status != 'cancelled' AND payment_status = 'paid'
        )
        +
        (
            SELECT COALESCE(SUM(total_price), 0) 
            FROM connected_bookings 
            WHERE booking_status != 'cancelled' AND payment_status = 'paid'
        ) AS total_system_revenue;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS get_admin_cargo_stats//
CREATE PROCEDURE get_admin_cargo_stats()
BEGIN
    -- Get cargo by type
    SELECT 
        cargo_type,
        COUNT(*) as cargo_count,
        COALESCE(AVG(weight), 0) as avg_weight
    FROM cargo
    GROUP BY cargo_type
    ORDER BY cargo_count DESC;
    
    -- Get cargo by status
    SELECT 
        status,
        COUNT(*) as cargo_count
    FROM cargo
    GROUP BY status
    ORDER BY cargo_count DESC;
    
    -- Get cargo booking conversion rates
    SELECT 
        'overall' as metric,
        COUNT(DISTINCT c.cargo_id) as total_cargo,
        (
            SELECT COUNT(DISTINCT cargo_id) FROM 
            (
                SELECT cargo_id FROM cargo_bookings
                where booking_status in ('completed', 'confirmed')
                UNION
                SELECT cargo_id FROM connected_bookings
                where booking_status in ("completed", "confirmed")
            ) as booked
        ) as booked_cargo,
        (
            (
                SELECT COUNT(DISTINCT cargo_id) FROM 
                (
                    SELECT cargo_id FROM cargo_bookings
                    where booking_status in ('completed', 'confirmed')
                    UNION
                    SELECT cargo_id FROM connected_bookings
                    where booking_status in ("completed", "confirmed")
                ) as booked
            ) / COUNT(DISTINCT c.cargo_id) * 100
        ) as conversion_rate
    FROM cargo c;
END//
DELIMITER ;

-- Fixed get_admin_booking_trends procedure
DELIMITER //
DROP PROCEDURE IF EXISTS get_admin_booking_trends//
CREATE PROCEDURE get_admin_booking_trends(
    IN p_days_back INT
)
BEGIN
    -- Calculate start date
    SET @start_date = DATE_SUB(CURDATE(), INTERVAL p_days_back DAY);
    
    -- Get daily booking data (direct and connected)
    SELECT 
        DATE(booking_date) as booking_day,
        COUNT(*) as booking_count,
        'direct' as booking_type
    FROM cargo_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_day
    
    UNION ALL
    
    SELECT 
        DATE(booking_date) as booking_day,
        COUNT(*) as booking_count,
        'connected' as booking_type
    FROM connected_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_day
    
    ORDER BY booking_day;
    
    -- Get weekly booking data
    SELECT 
        YEARWEEK(booking_date) as booking_week,
        COUNT(*) as booking_count,
        COALESCE(SUM(price), 0) as revenue,
        'direct' as booking_type
    FROM cargo_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_week
    
    UNION ALL
    
    SELECT 
        YEARWEEK(booking_date) as booking_week,
        COUNT(*) as booking_count,
        COALESCE(SUM(total_price), 0) as revenue,
        'connected' as booking_type
    FROM connected_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_week
    
    ORDER BY booking_week;
    
    -- Get monthly booking data
    SELECT 
        DATE_FORMAT(booking_date, '%Y-%m') as booking_month,
        COUNT(*) as booking_count,
        COALESCE(SUM(price), 0) as revenue,
        'direct' as booking_type
    FROM cargo_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_month
    
    UNION ALL
    
    SELECT 
        DATE_FORMAT(booking_date, '%Y-%m') as booking_month,
        COUNT(*) as booking_count,
        COALESCE(SUM(total_price), 0) as revenue,
        'connected' as booking_type
    FROM connected_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_month
    
    ORDER BY booking_month;
END//
DELIMITER ;

-- Fixed get_admin_top_routes procedure
DELIMITER //
DROP PROCEDURE IF EXISTS get_admin_top_routes//
CREATE PROCEDURE get_admin_top_routes(
    IN p_limit INT
)
BEGIN
    -- Create temporary tables to store direct and connected booking data
    DROP TEMPORARY TABLE IF EXISTS temp_direct_route_revenue;
    CREATE TEMPORARY TABLE temp_direct_route_revenue (
        route_id INT,
        route_name VARCHAR(100),
        origin_port VARCHAR(100),
        destination_port VARCHAR(100),
        booking_count INT,
        revenue DECIMAL(12,2)
    );
    
    DROP TEMPORARY TABLE IF EXISTS temp_connected_route_revenue;
    CREATE TEMPORARY TABLE temp_connected_route_revenue (
        route_id INT,
        route_name VARCHAR(100),
        origin_port VARCHAR(100),
        destination_port VARCHAR(100),
        booking_count INT,
        revenue DECIMAL(12,2)
    );
    
    DROP TEMPORARY TABLE IF EXISTS temp_all_routes;
    CREATE TEMPORARY TABLE temp_all_routes (
        route_id INT,
        route_name VARCHAR(100),
        origin_port VARCHAR(100),
        destination_port VARCHAR(100)
    );
    
    -- Get top routes by direct booking revenue - with COALESCE to handle NULL values
    INSERT INTO temp_direct_route_revenue
    SELECT 
        r.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        COUNT(cb.booking_id) AS booking_count,
        COALESCE(SUM(cb.price), 0) AS revenue
    FROM routes r
    JOIN ports op ON r.origin_port_id = op.port_id
    JOIN ports dp ON r.destination_port_id = dp.port_id
    JOIN schedules s ON r.route_id = s.route_id
    JOIN cargo_bookings cb ON s.schedule_id = cb.schedule_id
    WHERE cb.booking_status != 'cancelled'
    GROUP BY r.route_id, r.name, op.name, dp.name;
    
    -- Get top routes by connected booking revenue - with COALESCE to handle NULL values
    INSERT INTO temp_connected_route_revenue
    SELECT 
        r.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        COUNT(DISTINCT cbs.connected_booking_id) AS booking_count,
        COALESCE(SUM(cbs.segment_price), 0) AS revenue
    FROM routes r
    JOIN ports op ON r.origin_port_id = op.port_id
    JOIN ports dp ON r.destination_port_id = dp.port_id
    JOIN schedules s ON r.route_id = s.route_id
    JOIN connected_booking_segments cbs ON s.schedule_id = cbs.schedule_id
    JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
    WHERE cb.booking_status != 'cancelled'
    GROUP BY r.route_id, r.name, op.name, dp.name;
    
    -- Get all routes that have either direct or connected bookings
    INSERT INTO temp_all_routes
    SELECT DISTINCT route_id, route_name, origin_port, destination_port 
    FROM temp_direct_route_revenue
    
    UNION
    
    SELECT DISTINCT route_id, route_name, origin_port, destination_port 
    FROM temp_connected_route_revenue;
    
    -- Select the top routes with combined revenue, safely handling NULL values
    SELECT 
        r.route_id,
        r.route_name,
        r.origin_port,
        r.destination_port,
        COALESCE(d.booking_count, 0) + COALESCE(c.booking_count, 0) AS total_bookings,
        COALESCE(d.revenue, 0) + COALESCE(c.revenue, 0) AS total_revenue
    FROM temp_all_routes r
    LEFT JOIN temp_direct_route_revenue d ON r.route_id = d.route_id
    LEFT JOIN temp_connected_route_revenue c ON r.route_id = c.route_id
    ORDER BY total_revenue DESC
    LIMIT p_limit;
    
    -- Clean up temporary tables
    DROP TEMPORARY TABLE IF EXISTS temp_direct_route_revenue;
    DROP TEMPORARY TABLE IF EXISTS temp_connected_route_revenue;
    DROP TEMPORARY TABLE IF EXISTS temp_all_routes;
END//
DELIMITER ;

-- Fixed get_admin_recent_activities procedure
DELIMITER //
DROP PROCEDURE IF EXISTS get_admin_recent_activities//
CREATE PROCEDURE get_admin_recent_activities(
    IN p_limit INT
)
BEGIN
    -- Get recent user registrations
    SELECT 
        'user_registration' as activity_type,
        user_id,
        username,
        email,
        created_at as activity_time
    FROM users
    ORDER BY created_at DESC
    LIMIT p_limit;
    
    -- Get recent direct bookings - with safer price handling
    SELECT 
        'direct_booking' as activity_type,
        cb.booking_id as id,
        u.username,
        c.description as cargo_description,
        COALESCE(cb.price, 0) as amount,
        cb.booking_status as status,
        cb.booking_date as activity_time
    FROM cargo_bookings cb
    JOIN users u ON cb.user_id = u.user_id
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    ORDER BY cb.booking_date DESC
    LIMIT p_limit;
    
    -- Get recent connected bookings - with safer price handling
    SELECT 
        'connected_booking' as activity_type,
        cb.connected_booking_id as id,
        u.username,
        c.description as cargo_description,
        COALESCE(cb.total_price, 0) as amount,
        cb.booking_status as status,
        cb.booking_date as activity_time
    FROM connected_bookings cb
    JOIN users u ON cb.user_id = u.user_id
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    ORDER BY cb.booking_date DESC
    LIMIT p_limit;
    
    -- Get recent schedule creations
    SELECT 
        'schedule_creation' as activity_type,
        s.schedule_id as id,
        sh.name as ship_name,
        r.name as route_name,
        s.departure_date,
        s.arrival_date,
        s.created_at as activity_time
    FROM schedules s
    JOIN ships sh ON s.ship_id = sh.ship_id
    JOIN routes r ON s.route_id = r.route_id
    ORDER BY s.created_at DESC
    LIMIT p_limit;
END//
DELIMITER ;

--- Bookling section
drop PROCEDURE create_direct_booking//
DELIMITER //
CREATE PROCEDURE create_direct_booking(
    IN p_cargo_id INT,
    IN p_schedule_id INT,
    IN p_user_id INT,
    IN p_notes TEXT,
    OUT p_booking_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE cargo_weight DECIMAL(10, 2);
    DECLARE total_price DECIMAL(12, 2);
    
    -- Transaction to ensure all operations complete or none do
    START TRANSACTION;
    
    -- Calculate booking price
    SELECT 
        r.cost_per_kg * c.weight,
        c.weight INTO total_price, cargo_weight
    FROM 
        schedules s
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        cargo c ON c.cargo_id = p_cargo_id
    WHERE 
        s.schedule_id = p_schedule_id;


    IF total_price IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Could not calculate booking price';
        ROLLBACK;
    ELSE
        -- Create the booking
        INSERT INTO cargo_bookings (
            cargo_id, schedule_id, user_id, 
            booking_date, booking_status, payment_status, 
            price, notes
        ) VALUES (
            p_cargo_id, p_schedule_id, p_user_id, 
            NOW(), 'confirmed', 'paid', 
            total_price, p_notes
        );
        
        SET p_booking_id = LAST_INSERT_ID();
        
        -- Update cargo status (trigger handles this but keeping for clarity)
        UPDATE cargo 
        SET status = 'booked'
        WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
        
        -- Update schedule available capacity
        UPDATE schedules
        SET max_cargo = max_cargo - cargo_weight
        WHERE schedule_id = p_schedule_id;
        
        SET p_success = TRUE;
        SET p_message = CONCAT('Cargo booked successfully! Booking ID: ', p_booking_id);
        COMMIT;
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE create_direct_booking(
    IN p_cargo_id INT,
    IN p_schedule_id INT,
    IN p_user_id INT,
    IN p_notes TEXT,
    OUT p_booking_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE cargo_weight DECIMAL(10, 2);
    DECLARE total_price DECIMAL(12, 2);
    DECLARE cargo_status VARCHAR(50);
    
    -- Transaction to ensure all operations complete or none do
    START TRANSACTION;
    
    -- Check if cargo is already booked
    SELECT status INTO cargo_status
    FROM cargo 
    WHERE cargo_id = p_cargo_id;
    
    IF cargo_status = 'booked' THEN
        SET p_success = FALSE;
        SET p_message = 'Cargo is already booked';
        ROLLBACK;
    ELSE
        -- Calculate booking price
        SELECT
            r.cost_per_kg * c.weight,
            c.weight INTO total_price, cargo_weight
        FROM
            schedules s
        JOIN
            routes r ON s.route_id = r.route_id
        JOIN
            cargo c ON c.cargo_id = p_cargo_id
        WHERE
            s.schedule_id = p_schedule_id;
            
        IF total_price IS NULL THEN
            SET p_success = FALSE;
            SET p_message = 'Could not calculate booking price';
            ROLLBACK;
        ELSE
            -- Create the booking
            INSERT INTO cargo_bookings (
                cargo_id, schedule_id, user_id, 
                booking_date, booking_status, payment_status,
                price, notes
            ) VALUES (
                p_cargo_id, p_schedule_id, p_user_id, 
                NOW(), 'confirmed', 'paid',
                total_price, p_notes
            );
                
            SET p_booking_id = LAST_INSERT_ID();
                
            -- Update cargo status (trigger handles this but keeping for clarity)
            UPDATE cargo 
            SET status = 'booked'
            WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
                
            -- Update schedule available capacity
            UPDATE schedules
            SET max_cargo = max_cargo - cargo_weight
            WHERE schedule_id = p_schedule_id;
                
            SET p_success = TRUE;
            SET p_message = CONCAT('Cargo booked successfully! Booking ID: ', p_booking_id);
            COMMIT;
        END IF;
    END IF;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_direct_booking_details(
    IN p_schedule_id INT,
    IN p_cargo_id INT,
    IN p_user_id INT
)
BEGIN
    -- Get schedule details
    SELECT 
        s.schedule_id,
        s.ship_id,
        ships.name AS ship_name,
        ships.ship_type,
        r.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        s.departure_date,
        s.arrival_date,
        r.cost_per_kg,
        r.distance,
        ST_Y(op.location) AS origin_lat, 
        ST_X(op.location) AS origin_lng,
        ST_Y(dp.location) AS destination_lat, 
        ST_X(dp.location) AS destination_lng
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
        s.schedule_id = p_schedule_id;
    
    -- Get cargo details
    SELECT 
        cargo_id, description, cargo_type, weight, dimensions
    FROM 
        cargo
    WHERE 
        cargo_id = p_cargo_id AND user_id = p_user_id;
    
    -- Get username
    SELECT username FROM users WHERE user_id = p_user_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE create_connected_booking(
    IN p_cargo_id INT,
    IN p_user_id INT,
    IN p_schedule_ids VARCHAR(255),
    IN p_notes TEXT,
    OUT p_booking_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE origin_port_id INT;
    DECLARE destination_port_id INT;
    DECLARE total_price DECIMAL(12, 2);
    DECLARE cargo_weight DECIMAL(10, 2);
    DECLARE first_schedule_id INT;
    DECLARE last_schedule_id INT;
    DECLARE done INT DEFAULT 0;
    DECLARE segment_count INT DEFAULT 0;
    DECLARE current_schedule_id INT;
    DECLARE segment_price DECIMAL(12, 2);
    
    -- Create a temporary table to store schedule IDs
    DROP TEMPORARY TABLE IF EXISTS temp_schedule_ids;
    CREATE TEMPORARY TABLE temp_schedule_ids (
        id INT AUTO_INCREMENT PRIMARY KEY,
        schedule_id INT NOT NULL
    );
    
    -- Insert schedule IDs into temporary table
    SET @sql = CONCAT("INSERT INTO temp_schedule_ids (schedule_id) VALUES ('", 
                REPLACE(p_schedule_ids, ",", "'),('"), "')");
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Get first and last schedule IDs
    SELECT schedule_id INTO first_schedule_id FROM temp_schedule_ids ORDER BY id LIMIT 1;
    SELECT schedule_id INTO last_schedule_id FROM temp_schedule_ids ORDER BY id DESC LIMIT 1;
    
    -- Get total count of segments
    SELECT COUNT(*) INTO segment_count FROM temp_schedule_ids;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get origin and destination port IDs
    SELECT 
        r1.origin_port_id, r2.destination_port_id 
    INTO 
        origin_port_id, destination_port_id
    FROM 
        schedules s1
    JOIN 
        routes r1 ON s1.route_id = r1.route_id
    JOIN 
        schedules s2
    JOIN 
        routes r2 ON s2.route_id = r2.route_id
    WHERE 
        s1.schedule_id = first_schedule_id
        AND s2.schedule_id = last_schedule_id;
    
    -- Get cargo weight
    SELECT weight INTO cargo_weight FROM cargo WHERE cargo_id = p_cargo_id;
    
    -- Calculate total price by summing segment prices
    SELECT 
        SUM(r.cost_per_kg * cargo_weight) INTO total_price
    FROM 
        temp_schedule_ids t
    JOIN 
        schedules s ON t.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id;
    
    IF origin_port_id IS NULL OR destination_port_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Could not determine route endpoints';
        ROLLBACK;
    ELSEIF total_price IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Could not calculate booking price';
        ROLLBACK;
    ELSE
        -- Create the connected booking
        INSERT INTO connected_bookings (
            cargo_id, user_id, origin_port_id, destination_port_id,
            booking_date, booking_status, payment_status, 
            total_price, notes
        ) VALUES (
            p_cargo_id, p_user_id, origin_port_id, destination_port_id,
            NOW(), 'confirmed', 'paid', 
            total_price, p_notes
        );
        
        SET p_booking_id = LAST_INSERT_ID();
        
        -- Add each segment to the connected_booking_segments table
        -- Use cursor to iterate through temp_schedule_ids
        BEGIN
            DECLARE cur CURSOR FOR 
                SELECT schedule_id FROM temp_schedule_ids ORDER BY id;
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
            
            OPEN cur;
            
            SET @segment_order = 0;
            read_loop: LOOP
                FETCH cur INTO current_schedule_id;
                IF done THEN
                    LEAVE read_loop;
                END IF;
                
                SET @segment_order = @segment_order + 1;
                
                -- Calculate segment price
                SELECT 
                    r.cost_per_kg * cargo_weight INTO segment_price
                FROM 
                    schedules s
                JOIN 
                    routes r ON s.route_id = r.route_id
                WHERE 
                    s.schedule_id = current_schedule_id;
                
                -- Insert segment
                INSERT INTO connected_booking_segments (
                    connected_booking_id, schedule_id, segment_order, segment_price
                ) VALUES (
                    p_booking_id, current_schedule_id, @segment_order, segment_price
                );
                
                -- Update schedule available capacity
                UPDATE schedules
                SET max_cargo = max_cargo - cargo_weight
                WHERE schedule_id = current_schedule_id;
            END LOOP;
            
            CLOSE cur;
        END;
        
        -- Update cargo status (trigger handles this but keeping for clarity)
        UPDATE cargo 
        SET status = 'booked'
        WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
        
        SET p_success = TRUE;
        SET p_message = CONCAT('Connected route booked successfully! Booking ID: ', p_booking_id);
        COMMIT;
    END IF;
    
    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS temp_schedule_ids;
END//
DELIMITER ;


DELIMITER //

drop PROCEDURE get_connected_booking_details//
CREATE PROCEDURE get_connected_booking_details(
    IN p_schedule_ids VARCHAR(255),
    IN p_cargo_id INT,
    IN p_user_id INT
)
BEGIN
    -- Create a temporary table to store schedule IDs
    DROP TEMPORARY TABLE IF EXISTS temp_schedule_ids;
    CREATE TEMPORARY TABLE temp_schedule_ids (
        id INT AUTO_INCREMENT PRIMARY KEY,
        schedule_id INT NOT NULL
    );
    
    -- Insert schedule IDs into temporary table
    SET @sql = CONCAT("INSERT INTO temp_schedule_ids (schedule_id) VALUES ('", 
                REPLACE(p_schedule_ids, ",", "'),('"), "')");
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Get cargo details
    SELECT 
        cargo_id, description, cargo_type, weight, dimensions
    FROM 
        cargo
    WHERE 
        cargo_id = p_cargo_id AND user_id = p_user_id;
    
    -- Get segments data
    SELECT
        s.schedule_id,
        s.ship_id,
        ships.name AS ship_name,
        ships.ship_type,
        r.origin_port_id,
        op.name AS origin_port,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        r.destination_port_id,
        dp.name AS destination_port,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        s.departure_date,
        s.arrival_date,
        r.cost_per_kg,
        r.distance,
        t.id AS segment_order
    FROM
        temp_schedule_ids t
    JOIN
        schedules s ON t.schedule_id = s.schedule_id
    JOIN
        routes r ON s.route_id = r.route_id
    JOIN
        ships ON s.ship_id = ships.ship_id
    JOIN
        ports op ON r.origin_port_id = op.port_id
    JOIN
        ports dp ON r.destination_port_id = dp.port_id
    ORDER BY
        t.id;
    
    -- Get username
    SELECT username FROM users WHERE user_id = p_user_id;
    
    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS temp_schedule_ids;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_user_bookings(
    IN p_user_id INT
)
BEGIN
    -- Get direct bookings
    SELECT 
        b.booking_id,
        b.cargo_id,
        c.description AS cargo_description,
        b.schedule_id,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        b.booking_status,
        b.payment_status,
        b.price,
        b.booking_date,
        ships.name AS ship_name,
        'direct' AS booking_type
    FROM 
        cargo_bookings b
    JOIN 
        cargo c ON b.cargo_id = c.cargo_id
    JOIN 
        schedules s ON b.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        b.user_id = p_user_id
    ORDER BY 
        b.booking_date DESC;
    
    -- Get connected bookings
    SELECT 
        cb.connected_booking_id AS booking_id,
        cb.cargo_id,
        c.description AS cargo_description,
        op.name AS origin_port,
        dp.name AS destination_port,
        cb.booking_status,
        cb.payment_status,
        cb.total_price AS price,
        cb.booking_date,
        COUNT(cbs.segment_id) AS total_segments,
        'connected' AS booking_type,
        MIN(s.departure_date) AS first_departure,
        MAX(s.arrival_date) AS last_arrival
    FROM 
        connected_bookings cb
    JOIN 
        cargo c ON cb.cargo_id = c.cargo_id
    JOIN 
        ports op ON cb.origin_port_id = op.port_id
    JOIN 
        ports dp ON cb.destination_port_id = dp.port_id
    JOIN 
        connected_booking_segments cbs ON cb.connected_booking_id = cbs.connected_booking_id
    JOIN
        schedules s ON cbs.schedule_id = s.schedule_id
    WHERE 
        cb.user_id = p_user_id
    GROUP BY 
        cb.connected_booking_id, cb.cargo_id, c.description, op.name, dp.name,
        cb.booking_status, cb.payment_status, cb.total_price, cb.booking_date
    ORDER BY 
        cb.booking_date DESC;
    
    -- Get username
    SELECT username FROM users WHERE user_id = p_user_id;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_direct_booking_by_id(
    IN p_booking_id INT,
    IN p_user_id INT
)
BEGIN
    -- Get direct booking details
    SELECT 
        b.booking_id,
        b.cargo_id,
        c.description AS cargo_description,
        c.cargo_type,
        c.weight AS cargo_weight,
        c.dimensions AS cargo_dimensions,
        b.schedule_id,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        dp.name AS destination_port,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        r.distance,
        b.booking_status,
        b.payment_status,
        b.price,
        b.booking_date,
        b.notes,
        ships.name AS ship_name,
        ships.ship_type,
        'direct' AS booking_type
    FROM 
        cargo_bookings b
    JOIN 
        cargo c ON b.cargo_id = c.cargo_id
    JOIN 
        schedules s ON b.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        b.booking_id = p_booking_id AND b.user_id = p_user_id;
    
    -- Get username
    SELECT username FROM users WHERE user_id = p_user_id;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE get_connected_booking_by_id(
    IN p_booking_id INT,
    IN p_user_id INT
)
BEGIN
    -- Get connected booking details
    SELECT 
        cb.connected_booking_id,
        cb.cargo_id,
        c.description AS cargo_description,
        c.cargo_type,
        c.weight AS cargo_weight,
        c.dimensions AS cargo_dimensions,
        op.name AS origin_port,
        dp.name AS destination_port,
        cb.booking_status,
        cb.payment_status,
        cb.total_price,
        cb.booking_date,
        cb.notes,
        'connected' AS booking_type
    FROM 
        connected_bookings cb
    JOIN 
        cargo c ON cb.cargo_id = c.cargo_id
    JOIN 
        ports op ON cb.origin_port_id = op.port_id
    JOIN 
        ports dp ON cb.destination_port_id = dp.port_id
    WHERE 
        cb.connected_booking_id = p_booking_id AND cb.user_id = p_user_id;
    
    -- Get segment details for this connected booking
    SELECT 
        cbs.segment_id,
        cbs.segment_order,
        cbs.schedule_id,
        cbs.segment_price,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        op.port_id AS origin_port_id,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        dp.name AS destination_port,
        dp.port_id AS destination_port_id,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        r.distance,
        ships.name AS ship_name,
        ships.ship_type,
        TIMESTAMPDIFF(HOUR, 
            s.arrival_date, 
            LEAD(s.departure_date) OVER (ORDER BY cbs.segment_order)
        ) / 24 AS connection_time
    FROM 
        connected_booking_segments cbs
    JOIN 
        schedules s ON cbs.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        cbs.connected_booking_id = p_booking_id
    ORDER BY 
        cbs.segment_order;
    
    -- Get username
    SELECT username FROM users WHERE user_id = p_user_id;
END//
DELIMITER ;


DELIMITER //


CREATE PROCEDURE cancel_direct_booking(
    IN p_booking_id INT,
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE cargo_id INT;
    DECLARE schedule_id INT;
    DECLARE cargo_weight DECIMAL(10, 2);
    
    START TRANSACTION;
    
    -- Get cargo ID and schedule ID for this booking
    SELECT cb.cargo_id, cb.schedule_id 
    INTO cargo_id, schedule_id
    FROM cargo_bookings cb
    WHERE cb.booking_id = p_booking_id AND cb.user_id = p_user_id
    FOR UPDATE;
    
    IF cargo_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Booking not found or does not belong to you';
        ROLLBACK;
    ELSE
        -- Get cargo weight to restore schedule capacity
        SELECT weight INTO cargo_weight 
        FROM cargo WHERE cargo_id = cargo_id;
        
        -- Update booking status
        UPDATE cargo_bookings 
        SET booking_status = 'cancelled', payment_status = 'refunded'
        WHERE booking_id = p_booking_id AND user_id = p_user_id;
        
        -- Update cargo status back to pending
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = cargo_id;
        
        -- Restore schedule capacity
        UPDATE schedules
        SET max_cargo = max_cargo + cargo_weight
        WHERE schedule_id = schedule_id;
        
        SET p_success = TRUE;
        SET p_message = 'Booking cancelled successfully. Your payment will be refunded.';
        COMMIT;
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE cancel_connected_booking(
    IN p_booking_id INT,
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE cargo_id INT;
    DECLARE cargo_weight DECIMAL(10, 2);
    
    START TRANSACTION;
    
    -- Get cargo ID for this booking
    SELECT cb.cargo_id 
    INTO cargo_id
    FROM connected_bookings cb
    WHERE cb.connected_booking_id = p_booking_id AND cb.user_id = p_user_id
    FOR UPDATE;
    
    IF cargo_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Booking not found or does not belong to you';
        ROLLBACK;
    ELSE
        -- Get cargo weight to restore schedule capacity
        SELECT weight INTO cargo_weight 
        FROM cargo WHERE cargo_id = cargo_id;
        
        -- Update connected booking status
        UPDATE connected_bookings 
        SET booking_status = 'cancelled', payment_status = 'refunded'
        WHERE connected_booking_id = p_booking_id AND user_id = p_user_id;
        
        -- Update cargo status back to pending
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = cargo_id;
        
        -- Restore schedule capacity for all segments
        UPDATE schedules s
        JOIN connected_booking_segments cbs ON s.schedule_id = cbs.schedule_id
        SET s.max_cargo = s.max_cargo + cargo_weight
        WHERE cbs.connected_booking_id = p_booking_id;
        
        SET p_success = TRUE;
        SET p_message = 'Connected booking cancelled successfully. Your payment will be refunded.';
        COMMIT;
    END IF;
END//
DELIMITER ;


DELIMITER //

CREATE PROCEDURE get_active_ports()
BEGIN
    SELECT port_id, name, country, ST_Y(location) as lat, ST_X(location) as lng
    FROM ports 
    WHERE status = 'active'
    ORDER BY name;
END//

CREATE PROCEDURE get_user_cargo(IN p_user_id INT)
BEGIN
    SELECT cargo_id, description, cargo_type, weight, dimensions 
    FROM cargo 
    WHERE user_id = p_user_id
    AND status IN ('pending', 'booked')
    ORDER BY created_at DESC;
END//

CREATE PROCEDURE get_user_username(IN p_user_id INT)
BEGIN
    SELECT username FROM users WHERE user_id = p_user_id;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_route_segment_details(IN p_schedule_id INT)
BEGIN
    SELECT
        s.schedule_id,
        s.ship_id,
        ships.name AS ship_name,
        ships.ship_type,
        r.origin_port_id,
        op.name AS origin_port,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        r.destination_port_id,
        dp.name AS destination_port,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        s.departure_date,
        s.arrival_date,
        TIMESTAMPDIFF(DAY, s.departure_date, s.arrival_date) AS duration
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
        s.schedule_id = p_schedule_id;
END//

CREATE PROCEDURE get_connection_time(
    IN p_first_schedule_id INT,
    IN p_second_schedule_id INT
)
BEGIN
    SELECT
        TIMESTAMPDIFF(HOUR, s1.arrival_date, s2.departure_date) / 24.0
    FROM
        schedules s1, schedules s2
    WHERE
        s1.schedule_id = p_first_schedule_id AND s2.schedule_id = p_second_schedule_id;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_booking_price_info(
    IN p_cargo_id INT,
    IN p_schedule_id INT
)
BEGIN
    SELECT 
        r.cost_per_kg,
        c.weight,
        r.cost_per_kg * c.weight AS total_price
    FROM 
        schedules s
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        cargo c ON c.cargo_id = p_cargo_id
    WHERE 
        s.schedule_id = p_schedule_id;
END//

CREATE PROCEDURE get_schedule_details(IN p_schedule_id INT)
BEGIN
    SELECT 
        s.schedule_id,
        s.ship_id,
        ships.name AS ship_name,
        ships.ship_type,
        r.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        s.departure_date,
        s.arrival_date,
        r.cost_per_kg,
        r.distance
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
        s.schedule_id = p_schedule_id;
END//

CREATE PROCEDURE get_cargo_details(IN p_cargo_id INT, IN p_user_id INT)
BEGIN
    SELECT 
        cargo_id, description, cargo_type, weight, dimensions
    FROM 
        cargo
    WHERE 
        cargo_id = p_cargo_id AND user_id = p_user_id;
END//

DELIMITER ;


DELIMITER //

CREATE PROCEDURE get_connected_route_endpoints(
    IN p_first_schedule_id INT,
    IN p_last_schedule_id INT
)
BEGIN
    SELECT 
        r1.origin_port_id AS origin_port_id,
        r2.destination_port_id AS destination_port_id
    FROM 
        schedules s1
    JOIN 
        routes r1 ON s1.route_id = r1.route_id
    JOIN 
        schedules s2 ON s2.schedule_id = p_last_schedule_id
    JOIN 
        routes r2 ON s2.route_id = r2.route_id
    WHERE 
        s1.schedule_id = p_first_schedule_id;
END//

CREATE PROCEDURE calculate_connected_route_price(
    IN p_schedule_ids TEXT,
    IN p_cargo_id INT
)
BEGIN
    SET @sql = CONCAT(
        'SELECT 
            SUM(r.cost_per_kg * c.weight) AS total_price,
            c.weight
        FROM 
            cargo c
        JOIN (
            SELECT 
                schedule_id, 
                route_id
            FROM 
                schedules
            WHERE 
                schedule_id IN (', p_schedule_ids, ')
        ) s ON 1=1
        JOIN 
            routes r ON s.route_id = r.route_id
        WHERE 
            c.cargo_id = ?
        GROUP BY 
            c.weight');
            
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING p_cargo_id;
END//



CREATE PROCEDURE create_booking_segment(
    IN p_connected_booking_id INT,
    IN p_schedule_id INT,
    IN p_segment_order INT,
    IN p_cargo_weight DECIMAL(10,2)
)
BEGIN
    DECLARE segment_price DECIMAL(12,2);
    
    -- Calculate segment price
    SELECT 
        r.cost_per_kg * p_cargo_weight INTO segment_price
    FROM 
        schedules s
    JOIN 
        routes r ON s.route_id = r.route_id
    WHERE 
        s.schedule_id = p_schedule_id;
    
    -- Insert segment
    INSERT INTO connected_booking_segments (
        connected_booking_id, schedule_id, segment_order, segment_price
    ) VALUES (
        p_connected_booking_id, p_schedule_id, p_segment_order, segment_price
    );
    
    -- Update schedule available capacity
    UPDATE schedules
    SET max_cargo = max_cargo - p_cargo_weight
    WHERE schedule_id = p_schedule_id;
END//

CREATE PROCEDURE update_cargo_status(
    IN p_cargo_id INT,
    IN p_user_id INT,
    IN p_status VARCHAR(50)
)
BEGIN
    UPDATE cargo 
    SET status = p_status
    WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
END//

DELIMITER ;

--
DELIMITER //

CREATE PROCEDURE get_user_direct_bookings(IN p_user_id INT)
BEGIN
    SELECT 
        b.booking_id,
        b.cargo_id,
        c.description AS cargo_description,
        b.schedule_id,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        b.booking_status,
        b.payment_status,
        b.price,
        b.booking_date,
        ships.name AS ship_name
    FROM 
        cargo_bookings b
    JOIN 
        cargo c ON b.cargo_id = c.cargo_id
    JOIN 
        schedules s ON b.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        b.user_id = p_user_id
    ORDER BY 
        b.booking_date DESC;
END//

CREATE PROCEDURE get_user_connected_bookings(IN p_user_id INT)
BEGIN
    SELECT 
        cb.connected_booking_id,
        cb.cargo_id,
        c.description AS cargo_description,
        op.name AS origin_port,
        dp.name AS destination_port,
        cb.booking_status,
        cb.payment_status,
        cb.total_price,
        cb.booking_date,
        COUNT(cbs.segment_id) AS total_segments
    FROM 
        connected_bookings cb
    JOIN 
        cargo c ON cb.cargo_id = c.cargo_id
    JOIN 
        ports op ON cb.origin_port_id = op.port_id
    JOIN 
        ports dp ON cb.destination_port_id = dp.port_id
    JOIN 
        connected_booking_segments cbs ON cb.connected_booking_id = cbs.connected_booking_id
    WHERE 
        cb.user_id = p_user_id
    GROUP BY 
        cb.connected_booking_id
    ORDER BY 
        cb.booking_date DESC;
END//

CREATE PROCEDURE get_connected_booking_dates(IN p_booking_id INT)
BEGIN
    SELECT 
        MIN(s.departure_date) AS first_departure,
        MAX(s.arrival_date) AS last_arrival
    FROM 
        connected_booking_segments cbs
    JOIN 
        schedules s ON cbs.schedule_id = s.schedule_id
    WHERE 
        cbs.connected_booking_id = p_booking_id;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_direct_booking_details(
    IN p_booking_id INT,
    IN p_user_id INT
)
BEGIN
    SELECT 
        b.booking_id,
        b.cargo_id,
        c.description AS cargo_description,
        c.cargo_type,
        c.weight AS cargo_weight,
        c.dimensions AS cargo_dimensions,
        b.schedule_id,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        dp.name AS destination_port,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        r.distance,
        b.booking_status,
        b.payment_status,
        b.price,
        b.booking_date,
        b.notes,
        ships.name AS ship_name,
        ships.ship_type
    FROM 
        cargo_bookings b
    JOIN 
        cargo c ON b.cargo_id = c.cargo_id
    JOIN 
        schedules s ON b.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        b.booking_id = p_booking_id AND b.user_id = p_user_id;
END//



CREATE PROCEDURE get_connected_booking_segments(
    IN p_booking_id INT
)
BEGIN
    SELECT 
        cbs.segment_id,
        cbs.segment_order,
        cbs.schedule_id,
        cbs.segment_price,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        op.port_id AS origin_port_id,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        dp.name AS destination_port,
        dp.port_id AS destination_port_id,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        r.distance,
        ships.name AS ship_name,
        ships.ship_type
    FROM 
        connected_booking_segments cbs
    JOIN 
        schedules s ON cbs.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        cbs.connected_booking_id = p_booking_id
    ORDER BY 
        cbs.segment_order;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_direct_booking_for_cancel(
    IN p_booking_id INT,
    IN p_user_id INT
)
BEGIN
    SELECT cargo_id, schedule_id, price
    FROM cargo_bookings
    WHERE booking_id = p_booking_id AND user_id = p_user_id;
END//

DELIMITER //
CREATE PROCEDURE get_connected_booking_for_cancel(
    IN p_booking_id INT,
    IN p_user_id INT
)
BEGIN
    SELECT cb.cargo_id, cbs.schedule_id
    FROM connected_bookings cb
    JOIN connected_booking_segments cbs ON cb.connected_booking_id = cbs.connected_booking_id
    WHERE cb.connected_booking_id = p_booking_id AND cb.user_id = p_user_id;
END//



CREATE PROCEDURE restore_schedule_capacity(
    IN p_schedule_id INT,
    IN p_cargo_weight DECIMAL(10,2)
)
BEGIN
    UPDATE schedules
    SET max_cargo = max_cargo + p_cargo_weight
    WHERE schedule_id = p_schedule_id;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_cargo_details_api(
    IN p_cargo_id INT,
    IN p_user_id INT
)
BEGIN
    SELECT cargo_id, description, cargo_type, weight, dimensions
    FROM cargo
    WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
END//

DELIMITER ;


DELIMITER //

DROP PROCEDURE IF EXISTS cancel_booking_direct //

CREATE PROCEDURE cancel_booking_direct(
    IN p_booking_id INT,
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_cargo_id INT;
    DECLARE v_schedule_id INT;
    DECLARE v_cargo_weight DECIMAL(10, 2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'An error occurred while cancelling the booking';
    END;
    
    START TRANSACTION;
    
    -- Get booking details
    SELECT cargo_id, schedule_id INTO v_cargo_id, v_schedule_id
    FROM cargo_bookings 
    WHERE booking_id = p_booking_id AND user_id = p_user_id
    LIMIT 1;
    
    IF v_cargo_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Booking not found or does not belong to you';
        ROLLBACK;
    ELSE
        -- Get cargo weight
        SELECT weight INTO v_cargo_weight
        FROM cargo
        WHERE cargo_id = v_cargo_id
        LIMIT 1;
        
        -- Update booking status
        UPDATE cargo_bookings 
        SET booking_status = 'cancelled', payment_status = 'refunded'
        WHERE booking_id = p_booking_id AND user_id = p_user_id;
        
        -- Update cargo status
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = v_cargo_id;
        
        -- Restore schedule capacity
        UPDATE schedules
        SET max_cargo = max_cargo + v_cargo_weight
        WHERE schedule_id = v_schedule_id;
        
        SET p_success = TRUE;
        SET p_message = 'Booking cancelled successfully. Your payment will be refunded.';
        COMMIT;
    END IF;
END//

DELIMITER ;

DELIMITER //

DROP PROCEDURE IF EXISTS cancel_booking_connected //

CREATE PROCEDURE cancel_booking_connected(
    IN p_booking_id INT,
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_cargo_id INT;
    DECLARE v_cargo_weight DECIMAL(10, 2);
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_schedule_id INT;
    
    -- Cursor for schedule IDs
    DECLARE schedule_cursor CURSOR FOR
        SELECT schedule_id
        FROM connected_booking_segments
        WHERE connected_booking_id = p_booking_id;
    
    -- Handler for when cursor reaches end
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Handler for SQL exceptions
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'An error occurred while cancelling the booking';
    END;
    
    START TRANSACTION;
    
    -- Get booking details
    SELECT cargo_id INTO v_cargo_id
    FROM connected_bookings 
    WHERE connected_booking_id = p_booking_id AND user_id = p_user_id
    LIMIT 1;
    
    IF v_cargo_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Booking not found or does not belong to you';
        ROLLBACK;
    ELSE
        -- Get cargo weight
        SELECT weight INTO v_cargo_weight
        FROM cargo
        WHERE cargo_id = v_cargo_id
        LIMIT 1;
        
        -- Update booking status
        UPDATE connected_bookings 
        SET booking_status = 'cancelled', payment_status = 'refunded'
        WHERE connected_booking_id = p_booking_id AND user_id = p_user_id;
        
        -- Update cargo status
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = v_cargo_id;
        
        -- Restore schedule capacity for all segments
        OPEN schedule_cursor;
        
        read_loop: LOOP
            FETCH schedule_cursor INTO v_schedule_id;
            IF done THEN
                LEAVE read_loop;
            END IF;
            
            UPDATE schedules
            SET max_cargo = max_cargo + v_cargo_weight
            WHERE schedule_id = v_schedule_id;
        END LOOP;
        
        CLOSE schedule_cursor;
        
        SET p_success = TRUE;
        SET p_message = 'Connected booking cancelled successfully. Your payment will be refunded.';
        COMMIT;
    END IF;
END//

DELIMITER ;


DELIMITER //

DROP PROCEDURE IF EXISTS delete_user //

CREATE PROCEDURE delete_user(
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE username VARCHAR(50);
    DECLARE cargo_count INT DEFAULT 0;
    DECLARE bookings_count INT DEFAULT 0;
    DECLARE ships_count INT DEFAULT 0;
    DECLARE routes_count INT DEFAULT 0;
    
    -- Get username for message
    SELECT username INTO username FROM users WHERE user_id = p_user_id;
    IF username IS NULL THEN
        select user_id into username from users where user_id = p_user_id;
    END IF;
    
    IF username IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'User not found.';
    ELSE
        -- Check if user has any cargo
        SELECT COUNT(*) INTO cargo_count FROM cargo WHERE user_id = p_user_id;
        
        -- Check if user has any bookings (direct or connected)
        SELECT 
            (SELECT COUNT(*) FROM cargo_bookings WHERE user_id = p_user_id) +
            (SELECT COUNT(*) FROM connected_bookings WHERE user_id = p_user_id)
        INTO bookings_count;
        
        -- Check if user owns any ships
        SELECT COUNT(*) INTO ships_count FROM ships WHERE owner_id = p_user_id;
        
        -- Check if user owns any routes
        SELECT COUNT(*) INTO routes_count FROM routes WHERE owner_id = p_user_id;
        
        -- Only delete if no dependencies exist
        IF cargo_count > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete user "', username, '". User has ', cargo_count, ' cargo items. Please delete them first.');
        ELSEIF bookings_count > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete user "', username, '". User has ', bookings_count, ' bookings. Please delete them first.');
        ELSEIF ships_count > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete user "', username, '". User owns ', ships_count, ' ships. Please reassign or delete them first.');
        ELSEIF routes_count > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete user "', username, '". User owns ', routes_count, ' routes. Please reassign or delete them first.');
        ELSE
            -- Safe to delete
            DELETE FROM user_roles WHERE user_id = p_user_id;
            DELETE FROM users WHERE user_id = p_user_id;
            
            SET p_success = TRUE;
            SET p_message = CONCAT('User "', username, '" deleted successfully!');
        END IF;
    END IF;
END//

DELIMITER ;


DELIMITER //

DROP PROCEDURE IF EXISTS edit_user //

CREATE PROCEDURE edit_user(
    IN p_user_id INT,
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    IN p_roles VARCHAR(255),
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE existing_username VARCHAR(50);
    DECLARE email_exists INT DEFAULT 0;
    DECLARE role_id_val INT;
    DECLARE role_name_val VARCHAR(50);
    DECLARE role_exists BOOLEAN;
    DECLARE done INT DEFAULT FALSE;
    DECLARE roles_cursor CURSOR FOR SELECT value FROM roles_temp;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Create temporary table for roles
    DROP TEMPORARY TABLE IF EXISTS roles_temp;
    CREATE TEMPORARY TABLE roles_temp (
        id INT AUTO_INCREMENT PRIMARY KEY,
        value VARCHAR(50)
    );
    
    -- Parse the roles string into the temporary table
    SET @sql = CONCAT("INSERT INTO roles_temp (value) VALUES ('", REPLACE(p_roles, ",", "'),('"), "')");
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Check if user exists
    SELECT username INTO existing_username FROM users WHERE user_id = p_user_id;
    
    IF existing_username IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'User not found.';
    ELSE
        -- Check if email is already in use by another user
        SELECT COUNT(*) INTO email_exists 
        FROM users 
        WHERE email = p_email AND user_id != p_user_id;
        
        IF email_exists > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Email "', p_email, '" is already in use by another user.');
        ELSE
            START TRANSACTION;
            
            -- Update user information
            IF p_password IS NOT NULL AND p_password != '' THEN
                UPDATE users 
                SET username = p_username, 
                    email = p_email, 
                    password = p_password 
                WHERE user_id = p_user_id;
            ELSE
                UPDATE users 
                SET username = p_username, 
                    email = p_email 
                WHERE user_id = p_user_id;
            END IF;
            
            -- Delete existing roles
            DELETE FROM user_roles WHERE user_id = p_user_id;
            
            -- Check if all roles exist and add them
            OPEN roles_cursor;
            
            roles_loop: LOOP
                FETCH roles_cursor INTO role_name_val;
                IF done THEN
                    LEAVE roles_loop;
                END IF;
                
                -- Check if role exists
                SELECT role_id INTO role_id_val 
                FROM roles 
                WHERE role_name = role_name_val;
                
                IF role_id_val IS NULL THEN
                    SET p_success = FALSE;
                    SET p_message = CONCAT('Role "', role_name_val, '" does not exist.');
                    ROLLBACK;
                    CLOSE roles_cursor;
                    LEAVE roles_loop;
                ELSE
                    -- Add role to user
                    INSERT INTO user_roles (user_id, role_id)
                    VALUES (p_user_id, role_id_val);
                END IF;
            END LOOP;
            
            CLOSE roles_cursor;
            
            IF p_success IS NULL THEN
                SET p_success = TRUE;
                SET p_message = CONCAT('User "', p_username, '" updated successfully!');
                COMMIT;
            END IF;
        END IF;
    END IF;
    
    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS roles_temp;
END//

DELIMITER ;

-- berth related procedures
DELIMITER //

-- Procedure to add a new berth with validation
DROP PROCEDURE IF EXISTS add_new_berth //

CREATE PROCEDURE add_new_berth(
    IN p_port_id INT,
    IN p_berth_number VARCHAR(20),
    IN p_type VARCHAR(50),
    IN p_length DECIMAL(10, 2),
    IN p_width DECIMAL(10, 2),
    IN p_depth DECIMAL(10, 2),
    IN p_status VARCHAR(20),
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE port_exists INT;
    DECLARE berth_exists INT;
    DECLARE port_name VARCHAR(100);
    
    -- Check if the port exists and get its name
    SELECT COUNT(*) INTO port_exists
    FROM ports 
    WHERE port_id = p_port_id
    AND status = 'active';
    
    -- Get port name separately
    SELECT name INTO port_name
    FROM ports
    WHERE port_id = p_port_id;
    
    IF port_exists = 0 THEN
        SET p_success = FALSE;
        SET p_message = 'The selected port does not exist or is inactive.';
    ELSE
        -- Check if the berth number already exists for this port
        SELECT COUNT(*) INTO berth_exists
        FROM berths
        WHERE port_id = p_port_id AND berth_number = p_berth_number;
        
        IF berth_exists > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Berth number "', p_berth_number, '" already exists for port "', port_name, '".');
        ELSEIF p_length <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth length must be greater than zero.';
        ELSEIF p_width <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth width must be greater than zero.';
        ELSEIF p_depth <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth depth must be greater than zero.';
        ELSE
            -- Insert the new berth
            INSERT INTO berths (
                port_id, berth_number, type, length, width, depth, status
            ) VALUES (
                p_port_id, p_berth_number, p_type, p_length, p_width, p_depth, p_status
            );
            
            SET p_success = TRUE;
            SET p_message = CONCAT('Berth "', p_berth_number, '" has been added successfully to port "', port_name, '".');
        END IF;
    END IF;
END//

-- Procedure to edit an existing berth with validation
DROP PROCEDURE IF EXISTS edit_berth //

CREATE PROCEDURE edit_berth(
    IN p_berth_id INT,
    IN p_port_id INT,
    IN p_berth_number VARCHAR(20),
    IN p_type VARCHAR(50),
    IN p_length DECIMAL(10, 2),
    IN p_width DECIMAL(10, 2),
    IN p_depth DECIMAL(10, 2),
    IN p_status VARCHAR(20),
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE berth_exists INT;
    DECLARE existing_berth_number VARCHAR(20);
    DECLARE port_name VARCHAR(100);
    DECLARE duplicate_exists INT;
    
    -- Check if the berth exists and get its number
    SELECT COUNT(*) INTO berth_exists
    FROM berths
    WHERE berth_id = p_berth_id;
    
    -- Get berth number separately
    SELECT berth_number INTO existing_berth_number
    FROM berths
    WHERE berth_id = p_berth_id;
    
    IF berth_exists = 0 THEN
        SET p_success = FALSE;
        SET p_message = 'The selected berth does not exist.';
    ELSE
        -- Get port name for message
        SELECT name INTO port_name
        FROM ports
        WHERE port_id = p_port_id;
        
        -- Check for duplicate berth number
        SELECT COUNT(*) INTO duplicate_exists
        FROM berths
        WHERE port_id = p_port_id 
        AND berth_number = p_berth_number 
        AND berth_id != p_berth_id;
        
        IF duplicate_exists > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Berth number "', p_berth_number, '" is already in use by another berth at port "', port_name, '".');
        ELSEIF p_length <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth length must be greater than zero.';
        ELSEIF p_width <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth width must be greater than zero.';
        ELSEIF p_depth <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth depth must be greater than zero.';
        ELSE
            -- Update the berth
            UPDATE berths
            SET berth_number = p_berth_number,
                type = p_type,
                length = p_length,
                width = p_width,
                depth = p_depth,
                status = p_status
            WHERE berth_id = p_berth_id;
            
            SET p_success = TRUE;
            SET p_message = CONCAT('Berth "', p_berth_number, '" has been updated successfully.');
        END IF;
    END IF;
END//

-- Procedure to delete a berth with proper checks
DELIMITER //
DELIMITER //

DROP PROCEDURE IF EXISTS delete_berth //

CREATE PROCEDURE delete_berth(
    IN p_berth_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE berth_exists INT DEFAULT 0;
    DECLARE berth_number VARCHAR(20) DEFAULT NULL;
    DECLARE berth_status VARCHAR(20) DEFAULT NULL;
    DECLARE assignment_count INT DEFAULT 0;
    DECLARE port_name VARCHAR(100) DEFAULT NULL;
    DECLARE port_id_val INT DEFAULT NULL;
    
    -- Initialize output parameters
    SET p_success = FALSE;
    SET p_message = 'An error occurred during the deletion process.';
    
    -- Check if berth exists
    SELECT COUNT(*) INTO berth_exists
    FROM berths
    WHERE berth_id = p_berth_id;
    
    IF berth_exists = 0 THEN
        SET p_success = FALSE;
        SET p_message = CONCAT('The berth with ID ', p_berth_id, ' does not exist.');
    ELSE
        -- Get berth number and status separately to avoid issues
        SELECT berth_number INTO berth_number 
        FROM berths 
        WHERE berth_id = p_berth_id;
        
        SELECT status INTO berth_status 
        FROM berths 
        WHERE berth_id = p_berth_id;
        
        SELECT port_id INTO port_id_val 
        FROM berths 
        WHERE berth_id = p_berth_id;
        
        -- Get port name
        IF port_id_val IS NOT NULL THEN
            SELECT name INTO port_name 
            FROM ports 
            WHERE port_id = port_id_val;
        END IF;
        
        -- Use default values if any data is missing
        IF berth_number IS NULL THEN
            SET berth_number = CONCAT('ID:', p_berth_id);
        END IF;
        
        IF port_name IS NULL THEN
            SET port_name = 'Unknown Port';
        END IF;
        
        -- Check for assignments
        SELECT COUNT(*) INTO assignment_count
        FROM berth_assignments
        WHERE berth_id = p_berth_id AND status = 'active';
        
        -- Perform validation
        IF berth_status = 'occupied' THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete berth "', berth_number, '" because it is currently occupied.');
        ELSEIF assignment_count > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete berth "', berth_number, '" because it has ', assignment_count, ' active assignments.');
        ELSE
            -- Safe to delete
            START TRANSACTION;
            
            DELETE FROM berths WHERE berth_id = p_berth_id;
            
            IF ROW_COUNT() > 0 THEN
                SET p_success = TRUE;
                SET p_message = CONCAT('Berth "', berth_number, '" has been deleted successfully from port "', port_name, '".');
                COMMIT;
            ELSE
                SET p_success = FALSE;
                SET p_message = CONCAT('Failed to delete berth "', berth_number, '". No rows affected.');
                ROLLBACK;
            END IF;
        END IF;
    END IF;
END//

DELIMITER ;

DELIMITER ;

select * from berths;

select * from berth_assignments;

select * from berths where berth_id = 77;

select * from ports where port_id = 87;

-- Set the output variables
SET @p_success = NULL;
SET @p_message = '';

-- Call the stored procedure with the berth_id parameter
CALL delete_berth(77, @p_success, @p_message);

-- Retrieve the output values
SELECT @p_success AS success, @p_message AS message;


