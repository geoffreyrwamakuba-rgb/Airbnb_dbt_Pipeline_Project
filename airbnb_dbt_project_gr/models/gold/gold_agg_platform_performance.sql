{{ config(
    materialized='table'
) }}

WITH plat AS (

    SELECT
        d.year,
        d.month,

        b.platform,

        COUNT(DISTINCT b.booking_id) AS total_bookings,

        SUM(b.gross_booking_revenue) AS total_revenue,

        SUM(b.profit) AS total_profit

    FROM {{ ref('silver_bookings') }} b

    LEFT JOIN {{ ref('silver_dim_date') }} d
        ON b.checkin_date = d.full_date

    GROUP BY
        d.year,
        d.month,
        b.platform

),

occupancy AS (

    SELECT
        d.year,
        d.month,
        b.platform
    FROM {{ ref('silver_property_daily') }} p

    LEFT JOIN {{ ref('silver_bookings') }} b
        ON p.booking_id = b.booking_id

    LEFT JOIN {{ ref('silver_dim_date') }} d
        ON p.calendar_date = d.full_date

    GROUP BY
        d.year,
        d.month,
        b.platform

)

SELECT

    p.year,
    p.month,
    p.platform,
    COALESCE(p.total_bookings, 0) AS total_bookings,
    COALESCE(p.total_revenue, 0) AS total_revenue,
    ROUND(p.total_revenue/NULLIF(p.total_bookings, 0),2
    ) AS avg_stay_value,
    COALESCE(p.total_profit, 0) AS total_profit

FROM plat p

LEFT JOIN occupancy o
    ON p.year = o.year
    AND p.month = o.month
    AND p.platform = o.platform
 