SELECT COUNT(*) FROM crop_insurance_deals;
SELECT SUM(LIABILITY) FROM crop_insurance_deals;

-- Q1: Which 5 states had the highest total insured liability in 2023?
SELECT
  STATE_ABBR,
  SUM(LIABILITY) AS total_liability
FROM crop_insurance_deals
GROUP BY STATE_ABBR
ORDER BY total_liability DESC
LIMIT 5;

-- IA	622,609,998
-- MN	467,493,775
-- IL	379,756,484
-- NE	233,773,241
-- SD	180,397,230

-- Q2a: Average loss ratio by crop type
SELECT
  CROP_NAME,
  AVG(LOSS_RATIO) AS avg_loss_ratio,
  COUNT(*) AS row_count
FROM crop_insurance_deals
WHERE LOSS_RATIO IS NOT NULL
  AND CROP_NAME <> 'Nan'
GROUP BY CROP_NAME
ORDER BY avg_loss_ratio DESC;

-- Result:
-- Cotton    | 1.5459 | 26
-- Soybeans  | 0.6059 | 198
-- Wheat     | 0.6777 | 125
-- Corn      | 0.6530 | 226

-- Q2b: Crop with highest average loss ratio
SELECT
  CROP_NAME,
  AVG(LOSS_RATIO) AS avg_loss_ratio
FROM crop_insurance_deals
WHERE LOSS_RATIO IS NOT NULL
  AND CROP_NAME <> 'Nan'
GROUP BY CROP_NAME
ORDER BY avg_loss_ratio DESC
LIMIT 1;

-- Result:
-- Cotton | 1.5459


-- Q3: For corn, which 10 counties had the highest total indemnity payments?
SELECT
  STATE_ABBR,
  COUNTY_NAME,
  SUM(INDEMNITY) AS total_indemnity
FROM crop_insurance_deals
WHERE CROP_NAME = 'Corn'
  AND COUNTY_NAME <> 'nan'
GROUP BY STATE_ABBR, COUNTY_NAME
ORDER BY total_indemnity DESC
LIMIT 10;

-- Result:
-- STATE_ABBR | COUNTY_NAME      | TOTAL_INDEMNITY
-- IA         | Woodbury         | 25,175,164
-- MN         | Lyon             | 15,803,438
-- MN         | Yellow Medicine  | 9,967,906
-- IA         | Dubuque          | 7,401,200
-- KS         | Gove             | 6,801,972
-- NE         | Adams            | 6,306,833
-- IA         | Lyon             | 6,239,075
-- IA         | Worth            | 4,755,270
-- NE         | Cuming           | 3,905,137
-- IL         | Sangamon         | 3,834,958


-- Q4: What percentage of policies resulted in a claim by state?
-- Here, I built data cleaning into the query as I am running into time constraints and don't want to re-edit python file.
SELECT
  UPPER(STATE_ABBR) AS state_abbr,
  SUM(POLICIES_INDEMNIFIED) AS policies_indemnified,
  SUM(POLICIES_SOLD) AS policies_sold,
  ROUND(100.0 * SUM(POLICIES_INDEMNIFIED) / NULLIF(SUM(POLICIES_SOLD), 0), 2) AS claim_rate_pct
FROM crop_insurance_deals
GROUP BY UPPER(STATE_ABBR)
ORDER BY claim_rate_pct DESC;


-- Result:
-- STATE_ABBR | POLICIES_INDEMNIFIED | POLICIES_SOLD | CLAIM_RATE_PCT
-- MN         | 1364                 | 2636          | 51.75
-- NE         | 766                  | 1869          | 40.98
-- SD         | 394                  | 1025          | 38.44
-- IA         | 1611                 | 4484          | 35.93
-- KS         | 724                  | 2258          | 32.06
-- TX         | 371                  | 1394          | 26.10
-- IL         | 821                  | 3985          | 20.60
-- ND         | 233                  | 1194          | 19.51
-- IN         | 80                   | 783           | 10.22
-- OH         | 132                  | 1376          | 9.59

-- From the results of the table above, I see that Risk is high in Minnesota and IA judging from the elevated claim rate pct as well as # of policies sold.
-- Seeing as they are geographically close to each other in the upper midwest region, this suggests exposure driven by regional weather patterns rather than any isolated underwriting errors.
