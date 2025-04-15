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
    status ENUM('available', 'occupied', 'maintenance', 'reserved') NOT NULL DEFAULT 'available',
    capacity DECIMAL(12, 2) NOT NULL COMMENT 'Maximum weight capacity in tons',
    berth_type ENUM('container', 'bulk', 'tanker', 'roro', 'general') NOT NULL DEFAULT 'general',
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
INSERT INTO berths (berth_number, port_id, status, capacity, berth_type) VALUES
('B001', 1, 'available', 50000.00, 'container'),
('B002', 1, 'available', 30000.00, 'bulk'),
('B003', 1, 'available', 60000.00, 'tanker'),
('B004', 2, 'available', 40000.00, 'container'),
('B005', 2, 'available', 25000.00, 'bulk'),
('B006', 3, 'available', 55000.00, 'container'),
('B007', 3, 'available', 35000.00, 'tanker'),
('B008', 4, 'available', 45000.00, 'container'),
('B009', 5, 'available', 30000.00, 'roro'),
('B010', 6, 'available', 50000.00, 'container');

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