--EX1:
USE COMPUTER_STORE;
GO

CREATE OR ALTER FUNCTION CheckOver18 (@BirthDate date) RETURNS BIT AS
	BEGIN
		DECLARE @IsOver18 BIT

		IF DATEDIFF(YEAR, @BirthDate, GETDATE()) >= 18
			SET @IsOver18 = 1
		ELSE
			SET @IsOver18 = 0

		RETURN @IsOver18
	END
GO


CREATE OR ALTER FUNCTION ValidateEmail (@UserEmail NVARCHAR (100)) RETURNS BIT AS
	BEGIN
		DECLARE @IsValid BIT = 0;

		IF @UserEmail LIKE '%@%'
			SET @IsValid = 1;

		RETURN @IsValid;
	END
GO

CREATE OR ALTER PROCEDURE InsertIntoCustomer
    @CustomerID INT,
    @FirstName NVARCHAR(50),
    @FamilyName NVARCHAR(50),
    @BirthDate DATE,
    @Email NVARCHAR(100)
AS
BEGIN
    DECLARE @IsOver18 BIT
    DECLARE @IsValidEmail BIT

    SET @IsOver18 = dbo.CheckOver18(@BirthDate)
    SET @IsValidEmail = dbo.ValidateEmail(@Email)
    IF @IsOver18 = 1 AND @IsValidEmail = 1
    BEGIN
        INSERT INTO Customer (customer_ID, first_name, family_name, birth_date, email)
        VALUES (@CustomerID, @FirstName, @FamilyName, @BirthDate, @Email)
        PRINT 'Data inserted successfully.'
    END
    ELSE
    BEGIN
		PRINT 'Validation failed. Data not inserted.'
		IF @IsOver18 = 0
			RAISERROR ('Customer must be over 18', 16, 1);
		ELSE
			RAISERROR ('Invalid email', 16, 1);
    END
END
GO

DELETE FROM Customer
WHERE Customer.customer_ID = 1001;


EXEC InsertIntoCustomer '1001', 'Bob','Dob', '1990-05-15','johndoe@example.com';
EXEC InsertIntoCustomer '1002', 'Zob', 'Zob', '2013-06-15', 'zobzob@example.com';
EXEC InsertIntoCustomer '1003', 'Cob', 'Cob', '1990-05-15', 'cob.com';

SELECT * FROM Customer;


--EX2:
CREATE OR ALTER VIEW OrderFinalPrice AS
    SELECT
        o.order_ID,
        SUM((1 + ISNULL(t.tax_percentage / 100, 0)) * (1 - ISNULL(d.discount_percentage / 100, 0))
				* com.price * co.computer_amount) AS final_price
    FROM [Order] o
    JOIN ComputerOrder co ON o.order_ID = co.order_ID
    JOIN Computer com ON co.computer_ID = com.computer_ID
    LEFT JOIN ComputerTax ct ON com.computer_ID = ct.computer_ID
    LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
    LEFT JOIN ComputerDiscount cd ON com.computer_ID = cd.computer_ID
    LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
    GROUP BY o.order_ID;
GO


SELECT * FROM OrderFinalPrice;


CREATE OR ALTER FUNCTION GetRepeatCustomers ( @repeatTimes INT ) RETURNS TABLE
AS RETURN (
    SELECT
        c.customer_id,
        c.first_name,
        c.family_name,
        COUNT(o.order_ID) AS purchase_count
    FROM Customer c
    JOIN [Order] o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.family_name
    HAVING COUNT(o.order_ID) >= @repeatTimes
);
GO


SELECT * FROM GetRepeatCustomers(2);


SELECT
    rc.customer_id,
    rc.first_name,
    rc.family_name,
    ofp.final_price AS total_spending
FROM
    dbo.GetRepeatCustomers(2) rc
JOIN
    dbo.OrderFinalPrice ofp ON rc.customer_id = ofp.order_ID