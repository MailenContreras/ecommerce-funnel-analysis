-- ============================================
-- 2. FUNNEL BY CHANNEL - performance by traffic_source
-- ============================================

WITH max_date AS (
  SELECT MAX(event_date) AS latest_date
  FROM `portfolio-analytics-508503.my_dataset.user_events`
),

funnel_by_source AS (
  SELECT
    traffic_source,

    COUNT(DISTINCT CASE
      WHEN event_type = 'page_view' THEN user_id
    END) AS views,

    COUNT(DISTINCT CASE
      WHEN event_type = 'add_to_cart' THEN user_id
    END) AS carts,

    COUNT(DISTINCT CASE
      WHEN event_type = 'purchase' THEN user_id
    END) AS purchases
  FROM `portfolio-analytics-508503.my_dataset.user_events`, max_date

  WHERE event_date >= TIMESTAMP_SUB(
    max_date.latest_date,
    INTERVAL 30 DAY
  )

  GROUP BY traffic_source
)

SELECT
  traffic_source,
  views,
  carts,
  purchases
FROM funnel_by_source;


--------------------------------


WITH max_date AS (
  SELECT MAX(event_date) AS latest_date
  FROM `portfolio-analytics-508503.my_dataset.user_events`
),

funnel_by_source AS (
  SELECT
    traffic_source,

    COUNT(DISTINCT CASE
      WHEN event_type = 'page_view' THEN user_id
    END) AS views,

    COUNT(DISTINCT CASE
      WHEN event_type = 'add_to_cart' THEN user_id
    END) AS carts,

    COUNT(DISTINCT CASE
      WHEN event_type = 'purchase' THEN user_id
    END) AS purchases
  FROM `portfolio-analytics-508503.my_dataset.user_events`, max_date

  WHERE event_date >= TIMESTAMP_SUB(
    max_date.latest_date,
    INTERVAL 30 DAY
  )

  GROUP BY traffic_source
)

SELECT
  traffic_source,
  'View → Cart' AS conversion_type,
  ROUND(SAFE_DIVIDE(carts * 100, views), 2) AS rate
FROM funnel_by_source

UNION ALL

SELECT
  traffic_source,
  'View → Purchase',
  ROUND(SAFE_DIVIDE(purchases * 100, views), 2)
FROM funnel_by_source

UNION ALL

SELECT
  traffic_source,
  'Cart → Purchase',
  ROUND(SAFE_DIVIDE(purchases * 100, carts), 2)
FROM funnel_by_source;
