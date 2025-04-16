-- =======================================================
-- ADD NEW SHIPOWNER WITH ROUTES AND SCHEDULES
-- =======================================================

-- -------------------------
-- STEP 1: CREATE NEW SHIPOWNER
-- -------------------------

-- Add new shipowner user
INSERT INTO users (username, first_name, last_name, phone_number, email, password) VALUES
('robertocargo', 'Roberto', 'Mendez', '+11234567894', 'shipowner3@globalcargo.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO');

-- Get the user ID for reference
SET @roberto_id = (SELECT user_id FROM users WHERE username = 'robertocargo');

-- Assign shipowner role
INSERT INTO user_roles (user_id, role_id) VALUES
(@roberto_id, 5); -- robertocargo - shipowner

-- -------------------------
-- STEP 2: ADD SHIPS FOR NEW OWNER
-- -------------------------

-- Get port IDs for reference
SET @hamburg_id = (SELECT port_id FROM ports WHERE name = 'Port of Hamburg');
SET @barcelona_id = (SELECT port_id FROM ports WHERE name = 'Port of Barcelona');
SET @melbourne_id = (SELECT port_id FROM ports WHERE name = 'Port of Melbourne');
SET @busan_id = (SELECT port_id FROM ports WHERE name = 'Port of Busan');

-- Add ships for Roberto (shipowner 3)
INSERT INTO ships (name, ship_type, capacity, current_port_id, imo_number, flag, year_built, status, owner_id) VALUES
('Global Voyager', 'container', 95000.00, @hamburg_id, 'IMO9825007', 'Liberia', 2022, 'active', @roberto_id),
('Oceanic Trader', 'bulk', 78000.00, @barcelona_id, 'IMO9762008', 'Panama', 2021, 'active', @roberto_id),
('Southern Star', 'container', 88000.00, @melbourne_id, 'IMO9644009', 'Australia', 2020, 'active', @roberto_id),
('Eastern Wind', 'roro', 55000.00, @busan_id, 'IMO9531010', 'South Korea', 2019, 'active', @roberto_id);

-- Store ship IDs for later reference
SET @global_voyager_id = (SELECT ship_id FROM ships WHERE name = 'Global Voyager');
SET @oceanic_trader_id = (SELECT ship_id FROM ships WHERE name = 'Oceanic Trader');
SET @southern_star_id = (SELECT ship_id FROM ships WHERE name = 'Southern Star');
SET @eastern_wind_id = (SELECT ship_id FROM ships WHERE name = 'Eastern Wind');

-- -------------------------
-- STEP 3: CREATE ROUTES FOR NEW OWNER
-- -------------------------

-- Get additional port IDs
SET @vancouver_id = (SELECT port_id FROM ports WHERE name = 'Port of Vancouver');
SET @mumbai_id = (SELECT port_id FROM ports WHERE name = 'Port of Mumbai');
SET @tokyo_id = (SELECT port_id FROM ports WHERE name = 'Port of Tokyo');
SET @rio_id = (SELECT port_id FROM ports WHERE name = 'Port of Rio de Janeiro');
SET @marseille_id = (SELECT port_id FROM ports WHERE name = 'Port of Marseille');
SET @alexandria_id = (SELECT port_id FROM ports WHERE name = 'Port of Alexandria');

-- Routes for Roberto (shipowner 3)
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Hamburg-Barcelona Express', @hamburg_id, @barcelona_id, 2200.00, 7.00, 'active', @roberto_id, @global_voyager_id, 2.35),
('Barcelona-Alexandria Link', @barcelona_id, @alexandria_id, 2800.00, 8.50, 'active', @roberto_id, @global_voyager_id, 2.40),
('Melbourne-Busan Connection', @melbourne_id, @busan_id, 8300.00, 22.00, 'active', @roberto_id, @southern_star_id, 3.60),
('Busan-Tokyo Express', @busan_id, @tokyo_id, 1050.00, 3.50, 'active', @roberto_id, @eastern_wind_id, 1.95),
('Vancouver-Rio Route', @vancouver_id, @rio_id, 12500.00, 32.00, 'active', @roberto_id, @oceanic_trader_id, 4.10),
('Rio-Marseille Connection', @rio_id, @marseille_id, 9200.00, 26.00, 'active', @roberto_id, @oceanic_trader_id, 3.85),
('Tokyo-Mumbai Route', @tokyo_id, @mumbai_id, 7600.00, 20.00, 'active', @roberto_id, @eastern_wind_id, 3.50),
('Mumbai-Melbourne Link', @mumbai_id, @melbourne_id, 7900.00, 21.00, 'active', @roberto_id, @southern_star_id, 3.70);

INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Hamburg-Alexandria Express', @hamburg_id, @alexandria_id, 2200.00, 7.00, 'active', @roberto_id, @global_voyager_id, 2.35),

-- Store route IDs for later reference
SET @hamburg_barcelona_id = (SELECT route_id FROM routes WHERE name = 'Hamburg-Barcelona Express');
SET @barcelona_alexandria_id = (SELECT route_id FROM routes WHERE name = 'Barcelona-Alexandria Link');
SET @melbourne_busan_id = (SELECT route_id FROM routes WHERE name = 'Melbourne-Busan Connection');
SET @busan_tokyo_id = (SELECT route_id FROM routes WHERE name = 'Busan-Tokyo Express');
SET @vancouver_rio_id = (SELECT route_id FROM routes WHERE name = 'Vancouver-Rio Route');
SET @rio_marseille_id = (SELECT route_id FROM routes WHERE name = 'Rio-Marseille Connection');
SET @tokyo_mumbai_id = (SELECT route_id FROM routes WHERE name = 'Tokyo-Mumbai Route');
SET @mumbai_melbourne_id = (SELECT route_id FROM routes WHERE name = 'Mumbai-Melbourne Link');

-- -------------------------
-- STEP 4: CREATE SCHEDULES FOR NEW ROUTES
-- -------------------------

-- Past schedules (completed)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@global_voyager_id, @hamburg_barcelona_id, '2023-05-10 09:00:00', '2023-05-17 16:00:00', '2023-05-10 09:15:00', '2023-05-17 15:45:00', 'completed', 90000.00, 'Completed ahead of schedule'),
(@oceanic_trader_id, @vancouver_rio_id, '2023-06-05 08:00:00', '2023-07-07 14:00:00', '2023-06-05 08:30:00', '2023-07-07 15:00:00', 'completed', 75000.00, 'Weather delays in South Pacific'),
(@southern_star_id, @melbourne_busan_id, '2023-04-12 07:30:00', '2023-05-04 15:30:00', '2023-04-12 08:00:00', '2023-05-04 14:30:00', 'completed', 85000.00, 'Smooth voyage with good weather'),
(@eastern_wind_id, @busan_tokyo_id, '2023-07-20 06:00:00', '2023-07-23 18:00:00', '2023-07-20 06:15:00', '2023-07-23 17:30:00', 'completed', 50000.00, 'Quick turnaround delivery');

-- Current schedules (in progress)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@global_voyager_id, @barcelona_alexandria_id, CURRENT_DATE() - INTERVAL 4 DAY, CURRENT_DATE() + INTERVAL 4 DAY, CURRENT_DATE() - INTERVAL 4 DAY, NULL, 'in_progress', 90000.00, 'Smooth sailing through Mediterranean'),
(@eastern_wind_id, @tokyo_mumbai_id, CURRENT_DATE() - INTERVAL 12 DAY, CURRENT_DATE() + INTERVAL 8 DAY, CURRENT_DATE() - INTERVAL 12 DAY, NULL, 'in_progress', 50000.00, 'Currently in the South China Sea');

-- Near future schedules (departing soon)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@oceanic_trader_id, @rio_marseille_id, CURRENT_DATE() + INTERVAL 3 DAY, CURRENT_DATE() + INTERVAL 29 DAY, NULL, NULL, 'scheduled', 75000.00, 'Boarding cargo now'),
(@southern_star_id, @mumbai_melbourne_id, CURRENT_DATE() + INTERVAL 5 DAY, CURRENT_DATE() + INTERVAL 26 DAY, NULL, NULL, 'scheduled', 85000.00, 'Final preparations underway');

-- Mid-term future schedules
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@global_voyager_id, @hamburg_barcelona_id, CURRENT_DATE() + INTERVAL 14 DAY, CURRENT_DATE() + INTERVAL 21 DAY, NULL, NULL, 'scheduled', 90000.00, 'Regular service route'),
(@eastern_wind_id, @busan_tokyo_id, CURRENT_DATE() + INTERVAL 22 DAY, CURRENT_DATE() + INTERVAL 25 DAY, NULL, NULL, 'scheduled', 52000.00, 'Express cargo service');

-- Long-term future schedules
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@oceanic_trader_id, @vancouver_rio_id, CURRENT_DATE() + INTERVAL 40 DAY, CURRENT_DATE() + INTERVAL 72 DAY, NULL, NULL, 'scheduled', 75000.00, 'Pre-holiday shipping'),
(@southern_star_id, @melbourne_busan_id, CURRENT_DATE() + INTERVAL 45 DAY, CURRENT_DATE() + INTERVAL 67 DAY, NULL, NULL, 'scheduled', 85000.00, 'Year-end cargo service'),
(@global_voyager_id, @barcelona_alexandria_id, CURRENT_DATE() + INTERVAL 30 DAY, CURRENT_DATE() + INTERVAL 38 DAY, NULL, NULL, 'scheduled', 90000.00, 'Premium express service'),
(@eastern_wind_id, @tokyo_mumbai_id, CURRENT_DATE() + INTERVAL 35 DAY, CURRENT_DATE() + INTERVAL 55 DAY, NULL, NULL, 'scheduled', 50000.00, 'Standard cargo route');

