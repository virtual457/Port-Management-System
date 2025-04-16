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

-- Create a stored procedure to automatically assign a berth when a schedule is created
DELIMITER //
CREATE PROCEDURE assign_berth_for_schedule(
    IN p_schedule_id INT,
    IN p_ship_id INT,
    IN p_route_id INT,
    IN p_departure_date DATETIME,
    IN p_arrival_date DATETIME
)
BEGIN
    DECLARE v_destination_port_id INT;
    DECLARE v_ship_type VARCHAR(50);
    DECLARE v_ship_capacity DECIMAL(12, 2);
    DECLARE v_berth_id INT;
    
    -- Get destination port from route
    SELECT destination_port_id INTO v_destination_port_id
    FROM routes
    WHERE route_id = p_route_id;
    
    -- Get ship type and capacity
    SELECT ship_type, capacity INTO v_ship_type, v_ship_capacity
    FROM ships
    WHERE ship_id = p_ship_id;
    
    -- Find an available berth that matches the ship type and has enough capacity
    SELECT b.berth_id INTO v_berth_id
    FROM berths b
    WHERE b.port_id = v_destination_port_id
      AND b.status = 'available'
      AND b.capacity >= v_ship_capacity
      AND (b.berth_type = v_ship_type OR b.berth_type = 'general')
      AND NOT EXISTS (
          SELECT 1
          FROM berth_assignments ba
          WHERE ba.berth_id = b.berth_id
            AND ba.status IN ('scheduled', 'current')
            AND (
                (p_arrival_date BETWEEN ba.arrival_time AND ba.departure_time)
                OR (p_departure_date BETWEEN ba.arrival_time AND ba.departure_time)
                OR (ba.arrival_time BETWEEN p_arrival_date AND p_departure_date)
                OR (ba.departure_time BETWEEN p_arrival_date AND p_departure_date)
            )
      )
    ORDER BY b.berth_id
    LIMIT 1;
    
    -- If a suitable berth was found, create the assignment
    IF v_berth_id IS NOT NULL THEN
        INSERT INTO berth_assignments (
            berth_id, ship_id, schedule_id, arrival_time, departure_time, status
        ) VALUES (
            v_berth_id, p_ship_id, p_schedule_id, p_arrival_date, p_departure_date, 'scheduled'
        );
        
        -- Update berth status
        UPDATE berths SET status = 'reserved' WHERE berth_id = v_berth_id;
    END IF;
END//
DELIMITER ;

-- Create a trigger to automatically assign a berth when a new schedule is added
DELIMITER //
CREATE TRIGGER after_schedule_insert
AFTER INSERT ON schedules
FOR EACH ROW
BEGIN
    CALL assign_berth_for_schedule(
        NEW.schedule_id,
        NEW.ship_id,
        NEW.route_id,
        NEW.departure_date,
        NEW.arrival_date
    );
END//
DELIMITER ;

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
-- Check roles assigned to Chandan (user_id = 1)
select * from user_roles where user_id = 1; 

select * from users;


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