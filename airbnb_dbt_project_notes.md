# Airbnb dbt Pipeline Project — Learning Notes

> **Project:** UrbanStay Management Analytics Pipeline  
> **Stack:** Python · uv · dbt Core · Snowflake · AWS S3 · Git  
> **Repo:** https://github.com/geoffreyrwamakuba-rgb/Airbnb_dbt_Pipeline_Project

---

## 1. What Was Built

An end-to-end cloud analytics pipeline that takes raw booking data from multiple platforms (Airbnb, Booking.com, Vrbo) and transforms it into business-ready KPI tables in Snowflake, following a **Medallion architecture** (Bronze → Silver → Gold).

### Data Flow

```
Raw CSVs → AWS S3 → Snowflake (Staging)
                         ↓
                   Bronze Layer  (raw source tables, no transformations)
                         ↓
                   Silver Layer  (cleansed, typed, renamed)
                         ↓
                   Gold Layer    (KPI marts: dim_ + fct_ tables)
```

### Key outputs built

- **Staging models** — light cleaning and aliasing of raw source tables
- **Dimension models** (`dim_listings`, `dim_hosts`, `dim_properties`) — descriptive attributes, SCD Type 2 for history
- **Fact models** (`fct_bookings`, `fct_reviews`) — metrics and measures
- **SCD Type 2 Snapshots** — historical tracking of slowly changing dimensions (e.g. a listing's price or status over time)
- **Incremental models** — efficient processing of new records only (e.g. new reviews)
- **Data quality tests** — both singular (custom SQL) and generic (built-in dbt tests)
- **Macros** — reusable SQL functions in Jinja

---

## 2. Project Setup — uv

### What is uv?

`uv` is a fast Python package manager (written in Rust) that replaces `pip` + `virtualenv` in a single tool. It manages virtual environments and project dependencies, and is significantly faster than traditional pip installs.

### How it was used here

The project is structured as a standard Python project using `pyproject.toml` as the single source of truth for dependencies:

```toml
[project]
name = "airbnb-dbt-project"
version = "0.1.0"
requires-python = ">=3.12"

dependencies = [
    "dbt-core>=1.11.9",
    "dbt-snowflake>=1.11.4",
]
```

A `uv.lock` file is committed to Git — this pins exact dependency versions so every developer gets an identical environment, just like `package-lock.json` in Node.js.

### Key uv commands

```bash
uv venv                     # Create a virtual environment
uv sync                     # Install all dependencies from pyproject.toml + lock file
uv add dbt-core             # Add a new dependency (updates pyproject.toml + lock file)
uv run dbt run              # Run a command inside the managed environment
```

### Best practice
Commit `uv.lock` to Git. This ensures reproducible environments across machines and CI pipelines. Never manually edit the lock file.

---

## 3. Git — Fundamentals Applied

### What was done

The project uses Git for version control across all code — dbt SQL models, YAML config files, Python scripts, and notes. The public GitHub repo acts as the single source of truth.

### Key Git concepts used

**Initialising a repo**
```bash
git init
git remote add origin <url>
```

**Standard workflow**
```bash
git status                  # See what has changed
git add .                   # Stage all changes
git commit -m "add stg_listings model"
git push origin main
```

**`.gitignore`**
The project has a `.gitignore` to exclude files that should never be committed:
- `target/` — compiled dbt SQL (auto-generated, can be re-built)
- `dbt_packages/` — installed dbt packages (like pip installs, not source code)
- `.env` / `profiles.yml` — contain credentials; **never commit these**

### Best practice
Keep credentials out of Git entirely. In dbt, the `profiles.yml` file stores Snowflake credentials and lives in `~/.dbt/` on your local machine, not inside the project repo. In production, credentials go into environment variables or a secrets manager.

---

## 4. dbt — Core Concepts

### What dbt does

dbt (data build tool) handles the **T** in ELT. It takes SQL `SELECT` statements and manages the DDL/DML (CREATE TABLE, INSERT, etc.) on your behalf. You write `SELECT`; dbt writes the warehouse code.

This means the same dbt model works unchanged on Snowflake, Databricks, BigQuery, or DuckDB — dbt handles dialect differences.

### Project structure

```
airbnb_dbt_project_gr/
├── dbt_project.yml          # Project-level config (materializations, schema names)
├── profiles.yml             # Credentials (stored outside repo at ~/.dbt/)
├── models/
│   ├── staging/             # Bronze/Silver: light cleaning
│   ├── marts/
│   │   ├── dim/             # Dimension tables
│   │   └── fct/             # Fact tables
│   └── snapshots/           # SCD Type 2 history
├── macros/                  # Reusable Jinja functions
├── tests/                   # Custom singular data tests
└── target/                  # Compiled + run SQL (auto-generated, gitignored)
```

---

## 5. dbt — Materializations

A **materialization** controls what dbt physically creates in the warehouse when a model runs.

| Materialization | What it creates | When to use |
|---|---|---|
| `view` | A stored query (no data stored) | Staging models, rarely queried |
| `table` | A full table, rebuilt each run | Dimensions, smaller marts |
| `incremental` | Appends/merges only new rows | Large fact tables (e.g. reviews) |
| `ephemeral` | A CTE, exists only in dbt's code | Intermediate steps; reduces WH clutter |

### How to set materializations

There are three levels, each overriding the one above:

**1. Project-level default — `dbt_project.yml` (recommended for team consistency)**
```yaml
models:
  airbnb_dbt_project_gr:
    staging:
      +materialized: view
    marts:
      dim:
        +materialized: table
      fct:
        +materialized: incremental
```

**2. Model-level YAML file**
```yaml
# models/marts/dim/_dim_models.yml
models:
  - name: dim_listings
    config:
      materialized: table
```

**3. Inline config block in the SQL file (highest precedence)**
```sql
{{ config(materialized = 'table') }}

SELECT ...
```

### Best practice
Manage materializations from `dbt_project.yml` wherever possible — it's easier to track and audit. Use inline `{{ config() }}` only for exceptions.

---

## 6. dbt — Sources and the `ref()` / `source()` Functions

### Sources

Sources are declared in YAML files and point to raw tables that dbt did **not** create. Declaring sources enables data lineage in the dbt DAG.

```yaml
# models/staging/sources.yml
sources:
  - name: airbnb_raw
    database: AIRBNB
    schema: RAW
    tables:
      - name: raw_listings
      - name: raw_reviews
      - name: raw_hosts
```

### Referencing in SQL

```sql
-- Referencing a source (raw table dbt didn't build)
SELECT * FROM {{ source('airbnb_raw', 'raw_listings') }}

-- Referencing another dbt model (dbt-built table)
SELECT * FROM {{ ref('stg_listings') }}
```

Using `{{ ref() }}` and `{{ source() }}` instead of hardcoded table names means:
- dbt builds models in the correct order automatically
- The DAG lineage graph is populated
- Schema/database prefixes are handled automatically per environment

---

## 7. dbt — Jinja Templating

dbt uses Jinja2 as a templating layer on top of SQL. This enables logic, variables, and reusability.

### Key Jinja constructs used

**Variables**
```sql
{% set payment_methods = ['credit_card', 'bank_transfer', 'voucher'] %}
```

**If/Else conditions**
```sql
{% if is_incremental() %}
  WHERE created_at > (SELECT MAX(created_at) FROM {{ this }})
{% endif %}
```

**For loops** (useful for avoiding repetitive SQL)
```sql
{% for method in payment_methods %}
  SUM(CASE WHEN payment_method = '{{ method }}' THEN amount END) AS {{ method }}_amount
  {% if not loop.last %},{% endif %}
{% endfor %}
```

### VSCode tip
Add these to your `settings.json` so syntax highlighting works in dbt files:
```json
"files.associations": {
    "*.sql": "jinja-sql",
    "*.yml": "jinja-yaml"
}
```

---

## 8. dbt — Incremental Models

Incremental models process only new or changed rows instead of rebuilding the entire table. This is critical for large fact tables like reviews or bookings.

```sql
{{ config(materialized = 'incremental') }}

SELECT
    booking_id,
    listing_id,
    created_at,
    revenue
FROM {{ source('airbnb_raw', 'raw_bookings') }}

{% if is_incremental() %}
    -- Only load rows newer than what's already in the table
    WHERE created_at > (
        SELECT COALESCE(MAX(created_at), '1900-01-01')
        FROM {{ this }}
    )
{% endif %}
```

On first run: builds the full table. On subsequent runs: only processes new records.

`{{ this }}` refers to the current model's table in the warehouse.

---

## 9. dbt — Snapshots (SCD Type 2)

Slowly Changing Dimensions (SCD Type 2) track how a record changes over time, keeping a full history. For example: if a listing's price changes, you want to know what the price was on each historical booking date.

dbt handles the complex insert/update logic automatically through **Snapshots**.

```sql
-- snapshots/scd_listings.sql
{% snapshot scd_listings %}
{{
    config(
        target_schema = 'snapshots',
        unique_key = 'listing_id',
        strategy = 'timestamp',
        updated_at = 'updated_at'
    )
}}

SELECT * FROM {{ ref('stg_listings_ephemeral') }}

{% endsnapshot %}
```

When you run `dbt snapshot`, dbt:
- Detects changed rows using the `updated_at` timestamp
- Closes the old record (sets `dbt_valid_to`)
- Inserts the new version (with `dbt_valid_from` = now, `dbt_valid_to` = null)

### Key distinction
```bash
dbt run       # Runs models (views, tables, incremental)
dbt snapshot  # Runs snapshots separately — on its own schedule
dbt build     # Runs models + seeds + tests together
```

Snapshots run separately because they typically run on a different (slower) schedule than your regular model runs.

---

## 10. dbt — Ephemeral Models

An ephemeral model is a virtual CTE that lives only in dbt's codebase. It is **not** created as a table or view in the warehouse — dbt inlines it as a subquery wherever it's referenced.

```sql
-- models/staging/stg_listings_ephemeral.sql
{{ config(materialized = 'ephemeral') }}

SELECT
    listing_id,
    TRIM(listing_name) AS listing_name,
    price::FLOAT AS price,
    updated_at
FROM {{ source('airbnb_raw', 'raw_listings') }}
```

Use ephemeral models to reduce warehouse clutter for intermediate steps that don't need to be queried directly. Note: you cannot run `SELECT * FROM stg_listings_ephemeral` directly in the warehouse because no object is created.

---

## 11. dbt — Macros

Macros are reusable Jinja functions stored in the `macros/` folder. They work like Python functions — define once, call anywhere.

```sql
-- macros/cents_to_pounds.sql
{% macro cents_to_pounds(column_name, scale=2) %}
    ({{ column_name }} / 100)::NUMERIC(16, {{ scale }})
{% endmacro %}
```

Usage in a model:
```sql
SELECT
    booking_id,
    {{ cents_to_pounds('revenue_cents') }} AS revenue_gbp
FROM {{ ref('stg_bookings') }}
```

Macros are particularly powerful for metadata-driven pipelines — write generic logic once and apply it across dozens of tables without repeating code.

---

## 12. dbt — Data Quality Tests

dbt has a built-in testing framework. There are two types:

### Generic Tests
Configured in YAML, applied to specific columns. Built-in options: `unique`, `not_null`, `accepted_values`, `relationships`.

```yaml
# models/marts/_marts.yml
models:
  - name: fct_bookings
    columns:
      - name: booking_id
        tests:
          - unique
          - not_null
      - name: platform
        tests:
          - accepted_values:
              values: ['airbnb', 'booking_com', 'vrbo']
      - name: listing_id
        tests:
          - relationships:
              to: ref('dim_listings')
              field: listing_id
```

### Singular Tests
Custom SQL files in the `tests/` folder. A test passes if the query returns **zero rows** (zero rows = no failures found).

```sql
-- tests/assert_revenue_is_positive.sql
SELECT booking_id
FROM {{ ref('fct_bookings') }}
WHERE revenue <= 0
```

### Test severity
```yaml
tests:
  - not_null:
      severity: warn    # warn = log warning but don't fail the pipeline
  - unique:
      severity: error   # error = fail the pipeline (default)
```

### Running tests
```bash
dbt test                           # Run all tests
dbt test --select fct_bookings     # Run tests for one model
dbt build                          # Run models + tests together
```

---

## 13. dbt — Schema Name Management

By default, dbt adds your profile's schema name as a prefix to every model (e.g. `dbt_geoffrey_staging`, `dbt_geoffrey_marts`). This is useful for developer isolation but not ideal for production.

You can override the default `generate_schema_name` macro to remove prefixes or set custom schema names:

```sql
-- macros/generate_schema_name.sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
```

This gives you schemas like `STAGING`, `MARTS` instead of `dbt_user_STAGING`, `dbt_user_MARTS`.

---

## 14. dbt — The Target Folder

The `target/` folder is auto-generated by dbt and **gitignored**. It contains two important subfolders:

- `target/compiled/` — your Jinja SQL with all templating resolved, but before the DDL wrapper
- `target/run/` — the full SQL that dbt actually ran in Snowflake, including the `CREATE TABLE AS` / `MERGE` statements

Use the target folder for **debugging**. If a model fails, check `target/compiled/` to see exactly what SQL dbt generated.

```bash
dbt compile          # Fills target/compiled/ without running anything in the warehouse
dbt run              # Compiles + executes in the warehouse
dbt clean            # Deletes the target/ folder to clear old compiled files
```

---

## 15. dbt — The DAG

dbt automatically builds a **Directed Acyclic Graph (DAG)** of all model dependencies based on `{{ ref() }}` and `{{ source() }}` calls. This means:
- Models always run in the correct order
- You can visualise the full data lineage
- You can run subsets of the pipeline by selecting from the DAG

```bash
dbt run --select stg_listings+       # Run stg_listings and all models downstream of it
dbt run --select +fct_bookings       # Run fct_bookings and all models upstream of it
dbt run --select tag:daily           # Run all models tagged 'daily'
```

---

## 16. Metadata-Driven Pipelines

Rather than writing a new dbt model for every new data source, you can build generic, config-driven pipelines where adding a new table requires only a YAML entry.

**Benefits:**
- Scales to hundreds of tables without rewriting code
- Faster onboarding of new data sources
- Consistent logging, quality checks, and transformation logic across all tables

**Trade-offs:**
- Harder to debug when something goes wrong
- Can become over-engineered for small projects

The core idea: separate *what* the pipeline does (macros + models) from *which tables* it applies to (YAML config).

---

## 17. One Big Table (OBT)

An alternative to a traditional star schema. Instead of separate dimension and fact tables, everything is pre-joined into a single wide, denormalised table.

```sql
-- mart_obt_bookings.sql
SELECT
    b.booking_id,
    b.revenue,
    b.check_in_date,
    l.listing_name,
    l.property_type,
    l.city,
    h.host_name,
    h.superhost_flag
FROM {{ ref('fct_bookings') }} b
LEFT JOIN {{ ref('dim_listings') }} l ON b.listing_id = l.listing_id
LEFT JOIN {{ ref('dim_hosts') }} h ON l.host_id = h.host_id
```

OBT is popular for BI tools (including Tableau) because it avoids requiring analysts to understand join logic. The trade-off is data redundancy and larger storage.

---

## 18. Snowflake DDL — Setup Pattern

The project uses a dedicated DDL folder with setup scripts that configure Snowflake roles, warehouses, databases, and schemas before dbt runs.

Standard Snowflake setup pattern:
```sql
-- Create a dedicated transform role for dbt
USE ROLE ACCOUNTADMIN;
CREATE ROLE IF NOT EXISTS transform;

-- Create the dbt service account user
CREATE USER IF NOT EXISTS dbt
    PASSWORD = 'xxx'
    DEFAULT_ROLE = 'transform'
    DEFAULT_WAREHOUSE = 'COMPUTE_WH'
    DEFAULT_NAMESPACE = 'AIRBNB.RAW';

GRANT ROLE transform TO USER dbt;

-- Create database and schemas
CREATE DATABASE IF NOT EXISTS AIRBNB;
CREATE SCHEMA IF NOT EXISTS AIRBNB.RAW;
CREATE SCHEMA IF NOT EXISTS AIRBNB.STAGING;
CREATE SCHEMA IF NOT EXISTS AIRBNB.MARTS;

-- Grant permissions
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE transform;
GRANT ALL ON DATABASE AIRBNB TO ROLE transform;
GRANT ALL ON ALL SCHEMAS IN DATABASE AIRBNB TO ROLE transform;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE AIRBNB TO ROLE transform;
```

**Best practice:** Never run dbt as `ACCOUNTADMIN`. Create a least-privilege `transform` role and use that.

---

## 19. Key Commands — Quick Reference

```bash
# --- uv ---
uv sync                          # Install all dependencies
uv add <package>                 # Add a new dependency
uv run <command>                 # Run a command in the managed environment

# --- dbt ---
dbt debug                        # Test connection to Snowflake
dbt compile                      # Resolve Jinja templating, no warehouse execution
dbt run                          # Build all models in the warehouse
dbt run --select <model_name>    # Build a specific model
dbt test                         # Run all data quality tests
dbt snapshot                     # Run SCD Type 2 snapshots
dbt build                        # Run models + seeds + tests
dbt clean                        # Delete the target/ folder
dbt docs generate                # Build documentation site
dbt docs serve                   # Serve docs locally at localhost:8080

# --- git ---
git init && git remote add origin <url>
git status
git add .
git commit -m "descriptive message"
git push origin main
git log --oneline                # View commit history
```

---

## 20. Key Concepts Summary

| Concept | What it is | Why it matters |
|---|---|---|
| `ref()` | Reference to a dbt model | Builds DAG order + enables lineage |
| `source()` | Reference to a raw table | Documents origin, enables lineage from source |
| Materialization | How a model is stored (view/table/incremental) | Controls cost, performance, freshness |
| Incremental | Only process new rows | Scales to large fact tables without full rebuilds |
| Snapshot | SCD Type 2 history tracking | Records how dimensions change over time |
| Ephemeral | CTE, not stored in warehouse | Intermediate step, reduces clutter |
| Macro | Reusable Jinja function | DRY code, metadata-driven pipelines |
| Singular test | Custom SQL returning failure rows | Flexible, business-specific quality checks |
| Generic test | YAML-configured column check | Fast, standardised quality checks |
| `target/` | Compiled + run SQL output | Debugging — see exactly what dbt ran |
| `uv.lock` | Pinned dependency versions | Reproducible environments across all machines |
| `profiles.yml` | Snowflake credentials | Never commit — lives outside the repo |
