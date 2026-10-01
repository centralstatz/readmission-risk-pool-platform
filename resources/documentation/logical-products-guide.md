# Logical Products Guide

RRP logical products are a validated, consumer-facing view of authoritative
project history. They do not replace operational history and they do not read
hospital source data or invoke project producer or provider code.

## Build one coherent product set

Choose one complete operational scope and an explicit history cutoff. Call
`rrp_build_product_set()` with the scope's `operation_run_id`. The result is one
coherent set governed by `rrp.product-set.initial-readmission-risk@0.1.0` and
contains exactly these members:

- `rrp.product.current-remaining-risk@0.1.0` contains at most one effective
  accepted estimate for each episode at the selected scope time;
- `rrp.product.remaining-risk-trajectory@0.1.0` contains only actual effective
  accepted estimates at their governed analytical times; it does not invent,
  interpolate, replay, or convert observations; and
- `rrp.product.operational-scope-summary@0.1.0` contains one row reconciling
  the complete scope membership with effective outcomes.

An eligible population of zero episodes is a successful, available product
set: the first two members have zero rows and the summary has one complete
zero-count row. An incomplete, invalidated, unavailable, ambiguous, or changing
source is a bounded failure and produces no partial set.

```r
built <- rrp_build_product_set(
  catalog,
  project_root,
  operation_run_id,
  history_cutoff = "2026-01-20T12:00:00Z"
)
stopifnot(rrp_operation_succeeded(built))
product_set <- built$value
```

The product and row identities are deterministic and content-sensitive. Paths,
publication time, file format, and file digests are not logical identity.

## Materialize and reopen

`rrp_materialize_product_set()` publishes a complete set beneath explicit
project state using `rrp.product-materialization@0.1.0`. Publication validates
all members before replacing the current-set pointer. Repeating an identical
publication is idempotent. A later set may become current while older intact
sets remain valid stored evidence.

```r
published <- rrp_materialize_product_set(catalog, project_root, product_set)
stopifnot(rrp_operation_succeeded(published))

opened <- rrp_open_product_access(catalog, project_root)
stopifnot(rrp_operation_succeeded(opened))
inventory <- rrp_list_products(opened$value)
current <- rrp_read_product(
  opened$value,
  "rrp.product.current-remaining-risk",
  "0.1.0"
)
```

Use `rrp_list_products()` and `rrp_read_product()` rather than interpreting the
materialized representation. Access validates inventory, sizes, digests,
format compatibility, member conformance, and set coherence before returning
detached logical objects. Corrupt or incompatible state is denied without
returning product rows.

## Freshness and lineage

Open without expected source inputs to read a valid set with freshness
`not-evaluated`. Supply both the expected operation run and history cutoff to
`rrp_open_product_access()` to obtain `fresh` or `stale`. A later cutoff alone
does not make a set stale; freshness changes only when the governed effective
source view differs. A stale but intact set remains readable with its original
lineage so a caller can decide when to rebuild.

Each member carries the product-set identity. The set records project, state,
scope, target, analytical-time, history-cutoff, and source-fingerprint lineage.
Episode-level members expose canonical `episode_id`, not patient, encounter,
native, crosswalk, predictor, credential, connection, source-path, raw-record,
or model-artifact data.

## State, deletion, backup, and recovery

Materialized products are derived project state. Deleting them does not delete
authoritative history; rebuild the logical set from the same valid history and
materialize it again. Whole-project copying carries intact products, which are
reopened relative to the copied project root.

The project-state backup operation intentionally excludes products. Restore
recreates authoritative state and history with products absent. Rebuild and
materialize products after restore. This keeps backup authority focused on the
history required to reproduce products.

## Current boundary

These operations are the installed programmatic product capability. RRP does
not yet supply an application, dashboard, command-line product workflow,
scheduler, remote product service, custom product or materializer extension,
distribution procedure, production support claim, or clinical-validation
claim.
