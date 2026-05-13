# Airbnb_DBT_Project

## Executive Summary
UrbanStay Management is a short-term rental property management company operating a portfolio of properties across Airbnb, Booking.com, and Vrbo. As the business scaled, leadership struggled with fragmented operational data, inconsistent KPI reporting, and limited visibility into portfolio performance across platforms and properties.

Using Snowflake, dbt, AWS S3, Airflow, Docker, and Tableau, I developed an end-to-end cloud analytics solution that transformed raw booking and operational data into business-ready KPI marts and interactive dashboards.

## Tableau Dashboard
![ ](https://github.com/geoffreyrwamakuba-rgb/AWS_Youtube_Project/blob/a6725ad6a5d673be6f134c0c5019ed91dbabb54f/Images/AWS_Data_Flow.png)

## Project Overview

UrbanStay Management relied heavily on operational exports from multiple booking platforms to monitor business performance. Reporting processes were manual, inconsistent, and lacked standardised hospitality KPIs needed to support pricing and operational decisions.

The objective of this engagement was to build a scalable analytics platform capable of:

- consolidating booking and operational data from multiple platforms
- automating transformation and reporting workflows
- standardising hospitality KPI calculations
- providing interactive executive dashboards for management.

### 🏢 Business Scenario

### Context

The business needed visibility into questions such as:

Which properties generate the highest RevPAR?
- Are occupancy gains being driven by excessive discounting?
- Which booking platforms drive the highest revenue?
- How does seasonality impact occupancy and pricing performance?
- Which properties are underperforming operationally?

### ❌ The Problem

Prior to implementation, UrbanStay Management faced several operational and reporting challenges:
- Booking data was fragmented across Airbnb, Booking.com, and Vrbo
- KPI calculations were inconsistent across teams
- Reporting processes relied heavily on spreadsheets and manual exports
- Leadership lacked visibility into pricing efficiency and occupancy trends
- No historical change tracking existed for operational dimensions
- Reporting latency made proactive pricing and operational decisions difficult.

The absence of a centralised analytics platform limited the company’s ability to:
- Optimise pricing strategies
- Identify underperforming properties
- Diversify booking platform dependence
- Improve operational decision-making.

### ✅ The Solution

- Ingestion of raw booking and operational datasets into AWS S3
- Snowflake staging and warehouse modelling
- Incremental dbt transformations for scalable processing
- SCD Type 2 snapshot implementation for historical tracking
- Tableau dashboards for executive reporting and operational analysis

### Data Flow Architecture

![ ](https://github.com/geoffreyrwamakuba-rgb/AWS_Youtube_Project/blob/4144f6a8b43428482cfd3e4ff1f74559755a1022/Images/stepfunctions_graph.svg)
---

### Key Insights and Recommendations

### Insight 1 – Revenue Dependence On Airbnb

Analysis revealed that Airbnb generated the majority of portfolio revenue compared to Booking.com and Vrbo, exposing the business to significant platform concentration risk.

Airbnb contributed approximately:
- £7.0M revenue, compared to:
- £2.6M from Booking.com
- £1.0M from Vrbo

This highlighted an overreliance on a single acquisition channeL

### Recommendation:
I recommended that UrbanStay Management diversify booking acquisition strategies by:
- Improving Booking.com listing optimisation
- Improving listing quality and SEO across alternative platforms
- Testing platform-specific promotional strategies.

Reducing platform dependency would improve long-term revenue resilience and reduce exposure to marketplace algorithm or policy changes.

### Insight 2 – Occupancy Increased While ADR and RevPAR Declined
Portfolio occupancy increased to 95% month-over-month, while:
- ADR declined by 9%
- RevPAR declined by 7%.

This suggested that occupancy growth was likely being maintained through pricing discounts rather than stronger pricing power.
**The increase in occupancy was insufficient to offset declining average nightly pricing.**

### Recommendation:


### 🚀 Key Features / Industry Best Practices

1. Idempotent Data Ingestion
- Uses stable ingestion IDs derived from event timestamps to prevent duplicate loads
- Checks for existing S3 objects before writing (idempotency guard)
- Ensures safe retries if jobs are triggered multiple times

👉 Prevents duplicate data when schedulers (e.g. EventBridge) fire twice

2. Resilient API Handling
- Implements retry logic with exponential backoff for transient failures
- Handles HTTP errors explicitly (e.g. quota exhaustion)
- Uses persistent HTTP sessions for connection reuse

👉 Ensures pipeline stability when dealing with external APIs

3. Pagination & Full Data Extraction
- Iteratively retrieves all available pages from the API
- Avoids partial datasets caused by single-call limits

👉 Guarantees completeness of ingested data

4. Data Quality as a First-Class Step - Dedicated validation layer before downstream processing

Includes:
- Row count thresholds
- Null checks on critical fields
- Schema validation
- Value range checks
- Data freshness checks

👉 Prevents bad data from propagating into analytics

5. Observability & Monitoring
- Structured JSON logging for queryable logs
- CloudWatch metrics (e.g. API quota usage)
- SNS alerts for failures

👉 Enables fast debugging and proactive monitoring

---
