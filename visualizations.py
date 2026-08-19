import psycopg2
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import seaborn as sns
import os

print("Script started")

# ================================================
# CONNECTION
# ================================================
conn = psycopg2.connect(
    host="localhost",
    database="olist_db",
    user="postgres",
    password="newp@ssword`",
    port="5432"
)
print("Connected successfully")

# ================================================
# OUTPUT FOLDER
# ================================================
output_path = r"C:\Users\Faeza Kafeel\OneDrive\Documents\SQL PROJECTS\E-Commerce Sales Analysis(OList)\outputs\charts"
os.makedirs(output_path, exist_ok=True)

# ================================================
# STYLE
# ================================================
sns.set_theme(style="darkgrid")
plt.rcParams['figure.figsize'] = (12, 6)

# ================================================
# HELPER FUNCTION
# ================================================
def run_query(query):
    cursor = conn.cursor()
    cursor.execute(query)
    cols = [desc[0] for desc in cursor.description]
    data = cursor.fetchall()
    return pd.DataFrame(data, columns=cols)

# ================================================
# CHART 1 — Monthly Revenue Trend with MoM Growth
# ================================================
print("Running Chart 1...")

query1 = """
WITH monthly_revenue AS (
    SELECT SUM(p.payment_value) AS revenue,
           DATE_TRUNC('month', o.order_purchase_timestamp) AS month
    FROM orders o
    LEFT JOIN order_payments p ON o.order_id = p.order_id
    GROUP BY month
),
mom AS (
    SELECT month,
           revenue,
           LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue
    FROM monthly_revenue
)
SELECT month,
       revenue,
       ROUND((revenue - prev_month_revenue)/prev_month_revenue * 100, 2) AS mom_growth_pct
FROM mom
WHERE prev_month_revenue IS NOT NULL
ORDER BY month;
"""

df1 = run_query(query1)
print(df1.shape)
df1['month'] = pd.to_datetime(df1['month'])
df1['revenue'] = df1['revenue'].astype(float)
df1['mom_growth_pct'] = df1['mom_growth_pct'].astype(float)

fig, ax1 = plt.subplots(figsize=(12, 6))

ax1.plot(df1['month'], df1['revenue'], color='#2196F3', linewidth=2.5, label='Revenue')
ax1.fill_between(df1['month'], df1['revenue'], alpha=0.1, color='#2196F3')
ax1.set_xlabel('Month')
ax1.set_ylabel('Revenue (Reais)', color='#2196F3')
ax1.tick_params(axis='y', labelcolor='#2196F3')

ax2 = ax1.twinx()
ax2.bar(df1['month'], df1['mom_growth_pct'], alpha=0.3, color='orange', width=20, label='MoM Growth %')
ax2.set_ylabel('MoM Growth %', color='orange')
ax2.tick_params(axis='y', labelcolor='orange')

