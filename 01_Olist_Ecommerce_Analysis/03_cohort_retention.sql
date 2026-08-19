--3. Cohort retention — of customers who bought in month X, what % returned in months 1, 2, 3 after?

select * from orders

select * from customers

-- ================================================
--Every cohort starts at 100% (month 0)
--By month 1 — barely 0.3% to 0.7% of customers come back
--By month 3 — almost nobody, 0.1% to 0.4%
-- ================================================

WITH cte AS(
   SELECT c.customer_unique_id AS unique_id,
          min(DATE_TRUNC('month',o.order_purchase_timestamp)) AS first_month
   FROM customers c
   LEFT JOIN orders o
   ON c.customer_id = o.customer_id
   GROUP BY unique_id
),
cte2 AS(
   SELECT unique_id,
		  first_month,
		  (EXTRACT(YEAR FROM age(o.order_purchase_timestamp,cte.first_month)) *12 + EXTRACT(MONTH FROM age(o.order_purchase_timestamp,cte.first_month))) AS month_number
   FROM cte
   JOIN customers c ON cte.unique_id = c.customer_unique_id --gives first_month and order_timestamp from all orders
   JOIN orders o ON c.customer_id = o.customer_id
),
cte3 AS(
   SELECT first_month,
          month_number,
	      COUNT(distinct unique_id) AS count_u_id
   FROM cte2
   WHERE month_number IN (0,1,2,3)
   GROUP BY first_month,month_number
),
cte4 AS(
   SELECT first_month,
          month_number,
	      count_u_id,
	      SUM(CASE WHEN month_number = 0 THEN count_u_id ELSE 0 END) OVER(PARTITION BY first_month) AS cohort_size
   FROM cte3
)
SELECT first_month,
       month_number,
	   ROUND((count_u_id/cohort_size * 100),2) AS retention_pct
FROM cte4;

--Business recommendation: Olist needs post-purchase email campaigns, loyalty programs, and personalized recommendations to bring customers back.