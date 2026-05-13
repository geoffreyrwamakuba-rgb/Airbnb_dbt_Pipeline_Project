with source as (
        select * from {{ source('staging', 'raw_bookings') }}
  ),
  renamed as (
      select
          {{ adapter.quote("BOOKING_ID") }},
        {{ adapter.quote("PROPERTY_ID") }},
        {{ adapter.quote("PLATFORM") }},
        {{ adapter.quote("GUEST_NAME") }},
        {{ adapter.quote("BOOKING_DATE") }},
        {{ adapter.quote("CHECKIN_DATE") }},
        {{ adapter.quote("CHECKOUT_DATE") }},
        {{ adapter.quote("STAY_NIGHTS") }},
        {{ adapter.quote("GROSS_BOOKING_REVENUE") }},
        {{ adapter.quote("CLEANING_FEE") }},
        {{ adapter.quote("PLATFORM_FEE") }},
        {{ adapter.quote("MANAGEMENT_FEE") }},
        {{ adapter.quote("MAINTENANCE_COST") }},
        {{ adapter.quote("TOTAL_COST") }},
        {{ adapter.quote("PROFIT") }},
        {{ adapter.quote("AVG_NIGHTLY_RATE") }},
        {{ adapter.quote("REVIEW_RATING") }},
        {{ adapter.quote("OCCUPANCY_STATUS") }}

      from source
  )
  select * from renamed
    