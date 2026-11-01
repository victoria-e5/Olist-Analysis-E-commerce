# E-commerce Product Analytics

## Project Goal 
The primary objective of this analysis is to evaluate customer retention, calculate key Unit Economics metrics, and conduct an A/B test simulation for Olist, a major Brazilian e-commerce marketplace.
## Dataset Description
The analysis is based on the public Brazilian E-Commerce Dataset by Olist.  
Scope: ~100,000 anonymized orders.  
Time Period: September 2016 to September 2018.  
Architecture: Raw data was pre-processed and aggregated into data marts using PostgreSQL before being extracted into Python for statistical analysis.
## Key Objectives:
Cohort Analysis: Track user retention over time and visualize the Retention Rate using heatmaps.
Unit Economics: Calculate Cumulative Revenue per User (LTV), Average Order Value (AOV), and Purchase Frequency.
A/B Testing: Simulate and evaluate an experiment testing the hypothesis that introducing cross-sell recommendations at checkout increases the AOV, utilizing Welch's t-test and the Mann-Whitney U test.

