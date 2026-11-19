# Setup and safe review

## This is an incomplete learning repository

A fresh clone cannot run the full ETL: Bronze table definitions and all source CSVs are absent. Two scripts create or alter `silver.load_silver` with incompatible load strategies. Resolve those gaps before attempting a load. Do not point this project at a production database.

The source uses SQL Server/T-SQL and `GO` batch separators. Features such as `TRIM`, `CREATE OR ALTER`, `TRY_CAST` and `LEAD` need a compatible SQL Server environment and a client that understands batches. No database engine/version has been execution-validated for this refresh.

## Existing scripts: read these warnings first

| Original file | Risk or missing prerequisite |
| --- | --- |
| `scripts/init_database.sql` | Forces SINGLE_USER, rolls back connections and drops `DataWarehouse` if it exists. All its data is lost. |
| `scripts/bronze/ddl_data_defination_lang_bronze` | Defines a loader, not table DDL. Truncates all six tables, bulk-loads fixed local CSV paths and calls the loader at the end. Bronze tables are missing. |
| `scripts/Silver layer/ddl_silver` | Drops/recreates six Silver tables, then defines a direct-CSV `silver.load_silver`. Source CSV schemas are not supplied. |
| `scripts/Silver layer/Stored Procedure` | Starts with `exec silver.load_silver`, before replacing that procedure with Bronze-to-Silver transformations. Running the entire file can execute whichever previous definition is installed. |

The legacy scripts are preserved byte-for-byte. Their presence is not a recommendation to execute them unchanged.

## Non-destructive schema bootstrap

`scripts/bootstrap_schemas.sql` is a separate option for an empty development environment. It creates `DataWarehouse` only when missing, then creates missing Bronze/Silver/Gold schemas. It never drops, truncates, loads or resets an existing object. Review its database name first. Creating the Gold schema does not implement a Gold model.

This file has static safety checks only, not SQL Server execution evidence. Creating a database still changes the selected SQL Server instance and requires suitable permissions. The repository update has not run it anywhere.

## Work needed for a real test load

1. Create or select a disposable development instance/database. Verify the target in the client before executing any script.
2. Obtain appropriately licensed or fully synthetic CSV inputs. No personal/customer/work data is needed for a test.
3. Define and review all six Bronze tables against those exact CSV columns, data types, encoding and header conventions.
4. Replace machine-specific file paths in a local working copy. For server-side `BULK INSERT`, verify that the database service can read the chosen location. A file on the SQL client's computer is not automatically visible to the server.
5. Separate definition scripts from execution scripts. Choose one Silver transformation path and remove ambiguity in the local test plan. Do not invoke a loader while defining it.
6. Add fail-fast error handling, a rollback/staging strategy and row-count reconciliation before full refresh. The current truncate/load drafts do not provide an atomic pipeline.
7. Test malformed dates, duplicate/null keys, zero quantities, negative amounts, mismatched references and partial file failures using invented fixtures.
8. After loading, review `scripts/quality_checks.sql` and the quality checklist. Treat returned rows as issues to investigate, not automatic correction instructions.
9. Record the actual engine version, inputs, row counts, test results and remaining failures. Only then describe a specific path as verified runnable.

## Local static checks

```sh
python3 tests/check_repository.py
```

Python standard library only. These checks preserve the original script hashes, confirm the documented inventory, check bootstrap safety and reject write statements in the read-only quality-query file. They are not an integration suite.

## Privacy and history

Keep connection strings, server names, credentials, personal/customer CSVs and database backups out of git. Use local private configuration if a runnable loader is added later. No datasets or private work information were added during this refresh. Existing history, placeholders, script names and license are retained.
