SELECT
  COUNT(*) AS total_users,
  MIN(date_reg) AS first_reg,
  MAX(date_reg) AS last_reg,
  COUNTIF(date_first_payment IS NOT NULL) AS users_who_paid
FROM `abtest-496809.ABtest.ab_test_task_data`;

SELECT
  match,
  COUNT(*) AS users,
  COUNTIF(date_first_payment IS NOT NULL) AS paid
FROM `abtest-496809.ABtest.ab_test_task_data`
GROUP BY match;

SELECT
  COUNT(*) AS total_users,
  MIN(date_reg) AS first_reg,
  MAX(date_reg) AS last_reg,
  COUNTIF(date_first_payment IS NOT NULL) AS users_who_paid
FROM `abtest-496809.ABtest.ab_test_task_historical_data`;

SELECT
  COUNT(*) AS total_users,
  COUNTIF(date_first_payment IS NOT NULL) AS paid_users,
  COUNTIF(date_first_payment IS NOT NULL) / COUNT(*) AS conversion_rate
FROM `abtest-496809.ABtest.ab_test_task_historical_data`;

SELECT
  DATE(date_reg) AS day,
  COUNT(*) AS new_users
FROM `abtest-496809.ABtest.ab_test_task_historical_data`
GROUP BY day
ORDER BY day;

SELECT
  match,
  COUNT(*) AS total_users,
  COUNTIF(date_first_payment IS NOT NULL) AS paid_users,
  ROUND(COUNTIF(date_first_payment IS NOT NULL) / COUNT(*), 4) AS conversion_rate
FROM `abtest-496809.ABtest.ab_test_task_data`
GROUP BY match
ORDER BY match;

WITH stats AS (
  SELECT
    match,
    COUNT(*) AS n,
    COUNTIF(date_first_payment IS NOT NULL) AS x,
    COUNTIF(date_first_payment IS NOT NULL) / COUNT(*) AS p
  FROM `abtest-496809.ABtest.ab_test_task_data`
  GROUP BY match
),
aggregated AS (
  SELECT
    MAX(IF(match=0, p, NULL)) AS p_control,
    MAX(IF(match=1, p, NULL)) AS p_test,
    MAX(IF(match=0, n, NULL)) AS n_control,
    MAX(IF(match=1, n, NULL)) AS n_test
  FROM stats
)
SELECT
  p_control,
  p_test,
  p_test - p_control AS absolute_lift,
  ROUND((p_test - p_control) / p_control * 100, 2) AS relative_lift_pct,
  (p_test - p_control) /
    SQRT(
      (p_control*(1-p_control)/n_control) +
      (p_test*(1-p_test)/n_test)
    ) AS z_score
FROM aggregated;

SELECT
  match,
  ROUND(AVG(TIMESTAMP_DIFF(TIMESTAMP(date_first_payment), TIMESTAMP(date_reg), HOUR)), 1) AS avg_hours_to_payment,
  ROUND(AVG(TIMESTAMP_DIFF(TIMESTAMP(date_first_payment), TIMESTAMP(date_reg), MINUTE)) / 60 / 24, 1) AS avg_days_to_payment
FROM `abtest-496809.ABtest.ab_test_task_data`
WHERE date_first_payment IS NOT NULL
GROUP BY match
ORDER BY match;

SELECT
  DATE(date_reg) AS reg_day,
  match,
  COUNT(*) AS users,
  COUNTIF(date_first_payment IS NOT NULL) AS paid,
  ROUND(COUNTIF(date_first_payment IS NOT NULL) / COUNT(*), 4) AS cvr
FROM `abtest-496809.ABtest.ab_test_task_data`
GROUP BY reg_day, match
ORDER BY reg_day, match;
