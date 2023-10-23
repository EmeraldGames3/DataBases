USE COMPUTER_STORE

--Create new table TransportCompany
CREATE TABLE TransportCompany(
	transport_company_ID INT PRIMARY KEY,
	transport_company_name VARCHAR(30),
	transport_company_email VARCHAR(30),
);

--Modify Transportation table
ALTER TABLE Transportation
ADD transport_company_ID INT,
FOREIGN KEY (transport_company_ID) REFERENCES TransportCompany(transport_company_ID);

--Create new table Address
CREATE TABLE [Address](
	address_ID INT PRIMARY KEY,
	county VARCHAR(30),
	settlement VARCHAR(30),
	street VARCHAR(30),
	street_number INT,
);

--Create new table CustomerAddress with composite primary key
CREATE TABLE CustomerAddress (
    customer_ID INT,
    address_ID INT,
    PRIMARY KEY (customer_ID, address_ID),
    FOREIGN KEY (customer_ID) REFERENCES Customer(customer_ID),
    FOREIGN KEY (address_ID) REFERENCES Address(address_ID)
);

-- List foreign key constraints for the Computer table
SELECT
    f.name AS foreign_key_name
FROM sys.foreign_keys AS f
INNER JOIN sys.tables AS t
    ON f.parent_object_id = t.object_id
WHERE t.name = 'Computer';

-- Remove the foreign key constraint on the order_ID column in the Computer table
ALTER TABLE Computer
DROP CONSTRAINT FK__Computer__order___59FA5E80;

-- Create a new table to represent the relationship between Computer and Order
CREATE TABLE ComputerOrder (
    computer_ID INT,
    order_ID INT,
    PRIMARY KEY (computer_ID, order_ID),
    FOREIGN KEY (computer_ID) REFERENCES Computer(computer_ID),
    FOREIGN KEY (order_ID) REFERENCES [Order](order_ID)
);

-- Add a shipped column to the Order table
ALTER TABLE [Order]
ADD shipped BIT;