--EX 3
USE COMPUTER_STORE;
GO

CREATE TABLE Logger (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    LogDate DATETIME NOT NULL,
    LogType CHAR(1) NOT NULL,
    TableName NVARCHAR(100) NOT NULL,
    AffectedRows INT NOT NULL
);
GO

CREATE OR ALTER TRIGGER CustomerOperationTrigger
ON Customer
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @OperationType CHAR(1);
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        IF EXISTS (SELECT * FROM deleted)
            SET @OperationType = 'U';
        ELSE
            SET @OperationType = 'I';
    END
    ELSE
        SET @OperationType = 'D';
    INSERT INTO Logger (LogDate, LogType, TableName, AffectedRows)
    VALUES (GETDATE(), @OperationType, 'Customer', (SELECT COUNT(DISTINCT customer_ID) FROM (
            SELECT customer_ID FROM inserted
            UNION
            SELECT customer_ID FROM deleted
        ) AS CombinedTable));
END;
GO

SELECT * FROM Customer;
SELECT COUNT(*) FROM Customer;

INSERT INTO Customer (customer_ID, first_name, family_name, birth_date, email)
VALUES (111, 'John', 'Smith', '1985-05-15', 'john.smith@example.com')

UPDATE Customer
SET
    birth_date = '1990-01-01',
    email = 'updated_email@example.com'
WHERE customer_ID = 111;


DELETE FROM Customer
WHERE customer_ID = 111;

SELECT * FROM Logger;
DROP TABLE Logger;
DROP TRIGGER CustomerOperationTrigger;