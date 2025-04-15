-- Test calls for each procedure using test_data.sql data

-- Test find_direct_routes: NY to LA direct route
SELECT 'Testing find_direct_routes: NY to LA direct route' as test_case;
CALL find_direct_routes(1, 2, '2024-03-01', '2024-03-11', 1);

-- Test find_connected_routes: NY to Shanghai connected route
SELECT 'Testing find_connected_routes: NY to Shanghai connected route' as test_case;
CALL find_connected_routes(1, 5, '2024-03-01', '2024-04-21', 1);

-- Test find_all_routes: NY to Singapore with up to 2 connections
SELECT 'Testing find_all_routes: NY to Singapore with up to 2 connections' as test_case;
CALL find_all_routes(1, 2, '2024-03-01', '2024-05-15', 1, 2); 

SELECT * FROM schedules WHERE route_id = 1 AND departure_date >= '2024-02-01' AND arrival_date <= '2024-03-11';

select * from schedules where route_id = 1;

SELECT * FROM schedules WHERE route_id = 1 AND DATE(departure_date) >= '2024-02-11' AND DATE(arrival_date) <= '2024-03-11';

describe schedules;

