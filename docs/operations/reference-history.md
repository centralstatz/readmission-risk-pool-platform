# Durable reference history operations

## Purpose

These operations create and inspect a local DuckDB database containing only
deterministic fictional, nonclinical operational history. They invoke the same
synthetic producer, canonical admission, runtime, provider, persistence port,
and adapter used by tests. They do not build products, rank episodes, create
tasks, launch an application, deploy, or process real patient data.

Restore the locked environment first:

```sh
Rscript -e 'renv::restore()'
```

Run commands from the repository root.

## Generate and persist

Ordinary operators should use the stable one-run entry point:

```sh
Rscript operations/run-platform.R --scale test
```

The lower-level deterministic history command remains supported for debugging
and idempotency evidence.

Use the default ignored database at
`build/reference-operational-history.duckdb`:

```sh
Rscript operations/run-reference-history.R --scale test
```

Or choose a path explicitly:

```sh
Rscript operations/run-reference-history.R \
  --scale test \
  --database build/my-fictional-history.duckdb
```

Inputs are `test` or `reference` scale and an optional DuckDB file path.
The operation generates and admits the synthetic canonical bundle, constructs
state and requests, initializes or validates the database, appends `started`,
executes the exactly selected transparent provider, appends the atomic terminal
batch, closes, reopens read-only, and reports durable family counts.

The default test identity is
`runtime_synthetic_history_test_001`. Identity and semantic timestamps are
deterministic, so repeating the exact command against the same database is an
idempotent no-op and returns the same counts. A changed record under that ID is
a conflict; do not delete or overwrite history to make it pass. A future
intentional computation must use a new operation-owned run identity.

Side effects are the selected `.duckdb` file and a transient DuckDB WAL if the
process is active or interrupted. Paths under `build/` are ignored. Never
commit a database or WAL.

## Inspect through the port

Inspect the default test run with:

```sh
Rscript operations/inspect-reference-history.R --scale test
```

The explicit form selects a database and run identity:

```sh
Rscript operations/inspect-reference-history.R \
  --database build/reference-operational-history.duckdb \
  --run-id runtime_synthetic_history_test_001 \
  --view valid
```

Choose `--view raw` to retain invalidated facts in the counts. The operation
opens read-only and reports lifecycle plus family counts through the logical
port. It does not expose or mutate a DBI connection.

For exceptional debugging, a maintainer may open the closed database with the
DuckDB client or R DBI in read-only mode and inspect the documented physical
tables. Direct SQL is not a supported application or automation interface and
must never be used to rewrite operational history.

For example, with the platform writer stopped:

```sh
Rscript -e 'con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "build/reference-operational-history.duckdb", read_only = TRUE); print(DBI::dbGetQuery(con, "SELECT runtime_run_id, status_sequence, run_status FROM operational_run_statuses ORDER BY runtime_run_id, status_sequence")); DBI::dbDisconnect(con, shutdown = TRUE)'
```

This implementation-specific diagnostic is deliberately not used by the app,
the durable operation, or conformance tests of the logical port.

## Back up

Stop the platform writer, then create a new backup path:

```sh
Rscript operations/backup-reference-history.R \
  --database build/reference-operational-history.duckdb \
  --backup build/backups/reference-operational-history-001.duckdb
```

The registry's exact default backup command is:

```sh
Rscript operations/backup-reference-history.R --database build/reference-operational-history.duckdb --backup build/backups/reference-operational-history-001.duckdb
```

The operation validates and checkpoints the source, closes it, refuses an
existing destination, copies the database, and validates the copy read-only.
It does not overwrite backups. Operators own backup frequency, retention,
permissions, encryption, off-host storage, and restore testing.

To restore, stop the writer, preserve the suspect file for diagnosis, copy a
known validated backup into a new selected database path, and run inspection.
Do not combine files, copy an active WAL alone, or replace a live database.

## Validation

Run the focused suite and full repository checks:

```sh
Rscript tests/run-phase5-tests.R
Rscript operations/validate.R --mode development
Rscript operations/validate.R --mode checkpoint
```

The focused suite uses temporary databases and removes them. Repository
validation must leave no tracked or untracked DuckDB database.

## Troubleshooting and recovery

- **Package unavailable:** restore `renv.lock`; do not add DBI/DuckDB to
  `rrpruntime` or source a global workaround.
- **Existing path is not initialized:** select a new empty path or a validated
  backup. Initialization deliberately refuses unrelated files.
- **Adapter/schema incompatible:** retain the file and use code compatible with
  its recorded versions. No migration exists yet.
- **Identity conflict:** the same identity has different logical content.
  Preserve the accepted row, investigate inputs/code, and use a new run only
  for a genuinely new computation.
- **Only `started` is visible:** the prior run did not commit a terminal batch.
  It is safely incomplete and supplies no current estimate. Investigate before
  deliberately using a new run identity.
- **Database locked:** stop the other writer. Multiple independent write
  processes are unsupported; use read-only inspection only after writer
  coordination.
- **Backup destination exists:** select a new path. The helper never overwrites.
- **Ambiguous current estimate:** two candidates tie on as-of and terminal time.
  Correct the upstream identity/semantic issue; storage order is not authority.
