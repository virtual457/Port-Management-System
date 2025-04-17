-- =======================================================
-- MARITIME CARGO MANAGEMENT SYSTEM - DATA POPULATION SCRIPT
-- =======================================================

-- -------------------------
-- CLEANUP: DELETE EXISTING DATA
-- -------------------------

-- First, disable foreign key checks to allow easy deletion
SET FOREIGN_KEY_CHECKS = 0;

-- Clear all data in reverse order of dependencies
DELETE FROM connected_booking_segments;
DELETE FROM connected_bookings;
DELETE FROM cargo_bookings;
DELETE FROM schedules;
DELETE FROM routes;
DELETE FROM ships;
DELETE FROM cargo;
DELETE FROM user_roles WHERE user_id > 7; -- Keep roles for original users
DELETE FROM users WHERE user_id > 7; -- Keep the original 7 users
DELETE FROM ports WHERE port_id > 0; -- Clear all ports

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- -------------------------
-- STEP 1: CREATE PORTS
-- -------------------------

-- Add active ports
INSERT INTO ports (name, country, location, status) VALUES
('Port of Hamburg', 'Germany', POINT(9.9937, 53.5511), 'active'),
('Port of Vancouver', 'Canada', POINT(-123.0830, 49.2827), 'active'),
('Port of Mumbai', 'India', POINT(72.8777, 18.9387), 'active'),
('Port of Tokyo', 'Japan', POINT(139.6917, 35.6895), 'active'),
('Port of Rio de Janeiro', 'Brazil', POINT(-43.1729, -22.9068), 'active'),
('Port of Marseille', 'France', POINT(5.3698, 43.2965), 'active'),
('Port of Alexandria', 'Egypt', POINT(29.9187, 31.2001), 'active'),
('Port of Melbourne', 'Australia', POINT(144.9631, -37.8136), 'active'),
('Port of Busan', 'South Korea', POINT(129.0756, 35.1796), 'active'),
('Port of Barcelona', 'Spain', POINT(2.1686, 41.3851), 'active');

-- Add inactive or seasonal ports
INSERT INTO ports (name, country, location, status) VALUES
('Port of Reykjavik', 'Iceland', POINT(-21.9426, 64.1466), 'inactive'),
('Port of Havana', 'Cuba', POINT(-82.3666, 23.1136), 'inactive'),
('Port of Murmansk', 'Russia', POINT(33.0826, 68.9585), 'inactive'),
('Port of Ushuaia', 'Argentina', POINT(-68.3034, -54.8019), 'inactive'),
('Port of Churchill', 'Canada', POINT(-94.1711, 58.7684), 'inactive');

-- -------------------------
-- STEP 2: CREATE USERS AND ASSIGN ROLES
-- -------------------------

