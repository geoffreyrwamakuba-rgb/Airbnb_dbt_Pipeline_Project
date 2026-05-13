-- DDL For My Tables

CREATE OR REPLACE TABLE raw_bookings (
booking_id STRING, 
property_id STRING, 
platform STRING, 
guest_name STRING,
booking_date DATE,
checkin_date DATE,	
checkout_date DATE,
stay_nights INT,
gross_booking_revenue FLOAT,	
cleaning_fee FLOAT,	
platform_fee FLOAT,	
management_fee FLOAT,	
maintenance_cost FLOAT,	
total_cost FLOAT,
profit FLOAT,
avg_nightly_rate FLOAT,	
review_rating FLOAT,	
occupancy_status STRING,
PRIMARY KEY (booking_id)
);

CREATE OR REPLACE TABLE raw_property_daily (
property_id STRING,
calendar_date DATE,
day_of_week STRING,
month_name STRING,
year INT,
available_flag INT,
booked_flag INT,
nightly_rate FLOAT,
daily_revenue STRING,
booking_id STRING
);

CREATE OR REPLACE TABLE raw_reviews (
review_id STRING,
booking_id STRING,
property_id STRING,
review_date DATE,
guest_rating FLOAT,
review_text STRING,
PRIMARY KEY (review_id)
);

ALTER TABLE raw_reviews
DROP COLUMN review_text;

CREATE OR REPLACE TABLE dim_properties (
property_id STRING,
property_name STRING,
city STRING,
property_type STRING,
bedrooms INT,
max_guests INT,
owner_name STRING,
base_nightly_rate INT,
PRIMARY KEY (property_id));