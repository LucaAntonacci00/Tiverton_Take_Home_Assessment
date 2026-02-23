-- PART 1A
-- Land rows missing BOTH net_acres and gross_acres

SELECT COUNT(*) AS missing_all_acres_rows
FROM land_valuations
WHERE appraisal_type = 'Land'
  AND net_acres IS NULL
  AND gross_acres IS NULL;

-- PART 1B
-- Land rows where net_acres > gross_acres

SELECT
  company_name,
  subject_property,
  parcel_id,
  gross_acres,
  net_acres
FROM land_valuations
WHERE appraisal_type = 'Land'
  AND net_acres IS NOT NULL
  AND gross_acres IS NOT NULL
  AND net_acres > gross_acres
ORDER BY (net_acres - gross_acres) DESC;

-- PART 1C
-- Detect potential duplicate crop names via normalization

WITH crops AS (
  SELECT DISTINCT
    primary_crop,
    lower(regexp_replace(primary_crop, '[^a-z0-9]', '', 'g')) AS crop_clean
  FROM land_valuations
  WHERE appraisal_type = 'Land'
    AND primary_crop IS NOT NULL
),
grouped AS (
  SELECT
    crop_clean,
    string_agg(primary_crop, ', ') AS variants,
    COUNT(*) AS variant_count
  FROM crops
  GROUP BY crop_clean
)
SELECT *
FROM grouped
WHERE variant_count > 1
ORDER BY variant_count DESC;

-- PART 2A
-- Per-acre valuation metrics (Land only)

WITH land AS (
  SELECT
    company_name,
    state,
    county,
    primary_crop,
    appraisal_date,

    CASE
      WHEN net_acres IS NOT NULL AND net_acres > 0 THEN net_acres
      WHEN gross_acres IS NOT NULL AND gross_acres > 0 THEN gross_acres
      ELSE NULL
    END AS effective_acres,

    sales_comparison_valuation,
    cost_approach_valuation,
    income_approach_valuation,
    value_reconciliation

  FROM land_valuations
  WHERE appraisal_type = 'Land'
)

SELECT
  company_name,
  state,
  county,
  primary_crop,
  appraisal_date,
  effective_acres,

  sales_comparison_valuation / effective_acres AS sales_per_acre,
  cost_approach_valuation / effective_acres AS cost_per_acre,
  income_approach_valuation / effective_acres AS income_per_acre,
  value_reconciliation / effective_acres AS reconciliation_per_acre

FROM land
WHERE effective_acres IS NOT NULL
ORDER BY reconciliation_per_acre DESC;


-- PART 2B
-- Top 10 counties by MEDIAN reconciliation $/acre
-- Minimum 3 land appraisals

WITH land AS (
  SELECT
    state,
    county,
    primary_crop,
    CASE
      WHEN net_acres IS NOT NULL AND net_acres > 0 THEN net_acres
      WHEN gross_acres IS NOT NULL AND gross_acres > 0 THEN gross_acres
      ELSE NULL
    END AS effective_acres,
    value_reconciliation
  FROM land_valuations
  WHERE appraisal_type = 'Land'
),

per_acre AS (
  SELECT
    state,
    county,
    primary_crop,
    value_reconciliation / effective_acres AS reconciliation_per_acre
  FROM land
  WHERE effective_acres IS NOT NULL
    AND value_reconciliation IS NOT NULL
)

SELECT
  state,
  county,
  median(reconciliation_per_acre) AS median_per_acre,
  COUNT(*) AS appraisal_count,
  string_agg(DISTINCT primary_crop, ', ') AS crops_present
FROM per_acre
GROUP BY state, county
HAVING COUNT(*) >= 3
ORDER BY median_per_acre DESC
LIMIT 10;

--Land Counts by county (for my own understanding/double checking)

SELECT
  state,
  county,
  COUNT(*) AS land_rows
FROM land_valuations
WHERE appraisal_type = 'Land'
GROUP BY state, county
ORDER BY land_rows DESC, state, county;

-- PART 3A
-- Portfolio vs Pipeline Summary

WITH base AS (
  SELECT
    CASE
      WHEN is_current_investment = 'Y' THEN 'Portfolio'
      ELSE 'Pipeline'
    END AS segment,

    company_name,
    subject_property,
    appraisal_type,
    value_reconciliation,

    CASE
      WHEN net_acres IS NOT NULL AND net_acres > 0 THEN net_acres
      WHEN gross_acres IS NOT NULL AND gross_acres > 0 THEN gross_acres
      ELSE NULL
    END AS effective_acres

  FROM land_valuations
)

