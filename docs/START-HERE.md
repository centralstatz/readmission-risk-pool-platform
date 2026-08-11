# Start here

This repository has completed its first source-to-estimate flow and defined
the operational-history ports that will retain it;
understand the intended product and public boundaries before extending it.

## Recommended review

1. [Platform True North](vision/platform-true-north.md) — what the platform is
   and the durable tests for future changes.
2. [Platform Architecture](architecture/platform-architecture.md) — where
   responsibilities live, how dependencies flow, and which dependencies are
   prohibited.
3. [Platform Implementation Plan](architecture/platform-implementation-plan.md)
   — how the empty repository becomes a working platform in coherent phases.
4. [Specification Foundation](architecture/specification-foundation.md),
   [Canonical Bundle Foundation](architecture/canonical-bundle-foundation.md),
   and [Initial Canonical Clinical Profile](architecture/canonical-clinical-profile.md)
   — the common identity vocabulary and current generic and clinical handoff
   semantics.
5. [Platform Specifications](../contracts/README.md) — machine-readable
   contracts and nonclinical conformance examples.
6. [Synthetic Reference Implementation](architecture/synthetic-reference-implementation.md)
   — the complete deterministic fictional producer beneath that boundary.
7. [Runtime Foundation](architecture/runtime-foundation.md) — the admitted
   canonical-to-eligibility/state/request computation above the boundary.
8. [Provider and Estimate Foundation](architecture/provider-foundation.md) —
   provider trust, exact selection, compatibility, execution, and accepted
   estimate semantics.
9. [Operational History Foundation](architecture/operational-history-foundation.md)
   — run lifecycle, persisted families, retries, corrections, and logical
   persistence ports.
10. [Reference Asset Reconciliation](architecture/reference-asset-reconciliation.md)
   — which old assets appear useful and why none controls the design.
11. [Open Decisions](architecture/open-decisions.md) — choices that require
   maintainers at phase-appropriate checkpoints.
12. [Platform Implementation Record](architecture/platform-implementation-record.md)
   — what has actually been done, validated, and learned.
13. [Implementation Conventions](development/implementation-conventions.md) and
   [AGENTS.md](../AGENTS.md) before making changes.
14. [Repository Development Policies](development/repository-policies.md) for
   licensing, version bookkeeping, privacy, fixtures, tests, and dependencies.
15. [Operations](operations/README.md) for supported human operations and
   [Validation](operations/validation.md) for exact commands.

## Reading rule

Target statements describe intended capability, not current functionality.
Use the implementation record and repository contents to determine current
state. The sibling reference repository may explain old behavior but cannot
override these documents or become a runtime dependency.
