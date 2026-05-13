{{ config(
    materialized='incremental',
    unique_key='review_id'
) }}
{# KEEP NULLS IN RATING  #}

SELECT
    review_id,
    booking_id,
    property_id,
    review_date,
    guest_rating,
    ingestion_timestamp
FROM {{ref('raw_reviews')}} 
