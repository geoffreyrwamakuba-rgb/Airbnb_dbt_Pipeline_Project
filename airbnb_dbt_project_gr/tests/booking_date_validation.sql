SELECT *
FROM {{ref('silver_bookings')}}
WHERE checkout_date <= checkin_date