# RRP Standalone Application Guide

This guide covers the supported hospital-owned standalone application
lifecycle. The four application commands have deliberately different jobs:

- `rrp app launch` runs the read-only default supplied by the selected RRP
  installation against project products.
- `rrp app init` creates a new, independent application at an absent path.
- `rrp app refresh` changes only compatible analytical products beneath the
  standalone application's reserved `rrp-data/` directory.
- `rrp app validate` reads and validates managed content without executing
  application source.

## Initialize

First complete an analytical run and materialize its exact products. Supply the
returned operation scope and an explicit RFC 3339 UTC cutoff:

```sh
rrp app init \
  --scope "$SCOPE" \
  --cutoff "$CUTOFF" \
  --project "$PROJECT"
```

The default destination is `$PROJECT/app`. Use `--output` to choose another
absent path whose parent already exists. Initialization refuses an existing
destination. Its fixed `rrp-initialization.dcf` and
`rrp-source-inventory.dcf` describe what RRP supplied initially; refresh never
rewrites either record.

## Run with ordinary R

The application is conventional Shiny source. From the directory containing
`app`, run:

```r
shiny::runApp("app")
```

Its direct runtime packages are `shiny`, `bslib`, `plotly`, and `reactable`.
The exact minimal `renv.lock` may optionally be restored with ordinary `renv`
operations before launch. RRP does not add automatic activation, require its
private installed library at application runtime, or require `rrpplatform`,
`rrpruntime`, DBI, DuckDB, or analytical project code.

## Ownership and customization

After creation, the hospital owns `app.R`, `R/`, `www/`, `README.md`,
`renv.lock`, legal notices, dependency declarations, deployment configuration,
Git metadata, and any additional source or assets. RRP reserves only:

```text
app/rrp-data/
```

Normal hospital source changes are not a reason for a compatible refresh to
fail. Initial source-baseline agreement is informational historical evidence,
not a current source-authority or safety claim. The hospital is responsible for
reviewing, testing, maintaining, and deploying its source changes.

## Refresh managed products

Run and materialize the later analytical context explicitly through the normal
project workflow. Then refresh the already-materialized exact result:

```sh
rrp app refresh \
  --scope "$NEW_SCOPE" \
  --cutoff "$NEW_CUTOFF" \
  --project "$PROJECT"
```

Use `--app PATH` when the target is not `$PROJECT/app`. Refresh does not run a
producer, provider, model, analytical operation, or product materialization.
It validates the source products and current application, stages a complete
frozen set under `rrp-data/sets/`, and atomically replaces the small
`rrp-data/current.dcf` record only after the new set passes validation. The
previous complete set is retained so a reader that already resolved it can
finish safely. A precommit refusal leaves the previous set current. A
postcommit diagnostic explicitly reports that the new valid set was committed.

A local Shiny process reads the current record when it builds its application
model; restart that process to select refreshed products deterministically.
Externally hosted applications likewise require the hospital's normal
redeployment or restart procedure. RRP does not publish or redeploy them.

## Validate and recover

Validate a project application or a detached copy:

```sh
rrp app validate --project "$PROJECT"
rrp app validate --app "$DETACHED_APP"
```

Detached validation needs the selected installed RRP command but not the
originating project, state/history, source materialization, source repository,
or original installation path. It checks the current declaration, active
frozen set, exact inventory and SHA-256 digests, product compatibility,
presentation, identities, cutoff, and lineage. It does not source `app.R` or
hospital modules and does not repair, delete, regenerate, or execute anything.

`managed_content_status` is independent of `initial_provenance_status` and the
informational `source_baseline_status`. A missing or changed initial record, or
ordinary source drift, does not by itself corrupt managed products. Incomplete
staging and inactive-set counts are bounded diagnostic information; validation
is read-only.

If refresh refuses stale, incompatible, corrupt, linked, or unsafe content,
leave the application in place, correct the source materialization or managed
boundary through an authorized recovery decision, and validate again. RRP does
not silently reconstruct corrupt current content or repair hospital source.

## Obtain a fresh later default

To compare with the then-current supplied default, create another application
at a new absent path:

```sh
rrp app init \
  --scope "$SCOPE" \
  --cutoff "$CUTOFF" \
  --project "$PROJECT" \
  --output "$NEW_ABSENT_PATH"
```

Compare or adopt it with ordinary hospital tools. RRP does not upgrade, merge,
or replace an existing application's source.

## External hosting

The standalone directory can be deployed with ordinary Shiny hosting tools.
For example, a hospital may configure `rsconnect` and deploy to its own Posit
Connect service using that tool's documented workflow. This is illustrative
external tooling, not an RRP operation. RRP does not generate `manifest.json`,
manage Connect credentials or APIs, publish remotely, create Git deployment
workflows, or build Docker/OCI artifacts.

## Privacy and authorization

Frozen product rows and detached presentation are real application content.
They are not inherently free of protected health information merely because
they passed structural validation. The hospital owns data classification,
least-privilege access, authentication, authorization, transport security,
hosting controls, audit, retention, and incident response for the application
and its deployments.
