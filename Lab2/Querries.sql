USE COMPUTER_STORE

-- See all computers and theire associated taxes
SELECT
    c.computer_ID,
    c.model_name,
    c.price AS initial_price,
    STRING_AGG(CONCAT(t.tax_name, ' (', t.tax_percentage, '%)'), ', ') AS all_taxes
FROM Computer c
LEFT JOIN ComputerTax ct ON c.computer_ID = ct.computer_ID
LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
GROUP BY c.computer_ID, c.model_name, c.price;

-- See the the final taxes applied to computers
SELECT
    c.computer_ID,
    c.model_name,
    c.price AS initial_price,
    SUM(t.tax_percentage) AS total_tax
FROM Computer c
LEFT JOIN ComputerTax ct ON c.computer_ID = ct.computer_ID
LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
GROUP BY c.computer_ID, c.model_name, c.price;

-- See the final discounts applied to computers
SELECT
    c.computer_ID,
    c.model_name,
    c.price AS initial_price,
    SUM(d.discount_percentage) AS total_discount
FROM Computer c
LEFT JOIN ComputerDiscount cd ON c.computer_ID = cd.computer_ID
LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
GROUP BY c.computer_ID, c.model_name, c.price;

-- Querry 1: Calculate the final price of each computer
WITH TotalDiscounts AS ( -- Calculate total discounts
    SELECT
        c.computer_ID,
        SUM(d.discount_percentage) AS total_discount
    FROM Computer c
    LEFT JOIN ComputerDiscount cd ON c.computer_ID = cd.computer_ID
    LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
    GROUP BY c.computer_ID
),
TotalTaxes AS ( -- Calculate total taxes
    SELECT
        c.computer_ID,
        SUM(t.tax_percentage) AS total_tax
    FROM Computer c
    LEFT JOIN ComputerTax ct ON c.computer_ID = ct.computer_ID
    LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
    GROUP BY c.computer_ID
)
SELECT c.computer_ID, c.model_name, -- Calculate the total price for each computer after applying associated discounts and taxes
       c.price AS initial_price,
       (1 + ISNULL(tt.total_tax / 100, 0)) * (1 - ISNULL(td.total_discount / 100, 0)) * c.price AS total_price
FROM Computer c
LEFT JOIN TotalTaxes tt ON c.computer_ID = tt.computer_ID
LEFT JOIN TotalDiscounts td ON c.computer_ID = td.computer_ID
ORDER BY total_price DESC;

-- Query 2: Find the manufacturer with the highest average price before taxes
SELECT TOP 1 m.manufacturer_name, avg_price
FROM Manufacturer m
JOIN (
    SELECT c.manufacturer_ID, AVG(c.price) AS avg_price
    FROM Computer c
    GROUP BY c.manufacturer_ID
) AS avg_prices
ON m.manufacturer_ID = avg_prices.manufacturer_ID
ORDER BY avg_price DESC;

-- Query 3: Calculate the total price for each computer after applying associated discounts and taxes
WITH TotalPricePerComputer AS (
    SELECT
        co.order_ID,
        c.computer_ID,
        SUM((1 + t.tax_percentage / 100) * ISNULL(1 - d.discount_percentage / 100, 1) * c.price) AS total_price
    FROM ComputerOrder co
    JOIN Computer c ON co.computer_ID = c.computer_ID
    LEFT JOIN ComputerTax ct ON c.computer_ID = ct.computer_ID
    LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
    LEFT JOIN ComputerDiscount cd ON c.computer_ID = cd.computer_ID
    LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
    GROUP BY co.order_ID, c.computer_ID
),
TotalPricePerOrder AS ( -- Calculate the total price per order
    SELECT
        order_ID,
        SUM(total_price) AS total_order_price
    FROM TotalPricePerComputer
    GROUP BY order_ID
)
SELECT -- Calculate the total price of all orders
    o.order_ID,
    tpo.total_order_price
FROM [Order] o
LEFT JOIN TotalPricePerOrder tpo ON o.order_ID = tpo.order_ID;