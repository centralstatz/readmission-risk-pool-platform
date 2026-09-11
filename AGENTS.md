# Working agreement for coding agents

## Source of truth

This is the active clean implementation of the Readmission Risk Pool Platform.
Before architectural, public-interface, packaging, deployment, or material
product work, read:

1. `docs/vision/platform-true-north.md`;
2. `docs/architecture/platform-architecture.md`;
3. `docs/architecture/platform-implementation-plan.md` (currently the
   completed historical `v0.1.0` plan; the RRP 1.0.0 plan is pending);
4. `docs/architecture/reference-asset-reconciliation.md`; and
5. `docs/architecture/platform-implementation-record.md`.

Authority flows from True North to architecture to plan to implementation
record to software. Do not infer architecture from whichever code happens to
exist. Until the RRP 1.0.0 plan replaces the historical plan, forward software
implementation is not authorized and the forward authority stops at the
current architecture.

## Reference repository

The sibling `../readmission-risk-pool` repository is development-time reference
evidence only. Never source, import, symlink, test against, deploy from, or
require it. Do not modify it while working here.

Before using an old idea or asset:

```text
Identify the clean target requirement
        ↓
Design the appropriate clean interface
        ↓
Inspect the relevant old evidence just in time
        ↓
Reuse directly, adapt, use as reference only, or reject
```

Consult the reconciliation document. Record the actual decision in the
implementation record. Once deliberately copied or adapted, the asset must be
owned, documented, and tested in this repository with no sibling dependency.

## Forward architecture and historical implementation

Phase 0–11 is the completed `v0.1.0` implementation history, not the forward
development hierarchy. The exact release remains immutable; its code, focused
component documents, tests, generated Hospital distribution, and publication
evidence remain the current implemented baseline until deliberately replaced.

The current [Platform Architecture](docs/architecture/platform-architecture.md)
is the authoritative RRP 1.0.0 target. It establishes installed RRP software,
independent hospital projects, one nonselectable cumulative day-30 risk target,
project producer/provider seams, separate dependency/state lifecycles,
product-only deployment, non-mutating upgrades, and lifecycle-owned validation.
It supersedes contrary forward recommendations in assessments and historical
Phase documents. `1.0.0` is not implemented or released.

Do not begin 1.0.0 software implementation until the explicitly authorized RRP
1.0.0 Implementation Plan replaces the historical plan. Work from that future
plan's workstreams and acceptance evidence rather than continuing Phase
numbers. Documentation synthesis and planning may use proportional validation
when explicitly scoped. Do not alter released `v0.1.0` assets or publication
evidence while developing the new generation.

For every meaningful iteration, update
`docs/architecture/platform-implementation-record.md` with the planned
objective, actual work, old assets used/adapted, new clean work, decisions,
surprises, deviations, validation, later implications, and next task. Update
the architecture or plan explicitly if evidence changes them.

## Architectural boundaries

- Local source implementations own source interpretation and stop at the
  canonical handoff.
- Generic runtime never depends on a named implementation or source system.
- RRP owns one versioned remaining cumulative day-30 readmission-risk target;
  projects do not register or select estimands or request builders.
- Risk and decision/priority policy remain separate.
- Tasks and interventions remain separate.
- Operational history is append-oriented and distinct from products.
- Products are logical, versioned interfaces independent of storage.
- The app consumes products and does not query sources or invoke providers.
- Deployment targets package stable runtime interfaces and do not alter
  upstream semantics.
- Installed RRP software and independent project source/state are distinct;
  software installation or upgrade never silently modifies a project.
- Observability, provenance, validation, metrics, and audit remain distinct.
- One deployment represents one health system.
- Optional advanced methods never become mandatory core dependencies.

## Human-first operations

Agents are optional conveniences. Human operations documentation is
authoritative, and every meaningful supported operation must have a tested,
documented human equivalent with inputs, outputs, side effects, validation,
recovery, and troubleshooting.

Agents invoke the same tested operations as people and automation. Do not
invent hidden procedures, unique business logic, secret recovery steps, or an
AI-only interface. If guidance and an executable operation disagree, treat it
as a defect and reconcile them.

Interpret structured operation events only as privacy-conscious diagnostics.
Do not request or expose patient-level context to diagnose a routine operation;
preserve safe human recovery hints, and update the observability contract,
privacy tests, console guidance, and affected operation together when event
behavior changes. Agents are consumers of the same interface, never an
observability dependency.

The commands below operate the current `v0.1.0` source implementation. They are
historical/current executable interfaces, not the future RRP 1.0.0 CLI
contract. Read `docs/operations/operator-manual.md` before platform operation. Invoke its
exact commands instead of recreating multi-stage sequences ad hoc, report the
human operation invoked, keep documentation/registry/tests aligned when an
operation changes, and never introduce scheduling implicitly. Do not modify a
hospital/source implementation unless the user explicitly asks.

Stable intent mappings are:

