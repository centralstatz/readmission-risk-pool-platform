# Readmission Risk Pool Platform

Readmission Risk Pool is an open-source implementation platform for hospital
readmission management. It is intended to connect discharge episodes,
longitudinal post-discharge evidence, governed risk estimates, operational
decisions and work, outcomes, and measure lineage through replaceable,
well-documented interfaces.

This repository is the active clean implementation. It is being designed from
the documented product direction rather than migrated around the directory
structure of the earlier implementation. The sibling `readmission-risk-pool`
repository remains development-time reference evidence only and is never a
runtime or test dependency.

## Current status

**Phase 10 is complete and Phase 11 is in progress.** Iteration 11.1 provides
the retained first-release decision assessment. Iteration 11.2 baselines the
maintainer's release/governance direction. Iteration 11.3 revises the physical
distribution architecture: this is the only maintained CentralStatz source
repository, and it generates an independently versioned Readmission Risk
Pool Hospital Implementation release containing one exact verified Platform
release. Recipient modifications are outside the CentralStatz release
architecture. Iteration 11.4 proves the generated artifact, exact unpublished
Platform candidate, independent validator, safe extraction, and external-copy
synthetic/adopter workflows under ignored local state. Iteration 11.5 proves
the separate standalone Git form at an explicit outside-repository destination:
closed identity/provenance, pristine replacement, independent validation, and
`main` with all files staged, zero commits, and zero remotes. Iteration 11.6
installs Apache-2.0 and lightweight governance, establishes a narrow R 4.4/macOS
test claim plus Ubuntu CI, and adds one clean-source maintainer workflow for
exact Platform and Hospital `v0.1.0` candidates, acquisition proof, and release
evidence. The result is ready for publication but remains `not_published`: no
release commit, tag, remote, push, GitHub Release, or publication is created.
Iteration 11.7 now supplies the explicitly authorized maintainer publication
workflow: a zero-mutation preflight, Platform-first GitHub release, generated
Hospital repository/release, checksummed partial-stage recovery, published-
state acquisition, and post-verification development transition. Publication
still occurs only when the operation is invoked with explicit `--publish`.
The focused internal
`rrpruntime@0.3.0` package accepts an
admitted canonical input, evaluates temporal eligibility, builds minimal
availability-filtered episode state, creates requests for the first versioned
conditional readmission-hazard estimand, resolves an exactly selected trusted
provider, and returns structured execution results and standardized estimates.
The shipped transparent deterministic provider proves software conformance
against both the independent fixture and synthetic producer; it is not a
clinically valid model. It now also owns backend-independent operational
history records and append/read ports, including retry lineage, conflict,
invalidation, restatement, and atomic terminal-batch semantics. The
repository-owned DuckDB reference adapter now proves those semantics durably,
and one supported fictional operation runs source through accepted estimates
and close/reopen history reads. DuckDB is not a platform requirement. Three
versioned logical products build as one coherent set exclusively
from persistence-port reads, with explicit identity, freshness, compatibility,
availability/failure, and conformance. A replaceable YAML bundle adapter now
publishes complete sets atomically and validates them before logical access;
the minimal Shiny app consumes only that access boundary. A target-neutral
closed application artifact now packages only the app, read-only product
access/validation, its contracts/declarations, and one current coherent
product bundle; it validates and constructs Shiny from an isolated copy. The
first target realization now generates a separate, standalone, staged-but-
uncommitted local Git repository for Connect Cloud and validates it without the
platform source. Remote publication/deployment, OCI/container realization,
retained/external observability routing, metrics, audit, scheduling, priority
policy, replay, and CI/CD remain unimplemented. A versioned operation-run
context and structured privacy-conscious event contract now trace bounded
doctor, reference-run, product, artifact, and Connect-realization stages
through a non-retained console sink without changing analytical results or
history. The shipped synthetic source is now registered and selected as
`reference.synthetic-canonical-producer@0.1.0` through the generic
`platform.canonical-producer@0.1.0` seam. Installation configuration selects
one exact trusted producer; generic execution validates its structured result
and canonical admission before unchanged downstream runtime. A materially
different test-only adopter producer now passes the same seam and shared
conformance machinery, then reaches unchanged isolated DuckDB history,
products, Shiny app, and reduced artifact. This closes adapter independence;
turnkey hospital onboarding, real-data authorization, and final extension
packaging are not yet claimed.

