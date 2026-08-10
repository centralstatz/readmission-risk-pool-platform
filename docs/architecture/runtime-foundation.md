# Runtime foundation, episode state, and first estimand

## Status and scope

**Status:** authoritative Iteration 4.1 runtime boundary

The focused `rrpruntime` package begins only after canonical admission:

```text
admitted canonical bundle
        ↓
explicit eligibility results
        ↓
minimal availability-filtered episode states
        ↓
provider-neutral estimand requests
```

No provider runs and no risk is estimated in this iteration. State describes
what is known for an eligible episode; the estimand describes the quantity a
later provider will be asked to estimate.

## Loading and representation boundary

Language-neutral contracts remain under `contracts/runtime/`. Repository-level
operations load them and adapt the currently admitted canonical realization to
a normalized runtime input. `rrpruntime` receives both explicitly. It never
discovers a project root, reads YAML, resolves embedded fixture payloads, or
knows a source implementation.

Canonical admission and maintained-contract/checkpoint scans remain
transitionally under `operations/lib/`. They contain repository and current
representation concerns and were not moved wholesale into the package.

## Runtime as-of rule

Iteration 4.1 requires:

```text
runtime_as_of_time == admitted_bundle_as_of_time
```

This avoids claiming historical replay when discharge terminal fields have no
separate availability timestamp. Baselines and events are still defensively
dual-time filtered: baseline `score_time` and `available_at`, plus event
occurrence and `available_at`, must be no later than runtime as-of.

## Eligibility

The effective follow-up end is the earlier of the canonical episode end and 30
days after discharge. Discharge is included and the end is excluded:

```text
discharge_time <= t < effective_followup_end
```

Readmission or death at or before `t` makes the episode ineligible. A terminal
occurrence after `t` cannot affect the current result. Results explicitly
separate `eligible`, `before_discharge`, `followup_complete`,
`already_readmitted`, and `died`; ineligibility is never risk zero.

## Minimal state

`platform.readmission-episode-state@0.1.0` contains episode/run/as-of identity,
elapsed and remaining follow-up time, active/terminal facts, every available
canonical baseline row, ordered available canonical event history, capability
statuses, and canonical/eligibility references.

All available baseline rows are retained deterministically. The runtime does
not select a “latest” source model or reinterpret source baseline risk as a
platform estimate. Events are ordered by occurrence, availability, and event
ID. Neither collection is expanded into provider-specific features.

## First estimand

`platform.readmission-next-day-conditional-hazard@0.1.0` is:

> For an eligible episode at follow-up time `t`, the probability of first
> canonical readmission during `(t, min(t + 1 day, W)]`, conditional on being
> alive, readmission-free, and eligible at `t`, using information available
> through `t`, where `W` is effective follow-up end.

“Canonical readmission” means the first `readmission_time` represented by the
initial canonical profile. That profile has no planned/unplanned field, so this
version deliberately makes no narrower clinical event claim. Plannedness can
only be added through a future governed canonical and estimand change.

Death during the target interval is a competing terminal event. Probability is
bounded in `[0,1]`. Conditional daily hazard may increase or decrease as state
changes, so monotonicity across intervals is explicitly not required.

Only the discharge-episode capability is needed for the quantity to be
well-defined. Baseline and event history are optional estimand inputs; a future
provider may declare stronger method requirements without changing the
estimand.

## Request boundary

`platform.readmission-estimand-request@0.1.0` identifies the eligible episode,
state, estimand, run, as-of time, and target interval. It contains no provider,
model, probability, priority, task, or intervention field. Exactly one request
is created for each eligible state.

The human demonstration is
[Run the reference runtime](../operations/run-reference-runtime.md).
