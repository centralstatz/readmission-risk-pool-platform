# Platform-defined readmission-risk target assessment

## Status and scope

**Status:** focused `v0.2.0` architecture assessment and recommendation; no
risk-target implementation

This assessment narrows the prospective installed-RRP and independent-project
model described by the [installed software boundary
assessment](installed-software-project-contract-assessment.md). It supersedes
the configurable installed-estimand direction recommended by the earlier
[estimand composition assessment](estimand-composition-project-registration-assessment.md),
while retaining that document's code trace and trusted producer/provider
registration findings as evidence.

The released `v0.1.0` contracts, runtime, history, products, app, artifacts, and
release evidence remain immutable. This document does not alter code,
contracts, project loading, provider registration, state, stored data,
products, application behavior, artifacts, tags, releases, or publication.

## Executive conclusion

The next RRP implementation should define exactly one platform prediction
target. Estimands should cease to be project-configurable components: projects
should neither register nor select estimands, supply request builders, nor
configure estimand-to-provider routes. The current subsystem should be
materially simplified rather than hidden behind a singleton catalog.

The recommended canonical quantity is the **remaining cumulative probability
of first canonical readmission through the fixed 30-day post-discharge end,
conditional on being alive and free of that readmission at the current as-of
time, using only information legitimately available then**. Death should be a
competing terminal event, so this is an actual-world conditional cumulative
incidence rather than risk in a hypothetical world where death cannot occur.

Using terms defined precisely below, the recommended first contract is:

\[
  P\{t < T_R \le W_{30},\ T_R \le T_D
    \mid T_R > t,\ T_D > t,\ E_t=1,\mathcal H_t\},
\]

where `t` is the run's exact as-of instant, `W30` is 30 elapsed 24-hour days
after discharge, `T_R` is first canonical readmission, `T_D` is death, and a
same-instant readmission/death is counted as readmission to preserve the
current canonical rule. `E_t=1` means the admitted episode satisfies RRP-owned
target eligibility at `t`; absent readmission or death times are treated as
later than the target end. The target interval is `(t, W30]`.

For the first contract, “canonical readmission” must retain the current honest
limitation: it is the first `readmission_time` supplied by the admitted
canonical profile, which does not distinguish planned from unplanned
readmissions. Every admitted canonical discharge episode is in the base
population; this is not an HRRP or other measure cohort. A narrower event or
population would require canonical evidence and a new target-contract version,
not a local provider reinterpretation.

This target is more appropriate than next-day conditional hazard for the RRP
product. It directly answers the remaining-window question used by patients,
care programs, and executives while permitting providers to use survival,
daily hazards, direct cumulative-risk models, machine learning, Bayesian
updates, or compatible external scores internally. Daily hazard should leave
the public RRP contract and remain only a provider implementation primitive
when useful. No secondary hazard product is justified now.

The principal analytical extension seam becomes the **provider**. RRP defines
the question, eligibility, time origin, horizon, information cutoff, request,
result validation, history, and product meaning. A selected provider supplies
one method for answering that exact question. Project registration reduces to
producers and providers, the manifest selects one exact producer and one exact
provider, and the execution plan binds those choices to RRP's nonselectable
target.

This simplification removes target catalogs, project target selection,
pluggable request builders, estimand routing, and multi-estimand product/app
behavior. A target identity and version must nevertheless remain explicit in
requests, history, products, artifacts, provider compatibility, and
conformance. RRP software version alone does not say what statistical quantity
an old record contains.

## Exact current `v0.1.0` target

### Mathematical quantity

Let:

- `D` be the canonical discharge timestamp;
- `F` be canonical `followup_window_end`;
- `W = min(F, D + 30 × 86,400 seconds)`;
- `t` be runtime `as_of_time`, required to equal admitted bundle as-of;
- `T_R` be first canonical `readmission_time`; and
- `T_D` be canonical `death_time`.

For an eligible episode, `v0.1.0` requests:

\[
  P\{t < T_R \le \min(t + 1\text{ elapsed day}, W)
    \mid T_R > t,\ T_D > t,\text{ eligible at }t,
    \mathcal H_t\}.
\]

The estimand contract calls death within the requested interval a competing
terminal event. If readmission and death occur at the same instant, canonical
and eligibility rules give precedence to readmission.

The declaration's human mathematical field does not itself include an explicit
`T_R <= T_D` event term, while its terminal-behavior field says death during
the interval is competing. Canonical ordering prevents a represented
readmission after represented death, but provider conformance cannot prove a
model's future-death handling. The new target should eliminate that ambiguity
by expressing competing death directly in one normative definition.

### Executable semantics

| Dimension | Exact `v0.1.0` behavior |
|---|---|
| Population root | Every discharge episode admitted under `platform.readmission-initial-profile@0.1.0`; no additional clinical or measure cohort is implemented |
| Index event | Source-owned index encounter represented by one canonical discharge episode |
| Time origin | Exact `discharge_time` timestamp |
| Maximum horizon | Earlier of canonical `followup_window_end` and 30 elapsed 24-hour days after discharge |
| Eligible interval starts | `discharge_time <= t < W` |
| Terminal condition at start | Readmission or death at or before `t` yields no request; readmission wins a same-time tie |
| Event | First canonical `readmission_time`; plannedness is explicitly not distinguished |
| Requested interval | `(t, min(t + 86,400 seconds, W)]` |
| Time representation | Explicit-offset RFC 3339 instants converted to numeric elapsed seconds; not calendar-date bins |
| Information set | All admitted baseline rows with both score and availability no later than `t`, and events with both occurrence and availability no later than `t` |
| Runtime cutoff | Runtime as-of must exactly equal admitted bundle as-of |
| Output | Exactly one finite probability in `[0,1]` per successful request |
| Cross-time coherence | No monotonicity requirement |
| Failure | Ineligible episodes have no request; provider incompatibility/failure has a structured execution result and no fabricated `NA` estimate |

