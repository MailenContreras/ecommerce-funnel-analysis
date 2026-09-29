-- ============================================
-- 3. USER JOURNEY - user journey time
-- ============================================

WITH max_date AS (
  SELECT MAX(event_date) AS latest_date
  FROM `portfolio-analytics-508503.my_dataset.user_events`
),

user_journey AS (
  SELECT
    user_id,

    MIN(CASE
      WHEN event_type = 'page_view' THEN event_date
    END) AS view_time,

    MIN(CASE
      WHEN event_type = 'add_to_cart' THEN event_date
    END) AS cart_time,

    MIN(CASE
      WHEN event_type = 'purchase' THEN event_date
    END) AS purchase_time
  FROM `portfolio-analytics-508503.my_dataset.user_events`, max_date

  WHERE event_date >= TIMESTAMP_SUB(
    max_date.latest_date,
    INTERVAL 30 DAY
  )

  GROUP BY user_id

  HAVING MIN(CASE
    WHEN event_type = 'purchase' THEN event_date
  END) IS NOT NULL
),

journey_metrics AS (
  SELECT
    COUNT(*) AS converted_users,

    ROUND(
      AVG(TIMESTAMP_DIFF(cart_time, view_time, MINUTE)),
      2
    ) AS avg_view_to_cart_minutes,

    ROUND(
      AVG(TIMESTAMP_DIFF(purchase_time, cart_time, MINUTE)),
      2
    ) AS avg_cart_to_purchase_minutes,

    ROUND(
      AVG(TIMESTAMP_DIFF(purchase_time, view_time, MINUTE)),
      2
    ) AS avg_total_journey_minutes
  FROM user_journey
)

SELECT
  'View → Cart' AS stage,
  avg_view_to_cart_minutes AS minutes
FROM journey_metrics

UNION ALL

SELECT
  'Cart → Purchase' AS stage,
  avg_cart_to_purchase_minutes AS minutes
FROM journey_metrics

UNION ALL

SELECT
  'Total journey' AS stage,
  avg_total_journey_minutes AS minutes
FROM journey_metrics;
