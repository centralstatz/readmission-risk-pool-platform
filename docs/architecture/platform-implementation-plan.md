# Platform implementation plan

## Status and authority

**Status:** authoritative clean-build sequence

This plan derives from [Platform Architecture](platform-architecture.md), which
derives from [Platform True North](../vision/platform-true-north.md). It is not
a continuation of the sibling repository's refactoring plan.

The plan starts from an empty software repository. Each phase must leave a
coherent, documented state and must add an entry to the
[implementation record](platform-implementation-record.md). Later phases may
refine sequencing when evidence changes, but they must record the reason rather
than silently drift.

## Implementation strategy

### Target interfaces, simple realizations

Build the intended public boundary first, then place the simplest valid
implementation behind it. Early R objects, local files, a deterministic
provider, and a small Shiny application are useful if they exercise the same
contracts expected of later implementations.

> Implement simple valid realizations behind the correct architecture, then
> replace implementations later without replacing the architecture.

### Working vertical milestones

The repository should become executable in a narrow end-to-end form once the
minimum canonical, temporal, estimand, provider, and history semantics exist.
It should not wait for every backend adapter or public operation to be complete.
Conversely, the early slice must not write source data directly into app files,
substitute reconstructed trajectories for operational history, or let the app
invoke a provider.

### Evidence and reuse

Before implementing a subsystem, revisit the relevant rows in
[Reference Asset Reconciliation](reference-asset-reconciliation.md), inspect the
candidate assets just in time, and record the actual reuse decision. A prior
classification is guidance, not authorization to bypass current design or
review.

### Continuous quality spine

From the first executable phase, retain a regression path:

```text
synthetic source
  → canonical handoff
  → validation
  → eligibility/state
  → conforming default provider
  → append-oriented records
  → logical products
  → supplied application
  → reference deployment
```

The path grows by phase. Tests and documentation distinguish fictional
software conformance from clinical validity.

## Phase map

| Phase | Milestone | First material use |
|---:|---|---|
| 0 | Repository and engineering foundation | Clear, testable project conventions |
| 1 | Identity, compatibility, and contract foundation | Public specification vocabulary |
| 2 | Canonical implementation boundary | Independently supplied canonical data |
| 3 | Synthetic reference implementation | Complete conforming source producer |
| 4 | Minimal governed runtime and provider | Valid state and estimate records |
| 5 | First persistent vertical slice | Working products and minimal app over real operational history |
| 6 | Operational-history and product maturity | Corrections, transitions, capability-aware views |
| 7 | Stable platform operations and adoption guides | Human-operable selection/build/run/recovery |
| 8 | Deployment build and Connect Cloud reference | Validated target-specific realization |
| 9 | Observability integration | Correlated, privacy-conscious operations |
| 10 | Adapter independence | Concrete replacement of a reference component |
| 11 | Distribution and open-source governance | Intentionally supported public release |

## Phase 0 — Repository and engineering foundation

### Objective

Turn the documentation bootstrap into a small, safe engineering workspace
without adding domain runtime behavior.

### Deliverables

- license decision or an explicit non-release placeholder policy;
- `.gitignore`, `.editorconfig`, and minimal repository metadata;
- documentation link/path validation;
- a lightweight test/validation entry point with development and strict
  checkpoint concepts kept distinct;
- initial versioning and change-record conventions;
- privacy, fictional-data, and nonclinical test-fixture rules; and
- exact human instructions for validation.

Do not initialize `renv`, CI/CD, a package, or deployment tooling until an
executable need exists.

### Exit evidence

- a fresh checkout can run documentation validation;
- broken local links and malformed governing files fail clearly;
- repository status and generated/local path policy are understandable; and
- human and agent guidance name the same validation operation.

### Dependencies and decisions

No software prerequisite. License selection becomes material before public
distribution, not necessarily before internal Phase 0 work.

## Phase 1 — Identity, compatibility, and contract foundation

### Objective

Define cross-layer vocabulary before individual schemas make accidental
identity decisions.

### Deliverables