Current executable eligibility emits `before_discharge`, `eligible`,
`already_readmitted`, `died`, or `followup_complete`. Although the eligibility
contract lists insufficient-input and unsupported-capability reasons, the
current function does not produce those reasons. Baseline and event
capabilities are optional for target eligibility; a provider may impose
stronger input requirements.

### Current temporal limitation

Baseline and episode-event rows have distinct occurrence and availability
times and are defensively filtered by both. Root `readmission_time` and
`death_time` do not have separate availability fields. Current source
producers construct the as-of bundle from available outcomes, runtime as-of is
locked to bundle as-of, and future terminal occurrence does not affect
eligibility before it occurs. Nevertheless, the generic canonical contract
cannot itself express a late-recorded terminal occurrence. A future target
contract must not claim complete no-future-information enforcement for
terminal evidence without resolving that representation.

### Current reference method is not the quantity definition

The transparent provider returns:

```text
plogis(
  qlogis(0.04)
  + 0.75 × mean available probability-typed baseline rows
  + 0.12 × bounded available-event count
  + 0.10 × recent-event indicator
)
```

It does not rescale for a final interval shorter than one day and does not use
elapsed or remaining follow-up directly. Its declaration and output conform
technically to the current request, but it is deliberately nonclinical and
uncalibrated. This illustrates why bounds and identity validation cannot prove
that a provider truthfully estimates a declared quantity.

## Proposed RRP risk-target specification

### Recommended semantic contract

For the first platform-defined target:

| Dimension | Recommended rule |
|---|---|
| Target | Remaining actual-world cumulative incidence of first canonical readmission through day 30 |
| Base population | Every conforming admitted canonical discharge episode; no implied measure, service-line, or program cohort |
| Qualifying index discharge | The discharge represented by that admitted episode; source mapping owns encounter identification, while canonical admission and RRP own post-handoff validity |
| Qualifying readmission | First canonical `readmission_time`; no planned/unplanned distinction in the first target contract |
| Time origin | Exact canonical discharge instant `D` |
| Fixed endpoint | `W30 = D + 30 × 86,400 seconds`; endpoint included |
| Prediction time | Exact explicit-offset run/bundle as-of instant `t`, with `D <= t < W30` |
| Target interval | `(t, W30]` |
| Conditioning | Alive, no canonical readmission at or before `t`, target-eligible at `t`, and conditioned on admitted information available through `t` |
| Competing death | Death before readmission prevents the readmission event; equal timestamps count readmission, matching current canonical precedence |
| Other events | Enter `H_t` when valid and available; they are not additional event-free conditions or terminal events unless a later target contract says so |
| Scale | One finite probability in `[0,1]` |
| Missing/failure | No probability is emitted for ineligibility, unsupported target/provider, missing required provider input, execution failure, or invalid output |

This is a **conditional landmark prediction** made at each operational as-of
instant. “Continuously” means RRP may execute repeatedly as new information
becomes available; it does not promise mathematical continuous-time updating,
stream processing, or a prediction at every instant.

### Fixed 30-day meaning

The target endpoint must not vary by episode or provider. The current
`min(canonical followup end, 30 days)` rule is appropriate for a bounded daily
request but would make the phrase “remaining 30-day risk” false when the
canonical end is earlier.

The next canonical/runtime contract should therefore require the episode's
declared target coverage to reach `W30`—preferably by requiring
`followup_window_end == W30` for this profile—or reject the episode as
unsupported for this target. A provider must never receive a shortened end and
still label its output 30-day risk. A later observation-retention boundary may
be distinct from the prediction endpoint.

### Information set `H_t`

`H_t` is not “everything the source currently contains.” It is the immutable
provider-facing RRP state derived from an admitted bundle at cutoff `t`,
including only governed fields whose occurrence/effective time and
availability/recorded time permit use by `t`. It excludes:

- source records not admitted through the canonical boundary;
- future occurrences;
- records unavailable at `t` even if later known;
- post-`t` outcomes used during retrospective reconstruction; and
- provider lookups behind the state boundary.

The current baseline/event dual-time rules are reusable. Terminal-event
availability needs an explicit canonical solution before implementation. A
provider can require a subset of available state or derive its own features,
but it cannot broaden `H_t` or redefine the cutoff.

### Ineligibility and loss of eligibility

RRP should emit no request before discharge, after a known qualifying
readmission, after known death, or at/after `W30`. It must not manufacture zero
risk at day 30 or after a terminal event.

The current profile has no general loss-to-follow-up, hospice, enrollment,
data-feed interruption, or program-exclusion fact. Those states must not be
invented or inferred from missing provider inputs. Missing data can make one
provider unable to answer and produce a structured failure while the episode
remains target-eligible. Any future loss-of-eligibility rule requires an
explicit canonical fact, temporal availability, and target-contract change.

## Daily hazard versus remaining cumulative risk

