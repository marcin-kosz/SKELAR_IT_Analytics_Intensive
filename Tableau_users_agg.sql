CREATE OR REPLACE TABLE marketing_report.users_agg AS

SELECT

    registration_date AS date,
    channel,
    geo,

    COUNT(id_user) AS users,

    SUM(is_payer) AS payers,

    SUM(revenue_7d) AS revenue_7d,

    SUM(revenue_90d) AS revenue_90d

FROM marketing_report.users

GROUP BY
    registration_date,
    channel,
    geo
