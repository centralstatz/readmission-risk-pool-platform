# RRP 1.0.0 transition ledger

## Purpose and rules

This ledger turns the RRP 1.0.0 migration posture into reviewable retirement
controls. It tracks current machinery, the invariant that must survive, its
forward disposition, coexistence needs, and the evidence required before it
can leave the active path. It does not itself authorize implementation or
retirement.

Every validator in [`validation/ownership.yml`](../../validation/ownership.yml)
links to one stable `transition_id`. Non-validation machinery is recorded here
directly. Later stage closeout updates the relevant row's latest evidence and
notes; it does not rewrite the historical implementation record.

An item may be marked retired only when its named successor passes or the
authoritative architecture explicitly decides that its invariant no longer
belongs to RRP. Temporary shims need an owner, purpose, and testable retirement
condition from creation. The immutable published `v0.1.0` source, artifacts,
and evidence are never edited to perform a forward retirement.

## Ledger

| `transition_id` | Current location and purpose | Protected invariant | Disposition / authority now | Replacement stage | Coexistence need | Retirement condition | Latest completed-stage evidence and notes |
|---|---|---|---|---|---|---|---|
| `documentation-authorities` | True North, architecture, plan, implementation record, and maintained navigation | Documentation authority | Keep current authority; progressively reclassify implementation guidance | Stages 1 and 9 | Current and historical `v0.1.0` documentation must remain distinguishable | Stage 9 navigation and classification acceptance passes without breaking immutable release evidence | Stage 1.E accepts one forward authority chain and the distinction among the RRP 1.0 target, active development control, `v0.1.0`-derived executable behavior, and immutable release history without broad relocation |
| `validation-phase-controls` | `operations/validate.R`, repository policy, Phase runners/checkpoints, and prose gates | Privacy, dependency, documentation, and safe validation selection | Ownership profiles now route useful units; preserve exact modes as legacy; replace universal Phase governance | Stage 1 | Forward profiles and the isolated old aggregates coexist through the Stage 1 transition | Stage 1 closeout proves active profiles, exact legacy bridges, CI agreement, and invariant continuity | Stage 1.E passes the 41-test governance suite, all 24 local `ci-active` validators, exact 26/38-member legacy comparisons, and retains hosted run `34885965725` / job `104116580336` at commit `3719054` as accepted push evidence |
| `foundation-canonical-contracts` | `contracts/foundation/`, `contracts/canonical/`, and their validators | Specification/canonical identity, compatibility, relationships, and temporal validity | Reuse foundation; refactor clinical target inputs | Stage 5 | Current canonical admission remains executable until the 1.0 handoff passes | Stage 5 terminal-availability and fixed-coverage contract plus migration evidence passes | Stage 1.A classifies foundation active-scoped and canonical evidence replace-later |
| `root-operation-scripts` | Repository-root `operations/` scripts and synthetic/reference orchestration | Human-first operations, deterministic fictional evidence, and safe mutation | Replace with installed shared operations across later stages | Stages 2–8 | Current wrappers remain executable until each successor operation passes | Each installed successor has matching human docs, tests, recovery, and explicit state ownership | Increment 2.A updates the existing temporary runtime installer to the single `packages/rrpruntime/` source; operations remain repository-owned and behaviorally unchanged |
| `operation-library-chain` | `operations/lib/` source-order chain and observability helpers | Boundary ownership plus privacy-safe diagnostics | Split by eventual package/resource owner | Stages 2–8 | The eager whole-platform chain is isolated behind legacy validation; finite source lists expose current repository checks | All live responsibilities have namespaced owners and no active operation depends on repository source order | Increment 2.A establishes `rrpplatform@0.1.0.9000` without moving the broad loose-code clusters; the explicit-path temporary installer remains a development-only bridge excluded from the future distribution and retires when Stage 3+ successors no longer need source-development package loading |
| `runtime-package` | Internal `rrpruntime` package, runtime/provider contract, and current temporal checks | Eligibility, temporal correctness, trust, explicit failure, and dependency integrity | Reuse and refactor | Stages 2 and 5 | Installed package work coexists with current daily-hazard behavior | Installed closure passes and Stage 5 cumulative-risk runtime replaces public hazard semantics | Increment 2.A relocates unchanged `rrpruntime@0.3.0` to `packages/rrpruntime/`, removes the old source authority, and adds package-owned build/check and boundary validation; daily-hazard semantics remain transitional |
| `estimand-daily-hazard` | Current configurable estimand and daily-hazard request/estimate semantics | No accidental relabeling; temporal and analytical meaning stay explicit | Replace; never rename as cumulative day-30 risk | Stage 5 | Callable only as clearly versioned transition/history | Singular platform-owned cumulative day-30 target passes and old identity is legacy-only | Stage 1.A records the invariant; no analytical code or contract changed |
| `provider-registry-execution` | Current producer/provider registration, selection, admission, and execution | Trusted extension, compatibility, temporal input, and failure integrity | Reuse and bind to independent project plus platform target | Stages 4–5 | Current installation-selected composition remains executable | Project/provider registration and singular target execution pass with no named implementation in generic runtime | Stage 1.A inventories repository, suite, and direct conformance evidence |
| `history-persistence` | History ports, current record families, and DuckDB adapter | Atomic append, retry, conflict, invalidation, restatement, and deterministic reads | Reuse/refactor | Stage 6 | Current hazard-oriented state stays isolated during transition | Versioned 1.0 history/state and migration/rollback evidence pass | Stage 1.A keeps current history validation replace-later |
| `products-materializer-application` | Logical products, YAML materializer/access, and product-only app | Product/history separation, integrity, freshness, and product-only consumption | Reuse boundary; refactor semantics | Stage 7 | Current hazard products/views remain until cumulative-risk replacements pass | Stage 7 products and app acceptance pass and current views become legacy-only | Stage 1.A keeps current product/app checks replace-later |
| `application-artifact-connect` | Target-neutral artifact and Connect Cloud realization | Closed inventory, dependency and content integrity, target separation, and no implicit publication | Reuse/refactor | Stage 8 | Repository-built realization remains until installed-input artifact proof | Product-only installed-input artifact plus each supported target realization passes | Stage 1.A classifies artifact/Connect repository, suite, and lifecycle evidence |
| `hospital-distribution-git` | Generated Hospital distribution and standalone Git realization | Immutable `v0.1.0` delivery evidence, safe destinations, and remote-free staging | Retire from active 1.0 path | Stage 9 | Retained for explicit historical verification only | Stage 9 retirement review proves replacement adoption path and preserves exact release evidence | Stage 1.A marks Hospital units retire-later and excludes them from planned forward profiles |
| `development-renv` | Root `renv.lock` and repository development environment | Reproducible development dependencies without payload conflation | Retain for development only | Stage 2 | Root environment supports current source while installed closure is established | Stage 2 proves installed software closure separately and documents root lock as development-only | Increment 2.A requires no dependency or lockfile change; target-keyed installed closure remains 2.E work |
| `release-publication-tooling` | Release preparation, GitHub publication, verification, and acquisition machinery | Authorization, immutability, checksums, recovery, and public verification | Preserve safeguards; replace two-product payload later | Stage 10 | Explicit `v0.1.0` lifecycle remains callable and outside ordinary profiles | One-product 1.0 release path passes equivalent or stronger safeguards and immutable old evidence remains | Stage 1.A inventories lifecycle checks; no release or remote operation ran |

