# Canonical bundle identity and capability foundation

## Status and scope

**Status:** authoritative generic canonical handoff contract

This document follows [Platform True North](../vision/platform-true-north.md),
the [Platform Architecture](platform-architecture.md), and the
[Implementation Plan](platform-implementation-plan.md), and extends the
[Specification Foundation](specification-foundation.md). Its machine-readable
contract and examples live under
[`contracts/canonical/`](../../contracts/canonical/canonical-bundle.yml).

This defines the generic canonical handoff architecture. The first
readmission-specific instantiation is defined separately in the
[Initial Canonical Clinical Profile](canonical-clinical-profile.md). This
document does not implement a producer or create runtime, provider,
persistence, product, application, deployment, or observability code.

## Handoff model

An implementation eventually supplies two distinct objects:

```text
candidate canonical bundle
        +
structured implementation conformance result
        ↓
generic platform admission
```

The candidate carries logical identity and declarations. The result uses the
Phase 1 multi-issue conformance vocabulary. A pre-conformance candidate does
not claim that it already passed admission; an optional result reference may
point to producer-local evidence without replacing the platform's evaluation.

## Bundle specification and bundle instance identity

These identities answer different questions:

| Identity | Meaning |
|---|---|
| `platform.canonical-bundle@0.1.0` | The versioned public contract defining bundle semantics |
| `bundle_instance_id` | One concrete handoff produced for one run and as-of context |

A bundle instance also carries:

- the bundle specification reference;
- `run_id`, `operation_id`, and authoritative `as_of_time`;
- independent implementation and mapping IDs/versions;
- domain registrations;
- capability declarations;
- simple dependency declarations;
- provenance references; and
- optional conformance-result references.

Logical identity never requires a Git commit, path, R object name, database
schema, warehouse location, storage technology, host, or source-vendor name.
Those may be implementation-specific provenance evidence.

## Domain registration and identity

A domain registration declares:

- `domain_id` — stable logical domain meaning;
- `domain_specification` — independently versioned domain contract;
- `requirement_class` — bundle/profile obligation;
- `status` — what the active implementation supplies in this context;
- `domain_instance_id` when a candidate instance was supplied;
- associated capability IDs where relevant; and
- optional temporal-field semantics.

One bundle registers a logical `domain_id` at most once. List position,
filename, table name, and R member name do not identify the domain.

Two registrations describe the same logical domain when their `domain_id` is
the same. Their domain specification versions identify revisions of that
meaning. Patch-compatible revisions on an explicitly supported pre-1.0 line
may be compatible; a different pre-1.0 minor line is incompatible until the
bundle consumer explicitly supports it. Bundle and domain versions are
independent: changing the bundle contract does not force every domain to share
its version, and a domain version does not rename the bundle.

Iteration 2.2 created the first actual domain specifications and explicit
supported lines without changing these generic registration semantics. Generic
example domains remain teaching fixtures rather than clinical contracts.

## Requirement classes and status are separate

Requirement class describes what the active bundle/profile may or must have:

| Requirement class | Meaning |
|---|---|
| `required` | Conformance requires status `available` |
| `conditional` | Becomes required when one declared domain/capability has the stated status |
| `optional` | May be supplied; absence alone does not invalidate the bundle |

The initial conditional form contains `subject_type`, `subject_id`, and
`required_status: available`. It is a small declarative dependency, not an
expression language. Provider-specific requirements remain Phase 4 work.

Status reuses the Phase 1 vocabulary without modification:

| Status | Bundle meaning |
|---|---|
| `available` | Supplied in this context and applicable conformance passed |
| `unavailable` | Recognized/supported in principle but not supplied now |
| `unsupported` | This implementation deliberately does not implement it |
| `failed_conformance` | Claimed or supplied, but applicable conformance failed |

These dimensions must not be conflated. An optional capability can be
available, unavailable, unsupported, or failed. A required capability that is
unavailable or unsupported cannot conform. A failed-conformance status always
fails admission, even for an optional item.

Unavailable and unsupported domains have no `domain_instance_id` and no
payload. They are never represented by fabricated empty data, zeroes, or fake
rows. A supplied-but-invalid domain may retain its instance identity with
`failed_conformance` so the failure remains attributable.

This separation supports later ownership:

```text
bundle/profile contract   → what may or must exist
implementation            → what it supplies or supports
provider                   → what it requires
active conformance         → whether the combination is valid
```

## Domain and capability dependencies

The first dependency model is deliberately small:

