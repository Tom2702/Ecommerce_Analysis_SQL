-- Query 01: Calculate total visit, pageview, transaction for Jan, Feb and March 2017
SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
    SUM(totals.visits) AS visits,
    SUM(totals.pageviews) AS pageviews,
    SUM(totals.transactions) AS transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
GROUP BY month
ORDER BY month;


-- Query 02: Bounce rate per traffic source in July 2017
SELECT
    trafficSource.source AS source,
    COUNT(totals.visits) AS total_visits,
    COUNT(totals.bounces) AS total_no_of_bounces,
    ROUND(SAFE_DIVIDE(COUNT(totals.bounces), COUNT(totals.visits)) * 100, 3) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
GROUP BY source
ORDER BY total_visits DESC;


-- Query 03: Revenue by traffic source by week, by month in June 2017
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


-- Query 04: Conversion rate by traffic source in 2017
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


-- Query 05: Average number of pageviews by purchaser type in June, July 2017
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


-- Query 06: Average number of transactions per user that made a purchase in July 2017
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


-- Query 07: Revenue contribution by device in 2017
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


-- Query 08: Other products purchased by customers who purchased YouTube Men's Vintage Henley in July 2017
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


-- Query 09: Calculate cohort map from product view to add to cart to purchase in Jan, Feb and March 2017
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


-- Query 10: Calculate revenue by week from May to July 2017 and cumulative revenue
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
