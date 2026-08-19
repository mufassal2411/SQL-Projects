--2. What are the top 5 revenue-generating product categories — and what % of total revenue do they contribute (cumulative share)?

-- ================================================
-- Findings:
-- bed_bath_table leads with 1.7M reais (8.43% of total revenue)
-- Top 5 categories together contribute ~38% of total revenue
-- Revenue is spread across many categories -- no single dominant one
-- ================================================

SELECT * FROM products
LIMIT 10;

SELECT * FROM order_items
LIMIT 10;

SELECT * FROM order_payments
LIMIT 10;

SELECT * FROM product_category_name_translation
LIMIT 10;

WITH cte AS(
SELECT SUM(py.payment_value) AS revenue,
       p.product_category_name AS pc_name_spa,
	   pc.product_category_name_english AS pc_name
FROM products p
LEFT JOIN order_items i
ON p.product_id = i.product_id
LEFT JOIN order_payments py
ON i.order_id = py.order_id
LEFT JOIN product_category_name_translation pc
ON p.product_category_name = pc.product_category_name
GROUP BY pc_name,pc_name_spa
)
SELECT pc_name,
       revenue,
	   round((revenue/(select sum(revenue) from cte) *100),2) AS total_revenue_pct
FROM cte
ORDER BY revenue DESC
LIMIT 5

-- Business Insight:
-- Olist should prioritize seller acquisition and inventory
-- in bed_bath_table and health_beauty categories for maximum revenue impact