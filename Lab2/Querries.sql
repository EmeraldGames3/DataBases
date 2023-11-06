USE COMPUTER_STORE;

-- Query
SELECT TOP 1 WITH TIES
    m.manufacturer_name,
    AVG(
        (1 + ISNULL(tt.total_tax / 100, 0)) * (1 - ISNULL(td.total_discount / 100, 0)) * c.price
    ) AS avg_price
FROM Manufacturer m
JOIN Computer c ON m.manufacturer_ID = c.manufacturer_ID
JOIN (
    SELECT
        c.computer_ID,
        SUM(t.tax_percentage) AS total_tax
    FROM Computer c
    LEFT JOIN ComputerTax ct ON c.computer_ID = ct.computer_ID
    LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
    GROUP BY c.computer_ID
) AS tt ON c.computer_ID = tt.computer_ID
JOIN (
    SELECT
        c.computer_ID,
        SUM(d.discount_percentage) AS total_discount
    FROM Computer c
    LEFT JOIN ComputerDiscount cd ON c.computer_ID = cd.computer_ID
    LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
    GROUP BY c.computer_ID
) AS td ON c.computer_ID = td.computer_ID
GROUP BY m.manufacturer_ID, manufacturer_name
ORDER BY avg_price DESC;




-- Querry
SELECT
    pm.payment_method,
    pm.order_count,
    (pm.order_count * 100.0) / (SELECT COUNT(*) FROM [Order]) AS percentage
FROM (
    SELECT
        payment_method,
        COUNT(order_ID) AS order_count
    FROM [Order]
    GROUP BY payment_method
) AS pm
ORDER BY pm.order_count DESC;




-- Querry
SELECT 
    MIN((1 + ISNULL(tt.total_tax / 100, 0)) * (1 - ISNULL(td.total_discount / 100, 0)) * c.price) AS min_price,
    AVG((1 + ISNULL(tt.total_tax / 100, 0)) * (1 - ISNULL(td.total_discount / 100, 0)) * c.price) AS avg_price,
    MAX((1 + ISNULL(tt.total_tax / 100, 0)) * (1 - ISNULL(td.total_discount / 100, 0)) * c.price) AS max_price
FROM Computer c
LEFT JOIN (
    SELECT
        ct.computer_ID,
        SUM(t.tax_percentage) AS total_tax
    FROM ComputerTax ct
    LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
    GROUP BY ct.computer_ID
) AS tt ON c.computer_ID = tt.computer_ID
LEFT JOIN (
    SELECT
        cd.computer_ID,
        SUM(d.discount_percentage) AS total_discount
    FROM ComputerDiscount cd
    LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
    GROUP BY cd.computer_ID
) AS td ON c.computer_ID = td.computer_ID;




