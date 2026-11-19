# Quality and acceptance checklist

## What is checked automatically

`python3 tests/check_repository.py` checks repository structure, original-script preservation and limited static safety boundaries. It does not open a database, validate T-SQL syntax against an engine or test ETL results.

`scripts/quality_checks.sql` contains read-only issue queries for the Silver tables after an independently reviewed test load. It does not repair records. Required tables must exist first. No runtime results are included in this repository.

## Data acceptance checklist

- Source file headers/order/types match reviewed Bronze definitions.
- Source counts reconcile with loaded counts, with rejected rows explained.
- Customer keys are non-null and unique under the chosen deduplication policy.
- Deduplication is deterministic when dates tie.
- Product keys and product date intervals support the intended join semantics. A historical product key may legitimately repeat across periods.
- Sales customer/product references resolve. Define whether missing references are rejected or represented as unknown members.
- All dates are valid calendar dates, not only eight characters long.
- Order/shipping/due-date relationships match a confirmed business rule.
- Quantities, sales and prices have agreed zero/negative/null policies and sufficient numeric precision.
- ERP key normalization does not collapse distinct entities unexpectedly.
- Text trimming and low-cardinality mappings preserve meaning.
- All six tables belong to the same successful refresh, or failures roll back/promote consistently.

## Operational acceptance checklist

- Explicit disposable test target, no production connection.
- Input redistribution rights checked; invented records preferred.
- No credentials, backups or private exports committed.
- Procedure definitions separated from execution.
- Errors reach the caller, not only printed output.
- Recovery after a missing/bad file is tested.
- Engine/client/version and actual test evidence recorded.

Until those checks pass, use descriptions such as draft or learning implementation, not production-ready ETL.
