CREATE OR REPLACE TABLE `tableau-496709.Tableau.final_marketing_dataset` AS

WITH users_aggregated AS (
  SELECT
    registration_date AS date,
    channel,
    geo,
    device_os,
    COUNT(id_user)                                    AS users,
    SUM(is_payer)                                     AS payers,
    SUM(revenue_7d)                                   AS revenue_7d,
    SUM(revenue_90d)                                  AS revenue_90d
  FROM `tableau-496709.Tableau.Tableau2`
  GROUP BY registration_date, channel, geo, device_os
),

joined AS (
  SELECT
    s.date,
    s.channel,
    s.geo,
    u.device_os,
    s.spend,
    u.users,
    u.payers,
    u.revenue_7d,
    u.revenue_90d,
    SAFE_DIVIDE(u.revenue_7d, s.spend)               AS roas,
    SAFE_DIVIDE(u.revenue_90d, s.spend)              AS roas_90d,
    SAFE_DIVIDE(u.payers, u.users)                   AS conversion_rate,
    SAFE_DIVIDE(s.spend, NULLIF(u.users, 0))         AS cost_per_user,
    SAFE_DIVIDE(s.spend, NULLIF(u.payers, 0))        AS cpa
  FROM `tableau-496709.Tableau.Tableau` s
  LEFT JOIN users_aggregated u
    ON s.date = u.date
    AND s.channel = u.channel
    AND s.geo = u.geo
)

SELECT * FROM joined;
