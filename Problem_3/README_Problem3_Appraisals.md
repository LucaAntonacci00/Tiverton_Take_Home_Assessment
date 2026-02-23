# Data Engineering Interview Question: Land Appraisal Analytics

**Time Limit:** 2-3 hours  
**Tools:** SQL (Snowflake), Python optional for bonus  
**Context:** Agricultural private equity firm tracking land valuations across portfolio and pipeline companies

---

## Background

You've joined a PE firm that invests in agricultural operations. The firm receives appraisal PDFs for properties across their portfolio companies (existing investments) and pipeline companies (prospective deals). These appraisals have been extracted via an automated pipeline and stored in a Snowflake table.

Each appraisal PDF may contain **multiple parcels**, and each parcel may have **separate valuations** for:
- **Land** (the dirt itself, with crop-specific valuations)
- **Improvements** (buildings, packing houses, irrigation infrastructure, etc.)

The extraction pipeline creates **one row per parcel-type combination**, so a single PDF with 3 parcels that each have land + improvements produces 6 rows.

---

## Data Schema

```sql
CREATE TABLE appraisals.land_valuations (
    file_name                           VARCHAR,       -- Source PDF name
    processed_date                      TIMESTAMP,     -- When extracted
    company_name                        VARCHAR,       -- Portfolio/pipeline company
    is_current_investment               VARCHAR(1),    -- 'Y' = portfolio, 'N' = pipeline
    investment_type                     VARCHAR,       -- 'Credit' or 'Equity'
    fund                                VARCHAR,       -- Fund name
    appraisal_company                   VARCHAR,       -- Firm that did the appraisal
    appraiser_name                      VARCHAR,       -- Individual appraiser
    subject_property                    VARCHAR,       -- Property name
    appraisal_date                      DATE,
    state                               VARCHAR,
    county                              VARCHAR,
    parcel_id                           VARCHAR,       -- May be APN or tract name
    appraisal_type                      VARCHAR,       -- 'Land', 'Improvements', or null
    improvement_type                    VARCHAR,       -- e.g., 'Cold Storage', 'Housing'
    primary_crop                        VARCHAR,       -- For Land rows only
    soil_productivity_rating            VARCHAR,       -- e.g., 'Class 1', 'Class 2'
    gross_acres                         FLOAT,         -- Total acreage
    net_acres                           FLOAT,         -- Productive/tillable acres
    sales_comparison_valuation          FLOAT,         -- Market approach value
    cost_approach_valuation             FLOAT,         -- Replacement cost value
    income_approach_valuation           FLOAT,         -- Capitalized income value
    value_reconciliation                FLOAT          -- Appraiser's final opinion
);
```

### Sample Data (4 records shown)

**Record 1 — Land parcel with net acres populated:**
```
company_name:        Pacific Orchards
is_current_investment: Y (portfolio company)
state/county:        Washington / Yakima
parcel_id:           Parcel A
appraisal_type:      Land
primary_crop:        Apples
gross_acres:         342.91
net_acres:           111.57
sales_comparison:    $3,345,000
income_approach:     NULL
value_reconciliation: $3,400,000
appraisal_date:      2024-03-15
```

**Record 2 — Improvements for same parcel (no acreage):**
```
company_name:        Pacific Orchards
is_current_investment: Y
state/county:        Washington / Yakima
parcel_id:           Parcel A
appraisal_type:      Improvements
improvement_type:    Cold Storage
gross_acres:         NULL
net_acres:           NULL
value_reconciliation: $850,000
appraisal_date:      2024-03-15
```

**Record 3 — Pipeline deal with both valuation approaches:**
```
company_name:        Sunland Farms
is_current_investment: N (pipeline deal)
state/county:        California / Fresno
parcel_id:           012-345-678
appraisal_type:      Land
primary_crop:        Almonds
gross_acres:         500.00
net_acres:           480.00
sales_comparison:    $12,000,000
income_approach:     $11,500,000
value_reconciliation: $11,750,000
appraisal_date:      2024-06-01
```

**Record 4 — Land with missing net_acres (must use gross):**
```
company_name:        Delta Ag
is_current_investment: Y
state/county:        California / Kern
parcel_id:           Tract 1
appraisal_type:      Land
primary_crop:        Pistachios
gross_acres:         200.00
net_acres:           NULL  ← forces use of gross_acres for $/acre
sales_comparison:    $7,500,000
income_approach:     NULL
value_reconciliation: $7,500,000
appraisal_date:      2023-11-20
```

---

## Tasks

### Part 1: Data Quality Assessment (20 min)

Write queries to identify and quantify data quality issues:

**1a.** How many rows have `appraisal_type` = 'Land' but are missing **both** `net_acres` and `gross_acres`? These records cannot have $/acre calculated.

**1b.** Identify records where `net_acres > gross_acres` (logically impossible). Return the `company_name`, `parcel_id`, and both acreage values.

**1c.** Find duplicate primary crops that should be consolidated (e.g., 'Almonds' vs 'Almond', 'Wine Grapes' vs 'Grapes - Wine'). Write a query that identifies potential duplicates using fuzzy matching or pattern detection.

---

### Part 2: $/Acre Calculation Logic (30 min)

The credit team needs **$/acre** metrics for land valuations. The business rules are:

1. Only calculate for `appraisal_type = 'Land'`
2. Use `net_acres` as the denominator if available; otherwise use `gross_acres`
3. If both are null or zero, $/acre cannot be calculated
4. Calculate $/acre for **each** valuation approach that has data

