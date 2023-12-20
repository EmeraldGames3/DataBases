USE Wiederholung;
GO

SELECT r.route_name
FROM [Route] r
JOIN RouteDetails rd ON rd.route_id = r.route_id
JOIN Bahnhof b ON b.bahnhof_id = rd.bahnhof_id
GROUP BY r.route_id, r.route_name
HAVING COUNT(*) = (
	SELECT COUNT(*) FROM Bahnhof
)