/*

SELECT *
FROM dbo.sql_9_orders

SELECT *
FROM dbo.sql_9_users

SELECT *
FROM dbo.sql_9_items 

*/


WITH CTE_base_query AS (
/*--------------------------
1. Base_query : Retreiev all colums from the table
--------------------------*/
SELECT 
	o.seller_id,
	o.order_date,
	o.item_id AS product_id,
	i.item_brand AS product_name,
	u.favorite_brand AS seller_favorite_product
FROM dbo.sql_9_orders AS o
LEFT JOIN dbo.sql_9_items AS i
ON o.item_id = i.item_id
LEFT JOIN dbo.sql_9_users AS u
ON o.seller_id = u.user_id
)

, CTE_Aggregation AS (
/*--------------------------------
2. Aggregation:-- second product sold by row number ()
			-- create a new measure from existing dimension || flag if second item is favorite item sold
			|| sql_cmplex_8 || data segmentation
			-- 
--------------------------------------- */
SELECT 
	seller_id,
	order_date,
	product_id,
	product_name,
	seller_favorite_product,
	ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY order_date ASC) as rn,
	CASE WHEN ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY order_date ASC) = 2
			AND product_name = seller_favorite_product THEN 1
		ELSE 0
	END AS flag
FROM CTE_base_query AS cbq
)

, CTE_Seller_id_whose_favorite_product_sold AS (
/*---------------------------------
3. Filtering: identiy sellers whose favorite product is sold on second day or not
----------------------------*/
SELECT 
	seller_id
	-- flag
FROM CTE_Aggregation
--WHERE rn = 2 AND product_name = seller_favorite_product  
WHERE flag = 1
)

, CTE_new_sample AS (
/*--------- 
4. Creating new sample data 
------------*/

SELECT DISTINCT u.user_id,
	'No' AS response
FROM dbo.sql_9_users AS u
)
, CTE_final_query AS (
/*-----------------------------
5. joining sample data with filtered data which contains 
which sellers favorite product is sold on second day
-------------------------------*/
SELECT 
	cns.user_id,
	CASE 
		WHEN seller_id IS NOT NULL THEN 'Yes'
		ELSE cns.response
	END second_itemSold_fav_brand
FROM CTE_new_sample AS cns
LEFT JOIN CTE_Seller_id_whose_favorite_product_sold AS csfp
ON cns.user_id = csfp.seller_id
)

/*-------------
6.Solution
-----------*/
SELECT 
	user_id,
	second_itemSold_fav_brand
FROM CTE_final_query