The stable human operator surface now provides explicit initialization,
read-only doctor/preflight, one reference platform run, history inspection,
product materialization, app validation, and app launch. Fresh local state is
healthy with warnings rather than fabricated history. Scheduling remains
external, and reference components are documented as independently replaceable.

The platform is not clinically validated, production-ready, or approved for
patient care.

## Direction

The intended first working realization will use a deterministic, visibly
fictional synthetic health system. It will exercise the same canonical
boundary, runtime, provider, history, products, application, and deployment
interfaces expected of an adopter. Generic code will not contain a privileged
synthetic mode.

One deployment represents one health system. The supplied Shiny application
will be an important interface, but it will not define the platform. Posit
Connect Cloud will be the reference deployment target, not a core dependency.

## Start here

1. Read [Platform True North](docs/vision/platform-true-north.md) for product
   identity and durable principles.
2. Read [Platform Architecture](docs/architecture/platform-architecture.md) for
   layers, dependency direction, prohibited dependencies, and the proposed
   repository structure.
3. Read the [Implementation Plan](docs/architecture/platform-implementation-plan.md)
   for the clean-build phases.
4. Read the [Specification Foundation](docs/architecture/specification-foundation.md)
   for the shared contract vocabulary.
5. Read the [Canonical Bundle Foundation](docs/architecture/canonical-bundle-foundation.md),
   [Initial Canonical Clinical Profile](docs/architecture/canonical-clinical-profile.md),
   and [platform specifications](contracts/README.md) for the current handoff.
6. Read the [Synthetic Reference Implementation](docs/architecture/synthetic-reference-implementation.md)
   for the first source-to-canonical realization.
7. Read the [Runtime Foundation](docs/architecture/runtime-foundation.md) for
   eligibility, state, and the first estimand request.
8. Read the [Provider and Estimate Foundation](docs/architecture/provider-foundation.md)
   for provider trust, compatibility, execution, and accepted estimates.
9. Read the [Operational History Foundation](docs/architecture/operational-history-foundation.md)
   for run lifecycle, append semantics, invalidation, and persistence ports.
10. Read [DuckDB Reference Persistence](docs/architecture/duckdb-reference-persistence.md)
   for the concrete adapter, physical tradeoffs, concurrency, and recovery.
11. Read [Logical Product Foundation](docs/architecture/logical-product-foundation.md)
   for the first suite, product-set/freshness semantics, builders, conformance,
   and logical access boundary.
12. Read [Reference Product Materialization](docs/architecture/reference-product-materialization.md)
   and [Minimal Product-Only Application](docs/architecture/reference-application.md)
   for physical publication/access and the supplied Shiny boundary.
13. Read the [Local Reference Platform Operator Manual](docs/operations/operator-manual.md)
   and [Progressive Implementation Guide](docs/adoption/progressive-implementation.md)
   for the human workflow and replaceable reference composition.
14. Read [Target-Neutral Application Artifact](docs/architecture/application-artifact-foundation.md)
   and [Application Artifact Operations](docs/operations/application-artifacts.md)
   for the reduced runtime boundary and exact build/validation commands.
15. Read [Connect Cloud Git Realization](docs/architecture/connect-cloud-realization.md)
   and [Connect Cloud Deployment Operations](docs/operations/connect-cloud-deployment.md)
   for the complete local Git target and external-publication boundary.
16. Read [Observability Foundation](docs/architecture/observability-foundation.md)
   and [Operational Diagnostics](docs/operations/observability-and-diagnostics.md)
   for operation correlation, privacy rules, console rendering, and non-goals.
17. Read [Canonical Producer Foundation](docs/architecture/canonical-producer-foundation.md)
   for declaration, trusted registration, installation selection, execution,
   admission, and adopter ownership.
18. Read [Reference Asset Reconciliation](docs/architecture/reference-asset-reconciliation.md)
   before considering material from the sibling repository.
19. Read the [Distribution and First-Release Assessment](docs/architecture/distribution-release-assessment.md)
   for the evidence and ranked Phase 11 options that preceded maintainer
   decisions.
