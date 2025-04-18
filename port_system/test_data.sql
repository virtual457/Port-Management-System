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
DELETE FROM berth_assignments;
DELETE FROM berths;
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
('Port of Barcelona', 'Spain', POINT(2.1686, 41.3851), 'active'),
('Port of Shanghai', 'China', POINT(121.8947, 30.8718), 'active'),
('Port of Singapore', 'Singapore', POINT(103.8198, 1.2649), 'active'),
('Port of Rotterdam', 'Netherlands', POINT(4.4059, 51.9244), 'active'),
('Port of Dubai', 'UAE', POINT(55.2708, 25.2048), 'active'),
('Port of New York', 'USA', POINT(-74.0060, 40.7128), 'active');

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
('sarahlee', 'Sarah', 'Lee', '+11234567891', 'customer2@example.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('davidwang', 'David', 'Wang', '+11234567892', 'customer3@example.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('emilyjones', 'Emily', 'Jones', '+11234567893', 'customer4@example.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('rajpatel', 'Raj', 'Patel', '+11234567894', 'customer5@example.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO');

-- Add shipowner users
INSERT INTO users (username, first_name, last_name, phone_number, email, password) VALUES
('jamesship', 'James', 'Carter', '+11234567895', 'shipowner1@shipping.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('marinafleet', 'Marina', 'Rodriguez', '+11234567896', 'shipowner2@fleetmanagement.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('robertships', 'Robert', 'Chen', '+11234567897', 'shipowner3@oceanfleet.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('sofiamarine', 'Sofia', 'Kowalski', '+11234567898', 'shipowner4@marinecorp.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO'),
('liamvessel', 'Liam', 'Garcia', '+11234567899', 'shipowner5@vesselops.com', '$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO');

-- Get the user IDs for reference
SET @tom_id = (SELECT user_id FROM users WHERE username = 'tomsmith');
SET @sarah_id = (SELECT user_id FROM users WHERE username = 'sarahlee');
SET @david_id = (SELECT user_id FROM users WHERE username = 'davidwang');
SET @emily_id = (SELECT user_id FROM users WHERE username = 'emilyjones');
SET @raj_id = (SELECT user_id FROM users WHERE username = 'rajpatel');

SET @james_id = (SELECT user_id FROM users WHERE username = 'jamesship');
SET @marina_id = (SELECT user_id FROM users WHERE username = 'marinafleet');
SET @robert_id = (SELECT user_id FROM users WHERE username = 'robertships');
SET @sofia_id = (SELECT user_id FROM users WHERE username = 'sofiamarine');
SET @liam_id = (SELECT user_id FROM users WHERE username = 'liamvessel');

-- Assign roles to users
INSERT INTO user_roles (user_id, role_id) VALUES
(@tom_id, 4), -- tomsmith - customer
(@sarah_id, 4), -- sarahlee - customer
(@david_id, 4), -- davidwang - customer
(@emily_id, 4), -- emilyjones - customer
(@raj_id, 4), -- rajpatel - customer

(@james_id, 5), -- jamesship - shipowner
(@marina_id, 5), -- marinafleet - shipowner
(@robert_id, 5), -- robertships - shipowner
(@sofia_id, 5), -- sofiamarine - shipowner
(@liam_id, 5); -- liamvessel - shipowner

-- -------------------------
-- STEP 3: CREATE BERTHS
-- -------------------------

-- Get port IDs for reference
SET @hamburg_id = (SELECT port_id FROM ports WHERE name = 'Port of Hamburg');
SET @vancouver_id = (SELECT port_id FROM ports WHERE name = 'Port of Vancouver');
SET @mumbai_id = (SELECT port_id FROM ports WHERE name = 'Port of Mumbai');
SET @tokyo_id = (SELECT port_id FROM ports WHERE name = 'Port of Tokyo');
SET @rio_id = (SELECT port_id FROM ports WHERE name = 'Port of Rio de Janeiro');
SET @marseille_id = (SELECT port_id FROM ports WHERE name = 'Port of Marseille');
SET @alexandria_id = (SELECT port_id FROM ports WHERE name = 'Port of Alexandria');
SET @melbourne_id = (SELECT port_id FROM ports WHERE name = 'Port of Melbourne');
SET @busan_id = (SELECT port_id FROM ports WHERE name = 'Port of Busan');
SET @barcelona_id = (SELECT port_id FROM ports WHERE name = 'Port of Barcelona');
SET @shanghai_id = (SELECT port_id FROM ports WHERE name = 'Port of Shanghai');
SET @singapore_id = (SELECT port_id FROM ports WHERE name = 'Port of Singapore');
SET @rotterdam_id = (SELECT port_id FROM ports WHERE name = 'Port of Rotterdam');
SET @dubai_id = (SELECT port_id FROM ports WHERE name = 'Port of Dubai');
SET @newyork_id = (SELECT port_id FROM ports WHERE name = 'Port of New York');

-- Add berths for each active port
INSERT INTO berths (berth_number, port_id, type, length, width, depth, status) VALUES
-- Hamburg
('HAM-B001', @hamburg_id, 'container', 350.00, 45.00, 15.50, 'active'),
('HAM-B002', @hamburg_id, 'bulk', 280.00, 40.00, 14.00, 'active'),
('HAM-B003', @hamburg_id, 'tanker', 320.00, 50.00, 16.50, 'active'),
-- Vancouver
('VAN-B001', @vancouver_id, 'container', 340.00, 45.00, 15.00, 'active'),
('VAN-B002', @vancouver_id, 'bulk', 300.00, 42.00, 14.50, 'active'),
-- Mumbai
('MUM-B001', @mumbai_id, 'container', 330.00, 43.00, 14.80, 'active'),
('MUM-B002', @mumbai_id, 'bulk', 290.00, 41.00, 14.00, 'active'),
-- Tokyo
('TOK-B001', @tokyo_id, 'container', 360.00, 48.00, 16.00, 'active'),
('TOK-B002', @tokyo_id, 'tanker', 330.00, 52.00, 17.00, 'active'),
-- Rio
('RIO-B001', @rio_id, 'container', 320.00, 44.00, 15.20, 'active'),
('RIO-B002', @rio_id, 'bulk', 270.00, 38.00, 13.50, 'active'),
-- Add more berths for other ports
('MAR-B001', @marseille_id, 'container', 330.00, 45.00, 15.00, 'active'),
('ALX-B001', @alexandria_id, 'bulk', 290.00, 40.00, 14.00, 'active'),
('MEL-B001', @melbourne_id, 'container', 340.00, 46.00, 15.50, 'active'),
('BUS-B001', @busan_id, 'container', 350.00, 47.00, 16.00, 'active'),
('BAR-B001', @barcelona_id, 'container', 330.00, 45.00, 15.00, 'active'),
('SHA-B001', @shanghai_id, 'container', 380.00, 50.00, 16.50, 'active'),
('SIN-B001', @singapore_id, 'container', 370.00, 49.00, 16.20, 'active'),
('ROT-B001', @rotterdam_id, 'container', 360.00, 48.00, 16.00, 'active'),
('DUB-B001', @dubai_id, 'container', 350.00, 47.00, 15.80, 'active'),
('NYC-B001', @newyork_id, 'container', 340.00, 46.00, 15.50, 'active');

-- -------------------------
-- STEP 4: CREATE SHIPS
-- -------------------------

-- Ships for James (shipowner 1)
INSERT INTO ships (name, ship_type, capacity, current_port_id, imo_number, flag, year_built, status, owner_id) VALUES
('Atlantic Explorer', 'container', 85000.00, @hamburg_id, 'IMO9395001', 'Panama', 2015, 'active', @james_id),
('Pacific Voyager', 'bulk', 65000.00, @vancouver_id, 'IMO9412002', 'Marshall Islands', 2017, 'active', @james_id),
('North Sea Carrier', 'container', 92000.00, @mumbai_id, 'IMO9321003', 'Liberia', 2014, 'active', @james_id);

-- Ships for Marina (shipowner 2)
INSERT INTO ships (name, ship_type, capacity, current_port_id, imo_number, flag, year_built, status, owner_id) VALUES
('Mediterranean Queen', 'tanker', 105000.00, @tokyo_id, 'IMO9517004', 'Greece', 2018, 'active', @marina_id),
('Asian Star', 'container', 78000.00, @rio_id, 'IMO9632005', 'Singapore', 2016, 'active', @marina_id),
('Caribbean Princess', 'container', 45000.00, @vancouver_id, 'IMO9745006', 'United States', 2019, 'active', @marina_id);

-- Ships for Robert (shipowner 3)
INSERT INTO ships (name, ship_type, capacity, current_port_id, imo_number, flag, year_built, status, owner_id) VALUES
('Oceanic Voyager', 'container', 88000.00, @shanghai_id, 'IMO9823007', 'Hong Kong', 2017, 'active', @robert_id),
('Baltic Transporter', 'bulk', 72000.00, @rotterdam_id, 'IMO9456008', 'Denmark', 2016, 'active', @robert_id),
('Aegean Express', 'container', 65000.00, @alexandria_id, 'IMO9789009', 'Malta', 2018, 'active', @robert_id);

-- Ships for Sofia (shipowner 4)
INSERT INTO ships (name, ship_type, capacity, current_port_id, imo_number, flag, year_built, status, owner_id) VALUES
('Nordic Adventurer', 'container', 90000.00, @hamburg_id, 'IMO9567010', 'Norway', 2019, 'active', @sofia_id),
('Caspian Trader', 'tanker', 95000.00, @dubai_id, 'IMO9654011', 'Cyprus', 2015, 'active', @sofia_id),
('Adriatic Eagle', 'bulk', 68000.00, @marseille_id, 'IMO9432012', 'Italy', 2017, 'active', @sofia_id);

-- Ships for Liam (shipowner 5)
INSERT INTO ships (name, ship_type, capacity, current_port_id, imo_number, flag, year_built, status, owner_id) VALUES
('Pacific Guardian', 'container', 82000.00, @singapore_id, 'IMO9876013', 'Malaysia', 2018, 'active', @liam_id),
('Atlantic Champion', 'bulk', 75000.00, @newyork_id, 'IMO9765014', 'Bahamas', 2016, 'active', @liam_id),
('Indian Ocean Navigator', 'tanker', 98000.00, @mumbai_id, 'IMO9543015', 'India', 2017, 'active', @liam_id);

-- Store ship IDs for later reference
SET @atlantic_explorer_id = (SELECT ship_id FROM ships WHERE name = 'Atlantic Explorer');
SET @pacific_voyager_id = (SELECT ship_id FROM ships WHERE name = 'Pacific Voyager');
SET @north_sea_carrier_id = (SELECT ship_id FROM ships WHERE name = 'North Sea Carrier');
SET @mediterranean_queen_id = (SELECT ship_id FROM ships WHERE name = 'Mediterranean Queen');
SET @asian_star_id = (SELECT ship_id FROM ships WHERE name = 'Asian Star');
SET @caribbean_princess_id = (SELECT ship_id FROM ships WHERE name = 'Caribbean Princess');
SET @oceanic_voyager_id = (SELECT ship_id FROM ships WHERE name = 'Oceanic Voyager');
SET @baltic_transporter_id = (SELECT ship_id FROM ships WHERE name = 'Baltic Transporter');
SET @aegean_express_id = (SELECT ship_id FROM ships WHERE name = 'Aegean Express');
SET @nordic_adventurer_id = (SELECT ship_id FROM ships WHERE name = 'Nordic Adventurer');
SET @caspian_trader_id = (SELECT ship_id FROM ships WHERE name = 'Caspian Trader');
SET @adriatic_eagle_id = (SELECT ship_id FROM ships WHERE name = 'Adriatic Eagle');
SET @pacific_guardian_id = (SELECT ship_id FROM ships WHERE name = 'Pacific Guardian');
SET @atlantic_champion_id = (SELECT ship_id FROM ships WHERE name = 'Atlantic Champion');
SET @indian_ocean_navigator_id = (SELECT ship_id FROM ships WHERE name = 'Indian Ocean Navigator');

-- -------------------------
-- STEP 5: CREATE CARGO
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

-- Cargo for David (customer 3)
INSERT INTO cargo (user_id, description, cargo_type, weight, dimensions, special_instructions, status) VALUES
(@david_id, 'Solar Panels', 'container', 7500.00, '40×8×8.5', 'Fragile glass components. Secure stacking.', 'pending'),
(@david_id, 'Industrial Machinery', 'bulk', 22000.00, '40×10×9', 'Heavy items. Use appropriate lifting equipment.', 'pending'),
(@david_id, 'Packaged Food Products', 'container', 4200.00, '20×8×8.5', 'Keep away from moisture and heat.', 'pending'),
(@david_id, 'Textiles and Fabrics', 'container', 3100.00, '20×8×8.5', 'Protect from water damage.', 'pending'),
(@david_id, 'Construction Materials', 'bulk', 17500.00, '40×8×8.5', 'Various building supplies, non-hazardous.', 'pending');

-- Cargo for Emily (customer 4)
INSERT INTO cargo (user_id, description, cargo_type, weight, dimensions, special_instructions, status) VALUES
(@emily_id, 'Organic Produce', 'container', 4000.00, '20×8×8.5', 'Perishable goods. Temperature monitoring required.', 'pending'),
(@emily_id, 'Wind Turbine Components', 'bulk', 31000.00, '60×15×10', 'Oversized cargo. Special handling protocol.', 'pending'),
(@emily_id, 'Mineral Ores', 'bulk', 28000.00, '40×8×8.5', 'Heavy bulk material.', 'pending'),
(@emily_id, 'Artwork and Sculptures', 'container', 1200.00, '20×8×8.5', 'Extremely fragile. Expert handling only.', 'pending'),
(@emily_id, 'Chemicals (Non-hazardous)', 'liquid', 18000.00, '40×8×8.5', 'Keep away from food products.', 'pending');

-- Cargo for Raj (customer 5)
INSERT INTO cargo (user_id, description, cargo_type, weight, dimensions, special_instructions, status) VALUES
(@raj_id, 'Electronic Components', 'container', 2500.00, '20×8×8.5', 'Sensitive electronics. Avoid electromagnetic fields.', 'pending'),
(@raj_id, 'Automotive Vehicles', 'vehicle', 12000.00, '40×10×8', '5 standard sedans secured on rack.', 'pending'),
(@raj_id, 'Lumber and Timber', 'bulk', 19000.00, '40×8×8.5', 'Treated wood products. Keep dry.', 'pending'),
(@raj_id, 'Processed Metals', 'container', 26000.00, '40×8×8.5', 'Heavy steel components.', 'pending'),
(@raj_id, 'Wine Shipment', 'container', 8500.00, '20×8×8.5', 'Fragile glass bottles. Temperature controlled.', 'pending');

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

SET @david_cargo1_id = (SELECT cargo_id FROM cargo WHERE user_id = @david_id AND description = 'Solar Panels');
SET @david_cargo2_id = (SELECT cargo_id FROM cargo WHERE user_id = @david_id AND description = 'Industrial Machinery');
SET @david_cargo3_id = (SELECT cargo_id FROM cargo WHERE user_id = @david_id AND description = 'Packaged Food Products');
SET @david_cargo4_id = (SELECT cargo_id FROM cargo WHERE user_id = @david_id AND description = 'Textiles and Fabrics');
SET @david_cargo5_id = (SELECT cargo_id FROM cargo WHERE user_id = @david_id AND description = 'Construction Materials');

SET @emily_cargo1_id = (SELECT cargo_id FROM cargo WHERE user_id = @emily_id AND description = 'Organic Produce');
SET @emily_cargo2_id = (SELECT cargo_id FROM cargo WHERE user_id = @emily_id AND description = 'Wind Turbine Components');
SET @emily_cargo3_id = (SELECT cargo_id FROM cargo WHERE user_id = @emily_id AND description = 'Mineral Ores');
SET @emily_cargo4_id = (SELECT cargo_id FROM cargo WHERE user_id = @emily_id AND description = 'Artwork and Sculptures');
SET @emily_cargo5_id = (SELECT cargo_id FROM cargo WHERE user_id = @emily_id AND description = 'Chemicals (Non-hazardous)');

SET @raj_cargo1_id = (SELECT cargo_id FROM cargo WHERE user_id = @raj_id AND description = 'Electronic Components');
SET @raj_cargo2_id = (SELECT cargo_id FROM cargo WHERE user_id = @raj_id AND description = 'Automotive Vehicles');
SET @raj_cargo3_id = (SELECT cargo_id FROM cargo WHERE user_id = @raj_id AND description = 'Lumber and Timber');
SET @raj_cargo4_id = (SELECT cargo_id FROM cargo WHERE user_id = @raj_id AND description = 'Processed Metals');
SET @raj_cargo5_id = (SELECT cargo_id FROM cargo WHERE user_id = @raj_id AND description = 'Wine Shipment');

-- -------------------------
-- STEP 6: CREATE ROUTES
-- -------------------------

-- Routes for James (shipowner 1)
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Hamburg-Mumbai Express', @hamburg_id, @mumbai_id, 7500.00, 12.00, 'active', @james_id, @atlantic_explorer_id, 2.50),
('Vancouver-Tokyo Direct', @vancouver_id, @tokyo_id, 7500.00, 10.00, 'active', @james_id, @pacific_voyager_id, 3.20),
('Mumbai-Alexandria Route', @mumbai_id, @alexandria_id, 4800.00, 8.00, 'active', @james_id, @north_sea_carrier_id, 2.85);

-- Routes for Marina (shipowner 2)
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Tokyo-Rio Connection', @tokyo_id, @rio_id, 18200.00, 25.00, 'active', @marina_id, @mediterranean_queen_id, 2.75),
('Rio-Hamburg Trade Route', @rio_id, @hamburg_id, 10500.00, 16.00, 'active', @marina_id, @asian_star_id, 2.60),
('Vancouver-Marseille Trade Route', @vancouver_id, @marseille_id, 15800.00, 22.00, 'active', @marina_id, @caribbean_princess_id, 3.10);

-- Routes for Robert (shipowner 3)
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Shanghai-Singapore Express', @shanghai_id, @singapore_id, 4100.00, 6.00, 'active', @robert_id, @oceanic_voyager_id, 2.80),
('Rotterdam-Barcelona Link', @rotterdam_id, @barcelona_id, 2200.00, 4.00, 'active', @robert_id, @baltic_transporter_id, 2.20),
('Alexandria-Melbourne Route', @alexandria_id, @melbourne_id, 14200.00, 20.00, 'active', @robert_id, @aegean_express_id, 3.50);

-- Routes for Sofia (shipowner 4)
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Hamburg-Dubai Connection', @hamburg_id, @dubai_id, 11900.00, 18.00, 'active', @sofia_id, @nordic_adventurer_id, 3.15),
('Dubai-Tokyo Express', @dubai_id, @tokyo_id, 8300.00, 12.00, 'active', @sofia_id, @caspian_trader_id, 2.90),
('Marseille-Alexandria Link', @marseille_id, @alexandria_id, 2800.00, 5.00, 'active', @sofia_id, @adriatic_eagle_id, 2.10);

-- Routes for Liam (shipowner 5)
INSERT INTO routes (name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
('Singapore-Busan Express', @singapore_id, @busan_id, 4800.00, 7.00, 'active', @liam_id, @pacific_guardian_id, 2.60),
('New York-Barcelona Route', @newyork_id, @barcelona_id, 6800.00, 10.00, 'active', @liam_id, @atlantic_champion_id, 2.95),
('Mumbai-Melbourne Connection', @mumbai_id, @melbourne_id, 10200.00, 15.00, 'active', @liam_id, @indian_ocean_navigator_id, 3.30);

-- Store route IDs for later reference
SET @hamburg_mumbai_id = (SELECT route_id FROM routes WHERE name = 'Hamburg-Mumbai Express');
SET @vancouver_tokyo_id = (SELECT route_id FROM routes WHERE name = 'Vancouver-Tokyo Direct');
SET @mumbai_alexandria_id = (SELECT route_id FROM routes WHERE name = 'Mumbai-Alexandria Route');
SET @tokyo_rio_id = (SELECT route_id FROM routes WHERE name = 'Tokyo-Rio Connection');
SET @rio_hamburg_id = (SELECT route_id FROM routes WHERE name = 'Rio-Hamburg Trade Route');
SET @vancouver_marseille_id = (SELECT route_id FROM routes WHERE name = 'Vancouver-Marseille Trade Route');
SET @shanghai_singapore_id = (SELECT route_id FROM routes WHERE name = 'Shanghai-Singapore Express');
SET @rotterdam_barcelona_id = (SELECT route_id FROM routes WHERE name = 'Rotterdam-Barcelona Link');
SET @alexandria_melbourne_id = (SELECT route_id FROM routes WHERE name = 'Alexandria-Melbourne Route');
SET @hamburg_dubai_id = (SELECT route_id FROM routes WHERE name = 'Hamburg-Dubai Connection');
SET @dubai_tokyo_id = (SELECT route_id FROM routes WHERE name = 'Dubai-Tokyo Express');
SET @marseille_alexandria_id = (SELECT route_id FROM routes WHERE name = 'Marseille-Alexandria Link');
SET @singapore_busan_id = (SELECT route_id FROM routes WHERE name = 'Singapore-Busan Express');
SET @newyork_barcelona_id = (SELECT route_id FROM routes WHERE name = 'New York-Barcelona Route');
SET @mumbai_melbourne_id = (SELECT route_id FROM routes WHERE name = 'Mumbai-Melbourne Connection');

-- -------------------------
-- STEP 7: CREATE SCHEDULES
-- -------------------------

-- Define date variables for past, current, and future months
SET @past_month_start = DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH);
SET @past_month_end = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY);
SET @current_month_start = CURRENT_DATE();
SET @current_month_end = DATE_ADD(CURRENT_DATE(), INTERVAL 1 MONTH);
SET @future_month_start = DATE_ADD(CURRENT_DATE(), INTERVAL 1 MONTH);
SET @future_month_end = DATE_ADD(CURRENT_DATE(), INTERVAL 2 MONTH);

-- Completed schedules (past month)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@atlantic_explorer_id, @hamburg_mumbai_id, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 5 DAY), '%Y-%m-%d 08:00:00'),
 DATE_FORMAT(DATE_ADD(DATE_SUB(@past_month_start, INTERVAL 5 DAY), INTERVAL 12 DAY), '%Y-%m-%d 16:00:00'),
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 5 DAY), '%Y-%m-%d 08:30:00'),
 DATE_FORMAT(DATE_ADD(DATE_SUB(@past_month_start, INTERVAL 5 DAY), INTERVAL 12 DAY), '%Y-%m-%d 15:45:00'),
 'completed', 80000.00, 'Voyage completed successfully'),