```text
initialize the local platform
    → Rscript operations/initialize-platform.R
run doctor
    → Rscript operations/doctor.R
validate the configured producer
    → Rscript operations/validate-producer.R
run the reference platform once
    → Rscript operations/run-platform.R --scale test
inspect reference history
    → Rscript operations/inspect-reference-history.R --scale test
materialize reference products
    → Rscript operations/build-reference-products.R --scale test --materialize
validate the reference app
    → Rscript operations/launch-reference-app.R --validate-only
launch the reference app
    → Rscript operations/launch-reference-app.R
build the application artifact
    → Rscript operations/build-application-artifact.R
validate the application artifact
    → Rscript operations/validate-application-artifact.R
generate a Connect Cloud deployment repository
    → Rscript operations/build-connect-cloud-deployment.R --destination PATH
validate a Connect Cloud deployment repository
    → Rscript operations/validate-connect-cloud-deployment.R --destination PATH
build the Hospital Implementation distribution
    → Rscript operations/build-hospital-distribution.R
validate the Hospital Implementation distribution
    → Rscript operations/validate-hospital-distribution.R
generate a standalone Hospital Implementation repository
    → Rscript operations/build-hospital-git-realization.R --destination PATH
validate a standalone Hospital Implementation repository
    → Rscript operations/validate-hospital-git-realization.R --destination PATH
prepare release v0.1.0
    → Rscript operations/prepare-release.R --version 0.1.0
validate the v0.1.0 release candidate
    → Rscript operations/prepare-release.R --version 0.1.0 --validate-only
show release readiness
    → Rscript operations/prepare-release.R --version 0.1.0 --show-readiness
run publication preflight for v0.1.0
    → Rscript operations/publish-release.R --version 0.1.0 --preflight
publish v0.1.0
    → Rscript operations/publish-release.R --version 0.1.0 --publish
verify the published v0.1.0 release
    → Rscript operations/publish-release.R --version 0.1.0 --verify
```

Keep platform run, product refresh, and app launch distinct. “Refresh the local
reference app” is ambiguous: determine whether the user wants a new estimation
run, only a product rebuild from retained history, or only app launch/reload.
Never schedule any of them automatically.

Do not commit, publish, deploy, push, or mutate an external repository unless
the user explicitly requests it and the relevant operation's safety checks are
available.

## Human-readable implementation

Follow `docs/development/implementation-conventions.md`.

- Communicate intent with focused responsibilities and expressive names.
- Comment domain, temporal, safety, and architectural rationale rather than
  obvious syntax.
- Use native R `|>`; never `%>%`.
- Use tidyverse where it clarifies transformations and base R where simpler for
  system, CLI, filesystem, dependency-light, or performance-sensitive work.
- Add only dependencies used by current executable behavior.
- Keep AI-assisted changes directly understandable to human maintainers.
- Prefer correctness, safety, reproducibility, and appropriate performance over
  stylistic conformity.

## Validation and documentation

Use the exact human operations documented in
`docs/operations/validation.md` for changes to the implemented `v0.1.0`
software. The universal Phase/checkpoint commands are legacy release evidence,
not default proof for forward documentation or planning. Select validation
proportional to the affected architecture boundary and follow an explicit task's
stricter or narrower validation scope. The current legacy development command
is:

```sh
Rscript operations/validate.R --mode development
```

For the Iteration 11.7 checkpoint, run:

```sh
Rscript operations/validate.R --mode checkpoint
```

Run the focused Hospital distribution/Git-realization tests and supported
maintainer build/validation operations with:

```sh
Rscript tests/run-phase11-tests.R
Rscript operations/build-hospital-distribution.R
Rscript operations/validate-hospital-distribution.R
Rscript operations/build-hospital-git-realization.R --destination PATH
Rscript operations/validate-hospital-git-realization.R --destination PATH
Rscript operations/prepare-release.R --version 0.1.0
Rscript operations/prepare-release.R --version 0.1.0 --validate-only
Rscript operations/prepare-release.R --version 0.1.0 --show-readiness
Rscript operations/publish-release.R --version 0.1.0 --preflight
Rscript operations/publish-release.R --version 0.1.0 --verify
```

Run the focused Phase 3 producer tests and the supported reference operation
with:

```sh
Rscript tests/run-phase3-tests.R
Rscript operations/generate-reference.R
```

Run the focused runtime tests and reference runtime/estimation operations with:

```sh
Rscript tests/run-phase4-tests.R
Rscript operations/run-reference-runtime.R --input synthetic --scale test
Rscript operations/run-reference-estimation.R --input synthetic --scale test
```

Run the focused durable-history tests and reference persistence operation with:

```sh
Rscript tests/run-phase5-tests.R
Rscript operations/run-reference-history.R --scale test
```

Run the focused product/materialization/app tests and operations with:

```sh
Rscript tests/run-phase6-tests.R
Rscript operations/build-reference-products.R --scale test
Rscript operations/build-reference-products.R --scale test --materialize
Rscript operations/launch-reference-app.R --validate-only
```

Run the focused deployment-artifact/realization tests and human operations
with:

```sh
Rscript tests/run-phase8-tests.R
Rscript operations/build-application-artifact.R
Rscript operations/validate-application-artifact.R
Rscript operations/build-connect-cloud-deployment.R --destination PATH
Rscript operations/validate-connect-cloud-deployment.R --destination PATH
```

