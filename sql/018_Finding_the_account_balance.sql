-- =========================
-- Way_1: using case_when
-- ============================

WITH base_query AS
(SELECT 
	transaction_id,
	account_id, 
	transaction_type, 
	amount
FROM paypal_q1_transactions
)


SELECT 
/*
=========================================
Aggregation: conditonal aggregation on subset of data
========================================
*/
	account_id, 
	SUM(CASE 
		WHEN transaction_type = 'deposit' THEN amount
		WHEN transaction_type = 'withdrawal' THEN -amount
		ELSE 0
	END ) AS final_balance
FROM base_query 
GROUP BY account_id











-- ================================
-- Way_2: using joins
-- ================================


WITH base_query AS
(
SELECT 
	transaction_id,
	account_id, 
	transaction_type, 
	amount
FROM paypal_q1_transactions
)

, cte_deposits AS 
(
/*
==================================
Aggragtion: Isolating deposit data
============================
*/
SELECT
	account_id,
	SUM(amount) AS total_deposits
FROM base_query  AS b
WHERE b.transaction_type = 'deposit'
GROUP BY account_id
)

,cte_withdrawl AS 
(
/*
==================================
Aggragtion: Isolating withdrwal data
============================
*/
SELECT
	account_id,
	SUM(amount) AS total_withdrawl
FROM base_query  AS b
WHERE b.transaction_type = 'withdrawal'
GROUP BY account_id
)


/*
==================================
Joining(Data enrichment): combining deposit and withdrwal data 
============================
*/
SELECT
	COALESCE(w.account_id, d.account_id) AS account_id,
	-- d.total_deposits,
	-- w.total_withdrawl,
	COALESCE(d.total_deposits, 0) - COALESCE(w.total_withdrawl, 0) AS final_balance
FROM cte_deposits AS d
FULL JOIN cte_withdrawl AS w
ON d.account_id = w.account_id


CREATE TABLE paypal_q1_transactions (
    transaction_id INT,
    account_id INT,
    transaction_type VARCHAR(20),
    amount DECIMAL(10,2)
);

INSERT INTO paypal_q1_transactions
(transaction_id, account_id, transaction_type, amount)
VALUES
(1, 101, 'deposit',    5000.00),
(2, 101, 'withdrawal', 1200.00),
(3, 101, 'deposit',    2500.00),
(4, 101, 'withdrawal',  500.00),

(5, 102, 'deposit',    10000.00),
(6, 102, 'withdrawal', 3000.00),
(7, 102, 'withdrawal', 1500.00),

(8, 103, 'deposit',    7500.00),
(9, 103, 'withdrawal', 2000.00),
(10, 103, 'deposit',   1000.00);