| Concern | Current next-day hazard | Proposed remaining 30-day risk |
|---|---|---|
| Question | Chance of readmission in the next bounded day | Chance of readmission before the fixed day-30 endpoint |
| Interval | `(t, min(t+1 day, W)]` | `(t, W30]` |
| Clinical reading | Immediate short-term event intensity | Remaining episode-level risk burden |
| Care-program use | Useful for acute day-ahead surveillance | More directly supports remaining-window outreach and monitoring |
| Executive interpretation | Repeated hazards are difficult to summarize; cannot be added | One recognizable remaining 30-day probability at each landmark |
| Provider implementation | Must estimate a one-day conditional probability | May model the cumulative quantity directly or derive it from hazards/survival |
| Time updating | New one-day target on each run | Same fixed endpoint with changing conditioning, information, and remaining time |
| Thresholding | Threshold meaning is tied to immediate hazard | More intuitive, but distributions and sensible thresholds can still vary with `t` |
| Calibration | One-step hazard calibration by landmark/day | Conditional cumulative-incidence calibration by landmark/day and remaining horizon |
| History | Sequence of different adjacent interval risks | Sequence of updated predictions for one fixed endpoint |
| Visualization | Points are day-specific hazards | Points are remaining-risk trajectory; not expected to be monotone |

Remaining cumulative risk is the better canonical RRP quantity because it
matches the product's stated decision question. A next-day hazard can be high
while little total follow-up remains, or low on one day while cumulative
remaining risk is material. Users should not have to compose daily hazards—or
mistakenly add them—to interpret platform output.

The canonical target does not create a priority threshold or intervention
rule. Any thresholding, capacity allocation, decision, or task policy remains
separate, versioned behavior. Because the population and remaining horizon
change with `t`, a single unexamined threshold across all follow-up times may
be inappropriate even when the displayed probability is intuitive.

## Role of daily hazard going forward

Daily hazard should be removed from the active public RRP target contract.
There is no demonstrated product requirement for a second platform quantity,
and retaining one would reintroduce routing, product labeling, comparison, and
app behavior solely for symmetry with `v0.1.0`.

A provider may internally estimate daily or finer hazards and combine them
into the required cumulative incidence. In a no-competing-event illustration,
the remaining risk derived from conditional hazards is

\[
  1 - \prod_{u>t}^{W_{30}} (1-h_u).
\]

With death as a competing event, the provider must use a competing-risk
calculation consistent with the target; a simple readmission-hazard survival
product may estimate a different hypothetical quantity. Internal hazards,
survival curves, latent states, or simulation draws are provider
implementation details unless a later product requirement establishes a
separate governed output.

The current hazard declaration, provider, fixtures, and tests remain immutable
historical `v0.1.0` evidence. They must not be relabeled as cumulative risk.

## Estimand-subsystem disposition

| Current or proposed machinery | Disposition | Reason |
|---|---|---|
| Statistical quantity definition | **RETAIN AS RISK-TARGET SPECIFICATION** | One target still requires exact population, event, time, conditioning, competing-event, output, and failure meaning |
| Estimand identity/version | **RENAME/SIMPLIFY** and **RETAIN FOR PROVENANCE** | Becomes singular risk-target identity, not a selectable component |
| Current estimand YAML | **REFACTOR INTO RRP RISK-TARGET CONTRACT** | Its form is useful; its daily-hazard semantics are historical |
| Repository estimand parser/loading | **REFACTOR** | Load one installed target specification; do not create a catalog or selection service |
| Hard-coded supported estimand constants | **REFACTOR** | Replace hazard literals with one authoritative installed target contract and runtime implementation |
| Eligibility horizon/terminal logic | **COLLAPSE INTO RUNTIME** | RRP owns who may receive the one target and when |
| Daily request builder | **COLLAPSE INTO RUNTIME** semantically, then replace interval logic | Standard request construction remains necessary but is not an extension point |
| Request-builder identity/registry | **REMOVE FROM ACTIVE ARCHITECTURE** | No independently selectable/pluggable builder exists |
| Estimand registry/catalog | **REMOVE FROM ACTIVE ARCHITECTURE** | A singular nonselectable target needs no registry |
| Project estimand registration | **REMOVE FROM ACTIVE ARCHITECTURE** | Projects cannot change the question |
| Manifest estimand selection | **REMOVE FROM ACTIVE ARCHITECTURE** | Redundant configuration would imply a choice users do not have |
| Estimand-to-provider route | **REMOVE FROM ACTIVE ARCHITECTURE** | One selected provider must support the one installed target |
| Provider `supported_estimands` | **COLLAPSE INTO PROVIDER CONTRACT** | Becomes compatibility with the RRP risk-target identity/version |
| Provider interval/horizon checks | **REFACTOR** | Validate support for the complete landmark range and fixed endpoint rather than arbitrary routed intervals |
| Request/estimate target reference | **RENAME/SIMPLIFY** and **RETAIN FOR PROVENANCE** | Exact quantity remains attributable even though nonselectable |
| History `estimand_request` family | **RENAME/SIMPLIFY** in a new history version | Becomes RRP risk-prediction request; old records remain untouched |
| Product estimand fields/grain | **RENAME/SIMPLIFY** | One target permits episode grain while retaining target version metadata |
| App estimand labels | **REMOVE/REPLACE** | Show human target meaning/version rather than a configurable estimand column |
| Artifact estimand evidence | **REFACTOR** and **RETAIN FOR PROVENANCE** | Record exact risk-target identity/version directly |
| Estimand-specific validators/tests | **REFACTOR** | Become risk-target, temporal, request, provider, and downstream semantic conformance |
| `v0.1.0` hazard tests/docs/contracts | **HISTORICAL ONLY** | Immutable evidence, not a compatibility promise for the new target |
| Multi-target identities/catalogs | **DEFER** | A future major evolution can introduce them if a real product need appears |

