USE COMPUTER_STORE

-- Insert data into the Customer table for 15 customers
INSERT INTO Customer (customer_ID, first_name, family_name, birth_date, email)
VALUES
    (1, 'John', 'Smith', '1985-05-15', 'john.smith@example.com'),
    (2, 'Alice', 'Johnson', '1990-08-22', 'alice.johnson@example.com'),
    (3, 'Michael', 'Brown', '1982-04-10', 'michael.brown@example.com'),
    (4, 'Emily', 'Davis', '1995-11-30', 'emily.davis@example.com'),
    (5, 'Daniel', 'Miller', '1987-03-18', 'daniel.miller@example.com'),
    (6, 'Olivia', 'Wilson', '1992-09-25', 'olivia.wilson@example.com'),
    (7, 'David', 'Lee', '1980-07-14', 'david.lee@example.com'),
    (8, 'Sophia', 'Harris', '1998-01-07', 'sophia.harris@example.com'),
    (9, 'Matthew', 'Jackson', '1989-06-20', 'matthew.jackson@example.com'),
    (10, 'Emma', 'White', '1994-02-12', 'emma.white@example.com'),
    (11, 'William', 'Martinez', '1983-08-29', 'william.martinez@example.com'),
    (12, 'Ava', 'Anderson', '1996-04-03', 'ava.anderson@example.com'),
    (13, 'James', 'Taylor', '1981-10-26', 'james.taylor@example.com'),
    (14, 'Lily', 'Garcia', '1997-05-08', 'lily.garcia@example.com'),
    (15, 'Benjamin', 'Rodriguez', '1984-12-17', 'benjamin.rodriguez@example.com');

-- Insert data into the Address table for customers
INSERT INTO Address (address_ID, county, settlement, street, street_number)
VALUES
    (1, 'Los Angeles County', 'Los Angeles', 'Main Street', 123),
    (2, 'San Francisco County', 'San Francisco', 'Oak Street', 789),
    (3, 'New York County', 'New York', 'Broadway', 456),
    (4, 'Los Angeles County', 'Los Angeles', 'Main Street', 123),
    (5, 'San Francisco County', 'San Francisco', 'Oak Street', 789),
    (6, 'San Francisco County', 'San Francisco', 'Oak Street', 789),
    (7, 'Los Angeles County', 'Los Angeles', 'Hillside Avenue', 567),
    (8, 'New York County', 'New York', 'Broadway', 456),
    (9, 'San Francisco County', 'San Francisco', 'Market Street', 321),
    (10, 'Los Angeles County', 'Los Angeles', 'Hillside Avenue', 567),
    (11, 'New York County', 'New York', '5th Avenue', 987),
    (12, 'San Francisco County', 'San Francisco', 'Market Street', 321),
    (13, 'San Francisco County', 'San Francisco', 'Market Street', 321),
    (14, 'Los Angeles County', 'Los Angeles', 'Sunset Boulevard', 654),
    (15, 'New York County', 'New York', '5th Avenue', 987);

-- Insert data into the CustomerAddress table to establish relationships
INSERT INTO CustomerAddress (customer_ID, address_ID)
VALUES
    (1, 1),  -- John Smith shares Address ID 1 with another customer
    (2, 2),  -- Alice Johnson shares Address ID 2 with another customer
    (3, 3),  -- Michael Brown has Address ID 3
    (4, 1),  -- Emily Davis shares Address ID 1 with John Smith
    (5, 4),  -- Daniel Miller has Address ID 4
    (6, 5),  -- Olivia Wilson has Address ID 5
    (7, 6),  -- David Lee shares Address ID 6 with another customer
    (8, 3),  -- Sophia Harris shares Address ID 3 with Michael Brown
    (9, 7),  -- Matthew Jackson has Address ID 7
    (10, 8), -- Emma White has Address ID 8
    (11, 2), -- William Martinez shares Address ID 2 with Alice Johnson
    (12, 9), -- Ava Anderson has Address ID 9
    (13, 10), -- James Taylor has Address ID 10
    (14, 11), -- Lily Garcia has Address ID 11
    (15, 12), -- Benjamin Rodriguez has Address ID 12
    (15, 13); -- Benjamin Rodriguez shares Address ID 13 with another customer