(@pacific_voyager_id, @vancouver_tokyo_id, 
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 2 DAY), '%Y-%m-%d 09:00:00'),
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 2 DAY), INTERVAL 10 DAY), '%Y-%m-%d 14:00:00'),
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 2 DAY), '%Y-%m-%d 09:15:00'),
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 2 DAY), INTERVAL 10 DAY), '%Y-%m-%d 15:30:00'),
 'completed', 60000.00, 'Delay due to weather conditions'),

(@mediterranean_queen_id, @tokyo_rio_id, 
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 5 DAY), '%Y-%m-%d 07:00:00'),
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 5 DAY), INTERVAL 25 DAY), '%Y-%m-%d 15:00:00'),
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 5 DAY), '%Y-%m-%d 07:30:00'),
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 5 DAY), INTERVAL 25 DAY), '%Y-%m-%d 16:15:00'),
 'completed', 100000.00, 'Smooth sailing'),

(@oceanic_voyager_id, @shanghai_singapore_id, 
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 8 DAY), '%Y-%m-%d 08:30:00'),
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 8 DAY), INTERVAL 6 DAY), '%Y-%m-%d 16:30:00'),
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 8 DAY), '%Y-%m-%d 09:00:00'),
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 8 DAY), INTERVAL 6 DAY), '%Y-%m-%d 17:00:00'),
 'completed', 80000.00, 'Completed with minor delays'),

