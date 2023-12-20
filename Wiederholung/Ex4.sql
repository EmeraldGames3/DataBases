USE Wiederholung;
GO

-- Create or alter the SmallRoutes view to show routes with the fewest stations
CREATE OR ALTER VIEW SmallRoutes AS
    SELECT r.route_id, r.route_name, COUNT(rd.bahnhof_id) AS StationCount
    FROM [Route] r
    JOIN RouteDetails rd ON rd.route_id = r.route_id
    GROUP BY r.route_id, r.route_name
    HAVING COUNT(rd.bahnhof_id) = 
		(SELECT MIN(StationCount) 
		FROM (
			SELECT route_id, COUNT(bahnhof_id) AS StationCount 
			FROM RouteDetails 
			GROUP BY route_id) 
		AS RouteCounts)
		AND
		COUNT(rd.bahnhof_id) <= 5


CREATE OR ALTER VIEW SmallRoutes AS
WITH RouteCounts AS (
    SELECT route_id, COUNT(bahnhof_id) AS StationCount
    FROM RouteDetails
    GROUP BY route_id
)
SELECT r.route_id, r.route_name, RC.StationCount
FROM [Route] r
JOIN RouteCounts RC ON r.route_id = RC.route_id
WHERE RC.StationCount = (SELECT MIN(StationCount) FROM RouteCounts)
  AND RC.StationCount <= 5;


-- Query the SmallRoutes view with the desired ordering
SELECT * FROM SmallRoutes
