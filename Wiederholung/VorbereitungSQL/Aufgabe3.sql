/*
Schreibe eine benutzerdefinierte Funktion, die alle Bahnhöfe auflistet, die mehr als ein Zug haben an
einem bestimmten Zeitpunkt. (z.B. um 10:30) 

*/
use PraktischePrufungUbungen
GO
CREATE OR ALTER FUNCTION ListStations(@time DATETIME)
RETURNS TABLE
AS
RETURN
(
    SELECT T.stationID,COUNT(*) AS NumberOfTrains
    FROM Timetables T
	WHERE T.arrivalTime<=@time AND T.departureTime>=@time
	GROUP BY T.stationID
	HAVING COUNT(*)>1
);
GO

-- Example of calling the function
-- Example of calling the function with a modified datetime value
SELECT * FROM ListStations('2024-01-03T11:17:00.000');

