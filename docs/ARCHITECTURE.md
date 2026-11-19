# Architecture and source contracts

## Intended flow versus code today

```text
CRM / ERP CSVs           Bronze                    Silver                 Gold / reporting
(not supplied)   -->     raw tables        -->     typed/cleaned tables --> not implemented
                         DDL missing                draft code present
```

The original architecture aims to integrate CRM and ERP sales-related data. The checked-in code is an early learning implementation, not a deployed data platform. No orchestration, incremental load, historization framework, lineage service or business-report output is supplied.

## Source inventory

| Source | Expected filename in legacy loader | Target |
| --- | --- | --- |
| CRM | `cust_info.csv` | `crm_cust_info` |
| CRM | `prd_info.csv` | `crm_prd_info` |
| CRM | `sales_details.csv` | `crm_sales_details` |
| ERP | `CUST_AZ12.csv` | `erp_CUST_AZ12` |
| ERP | `LOC_A101.csv` | `erp_LOC_A101` |
| ERP | `PX_CAT_G1V2.csv` | `erp_PX_CAT_G1V2` |

Filenames come from code, not available data. The code skips the first CSV row and uses comma field terminators. Quoting, embedded commas, line endings, Unicode and column mappings have not been validated against actual input files. Do not infer a complete file contract from filenames alone.

## Current transformation behavior to review

- Customer rows use `ROW_NUMBER` by customer ID with creation date **ascending**, retaining the earliest row. If latest-record deduplication is intended, that requires a reviewed change. Ties are not deterministically resolved.
- Customer names are trimmed; short marital-status and gender codes are expanded, otherwise `n/a`.
- Product keys are split into category/product portions. Product end date is derived from the next start date. Nulls, ties, types and date arithmetic need execution tests.
- Sales date conversion only checks zero/length before casting. An eight-digit invalid calendar date can still fail conversion.
- Sales and price adjustments use integer columns. Division precision and inconsistent/negative/zero inputs need an explicit policy, not a guessed correction.
- ERP customer IDs can lose a prefix, location IDs lose hyphens, and some country names/codes are standardized. Reference consistency must be checked after those changes.
- Silver DDL adds a default load timestamp. That is not complete audit lineage or a history model.

## Two conflicting Silver definitions

`ddl_silver` defines a direct-CSV loader for Silver after dropping/recreating its tables. `Stored Procedure` defines a Bronze-to-Silver transformation using the same procedure name. The last definition installed wins. The second file also executes the existing procedure before redefining it.

This refresh does not silently choose one business meaning. The intended layered flow suggests Bronze-to-Silver, but completing it requires Bronze schemas, test inputs and a reviewed loading contract. The original drafts stay intact with clear warnings.

## Full-refresh failure boundary

Legacy loaders truncate targets before loading. Several catches print errors instead of throwing them back to a caller. There is no transaction covering the complete refresh or validation-based promotion. A partial load can therefore leave empty or mixed-state tables while the client sees printed messages rather than a reliable failure signal. Do not run these drafts against valuable data.

## Remaining stages

- Complete schema/input contracts and definition-only deployment scripts.
- One tested load path with fail-fast behavior and documented recovery.
- Source/target count and key reconciliations.
- Gold dimensional model and analytics, if desired.
- SQL Server-backed test automation with invented fixtures.

No results, performance improvement, business impact or completed Gold models are claimed.
