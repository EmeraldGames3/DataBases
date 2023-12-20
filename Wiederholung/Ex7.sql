USE Wiederholung;
GO

CREATE OR ALTER TRIGGER CheckTimeConstraint
ON RouteDetails
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE (
            DATEPART(HOUR, i.ankunft_zeit) BETWEEN 3 AND 4  -- 3:00 AM to 4:59 AM
            OR DATEPART(HOUR, i.abfahrt_zeit) BETWEEN 3 AND 4  -- 3:00 AM to 4:59 AM
        )
    )
    BEGIN
        ROLLBACK;
        THROW 51000, 'Ankunfts- und Abfahrtszeiten dürfen nicht zwischen 3:00 AM und 5:00 AM liegen.', 1;
    END
END;



-- Insert data into RouteDetails with valid route_id values
INSERT INTO RouteDetails (routeDetails_id, route_id, bahnhof_id, ankunft_zeit, abfahrt_zeit)
VALUES (1, 301, 201, '08:00:00', '09:00:00');

-- Insert data into RouteDetails with another valid route_id value
INSERT INTO RouteDetails (routeDetails_id, route_id, bahnhof_id, ankunft_zeit, abfahrt_zeit)
VALUES (2, 302, 202, '03:00:00', '09:00:00');

-- Insert data into RouteDetails with yet another valid route_id value
INSERT INTO RouteDetails (routeDetails_id, route_id, bahnhof_id, ankunft_zeit, abfahrt_zeit)
VALUES (3, 303, 203, '01:00:00', '04:00:00');


