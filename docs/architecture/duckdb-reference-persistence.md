# DuckDB reference persistence

## Purpose and maturity

Iteration 5.2 realizes `platform.persistence-adapter@0.1.0` with
`reference.duckdb-persistence@0.1.0`. It is the repository-owned durable local
reference implementation, not a production database requirement. The logical
contract remains authoritative and contains no DuckDB, SQL, table, connection,
or file-path assumption.

DuckDB is the shipped reference persistence implementation. The persistence
contract is the platform architecture.

The adapter proves one fictional source-to-canonical-to-runtime-to-provider
run can become durable operational history. It does not provide products,
decision policy, tasks, an application, deployment, replay, general
observability, clinical validation, or production readiness.

## Technology evaluation

DuckDB was selected because its R client implements DBI, persistent databases
are single files, and ACID transactions can make one completed-run batch
visible all-or-none. It supports the required append, exact identity lookup,
deterministic query inputs, close/reopen evidence, and explicit checkpointing
without a service dependency.

The tradeoff is intentional. Native DuckDB supports one read-write process for
a database file; multiple processes may open it read-only. It is not the
reference choice for independently coordinated concurrent writers. The
supported posture is one controlled platform writer process per health-system
database, local storage rather than a network filesystem, explicit session
close, and separate read-only inspection after the writer closes. A substitute
adapter must satisfy the same logical conformance tests but may choose a client-
server store and a different concurrency model.

## Ownership and identity

Concrete code and configuration live under
`implementations/persistence/duckdb/`. Repository operations compose it with
`rrpruntime`; the package does not import DBI or DuckDB and never discovers a
database path. The adapter declaration owns:

- adapter `reference.duckdb-persistence@0.1.0`;
- physical schema `0.1.0`;
- payload encoding `r-serialize-v3-hex@0.1.0`; and
- exact conformance to `platform.persistence-adapter@0.1.0`.

An initialized database records all four values. Open fails if metadata or a
required table is absent or incompatible. No automatic migration exists in
this iteration.

## Physical representation

The database contains adapter metadata and six append-only record-family
tables:

| Logical family | Physical table |
|---|---|
| Operational run status | `operational_run_statuses` |
| Episode state | `episode_states` |
| Estimand request | `estimand_requests` |
| Provider execution result | `provider_execution_results` |
| Accepted estimate | `estimates` |
| History invalidation | `history_invalidations` |

Each table exposes stable identity, relationship, status, and time columns for
inspection and indexed lookup. The complete logical R record is serialized
with base R serialization version 3 and stored as lowercase hexadecimal text.
This semi-structured design avoids flattening nested episode state and losing
R types, names, `NULL`, class, or attributes. Reads decode the full record, so
logical round-trip is exact and semantic `identical()` comparison remains the
conflict authority.

The cost is language and representation portability: another language cannot
interpret the payload without implementing the encoding, and hex doubles raw
payload size. Those are acceptable for this small R reference adapter. The
query columns and versioned encoding make the tradeoff explicit; a production
adapter may normalize or use a portable document encoding without changing
the port.

The full canonical bundle is not stored. The retained episode state and run
context preserve the admitted bundle, canonical run, implementation, mapping,
and provenance references selected by the operational-history foundation.

## Writes, retries, and atomicity

Initialization is explicit. A missing database is created transactionally; an
existing compatible database is validated and left unchanged. An unrelated,
partial, or incompatible file fails. Initialization never drops or truncates
tables and there is no destructive reinitialize option.

Every append checks the existing record under the same family identity:

- identical logical content is an idempotent no-op;
- different content is a conflict before mutation; and
- original rows are never updated or deleted.

A `started` or `failed` status is its own transaction. For a completed run,
the adapter preflights the terminal status and every state, request, execution,
and estimate, then inserts all five stages in one transaction. Injected-failure
tests after each stage prove rollback survives close/reopen with only the
previously committed `started` fact visible.

## Reads and invalidation

Raw reads return retained facts, including invalidated records and invalidation
evidence. Valid reads calculate the complete run/state/request/execution/
estimate invalidation closure; callers never reconstruct it themselves.

Run lifecycle records sort by sequence, status time, and identity. Estimate
history sorts by estimate as-of time, terminal run time, and estimate identity.
Current reads use greatest valid as-of time followed by greatest terminal time.
The identity tie-breaker makes history presentation deterministic but does not
invent current semantics: if more than one candidate remains tied after the
two semantic keys, the current read fails as ambiguous.

## Connection, recovery, and backup posture

The adapter owns open and close. Normal callers receive a validated persistence
port, the resolved path, and a close operation—not a raw DBI connection. After
an ordinary process interruption, reopen validates metadata and tables before
any read or write. DuckDB recovery handles committed database/WAL state; a run
left only at `started` remains incomplete and cannot become a current estimate.

The supported backup helper requires the platform writer to be stopped. It
opens the source as the controlled writer, validates it, executes `CHECKPOINT`,
closes it, copies to a new destination without overwrite, then reopens the copy
read-only and validates its schema. Backup scheduling, retention, encryption,
off-host copies, access control, and recovery objectives remain operator
responsibilities. Restoring means selecting a validated closed backup file at
the configured path; never merge database files or copy an active WAL by hand.

Direct SQL is optional debugging only. It may inspect the query columns while
the platform writer is closed, preferably through a read-only connection.
Applications and supported operations use the persistence port; SQL and table
names are not stable platform interfaces.

## Evidence and limitations

Focused tests cover exact round-trip of all six families, non-destructive
initialization, restart idempotency/conflict, all five transaction interruption
points, retries, provider transition, all invalidation targets, restatement
semantics inherited from the port suite, deterministic ordering, ambiguous
current reads, schema mismatch, checkpointed backup, and generic-runtime/
contract independence. The durable reference operation is safely repeatable
with deterministic run identities and proves close/reopen reads.

This remains fictional, nonclinical, pre-1.0 conformance software. There are no
migrations, retention automation, multi-writer service, product interfaces,
application, security certification, or production support promise.