SELECT
  segment,

  SUM(CASE WHEN appraisal_type = 'Land' THEN value_reconciliation ELSE 0 END)
    AS total_land_value,

  SUM(CASE WHEN appraisal_type = 'Improvements' THEN value_reconciliation ELSE 0 END)
    AS total_improvement_value,

  SUM(CASE WHEN appraisal_type = 'Land' THEN effective_acres ELSE 0 END)
    AS total_acres,

  SUM(CASE WHEN appraisal_type = 'Land' THEN value_reconciliation ELSE 0 END)
  /
  NULLIF(SUM(CASE WHEN appraisal_type = 'Land' THEN effective_acres ELSE 0 END), 0)
    AS avg_per_acre,

  COUNT(DISTINCT company_name) AS num_companies,
  COUNT(DISTINCT subject_property) AS num_properties

FROM base
GROUP BY segment
ORDER BY segment;

-- Analysis
-- Portfolio Assets are currently valued at higher per-acre levels.
-- Portfolio represents roughly 2x the land value of the pipeline.
-- Portfolio has more diversified property exposure, with 5 portfolio properties vs 3 in the pipeline.
-- As a summary, The current portfolio exhibits both higher aggregate land value and higher per-acre valuation relative to the pipeline. 
----- This suggests that existing holdings are concentrated in higher-quality or more premium agricultural regions. Perhaps the pipeline is targeting more speculative properties or the firm is looking to diversify.


-- PART 3B 

-- Looking for where appraisal dates >2
SELECT
  company_name,
  county,
  COUNT(*) AS land_row_count,
  COUNT(DISTINCT appraisal_date) AS distinct_appraisal_dates,
  MIN(appraisal_date) AS earliest_date,
  MAX(appraisal_date) AS latest_date
FROM land_valuations
WHERE appraisal_type = 'Land'
GROUP BY company_name, county
ORDER BY land_row_count DESC;

-- Show appraisal date and existence of inputs
WITH multi AS (
  SELECT
    company_name,
    county
  FROM land_valuations
  WHERE appraisal_type = 'Land'
  GROUP BY company_name, county
  HAVING COUNT(DISTINCT appraisal_date) >= 2
)
SELECT
  l.company_name,
  l.county,
  l.appraisal_date,
  l.primary_crop,
  l.net_acres,
  l.gross_acres,
  l.value_reconciliation,
  CASE
    WHEN l.value_reconciliation IS NULL THEN 'NO_RECON'
    WHEN ( (l.net_acres IS NOT NULL AND l.net_acres > 0) OR (l.gross_acres IS NOT NULL AND l.gross_acres > 0) )
      THEN 'OK'
    ELSE 'NO_ACRES'
  END AS status,
  l.value_reconciliation /
    CASE
      WHEN l.net_acres IS NOT NULL AND l.net_acres > 0 THEN l.net_acres
      WHEN l.gross_acres IS NOT NULL AND l.gross_acres > 0 THEN l.gross_acres
      ELSE NULL
    END AS recon_per_acre
FROM land_valuations l
JOIN multi m
  ON l.company_name = m.company_name
 AND l.county = m.county
WHERE l.appraisal_type = 'Land'
ORDER BY l.company_name, l.county, l.appraisal_date;

-- While 3 company and county combinations contain multiple appraisal dates, none contain two non-null reconciliation values while also having valid acreage on different dates.
-- CAGR cannot be computed for any property in the provided dataset


-- PART 3C
-- Valuation Method Consistency (Sales vs Income)


WITH usable AS (
  SELECT
    state,
    (income_approach_valuation - sales_comparison_valuation)
      / sales_comparison_valuation * 100 AS difference_pct
  FROM land_valuations
  WHERE appraisal_type = 'Land'
    AND sales_comparison_valuation IS NOT NULL
    AND income_approach_valuation IS NOT NULL
    AND sales_comparison_valuation > 0
)

SELECT
  state,
  AVG(difference_pct) AS avg_difference_pct,
  COUNT(*) AS count_records
FROM usable
GROUP BY state
ORDER BY ABS(AVG(difference_pct)) DESC;

-- As shown by the results of the above table, the income approach syematically values land lower than the sales comparison approach. The largest divergence is seen in Oregon, though the sample size is limited.
-- California shows an average discount of 4.5% across 8 samples, a more statistically significant result in relation to the dataset.