-- Add customer users
INSERT INTO users (username, first_name, last_name, phone_number, email, password) VALUES
('tomsmith', 'Tom', 'Smith', '+11234567890', 'customer1@example.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('sarahlee', 'Sarah', 'Lee', '+11234567891', 'customer2@example.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO');

-- Add shipowner users
INSERT INTO users (username, first_name, last_name, phone_number, email, password) VALUES
('jamesship', 'James', 'Carter', '+11234567892', 'shipowner1@shipping.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('marinafleet', 'Marina', 'Rodriguez', '+11234567893', 'shipowner2@fleetmanagement.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO');

-- Get the user IDs for reference
SET @tom_id = (SELECT user_id FROM users WHERE username = 'tomsmith');
SET @sarah_id = (SELECT user_id FROM users WHERE username = 'sarahlee');
SET @james_id = (SELECT user_id FROM users WHERE username = 'jamesship');
SET @marina_id = (SELECT user_id FROM users WHERE username = 'marinafleet');

-- Assign roles to users
INSERT INTO user_roles (user_id, role_id) VALUES
(@tom_id, 4), -- tomsmith - customer
(@sarah_id, 4), -- sarahlee - customer
(@james_id, 5), -- jamesship - shipowner
(@marina_id, 5); -- marinafleet - shipowner

-- -------------------------
-- STEP 3: CREATE SHIPS
-- -------------------------

-- Get port IDs for reference
SET @hamburg_id = (SELECT port_id FROM ports WHERE name = 'Port of Hamburg');
SET @vancouver_id = (SELECT port_id FROM ports WHERE name = 'Port of Vancouver');
SET @mumbai_id = (SELECT port_id FROM ports WHERE name = 'Port of Mumbai');
SET @tokyo_id = (SELECT port_id FROM ports WHERE name = 'Port of Tokyo');

-- Add ships for James (shipowner 1)
INSERT INTO ships (name, ship_type, capacity, current_port_id, imo_number, flag, year_built, status, owner_id) VALUES
('Atlantic Explorer', 'container', 85000.00, @hamburg_id, 'IMO9395001', 'Panama', 2015, 'active', @james_id),
('Pacific Voyager', 'bulk', 65000.00, @vancouver_id, 'IMO9412002', 'Marshall Islands', 2017, 'active', @james_id),
('North Sea Carrier', 'container', 92000.00, @mumbai_id, 'IMO9321003', 'Liberia', 2014, 'active', @james_id);

-- Add ships for Marina (shipowner 2)
INSERT INTO ships (name, ship_type, capacity, current_port_id, imo_number, flag, year_built, status, owner_id) VALUES
('Mediterranean Queen', 'tanker', 105000.00, @tokyo_id, 'IMO9517004', 'Greece', 2018, 'active', @marina_id),
('Asian Star', 'container', 78000.00, (SELECT port_id FROM ports WHERE name = 'Port of Rio de Janeiro'), 'IMO9632005', 'Singapore', 2016, 'active', @marina_id),
('Caribbean Princess', 'roro', 45000.00, @vancouver_id, 'IMO9745006', 'United States', 2019, 'active', @marina_id);

-- Store ship IDs for later reference
SET @atlantic_explorer_id = (SELECT ship_id FROM ships WHERE name = 'Atlantic Explorer');
SET @pacific_voyager_id = (SELECT ship_id FROM ships WHERE name = 'Pacific Voyager');
SET @north_sea_carrier_id = (SELECT ship_id FROM ships WHERE name = 'North Sea Carrier');
SET @mediterranean_queen_id = (SELECT ship_id FROM ships WHERE name = 'Mediterranean Queen');
SET @asian_star_id = (SELECT ship_id FROM ships WHERE name = 'Asian Star');
SET @caribbean_princess_id = (SELECT ship_id FROM ships WHERE name = 'Caribbean Princess');

-- -------------------------
-- STEP 4: CREATE CARGO
-- -------------------------

-- Cargo for Tom (customer 1)
INSERT INTO cargo (user_id, description, cargo_type, weight, dimensions, special_instructions, status) VALUES
(@tom_id, 'Computer Equipment', 'container', 5000.00, '20x8x8.5', 'Handle with care. Keep dry.', 'pending'),
(@tom_id, 'Automotive Parts', 'container', 12000.50, '40x8x8.5', 'Heavy equipment inside.', 'pending'),
(@tom_id, 'Frozen Foods', 'container', 8000.75, '40x8x8.5', 'Maintain temperature between -18°C to -20°C', 'pending'),
(@tom_id, 'Crude Oil', 'liquid', 25000.00, '40×8×8.5', 'Flammable liquid.', 'pending'),
(@tom_id, 'Luxury Yacht', 'vehicle', 18000.00, '60×15×20', 'High-value item. Special insurance.', 'pending');

-- Cargo for Sarah (customer 2)
INSERT INTO cargo (user_id, description, cargo_type, weight, dimensions, special_instructions, status) VALUES
(@sarah_id, 'Designer Furniture', 'container', 3500.00, '20×8×8.5', 'Fragile items inside.', 'pending'),
(@sarah_id, 'Medical Supplies', 'container', 2800.00, '20×8×8.5', 'Priority shipment. Temperature controlled.', 'pending'),
(@sarah_id, 'Farm Equipment', 'bulk', 15000.00, '30×10×5', 'Heavy machinery.', 'pending'),
(@sarah_id, 'Luxury Cars', 'vehicle', 5200.00, '40×8×8.5', 'Premium vehicles, special handling required.', 'pending'),
(@sarah_id, 'Pharmaceuticals', 'container', 1800.00, '20×8×8.5', 'Temperature sensitive. Keep between 2-8°C.', 'pending');

-- Store cargo IDs for later reference
SET @tom_cargo1_id = (SELECT cargo_id FROM cargo WHERE user_id = @tom_id AND description = 'Computer Equipment');
SET @tom_cargo2_id = (SELECT cargo_id FROM cargo WHERE user_id = @tom_id AND description = 'Automotive Parts');
SET @tom_cargo3_id = (SELECT cargo_id FROM cargo WHERE user_id = @tom_id AND description = 'Frozen Foods');
SET @tom_cargo4_id = (SELECT cargo_id FROM cargo WHERE user_id = @tom_id AND description = 'Crude Oil');
SET @tom_cargo5_id = (SELECT cargo_id FROM cargo WHERE user_id = @tom_id AND description = 'Luxury Yacht');

SET @sarah_cargo1_id = (SELECT cargo_id FROM cargo WHERE user_id = @sarah_id AND description = 'Designer Furniture');
SET @sarah_cargo2_id = (SELECT cargo_id FROM cargo WHERE user_id = @sarah_id AND description = 'Medical Supplies');
SET @sarah_cargo3_id = (SELECT cargo_id FROM cargo WHERE user_id = @sarah_id AND description = 'Farm Equipment');
SET @sarah_cargo4_id = (SELECT cargo_id FROM cargo WHERE user_id = @sarah_id AND description = 'Luxury Cars');
SET @sarah_cargo5_id = (SELECT cargo_id FROM cargo WHERE user_id = @sarah_id AND description = 'Pharmaceuticals');

-- -------------------------
-- STEP 5: CREATE ROUTES
-- -------------------------

-- Get additional port IDs
SET @rio_id = (SELECT port_id FROM ports WHERE name = 'Port of Rio de Janeiro');
SET @marseille_id = (SELECT port_id FROM ports WHERE name = 'Port of Marseille');
SET @alexandria_id = (SELECT port_id FROM ports WHERE name = 'Port of Alexandria');
SET @melbourne_id = (SELECT port_id FROM ports WHERE name = 'Port of Melbourne');
SET @busan_id = (SELECT port_id FROM ports WHERE name = 'Port of Busan');
SET @barcelona_id = (SELECT port_id FROM ports WHERE name = 'Port of Barcelona');

-- Routes for James (shipowner 1)
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Hamburg-Mumbai Express', @hamburg_id, @mumbai_id, 3500.00, 12.00, 'active', @james_id, @atlantic_explorer_id, 2.50),
('Vancouver-Tokyo Direct', @vancouver_id, @tokyo_id, 6200.00, 18.00, 'active', @james_id, @pacific_voyager_id, 3.20),
('Mumbai-Alexandria Route', @mumbai_id, @alexandria_id, 5100.00, 15.00, 'active', @james_id, @north_sea_carrier_id, 2.85);

-- Routes for Marina (shipowner 2)
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Tokyo-Rio Connection', @tokyo_id, @rio_id, 2800.00, 9.00, 'active', @marina_id, @mediterranean_queen_id, 2.75),
('Mumbai-Hamburg Return', @mumbai_id, @hamburg_id, 3500.00, 12.00, 'active', @marina_id, @asian_star_id, 2.60),
('Vancouver-Marseille Trade Route', @vancouver_id, @marseille_id, 4800.00, 16.00, 'active', @marina_id, @caribbean_princess_id, 3.10);

-- Store route IDs for later reference
SET @hamburg_mumbai_id = (SELECT route_id FROM routes WHERE name = 'Hamburg-Mumbai Express');
SET @vancouver_tokyo_id = (SELECT route_id FROM routes WHERE name = 'Vancouver-Tokyo Direct');
SET @mumbai_alexandria_id = (SELECT route_id FROM routes WHERE name = 'Mumbai-Alexandria Route');
SET @tokyo_rio_id = (SELECT route_id FROM routes WHERE name = 'Tokyo-Rio Connection');
SET @mumbai_hamburg_id = (SELECT route_id FROM routes WHERE name = 'Mumbai-Hamburg Return');
SET @vancouver_marseille_id = (SELECT route_id FROM routes WHERE name = 'Vancouver-Marseille Trade Route');

-- -------------------------
-- STEP 6: CREATE SCHEDULES
-- -------------------------

-- Past schedules (completed or cancelled)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@atlantic_explorer_id, @hamburg_mumbai_id, '2023-02-15 08:00:00', '2023-02-27 16:00:00', '2023-02-15 08:30:00', '2023-02-27 15:45:00', 'completed', 80000.00, 'Voyage completed successfully'),
(@pacific_voyager_id, @vancouver_tokyo_id, '2023-03-10 09:00:00', '2023-03-28 14:00:00', '2023-03-10 09:15:00', '2023-03-28 15:30:00', 'completed', 60000.00, 'Delay due to weather conditions'),
(@north_sea_carrier_id, @mumbai_alexandria_id, '2023-04-05 10:00:00', '2023-04-20 17:00:00', '2023-04-05 10:45:00', NULL, 'cancelled', 90000.00, 'Cancelled due to technical issues'),
(@mediterranean_queen_id, @tokyo_rio_id, '2023-05-20 07:00:00', '2023-05-29 15:00:00', '2023-05-20 07:30:00', '2023-05-29 16:15:00', 'completed', 100000.00, 'Smooth sailing'),
(@asian_star_id, @mumbai_hamburg_id, '2023-06-15 08:30:00', '2023-06-27 16:30:00', '2023-06-15 09:00:00', '2023-06-27 17:00:00', 'completed', 75000.00, 'Completed with minor delays');

-- Current schedules (in progress)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@caribbean_princess_id, @vancouver_marseille_id, CURRENT_DATE() - INTERVAL 5 DAY, CURRENT_DATE() + INTERVAL 11 DAY, CURRENT_DATE() - INTERVAL 5 DAY, NULL, 'in_progress', 42000.00, 'Currently in transit'),
(@atlantic_explorer_id, @hamburg_mumbai_id, CURRENT_DATE() - INTERVAL 3 DAY, CURRENT_DATE() + INTERVAL 9 DAY, CURRENT_DATE() - INTERVAL 3 DAY, NULL, 'in_progress', 80000.00, 'Currently in transit');

