--EX4
USE COMPUTER_STORE;
GO

CREATE TABLE UpdateLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    computer_ID INT,
    OldComputerCost DECIMAL(10, 2),
    NewComputerCost DECIMAL(10, 2),
    UpdateDate DATETIME
);
GO

CREATE OR ALTER PROCEDURE UpdateComputerCost
    @ComputerID INT,
    @scalar DECIMAL(10, 2)
AS
BEGIN
    DECLARE @OldComputerCost DECIMAL(10, 2);
    DECLARE @NewComputerCost DECIMAL(10, 2);

    SELECT @OldComputerCost = price
    FROM Computer
    WHERE computer_ID = @ComputerID;

    SET @NewComputerCost = @scalar * @OldComputerCost;

    UPDATE Computer
    SET price = @NewComputerCost
    WHERE computer_ID = @ComputerID;

    INSERT INTO UpdateLog (computer_ID, OldComputerCost, NewComputerCost, UpdateDate)
    VALUES (@ComputerID, @OldComputerCost, @NewComputerCost, GETDATE());
END;
GO

SELECT computer_ID, model_name, price FROM Computer;

DECLARE ComputerCursor CURSOR FOR
SELECT computer_ID, price
FROM Computer;

DECLARE @avgPrice DECIMAL(10, 2) = (SELECT AVG(price) FROM Computer);

DECLARE @ComputerID INT, @OldPrice DECIMAL(10, 2), @Scalar DECIMAL(10, 2);

OPEN ComputerCursor;
FETCH NEXT FROM ComputerCursor INTO @ComputerID, @OldPrice;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @OldPrice > @avgPrice
		SET @Scalar = 0.9;
    ELSE 
        SET @Scalar = 1.1;

	EXEC UpdateComputerCost @ComputerID, @Scalar;
    FETCH NEXT FROM ComputerCursor INTO @ComputerID, @OldPrice;
END

CLOSE ComputerCursor;
DEALLOCATE ComputerCursor;

SELECT computer_ID, model_name, price FROM Computer;

SELECT * FROM UpdateLog;
SELECT computer_ID, model_name, price FROM Computer;
DROP TABLE UpdateLog;