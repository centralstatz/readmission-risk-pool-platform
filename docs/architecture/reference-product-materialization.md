# Reference product materialization

## Decision and boundary

Iteration 6.2 realizes the storage-neutral product seam with
`reference.yaml-product-bundle@0.1.0`, conforming to
`platform.product-materialization-adapter@0.1.0`. YAML was selected instead of
CSV because all three current products contain nested model, provider,
estimand, implementation, mapping, or provenance references. Flattening those
values into CSV would add a second ad hoc encoding and weaken exact contract
validation. The repository already owns the `yaml` dependency, and the result
is inspectable and language-neutral. A database or service adapter can replace
this reference without changing logical builders or the app.

DuckDB remains authoritative operational history. A YAML product bundle is a
rebuildable consumer projection. It is never an audit store, never changes
history, and cannot recover history that retention has removed.

## Physical layout

```text
reference-products/
├── CURRENT.yml
└── sets/
    └── bundle-<physical-md5>/
        ├── PRODUCT_SET.yml
        ├── current-episode-risk.yml
        ├── episode-risk-history.yml
        └── operational-run-summary.yml
```

`PRODUCT_SET.yml` contains complete logical set metadata, builder and
specification references, source runs/cutoff/as-of, generated time, member
identity, row counts, adapter/format identity, and member checksums. Each member
file contains one complete logical product. `CURRENT.yml` names one immutable
bundle, its manifest checksum, and publication time.

Logical IDs exclude directories, paths, adapter/format, checksums, and
publication time. The directory digest is physical naming only. MD5 detects
accidental local corruption; it is not evidence of authenticity or security.

## Atomic publication and replacement

The materializer reconforms the complete logical set, writes every member and
the manifest into a unique staging directory under `sets/`, hashes them, and
promotes that directory with a same-filesystem atomic rename. Only then does it
write and atomically replace `CURRENT.yml`. Readers see the previous complete
set or the new complete set, never mixed members or a partial set.

Published bundle directories are immutable. Identical materialization is an
idempotent reuse; conflicting content at an existing physical identity fails.
Previous bundles remain retained for safe replacement and inspection. Cleanup
is a separate operator-governed retention action and is not automated. Pointer
replacement failure leaves the prior set visible.

## Validation and access

Opening access validates the entire current set before exposing a method:

1. **Integrity:** safe non-linked paths, exact inventory, readable YAML, and
   manifest/member checksums.
2. **Compatibility:** contract, adapter, format, set, member identities,
   versions, and row counts.
3. **Coherence:** member conformance and one shared set/source/freshness scope.
4. **Freshness:** cutoff, source as-of, latest run, generation, and publication
   facts.

Integrity, compatibility, and coherence failure returns structured issues and
no access object. The platform has no universal staleness threshold, so an old
but valid set loads with `not_evaluated_no_platform_threshold` and truthful
times. Successful access implements `list_products()`, `read_product()`, and
`read_product_metadata()` over copies of the one validated bundle.

## Cadence and generated-data policy

Materialization occurs only when invoked; there is no daily scheduler. Missed
days create no synthetic observations, and multiple same-day runs remain
distinct timestamps and run IDs. Bundles and DuckDB files are generated state
under `build/` and are not committed. Scheduling, cleanup, retention duration,
authentication, deployment, and production storage remain outside this adapter.
