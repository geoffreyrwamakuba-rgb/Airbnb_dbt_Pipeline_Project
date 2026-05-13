USE DATABASE AIRBNB_GR;

CREATE FILE FORMAT IF NOT EXISTS csv_format
  TYPE = 'CSV' 
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

SHOW FILE FORMATS;

-- Stage is a link to S3 Bucket with all the csv files
-- Create new user in AWS IAM "snowuser"
-- Create access key for snowuser with secrets key
CREATE OR REPLACE STAGE snowstage
FILE_FORMAT = csv_format
URL = 's3://airbnb-project-gr/source_data/'
CREDENTIALS=(aws_key_id = 'AKIATJB7YRWNTTOAT6W6', aws_secret_key ='z0fAbLKB582Dfzl0/XMSjJAhix+ad6VzCVjklTTI');

SHOW STAGES; 

COPY INTO staging.raw_bookings
FRoM @snowstage
FILES=('raw_bookings.csv');

COPY INTO staging.raw_property_daily
FRoM @snowstage
FILES=('raw_property_daily.csv');

COPY INTO staging.raw_reviews
FRoM @snowstage
FILES=('raw_reviews.csv');

COPY INTO staging.dim_properties
FRoM @snowstage
FILES=('dim_properties.csv');
