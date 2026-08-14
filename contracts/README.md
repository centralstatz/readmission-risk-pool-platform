# Platform specifications

This directory owns language-neutral, machine-readable platform
specifications. Phase 1 established the common specification envelope and
identity vocabulary. Phase 2 added the canonical handoff and first clinical
profile. Phase 4 added runtime records, the first estimand, governed provider
execution, and accepted estimates. Iteration 5.1 adds operational run,
invalidation, and persistence-adapter semantics. Iteration 5.2 leaves these
contracts unchanged while proving them through a concrete implementation
outside this directory. Iteration 6.1 adds the first three logical products and
their coherent product-set contract. Iteration 6.2 adds the storage-neutral
product-materialization adapter contract; its YAML realization stays under
`implementations/`. Iteration 8.1 adds the target-neutral reduced application
artifact contract; Iteration 8.2 adds its first target-specific local Git
realization contract.
Iteration 9.1 adds distinct operation-run context and operational diagnostic
event contracts; it adds no history, metric, audit, routing, or retention
contract.
Iteration 10.1 adds `platform.canonical-producer@0.1.0` declaration, trusted
callable, result, failure, and configuration-ownership semantics without
changing canonical clinical meaning.

- `foundation/` contains the common vocabulary specification.
- `examples/` contains small, nonclinical teaching and validation fixtures.
- `canonical/` contains the generic bundle, three clinical domain contracts,
  two controlled vocabularies, the initial profile, generic examples, and a
  source-independent fictional clinical fixture, and the generic canonical-
  producer contract.
- `runtime/` contains eligibility, minimal episode-state, first estimand,
  provider-neutral request, provider declaration/adapter/result, accepted
  estimate, and the shipped reference-provider specifications.
- `persistence/` contains backend-independent operational run, invalidation,
  and adapter capability contracts. It contains no connection or storage
  configuration.
- `products/` contains the current-risk, persisted-risk-history, operational
  run-summary, required core-set, and storage-neutral materialization-adapter
  contracts. It selects no file, database, or application implementation.
- `deployment/` contains the target-neutral reduced application-artifact
  contract and the Connect Cloud local Git realization. Neither defines a
  remote, publication identity, service credential, or container target.
- `observability/` contains the operation-attempt correlation context and
  privacy-conscious structured diagnostic event contracts. It contains no
  patient payload, sink configuration, or retention policy.

The first profile is documented in
[Initial canonical clinical profile](../docs/architecture/canonical-clinical-profile.md),
the Phase 4 provider boundary is documented in
[Provider and estimate foundation](../docs/architecture/provider-foundation.md),
and operational history is documented in
[Operational history foundation](../docs/architecture/operational-history-foundation.md).
The non-normative DuckDB realization is documented in
[DuckDB reference persistence](../docs/architecture/duckdb-reference-persistence.md).
The first history-backed consumer boundary is documented in
[Logical product foundation](../docs/architecture/logical-product-foundation.md).
The physical reference is documented in
[Reference product materialization](../docs/architecture/reference-product-materialization.md).
The target-neutral runtime unit is documented in
[Application artifact foundation](../docs/architecture/application-artifact-foundation.md).
The first target realization is documented in
[Connect Cloud Git realization](../docs/architecture/connect-cloud-realization.md).
The diagnostic boundary is documented in
[Observability foundation](../docs/architecture/observability-foundation.md).
The source composition seam is documented in
[Canonical producer foundation](../docs/architecture/canonical-producer-foundation.md).
The profile is intentionally smaller than the future canonical suite. Future
product, diagnostic, configuration, and deployment specifications must use the
common envelope defined in
[Specification foundation](../docs/architecture/specification-foundation.md).
Canonical handoff semantics are defined in
[Canonical bundle foundation](../docs/architecture/canonical-bundle-foundation.md).

YAML files are human-maintained source. Quote version and timestamp strings,
use two-space indentation, and prefer comments that explain meaning or a
non-obvious constraint. Do not put executable code, source mappings,
credentials, local paths, or implementation-specific runtime configuration in
these specifications.
