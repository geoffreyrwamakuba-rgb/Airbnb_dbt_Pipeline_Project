{{ config(
    materialized='incremental',
    unique_key='review_id'
) }}

SELECT
    review_id,
    booking_id,
    property_id,
    review_date,
    guest_rating,
    CURRENT_TIMESTAMP AS ingestion_timestamp
FROM {{ source('staging', 'raw_reviews') }}
