USE Wiederholung;

CREATE TABLE Schauspieler(
	SchauspielerID INT PRIMARY KEY,
	Vorname Varchar(30),
	Familienname Varchar(30)
)

Create Table Abonament(
	AbonamentID int primary key,
	AbonamentTyp Varchar(20),
	Price int
)

CREATE TABLE Zuschauer(
	ZuschauerID Int Primary Key,
	Vorname Varchar(30),
	Familienname Varchar(30),
	AbonamentID int foreign key references Abonament(AbonamentID)
)

Create Table ShowKategorie(
	CatagoryID Int primary key,
	CategoryName Varchar(30),
	CategoryDescription Varchar(30)
)

Create Table TvShows(
	ShowID Int Primary Key,
	CategoryID Int foreign key references ShowKategorie(CatagoryID),
	ShowName Varchar(30),
	Rating Int,
)

Create Table TvShowsActors(
	ShowID int foreign key references TvShows(ShowID),
	SchauspielerID int foreign key references Schauspieler(SchauspielerID)
	primary key(ShowID, SchauspielerID)
)

Create Table ZuschauerTvShow(
	ZuschauerID int foreign key references Zuschauer(ZuschauerID),
	ShowID int foreign key references TvShows(ShowID),
	WatchDate Datetime,
	primary key (ZuschauerID, ShowID, WatchDate)
)

INSERT INTO Schauspieler (SchauspielerID, Vorname, Familienname) Values
	(1, 'Mike', 'mike'),
	(2, 'Jane', 'mike'),
	(3, 'Dob', 'mi');

INSERT INTO Abonament (AbonamentID, AbonamentTyp, Price) Values
	(1, 'one', 20),
	(2, 'Ja', 25),
	(3, 'D', 50);

INSERT INTO Zuschauer (ZuschauerID, Vorname, Familienname, AbonamentID) Values
	(1, 'Mike', 'Smith', 1),
	(2, 'Jane', 'Schmitt', 2),
	(3, 'David', 'Zabalazza', 3),
	(4, 'Dave', 'Smith', 1),
	(5, 'Janette', 'Schmitt', 2),
	(6, 'Mikel', 'Smith', 1);

INSERT INTO ShowKategorie (CatagoryID, CategoryName, CategoryDescription) VALUES 
	(1, 'Drama', 'drrr'),
	(2, 'Komodie', 'kom'),
	(3, 'Thriller', 'trrr');


INSERT INTO TvShows (ShowID, CategoryID, ShowName, Rating) Values
	(1, 1, 'Megastar', 1),
	(2, 1, 'Next Star', 3),
	(3, 1, 'Financial Education', 2);


Insert into TvShowsActors (ShowID, SchauspielerID) Values
	(1, 1),
	(2, 2),
	(3, 3);


Insert into ZuschauerTvShow (ZuschauerID, ShowID, WatchDate) Values
	(1, 1, '2023-01-01 23:23:00'),
	(1, 2, '2023-08-01 23:21:00'),
	(1, 2, '2023-02-01 23:23:00'),
	(1, 3, '2023-05-01 23:20:00'),
	(2, 2, '2023-09-01 23:23:00'),
	(2, 3, '2023-03-01 23:23:00'),
	(3, 3, '2023-07-01 23:23:00');


--view 
CREATE OR ALTER VIEW ZuschauerNextStarAndFinancialEducation AS
	SELECT Z.ZuschauerID, Z.Vorname, Z.Familienname
	FROM ZuschauerTvShow ZTV
	JOIN Zuschauer Z ON Z.ZuschauerID = ZTV.ZuschauerID
	JOIN TvShows TV ON TV.ShowID = ZTV.ShowID
	WHERE TV.ShowName = 'Next Star'

	INTERSECT

	SELECT Z.ZuschauerID, Z.Vorname, Z.Familienname
	FROM ZuschauerTvShow ZTV
	JOIN Zuschauer Z ON Z.ZuschauerID = ZTV.ZuschauerID
	JOIN TvShows TV ON TV.ShowID = ZTV.ShowID
	WHERE TV.ShowName = 'Financial Education'

SELECT * FROM ZuschauerNextStarAndFinancialEducation;


--querry 1
SELECT TV.ShowID, TV.ShowName, COUNT(*) AS Viewers
FROM ZuschauerTvShow ZTV
JOIN Zuschauer Z ON Z.ZuschauerID = ZTV.ZuschauerID
JOIN TvShows TV ON TV.ShowID = ZTV.ShowID
GROUP BY TV.ShowID, TV.ShowName
HAVING COUNT(*) > (
	SELECT COUNT(*) AS Viewers
	FROM ZuschauerTvShow ZTV
	JOIN Zuschauer Z ON Z.ZuschauerID = ZTV.ZuschauerID
	JOIN TvShows TV ON TV.ShowID = ZTV.ShowID
	WHERE TV.ShowName = 'Megastar'
	GROUP BY TV.ShowID, TV.ShowName
)


--querry 2
SELECT A.AbonamentID, A.AbonamentTyp, COUNT(*) as Subscribers, SUM(A.Price) AS Total
FROM Zuschauer Z
JOIN Abonament A ON A.AbonamentID = Z.AbonamentID
GROUP BY A.AbonamentID, A.AbonamentTyp
HAVING COUNT(*) >= 3