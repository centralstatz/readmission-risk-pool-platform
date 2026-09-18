# `rrpruntime`

`rrpruntime` is the dependency-light internal R package owner for
implementation-neutral Readmission Risk Pool runtime responsibilities. Its
package version is `0.3.0.9000`, independently of the RRP product development
identity `1.0.0-dev`.

The package uses only base R package machinery and exports exactly two
technical interfaces:

- `rrp_admit_canonical_bundle(candidate, expected_context)` validates the
  closed source-independent canonical handoff and returns a detached admitted
  bundle; and
- `rrp_prepare_episode_state(admitted_bundle, episode_id, as_of_time,
  expected_context)` enforces the one remaining day-30 readmission-risk
  target's cutoff and eligibility rules and returns one detached minimal state
  for an eligible episode.

Admission enforces the initial discharge-episode and terminal-event key,
relationship, cardinality, explicit-offset timestamp, dual-time, and exact
30-elapsed-day rules. State preparation requires the analytical instant to be
the same instant as the admitted bundle cutoff, includes discharge but excludes
the day-30 endpoint, and rejects an already readmitted or dead episode without
creating a risk request or estimate.

Expected admission failures inherit from `rrp_canonical_error`; expected target
and state failures inherit from `rrp_runtime_error`. Both carry a stable bounded
`code` and fixed privacy-safe message and never render canonical values or
identifiers. The package does not know a project root, load installed resources,
access a source, execute a producer or provider, construct a risk request or
estimate, or persist state.

The package is internal software source. It is not the RRP product, an operator
interface, or evidence that RRP 1.0 is installed, released, or clinically
validated.
