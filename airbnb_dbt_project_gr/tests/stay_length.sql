SELECT *
FROM {{ref('silver_bookings')}}
WHERE stay_nights != DATEDIFF(day, checkin_date, checkout_date)