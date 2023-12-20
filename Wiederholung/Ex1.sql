USE Wiederholung;
GO

CREATE TABLE Zugtyp(
	zugtyp_id INT PRIMARY KEY,
	beschreibung VARCHAR(100)
);
GO

CREATE TABLE Zug(
	zug_id INT PRIMARY KEY,
	zug_name VARCHAR(50),
	zugtype_id INT FOREIGN KEY REFERENCES Zugtyp(zugtyp_id),
);
GO

CREATE TABLE Bahnhof(
	bahnhof_id INT PRIMARY KEY,
	bahnhof_name VARCHAR(100),
);
GO

CREATE TABLE [Route](
	route_id INT PRIMARY KEY,
	route_name VARCHAR(100),
	zug_id INT FOREIGN KEY REFERENCES Zug(zug_id),
);
GO

CREATE TABLE RouteDetails(
	routeDetails_id INT PRIMARY KEY,
	route_id INT FOREIGN KEY REFERENCES [Route](route_id),
	bahnhof_id INT FOREIGN KEY REFERENCES Bahnhof(bahnhof_id),
	ankunft_zeit TIME,
	abfahrt_zeit TIME
);
GO

-- Insert data into Zugtyp table
INSERT INTO Zugtyp (zugtyp_id, beschreibung)
VALUES
    (1, 'Regionalzug'),
    (2, 'Schnellzug'),
    (3, 'Intercity'),
    (4, 'Eurostar');

-- Insert data into Zug table
INSERT INTO Zug (zug_id, zug_name, zugtype_id)
VALUES
    (101, 'Train A', 1),
    (102, 'Train B', 2),
    (103, 'Train C', 3),
    (104, 'Train D', 4);

-- Insert data into Bahnhof table
INSERT INTO Bahnhof (bahnhof_id, bahnhof_name)
VALUES
    (201, 'Berlin Hauptbahnhof'),
    (202, 'Munich Central Station'),
    (203, 'Hamburg Altona'),
    (204, 'Cologne Central Station');

-- Insert data into Route table
INSERT INTO [Route] (route_id, route_name, zug_id)
VALUES
    (301, 'Route 1', 101),
    (302, 'Route 2', 102),
    (303, 'Route 3', 103),
    (304, 'Route 4', 104);

-- Insert data into RouteDetails table
INSERT INTO RouteDetails (routeDetails_id, route_id, bahnhof_id, ankunft_zeit, abfahrt_zeit)
VALUES
    (401, 301, 201, '08:00:00', '08:30:00'),
    (402, 301, 202, '09:15:00', '09:30:00'),
    (403, 301, 203, '10:00:00', '10:15:00'),
    (404, 302, 202, '11:00:00', '11:15:00'),
    (405, 303, 201, '12:00:00', '12:30:00'),
    (406, 303, 204, '13:15:00', '13:30:00'),
    (407, 304, 203, '14:00:00', '14:15:00');
