CREATE OR REPLACE TABLE saas_curated.users AS
SELECT
  account_id AS user_id,
  TIMESTAMP(signup_date) AS signup_at,
  country,
  industry,
  plan_tier,
  seats,
  is_trial,
  churn_flag
FROM saas_raw.users_raw;