20. Read [Hospital-Facing Implementation Distribution](docs/architecture/hospital-implementation-distribution-assessment.md)
   for the authoritative one-repository/two-release-product ownership,
   embedded Platform archive, environment, trusted composition, lifecycle,
   and next-proof decision.
21. Read the [Implementation Record](docs/architecture/platform-implementation-record.md)
   for what has actually happened.

The [documentation start page](docs/START-HERE.md) provides an ordered review,
and the [documentation index](docs/README.md) lists all current documents.

## Validate the repository

The complete human procedure and claim boundaries are documented in the
[validation operation](docs/operations/validation.md). Run in-progress checks
with:

```sh
Rscript operations/validate.R --mode development
```

Evaluate the Iteration 11.6 checkpoint with:

```sh
Rscript operations/validate.R --mode checkpoint
```

Build and independently validate the proof-only Hospital Implementation with:

```sh
Rscript operations/build-hospital-distribution.R
Rscript operations/validate-hospital-distribution.R
```

Maintainers can then generate and validate the pristine standalone repository
at an explicit temporary destination:

```sh
Rscript operations/build-hospital-git-realization.R --destination PATH
Rscript operations/validate-hospital-git-realization.R --destination PATH
```

These commands stop before commit, remote configuration, push, release, or
publication.

From a clean committed source state, prepare the exact unpublished first
release candidates and readiness evidence with:

```sh
Rscript operations/prepare-release.R --version 0.1.0
```

This also stops before commit, tag, remote, push, GitHub Release, or publication.

Generate and validate the deterministic reference flow with:

```sh
Rscript operations/generate-reference.R
```

Exercise admitted canonical input through state and request construction with:

```sh
Rscript operations/run-reference-runtime.R --input synthetic --scale test
```

Run the complete admitted-input-to-estimate demonstration with:

```sh
Rscript operations/run-reference-estimation.R --input synthetic --scale test
```

Initialize, preflight, and run the first durable fictional vertical slice with:

```sh
Rscript -e 'renv::restore()'
Rscript operations/initialize-platform.R
Rscript operations/doctor.R
Rscript operations/validate-producer.R
Rscript operations/run-platform.R --scale test
Rscript operations/inspect-reference-history.R --scale test
```

Build and inspect the first logical product set from that history with:

```sh
Rscript operations/build-reference-products.R --scale test
```

Materialize the coherent set and validate or launch the product-only app with:

```sh
Rscript operations/build-reference-products.R --scale test --materialize
Rscript operations/launch-reference-app.R --validate-only
Rscript operations/launch-reference-app.R
```

Build and independently validate the reduced target-neutral artifact with:

```sh
Rscript operations/build-application-artifact.R
Rscript operations/validate-application-artifact.R
```

Generate and independently validate a local Connect Cloud deployment
repository, stopping before external publication:

```sh
Rscript operations/build-connect-cloud-deployment.R --destination PATH
Rscript operations/validate-connect-cloud-deployment.R --destination PATH
```

## Authority

```text
Platform True North
        ↓
Clean target architecture
        ↓
Clean implementation plan
        ↓
Implementation record
        ↓
Software
```

Reference evidence never enters this chain merely because it already exists.
Future reuse follows target requirement → clean design → inspect evidence →
reuse, adapt, reference, or reject.

## Contributing at this stage

Follow [AGENTS.md](AGENTS.md) and the
[implementation conventions](docs/development/implementation-conventions.md).
Open decisions are tracked in [Open decisions](docs/architecture/open-decisions.md).
Phase 11 decision support is in the
[distribution and first-release assessment](docs/architecture/distribution-release-assessment.md).
Accepted hospital-facing composition architecture is in
[Hospital-Facing Implementation Distribution](docs/architecture/hospital-implementation-distribution-assessment.md).
Maintainer realization behavior is in
[Standalone Hospital Implementation Git Realization](docs/operations/hospital-git-realization.md).
The [release preparation guide](docs/operations/release-preparation.md) owns the
local candidate workflow, and the
[release publication guide](docs/operations/release-publication.md) owns the
separate preflight/publish/verify boundary. Repository-authored work is licensed under
[Apache-2.0](LICENSE), while [publication status](LICENSE-STATUS.md) remains
explicitly separate and `not_published`; the bounded
[compatibility review](docs/architecture/release-license-review.md) records the
dependency and asset evidence.
