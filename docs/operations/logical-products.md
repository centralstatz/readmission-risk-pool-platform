# Build, materialize, inspect, and launch reference products

## Purpose and prerequisites

These human operations read fictional DuckDB history through the logical
persistence port, build the required product set, optionally publish a complete
YAML bundle, validate/open that bundle through product access, and launch the
minimal Shiny app. They do not alter history, invoke a source/provider during
product build, apply priority policy, schedule work, or deploy anything.

Restore the locked environment from the repository root:

```sh
Rscript -e 'renv::restore()'
```

## Complete manual sequence

```sh
Rscript operations/run-platform.R --scale test
Rscript operations/build-reference-products.R --scale test --materialize
Rscript operations/launch-reference-app.R --validate-only
Rscript operations/launch-reference-app.R
```

The first command creates or idempotently confirms deterministic fictional
history. The second builds, conforms, stages, validates, and atomically
publishes all three products. The third proves clean product access and app
initialization without starting a server. The fourth launches from the already
materialized set and can be repeated without rerunning the pipeline. Stop the
foreground Shiny process with Ctrl-C.

## Paths and source scope

The default run is `runtime_synthetic_history_test_001`. Use explicit paths
when needed:

```sh
Rscript operations/run-reference-history.R \
  --scale test \
  --database build/my-fictional-history.duckdb
Rscript operations/build-reference-products.R \
  --database build/my-fictional-history.duckdb \
  --run-id runtime_synthetic_history_test_001 \
  --materialize \
  --products build/my-reference-products
Rscript operations/launch-reference-app.R \
  --products build/my-reference-products \
  --validate-only
```

Repeat `--run-id` for a coherent history set. IDs are sorted/deduplicated and
each must be currently valid and terminally completed. The caller supplies the
complete intended source scope. The operation does not discover or silently
combine other runs. Without `--materialize`, the build command prints logical
identity/freshness/counts and discards the in-memory objects.

## Side effects and publication

History generation has the append/idempotency effects documented in
[Durable Reference History](reference-history.md). Materialization creates the
selected product store, writes a staging bundle, promotes an immutable set
directory, and atomically replaces `CURRENT.yml`. The previous bundle remains
retained. Failed build never publishes; failed pointer replacement leaves the
previous set visible. App validation and launch are read-only.

Generated databases and products are ignored operational state under `build/`,
not source, and must not be committed. No cleanup command exists yet; review
non-current bundles and recovery needs before manual deletion.

## Cadence, freshness, and history

Commands run only when invoked. Scheduling is external. A missed run yields no
row for that interval and is not backfilled by product construction. Multiple
runs on one day retain distinct run IDs and actual estimate-as-of timestamps;
the app plots points without interpolation or daily aggregation.

Platform run, product refresh, and app launch are distinct. This product
operation never invokes runtime/provider code or creates history, and app
validation/launch never rebuilds products.

Old products are not automatically rejected. Integrity, compatibility, and
coherence must pass, after which access and the app show cutoff, source as-of,
latest run, generation, and publication facts. A deployment may later add an
explicit staleness policy without changing the bundle.

## Validation

```sh
Rscript tests/run-phase6-tests.R
Rscript operations/validate.R --mode development
Rscript operations/validate.R --mode checkpoint
```

The suite covers in-memory/DuckDB logical equivalence, YAML round-trip access,
replacement, corruption/incompatibility, old-valid freshness, zero rows, safe
app failure, provider transitions, missed days, and multiple same-day runs.

## Recovery and troubleshooting

- **History missing/incompatible:** create or select it with the Phase 5
  operation. Product operations never initialize or migrate history.
- **Selected run invalid/incomplete:** inspect through the history operation;
  do not publish it as completed input.
- **Build/conformance failure:** preserve history and correct the source-scope
  or contract mismatch. No partial set is published.
- **Integrity failure:** rebuild from authoritative history. Do not edit member
  files or checksums in place.
- **Compatibility failure:** use matching versions or an explicit migration;
  never relabel a manifest.
- **Old but valid products:** review displayed facts and local policy. Age is
  not corruption.
- **Zero risk rows:** review run status. An available empty product is valid.
- **App startup failure:** run `--validate-only` and act on its structured
  validation result.

No recovery step deletes or rewrites operational history.
