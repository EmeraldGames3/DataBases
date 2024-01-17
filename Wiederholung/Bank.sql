USE Wiederholung;
GO

CREATE TABLE Kunde(
	CNP INT PRIMARY KEY,
	Vorname VARCHAR(20),
	Familienname Varchar(20)
)

CREATE TABLE Wahrung(
	WahrungID INT PRIMARY KEY,
	WahrungName Varchar(20)
)

Create TABLE Konto(
	KontoNummer INT PRIMARY KEY,
	Balance INT,
	CNP INT FOREIGN KEY REFERENCES Kunde(CNP),
	WahrungID INT FOREIGN KEY REFERENCES Wahrung(WahrungID),
)

CREATE TABLE Kredit(
	KreditID INT PRIMARY KEY,
	WahrungID INT FOREIGN KEY REFERENCES Wahrung(WahrungID),
	Laufzeit INT,
)

CREATE TABLE KundeKredit(
	CNP INT FOREIGN KEY REFERENCES Kunde(CNP),
	KreditID INT FOREIGN KEY REFERENCES Kredit(KreditID),
	Betrag INT,
	Rate INT,
	StartDate DATE,
	PRIMARY KEY(CNP, KreditID)
)

-- Insert data into Kunde
INSERT INTO Kunde(CNP, Vorname, Familienname) VALUES
(1001, 'Max', 'Mustermann'),
(1002, 'Maria', 'Müller'),
(1003, 'Johann', 'Schmidt');

-- Insert data into Wahrung
INSERT INTO Wahrung(WahrungID, WahrungName) VALUES
(1, 'Euro'),
(2, 'USD'),
(3, 'RON');

-- Insert data into Konto
INSERT INTO Konto(KontoNummer, Balance, CNP, WahrungID) VALUES
(5001, 10000, 1001, 1),
(5002, 15000, 1002, 2),
(5003, 20000, 1003, 3),
(5004, 5000, 1001, 2),  
(5005, 7500, 1001, 3), 
(5006, 12000, 1002, 1), 
(5007, 6000, 1003, 2); 

-- Insert data into Kredit
INSERT INTO Kredit(KreditID, WahrungID, Laufzeit) VALUES
(3001, 1, 60),
(3002, 2, 36),
(3003, 3, 48);

-- Insert data into KundeKredit
INSERT INTO KundeKredit(CNP, KreditID, Betrag, Rate) VALUES
(1001, 3001, 5000, 100),
(1001, 3002, 7000, 150), 
(1001, 3003, 10000, 250),
(1002, 3002, 8000, 200),
(1003, 3003, 12000, 300); 


--querry 1
SELECT AVG(KK.Betrag) AS AvarageBetrag
FROM Kredit K
JOIN KundeKredit KK ON K.KreditID = KK.KreditID

--querry 2
SELECT Ku.CNP, Ku.Familienname, Ku.Vorname, W.WahrungName
FROM Kunde Ku
JOIN KundeKredit KK ON KK.CNP = Ku.CNP
JOIN Kredit K ON K.KreditID = KK.KreditID
JOIN Wahrung W ON W.WahrungID = K.WahrungID
WHERE KK.Betrag > 1000 AND W.WahrungName='Euro'

--querry 3
SELECT Count(W.WahrungID) As EuroKontosAnzahl
FROM Konto K
JOIN Wahrung W ON W.WahrungID = K.WahrungID
WHERE W.WahrungName = 'Euro'
GROUP BY W.WahrungID

--querry 4
SELECT Ku.CNP, Ku.Vorname, Ku.Familienname
FROM Kunde Ku
JOIN KundeKredit KK1 ON KK1.CNP = Ku.CNP
JOIN Kredit K1 ON K1.KreditID = KK1.KreditID
JOIN Wahrung W1 ON W1.WahrungID = K1.WahrungID
JOIN KundeKredit KK2 ON KK2.CNP = Ku.CNP
JOIN Kredit K2 ON K2.KreditID = KK2.KreditID
JOIN Wahrung W2 ON W2.WahrungID = K2.WahrungID
WHERE W1.WahrungName = 'Ron' AND W2.WahrungName = 'Euro'
AND KK2.Betrag > KK1.Betrag