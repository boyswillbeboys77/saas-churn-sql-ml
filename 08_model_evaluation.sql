SELECT *
FROM ML.EVALUATE(
  MODEL saas_curated.churn_lr_model,
  (
    SELECT
      events_7d,
      events_30d,
      recency_days,
      label_churn_30d
    FROM saas_curated.features_churn_30d
    WHERE as_of_date > DATE '2024-06-30'
  )
);
