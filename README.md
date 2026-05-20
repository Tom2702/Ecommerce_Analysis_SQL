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

| Query | Analysis |
| --- | --- |
| Query 01 | Calculate total visits, pageviews, and transactions by month for January to March 2017 |
| Query 02 | Calculate bounce rate by traffic source in July 2017 |
| Query 03 | Calculate revenue by traffic source by week and month in June 2017 |
| Query 04 | Calculate conversion rate by traffic source in 2017 |
| Query 05 | Compare average pageviews between purchasers and non-purchasers in June and July 2017 |
| Query 06 | Calculate average transactions per purchasing user in July 2017 |
| Query 07 | Calculate revenue contribution by device category in 2017 |
| Query 08 | Identify other products purchased by customers who bought `YouTube Men's Vintage Henley` in July 2017 |
| Query 09 | Build a product funnel cohort from product view to add to cart and purchase in Q1 2017 |
| Query 10 | Calculate weekly revenue and cumulative revenue from May to July 2017 |

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

## Key Takeaways

Based on the expected outputs in the project instruction sheet:

- March 2017 had the highest visits and transactions among the first three months of 2017.
- Google and direct traffic were among the largest traffic sources in July 2017.
- Direct traffic contributed strongly to June 2017 revenue.
- Desktop generated the majority of 2017 revenue compared with mobile and tablet.
- The product funnel from product view to add to cart and purchase improved from January to March 2017.
- Weekly cumulative revenue from May to July 2017 shows how revenue builds over time.

## Notes

- Queries that use product-level revenue must unnest both `hits` and `hits.product`.
- For purchase and revenue analysis, filter with `product.productRevenue IS NOT NULL`.
- `product.productRevenue` is stored in micros, so it is divided by `1000000`.
- `SAFE_DIVIDE` is used to avoid division-by-zero errors when calculating rates.