## RRP risk-target contract

The replacement should be a small singular contract, not a component system:

```text
RRP Readmission Risk Target v1
├── exact identity/version and human title
├── base population and canonical-profile requirement
├── qualifying discharge/readmission definition
├── discharge time origin and fixed 30-day endpoint
├── landmark/as-of and information-availability rules
├── alive/readmission-free conditioning
├── competing-death rule and timestamp precedence
├── RRP-owned eligibility and request semantics
├── one bounded-probability output
├── structured no-estimate/failure semantics
└── conformance scenarios and provenance requirements
```

Use a combination of:

- one installed, versioned machine-readable semantic specification;
- code-level target constants/types and fail-closed validators implementing
  that specification;
- one human-auditable formal architecture/specification document; and
- fixtures spanning temporal and terminal boundaries.

YAML alone cannot enforce temporal behavior, and code alone is not an
auditable statistical definition. The installed metadata should be resolved
internally by the RRP release. There is no public registration collection,
catalog enumeration, or project selection API.

### Target versioning

An explicit identity such as `rrp.readmission-risk@1` is conceptually useful,
but exact syntax and version scale belong to contract design. A new target
version is required when any of these meanings change:

- base population or qualifying discharge;
- qualifying readmission/event definition or plannedness;
- time origin, 30-day calculation, or interval boundaries;
- alive/readmission-free conditioning;
- death/competing-event or tie behavior;
- information-set/temporal-availability rules;
- eligibility/terminal behavior that changes who receives a request;
- probability interpretation, dimensions, or cardinality; or
- missing/unsupported semantics that alter the meaning of emitted estimates.

Implementation refactors, performance work, packaging changes, or validator
fixes that preserve observable semantics need software/contract implementation
versioning but not necessarily a target change. Provider/model changes never
change target identity by themselves.

RRP software version is insufficient as the only target evidence: multiple
software releases may implement the same target, while a later software
release may support a changed target. Explicit target identity allows history,
products, providers, and artifacts to reject semantic mixing directly.

## Standard prediction-request semantics

A separate request record remains valuable even when request construction is
not pluggable. It provides the provider-neutral invocation boundary,
deterministic work identity, history linkage, retry target, interval evidence,
and the exact question against which output is validated.

The installed runtime should construct one request per target-eligible state:

```text
request ID and request-contract identity
runtime-run, episode, and immutable state reference
risk-target identity/version
as-of / landmark time t
discharge time origin D
fixed target end W30
target interval (t, W30]
elapsed and remaining follow-up
capability/input references
```

The provider must not choose or alter the endpoint. It receives the matching
state, whose clinical information has already been cut off at `t`.

The new deterministic request ID should include at least request-contract
version, runtime run, episode/state, target identity/version, as-of, discharge
origin, fixed end, and boundary. Including target identity remains useful even
with one target: it prevents a changed target from reproducing a legacy
request identity. Repeated predictions are distinguished by exact as-of/state
and run identity. An exact retry refers to the same request rather than making
a new semantic prediction.

Rename the active record to an RRP prediction/risk request in a new version.
Keeping `estimand_request` solely for hypothetical extensibility would obscure
the simplified public model. The old family and IDs remain valid only in
`v0.1.0` history.

## RRP-owned eligibility and temporal framing

RRP owns:

- whether an admitted episode is within `D <= t < W30`;
- whether a known readmission or death already terminated prediction;
- target population/canonical-profile conformance;
- the fixed target endpoint and `(t, W30]` boundary;
- the exact as-of/bundle relationship;
- dual-time exclusion of unavailable/future information;
- immutable state and request construction;
- target identity and standard output meaning; and
- the distinction between ineligibility and provider failure.

The provider owns none of those decisions. It may declare required state
fields/capabilities and fail when required inputs are absent, but it cannot
exclude inconvenient eligible episodes and redefine the target population.
Provider-specific missingness should remain visible as method coverage, not
be converted to platform ineligibility.

Current eligibility, state isolation, dual-time baseline/event filtering,
terminal-at-start behavior, explicit reasons, and no-request terminal semantics
are reusable. Required changes are the fixed remaining endpoint, singular
target reference, target-aware identities, and explicit terminal availability.

## Provider contract and provider flexibility

### Provider promise

A conforming provider promises:

> Given one valid immutable RRP prediction request and its matching state at
> `t`, produce one estimate of the installed RRP remaining cumulative 30-day
> readmission-risk target, or return a structured non-estimate outcome.

Its declaration should include:

- provider and implementation identity/version and lifecycle;
- compatible RRP risk-target identity/version;
- supported state/request contract versions and landmark range;
- required canonical capabilities, state fields, and provider inputs;
- one finite probability output and cardinality;
- provider and separate model/artifact provenance;
- dependency and model-availability requirements;
- deterministic/reproducibility declaration;
- uncertainty/explanation/calibration metadata capabilities when actually
  supported;
- structured missing-input, unsupported, execution-failure, and invalid-output
  behavior; and
- conformance scenarios and honest limitations.

Target compatibility replaces an arbitrary `supported_estimands` collection.
A range can be useful across compatible target revisions, but selection still
uses one exact provider ID/version and RRP validates the installed exact target.

The provider does not control target/population/event definition, endpoint,
eligibility, project target selection, state cutoff, history, product meaning,
priority, or interventions. It does not fetch source or canonical data behind
the state.

