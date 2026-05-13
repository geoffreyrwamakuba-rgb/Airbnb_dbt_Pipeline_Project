{{ config(
    materialized='incremental',
    unique_key='property_id'
) }}

SELECT
     property_id,
     property_name,
     city,
     property_type,
     bedrooms,
     max_guests,
     owner_name,
     base_nightly_rate,
     ingestion_timestamp
FROM {{ ref('snapshot_dim_properties') }}
