{{ config(
    materialized='incremental',
    unique_key=['property_id', 'calendar_date']
) }}

SELECT
    property_id,
    calendar_date,
    day_of_week,
    month_name,
    year,
    available_flag,
    booked_flag,
    nightly_rate,
    daily_revenue,
    booking_id,
    CURRENT_TIMESTAMP AS ingestion_timestamp
FROM {{ source('staging', 'raw_property_daily') }}
