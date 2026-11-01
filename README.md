# E-Commerce Product Analytics & A/B Testing: Olist


## Overview
This project is an end-to-end product analytics pipeline evaluating customer retention, Unit Economics, and A/B test simulation for Olist, a major Brazilian e-commerce marketplace. The analysis bridges raw database extraction, statistical hypothesis testing, and BI visualization to provide actionable business insights.

## Project Goal 
The primary objective of this analysis is to evaluate customer retention, calculate key Unit Economics metrics, and conduct an A/B test simulation for Olist.

## Dataset Description
Scope: ~100,000 anonymized orders.  
Time Period: September 2016 to September 2018.  
Architecture: Raw data was pre-processed and aggregated into data marts using PostgreSQL before being extracted into Python for statistical analysis.

## Key Objectives:
Cohort Analysis: Track user retention over time and visualize the Retention Rate using heatmaps.
Unit Economics: Calculate Cumulative Revenue per User (LTV), Average Order Value (AOV), and Purchase Frequency.
A/B Testing: Simulate and evaluate an experiment testing the hypothesis that introducing cross-sell recommendations at checkout increases the AOV, utilizing Welch's t-test and the Mann-Whitney U test.

***
## Tech Stack
1.Database: PostgreSQL (CTEs, Window Functions, Views, Data Marts)

2.Python (through Jupyter Notebook): Pandas, SciPy, Matplotlib, Seaborn

3.Business Intelligence: Power BI

4.Concepts: Cohort Analysis, Retention Rate, LTV, Unit Economics, A/B Testing (Welch’s t-test, Mann-Whitney U test)

***
## Pipeline
1. Data Engineering (using SQL): Raw transactional tables were processed in PostgreSQL. Created aggregated three Data Marts (`mart_orders_finance`, `mart_behavioral_retention`, `mart_rfm_profile`) using `CREATE OR REPLACE VIEW` to isolate analytical logic.
2. Product Analytics (using Python): Directly queried SQL views via `SQLAlchemy` into pandas DataFrames. Conducted cohort analysis, calculated cumulative LTV, and simulated an A/B test.
3. Data Visualization (using Power BI): Connected to the SQL Data Marts to build a dashboard tracking total revenue, purchase frequency, and customer segmentation.


***
## Business Insights

### Cohort Analysis
Customer retention drops below 1% by the first month (Lifetime 1) across all cohorts. The e-commerce platform functions primarily as a single-use marketplace. There is no established core of loyal returning customers, forcing the business to recover Customer Acquisition Cost (CAC) entirely on the first order.

### Unit Economics
The average orders per active user stagnates between 1.005 and 1.025. Cumulative Revenue per User (LTV) plateaus immediately after the month of acquisition. The difference in cohort value is driven entirely by the initial Average Order Value (AOV), not by recurring purchases.

### A/B Testing Simulation
Experiment Design: Simulated the introduction of a cross-sell recommendation block - "Frequently bought together" - at checkout, targeting a 5% MDE on AOV. 

Methodology: Users were strictly hashed by `customer_unique_id` and split 50/50. Due to the right-skewed log-normal distribution of e-commerce revenue (heavy outliers), Welch’s t-test and the non-parametric Mann-Whitney U test were applied.

Results: The null hypothesis $H_0$ was rejected ($p-value < 0.05$). The alternative hypothesis $H_1$ was mathematically confirmed, proving the statistical significance of the 5% AOV uplift. 

Recommendation: Roll out the recommendation system to 100% of the user base to maximize Gross Profit.

***

## Repository Structure
```
├── sql/
│   ├── 01_mart_orders_finance.sql
│   ├── 02_mart_behavioral_retention.sql
│   └── 03_mart_rfm_profile.sql
├── A_B_Olist.ipynb           # Cohorts, LTV, A/B testing
├── Dashboard_Olist.png       # Power BI dashboard visualization
└── README.md
```

***
#### How to Run

1. Clone the repository: git clone https://github.com/victoria-e5/olist-analytics.git

2. Set up the PostgreSQL database and execute the scripts in the /sql folder to build the data marts.

3. Update the database connection string credentials (db_user, db_password) in A_B_Olist.ipynb.

4. Run the Jupyter Notebook to replicate the statistical tests and cohort heatmaps.
