# Operational history foundation

## Purpose and maturity

Iteration 5.1 defines operational truth before choosing storage. It adds
language-neutral record contracts and backend-independent ports to
`rrpruntime@0.3.0`; it does not add a durable adapter, database, file format,
product, application, deployment, replay tool, decision policy, or
observability system.

It extends the completed
[Provider and Estimate Foundation](provider-foundation.md) within the sequence
owned by the [Platform Implementation Plan](platform-implementation-plan.md).
The machine-readable identities are indexed in
[Platform Specifications](../../contracts/README.md).

Operational history is the append-oriented evidence of what the admitted
platform runtime knew, requested, attempted, accepted, and concluded during a
specific run. It is distinct from:

- source history, which remains owned below the canonical boundary;
- a canonical bundle, which is an admitted handoff rather than an operational
  event ledger;
- products, which are later logical interfaces derived from history;
- provenance, which attributes records but is not a substitute for retaining
  them;
- logs and diagnostics, which explain execution but do not establish accepted
  domain facts;
- replay, which would perform a new computation and is not supplied here; and
- research datasets, whose analytical purpose and governance differ from live
  operational truth.

These interfaces are pre-1.0. They establish semantic ownership and adapter
conformance, not production durability or clinical fitness.

## Persisted record families

An accepted terminal run batch contains five families.

| Family | Historical meaning | Primary identity |
|---|---|---|
| Operational run status | Immutable lifecycle facts and coherent run context | `run_status_record_id` within `runtime_run_id` |
| Episode state | The versioned, availability-filtered state actually supplied to estimation | `state_id` |
| Estimand request | The governed quantity requested for that state | `request_id` |
| Provider execution result | Every attempt outcome, including unsupported and failure outcomes | `execution_result_id` |
| Accepted estimate | A conforming methodological result produced by a successful execution | `estimate_id` |

Invalidations form a sixth append-only control family. They retain corrections
without altering the original facts.

The complete episode-state record is retained, including its baseline and
event collections, capability statuses, input references, state version, and
canonical provenance. A state is intentionally a narrow snapshot for its
declared version, not a universal future feature warehouse. A future provider
requiring information absent from an old state cannot reinterpret that state
as though the information had been present.

The full canonical bundle is deliberately not retained by this interface.
State and run records retain the bundle instance, canonical run,
implementation, mapping, and input provenance necessary to attribute what was
used. An adopter may retain canonical bundles under separate source/handoff
policy, but Iteration 5.1 neither requires nor exposes that as operational
history. This decision keeps the runtime port from taking ownership of source
history and will be revisited only if a concrete correction or audit need
cannot be met by retained state and provenance.

## Run identity and lifecycle

`platform.operational-run-status@0.1.0` represents lifecycle as immutable
status records:

```text
started (sequence 1)
    ├── completed (sequence 2)
    ├── completed_with_failures (sequence 2)
    └── failed (sequence 2)
```

All records in this diagram share one `runtime_run_id` and immutable as-of,
bundle, canonical-run, implementation, and mapping context. A terminal record
references the started record. A run has at most one terminal record.

`completed` means an accepted atomic terminal batch has no failed provider
executions. `completed_with_failures` means a valid atomic batch exists and at
least one execution was unsupported, missing input, failed, or returned
invalid output. An individual provider failure therefore does not falsely
turn every accepted fact into a failed run. `failed` means no accepted
terminal batch exists. Invalidation is a separate overlay, never a lifecycle
status.

A new intentional platform computation receives a new `runtime_run_id`, even
at the same as-of time. Multiple provider attempts within that run retain the
run ID but use distinct provider-execution-run and execution-result identities.

## Atomicity and incomplete runs

A `started` record may be appended as soon as the run context is admitted. A
`failed` record may later close it without accepted member records.

A `completed` or `completed_with_failures` status is different: it becomes
visible atomically with every state, request, execution result, and estimate
declared by its exact status summary. The batch validates identities,
cardinalities, same-run membership, state/request/execution/estimate links,
retry lineage, accepted-estimate uniqueness, status outcome, and summary
counts before delegation.

An adapter must make all or none of that completed batch visible. A process
failure after `started`, a partially written candidate batch, or a run lacking
a terminal status cannot appear in current valid estimate reads. Iteration 5.2
must demonstrate this property for the selected local adapter rather than
assuming that a particular transaction API supplies it.

## Idempotency and conflicts

Append behavior is defined by logical identity and full semantic content:

- the same identity with identical content is an idempotent no-op;
- the same identity with different content is a conflict that fails before
  mutation;
- no append overwrites or deletes an accepted record; and
- semantic equality is authoritative. A content digest may be adapter evidence
  but no hash algorithm is part of the logical contract.

Run status records sharing a run ID must retain identical context. Record IDs
must be unique within their families. One terminal batch cannot accept more
than one estimate for a request/provider/model/interval semantic key.

## Provider attempts and retry

`platform.provider-execution-result@0.2.0` adds the run identity,
`attempt_number`, and `retry_of_execution_result_id` required to preserve
attempt history. Attempt 1 has no retry reference. Each later attempt names the
immediately preceding attempt for the same request and provider and uses a
distinct `provider_execution_run_id`.

A retry after failure may produce the single accepted estimate for that
request/provider/interval. Earlier failures remain first-class history. A
retry after success cannot append a second accepted estimate for the same
semantic key within the run. Repeating the exact same attempt and batch is
idempotent; changing content under its identity is a conflict.

