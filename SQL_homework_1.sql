WITH ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY ad_id, date
      ORDER BY timestamp DESC
    ) AS rn
  FROM `sql-homework-496611.workshop_sql.tabela-zadanie1`
),

dedup AS (
  SELECT *
  FROM ranked
  WHERE rn = 1
),

daily AS (
  SELECT
    source,
    date,
    spend,
    impressions,
    clicks,
    installs,
    registrations
  FROM dedup
),

monthly AS (
  SELECT
    source,
    DATE_TRUNC(date, MONTH) AS month,
    SUM(spend) AS spend,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(installs) AS installs,
    SUM(registrations) AS registrations
  FROM daily
  GROUP BY source, month
),

channel_kpi AS (
  SELECT
    source,

    SUM(spend) AS total_spend,

    SUM(spend) / NULLIF(SUM(impressions),0) * 1000 AS cpm,

    SUM(clicks) / NULLIF(SUM(impressions),0) AS ctr,

    SUM(installs) / NULLIF(SUM(clicks),0) AS click_to_install,

    SUM(registrations) / NULLIF(SUM(installs),0) AS install_to_reg,

    SUM(spend) / NULLIF(SUM(registrations),0) AS cac
  FROM daily
  GROUP BY source
),

ltv AS (
  SELECT 'tiktok' AS source, 8.50 AS ltv
  UNION ALL
  SELECT 'meta', 6.20
  UNION ALL
  SELECT 'google', 12.40
),

final AS (
  SELECT
    c.source,
    c.total_spend,
    c.cpm,
    c.ctr,
    c.click_to_install,
    c.install_to_reg,
    c.cac,
    l.ltv,
    l.ltv / c.cac AS ltv_cac
  FROM channel_kpi c
  LEFT JOIN ltv l USING(source)
)

-- RESULT 1: KPI per channel
SELECT *
FROM final
ORDER BY ltv_cac DESC;