-- Query
SELECT '2022' AS year, SUM(total_price) AS total_sales_revenue
FROM (
    SELECT
        co.order_ID,
        SUM((1 + ISNULL(t.tax_percentage / 100, 0)) * (1 - ISNULL(d.discount_percentage / 100, 0)) * c.price) AS total_price
    FROM ComputerOrder co
    JOIN [Order] o ON co.order_ID = o.order_ID
    JOIN Computer c ON co.computer_ID = c.computer_ID
    LEFT JOIN (
        SELECT ct.computer_ID, SUM(tax.tax_percentage) AS tax_percentage
        FROM ComputerTax ct
        LEFT JOIN Tax tax ON ct.tax_ID = tax.tax_ID
        GROUP BY ct.computer_ID
    ) AS t ON c.computer_ID = t.computer_ID
    LEFT JOIN (
        SELECT cd.computer_ID, SUM(discount.discount_percentage) AS discount_percentage
        FROM ComputerDiscount cd
        LEFT JOIN Discount discount ON cd.discount_ID = discount.discount_ID
        GROUP BY cd.computer_ID
    ) AS d ON c.computer_ID = d.computer_ID
    WHERE (o.order_date >= '2022-11-01' AND o.order_date <= '2022-12-31')
    GROUP BY co.order_ID, o.order_date
) AS TotalSales
UNION
SELECT '2023' AS year, SUM(total_price) AS total_sales_revenue
FROM (
    SELECT
        co.order_ID,
        SUM((1 + ISNULL(t.tax_percentage / 100, 0)) * (1 - ISNULL(d.discount_percentage / 100, 0)) * c.price) AS total_price
    FROM ComputerOrder co
    JOIN [Order] o ON co.order_ID = o.order_ID
    JOIN Computer c ON co.computer_ID = c.computer_ID
    LEFT JOIN (
        SELECT ct.computer_ID, SUM(tax.tax_percentage) AS tax_percentage
        FROM ComputerTax ct
        LEFT JOIN Tax tax ON ct.tax_ID = tax.tax_ID
        GROUP BY ct.computer_ID
    ) AS t ON c.computer_ID = t.computer_ID
    LEFT JOIN (
        SELECT cd.computer_ID, SUM(discount.discount_percentage) AS discount_percentage
        FROM ComputerDiscount cd
        LEFT JOIN Discount discount ON cd.discount_ID = discount.discount_ID
        GROUP BY cd.computer_ID
    ) AS d ON c.computer_ID = d.computer_ID
    WHERE (o.order_date >= '2023-11-01' AND o.order_date <= '2023-12-31')
    GROUP BY co.order_ID, o.order_date
) AS TotalSales;




-- Querry -- can be deleted if need be
SELECT
	c.customer_id,
    c.first_name,
	c.family_name,
	SUM((1 + ISNULL(t.tax_percentage / 100, 0)) * (1 - ISNULL(d.discount_percentage / 100, 0)) * com.price) AS total_spending
FROM Customer c
JOIN [Order] o ON c.customer_id = o.customer_id
JOIN ComputerOrder co ON o.order_ID = co.order_ID
JOIN Computer com ON co.computer_ID = com.computer_ID
LEFT JOIN ComputerTax ct ON com.computer_ID = ct.computer_ID
LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
LEFT JOIN ComputerDiscount cd ON com.computer_ID = cd.computer_ID
LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
GROUP BY c.customer_id, c.first_name, c.family_name
HAVING COUNT(o.order_ID) > 1;




-- Querry -> Changed
SELECT DISTINCT cu.customer_id, cu.first_name, cu.family_name
FROM Customer cu
JOIN [Order] o ON cu.customer_id = o.customer_id
JOIN ComputerOrder co ON o.order_ID = co.order_ID
JOIN Computer com ON co.computer_ID = com.computer_ID
JOIN OperatingSystem os ON com.os_ID = os.os_ID
WHERE os.os_name NOT IN (
    SELECT TOP 2 os.os_name
    FROM ComputerOrder co
    JOIN Computer c ON co.computer_ID = c.computer_ID
    JOIN OperatingSystem os ON c.os_ID = os.os_ID
    WHERE os.os_name IS NOT NULL
    GROUP BY os.os_name
    ORDER BY COUNT(co.order_ID) DESC
);




-- Querry
SELECT Distinct cc.category_name
FROM (
    SELECT cu.customer_id, YEAR(GETDATE()) - YEAR(cu.birth_date) AS age
    FROM Customer cu
) AS ca
JOIN [Order] o ON ca.customer_id = o.customer_id
JOIN ComputerOrder co ON o.order_ID = co.order_ID
JOIN Computer com ON co.computer_ID = com.computer_ID
JOIN ComputerCategory cc ON com.computer_category_ID = cc.computer_category_ID
WHERE ca.age < 25 OR ca.age < 0.75 * (
    SELECT AVG(age) 
    FROM (
        SELECT cu.customer_id, YEAR(GETDATE()) - YEAR(cu.birth_date) AS age
        FROM Customer cu
    ) AS CustomerAge
);




