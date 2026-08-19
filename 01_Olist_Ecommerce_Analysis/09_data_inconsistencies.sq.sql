--9. Which orders have data inconsistencies — delivered before purchase, estimated before order, etc.?

-- Findings:
-- 1. ~8 orders marked 'delivered' with NULL delivery timestamp — status update bug
-- 2. ~60 orders delivered before approval timestamp — caused by batch approval 
--    jobs running at midnight, creating artificial timestamp sequences
-- These are system-level data quality issues, not business logic errors

SELECT 'approved before purchase' AS inconsistency_type,
       order_approved_at AS date_1,
       order_purchase_timestamp date2
FROM orders
WHERE order_approved_at < order_purchase_timestamp
UNION ALL
SELECT 'delivered before purchase' AS inconsistency_type,
       order_delivered_customer_date AS date_1,
       order_purchase_timestamp AS date_2
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp
UNION ALL
SELECT 'estimated delivery before purchase' AS inconsistency_type,
        order_estimated_delivery_date AS date_1,
		order_purchase_timestamp AS date_2
FROM orders
WHERE order_estimated_delivery_date < order_purchase_timestamp
UNION ALL
SELECT 'delivered but NULL' AS inconsistency_type,
        NULL::timestamp AS date_1,
		order_delivered_customer_date AS date_2
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL
UNION ALL
SELECT 'delivered before approval' AS inconsistency_type,
        order_approved_at AS date_1,
		order_delivered_customer_date AS date_2
FROM orders
WHERE order_delivered_customer_date < order_approved_at;

-- Business Insight: Olist's order management system needs real-time timestamp 
-- logging instead of batch processing to maintain data integrity