-- Future schedules (scheduled)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@pacific_voyager_id, @vancouver_tokyo_id, CURRENT_DATE() + INTERVAL 5 DAY, CURRENT_DATE() + INTERVAL 23 DAY, NULL, NULL, 'scheduled', 60000.00, 'Regular cargo service'),
(@north_sea_carrier_id, @mumbai_alexandria_id, CURRENT_DATE() + INTERVAL 10 DAY, CURRENT_DATE() + INTERVAL 25 DAY, NULL, NULL, 'scheduled', 90000.00, 'Express service'),
(@mediterranean_queen_id, @tokyo_rio_id, CURRENT_DATE() + INTERVAL 15 DAY, CURRENT_DATE() + INTERVAL 24 DAY, NULL, NULL, 'scheduled', 100000.00, 'Premium service'),
(@asian_star_id, @mumbai_hamburg_id, CURRENT_DATE() + INTERVAL 20 DAY, CURRENT_DATE() + INTERVAL 32 DAY, NULL, NULL, 'scheduled', 75000.00, 'Standard service'),
(@atlantic_explorer_id, @hamburg_mumbai_id, CURRENT_DATE() + INTERVAL 30 DAY, CURRENT_DATE() + INTERVAL 42 DAY, NULL, NULL, 'scheduled', 80000.00, 'Year-end service'),
(@caribbean_princess_id, @vancouver_marseille_id, CURRENT_DATE() + INTERVAL 35 DAY, CURRENT_DATE() + INTERVAL 51 DAY, NULL, NULL, 'scheduled', 42000.00, 'Holiday season cargo');

