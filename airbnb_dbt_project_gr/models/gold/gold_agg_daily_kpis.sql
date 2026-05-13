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

    ORDER BY d.full_date)
    
    SELECT * FROM CTE1
        