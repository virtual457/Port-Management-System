-- Test Case 1: Direct route from NY to LA (should find route)
SELECT 'Test Case 1: Direct route NY to LA' as test_case;
CALL find_all_routes(1, 2, '2024-03-01', '2024-03-11', 1, 0);

-- Test Case 2: Direct route from LA to Rotterdam (should find route)
SELECT 'Test Case 2: Direct route LA to Rotterdam' as test_case;
CALL find_all_routes(2, 3, '2024-03-15', '2024-03-30', 1, 0);

-- Test Case 3: Connected route from NY to Shanghai (should find connected route)
SELECT 'Test Case 3: Connected route NY to Shanghai' as test_case;
CALL find_all_routes(1, 4, '2024-03-01', '2024-04-21', 1, 2);

-- Test Case 4: No route available (invalid dates)
SELECT 'Test Case 4: No route available (invalid dates)' as test_case;
CALL find_all_routes(1, 2, '2024-02-01', '2024-02-10', 1, 0);

-- Test Case 5: Connected route with max 1 connection
SELECT 'Test Case 5: Connected route with max 1 connection' as test_case;
CALL find_all_routes(1, 3, '2024-03-01', '2024-03-30', 1, 1);

-- Test Case 6: Cargo too heavy for available capacity
SELECT 'Test Case 6: Cargo too heavy for available capacity' as test_case;
CALL find_all_routes(1, 2, '2024-03-01', '2024-03-11', 2, 0);

-- Test Case 7: Direct route from Shanghai to Singapore
SELECT 'Test Case 7: Direct route Shanghai to Singapore' as test_case;
CALL find_all_routes(4, 5, '2024-04-25', '2024-05-02', 1, 0);

-- Test Case 8: Connected route from NY to Singapore with max 2 connections
SELECT 'Test Case 8: Connected route NY to Singapore with max 2 connections' as test_case;
CALL find_all_routes(1, 5, '2024-03-01', '2024-05-02', 1, 2);

-- Test Case 9: Same origin and destination (should return empty)
SELECT 'Test Case 9: Same origin and destination' as test_case;
CALL find_all_routes(1, 1, '2024-03-01', '2024-03-11', 1, 0);

-- Test Case 10: Invalid port IDs (should return empty)
SELECT 'Test Case 10: Invalid port IDs' as test_case;
CALL find_all_routes(999, 1000, '2024-03-01', '2024-03-11', 1, 0);

-- Test Case 11: Multiple direct routes available (should show all options)
SELECT 'Test Case 11: Multiple direct routes available' as test_case;
CALL find_all_routes(1, 2, '2024-03-01', '2024-03-11', 1, 0);

-- Test Case 12: Connected route with minimum layover time
SELECT 'Test Case 12: Connected route with minimum layover time' as test_case;
CALL find_all_routes(1, 3, '2024-03-01', '2024-03-31', 1, 1);

-- Test Case 13: Connected route with maximum layover time
SELECT 'Test Case 13: Connected route with maximum layover time' as test_case;
CALL find_all_routes(1, 4, '2024-03-01', '2024-05-01', 1, 2);

-- Test Case 14: Route with specific cargo type requirements
SELECT 'Test Case 14: Route with specific cargo type requirements' as test_case;
CALL find_all_routes(1, 2, '2024-03-01', '2024-03-11', 2, 0);

-- Test Case 15: Route with multiple connection options
SELECT 'Test Case 15: Route with multiple connection options' as test_case;
CALL find_all_routes(1, 5, '2024-03-01', '2024-05-15', 1, 2);

-- Test Case 16: Route with seasonal availability
SELECT 'Test Case 16: Route with seasonal availability' as test_case;
CALL find_all_routes(3, 4, '2024-04-01', '2024-04-21', 1, 0);

-- Test Case 17: Route with capacity constraints
SELECT 'Test Case 17: Route with capacity constraints' as test_case;
CALL find_all_routes(1, 2, '2024-03-01', '2024-03-11', 3, 0);

-- Test Case 18: Route with cost optimization
SELECT 'Test Case 18: Route with cost optimization' as test_case;
CALL find_all_routes(1, 5, '2024-03-01', '2024-05-15', 1, 2);

-- Test Case 19: Route with time optimization
SELECT 'Test Case 19: Route with time optimization' as test_case;
CALL find_all_routes(1, 5, '2024-03-01', '2024-05-15', 1, 2);

-- Test Case 20: Route with mixed optimization (cost and time)
SELECT 'Test Case 20: Route with mixed optimization' as test_case;
CALL find_all_routes(1, 5, '2024-03-01', '2024-05-15', 1, 2); 


SET @status = 0;
SET @message = '';


select * from ports where name = 'deletable port';
-- Call the procedure with a port ID (replace 5 with an actual port ID from your database)
CALL delete_port(61, @status, @message);

-- Display the results
SELECT @status AS deletion_status, @message AS result_message;

select * from schedules;

select * from routes where route_id = 1;


select * from users;


select * from schedules;
select * from cargo;

select * from cargo_bookings;
