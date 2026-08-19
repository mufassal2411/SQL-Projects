--7. Does a higher delivery delay directly hurt review scores — prove it with data?

SELECT * FROM orders;

SELECT * FROM order_reviews;

-- ================================================
'''FINDINGS:
A single week of delay cuts customer satisfaction nearly in half (4.29 → 2.68).
After 8 days late, satisfaction hits rock bottom and doesnt get worse — customers are already done.'''

-- ================================================

WITH cte AS(
   SELECT EXTRACT(DAY FROM AGE(o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS delay_date,
          oe.review_score AS review_score
   FROM orders o 
   LEFT JOIN order_reviews oe
   ON o.order_id = oe.order_id
   WHERE o.order_status = 'delivered'
)
SELECT CASE WHEN delay_date <= 0 THEN 'on_time'
            WHEN delay_date BETWEEN 1 AND 7 THEN '1-7 days late'
			WHEN delay_date BETWEEN 8 AND 14 THEN '8-14 days late'
			ELSE '15+ days late'
			END AS delay_bucket,
			ROUND(AVG(review_score),2) AS avg_review_score
FROM cte
GROUP by delay_bucket
ORDER BY avg_review_score;

'''BUSINESS RECOMMENDATION : Delivery delay beyond 7 days is the single biggest driver of 
negative reviews. Olist should set a 7-day delay threshold as a critical SLA 
any order projected to exceed this should trigger proactive customer communication to 
manage expectations and prevent 1-star reviews.'''
       