{{ config(
    materialized='table'
) }}

WITH base AS (

    SELECT

        d.month_name,

        d.month,

        d.day_name,

        d.day_of_week_num,

        SUM(p.booked_flag) AS occupied_nights,

        COUNT(*) AS available_nights,

        ROUND(
            SUM(p.booked_flag)::FLOAT
            /
            NULLIF(COUNT(*), 0),
            4
        ) AS occupancy_rate

    FROM {{ ref('silver_property_daily') }} p

    LEFT JOIN {{ ref('silver_dim_date') }} d
        ON p.calendar_date = d.full_date

    GROUP BY
        d.month_name,
        d.month,
        d.day_name,
        d.day_of_week_num

)

SELECT *

FROM base

ORDER BY
    month,
    day_of_week_num