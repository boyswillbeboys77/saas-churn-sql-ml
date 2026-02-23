CREATE OR REPLACE TABLE saas_curated.retention_cohort AS
WITH users AS (
  SELECT
    user_id,
    DATE_TRUNC(DATE(signup_at), MONTH) AS cohort_month
  FROM saas_curated.users
),
activity AS (
  SELECT
    user_id,
    DATE_TRUNC(DATE(event_time), MONTH) AS active_month
  FROM saas_curated.events
  GROUP BY 1,2
),
joined AS (
  SELECT
    u.user_id,
    u.cohort_month,
    a.active_month,
    DATE_DIFF(a.active_month, u.cohort_month, MONTH) AS month_n
  FROM users u
  JOIN activity a
    ON u.user_id = a.user_id
  WHERE a.active_month >= u.cohort_month
),
cohort_sizes AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT user_id) AS cohort_size
  FROM users
  GROUP BY 1
)
SELECT
  j.cohort_month,
  j.month_n,
  COUNT(DISTINCT j.user_id) AS active_users,
  c.cohort_size,
  SAFE_DIVIDE(COUNT(DISTINCT j.user_id), c.cohort_size) AS retention_rate
FROM joined j
JOIN cohort_sizes c
  ON j.cohort_month = c.cohort_month
GROUP BY 1,2,4
ORDER BY cohort_month, month_n;
