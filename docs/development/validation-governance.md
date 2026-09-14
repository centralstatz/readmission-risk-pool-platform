# Validation governance

## Current state

The RRP 1.0.0 validation ownership model is now classified but not yet active.
[`validation/ownership.yml`](../../validation/ownership.yml) is the
machine-readable inventory of current validators, protected invariants,
ownership, transition status, prerequisites, path triggers, and planned
profiles. It is a development control, not an installed RRP resource, project
manifest, clinical contract, or release authorization.

The change is needed because the implemented aggregate organizes evidence by
historical Phase completion and loads nearly the whole repository for either
mode. That remains valid `v0.1.0` evidence, but it cannot answer which current
component or lifecycle owns a check, why a changed path needs it, or when a
transitional check may leave the forward path. Ownership and protected
invariants therefore govern the 1.0 transition; Phase chronology remains
historical evidence rather than the forward development hierarchy.

Increment 1.A does not change validation dispatch. The supported executable
aggregates remain:

```sh
Rscript operations/validate.R --mode development
Rscript operations/validate.R --mode checkpoint
```

Their exact ordered membership is frozen in the registry as
`legacy-v0.1-development` and `legacy-v0.1-checkpoint`. Named profiles such as
`source-fast`, `source-changed`, and `ci-active` describe the accepted routing
design, but they cannot be invoked until Increment 1.B implements and tests the
dispatcher. CI and the legacy commands are unchanged in this increment.

## Registry semantics

The planned Stage 1 model distinguishes four concepts:

- A **validator unit** is one owned, noninteractive check with a structured
  runner, protected invariant, triggers, prerequisites, and transition link.
- A **profile** is an acyclic named composition. It makes a bounded validation
  claim; it is not a new check.
- **Changed-path selection** will match literal repository-relative paths to
  scoped units, expand their prerequisites, and explain the deterministic
  result. Increment 1.A records triggers but does not execute this selection.
- A **legacy bridge** will preserve the exact old aggregate compositions under
  explicit names. Increment 1.A freezes those compositions; Increment 1.B will
  make the names callable without changing their meaning.

Component checks belong to the code or contract boundary whose conformance
they establish. Lifecycle checks belong to the operation whose stronger state,
artifact, Git, release, or publication claim they establish. A lifecycle rule
such as Git cleanliness must not become an unrelated source-validity rule.

Every validator entry identifies one current unit and records:

- a stable validator ID, owner boundary, and lifecycle scope;
- one status from the closed governance vocabulary;
- the protected invariants it currently carries;
- a repository-relative R script and literal argument vector;
- exact paths, literal directory prefixes, and literal suffixes for future
  changed-path routing;
- validator prerequisites;
- a transition-ledger link; and
- the current functions, scripts, or lifecycle checks covered by the entry.

The status vocabulary is:

| Status | Meaning |
|---|---|
| `active_global` | Required by every forward profile |
| `active_scoped` | Selected for its owned boundary |
| `composite` | A profile composition, not a validator |
| `legacy_callable` | Available only through deliberate legacy use |
| `historical_evidence` | Retained evidence, not ordinary forward validation |
| `replace_later` | Current evidence until a named successor passes |
| `retire_later` | Legacy evidence retained until its retirement condition passes |

The registry does not execute function names or shell text. Runner scripts must
be regular, non-symlinked files inside this repository. Paths are literal and
repository-relative; absolute paths, parent traversal, shell syntax, globbing,
and regular expressions are rejected. IDs and references are unique and
acyclic. A protected invariant cannot silently lose every current owner.
The protected set covers specification/canonical validity, temporal
correctness, history integrity, privacy and secrets, dependency integrity,
artifact integrity, release immutability, publication authorization/recovery,
documentation authority, and destructive-operation safety. Reclassification
may move their evidence but cannot weaken or silently discard these promises.

## Planned profiles

The registry records these profiles so Increment 1.B has one accepted source
of composition truth:

| Profile | Intended role | Executable now? |
|---|---|---|
| `source-fast` | Governance self-check, repository policy, and documentation | No |
| `source-changed` | `source-fast` plus path-owned validators and prerequisites | No |
| `ci-active` | All forward-relevant current and transitional evidence | No |
| `legacy-v0.1-development` | Exact current development aggregate | Through `--mode development` only |
| `legacy-v0.1-checkpoint` | Exact current checkpoint aggregate | Through `--mode checkpoint` only |

The three forward profiles are classification data only. The registry's
`governance_state.classification_only` and `activated_dispatcher` fields make
that limitation machine-readable. This prevents documentation or an agent from
claiming a command before its human operation exists.

## Governance check

Maintainers and agents can validate this classification without running any
Phase, Hospital, release, publication, or product operation:

```sh
Rscript tests/run-governance-tests.R
```

The check parses the registry and verifies its closed schema and statuses,
safe runner/path representation, unique identities, known references,
acyclic prerequisite/profile graphs, transition-ledger linkage, protected-
invariant continuity, current-check coverage, and exact-order legacy
aggregate capture. Its negative tests cover duplicate IDs, cycles, unsafe and
linked runners, unknown references, missing ledger links, lost invariants,
and unclassified current checks.

This command is intentionally a non-Phase development test runner. It changes
no state other than ordinary R process-local state and temporary test fixtures.
On failure, inspect the reported issue code, correct the registry or ledger,
and rerun it. Do not work around a failure by changing a current validator or
the old aggregate; those executable changes belong to Increment 1.B or the
later stage that owns the affected boundary.

## Updating ownership later

A later stage may change an entry only with all of the following in the same
meaningful iteration:

1. identify the actual boundary and invariant being changed;
2. add or update a direct, noninteractive validator owned by that boundary;
3. update its registry paths, prerequisites, runner, status, and current-check
   inventory;
4. update the linked transition-ledger condition and evidence;
5. test success, failure, routing safety, and invariant continuity; and
6. append the implementation record.

Do not invent validators for components that do not exist. A `replace_later`
or `retire_later` entry remains current or deliberately callable until its
ledger condition has named successor evidence. Published `v0.1.0` evidence and
release safeguards remain immutable and outside ordinary forward routing.