-- Insert data into the TransportCompany table
INSERT INTO TransportCompany (transport_company_ID, transport_company_name, transport_company_email)
VALUES
    (2, 'FastShip', 'info@fastship.com'),
    (3, 'SwiftTransport', 'info@swifttransport.com');

-- Insert data into the Transportation table
INSERT INTO Transportation (transportation_ID, transportation_method, transport_company_ID)
VALUES
    (1, 'Express Delivery', 2),  -- Using 'FastShip' for Express Delivery
    (2, 'Standard Shipping', 3);  -- Using 'SwiftTransport' for Standard Shipping

-- Insert data into the OperatingSystem table
INSERT INTO OperatingSystem (os_ID, os_name, os_version)
VALUES
    (1, 'Windows', '11'),
    (2, 'Mac OS', 'Monterey'),
    (3, 'Linux', 'Fedora 35');

-- Insert data into the Manufacturer table
INSERT INTO Manufacturer (manufacturer_ID, manufacturer_name, manufacturer_email)
VALUES
    (1, 'Asus', 'info@asus.com'),
    (2, 'Acer', 'info@acer.com'),
    (3, 'Sony', 'info@sony.com'),
    (4, 'Toshiba', 'info@toshiba.com'),
    (5, 'MSI', 'info@msi.com');

-- Insert data into the ComputerCategory table
INSERT INTO ComputerCategory (computer_category_ID, category_name, category_description)
VALUES
    (1, 'Gaming Laptop', 'High-performance gaming'),
    (2, 'All-in-One PC', 'Integrated desktop monitor'),
    (3, 'Convertible Laptop', '2-in-1 design');

-- Insert data into the Tax table
INSERT INTO Tax (tax_ID, tax_name, tax_percentage)
VALUES
    (1, 'Green Tax', 8.5),
    (2, 'VAT Tax', 20.0);

-- Insert data into the Discount
INSERT INTO Discount (discount_ID, discount_name, discount_percentage, is_active)
VALUES
    (1, 'Back to School Sale', 10.0, 1),
    (2, 'Season Clearance', 15.0, 0);

-- Insert data into the Computer table
INSERT INTO Computer (computer_ID, model_name, price, computer_category_ID, os_ID, manufacturer_ID)
VALUES
    (1, 'SwiftBook Pro', 1200, 1, 1, 1),
    (2, 'FusionStation X', 900, 2, 2, 2),
    (3, 'UltraBook Elite', 1500, 1, 2, 3),
    (4, 'Performance 2000', 1100, 2, 1, 4),
    (5, 'EcoBook Plus', 1300, 3, 3, 5),
    (6, 'ProBook X1', 950, 1, 1, 1),
    (7, 'ZenStation 7', 1000, 2, 2, 2),
    (8, 'InnovaBook X3', 1350, 1, 1, 3),
    (9, 'GigaDesk 9000', 980, 2, 2, 4),
    (10, 'TouchBook Flex', 1050, 3, 3, 5),
    (11, 'SwiftBook 12', 1000, 1, 1, 1),
    (12, 'FusionDesk Pro', 1300, 2, 2, 2),
    (13, 'SlimBook X2', 880, 1, 1, 3),
    (14, 'TurboStation Max', 1200, 2, 2, 4),
    (15, 'SleekBook Ultra', 1050, 3, 3, 5),
    (16, 'Infinity 3000', 1250, 1, 1, 1),
    (17, 'MegaDesk Plus', 950, 2, 2, 2),
    (18, 'NanoBook Flex', 1250, 1, 1, 3),
    (19, 'PowerBook 3000', 980, 2, 2, 4),
    (20, 'FlexiBook Pro', 1100, 3, 3, 5);

