Use Wiederholung;
Go

CREATE TABLE Zugtyp(
	TypID INT PRIMARY KEY,
	TypDescription VARCHAR(100)
)

CREATE TABLE Zug(
	ZugID INT PRIMARY KEY,
	ZugName VARCHAR(20),
	ZugTypeID INT FOREIGN KEY REFERENCES Zugtyp(TypID)
)

CREATE TABLE [Route] (
	RouteID INT PRIMARY KEY,
	ZugID INT FOREIGN KEY REFERENCES Zug(ZugID),
	RouteName VARCHAR(20)
)

CREATE TABLE Bahnhoff(
	BahnhoffID INT PRIMARY KEY,
	BahnhoffName VARCHAR(20)
)

CREATE TABLE BahnhoffRoute(
	BahnhoffID INT FOREIGN KEY REFERENCES Bahnhoff(BahnhoffID),
	RouteID  INT FOREIGN KEY REFERENCES [Route](RouteID),
	Ankunftzeit TIME,
	Abfahrzeit TIME,
	PRIMARY KEY(BahnhoffID, RouteID)
)

INSERT INTO Zugtyp(TypID, TypDescription) VALUES 
    (1, 'Regionalzug'),
    (2, 'Schnellzug'),
    (3, 'Intercity'),
    (4, 'Eurostar');

INSERT INTO Zug(ZugID, ZugName, ZugTypeID) VALUES
	(1, 'Fred', 1),
	(2, 'Dob', 2),
	(3, 'Bob', 3),
	(4, 'Thomas', 4)

INSERT INTO Bahnhoff(BahnhoffID, BahnhoffName) VALUES
	(1, 'Berlin'),
    (2, 'Munich'),
    (3, 'Hamburg'),
    (4, 'Cologne');

INSERT INTO [Route] (RouteID, RouteName, ZugID) VALUES
    (1, 'Route 1', 1),
    (2, 'Route 2', 2),
    (3, 'Route 3', 3),
    (4, 'Route 4', 4);

INSERT INTO BahnhoffRoute (BahnhoffID, RouteID, Ankunftzeit, Abfahrzeit) VALUES
	(1, 1, '08:00:00', '08:30:00'),
    (1, 2, '09:15:00', '09:30:00'),
    (1, 3, '10:00:00', '10:15:00'),
    (2, 2, '11:00:00', '11:15:00'),
    (3, 1, '12:00:00', '12:30:00'),
    (3, 4, '13:15:00', '13:30:00'),
    (4, 3, '14:00:00', '14:15:00');

-- procedure
CREATE OR ALTER PROCEDURE AddBahnhoffRoute(
	@RouteID INT,
	@BahnhoffID INT,
	@Ankunftzeit TIME,
	@Abfahrzeit TIME) AS
BEGIN
	IF NOT EXISTS (SELECT * FROM BahnhoffRoute WHERE BahnhoffID = @BahnhoffID AND RouteID = @RouteID)
	BEGIN
		INSERT INTO BahnhoffRoute(BahnhoffID, RouteID, Ankunftzeit, Abfahrzeit) VALUES
		(@BahnhoffID, @RouteID, @Ankunftzeit, @Abfahrzeit)
	END
	ELSE
	BEGIN
		UPDATE BahnhoffRoute
		SET Ankunftzeit = @Ankunftzeit, Abfahrzeit = @Abfahrzeit
		WHERE BahnhoffID = @BahnhoffID AND RouteID = @RouteID;
	END
END


EXEC AddBahnhoffRoute @RouteID = 1, @BahnhoffID = 4, @Ankunftzeit = '15:00:00', @Abfahrzeit = '15:15:00';

EXEC AddBahnhoffRoute @RouteID = 1, @BahnhoffID = 2, @Ankunftzeit = '09:00:00', @Abfahrzeit = '09:45:00';

EXEC AddBahnhoffRoute @RouteID = 2, @BahnhoffID = 1, @Ankunftzeit = '11:15:00', @Abfahrzeit = '11:45:00';

SELECT * FROM BahnhoffRoute;

--function
CREATE OR ALTER FUNCTION ShowBusyBahnhofs (@Timestamp Time)
RETURNS TABLE
AS
RETURN (
    SELECT BR.BahnhoffID, B.BahnhoffName, COUNT(DISTINCT BR.RouteID) AS ZugCount
    FROM BahnhoffRoute BR
    JOIN [Route] R ON BR.RouteID = R.RouteID
    JOIN Zug Z ON R.ZugID = Z.ZugID
    JOIN Bahnhoff B ON BR.BahnhoffID = B.BahnhoffID
    WHERE @Timestamp BETWEEN BR.Ankunftzeit AND BR.Abfahrzeit
    GROUP BY BR.BahnhoffID, B.BahnhoffName
    HAVING COUNT(DISTINCT BR.RouteID) > 1
)

SELECT * FROM ShowBahnhoff('11:00:00')

CREATE OR ALTER VIEW RoutesWithLeastBahnhofe as
	SELECT R.RouteID, R.RouteName, Count(R.RouteID) as numberBahnhoffe
	FROM [Route] R
	JOIN BahnhoffRoute BR ON BR.RouteID = R.RouteID
	GROUP BY R.RouteID, R.RouteName
	HAVING Count(R.RouteID) = (
		SELECT MIN(minimum) 
		FROM (
			SELECT COUNT(R.RouteID) as minimum
			FROM [Route] R
			JOIN BahnhoffRoute BR ON BR.RouteID = R.RouteID
			GROUP BY R.RouteID, R.RouteName
		) AS subquerry
	)
	AND Count(R.RouteID) < 5

SELECT * FROM BahnhoffRoute;
SELECT * FROM RoutesWithLeastBahnhofe

--querry 1
SELECT R.RouteName, COUNT(BR.BahnhoffID) AS BahnhoffCount
FROM [Route] R
JOIN BahnhoffRoute br on BR.BahnhoffID = R.RouteID
GROUP BY R.RouteID, R.RouteName
HAVING COUNT(BR.BahnhoffID) = (
	SELECT COUNT(BahnhoffID)
	FROM Bahnhoff
)

--querry 2
SELECT TOP 1 WITH TIES B.BahnhoffID, B.BahnhoffName, DATEDIFF(MINUTE, BR.Ankunftzeit, BR.Abfahrzeit) AS TrainTime
FROM Bahnhoff B
JOIN BahnhoffRoute BR ON BR.BahnhoffID = B.BahnhoffID
JOIN [Route] R ON R.RouteID = BR.RouteID
JOIN Zug Z ON R.ZugID = Z.ZugID
GROUP BY B.BahnhoffID, B.BahnhoffName, DATEDIFF(MINUTE, BR.Ankunftzeit, BR.Abfahrzeit)
ORDER BY DATEDIFF(MINUTE, BR.Ankunftzeit, BR.Abfahrzeit) DESC

-- trigger
CREATE OR ALTER TRIGGER addBahnhoffTrigger ON BahnhoffRoute
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT * FROM inserted 
        WHERE Ankunftzeit BETWEEN '03:00:00' AND '05:00:00'
        OR Abfahrzeit BETWEEN '03:00:00' AND '05:00:00'
    ) 
    BEGIN
        RAISERROR('Invalid time range', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

EXEC AddBahnhoffRoute @RouteID = 2, @BahnhoffID = 3, @Ankunftzeit = '2:15:00', @Abfahrzeit = '2:45:00';