(@nordic_adventurer_id, @hamburg_dubai_id, 
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 12 DAY), '%Y-%m-%d 10:00:00'),
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 12 DAY), INTERVAL 18 DAY), '%Y-%m-%d 18:00:00'),
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 12 DAY), '%Y-%m-%d 10:30:00'),
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 12 DAY), INTERVAL 18 DAY), '%Y-%m-%d 18:30:00'),
 'completed', 85000.00, 'Voyage completed as scheduled');

-- Cancelled schedules (past month)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@north_sea_carrier_id, @mumbai_alexandria_id, 
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 15 DAY), '%Y-%m-%d 10:00:00'),
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 15 DAY), INTERVAL 8 DAY), '%Y-%m-%d 17:00:00'),
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 15 DAY), '%Y-%m-%d 10:45:00'),
 NULL,
 'cancelled', 90000.00, 'Cancelled due to technical issues');

-- Current schedules (in progress - current month)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@caribbean_princess_id, @vancouver_marseille_id, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 10 DAY), '%Y-%m-%d 08:00:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 12 DAY), '%Y-%m-%d 16:00:00'),
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 10 DAY), '%Y-%m-%d 08:15:00'),
 NULL,
 'in_progress', 42000.00, 'Currently in transit'),

(@asian_star_id, @rio_hamburg_id, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 8 DAY), '%Y-%m-%d 09:00:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 8 DAY), '%Y-%m-%d 17:00:00'),
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 8 DAY), '%Y-%m-%d 09:30:00'),
 NULL,
 'in_progress', 70000.00, 'Currently in transit'),

