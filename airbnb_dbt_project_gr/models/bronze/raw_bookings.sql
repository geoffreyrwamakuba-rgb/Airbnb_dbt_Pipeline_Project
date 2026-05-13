{# NOTE: The preview button always runs the raw SQL without the incremental logic — it ignores is_incremental()
Will always show results #}
{{ config(
    materialized='incremental',
    unique_key='booking_id'
) }}

WITH deduplicated AS (
    SELECT
    booking_id, 
    property_id, 
    platform, 
    guest_name,
    booking_date,
    checkin_date,	
    checkout_date,
    stay_nights,
    gross_booking_revenue,	
    cleaning_fee,	
    platform_fee,	
    management_fee,	
    maintenance_cost,	
    total_cost,
    profit,
    avg_nightly_rate,	
    review_rating,	
    occupancy_status,
    CURRENT_TIMESTAMP AS ingestion_timestamp
    FROM {{ source('staging', 'raw_bookings') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY booking_id ORDER BY ingestion_timestamp DESC) = 1
)

SELECT * FROM deduplicated

{% if is_incremental() %}
    WHERE ingestion_timestamp > (SELECT MAX(ingestion_timestamp) FROM {{ this }})
{% endif %}


{# NOTE:
materialized='incremental'
→ only processes new/updated rows after first run
unique_key='booking_id'
→ Snowflake/dbt performs merge/upsert logic
CURRENT_TIMESTAMP AS ingestion_timestamp
→ records when the row entered bronze #}