-- Store schedule IDs for later reference
SET @completed_schedule1 = (SELECT schedule_id FROM schedules WHERE ship_id = @atlantic_explorer_id AND status = 'completed' ORDER BY departure_date LIMIT 1);
SET @completed_schedule2 = (SELECT schedule_id FROM schedules WHERE ship_id = @pacific_voyager_id AND status = 'completed' LIMIT 1);
SET @cancelled_schedule = (SELECT schedule_id FROM schedules WHERE status = 'cancelled' LIMIT 1);
SET @completed_schedule3 = (SELECT schedule_id FROM schedules WHERE ship_id = @mediterranean_queen_id AND status = 'completed' LIMIT 1);
SET @completed_schedule4 = (SELECT schedule_id FROM schedules WHERE ship_id = @asian_star_id AND status = 'completed' LIMIT 1);
SET @in_progress_schedule1 = (SELECT schedule_id FROM schedules WHERE ship_id = @caribbean_princess_id AND status = 'in_progress' LIMIT 1);
SET @in_progress_schedule2 = (SELECT schedule_id FROM schedules WHERE ship_id = @atlantic_explorer_id AND status = 'in_progress' LIMIT 1);
SET @future_schedule1 = (SELECT schedule_id FROM schedules WHERE ship_id = @pacific_voyager_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);
SET @future_schedule2 = (SELECT schedule_id FROM schedules WHERE ship_id = @north_sea_carrier_id AND status = 'scheduled' LIMIT 1);
SET @future_schedule3 = (SELECT schedule_id FROM schedules WHERE ship_id = @mediterranean_queen_id AND status = 'scheduled' LIMIT 1);
SET @future_schedule4 = (SELECT schedule_id FROM schedules WHERE ship_id = @asian_star_id AND status = 'scheduled' LIMIT 1);

