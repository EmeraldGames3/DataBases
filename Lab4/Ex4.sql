--EX4
CREATE TABLE UpdateLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    OldComputerCost DECIMAL(10, 2),
    NewComputerCost DECIMAL(10, 2),
    UpdateDate DATETIME
);

CREATE OR ALTER PROCEDURE UpdateComputerCost
    @ComputerID INT,
    @NewComputerCost DECIMAL(10, 2)
AS
BEGIN
    DECLARE @OldComputerCost DECIMAL(10, 2);

    SELECT @OldComputerCost = price
    FROM Computer
    WHERE computer_ID = @ComputerID;

    UPDATE Computer
    SET price = @NewComputerCost
    WHERE computer_ID = @ComputerID;

    INSERT INTO UpdateLog (EmployeeID, OldComputerCost, NewComputerCost, UpdateDate)
    VALUES (@ComputerID, @OldComputerCost, @NewComputerCost, GETDATE());
END;


DECLARE ComputerCursor CURSOR FOR
SELECT computer_ID, price
FROM Computer;

DECLARE @ComputerID INT, @OldPrice DECIMAL(10, 2), @NewPrice DECIMAL(10, 2);

OPEN ComputerCursor;

FETCH NEXT FROM ComputerCursor INTO @ComputerID, @OldPrice;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @NewPrice = @OldPrice * 1.1;
    EXEC UpdateComputerCost @ComputerID, @NewPrice;

    FETCH NEXT FROM ComputerCursor INTO @ComputerID, @OldPrice;
END

CLOSE ComputerCursor;
DEALLOCATE ComputerCursor;

SELECT * FROM UpdateLog;
DROP TABLE UpdateLog;