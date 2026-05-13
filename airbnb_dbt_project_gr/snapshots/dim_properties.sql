{% snapshot snapshot_dim_properties %}

{{
    config(
      target_schema='snapshots',
      unique_key='property_id',
      strategy='check',
      check_cols=[
        'city',
        'property_type',
        'bedrooms',
        'max_guests',
        'base_nightly_rate'
      ]
    )
}}

SELECT *
FROM {{ ref('dim_properties') }}

{% endsnapshot %}