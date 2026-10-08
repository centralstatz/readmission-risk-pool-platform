# RRP Operator Guide

## Projects and explicit context

An RRP project is one hospital-owned implementation of the installed RRP
project contract. Its editable source and project-owned state remain separate
from installed software. Commands operating on an existing project use exactly
`--project PATH`, or exactly the current working directory when that option is
omitted. RRP never searches parents, Git roots, siblings, an installation, or a
remembered registry.

Use `--json` when a versioned machine result is required. Human and JSON output
come from the same operation result and use the same exit status. Successful
commands, including success with warnings, exit 0; operation failures exit 1;
usage failures exit 2; invalid installed context exits 3. Returned identities
are intended to be copied into later commands.

## Initialize and diagnose

Create an ordinary hospital-owned scaffold only at an explicit absent
destination:

```text
rrp project init PATH --project-id ID --project-version VERSION
rrp project validate --project PATH
rrp project doctor --project PATH
rrp project status --project PATH
```

Initialization creates project source only. It does not create state, acquire
hospital data, execute a producer/provider, run analytics, or publish products.
Validation proves the project contract and selections without invoking either
component. Doctor and status summarize compatibility and readiness; absent
state or products are expected warning states rather than corruption. Optional
`--scope ID --cutoff TIME` evaluates product freshness only against that exact
context.

The supplied fictional, nonclinical teaching path is deliberately distinct:

```text
rrp reference init PATH
rrp reference prepare-source --project PATH
```

Preparation runs only the cataloged deterministic fictional generator and is
guarded by the exact fictional-project identity. It is not generic ingestion.
Hospitals implement their own source acquisition and canonical mapping in the
normal project authoring surface.

## State and recovery

State is explicit and project owned:

```text
rrp state init --project PATH
rrp state inspect --project PATH
rrp state backup BACKUP_PATH --project PATH
rrp state restore BACKUP_PATH --project PATH --yes
```

Initialization is create-only and idempotently validates compatible existing
state. Backup creates one absent closed checkpoint artifact. Restore accepts
one validated backup only when project state is absent, excludes rebuildable
products, and requires controlled confirmation. Omitting `--yes` in
noninteractive operation denies restore without mutation. None of these
commands migrates, repairs, schedules, or transports state.

## Run and history

One durable run requires deliberate analytical time and idempotency identity:

```text
rrp run --at TIME --operation-key KEY --project PATH
```

The returned `operation_run_id` identifies its admitted scope. The command
executes the selected producer and, where eligible, the selected provider under
the accepted contracts. It appends or idempotently matches history. It does not
materialize products or launch the app.

Focused reads require exact identities and cutoffs:

```text
rrp history scope --scope ID --project PATH
rrp history episode --episode ID --target ID --cutoff TIME --project PATH
rrp history current --episode ID --target ID --at TIME --cutoff TIME --project PATH
```

CLI history output is deliberately bounded: it exposes reusable analytical and
operation identities, outcomes, counts, and action evidence, but not patient
content, episode identifiers in output, retained state/request/estimate
objects, mappings, or storage internals.

Retry, invalidation, and restatement are advanced append-only corrections:

```text
rrp history retry --scope ID --analytical-run ID --retry-key KEY --project PATH --yes
rrp history invalidate --target-kind KIND --scope ID --target ID --effective-at TIME --reason CODE --actor CATEGORY --project PATH --yes
rrp history restate --target-kind KIND --scope ID --target ID --replacement-scope ID [--replacement-analytical-run ID] --effective-at TIME --reason CODE --actor CATEGORY --project PATH --yes
```

They require explicit targets, intent, effective time, reason, actor category,
and confirmation. Restatement resolves only an explicitly named governed
replacement record and delegates the existing atomic relationship operation;
it does not synthesize corrected clinical content. Constructing a new governed
episode replacement remains an advanced direct-R responsibility. Cancellation
or invalid inputs leave history unchanged.

## Products and application

Materialize one coherent set from one exact complete scope and history cutoff:

```text
rrp products materialize --scope ID --cutoff TIME --project PATH
rrp products status --project PATH
rrp products status --scope ID --cutoff TIME --project PATH
```

The first command builds accepted logical products and atomically publishes the
set. The second validates the current set; an optional paired scope/cutoff
reports fresh or stale without selecting a latest run. Product publication does
not execute analytics.

Launch the installed product-only application in the foreground:

```text
rrp app launch --project PATH
rrp app launch --scope ID --cutoff TIME --project PATH --port PORT
```

The optional comparison pair validates freshness. `--browser` requests a local
browser; hosting remains loopback-only. The foreground process exits normally
when the application stops and propagates interruption. It reads validated
products only and never executes a producer/provider, opens history directly,
refreshes products, or creates project application source.

## Advanced R use and limits

The CLI is a thin transport over exported `rrpplatform` operations. Advanced
clients may call those R APIs directly with an explicit installed resource
catalog and project root, including storage-neutral history objects needed for
deliberate episode restatement. Direct use does not relax project, state,
history, product, privacy, or compatibility contracts.

This guide does not describe an installer or active-version selector. The
current launcher operates one explicitly supplied installed context. No
distribution builder, dependency restoration, activation, upgrade, rollback,
uninstall, project migration, generic source acquisition, scheduler, daemon,
remote publication, or deployment artifact is implemented here.
