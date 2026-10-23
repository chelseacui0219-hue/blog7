# ============================================================
# Blog 7: Interactive Data Visualization with Plotly
# Pipeline: From Raw IPUMS CPS to Interactive Plotly Graph
# ============================================================

install.packages(c("ipumsr", "plotly"))
library(tidyverse)
library(survey)
library(ipumsr)
library(plotly)
library(here)

# ============================================================
# 1. read raw data
# ============================================================

cps_raw <- read_ipums_micro(
  ddi = here("data", "raw", "cps_00001.xml"),
  data = here("data", "raw", "cps_00001.dat")
)

# ============================================================
# 2. clean data
# ============================================================

cps_clean <- cps_raw |>
  filter(
    INCWAGE > 0, INCWAGE < 9999990,
    INCWAGE_CPIU_2010 > 0, INCWAGE_CPIU_2010 < 9999990
  ) |>
  filter(EDUC %in% c(73, 111)) |>
  filter(AGE >= 25, AGE <= 64) |>
  filter(WKSWORK1 > 0, UHRSWORKLY > 0, UHRSWORKLY < 999) |>
  mutate(
    education = case_when(
      EDUC == 73  ~ "High school",
      EDUC == 111 ~ "Bachelor's"
    ),
    age_group = case_when(
      AGE >= 25 & AGE <= 34 ~ "25-34",
      AGE >= 35 & AGE <= 44 ~ "35-44",
      AGE >= 45 & AGE <= 54 ~ "45-54",
      AGE >= 55 & AGE <= 64 ~ "55-64"
    ),
    INCWAGE_CPIU_2010 = as.numeric(INCWAGE_CPIU_2010)
  )

# ============================================================
# 3. group and weight the data
# ============================================================

svy <- svydesign(ids = ~1, weights = ~ASECWT, data = cps_clean)

weighted_medians <- svyby(
  ~INCWAGE_CPIU_2010,
  ~YEAR + education + age_group,
  svy,
  svyquantile,
  quantiles = 0.5
)

age_premium <- weighted_medians |>
  as_tibble() |>
  select(YEAR, education, age_group, median_wage = INCWAGE_CPIU_2010) |>
  pivot_wider(names_from = education, values_from = median_wage) |>
  mutate(
    pct_premium = (`Bachelor's` / `High school` - 1) * 100
  )

# ============================================================
# 4. Plotly 
# ============================================================

p_interactive <- age_premium |>
  plot_ly(
    x = ~YEAR,
    y = ~pct_premium,
    color = ~age_group,
    type = 'scatter',
    mode = 'lines+markers',
    hovertemplate = paste(
      "<b>Year:</b> %{x}<br>",
      "<b>Age Group:</b> %{color}<br>",
      "<b>Premium:</b> %{y:.1f}%<extra></extra>"
    ),
    line = list(width = 3),
    marker = list(size = 8)
  ) |>
  layout(
    title = list(
      text = "<b>The College Wage Premium by Age Group (2002-2025)</b>",
      x = 0.05
    ),
    xaxis = list(
      title = "Year",
      dtick = 3, 
      zeroline = FALSE
    ),
    yaxis = list(
      title = "College Premium (%)",
      zeroline = FALSE
    ),
    legend = list(title = list(text = "<b>Age Group</b>")),
    hovermode = "x unified", 
    plot_bgcolor = "rgba(245, 245, 245, 1)",
    paper_bgcolor = "rgba(255, 255, 255, 1)"
  )

p_interactive


dir.create(here("output"), recursive = TRUE, showWarnings = FALSE)
htmlwidgets::saveWidget(p_interactive, here("output", "interactive_premium.html"), selfcontained = TRUE)

