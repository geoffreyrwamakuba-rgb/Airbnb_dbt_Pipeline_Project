SELECT DISTINCT platform
FROM {{ref('silver_bookings')}}
WHERE platform NOT IN ('Airbnb', 'Booking.com', 'Vrbo')
