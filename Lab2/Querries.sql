USE COMPUTER_STORE

-- Query 1: Calculate the total price for each computer after applying all taxes and discounts
SELECT c.computer_ID, c.model_name, 
       SUM((1 + t.tax_percentage / 100) * (1 - d.discount_percentage / 100) * c.price) AS total_price
FROM Computer c
JOIN Tax t ON 1 = 1
JOIN Discount d ON 1 = 1
GROUP BY c.computer_ID, c.model_name;

-- Query 2: Find the manufacturer with the highest average final price for their computers after taxes and discounts
SELECT TOP 1 m.manufacturer_name, AVG((1 + t.tax_percentage / 100) * (1 - d.discount_percentage / 100) * c.price) AS avg_final_price
FROM Computer c
JOIN Manufacturer m ON c.manufacturer_ID = m.manufacturer_ID
JOIN Tax t ON 1 = 1
JOIN Discount d ON 1 = 1
GROUP BY m.manufacturer_name
ORDER BY avg_final_price DESC;

-- Query 3: Find the top 5 most expensive computers after applying all taxes and discounts
SELECT TOP 5 computer_ID, model_name, final_price
FROM (
    SELECT c.computer_ID, c.model_name, 
           (1 + t.tax_percentage / 100) * (1 - d.discount_percentage / 100) * c.price AS final_price
    FROM Computer c
    JOIN Tax t ON 1 = 1
    JOIN Discount d ON 1 = 1
) AS final_prices
ORDER BY final_price DESC;