-- -------------------------
-- STEP 7: CREATE DIRECT BOOKINGS
-- -------------------------

-- Completed bookings
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, notes) VALUES
(@tom_cargo3_id, @completed_schedule1, @tom_id, 'completed', 'paid', 20000.00, 'Shipment delivered successfully'),
(@sarah_cargo2_id, @completed_schedule2, @sarah_id, 'completed', 'paid', 8960.00, 'Shipment arrived on time');

-- In progress bookings
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, notes) VALUES
(@tom_cargo2_id, @in_progress_schedule1, @tom_id, 'confirmed', 'paid', 37200.00, 'Currently in transit'),
(@sarah_cargo5_id, @in_progress_schedule2, @sarah_id, 'confirmed', 'paid', 4500.00, 'Currently in transit');

-- Future confirmed bookings
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, notes) VALUES
(@tom_cargo1_id, @future_schedule1, @tom_id, 'confirmed', 'paid', 16000.00, 'Scheduled for upcoming voyage'),
(@sarah_cargo4_id, @future_schedule3, @sarah_id, 'confirmed', 'paid', 14300.00, 'Scheduled for upcoming voyage');

-- Pending bookings
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, notes) VALUES
(@tom_cargo4_id, @future_schedule2, @tom_id, 'pending', 'unpaid', 71250.00, 'Awaiting payment confirmation'),
(@sarah_cargo3_id, @future_schedule4, @sarah_id, 'pending', 'unpaid', 39000.00, 'Awaiting documentation');

-- Cancelled bookings
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, notes) VALUES
(@sarah_cargo1_id, @cancelled_schedule, @sarah_id, 'cancelled', 'refunded', 9975.00, 'Cancelled due to schedule changes');

-- -------------------------
-- STEP 8: CREATE CONNECTED BOOKINGS (MULTI-SEGMENT)
-- -------------------------

-- Completed connected booking for Tom
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, notes) VALUES
(@tom_cargo3_id, @tom_id, @vancouver_id, @mumbai_id, 'completed', 'paid', 30800.00, 'Multi-segment shipment completed successfully');

-- Add segments for the completed connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(LAST_INSERT_ID(), @completed_schedule2, 1, 16000.00),
(LAST_INSERT_ID(), @completed_schedule4, 2, 14800.00);

-- In progress connected booking for Sarah
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, notes) VALUES
(@sarah_cargo5_id, @sarah_id, @hamburg_id, @rio_id, 'confirmed', 'paid', 35600.00, 'Multi-segment shipment currently in transit');

SET @last_connected_booking = LAST_INSERT_ID();

-- Add segments for the in progress connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@last_connected_booking, @in_progress_schedule2, 1, 12500.00),
(@last_connected_booking, @future_schedule4, 2, 23100.00);

-- Future confirmed connected booking for Tom
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, notes) VALUES
(@tom_cargo1_id, @tom_id, @hamburg_id, @alexandria_id, 'confirmed', 'paid', 42000.00, 'Multi-segment shipment scheduled');

SET @last_connected_booking = LAST_INSERT_ID();

-- Add segments for the future connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@last_connected_booking, @future_schedule1, 1, 18600.00),
(@last_connected_booking, @future_schedule2, 2, 23400.00);

