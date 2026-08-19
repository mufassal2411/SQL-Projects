# Olist E-Commerce — Business Recommendations
## Based on SQL Analysis of 99,441 Orders (2016–2018)

---

## Top 3 States Olist Should Prioritize for Operational Improvement

---

### 1. Rio de Janeiro (RJ)
**Why it matters:** Second highest revenue state at 2.15M reais — too valuable to ignore.

**The problem:**
- Average review score of 3.90 — below the national leader SP (4.21)
- Delivery delays in high-value categories pushing customers toward negative reviews
- Q7 proved that even 1-7 days of delay drops review scores from 4.29 to 2.68

**Recommendation:**
- Partner with regional logistics providers in RJ to reduce last-mile delivery time
- Prioritize seller onboarding in RJ to reduce cross-state shipments
- Set up a regional fulfillment center to serve RJ customers faster

---

### 2. Bahia (BA)
**Why it matters:** 618k reais revenue with consistently low review scores (3.86) — underperforming relative to its size.

**The problem:**
- One of the lowest review scores among high-revenue states
- Northern location means longer delivery distances from São Paulo sellers
- Q6 showed northeastern states cluster in worst delay combinations

**Recommendation:**
- Recruit more local sellers in BA to reduce delivery distance
- Implement proactive delay alerts — notify customers when orders are projected late
- Q7 shows managing expectations reduces review damage even when delays occur

---

### 3. Pará (PA)
**Why it matters:** 218k revenue but review score of only 3.84 — chronic logistics problem threatening growth.

**The problem:**
- Q6 identified PA as one of the worst states for delivery delays (28 day avg in some categories)
- Remote geography means national logistics partners deprioritize the region
- Low review scores will suppress future customer acquisition in the state

**Recommendation:**
- Negotiate dedicated logistics SLAs for northern states (PA, AM, RO)
- Consider restricting heavy/bulky product categories in PA until logistics improve
- Offer extended estimated delivery windows to set accurate expectations

---

## Cross-Cutting Recommendations (All States)

### Retention is the #1 Business Problem
- Q3 showed less than 1% of customers return after their first purchase — across ALL cohorts
- Olist is running on a leaky bucket — strong acquisition, near-zero retention
- **Action:** Launch post-purchase email campaigns, loyalty programs, and personalized recommendations targeting Bronze customers (91k customers, 74% of revenue)

### Delivery SLA Must Be Enforced
- Q7 proved 7 days of delay cuts review scores nearly in half (4.29 → 2.68)
- Q5 identified sellers with 40-50% delay rates still generating significant revenue
- **Action:** Set a hard 7-day delay SLA. Sellers exceeding it consistently should face reduced listing visibility or account review

### Data Quality Improvements Needed
- Q8 found 88% of reviews have no title, 59% have no written message — limiting feedback quality
- Q9 found ~60 orders with timestamp inconsistencies due to batch approval processing
- **Action:** Switch from batch approval jobs to event-driven logging to fix timestamp issues

---

## Summary

| State | Revenue | Avg Review | Priority Reason |
|-------|---------|------------|-----------------|
| RJ    | 2.15M   | 3.90       | High value, underperforming satisfaction |
| BA    | 618k    | 3.86       | Chronic low reviews, logistics gap |
| PA    | 218k    | 3.84       | Worst delay + review combination |

*Analysis based on 99,441 orders, 3,095 sellers, 99,441 customers across Brazil (2016–2018)*