```yaml
dependency_id: reference.event-requires-entity
subject_type: domain
subject_id: reference.event
prerequisite_type: domain
prerequisite_id: reference.entity
```

It supports domain-to-domain and capability-to-capability edges. Cross-type
edges, arbitrary Boolean expressions, embedded code, and executable YAML are
not supported. IDs are unique, self-dependencies are invalid, and the graph is
acyclic.

When a subject is `available`, its declared prerequisite must exist and be
`available`. A subject that is unavailable or unsupported does not activate
its dependency. These failures remain distinct:

- **unsupported/unavailable:** an explicit implementation status;
- **missing available prerequisite:** cross-declaration dependency failure;
- **failed conformance:** claimed data or capability failed its own contract;
- **malformed declaration:** the bundle structure cannot be interpreted.

## Bundle as-of context

The bundle carries the Phase 1 run context directly. Its `as_of_time` is the
one explicit-offset RFC 3339 information cutoff for the whole handoff:

> The canonical inputs represent information the platform was permitted to
> treat as known for this run at the declared cutoff.

Rows need not share the cutoff timestamp. A source extraction, generation, or
execution time cannot silently replace it. Later domain contracts may define
occurrence, effective, recorded, available, or generated fields, but they must
relate them to this bundle-level cutoff explicitly.

## Occurrence and availability invariant

The durable invariant is:

> Information cannot influence a run before it is available to the platform.

A domain specification declares which logical fields play occurrence/effective
and availability/recorded roles. It can also state whether availability before
occurrence is impossible. The generic examples use `occurred_at` and
`available_at` only as teaching names; future domains may select different
field names.

For the test-only realization, conformance rejects:

- `available_at < occurred_at` when the domain declares
  `not_before_occurrence`; and
- information whose availability timestamp is later than the bundle
  `as_of_time`.

The validator reports future information; it does not filter or mutate it.
Runtime availability filtering begins in Phase 4.

## Conformance layering

Failures retain their owning level:

```text
implementation-local source validation
        ↓
domain conformance
        ↓
bundle structural conformance
        ↓
cross-domain and capability conformance
        ↓
generic platform admission
```

Iteration 2.1 executes generic bundle structure, declaration, dependency, and
temporal examples. Iteration 2.2 adds clinical domain and cross-domain rules.
Implementation-local validation remains producer-owned; platform admission
beyond the handoff begins with the runtime. Rule IDs such as `canonical.domain.*`,
`canonical.bundle.*`, `canonical.dependency.*`, and `canonical.temporal.*`
keep those categories visible in one common structured result.

A result can distinguish local-source failure, invalid bundle structure,
domain failure, missing dependency, false capability claim, explicit
unavailable/unsupported status, and a conforming bundle. Software conformance
does not imply clinical validity, calibration, fairness, safety, effectiveness,
regulatory status, or production approval.

## Representation independence

Valid future adapters may realize the same logical bundle as:

- named R structures;
- files plus a manifest;
- database relations;
- warehouse tables or views; or
- a service response.

Representation adapters resolve domain instance IDs to data. They do not
change bundle/domain identity, capability status, requirements, dependencies,
as-of meaning, or conformance rules.

Phase 2.1 examples optionally embed generic records under
`reference_test_realization`. This is explicitly a **reference test
realization**, not a public container API. Validation resolves payloads by
logical domain instance ID and is independent of YAML filename, sequence order,
or local path.

## Compatibility and ownership

The bundle specification owns version `0.1.0`; future domain specifications
own independent versions. Both follow the Phase 1 pre-1.0 policy. Unknown
format versions and unsupported specification lines fail closed. Optional
metadata cannot silently redefine identity, requiredness, time semantics,
status meaning, or failure behavior.

Language-neutral source remains in `contracts/`. Executable validation remains
temporarily in `operations/lib/` until Phase 4 characterizes the runtime
package API. Phase 2.1 adds no dependency beyond the existing `yaml` package.

## Clinical-profile instantiation

The first readmission-specific domain contracts:

- use the common envelope and own independent specification versions;
- register by logical domain ID rather than representation name;
- declare requirement/capability behavior rather than infer it from empty data;
- identify occurrence/effective and availability/recorded semantics;
- declare simple dependencies without executable rules;
- return structured, layered issues; and
- remain independent of the old seven-member R-list representation.

Those decisions are resolved by
[`platform.readmission-initial-profile@0.1.0`](canonical-clinical-profile.md):
one required discharge root plus optional baseline and episode-event domains.
The generic bundle remains reusable for later profiles.
