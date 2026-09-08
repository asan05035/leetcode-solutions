/*
===============================================
For every customer that bought Photoshop, 
return a list of the customers and the total spent on all the products except for Photoshop products.

===============================================
*/


/*
=============================
-- IN operator subquery
-- Is used to make the filtering dynamic
==============================
*/

WITH base_query AS
(
-- ===============================
-- Base query: Retreive all the columns needed from the table
-- ===============================
SELECT 
	customer_id,
	product,
	revenue
FROM medium.adobe_transactions
)

, CustomerWhoBoughtPhotoshop AS
(
-- ========================================
-- Filtering: Finding customers who bought photoshop
-- ========================================
SELECT customer_id 
FROM medium.adobe_transactions
WHERE product = 'Photoshop'
)


-- Amount Spend on other products by customers who bought photoshop

-- ==========================================================
-- Filtering: Filter customer who bought photoshop from overalll records 
--				and filtering inside their records
-- ==========================================================
SELECT 
	customer_id,
	SUM(revenue) AS AmountSpend
FROM base_query
WHERE customer_id IN (SELECT customer_id FROM CustomerWhoBoughtPhotoshop)
AND product != 'Photoshop'
GROUP BY customer_id


/*
====================
Way_2: EXISTS OPERATOR
- Correlated subquery
====================
*/

WITH base_query AS
(
-- ===============================
-- Base query: Retreive all the columns needed from the table
-- ===============================
SELECT 
	customer_id,
	product,
	revenue
FROM medium.adobe_transactions
)

, CustomerWhoBoughtPhotoshop AS
(
-- ========================================
-- Filtering: Finding customers who bought photoshop
-- ========================================
SELECT customer_id 
FROM medium.adobe_transactions
WHERE product = 'Photoshop'
)


-- ======================================
-- Filtering using another table : EXISTS
--	Checking if each customer from entire records also in customer who bought photoshop records
-- ======================================


SELECT 
	customer_id,
	SUM(revenue) AS total
FROM medium.adobe_transactions AS a
WHERE EXISTS (SELECT 1 FROM CustomerWhoBoughtPhotoshop AS b WHERE b.customer_id = a.customer_id)
AND product != 'Photoshop'
GROUP BY customer_id


/*
DDL Script
*/

CREATE TABLE medium.adobe_transactions (
    customer_id INT,
    product VARCHAR(100),
    revenue INT
);

INSERT INTO medium.adobe_transactions (customer_id, product, revenue) VALUES
(123, 'Photoshop', 50),
(123, 'Premier Pro', 100),
(123, 'After Effects', 50),
(234, 'Illustrator', 200),
(234, 'Premier Pro', 100),
(562, 'Illustrator', 350),
(913, 'Photoshop', 200),
(913, 'Premier Pro', 100),
(913, 'Illustrator', 200);

