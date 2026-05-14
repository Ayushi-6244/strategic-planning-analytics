-- ============================================================
-- Strategic Planning Analytics Suite
-- SQL Data Capture & KPI Tracking Queries
-- Author: Ayushi | github.com/Ayushi-6244
-- ============================================================
 
 
-- ─────────────────────────────────────────────
-- SCHEMA: CORE TABLES
-- ─────────────────────────────────────────────
 
CREATE TABLE IF NOT EXISTS business_records (
    record_id       SERIAL PRIMARY KEY,
    record_date     DATE          NOT NULL,
    region          VARCHAR(20)   NOT NULL,
    segment         VARCHAR(20)   NOT NULL,   -- Enterprise, Mid-Market, SMB
    category        VARCHAR(30)   NOT NULL,
    revenue         NUMERIC(14,2) NOT NULL,
    cost            NUMERIC(14,2) NOT NULL,
    units_sold      INTEGER       NOT NULL DEFAULT 0,
    headcount       INTEGER       NOT NULL DEFAULT 1,
    customer_sat    NUMERIC(3,1),
    created_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);
 
CREATE TABLE IF NOT EXISTS kpi_targets (
    kpi_name        VARCHAR(60) PRIMARY KEY,
    target_value    NUMERIC(14,4) NOT NULL,
    unit            VARCHAR(20),
    effective_date  DATE NOT NULL DEFAULT CURRENT_DATE
);
 
-- Seed KPI targets
INSERT INTO kpi_targets (kpi_name, target_value, unit) VALUES
    ('gross_margin_pct',    38.0,    'percent'),
    ('revenue_growth_pct',   8.0,    'percent'),
    ('customer_sat_avg',     4.2,    'score'),
    ('revenue_per_headcount', 1500.0, 'USD')
ON CONFLICT (kpi_name) DO NOTHING;
 
 
-- ─────────────────────────────────────────────
-- KPI TRACKING QUERIES
-- ─────────────────────────────────────────────
 
-- 1. Monthly KPI Summary for Leadership Dashboard
-- ─────────────────────────────────────────────
SELECT
    DATE_TRUNC('month', record_date)          AS month,
    COUNT(*)                                  AS record_count,
    ROUND(SUM(revenue), 2)                    AS total_revenue,
    ROUND(SUM(cost), 2)                       AS total_cost,
    ROUND(SUM(revenue - cost), 2)             AS gross_profit,
    ROUND(AVG((revenue - cost) / NULLIF(revenue,0) * 100), 2) AS gross_margin_pct,
    ROUND(AVG(customer_sat), 2)               AS avg_customer_sat,
    ROUND(AVG(revenue / NULLIF(headcount,0)), 2) AS avg_revenue_per_hc
FROM business_records
GROUP BY DATE_TRUNC('month', record_date)
ORDER BY month;
 
 
-- 2. KPI Scorecard vs Targets (Most Recent Month)
-- ─────────────────────────────────────────────
WITH latest_month AS (
    SELECT
        AVG((revenue - cost) / NULLIF(revenue,0) * 100)  AS gross_margin_pct,
        AVG(customer_sat)                                  AS customer_sat_avg,
        AVG(revenue / NULLIF(headcount,0))                 AS revenue_per_hc
    FROM business_records
    WHERE DATE_TRUNC('month', record_date) = (
        SELECT MAX(DATE_TRUNC('month', record_date)) FROM business_records
    )
),
revenue_growth AS (
    SELECT
        (curr.total_rev - prev.total_rev) / NULLIF(prev.total_rev, 0) * 100 AS revenue_growth_pct
    FROM
        (SELECT SUM(revenue) AS total_rev FROM business_records
         WHERE DATE_TRUNC('month', record_date) = (
             SELECT MAX(DATE_TRUNC('month', record_date)) FROM business_records)) curr,
        (SELECT SUM(revenue) AS total_rev FROM business_records
         WHERE DATE_TRUNC('month', record_date) = (
             SELECT MAX(DATE_TRUNC('month', record_date)) - INTERVAL '1 month'
             FROM business_records)) prev
)
SELECT
    t.kpi_name,
    t.target_value,
    t.unit,
    CASE t.kpi_name
        WHEN 'gross_margin_pct'      THEN ROUND(lm.gross_margin_pct::NUMERIC, 2)
        WHEN 'customer_sat_avg'      THEN ROUND(lm.customer_sat_avg::NUMERIC, 2)
        WHEN 'revenue_per_headcount' THEN ROUND(lm.revenue_per_hc::NUMERIC, 2)
        WHEN 'revenue_growth_pct'    THEN ROUND(rg.revenue_growth_pct::NUMERIC, 2)
    END                                                        AS actual_value,
    CASE
        WHEN CASE t.kpi_name
            WHEN 'gross_margin_pct'      THEN lm.gross_margin_pct
            WHEN 'customer_sat_avg'      THEN lm.customer_sat_avg
            WHEN 'revenue_per_headcount' THEN lm.revenue_per_hc
            WHEN 'revenue_growth_pct'    THEN rg.revenue_growth_pct
        END >= t.target_value THEN 'On Track'
        ELSE 'Below Target'
    END                                                        AS status
