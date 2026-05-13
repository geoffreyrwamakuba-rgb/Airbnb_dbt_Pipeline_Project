SELECT *
FROM {{ref('silver_bookings')}}
WHERE booking_id IS NULL OR
property_id IS NULL OR
checkin_date IS NULL OR
checkout_date IS NULL OR
gross_booking_revenue IS NULL