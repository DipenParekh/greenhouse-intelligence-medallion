-- Greenhouse Intelligence Medallion
-- Gold reporting views for Databricks SQL
-- Public Statistics Canada analytics and synthetic operational reconciliation
-- Generated for the portfolio repository.

USE CATALOG workspace;
USE SCHEMA greenhouse_gold;

-- ============================================================
-- 1. Year-over-Year Production View
-- ============================================================

CREATE OR REPLACE VIEW workspace.greenhouse_gold.vw_production_yoy AS
WITH production_with_previous AS (
    SELECT
        year,
        geography,
        commodity,
        production_kg,
        production_quality,
        source_unit,
        is_canada_total,

        LAG(year) OVER (
            PARTITION BY geography, commodity
            ORDER BY year
        ) AS previous_year,

        LAG(production_kg) OVER (
            PARTITION BY geography, commodity
            ORDER BY year
        ) AS previous_production_kg,

        LAG(production_quality) OVER (
            PARTITION BY geography, commodity
            ORDER BY year
        ) AS previous_production_quality

    FROM workspace.greenhouse_gold.fact_production_mass
)

SELECT
    year,
    geography,
    commodity,
    production_kg,
    production_quality,
    source_unit,
    is_canada_total,
    previous_year,
    previous_production_kg,
    previous_production_quality,

    CASE
        WHEN previous_year = year - 1
         AND previous_production_kg > 0
         AND production_quality = 'AVAILABLE'
         AND previous_production_quality = 'AVAILABLE'
        THEN ROUND(
            ((production_kg - previous_production_kg)
             / previous_production_kg) * 100,
            2
        )
        ELSE NULL
    END AS approved_yoy_growth_pct

FROM production_with_previous;


-- ============================================================
-- 2. Combined Greenhouse Analytics View
-- ============================================================

CREATE OR REPLACE VIEW workspace.greenhouse_gold.vw_greenhouse_analytics AS
SELECT
    p.year,
    p.geography,
    p.commodity,
    p.production_kg,
    p.production_quality,
    p.source_unit,
    p.is_canada_total,

    f.farm_gate_value_cad,
    a.harvested_area_m2,
    pr.average_price_cad_per_kg

FROM workspace.greenhouse_gold.fact_production_mass p

LEFT JOIN workspace.greenhouse_gold.fact_farm_gate_value f
    ON  p.year = f.year
    AND p.geography = f.geography
    AND p.commodity = f.commodity

LEFT JOIN workspace.greenhouse_gold.fact_harvested_area a
    ON  p.year = a.year
    AND p.geography = a.geography
    AND p.commodity = a.commodity

LEFT JOIN workspace.greenhouse_gold.fact_average_price_mass pr
    ON  p.year = pr.year
    AND p.geography = pr.geography
    AND p.commodity = pr.commodity;


-- ============================================================
-- 3. Shipment Reconciliation KPI View
-- Synthetic operational data only
-- ============================================================

CREATE OR REPLACE VIEW workspace.greenhouse_gold.vw_reconciliation_kpis AS
SELECT
    COUNT(*) AS total_shipments,

    SUM(
        CASE
            WHEN reconciliation_status = 'MATCHED'
            THEN 1 ELSE 0
        END
    ) AS matched_shipments,

    SUM(
        CASE
            WHEN reconciliation_status = 'PENDING_RECEIPT'
            THEN 1 ELSE 0
        END
    ) AS pending_receipts,

    SUM(
        CASE
            WHEN reconciliation_status = 'QUANTITY_DISCREPANCY'
            THEN 1 ELSE 0
        END
    ) AS quantity_discrepancies,

    SUM(COALESCE(shortfall_kg, 0)) AS total_shortfall_kg

FROM workspace.greenhouse_gold.fact_shipment_reconciliation;


-- ============================================================
-- 4. Operational Data Quality Summary View
-- Synthetic operational data only
-- ============================================================

CREATE OR REPLACE VIEW workspace.greenhouse_gold.vw_operational_data_quality AS

SELECT
    'Shipments' AS dataset,
    (SELECT COUNT(*) FROM workspace.greenhouse_bronze.raw_shipments) AS bronze_records,
    (SELECT COUNT(*) FROM workspace.greenhouse_silver.shipments_clean) AS accepted_records,
    (SELECT COUNT(*) FROM workspace.greenhouse_silver.shipments_quarantine) AS rejected_records

UNION ALL

SELECT
    'Receipts' AS dataset,
    (SELECT COUNT(*) FROM workspace.greenhouse_bronze.raw_receipts) AS bronze_records,
    (SELECT COUNT(*) FROM workspace.greenhouse_silver.receipts_clean) AS accepted_records,
    (SELECT COUNT(*) FROM workspace.greenhouse_silver.receipts_quarantine) AS rejected_records;


-- ============================================================
-- Expected validated outputs from the completed project
-- ============================================================
-- vw_greenhouse_analytics row count: 2,299
-- vw_reconciliation_kpis:
--   total_shipments          = 499
--   matched_shipments        = 452
--   pending_receipts         = 31
--   quantity_discrepancies   = 16
--   total_shortfall_kg       = 235
--
-- vw_operational_data_quality:
--   Shipments: 503 Bronze / 499 accepted / 4 rejected
--   Receipts:  473 Bronze / 468 accepted / 5 rejected
