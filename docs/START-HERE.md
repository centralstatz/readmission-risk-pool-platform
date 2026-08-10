# Start here

This repository is at architecture bootstrap: understand the intended product
before looking for software that does not exist yet.

## Recommended review

1. [Platform True North](vision/platform-true-north.md) — what the platform is
   and the durable tests for future changes.
2. [Platform Architecture](architecture/platform-architecture.md) — where
   responsibilities live, how dependencies flow, and which dependencies are
   prohibited.
3. [Platform Implementation Plan](architecture/platform-implementation-plan.md)
   — how the empty repository becomes a working platform in coherent phases.
4. [Reference Asset Reconciliation](architecture/reference-asset-reconciliation.md)
   — which old assets appear useful and why none controls the design.
5. [Open Decisions](architecture/open-decisions.md) — choices that require
   maintainers at phase-appropriate checkpoints.
6. [Platform Implementation Record](architecture/platform-implementation-record.md)
   — what has actually been done, validated, and learned.
7. [Implementation Conventions](development/implementation-conventions.md) and
   [AGENTS.md](../AGENTS.md) before making changes.
8. [Repository Development Policies](development/repository-policies.md) for
   licensing, version bookkeeping, privacy, fixtures, tests, and dependencies.
9. [Operations](operations/README.md) for the supported human operation and
   [Validation](operations/validation.md) for exact commands.

## Reading rule

Target statements describe intended capability, not current functionality.
Use the implementation record and repository contents to determine current
state. The sibling reference repository may explain old behavior but cannot
override these documents or become a runtime dependency.