- compatibility and versioning policy for pre-1.0 contracts;
- logical definitions for as-of context, run identity, implementation identity,
  capability status, provenance references, and conformance results;
- contract authoring and validation conventions;
- initial diagnostic-envelope vocabulary without a logging implementation;
- machine-readable format decision based on small examples; and
- fixtures proving version and error-reporting conventions.

### Exit evidence

- contracts can identify themselves and report structured, actionable failures;
- reference defaults are visibly distinct from universal values;
- logical identity does not depend on Git, file layout, R lists, or a database;
  and
- tests distinguish contract validation from clinical validation.

### Dependencies and decisions

Depends on Phase 0 validation. Decide the initial schema/specification format
and pre-1.0 compatibility expectations here. Do not decide a production store.

## Phase 2 — Canonical implementation boundary

### Objective

Make the first public source-to-platform interface explicit and independently
testable.

### Deliverables

- selected canonical domain schemas and vocabularies;
- bundle identity, as-of context, implementation/mapping provenance, and
  capability declarations;
- required, conditional, optional, unavailable, and unsupported semantics;
- structural, relationship, vocabulary, and temporal conformance rules;
- a representation-neutral producer/result interface;
- an independent canonical fixture with no synthetic implementation imports;
- R realization and validator only as needed to exercise the logical contract;
  and
- compatibility examples and failure fixtures.

### Exit evidence

- a separately constructed fixture passes the public handoff and reaches a
  no-op/minimal generic consumer;
- future information, bad keys, invalid windows, and false capability claims
  fail with structured issues;
- list/file/table mechanics are not public requirements; and
- generic code has no reference-implementation names or paths.

### Dependencies and decisions

Depends on Phase 1 identity and compatibility vocabulary. Maintainers decide
the first required/capability-dependent domains before completion.

## Phase 3 — Synthetic reference implementation

### Objective

Create the first complete source implementation beneath the public boundary.

### Deliverables

- deterministic fictional source generation with declared seed, as-of time,
  generator version, and scale;
- recognizable relational source domains rather than renamed canonical tables;
- implementation-owned source validation and mappings;
- explicit mapping provenance and fictional/nonclinical classification;
- implementation conformance operation and report;
- focused small fixtures plus a richer reference scale; and
- onboarding documentation explaining what a local implementation replaces.

### Exit evidence

- repeated generation is deterministic for declared inputs;
- source failures and canonical failures remain distinguishable;
- the implementation passes the same handoff as the independent fixture;
- generic code contains no synthetic branch; and
- no generated data are required to be committed merely to prove generation.

### Dependencies and decisions

Depends on Phase 2. Decide whether a small prebuilt fictional bundle is also
distributed for immediate exploration; generation remains reproducible either
way.

## Phase 4 — Minimal governed runtime and provider

### Objective

Produce valid state and estimates through the intended runtime and extension
interfaces.

### Deliverables

- focused internal R package under `runtime/` with minimal dependencies;
- canonical/bundle validation API, eligibility, dual-time filtering, and a
  small versioned state contract;
- at least one versioned default estimand with explicit event, horizon,
  terminal, and coherence semantics;
- provider specification, controlled registry/selection, and execution request;
- transparent deterministic nonclinical provider valid for that estimand;
- universal and estimand-specific conformance scenarios;
- standardized estimate record with run/state/estimand/provider provenance;
- separation of estimate generation from decision/priority policy; and
- an operation that runs synthetic bundle → state → estimate in a clean session.

### Exit evidence

- a second tiny test provider can register and run without generic-runtime
  edits;
- missing capability, unsupported estimand, execution failure, invalid bounds,
  cardinality, horizon, future information, and terminal behavior are tested;
- the default provider is simple but contractually valid and visibly
  nonclinical; and
- package APIs do not depend on source implementations, products, app,
  deployment, Git, or optional methods.

### Dependencies and decisions

Depends on Phases 1–3. Maintainers must approve the first default estimand and
initial provider trust/registration boundary. Full non-R provider execution is
deferred.

## Phase 5 — First persistent vertical slice

