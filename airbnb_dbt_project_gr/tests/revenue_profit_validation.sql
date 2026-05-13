SELECT *
FROM {{ref('silver_bookings')}}
WHERE gross_booking_revenue < 0 OR profit > gross_booking_revenue