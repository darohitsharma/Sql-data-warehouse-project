# SQL Data Warehouse Learning Project

A SQL Server learning project exploring a Bronze/Silver/Gold warehouse structure for CRM and ERP data. The checked-in implementation contains schema initialization, a Bronze bulk-load procedure and Silver transformation drafts. It is **not a complete runnable warehouse or reporting solution**.

[Setup and safe review](SETUP.md) | [Architecture and source contracts](docs/ARCHITECTURE.md) | [Quality checks](docs/QUALITY.md) | [Changes](CHANGELOG.md)

## Current implementation

| Area | Present | Limit |
| --- | --- | --- |
| Database schemas | Original reset script, plus a separate non-destructive bootstrap | Original reset script deletes an existing database |
| Bronze | Bulk-load procedure for six CRM/ERP CSV inputs | Source CSVs and Bronze table DDL are not included |
| Silver | Six table definitions and transformation draft | Two files redefine the same loader; do not run both blindly |
| Gold | Schema name only | No dimensional model, views or analytical queries |
| Reporting | Requirements in the original project brief | No report implementation or measured business results |
| Tests | Static repository checks and read-only quality-query draft | No SQL Server integration test or data-based validation |

## Start with review, not execution

1. Read [SETUP.md](SETUP.md). Use a disposable SQL Server development database only.
2. Review the original files before running anything. They contain `DROP DATABASE`, `DROP TABLE`, `TRUNCATE TABLE` and embedded procedure calls.
3. If all you need is empty schemas, review the new `scripts/bootstrap_schemas.sql`. It creates missing objects without dropping/resetting the database. It does not make the loaders complete.
4. Run the static checks with Python 3:

```sh
python3 tests/check_repository.py
```

The checks verify the documented inventory and safety boundaries. They do not connect to SQL Server, parse all T-SQL or prove ETL correctness.

## Repository map

```text
scripts/
  init_database.sql                     Original destructive database reset
  bootstrap_schemas.sql                 Separate non-destructive schema bootstrap
  bronze/ddl_data_defination_lang_bronze Original Bronze loader draft
  Silver layer/ddl_silver                Original Silver DDL plus direct-CSV loader
  Silver layer/Stored Procedure          Original Bronze-to-Silver transformation draft
  quality_checks.sql                    Read-only post-load checks, review first
  legacy-manifest.json                  Original script hashes for preservation checks
docs/
  ARCHITECTURE.md                        Actual layer contracts and unresolved decisions
  QUALITY.md                             Review checklist and validation limits
tests/
  check_repository.py                   Standard-library static checks
```

Original names and contents are retained to preserve the learning record. Files named `placeholders` are placeholders, not evidence of implemented features. No source datasets, credentials, database connection strings or private work exports are added.

## Concepts explored

- Full-refresh loading of CRM customer, product and sales data plus ERP customer/location/category data.
- Whitespace cleanup and standardization of short gender/marital-status codes.
- Customer deduplication with a window function, product category/key extraction and product date ranges.
- Handling missing/invalid dates, sales arithmetic and source-key alignment.

These are code topics, not claims of production readiness. Deduplication ordering, invalid calendar dates, integer arithmetic, error propagation and all-or-nothing refresh behavior still need review. See the architecture and quality notes.

## Planned, not implemented

Complete Bronze DDL and documented synthetic inputs, one unambiguous Silver load path, SQL Server integration tests, Gold models, reconciliation and analytical reporting. These stages require explicit design work and validation; the repository refresh does not fabricate them.

## License

The existing [MIT license](LICENSE) is retained. Data provenance and redistribution rights must be checked separately before adding any dataset.
