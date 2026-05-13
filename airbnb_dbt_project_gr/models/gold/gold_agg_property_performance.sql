{{ config(
    materialized='table'
) }}

WITH PROP AS (

    SELECT
    b.PROPERTY_ID,
    d.PROPERTY_NAME,
    d.CITY,
    COUNT(DISTINCT b.BOOKING_ID) AS TOTAL_BOOKINGS,
    SUM(b.GROSS_BOOKING_REVENUE) AS TOTAL_REVENUE,
    SUM(b.PROFIT) AS TOTAL_PROFIT,
    ROUND(AVG(b.REVIEW_RATING),2) AS AVG_GUEST_RATING
    FROM {{ ref('silver_bookings') }} b
    LEFT JOIN {{ ref('silver_dim_properties') }} d
    ON b.PROPERTY_ID = d.PROPERTY_ID
    GROUP BY b.PROPERTY_ID, d.PROPERTY_NAME, d.CITY
),

occupancy AS (

    SELECT
        PROPERTY_ID,
        SUM(booked_flag) AS occupied_nights,
        SUM(available_flag) AS available_nights,
        ROUND(
            SUM(booked_flag)::FLOAT
            /
            NULLIF(SUM(available_flag), 0),
            4
        ) AS occupancy_rate

    FROM {{ ref('silver_property_daily') }}
    GROUP BY PROPERTY_ID)

    SELECT 
    p.PROPERTY_ID,
    p.PROPERTY_NAME,
    p.CITY,
    COALESCE(p.TOTAL_BOOKINGS,0) AS TOTAL_BOOKINGS,
    COALESCE(o.occupancy_rate,0) AS OCCUPANCY_RATE,
    COALESCE(p.TOTAL_REVENUE,0) AS TOTAL_REVENUE,
    COALESCE(p.TOTAL_PROFIT,0) AS TOTAL_PROFIT,
    ROUND(COALESCE(p.TOTAL_REVENUE,0)/NULLIF(o.available_nights,0),2) AS REVPAR,
    ROUND(COALESCE(p.TOTAL_REVENUE,0)/NULLIF(o.occupied_nights,0),2) AS ADR,
    p.AVG_GUEST_RATING AS AVG_RATING
    FROM PROP P
    LEFT JOIN occupancy o
    ON p.PROPERTY_ID = o.PROPERTY_ID