# Documentation index

The documentation is the active product at this bootstrap stage. Begin with
[START HERE](START-HERE.md) for the recommended reading order.

## Vision

- [Platform True North](vision/platform-true-north.md) — authoritative product
  identity, principles, ownership, and direction.

## Architecture and implementation

- [Platform Architecture](architecture/platform-architecture.md) — clean
  layers, interfaces, structure, dependencies, and prohibited dependencies.
- [Platform Implementation Plan](architecture/platform-implementation-plan.md)
  — phased clean-build sequence and exit evidence.
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
- [Reference Asset Reconciliation](architecture/reference-asset-reconciliation.md)
  — target-first classifications of evidence in the sibling repository.
- [Platform Implementation Record](architecture/platform-implementation-record.md)
  — append-oriented record of actual work and validation.
- [Open Decisions](architecture/open-decisions.md) — maintainer decisions and
  the phases in which they become material.

## Development

- [Implementation Conventions](development/implementation-conventions.md) —
  concise human-readable code and boundary conventions.
- [Repository Development Policies](development/repository-policies.md) —
  licensing status, version/change bookkeeping, privacy, fixtures, tests, and
  dependency discipline.

## Operations

- [Operations Index](operations/README.md) — currently supported human
  operations.
- [Validation](operations/validation.md) — exact development, checkpoint,
  documentation, and Phase 0–5 test commands.
- [Generate Reference](operations/generate-reference.md) — run the complete
  fictional source-to-canonical producer without writing generated data.
- [Run Reference Runtime](operations/run-reference-runtime.md) — exercise
  canonical admission through eligibility, state, and estimand request.
- [Run Reference Estimation](operations/run-reference-estimation.md) — execute
  the exact registered transparent provider and validate accepted estimates.
- [Durable Reference History](operations/reference-history.md) — initialize,
  run, persist, inspect, back up, and recover fictional DuckDB history.

## Specifications

- [Platform Specifications](../contracts/README.md) — machine-readable
  foundation, canonical, runtime, provider, execution-result, estimate, and
  operational-history contracts.

## Repository guidance

- [Root README](../README.md) — project identity, status, and navigation.
- [Agent Guidance](../AGENTS.md) — human-first, target-first working agreement.

Contract, user, adoption, application, and deployment guides will be added in
the phases that create those capabilities. Documentation must not claim an
operation exists before it has a tested human implementation.
