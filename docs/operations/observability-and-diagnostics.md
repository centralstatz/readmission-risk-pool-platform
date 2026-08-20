# Operational diagnostics

The normative boundary is defined in the
[Observability Foundation](../architecture/observability-foundation.md). Exact
aggregate validation commands and claim limits are in
[Validation](validation.md).

## What operators see

Selected stable operations now print structured diagnostic lines around their
existing human-readable result. For example:

```text
[2026-08-13T12:00:00Z] INFO operation-run::... operation/operation_started operation.started - Operation started.
[2026-08-13T12:00:01Z] INFO operation-run::... persistence/stage_completed run.persistence_completed - Operational history persistence completed. analytical_runtime_run_id=...
```

Use the operation-run ID to follow one command attempt. A related analytical
run, product, artifact, or realization ID is correlation only and retains its
own meaning. The authoritative success/failure result remains the operation's
structured return and process exit status. The console is not operational
history, provenance, validation evidence, metrics, or audit.

## Supported commands

Diagnostics are currently emitted by the unchanged human commands:

```sh
Rscript operations/doctor.R
Rscript operations/validate-producer.R
Rscript operations/run-platform.R --scale test
Rscript operations/build-reference-products.R --scale test --materialize
Rscript operations/build-application-artifact.R
Rscript operations/build-connect-cloud-deployment.R --destination PATH
```

The commands retain their documented inputs, outputs, side effects, recovery,
and exit statuses. No scheduling or background process is introduced.

## Privacy and safe interpretation

Expected events contain only lifecycle information, stable non-patient
identities, controlled status/classification values, and aggregate counts.
They must not contain patient/encounter/episode IDs, ZIP/location or clinical
values, risk/features, raw records, SQL, credentials, connection strings,
environment dumps, or arbitrary nested payloads.

If a proposed diagnostic needs such content, do not weaken the safe mapping or
put it in a free-text message. Define a privacy-reviewed aggregate or stable
non-patient classification. The automated checks reduce accidental leakage;
they do not certify arbitrary future messages or deployment sinks.

## Failure and recovery

A terminal `operation_failed` event is always severity `error` and includes a
safe recovery hint. The ordinary command error may contain more local
troubleshooting detail, but raw exception text is not copied automatically into
the structured event. Run doctor where advised, correct the named operation
input or state, and retry the same human command.

No event log is persisted by the reference implementation. Redirecting process
output is an operator/environment choice and gives that environment
responsibility for access, protection, rotation, and retention. The platform
does not currently support a retained diagnostic sink.

## Validation

Run the focused contract/privacy/lifecycle/renderer suite:

```sh
Rscript tests/run-phase9-tests.R
```

Run complete development or completed Phase 10 checkpoint validation:

```sh
Rscript operations/validate.R --mode development
Rscript operations/validate.R --mode checkpoint
```

When reviewing output, verify one correlated lifecycle, aggregate-only detail,
safe terminal recovery, unchanged domain/result identities, and absence of any
new log file or diagnostic database/table.
