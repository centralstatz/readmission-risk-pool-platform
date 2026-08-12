# Build and inspect reference logical products

## Purpose

This read-only operation opens existing fictional DuckDB operational history
through the logical persistence port, selects explicit valid completed run
history, builds the required in-memory logical product set, validates every
product and set coherence, and prints identities, freshness, availability, and
row counts. It writes no product file or table and does not invoke a source,
runtime eligibility, provider, decision policy, application, or deployment.

Restore the locked environment and run commands from the repository root:

```sh
Rscript -e 'renv::restore()'
```

## Build after durable history

Create the deterministic fictional history first:

```sh
Rscript operations/run-reference-history.R --scale test
```

Then build and inspect the three logical products in memory:

```sh
Rscript operations/build-reference-products.R --scale test
```

The default database is the ignored path configured by the DuckDB reference
adapter. The default selected run is
`runtime_synthetic_history_test_001`. Choose a database and one or more exact
run IDs explicitly when required:

```sh
Rscript operations/build-reference-products.R \
  --database build/my-fictional-history.duckdb \
  --run-id runtime_synthetic_history_test_001
```

Repeat `--run-id` to build a coherent transition/history set. The command
sorts/deduplicates the supplied IDs, requires every one to be currently valid
and terminally completed, derives the cutoff from their greatest run as-of,
and lets the product builder identify the unique latest represented run by
as-of then terminal status time. The selected IDs must be the complete intended
history scope at that cutoff. A current estimate outside the supplied scope is
a coherence failure.

## Output and side effects

Success prints:

- deterministic product-set and build IDs;
- selected source cutoff and source as-of;
- latest represented valid runtime run;
- product generation time; and
- each product ID/version, availability, and row count.

The logical objects and access boundary exist only in process memory and are
discarded on exit. The operation opens the database read-only, closes it, and
does not modify history. Ordinary console output contains aggregate identities
and counts for visibly fictional reference data; it is not logging,
observability, provenance storage, or audit.

## Validation

Run:

```sh
Rscript tests/run-phase6-tests.R
Rscript operations/validate.R --mode development
Rscript operations/validate.R --mode checkpoint
```

The focused suite proves the same logical results through the in-memory test
adapter and a temporary DuckDB database, plus current/history/run-summary,
provider-transition, invalidation/restatement, failure/zero-row, conformance,
freshness, deterministic identity, and access-boundary behavior.

## Recovery and troubleshooting

- **Database missing or incompatible:** create history with the documented
  Phase 5 operation or select a compatible validated database. Do not
  initialize or migrate it through the product command.
- **Selected run unavailable:** inspect the run through the history port. An
  invalidated, incomplete, failed, missing, or ambiguous run cannot be treated
  as a completed valid product source.
- **Current estimate outside selected scope:** supply the complete intended
  valid run set at the cutoff. Do not allow the builder to combine undeclared
  history silently.
- **Unsupported upstream version:** use a product builder declaring that exact
  compatible line or deliberately version the product contracts and tests.
- **Product conformance failure:** preserve the source history, inspect all
  structured issues, and correct the builder/contract mismatch. Do not publish
  partial products or substitute empty rows.
- **Zero risk rows:** check the run summary. A valid
  `completed_with_failures` run can legitimately yield available zero-row risk
  products; this is not equivalent to a failed build.

No recovery step deletes or rewrites operational history. Physical product
materialization/recovery begins only when Iteration 6.2 selects an adapter.
