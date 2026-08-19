--6. Which state × category combinations have the worst average delivery delay?

SELECT * FROM products; 

SELECT * FROM customers;

SELECT * FROM orders;

SELECT * FROM order_items;

SELECT * FROM product_category_name_translation;

'''All top 10 worst state×category combinations show average delays exceeding 22 days 
—> suggesting this is a systemic logistics problem across Brazils northern and northeastern regions, 
not isolated to specific sellers or categories.'''

WITH cte AS(
   SELECT EXTRACT(DAY FROM age(o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS delay_date,
       c.customer_state AS state,
	   p.product_category_name AS category_por,
	   pc.product_category_name_english AS category
   FROM orders o
   LEFT JOIN customers c
   ON o.customer_id = c.customer_id
   LEFT JOIN order_items oi
   ON o.order_id = oi.order_id
   LEFT JOIN products p 
   ON p.product_id = oi.product_id
   LEFT JOIN product_category_name_translation pc
   on p.product_category_name = pc.product_category_name
   WHERE o.order_status = 'delivered' AND EXTRACT(DAY FROM age(o.order_delivered_customer_date, o.order_estimated_delivery_date)) > 0
)
SELECT state,
       category,
	   ROUND(AVG(delay_date),2) AS avg_delay_date
FROM cte
GROUP BY state,category
ORDER BY avg_delay_date DESC
LIMIT 10;

	   