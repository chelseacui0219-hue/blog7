# Interactive Data Visualization of the College Wage Premium

An interactive time-series analysis of the college wage premium across different age groups using Plotly and IPUMS CPS data.

## Overview

This project extends previous analyses of the College Wage Premium by introducing interactivity. Using Plotly in R, we visualize the wage gap between bachelor's degree holders and high school graduates across four age cohorts from 2002 to 2025. 

The interactive chart allows readers to:
- Hover to see exact premium values simultaneously across groups.
- Click the legend to isolate specific age cohorts.
- Zoom into critical macroeconomic periods (e.g., 2008 crisis, COVID-19).

## Data Source & Methodology

| Item | Description |
|------|-------------|
| Source | U.S. Census Bureau, IPUMS CPS (ASEC) |
| Years | 2002 - 2025 |
| Sample | Workers aged 25-64, with positive earnings and work hours |
| Weight | `ASECWT` (survey weight for population representation) |
| Earnings | Adjusted to 2010 dollars (`INCWAGE_CPIU_2010`) |

1. **Data Cleaning**: The raw IPUMS `.dat` and `.xml` files are parsed using `ipumsr`. Invalid income codes (9999999) are dropped. Education is restricted to high school (73) and bachelor's (111).
2. **Aggregation**: Using the `survey` package, weighted medians are calculated for each year and age group.
3. **Premium Calculation**: `(Bachelor's Median / High School Median) - 1`.
4. **Visualization**: Rendered using `plotly` with custom hover templates and a unified hover mode.

## Repository Structure