**2a.** Write a query that calculates $/acre for each valuation approach. Output should include:
- `company_name`, `parcel_id`, `state`, `county`, `primary_crop`, `appraisal_date`
- `effective_acres` (the denominator used)
- `sales_comparison_per_acre`
- `cost_approach_per_acre`
- `income_approach_per_acre`
- `reconciliation_per_acre`

**2b.** Create a ranked list of the **top 10 most expensive agricultural counties** based on median $/acre (using `value_reconciliation`). Include:
- `state`, `county`
- `median_per_acre`
- `count_of_appraisals`
- `primary_crops` (comma-separated list of distinct crops in that county)

Filter to counties with ≥3 land appraisals.

---

### Part 3: Portfolio Analytics (40 min)

**3a. Portfolio vs Pipeline Comparison**

Create a summary comparing portfolio companies (`is_current_investment = 'Y'`) vs pipeline deals (`= 'N'`):

Expected output columns:
```
segment | total_land_value | total_improvement_value | total_acres | avg_per_acre | num_companies | num_properties
```

Use `value_reconciliation` for values. For land rows, sum effective acres.

**3b. Year-over-Year Valuation Trends**

For properties that have been appraised **multiple times** (same `company_name` + `county` combination with different `appraisal_date`), calculate the compound annual growth rate (CAGR) in $/acre.

Return: `company_name`, `county`, `primary_crop`, `earliest_appraisal_date`, `latest_appraisal_date`, `earliest_per_acre`, `latest_per_acre`, `cagr_pct`

Sort by `cagr_pct` descending to surface properties with the highest appreciation.

**3c. Valuation Method Consistency**

Some appraisers prefer different valuation methods. Analyze whether `sales_comparison_valuation` vs `income_approach_valuation` produces systematically different results:

1. For Land rows that have **both** approaches populated, calculate the % difference: `(income - sales) / sales * 100`
2. Aggregate by `state` to show which states have the largest systematic divergence between methods
3. Output: `state`, `avg_difference_pct`, `count_records`

---

### Part 4: Data Modeling (30 min)

The current flat table makes some analyses difficult. Design a normalized schema that would better support:

- Tracking the same physical property over time
- Separating land parcels from improvements
- Enabling geographic rollups (parcel → county → state → region)
- Supporting future integration with external data (USDA land value surveys, county assessor records)

**4a.** Draw or describe an ERD with at least 4 tables. Explain your primary/foreign key choices.

**4b.** Write the DDL for your `dim_property` or equivalent table that would serve as the "master" list of physical properties.

**4c.** What deduplication logic would you use to match appraisal records to a canonical property? (Consider that `parcel_id` formats vary widely: APNs, tract names, informal descriptions)

---

### Bonus: Advanced Analytics (if time permits)

**Bonus 1:** Write a query using Snowflake's `GEOGRAPHY` type to calculate the distance between each property and the nearest major agricultural market (assume you have a `markets` table with `market_name`, `lat`, `lng`). How would you join properties to markets given that the appraisals data lacks coordinates?

**Bonus 2:** Design an incremental loading strategy for this data. New PDFs are processed daily via an Azure queue. How would you:
- Detect truly new records vs re-processed PDFs?
- Handle late-arriving corrections to previously extracted data?
- Maintain a slowly-changing dimension for company information (portfolio → pipeline transitions)?

---

## Evaluation Criteria

| Criteria               | Weight | What We're Looking For                              |
|:-----------------------|:------:|:----------------------------------------------------|
| SQL Correctness        |  25%   | Queries execute, handle nulls/edge cases            |
| Business Logic         |  25%   | Correctly implements acreage fallback, filters      |
| Data Quality Awareness |  20%   | Identifies issues, proposes cleaning strategies     |
| Schema Design          |  20%   | Normalized, supports stated use cases               |
| Code Clarity           |  10%   | Readable SQL, meaningful aliases, comments          |

---

## Rules & Guidelines

- **You may use any tools** — pandas, Python, SQL, Excel, LLMs/AI assistants, Stack Overflow, whatever you'd use in a real job
- **Time-box yourself** — we respect your time. A focused 3-4 hour effort is better than an over-engineered 10-hour submission
- **Ask questions** — if something is genuinely unclear, email rgibbs@tiverton.ag. We'd rather clarify than have you guess wrong.
- **AI Honor Code** - AI/LLM use on take-home assignments is permitted/encouraged with the following guidelines:
- If you use AI tools(ChatGPT, Claude, Copilot etc), briefly note where and how in your README — this is encouraged, not penalized
- Think of it as an extension of any plagiarism policy, specifically:
- Must cites LLM usage as a source where appropriate, using footnotes - which tool(s) used and for which deliverable elements. 
- Be aware that we as a team take QAing the output of LLMs very seriously, and spend a lot of time reviewing output for which AI is either cited as having been used or can be assumed to have been used
- Use your best judgement on the amount of usage - it will be very evident if your code or written summaries are 100% AI-generated, for instance

## Deliverables

1. SQL file(s) with all queries, clearly labeled by task number
2. Brief written answers for Part 4 (ERD can be ASCII, diagram, or prose description)
3. Any assumptions you made about the data

---

*Good luck! Focus on demonstrating your reasoning—partial solutions with clear explanations are valued over rushed complete answers.*
