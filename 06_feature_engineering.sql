CREATE OR REPLACE TABLE saas_curated.features_churn_30d AS
WITH bounds AS (
  SELECT DATE('2023-01-01') AS min_date,
         DATE('2024-12-31') AS max_date
),
calendar AS (
  SELECT d AS as_of_date
  FROM bounds,
  UNNEST(GENERATE_DATE_ARRAY(
    DATE_ADD(min_date, INTERVAL 180 DAY),
    DATE_SUB(max_date, INTERVAL 30 DAY),
    INTERVAL 7 DAY
  )) d
),
base AS (
  SELECT
    u.user_id,
    c.as_of_date
  FROM saas_curated.users u
  JOIN calendar c
    ON DATE(u.signup_at) <= c.as_of_date
),
event_features AS (
  SELECT
    b.user_id,
    b.as_of_date,
    COUNTIF(DATE(e.event_time)
      BETWEEN DATE_SUB(b.as_of_date, INTERVAL 7 DAY)
      AND b.as_of_date) AS events_7d,
    COUNTIF(DATE(e.event_time)
      BETWEEN DATE_SUB(b.as_of_date, INTERVAL 30 DAY)
      AND b.as_of_date) AS events_30d,
    MIN(DATE_DIFF(b.as_of_date, DATE(e.event_time), DAY)) AS recency_days
  FROM base b
  LEFT JOIN saas_curated.events e
    ON e.user_id = b.user_id
   AND DATE(e.event_time) <= b.as_of_date
   AND DATE(e.event_time) >= DATE_SUB(b.as_of_date, INTERVAL 30 DAY)
  GROUP BY 1,2
),
label AS (
  SELECT
    b.user_id,
    b.as_of_date,
    MAX(
      IF(
        s.churn_flag = TRUE
        AND DATE(s.end_at) > b.as_of_date
        AND DATE(s.end_at) <= DATE_ADD(b.as_of_date, INTERVAL 30 DAY),
        1, 0
      )
    ) AS label_churn_30d
  FROM base b
  LEFT JOIN saas_curated.subscriptions s
    ON s.user_id = b.user_id
  GROUP BY 1,2
)
SELECT
  b.user_id,
  b.as_of_date,
  IFNULL(e.events_7d, 0) AS events_7d,
  IFNULL(e.events_30d, 0) AS events_30d,
  IFNULL(e.recency_days, 9999) AS recency_days,
  l.label_churn_30d
FROM base b
LEFT JOIN event_features e USING (user_id, as_of_date)
LEFT JOIN label l USING (user_id, as_of_date);