### Objective

Deliver the first small working product without violating history, product, or
application boundaries.

### Deliverables

- logical ports for appending and reading runs, state, and estimate records;
- a lightweight local reference storage adapter;
- initial idempotency and prospective-start behavior;
- one current episode product, one trajectory/history product, and one compact
  summary or queue, each with versioned contracts;
- local product materialization/access adapter;
- a minimal Shiny interface that reads only those logical products;
- one human command sequence to generate, run, persist, build products, and
  launch; and
- end-to-end fictional regression tests.

### Exit evidence

- day `t` and `t+1` append distinct records;
- retry behavior follows a declared idempotency key;
- trajectories read persisted estimates rather than reconstructing historical
  estimates under current code;
- product rebuild leaves history unchanged;
- the app can change storage adapters without source or provider knowledge; and
- a new user can reach a visibly fictional working app through documented
  commands.

### Dependencies and decisions

Depends on Phase 4 identities and records. Choose only a reference local
storage technology; do not make it the production requirement. The first
product subset is provisional pending the product-suite decision.

## Phase 6 — Operational-history and product maturity

### Objective

Complete the history semantics and evolve the first slice into stable,
capability-aware product interfaces.

### Deliverables

- explicit duplicate, correction, invalidation, and restatement behavior;
- transaction and backend conformance expectations;
- provider/estimand/platform/state-schema transition representation;
- retained decision and lineage records where their operational meaning
  justifies persistence;
- versioned product-suite composition, keys, relationships, freshness, and
  compatibility;
- explicit partial/unavailable capability behavior;
- current, trajectory, care-management, executive, and lineage products chosen
  for the reference suite; and
- storage adapter contract tests and migration rules.

### Exit evidence

- provider A history remains visible when provider B begins;
- correction/restatement never silently overwrites prior operational truth;
- a prospectively initialized deployment works with empty prior history;
- products rebuild consistently from authoritative records;
- optional products can be absent without false zero values; and
- app consumers reject or qualify incompatible/stale products safely.

### Dependencies and decisions

Depends on the Phase 5 slice. Resolve persistence semantics and the default
product suite before freezing their first supported versions. Production
database choice remains deployment-owned.

## Phase 7 — Stable platform operations and adoption guides

### Objective

Make stable capabilities fully human-operable through one reusable control
surface.

### Deliverables

- callable operations with IDs, inputs, outputs, side effects, validation,
  structured results, dry-run where appropriate, and recovery behavior;
- human entry points for initialize, doctor, validate, generate reference,
  build/run, select implementation/provider, build products, launch, and
  upgrade as supported;
- operation registry and documentation-drift tests;
- fresh-checkout and clean-session tests;
- guides for exploration, local integration, prototype, pilot preparation, and
  governed operational adoption; and
- agent mappings that invoke, rather than reproduce, those operations.

### Exit evidence

- an experienced external developer can operate and troubleshoot supported
  flows without conversation history or AI;
- selection changes configuration, not generic source code;
- agents and scripts reach the same implementation; and
- mutation and checkpoint requirements are explicit.

### Dependencies and decisions

Thin human wrappers begin earlier, but stable extraction depends on Phases 2–6.
Decide whether a CLI or package control surface adds evidence-based value only
after operation APIs stabilize.

## Phase 8 — Deployment build and Connect Cloud reference

### Objective

Prove the deployment interface with a safe, target-specific reference
realization.

### Deliverables

- deployment artifact contract and target profile;
- explicit runtime allowlist and generated adapter/template boundary;
- independent artifact validation from a clean copy/session;
- artifact and product/run provenance linkage;
- Connect Cloud target builder and validation;
- separate, conservative publication operation with explicit destination
  ownership, staging, dry-run, and opt-in external mutations; and
- human deployment and recovery guides.

### Exit evidence

- the platform root is not a hosting application root;
- the artifact contains only target-required, approved content;
- target packaging does not change app, product, or model semantics;
- validation can prove portability without the sibling repository; and
- commit/push remain explicit rather than automatic defaults.

