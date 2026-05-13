SELECT booking_id, COUNT(*)
FROM {{ref('silver_bookings')}}
GROUP BY booking_id
HAVING COUNT(*) > 1