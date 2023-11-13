USE Lab3;

CREATE OR ALTER PROCEDURE SetUp
AS
BEGIN
	CREATE TABLE currentVersion (CurrentVersion INT PRIMARY KEY);

	INSERT INTO currentVersion (CurrentVersion) VALUES (0);

	CREATE TABLE VersionHistory (
		VersionID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ProcedureName VARCHAR(50),
        tableName VARCHAR(100),
        columnsDefinition VARCHAR(MAX),
        columnName VARCHAR(100),
        columnType VARCHAR(100),
        defaultConstraint VARCHAR(100),
        oldColumnType VARCHAR(100),
        referencedTable VARCHAR(100),
        referencedColumn VARCHAR(100)
	);
END;

CREATE OR ALTER PROCEDURE RollbackSetUp
AS
BEGIN
	DROP TABLE currentVersion;
	DROP TABLE VersionHistory;
END;


CREATE OR ALTER PROCEDURE ShowVersionHistory
AS
BEGIN
	SELECT * FROM VersionHistory;
	SELECT * FROM currentVersion;
END;


CREATE OR ALTER PROCEDURE CreateTable(
    @tableName VARCHAR(100),
    @columnsDefinition VARCHAR(MAX),
	@addToVersionHistory BIT = 1
)
AS
BEGIN
    DECLARE @sql VARCHAR(MAX);
    SET @sql = 'CREATE TABLE ' + @tableName + ' (' + @columnsDefinition + ')';
	PRINT @sql;
    EXEC (@sql);


	IF @addToVersionHistory = 1
		BEGIN
			INSERT INTO VersionHistory (ProcedureName, tableName, columnsDefinition)
				VALUES ('CreateTable', @tableName, @columnsDefinition);

			IF EXISTS (SELECT * FROM currentVersion)
				UPDATE currentVersion
				SET CurrentVersion = (SELECT MAX(VersionID) FROM VersionHistory)
			ELSE		
				INSERT INTO currentVersion
				VALUES ((SELECT MAX(VersionID) FROM VersionHistory))
		END;
END
GO

CREATE OR ALTER PROCEDURE RollbackCreateTable(
	@tableName VARCHAR(100)
)
AS
BEGIN
    IF OBJECT_ID(@tableName, 'U') IS NOT NULL
    BEGIN
        DECLARE @sql VARCHAR(MAX);
        SET @sql = 'DROP TABLE ' + @tableName;
        PRINT @sql;
		EXEC (@sql);
    END
END
GO



CREATE OR ALTER PROCEDURE AddForeignKeyConstraint(
    @tableName VARCHAR(100),
    @columnName VARCHAR(100),
    @referencedTable VARCHAR(100),
    @referencedColumn VARCHAR(100),
	@addToVersionHistory BIT = 1
)
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);
    SET @sql = 'ALTER TABLE ' + @tableName + ' ADD CONSTRAINT FK_' + @tableName + '_' + @columnName +
               ' FOREIGN KEY (' + @columnName + ') REFERENCES ' + @referencedTable + '(' + @referencedColumn + ')';
	PRINT @sql;
	EXEC (@sql);

	
	IF @addToVersionHistory = 1
		BEGIN
			INSERT INTO VersionHistory (ProcedureName, tableName, columnName, referencedTable, referencedColumn)
				VALUES ('AddForeignKeyConstraint', @tableName, @columnName, @referencedTable, @referencedColumn);

			IF EXISTS (SELECT * FROM currentVersion)
				UPDATE currentVersion
				SET CurrentVersion = (SELECT MAX(VersionID) FROM VersionHistory)
			ELSE		
				INSERT INTO currentVersion
				VALUES ((SELECT MAX(VersionID) FROM VersionHistory))
		END;
END
GO

CREATE OR ALTER PROCEDURE RollbackAddForeignKeyConstraint(
    @tableName VARCHAR(100),
    @columnName VARCHAR(100)
)
AS
BEGIN
    DECLARE @sql VARCHAR(MAX);
    SET @sql = 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT FK_' + @tableName + '_' + @columnName;
	PRINT @sql;
    EXEC (@sql);
END
GO



CREATE OR ALTER PROCEDURE AddColumnToTable(
	@tableName VARCHAR(100),
	@columnName VARCHAR(100),
	@columnType VARCHAR(100),
	@addToVersionHistory BIT = 1
)
AS
   BEGIN
       DECLARE @sql VARCHAR(MAX);
       SET @sql = 'ALTER TABLE ' + @tableName +  ' ADD ' + @columnName + ' ' + @columnType;
	   PRINT @sql;
       EXEC (@sql);

	IF @addToVersionHistory = 1
	BEGIN
		INSERT INTO VersionHistory (ProcedureName, tableName, columnName, columnType)
			VALUES ('AddColumnToTable', @tableName, @columnName, @columnType);
	
			IF EXISTS (SELECT * FROM currentVersion)
				UPDATE currentVersion
				SET CurrentVersion = (SELECT MAX(VersionID) FROM VersionHistory)
			ELSE		
				INSERT INTO currentVersion
				VALUES ((SELECT MAX(VersionID) FROM VersionHistory))
	END;
