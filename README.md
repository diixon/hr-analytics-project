# HR Analytics Project: Employee Attrition & Performance

> **Status:** in progress

## Overview
An end-to-end analysis of HR data for a company with 1,470 employees. The goal is to understand which factors are related to employee attrition (employees leaving the company) and how performance reviews and satisfaction scores look across departments.

## Business questions
1. What is the overall attrition rate, and how does it differ by department and job role?
2. Is overtime related to attrition?
3. Do employees who left earn less than those who stayed?
4. How do self ratings compare with manager ratings?
5. Are satisfaction, work-life balance, and training related to performance?

## Dataset
Five CSV files (source: **TODO: add the source of the data**):

| File | Description | Rows |
|---|---|---|
| Employee.csv | One row per employee: demographics, job, salary, attrition | 1,470 |
| PerformanceRating.csv | Performance reviews and satisfaction scores | 6,709 |
| EducationLevel.csv | Lookup: education level names | 5 |
| RatingLevel.csv | Lookup: rating names | 5 |
| SatisfiedLevel.csv | Lookup: satisfaction level names | 5 |

## Tools
- **Python** (pandas, matplotlib, seaborn) in Jupyter notebooks
- **SQL** (SQLite)
- **Excel** (PivotTables)
- **Power BI** (dashboard)
- **Git & GitHub**

## Project structure
```
hr-analytics-project/
├── data/
│   ├── raw/        original CSV files (never edited)
│   └── clean/      cleaned CSV files
├── notebooks/      Jupyter notebooks
├── sql/            SQL queries
├── excel/          Excel analysis
├── powerbi/        Power BI report
└── images/         screenshots of charts and dashboard
```

## How to run
1. Install the libraries: `pip install pandas matplotlib seaborn ipykernel`
2. Put the 5 CSV files in `data/raw/` and create the folders `data/clean/`.
3. Run `notebooks/01_data_cleaning.ipynb`, then `notebooks/02_create_database.ipynb`.

## Progress
- [x] Data cleaning (Python)
- [x] SQLite database with primary and foreign keys
- [x] Basic SQL queries
- [ ] Advanced SQL queries (CTEs, window functions)
- [ ] Exploratory analysis and charts (Python)
- [ ] Excel PivotTables
- [ ] Power BI dashboard
- [ ] Final insights and recommendations

## Data cleaning summary
- No missing values and no duplicate rows were found.
- Extra spaces in text columns (BusinessTravel, Ethnicity, EducationField, and the lookup tables) were removed.
- HireDate and ReviewDate were converted from text to dates.
- Only 1,280 of 1,470 employees have performance reviews, so LEFT JOIN is used to keep all employees.
- Known data issue: 1,141 reviews (17%) for 289 employees are dated before the employee's hire date. These rows are kept and flagged; time-based analysis is done with this in mind.

## Key findings
TODO: add after the analysis is finished.

## Recommendations
TODO: add after the analysis is finished.
