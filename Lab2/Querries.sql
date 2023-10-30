USE COMPUTER_STORE

/*
	What do I have:
		- 2 WHERE //TODO: make it 5
		- 3 Joining more than two tables
		- 1 Outer Joing
		- TODO: 1 with ANY
		- TODO: 1 with ALL
		- 3 GROUP BY
		- 1 HAVING //TODO: 2 HAVING
		- 1 Aggregate functions
		- TODO: 1 UNION
		- TODO: 1 OR
		- TODO: 1 INTERSECT
		- TODO: 1 IN
		- TODO: 1 EXCEPT
		- TODO: 1 NOT IN
		- TODO: 1 DISTINCT
		- 1 Top
		- 1 Order by
*/

-- Query 1: Find the manufacturer with the highest average price before taxes
SELECT TOP 1 m.manufacturer_name, avg_price
FROM Manufacturer m
JOIN (
    SELECT c.manufacturer_ID, AVG(c.price) AS avg_price
    FROM Computer c
    GROUP BY c.manufacturer_ID
) AS avg_prices
ON m.manufacturer_ID = avg_prices.manufacturer_ID
ORDER BY avg_price DESC;



-- Querry 2: Calculate the count and percentage of each payment method used in orders
WITH PaymentMethodCounts AS (
    SELECT
        payment_method,
        COUNT(order_ID) AS order_count
    FROM [Order]
    GROUP BY payment_method
)
SELECT
    payment_method,
    order_count,
    (order_count * 100.0) / SUM(order_count) OVER () AS percentage
FROM PaymentMethodCounts
ORDER BY order_count DESC;



-- Querry 3: Find minimum, maximum and avarage price of computers
WITH TotalDiscounts AS (
    SELECT
        c.computer_ID,
        SUM(d.discount_percentage) AS total_discount
    FROM Computer c
    LEFT JOIN ComputerDiscount cd ON c.computer_ID = cd.computer_ID
    LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
    GROUP BY c.computer_ID
),
TotalTaxes AS (
    SELECT
        c.computer_ID,
        SUM(t.tax_percentage) AS total_tax
    FROM Computer c
    LEFT JOIN ComputerTax ct ON c.computer_ID = ct.computer_ID
    LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
    GROUP BY c.computer_ID
)
SELECT 
    MIN((1 + ISNULL(tt.total_tax / 100, 0)) * (1 - ISNULL(td.total_discount / 100, 0)) * c.price) AS min_price,
    AVG((1 + ISNULL(tt.total_tax / 100, 0)) * (1 - ISNULL(td.total_discount / 100, 0)) * c.price) AS avg_price,
	MAX((1 + ISNULL(tt.total_tax / 100, 0)) * (1 - ISNULL(td.total_discount / 100, 0)) * c.price) AS max_price
FROM Computer c
LEFT JOIN TotalTaxes tt ON c.computer_ID = tt.computer_ID
LEFT JOIN TotalDiscounts td ON c.computer_ID = td.computer_ID;




-- Query 4: Calculate the total sales revenue for a given time period
DECLARE @StartDate DATE = '2023-01-01'; -- Replace with your desired start date
DECLARE @EndDate DATE = '2023-12-31'; -- Replace with your desired end date
WITH TotalTaxes AS (
    SELECT
        c.computer_ID,
        SUM(t.tax_percentage) AS total_tax
    FROM Computer c
    LEFT JOIN ComputerTax ct ON c.computer_ID = ct.computer_ID
    LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
    GROUP BY c.computer_ID
),
TotalDiscounts AS (
    SELECT
        c.computer_ID,
        SUM(d.discount_percentage) AS total_discount
    FROM Computer c
    LEFT JOIN ComputerDiscount cd ON c.computer_ID = cd.computer_ID
    LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
    GROUP BY c.computer_ID
),
TotalSales AS (
    SELECT
        co.order_ID,
        SUM((1 + ISNULL(t.total_tax / 100, 0)) * (1 - ISNULL(d.total_discount / 100, 0)) * c.price) AS total_price
    FROM ComputerOrder co
    JOIN [Order] o ON co.order_ID = o.order_ID
    JOIN Computer c ON co.computer_ID = c.computer_ID
    LEFT JOIN TotalTaxes t ON c.computer_ID = t.computer_ID
    LEFT JOIN TotalDiscounts d ON c.computer_ID = d.computer_ID
    WHERE o.order_date >= @StartDate AND o.order_date <= @EndDate
    GROUP BY co.order_ID
)
SELECT SUM(total_price) AS total_sales_revenue
FROM TotalSales;




-- Query 5: Find repeat customers that made big purchases with order details
WITH TotalPricePerComputer AS (
    SELECT
        co.order_ID,
        c.computer_ID,
        c.price,
        co.computer_amount,
        SUM((1 + t.tax_percentage / 100) * ISNULL(1 - d.discount_percentage / 100, 1) * c.price) AS total_price_per_unit
    FROM ComputerOrder co
    JOIN Computer c ON co.computer_ID = c.computer_ID
    LEFT JOIN ComputerTax ct ON c.computer_ID = ct.computer_ID
    LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
    LEFT JOIN ComputerDiscount cd ON c.computer_ID = cd.computer_ID
    LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
    GROUP BY co.order_ID, c.computer_ID, c.price, co.computer_amount
),
TotalPricePerOrder AS (
    SELECT
        order_ID,
        SUM(total_price_per_unit * computer_amount) AS total_order_price
    FROM TotalPricePerComputer
    GROUP BY order_ID
),
RepeatCustomers AS (
    SELECT c.customer_id
    FROM Customer c
    JOIN [Order] o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
    HAVING COUNT(o.order_id) >= 2
),
AverageOrderPrice AS (
    SELECT
        AVG(tpo.total_order_price) AS average_order_price
    FROM TotalPricePerOrder tpo
),
BigPurchases AS (
    SELECT c.customer_id
    FROM Customer c
    JOIN [Order] o ON c.customer_id = o.customer_id
    JOIN TotalPricePerOrder tpo ON o.order_ID = tpo.order_ID
    WHERE tpo.total_order_price >= (SELECT average_order_price FROM AverageOrderPrice)
    GROUP BY c.customer_id
),
TotalMoneySpent AS (
    SELECT
        c.customer_id,
        SUM(tpo.total_order_price) AS total_money_spent
    FROM Customer c
    JOIN [Order] o ON c.customer_id = o.customer_id
    JOIN TotalPricePerOrder tpo ON o.order_ID = tpo.order_ID
    GROUP BY c.customer_id
)
SELECT
    c.customer_id,
    c.first_name,
    c.family_name,
    tms.total_money_spent
FROM Customer c
JOIN TotalMoneySpent tms ON c.customer_id = tms.customer_id
WHERE c.customer_id IN (SELECT customer_id FROM RepeatCustomers)
INTERSECT
SELECT
    c.customer_id,
    c.first_name,
    c.family_name,
    tms.total_money_spent
FROM Customer c
JOIN TotalMoneySpent tms ON c.customer_id = tms.customer_id
WHERE c.customer_id IN (SELECT customer_id FROM BigPurchases);