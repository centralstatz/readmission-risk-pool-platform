# `rrpruntime`

`rrpruntime` is the dependency-light internal R package owner for
implementation-neutral Readmission Risk Pool runtime responsibilities. Its
package version is `0.3.0.9000`, independently of the RRP product development
identity `1.0.0-dev`.

The package uses only base R package machinery and exports exactly
`rrp_admit_canonical_bundle(candidate, expected_context)`. That function
validates one closed source-independent candidate against exact expected
bundle, project, producer, implementation, mapping, profile, capability, and
as-of facts. It enforces the initial discharge-episode and terminal-event key,
relationship, cardinality, explicit-offset timestamp, dual-time, and exact
30-elapsed-day rules and returns a detached in-memory admitted bundle.

Expected admission failures inherit from `rrp_canonical_error`, carry a stable
bounded `code` and fixed privacy-safe message, and never render candidate
values or identifiers. The package does not know a project root, load installed
resources, access a source, execute a producer or provider, evaluate target
eligibility, construct risk, or persist state.

The package is internal software source. It is not the RRP product, an operator
interface, or evidence that RRP 1.0 is installed, released, or clinically
validated.
