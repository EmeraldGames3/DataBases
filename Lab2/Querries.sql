USE COMPUTER_STORE

/*
	What do I have:
		- 5 WHERE
		- 6 JOIN more than two tables // TODO: make it 7
		- 1 Outer Joing
		- 1 with ANY
		- 1 with ALL
		- 3 GROUP BY
		- 2 HAVING
		- 3 Aggregate functions
		- TODO: 1 UNION
		- 1 OR
		- 1 INTERSECT
		- 1 IN
		- TODO: 1 EXCEPT
		- 1 NOT IN
		- 1 DISTINCT
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
DECLARE @StartDate DATE = '2023-01-01';
DECLARE @EndDate DATE = '2023-12-31';
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




-- Query 5: Find repeat customers that made big purchases
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




-- Querry 6: Find customers who purchased computers with non-popular OS
WITH OperatingSystemPopularity AS (
    SELECT os.os_name, os_version, COUNT(co.order_ID) AS os_order_count
    FROM ComputerOrder co
    JOIN Computer c ON co.computer_ID = c.computer_ID
    JOIN OperatingSystem os ON c.os_ID = os.os_ID
    GROUP BY os.os_name, os.os_version
	HAVING os.os_name IS NOT NULL OR os.os_version IS NOT NULL
)
SELECT DISTINCT cu.customer_id, cu.first_name, cu.family_name
FROM Customer cu
JOIN [Order] o ON cu.customer_id = o.customer_id
JOIN ComputerOrder co ON o.order_ID = co.order_ID
JOIN Computer com ON co.computer_ID = com.computer_ID
JOIN OperatingSystem os ON com.os_ID = os.os_ID
WHERE os.os_name NOT IN (
    SELECT TOP 2 os_name
    FROM OperatingSystemPopularity
    ORDER BY os_order_count DESC
);




-- Querry 7 Show what computer categories young people purchase:
WITH CustomerAge AS (
    SELECT cu.customer_id, YEAR(GETDATE()) - YEAR(cu.birth_date) AS age
    FROM Customer cu
)
SELECT DISTINCT cc.category_name
FROM CustomerAge ca
JOIN [Order] o ON ca.customer_id = o.customer_id
JOIN ComputerOrder co ON o.order_ID = co.order_ID
JOIN Computer com ON co.computer_ID = com.computer_ID
JOIN ComputerCategory cc ON com.computer_category_ID = cc.computer_category_ID
WHERE ca.age < 25 OR ca.age < (
    SELECT AVG(age) 
    FROM CustomerAge
);




-- Querry 8: Find customers who have purchased any of the most popular OS types
SELECT cu.customer_id, cu.first_name, cu.family_name
FROM Customer cu
WHERE cu.customer_id = ANY (
    SELECT DISTINCT o.customer_id
    FROM [Order] o
    WHERE o.customer_id = cu.customer_id
    AND o.order_ID IN (
        SELECT co.order_ID
        FROM ComputerOrder co
        JOIN Computer com ON co.computer_ID = com.computer_ID
        JOIN OperatingSystem os ON com.os_ID = os.os_ID
        WHERE os.os_name IN ('Windows', 'Mac OS')
    )
);




-- Querry 9: Find all adults that pay exclusively with Credit Cards
SELECT c.customer_ID, c.first_name, c.family_name
FROM Customer c
WHERE c.customer_ID = ALL (
    SELECT o.customer_ID
    FROM [Order] o
    WHERE o.customer_ID = c.customer_ID
    AND o.payment_method = 'Credit Card'
)
INTERSECT
SELECT c.customer_ID, c.first_name, c.family_name
FROM Customer c
WHERE YEAR(GETDATE()) - YEAR(c.birth_date) > 30;



-- Querry 10: Find new customers that bought less popular models
SELECT c.customer_ID, c.first_name, c.family_name
FROM Customer c
WHERE c.customer_ID IN (
    SELECT DISTINCT o.customer_ID
    FROM [Order] o
    WHERE o.order_date >= DATEADD(MONTH, -1, GETDATE())
)
EXCEPT
SELECT c.customer_ID, c.first_name, c.family_name
FROM Customer c
WHERE c.customer_ID IN (
    SELECT DISTINCT o.customer_ID
    FROM [Order] o
    JOIN ComputerOrder co ON o.order_ID = co.order_ID
    JOIN Computer com ON co.computer_ID = com.computer_ID
    JOIN ComputerCategory cc ON com.computer_category_ID = cc.computer_category_ID
    WHERE cc.category_name IN ('All-in-One PC', 'Convertible Laptop')
)