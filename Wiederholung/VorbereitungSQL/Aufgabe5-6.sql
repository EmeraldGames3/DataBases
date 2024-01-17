/*
5. Schreibe eine Abfrage, welche die Namen der Routen ausgibt, die alle Bahnh�fe enthalten.
6. Schreibe eine Abfrage, welche die Bahnh�fe ausgibt, wo ein Zug am l�ngsten bleibt.
*/
SELECT R.trainRouteID,R.trainRouteName
FROM TrainRoutes R
WHERE NOT EXISTS(SELECT S.stationID
				FROM Stations S
				EXCEPT
				SELECT T.stationID
				FROM Timetables T
				WHERE T.trainRouteID = R.trainRouteID)

SELECT T.stationID
FROM Timetables T
WHERE T.departureTime - T.arrivalTime IN (SELECT MAX(T.departureTime - T.arrivalTime)
FROM Timetables T)

SELECT
    S.stationID,
    S.stationName,
    MAX(DATEDIFF(MINUTE, T.arrivalTime, T.departureTime)) AS MaxStayDuration
FROM
    Stations S
JOIN
    Timetables T ON S.stationID = T.stationID
GROUP BY
    S.stationID, S.stationName
ORDER BY
    MaxStayDuration DESC;