Run the focused observability contract/privacy/lifecycle tests with:

```sh
Rscript tests/run-phase9-tests.R
```

Run the focused canonical-producer tests and configured producer conformance
operation with:

```sh
Rscript tests/run-phase10-tests.R
Rscript operations/validate-producer.R
```

Run the focused human-operation tests and stable reference workflow with:

```sh
Rscript tests/run-phase7-tests.R
Rscript operations/initialize-platform.R
Rscript operations/doctor.R
Rscript operations/run-platform.R --scale test
Rscript operations/inspect-reference-history.R --scale test
Rscript operations/build-reference-products.R --scale test --materialize
Rscript operations/launch-reference-app.R --validate-only
```

Development coherence and strict milestone readiness are different claims.
Never use development mode to bypass checkpoint failure. Later generation,
deployment, publication, and release checkpoints may add stronger state
requirements only when their components exist.

Do not invent alternate validation behavior in agent instructions. When
validation changes, update callable behavior, focused tests, human operations
documentation, this file, and the implementation record together.

Tests should cover success and failure, identity and relationship integrity,
temporal availability and terminal behavior, deterministic promises,
compatibility, standardized outputs, and safe unsupported behavior as
applicable.

Machine-readable platform specifications use the common YAML envelope and
identity vocabulary documented in
`docs/architecture/specification-foundation.md`. Run focused specification
tests with `Rscript tests/run-phase1-tests.R`. Do not introduce canonical
clinical-domain fields while changing the foundation vocabulary.

The generic canonical handoff uses
`docs/architecture/canonical-bundle-foundation.md` and
`contracts/canonical/canonical-bundle.yml`. Run its focused tests with
`Rscript tests/run-phase2-tests.R`. The first clinical instantiation uses
`docs/architecture/canonical-clinical-profile.md` and
`contracts/canonical/profiles/readmission-initial-profile.yml`. Phase 2 is
complete. The Phase 3 implementation is documented in
`docs/architecture/synthetic-reference-implementation.md`; it is not a generic
runtime mode, and generic canonical code must not depend on its identity or
source tables.

The currently implemented `v0.1.0` adopter/source composition seam uses
`docs/architecture/canonical-producer-foundation.md` and
`contracts/canonical/canonical-producer.yml`. One installation selects one
exact producer in `config/platform-instance.yml`; trusted maintained code, not
YAML, registers its callable. Generic execution admits the structured result
before runtime. The independent adopter evidence is isolated under
`tests/phase10/fixtures/adopter-producer/` and never enters the normal installed
registry. Do not add dynamic loading, hospital selectors, multiple active
producers, or source configuration or secrets above this boundary.

The generated Hospital composition in
`docs/architecture/hospital-implementation-distribution-assessment.md` is
immutable `v0.1.0` release history, not forward architecture. Preserve its
published assets and explicit publication safeguards, but do not extend it as
the RRP 1.0.0 acquisition path. The forward project registers producers and
providers only; installed RRP owns the singular target and runtime. The
development lock, installed software environment, project extension
environment, and deployment closure are distinct.

The generic runtime foundation uses
`docs/architecture/runtime-foundation.md` and `contracts/runtime/`. It requires
canonical admission and must not discover repository paths or source
implementations. The completed provider boundary uses
`docs/architecture/provider-foundation.md`; generic code does not depend on the
reference provider identity, and failures never become fabricated estimates.
Phase 4 is complete. Operational history is documented in
`docs/architecture/operational-history-foundation.md` and
`contracts/persistence/`. Iteration 5.2 realizes the unchanged port through
`docs/architecture/duckdb-reference-persistence.md` and
`implementations/persistence/duckdb/`. Phase 5 is complete. Phase 6 is complete
through the logical boundary in
`docs/architecture/logical-product-foundation.md`, the reference materializer
in `docs/architecture/reference-product-materialization.md`, and the app in
`docs/architecture/reference-application.md`. Phase 7 is complete through
`docs/operations/operator-manual.md`, `docs/adoption/progressive-implementation.md`,
and `operations/operations.yml`. Replay, decision policy, scheduling, and later
capabilities remain unauthorized until their phases.
The target-neutral deployment boundary is documented in
`docs/architecture/application-artifact-foundation.md` and
`contracts/deployment/application-artifact.yml`; the completed Connect target
is documented in `docs/architecture/connect-cloud-realization.md` and
`contracts/deployment/connect-cloud-realization.yml`. Neither authorizes remote
publication or deployment.
The bounded diagnostic boundary uses
`docs/architecture/observability-foundation.md` and
`contracts/observability/`. Operation-run identity is never analytical
runtime-run identity; events are not history, validation, provenance, metrics,
or audit, and no default sink persists them.

Update versions, tests, examples/configuration, human documentation, and the
implementation record together when changing a contract, risk target, provider,
policy, record, product, operation, or deployment interface. Keep current
maturity and fictional/nonclinical limitations explicit.

Never put PHI, patient-level clinical values, credentials, connection strings,
raw records, private hospital mappings, or confidential business material in
the repository or ordinary diagnostics.
