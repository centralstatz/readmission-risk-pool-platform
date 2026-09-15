# Validation governance

## Current state

The RRP 1.0.0 ownership dispatcher is active.
[`validation/ownership.yml`](../../validation/ownership.yml) is the
machine-readable inventory of current validators, protected invariants,
ownership, transition status, prerequisites, literal path triggers, executable
profiles, and frozen legacy aggregates. It is a development control, not an
installed RRP resource, project manifest, clinical contract, or release
authorization.

The dispatcher replaces historical Phase chronology as the ordinary source-
development selection mechanism. It does not retire the implemented `v0.1.0`
evidence. Exact old aggregates remain deliberately callable as legacy profiles
and deprecated `--mode` aliases.

Local and hosted breadth are intentionally different. Ordinary local work uses
`source-changed`; push and pull-request CI uses `ci-active` once; maintainers
may manually request exactly one explicit legacy profile for historical
regression evidence.

## Human commands

The normal local operation discovers tracked, staged, and untracked working-
tree changes relative to `HEAD`:

```sh
Rscript operations/validate.R --profile source-changed
```

Use explicit repository-relative paths when validating a proposed path set:

```sh
Rscript operations/validate.R --profile source-changed --paths PATH
```

Multiple literal paths may follow `--paths`. Use a simple branch, tag, or commit
identity to compare the working tree with another base:

```sh
Rscript operations/validate.R --profile source-changed --base BASE
```

Other forward operations are:

```sh
Rscript operations/validate.R --profile source-fast
Rscript operations/validate.R --profile ci-active
```

`source-fast` is the bounded local universal profile. The registered
`ci-active` command is the hosted push/pull-request authority, not the routine
command after every local edit.

Discover and explain routing without running validators:

```sh
Rscript operations/validate.R --list
Rscript operations/validate.R --profile source-changed --paths PATH --explain
Rscript operations/validate.R --profile legacy-v0.1-development --explain
Rscript operations/validate.R --profile legacy-v0.1-checkpoint --explain
```

A current validator whose status permits direct forward execution may also be
selected by stable ID:

```sh
Rscript operations/validate.R --validator repository.policy
```

Unknown, legacy-only, retired, or historical validator IDs fail closed.

## Profiles and selection

| Profile | Executable role |
|---|---|
| `source-fast` | Three bounded universal units: governance self-check, documentation, and repository policy |
| `source-changed` | `source-fast` plus every matching `active_scoped` or `replace_later` unit and all registered prerequisites |
| `ci-active` | Broad forward-relevant current and transitional component evidence |
| `legacy-v0.1-development` | Frozen exact 26-unit old development composition, executed through one compatibility process |
| `legacy-v0.1-checkpoint` | Frozen exact 38-unit old checkpoint composition, executed through one compatibility process |

`source-changed` matches only exact paths, literal directory prefixes, and
literal suffixes recorded in the registry. It does not interpret regexes,
globs, shell syntax, or configuration as code. Matching a file may select
multiple owners. Registered prerequisites expand recursively, precede their
dependents, and execute once. The explanation identifies global, profile,
path-matched, and prerequisite reasons in deterministic order. With no scoped
match, `source-fast` remains selected; Git discovery failure is reported and
never broadens silently to a larger profile.

Git cleanliness is not a source-validity invariant. Default discovery includes
unstaged tracked changes, staged changes, and untracked non-ignored files.
Generated ignored state is not selected.

The non-Phase `package.rrpruntime` and `package.rrpplatform` validators own
package structure, build, isolated installation/loading, `R CMD check`, and
static package-boundary evidence. Changes below the corresponding `packages/`
tree select their owner; `package.rrpplatform` depends on
`package.rrpruntime`, matching the only allowed package dependency direction.
Both participate in `ci-active` but not the bounded `source-fast` profile.

`ci-active` may still use Phase-named suites where the registry says they carry
forward evidence. It excludes Hospital distribution, Phase 11 delivery,
historical checkpoints/prose gates, release preparation, publication, and
public-acquisition verification. The hosted workflow lists none of those
members itself: it invokes `ci-active` once and the dispatcher prints the
registry-owned resolved membership and result.

## Execution boundary