END
GO

CREATE OR ALTER PROCEDURE RollbackAddColumnToTable(
	@tableName VARCHAR(100),
	@columnName VARCHAR(100))
AS
    BEGIN
       DECLARE @sql VARCHAR(MAX);
       SET @sql = 'ALTER TABLE ' + @tableName + ' DROP COLUMN ' + @columnName;
	   PRINT @sql;
       EXEC (@sql);
    END
GO



CREATE OR ALTER PROCEDURE AddDefaultConstraint(
	@tableName VARCHAR(100),
	@columnName VARCHAR(100),
	@defaultConstraint VARCHAR(100),
	@addToVersionHistory BIT = 1
)
AS
	BEGIN
		DECLARE @sql VARCHAR(MAX);
		SET @sql = 'ALTER TABLE ' + @tableName + ' ADD CONSTRAINT DF_' 
					+ @tableName + '_' + @columnName + ' DEFAULT ' + @defaultConstraint + ' FOR ' + @columnName;
		PRINT @sql
		EXEC (@sql);

		IF @addToVersionHistory = 1
			BEGIN
				INSERT INTO VersionHistory (ProcedureName, tableName, columnName, defaultConstraint)
				VALUES ('AddDefaultConstraint', @tableName, @columnName, @defaultConstraint);
	
				IF EXISTS (SELECT * FROM currentVersion)
					UPDATE currentVersion
					SET CurrentVersion = (SELECT MAX(VersionID) FROM VersionHistory)
				ELSE		
					INSERT INTO currentVersion
					VALUES ((SELECT MAX(VersionID) FROM VersionHistory))
			END;
    END;
GO

CREATE OR ALTER PROCEDURE RollbackAddDefaultConstraint(
	@tableName VARCHAR(100),
	@columnName VARCHAR(100)
)
AS
    BEGIN
       DECLARE @sql VARCHAR(MAX);
       SET @sql = 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT DF_' + @tableName + '_' + @columnName;
	   PRINT @sql;
       EXEC (@sql);
    END
GO



CREATE OR ALTER PROCEDURE ChangeColumnType (
	@tableName VARCHAR(100),
	@columnName VARCHAR(100),
	@columnType VARCHAR(100),
	@addToVersionHistory BIT = 1
)
AS
	BEGIN
		DECLARE @oldColumnType as varchar(100)
		SET @oldColumnType = (SELECT T.DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS T 
								WHERE TABLE_NAME = @tableName  AND COLUMN_NAME = @columnName)
		DECLARE @length as varchar(100)
		SET @length = (SELECT T.CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS T 
						WHERE TABLE_NAME = @tableName  AND COLUMN_NAME = @columnName)
		IF @length IS NOT NULL
			SET @oldColumnType = @oldColumnType + '(' + @length + ')'

		DECLARE @sql VARCHAR(MAX);
		SET @sql = 'ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + @columnName + ' ' + @columnType;
		PRINT @sql;
		EXEC (@sql);

		IF @addToVersionHistory = 1
			BEGIN
				INSERT INTO VersionHistory (ProcedureName, tableName, columnName, columnType, oldColumnType)
					VALUES ('ChangeColumnType', @tableName, @columnName, @columnType, @oldColumnType);

				IF EXISTS (SELECT * FROM currentVersion)
					UPDATE currentVersion
					SET CurrentVersion = (SELECT MAX(VersionID) FROM VersionHistory)
				ELSE		
					INSERT INTO currentVersion
					VALUES ((SELECT MAX(VersionID) FROM VersionHistory))
			END;
	END;
GO

CREATE OR ALTER PROCEDURE RollBackChangeColumnType(
	@tableName VARCHAR(100),
	@columnName VARCHAR(100),
	@oldColumnType VARCHAR(100)
)
AS
    BEGIN
       DECLARE @sql VARCHAR(MAX);
       SET @sql = 'ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + @columnName + ' ' + @oldColumnType;
	   PRINT @sql;
       EXEC (@sql);
    END;
GO




