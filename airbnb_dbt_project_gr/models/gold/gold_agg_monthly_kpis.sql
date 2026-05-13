{{ config(
    materialized='table'
) }}

WITH daily_bookings AS (

    SELECT
        d.full_date AS calendar_date,
        COUNT(DISTINCT b.booking_id) AS bookings,
        SUM(b.gross_booking_revenue) AS gross_revenue,
        SUM(b.profit) AS total_profit,
        AVG(b.review_rating) AS avg_guest_rating
    FROM {{ ref('silver_bookings') }} b

    LEFT JOIN {{ ref('silver_dim_date') }} d
        ON b.checkin_date = d.full_date

    GROUP BY d.full_date

),

daily_occupancy AS (

    SELECT
        calendar_date,
        SUM(booked_flag) AS occupied_nights,
        SUM(available_flag) AS available_nights,
        ROUND(
            SUM(booked_flag)::FLOAT
            /
            NULLIF(SUM(available_flag), 0),
            4
        ) AS occupancy_rate

    FROM {{ ref('silver_property_daily') }}
    GROUP BY calendar_date

),

CTE1 AS (SELECT
        d.full_date AS calendar_date,
        d.year,
        d.month,
        d.month_name,
        COALESCE(b.bookings, 0) AS bookings,
        COALESCE(o.occupied_nights, 0) AS occupied_nights,
        COALESCE(o.available_nights, 0) AS available_nights,
        COALESCE(o.occupancy_rate, 0) AS occupancy_rate,
        COALESCE(b.gross_revenue, 0) AS gross_revenue,
        COALESCE(b.total_profit, 0) AS total_profit,
        NULLIF(ROUND(
            COALESCE(b.avg_guest_rating, 0),
            2
        ),0) AS avg_guest_rating,

        ROUND(
            COALESCE(b.gross_revenue, 0)
            /
            NULLIF(o.available_nights, 0),
            2
        ) AS revpar,

        ROUND(
            COALESCE(b.gross_revenue, 0)
            /
            NULLIF(o.occupied_nights, 0),
            2
        ) AS adr

    FROM {{ ref('silver_dim_date') }} d

    LEFT JOIN daily_bookings b
        ON d.full_date = b.calendar_date

    LEFT JOIN daily_occupancy o
        ON d.full_date = o.calendar_date

    ORDER BY d.full_date),
CTE2 AS (
SELECT 
        year,
        month, 
        month_name,
        SUM(bookings) AS bookings,
        SUM(occupied_nights) AS occupied_nights,
        SUM(available_nights) AS available_nights,
        ROUND(
            SUM(occupied_nights)::FLOAT
            /
            NULLIF(SUM(available_nights),0),
            4
        ) AS occupancy_rate,
        SUM(gross_revenue) AS gross_revenue,
        SUM(total_profit) AS total_profit,
        ROUND(AVG(avg_guest_rating),2) AS avg_guest_rating,
        ROUND(
            SUM(gross_revenue)
            /
            NULLIF(SUM(available_nights),0),
            2
        ) AS revpar,
        ROUND(
            SUM(gross_revenue)
            /
            NULLIF(SUM(occupied_nights),0),
            2
        ) AS adr
    FROM CTE1
    GROUP BY year, month, month_name)

SELECT *, 
ROUND(occupancy_rate - Lead(occupancy_rate,1) OVER(ORDER BY year desc, month desc),3) AS occupancy_rate_CHANGE_VS_LAST_MONTH,
ROUND((gross_revenue/NULLIF(Lead(gross_revenue,1) OVER(ORDER BY year desc, month desc),0))-1,2) AS gross_revenue_CHANGE_VS_LAST_MONTH,
ROUND((total_profit/NULLIF(Lead(total_profit,1) OVER(ORDER BY year desc, month desc),0))-1,2) AS total_profit_CHANGE_VS_LAST_MONTH,
ROUND((revpar/NULLIF(Lead(revpar,1) OVER(ORDER BY year desc, month desc),0))-1,2) AS revpar_CHANGE_VS_LAST_MONTH,
ROUND((adr/NULLIF(Lead(adr,1) OVER(ORDER BY year desc, month desc),0))-1,2) AS adr_CHANGE_VS_LAST_MONTH,
(avg_guest_rating - Lead(avg_guest_rating,1) OVER(ORDER BY year desc, month desc)) AS avg_guest_rating_CHANGE_VS_LAST_MONTH
FROM CTE2 
ORDER BY year DESC, month DESC
        