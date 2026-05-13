{# SELECT count(*) FROM {{ref('raw_bookings')}} #}

{{ config(
    materialized='incremental',
    unique_key='booking_id'
) }}

{# Handle duplicates #}
{# NULLS in platform fee replaced with average #}
{# Standard PLATFORM NAMES #}

WITH silver AS (
    SELECT *, 
        ROW_NUMBER() OVER (PARTITION BY booking_id ORDER BY ingestion_timestamp DESC) AS row_number
    FROM {{ ref('raw_bookings') }}
),

avg_platform_fee AS (
    SELECT ROUND(AVG(platform_fee), 2) AS avg_fee
    FROM {{ ref('raw_bookings') }}
    WHERE platform_fee IS NOT NULL
)

SELECT 
    booking_id,
    property_id, 
    CASE WHEN LOWER(platform)= 'booking.com' THEN 'Booking.com' ELSE INITCAP(platform) END AS platform, 
    guest_name,
    booking_date,
    checkin_date,	
    checkout_date,
    stay_nights,
    gross_booking_revenue,	
    cleaning_fee,	
    COALESCE(platform_fee, avg_fee) AS platform_fee,
    management_fee,	
    maintenance_cost,	
    total_cost,
    profit,
    avg_nightly_rate,	
    review_rating,	
    occupancy_status,
    ingestion_timestamp
FROM silver
CROSS JOIN avg_platform_fee
WHERE row_number = 1