The dispatcher validates the registry before planning. Each forward validator
runs once in an independent `Rscript` process. It captures every result,
continues across ordinary child failures so the complete selected result is
visible, and exits nonzero if any required unit fails. An interrupt stops the
active process and returns an interrupt status rather than spawning further
units.

Safe direct scripts are used as registered. Twelve existing repository-check
functions that previously were reachable only through the eager aggregate use
a finite code-owned compatibility adapter in
[`validation/R/current-boundary.R`](../../validation/R/current-boundary.R).
The adapter maps an allowlisted validator ID to exact source files and one exact
function. YAML cannot supply function names, expressions, source lists, or shell
commands. Unknown IDs fail closed, and the adapter never sources
`platform-validation.R`.

Repository policy has its own noninteractive operation:

```sh
Rscript operations/validate-repository-policy.R
```

It invokes the existing repository-policy semantics only; it does not enter a
Phase suite or either aggregate.

## Legacy compatibility

Run historical aggregate evidence only deliberately:

```sh
Rscript operations/validate.R --profile legacy-v0.1-development
Rscript operations/validate.R --profile legacy-v0.1-checkpoint
```

The hosted `validation` workflow exposes those two identities—and only those
two—as a required manual choice. Each choice invokes its exact registered
dispatcher command under read-only permissions, without secrets, release,
publication, deployment, artifact upload, or remote mutation. Push/pull-request
jobs cannot select either legacy profile. Existing publication preflight keeps
its separate exact checkpoint lifecycle behavior.

The old commands remain exact, visibly deprecated aliases:

```sh
Rscript operations/validate.R --mode development
Rscript operations/validate.R --mode checkpoint
```

The aliases bypass changed-path routing and map respectively to the two frozen
legacy profiles. One isolated legacy entry point retains the unchanged eager
source chain and `rrp_validate_platform()` behavior, including checkpoint
semantics used by publication preflight. Forward profiles cannot route through
that entry point merely because a validator was historically reachable from an
aggregate.

## Registry semantics and safety

A validator unit owns one noninteractive check and declares a stable ID,
boundary, lifecycle, status, protected invariants, structured runner, literal
triggers, prerequisites, transition link, and current checks. A profile is an
acyclic composition, not a new validator. Status meanings are:

| Status | Meaning |
|---|---|
| `active_global` | Required by every forward profile |
| `active_scoped` | Selected for its owned boundary |
| `composite` | A profile composition, not a validator |
| `legacy_callable` | Available only through deliberate legacy use |
| `historical_evidence` | Retained evidence, not ordinary forward validation |
| `replace_later` | Current evidence until a named successor passes |
| `retire_later` | Legacy evidence retained until its retirement condition passes |

Runner scripts must be regular, non-symlinked repository files. Registry and
dispatcher validation reject unknown references, duplicate IDs, cycles,
absolute or parent-traversing paths, malformed literal arguments, unsafe or
missing runners, shell syntax, and unclassified routing states. Protected
invariants cannot silently lose every current owner.

## Focused governance and recovery

Run the non-Phase governance evidence directly:

```sh
Rscript tests/run-governance-tests.R
```

It covers closed registry semantics, inventory and transition linkage, literal
matching, dirty/staged/untracked discovery, profile/prerequisite resolution,
determinism, deduplication, process isolation, combined failures, forward/
legacy separation, adapter allowlisting, direct repository policy, and exact
legacy composition and alias equivalence.

On a routing failure, use `--explain` with the same selector. Correct the
registry trigger or prerequisite only when ownership evidence is wrong; do not
broaden to `ci-active` to conceal ambiguous discovery. On a child failure, use
the printed validator ID and output, repair its owned boundary, and rerun the
same profile. Use an explicit legacy profile only when the historical aggregate
claim is actually required.

Contributor, agent, and hosted-CI instructions use this proportional model.
See [Implementation Conventions](implementation-conventions.md) for forward
code, resource, project-context, dependency, test, reuse, and shim rules. Stage
1 and Increments 1.A–1.E are complete after local acceptance of all 24
`ci-active` validators and the accepted hosted 1.D run. Component validators,
Phase suite names/locations, package and project validators, and release/
publication behavior remain unchanged. A later stage may reclassify a unit only
with its direct validator, registry, transition condition, focused routing
evidence, documentation, and implementation record updated together.
