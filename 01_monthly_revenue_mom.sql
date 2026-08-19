--1. What is monthly revenue trend with MoM growth % — and which 3 months had the sharpest drops?

-- Findings:
-- Olist grew rapidly through 2017, with MoM growth peaking at 705% (Jan-17)
-- and 110% (Feb-17) as the business scaled from near-zero in late 2016
-- Revenue stabilized in 2018 around 1M reais/month -- sign of business maturity
-- 3 sharpest drops: Dec-16, Sep-18, Oct-18 -- all data anomalies
-- (Dec-16: early launch phase, Sep/Oct-18: incomplete data at dataset cutoff)
-- Business Insight:
-- Revenue growth story is strong through 2017 but 2018 shows plateauing
-- Olist needs new growth levers -- new categories, new states, or seller expansion

SELECT * FROM order_payments;

WITH monthly_revenue AS(
SELECT SUM(p.payment_value) AS revenue,
       DATE_TRUNC('month',o.order_purchase_timestamp) AS month
FROM orders o
LEFT JOIN order_payments p
ON o.order_id = p.order_id
GROUP BY month
),  
mom AS(
SELECT month,
       revenue,
	   LAG(revenue) OVER(ORDER BY month) AS previous_month_revenue
FROM monthly_revenue
)
SELECT month,
       revenue,
	   previous_month_revenue,
	   ROUND((revenue - previous_month_revenue)/previous_month_revenue *100,2) AS mom_growth_pct
FROM mom
ORDER BY mom_growth_pct;