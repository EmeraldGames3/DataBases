USE Wiederholung;
GO

CREATE TABLE Flughafen(
	FlughafenID INT PRIMARY KEY,
	FlughafenName Varchar(100),
	FlughafenOrt Varchar(100),
)

CREATE TABLE GepackTyp(
	TypID INT PRIMARY KEY,
	TypDescription Varchar(100),
	TypName Varchar(20)
)

CREATE TABLE Gepack(
	GepackID INT PRIMARY KEY,
	GepackGewicht INT,
	GepackTyp INT FOREIGN KEY REFERENCES GepackTyp(TypID)
)

CREATE TABLE Passanger(
	CNP INT PRIMARY KEY,
	Surname VARCHAR(20),
	FamilyName VARCHAR(20)
)

CREATE TABLE Fluggesellschaft(
	GesellschaftID INT PRIMARY KEY,
	GesellschaftName VARCHAR(20)
)

CREATE TABLE FLug(
	FlugCode INT PRIMARY KEY,
	GesellschaftID INT FOREIGN KEY REFERENCES Fluggesellschaft(GesellschaftID),
	Departure INT FOREIGN KEY REFERENCES Flughafen(FlughafenID),
	Arrival INT FOREIGN KEY REFERENCES Flughafen(FlughafenID),
	DepartureTime DATETIME,
	ArrivalTime DATETIME,
)

CREATE TABLE FlugPassanger(
	CNP INT FOREIGN KEY REFERENCES Passanger(CNP),
	FlugCode INT FOREIGN KEY REFERENCES Flug(FlugCode),
	GepackID INT FOREIGN KEY REFERENCES Gepack(GepackID)
	PRIMARY KEY(CNP, FlugCode)
)

-- Insert data into Flughafen
INSERT INTO Flughafen(FlughafenID, FlughafenName, FlughafenOrt) VALUES
(1, 'Berlin Tegel', 'Berlin'),
(2, 'Frankfurt Airport', 'Frankfurt');

-- Insert data into GepackTyp
INSERT INTO GepackTyp(TypID, TypDescription, TypName) VALUES
(1, 'Hand Baggage', 'Hand'),
(2, 'Checked Baggage', 'Checked');

-- Insert data into Gepack
INSERT INTO Gepack(GepackID, GepackGewicht, GepackTyp) VALUES
(1, 10, 1),
(2, 23, 2);

-- Insert data into Passanger
INSERT INTO Passanger(CNP, Surname, FamilyName) VALUES
(123456789, 'Müller', 'Anamaria'),
(987654321, 'Schmidt', 'Johannes');

-- Insert data into Fluggesellschaft
INSERT INTO Fluggesellschaft(GesellschaftID, GesellschaftName) VALUES
(1, 'Lufthansa'),
(2, 'Ryanair');

-- Insert data into Flug
INSERT INTO Flug(FlugCode, GesellschaftID, Departure, Arrival, DepartureTime, ArrivalTime) VALUES
(101, 1, 1, 2, '2024-01-15 08:00:00', '2024-01-15 10:30:00'),
(102, 2, 2, 1, '2024-01-16 09:00:00', '2024-01-16 11:30:00');

-- Additional data for Flughafen
INSERT INTO Flughafen(FlughafenID, FlughafenName, FlughafenOrt) VALUES
(3, 'Munich Airport', 'Munich'),
(4, 'Hamburg Airport', 'Hamburg');

-- Additional data for GepackTyp
INSERT INTO GepackTyp(TypID, TypDescription, TypName) VALUES
(3, 'Special Baggage', 'Special'),
(4, 'Light Baggage', 'Light');

-- Additional data for Gepack
INSERT INTO Gepack(GepackID, GepackGewicht, GepackTyp) VALUES
(3, 15, 3),
(4, 5, 4),
(5, 20, 2);

-- Additional data for Passanger
INSERT INTO Passanger(CNP, Surname, FamilyName) VALUES
(222333444, 'Fischer', 'Maria'),
(555666777, 'Weber', 'Klaus'),
(888999000, 'Becker', 'Peter');

-- Additional data for Fluggesellschaft
INSERT INTO Fluggesellschaft(GesellschaftID, GesellschaftName) VALUES
(3, 'Air Berlin'),
(4, 'Eurowings');