FROM kpi_targets t
CROSS JOIN latest_month lm
CROSS JOIN revenue_growth rg
ORDER BY t.kpi_name;
 
 
-- 3. Business Trend Analysis (12,000+ Records)
-- ─────────────────────────────────────────────
SELECT
    segment,
    region,
    DATE_TRUNC('quarter', record_date)          AS quarter,
    COUNT(*)                                    AS records,
    ROUND(SUM(revenue), 0)                      AS total_revenue,
    ROUND(AVG((revenue-cost)/NULLIF(revenue,0)*100), 1) AS margin_pct,
    ROUND(AVG(customer_sat), 2)                 AS avg_sat,
    SUM(units_sold)                             AS total_units
FROM business_records
GROUP BY segment, region, DATE_TRUNC('quarter', record_date)
ORDER BY quarter, total_revenue DESC;
 
 
-- 4. Ad Hoc: Revenue Trend with Moving Average
-- ─────────────────────────────────────────────
SELECT
    record_date,
    region,
    revenue,
    ROUND(AVG(revenue) OVER (
        PARTITION BY region
        ORDER BY record_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2)  AS revenue_30d_ma,
    ROUND(SUM(revenue) OVER (
        PARTITION BY region, DATE_TRUNC('month', record_date)
    ), 2)  AS revenue_mtd
FROM business_records
ORDER BY region, record_date;
 
 
-- 5. Growth Initiative Support: Cohort Analysis
-- ─────────────────────────────────────────────
WITH cohort_base AS (
    SELECT
        segment,
        DATE_TRUNC('quarter', record_date) AS cohort_quarter,
        SUM(revenue)                       AS cohort_revenue,
        AVG(gross_margin_pct)              AS cohort_margin
    FROM (
        SELECT *,
            (revenue - cost) / NULLIF(revenue,0) * 100 AS gross_margin_pct
        FROM business_records
    ) t
    GROUP BY segment, DATE_TRUNC('quarter', record_date)
),
ranked AS (
    SELECT *,
        LAG(cohort_revenue) OVER (PARTITION BY segment ORDER BY cohort_quarter) AS prev_revenue,
        ROW_NUMBER() OVER (PARTITION BY segment ORDER BY cohort_quarter)        AS cohort_num
    FROM cohort_base
)
SELECT
    segment,
    cohort_quarter,
    cohort_num,
    ROUND(cohort_revenue, 0)                                            AS revenue,
    ROUND(cohort_margin, 2)                                             AS margin_pct,
    ROUND((cohort_revenue - prev_revenue) / NULLIF(prev_revenue,0) * 100, 1) AS qoq_growth_pct
FROM ranked
ORDER BY segment, cohort_quarter;
 
 
-- 6. Data Capture: Validate Record Completeness
-- ─────────────────────────────────────────────
SELECT
    COUNT(*)                                   AS total_records,
    COUNT(*) FILTER (WHERE revenue IS NULL)    AS null_revenue,
    COUNT(*) FILTER (WHERE cost IS NULL)       AS null_cost,
    COUNT(*) FILTER (WHERE customer_sat IS NULL) AS null_sat,
    COUNT(*) FILTER (WHERE headcount <= 0)     AS invalid_headcount,
    MIN(record_date)                           AS earliest_date,
    MAX(record_date)                           AS latest_date,
    COUNT(DISTINCT region)                     AS distinct_regions,
    COUNT(DISTINCT segment)                    AS distinct_segments
FROM business_records;
 
 
-- 7. Executive Summary View (used in management presentations)
-- ─────────────────────────────────────────────
CREATE OR REPLACE VIEW v_executive_summary AS
SELECT
    DATE_TRUNC('month', record_date)                                AS month,
    segment,
    ROUND(SUM(revenue) / 1e6, 2)                                   AS revenue_m,
    ROUND(SUM(revenue - cost) / 1e6, 2)                            AS gross_profit_m,
    ROUND(AVG((revenue-cost)/NULLIF(revenue,0)*100), 1)            AS margin_pct,
    ROUND(AVG(customer_sat), 2)                                     AS avg_sat,
    SUM(units_sold)                                                 AS units,
    ROUND(AVG(revenue/NULLIF(headcount,0)), 0)                      AS rev_per_hc
FROM business_records
GROUP BY DATE_TRUNC('month', record_date), segment
ORDER BY month DESC, segment;
 
