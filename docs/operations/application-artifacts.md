# Build and validate a reduced application artifact

This guide operates the boundary defined by the
[application-artifact foundation](../architecture/application-artifact-foundation.md).
Use the [validation guide](validation.md) for aggregate development and strict
checkpoint evidence.

## Purpose and prerequisites

These operations turn an already validated current materialized product set
into one local target-neutral product-only application artifact. They do not
run the platform, rebuild products, open DuckDB, deploy, publish, commit, push,
or contact an external service.

First complete the established workflow through app validation:

```sh
Rscript operations/run-platform.R --profile reference --scale test
Rscript operations/build-reference-products.R --scale test --materialize
Rscript operations/launch-reference-app.R --validate-only
```

## Build

Run:

```sh
Rscript operations/build-application-artifact.R
```

The operation validates current products and app compatibility, stages only
the closed runtime allowlist, copies only the current product bundle, writes
artifact identity/provenance/inventory/integrity metadata, constructs the app
from the staged content, promotes an immutable build, validates it again, and
atomically updates `build/reference-application-artifacts/CURRENT.yml`.

Use explicit local state when needed:

```sh
Rscript operations/build-application-artifact.R --products build/reference-products --artifacts build/reference-application-artifacts --built-at 2026-08-13T16:00:00Z
```

`--built-at` is mainly for controlled reproducibility and must not precede the
embedded product publication. An exact build ID/content retry is idempotent.
A later build time creates another immutable build of the same artifact
instance when runtime content and products are unchanged. Conflicting content
at an existing build identity fails closed.

## Validate independently

Run the public validator:

```sh
Rscript operations/validate-application-artifact.R
```

Or name an artifact store or one immutable artifact directory:

```sh
Rscript operations/validate-application-artifact.R --artifact build/reference-application-artifacts
```

The wrapper resolves the current pointer and invokes the artifact's own
`validate-artifact.R` in a vanilla R subprocess with the artifact as working
directory. Validation uses artifact content rather than monorepo application,
product, operation, source, runtime, provider, or persistence files. The
external R package library is still required, as declared by the artifact.

Validation checks exact inventory, safe relative paths, absence of symlinks,
manifest and member checksums, contract/application/adapter versions,
product-set identity/integrity/coherence/freshness, direct runtime dependency
declaration and installed versions, and successful app initialization and
Shiny construction.

## Inputs, outputs, and side effects

- Input products default to `build/reference-products`.
- Output store defaults to `build/reference-application-artifacts`.
- The builder creates immutable local directories and replaces only the local
  current-artifact pointer after validation.
- The validator is read-only apart from removed temporary process output.
- Operational history and source product materializations are never modified.
- Generated artifacts remain ignored and uncommitted.

The artifact embeds fictional product rows, so it remains
`fictional_nonclinical_reference_only`. A real-data artifact would require
deployment-owned privacy, access, security, retention, and authorization rules
that are not implemented here.

## Recovery and troubleshooting

- **No products:** run product materialization explicitly; the builder will not
  synthesize history or products.
- **Product corruption/incompatibility:** preserve history and rebuild the
  complete product set. Never edit member checksums.
- **Dependency mismatch:** restore the repository environment for local build.
  A future target must realize the declared R/Shiny/YAML versions separately.
- **Unexpected artifact file or symlink:** discard that generated build and
  rebuild from maintained source; do not expand the allowlist casually.
- **Immutable-build conflict:** preserve both evidence and investigate identity
  construction or filesystem mutation. Do not overwrite it.
- **Current pointer failure:** a prior immutable build remains available; rerun
  the builder after restoring a regular writable local store.
- **Application validation failure:** inspect the reported contract/product/
  dependency category. Do not add upstream platform machinery to make startup
  succeed.

## Current boundary

The next step is intentionally future work: realize this validated artifact for
Connect Cloud or another target, then publish only through a separately
authorized operation. No current command deploys or publishes it.
