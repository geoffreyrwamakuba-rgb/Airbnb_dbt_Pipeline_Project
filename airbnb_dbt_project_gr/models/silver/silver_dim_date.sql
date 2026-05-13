{# CREATE OR REPLACE TABLE dim_date AS #}

WITH date_bounds AS (

    SELECT
        MIN(calendar_date) AS min_date,
        MAX(calendar_date) AS max_date
    FROM {{ref('raw_property_daily')}}

),

date_spine AS (

    SELECT
        DATEADD(
            day,
            SEQ4(),
            (SELECT min_date FROM date_bounds)
        ) AS full_date

    FROM TABLE(
        GENERATOR(
            ROWCOUNT => 5000
        )
    )

    WHERE full_date <= (SELECT max_date FROM date_bounds)

)

SELECT

    TO_NUMBER(TO_CHAR(full_date, 'YYYYMMDD')) AS date_key,

    full_date,

    YEAR(full_date) AS year,

    QUARTER(full_date) AS quarter,

    MONTH(full_date) AS month,

    MONTHNAME(full_date) AS month_name,

    WEEK(full_date) AS week_number,

    DAY(full_date) AS day_of_month,

    DAYNAME(full_date) AS day_name,

    DAYOFWEEK(full_date) AS day_of_week_num,

    CASE
        WHEN DAYOFWEEK(full_date) IN (1, 7)
        THEN 1
        ELSE 0
    END AS is_weekend,

    CASE
        WHEN MONTH(full_date) IN (12, 1, 2)
        THEN 'Winter'

        WHEN MONTH(full_date) IN (3, 4, 5)
        THEN 'Spring'

        WHEN MONTH(full_date) IN (6, 7, 8)
        THEN 'Summer'

        ELSE 'Autumn'
    END AS season

FROM date_spine

ORDER BY full_date