(@baltic_transporter_id, @rotterdam_barcelona_id, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY), '%Y-%m-%d 10:00:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY), '%Y-%m-%d 14:00:00'),
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY), '%Y-%m-%d 10:15:00'),
 NULL,
 'in_progress', 65000.00, 'Currently in transit'),

(@caspian_trader_id, @dubai_tokyo_id, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 6 DAY), '%Y-%m-%d 07:00:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 6 DAY), '%Y-%m-%d 15:00:00'),
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 6 DAY), '%Y-%m-%d 07:30:00'),
 NULL,
 'in_progress', 85000.00, 'Currently in transit'),

(@pacific_guardian_id, @singapore_busan_id, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 4 DAY), '%Y-%m-%d 08:30:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 3 DAY), '%Y-%m-%d 16:30:00'),
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 4 DAY), '%Y-%m-%d 09:00:00'),
 NULL,
 'in_progress', 75000.00, 'Currently in transit');

-- Future schedules (this month - scheduled)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@atlantic_explorer_id, @hamburg_mumbai_id, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 5 DAY), '%Y-%m-%d 08:00:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 17 DAY), '%Y-%m-%d 16:00:00'),
 NULL, NULL,
 'scheduled', 80000.00, 'Regular cargo service'),

(@north_sea_carrier_id, @mumbai_alexandria_id, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 8 DAY), '%Y-%m-%d 09:00:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 16 DAY), '%Y-%m-%d 17:00:00'),
 NULL, NULL,
 'scheduled', 90000.00, 'Express service'),

(@aegean_express_id, @alexandria_melbourne_id, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), '%Y-%m-%d 10:00:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY), '%Y-%m-%d 18:00:00'),
 NULL, NULL,
 'scheduled', 60000.00, 'Long-distance route'),

(@adriatic_eagle_id, @marseille_alexandria_id, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 12 DAY), '%Y-%m-%d 07:00:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 17 DAY), '%Y-%m-%d 15:00:00'),
 NULL, NULL,
 'scheduled', 65000.00, 'Mediterranean service'),

(@atlantic_champion_id, @newyork_barcelona_id, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 15 DAY), '%Y-%m-%d 08:30:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 25 DAY), '%Y-%m-%d 16:30:00'),
 NULL, NULL,
 'scheduled', 70000.00, 'Transatlantic crossing');

-- Future schedules (next month - scheduled)
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) VALUES
(@pacific_voyager_id, @vancouver_tokyo_id, 
 DATE_FORMAT(@future_month_start, '%Y-%m-%d 08:00:00'),
 DATE_FORMAT(DATE_ADD(@future_month_start, INTERVAL 10 DAY), '%Y-%m-%d 16:00:00'),
 NULL, NULL,
 'scheduled', 60000.00, 'Next month service'),

(@mediterranean_queen_id, @tokyo_rio_id, 
 DATE_FORMAT(DATE_ADD(@future_month_start, INTERVAL 3 DAY), '%Y-%m-%d 09:00:00'),
 DATE_FORMAT(DATE_ADD(@future_month_start, INTERVAL 28 DAY), '%Y-%m-%d 17:00:00'),
 NULL, NULL,
 'scheduled', 100000.00, 'Long-distance transoceanic route'),

