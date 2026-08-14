# Observability foundation

This foundation realizes the diagnostic boundary in the
[Platform Architecture](platform-architecture.md) and
[Implementation Plan](platform-implementation-plan.md). Its machine-readable
sources are the [operation-run context contract](../../contracts/observability/operation-run-context.yml)
and [operational event contract](../../contracts/observability/operational-event.yml).
Human use is documented in [Operational Diagnostics](../operations/observability-and-diagnostics.md).

## Purpose and boundary

Iteration 9.1 adds a small, implementation-neutral diagnostic interface around
existing stable operations. It answers which operation attempt is running,
which major stage it reached, whether that stage completed, and what safe next
action is available after a failure. It does not create analytical truth.

Diagnostics are distinct from:

- the analytical runtime run and append-oriented operational history;
- provenance and validation evidence;
- metrics, service-level objectives, tracing backends, and alerting;
- security or clinical audit records; and
- scheduling, orchestration, and retention.

The operations layer owns the base-R interface. `rrpruntime`, canonical
contracts, provider semantics, persistence ports, products, and artifacts do
not depend on a console or logging implementation.

## Versioned identities

`platform.operation-run-context@0.1.0` identifies one attempt to invoke a
stable operation. Its `operation_run_id` is diagnostic correlation only. It is
never substituted for an analytical `runtime_run_id`, product build,
artifact, materialization, deployment realization, validation, or provenance
identity.

`platform.operational-diagnostic-event@0.1.0` defines one immutable event.
Events carry their specification, unique event and operation-run identities,
explicit-offset timestamp, controlled component and stage, severity,
lifecycle, stable code, safe message, related non-patient identities, and a
shallow safe-detail mapping. Terminal events also carry elapsed milliseconds.
Durations describe wall-clock operation diagnostics and never participate in a
deterministic domain identity or result.

## Lifecycle and severity

The initial severities are `debug`, `info`, `warning`, and `error`. The initial
lifecycle vocabulary is:

1. `operation_started`;
2. zero or more `stage_started` / `stage_completed` pairs;
3. exactly one `operation_completed`, `operation_completed_with_warnings`, or
   `operation_failed` terminal event.

An emitter refuses events after a terminal event. The reference run reports
bounded source/canonical production, runtime preparation, provider execution,
and persistence stages. Product, artifact, Connect-realization, and doctor
operations report their own meaningful boundaries. Events are aggregate: no
event is emitted per patient, encounter, episode, feature, or estimate.

## Privacy policy

Default diagnostics permit stable contract/provider/product/artifact/
realization relationships and an explicit allowlist of aggregate counts.
They reject:

- patient, encounter, or episode identities;
- ZIP, address, location, clinical-event, feature, risk, score, or probability
  values;
- raw records or arbitrary/nested payloads;
- SQL, queries, connection strings, environment dumps, and file paths; and
- credentials, passwords, tokens, authorization material, and private keys.

Messages and recovery hints are bounded single-line text and reject common
sensitive assignment/private-key forms. Instrumented failure boundaries emit
stable safe classifications and guidance rather than copying arbitrary
exception text into structured events. These controls are automated guardrails,
not privacy or security certification. Adopters remain responsible for review
of any new event field or sink.

## Sink and rendering interface

A sink is one callable accepting a validated event object. The emitter retains
event objects in memory independently of whether a sink renders them. The
reference sink writes bounded human-readable lines to the console and creates
no files, tables, database rows, or retained log store.

Console verbosity is an adapter concern:

- `normal` renders information, warnings, and errors;
- `quiet` renders warnings and errors and therefore never hides terminal
  failure; and
- `debug` renders every safe event.

The stable commands use `normal`. No new CLI/configuration framework is added
merely to expose verbosity. A future deployment may inject a different sink or
select verbosity without changing domain code, event semantics, or operation
results. Routing, buffering, retention, external vendors, and access controls
belong to that deployment realization and remain unimplemented.

## Correlation without conflation

`related_identities` may link an event to a runtime run, product set/build,
materialization, artifact instance/build, provider, or deployment realization.
Those identities retain their own semantics. An event does not validate them,
become their provenance, or enter operational history. Validation results also
remain their existing structured return values; console diagnostic lines do
not replace them.

Operation-run identity generation avoids R's random-number generator so
turning diagnostics on cannot perturb seeded reference computation. Event
timestamps, sequence identities, rendering, and sinks are excluded from all
analytical, product, artifact, and deployment identity inputs.

## Implemented scope and non-goals

The common boundary is used by doctor, the stable reference run, logical
product build/materialization, application-artifact build, and Connect Cloud
local-realization build. This is enough to trace the current human workflow
without claiming universal component instrumentation.

Iteration 9.1 deliberately adds no log directory, rotation, retention,
external service, trace/span protocol, metrics store, audit framework, alert,
schedule, deployment, or patient-level diagnostic. Those require separate
requirements and ownership.
