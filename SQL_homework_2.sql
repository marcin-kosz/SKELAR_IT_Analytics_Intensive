SELECT
  source,
  month,

  SUM(spend) AS spend,

  SUM(spend) / NULLIF(SUM(registrations),0) AS cac
FROM (
  SELECT
    source,
    DATE_TRUNC(date, MONTH) AS month,
    spend,
    registrations
  FROM `sql-homework-496611.workshop_sql.tabela-zadanie1`
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY ad_id, date
    ORDER BY timestamp DESC
  ) = 1
)
GROUP BY source, month
ORDER BY source, month;