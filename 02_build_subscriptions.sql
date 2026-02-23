CREATE OR REPLACE TABLE saas_curated.subscriptions AS
SELECT
  subscription_id,
  account_id AS user_id,
  TIMESTAMP(start_date) AS start_at,
  TIMESTAMP(end_date) AS end_at,
  plan_tier,
  seats,
  mrr_amount,
  arr_amount,
  is_trial,
  upgrade_flag,
  downgrade_flag,
  churn_flag,
  billing_frequency,
  auto_renew_flag
FROM saas_raw.subscriptions_raw;