CREATE OR ALTER PROCEDURE GoToVersion(@targetVersion INT)
AS
BEGIN
    DECLARE @currentVersion INT;
	DECLARE @procedureName VARCHAR(100);
	DECLARE @tableName VARCHAR(100);
	DECLARE @columnsDefinition VARCHAR(100);
	DECLARE @columnName VARCHAR(100);
	DECLARE @columnType VARCHAR(100);
	DECLARE @defaultConstraint VARCHAR(100);
	DECLARE @oldColumnType VARCHAR(100);
	DECLARE @referencedTable VARCHAR(100);
	DECLARE @referencedColumn VARCHAR(100);

    SELECT @currentVersion = CurrentVersion FROM currentVersion;

    IF @targetVersion >= 0 AND @targetVersion < @currentVersion
    BEGIN
        WHILE @currentVersion > @targetVersion
        BEGIN
            SELECT @procedureName = ProcedureName FROM VersionHistory WHERE VersionID = @currentVersion;
			SELECT @tableName = tableName FROM VersionHistory WHERE VersionID = @currentVersion;
			SELECT @columnName = columnName FROM VersionHistory WHERE VersionID = @currentVersion;
			SELECT @oldColumnType = oldColumnType FROM VersionHistory WHERE VersionID = @currentVersion;

			DECLARE @rollbackProcedure VARCHAR(100) = 'Rollback' + @procedureName;

			IF @procedureName = 'CreateTable'
				BEGIN
					EXEC @rollbackProcedure @tableName;
				END
			ELSE IF @procedureName = 'AddForeignKeyConstraint'
				BEGIN
					EXEC @rollbackProcedure @tableName, @columnName;
				END
			ELSE IF @procedureName = 'AddColumnToTable'
				BEGIN
					EXEC @rollbackProcedure @tableName, @columnName;
				END
			ELSE IF @procedureName = 'AddDefaultConstraint'
				BEGIN
					EXEC @rollbackProcedure @tableName, @columnName;
				END
			ELSE IF @procedureName = 'ChangeColumnType'
				BEGIN
					EXEC @rollbackProcedure @tableName, @columnName, @oldColumnType;
				END


            SET @currentVersion = @currentVersion - 1;

            UPDATE currentVersion
            SET CurrentVersion = @currentVersion;
        END;
    END;

	ELSE IF @targetVersion > @currentVersion AND @targetVersion <= (SELECT MAX(VersionID) FROM VersionHistory)
    BEGIN
        WHILE @currentVersion < @targetVersion
        BEGIN
            SELECT @procedureName = ProcedureName FROM VersionHistory WHERE VersionID = (@currentVersion + 1);
			SELECT @tableName = tableName FROM VersionHistory WHERE VersionID = (@currentVersion + 1);
			SELECT @columnsDefinition = columnsDefinition FROM VersionHistory WHERE VersionID = (@currentVersion + 1)
			SELECT @columnName = columnName FROM VersionHistory WHERE VersionID = (@currentVersion + 1);
			SELECT @columnType = columnType FROM VersionHistory WHERE VersionID = (@currentVersion + 1);
			SELECT @referencedTable = referencedTable FROM VersionHistory WHERE VersionID = (@currentVersion + 1);
			SELECT @referencedColumn = referencedColumn FROM VersionHistory WHERE VersionID = (@currentVersion + 1);
			SELECT @defaultConstraint = defaultConstraint FROM VersionHistory WHERE VersionID = (@currentVersion + 1);

			IF @procedureName = 'CreateTable'
				BEGIN
					EXEC @procedureName @tableName, @columnsDefinition, 0;
				END
			ELSE IF @procedureName = 'AddForeignKeyConstraint'
				BEGIN
					EXEC @procedureName @tableName, @columnName, @referencedTable, @referencedColumn, 0;
				END
			ELSE IF @procedureName = 'AddColumnToTable'
				BEGIN
					EXEC @procedureName @tableName, @columnName, @columnType, 0;
				END
			ELSE IF @procedureName = 'AddDefaultConstraint'
				BEGIN
					EXEC @procedureName @tableName, @columnName, @defaultConstraint, 0;
				END
			ELSE IF @procedureName = 'ChangeColumnType'
				BEGIN
					PRINT @columnType;
					EXEC @procedureName @tableName, @columnName, @columnType, 0;
				END

            SET @currentVersion = @currentVersion + 1;

            UPDATE currentVersion
            SET CurrentVersion = @currentVersion;
        END;
    END;
END;


EXEC SetUp;
EXEC CreateTable 'Customers', 'CustomerID INT PRIMARY KEY, CustomerName NVARCHAR(255)';
EXEC AddColumnToTable 'Customers', 'Age', 'INT';
EXEC ChangeColumnType 'Customers', 'CustomerName', 'CHAR(20)';
EXEC AddDefaultConstraint 'Customers', 'CustomerName', '''Nume''';
EXEC AddDefaultConstraint 'Customers', 'Age', '18';
EXEC CreateTable 'Orders', 'OrderID INT PRIMARY KEY, OrderDate DATETIME, CustomerID INT';
EXEC AddForeignKeyConstraint 'Orders', 'CustomerID', 'Customers', 'CustomerID';

EXEC ShowVersionHistory;

EXEC GoToVersion 2;
EXEC GoToVersion 3;
EXEC GoToVersion 0;
EXEC GoToVersion 5;
EXEC GoToVersion 7;

EXEC GoToVersion 0;
EXEC RollbackSetUp;