"""
KPI Dashboard & Ad Hoc Analysis Utilities
Strategic Planning Analytics Suite
Author: Ayushi | github.com/Ayushi-6244
"""

import pandas as pd
import numpy as np


# ─────────────────────────────────────────────
# AD HOC ANALYSIS FUNCTIONS
# ─────────────────────────────────────────────

def revenue_by_category(df: pd.DataFrame) -> pd.DataFrame:
    """Revenue breakdown by product/service category."""
    return (
        df.groupby("category")
        .agg(
            total_revenue  = ("revenue",      "sum"),
            avg_margin     = ("gross_margin", "mean"),
            total_units    = ("units_sold",   "sum"),
            record_count   = ("record_id",    "count"),
        )
        .round(2)
        .reset_index()
        .sort_values("total_revenue", ascending=False)
    )


def yoy_growth_analysis(df: pd.DataFrame) -> pd.DataFrame:
    """Year-over-year revenue and margin growth analysis."""
    df = df.copy()
    df["year"] = df["date"].dt.year

    annual = df.groupby("year").agg(
        total_revenue = ("revenue",      "sum"),
        avg_margin    = ("gross_margin", "mean"),
        total_units   = ("units_sold",   "sum"),
    ).reset_index()

    annual["revenue_yoy_pct"] = annual["total_revenue"].pct_change() * 100
    annual["margin_yoy_pts"]  = annual["avg_margin"].diff()

    return annual.round(2)


def top_performers(df: pd.DataFrame, n: int = 10) -> pd.DataFrame:
    """Identify top N records by revenue for leadership review."""
    return (
        df.nlargest(n, "revenue")
        [["record_id", "date", "region", "segment", "category",
          "revenue", "gross_margin", "customer_sat"]]
        .reset_index(drop=True)
    )


def growth_initiative_roi(df: pd.DataFrame) -> pd.DataFrame:
    """Estimate ROI metrics for growth initiatives by segment."""
    base = df.groupby("segment").agg(
        avg_revenue = ("revenue",      "mean"),
        avg_cost    = ("cost",         "mean"),
        avg_margin  = ("gross_margin", "mean"),
    ).reset_index()

    # Simulate 12–15% decision quality improvement impact
    base["improved_revenue_low"]  = base["avg_revenue"] * 1.12
    base["improved_revenue_high"] = base["avg_revenue"] * 1.15
    base["estimated_gain_low"]    = base["improved_revenue_low"]  - base["avg_revenue"]
    base["estimated_gain_high"]   = base["improved_revenue_high"] - base["avg_revenue"]

    return base.round(2)


def monthly_kpi_trend(df: pd.DataFrame) -> pd.DataFrame:
    """Monthly KPI trends for senior leadership dashboard."""
    df = df.copy()
    df["year_month"] = df["date"].dt.to_period("M")

    monthly = df.groupby("year_month").agg(
        revenue       = ("revenue",        "sum"),
        gross_profit  = ("gross_profit",   "sum"),
        margin_pct    = ("gross_margin",   "mean"),
        units         = ("units_sold",     "sum"),
        customer_sat  = ("customer_sat",   "mean"),
        rev_per_hc    = ("revenue_per_hc", "mean"),
    ).reset_index()

    monthly["revenue_mom_pct"] = (monthly["revenue"].pct_change() * 100).round(2)

    # Traffic-light status
    def status(row):
        if row["margin_pct"] >= 38 and row["customer_sat"] >= 4.2:
            return "🟢 Strong"
        elif row["margin_pct"] >= 33:
            return "🟡 Moderate"
        else:
            return "🔴 Attention"

    monthly["health_status"] = monthly.apply(status, axis=1)
    return monthly


# ─────────────────────────────────────────────
# DATA CAPTURE & VALIDATION
# ─────────────────────────────────────────────

def validate_and_capture(df: pd.DataFrame) -> dict:
    """Validate data quality and capture key statistics for KPI tracking."""
    total      = len(df)
    null_pct   = (df.isnull().sum() / total * 100).round(2)
    dupes      = df.duplicated().sum()

    numeric_cols = df.select_dtypes(include=[np.number]).columns
    stats = df[numeric_cols].describe().round(2)

    issues = []
    if dupes > 0:
        issues.append(f"⚠️  {dupes} duplicate rows detected")
    for col, pct in null_pct.items():
        if pct > 0:
            issues.append(f"⚠️  {col}: {pct}% null values")
    if not issues:
        issues.append("✅ No data quality issues found")

    return {
        "total_records":  total,
        "null_summary":   null_pct.to_dict(),
        "duplicate_rows": dupes,
        "summary_stats":  stats,
        "issues":         issues,
    }


# ─────────────────────────────────────────────
# MAIN — DEMO
# ─────────────────────────────────────────────

if __name__ == "__main__":
    from forecast_model import generate_business_data

    df = generate_business_data(12_500)

    print("📦 DATA VALIDATION:")
    report = validate_and_capture(df)
    print(f"  Total Records  : {report['total_records']:,}")
    print(f"  Duplicate Rows : {report['duplicate_rows']}")
    for issue in report["issues"]:
        print(f"  {issue}")

    print("\n📊 REVENUE BY CATEGORY:")
    print(revenue_by_category(df).to_string(index=False))

    print("\n📈 YEAR-OVER-YEAR GROWTH:")
    print(yoy_growth_analysis(df).to_string(index=False))

    print("\n🏆 TOP 5 PERFORMERS:")
    print(top_performers(df, n=5).to_string(index=False))

    print("\n💹 GROWTH INITIATIVE ROI ESTIMATES:")
    print(growth_initiative_roi(df).to_string(index=False))
