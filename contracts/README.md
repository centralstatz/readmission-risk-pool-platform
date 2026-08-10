# Platform specifications

This directory owns language-neutral, machine-readable platform
specifications. Phase 1 established the common specification envelope and
identity vocabulary. Phase 2 adds the generic canonical handoff container and
the first readmission-specific clinical profile.

- `foundation/` contains the common vocabulary specification.
- `examples/` contains small, nonclinical teaching and validation fixtures.
- `canonical/` contains the generic bundle, three clinical domain contracts,
  two controlled vocabularies, the initial profile, generic examples, and a
  source-independent fictional clinical fixture.

The first profile is documented in
[Initial canonical clinical profile](../docs/architecture/canonical-clinical-profile.md).
It is intentionally smaller than the future canonical suite. Future canonical,
estimand, provider, derived-record,
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
