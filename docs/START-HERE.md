# Start here

The repository contains an immutable released `v0.1.0` implementation and the
authoritative target architecture for RRP 1.0.0. Read authority before
implementation detail: assessments explain decisions, and Phase 0–11 documents
describe history rather than the forward development hierarchy.

## Recommended review

1. [Platform True North](vision/platform-true-north.md) — what the platform is
   and the durable tests for future changes.
2. [Platform Architecture](architecture/platform-architecture.md) — where
   the authoritative RRP 1.0.0 software, project, target, runtime, state,
   deployment, upgrade, and validation responsibilities now live.
3. [Platform Implementation Plan](architecture/platform-implementation-plan.md)
   — completed historical `v0.1.0` Phase 0–11 plan. Do not use it as the RRP
   1.0.0 implementation sequence; the replacement plan is the next task.
4. [Specification Foundation](architecture/specification-foundation.md),
   [Canonical Bundle Foundation](architecture/canonical-bundle-foundation.md),
   and [Initial Canonical Clinical Profile](architecture/canonical-clinical-profile.md)
   — the common identity vocabulary and current generic and clinical handoff
   semantics.
5. [Platform Specifications](../contracts/README.md) — machine-readable
   contracts and nonclinical conformance examples.
6. [Synthetic Reference Implementation](architecture/synthetic-reference-implementation.md)
   — the complete deterministic fictional producer beneath that boundary.
7. [Canonical Producer Foundation](architecture/canonical-producer-foundation.md)
   — the declaration, trust, installation selection, generic execution,
   admission, conformance, and two-producer substitution evidence above source
   implementations.
8. [Runtime Foundation](architecture/runtime-foundation.md) — the admitted
   canonical-to-eligibility/state/request computation above the boundary.
9. [Provider and Estimate Foundation](architecture/provider-foundation.md) —
   provider trust, exact selection, compatibility, execution, and accepted
   estimate semantics.
10. [Operational History Foundation](architecture/operational-history-foundation.md)
   — run lifecycle, persisted families, retries, corrections, and logical
   persistence ports.
11. [DuckDB Reference Persistence](architecture/duckdb-reference-persistence.md)
   — the concrete local adapter, physical tradeoffs, atomicity, and recovery.
12. [Logical Product Foundation](architecture/logical-product-foundation.md) —
   first suite, identity/freshness, compatibility/failure behavior, builders,
   conformance, and application access.
13. [Reference Product Materialization](architecture/reference-product-materialization.md)
   and [Minimal Product-Only Application](architecture/reference-application.md)
   — atomic physical access and the supplied consumer boundary.
14. [Local Reference Platform Operator Manual](operations/operator-manual.md)
   and [Progressive Implementation](adoption/progressive-implementation.md) —
   operate the reference composition and understand each replacement boundary.
15. [Target-Neutral Application Artifact](architecture/application-artifact-foundation.md)
   and [Application Artifact Operations](operations/application-artifacts.md) —
   understand the closed runtime unit before any target realization.
16. [Connect Cloud Git Realization](architecture/connect-cloud-realization.md)
   and [Connect Cloud Deployment Operations](operations/connect-cloud-deployment.md)
   — understand the generated local repository and external publication stop.
17. [Observability Foundation](architecture/observability-foundation.md) and
   [Operational Diagnostics](operations/observability-and-diagnostics.md) —
   understand correlation, privacy guardrails, console events, and non-goals.
18. [Reference Asset Reconciliation](architecture/reference-asset-reconciliation.md)
   — which old assets appear useful and why none controls the design.
19. [Open Decisions](architecture/open-decisions.md) — choices that require
   maintainer decisions in the historical Phase plan; the 1.0.0 plan will
   establish the active decision register.
20. [Distribution and First-Release Assessment](architecture/distribution-release-assessment.md)
   — the Phase 11.1 options, evidence, deliberate deferrals, and release gaps
   that preceded maintainer decisions.
21. [Hospital-Facing Implementation Distribution](architecture/hospital-implementation-distribution-assessment.md)
   — the historical `v0.1.0` one-repository/two-release-product model, exact
   embedded Platform release, environment, composition, and generated proofs.
22. [Installed RRP and Independent Project Architecture Assessment](architecture/installed-software-project-model-assessment.md)
   — supporting evidence for installed software, independent projects, and
   reusable boundaries; later target/package conclusions supersede parts of it.
23. [Governance and Validation Architecture Assessment](architecture/governance-validation-architecture-assessment.md)
   — supporting evidence for proportional validation, lifecycle ownership,
   authority simplification, and historical Phase status.
24. [Installed Software Boundary and Minimum RRP Project Contract Assessment](architecture/installed-software-project-contract-assessment.md)
   — retained ownership/dependency trace; its provisional user-facing package
   topology is superseded by the current architecture.
25. [Estimand Composition and Trusted Project Registration Assessment](architecture/estimand-composition-project-registration-assessment.md)
   — the retained superseded precursor that assessed a selectable supplied
   estimand, trusted registration, provider routing, and compatibility.
26. [Platform-Defined Readmission-Risk Target Assessment](architecture/readmission-risk-target-assessment.md)
   — accepted decision evidence for one explicit nonselectable remaining
   cumulative 30-day risk target and provider-focused extension.
27. [Software Distribution, Dependency, and Build-Reproducibility Assessment](architecture/software-distribution-build-reproducibility-assessment.md)
   — accepted decision evidence for the RRP software boundary, internal packages,
   host-R roles, project dependency ownership, closed builds, and deployments.
28. [Hospital Implementation Distribution Operations](operations/hospital-implementation-distribution.md)
   — historical `v0.1.0` build/validation operation for its proof artifact.
29. [Standalone Hospital Implementation Git Realization](operations/hospital-git-realization.md)
   — historical generation/validation of the pristine staged form, stopping
   before commit, remote, tag, push, or publication.
30. [Maintainer Release Preparation](operations/release-preparation.md) and
   [Apache-2.0 Compatibility Review](architecture/release-license-review.md) —
   historical preparation and governance evidence for exact `v0.1.0` candidates.
31. [Maintainer Release Publication](operations/release-publication.md) —
   historical zero-mutation preflight, explicit GitHub mutation boundary,
   partial-failure recovery, and remote verification.
32. [Platform Implementation Record](architecture/platform-implementation-record.md)
   — what has actually been done, validated, and learned.
33. [Implementation Conventions](development/implementation-conventions.md) and
   [AGENTS.md](../AGENTS.md) before making changes.
34. [Repository Development Policies](development/repository-policies.md) for
   licensing, version bookkeeping, privacy, fixtures, tests, and dependencies.
35. [Operations](operations/README.md) for supported human operations and
   [Validation](operations/validation.md) for exact commands.

## Reading rule

Target statements describe intended capability, not current functionality.
Use the implementation record and repository contents to determine current
state. The sibling reference repository may explain old behavior but cannot
override these documents or become a runtime dependency.
