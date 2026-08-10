# Platform specifications

This directory owns language-neutral, machine-readable platform
specifications. Phase 1 establishes only the common specification envelope,
identity vocabulary, and generic examples needed by later contract kinds.

- `foundation/` contains the common vocabulary specification.
- `examples/` contains small, nonclinical teaching and validation fixtures.

There are no canonical clinical-domain schemas here yet. Future canonical,
estimand, provider, derived-record, product, diagnostic, configuration, and
deployment specifications must use the common envelope defined in
[Specification foundation](../docs/architecture/specification-foundation.md).

YAML files are human-maintained source. Quote version and timestamp strings,
use two-space indentation, and prefer comments that explain meaning or a
non-obvious constraint. Do not put executable code, source mappings,
credentials, local paths, or implementation-specific runtime configuration in
these specifications.