## Stage 1.A state

Increment 1.A is additive. The registry is classification authority while the
existing `development` and `checkpoint` operations remain executable
authority. No item above is retired, no replacement stage has begun, and no
new runtime, distribution, project, or release component is implied.

## Stage 1.B state

Ownership-routed validation is executable through `source-fast`,
`source-changed`, and `ci-active`. The eager Phase aggregate no longer provides
forward routing; it remains unchanged behind the explicit
`legacy-v0.1-development` and `legacy-v0.1-checkpoint` bridges and their
deprecated exact `--mode` aliases. No Phase, Hospital, release, publication,
or source-chain machinery is retired. CI alignment and broader instruction
changes remain assigned to later Stage 1 increments.

## Stage 1.C state

Maintained contributor, agent, navigation, policy, convention, and validation
guidance now follows the current authority chain and proportional ownership
profiles. Forward conventions require component/lifecycle test ownership,
owned reusable code/resources, explicit project context and dependency owners,
recorded retireable shims, immutable published versions, and evidence-led reuse
of proven core capability without preserving obsolete structural coupling. No
implementation machinery is retired; CI alignment remains Increment 1.D.

## Stage 1.D state

The validation workflow now preserves its Ubuntu/R 4.4/root-`renv` environment
and read-only permissions while replacing separate documentation plus legacy
checkpoint execution with one registry-owned `ci-active` invocation on pushes
and pull requests. A manual workflow choice exposes exactly
`legacy-v0.1-development` or `legacy-v0.1-checkpoint`; neither branch performs
release, publication, deployment, artifact upload, or remote mutation. Static
and local evidence passes. GitHub Actions push run `34885965725`, job
`104116580336`, completed successfully at the exact 1.D commit `3719054` on
`main`, satisfying hosted acceptance. Increment 1.D is complete. Nothing is
retired.

## Stage 1.E and Stage 1 closeout state

All 12 authoritative Stage 1 gate categories pass. Ownership-routed forward
development control is active; exact legacy aggregates, the finite current-
boundary adapter, Phase-era evidence, the eager operation-library chain,
Hospital machinery, and release/publication safeguards remain contained and
callable under their recorded dispositions. No item is newly retired. The
`v0.1.0`-derived product/runtime remains executable and behaviorally unchanged,
and the installed-software/project architecture is not yet implemented. Stage
1 and Increments 1.A–1.E are complete.

## Stage 2 implementation state

The detailed Stage 2 plan is accepted. Increment 2.A is complete: the only
active package sources are `packages/rrpruntime/` and
`packages/rrpplatform/`, with one-way `rrpplatform -> rrpruntime` dependency and
non-Phase package validation. No machinery is retired, root `renv` remains
development-only, product identity remains `0.2.0-dev`, and no resource catalog
or distribution machinery exists. Stage 2 remains in progress; Increment 2.B
— installed-resource catalog and access boundary — is next.
