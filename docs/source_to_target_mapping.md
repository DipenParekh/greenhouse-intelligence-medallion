# Source-to-Target Mapping

## Public Statistics Canada domain

| Source | Silver / Gold target | Rule |
|---|---|---|
| `REF_DATE` | `year` | Cast to integer |
| `GEO` | `geography` | Preserve source geography |
| `Commodity` | `commodity` | Preserve source commodity label |
| `Production and value` | Measurement classification | Used to identify production/value/area/price measures |
| `Estimates` | Measurement subtype | Preserved for measurement interpretation |
| `UOM` | Unit logic | Used for unit standardization |
| `VALUE` | Numeric measure | Cast to double; null remains null |
| `STATUS` | `measurement_quality` / Gold quality | Map status to explicit quality classification |
| source file path | `source_file` | Added during Bronze ingestion |
| ingestion time | `ingestion_timestamp` | Added during Bronze ingestion |

### Status mapping

| `STATUS` | Target quality |
|---|---|
| blank | AVAILABLE |
| `E` | USE_WITH_CAUTION |
| `x` | CONFIDENTIAL |
| `..` | NOT_AVAILABLE |
| `F` | UNRELIABLE |

## Synthetic operational domain

| Source | Target | Rule |
|---|---|---|
| Product records | `products_clean` | Standardize product reference data |
| Shipment records | `shipments_clean` / `shipments_quarantine` | Validate IDs, duplicates, and quantities |
| Receipt records | `receipts_clean` / `receipts_quarantine` | Validate IDs, duplicates, quantities, and shipment references |
| Valid shipments + valid receipts | `fact_shipment_reconciliation` | Left reconcile receipts to shipment grain |
| Reconciliation fact | `vw_reconciliation_kpis` | Aggregate operational KPIs |
| Silver validation counts | `vw_operational_data_quality` | Summarize accepted/rejected records |