### Method flexibility

| Method | Can satisfy the target? | Required truth condition |
|---|---|---|
| Survival model | Yes | Returns conditional cumulative incidence through fixed `W30`, with death handled consistently |
| Discrete-time hazards | Yes | Combines future interval hazards into the required remaining cumulative incidence; handles competing death rather than returning one hazard |
| Direct cumulative-risk model | Yes | Is trained/defined for the same landmark population, event, conditioning, endpoint, and information cutoff |
| Machine-learning model | Yes | Output has the same probability semantics; algorithm class does not relax the target |
| Bayesian/dynamic model | Yes | Posterior predictive quantity integrates to the same event probability using only `H_t` |
| External hospital/EHR score | Sometimes | Score definition, population, horizon, landmark, competing events, and calibration must match; a bounded number alone is insufficient |
| Model for any-readmission when target later means unplanned only | No | Event definitions differ |
| Day-0 30-day score reused unchanged at day 12 | No as a direct provider | It is not automatically conditional on survival/event-free status and updated `H_t` at day 12 |
| Next-day hazard | No as provider output | It is an internal primitive, not the required cumulative quantity |

Uncertainty remains optional because current contracts do not support it. A
later provider/result contract may add governed intervals without changing the
point target if their meaning is explicit. Calibration metadata is valuable
attribution/evaluation evidence, not proof of calibration and not part of the
probability value itself.

## External-score compatibility

The existing canonical baseline-risk domain correctly preserves a discharge
score without claiming it is an RRP estimate. It records source model/version,
score and availability times, representation type, value, and lineage, but not
enough semantic metadata to prove equivalence to the new target.

Keep two cases distinct:

```text
external score as input
  → admitted baseline evidence in H_t
  → adapter/calibration/update provider
  → RRP remaining-risk estimate

external score as direct provider output
  → allowed only after exact semantic compatibility is established
```

An adapter provider may calibrate, condition, or dynamically update an
external discharge score using later evidence and return the RRP target. Its
provider/model provenance must identify both the adapter and source score. It
must not silently call an arbitrary score a probability, infer an unstated
horizon, or claim day-`t` conditional meaning from a day-0 score.

A direct external provider is compatible only if governed evidence establishes
the same population, event, endpoint, interval boundaries, as-of information,
alive/readmission-free conditioning, death handling, probability scale, and
landmark applicability. Otherwise RRP should reject it or treat the value only
as an input. Provider flexibility must not weaken target semantics.

## Project registration and manifest simplification

The initial trusted project registration result becomes exactly:

```text
project registration result
├── producer entries: declaration + trusted callable + safe metadata
└── provider entries: declaration + trusted callable + safe metadata
```

Target/estimand entries and request-builder callables disappear entirely.
Provider declarations contain compatibility with RRP's installed target, so
registration does not otherwise need to know or return the target. The closed
result, callable-object trust boundary, project identity match, no global
mutation, collision rejection, and installed/project origin labels from the
prior assessment remain appropriate.

The conceptual minimum manifest selection becomes:

```text
producer: exact producer ID + version
provider: exact provider ID + version
```

No target field is legitimate in the initial manifest. Repeating a fixed
installed value creates drift and suggests that another selection is valid.
The manifest also must not carry executable paths/functions, credentials, or
provider logic.

Catalog resolution becomes simpler: RRP has a singular internal target
specification, a project producer catalog, and installed/project provider
entries. The resolver selects one producer and one provider, validates that
provider against the target, and has no target catalog, target collision,
route table, or cross-product search.

## Execution-plan simplification

The prospective flow is:

```text
validated project and registration
        ↓
exact selected producer
        ↓
canonical production and admission at t
        ↓
RRP-owned eligibility and immutable state
        ↓
RRP-owned standard remaining-risk request
        ↓
exact selected compatible provider
        ↓
validated estimate or structured failure
        ↓
atomic history → products → product-only app
```

The immutable project context retains project/RRP identity, validated producer
and provider catalogs, exact selections, static compatibility, dependencies,
and state services. The run-specific plan retains runtime/as-of identities,
producer and provider callables, persistence session, and the singular target
specification/request semantics.

Explicit target identity still belongs in the plan even though it is not
selectable: it binds the provider check, request constructor, history, and
provenance to one quantity. What disappears is target resolution from project
configuration, request-builder resolution, route construction, multiple-route
cardinality, fallback, and estimand catalog diagnostics.

## History, product, and application implications

### History

Append orientation, lifecycle, atomic completed batches, structured execution
outcomes, retries, provider transitions, invalidation/restatement, immutable
state, and raw/valid reads remain correct.

The new semantic line should:

- replace `estimand_request` with a risk-prediction request family;
- replace `estimand_specification` with `risk_target_specification` in request,
  execution, estimate, run summary, and provenance;
- change the target interval from next-day to `(t, W30]`;
- include target ID/version in request and estimate identities;
- retain exact as-of, state, provider/implementation, optional model, interval,
  and execution lineage;
- make current selection one valid estimate per episode for the singular target
  at a cutoff; and
- version the logical and physical schemas rather than relabel old payloads.

Generic word `estimand` is statistically accurate, but in this product it now
communicates configurability that no longer exists. Explicit
`risk_target_*` naming is clearer and still statistically precise. Internal
generic helpers need not be renamed mechanically when they are invisible and
harmless, but public records, operations, diagnostics, and products should use
the RRP target vocabulary.

