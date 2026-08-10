# Initial canonical clinical profile

## Status and scope

**Status:** authoritative Phase 2.2 clinical canonical handoff contract

This document instantiates the generic
[Canonical Bundle Foundation](canonical-bundle-foundation.md) with the first
readmission-specific profile. The machine-readable specifications live under
[`contracts/canonical/`](../../contracts/canonical/profiles/readmission-initial-profile.yml).

> This is the first supported canonical profile, not a claim that the platform
> can never add other domains.

The profile establishes only the source-to-platform semantics needed for an
episode root, an immutable source baseline, and post-discharge evidence. It
does not implement eligibility, an estimand, source mapping, state, providers,
persistence, products, application behavior, deployment, or observability.

## Approved initial core

The initial core contains three independently versioned domains:

| Domain | Specification | Requirement | Available row cardinality |
|---|---|---|---|
| `discharge_episode` | `platform.canonical-discharge-episode@0.1.0` | required | one or more |
| `baseline_risk` | `platform.canonical-baseline-risk@0.1.0` | optional | zero or more |
| `episode_event` | `platform.canonical-episode-event@0.1.0` | optional | zero or more |

Together they prove the critical handoff semantics:

- the discharge episode supplies stable root identity and bounded observation;
- terminal timestamps preserve readmission and death evidence without relying
  on a source status field;
- baseline risk preserves an organization's discharge-time source score;
- episode events supply longitudinal evidence with occurrence and availability
  as separate times; and
- both child domains prove explicit episode foreign keys.

`workflow_task`, `intervention`, `measure_membership`, and `feature_value` are
deferred. None is required to establish the first handoff. Tasks and
interventions belong to later operational semantics; measure membership is not
the organizing data model; features are provider inputs rather than a required
universal source domain.

## Capability and row-cardinality semantics

Each domain has a one-to-one capability declaration:

| Domain | Capability |
|---|---|
| `discharge_episode` | `platform.discharge-episode` |
| `baseline_risk` | `platform.baseline-risk-input` |
| `episode_event` | `platform.episode-event-history` |

The root domain and capability are required and must be `available`. Baseline
risk is optional because generic operation may later use a conforming provider
that does not require a source baseline. Episode events are optional because a
valid episode may have no observed post-discharge events and because an
implementation may deliberately omit event-history support.

Status and row count answer different questions:

- `available` means a conforming domain instance is supplied. An optional
  available instance may contain zero records.
- `unavailable` means the implementation recognizes the domain but cannot
  supply it for this handoff. It has no instance or payload.
- `unsupported` means the implementation deliberately does not implement the
  domain. It has no instance or payload.
- `failed_conformance` identifies a supplied or claimed item that failed and
  causes admission failure.

Thus an available `episode_event` payload with zero records means “event
history is supported and no event is currently known,” not “event history is
unavailable.” An available baseline payload may likewise have zero rows; the
profile does not fabricate a baseline for every episode.

## Discharge episode root

`episode_id` is the canonical primary key. It is stable across one handoff and
later references; a patient may have multiple episodes. `patient_id` is a
stable local lineage identifier, and `index_encounter_id` identifies the
source encounter associated with the discharge. Their construction and
resolution belong to the source implementation. Neither field creates a
canonical Patient or Encounter domain or an enterprise identity model.

The required temporal fields are `admission_time`, `discharge_time`, and
`followup_window_end`. They enforce:

```text
admission_time < discharge_time < followup_window_end
```

Optional `readmission_time` and `death_time` are terminal evidence. When
present, each must be strictly after discharge and no later than the follow-up
window end. If both are present, readmission may precede or coincide with
death but may not follow death. The first applicable terminal timestamp can
later govern eligibility or an estimand; Phase 2 does not derive that logic.

There is deliberately no authoritative `episode_status`. Terminal behavior is
timestamp-based, preventing a mutable source label from silently overriding
the observation facts.

## Immutable baseline risk

The baseline primary key is:

```text
episode_id + source_model_id + source_model_version + score_time
```

This permits multiple explicitly identified source models or versions without
implicit row ordering. It prohibits duplicate observations of the same source
score identity.

`source_model_id` and `source_model_version` identify an Epic score, local
model, vendor score, hospital rule, or research model supplied as input. They
are intentionally not future `provider_id` and `provider_version` values. A
platform provider estimates a governed platform quantity; a baseline source
preserves externally supplied meaning.

Every row declares one `value_type` and populates exactly its matching value:

| `value_type` | Populated field | Rule |
|---|---|---|
| `probability` | `probability` | finite and between 0 and 1 inclusive |
| `numeric_score` | `numeric_score` | finite; source range remains source-owned |
| `category` | `category` | non-empty source-defined string |

No row may omit all representations or populate more than one. The canonical
boundary does not calibrate, normalize, translate, or compare these forms.

