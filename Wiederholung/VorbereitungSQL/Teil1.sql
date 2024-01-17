
-- Creating tables
CREATE TABLE Doctors(
	doctorID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	firstName VARCHAR(50),
	lastName VARCHAR(50),
	dateOfBirth DATE
)
GO
CREATE TABLE Hospitals(
	hospitalID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	hospitalName VARCHAR(50) NOT NULL
);
GO
CREATE TABLE Departments(
	departmentID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	departmentName VARCHAR(50) NOT NULL,
	hospitalID INT NOT NULL FOREIGN KEY REFERENCES Hospitals(hospitalID)
);
GO
CREATE TABLE EnrolledDocs(
enrolledDocID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
departmentID INT NOT NULL,
doctorID INT NOT NULL,
FOREIGN KEY (departmentID) REFERENCES Departments(departmentID),
FOREIGN KEY (doctorID) REFERENCES Doctors(doctorID)
);
GO

-- Function that checks age(Scalar function)
CREATE OR ALTER FUNCTION CheckAge(
	@dateOfBirth DATE
)
RETURNS BIT
AS
BEGIN
    DECLARE @isValid bit
    IF DATEDIFF(YEAR, @dateOfBirth, GETDATE()) >= 35
			SET @isValid = 1
		ELSE
			SET @isValid = 0

		RETURN @isValid
END
GO 

-- Function to populate Doctors
CREATE OR ALTER PROCEDURE PopulateDoctors(
	@firstName VARCHAR(50),
	@lastName VARCHAR(50),
	@dateOfBirth DATE
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @isValid BIT
	SET @isValid = dbo.CheckAge(@dateOfBirth)
	IF @isValid = 1
	BEGIN
		INSERT INTO Doctors(firstName,lastName,dateOfBirth)
		VALUES (@firstName,@lastName,@dateOfBirth);
		PRINT 'Data inserted successfully.'
	END
	ELSE
	BEGIN
		PRINT 'Data not inserted.'
	END
END
GO
EXEC PopulateDoctors 'John', 'Doe','1980-01-01';
EXEC PopulateDoctors 'Jane', 'Doe','2003-01-01';

-- Procedure to create a table
CREATE OR ALTER PROCEDURE CreateTable(
	@tableName VARCHAR(50),
	@tableInfo VARCHAR(MAX)
)
AS
BEGIN
	DECLARE @sqlQuery VARCHAR(MAX)
	SET @sqlQuery = 'CREATE TABLE ' + @tableName + '(' + @tableInfo + ')'
	PRINT @sqlQuery
	EXEC (@sqlQuery)
END
GO
-- Procedure to drop a table
CREATE OR ALTER PROCEDURE DropTable(@tableName VARCHAR(50))
AS
BEGIN
    IF OBJECT_ID(@tableName, 'U') IS NOT NULL
    BEGIN
        DECLARE @sqlQuery AS VARCHAR(MAX)
        SET @sqlQuery = 'DROP TABLE ' + @tableName
        PRINT @sqlQuery
        EXEC (@sqlQuery)
    END
END
GO
EXEC DropTable 'Patients';
EXEC CreateTable 'Patients',
'	patientID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	firstName VARCHAR(50),
	lastName VARCHAR(50),
	dateOfBirth DATE';

CREATE OR ALTER PROCEDURE AddNewColumn(
	@tableName VARCHAR(50),
	@columnName VARCHAR(50),
	@columnType VARCHAR(50)
)
AS
BEGIN
	DECLARE @sqlQuery VARCHAR(MAX)
	SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' ADD ' + @columnName + ' ' + @columnType
	PRINT @sqlQuery
	EXEC (@sqlQuery)
END
GO

CREATE OR ALTER PROCEDURE DropColumn(
	@tableName VARCHAR(50),
	@columnName VARCHAR(50)
)
AS
BEGIN
	DECLARE @sqlQuery VARCHAR(MAX)
	SET @sqlQuery = 'ALTER TABLE '+ @tableName + ' DROP COLUMN ' + @columnName
	PRINT @sqlQuery
	EXEC (@sqlQuery)
END
GO

EXEC AddNewColumn 'Doctors','address','VARCHAR(50)';
EXEC DropColumn 'Doctors','address';

CREATE OR ALTER PROCEDURE ChangeColumnType(
	@tableName VARCHAR(50),
	@columnName VARCHAR(50),
	@columnType VARCHAR(50)
)
AS
BEGIN
	DECLARE @sqlQuery VARCHAR(MAX)
	SET @sqlQuery = 'ALTER TABLE '+ @tableName + ' ALTER COLUMN ' + @columnName + ' ' + @columnType
	PRINT @sqlQuery
	EXEC (@sqlQuery)
END
GO
EXEC ChangeColumnType 'Doctors','address','VARCHAR(100)';
CREATE OR ALTER PROCEDURE DefaultConstraint(
	@tableName VARCHAR(50),
	@columnName VARCHAR(50),
	@defaultConstraint VARCHAR(100)
)
AS
BEGIN
	DECLARE @sqlQuery VARCHAR(MAX)
    SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' ADD CONSTRAINT DF_' +
               @tableName + '_' + @columnName + ' DEFAULT ' + @defaultConstraint + ' FOR ' + @columnName
	PRINT @sqlQuery
	EXEC (@sqlQuery)
END
GO
EXEC DefaultConstraint 'Doctors','address','''Address''';
CREATE OR ALTER PROCEDURE DropDefaultConstraint(
	@tableName VARCHAR(50),
	@columnName VARCHAR(50)
)
AS
BEGIN
	DECLARE @sqlQuery VARCHAR(MAX)
	SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT DF_' + @tableName + '_' + @columnName 
	PRINT @sqlQuery
	EXEC (@sqlQuery)
END
GO
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
               ' FOREIGN KEY (' + @columnName + ') REFERENCES ' + @referencedTable + '(' + @referencedColumn + ')'
    PRINT @sql;
    EXEC (@sql);

END
GO
CREATE OR ALTER PROCEDURE DropForeignKeyConstraint(
	@tableName VARCHAR(50),
	@columnName VARCHAR(50)
)
AS
BEGIN
	DECLARE @sqlQuery VARCHAR(MAX)
	SET @sqlQuery = 'ALTER TABLE ' + @tableName +' DROP CONSTRAINT FK_'+ @tableName +'_'+@columnName 
	PRINT @sqlQuery
	EXEC (@sqlQuery)
END
GO
CREATE OR ALTER FUNCTION GetEnrolledDoctorsByHospitalID(@HospitalID INT)
RETURNS TABLE
AS
RETURN(
	SELECT E.enrolledDocID AS EnrolledDocID,D.departmentName AS DepartmentName,D.hospitalID
	FROM EnrolledDocs E
	INNER JOIN Departments D ON E.departmentID = D.departmentID
	WHERE D.hospitalID = @HospitalID
)
GO
CREATE OR ALTER VIEW DoctorsDelatils
AS
	SELECT D.firstName AS firstName,
		   D.lastName AS lastName,
		   E.enrolledDocID AS EnrolledDocID
	FROM Doctors D
	INNER JOIN EnrolledDocs E ON D.doctorID = E.enrolledDocID
GO
SELECT D.firstName,D.lastName,T.DepartmentName,T.hospitalID
FROM DoctorsDelatils D
INNER JOIN GetEnrolledDoctorsByHospitalID(3) T ON D.EnrolledDocID = T.EnrolledDocID
