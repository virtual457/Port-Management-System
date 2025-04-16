-- =======================================================
-- DIRECT VS CONNECTED ROUTES WITH PRICE COMPARISON
-- =======================================================

-- -------------------------
-- STEP 1: SELECT PORTS FOR THE ROUTE
-- -------------------------

-- Get the port IDs for reference (Hamburg to Tokyo route)
SET @origin_port_id = (SELECT port_id FROM ports WHERE name = 'Port of Hamburg');
SET @destination_port_id = (SELECT port_id FROM ports WHERE name = 'Port of Tokyo');
SET @intermediate_port_id = (SELECT port_id FROM ports WHERE name = 'Port of Mumbai');

-- Get shipowner IDs
SET @james_id = (SELECT user_id FROM users WHERE username = 'jamesship');
SET @marina_id = (SELECT user_id FROM users WHERE username = 'marinafleet');

-- Get select ship IDs
SET @atlantic_explorer_id = (SELECT ship_id FROM ships WHERE name = 'Atlantic Explorer');
SET @mediterranean_queen_id = (SELECT ship_id FROM ships WHERE name = 'Mediterranean Queen');
SET @asian_star_id = (SELECT ship_id FROM ships WHERE name = 'Asian Star');

-- -------------------------
-- STEP 2: CREATE DIRECT ROUTE (Hamburg to Tokyo)
-- -------------------------

-- Create direct route
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Hamburg-Tokyo Direct', @origin_port_id, @destination_port_id, 11600.00, 35.00, 'active', @james_id, @atlantic_explorer_id, 5.20);

-- Store route ID
SET @direct_route_id = LAST_INSERT_ID();

-- -------------------------
-- STEP 3: CREATE CONNECTED ROUTE SEGMENTS
-- -------------------------

-- First segment: Hamburg to Mumbai
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Hamburg-Mumbai Segment', @origin_port_id, @intermediate_port_id, 7200.00, 21.00, 'active', @james_id, @atlantic_explorer_id, 3.10);

-- Store first segment route ID
SET @segment1_route_id = LAST_INSERT_ID();

-- Second segment: Mumbai to Tokyo
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Mumbai-Tokyo Segment', @intermediate_port_id, @destination_port_id, 6800.00, 19.00, 'active', @marina_id, @asian_star_id, 2.90);

-- Store second segment route ID
SET @segment2_route_id = LAST_INSERT_ID();

-- -------------------------
-- STEP 4: CREATE SCHEDULES FOR DIRECT ROUTE
-- -------------------------

-- Past completed schedule
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@atlantic_explorer_id, @direct_route_id, '2023-01-05 08:00:00', '2023-02-09 14:00:00', '2023-01-05 08:30:00', '2023-02-09 15:00:00', 'completed', 80000.00, 'Successful first direct journey on this route');

-- Current schedule (in progress)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@atlantic_explorer_id, @direct_route_id, CURRENT_DATE() - INTERVAL 20 DAY, CURRENT_DATE() + INTERVAL 15 DAY, CURRENT_DATE() - INTERVAL 20 DAY, NULL, 'in_progress', 80000.00, 'Currently crossing the Indian Ocean');

-- Near future schedule
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@atlantic_explorer_id, @direct_route_id, CURRENT_DATE() + INTERVAL 20 DAY, CURRENT_DATE() + INTERVAL 55 DAY, NULL, NULL, 'scheduled', 80000.00, 'Accepting bookings, cargo consolidation in progress');

-- Far future schedule
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@atlantic_explorer_id, @direct_route_id, CURRENT_DATE() + INTERVAL 60 DAY, CURRENT_DATE() + INTERVAL 95 DAY, NULL, NULL, 'scheduled', 80000.00, 'Early booking available with discount');

-- Store schedule IDs
SET @direct_past_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @direct_route_id AND status = 'completed' LIMIT 1);
SET @direct_current_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @direct_route_id AND status = 'in_progress' LIMIT 1);
SET @direct_near_future_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @direct_route_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);
SET @direct_far_future_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @direct_route_id AND status = 'scheduled' ORDER BY departure_date DESC LIMIT 1);

-- -------------------------
-- STEP 5: CREATE SCHEDULES FOR CONNECTED ROUTE SEGMENTS
-- -------------------------

-- SEGMENT 1: Hamburg to Mumbai

-- Past completed schedule (segment 1)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@atlantic_explorer_id, @segment1_route_id, '2023-01-10 09:00:00', '2023-01-31 15:00:00', '2023-01-10 09:15:00', '2023-01-31 14:30:00', 'completed', 80000.00, 'Smooth journey with good weather');

