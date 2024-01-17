/*
	4. Erstelle einen Sicht mit den Namen der Routen, welche die wenigsten Bahnhöfe enthalten und, die,
zusätzlich, nicht mehr als 5 Bahnhöfe enthalten.
*/
CREATE OR ALTER VIEW ShowRoutes
AS
	SELECT R.trainRouteID,R.trainRouteName,COUNT(*) AS NumberOfStations
	FROM TrainRoutes R
	INNER JOIN Timetables T ON T.trainRouteID = R.trainRouteID
	GROUP BY R.trainRouteID,R.trainRouteName
	HAVING COUNT(*) <=5 AND COUNT(*) IN (
		SELECT MIN(Counts.nrStations)
		FROM (SELECT COUNT(*) AS nrStations
			  FROM Timetables T1
			  GROUP BY T1.trainRouteID
		) AS Counts
	)
GO

SELECT * FROM ShowRoutes