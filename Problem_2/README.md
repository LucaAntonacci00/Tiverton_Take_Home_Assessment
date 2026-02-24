Executive Summary

This analysis evaluates 2023 crop insurance policy data to identify geographic and crop-level risk concentration. After cleaning and standardizing the dataset (582 valid records), we examined liability exposure, loss ratios, indemnity concentration, and claim frequency.

Key findings indicate that underwriting risk is heavily concentrated in the Upper Midwest, particularly Minnesota, Iowa, Nebraska, and South Dakota. Cotton exhibits the highest average loss ratio across crop types, while corn exposure is geographically clustered at the county level.

Data Preparation
- Initial cleaning included:
- Removing rows with invalid key monetary values
- Recomputing loss ratios
- Standardizing categorical fields (e.g., state abbreviations, crop names)
- Consolidating crop synonyms (e.g., “Maize” → “Corn”)
- Excluding placeholder values such as “Nan” in crop and county fields
Final dataset: 582 policies

Findings
1. Liability Concentration (Q1)
The states with the highest total insured liability in 2023 were:
- Iowa
- Minnesota
- Illinois
- Nebraska
- South Dakota
These states represent the largest underwriting exposure in the portfolio.

2. Crop Risk – Average Loss Ratio (Q2)
Average loss ratio by crop:
Crop	   |   Avg Loss Ratio
Cotton	 |   1.5459
Soybeans | 	 0.6059
Wheat	   |   0.6777
Corn	   |   0.6530
Cotton has the highest average loss ratio (1.55), meaning indemnities exceeded premiums by ~55% on average. This indicates elevated underwriting risk for cotton relative to other major crops.

3. Corn Indemnity Concentration (Q3)
- Top counties by total corn indemnity payments include:
- Woodbury County, IA – $25.2M
- Lyon County, MN – $15.8M
- Yellow Medicine County, MN – $9.97M
- Dubuque County, IA – $7.4M
- Gove County, KS – $6.8M
Indemnity exposure is concentrated in Midwestern counties, particularly Iowa and Minnesota.

4. Claim Frequency by State (Q4) (See analysis.sql file for exact figures)
Minnesota exhibits the highest claim frequency at 51.75% across more than 2,600 policies, indicating statistically significant elevated risk. High claim rates align geographically with indemnity concentration findings.

Conclusion
The 2023 portfolio shows meaningful concentration risk in the Upper Midwest, particularly across corn-producing regions. Minnesota stands out for both high claim frequency and elevated indemnity concentration. Cotton demonstrates the highest relative loss performance but represents lower overall policy volume.
Future underwriting strategy should consider geographic diversification and closer risk assessment in high-claim Midwestern regions.
