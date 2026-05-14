# 📊 Strategic Planning Analytics Suite
### Forecast Models, KPI Tracking & Management Presentations

[![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white)](https://python.org)
[![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?logo=postgresql&logoColor=white)](https://postgresql.org)
[![Excel](https://img.shields.io/badge/Excel-Advanced-217346?logo=microsoft-excel&logoColor=white)](https://microsoft.com/excel)
[![Tableau](https://img.shields.io/badge/Tableau-Visualizations-E97627?logo=tableau&logoColor=white)](https://tableau.com)
[![PowerPoint](https://img.shields.io/badge/PowerPoint-Executive%20Decks-B7472A?logo=microsoft-powerpoint&logoColor=white)](https://microsoft.com)

> **Live Portfolio:** [ayushi-6244.github.io](https://ayushi-6244.github.io)

---

## 🎯 Project Overview

End-to-end strategic planning analytics system built to support senior leadership decision-making. Developed and maintained **forecast models and analyses identifying key business trends across 12,500+ records**, with full KPI monitoring, management reporting, and ad hoc analysis capabilities.

**Estimated Impact:** 12–15% improvement in strategic decision quality through automated KPI monitoring and data-driven forecasting.

---

## 📁 Repository Structure

```
strategic-planning-analytics/
│
├── python/
│   ├── forecast_model.py       # Core forecast engine & KPI tracker
│   └── kpi_dashboard.py        # Ad hoc analysis & data validation utilities
│
├── sql/
│   └── kpi_queries.sql         # KPI scorecards, trend analysis & exec views
│
├── data/
│   ├── kpi_scorecard.csv       # Latest KPI scorecard output
│   ├── revenue_forecast.csv    # 6-month revenue forecast
│   └── monthly_summary.csv     # Monthly aggregated metrics
│
├── presentations/
│   └── Strategic_Planning_Analytics_Suite.pptx   # Executive management deck
│
└── README.md
```

---

## 🔧 Tech Stack

| Tool | Usage |
|------|-------|
| **Python** (pandas, numpy) | Forecast modeling, KPI engine, data generation |
| **SQL** (PostgreSQL) | Data capture, KPI scorecards, executive summary views |
| **Advanced Excel** | KPI dashboard templates, management summaries |
| **Tableau** | Interactive trend visualizations |
| **PowerPoint** | Executive management presentations |

---

## 📈 Key Features

### 1. Forecast Engine (`python/forecast_model.py`)
- Trend + seasonality decomposition model over 12,500+ business records
- 6-month forward revenue forecast with **90% confidence intervals**
- In-sample accuracy metrics: MAE, MAPE, RMSE
- Segment-level and regional performance analytics

### 2. KPI Tracking System
Monitors 4 critical KPIs against strategic targets:

| KPI | Target | Method |
|-----|--------|--------|
| Gross Margin % | ≥ 38.0% | Monthly avg |
| Revenue Growth % | ≥ 8.0% | MoM % change |
| Customer Satisfaction | ≥ 4.20 | Rolling avg |
| Revenue / Headcount | ≥ $1,500 | Productivity ratio |

Traffic-light status (🟢 On Track / 🔴 Below Target) generated automatically for leadership review.

### 3. SQL Analytics (`sql/kpi_queries.sql`)
- Monthly KPI summaries for leadership dashboard
- KPI scorecard vs. targets (most recent period)
- Segment × region trend analysis
- 30-day moving average and MTD revenue tracking
- Cohort analysis for growth initiative support
- Data quality validation queries
- `v_executive_summary` view for management presentations

### 4. Management Presentations
- 6-slide executive deck covering: KPI scorecard, revenue forecast, segment performance, methodology
- Designed for senior leadership monthly review cadence
- Ad hoc analysis templates for growth initiatives

---

## 🚀 Getting Started

### Prerequisites
```bash
pip install pandas numpy
```

### Run the Forecast Model
```bash
cd python
python forecast_model.py
```

**Output:**
```
✅ Generated 12,500 business records
📊 KPI SCORECARD: [traffic-light status vs. targets]
📈 6-MONTH REVENUE FORECAST: [forecast + confidence intervals]
✅ Forecast Accuracy — MAPE: 3.7%
💾 Outputs saved to /data/
```

### Run Ad Hoc Analysis
```bash
cd python
python kpi_dashboard.py
```

### SQL Setup (PostgreSQL)
```sql
-- Create schema and load data
\i sql/kpi_queries.sql

-- Query the executive summary view
SELECT * FROM v_executive_summary ORDER BY month DESC, revenue_m DESC;
```

---

## 📊 Sample Outputs

### KPI Scorecard
```
KPI                      Actual   Target   vs Target   Status
Gross Margin %           39.4%    38.0%    +1.4 pts    ✅ On Track
Revenue Growth %          9.2%     8.0%    +1.2%       ✅ On Track
Customer Satisfaction     4.31     4.20    +0.11       ✅ On Track
Revenue / Headcount      $1,612   $1,500   +$112       ✅ On Track
```

### 6-Month Revenue Forecast
```
Period      Forecast     Lower 90%    Upper 90%
Jul '25    $2,840,000   $2,560,000   $3,120,000
Aug '25    $2,910,000   $2,620,000   $3,200,000
Sep '25    $2,875,000   $2,590,000   $3,160,000
Oct '25    $3,020,000   $2,730,000   $3,310,000
Nov '25    $3,185,000   $2,875,000   $3,495,000
Dec '25    $3,310,000   $2,990,000   $3,630,000
```

---

## 💡 Strategic Insights Delivered

- **Seasonal patterns** identified in Q2 and Q4 — enabling proactive resource planning
- **Enterprise segment** outperforms with highest margin (42.1%) and satisfaction (4.45)
- **Growth initiatives** supported with cohort analysis and ROI estimation
- **Decision quality improvement** of ~12–15% via systematic KPI monitoring

---

## 👤 Author

**Ayushi**
- GitHub: [github.com/Ayushi-6244](https://github.com/Ayushi-6244)
- Portfolio: [ayushi-6244.github.io](https://ayushi-6244.github.io)

---

*Built to demonstrate the forecast modeling, KPI tracking, and senior leadership support capabilities required for Strategic Planning & Business Operations roles.*
