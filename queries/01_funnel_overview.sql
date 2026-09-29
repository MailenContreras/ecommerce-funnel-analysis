-- ============================================
-- 1. GENERAL FUNNEL - conversion rates
-- ============================================

WITH max_date AS (
  SELECT MAX(event_date) AS latest_date
  FROM `portfolio-analytics-508503.my_dataset.user_events`
),

funnel AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS carts,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS payments,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases

  FROM `portfolio-analytics-508503.my_dataset.user_events`, max_date

  WHERE event_date >= TIMESTAMP_SUB(
    max_date.latest_date,
    INTERVAL 30 DAY
  )
)

SELECT '1. Views' AS stage, views AS users FROM funnel
UNION ALL
SELECT '2. Cart', carts FROM funnel
UNION ALL
SELECT '3. Checkout', checkout FROM funnel
UNION ALL
SELECT '4. Payment', payments FROM funnel
UNION ALL
SELECT '5. Purchase', purchases FROM funnel;


------------------------------------------------------------------

WITH max_date AS (
  SELECT MAX(event_date) AS latest_date
  FROM `portfolio-analytics-508503.my_dataset.user_events`
),

funnel AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS carts,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS payments,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases

  FROM `portfolio-analytics-508503.my_dataset.user_events`, max_date

  WHERE event_date >= TIMESTAMP_SUB(
    max_date.latest_date,
    INTERVAL 30 DAY
  )
)

SELECT
  '1. View → Cart' AS conversion,
  ROUND(SAFE_DIVIDE(carts * 100, views), 2) AS rate
FROM funnel

UNION ALL

SELECT
  '2. Cart → Checkout',
  ROUND(SAFE_DIVIDE(checkout * 100, carts), 2)
FROM funnel

UNION ALL

SELECT
  '3. Checkout → Payment',
  ROUND(SAFE_DIVIDE(payments * 100, checkout), 2)
FROM funnel

UNION ALL

SELECT
  '4. Payment → Purchase',
  ROUND(SAFE_DIVIDE(purchases * 100, payments), 2)
FROM funnel

UNION ALL

SELECT
  '5. Overall conversion',
  ROUND(SAFE_DIVIDE(purchases * 100, views), 2)
FROM funnel;