(@oceanic_voyager_id, @shanghai_singapore_id, 
 DATE_FORMAT(DATE_ADD(@future_month_start, INTERVAL 5 DAY), '%Y-%m-%d 10:00:00'),
 DATE_FORMAT(DATE_ADD(@future_month_start, INTERVAL 11 DAY), '%Y-%m-%d 18:00:00'),
 NULL, NULL,
 'scheduled', 80000.00, 'Asian trade route'),

(@nordic_adventurer_id, @hamburg_dubai_id, 
 DATE_FORMAT(DATE_ADD(@future_month_start, INTERVAL 8 DAY), '%Y-%m-%d 07:00:00'),
 DATE_FORMAT(DATE_ADD(@future_month_start, INTERVAL 26 DAY), '%Y-%m-%d 15:00:00'),
 NULL, NULL,
 'scheduled', 85000.00, 'Europe-Middle East trade'),

(@indian_ocean_navigator_id, @mumbai_melbourne_id, 
 DATE_FORMAT(DATE_ADD(@future_month_start, INTERVAL 10 DAY), '%Y-%m-%d 08:30:00'),
 DATE_FORMAT(DATE_ADD(@future_month_start, INTERVAL 25 DAY), '%Y-%m-%d 16:30:00'),
 NULL, NULL,
 'scheduled', 90000.00, 'Indian Ocean crossing');

-- Store schedule IDs for reference
-- Past completed schedules
SET @past_schedule1 = (SELECT schedule_id FROM schedules WHERE ship_id = @atlantic_explorer_id AND status = 'completed' LIMIT 1);
SET @past_schedule2 = (SELECT schedule_id FROM schedules WHERE ship_id = @pacific_voyager_id AND status = 'completed' LIMIT 1);
SET @past_schedule3 = (SELECT schedule_id FROM schedules WHERE ship_id = @mediterranean_queen_id AND status = 'completed' LIMIT 1);
SET @past_schedule4 = (SELECT schedule_id FROM schedules WHERE ship_id = @oceanic_voyager_id AND status = 'completed' LIMIT 1);
SET @past_schedule5 = (SELECT schedule_id FROM schedules WHERE ship_id = @nordic_adventurer_id AND status = 'completed' LIMIT 1);

-- Cancelled schedule
SET @cancelled_schedule = (SELECT schedule_id FROM schedules WHERE status = 'cancelled' LIMIT 1);

-- Current in-progress schedules
SET @current_schedule1 = (SELECT schedule_id FROM schedules WHERE ship_id = @caribbean_princess_id AND status = 'in_progress' LIMIT 1);
SET @current_schedule2 = (SELECT schedule_id FROM schedules WHERE ship_id = @asian_star_id AND status = 'in_progress' LIMIT 1);
SET @current_schedule3 = (SELECT schedule_id FROM schedules WHERE ship_id = @baltic_transporter_id AND status = 'in_progress' LIMIT 1);
SET @current_schedule4 = (SELECT schedule_id FROM schedules WHERE ship_id = @caspian_trader_id AND status = 'in_progress' LIMIT 1);
SET @current_schedule5 = (SELECT schedule_id FROM schedules WHERE ship_id = @pacific_guardian_id AND status = 'in_progress' LIMIT 1);

-- Future schedules (this month)
SET @future_schedule1 = (SELECT schedule_id FROM schedules WHERE ship_id = @atlantic_explorer_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);
SET @future_schedule2 = (SELECT schedule_id FROM schedules WHERE ship_id = @north_sea_carrier_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);
SET @future_schedule3 = (SELECT schedule_id FROM schedules WHERE ship_id = @aegean_express_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);
SET @future_schedule4 = (SELECT schedule_id FROM schedules WHERE ship_id = @adriatic_eagle_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);
SET @future_schedule5 = (SELECT schedule_id FROM schedules WHERE ship_id = @atlantic_champion_id AND status = 'scheduled' ORDER BY departure_date LIMIT 1);

-- Future schedules (next month)
SET @next_month_schedule1 = (SELECT schedule_id FROM schedules WHERE ship_id = @pacific_voyager_id AND status = 'scheduled' ORDER BY departure_date DESC LIMIT 1);
SET @next_month_schedule2 = (SELECT schedule_id FROM schedules WHERE ship_id = @mediterranean_queen_id AND status = 'scheduled' ORDER BY departure_date DESC LIMIT 1);
SET @next_month_schedule3 = (SELECT schedule_id FROM schedules WHERE ship_id = @oceanic_voyager_id AND status = 'scheduled' ORDER BY departure_date DESC LIMIT 1);
SET @next_month_schedule4 = (SELECT schedule_id FROM schedules WHERE ship_id = @nordic_adventurer_id AND status = 'scheduled' ORDER BY departure_date DESC LIMIT 1);
SET @next_month_schedule5 = (SELECT schedule_id FROM schedules WHERE ship_id = @indian_ocean_navigator_id AND status = 'scheduled' ORDER BY departure_date DESC LIMIT 1);

-- -------------------------
-- STEP 8: CREATE BERTH ASSIGNMENTS
-- -------------------------

-- Get berth IDs for reference
SET @hamburg_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'HAM-B001');
SET @mumbai_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'MUM-B001');
SET @vancouver_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'VAN-B001');
SET @tokyo_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'TOK-B001');
SET @rio_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'RIO-B001');
SET @marseille_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'MAR-B001');
SET @alexandria_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'ALX-B001');
SET @melbourne_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'MEL-B001');
SET @shanghai_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'SHA-B001');
SET @singapore_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'SIN-B001');
SET @rotterdam_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'ROT-B001');
SET @barcelona_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'BAR-B001');
SET @dubai_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'DUB-B001');
SET @newyork_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'NYC-B001');
SET @busan_berth1 = (SELECT berth_id FROM berths WHERE berth_number = 'BUS-B001');

-- Create berth assignments for completed schedules
INSERT INTO berth_assignments (berth_id, ship_id, schedule_id, arrival_time, departure_time, status) VALUES
-- Past schedules
(@hamburg_berth1, @atlantic_explorer_id, @past_schedule1, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 6 DAY), '%Y-%m-%d 18:00:00'),
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 5 DAY), '%Y-%m-%d 07:30:00'),
 'active'),
(@mumbai_berth1, @atlantic_explorer_id, @past_schedule1, 
 DATE_FORMAT(DATE_ADD(DATE_SUB(@past_month_start, INTERVAL 5 DAY), INTERVAL 12 DAY), '%Y-%m-%d 15:30:00'),
 DATE_FORMAT(DATE_ADD(DATE_SUB(@past_month_start, INTERVAL 5 DAY), INTERVAL 13 DAY), '%Y-%m-%d 09:00:00'),
 'active'),

(@vancouver_berth1, @pacific_voyager_id, @past_schedule2, 
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 1 DAY), '%Y-%m-%d 16:00:00'),
 DATE_FORMAT(DATE_ADD(@past_month_start, INTERVAL 2 DAY), '%Y-%m-%d 08:30:00'),
 'active'),