Current hazard records must never enter new current-risk products as if they
were cumulative risks. No rename-only data migration is valid. A new history
schema/store or explicit side-by-side version boundary should keep `v0.1.0`
facts queryable as historical evidence if needed while excluding them from the
new semantic current view. Exact migration/storage disposition is a planning
decision.

### Products

The current and history products already preserve accepted estimates rather
than recomputing pseudo-history. Their new versions should make the quantity
unambiguous. Minimum current/history fields are:

- episode and accepted estimate identity;
- current remaining 30-day readmission probability;
- estimate/state as-of time;
- discharge-relative elapsed time and remaining follow-up;
- fixed `W30` target endpoint and interval boundary;
- risk-target ID/version;
- provider/implementation and optional model reference;
- source runtime run and provenance; and
- validity/freshness metadata.

With one target, current product grain can be one current valid accepted risk
per episode rather than episode+estimand. Retaining target version in each row
prevents semantic mixing and remains useful despite not being a selection key.
Product-set compatibility must accept only the new target contract. Daily
hazard and cumulative-risk rows cannot share one product merely because both
are probabilities.

### Application

The product-only application boundary remains correct. It should not load the
target specification, registration result, provider code, or history backend
directly. Product metadata supplies all required meaning.

Labels should change from generic “estimate value” and estimand columns to
plain “remaining 30-day readmission risk,” with as-of, remaining endpoint/time,
provider/model, and target version available. The history y-axis and help text
must describe repeated conditional remaining-risk estimates, not daily hazard.
Sorting remains presentation only, not priority. No UI should imply clinical
validation or an intervention recommendation.

## Risk-trajectory interpretation

A trajectory such as 22%, 18%, 27%, and 11% is a sequence of landmark
predictions for the same fixed endpoint, each conditional on surviving alive
and readmission-free to a later `t` and each using a potentially richer
`H_t`. It is scientifically coherent to retain and inspect those attributable
predictions, but it is not a time series of repeated measurements of one
unchanging unconditional quantity.

Two mechanisms change a point:

1. **mechanical/conditional passage of time:** less of `(t, W30]` remains and
   the episode has remained event-free; and
2. **information/model change:** new state, a changed provider/model, or a
   changed software/target contract alters the prediction.

The risk need not decrease monotonically: adverse new information can outweigh
the shrinking horizon. Conversely, a decrease is not evidence that care caused
improvement. Points across provider/model or target versions remain
attributable but should not be drawn as one homogeneous model trajectory
without visible transition markers.

The first implementation should expose as-of, elapsed/remaining time, endpoint,
target, and provider/model identities and provide this interpretation. It need
not decompose each change into “time passed” versus “information changed.” Such
a decomposition requires counterfactual predictions or explanation methods and
can be deferred. The app must not interpolate missing runs.

## Validation and scientific-conformance limits

### Static project validation

Before source access, RRP can prove that:

- the exact selected producer and provider exist in validated registration;
- declarations and callable pairings conform;
- the provider declares compatibility with the installed exact target,
  request, state, output, and landmark range;
- known producer capabilities can meet target and provider requirements;
- required packages/model artifacts are available; and
- no target selection, route, or request-builder extension is present.

### Runtime validation

After canonical admission, RRP can prove that:

- the episode/profile and actual capabilities conform;
- `t`, discharge, fixed `W30`, terminal status, and target eligibility align;
- state includes only information admissible through `t`;
- one deterministic standard request exists for each eligible state;
- request and state identities match;
- provider-required input is present before invocation;
- one output matches exact request/target/provider identity and interval; and
- the result is one finite probability or a structured non-estimate failure.

Target fixtures should cover discharge, just before day 30, exact day 30,
readmission/death before and at `t`, same-time terminal precedence, delayed
information, fixed-end enforcement, repeated as-of runs, deterministic IDs,
provider mismatch, missing input, and invalid output. This is new
implementation evidence, not a reason to rerun historical suites for this
assessment.

### Scientific and model validation

RRP cannot automatically establish that executable provider code truly
estimates the target merely because it returns a bounded probability and copies
the requested IDs. Nor can software conformance prove calibration,
discrimination, transportability, fairness, clinical usefulness, causal
effect, regulatory status, or production authorization.

Fixing one target does make evaluation more coherent. Providers can be compared
only within the same target version, landmark/as-of stratum or declared
landmark model, eligible population, information policy, outcome ascertainment,
and evaluation design. Calibration must be assessed over remaining cumulative
incidence at relevant `t` values with appropriate censoring and competing-death
methods. Discrimination is likewise time/landmark specific. Naively pooling
all as-of predictions or comparing them with old next-day hazards is invalid.

Full evaluation, monitoring, calibration, and approval remain adopter/model
governance responsibilities and later platform capabilities. The architecture
should retain target, provider/model, as-of, and outcome linkage needed for
them without designing an evaluation subsystem now.

## Provenance and versioning implications

Every retained estimate and built artifact should be able to answer:

> What exact definition of readmission risk was this provider expected to
> estimate in this run?

Minimum nonsecret evidence is:

- RRP software/release identity and version;
- RRP risk-target identity/version;
- request/state/history/product contract versions;
- project identity/version and manifest/inventory evidence;
- producer, source implementation, and mapping identity/version;
- provider and provider-implementation identity/version;
- optional model/artifact identity/version/digest;
- runtime run, provider execution, request, and as-of identity;
- canonical bundle/cutoff and target endpoint; and
- product/build/materialization/application/artifact builder identities as
  applicable.

