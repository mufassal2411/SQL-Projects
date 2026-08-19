--8. How complete is the dataset — null audit across all 8 tables with completeness % per column?
SELECT * FROM orders;

-- ================================================
--FINDINGS:
'''Data quality is strong for transactional columns.
The only significant gaps are in review text fields —
88% of reviews have no title and 59% have no written message — 
suggesting customers prefer quick star ratings over written feedback. 
This limits sentiment analysis but doesnt affect quantitative analysis.'''
-- ================================================

SELECT 'orders' AS table_name, 'order_id' AS column_name, ROUND(COUNT(order_id)::numeric/COUNT(*)*100,2) AS completeness_pct FROM orders UNION ALL
SELECT 'orders', 'customer_id', ROUND(COUNT(customer_id)::numeric/COUNT(*)*100,2) FROM orders UNION ALL
SELECT 'orders', 'order_status', ROUND(COUNT(order_status)::numeric/COUNT(*)*100,2) FROM orders UNION ALL
SELECT 'orders', 'order_purchase_timestamp', ROUND(COUNT(order_purchase_timestamp)::numeric/COUNT(*)*100,2) FROM orders UNION ALL
SELECT 'orders', 'order_approved_at', ROUND(COUNT(order_approved_at)::numeric/COUNT(*)*100,2) FROM orders UNION ALL
SELECT 'orders', 'order_delivered_carrier_date', ROUND(COUNT(order_delivered_carrier_date)::numeric/COUNT(*)*100,2) FROM orders UNION ALL
SELECT 'orders', 'order_delivered_customer_date', ROUND(COUNT(order_delivered_customer_date)::numeric/COUNT(*)*100,2) FROM orders UNION ALL
SELECT 'orders', 'order_estimated_delivery_date', ROUND(COUNT(order_estimated_delivery_date)::numeric/COUNT(*)*100,2) FROM orders UNION ALL

SELECT 'customers', 'customer_id', ROUND(COUNT(customer_id)::numeric/COUNT(*)*100,2) FROM customers UNION ALL
SELECT 'customers', 'customer_unique_id', ROUND(COUNT(customer_unique_id)::numeric/COUNT(*)*100,2) FROM customers UNION ALL
SELECT 'customers', 'customer_zip_code_prefix', ROUND(COUNT(customer_zip_code_prefix)::numeric/COUNT(*)*100,2) FROM customers UNION ALL
SELECT 'customers', 'customer_city', ROUND(COUNT(customer_city)::numeric/COUNT(*)*100,2) FROM customers UNION ALL
SELECT 'customers', 'customer_state', ROUND(COUNT(customer_state)::numeric/COUNT(*)*100,2) FROM customers UNION ALL
 
SELECT 'order_items', 'order_id', ROUND(COUNT(order_id)::numeric/COUNT(*)*100,2) FROM order_items UNION ALL
SELECT 'order_items', 'order_item_id', ROUND(COUNT(order_item_id)::numeric/COUNT(*)*100,2) FROM order_items UNION ALL
SELECT 'order_items', 'product_id', ROUND(COUNT(product_id)::numeric/COUNT(*)*100,2) FROM order_items UNION ALL
SELECT 'order_items', 'seller_id', ROUND(COUNT(seller_id)::numeric/COUNT(*)*100,2) FROM order_items UNION ALL
SELECT 'order_items', 'price', ROUND(COUNT(price)::numeric/COUNT(*)*100,2) FROM order_items UNION ALL
SELECT 'order_items', 'freight_value', ROUND(COUNT(freight_value)::numeric/COUNT(*)*100,2) FROM order_items UNION ALL
 
SELECT 'order_payments', 'order_id', ROUND(COUNT(order_id)::numeric/COUNT(*)*100,2) FROM order_payments UNION ALL
SELECT 'order_payments', 'payment_type', ROUND(COUNT(payment_type)::numeric/COUNT(*)*100,2) FROM order_payments UNION ALL
SELECT 'order_payments', 'payment_installments', ROUND(COUNT(payment_installments)::numeric/COUNT(*)*100,2) FROM order_payments UNION ALL
SELECT 'order_payments', 'payment_value', ROUND(COUNT(payment_value)::numeric/COUNT(*)*100,2) FROM order_payments UNION ALL
 
SELECT 'order_reviews', 'review_id', ROUND(COUNT(review_id)::numeric/COUNT(*)*100,2) FROM order_reviews UNION ALL
SELECT 'order_reviews', 'order_id', ROUND(COUNT(order_id)::numeric/COUNT(*)*100,2) FROM order_reviews UNION ALL
SELECT 'order_reviews', 'review_score', ROUND(COUNT(review_score)::numeric/COUNT(*)*100,2) FROM order_reviews UNION ALL
SELECT 'order_reviews', 'review_comment_title', ROUND(COUNT(review_comment_title)::numeric/COUNT(*)*100,2) FROM order_reviews UNION ALL
SELECT 'order_reviews', 'review_comment_message', ROUND(COUNT(review_comment_message)::numeric/COUNT(*)*100,2) FROM order_reviews UNION ALL
 
SELECT 'products', 'product_id', ROUND(COUNT(product_id)::numeric/COUNT(*)*100,2) FROM products UNION ALL
SELECT 'products', 'product_category_name', ROUND(COUNT(product_category_name)::numeric/COUNT(*)*100,2) FROM products UNION ALL
SELECT 'products', 'product_name_length', ROUND(COUNT(product_name_length)::numeric/COUNT(*)*100,2) FROM products UNION ALL
SELECT 'products', 'product_description_length', ROUND(COUNT(product_description_length)::numeric/COUNT(*)*100,2) FROM products UNION ALL
SELECT 'products', 'product_photos_qty', ROUND(COUNT(product_photos_qty)::numeric/COUNT(*)*100,2) FROM products UNION ALL
SELECT 'products', 'product_weight_g', ROUND(COUNT(product_weight_g)::numeric/COUNT(*)*100,2) FROM products UNION ALL
 
SELECT 'sellers', 'seller_id', ROUND(COUNT(seller_id)::numeric/COUNT(*)*100,2) FROM sellers UNION ALL
SELECT 'sellers', 'seller_zip_code_prefix', ROUND(COUNT(seller_zip_code_prefix)::numeric/COUNT(*)*100,2) FROM sellers UNION ALL
SELECT 'sellers', 'seller_city', ROUND(COUNT(seller_city)::numeric/COUNT(*)*100,2) FROM sellers UNION ALL
SELECT 'sellers', 'seller_state', ROUND(COUNT(seller_state)::numeric/COUNT(*)*100,2) FROM sellers
 
ORDER BY completeness_pct ASC;

