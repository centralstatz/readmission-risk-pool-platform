# Documentation index

Begin with [START HERE](START-HERE.md). Current normative architecture,
supporting decision evidence, implemented `v0.1.0` documentation, and
historical release evidence have different authority.

## Current normative authority

- [Platform True North](vision/platform-true-north.md) — authoritative product
  identity, principles, ownership, and direction.
- [Platform Architecture](architecture/platform-architecture.md) —
  authoritative RRP 1.0.0 target architecture for installed software,
  independent projects, singular risk, lifecycle ownership, and migration.
- [RRP 1.0.0 Implementation Plan](architecture/platform-implementation-plan.md)
  — authoritative high-level stage order, transition strategy, and acceptance
  gates; detailed planning proceeds one stage at a time, beginning with Stage
  1 only.

## Implemented and historical `v0.1.0` boundary documentation

- [Specification Foundation](architecture/specification-foundation.md) — common
  YAML envelope, compatibility, identity, time, conformance, and diagnostic
  vocabulary.
- [Canonical Bundle Foundation](architecture/canonical-bundle-foundation.md) —
  generic bundle/instance identity, domain registration, capability,
  dependency, as-of, and representation-independent handoff semantics.
- [Initial Canonical Clinical Profile](architecture/canonical-clinical-profile.md)
  — the first supported discharge episode, baseline risk, and episode event
  contracts and their cross-domain conformance semantics.
- [Synthetic Reference Implementation](architecture/synthetic-reference-implementation.md)
  — deterministic fictional source feeds, source-local validation, mapping,
  and canonical producer boundary.
- [Canonical Producer Foundation](architecture/canonical-producer-foundation.md)
  — generic declaration/result, trusted callable registration, exact
  installation selection, admission, conformance, and the independent
  adopter-source substitution proof.
- [Runtime Foundation](architecture/runtime-foundation.md) — admitted input,
  eligibility, minimal episode state, and first estimand-request semantics.
- [Provider and Estimate Foundation](architecture/provider-foundation.md) —
  provider declaration, trust, registry, compatibility, execution outcomes,
  transparent reference method, and standardized estimates.
- [Operational History Foundation](architecture/operational-history-foundation.md)
  — persisted record families, run lifecycle, atomicity, retry, invalidation,
  raw/valid reads, and backend-independent persistence ports.
- [DuckDB Reference Persistence](architecture/duckdb-reference-persistence.md)
  — reference adapter identity, physical representation, transactions,
  deterministic reads, connection lifecycle, concurrency, and recovery.
- [Logical Product Foundation](architecture/logical-product-foundation.md) —
  first product suite, grains/keys, set identity, freshness, compatibility,
  failure semantics, builders, conformance, and logical access boundary.
- [Reference Product Materialization](architecture/reference-product-materialization.md)
  — YAML bundle adapter, atomic replacement, integrity, access, and freshness.
- [Minimal Product-Only Application](architecture/reference-application.md) —
  injected product access, Shiny views, empty states, and safe failure.
- [Target-Neutral Application Artifact](architecture/application-artifact-foundation.md)
  — reduced runtime characterization, contract/layout, identity, integrity,
  dependency, build, validation, and publication boundaries.
- [Connect Cloud Git Realization](architecture/connect-cloud-realization.md) —
  target requirements, local repository contract, dependency and Git choices,
  safe regeneration, standalone validation, and publication boundary.
- [Observability Foundation](architecture/observability-foundation.md) —
  operation-run correlation, structured events, privacy rules, callable sinks,
  console rendering, and separation from history/metrics/audit.
- [Progressive Implementation](adoption/progressive-implementation.md) —
  reference composition and source/provider/persistence/product/app replacement.

These component documents describe the released/source `v0.1.0` implementation
until each is prospectively revised under the 1.0.0 plan. They do not override
the current Platform Architecture.

## Supporting architecture assessments and decision evidence

- [Reference Asset Reconciliation](architecture/reference-asset-reconciliation.md)
  — target-first classifications of evidence in the sibling repository.
- [Distribution and First-Release Assessment](architecture/distribution-release-assessment.md)
  — retained Phase 11.1 evidence for licensing, packaging, governance,
  environment support, release gaps, and maintainer choices.
- [Hospital-Facing Implementation Distribution](architecture/hospital-implementation-distribution-assessment.md)
  — historical Iteration 11.3 decision for one maintained repository, two
  independently versioned release products, the exact embedded Platform
  release, top-level environment, trusted composition, lifecycle, and bounded
  generated-artifact and standalone Git proofs implemented in Iterations
  11.4–11.5.
- [Installed RRP and Independent Project Architecture Assessment](architecture/installed-software-project-model-assessment.md)
  — precursor assessment of replacing the generated Hospital product with
  installed software, independently owned projects, layered validation, and
  project-composable estimands and providers.