-- Near future schedules (segment 1)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@atlantic_explorer_id, @segment1_route_id, CURRENT_DATE() + INTERVAL 10 DAY, CURRENT_DATE() + INTERVAL 31 DAY, NULL, NULL, 'scheduled', 80000.00, 'Regular service with competitive rates'),
(@atlantic_explorer_id, @segment1_route_id, CURRENT_DATE() + INTERVAL 45 DAY, CURRENT_DATE() + INTERVAL 66 DAY, NULL, NULL, 'scheduled', 80000.00, 'High season service with additional capacity');

-- Store segment 1 schedule IDs
SET @segment1_past_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @segment1_route_id AND status = 'completed' LIMIT 1);
SET @segment1_near_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @segment1_route_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);
SET @segment1_far_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @segment1_route_id AND status = 'scheduled' ORDER BY departure_date DESC LIMIT 1);

-- SEGMENT 2: Mumbai to Tokyo

-- Past completed schedule (segment 2)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@asian_star_id, @segment2_route_id, '2023-02-03 10:00:00', '2023-02-22 16:00:00', '2023-02-03 10:30:00', '2023-02-22 15:45:00', 'completed', 75000.00, 'Efficient delivery with optimized routing');

-- Current in-progress schedule (segment 2)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@asian_star_id, @segment2_route_id, CURRENT_DATE() - INTERVAL 10 DAY, CURRENT_DATE() + INTERVAL 9 DAY, CURRENT_DATE() - INTERVAL 10 DAY, NULL, 'in_progress', 75000.00, 'Currently sailing through South China Sea');

-- Near future schedules (segment 2)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@asian_star_id, @segment2_route_id, CURRENT_DATE() + INTERVAL 32 DAY, CURRENT_DATE() + INTERVAL 51 DAY, NULL, NULL, 'scheduled', 75000.00, 'Synchronized with Hamburg-Mumbai service'),
(@asian_star_id, @segment2_route_id, CURRENT_DATE() + INTERVAL 67 DAY, CURRENT_DATE() + INTERVAL 86 DAY, NULL, NULL, 'scheduled', 75000.00, 'Peak season additional service');

-- Store segment 2 schedule IDs
SET @segment2_past_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @segment2_route_id AND status = 'completed' LIMIT 1);
SET @segment2_current_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @segment2_route_id AND status = 'in_progress' LIMIT 1);
SET @segment2_near_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @segment2_route_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);
SET @segment2_far_schedule_id = (SELECT schedule_id FROM schedules WHERE route_id = @segment2_route_id AND status = 'scheduled' ORDER BY departure_date DESC LIMIT 1);

-- -------------------------
-- STEP 6: ADD CUSTOMER CARGO FOR TESTING
-- -------------------------

-- Get customer IDs
SET @tom_id = (SELECT user_id FROM users WHERE username = 'tomsmith');
SET @sarah_id = (SELECT user_id FROM users WHERE username = 'sarahlee');

-- Add new cargo for route testing
INSERT INTO cargo (user_id, description, cargo_type, weight, dimensions, special_instructions, status) VALUES
(@tom_id, 'Industrial Machinery', 'container', 12000.00, '40x8x8.5', 'Heavy equipment requiring crane for loading/unloading', 'pending'),
(@sarah_id, 'Precision Instruments', 'container', 5800.00, '20x8x8.5', 'Sensitive to vibration and temperature variations', 'pending');

-- Store cargo IDs
SET @tom_machinery_id = (SELECT cargo_id FROM cargo WHERE user_id = @tom_id AND description = 'Industrial Machinery');
SET @sarah_instruments_id = (SELECT cargo_id FROM cargo WHERE user_id = @sarah_id AND description = 'Precision Instruments');

-- -------------------------
-- STEP 7: CREATE BOOKINGS FOR PRICE COMPARISON
-- -------------------------

-- Direct route booking (Tom's machinery)
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, notes) VALUES
(@tom_machinery_id, @direct_near_future_schedule_id, @tom_id, 'confirmed', 'paid', 62400.00, 'Direct route booking (12000 kg x $5.20)');

-- Connected route bookings (Sarah's instruments) - First segment
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, notes) VALUES
(@sarah_instruments_id, @sarah_id, @origin_port_id, @destination_port_id, 'confirmed', 'paid', 34800.00, 'Connected route booking - Total: $34,800 (Segment 1: $17,980 + Segment 2: $16,820)');

SET @connected_booking_id = LAST_INSERT_ID();

-- Add segments for connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@connected_booking_id, @segment1_near_schedule_id, 1, 17980.00), -- 5800 kg x $3.10 = $17,980
(@connected_booking_id, @segment2_near_schedule_id, 2, 16820.00); -- 5800 kg x $2.90 = $16,820

select * from users;

select * from roles;

select * from user_roles where user_id = 1;