(@tokyo_berth1, @pacific_voyager_id, @past_schedule2, 
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 2 DAY), INTERVAL 10 DAY), '%Y-%m-%d 14:30:00'),
 DATE_FORMAT(DATE_ADD(DATE_ADD(@past_month_start, INTERVAL 2 DAY), INTERVAL 11 DAY), '%Y-%m-%d 10:00:00'),
 'active');

-- Create berth assignments for current schedules
INSERT INTO berth_assignments (berth_id, ship_id, schedule_id, arrival_time, departure_time, status) VALUES
(@vancouver_berth1, @caribbean_princess_id, @current_schedule1, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 11 DAY), '%Y-%m-%d 16:00:00'),
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 10 DAY), '%Y-%m-%d 07:30:00'),
 'active'),
(@marseille_berth1, @caribbean_princess_id, @current_schedule1, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 12 DAY), '%Y-%m-%d 15:30:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 13 DAY), '%Y-%m-%d 09:00:00'),
 'active'),

(@rio_berth1, @asian_star_id, @current_schedule2, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 9 DAY), '%Y-%m-%d 16:00:00'),
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 8 DAY), '%Y-%m-%d 08:30:00'),
 'active'),
(@hamburg_berth1, @asian_star_id, @current_schedule2, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 8 DAY), '%Y-%m-%d 16:30:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 9 DAY), '%Y-%m-%d 10:00:00'),
 'active');

-- Create berth assignments for future schedules
INSERT INTO berth_assignments (berth_id, ship_id, schedule_id, arrival_time, departure_time, status) VALUES
(@hamburg_berth1, @atlantic_explorer_id, @future_schedule1, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 4 DAY), '%Y-%m-%d 16:00:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 5 DAY), '%Y-%m-%d 07:30:00'),
 'active'),
(@mumbai_berth1, @atlantic_explorer_id, @future_schedule1, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 17 DAY), '%Y-%m-%d 15:30:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 18 DAY), '%Y-%m-%d 09:00:00'),
 'active'),

(@mumbai_berth1, @north_sea_carrier_id, @future_schedule2, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 7 DAY), '%Y-%m-%d 16:00:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 8 DAY), '%Y-%m-%d 08:30:00'),
 'active'),
(@alexandria_berth1, @north_sea_carrier_id, @future_schedule2, 
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 16 DAY), '%Y-%m-%d 16:30:00'),
 DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 17 DAY), '%Y-%m-%d 10:00:00'),
 'active');

-- -------------------------
-- STEP 9: CREATE DIRECT BOOKINGS
-- -------------------------

-- Completed bookings (past month)
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, booking_date, notes) VALUES
(@tom_cargo3_id, @past_schedule1, @tom_id, 'completed', 'paid', 20000.00, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 15 DAY), '%Y-%m-%d %H:%i:%s'),
 'Shipment delivered successfully'),
 
(@sarah_cargo2_id, @past_schedule2, @sarah_id, 'completed', 'paid', 8960.00, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 13 DAY), '%Y-%m-%d %H:%i:%s'),
 'Shipment arrived on time'),
 
(@david_cargo3_id, @past_schedule3, @david_id, 'completed', 'paid', 11550.00, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 10 DAY), '%Y-%m-%d %H:%i:%s'),
 'Shipment completed as scheduled'),
 
(@emily_cargo1_id, @past_schedule4, @emily_id, 'completed', 'paid', 11200.00, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 12 DAY), '%Y-%m-%d %H:%i:%s'),
 'Delivery confirmed by receiver'),
 
(@raj_cargo1_id, @past_schedule5, @raj_id, 'completed', 'paid', 7875.00, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 18 DAY), '%Y-%m-%d %H:%i:%s'),
 'Shipment arrived in excellent condition');

-- Cancelled bookings (past month)
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, booking_date, notes) VALUES
(@sarah_cargo1_id, @cancelled_schedule, @sarah_id, 'cancelled', 'refunded', 9975.00, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 20 DAY), '%Y-%m-%d %H:%i:%s'),
 'Cancelled due to schedule changes');

-- In progress bookings (current month)
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, booking_date, notes) VALUES
(@tom_cargo2_id, @current_schedule1, @tom_id, 'confirmed', 'paid', 37200.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 15 DAY), '%Y-%m-%d %H:%i:%s'),
 'Currently in transit'),
 
(@sarah_cargo5_id, @current_schedule2, @sarah_id, 'confirmed', 'paid', 4500.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 12 DAY), '%Y-%m-%d %H:%i:%s'),
 'Currently in transit'),
 
(@david_cargo4_id, @current_schedule3, @david_id, 'confirmed', 'paid', 6820.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 8 DAY), '%Y-%m-%d %H:%i:%s'),
 'Currently in transit'),
 
(@emily_cargo5_id, @current_schedule4, @emily_id, 'confirmed', 'paid', 52200.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 10 DAY), '%Y-%m-%d %H:%i:%s'),
 'Currently in transit'),
 
(@raj_cargo4_id, @current_schedule5, @raj_id, 'confirmed', 'paid', 67600.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY), '%Y-%m-%d %H:%i:%s'),
 'Currently in transit');

-- Future confirmed bookings (current month)
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, booking_date, notes) VALUES
(@tom_cargo1_id, @future_schedule1, @tom_id, 'confirmed', 'paid', 12500.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY), '%Y-%m-%d %H:%i:%s'),
 'Scheduled for upcoming voyage'),
 
(@sarah_cargo4_id, @future_schedule2, @sarah_id, 'confirmed', 'paid', 14820.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY), '%Y-%m-%d %H:%i:%s'),
 'Scheduled for upcoming voyage'),
 
(@david_cargo1_id, @future_schedule3, @david_id, 'confirmed', 'paid', 26250.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 4 DAY), '%Y-%m-%d %H:%i:%s'),
 'Scheduled for upcoming voyage'),
 
(@emily_cargo4_id, @future_schedule4, @emily_id, 'confirmed', 'paid', 2520.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 5 DAY), '%Y-%m-%d %H:%i:%s'),
 'Premium handling for artwork'),
 
(@raj_cargo5_id, @future_schedule5, @raj_id, 'confirmed', 'paid', 25075.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY), '%Y-%m-%d %H:%i:%s'),
 'Temperature-controlled shipping');

-- Future pending bookings (next month)
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, booking_date, notes) VALUES
(@tom_cargo4_id, @next_month_schedule1, @tom_id, 'pending', 'unpaid', 80000.00, 
 DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d %H:%i:%s'),
 'Awaiting payment confirmation'),
 
(@sarah_cargo3_id, @next_month_schedule2, @sarah_id, 'pending', 'unpaid', 41250.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d %H:%i:%s'),
 'Awaiting documentation'),
 
(@david_cargo5_id, @next_month_schedule3, @david_id, 'pending', 'unpaid', 49000.00, 
 DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d %H:%i:%s'),
 'Quote provided, awaiting confirmation'),
 
(@emily_cargo2_id, @next_month_schedule4, @emily_id, 'pending', 'unpaid', 97650.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d %H:%i:%s'),
 'Special handling requirements under review'),
 
(@raj_cargo3_id, @next_month_schedule5, @raj_id, 'pending', 'unpaid', 62700.00, 
 DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d %H:%i:%s'),
 'Awaiting insurance documentation');

-- -------------------------
-- STEP 10: CREATE CONNECTED BOOKINGS (MULTI-SEGMENT)
-- -------------------------

