# Platform specifications

This directory owns language-neutral, machine-readable platform
specifications. Phase 1 established the common specification envelope and
identity vocabulary. Phase 2 added the canonical handoff and first clinical
profile. Phase 4 added runtime records, the first estimand, governed provider
execution, and accepted estimates. Iteration 5.1 adds operational run,
invalidation, and persistence-adapter semantics.

- `foundation/` contains the common vocabulary specification.
- `examples/` contains small, nonclinical teaching and validation fixtures.
- `canonical/` contains the generic bundle, three clinical domain contracts,
  two controlled vocabularies, the initial profile, generic examples, and a
  source-independent fictional clinical fixture.
- `runtime/` contains eligibility, minimal episode-state, first estimand,
  provider-neutral request, provider declaration/adapter/result, accepted
  estimate, and the shipped reference-provider specifications.
- `persistence/` contains backend-independent operational run, invalidation,
  and adapter capability contracts. It contains no connection or storage
  configuration.

The first profile is documented in
[Initial canonical clinical profile](../docs/architecture/canonical-clinical-profile.md),
the Phase 4 provider boundary is documented in
[Provider and estimate foundation](../docs/architecture/provider-foundation.md),
and operational history is documented in
[Operational history foundation](../docs/architecture/operational-history-foundation.md).
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
