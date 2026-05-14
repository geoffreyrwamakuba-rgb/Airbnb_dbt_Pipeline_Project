# Airbnb DBT Project

## Executive Summary
UrbanStay Management is a short-term rental property management company operating a portfolio of properties across Airbnb, Booking.com, and Vrbo. As the business scaled, leadership struggled with fragmented operational data, inconsistent KPI reporting, and limited visibility into portfolio performance across platforms and properties.

Using Snowflake, dbt, AWS S3, and Tableau, I developed an end-to-end cloud analytics solution that transformed raw booking and operational data into business-ready KPI marts and interactive dashboards.

## Tableau Dashboard
![ ](https://github.com/geoffreyrwamakuba-rgb/Airbnb_DBT_Project/blob/c93242934902c7e9ec4ed293b6ae4ea1424d8478/Tableau%20-%20Dashboard.png)

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

- Which properties generate the highest RevPAR?
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
![ ](https://github.com/geoffreyrwamakuba-rgb/Airbnb_DBT_Project/blob/1c7272f71bfbc8cab6c61c19dc478be23c90df95/Data%20lineage.png)
---

### Key Insights and Recommendations

### Insight 1 – Revenue Dependence On Airbnb

Analysis revealed that Airbnb generated the majority of portfolio revenue compared to Booking.com and Vrbo, exposing the business to significant platform concentration risk.

Airbnb contributed approximately:
- £7.0M revenue, compared to:
- £2.6M from Booking.com
- £1.0M from Vrbo

**This highlighted an overreliance on a single acquisition channel**

### Recommendation:
I recommended that UrbanStay Management diversify booking acquisition strategies by:
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
I recommended implementing more sophisticated revenue management strategies including:
- Premium weekend pricing
- Test price elasticity by property type
- Minimum stay requirements
- Reduced reliance on discounting during high-demand periods.

Given the consistently high occupancy rates, the data suggested there was likely room to increase ADR without materially impacting booking volumes

### dbt DAG

![ ](https://github.com/geoffreyrwamakuba-rgb/Airbnb_DBT_Project/blob/b5e9174d8fd73997d4edde7ee9be3172c396704e/DBT%20DAG.png)
---
