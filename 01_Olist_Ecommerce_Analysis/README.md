# 🛒 Olist E-Commerce Sales Analysis
### End-to-End SQL + Python Analytics Project

![Python](https://img.shields.io/badge/Python-3.14-blue) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue) ![pandas](https://img.shields.io/badge/pandas-2.0-green) ![matplotlib](https://img.shields.io/badge/matplotlib-3.11-orange) ![seaborn](https://img.shields.io/badge/seaborn-0.13-teal)

---

## 📌 Project Overview

This project performs a full business analysis of **Olist**, a Brazilian e-commerce marketplace, using **99,441 real orders** placed between 2016 and 2018. The goal is to extract actionable business insights across revenue, customer behavior, seller performance, and logistics — using only SQL and Python.

Built to demonstrate skills relevant to **Data Analyst** and **Data Engineer** roles:
- Advanced SQL (window functions, CTEs, cohort analysis, aggregations)
- Data quality auditing and inconsistency detection
- Python visualization connected directly to PostgreSQL
- Business storytelling and data-backed recommendations

---

## 📂 Project Structure

```
olist-ecommerce-sql/
├── sql/
│   ├── 01_monthly_revenue_mom.sql
│   ├── 02_top5_revenue_categories.sql
│   ├── 03_cohort_retention.sql
│   ├── 04_customer_clv_segmentation.sql
│   ├── 05_seller_delay_ranking.sql
│   ├── 06_state_category_delay.sql
│   ├── 07_delay_vs_review_score.sql
│   ├── 08_null_audit.sql
│   ├── 09_data_inconsistencies.sql
│   └── 10_state_prioritization.sql
├── python/
│   ├── test_connection.py
│   └── visualizations.py
├── outputs/
│   └── charts/
│       ├── 01_monthly_revenue.png
│       ├── 02_cohort_retention.png
│       ├── 03_clv_segmentation.png
│       ├── 04_state_category_delay.png
│       └── 05_delay_vs_review.png
├── schema/
│   └── 01_create_tables.sql
├── business_recommendations.md
└── README.md
```

---

## 🗄️ Dataset

**Source:** [Olist Brazilian E-Commerce Dataset — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

| Table | Rows | Description |
|-------|------|-------------|
| orders | 99,441 | Core order lifecycle and timestamps |
| customers | 99,441 | Customer location and unique IDs |
| order_items | 112,650 | Products and sellers per order |
| order_payments | 103,886 | Payment method and value |
| order_reviews | 99,224 | Customer review scores and comments |
| products | 32,951 | Product categories and dimensions |
| sellers | 3,095 | Seller location data |
| geolocation | 1,000,163 | Zip code level coordinates |

---

## 🔍 Analysis Modules

### Module 1 — Revenue Intelligence
**Q1. Monthly Revenue Trend with MoM Growth**
- Olist grew from near-zero in Sep 2016 to ~1.2M reais/month by Nov 2017
- Revenue plateaued in 2018 at ~1M reais/month — sign of business maturity
- Sharpest drops in Sep/Oct 2018 are due to incomplete data at dataset cutoff, not real decline

**Q2. Top 5 Revenue Categories with Cumulative % Share**
- bed_bath_table leads at 1.7M reais (8.43% of total revenue)
- Top 5 categories contribute only ~38% of total — revenue is well distributed
- No single dominant category — Olist's strength is breadth, not depth

---

### Module 2 — Customer Behavior
**Q3. Cohort Retention Analysis**

![Cohort Retention Heatmap](outputs/charts/02_cohort_retention.png)

- **Less than 1% of customers return after their first purchase — across all cohorts**
- January 2017 cohort (764 customers): only 0.39% returned in Month 1
- Retention crisis is consistent across 2 years of data — not a temporary issue

**Q4. Customer CLV Segmentation (Bronze / Silver / Gold)**

![CLV Segmentation](outputs/charts/03_clv_segmentation.png)

| Segment | Customers | Revenue Share |
|---------|-----------|---------------|
| Bronze (<500R) | 91,606 | 73.92% |
| Silver (500-2500R) | 4,399 | 24.03% |
| Gold (>2500R) | 90 | 2.05% |

- Business is driven by high volume of small one-time purchases
- Combined with Q3 findings: Olist has a severe retention problem

---

### Module 3 — Operational Efficiency
**Q5. Seller Delay Ranking with Revenue Contribution**
- Top seller has 50% delay rate — 1 in 2 orders consistently late
- High-revenue sellers with high delay rates are the critical risk — can't offboard them but can't ignore the problem
- Minimum 15 orders threshold applied to avoid small sample bias

**Q6. State × Category Delivery Delay Heatmap**

![State Category Delay Heatmap](outputs/charts/04_state_category_delay.png)

- All top 10 worst state×category combinations show 22+ day average delays
- Northern states (RR, PA, AM, AC) dominate the worst combinations
- RR + bed_bath_table: 29 day average delay — the biggest revenue category in the worst delivery state

**Q7. Delivery Delay vs Review Score — Proof**

![Delay vs Review Score](outputs/charts/05_delay_vs_review.png)

| Delivery Status | Avg Review Score |
|-----------------|-----------------|
| On Time | 4.29 |
| 1-7 Days Late | 2.68 |
| 8-14 Days Late | 1.70 |
| 15+ Days Late | 1.71 |

- **One week of delay cuts review scores nearly in half (4.29 → 2.68)**
- After 8 days, satisfaction flatlines — customers are already done
- 7-day delay threshold is the critical SLA Olist must enforce

---

### Module 4 — Data Quality (DE Signal)
**Q8. Null Audit — Completeness % Across All Tables**
- Core transactional data: 100% complete (order_id, customer_id, payment_value, etc.)
- review_comment_title: only **11.66% complete** — 88% of customers skip the title
- review_comment_message: **41.30% complete** — majority prefer star ratings only
- order_delivered_customer_date: **97.02%** — ~3% of orders have no delivery timestamp

**Q9. Data Inconsistencies**
- ~60 orders show delivery before approval timestamp — caused by a midnight batch approval job
- ~8 orders marked 'delivered' with NULL delivery timestamp — status update bug
- No timestamp sequence violations found (purchase → approval → delivery order is always correct)

---

### Module 5 — Business Recommendations
**Q10. Which 3 States Should Olist Prioritize?**

| State | Revenue | Avg Review Score | Priority Reason |
|-------|---------|-----------------|-----------------|
| RJ | 2.15M | 3.90 | Highest value state underperforming on satisfaction |
| BA | 618k | 3.86 | Chronic low reviews, logistics gap |
| PA | 218k | 3.84 | Worst delay + review combination |

See [business_recommendations.md](business_recommendations.md) for full recommendations.

---

## 📊 Key Visualizations

| Chart | Insight |
|-------|---------|
| ![Revenue](outputs/charts/01_monthly_revenue.png) | Revenue grew 10x in 2017, plateaued in 2018 |
| ![Cohort](outputs/charts/02_cohort_retention.png) | <1% retention across all cohorts |
| ![CLV](outputs/charts/03_clv_segmentation.png) | 91k Bronze customers drive 74% of revenue |
| ![Delay Heatmap](outputs/charts/04_state_category_delay.png) | Northern states have 22-29 day delays |
| ![Review](outputs/charts/05_delay_vs_review.png) | 7 days of delay halves review scores |

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| PostgreSQL 16 | Database and all SQL analysis |
| pgAdmin 4 | Query execution and data loading |
| Python 3.14 | Visualization scripting |
| pandas | Data manipulation |
| matplotlib + seaborn | Chart generation |
| psycopg2 | Python ↔ PostgreSQL connection |

---

## 🚀 How to Run

**1. Clone the repo**
```bash
git clone https://github.com/yourusername/olist-ecommerce-sql.git
```

**2. Set up the database**
```bash
# Create olist_db in PostgreSQL
# Run schema/01_create_tables.sql in pgAdmin
# Import all 8 CSVs from Kaggle dataset
```

**3. Run SQL analyses**
```bash
# Open any file in sql/ folder and run in pgAdmin
```

**4. Generate visualizations**
```bash
pip install pandas matplotlib seaborn psycopg2-binary
# Update password in python/visualizations.py
python python/visualizations.py
```

---

## 💡 Key Business Insights

1. **Retention is the #1 problem** — <1% of customers return. Olist needs loyalty programs and post-purchase campaigns urgently.
2. **7-day delivery SLA is critical** — One week of delay halves customer satisfaction. This is the single biggest lever for review score improvement.
3. **Northern states need dedicated logistics** — RR, PA, AM, AC average 22-29 day delays. Regional fulfillment centers would have outsized impact.
4. **Batch approval system needs fixing** — ~60 timestamp inconsistencies caused by midnight batch jobs. Switch to event-driven logging.
5. **Bronze customers are the business** — 91k customers driving 74% revenue are all one-time buyers. Converting 5% to repeat buyers would dramatically improve revenue without increasing acquisition costs.

---

*Analysis based on 99,441 orders, 3,095 sellers, 99,441 customers across Brazil (2016–2018)*

*Dataset: [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)*
