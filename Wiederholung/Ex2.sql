USE Wiederholung;
GO

CREATE OR ALTER PROCEDURE AddRoute
    @route_id INT,
    @bahnhof_id INT,
    @ankunft_zeit TIME,
    @abfahrt_zeit TIME
AS
BEGIN
    -- Check if the station already exists in the route
    IF EXISTS (SELECT 1 FROM RouteDetails 
               WHERE route_id = @route_id AND bahnhof_id = @bahnhof_id)
    BEGIN
        -- Update existing station times
        UPDATE RouteDetails
        SET ankunft_zeit = @ankunft_zeit, abfahrt_zeit = @abfahrt_zeit
        WHERE route_id = @route_id AND bahnhof_id = @bahnhof_id
    END
    ELSE
    BEGIN
        -- Insert new station into the route with a new routeDetails_id
        DECLARE @newID INT
        SELECT @newID = ISNULL(MAX(routeDetails_id), 0) + 1 FROM RouteDetails

        INSERT INTO RouteDetails(routeDetails_id, route_id, bahnhof_id, ankunft_zeit, abfahrt_zeit)
        VALUES (@newID, @route_id, @bahnhof_id, @ankunft_zeit, @abfahrt_zeit)
    END
END;
GO


-- Test the AddRoute procedure
-- Call the procedure to add a new station to the route
EXEC AddRoute @route_id = 301, @bahnhof_id = 204, @ankunft_zeit = '15:00:00', @abfahrt_zeit = '15:15:00';

-- Call the procedure to update an existing station's times
EXEC AddRoute @route_id = 301, @bahnhof_id = 202, @ankunft_zeit = '09:30:00', @abfahrt_zeit = '09:45:00';

-- Call the procedure to add another new station to the route
EXEC AddRoute @route_id = 302, @bahnhof_id = 201, @ankunft_zeit = '11:30:00', @abfahrt_zeit = '11:45:00';

-- Check the RouteDetails table to see the results
SELECT * FROM RouteDetails;
