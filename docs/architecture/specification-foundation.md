# Specification and identity foundation

## Status and scope

**Status:** authoritative Phase 1 foundation vocabulary

This vocabulary follows [Platform True North](../vision/platform-true-north.md),
the [Platform Architecture](platform-architecture.md), and the
[Implementation Plan](platform-implementation-plan.md).

This document defines the common envelope and logical vocabulary that later
canonical, estimand, provider, derived-record, product, diagnostic,
configuration, and deployment specifications must share. It does not define
any of those domain-specific contracts.

The machine-readable examples live under [`contracts/`](../../contracts/README.md).
The current R validator proves these conventions but remains a Phase 1
implementation detail under `operations/lib/`; it is not the future runtime
package or a universal schema engine.

## Selected authoring format

Platform specifications use one human-authored format: **YAML**.

| Concern | YAML | JSON |
|---|---|---|
| Human authoring | Concise and readable | More punctuation and quoting |
| Review and Git diffs | Clear for small mappings/lists | Clear but noisier |
| Comments | Supported | Not supported by the standard |
| Language neutrality | Broad support | Broad support |
| Machine validation | Requires a parser and explicit rules | Requires a parser and explicit rules |
| R dependency | Small `yaml` package | Typically `jsonlite` or another parser |

YAML is selected because specifications are maintained by humans, benefit from
comments, and should be immediately teachable in review. JSON would not remove
the parser dependency and would sacrifice comments. Only YAML is accepted as
authoritative specification source; equivalent JSON copies are not maintained.

YAML syntax is not semantic validation. Every specification still passes the
common envelope validator and later kind-specific conformance.

The external `yaml` R package is therefore justified. This repository owns its
own `renv` state; no lockfile or dependency state is copied from the sibling
repository.

## Common specification envelope

Every machine-readable specification begins with:

```yaml
specification_kind: foundation_example
specification_id: reference.small-example
specification_version: "0.1.0"
specification_format_version: "1.0.0"
identity_scope: reference
title: Small example
status: experimental
description: Optional concise explanation.
```

### Required fields

| Field | Meaning |
|---|---|
| `specification_kind` | Stable type that selects kind-specific semantics and validation |
| `specification_id` | Stable logical ID within its kind and identity scope |
| `specification_version` | Semantic version of the meaning owned by this specification |
| `specification_format_version` | Version of the common YAML envelope syntax understood by the reader |
| `identity_scope` | Whether the identity is `platform`, `reference`, or `implementation` owned |
| `title` | Short human-readable name |
| `status` | Maturity/lifecycle status: `experimental`, `active`, `deprecated`, or `retired` |

`description` is optional but recommended where title and kind do not make the
purpose evident.

IDs use lowercase letters and numbers separated by `.`, `_`, or `-`. Platform
IDs identify generally owned platform meaning. Reference defaults use the
`reference.` namespace and `identity_scope: reference`; they are examples or
defaults, not universal platform identities. Adopter/local specifications use
`identity_scope: implementation` and an approved stable namespace.

The current format version is `1.0.0`. Readers fail closed on another format
version. Format version describes envelope syntax, not product release or the
meaning of a particular specification.

## Pre-1.0 specification compatibility

Specification versions use quoted Semantic Versioning strings such as
`0.1.0`. Optional prerelease/build suffixes follow SemVer syntax. Do not use the
old `0.1.0-draft` convention: maturity belongs in `status`, not in an
unstructured version suffix.

Before `1.0.0`, stability is intentionally limited:

- a **patch** increment may clarify documentation, correct a nonsemantic error,
  or add optional metadata whose absence has an explicit safe interpretation;
- a **minor** increment may change required fields, controlled semantics,
  validation, or consumer behavior incompatibly;
- a **major** increment remains available for a deliberately new contract
  generation, but `0.y.z` consumers must not infer stability from a shared
  major zero.

A change is incompatible when it removes or renames a field, changes a type,
identity/key, time meaning, requiredness, controlled-value meaning, failure
behavior, or another semantic invariant. Adding a required field is
incompatible. Adding an optional field or vocabulary value is compatible only
when existing consumers explicitly tolerate unknown/absent values safely.

Consumers declare support by specification kind/ID, exact format versions, and
an explicit specification-version range. They must not use an unbounded
“version greater than” rule. An unknown format version, major version, or newer
pre-1.0 minor line fails as unsupported unless the consumer explicitly declares
support. A newer patch within a declared patch-compatible line may be accepted.

Deprecation uses `status: deprecated` and should identify a supported successor
in kind-specific metadata. `retired` means the specification cannot be newly
selected. Deprecation does not delete historical identity or provenance.

Phase 11 will define platform release governance. This policy governs
specification compatibility only.

## As-of context

`as_of_time` is the one authoritative information cutoff for a run or request.
It answers:

> What information was the platform permitted to treat as known for this
> computation?