-- Additional data for Flug
INSERT INTO Flug(FlugCode, GesellschaftID, Departure, Arrival, DepartureTime, ArrivalTime) VALUES
(103, 3, 3, 4, '2024-01-17 07:00:00', '2024-01-17 08:45:00'),
(104, 4, 4, 3, '2024-01-18 18:00:00', '2024-01-18 19:35:00'),
(105, 1, 1, 3, '2024-01-19 13:00:00', '2024-01-19 15:00:00');

-- Additional data for FlugPassanger
INSERT INTO FlugPassanger(CNP, FlugCode, GepackID) VALUES
(222333444, 103, 3),
(555666777, 104, 4),
(888999000, 105, 5),
(123456789, 103, 2),
(987654321, 104, 1);


-- Insert data into FlugPassanger
INSERT INTO FlugPassanger(CNP, FlugCode, GepackID) VALUES
(123456789, 101, 1),
(987654321, 102, 2);

--querry 1
SELECT DISTINCT FP.FlugCode
FROM FlugPassanger FP
JOIN Passanger P ON P.CNP = FP.CNP
WHERE P.FamilyName = 'Anamaria'

--querry 2
SELECT DISTINCT COUNT(FP.FlugCode) AS FlightCount, P.Surname, P.FamilyName
FROM FlugPassanger FP
JOIN Passanger P ON P.CNP = FP.CNP
GROUP BY P.CNP, P.FamilyName, P.Surname

--querry 3
SELECT *
FROM FlugPassanger FP
JOIN Passanger P ON FP.CNP = P.CNP

SELECT FlugCode, COUNT(*) AS PassengerCount
FROM FlugPassanger
GROUP BY FlugCode;

SELECT AVG(PassengerCount) AS AveragePassengerCount
FROM (
    SELECT COUNT(*) AS PassengerCount
    FROM FlugPassanger
    GROUP BY FlugCode
) AS FlightPassengerCounts;

SELECT AVG(CAST(PassengerCount AS DECIMAL)) AS AveragePassengerCount
FROM (
    SELECT COUNT(*) AS PassengerCount
    FROM FlugPassanger
    GROUP BY FlugCode
) AS FlightPassengerCounts;

--querry 4
SELECT F.FlugCode, Fl.FlughafenID, Fl.FlughafenName
FROM Flughafen Fl
JOIN FLug F ON F.Departure = Fl.FlughafenID OR F.Arrival = Fl.FlughafenID

SELECT Fl.FlughafenID, Fl.FlughafenName, Count(Fl.FlughafenID) As FlightCount
FROM Flughafen Fl
JOIN FLug F ON F.Arrival = Fl.FlughafenID
GROUP BY Fl.FlughafenID, Fl.FlughafenName
HAVING Count(*) >= 2

--querry 5
SELECT * FROM FlugPassanger FP JOIN Gepack G ON FP.GepackID = G.GepackID

SELECT Fp.FlugCode, SUM(G.GepackGewicht) AS TotalWeight
FROM FlugPassanger FP
JOIN Gepack G ON FP.GepackID = G.GepackID
GROUP BY FP.Flugcode

--querry 6
SELECT *
FROM Flughafen Fl
JOIN FLug F ON F.Arrival = Fl.FlughafenID OR F.Departure = Fl.FlughafenID

SELECT FL.FlughafenID, Fl.FlughafenName, Count(Fl.FlughafenID) FLights
FROM Flughafen Fl
JOIN FLug F ON F.Arrival = Fl.FlughafenID OR F.Departure = Fl.FlughafenID
GROUP BY Fl.FlughafenID, Fl.FlughafenName

SELECT Fl.FlughafenID, Fl.FlughafenName, COUNT(DISTINCT F.FlugCode) AS FLights
FROM Flughafen Fl
JOIN FLug F ON F.Arrival = Fl.FlughafenID OR F.Departure = Fl.FlughafenID
GROUP BY Fl.FlughafenID, Fl.FlughafenName;

DROP TABLE Fluggesellschaft, FLug, Flughafen, Passanger, FlugPassanger, Gepack, GepackTyp