# Business Rules

## Public Statistics Canada analytics

1. The public source is Statistics Canada table 32-10-0456-01, Production and Value of Greenhouse Fruits and Vegetables.
2. Statistics Canada quality/status flags are preserved throughout the pipeline.
3. Missing, confidential, unavailable, or unreliable measurements are never replaced with zero.
4. Canada-level observations remain distinct from provincial observations to prevent double counting.
5. Mass production is standardized to kilograms:
   - Prefer reported kilograms when present.
   - Otherwise convert pounds using `kg = lb × 0.45359237`.
   - Never sum reported kilograms and pounds for the same business grain.
6. Harvested area is standardized to square metres:
   - Prefer reported square metres.
   - Otherwise convert square feet using `m² = ft² × 0.09290304`.
7. Average mass price is standardized to CAD/kg:
   - Prefer reported CAD/kg.
   - Otherwise convert CAD/lb using `CAD/kg = CAD/lb × 2.20462262`.
8. Count-based units such as dozens and heads remain separate from mass-based units.
9. Approved YoY production growth is returned only when:
   - the previous observation is exactly the prior calendar year;
   - previous production is greater than zero; and
   - current and previous quality are both `AVAILABLE`.

## Synthetic operational reconciliation

1. Shipment and receipt data is synthetic and is used only to demonstrate operational data quality and reconciliation.
2. Invalid records are quarantined in Silver instead of being silently discarded.
3. Shipment validation includes missing IDs, invalid or negative quantities, and duplicate shipment IDs.
4. Receipt validation includes missing IDs, invalid or negative quantities, duplicate receipt IDs, and orphan shipment references.
5. Gold reconciliation remains at shipment grain.
6. Reconciliation statuses:
   - `MATCHED`
   - `PENDING_RECEIPT`
   - `QUANTITY_DISCREPANCY`
7. Shortfall is measured in kilograms and is never mixed with public annual production totals.