`score_time` states when the score applies and must fall within the index
encounter through discharge. `available_at` states when the platform could
know it and must be at or after `score_time` and at or before bundle
`as_of_time`. A baseline may arrive after discharge: it remains valid input but
cannot influence an earlier run. This preserves late-arriving source evidence
without pretending it was known at discharge.

## Episode event

The event primary key is `event_id`; `episode_id` is required lineage to the
root. The minimal record contains controlled `event_type`, occurrence
`event_time`, availability `available_at`, and an optional opaque
`source_reference_id`. It deliberately has no arbitrary numeric/text EAV
fields, lifecycle status, task state, or intervention payload.

For admitted records:

```text
discharge_time <= event_time <= followup_window_end
event_time <= available_at <= bundle as_of_time
```

The domain is specifically an episode-window event domain, so evidence outside
that interval is rejected rather than retained as broader patient history.
Candidate future events are also rejected: because availability cannot precede
occurrence and admitted information must be available by as-of, occurrence is
necessarily at or before as-of. Runtime code therefore does not have to guess
whether a future candidate was intended for later use.

The initial event vocabulary is intentionally small:

- `care_transition_contact`;
- `followup_visit`;
- `emergency_department_visit`;
- `medication_issue`;
- `hospital_readmission`; and
- `death_notification`.

It supports the first fictional fixture without claiming completeness. New
platform values require a new minor specification line, definitions, mapping
evidence, and conformance updates; arbitrary implementation values fail
closed.

## Relationships and cardinalities

Both child domains require the root capability when they are available:

```text
baseline_risk.episode_id ──→ discharge_episode.episode_id
episode_event.episode_id ──→ discharge_episode.episode_id
```

One episode has zero or more baseline rows, with uniqueness enforced by the
compound source-score key. One episode has zero or more event rows, each with
a globally unique event ID within the domain instance. Child rows without a
resolving episode fail conformance.

## Requiredness, nullability, and extensions

Required non-null fields carry identity, relationships, and governed time.
Terminal timestamps and source reference IDs are optional and nullable.
Baseline value fields are optional individually but conditionally require
exactly one populated representation.

All three `0.1.0` domain contracts reject unknown fields. Public fields are
governed; implementation-specific source columns stay below the canonical
boundary. No extension container is defined yet. A later extension mechanism
must have concrete portability evidence and requires a new minor specification
line rather than permissive additional fields.

## Independent fixture and conformance

`reference.readmission-initial-profile-valid@0.1.0` begins directly at the
canonical handoff and is visibly fictional and nonclinical. It contains two
episodes for one fictional patient, one baseline record, two events with one
delayed availability timestamp, an episode with zero events, and one
readmission terminal outcome. It does not invoke or import a synthetic source
implementation.

The temporary executable realization embeds records solely for conformance
testing. The validator resolves payloads by logical instance ID, applies field,
type, nullability, vocabulary, primary-key, conditional, relationship, window,
terminal, and as-of rules, and returns all discovered issues in the Phase 1
structured result. YAML, R lists, files, tables, and services remain
representation choices rather than public contract meaning.

## Deliberate differences from sibling evidence

The field/rule-level review retained stable episode and child keys, compound
baseline identity, and dual event/recorded time as adapted semantics. The clean
contracts deliberately differ as follows:

| Sibling evidence | Clean decision |
|---|---|
| draft schemas without the common envelope | independent common-envelope `0.1.0` specifications |
| `additional_fields_allowed: true` | unknown fields rejected; extensions deferred |
| required `episode_status` | removed; terminal timestamps govern facts |
| facility, service, disposition, care-team fields | deferred because the first handoff does not require them |
| optional terminal timestamps without executed ordering | bounded and ordered terminal rules enforced |
| `model_id`/`model_version` | renamed `source_model_id`/`source_model_version` to distinguish provider identity |
| prediction interval, calibration, and source-system fields | deferred; not required to preserve a source baseline value |
| advisory “at least one” baseline rule | exact-one typed representation enforced |
| baseline `generated_at` inherited as discharge-time rule | `available_at` may be later than discharge but cannot affect an earlier run |
| event subtype/status/numeric/text EAV fields | removed from the initial bounded event record |
| 16 draft event values including task/intervention concepts | six narrowly approved evidence values |
| seven mandatory R-list members, including typed empty tables | three explicit domain/capability statuses separate from row cardinality |

No sibling schema, fixture, validator code, version, or text was copied. The
existing **Adapt** classifications remain accurate.

## Compatibility and phase boundary

The profile, each domain, and each vocabulary own independent `0.1.0` meaning
versions under the Phase 1 pre-1.0 policy. Semantic, key, requiredness,
temporal, vocabulary, or failure changes require a new minor line and explicit
consumer support. Unknown versions fail closed.

With this profile, Phase 2 supplies its planned schemas, vocabularies, bundle
identity, capabilities, conformance layers, representation-neutral interface,
independent fixture, and compatibility/failure evidence. Phase 2 is complete.
Phase 3 may now build the deterministic fictional source and mapping that
produce this same public handoff; it must not change generic behavior based on
the implementation identity.

