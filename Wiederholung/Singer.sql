USE Wiederholung;

CREATE TABLE Sanger(
	SangerID int primary key,
	Sangername Varchar(30),
	Popularity Int
)

INSERT INTO Sanger VALUES
	(1, 'Rammstein', 100),
	(2, 'Jazzrausch', 80),
	(3, 'Three days grace', 90);

Create table Plattenlabels(
	LabelID int primary key,
	Rating int,
	LabelName Varchar(30)
)

INSERT INTO Plattenlabels VALUES
	(1, 95, 'Columbia Records'),
	(2, 85, 'Sonny Pictures');

Create table Alben(
	AlbenID int primary key,
	Titel Varchar(30),
	Veroffentlichungsdatum Date,
	LabelID int foreign key references Plattenlabels(LabelID)
)

INSERT INTO Alben Values
	(1, 'Mutter', '2010-12-12', 1),
	(2, 'Jazz', '2013-02-02', 1),
	(3, 'Grace', '2003-05-07', 2);

Create table Lieder(
	LiedID int primary key,
	Title Varchar(30),
	Dauer Int,
	AlbenID int foreign key references Alben(AlbenID)
)

INSERT INTO Lieder (LiedID, Title, Dauer, AlbenID) VALUES
(1, 'Sonne', 280, 1),
(2, 'Ich will', 255, 1),
(3, 'Jazz in Paris', 300, 2),
(4, 'Smooth Jazz', 330, 2),
(5, 'Pain', 210, 3),
(6, 'Animal I Have Become', 230, 3);

CREATE table SangerLied(
	SangerID int foreign key references Sanger(SangerID),
	LiedID int foreign key references Lieder(LiedID),
	primary key(SangerID, LiedID)
)

INSERT INTO SangerLied (SangerID, LiedID) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5),
(3, 6);

Create table Musikvideos(
	VideoID int primary key,
	LiedID int foreign key references Lieder(LiedID),
	Veroffentlichungsdatum Date,
)

INSERT INTO Musikvideos (VideoID, LiedID, Veroffentlichungsdatum) VALUES
(1, 1, '2011-01-15'),
(2, 3, '2013-03-20'),
(3, 5, '2004-06-10');

Create table Konzerte(
	KonzertID int primary key,
	Ort Varchar(30),
	Datum Date,
	Zeit Time,
)

INSERT INTO Konzerte (KonzertID, Ort, Datum, Zeit) VALUES
(1, 'Berlin', '2024-07-20', '19:00:00'),
(2, 'München', '2024-08-15', '20:00:00'),
(3, 'New York', '2024-09-10', '21:00:00');

Create table KonzertSanger(
	SangerID int foreign key references Sanger(SangerID),
	KonzertID int foreign key references Konzerte(KonzertID),
	primary key(SangerID, KonzertID)
)

INSERT INTO KonzertSanger (SangerID, KonzertID) VALUES
(1, 1),
(2, 2),
(3, 3),
(1, 3);

--view
SELECT * 
FROM Alben A
JOIN Lieder L ON L.AlbenID = A.AlbenID
GO

CREATE OR ALTER VIEW AlbenTitel AS
	SELECT A.AlbenID, A.Titel, SUM(L.Dauer) AS TotalenDauer
	FROM Alben A
	JOIN Lieder L ON L.AlbenID = A.AlbenID
	GROUP BY A.AlbenID, A.Titel
GO

SELECT * FROM AlbenTitel

--querry 1
SELECT K.KonzertID, K.Ort
FROM Konzerte K
JOIN KonzertSanger KS ON K.KonzertID = KS.KonzertID
JOIN Sanger S ON S.SangerID = KS.SangerID
WHERE S.Sangername = 'Rammstein'
EXCEPT
SELECT K.KonzertID, K.Ort
FROM Konzerte K
JOIN KonzertSanger KS ON K.KonzertID = KS.KonzertID
JOIN Sanger S ON S.SangerID = KS.SangerID
WHERE S.Sangername = 'Three days grace'

--querry 2
SELECT *
FROM Konzerte K
JOIN KonzertSanger KS ON KS.KonzertID = K.KonzertID

SELECT TOP 1 WITH TIES K.KonzertID, COUNT(KS.SangerID) AS SangerNumber
FROM Konzerte K
JOIN KonzertSanger KS ON KS.KonzertID = K.KonzertID
GROUP BY K.KonzertID
ORDER BY COUNT(KS.SangerID) ASC