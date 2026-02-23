CREATE OR REPLACE TABLE saas_curated.kpi_monthly AS
WITH mau AS (
  SELECT
    DATE_TRUNC(DATE(event_time), MONTH) AS month,
    COUNT(DISTINCT user_id) AS mau
  FROM saas_curated.events
  GROUP BY 1
),
new_users AS (
  SELECT
    DATE_TRUNC(DATE(signup_at), MONTH) AS month,
    COUNT(*) AS new_users
  FROM saas_curated.users
  GROUP BY 1
),
churn_users AS (
  SELECT
    DATE_TRUNC(DATE(end_at), MONTH) AS month,
    COUNT(DISTINCT user_id) AS churned_users
  FROM saas_curated.subscriptions
  WHERE churn_flag = TRUE
    AND end_at IS NOT NULL
  GROUP BY 1
)
SELECT
  m.month,
  COALESCE(m.mau, 0) AS mau,
  COALESCE(n.new_users, 0) AS new_users,
  COALESCE(c.churned_users, 0) AS churned_users,
  SAFE_DIVIDE(COALESCE(c.churned_users, 0), NULLIF(COALESCE(m.mau, 0), 0)) AS churn_rate_vs_mau
FROM mau m
LEFT JOIN new_users n USING (month)
LEFT JOIN churn_users c USING (month)
ORDER BY month;
