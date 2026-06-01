# Ecommerce Web Performance & Purchase Behavior Analysis | SQL

![BigQuery](https://img.shields.io/badge/Google%20BigQuery-SQL%20Analysis-4285F4?style=for-the-badge&logo=googlebigquery&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Ecommerce%20Analytics-336791?style=for-the-badge)
![Dataset](https://img.shields.io/badge/Dataset-Google%20Analytics%20Sample-F2C94C?style=for-the-badge)

## Overview

This project analyzes web performance and purchase behavior for an ecommerce website using SQL in Google BigQuery.

The analysis is based on the Google Analytics Sample Dataset and focuses on traffic volume, bounce rate, conversion, revenue contribution, product purchase behavior, shopping funnel movement, and cumulative revenue performance.

## Objective

Use SQL to analyze ecommerce traffic, engagement, conversion, revenue, device performance, and purchase behavior, then turn raw Google Analytics data into clear business insights for channel optimization, funnel improvement, and revenue monitoring.

## Dataset

This project uses the BigQuery public dataset:

```sql
bigquery-public-data.google_analytics_sample.ga_sessions_*
```

The dataset contains session-level Google Analytics data from the Google Merchandise Store. Some fields are nested and repeated, especially `hits` and `hits.product`, so product-level analysis requires `UNNEST`.

| Field | Description |
| --- | --- |
| `date` | Session date in `YYYYMMDD` format. |
| `fullVisitorId` | Unique visitor identifier. |
| `totals.visits` | Number of visits. |
| `totals.pageviews` | Number of pageviews. |
| `totals.transactions` | Number of transactions. |
| `totals.bounces` | Number of bounce sessions. |
| `trafficSource.source` | Traffic source. |
| `device.deviceCategory` | Device category such as desktop, mobile, or tablet. |
| `hits.eCommerceAction.action_type` | Ecommerce action type such as product view, add to cart, or purchase. |
| `product.v2ProductName` | Product name. |
| `product.productQuantity` | Quantity purchased. |
| `product.productRevenue` | Product revenue, divided by `1000000` for readable values. |

## Repository Structure

```text
Ecommerce_Analysis_SQL/
|-- Ecommerce Analysis.sql
`-- README.md
```

## Analytics

Each analysis includes the business question, SQL query, result screenshot, and key insight.

SQL script: `Ecommerce Analysis.sql`

| No. | Analysis Area | Business Question | Main Output |
| --- | --- | --- | --- |
| 01 | Monthly Website Performance | How did visits, pageviews, and transactions change across Q1 2017? | Monthly visits, pageviews, and transactions |
| 02 | Bounce Rate by Source | Which traffic sources had the highest bounce rate in July 2017? | Bounce rate by traffic source |
| 03 | Revenue by Source and Time | How much revenue did each source generate by month and week in June 2017? | Revenue by source, month, and week |
| 04 | Conversion Rate by Source | Which sources had the best conversion rate in 2017? | Source-level conversion rate |
| 05 | Pageviews by Purchaser Type | How do average pageviews differ between purchasers and non-purchasers? | Average pageviews by user type |
| 06 | Transactions per Purchasing User | How many transactions did purchasing users make on average in July 2017? | Average transactions per purchasing user |
| 07 | Revenue by Device | Which devices contributed the most revenue in 2017? | Revenue and ratio by device |
| 08 | Co-Purchased Products | What other products were purchased by customers who bought `YouTube Men's Vintage Henley`? | Co-purchased product quantities |
| 09 | Product Funnel | How did users move from product view to add to cart and purchase in Q1 2017? | View, add-to-cart, and purchase funnel |
| 10 | Weekly Cumulative Revenue | How did weekly revenue accumulate from May to July 2017? | Weekly and cumulative revenue |

<details>
<summary><strong>01. Monthly Visits, Pageviews, and Transactions</strong></summary>

**Business question:** How did visits, pageviews, and transactions change across January, February, and March 2017?

**SQL query:**

```sql
SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
    SUM(totals.visits) AS visits,
    SUM(totals.pageviews) AS pageviews,
    SUM(totals.transactions) AS transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
GROUP BY month
ORDER BY month;
```

**Result:**

<p align="center">
  <img width="1216" height="243" alt="Query 01 Result" src="https://github.com/user-attachments/assets/5394b37e-5baf-454e-aacc-4221760a2d53" />
</p>

**Key insight:** March 2017 had the highest visits, pageviews, and transactions in Q1, showing stronger website performance than January and February.

</details>

<details>
<summary><strong>02. Bounce Rate by Traffic Source</strong></summary>

**Business question:** Which traffic sources had the highest bounce rate in July 2017?

**SQL query:**

```sql
SELECT
    trafficSource.source AS source,
    COUNT(totals.visits) AS total_visits,
    COUNT(totals.bounces) AS total_no_of_bounces,
    ROUND(SAFE_DIVIDE(COUNT(totals.bounces), COUNT(totals.visits)) * 100, 3) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
GROUP BY source
ORDER BY total_visits DESC;
```

**Result:**

<p align="center">
  <img width="1194" height="690" alt="Query 02 Result" src="https://github.com/user-attachments/assets/79d4deaf-0c24-492a-b8e2-86c4a6b2b8e2" />
</p>

**Key insight:** Google and direct traffic generated the largest visit volume, while several referral sources showed high bounce rates that may indicate weak landing-page relevance.

</details>

<details>
<summary><strong>03. Revenue by Traffic Source by Month and Week</strong></summary>

**Business question:** How much revenue did each traffic source generate by week and by month in June 2017?

**SQL query:**

```sql
WITH month_data AS (
    SELECT
        'Month' AS time_type,
        FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS time,
        trafficSource.source AS source,
        SUM(product.productRevenue) / 1000000 AS revenue
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    CROSS JOIN UNNEST(hits) AS hits
    CROSS JOIN UNNEST(hits.product) AS product
    WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170630'
        AND product.productRevenue IS NOT NULL
    GROUP BY time_type, time, source
),
week_data AS (
    SELECT
        'Week' AS time_type,
        FORMAT_DATE('%Y%W', PARSE_DATE('%Y%m%d', date)) AS time,
        trafficSource.source AS source,
        SUM(product.productRevenue) / 1000000 AS revenue
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    CROSS JOIN UNNEST(hits) AS hits
    CROSS JOIN UNNEST(hits.product) AS product
    WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170630'
        AND product.productRevenue IS NOT NULL
    GROUP BY time_type, time, source
)
SELECT
    time_type,
    time,
    source,
    ROUND(revenue, 4) AS revenue
FROM month_data
UNION ALL
SELECT
    time_type,
    time,
    source,
    ROUND(revenue, 4) AS revenue
FROM week_data
ORDER BY time_type, time, revenue DESC;
```

**Result:**

<p align="center">
  <img width="1312" height="690" alt="Query 03 Result" src="https://github.com/user-attachments/assets/b563e9fa-ee0a-4b6f-a43c-4427cc9c124f" />
</p>

**Key insight:** Direct traffic generated the highest visible revenue in June 2017, with Google and DFA also contributing meaningful revenue.

</details>

<details>
<summary><strong>04. Conversion Rate by Traffic Source</strong></summary>

**Business question:** Which traffic sources had the best conversion rate in 2017?

**SQL query:**

```sql
SELECT
    trafficSource.source AS source,
    SUM(totals.visits) AS visits,
    SUM(totals.transactions) AS transactions,
    FORMAT('%.2f%%', SAFE_DIVIDE(SUM(totals.transactions), SUM(totals.visits)) * 100) AS conversion_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20171231'
GROUP BY source
HAVING SUM(totals.transactions) >= 50
ORDER BY SAFE_DIVIDE(SUM(totals.transactions), SUM(totals.visits)) DESC;
```

**Result:**

<p align="center">
  <img width="1183" height="255" alt="Query 04 Result" src="https://github.com/user-attachments/assets/69b30d5e-fb68-4c2b-bd9c-8de5754b6770" />
</p>

**Key insight:** DFA had the highest conversion rate among qualified sources, while direct traffic contributed the largest transaction volume.

</details>

<details>
<summary><strong>05. Average Pageviews by Purchaser Type</strong></summary>

**Business question:** How do average pageviews differ between purchasers and non-purchasers?

**SQL query:**

```sql
WITH purchaser_data AS (
    SELECT
        FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
        SUM(totals.pageviews) / COUNT(DISTINCT fullVisitorId) AS avg_pageviews_purchase
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    CROSS JOIN UNNEST(hits) AS hits
    CROSS JOIN UNNEST(hits.product) AS product
    WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170731'
        AND totals.transactions >= 1
        AND product.productRevenue IS NOT NULL
    GROUP BY month
),
non_purchaser_data AS (
    SELECT
        FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
        SUM(totals.pageviews) / COUNT(DISTINCT fullVisitorId) AS avg_pageviews_non_purchase
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    CROSS JOIN UNNEST(hits) AS hits
    CROSS JOIN UNNEST(hits.product) AS product
    WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170731'
        AND totals.transactions IS NULL
        AND product.productRevenue IS NULL
    GROUP BY month
)
SELECT
    month,
    avg_pageviews_purchase,
    avg_pageviews_non_purchase
FROM purchaser_data
FULL OUTER JOIN non_purchaser_data
    USING (month)
ORDER BY month;
```

**Result:**

<p align="center">
  <img width="959" height="209" alt="Query 05 Result" src="https://github.com/user-attachments/assets/7c064cad-d120-4f25-8423-0795570f0737" />
</p>

**Key insight:** Non-purchasers viewed more pages on average than purchasers, suggesting browsing friction or difficulty finding the right product.

</details>

<details>
<summary><strong>06. Average Transactions per Purchasing User</strong></summary>

**Business question:** How many transactions did purchasing users make on average in July 2017?

**SQL query:**

```sql
SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
    SUM(totals.transactions) / COUNT(DISTINCT fullVisitorId) AS avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
CROSS JOIN UNNEST(hits) AS hits
CROSS JOIN UNNEST(hits.product) AS product
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
    AND totals.transactions >= 1
    AND product.productRevenue IS NOT NULL
GROUP BY month;
```

**Result:**

<p align="center">
  <img width="958" height="157" alt="Query 06 Result" src="https://github.com/user-attachments/assets/c73277a0-7191-4e9e-8213-a3e03258f497" />
</p>

**Key insight:** Purchasing users made about 43.86 transactions per user in July 2017 based on the query result.

</details>

<details>
<summary><strong>07. Revenue Contribution by Device</strong></summary>

**Business question:** Which device categories contributed the most revenue in 2017?

**SQL query:**

```sql
WITH revenue_by_device AS (
    SELECT
        device.deviceCategory AS device,
        SUM(product.productRevenue) / 1000000 AS device_revenue
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    CROSS JOIN UNNEST(hits) AS hits
    CROSS JOIN UNNEST(hits.product) AS product
    WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20171231'
        AND totals.transactions IS NOT NULL
        AND product.productRevenue IS NOT NULL
    GROUP BY device
),
total_revenue AS (
    SELECT
        SUM(device_revenue) AS total_revenue
    FROM revenue_by_device
)
SELECT
    revenue_by_device.device,
    ROUND(revenue_by_device.device_revenue, 2) AS revenue_by_device,
    ROUND(total_revenue.total_revenue, 2) AS total_revenue,
    ROUND(
        SAFE_DIVIDE(revenue_by_device.device_revenue, total_revenue.total_revenue) * 100,
        2
    ) AS ratio
FROM revenue_by_device
CROSS JOIN total_revenue
ORDER BY ratio DESC;
```

**Result:**

<p align="center">
  <img width="1216" height="248" alt="Query 07 Result" src="https://github.com/user-attachments/assets/202e28a2-12ee-400d-96e0-124bb0755c01" />
</p>

**Key insight:** Desktop contributed 96.41% of total revenue, while mobile and tablet contributed only a small share.

</details>

<details>
<summary><strong>08. Other Products Purchased with YouTube Men's Vintage Henley</strong></summary>

**Business question:** What other products were purchased by customers who bought `YouTube Men's Vintage Henley`?

**SQL query:**

```sql
WITH buyer_list AS (
    SELECT DISTINCT
        fullVisitorId
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    CROSS JOIN UNNEST(hits) AS hits
    CROSS JOIN UNNEST(hits.product) AS product
    WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
        AND totals.transactions >= 1
        AND product.productRevenue IS NOT NULL
        AND product.v2ProductName = "YouTube Men's Vintage Henley"
)
SELECT
    product.v2ProductName AS other_purchased_products,
    SUM(product.productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS sessions
CROSS JOIN UNNEST(sessions.hits) AS hits
CROSS JOIN UNNEST(hits.product) AS product
JOIN buyer_list
    ON sessions.fullVisitorId = buyer_list.fullVisitorId
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
    AND sessions.totals.transactions >= 1
    AND product.productRevenue IS NOT NULL
    AND product.v2ProductName != "YouTube Men's Vintage Henley"
GROUP BY other_purchased_products
ORDER BY quantity DESC;
```

**Result:**

<p align="center">
  <img width="974" height="692" alt="Query 08 Result" src="https://github.com/user-attachments/assets/8fb0b56c-d92e-4196-b3f3-31cfb0d3d2c1" />
</p>

**Key insight:** Google Sunglasses was the most common co-purchased product, followed by apparel and accessories.

</details>

<details>
<summary><strong>09. Product View to Add-to-Cart and Purchase Funnel</strong></summary>

**Business question:** How did users move from product view to add to cart and purchase in Q1 2017?

**SQL query:**

```sql
WITH product_data AS (
    SELECT
        FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
        COUNT(CASE
            WHEN hits.eCommerceAction.action_type = '2'
            THEN product.productSKU
        END) AS num_product_view,
        COUNT(CASE
            WHEN hits.eCommerceAction.action_type = '3'
            THEN product.productSKU
        END) AS num_add_to_cart,
        COUNT(CASE
            WHEN hits.eCommerceAction.action_type = '6'
                AND product.productRevenue IS NOT NULL
            THEN product.productSKU
        END) AS num_purchase
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    CROSS JOIN UNNEST(hits) AS hits
    CROSS JOIN UNNEST(hits.product) AS product
    WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
        AND hits.eCommerceAction.action_type IN ('2', '3', '6')
    GROUP BY month
)
SELECT
    month,
    num_product_view,
    num_add_to_cart AS num_addtocart,
    num_purchase,
    ROUND(SAFE_DIVIDE(num_add_to_cart, num_product_view) * 100, 2) AS add_to_cart_rate,
    ROUND(SAFE_DIVIDE(num_purchase, num_product_view) * 100, 2) AS purchase_rate
FROM product_data
WHERE num_product_view > 0
ORDER BY month;
```

**Result:**

<p align="center">
  <img width="1468" height="194" alt="Query 09 Result" src="https://github.com/user-attachments/assets/90f04f00-5462-475a-a29d-fa543ae0292b" />
</p>

**Key insight:** The funnel improved from January to March, with add-to-cart rate and purchase rate both increasing over time.

</details>

<details>
<summary><strong>10. Weekly Revenue and Cumulative Revenue</strong></summary>

**Business question:** How did weekly revenue accumulate from May to July 2017?

**SQL query:**

```sql
WITH weekly_revenue_data AS (
    SELECT
        FORMAT_DATE('%Y-%W', PARSE_DATE('%Y%m%d', date)) AS week,
        SUM(product.productRevenue) / 1000000 AS weekly_revenue
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    CROSS JOIN UNNEST(hits) AS hits
    CROSS JOIN UNNEST(hits.product) AS product
    WHERE _TABLE_SUFFIX BETWEEN '20170501' AND '20170731'
        AND product.productRevenue IS NOT NULL
    GROUP BY week
)
SELECT
    week,
    ROUND(weekly_revenue, 2) AS weekly_revenue,
    ROUND(SUM(weekly_revenue) OVER (ORDER BY week), 2) AS cumulative_revenue
FROM weekly_revenue_data
ORDER BY week;
```

**Result:**

<p align="center">
  <img width="974" height="691" alt="Query 10 Result" src="https://github.com/user-attachments/assets/aed5ca48-9450-428c-b817-6a3841f4cd3f" />
</p>

**Key insight:** Weekly revenue accumulated to about 413.42K by week 2017-30, with the strongest visible week at 2017-29.

</details>

## Key Findings & Recommendations

| Key Finding | Recommendation |
| --- | --- |
| March 2017 had the highest visits, pageviews, and transactions in Q1. | Review March acquisition and merchandising activity to identify what drove stronger performance. |
| Google and direct traffic were the largest traffic sources, but some high-volume sources also had high bounce rates. | Improve landing page relevance and message match for high-bounce traffic sources such as YouTube, Google, and mobile Facebook. |
| Direct traffic generated the strongest visible revenue in June 2017. | Prioritize retention, brand, and direct-visit strategies because direct users show strong revenue contribution. |
| DFA had the highest qualified conversion rate, while direct traffic generated the largest transaction volume. | Allocate more attention to high-converting channels and compare campaign quality across sources. |
| Non-purchasers viewed more pages than purchasers on average. | Investigate product discovery, navigation, and checkout friction that may prevent browsing users from converting. |
| Desktop contributed 96.41% of total revenue in 2017. | Review the mobile shopping and checkout experience to increase mobile and tablet revenue contribution. |
| Google Sunglasses and related apparel were commonly purchased with `YouTube Men's Vintage Henley`. | Use product recommendation modules or bundles for common co-purchased products. |
| Add-to-cart and purchase rates improved from January to March. | Continue tracking funnel metrics monthly and use funnel movement as an early signal of ecommerce performance. |


## How to Run the Project

1. Open Google BigQuery.
2. Use the public dataset `bigquery-public-data.google_analytics_sample.ga_sessions_*`.
3. Open `Ecommerce Analysis.sql`.
4. Run each query independently.
5. Compare the query outputs with the result screenshots in this README.

## Tech Stack

- Google BigQuery
- SQL
- Window Functions
- CTEs
- Nested and Repeated Fields
- Ecommerce Analytics
- Web Performance Analysis
- Purchase Funnel Analysis

## Outcome

The final analysis provides a structured view of ecommerce traffic, engagement, conversion, revenue contribution, device performance, co-purchase behavior, and funnel movement. It supports channel optimization, product recommendation planning, mobile experience review, and ongoing revenue monitoring.