-- Querry -> Changed
SELECT cu.customer_id, cu.first_name, cu.family_name
FROM Customer cu
WHERE cu.customer_id = ANY (
    SELECT o.customer_id
    FROM [Order] o
    WHERE o.customer_id = cu.customer_id
    AND o.order_ID IN (
        SELECT TOP 2 co.order_ID
        FROM ComputerOrder co
        JOIN Computer com ON co.computer_ID = com.computer_ID
        JOIN OperatingSystem os ON com.os_ID = os.os_ID
        WHERE os.os_name IN ('Windows', 'Mac OS') OR os.os_name = (
			SELECT TOP 2 os.os_name
		    FROM ComputerOrder co
			JOIN Computer c ON co.computer_ID = c.computer_ID
			JOIN OperatingSystem os ON c.os_ID = os.os_ID
			WHERE os.os_name IS NOT NULL
			GROUP BY os.os_name
			ORDER BY COUNT(co.order_ID) DESC
        )
    )
);

--Querry -> Changed
SELECT co.order_ID,
	SUM(
		(1 + ISNULL(t.tax_percentage / 100, 0)) 
		* (1 - ISNULL(d.discount_percentage / 100, 0)) 
		* c.price * co.computer_amount
	) AS Order_Price
FROM ComputerOrder co
JOIN Computer c ON co.computer_ID = c.computer_ID
LEFT JOIN ComputerTax ct ON co.computer_ID = ct.computer_ID
LEFT JOIN Tax t ON ct.tax_ID = t.tax_ID
LEFT JOIN ComputerDiscount cd ON co.computer_ID = cd.computer_ID
LEFT JOIN Discount d ON cd.discount_ID = d.discount_ID
GROUP BY co.order_ID
HAVING SUM(
		(1 + ISNULL(t.tax_percentage / 100, 0)) 
		* (1 - ISNULL(d.discount_percentage / 100, 0)) 
		* c.price * co.computer_amount) 
>= ALL (
    SELECT SUM(
		(1 + ISNULL(tax.tax_percentage / 100, 0)) 
		* (1 - ISNULL(discount.discount_percentage / 100, 0)) 
		* computer.price * co.computer_amount
    ) AS total_cost
    FROM ComputerOrder co
    JOIN Computer computer ON co.computer_ID = computer.computer_ID
    LEFT JOIN ComputerTax ct ON co.computer_ID = ct.computer_ID
    LEFT JOIN Tax tax ON ct.tax_ID = tax.tax_ID
    LEFT JOIN ComputerDiscount cd ON co.computer_ID = cd.computer_ID
    LEFT JOIN Discount discount ON cd.discount_ID = discount.discount_ID
    GROUP BY co.order_ID
);


--Querry -> changed
SELECT customer_id, first_name, family_name
FROM Customer
WHERE customer_id IN (
    SELECT customer_id
    FROM [Order]
    WHERE payment_method = 'Cash'
)
INTERSECT
SELECT customer_id, first_name, family_name
FROM Customer
WHERE customer_id IN (
    SELECT customer_id
    FROM [Order]
    WHERE payment_method = 'Credit Card'
);




-- Querry
SELECT c.customer_ID, c.first_name, c.family_name
FROM Customer c
WHERE c.customer_ID IN (
    SELECT o.customer_ID
    FROM [Order] o
    WHERE o.order_date >= DATEADD(MONTH, -1, GETDATE())
)
EXCEPT
SELECT c.customer_ID, c.first_name, c.family_name
FROM Customer c
WHERE c.customer_ID IN (
    SELECT o.customer_ID
    FROM [Order] o
    JOIN ComputerOrder co ON o.order_ID = co.order_ID
    JOIN Computer com ON co.computer_ID = com.computer_ID
    JOIN ComputerCategory cc ON com.computer_category_ID = cc.computer_category_ID
    WHERE cc.category_name IN ('All-in-One PC', 'Convertible Laptop')
)