CREATE TABLE CurrentVersion (
	CurrentVersion INT PRIMARY KEY
);

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


CREATE OR ALTER PROCEDURE CreateTable(
    @tableName VARCHAR(100),
    @columnsDefinition VARCHAR(MAX)
)
AS
BEGIN
    DECLARE @sql VARCHAR(MAX);
    SET @sql = 'CREATE TABLE ' + @tableName + ' (' + @columnsDefinition + ')';
	PRINT @sql;
    EXEC (@sql);

	INSERT INTO VersionHistory (ProcedureName, tableName, columnsDefinition)
	VALUES ('CreateTable', @tableName, @columnsDefinition)
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

EXEC CreateTable 'ExampleTable1', 'ID INT PRIMARY KEY, Name NVARCHAR(255), Age INT';
EXEC CreateTable 'ExampleTable2', 'ProductID INT PRIMARY KEY, ProductName NVARCHAR(255), Price DECIMAL(10, 2)';

EXEC RollbackCreateTable 'ExampleTable1';
EXEC RollbackCreateTable 'ExampleTable2';

CREATE OR ALTER PROCEDURE AddForeignKeyConstraint(
    @tableName VARCHAR(100),
    @columnName VARCHAR(100),
    @referencedTable VARCHAR(100),
    @referencedColumn VARCHAR(100)
)
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);
    SET @sql = 'ALTER TABLE ' + @tableName + ' ADD CONSTRAINT FK_' + @tableName + '_' + @columnName +
               ' FOREIGN KEY (' + @columnName + ') REFERENCES ' + @referencedTable + '(' + @referencedColumn + ')';
	PRINT @sql;
	EXEC (@sql);

	INSERT INTO VersionHistory (ProcedureName, tableName, columnName, referencedTable, referencedColumn)
	VALUES ('AddForeignKeyConstraint', @tableName, @columnName, @referencedTable, @referencedColumn)
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

EXEC CreateTable 'Customers', 'CustomerID INT PRIMARY KEY, CustomerName NVARCHAR(255)';
EXEC CreateTable 'Orders', 'OrderID INT PRIMARY KEY, OrderDate DATETIME, CustomerID INT';
EXEC AddForeignKeyConstraint 'Orders', 'CustomerID', 'Customers', 'CustomerID';

EXEC RollbackAddForeignKeyConstraint 'Orders', 'CustomerID';
EXEC RollbackCreateTable 'Customers';
EXEC RollbackCreateTable 'Orders';


CREATE OR ALTER PROCEDURE AddColumnToTable(
	@tableName VARCHAR(100),
	@columnName VARCHAR(100),
	@columnType VARCHAR(100)
)
AS
    BEGIN
       DECLARE @sql VARCHAR(MAX);
       SET @sql = 'ALTER TABLE ' + @tableName +  ' ADD ' + @columnName + ' ' + @columnType;
	   PRINT @sql;
       EXEC (@sql);

	   INSERT INTO VersionHistory (ProcedureName, tableName, columnName, columnType)
	   VALUES ('AddColumnToTable', @tableName, @columnName, @columnType)
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

EXEC CreateTable 'Customers', 'CustomerID INT PRIMARY KEY, CustomerName NVARCHAR(255)';
EXEC AddColumnToTable 'Customers', 'Age', 'INT';

EXEC RollbackAddColumnToTable 'Customers', 'Age';
EXEC RollbackCreateTable 'Customers';



CREATE OR ALTER PROCEDURE AddDefaultConstraint(
	@tableName VARCHAR(100),
	@columnName VARCHAR(100),
	@defaultConstraint VARCHAR(100)
)
AS
    BEGIN
       DECLARE @sql VARCHAR(MAX);
       SET @sql = 'ALTER TABLE ' + @tableName + ' ADD CONSTRAINT DF_' 
					+ @tableName + '_' + @columnName + ' DEFAULT ' + @defaultConstraint + ' FOR ' + @columnName;
       PRINT @sql
       EXEC (@sql);

	   INSERT INTO VersionHistory (ProcedureName, tableName, columnName, defaultConstraint)
	   VALUES ('AddDefaultConstraint', @tableName, @columnName, @defaultConstraint)
    END
GO

CREATE OR ALTER PROCEDURE RollbackAddDefaultConstraint(
	@tableName VARCHAR(100),
	@columnName VARCHAR(100)
)
AS
    BEGIN
       DECLARE @sql VARCHAR(MAX);
       SET @sql = 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT DF_' + @tableName + '_' + @columnName;
	   PRINT @sql
       EXEC (@sql);
    END
GO

EXEC CreateTable 'Customers', 'CustomerID INT PRIMARY KEY, CustomerName NVARCHAR(255)';
EXEC AddColumnToTable 'Customers', 'Age', 'INT';
EXEC AddDefaultConstraint 'Customers', 'Age', '18';
EXEC AddDefaultConstraint 'Customers', 'CustomerName', '''Nume''';

INSERT INTO Customers (CustomerID) VALUES (1);

EXEC RollbackAddDefaultConstraint 'Customers', 'Age';
EXEC RollbackAddDefaultConstraint 'Customers', 'CustomerName';
EXEC RollbackAddColumnToTable 'Customers', 'Age';
EXEC RollbackCreateTable 'Customers';



CREATE OR ALTER PROCEDURE ChangeColumnType (
	@tableName VARCHAR(100),
	@columnName VARCHAR(100),
	@columnType VARCHAR(100)
)
AS
	BEGIN
		DECLARE @sql VARCHAR(MAX);
		SET @sql = 'ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + @columnName + ' ' + @columnType;
		EXEC (@sql);
	END;
GO


CREATE OR ALTER PROCEDURE RollBackChangeColumnType(
	@tableName VARCHAR(100),
	@columnName VARCHAR(100),
	@originalDataType VARCHAR(100)
)
AS
    BEGIN
       DECLARE @sql VARCHAR(MAX);
       SET @sql = 'ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + @columnName + ' ' + @originalDataType;
       EXEC (@sql);
    END;
GO

EXEC CreateTable 'Customers', 'CustomerID INT PRIMARY KEY, CustomerName NVARCHAR(255)';
EXEC AddColumnToTable 'Customers', 'Age', 'INT';
EXEC ChangeColumnType 'Customers', 'Age', 'VARCHAR(50)';

EXEC RollBackChangeColumnType 'Customers', 'Age', 'INT';
EXEC RollbackAddColumnToTable 'Customers', 'Age';
EXEC RollbackCreateTable 'Customers';