### Dependencies and decisions

Depends on a stable application/product runtime and Phase 7 operations. Resolve
deployment ownership and publication destination before publication support.
Do not add other infrastructure without a concrete target.

## Phase 9 — Observability integration

### Objective

Connect stable operations and runtime stages with portable, privacy-conscious
diagnostics.

### Deliverables

- run context propagation across implementation, validation, computation,
  provider, persistence, product, app, and deployment operations;
- structured event contract, console renderer, verbosity, redaction, and safe
  context rules;
- bounded local reference sink plus deployment-owned routing interface;
- operational metrics separated from diagnostic events;
- explicit links among run diagnostics, provenance, and validation reports; and
- failure-actionability and redaction tests.

### Exit evidence

- one run can be followed across major stages;
- no default diagnostic contains PHI, raw records, secrets, or connection
  strings;
- routing/retention can change without domain-code changes;
- diagnostics do not alter computational results; and
- logging is not represented as a governed audit trail.

### Dependencies and decisions

The event vocabulary begins in Phase 1; integration waits for stable operations
and history. Deployments choose sinks and retention.

## Phase 10 — Adapter independence

### Objective

Demonstrate that a reference component can be replaced through the architecture
rather than a named exception.

### Deliverables

- one concrete non-synthetic canonical producer or realistic independent
  producer fixture;
- and/or one contract-tested non-file storage adapter;
- and/or a second deployment target based on a real need;
- conformance suites usable by each adapter category; and
- a cross-combination test matrix.

### Exit evidence

- the replacement requires no named hospital, storage, or target branch in
  generic code;
- reference components remain valid peers;
- missing capabilities are explicit; and
- changing one adapter does not require unrelated components to change.

### Dependencies and decisions

Depends on stable contracts and operations. Choose the adapter that provides
the strongest real evidence; do not build speculative abstractions merely to
complete the phase number.

## Phase 11 — Distribution and open-source governance

### Objective

Publish an intentionally supported open-source platform rather than an
unqualified source snapshot.

### Deliverables

- final license and asset/license inventory;
- contribution, security reporting, support, and code-of-conduct policies;
- release/version/compatibility and upgrade policy;
- supported R/OS/environment matrix;
- clean release validation and reproducible release metadata;
- public/private/companion methodology and extension policy;
- CentralStatz stewardship and branding boundaries; and
- evidence-based acquisition through clone, release archive, installer, or
  optional client.

### Exit evidence

- a supported release reproduces the fictional reference path;
- users understand compatibility, security, support, and adopter obligations;
- no proprietary service, agent, or optional package gates core operation; and
- release artifacts carry clear provenance and licensing.

### Dependencies and decisions

Legal and brand decisions can begin earlier. Formal public release depends on
stabilized contracts and operations. The role of `readmit` and extension
repository strategy are decided from demonstrated needs.

## Cross-phase rules

Every meaningful iteration must:

1. state the planned objective and affected architecture boundary;
2. inspect old-repository candidates just in time;
3. record reuse, adaptation, reference-only use, and newly written code;
4. preserve human-readable decomposition and dependency direction;
5. add success and failure validation proportional to risk;
6. update human operations and agent mappings together when operations change;
7. state compatibility and migration effects;
8. keep fictional/nonclinical labeling visible;
9. append the actual result to the implementation record; and
10. leave a recommended next task.

No phase may create a runtime/test/deployment dependency on
`../readmission-risk-pool`. No old asset may enter merely because it is already
implemented.

## Ordering rationale

Identity and compatibility precede domains because bundle, run, provider,
history, and product records must agree on attribution. The canonical boundary
precedes the synthetic producer so the reference conforms to a public
interface. Estimand meaning precedes provider selection. Provider and state
identity precede durable estimates. A narrow history-backed app arrives before
full persistence/product breadth to preserve an early working vertical slice.
Stable operations precede deployment and full observability because both need
well-defined run and side-effect boundaries. Adapter generalization follows a
real first implementation, and formal release follows stabilized public
interfaces.
