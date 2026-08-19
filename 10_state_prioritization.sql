--10. Based on all above — which 3 states should Olist prioritize for operational improvement, and why?

--FINDINGS:
--  State	 Revenue  Avg Review  Priority Reason
--1  RJ	     2.15M	  3.90	      High value, underperforming satisfaction
--2  BA	     618k	  3.86	      Chronic low reviews, logistics gap
--3  PA	     218k	  3.84	      Worst delay + review combination

SELECT * FROM order_reviews;

SELECT * FROM order_payments;


WITH cte AS(
SELECT c.customer_state AS state,
	   oe.review_score AS review_score,
	   SUM(op.payment_value) AS revenue,
	   o.order_delivered_customer_date AS odcd,
	   o.order_estimated_delivery_date AS oedd
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
LEFT join order_reviews oe
ON o.order_id = oe.order_id
LEFT JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY c.customer_state, oe.review_score, o.order_delivered_customer_date, o.order_estimated_delivery_date
)
SELECT AVG(EXTRACT(DAY FROM age(odcd, oedd))) AS avg_delay_date,
       state,
	   AVG(review_score) AS avg_review_score,
	   SUM(revenue) AS total_revenue
FROM cte
GROUP BY state
ORDER BY total_revenue DESC, avg_review_score;


