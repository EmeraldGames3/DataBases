CREATE TABLE TrainType(
	trainTypeID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	trainDescription VARCHAR(100) NOT NULL 
);
GO
CREATE TABLE Trains(
	trainID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	trainName VARCHAR(50) NOT NULL,
	trainTypeID INT NOT NULL FOREIGN KEY REFERENCES TrainType(trainTypeID)
);
GO
CREATE TABLE Stations(
	stationID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	stationName VARCHAR(50) NOT NULL
);
GO
CREATE TABLE TrainRoutes(
	trainRouteID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	trainRouteName VARCHAR(50) NOT NULL,
	trainID INT NOT NULL FOREIGN KEY REFERENCES Trains(trainID)
);
GO

CREATE TABLE Timetables(
	timetableID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	trainRouteID INT NOT NULL FOREIGN KEY REFERENCES TrainRoutes(trainRouteID),
	stationID INT NOT NULL FOREIGN KEY REFERENCES Stations(stationID),
	arrivalTime DATETIME NOT NULL,
	departureTime DATETIME NOT NULL
);
GO
-- Populate TrainType table
INSERT INTO TrainType (trainDescription) VALUES 
('Express'),
('Local'),
('High-Speed');

-- Populate Trains table
INSERT INTO Trains (trainName, trainTypeID) VALUES
('Train A', 1),
('Train B', 2),
('Train C', 3);

-- Populate Stations table
INSERT INTO Stations (stationName) VALUES
('Station X'),
('Station Y'),
('Station Z');

-- Populate TrainRoutes table
INSERT INTO TrainRoutes (trainRouteName, trainID) VALUES
('Route 1', 1),
('Route 2', 2),
('Route 3', 3);

-- Populate Timetables table
INSERT INTO Timetables (trainRouteID, stationID, arrivalTime, departureTime) VALUES
(1, 1, '2024-01-03T10:00:00', '2024-01-03T10:10:00'),
(1, 2, '2024-01-03T10:30:00', '2024-01-03T10:35:00'),
(1, 3, '2024-01-03T11:15:00', '2024-01-03T11:20:00'),
(2, 1, '2024-01-03T09:45:00', '2024-01-03T10:00:00'),
(2, 2, '2024-01-03T10:15:00', '2024-01-03T10:20:00'),
(2, 3, '2024-01-03T11:00:00', '2024-01-03T11:05:00'),
(3, 1, '2024-01-03T08:30:00', '2024-01-03T08:45:00'),
(3, 2, '2024-01-03T09:00:00', '2024-01-03T09:05:00'),
(3, 3, '2024-01-03T09:45:00', '2024-01-03T09:50:00');
