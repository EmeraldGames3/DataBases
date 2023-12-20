USE Wiederholung;
GO

CREATE OR ALTER FUNCTION ListStationsWithTrains(
    @time TIME
)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT b.bahnhof_id, b.bahnhof_name
    FROM Bahnhof b
    JOIN RouteDetails rd ON rd.bahnhof_id = b.bahnhof_id
    WHERE rd.ankunft_zeit <= @time AND rd.abfahrt_zeit >= @time
);
GO


SELECT * FROM ListStationsWithTrains('10:00:00');