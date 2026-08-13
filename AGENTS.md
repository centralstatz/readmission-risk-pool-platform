# Working agreement for coding agents

## Source of truth

This is the active clean implementation of the Readmission Risk Pool Platform.
Before architectural, public-interface, packaging, deployment, or material
product work, read:

1. `docs/vision/platform-true-north.md`;
2. `docs/architecture/platform-architecture.md`;
3. `docs/architecture/platform-implementation-plan.md`;
4. `docs/architecture/reference-asset-reconciliation.md`; and
5. `docs/architecture/platform-implementation-record.md`.

Authority flows from True North to architecture to plan to implementation
record to software. Do not infer architecture from whichever code happens to
exist.

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

## Work by implementation phase

Keep work within the active phase and its stated exit evidence. Do not create
later-phase scaffolding merely to make the tree look complete. In particular,
do not add persistence, products, app code, deployment, observability, or CI/CD
before the relevant task authorizes it. Completed Phase 4 owns admitted input,
eligibility, state, estimand requests, provider contracts/registry/execution,
structured outcomes, the transparent reference provider, and accepted
estimates inside `rrpruntime`. The current `renv` state owns the Phase 1 YAML
parser plus DBI and DuckDB solely for the Iteration 5.2 concrete reference
adapter; `rrpruntime` remains base-R-only. Completed Phase 6 owns the
three-product logical core set, backend-neutral builders/conformance, YAML
reference materialization/access adapter, and minimal product-only Shiny app.
The app owns Shiny; the adapter reuses YAML. Completed Phase 7 owns the stable
human initialize/doctor/run/inspect/materialize/validate/launch surface,
operation classification/registry, and progressive-adoption guide. Deployment
and later layers remain unauthorized.

For every meaningful iteration, update
`docs/architecture/platform-implementation-record.md` with the planned
objective, actual work, old assets used/adapted, new clean work, decisions,
surprises, deviations, validation, later implications, and next task. Update
the architecture or plan explicitly if evidence changes them.

## Architectural boundaries

- Local source implementations own source interpretation and stop at the
  canonical handoff.
- Generic runtime never depends on a named implementation or source system.
- Estimands own quantity semantics; providers declare and conform to them.
- Risk and decision/priority policy remain separate.
- Tasks and interventions remain separate.
- Operational history is append-oriented and distinct from products.
- Products are logical, versioned interfaces independent of storage.
- The app consumes products and does not query sources or invoke providers.
- Deployment targets package stable runtime interfaces and do not alter
  upstream semantics.
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

Read `docs/operations/operator-manual.md` before platform operation. Invoke its
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
run the reference platform once
    → Rscript operations/run-platform.R --profile reference --scale test
inspect reference history
    → Rscript operations/inspect-reference-history.R --scale test
materialize reference products
    → Rscript operations/build-reference-products.R --scale test --materialize
validate the reference app
    → Rscript operations/launch-reference-app.R --validate-only
launch the reference app
    → Rscript operations/launch-reference-app.R
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
`docs/operations/validation.md`. During intentional work, run:

```sh
Rscript operations/validate.R --mode development
```

For the completed Phase 7 checkpoint, run:

```sh
Rscript operations/validate.R --mode checkpoint
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

Run the focused human-operation tests and stable reference workflow with:

```sh
Rscript tests/run-phase7-tests.R
Rscript operations/initialize-platform.R
Rscript operations/doctor.R
Rscript operations/run-platform.R --profile reference --scale test
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
and `operations/operations.yml`. Deployment, replay, decision
policy, scheduling, observability, and later capabilities remain unauthorized
until their phases.

Update versions, tests, examples/configuration, human documentation, and the
implementation record together when changing a contract, estimand, provider,
policy, record, product, operation, or deployment interface. Keep current
maturity and fictional/nonclinical limitations explicit.

Never put PHI, patient-level clinical values, credentials, connection strings,
raw records, private hospital mappings, or confidential business material in
the repository or ordinary diagnostics.
