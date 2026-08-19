from visualizations import run_query


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
print(df1.head())
print(df1.shape)
df1['month'] = pd.to_datetime(df1['month'])

fig, ax1 = plt.subplots()

# Revenue line
ax1.plot(df1['month'], df1['revenue'], color='#2196F3', linewidth=2.5, label='Revenue')
ax1.fill_between(df1['month'], df1['revenue'], alpha=0.1, color='#2196F3')
ax1.set_xlabel('Month')
ax1.set_ylabel('Revenue (Reais)', color='#2196F3')
ax1.tick_params(axis='y', labelcolor='#2196F3')

# MoM growth bars on second axis
ax2 = ax1.twinx()
ax2.bar(df1['month'], df1['mom_growth_pct'], alpha=0.3, color='orange', width=20, label='MoM Growth %')
ax2.set_ylabel('MoM Growth %', color='orange')
ax2.tick_params(axis='y', labelcolor='orange')

plt.title('Olist Monthly Revenue Trend with MoM Growth (2016-2018)')
fig.tight_layout()
plt.savefig(os.path.join(output_path, '01_monthly_revenue.png'), dpi=150, bbox_inches='tight')
print("Chart 1 saved.")
plt.show()