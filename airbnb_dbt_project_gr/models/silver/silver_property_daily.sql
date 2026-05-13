{# select property_id,calendar_date, count(*) from {{ref('raw_property_daily')}} 
group by 1,2 HAVING COUNT(*)>1 #}

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
    TRY_TO_DECIMAL(daily_revenue, 10, 2) AS daily_revenue,
    booking_id,
    ingestion_timestamp
FROM {{ref('raw_property_daily')}}

