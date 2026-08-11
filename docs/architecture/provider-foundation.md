# Provider and estimate foundation

## Purpose and scope

Iteration 4.2 completes the minimal governed runtime promised by Phase 4. It
adds a language-neutral provider declaration, controlled in-memory
registration and exact selection, compatibility evaluation, isolated adapter
execution, structured execution outcomes, one transparent reference provider,
and a standardized estimate record.

It extends the accepted state, eligibility, and request boundary in the
[Runtime Foundation](runtime-foundation.md) without changing that estimand.

The ownership boundary is deliberate:

```text
estimand defines WHAT quantity is requested
        ↓
provider declares HOW it can produce that quantity
        ↓
execution result records WHETHER one invocation conformed
        ↓
estimate records the accepted methodological RESULT
```

This provider boundary does not itself persist estimates, rank episodes, make
decisions, recommend interventions, construct products, or create application
behavior. Iteration 5.1 now owns retry lineage and operational-history
semantics in the
[Operational History Foundation](operational-history-foundation.md).
Later phases own decision policy, products, and applications.

## Contract suite

Four platform contracts and one shipped declaration establish the boundary:

| Identity | Responsibility |
|---|---|
| `platform.provider-specification@0.1.0` | Required declaration, compatibility dimensions, lifecycle, and trust rules |
| `platform.provider-execution-adapter@0.1.0` | Language-neutral invocation inputs, output meaning, and prohibited behavior |
| `platform.provider-execution-result@0.2.0` | One structured success or failure with runtime-run and retry-attempt lineage from compatibility through output validation |
| `platform.readmission-risk-estimate@0.1.0` | One accepted probability with request, state, estimand, provider, run, interval, and provenance identity |
| `reference.transparent-readmission-hazard@0.1.0` | Fixed nonclinical method conforming to the first estimand |

The YAML documents use the common specification envelope. They declare
semantics, not executable code, paths, packages to install, or remote plugins.
The `rrpruntime` package receives already parsed documents from an operation;
it does not discover repository paths.

## Trust, registration, and selection

A provider becomes executable only when trusted platform code pairs a
conforming declaration with an approved adapter callable. The current
registry is process-local and in memory. Registration rejects an invalid
declaration and duplicate provider ID/version pairs. Selection requires the
exact registered `provider_id` and `provider_version`; there is no implicit
default, latest-version resolution, arbitrary source-file loading, executable
configuration, package installation, or remote discovery.

This R registry is one realization of a language-neutral boundary. A future
controlled service or non-R adapter may implement the same request, state,
declaration, and output semantics without changing the estimand or estimate
contracts. Such an adapter still needs an explicit trust and transport design;
Iteration 4.2 does not claim that external execution already exists.

## Compatibility before execution

The platform resolves the exact provider and evaluates compatibility before
invoking its adapter. Compatibility covers:

- an active/selectable provider lifecycle;
- exact estimand ID and a declared supported version range;
- state specification ID/version and declared required fields;
- required canonical capability statuses;
- provider-specific required input availability;
- target follow-up and interval limits; and
- a declared one-probability output compatible with the estimand.

An unsupported method or missing input does not call the adapter. The provider
receives only isolated copies of the accepted request, its matching immutable
episode state, and its registered declaration. It cannot look behind state to
source or canonical tables, repeat eligibility, or mutate the caller's input.

## Execution outcomes and output conformance

Every attempted request/provider pairing produces one execution result with
one of these statuses:

- `successful_estimate` — exactly one conforming output became an estimate;
- `unsupported` — declared lifecycle or compatibility does not support it;
- `missing_required_input` — a required capability, state field, or provider
  input is absent;
- `execution_failure` — the approved adapter was invoked and failed; or
- `invalid_output` — the adapter claimed success but its output did not
  conform.

Failures have a machine-readable failure code, message, and no estimate.
They never fabricate an `NA` probability. The platform, rather than each
provider, enforces request/state/episode and estimand identity, target interval,
cardinality, finite numeric probability bounds, and required provenance. Only
then does the platform construct the standardized estimate record.

## Estimate identity and model identity

An accepted estimate carries deterministic comparison identity derived from
the runtime run, provider execution run, request, state, estimand version,
provider version, optional model version, and target interval. It also links
the request, state, provider declaration, and execution result in provenance.
This is not yet a persistence key or a claim about retry idempotency.

Provider identity describes executable method behavior. It is distinct from a
canonical baseline row's `source_model_id` and from an optional trained model
or artifact identity. The transparent reference provider is a fixed formula,
so it declares no separate model artifact and its estimate records carry an
explicit null model reference. Future fitted providers may identify a model
separately.

## Transparent reference provider

`reference.transparent-readmission-hazard@0.1.0` supports only
`platform.readmission-next-day-conditional-hazard@0.1.0`, the matching state
contract, a maximum 30-day follow-up, and a one-day interval. Discharge episode
capability is required. Available baseline-risk and episode-event inputs are
optional; absent optional inputs contribute zero.

For each accepted request, the provider computes:

```text
plogis(
  qlogis(0.04)
  + 0.75 × mean(available probability-typed baseline rows)
  + 0.12 × min(available event count, 5)
  + 0.10 × indicator(any available event in the previous 7 days)
)
```

Only probability-typed baseline rows enter the mean. Numeric scores and
categories are ignored. Event rows are already constrained by state
availability and the provider measures recency relative to state `as_of_time`.
The method is deterministic: it uses neither wall clock nor random numbers.

The provider exists solely to prove software conformance and extension
behavior. It is not fitted, calibrated, clinically validated, causal,
production-ready, or approved for patient care.

## Conformance evidence

Focused tests cover valid and duplicate registration, exact and unknown
selection, path rejection, version and capability compatibility, missing
inputs, adapter isolation, deterministic execution, a test-only second
provider, execution exceptions, identity/cardinality/interval/value rejection,
estimate tampering, optional-input scenarios, and both independent and
synthetic admitted inputs.

The supported human operation is documented in
[Run reference estimation](../operations/run-reference-estimation.md). The
full validation claim is documented in [Validation](../operations/validation.md).
