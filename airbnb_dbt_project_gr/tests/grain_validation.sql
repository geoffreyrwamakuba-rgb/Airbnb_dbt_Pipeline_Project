SELECT
    property_id,
    calendar_date,
    COUNT(*)
FROM {{ref('silver_property_daily')}}
GROUP BY 1,2
HAVING COUNT(*) > 1