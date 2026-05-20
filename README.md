# Ecommerce Web Performance & Purchase Behavior Analysis | SQL

## Tools Used

- Google BigQuery
- SQL
- Google Analytics Sample Dataset

## Table of Contents

- [Background & Overview](#background--overview)
- [Business Questions](#business-questions)
- [Dataset Description](#dataset-description)
- [Project Structure](#project-structure)
- [Main Analysis](#main-analysis)
- [SQL Techniques](#sql-techniques)
- [Key Takeaways](#key-takeaways)
- [How to Run](#how-to-run)
- [References](#references)

## Background & Overview

This project analyzes web performance and purchase behavior for an ecommerce website using the Google Analytics sample dataset in BigQuery. The analysis focuses on traffic volume, engagement, conversion, revenue contribution, product purchase behavior, and funnel movement from product view to purchase.

The project answers practical ecommerce questions such as which traffic sources perform best, how customers move through the purchase funnel, which devices contribute the most revenue, and which products are commonly purchased together.

## Business Questions

This project is designed to answer the following questions:

- How did visits, pageviews, and transactions change across January, February, and March 2017?
- Which traffic sources had the highest bounce rate in July 2017?
- How much revenue did each traffic source generate by week and by month in June 2017?
- Which traffic sources had the best conversion rate in 2017?
- How do average pageviews differ between purchasers and non-purchasers?
- How many transactions did purchasing users make on average in July 2017?
- Which device categories contributed the most revenue in 2017?
- What other products were purchased by customers who bought `YouTube Men's Vintage Henley`?
- How did users move from product view to add to cart and purchase in Q1 2017?
- How did weekly revenue accumulate from May to July 2017?

## Dataset Description

This project uses the BigQuery public dataset:

```sql
bigquery-public-data.google_analytics_sample.ga_sessions_*
```

The dataset contains session-level Google Analytics data from the Google Merchandise Store. Some fields are nested and repeated, especially `hits` and `hits.product`, so product-level analysis requires `UNNEST`.

Important fields used in this project:

| Field | Description |
| --- | --- |
| `date` | Session date in `YYYYMMDD` format |
| `fullVisitorId` | Unique visitor identifier |
| `totals.visits` | Number of visits |
| `totals.pageviews` | Number of pageviews |
| `totals.transactions` | Number of transactions |
| `totals.bounces` | Number of bounce sessions |
| `trafficSource.source` | Traffic source |
| `device.deviceCategory` | Device category such as desktop, mobile, or tablet |
| `hits.eCommerceAction.action_type` | E-commerce action type such as product view, add to cart, or purchase |
| `product.v2ProductName` | Product name |
| `product.productQuantity` | Quantity purchased |
| `product.productRevenue` | Product revenue, divided by `1000000` for readable values |


## Main Analysis

### Query 01: Monthly Visits, Pageviews, and Transactions

This query calculates the total number of visits, pageviews, and transactions for January, February, and March 2017. The purpose is to understand monthly website traffic and transaction performance during Q1 2017.

The query uses `FORMAT_DATE` and `PARSE_DATE` to convert the raw `date` field into a monthly format, then aggregates visits, pageviews, and transactions by month.

**Result**

<img width="1216" height="243" alt="image" src="https://github.com/user-attachments/assets/5394b37e-5baf-454e-aacc-4221760a2d53" />

### Query 02: Bounce Rate by Traffic Source

This query calculates the bounce rate for each traffic source in July 2017. Bounce rate is calculated as the number of bounce sessions divided by the total number of visits.

This analysis helps identify which traffic sources brought users who left the website without further interaction after landing.

**Result**

<img width="1194" height="690" alt="image" src="https://github.com/user-attachments/assets/79d4deaf-0c24-492a-b8e2-86c4a6b2b8e2" />

### Query 03: Revenue by Traffic Source by Month and Week

This query calculates revenue by traffic source in June 2017 at two time levels: monthly and weekly. The monthly result and weekly result are created separately, then combined using `UNION ALL`.

Because revenue is stored inside the nested product field, the query uses `UNNEST(hits)` and `UNNEST(hits.product)` to access `product.productRevenue`. Revenue is divided by `1000000` to convert it into readable values.

**Result**

<img width="1312" height="690" alt="Screenshot 2026-05-20 130804" src="https://github.com/user-attachments/assets/b563e9fa-ee0a-4b6f-a43c-4427cc9c124f" />

### Query 04: Conversion Rate by Traffic Source

This query calculates the conversion rate by traffic source in 2017. Conversion rate is calculated as transactions divided by visits.

To keep the result focused on meaningful traffic sources, the query filters for sources with at least 50 transactions and orders the output by conversion rate in descending order.

**Result**

<img width="1183" height="255" alt="Screenshot 2026-05-20 130852" src="https://github.com/user-attachments/assets/69b30d5e-fb68-4c2b-bd9c-8de5754b6770" />


### Query 05: Average Pageviews by Purchaser Type

This query compares the average number of pageviews between purchasers and non-purchasers in June and July 2017.

Purchasers are users with at least one transaction and non-null product revenue. Non-purchasers are users with no transactions and null product revenue. The final result joins both groups by month.

**Result**

<img width="959" height="209" alt="image" src="https://github.com/user-attachments/assets/7c064cad-d120-4f25-8423-0795570f0737" />

### Query 06: Average Transactions per Purchasing User

This query calculates the average number of transactions per user who made a purchase in July 2017.

The metric is calculated by dividing total transactions by the number of unique purchasing users, using `fullVisitorId` as the user identifier.

**Result**

<img width="958" height="157" alt="image" src="https://github.com/user-attachments/assets/c73277a0-7191-4e9e-8213-a3e03258f497" />

### Query 07: Revenue Contribution by Device

This query calculates total revenue by device category in 2017 and compares each device category with total revenue.

The ratio shows how much each device contributes to overall revenue, helping evaluate whether desktop, mobile, or tablet users generate the most revenue.

**Result**

<img width="1216" height="248" alt="image" src="https://github.com/user-attachments/assets/202e28a2-12ee-400d-96e0-124bb0755c01" />

### Query 08: Other Products Purchased with YouTube Men's Vintage Henley

This query identifies other products purchased by customers who bought `YouTube Men's Vintage Henley` in July 2017.

The query first creates a buyer list using distinct `fullVisitorId`, then joins it back to product-level purchase data to find other purchased products and their quantities.

**Result**

<img width="974" height="692" alt="image" src="https://github.com/user-attachments/assets/8fb0b56c-d92e-4196-b3f3-31cfb0d3d2c1" />

### Query 09: Product View to Add-to-Cart and Purchase Funnel

This query builds a monthly funnel from product view to add to cart and purchase for January, February, and March 2017.

The funnel uses ecommerce action types: `2` for product view, `3` for add to cart, and `6` for purchase. The add-to-cart rate and purchase rate are calculated against the number of product views.

**Result**

<img width="1468" height="194" alt="image" src="https://github.com/user-attachments/assets/90f04f00-5462-475a-a29d-fa543ae0292b" />

### Query 10: Weekly Revenue and Cumulative Revenue

This query calculates weekly revenue from May to July 2017 and uses a window function to calculate cumulative revenue over time.

The cumulative revenue column shows the running total of revenue by week, which helps track revenue growth across the analysis period.

**Result**
<img width="974" height="691" alt="image" src="https://github.com/user-attachments/assets/aed5ca48-9450-428c-b817-6a3841f4cd3f" />


## SQL Techniques

The project uses the following SQL techniques:

- Wildcard tables with `_TABLE_SUFFIX` for date-range filtering.
- Date parsing and formatting with `PARSE_DATE` and `FORMAT_DATE`.
- Nested data handling with `UNNEST(hits)` and `UNNEST(hits.product)`.
- Conditional aggregation with `COUNT(CASE WHEN ... THEN ... END)`.
- Safe division with `SAFE_DIVIDE`.
- Joins for combining purchaser and non-purchaser metrics.
- Window functions for cumulative revenue.
- Revenue normalization by dividing `product.productRevenue` by `1000000`.


## Conclusion

Website performance improved in March 2017, which had the highest visits, pageviews, and transactions in Q1. Google and direct traffic were the largest traffic sources, but some high-volume channels also had high bounce rates.

Revenue was mainly driven by direct traffic and desktop users. Desktop contributed 96.41% of total revenue, while mobile and tablet contributed only a small share. The product funnel also improved from January to March, with both add-to-cart rate and purchase rate increasing over time.

Overall, the analysis shows that traffic volume, traffic quality, device experience, and funnel efficiency all play important roles in e-commerce performance.

## Recommendations

- Improve landing pages for high-bounce sources such as YouTube, Google, and mobile Facebook.
- Prioritize high-converting channels such as DFA and direct traffic.
- Review the mobile shopping and checkout experience to increase mobile revenue contribution.
- Investigate why non-purchasers view many more pages but do not convert.
- Use product recommendations for common co-purchased items such as Google Sunglasses and related apparel.
- Continue tracking funnel metrics and weekly cumulative revenue to monitor performance changes.

