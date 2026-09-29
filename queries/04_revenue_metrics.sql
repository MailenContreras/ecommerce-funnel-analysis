-- ============================================
-- 4. REVENUE - revenue metrics
-- ============================================

WITH max_date AS (
  SELECT MAX(event_date) AS latest_date
  FROM `portfolio-analytics-508503.my_dataset.user_events`
),

revenue_funnel AS (
  SELECT
    COUNT(DISTINCT CASE
      WHEN event_type = 'page_view' THEN user_id
    END) AS total_visitors,

    COUNT(DISTINCT CASE
      WHEN event_type = 'purchase' THEN user_id
    END) AS total_buyers,

    SUM(CASE
      WHEN event_type = 'purchase' THEN amount
    END) AS total_revenue,

    COUNT(CASE
      WHEN event_type = 'purchase' THEN 1
    END) AS total_orders

  FROM `portfolio-analytics-508503.my_dataset.user_events`, max_date

  WHERE event_date >= TIMESTAMP_SUB(
    max_date.latest_date,
    INTERVAL 30 DAY
  )
)


SELECT
  'Visitors' AS metric,
  total_visitors AS value
FROM revenue_funnel

UNION ALL

SELECT
  'Buyers',
  total_buyers
FROM revenue_funnel

UNION ALL

SELECT
  'Orders',
  total_orders
FROM revenue_funnel

UNION ALL

SELECT
  'Revenue',
  total_revenue
FROM revenue_funnel

UNION ALL

SELECT
  'Average order value',
  total_revenue / total_orders
FROM revenue_funnel

UNION ALL

SELECT
  'Revenue per buyer',
  total_revenue / total_buyers
FROM revenue_funnel

UNION ALL

SELECT
  'Revenue per visitor',
  total_revenue / total_visitors
FROM revenue_funnel;
