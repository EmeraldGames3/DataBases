USE Wiederholung;
GO


SELECT DISTINCT TOP 1 WITH TIES r.route_id, r.route_name,
    DATEDIFF(MINUTE, rd.ankunft_zeit, rd.abfahrt_zeit) AS StayDurationInMinutes
FROM [Route] r
JOIN RouteDetails rd ON r.route_id = rd.route_id
JOIN Bahnhof b ON rd.bahnhof_id = b.bahnhof_id
ORDER BY StayDurationInMinutes DESC