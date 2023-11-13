USE Lab3;

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