plt.title('Olist Monthly Revenue Trend with MoM Growth (2016-2018)', fontsize=14, fontweight='bold')
fig.tight_layout()
plt.savefig(os.path.join(output_path, '01_monthly_revenue.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Chart 1 saved.")

# ================================================
# CHART 2 — Cohort Retention Heatmap
# ================================================
print("Running Chart 2...")

query2 = """
WITH cte AS (
    SELECT c.customer_unique_id AS unique_id,
           MIN(DATE_TRUNC('month', o.order_purchase_timestamp)) AS first_month
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY unique_id
),
cte2 AS (
    SELECT cte.unique_id,
           cte.first_month,
           (EXTRACT(YEAR FROM age(o.order_purchase_timestamp, cte.first_month)) * 12 +
            EXTRACT(MONTH FROM age(o.order_purchase_timestamp, cte.first_month))) AS month_number
    FROM cte
    JOIN customers c ON cte.unique_id = c.customer_unique_id
    JOIN orders o ON c.customer_id = o.customer_id
),
cte3 AS (
    SELECT first_month,
           month_number,
           COUNT(DISTINCT unique_id) AS count_u_id
    FROM cte2
    WHERE month_number IN (0, 1, 2, 3)
    GROUP BY first_month, month_number
),
cte4 AS (
    SELECT first_month,
           month_number,
           count_u_id,
           SUM(CASE WHEN month_number = 0 THEN count_u_id ELSE 0 END)
               OVER (PARTITION BY first_month) AS cohort_size
    FROM cte3
)
SELECT TO_CHAR(first_month, 'YYYY-MM') AS cohort,
       month_number,
       ROUND(count_u_id::numeric / cohort_size * 100, 2) AS retention_pct
FROM cte4
ORDER BY first_month, month_number;
"""

df2 = run_query(query2)
print(df2.shape)
df2['retention_pct'] = df2['retention_pct'].astype(float)

pivot = df2.pivot(index='cohort', columns='month_number', values='retention_pct')
pivot.columns = ['Month 0', 'Month 1', 'Month 2', 'Month 3']

plt.figure(figsize=(10, 10))
sns.heatmap(pivot, annot=True, fmt='.1f', cmap='YlOrRd_r',
            linewidths=0.5, cbar_kws={'label': 'Retention %'})
plt.title('Olist Customer Cohort Retention Heatmap (%)', fontsize=14, fontweight='bold')
plt.xlabel('Months After First Purchase')
plt.ylabel('Cohort (First Purchase Month)')
plt.tight_layout()
plt.savefig(os.path.join(output_path, '02_cohort_retention.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Chart 2 saved.")

# ================================================
# CHART 3 — CLV Segmentation
# ================================================
print("Running Chart 3...")

query3 = """
WITH cte AS (
    SELECT c.customer_unique_id AS unique_id,
           SUM(op.payment_value) AS revenue
    FROM order_payments op
    LEFT JOIN orders o ON op.order_id = o.order_id
    LEFT JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY unique_id
)
SELECT
    CASE WHEN revenue < 500 THEN 'Bronze'
         WHEN revenue >= 500 AND revenue < 2500 THEN 'Silver'
         ELSE 'Gold'
    END AS level,
    COUNT(unique_id) AS customer_count,
    ROUND(SUM(revenue)::numeric, 2) AS total_revenue,
    ROUND(SUM(revenue) / (SELECT SUM(revenue) FROM cte) * 100, 2) AS revenue_pct
FROM cte
GROUP BY level
ORDER BY total_revenue DESC;
"""

df3 = run_query(query3)
print(df3.shape)
df3['customer_count'] = df3['customer_count'].astype(int)
df3['revenue_pct'] = df3['revenue_pct'].astype(float)

colors = {'Bronze': '#CD7F32', 'Silver': '#C0C0C0', 'Gold': '#FFD700'}
bar_colors = [colors[l] for l in df3['level']]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

ax1.bar(df3['level'], df3['customer_count'], color=bar_colors, edgecolor='black')
ax1.set_title('Customer Count by CLV Segment', fontweight='bold')
ax1.set_xlabel('Segment')
ax1.set_ylabel('Number of Customers')
for i, v in enumerate(df3['customer_count']):
    ax1.text(i, v + 500, f'{v:,}', ha='center', fontweight='bold')

ax2.bar(df3['level'], df3['revenue_pct'], color=bar_colors, edgecolor='black')
ax2.set_title('Revenue % by CLV Segment', fontweight='bold')
ax2.set_xlabel('Segment')
ax2.set_ylabel('Revenue %')
for i, v in enumerate(df3['revenue_pct']):
    ax2.text(i, v + 0.5, f'{v}%', ha='center', fontweight='bold')

plt.suptitle('Olist Customer Lifetime Value Segmentation', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig(os.path.join(output_path, '03_clv_segmentation.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Chart 3 saved.")

# ================================================
# CHART 4 — State x Category Delay Heatmap (Top 10)
# ================================================
print("Running Chart 4...")

query4 = """
WITH cte AS (
    SELECT EXTRACT(DAY FROM age(o.order_delivered_customer_date,
                                o.order_estimated_delivery_date)) AS delay_days,
           c.customer_state AS state,
           t.product_category_name_english AS category
    FROM orders o
    LEFT JOIN customers c ON o.customer_id = c.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN products p ON p.product_id = oi.product_id
    LEFT JOIN product_category_name_translation t
           ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date > o.order_estimated_delivery_date
)
SELECT state,
       category,
       ROUND(AVG(delay_days)::numeric, 1) AS avg_delay_days
FROM cte
WHERE category IS NOT NULL
GROUP BY state, category
ORDER BY avg_delay_days DESC
LIMIT 50;
"""

df4 = run_query(query4)
print(df4.shape)
df4['avg_delay_days'] = df4['avg_delay_days'].astype(float)

pivot4 = df4.pivot_table(index='state', columns='category', values='avg_delay_days')

plt.figure(figsize=(16, 8))
sns.heatmap(pivot4, cmap='Reds', linewidths=0.3,
            cbar_kws={'label': 'Avg Delay Days'},
            annot=True, fmt='.0f')
plt.title('Olist Delivery Delay Heatmap — State × Category (Top 50 Worst)', fontsize=14, fontweight='bold')
plt.xlabel('Product Category')
plt.ylabel('Customer State')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig(os.path.join(output_path, '04_state_category_delay.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Chart 4 saved.")

# ================================================
# CHART 5 — Delay vs Review Score
# ================================================
print("Running Chart 5...")

query5 = """
WITH cte AS (
    SELECT EXTRACT(DAY FROM age(o.order_delivered_customer_date,
                                o.order_estimated_delivery_date)) AS delay_days,
           r.review_score
    FROM orders o
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
)
SELECT
    CASE WHEN delay_days <= 0 THEN 'On Time'
         WHEN delay_days BETWEEN 1 AND 7 THEN '1-7 Days Late'
         WHEN delay_days BETWEEN 8 AND 14 THEN '8-14 Days Late'
         ELSE '15+ Days Late'
    END AS delay_bucket,
    ROUND(AVG(review_score)::numeric, 2) AS avg_review_score,
    COUNT(*) AS order_count
FROM cte
WHERE review_score IS NOT NULL
GROUP BY delay_bucket
ORDER BY avg_review_score DESC;
"""

df5 = run_query(query5)
print(df5.shape)
df5['avg_review_score'] = df5['avg_review_score'].astype(float)

bucket_order = ['On Time', '1-7 Days Late', '8-14 Days Late', '15+ Days Late']
df5['delay_bucket'] = pd.Categorical(df5['delay_bucket'], categories=bucket_order, ordered=True)
df5 = df5.sort_values('delay_bucket')

colors = ['#4CAF50', '#FFC107', '#FF5722', '#B71C1C']

fig, ax = plt.subplots(figsize=(10, 6))
bars = ax.bar(df5['delay_bucket'], df5['avg_review_score'], color=colors, edgecolor='black', width=0.5)
ax.set_ylim(0, 5)
ax.set_xlabel('Delivery Status', fontsize=12)
ax.set_ylabel('Average Review Score (out of 5)', fontsize=12)
ax.set_title('Impact of Delivery Delay on Review Scores', fontsize=14, fontweight='bold')
ax.axhline(y=4.0, color='gray', linestyle='--', alpha=0.5, label='Score = 4.0')

for bar, score in zip(bars, df5['avg_review_score']):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
            f'{score}', ha='center', fontsize=12, fontweight='bold')

plt.tight_layout()
plt.savefig(os.path.join(output_path, '05_delay_vs_review.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Chart 5 saved.")

# ================================================
# DONE
# ================================================
conn.close()
print("\nAll 5 charts saved successfully!")