Registration and executable code digests may add attribution when governed,
but functions should not be serialized into history. Credentials, source
records, patient-level values, private mappings, and secret-bearing
configuration remain prohibited from ordinary provenance and diagnostics.

No estimand selection field is necessary. A singular target reference is
evidence, not configuration.

## Future `readmit` compatibility

The simplified relationship is direct:

```text
readmit model / updater / survival machinery
        ↓
RRP-compatible project provider
        ↓
one RRP-defined remaining 30-day risk
```

`readmit` may internally model hazards, survival, competing risks, latent
states, Bayesian updates, or direct cumulative probability. RRP need not know
those representations and must not become dependent on `readmit`. The project
registration returns a provider declaration/callable; the provider truthfully
declares target compatibility and returns the standard result.

This focus constrains `readmit` beneficially: a method that answers a different
event, horizon, conditioning, or death question cannot masquerade as an RRP
provider. It may still exist as research or motivate a future target contract,
but it does not weaken the current product meaning.

## Future-generalization path

The design preserves useful generalization points without installing their
machinery:

- exact risk-target identity/version in request, provider compatibility,
  history, products, and artifacts;
- provider-neutral immutable request/result envelopes;
- versioned canonical/state/target/product contracts;
- explicit event, horizon, conditioning, and competing-event fields in the
  target specification; and
- fail-closed compatibility rather than target-specific behavior hidden in
  provider code.

If a demonstrated future need requires next-day, seven-day, mortality,
competing-risk, or multiple targets, a major architecture/contract evolution
can introduce a target catalog, project or operation selection, route
cardinality, target-specific state/requests, history query rules, and product/UI
presentation. Existing singular target references make that evolution
possible. Today's manifest and registration result should not contain dormant
arrays, target plugins, or route tables in anticipation.

The principle is: **preserve identities and boundaries that make later
generalization possible; omit selection and plugin machinery until the product
has more than one supported question.**

## `v0.1.0` reuse and disposition matrix

| `v0.1.0` machinery | Disposition | Forward implication |
|---|---|---|
| Canonical discharge episode identity and time origin | **REUSE AS-IS** conceptually | Remains the episode root and discharge landmark |
| Current first canonical readmission definition | **REUSE WITH NEW TARGET SEMANTICS** | Event persists across the whole remaining window; limitation on plannedness stays explicit |
| Death timestamp and tie precedence | **REUSE WITH NEW TARGET SEMANTICS** | Death becomes competing event through `W30`; terminal availability needs follow-up |
| Canonical `followup_window_end` minimum rule | **REQUIRES ANOTHER DECISION** physically | Recommend exact/at-least fixed `W30`; never silently shorten target |
| Baseline/event dual-time filtering | **REUSE AS-IS** semantically | Forms governed `H_t` |
| Root terminal fields without availability | **REFACTOR INTO RRP RISK-TARGET CONTRACT** plus canonical support | Must close the late-recorded-terminal gap |
| Eligibility result and explicit no-request states | **COLLAPSE INTO RUNTIME** | Rename target references; use fixed endpoint |
| Minimal immutable episode state | **REUSE WITH NEW TARGET SEMANTICS** | Add exact origin/end/target evidence needed by standard request/provider |
| Daily-hazard estimand declaration | **RETAIN AS HISTORICAL v0.1.0 EVIDENCE** | Never relabel as remaining cumulative risk |
| Runtime singular estimand parser/constants | **REFACTOR INTO RRP RISK-TARGET CONTRACT** | One installed target, not selectable catalog |
| Daily request interval builder | **COLLAPSE INTO RUNTIME** and replace semantics | Build `(t, W30]` request deterministically |
| Provider-neutral request abstraction | **REUSE WITH NEW TARGET SEMANTICS** | Rename/version and retain target/as-of/interval identity |
| Request builder as proposed component | **REMOVE FROM ACTIVE ARCHITECTURE** | RRP owns constructor; no project callable |
| Provider declaration | **COLLAPSE INTO PROVIDER CONTRACT** and version | Replace supported-estimand collection with target compatibility/landmark support |
| Provider registry and exact selection | **REUSE AS-IS** architecturally | Provider remains project analytical extension seam |
| Compatibility and isolated execution | **REUSE WITH NEW TARGET SEMANTICS** | Validate target/state/request rather than routed estimand |
| Structured execution failures | **REUSE AS-IS** | No fabricated estimate and no fallback |
| Estimate/result identity and provenance | **REUSE WITH NEW TARGET SEMANTICS** | Rename target fields and use full remaining interval |
| Transparent hazard provider/formula | **RETAIN AS HISTORICAL v0.1.0 EVIDENCE** | A new nonclinical cumulative-risk demonstration provider is required later |
| Operational run lifecycle/atomicity | **REUSE AS-IS** | Rename member family/count in a new contract version |
| Retry, provider transition, invalidation/restatement | **REUSE AS-IS** | Preserve exact target/provider semantics across history |
| DuckDB schema and estimand-indexed reads | **RENAME/SIMPLIFY** in a new adapter schema | Do not mutate or reinterpret existing stores |
| Current/history product construction from accepted estimates | **REUSE WITH NEW TARGET SEMANTICS** | New contracts/fields/grain; reject hazards |
| Product estimand columns | **RENAME/SIMPLIFY** | `risk_target_*`; target remains attribution, not selector |
| Product-only app boundary | **REUSE AS-IS** | Update labels/trajectory interpretation only through products |
| App estimand/provider presentation | **RENAME/SIMPLIFY** | Human target label; retain provider/model attribution |
| Reduced artifact integrity/closed inventory | **REUSE AS-IS** architecturally | Add direct target/project/provider evidence |
| Estimand-specific validators/tests | **REFACTOR** | New target temporal/conformance suite; old suite remains release evidence |
| Estimand catalog/selection/routing proposed for vNext | **REMOVE FROM ACTIVE ARCHITECTURE** | Never implement merely because it was assessed |
| Multi-target execution/product/app behavior | **DEFER FOR POSSIBLE FUTURE GENERALIZATION** | Requires demonstrated product need and major design |