- [Governance and Validation Architecture Assessment](architecture/governance-validation-architecture-assessment.md)
  — assessment of proportional validation, lifecycle ownership,
  historical phase governance, and strict release/publication boundaries.
- [Installed Software Boundary and Minimum RRP Project Contract Assessment](architecture/installed-software-project-contract-assessment.md)
  — precursor dependency trace, installed/project ownership map,
  minimum manifest and trust boundary, packaging options, and remaining design
  decisions.
- [Estimand Composition and Trusted Project Registration Assessment](architecture/estimand-composition-project-registration-assessment.md)
  — retained superseded precursor assessing a selectable installed estimand,
  registration result, provider routing, and compatibility sequence.
- [Platform-Defined Readmission-Risk Target Assessment](architecture/readmission-risk-target-assessment.md)
  — accepted evidence for one nonselectable remaining cumulative
  30-day target, provider-focused extension, and simplified composition.
- [Software Distribution, Dependency, and Build-Reproducibility Assessment](architecture/software-distribution-build-reproducibility-assessment.md)
  — accepted evidence for the RRP software boundary, internal packages/host R,
  independent project dependencies, closed builds, and artifact closure.

## Historical release and implementation evidence

- [Hospital Implementation Distribution Operations](operations/hospital-implementation-distribution.md)
  — build, validate, initialize, and exercise the proof-only generated artifact.
- [Standalone Hospital Implementation Git Realization](operations/hospital-git-realization.md)
  — realize that validated artifact as a staged, uncommitted, remote-free
  standalone repository for later release preparation.
- [Maintainer Release Preparation](operations/release-preparation.md) and
  [Apache-2.0 Compatibility Review](architecture/release-license-review.md) —
  prepare and inspect exact unpublished `v0.1.0` candidates and the evidence
  required to stop at `READY FOR PUBLICATION`.
- [Maintainer Release Publication](operations/release-publication.md) — fixed
  GitHub targets, zero-mutation preflight, explicit publication, partial-stage
  recovery, published-state verification, and development transition.
- [Platform Implementation Record](architecture/platform-implementation-record.md)
  — append-oriented record of actual work and validation.
- [Open Decisions](architecture/open-decisions.md) — historical Phase decisions;
  the RRP 1.0.0 plan will establish the active decision register.

## Development

- [Hospital Implementation v0.1.0 Clean-Room Adoption Assessment](development/hospital-implementation-v0.1.0-adoption-assessment.md)
  — evidence from exact-release acquisition, recipient-owned source/provider/
  estimand extension attempts, and implications synthesized into RRP 1.0.0.
- [Implementation Conventions](development/implementation-conventions.md) —
  concise human-readable code and boundary conventions.
- [Repository Development Policies](development/repository-policies.md) —
  licensing status, version/change bookkeeping, privacy, fixtures, tests, and
  dependency discipline.

## Operations

- [Operations Index](operations/README.md) — currently supported human
  operations.
- [Local Reference Platform Operator Manual](operations/operator-manual.md) —
  initialize, doctor, run, inspect, materialize, validate, launch, repeat, and
  troubleshoot without AI.
- [Validation](operations/validation.md) — exact development, checkpoint,
  documentation, and Phase 0–10 test commands.
- [Operational Diagnostics](operations/observability-and-diagnostics.md) —
  interpret structured console events, privacy limits, failure recovery, and
  focused validation.
- [Generate Reference](operations/generate-reference.md) — run the complete
  fictional source-to-canonical producer without writing generated data.
- [Run Reference Runtime](operations/run-reference-runtime.md) — exercise
  canonical admission through eligibility, state, and estimand request.
- [Run Reference Estimation](operations/run-reference-estimation.md) — execute
  the exact registered transparent provider and validate accepted estimates.
- [Durable Reference History](operations/reference-history.md) — initialize,
  run, persist, inspect, back up, and recover fictional DuckDB history.
- [Build, Materialize, and Launch Products](operations/logical-products.md) —
  build/inspect in memory or publish atomically, validate access, and launch
  the fictional app.
- [Build and Validate Application Artifacts](operations/application-artifacts.md)
  — construct the local target-neutral artifact and prove isolated startup.
- [Generate and Validate a Connect Cloud Repository](operations/connect-cloud-deployment.md)
  — create the standalone local Git deployment output and stop before remote
  publication.

## Specifications

- [Platform Specifications](../contracts/README.md) — machine-readable
  foundation, canonical, runtime, provider, execution-result, estimate,
  operational-history, and logical-product contracts.

## Repository guidance

- [Root README](../README.md) — project identity, status, and navigation.
- [Agent Guidance](../AGENTS.md) — human-first, target-first working agreement.

Further target-specific realization and release guides will be added only in
phases that create those capabilities. Publication remains maintainer
controlled through the tested explicit operation. Documentation must not claim
an operation exists before it has a tested human implementation.
