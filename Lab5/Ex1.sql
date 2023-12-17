USE Lab5;
GO


CREATE OR ALTER PROCEDURE CreateTables
AS
BEGIN
    CREATE TABLE Ta (
        idA INT PRIMARY KEY,
        a2 INT UNIQUE,
		a3 INT,
    );

    CREATE TABLE Tb (
        idB INT PRIMARY KEY,
        b2 INT,
        b3 INT,
    );

    CREATE TABLE Tc (
        idC INT PRIMARY KEY,
        idA INT,
        idB INT,
        FOREIGN KEY (idA) REFERENCES Ta(idA),
        FOREIGN KEY (idB) REFERENCES Tb(idB)
    );
END
GO


CREATE OR ALTER PROCEDURE DropTables
AS
BEGIN
    DROP TABLE IF EXISTS Tc;
    DROP TABLE IF EXISTS Tb;
    DROP TABLE IF EXISTS Ta;
END
GO


CREATE OR ALTER PROCEDURE InsertData
AS
BEGIN
    DECLARE @i INT = 1;
    WHILE @i <= 10000
    BEGIN
		INSERT INTO Ta (idA, a2, a3) VALUES (@i, @i * 2, @i * 3);
        SET @i = @i + 1;
    END;

    SET @i = 1;

    WHILE @i <= 3000
	BEGIN
        INSERT INTO Tb (idB, b2, b3) VALUES (@i, @i * 5, @i * 10);
        SET @i = @i + 1;
    END;

    SET @i = 1;

    WHILE @i <= 30000
    BEGIN
		DECLARE @idA_val INT;
        DECLARE @idB_val INT;

        SET @idA_val = FLOOR(RAND() * 10000) + 1;
        SET @idB_val = FLOOR(RAND() * 3000) + 1;

        INSERT INTO Tc (idC, idA, idB) VALUES (@i, @idA_val, @idB_val);
        SET @i = @i + 1;
    END;
END




EXEC CreateTables;

EXEC InsertData;

SELECT COUNT(*) FROM Ta;
SELECT COUNT(*) FROM Tb;
SELECT COUNT(*) FROM Tc;

SELECT * FROM Ta;
SELECT * FROM Tb;
SELECT * FROM Tc;

EXEC DropTables;