## Risks and tradeoffs

| Choice | Cost or lost capability | Why acceptable / mitigation |
|---|---|---|
| One RRP-owned target | Projects cannot use RRP as a generic prediction platform | This matches the product purpose; unrelated questions should not inherit readmission-risk semantics |
| No project estimands | New local quantities require an RRP target evolution or separate system | Preserves interoperability, scientific review, history meaning, and honest products |
| No target selection | A project cannot choose next-day versus remaining risk | There is one supported question; exposing a false choice creates drift |
| Remove daily hazard publicly | Acute next-day surveillance is not a core output | No demonstrated product requirement; providers may retain hazards internally |
| Fixed cumulative endpoint | Providers must support dynamic landmark prediction, which can be harder | The complexity belongs in the model seam because it answers the intended question |
| Competing-death target | Models that ignore death may not conform | Prevents a hypothetical quantity from being presented as actual remaining risk |
| Exact target semantics | Some EHR/vendor scores will be rejected as direct providers | Scores remain usable as inputs; semantic honesty is more important than broad nominal compatibility |
| Explicit target version despite one target | Additional metadata/version discipline | Necessary to prevent semantic mixing across software, history, products, and artifacts |
| Renamed active history fields | New schema and migration boundary | A mere rename cannot convert hazards to cumulative risk; version isolation is safer |
| Platform-owned eligibility | Providers cannot silently choose their own cohort | Provider missingness remains visible; local clinical approval still governs use |
| Repeated cumulative-risk trajectories | Changes can be misread as treatment effects or simple deterioration | Label as landmark predictions; expose time/provider/target transitions; defer decomposition |
| Singular architecture | Later multiple targets require major evolution | Stable target identity/request/provider boundaries preserve a credible path without current plugin cost |

The principal loss is analytical-question flexibility. That loss is acceptable
for the next implementation because no current adopter proof requires a custom
estimand, while every configurable target would expand scientific governance,
request execution, history compatibility, product semantics, UI, and provider
routing. Provider diversity supplies the flexibility the product actually
needs: different hospitals and methods can answer the same question.

## Remaining decisions

### Before package/dependency/build assessment

No unresolved semantic issue blocks the packaging assessment. That work can
assume one installed, nonselectable, versioned risk target; one RRP-owned
request constructor; project producer/provider registration; and exact
producer/provider selections.

### Before implementation planning is finalized

The target-architecture synthesis must encode, and maintainers must explicitly
accept, these bounded choices:

1. the exact target ID/version syntax and contract-version policy;
2. the recommended crude competing-risk interpretation of death rather than a
   hypothetical death-eliminated risk;
3. the recommended first event/population definition—every admitted canonical
   episode and its first canonical readmission, without a plannedness claim;
4. whether the canonical profile requires `followup_window_end == W30` or
   permits a later end while the target always uses `W30`;
5. the canonical representation/enforcement of terminal-event availability;
6. the names and version transition for request, history, product, and adapter
   contracts; and
7. isolation or read-only disposition of existing hazard history rather than
   semantic migration.

These are contract-synthesis decisions with a clear recommended direction,
not evidence that another broad estimand-platform assessment is needed.

### Safe deferrals

- Planned/unplanned or measure-specific readmission definitions.
- Additional clinical/program eligibility rules.
- Loss-to-follow-up and other terminal/competing events.
- Uncertainty outputs and explanation contracts.
- Calibration/evaluation and monitoring subsystems.
- Decomposition of trajectory change into time versus information.
- External/non-R provider transport.
- Custom products or applications.
- Next-day, seven-day, mortality, or other targets.
- Target catalogs, project target selection, routing, and multi-target runs.
- Historical hazard viewer or cross-target research tooling.

## Recommended next task

This assessment resolves the target/estimand direction sufficiently for the
next architecture step. Proceed to the **package/dependency and
build-reproducibility assessment**. It should evaluate the proposed installed
RRP package topology, singular installed target resources, project provider
dependencies/model artifacts, clean installation, project-owned environment,
and artifact/Connect dependency closure.

After that assessment, synthesize the forward target architecture and
implementation plan. That synthesis should revise the plural-estimand language
in True North, architecture, and plan only after maintainers accept this
recommendation; it should not rewrite the immutable `v0.1.0` implementation
record or released contracts.

## Validation posture for this assessment

This is documentation-only architecture work. Direct inspection of current
contracts, runtime code, temporal/provider tests, history conformance and
adapter schemas, product builders/contracts, application view models, and
artifact boundaries answered the architectural questions. No executable test
was needed to discover behavior not already explicit in those sources.

Validation is limited to affected documentation/navigation checks, direct
diff and scope review, Markdown trailing-whitespace inspection, and `git diff
--check`. Historical Phase 0–11, Hospital distribution/acquisition, release,
publication, and unrelated runtime suites are intentionally not run.
