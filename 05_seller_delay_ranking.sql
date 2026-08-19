--5. Which sellers are consistently late — ranked by delay rate with their revenue contribution?

--Seller 2709af... — rank 1,50% delay rate, only 5,965 revenue. High delay, low revenue. Easy to drop.
'''Seller 06a2c3... — rank 22, 51,983 revenue but still 22% delay rate. High revenue AND high delay — 
this is the dangerous one. Olist cant afford to lose them but also cant ignore the delay problem.'''

select * from orders;

select * from sellers;

select * from order_payments;

select * from order_items;

WITH cte AS(
   SELECT o.order_id AS order_id,
          s.seller_id AS seller_id,
          o.order_delivered_customer_date > o.order_estimated_delivery_date AS delay_date
   FROM orders o
   LEFT JOIN order_items oi
   ON o.order_id = oi.order_id
   LEFT JOIN sellers s
   ON oi.seller_id = s.seller_id
   WHERE order_status = 'delivered'
),
cte2 AS(
   SELECT seller_id,
          COUNT(order_id) AS total_orders,
          COUNT(CASE WHEN delay_date = true THEN 1 END) AS late_orders
   FROM cte
   GROUP BY seller_id
   HAVING COUNT(order_id) >= 15
),
cte3 AS(
   select cte2.seller_id AS seller_id,
          ROUND((late_orders::numeric/total_orders * 100.0),2) AS delay_rate_pct,
		  SUM(op.payment_value) AS revenue
   FROM cte2 
   LEFT JOIN order_items oi
   ON cte2.seller_id = oi.seller_id
   LEFT JOIN order_payments op
   ON oi.order_id = op.order_id
   GROUP BY cte2.seller_id,late_orders,total_orders
)
SELECT seller_id,
       revenue,
	   delay_rate_pct,
       DENSE_RANK() OVER(ORDER BY delay_rate_pct DESC) AS rank
FROM cte3
LIMIT 20;

'''Olist can solve by Investigating 
->WHY theyre late — is it the sellers fault or the logistics partner?
->Offer operational support — help them with inventory management, packaging speed
->Monitor monthly — if delay rate improves, reward them. If not, gradually reduce their listing visibility'''



