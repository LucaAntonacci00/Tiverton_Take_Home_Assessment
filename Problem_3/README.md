Land Appraisal Analysis (Problem 3) – Tiverton Take Home Assessment
Overview

This project analyzes agricultural land appraisal data to evaluate acreage consistency, valuation trends, and methodological differences across states.

All analytical logic, validation steps, and commentary are built directly into the accompanying SQL file. Queries are structured with inline comments to document assumptions, filtering decisions, and data limitations encountered during analysis.

Structure
The SQL file contains the following sections:

1. Acreage Validation

Constructed an effective_acres field using:
net_acres when available and positive
Otherwise gross_acres when available and positive
Identified rows where acreage data was missing or unusable
Ensured per-acre calculations only use valid denominators

2. Reconciliation Value CAGR Analysis

Objective:
Compute CAGR in reconciliation value per acre for properties with multiple appraisal dates.

Finding:
While three company + county combinations contain multiple appraisal dates, none contain two non-null reconciliation values with valid acreage across different dates.
As a result, reconciliation $/acre CAGR cannot be computed for any property in the provided sample dataset.

3. Valuation Method Consistency (Sales vs Income)

Objective:
Evaluate whether income-based valuations systematically differ from sales comparison valuations.
Method:
Restricted to Land rows
Required both sales_comparison_valuation and income_approach_valuation to be populated
Calculated:

(income - sales) / sales * 100 Aggregated by state

Key Findings:

Income approach valuations are systematically lower than sales comparison valuations across all states in the dataset.
Largest divergence observed in Oregon (~ -5.9%)
California shows consistent ~ -4.5% difference across the largest sample size
___________________________________________________________________________________
Design Approach
All transformations performed in SQL
Data validation and logic checks included
Edge cases explicitly tested before computing metrics

Note on Data Limitations
Limited multi-date reconciliation observations prevent time-series CAGR analysis

Problem Completion Note
I completed up to Part 4a within Problem 3 in the alloted time
Please see the uploaded PDF for my ERD and Design Rationale.
___________________________________________________________________________________
Tooling and Development Process

SQL Environment:
All analysis was executed using DuckDB via DBeaver as the SQL client
DBeaver was used to:
- Explore schema and inspect table structures
- Validate intermediate result sets
- Iteratively test logic
- Debug/revise filtering logic

Use of LLM Assistance
Large Language Models were used selectively to 
- Accelerate query drafting
- Refine SQL structure and formatting
- Validate mathmatical expressions (e.g., CAGR, percentage difference)
- Troubleshoot SQL specific issues

All analytical decisions, filtering logic, and data interpretation were independently validated within the SQL environment. 
LLM assistance was used as a development accelerator, and all reasoning or validation was done by me.