-- Completed connected booking (past month)
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
(@tom_cargo5_id, @tom_id, @hamburg_id, @alexandria_id, 'completed', 'paid', 50400.00, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 20 DAY), '%Y-%m-%d %H:%i:%s'),
 'Multi-segment shipment completed successfully');

-- Get the connected booking ID
SET @past_connected_booking1 = LAST_INSERT_ID();

-- Add segments for the completed connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@past_connected_booking1, @past_schedule1, 1, 30000.00),
(@past_connected_booking1, @past_schedule3, 2, 20400.00);

-- Another completed connected booking (past month)
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
(@david_cargo2_id, @david_id, @vancouver_id, @tokyo_id, 'completed', 'paid', 70400.00, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 15 DAY), '%Y-%m-%d %H:%i:%s'),
 'Heavy machinery successfully delivered');

-- Get the connected booking ID
SET @past_connected_booking2 = LAST_INSERT_ID();

-- Add segments for the completed connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@past_connected_booking2, @past_schedule2, 1, 70400.00);

-- In progress connected booking (current month)
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
(@emily_cargo3_id, @emily_id, @rotterdam_id, @barcelona_id, 'confirmed', 'paid', 61600.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 10 DAY), '%Y-%m-%d %H:%i:%s'),
 'Multi-segment shipment currently in transit');

SET @current_connected_booking1 = LAST_INSERT_ID();

-- Add segments for the in progress connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@current_connected_booking1, @current_schedule3, 1, 61600.00);

-- In progress connected booking (current month)
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
(@raj_cargo2_id, @raj_id, @singapore_id, @busan_id, 'confirmed', 'paid', 31200.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 8 DAY), '%Y-%m-%d %H:%i:%s'),
 'Vehicles in transit to final destination');

SET @current_connected_booking2 = LAST_INSERT_ID();

-- Add segments for the in progress connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@current_connected_booking2, @current_schedule5, 1, 31200.00);

-- Future confirmed connected booking (current month)
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
(@sarah_cargo1_id, @sarah_id, @hamburg_id, @dubai_id, 'confirmed', 'paid', 38500.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 4 DAY), '%Y-%m-%d %H:%i:%s'),
 'Multi-segment shipment scheduled');

SET @future_connected_booking1 = LAST_INSERT_ID();

-- Add segments for the future connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@future_connected_booking1, @future_schedule1, 1, 8750.00),
(@future_connected_booking1, @future_schedule5, 2, 29750.00);

-- Another future confirmed connected booking (current month)
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
(@tom_cargo5_id, @tom_id, @mumbai_id, @alexandria_id, 'confirmed', 'paid', 51300.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY), '%Y-%m-%d %H:%i:%s'),
 'Special arrangements for luxury yacht transport');

SET @future_connected_booking2 = LAST_INSERT_ID();

-- Add segments for the future connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@future_connected_booking2, @future_schedule2, 1, 51300.00);

-- Pending connected booking (next month)
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
(@david_cargo2_id, @david_id, @shanghai_id, @singapore_id, 'pending', 'unpaid', 61600.00, 
 DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d %H:%i:%s'),
 'Multi-segment shipment pending confirmation');

SET @pending_connected_booking1 = LAST_INSERT_ID();

-- Add segments for the pending connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@pending_connected_booking1, @next_month_schedule3, 1, 61600.00);

-- Another pending connected booking (next month)
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
(@emily_cargo2_id, @emily_id, @hamburg_id, @dubai_id, 'pending', 'unpaid', 97650.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), '%Y-%m-%d %H:%i:%s'),
 'Specialized transport for oversized wind turbine components');

SET @pending_connected_booking2 = LAST_INSERT_ID();

-- Add segments for the pending connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@pending_connected_booking2, @next_month_schedule4, 1, 97650.00);

-- Cancelled connected booking (past month)
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
(@raj_cargo3_id, @raj_id, @tokyo_id, @rio_id, 'cancelled', 'refunded', 52250.00, 
 DATE_FORMAT(DATE_SUB(@past_month_start, INTERVAL 12 DAY), '%Y-%m-%d %H:%i:%s'),
 'Cancelled due to client request');

SET @cancelled_connected_booking = LAST_INSERT_ID();

-- Add segments for the cancelled connected booking
INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@cancelled_connected_booking, @past_schedule3, 1, 52250.00);

-- -------------------------
-- STEP 11: UPDATE CARGO STATUSES
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
-- STEP 12: ADD SOME MORE COMPLETED BOOKINGS FOR HISTORICAL DATA
-- -------------------------

-- Let's add some more historical data for 2-3 months ago for better statistics
SET @two_months_ago = DATE_SUB(CURRENT_DATE(), INTERVAL 2 MONTH);
SET @three_months_ago = DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH);

-- Define date variables for historical data (simpler approach)
SET @two_months_ago_start = DATE_SUB(CURRENT_DATE(), INTERVAL 65 DAY);
SET @two_months_ago_end = DATE_SUB(CURRENT_DATE(), INTERVAL 35 DAY);
SET @three_months_ago_start = DATE_SUB(CURRENT_DATE(), INTERVAL 95 DAY);
SET @three_months_ago_end = DATE_SUB(CURRENT_DATE(), INTERVAL 65 DAY);

-- Add some completed schedules from 2-3 months ago
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) 
VALUES
-- 2 months ago
(@atlantic_explorer_id, @hamburg_mumbai_id, 
 DATE_FORMAT(@two_months_ago_start, '%Y-%m-%d 08:00:00'),
 DATE_FORMAT(DATE_ADD(@two_months_ago_start, INTERVAL 12 DAY), '%Y-%m-%d 16:00:00'),
 DATE_FORMAT(@two_months_ago_start, '%Y-%m-%d 08:30:00'),
 DATE_FORMAT(DATE_ADD(@two_months_ago_start, INTERVAL 12 DAY), '%Y-%m-%d 15:45:00'),
 'completed', 80000.00, 'Historical voyage 1');

INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) 
VALUES
(@pacific_voyager_id, @vancouver_tokyo_id, 
 DATE_FORMAT(DATE_ADD(@two_months_ago_start, INTERVAL 7 DAY), '%Y-%m-%d 09:00:00'),
 DATE_FORMAT(DATE_ADD(@two_months_ago_start, INTERVAL 17 DAY), '%Y-%m-%d 14:00:00'),
 DATE_FORMAT(DATE_ADD(@two_months_ago_start, INTERVAL 7 DAY), '%Y-%m-%d 09:15:00'),
 DATE_FORMAT(DATE_ADD(@two_months_ago_start, INTERVAL 17 DAY), '%Y-%m-%d 15:30:00'),
 'completed', 60000.00, 'Historical voyage 2');

-- 3 months ago
INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) 
VALUES
(@mediterranean_queen_id, @tokyo_rio_id, 
 DATE_FORMAT(@three_months_ago_start, '%Y-%m-%d 07:00:00'),
 DATE_FORMAT(DATE_ADD(@three_months_ago_start, INTERVAL 25 DAY), '%Y-%m-%d 15:00:00'),
 DATE_FORMAT(@three_months_ago_start, '%Y-%m-%d 07:30:00'),
 DATE_FORMAT(DATE_ADD(@three_months_ago_start, INTERVAL 25 DAY), '%Y-%m-%d 16:15:00'),
 'completed', 100000.00, 'Historical voyage 3');

