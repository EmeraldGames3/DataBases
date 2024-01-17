/*
	Schreibe eine gespeicherte Prozedur, die Route, Bahnhof, Ankunftszeit und Abfahrtszeit als
	Parameter kriegt. Falls sich der Bahnhof schon auf dieser Route befindet, dann werden die
	Ankunftszeit und Abfahrtszeit entsprechend geändert. Ansonsten, wird der neue Bahnhof zu der
	Route eingefügt.
*/
CREATE OR ALTER PROCEDURE UpdateRouteInfo(
	@routeID INT,
	@stationID INT,
	@arrivalTime DATETIME,
	@departureTime DATETIME
)
AS
BEGIN
	IF @stationID NOT IN (	SELECT T.stationID
							FROM Timetables T
							WHERE T.trainRouteID = @routeID)
	BEGIN
		INSERT INTO Timetables
		VALUES(@routeID, @stationID, @arrivalTime, @departureTime)
	END
	ELSE
	BEGIN
		UPDATE Timetables
		SET arrivalTime = @arrivalTime, departureTime = @departureTime
		WHERE trainRouteID = @routeID AND stationID = @stationID
	END
END
GO
SELECT * FROM Stations;
SELECT * FROM TrainRoutes;
SELECT * FROM Timetables;

EXEC UpdateRouteInfo 1,2,'2024-01-03 11:15:00.000','2024-01-03 11:50:00.000'
EXEC UpdateRouteInfo 3,3,'2024-01-03 11:15:00.000','2024-01-03 11:50:00.000'