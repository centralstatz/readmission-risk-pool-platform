# RRP Command-Line Guide

The RRP command line uses one shallow noun-based grammar. The command itself is
`rrp`; package names, R library paths, and installed-resource paths are not part
of ordinary command syntax.

Use these discovery commands:

```text
rrp help
rrp --help
rrp software --help
rrp project --help
rrp reference --help
rrp state --help
rrp history --help
rrp products --help
rrp app --help
rrp run --help
```

This software version implements the project lifecycle command surface:

```text
rrp version [--json]
rrp project init PATH --project-id ID --project-version VERSION [--json]
rrp project validate|doctor|status [--project PATH] [...] [--json]
rrp reference init PATH [--json]
rrp reference prepare-source [--project PATH] [--json]
rrp state init|inspect [--project PATH] [--json]
rrp state backup|restore PATH [--project PATH] [...] [--json]
rrp run --at TIME --operation-key KEY [--project PATH] [--json]
rrp history scope|episode|current|retry|invalidate|restate ...
rrp products materialize|status ...
rrp app launch ...
```

It also implements the software installation and selection surface:

```text
rrp software install PATH --repository HTTPS_URL [--json]
rrp software list|current [--json]
rrp software verify|doctor [--software SELECTOR] [--json]
rrp software activate SELECTOR [--json]
rrp software uninstall SELECTOR [--yes] [--json]
rrp --software SELECTOR COMMAND ...
```

`PATH` is one already extracted, locally acquired distribution. The command
verifies it and delegates to the same private-library restoration and atomic
promotion engine as the distribution-local `install.R`. The host R is the
current version-specific launcher's recorded R. It accepts no project input.

Use `rrp <noun> --help` for the exact options. Project and reference creation
always require one positional destination whose parent already exists. Every
operation on an existing project uses exactly `--project PATH` when present or
exactly the current working directory otherwise. RRP does not search a parent,
inspect Git, remember a prior project, or associate a project with a software
version. An invalid current directory fails through the project contract.

Times are explicit RFC 3339 UTC values such as `2026-01-20T12:00:00Z`.
Analytical runs require both `--at` and an operator-owned `--operation-key`.
History reads, corrections, and product publication require the exact
identities and cutoffs shown by help; RRP never substitutes a latest run or
current time. Returned operation, analytical, action, product-set,
materialization, state, and backup identities can be supplied to later
commands.

Project initialization, fictional source preparation, state initialization,
backup, analytical runs, retries, corrections, and product materialization are
distinct explicit mutations. Restore and history correction additionally
require confirmation; use `--yes` for deliberate noninteractive operation.
Project validation, diagnosis/status, state inspection, history reads, product
status, and application launch are analytically read-only. `run`, `products`,
and `app` remain separate intentions: a run never publishes products, product
materialization never estimates risk, and app launch never refreshes either.

Human-readable output is the default. `--json` selects the one versioned,
privacy-safe machine result derived from the same operation. Warnings remain
successful results; usage and operation failures return nonzero status. The
command does not expose patient records, credentials, private mappings,
callables, connections, or storage internals.

The stable per-user launcher resolves the validated active realization or one
exact `PRODUCT_VERSION/DISTRIBUTION_ID` override. The selected version launcher
then establishes its recorded R executable, private package library, and
matching software resources before dispatch. Neither layer discovers a
project. Installation does not activate; activation changes only the atomic
software selection record. Upgrade composes install, exact verification, and
activation; rollback is exact activation of a retained prior realization.
Neither accepts a project path. `software uninstall` is a separately confirmed
destructive operation that removes only one exact verified inactive realization
and preserves the shared launcher and every other version. See the Software
Lifecycle Guide for refusal, recovery, and final-inactive-version behavior.
The installed Operator Guide gives the supported end-to-end project procedure
and the advanced R API boundary.