-- 3 months ago

INSERT INTO schedules (ship_id, route_id, departure_date, arrival_date, actual_departure, actual_arrival, status, max_cargo, notes) 
VALUES
(@oceanic_voyager_id, @shanghai_singapore_id, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 87 DAY), '%Y-%m-%d 08:30:00'),
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 81 DAY), '%Y-%m-%d 16:30:00'),
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 87 DAY), '%Y-%m-%d 09:00:00'),
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 81 DAY), '%Y-%m-%d 17:00:00'),
 'completed', 80000.00, 'Historical voyage 4');
-- Store historical schedule IDs
SET @hist_schedule1 = (SELECT schedule_id FROM schedules WHERE notes = 'Historical voyage 1');
SET @hist_schedule2 = (SELECT schedule_id FROM schedules WHERE notes = 'Historical voyage 2');
SET @hist_schedule3 = (SELECT schedule_id FROM schedules WHERE notes = 'Historical voyage 3');
SET @hist_schedule4 = (SELECT schedule_id FROM schedules WHERE notes = 'Historical voyage 4');

-- Add historical bookings (direct)
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, booking_date, notes) 
VALUES
-- 2 months ago
(@tom_cargo1_id, @hist_schedule1, @tom_id, 'completed', 'paid', 12500.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 75 DAY), '%Y-%m-%d %H:%i:%s'),
 'Historical shipment 1');

INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, booking_date, notes) 
VALUES 
(@sarah_cargo2_id, @hist_schedule2, @sarah_id, 'completed', 'paid', 8960.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 73 DAY), '%Y-%m-%d %H:%i:%s'),
 'Historical shipment 2');

-- 3 months ago 
INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, booking_date, notes) 
VALUES
(@david_cargo3_id, @hist_schedule3, @david_id, 'completed', 'paid', 11550.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 105 DAY), '%Y-%m-%d %H:%i:%s'),
 'Historical shipment 3');

INSERT INTO cargo_bookings (cargo_id, schedule_id, user_id, booking_status, payment_status, price, booking_date, notes) 
VALUES
(@emily_cargo1_id, @hist_schedule4, @emily_id, 'completed', 'paid', 11200.00, 
 DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 107 DAY), '%Y-%m-%d %H:%i:%s'),
 'Historical shipment 4');

-- Add historical connected bookings
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
-- 2 months ago
(@raj_cargo1_id, @raj_id, @hamburg_id, @mumbai_id, 'completed', 'paid', 6250.00, 
 DATE_FORMAT(DATE_SUB(@two_months_ago, INTERVAL 20 DAY), '%Y-%m-%d %H:%i:%s'),
 'Historical connected shipment 1');

SET @hist_connected_booking1 = LAST_INSERT_ID();

INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@hist_connected_booking1, @hist_schedule1, 1, 6250.00);

-- 3 months ago
INSERT INTO connected_bookings (cargo_id, user_id, origin_port_id, destination_port_id, booking_status, payment_status, total_price, booking_date, notes) VALUES
(@tom_cargo3_id, @tom_id, @tokyo_id, @rio_id, 'completed', 'paid', 22000.00, 
 DATE_FORMAT(DATE_SUB(@three_months_ago, INTERVAL 15 DAY), '%Y-%m-%d %H:%i:%s'),
 'Historical connected shipment 2');

SET @hist_connected_booking2 = LAST_INSERT_ID();

INSERT INTO connected_booking_segments (connected_booking_id, schedule_id, segment_order, segment_price) VALUES
(@hist_connected_booking2, @hist_schedule3, 1, 22000.00);

-- -------------------------
-- VERIFICATION QUERIES
-- -------------------------

-- Uncomment to verify data was loaded correctly
-- SELECT 'Users' AS entity, COUNT(*) AS count FROM users WHERE user_id > 7;
-- SELECT 'Ports' AS entity, COUNT(*) AS count FROM ports;
-- SELECT 'Ships' AS entity, COUNT(*) AS count FROM ships;
-- SELECT 'Routes' AS entity, COUNT(*) AS count FROM routes;
-- SELECT 'Schedules' AS entity, COUNT(*) AS count FROM schedules;
-- SELECT 'Berths' AS entity, COUNT(*) AS count FROM berths;
-- SELECT 'Berth Assignments' AS entity, COUNT(*) AS count FROM berth_assignments;
-- SELECT 'Cargo' AS entity, COUNT(*) AS count, 
--        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending,
--        SUM(CASE WHEN status = 'booked' THEN 1 ELSE 0 END) AS booked,
--        SUM(CASE WHEN status = 'in_transit' THEN 1 ELSE 0 END) AS in_transit,
--        SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) AS delivered
-- FROM cargo;
-- SELECT 'Direct Bookings' AS entity, COUNT(*) AS count FROM cargo_bookings;
-- SELECT 'Connected Bookings' AS entity, COUNT(*) AS count FROM connected_bookings;
-- SELECT 'Connected Booking Segments' AS entity, COUNT(*) AS count FROM connected_booking_segments;

-- -------------------------
-- STATISTICS QUERIES
-- -------------------------

-- Check bookings per month (for charts)
SELECT DATE_FORMAT(booking_date, '%Y-%m') AS month,
       COUNT(*) AS booking_count,
       SUM(price) AS total_revenue
FROM cargo_bookings
GROUP BY month
ORDER BY month;

-- Check connected bookings per month
SELECT DATE_FORMAT(booking_date, '%Y-%m') AS month,
       COUNT(*) AS booking_count,
       SUM(total_price) AS total_revenue
FROM connected_bookings
GROUP BY month
ORDER BY month;

-- Check cargo by type
SELECT cargo_type, COUNT(*) AS count, AVG(weight) AS avg_weight
FROM cargo
GROUP BY cargo_type
ORDER BY count DESC;

-- Check booking statuses
SELECT booking_status, COUNT(*) AS count
FROM cargo_bookings
GROUP BY booking_status
ORDER BY count DESC;

-- Check shipping routes by popularity
SELECT r.name, COUNT(cb.booking_id) AS booking_count
FROM routes r
JOIN schedules s ON r.route_id = s.route_id
JOIN cargo_bookings cb ON s.schedule_id = cb.schedule_id
GROUP BY r.name
ORDER BY booking_count DESC;


select * from cargo;

call get_admin_cargo_stats();

select count(DISTINCT(cargo_id)) from connected_bookings;

select count(DISTINCT(cargo_id)) from cargo_bookings;

select * from cargo_bookings;

select * from connected_bookings join cargo on connected_bookings.cargo_id = cargo.cargo_id where booking_status in ('completed', 'confirmed') and status = "pending";

select * from cargo where status = "completed";

select * from roles;




select * from schedules;

select * from routes where route_id in (52,54,60,63);


select * from schedules;

select * from users where email like "%shipowner1%";


SELECT r.route_id, r.name, op.name AS origin_port, 
                   dp.name AS destination_port, r.distance, r.duration
            FROM routes r
            JOIN ports op ON r.origin_port_id = op.port_id
            JOIN ports dp ON r.destination_port_id = dp.port_id
            WHERE r.owner_id = 47 AND r.status = 'active'
            ORDER BY r.name