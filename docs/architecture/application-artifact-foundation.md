# Target-neutral reduced application artifact

## Purpose and maturity

Iteration 8.1 introduces
`platform.reduced-application-artifact@0.1.0`: the boundary between the full
platform repository and any future deployment target. It packages what the
current product-only application needs to run, not what Connect Cloud, Git, a
container, or another host expects.

```text
validated application + current materialized products
        ↓
closed target-neutral artifact build
        ↓
standalone artifact validation and Shiny construction
        ↓
future target-specific realization and separate publication
```

The implementation is pre-1.0, fictional/nonclinical deployment architecture.
It proves a reduced portable R/Shiny unit on the current validated environment;
it does not prove a production host, public release, security posture, or
clinical fitness.

## Current application runtime characterization

The characterization preceded the artifact design.

1. **Application code:** the running app needs its root entry point, product
   initialization, presentation view models, and Shiny factory. The artifact
   adds a standalone loader/validator and root entry point; it does not preserve
   the monorepo launcher arrangement.
2. **Products:** it needs exactly one current coherent
   `platform.initial-risk-product-set@0.1.0` YAML materialization: `CURRENT.yml`,
   `PRODUCT_SET.yml`, and the current-risk, risk-history, and run-summary
   members. Prior materializations and DuckDB history are unnecessary.
3. **R dependencies:** runtime code directly needs R 4.1.0 or newer,
   `shiny@1.10.0`, and `yaml@2.3.10`. Shiny's dependency closure is an
   installation concern, not a list of direct platform dependencies.
4. **Development-only platform source:** canonical/source generation,
   `rrpruntime`, provider execution, DuckDB persistence, product builders and
   writers, platform operations, tests, development docs, `renv`, Git, and
   sibling evidence are unnecessary after products exist.
5. **Preconstruction validation:** the builder opens and validates the current
   product set through the Phase 6 adapter, initializes and constructs the app,
   checks maintained inputs and direct dependency versions, and rejects unsafe
   output state before staging.
6. **Completed-artifact validation:** the artifact validates its closed
   inventory, paths, links, checksums, embedded declarations, product set,
   freshness, app compatibility, runtime packages, and Shiny construction using
   only artifact files plus an externally installed R package library.
7. **External runtime configuration:** host, port, process management,
   credentials, authorization, package installation, and hosting policy remain
   target/environment supplied. No secret or connection is baked into the
   artifact. The selected fictional product data are intentionally embedded.

## Contract and exact layout

The contract is
[`platform.reduced-application-artifact@0.1.0`](../../contracts/deployment/application-artifact.yml).
A completed artifact contains 27 regular files: 25 checksummed payload members
plus the manifest and its checksum.

```text
artifact-<build-digest>/
├── ARTIFACT.yml
├── ARTIFACT.md5
├── app.R
├── validate-artifact.R
├── R/
│   ├── artifact-runtime.R
│   ├── product-foundation.R
│   ├── product-conformance.R
│   ├── yaml-product-foundation.R
│   ├── yaml-product-validation.R
│   ├── yaml-product-access.R
│   ├── app-init.R
│   ├── view-models.R
│   └── application.R
├── contracts/
│   ├── application-artifact.yml
│   ├── application.yml
│   ├── product-materialization-adapter.yml
│   ├── initial-risk-product-set.yml
│   ├── current-episode-risk.yml
│   ├── episode-risk-history.yml
│   └── operational-run-summary.yml
├── config/
│   ├── yaml-product-adapter.yml
│   └── runtime-dependencies.yml
└── products/
    ├── CURRENT.yml
    └── sets/bundle-<physical-md5>/
        ├── PRODUCT_SET.yml
        ├── current-episode-risk.yml
        ├── episode-risk-history.yml
        └── operational-run-summary.yml
```

The artifact has no product writer. The YAML access implementation was split
from materialization so the reduced unit carries validation/read behavior only.
Contract copies remain because product field, identity, coherence, and adapter
compatibility validation must work after the monorepo is absent.

## Identity and provenance

Five identities remain distinct:

- operational run IDs name actual source-to-estimate observations;
- product-set ID names the logical projection selected for consumption;
- artifact instance ID deterministically names application identity, product
  set, and the complete runtime payload checksums;
- artifact build ID adds its declared build time; and
- future deployment/publication IDs will name target realization and external
  mutation separately.

Neither identity uses a Git commit or local path. The manifest records the
source materialization, product build, source runs, cutoff/as-of/generation/
publication times, application and builder versions, build time, compatibility,
and staged validation evidence. A later build at another time has a different
build ID but the same instance ID when its application, products, dependencies,
and content are unchanged.

## Integrity, replacement, and validation

`ARTIFACT.yml` is the closed inventory and carries an MD5 checksum for every
payload. `ARTIFACT.md5` covers the manifest. MD5 detects accidental corruption;
it is not authenticity, signing, or security evidence. Validation rejects
undeclared/missing files, unsafe relative paths, duplicate paths, all symlinks,
unsupported declarations, product corruption/incoherence, dependency mismatch,
and app failure.

Builds stage under the ignored artifact store, validate before promotion,
promote to an immutable build directory, validate again, and atomically replace
only `CURRENT.yml`. The same build identity/content is idempotent; conflicting
content at an existing immutable identity fails. A different build is retained
beside the previous build. Cleanup is not automated.

## Dependency decision

The artifact declares only its direct runtime roots and exact currently tested
versions in `config/runtime-dependencies.yml`. It does not copy the full project
`renv.lock`, because that would incorrectly make DuckDB, DBI, development
validation, and build dependencies permanent app requirements. It also does not
copy a developer library. A future target realization must translate the direct
declaration into its supported reproducible installation mechanism and resolve
transitive dependencies. Iteration 8.1 validates against the installed package
environment but does not design a container or Connect manifest.

## Publication boundary

The builder creates only local ignored files. There is no Connect profile,
`rsconnect` manifest, container, companion repository, Git mutation, credential,
commit, push, or external publication. A target builder may consume this
artifact in a later iteration but must keep artifact construction, target
realization, and publication as separate identities and operations.

## Reference evidence classification

The clean contract and layout preceded the read-only sibling review.

| Sibling evidence | Classification | Retained or rejected |
|---|---|---|
| Connect bundle allowlist and staged builder | **Adapt — principles only** | Retained explicit file inclusion, staging, exact inventory, and validate-before-promotion; rejected Connect identity, committed-product checkpoints, root Git state, `rsconnect`, and broad engine/schema copying |
| Connect artifact validator and portability copy | **Adapt — principles only** | Retained checksum/exclusion checks and clean-copy application initialization; replaced target manifest assumptions with the generic contract and product-only runtime |
| Generated root adapter | **Reference only** | Confirmed a hosting root may adapt an authoritative app entry point; the clean artifact owns a target-neutral root directly |
| Publication helper/profile/tests | **Defer** | Destination ownership, staging, rollback, dry-run, commit, and push safety belong to later target realization/publication |
| Fully generated companion repository policy | **Defer/reject as generic** | May inform the Connect target, but Git and companion ownership are not artifact semantics |

No sibling code, prose, YAML, identifier, dependency declaration, product,
template, or configuration was copied.

See the [platform architecture](platform-architecture.md), the
[implementation plan](platform-implementation-plan.md), and the human
[artifact operations guide](../operations/application-artifacts.md) for the
governing boundary, phase sequence, and supported commands.
