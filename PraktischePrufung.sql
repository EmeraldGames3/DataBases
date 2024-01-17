USE PraktischePrufung;

CREATE TABLE Masseinheit(
	MasseinheitID int primary key,
	MasseinheitName Varchar(30)
)

CREATE TABLE Zutaten(
	ZutatID int primary key,
	ZutatName Varchar(30),
	MasseinheitID int foreign key references Masseinheit(MasseinheitID)
)

CREATE TABLE Kuchen(
	KuchenID int primary key,
	KuchenName Varchar(30),
	Beschreibung Varchar(MAX)
)

CREATE TABLE KuchenZutat(
	KuchenID int foreign key references Kuchen(KuchenID),
	ZutatID int foreign key references Zutaten(ZutatID),
	ZutatQuantity int
	primary key (KuchenID, ZutatID)
)

CREATE TABLE Kunde(
	KundeID int primary key,
	Vorname Varchar(30),
	FamilienName Varchar(30),
	Email Varchar(30),
	Telefon int
)

CREATE TABLE CandyBar(
	CandyBarID int primary key,
	KundeID int foreign key references Kunde(KundeID),
	Thema Varchar(30),
	Datum Date
)

CREATE TABLE CandyBarKuchen(
	KuchenID int foreign key references Kuchen(KuchenID),
	CandyBarID int foreign key references CandyBar(CandyBarID),
	KuchenQuantity int --kg
	primary key (KuchenID, CandyBarID)
)

INSERT INTO Masseinheit(MasseinheitID, MasseinheitName) VALUES
	(1, 'g'),
	(2, 'ml');

INSERT INTO Zutaten(ZutatID, ZutatName) VALUES 
	(1, 'Milch'),
	(2, 'Zucker'),
	(3, 'Cocos'),
	(4, 'Schokolade'),
	(5, 'WeiseSchokolade'),
	(6, 'Cacao'),
	(7, 'Bombons'),
	(8, 'Honig')

INSERT INTO Kuchen(KuchenID, KuchenName, Beschreibung) VALUES
	(1, 'Himbbeertraum', 'aaaa'),
	(2, 'Erdbeer-Cupcake', '112a'),
	(3, 'Kokos Tortchen', 'uio'),
	(4, 'Vanilla-Cupcake', '0mij'),
	(5, 'Zitronen Mouse', '891'),
	(6, 'Nutellakuchen', 'oijm');

INSERT INTO Kuchen VALUES
	(7, 'SchokoladeMouse', 'schok')

INSERT INTO KuchenZutat VALUES
	(7, 1, 100),
	(7, 3, 100),
	(7, 4, 100),
	(7, 5, 100),
	(7, 6, 100);

INSERT INTO KuchenZutat(KuchenID, ZutatID, ZutatQuantity) VALUES 
	(1, 1, 10),
	(1, 2, 10),
	(1, 3, 10),
	(1, 4, 10),
	(2, 1, 12),
	(2, 2, 12),
	(2, 3, 12),
	(2, 4, 12),
	(2, 5, 12),
	(2, 6, 12),
	(3, 4, 15),
	(3, 5, 15),
	(3, 6, 15),
	(4, 1, 20),
	(4, 2, 20),
	(4, 3, 20),
	(4, 4, 20),
	(4, 5, 20),
	(4, 6, 20),
	(4, 7, 20),
	(4, 8, 20),
	(5, 1, 34),
	(5, 2, 34),
	(5, 3, 34),
	(5, 4, 34),
	(5, 5, 34),
	(6, 1, 11),
	(6, 2, 11),
	(6, 3, 11);

INSERT INTO Kunde(KundeID, Vorname, FamilienName, Telefon, Email) VALUES
	(1, 'John', 'Smith', '05657531', 'john@gmail.com'),
	(2, 'Mark', 'Smith', '05697530', 'mark@gmail.com');

INSERT INTO CandyBar(CandyBarID, KundeID, Thema, Datum) VALUES
	(1, 1, 'Weinachten', '02-03-2030'),
	(2, 2, 'Ostern', '03-03-2031');

INSERT INTO CandyBarKuchen(CandyBarID, KuchenID, KuchenQuantity) VALUES
	(1, 1, 100),
	(1, 7, 30),
	(2, 1, 40)


--querry 1
SELECT *
FROM Kuchen K
JOIN CandyBarKuchen CBK ON CBK.KuchenID = K.KuchenID
JOIN CandyBar CB ON CB.CandyBarID = CBK.CandyBarID

SELECT CB.CandyBarID, CB.Thema, CB.Datum
FROM Kuchen K
JOIN CandyBarKuchen CBK ON CBK.KuchenID = K.KuchenID
JOIN CandyBar CB ON CB.CandyBarID = CBK.CandyBarID
WHERE K.KuchenName='Himbeertraum'
INTERSECT
SELECT CB.CandyBarID, CB.Thema, CB.Datum
FROM Kuchen K
JOIN CandyBarKuchen CBK ON CBK.KuchenID = K.KuchenID
JOIN CandyBar CB ON CB.CandyBarID = CBK.CandyBarID
WHERE K.KuchenName='SchokoladeMouse'


--querry 2
SELECT * 
FROM Kuchen K
JOIN KuchenZutat KZ ON KZ.KuchenID = K.KuchenID

SELECT K.KuchenID, K.KuchenName, Count(*) As AnzahlZutaten 
FROM Kuchen K
JOIN KuchenZutat KZ ON KZ.KuchenID = K.KuchenID
GROUP BY K.KuchenID, K.KuchenName

SELECT TOP 1 WITH TIES K.KuchenID, K.KuchenName, K.Beschreibung, Count(*) As AnzahlZutaten 
FROM Kuchen K
JOIN KuchenZutat KZ ON KZ.KuchenID = K.KuchenID
GROUP BY K.KuchenID, K.KuchenName, K.Beschreibung
ORDER BY COUNT(KZ.ZutatID) ASC