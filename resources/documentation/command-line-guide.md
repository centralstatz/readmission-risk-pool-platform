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

This software version implements these read-only commands:

```text
rrp version [--json]
rrp project status [--project PATH] [--json]
```

`project status` uses exactly `PATH` when `--project` is present. When it is
omitted, RRP uses exactly the current working directory. It does not search a
parent, inspect Git, remember a prior project, or associate a project with a
software version. A directory that is not a valid project fails through the
normal project contract.

Human-readable output is the default. `--json` selects the one versioned,
privacy-safe machine result derived from the same operation. Warnings remain
successful results; usage and operation failures return nonzero status. The
command does not expose patient records, credentials, private mappings,
callables, connections, or storage internals.

The launcher for one installed version establishes its recorded R executable,
private package library, and matching software resources before dispatch. It
does not choose an active version, install software, or discover a project.
Those lifecycle capabilities are not provided by this command foundation.
