# Data Dictionary

## Public Gold analytics

### `fact_production_mass`

| Column | Description |
|---|---|
| `year` | Reporting year |
| `geography` | Canada or province |
| `commodity` | Statistics Canada commodity label |
| `production_kg` | Standardized mass production in kilograms |
| `production_quality` | AVAILABLE / USE_WITH_CAUTION / CONFIDENTIAL / NOT_AVAILABLE / UNRELIABLE |
| `source_unit` | Unit selected for the standardized production value |
| `reported_kg` | Original reported kilograms when present |
| `reported_lb` | Original reported pounds when present |
| `kg_quality` | Quality classification for kg observation |
| `lb_quality` | Quality classification for lb observation |
| `is_canada_total` | Boolean flag identifying Canada-level observations |

### `fact_farm_gate_value`

Business grain: Year + Geography + Commodity.

Stores farm-gate value in Canadian dollars while preserving missing/suppressed observations and quality metadata.

### `fact_harvested_area`

Stores standardized harvested area in square metres using the rule: prefer reported m², otherwise convert ft².

### `fact_average_price_mass`

Stores standardized average price in CAD/kg using the rule: prefer CAD/kg, otherwise convert CAD/lb.

### `vw_greenhouse_analytics`

Reporting view joining production with farm-gate value, harvested area, and average price at production grain.

### `vw_production_yoy`

Adds previous-year production context and quality-aware approved YoY growth.

---

## Synthetic operational Gold model

### `fact_shipment_reconciliation`

| Column | Description |
|---|---|
| `shipment_id` | Synthetic shipment identifier |
| `product_id` | Synthetic product identifier |
| `product_name` | Product name |
| `shipment_date` | Shipment date |
| `shipped_kg` | Shipped quantity in kilograms |
| `receipt_id` | Matching receipt identifier when present |
| `receipt_date` | Receipt date when present |
| `received_kg` | Received quantity in kilograms |
| `reconciliation_status` | MATCHED / PENDING_RECEIPT / QUANTITY_DISCREPANCY |
| `quantity_difference_kg` | Shipment minus receipt quantity |
| `shortfall_kg` | Positive operational shortfall in kilograms |

### `vw_reconciliation_kpis`

Contains total shipments, matched shipments, pending receipts, quantity discrepancies, and total shortfall.

### `vw_operational_data_quality`

Summarizes Bronze, accepted, and rejected record counts for shipments and receipts.