-- Pending connected booking for Sarah
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, notes) VALUES
(@sarah_cargo3_id, @sarah_id, @rio_id, @hamburg_id, 'pending', 'unpaid', 38250.00, 'Multi-segment shipment pending confirmation');

SET @last_connected_booking = LAST_INSERT_ID();

-- Add segments for the pending connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@last_connected_booking, @future_schedule3, 1, 16500.00),
(@last_connected_booking, @future_schedule4, 2, 21750.00);

-- Cancelled connected booking for Tom
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, notes) VALUES
(@tom_cargo4_id, @tom_id, @tokyo_id, @alexandria_id, 'cancelled', 'refunded', 27000.00, 'Cancelled due to cargo specification changes');

SET @last_connected_booking = LAST_INSERT_ID();

-- Add segments for the cancelled connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@last_connected_booking, @completed_schedule3, 1, 13750.00),
(@last_connected_booking, @cancelled_schedule, 2, 13250.00);

-- -------------------------
-- STEP 9: UPDATE CARGO STATUSES
-- -------------------------

-- Update cargo status for completed bookings
UPDATE cargo SET status = 'delivered' WHERE cargo_id IN (
    SELECT cargo_id FROM cargo_bookings WHERE booking_status = 'completed'
    UNION
    SELECT cargo_id FROM connected_bookings WHERE booking_status = 'completed'
);

-- Update cargo status for in-transit bookings
UPDATE cargo SET status = 'in_transit' WHERE cargo_id IN (
    SELECT cargo_id FROM cargo_bookings 
    WHERE booking_status = 'confirmed' 
    AND schedule_id IN (SELECT schedule_id FROM schedules WHERE status = 'in_progress')
    UNION
    SELECT cb.cargo_id FROM connected_bookings cb
    JOIN connected_booking_segments cbs ON cb.connected_booking_id = cbs.connected_booking_id
    JOIN schedules s ON cbs.schedule_id = s.schedule_id
    WHERE cb.booking_status = 'confirmed' AND s.status = 'in_progress'
);

-- Update cargo status for confirmed future bookings
UPDATE cargo SET status = 'booked' WHERE cargo_id IN (
    SELECT cargo_id FROM cargo_bookings 
    WHERE booking_status = 'confirmed' 
    AND schedule_id IN (SELECT schedule_id FROM schedules WHERE status = 'scheduled')
    UNION
    SELECT cb.cargo_id FROM connected_bookings cb
    JOIN connected_booking_segments cbs ON cb.connected_booking_id = cbs.connected_booking_id
    JOIN schedules s ON cbs.schedule_id = s.schedule_id
    WHERE cb.booking_status = 'confirmed' AND s.status = 'scheduled'
);

-- Reset to pending for other statuses (pending, cancelled)
UPDATE cargo SET status = 'pending' WHERE cargo_id IN (
    SELECT cargo_id FROM cargo_bookings WHERE booking_status IN ('pending', 'cancelled')
    UNION
    SELECT cargo_id FROM connected_bookings WHERE booking_status IN ('pending', 'cancelled')
);

-- -------------------------
-- VERIFICATION QUERIES
-- -------------------------

-- Uncomment to verify data was loaded correctly
-- SELECT 'Users' AS entity, COUNT(*) AS count FROM users WHERE user_id > 7;
-- SELECT 'Ports' AS entity, COUNT(*) AS count FROM ports;
-- SELECT 'Ships' AS entity, COUNT(*) AS count FROM ships;
-- SELECT 'Routes' AS entity, COUNT(*) AS count FROM routes;
-- SELECT 'Schedules' AS entity, COUNT(*) AS count FROM schedules;
-- SELECT 'Cargo' AS entity, COUNT(*) AS count, 
--        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending,
--        SUM(CASE WHEN status = 'booked' THEN 1 ELSE 0 END) AS booked,
--        SUM(CASE WHEN status = 'in_transit' THEN 1 ELSE 0 END) AS in_transit,
--        SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) AS delivered
-- FROM cargo;
-- SELECT 'Direct Bookings' AS entity, COUNT(*) AS count FROM cargo_bookings;
-- SELECT 'Connected Bookings' AS entity, COUNT(*) AS count FROM connected_bookings;
-- SELECT 'Connected Booking Segments' AS entity, COUNT(*) AS count FROM connected_booking_segments;

select * from schedules;