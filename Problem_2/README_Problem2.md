# Tiverton Advisors — Data Engineering Analyst Take-Home Assignment

## Overview

Tiverton Advisors is an agricultural private equity firm. Our investment team regularly works with USDA crop insurance data to assess risk, evaluate potential deals, and monitor portfolio performance across farm operations.

You've received an export of 2023 crop insurance policy data covering major agricultural states. Unfortunately, the data has quality issues from the extraction process. Your task is to clean this dataset, load it into a queryable format, and answer several business questions.

**Time expectation:** 3-4 hours  
**Submission deadline:** In instructions email

---

## Dataset

**File:** `crop_insurance_deals_2023.csv`

This is a subset of USDA Risk Management Agency (RMA) Summary of Business data. Each row represents crop insurance policies at the county/crop/coverage level.

**Key columns:**
| Column | Description |
|--------|-------------|
| `CROP_YEAR` | Policy year |
| `STATE_CODE` / `STATE_ABBR` | State identifiers |
| `COUNTY_CODE` / `COUNTY_NAME` | County identifiers |
| `CROP_CODE` / `CROP_NAME` | Crop identifiers |
| `COVERAGE_LEVEL` | Insurance coverage level (e.g., 0.75 = 75%) |
| `POLICIES_SOLD` | Number of policies sold |
| `POLICIES_INDEMNIFIED` | Number of policies with claims paid |
| `LIABILITY` | Total insured liability (dollars) |
| `TOTAL_PREMIUM` | Total premium charged |
| `INDEMNITY` | Total claims paid |
| `LOSS_RATIO` | Indemnity / Total Premium |

---

## Tasks

### Part 1: Data Cleaning (Python)

Write a Python script or Jupyter notebook that:

1. **Profiles the raw data** — row count, column types, missing values, basic statistics
2. **Identifies and documents data quality issues** — be specific about what you find
3. **Cleans the data** — handle the issues you identified (duplicates, inconsistencies, missing values, outliers, etc.)
4. **Outputs a clean CSV** ready for analysis

**Document your decisions.** For each issue, briefly note:
- What you found
- How you handled it
- Why you chose that approach

### Part 2: SQL Analysis

Using your cleaned data, answer the following business questions. You may use SQLite, DuckDB, or write queries assuming a table called `crop_insurance`.

1. **Which 5 states had the highest total insured liability in 2023?**

2. **What is the average loss ratio by crop type? Which crop had the worst (highest) loss ratio?**

3. **For corn specifically: which 10 counties had the highest total indemnity payments?**

4. **What percentage of policies resulted in a claim (were indemnified) by state? Rank states from highest to lowest claim rate.**

5. **BONUS:** Identify any patterns or anomalies in the data that might be worth flagging to an investment analyst. (Open-ended — show us how you think.)

### Part 3: Summary Memo

Write a brief memo (half page to one page) summarizing your findings for a non-technical reader. Imagine your audience is an investment professional who wants to understand:
- Key data quality issues you found and fixed
- 2-3 insights from your analysis
- Any caveats or limitations

---

## Deliverables

Submit a **GitHub repository** (public or private, shared with ryandgibbs) containing:

```
/
├── README.md              # Setup instructions, approach overview
├── data/
│   ├── raw/               # Original messy CSV (unchanged)
│   └── clean/             # Your cleaned output
├── src/
│   └── clean_data.py      # (or .ipynb) Your cleaning code
├── sql/
│   └── analysis.sql       # Your SQL queries with results
└── memo.md (or memo.pdf)  # Summary memo
```

**Alternative:** If you prefer, a single well-organized Jupyter notebook with all components is acceptable.

---

## Evaluation Criteria

| Criteria | What we're looking for |
|----------|------------------------|
| **Data profiling** | Did you systematically explore the data before diving in? |
| **Issue identification** | Did you catch the main problems? Did you miss obvious issues? |
| **Cleaning approach** | Are your solutions reasonable? Did you handle edge cases? |
| **Code quality** | Is your code readable, organized, and documented? |
| **SQL correctness** | Do your queries run and return correct results? |
| **Communication** | Can you explain technical work to non-technical stakeholders? |
| **Judgment** | Did you make sensible decisions when there wasn't one "right" answer? |

We're evaluating your **process and thinking**, not just whether you get the "right" answers. If you encounter ambiguity, document your assumption and move on.

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

---

## Submission

Email a link to your GitHub repo (or a zip file) to rgibbs@tiverton.ag by the submission deadline.

Include in your email:
- Approximately how long you spent
- Any questions or feedback on the assignment itself

---

Any questions, email rgibbs@tiverton.ag.

Good luck! We're excited to see your work.