It is an RFC 3339 timestamp with an explicit `Z` or numeric UTC offset. A run
has exactly one authoritative as-of time. Components may derive local displays,
but they do not independently choose new cutoffs inside the same run.

As-of time differs from:

- **event occurrence time:** when an event happened in the represented world;
- **recorded/available time:** when the source or platform could know the event;
- **source extraction time:** when source content was read;
- **generation time:** when an object or artifact was produced; and
- **execution wall-clock time:** when code actually ran.

Those timestamps may be later than the as-of cutoff and do not replace it.
Later domain contracts will define event availability and episode rules. This
foundation defines only the shared cutoff meaning.

## Implementation and mapping identity

Implementation identity and mapping identity answer different questions:

```text
implementation_id + implementation_version
    Which source-interpretation implementation was active?

mapping_id + mapping_version
    Which mapping semantics produced this representation?
```

Both are stable logical IDs plus SemVer versions. They work for synthetic R,
hospital SQL, dbt, warehouse views, Python, or another conforming technology.
Technology, package, source revision, and query location may appear in optional
provenance evidence; they are not part of logical identity.

Neither identity contains credentials, arbitrary executable code, local paths,
or a mandatory Git commit. Changing mapping meaning requires a new mapping
version even if the implementation package or repository revision is
unchanged.

## Run and operation identity

The foundational run context distinguishes:

- `run_id` — unique identity for one attempted platform run;
- `operation_id` — stable identity of the operation being attempted; and
- `as_of_time` — the authoritative information cutoff for its computation.

An operation ID groups comparable actions such as specification validation. A
run ID distinguishes attempts of that operation. A retry may retain a separate
attempt/run ID while later persistence policy links it to an idempotency or
retry identity. Phase 5 will define new-run, retry, duplicate, correction, and
restatement persistence semantics.

Changing as-of time, selected implementation, mapping, provider, or other
declared computational identity must remain attributable even when an operation
name is unchanged. Git commits may be optional provenance but never universal
run IDs.

## Capability status

Future capability IDs are phase-owned. This iteration defines only status:

| Status | Meaning |
|---|---|
| `available` | The component supplies the capability in the active context and applicable conformance passed |
| `unavailable` | The component can support the capability in principle, but the active instance/configuration/input does not currently supply it |
| `unsupported` | This component type/version intentionally does not implement the capability |
| `failed_conformance` | The capability was claimed or supplied but failed an applicable software-contract check |

`unavailable` is contextual; `unsupported` is a declared limitation;
`failed_conformance` is invalid claimed behavior. Consumers must not translate
any of those three states into a fabricated value or silent zero. Unknown
statuses fail validation.

## Provenance references

A minimal provenance reference contains:

- `provenance_type` — kind of evidence or provenance record;
- `provenance_id` — stable identity of that record;
- `relationship` — how the current object relates to it; and
- optional `version_or_revision` — a version meaningful to that provenance
  system.

Hashes, Git commits, URLs, object-store keys, database identifiers, and file
paths may be optional evidence inside a later provenance record. They are not
universal provenance or object identity. References point to evidence; they do
not embed credentials or arbitrary executable locations.

## Structured conformance results

Conformance asks whether a candidate satisfies a software specification. A
result contains:

- `overall_status`: `pass` or `fail`;
- candidate identity when available;
- the specification identity evaluated against;
- zero or more issues, each with a rule ID, severity, machine-readable issue
  code, concise message, and optional object/path/location context.

`error` issues derive `overall_status: fail`; warnings and informational issues
do not fail by themselves. Validators collect multiple issues rather than stop
at the first malformed field. Overall status is derived, never trusted from an
independent manually supplied flag.

Software conformance does not establish clinical validity, calibration,
fairness, effectiveness, safety, regulatory status, or production approval.

## Initial diagnostic-event vocabulary

The future diagnostic envelope reserves these logical concepts:

- `event_timestamp`;
- `run_id`;
- `operation_id`;
- `component` and `stage`;
- `severity`;
- `status`;
- safe `diagnostic_code`; and
- human-readable `message`.

A diagnostic event explains execution. A conformance result records rule
evaluation. A provenance reference attributes an object. They may share a run
ID but are not interchangeable.

Phase 9 owns routing, sinks, verbosity, redaction mechanisms, retention,
approved record-level debugging, and observability adapters. This iteration
does not implement logging or create an audit trail.

## Authoring and ownership rules

- Keep specifications small, commented where meaning is non-obvious, and
  independent of one programming language or storage technology.
- Quote versions and timestamps so YAML parsers cannot reinterpret them.
- Keep executable validation temporarily in `operations/lib/` until Phase 4
  creates and characterizes the internal runtime package.
- Do not put R validation logic in `contracts/`; this directory remains
  language-neutral source.
- Update specification, example, policy, tests, human documentation, and the
  implementation record together for a semantic change.
- Phase 2 must use this envelope and vocabulary without copying old canonical
  domain fields or representations by default.