-- Store schedule IDs for later reference
SET @completed_schedule_hb = (SELECT schedule_id FROM schedules WHERE ship_id = @global_voyager_id AND route_id = @hamburg_barcelona_id AND status = 'completed' LIMIT 1);
SET @completed_schedule_vr = (SELECT schedule_id FROM schedules WHERE ship_id = @oceanic_trader_id AND route_id = @vancouver_rio_id AND status = 'completed' LIMIT 1);
SET @completed_schedule_mb = (SELECT schedule_id FROM schedules WHERE ship_id = @southern_star_id AND route_id = @melbourne_busan_id AND status = 'completed' LIMIT 1);
SET @completed_schedule_bt = (SELECT schedule_id FROM schedules WHERE ship_id = @eastern_wind_id AND route_id = @busan_tokyo_id AND status = 'completed' LIMIT 1);

SET @in_progress_schedule_ba = (SELECT schedule_id FROM schedules WHERE ship_id = @global_voyager_id AND route_id = @barcelona_alexandria_id AND status = 'in_progress' LIMIT 1);
SET @in_progress_schedule_tm = (SELECT schedule_id FROM schedules WHERE ship_id = @eastern_wind_id AND route_id = @tokyo_mumbai_id AND status = 'in_progress' LIMIT 1);

SET @near_future_schedule_rm = (SELECT schedule_id FROM schedules WHERE ship_id = @oceanic_trader_id AND route_id = @rio_marseille_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);
SET @near_future_schedule_mm = (SELECT schedule_id FROM schedules WHERE ship_id = @southern_star_id AND route_id = @mumbai_melbourne_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);

SET @midterm_schedule_hb = (SELECT schedule_id FROM schedules WHERE ship_id = @global_voyager_id AND route_id = @hamburg_barcelona_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);
SET @midterm_schedule_bt = (SELECT schedule_id FROM schedules WHERE ship_id = @eastern_wind_id AND route_id = @busan_tokyo_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);

-- -------------------------
-- STEP 5: CREATE CUSTOMER CARGO AND BOOKINGS
-- -------------------------

-- Get customer IDs
SET @tom_id = (SELECT user_id FROM users WHERE username = 'tomsmith');
SET @sarah_id = (SELECT user_id FROM users WHERE username = 'sarahlee');

-- Add new cargo for existing customers
INSERT INTO cargo (user_id, description, cargo_type, weight, dimensions, special_instructions, status) VALUES
(@tom_id, 'Electronics', 'container', 6800.00, '40x8x8.5', 'Sensitive equipment, handle with care', 'pending'),
(@tom_id, 'Textile Machinery', 'container', 15000.00, '40x8x8.5', 'Heavy machinery requiring special handling', 'pending'),
(@sarah_id, 'Wine Collection', 'container', 4200.00, '20x8x8.5', 'Climate controlled, keep between 10-15°C', 'pending'),
(@sarah_id, 'Solar Panels', 'container', 8500.00, '40x8x8.5', 'Fragile items, protect from impacts', 'pending');

-- Store cargo IDs for reference
SET @tom_electronics_id = (SELECT cargo_id FROM cargo WHERE user_id = @tom_id AND description = 'Electronics');
SET @tom_textile_id = (SELECT cargo_id FROM cargo WHERE user_id = @tom_id AND description = 'Textile Machinery');
SET @sarah_wine_id = (SELECT cargo_id FROM cargo WHERE user_id = @sarah_id AND description = 'Wine Collection');
SET @sarah_solar_id = (SELECT cargo_id FROM cargo WHERE user_id = @sarah_id AND description = 'Solar Panels');

-- -------------------------
-- STEP 6: CREATE DIRECT BOOKINGS
-- -------------------------

-- Completed direct bookings
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, notes) VALUES
(@tom_electronics_id, @completed_schedule_bt, @tom_id, 'completed', 'paid', 13260.00, 'Delivered to customer warehouse');

-- In progress direct bookings
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, notes) VALUES
(@sarah_wine_id, @in_progress_schedule_ba, @sarah_id, 'confirmed', 'paid', 10080.00, 'Currently in transit, specialized temperature monitoring active');

-- Future confirmed direct bookings
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, notes) VALUES
(@tom_textile_id, @near_future_schedule_rm, @tom_id, 'confirmed', 'paid', 57750.00, 'Scheduled for upcoming voyage, special equipment arranged for loading');

