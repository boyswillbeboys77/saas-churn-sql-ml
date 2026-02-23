CREATE OR REPLACE TABLE saas_curated.events AS
SELECT
  s.account_id AS user_id,
  TIMESTAMP(u.usage_date) AS event_time,
  u.feature_name AS event_name,
  u.usage_count,
  u.usage_duration_secs,
  u.error_count,
  u.is_beta_feature
FROM saas_raw.usage_raw u
JOIN saas_raw.subscriptions_raw s
  ON u.subscription_id = s.subscription_id;
