-- Active: 1744521332564@@127.0.0.1@3306@port
-- Clean up existing data for route testing
DELETE FROM schedules;
DELETE FROM routes;
DELETE FROM ships;
DELETE FROM cargo;
DELETE FROM ports;

-- Insert test ports
INSERT INTO ports (port_id, name, country, location, status) VALUES
(1, 'Port of New York', 'USA', POINT(-74.0060, 40.7128), 'active'),
(2, 'Port of Los Angeles', 'USA', POINT(-118.2437, 33.7701), 'active'),
(3, 'Port of Rotterdam', 'Netherlands', POINT(4.4059, 51.9244), 'active'),
(4, 'Port of Shanghai', 'China', POINT(121.8947, 30.8718), 'active'),
(5, 'Port of Singapore', 'Singapore', POINT(103.8198, 1.2649), 'active');

-- Insert test ships
INSERT INTO ships (ship_id, name, ship_type, capacity, current_port_id, imo_number, flag, year_built, status, owner_id) VALUES
(1, 'Ocean Voyager', 'container', 50000.00, 1, 'IMO1234567', 'Panama', 2015, 'active', 1),
(2, 'Pacific Carrier', 'container', 45000.00, 2, 'IMO2345678', 'Liberia', 2018, 'active', 1),
(3, 'Atlantic Express', 'container', 40000.00, 3, 'IMO3456789', 'Marshall Islands', 2017, 'active', 1);

-- Insert test routes
INSERT INTO routes (route_id, name, origin_port_id, destination_port_id, distance, duration, status, owner_id, ship_id, cost_per_kg) VALUES
(1, 'NY-LA Route', 1, 2, 2500.00, 10.00, 'active', 1, 1, 0.50),
(2, 'LA-Rotterdam Route', 2, 3, 4500.00, 15.00, 'active', 1, 2, 0.75),
(3, 'Rotterdam-Shanghai Route', 3, 4, 6000.00, 20.00, 'active', 1, 3, 1.00),
(4, 'Shanghai-Singapore Route', 4, 5, 2000.00, 7.00, 'active', 1, 1, 0.40);

-- Insert test schedules
INSERT INTO schedules (schedule_id, ship_id, route_id, departure_date, arrival_date, status, max_cargo) VALUES
(1, 1, 1, '2024-03-01 08:00:00', '2024-03-11 08:00:00', 'scheduled', 50000.00),
(2, 2, 2, '2024-03-15 10:00:00', '2024-03-30 10:00:00', 'scheduled', 45000.00),
(3, 3, 3, '2024-04-01 12:00:00', '2024-04-21 12:00:00', 'scheduled', 40000.00),
(4, 1, 4, '2024-04-25 14:00:00', '2024-05-02 14:00:00', 'scheduled', 50000.00);

-- Insert test cargo
INSERT INTO cargo (cargo_id, user_id, description, cargo_type, weight, dimensions, status) VALUES
(1, 1, 'Electronics Shipment', 'container', 5000.00, '20x8x8.5', 'pending'),
(2, 1, 'Machine Parts', 'container', 10000.00, '40x8x8.5', 'pending'),
(3, 1, 'Automotive Parts', 'container', 8000.00, '40x8x8.5', 'pending'); 