-- -------------------------
-- STEP 7: CREATE CONNECTED BOOKINGS (MULTI-SEGMENT)
-- -------------------------

-- Create connected booking - Hamburg to Alexandria (Global Voyager)
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, notes) VALUES
(@sarah_solar_id, @sarah_id, @hamburg_id, @alexandria_id, 'confirmed', 'paid', 40375.00, 'Multi-segment shipment for solar equipment');

SET @connected_booking_solar = LAST_INSERT_ID();

-- Add segments for connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@connected_booking_solar, @midterm_schedule_hb, 1, 15987.50),
(@connected_booking_solar, @near_future_schedule_mm, 2, 24387.50);

-- Create another complex connected booking - Tokyo to Melbourne via Mumbai
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, notes) VALUES
(@tom_electronics_id, @tom_id, @tokyo_id, @melbourne_id, 'pending', 'unpaid', 48280.00, 'Multi-segment electronics shipment awaiting final documentation');

SET @connected_booking_electronics = LAST_INSERT_ID();

-- Add segments for connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@connected_booking_electronics, @in_progress_schedule_tm, 1, 23800.00),
(@connected_booking_electronics, @near_future_schedule_mm, 2, 24480.00);

-- -------------------------
-- STEP 8: UPDATE CARGO STATUSES
-- -------------------------

-- Update cargo status for completed bookings
UPDATE cargo SET status = 'delivered' WHERE cargo_id IN (
    SELECT cargo_id FROM cargo_bookings WHERE booking_status = 'completed'
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


INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@global_voyager_id, @hamburg_barcelona_id, '2023-05-10 09:00:00', '2023-05-17 16:00:00', '2023-05-10 09:15:00', '2023-05-17 15:45:00', 'completed', 90000.00, 'Completed ahead of schedule'),
(@oceanic_trader_id, @vancouver_rio_id, '2023-06-05 08:00:00', '2023-07-07 14:00:00', '2023-06-05 08:30:00', '2023-07-07 15:00:00', 'completed', 75000.00, 'Weather delays in South Pacific'),
(@southern_star_id, @melbourne_busan_id, '2023-04-12 07:30:00', '2023-05-04 15:30:00', '2023-04-12 08:00:00', '2023-05-04 14:30:00', 'completed', 85000.00, 'Smooth voyage with good weather'),
(@eastern_wind_id, @busan_tokyo_id, '2023-07-20 06:00:00', '2023-07-23 18:00:00', '2023-07-20 06:15:00', '2023-07-23 17:30:00', 'completed', 50000.00, 'Quick turnaround delivery');


-- -------------------------
-- VERIFICATION QUERIES
-- -------------------------

-- Uncomment to verify new data was loaded correctly
-- SELECT 'New Ships' AS entity, COUNT(*) AS count FROM ships WHERE owner_id = @roberto_id;
-- SELECT 'New Routes' AS entity, COUNT(*) AS count FROM routes WHERE owner_id = @roberto_id;
-- SELECT 'New Schedules' AS entity, COUNT(*) AS count FROM schedules 
--   WHERE ship_id IN (SELECT ship_id FROM ships WHERE owner_id = @roberto_id);
-- SELECT 'Connected Bookings Created' AS entity, COUNT(*) AS count FROM connected_bookings
--   WHERE connected_booking_id >= @connected_booking_solar;

select * from berth_assignments;

-- Step 1: Declare OUT parameters
SET @p_schedule_id = NULL;
SET @p_success = FALSE;
SET @p_message = '';

-- Step 2: Call the procedure with test input values
CALL create_schedule_with_berths(
    67,                             -- p_ship_id
    61,                             -- p_route_id
    10000.00,                      -- p_max_cargo
    'scheduled',                  -- p_status
    'Test voyage schedule',       -- p_notes
    '2025-04-20 08:00:00',         -- p_departure_date
    '2025-04-25 20:00:00',         -- p_arrival_date
    17,                             -- p_origin_berth_id
    '2025-04-20 06:00:00',         -- p_origin_berth_start
    '2025-04-20 08:00:00',         -- p_origin_berth_end
    18,                             -- p_destination_berth_id
    '2025-04-25 18:00:00',         -- p_destination_berth_start
    '2025-04-25 20:00:00',         -- p_destination_berth_end
    @p_schedule_id,                -- OUT
    @p_success,                    -- OUT
    @p_message                     -- OUT
);

-- Step 3: Retrieve the OUT results
SELECT 
    @p_schedule_id AS schedule_id,
    @p_success AS success,
    @p_message AS message;


delete from berth_assignments where true;
delete from schedules where true;


select * from schedules;
select * from berth_assignments;

select * from schedules;