Retry semantics here describe retained truth. Scheduling, backoff, automatic
retry policy, and recovery orchestration are intentionally outside the port.

## Provider transitions

A provider transition changes only future runs. Prior estimates keep their
original provider, implementation, optional model, request, state, and run
references. They remain valid unless a separate governed invalidation says
otherwise.

For example, if provider A produces the valid estimate on day `t` and provider
B is selected for a new run on day `t+1`, episode history contains both. The
current-valid read at `t` returns A; the current-valid read after the later run
returns B. No migration rewrites A into B and no product is allowed to hide the
transition by reconstructing day `t` with provider B.

## Correction, invalidation, and restatement

`platform.history-invalidation@0.1.0` is an immutable assertion that a retained
record or complete run is excluded from currently-valid reads. It records the
target family and identity, target run, correction time, machine-readable and
human-readable reason, optional replacement run, and provenance.

The original remains visible in the raw view. Validity resolution applies this
closure:

- run invalidation excludes every record owned by that run;
- state invalidation excludes the state and dependent requests, executions,
  and estimates;
- request invalidation excludes the request and dependent executions and
  estimates;
- execution invalidation excludes that result and its accepted estimate; and
- estimate invalidation excludes only that estimate.

An adapter provides the resolved valid view. Consumers must not manually
reconstruct invalidation closure.

A correction that requires recomputation is a restatement: append an
invalidation, then deliberately execute a new run with a new identity and
provenance referencing the superseded run and invalidation. The replacement
records receive their own normal identities. This describes how restated facts
relate; it does not provide a replay command or silently run current code over
old inputs.

## Raw, valid, and current reads

The persistence port supports:

- exact identity read for one record family;
- all records associated with one runtime run;
- estimate history for an episode, optionally narrowed to an estimand; and
- the current valid estimate for an episode and estimand at an explicit
  cutoff.

Exact, run, and episode-history reads accept `raw` or `valid`. Raw retains
invalidated facts and invalidation evidence. Valid applies the cascade above.

Current estimate reads always use valid records from runs terminally marked
`completed` or `completed_with_failures`. At or before the requested cutoff,
the greatest estimate `as_of_time` wins; terminal `status_time` breaks a tie.
If more than one candidate remains tied, the read fails as ambiguous instead
of choosing by storage order, provider name, insertion time, or record ID.

## Persistence port and adapter contract

`rrpruntime` owns the semantic port because the records and their relationships
are runtime concerns. Repository operations will later compose the port with a
real adapter; generic runtime never discovers a repository path or named
technology.

The public port functions are:

```r
new_persistence_port(adapter, history_contracts)
append_run_status(port, run_status)
append_completed_run(port, run_status, episode_states, estimand_requests,
                     provider_execution_results, estimates)
append_history_invalidations(port, invalidations)
read_history_record(port, record_family, record_id, view)
read_run_history(port, runtime_run_id, view)
read_episode_estimate_history(port, episode_id, estimand_id, view)
read_current_estimate(port, episode_id, estimand_id, as_of_time)
```

`platform.persistence-adapter@0.1.0` requires matching logical methods and
affirmation of six capabilities: atomic completed-run append, identical append
idempotency, conflicting-identity rejection, append-only invalidation, raw
reads, and validity-resolved reads. It deliberately says nothing about tables,
files, connections, query languages, indexes, locks, serialization, or a
vendor.

The package validates records and completed batches before delegation. The
adapter remains responsible for atomic visibility, conflict-safe append, raw
retention, invalidation resolution, and deterministic read ordering in its own
physical environment.

## Test-only realization

`tests/helpers/in-memory-history-adapter.R` is an ephemeral conformance double.
It stores copied R objects in one process solely to exercise the logical port.
It proves append/read, identical retry, conflicting content, provider
transition, invalidation cascade, restatement, and incomplete-run behavior.
It is not packaged, documented as an operation, durable, supported for adopter
data, or eligible to become the reference adapter by accident.

## Reference evidence classification

The clean design above preceded inspection of the sibling repository. The
subsequent read-only review classified its evidence as follows:

- stable product-set identities, coherent-set counts/hashes, tamper detection,
  and explicit generation-input attribution: **adapt as principles** for
  future adapter validation where they are useful;
- separate occurrence/as-of meaning and deterministic state identity in the
  canonical pipeline: **reference only**, because the clean state record
  already owns the necessary semantics;
- Git revisions A/B/C as generation/product/deployment identity:
  **reject for operational history**;
- tracked application CSVs as persistence or historical truth: **reject**;
- weekly trajectories rebuilt by rerunning current code over an as-of grid:
  **reject**; future trajectories must read retained estimates;
- fixed eight-product manifests, app storage paths, current-commit cycles, and
  product refresh behavior: **defer or reject as foundations** because products
  and deployment are outside Iteration 5.1.

No old code, record, identifier, text, configuration, data, or dependency was
copied into the implementation.

## Iteration 5.2 requirement

The next iteration should select the smallest local durable adapter only after
evaluating it against this port. It must implement every declared method and
capability, prove atomic terminal batches under injected failure, preserve
same-ID conflict behavior across process restarts, resolve invalidations,
return unambiguous current reads, and document setup, side effects, validation,
backup/recovery, and troubleshooting. The technology is a reference choice,
not a platform requirement.
