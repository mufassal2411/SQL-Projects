--4. Customer segmentation by CLV — who are Bronze, Silver, Gold customers and what's the revenue split?

SELECT * FROM order_payments;

SELECT * FROM orders;

SELECT * FROM customers;

-- ================================================
--findings:
--Bronze = 91,606 customers, 73.92% revenue — mass market, small spenders
--Silver = 4,399 customers, 24.03% revenue — mid tier
--Gold = 90 customers, 2.05% revenue — top spenders but surprisingly low revenue contribution
-- ================================================

WITH cte AS(
   SELECT c.customer_unique_id AS unique_id,
          sum(op.payment_value) as revenue
   FROM order_payments op
   LEFT JOIN orders o
   ON op.order_id = o.order_id
   LEFT JOIN customers c
   ON c.customer_id = o.customer_id
   GROUP BY unique_id
)
SELECT 
       CASE WHEN revenue < 500 THEN 'Bronze'
            WHEN revenue >= 500 AND revenue < 2500 THEN 'Silver'
			ELSE 'Gold'
	   END AS level,
	   COUNT(unique_id),
	   SUM(revenue),
	   ROUND((sum(revenue)/(SELECT sum(revenue) FROM cte) * 100.0),2) AS level_pct
FROM cte
GROUP BY level
ORDER BY level_pct

'''Olist should shift marketing focus from pure acquisition to retention — email campaigns, 
loyalty rewards, and personalized product recommendations targeting Bronze customers specifically, 
since converting even 5% of them to repeat buyers would significantly impact revenue without increasing 
acquisition costs'''
	   
