# Platform implementation record

## Purpose and authority

This append-oriented record explains what the clean platform actually becomes.
The governing relationship is:

- [Platform True North](../vision/platform-true-north.md) defines the
  destination.
- [Platform Architecture](platform-architecture.md) defines the target
  structure and dependencies.
- [Platform Implementation Plan](platform-implementation-plan.md) defines the
  intended build sequence.
- [Reference Asset Reconciliation](reference-asset-reconciliation.md) records
  candidate reuse and evidence.
- This record documents what was done, learned, validated, and changed.

The record does not override True North. If implementation evidence requires an
architecture or plan change, update the authoritative document explicitly and
record the reason here.

For every meaningful iteration, append:

- planned objective;
- actual implementation;
- old-repository assets reused or adapted;
- new code or documentation created cleanly;
- decisions and rationale;
- surprises and deviations;
- validation evidence;
- implications for later phases; and
- recommended next task.

Do not rewrite an earlier entry to make later events appear planned. Add a
correction or follow-up entry.

## Bootstrap — Governing architecture and clean-build plan (2026-08-09)

### Planned objective

Bootstrap a completely clean repository with governing product direction,
target architecture, phased implementation plan, reference-asset
reconciliation, human/agent guidance, implementation conventions, navigation,
and an initial implementation record. Do not copy or implement runtime
software.

### Actual implementation

- Reconciled the old directional document into this repository's authoritative
  Platform True North.
- Designed a target architecture from product requirements before classifying
  old assets.
- Proposed top-level ownership, dependency direction, prohibited dependencies,
  logical ports, and a focused future internal R package.
- Created an eleven-phase clean implementation plan with a history-backed early
  vertical slice.
- Reconciled representative old contracts, synthetic code, engine/runtime
  behavior, providers, products, app, provenance, deployment, operations, and
  tests.
- Recorded phase-gated maintainer decisions and concise implementation
  conventions.
- Added human-first root agent guidance and repository/documentation navigation.

### Assets reused or adapted from the reference repository

No software, schema, fixture, configuration, generated data, or deployment
asset was copied or adapted into the clean repository during bootstrap.

The old Platform True North supplied product-direction evidence. Its durable
principles were preserved and rewritten cleanly; repository-specific current
state, migration language, and old architecture implications were removed.
The readiness assessment, canonical characterization, superseded plan and
record, and representative source/tests supplied evidence for classifications.

### New material created cleanly

All files in this repository were authored for the clean build:

- `README.md` and `AGENTS.md`;
- `docs/README.md` and `docs/START-HERE.md`;
- `docs/vision/platform-true-north.md`;
- `docs/architecture/platform-architecture.md`;
- `docs/architecture/platform-implementation-plan.md`;
- `docs/architecture/reference-asset-reconciliation.md`;
- `docs/architecture/open-decisions.md`;
- `docs/architecture/platform-implementation-record.md`; and
- `docs/development/implementation-conventions.md`.

### Decisions

1. The authority chain is True North → architecture → plan → record →
   software. The sibling repository is outside it.
2. The clean semantic spine is implementation → canonical boundary → generic
   runtime → operational history → logical products → application.
3. Estimand meaning precedes provider implementation and selection.
4. A narrow, history-backed product/app slice arrives before full persistence
   and product breadth.
5. A focused internal R package under a future `runtime/` directory is useful,
   but the repository is not an R package and no package scaffold is justified
   during bootstrap.
6. No old asset is approved for direct reuse yet. High-value candidates are
   classified mostly as Adapt because target contracts do not yet exist.
7. Connect Cloud remains the reference target, never a core dependency.
8. Operational history is append-oriented and separate from application
   products from the first persistent slice.

### Surprises and findings

- The old canonical boundary is cleaner than its hard-wired orchestration: an
  independent seven-domain fixture reached generic state/provider behavior.
- The old provider extension point is less complete than its configuration
  suggests: provider selection is hard-coded and estimand semantics are not a
  governed executable contract.
- The old deployment and publication safeguards are among the most mature
  reusable patterns, but remain coupled to Connect/Git/fully-generated policy.
- The old application products contain useful consumer concepts but also carry
  implicit schemas, fixed-suite assumptions, reconstructed history, and
  synthetic provenance leakage.

### Deviations from plan

None. The task remained documentation- and architecture-only. No package,
dependency environment, runtime directory, schema, provider, persistence,
product, app, deployment script, or CI/CD configuration was created.

### Validation evidence

Validation results are recorded after the bootstrap files are complete:

- local Markdown link and navigation check: passed for all Markdown files;
- accidental absolute-path check: passed; no machine-specific filesystem path
  or local-file URI is present;
- sibling runtime-dependency check: passed; the repository contains only
  Markdown, and sibling paths appear only in explicit evidence/independence
  guidance;
- whitespace check: passed for every untracked file using
  `git diff --no-index --check`; root `git diff --check` also passed; and
- repository status review: passed; the only changes are the intended new
  `README.md`, `AGENTS.md`, and `docs/` tree, with no commit created.

### Implications for later phases

- Phase 0 can establish only the engineering foundation and documentation
  validator without prematurely choosing dependencies.
- Phase 1 must settle identity and compatibility vocabulary before schemas.
- Phase 2 should revisit canonical assets just in time and preserve dual-time,
  episode-key, and cross-domain semantics without freezing the R list.
- Phase 4 must approve a default estimand before selecting or adapting a
  provider.
- Phase 5 must build trajectories over persisted outputs, never reproduce the
  old historical reconstruction behavior.

### Recommended next task

Implement **Phase 0 — Repository and engineering foundation** as a narrow task:
add minimal repository metadata and a tested documentation-validation operation,
make development versus strict checkpoint intent explicit, and document the
exact human command. Do not yet add domain contracts, `renv`, the runtime
package, synthetic generation, providers, persistence, products, app,
deployment, or CI/CD.

## Phase 0 — Repository and engineering foundation

### Iteration 0.1 — Repository foundation and validation (2026-08-09)

#### Planned objective

Turn the documentation bootstrap into a small, safe engineering workspace.
Add only justified metadata, explicit license/version/privacy/fixture policy,
a first human documentation-validation operation, distinct development and
strict Phase 0 checkpoint claims, focused tests, and complete human guidance.
Do not begin domain or platform runtime implementation.

#### Actual implementation

- Added `.gitignore` for editor/OS debris, local R state, local environment
  files, caches, temporary paths, and the architecture-named generated `build/`
  area without creating placeholder directories.
- Added a minimal `.editorconfig` for UTF-8, LF endings, final newlines,
  two-space indentation, and trailing-whitespace removal.
- Added `LICENSE-STATUS.md` with an explicit no-public-release policy and no
  provisional legal license text.
- Added repository policies covering version/change bookkeeping, fictional
  fixtures, PHI and secret exclusions, base-R tests, and dependency deferral.
- Implemented callable base-R documentation, repository-policy, and Phase 0
  checkpoint validators that return structured checks and actionable issues.
- Added thin human commands for documentation-only, development, and checkpoint
  validation.
- Added a dependency-free Phase 0 test runner with ten temporary-fixture cases.
- Added human operations documentation and aligned README, docs navigation, and
  `AGENTS.md` with the exact tested commands.

#### Assets reused or adapted

The following sibling-repository assets were inspected read-only:

| Reference path | Actual classification | Use in this iteration |
|---|---|---|
| `scripts/lib/validation-modes.R` | **Adapt — concepts only** | Preserved the distinction between development coherence and stronger checkpoints; no code, mode matrix, names, or old checkpoint assumptions were copied |
| `tests/platform/test-validation-modes.R` | **Reference only** | Confirmed the value of testing claim boundaries and temporary invalid inputs; tests were written cleanly without `testthat` |
| `scripts/validate-documentation.R` | **Reference only** | Confirmed local-link validation as useful behavior; parsing, result structure, portability checks, and navigation rules were implemented cleanly |
| `scripts/validate-operations-docs.R` | **Adapt — principle only** | Preserved human-operation/documentation drift detection as a checkpoint check; no YAML dependency or large registry was introduced |
| `docs/operations/operations.yml` | **Reference only** | Demonstrated a future registry pattern; one operation does not yet justify a registry |
| `docs/operations/validation.md` | **Reference only** | Informed complete human coverage of purpose, claims, commands, failures, and recovery; clean documentation describes only current operations |

No code, tests, configuration, registry, or documentation text was copied from
the sibling repository. No direct-reuse classification was approved.

#### New material created cleanly

- `.editorconfig`, `.gitignore`, and `LICENSE-STATUS.md`;
- `docs/development/repository-policies.md`;
- `docs/operations/README.md` and `docs/operations/validation.md`;
- `operations/lib/validation-result.R`;
- `operations/lib/documentation-validation.R`;
- `operations/lib/repository-validation.R`;
- `operations/lib/platform-validation.R`;
- `operations/validate-documentation.R` and `operations/validate.R`;
- `tests/helpers/assertions.R`;
- `tests/phase0/test-documentation-validation.R`; and
- `tests/run-phase0-tests.R`.

Navigation and guidance changes were made to existing README, docs index,
START HERE, open decisions, and `AGENTS.md`.

#### Decisions

1. **Command structure:** Keep a focused documentation command and one aggregate
   validation command with explicit `development` and `checkpoint` modes.
2. **Callable design:** Validators return an `rrp_validation_result` containing
   pass/fail, executed checks, and file/line issues. CLI files only source,
   compose, print, and set process status.
3. **Mode meaning:** Development allows intentional changes and checks current
   coherence. Checkpoint adds only Phase 0 file, scope, licensing, dependency,
   and human/agent alignment requirements. Neither claims release readiness.
4. **Testing:** Use base R, phase-scoped `test-*.R` files, shared test helpers,
   and temporary repository copies. An external framework is not justified for
   ten small Phase 0 tests.
5. **Dependencies:** Phase 0 uses only base R. No external dependency was added.
6. **`renv`:** Deferred because there is no dependency to lock. A future phase
   must initialize this repository's dependency state independently if needed.
7. **Licensing:** No license was selected on the maintainer's behalf. The
   repository explicitly authorizes no public release and makes no implied
   license grant.
8. **Versions and records:** Git identifies repository history, the
   implementation record explains actual iterations, platform version waits
   for executable identity, and contract versions begin with their owning
   phases. Phase 1 still owns compatibility vocabulary.
9. **Privacy and fixtures:** Patient-level committed examples must be
   deterministic and fictional; PHI, real patient data, secrets, connections,
   and private hospital configuration are prohibited. Automated checks catch
   obvious cases but do not replace human review.
10. **Operations registry:** A registry is deferred until more than one
    operation or another concrete drift problem justifies it.

#### Surprises and deviations

The first strict-checkpoint run correctly failed because the license-policy
assertion assumed a required phrase remained on one Markdown line. The policy
itself was correct; the validator was changed to recognize ordinary whitespace
and line wrapping. A checkpoint test now guards the intended semantic behavior.

The fixture suite grew from the eight minimum cases to ten by adding explicit
mode parsing and proof that checkpoint validation rejects later-phase
scaffolding. This remained within Phase 0 scope.

No architectural or sequencing deviation occurred. No implementation-plan
adjustment is required.

#### Validation evidence

The final validation matrix passed:

- `Rscript operations/validate-documentation.R` — 4 checks, 0 issues;
- `Rscript tests/run-phase0-tests.R` — 10 tests, 0 failures;
- `Rscript operations/validate.R --mode development` — 9 checks, 0 issues;
- `Rscript operations/validate.R --mode checkpoint` — 13 checks, 0 issues;
- all 9 R files parsed successfully in a clean R process;
- untracked-file-aware whitespace validation — passed for every maintained
  tracked or untracked file;
- `git diff --check` — passed; and
- sibling/reference repository status — clean in a final read-only check.

Validation creates only removed temporary fixtures. It found no
machine-specific path, local-file URI, executable sibling dependency,
sibling-targeting symlink, obvious secret, unlabelled patient-like fixture,
later-phase scaffold, or dependency lock.

#### Implications for Phase 1

- Phase 1 can add identity/specification vocabulary as focused validators
  without replacing the result/CLI structure.
- Contract compatibility semantics remain deliberately undefined; Phase 1 must
  own them rather than inheriting the Phase 0 checkpoint model.
- If Phase 1 introduces an external R package, it must justify the dependency
  and establish clean dependency management here.
- Navigation expectations must be updated when new authoritative documents are
  added, keeping human entry points explicit.
- The simple secret/fixture checks are development guardrails, not privacy or
  security certification.

#### Recommended next task

Begin **Phase 1 — Identity, compatibility, and contract foundation** with one
bounded iteration: define the minimum logical vocabulary for specification
identity/version, as-of context, implementation identity, run identity,
capability status, provenance reference, and structured conformance results;
choose a small diff-friendly specification format through examples; and add
format/identity tests. Do not yet define canonical clinical domains or runtime
processing.

## Phase 1 — Identity, compatibility, and contract foundation

### Iteration 1.1 — Core specification and identity vocabulary (2026-08-10)

#### Planned objective

Establish the minimum reusable, machine-readable foundation that later
canonical, estimand, provider, persistence, product, diagnostic,
configuration, and deployment specifications can share. Select one format;
define identity, compatibility, time, capability, provenance, conformance, and
diagnostic vocabulary; prove it with readable generic examples and a small
validator; and preserve the boundary against Phase 2 and later implementation.

#### Actual implementation

- Selected YAML as the only authoritative specification-authoring format and
  defined a common envelope with kind, stable ID, meaning version, format
  version, identity scope, title, lifecycle status, and optional description.
- Authored one cohesive specification-foundation document, one vocabulary
  specification, and two small nonclinical examples covering identity/run
  context and a multi-issue conformance result.
- Defined quoted SemVer representation and an explicit pre-1.0 support policy,
  including fail-closed handling of unknown format and specification lines.
- Defined one authoritative RFC 3339 `as_of_time` per run, separate from event,
  availability, extraction, generation, and wall-clock execution times.
- Distinguished implementation from mapping identity and run from operation
  identity; defined capability statuses and minimal provenance references.
- Implemented structured conformance results that collect multiple issues and
  derive pass/fail from issue severity.
- Defined only the shared diagnostic-event vocabulary; no logging or
  observability mechanism was added.
- Added focused YAML parsing, envelope, compatibility, foundation-context,
  example, repository, and checkpoint validators under `operations/lib/`.
- Integrated specification and Phase 1 test checks into the existing
  development and checkpoint operation.
- Added fourteen Phase 1 success/failure tests and retained all ten Phase 0
  regression tests.
- Initialized this repository's own `renv` state and locked `renv` 1.0.9 and
  `yaml` 2.3.10 without copying sibling dependency state.

#### Reference assets inspected

All inspection was read-only and occurred after the clean foundation design.

| Reference path | Prior classification | Final decision in this iteration |
|---|---|---|
| `contracts/schemas/*.yml` and `contracts/README.md` | **Adapt** for future canonical semantics | **Reference only** for YAML readability and ID/version evidence; no field, version, seven-domain assumption, schema shape, or text was copied |
| `engine/R/contract-validation.R` | **Adapt** for a future canonical validator | **Adapt — result concept only**; collecting structured issues informed the clean result shape, but no code, project-root behavior, domain rule, or dependency pattern was copied |
| `engine/tests/testthat/test-contracts.R` | **Reference only** | Consulted for failure categories; the base-R Phase 1 suite and fixtures were written cleanly |
| `scripts/lib/validation-modes.R` | **Adapt** | Existing development/checkpoint separation was retained conceptually; no code or later-phase mode was copied |
| `contracts/validation/compatibility-policy.md` | Not separately classified | **Reference only**; confirmed shortcomings of the old draft convention, while the pre-1.0 SemVer policy was designed cleanly |

No reference code, schema, fixture, configuration, dependency state, or text
was copied. The inspection did not materially change the reconciliation table,
so that document required no classification update.

#### New material created cleanly

- `contracts/README.md`;
- `contracts/foundation/foundation-vocabulary.yml`;
- `contracts/examples/example-identity-context.yml` and
  `example-conformance-result.yml`;
- `docs/architecture/specification-foundation.md`;
- `operations/lib/conformance-result.R`;
- `operations/lib/specification-validation.R`;
- `operations/lib/foundation-context-validation.R`;
- `tests/phase1/test-specification-foundation.R` and
  `tests/run-phase1-tests.R`; and
- `.Rprofile`, `renv.lock`, `renv/activate.R`, `renv/settings.json`, and
  `renv/.gitignore` generated for this repository's dependency state.

Existing navigation, policies, validation composition, checkpoint behavior,
and human/agent guidance were updated to own this new foundation.

#### Decisions

1. **Format:** YAML is concise, commentable, language-neutral, and readable in
   review. JSON would still require a parser while making authored examples
   noisier. Multiple authoritative encodings are not maintained.
2. **Envelope identity:** Meaning lives in `specification_id` plus quoted
   `specification_version`; `specification_format_version` independently
   identifies envelope syntax. Kind, identity scope, title, and lifecycle
   status are explicit.
3. **Reference scope:** Reference examples use both a `reference.` namespace
   and `identity_scope: reference`, preventing defaults from silently becoming
   universal platform identity.
4. **Pre-1.0 compatibility:** Patch increments are limited to nonsemantic
   corrections or safely optional metadata. Semantic, requiredness, type, key,
   time, controlled-value, or failure changes move to a new minor line and may
   be incompatible. Consumers declare bounded support explicitly and fail
   closed on unknown lines.
5. **As-of context:** One explicit-offset RFC 3339 cutoff governs information
   availability for one run; other domain and operational timestamps never
   replace it.
6. **Implementation and mapping:** Each owns a stable logical ID and version.
   Source technology, path, and Git revision are optional evidence rather than
   mandatory logical identity.
7. **Run and operation:** `run_id` identifies one attempt, `operation_id`
   identifies the stable action, and `as_of_time` identifies its information
   cutoff. Later persistence work still owns retry, correction, duplicate, and
   restatement semantics.
8. **Capability status:** `available`, `unavailable`, `unsupported`, and
   `failed_conformance` distinguish supplied behavior, contextual absence,
   intentional non-support, and a failed claim without fabricating values.
9. **Provenance reference:** Type, logical ID, relationship, and optional
   version/revision provide representation-independent attribution. Git,
   hashes, URLs, and paths remain optional evidence.
10. **Conformance:** Results identify the candidate/specification and retain
    rule, severity, issue code, message, and optional object/location context.
    Errors derive failure; warnings/information alone do not. Software
    conformance makes no clinical-validity claim.
11. **Diagnostics:** Event time, run/operation, component/stage, severity,
    status, safe code, and message are reserved vocabulary only. Routing,
    sinks, redaction, verbosity, and retention remain Phase 9 work.
12. **Ownership:** Language-neutral assets belong in `contracts/`; temporary
    executable validation belongs in `operations/lib/` until Phase 4 can
    justify a runtime package.
13. **Dependency state:** The small `yaml` parser is justified by the selected
    format. `renv` was initialized independently at the first real external
    dependency.

#### Surprises and deviations

The first focused regression run exposed that generated, ignored
`renv/library/` content was still included by the repository's own recursive
file scanners. Both documentation and policy discovery now exclude standard
generated `renv` directories; a clean rerun passed.

The generated activation bootstrap also contained trailing spaces. They were
normalized mechanically before the final all-file whitespace check.

Within the managed execution environment, `renv` sandbox activation waited on
an unavailable global lock. Validation was run with the documented project
environment active and sandboxing disabled for those processes; this did not
change the lockfile or repository policy and is not a platform runtime choice.

No scope or architecture deviation occurred. The planned `contracts/`
ownership was activated, but no canonical domain, runtime package, provider,
persistence, product, application, deployment, or observability implementation
was begun. The architecture and implementation plan required no adjustment.

#### Validation evidence

The completed validation matrix passed:

- `Rscript operations/validate-documentation.R` — 4 checks, 0 issues;
- `Rscript tests/run-phase0-tests.R` — 10 tests, 0 failures;
- `Rscript tests/run-phase1-tests.R` — 14 tests, 0 failures;
- `Rscript operations/validate.R --mode development` — 14 checks, 0 issues;
- `Rscript operations/validate.R --mode checkpoint` — 21 checks, 0 issues;
- all 15 maintained R files, including the `renv` activation bootstrap, parsed
  successfully in a clean R process;
- all three maintained YAML specification examples parsed and conformed;
- malformed YAML and unsupported format/version fixtures failed with
  structured issues as expected;
- repository policy checks found no machine-specific path, executable sibling
  dependency, secret pattern, unlabelled patient-like fixture, or later-phase
  scaffold; and
- untracked-file-aware whitespace validation and `git diff --check` passed.

Validation used only temporary fixtures and did not modify the sibling
repository. No commit or push was performed.

#### Implications for Phase 2

- Every canonical domain and bundle specification must use the common envelope
  and keep format version separate from its own meaning version.
- Reference defaults must remain visibly reference-scoped and cannot become
  universal required domains by example.
- Phase 2 must define domain capability IDs while preserving the four status
  meanings and safe unavailable behavior.
- Canonical time fields must distinguish occurrence and recorded/available
  semantics while accepting the run's one authoritative as-of cutoff.
- Bundle and domain validation should extend the structured multi-issue result
  instead of throwing first-error strings or implying clinical validity.
- Implementation/mapping identity and minimal provenance references must be
  carried without hard-coding R, SQL, dbt, Python, Git, or filesystem paths.
- Phase 2 should design bundle representation cleanly and revisit old domain
  semantics just in time; it must not inherit the seven-domain R-list shape.

#### Recommended next task

Begin a bounded **Phase 2 / Iteration 2.1 — Canonical capability and bundle
identity foundation**: define the generic canonical bundle envelope, domain
registration/identity, capability declaration rules, and event-versus-recorded
time invariants using only generic nonclinical fixtures. Defer the first actual
clinical-domain field schemas to the following iteration so bundle and
capability semantics can be reviewed independently.

## Phase 2 — Canonical implementation boundary

### Iteration 2.1 — Canonical capability and bundle identity foundation (2026-08-10)

#### Planned objective

Define the generic, representation-independent canonical handoff container
before selecting readmission-specific domains or fields. Reuse the Phase 1
identity, compatibility, as-of, status, provenance, conformance, and diagnostic
vocabulary; add only bundle/instance identity, domain registration,
requirements, dependencies, and generic temporal-availability semantics.

#### Actual implementation

- Added `platform.canonical-bundle@0.1.0`, a language-neutral YAML contract for
  bundle identity, independently versioned domain registration, capabilities,
  requirement classes, typed dependencies, temporal declarations, and layered
  conformance.
- Distinguished the public bundle specification from one concrete
  `bundle_instance_id` produced for a run and authoritative as-of cutoff.
- Reused the Phase 1 `available`, `unavailable`, `unsupported`, and
  `failed_conformance` statuses for both domain and capability declarations.
- Defined `required`, `conditional`, and `optional` independently of status.
  The first conditional form references one declared domain/capability and
  `required_status: available`; it is not an expression language.
- Defined unique, acyclic domain-to-domain and capability-to-capability
  dependencies. An available subject requires an available prerequisite.
- Prohibited unavailable/unsupported domains from claiming an instance,
  preserving absence without fake rows, empty fabricated data, or zero values.
- Carried run/as-of, implementation, mapping, provenance, and optional producer
  conformance-result references without requiring Git, paths, hosts, R names,
  database schemas, or storage technology.
- Defined domain-owned occurrence/effective and availability/recorded field
  roles. Generic conformance rejects impossible declared ordering and
  information unavailable at the bundle cutoff without implementing runtime
  filtering.
- Added six readable generic nonclinical examples: valid, optional unavailable,
  unsupported, failed capability claim, missing prerequisite, and temporal
  failure.
- Implemented focused bundle, registration, condition, dependency-graph,
  provenance, temporal, maintained-example, repository, and Phase 2.1
  checkpoint validators under the existing transitional `operations/lib/`
  ownership.
- Added eighteen Phase 2 success/failure tests and integrated canonical assets
  plus Phase 0–2 regression suites into development/checkpoint validation.

#### Reference assets inspected

The clean generic design was drafted first. The following sibling assets were
then inspected read-only:

| Reference path | Prior classification | Final decision and actual use |
|---|---|---|
| `docs/architecture/canonical-bundle-boundary.md` | **Reference only** | **Reference only**; confirmed durable representation independence, name-not-order behavior, dual-time needs, top-level as-of/capability gaps, and synthetic metadata leakage; no wording or seven-member shape was copied |
| `contracts/schemas/*.yml` | **Adapt** for future domain semantics | **Reference only in Iteration 2.1**; supplied evidence that domains need independent versions and temporal roles, but no field, domain set, version, requiredness, schema shape, or old `0.1.0-draft` value was copied |
| `contracts/vocabularies/*.yml` | **Adapt** for future vocabularies | **Reference only in Iteration 2.1**; confirmed versioned controlled-value value, but no clinical vocabulary was selected or copied |
| `engine/R/contract-validation.R` | **Adapt** | **Adapt — multi-issue principle only**; retained structured collection of failures, while code, tibble dependency, project-root lookup, schema API, and helper names were not copied |
| `tests/fixtures/canonical-bundle-fixture.R` | **Adapt** | **Adapt — independence test principle only**; clean YAML/R fixtures prove a separately constructed handoff and ordering independence without copying seven tables, rows, R-list structure, or helper code |
| `tests/platform/test-canonical-boundary.R` | **Adapt selectively** | **Adapt — failure/independence principles only**; clean tests cover missing relationships, ordering independence, and sibling/source independence through the new public identity model |

The review confirmed rather than changed the reconciliation classifications,
so `reference-asset-reconciliation.md` required no table update. No sibling
code, text, schema, fixture, vocabulary, configuration, or version was copied.

#### New material created cleanly

- `contracts/canonical/canonical-bundle.yml`;
- six files under `contracts/canonical/examples/`;
- `docs/architecture/canonical-bundle-foundation.md`;
- `operations/lib/canonical-bundle-validation.R`;
- `operations/lib/canonical-specification-validation.R`;
- `tests/phase2/test-canonical-bundle-foundation.R`; and
- `tests/run-phase2-tests.R`.

Existing validation composition, scope checkpoints, navigation, current-status
documentation, repository policies, open decisions, and agent guidance were
updated for Phase 2.1.

#### Decisions

1. **Bundle specification versus instance:**
   `platform.canonical-bundle@0.1.0` defines public meaning;
   `bundle_instance_id` identifies one concrete handoff. Neither is a filename,
   object name, or Git revision.
2. **Domain registration:** A unique logical `domain_id` references an
   independently versioned `canonical_domain` specification. Optional instance,
   capability-association, and temporal declarations do not define storage.
3. **Capability status:** The Phase 1 status vocabulary is reused exactly.
   `failed_conformance` always fails admission; unavailable and unsupported
   remain distinct non-fabricated absence states.
4. **Requirement classes:** `required`, `conditional`, and `optional` describe
   contract/profile obligation independently from implementation status.
5. **Conditional form:** A conditional item references one declared domain or
   capability and activates when it is available. Arbitrary Boolean rules and
   executable YAML are deferred unless concrete evidence justifies them.
6. **Dependencies:** The initial acyclic graph supports only domain-to-domain
   and capability-to-capability edges. Cross-type edges and rule engines are
   intentionally unsupported.
7. **As-of carrier:** The bundle directly carries Phase 1 run context. Source
   extraction, generation, and wall-clock execution cannot substitute for its
   one authoritative cutoff.
8. **Occurrence/availability:** A domain owns the names of its temporal roles
   and whether availability-before-occurrence is impossible. Availability
   after bundle as-of always fails admission.
9. **Conformance layering:** Source-local, domain, bundle structure,
   cross-domain/capability, and platform-admission levels share one structured
   result while retaining level-specific rule IDs and issue codes.
10. **Reference test realization:** Generic records may be embedded and matched
    by `domain_instance_id` only for executable tests. This is explicitly not a
    public bundle representation.
11. **Compatibility:** Bundle and domain meaning versions are independent and
    follow the Phase 1 pre-1.0 policy. The current bundle reader supports only
    the explicit `0.1` line and fails closed on unknown lines.
12. **Conformance-result reference:** A candidate may link producer-local
    conformance evidence, but the platform's derived result remains the
    admission authority and is returned beside the candidate rather than
    trusted from it.
13. **Dependencies:** No new software package was justified. Existing
    `yaml`/`renv` state remains sufficient.
14. **Transitional ownership:** Executable validation remains in
    `operations/lib/`; no runtime package is created before Phase 4.

#### Surprises and deviations

The sibling characterization made the zero-row convention's ambiguity
especially concrete: a typed empty table currently means both “member exists”
and “no records,” but cannot distinguish optional, unavailable, unsupported,
or failed. The clean design therefore represents status independently and
prohibits fabricated instances for unavailable/unsupported domains.

YAML parses an empty sequence into a value that required explicit normalization
before exact expected-issue comparison. The maintained-example validator now
normalizes empty and populated issue-code sequences consistently.

No architecture or sequence deviation occurred. `contracts/canonical/` is the
planned public specification location; executable proof remains transitional.
No clinical-domain set or field semantics were selected.

#### Validation evidence

The completed validation matrix passed:

- `Rscript operations/validate-documentation.R` — 4 checks, 0 issues;
- `Rscript tests/run-phase0-tests.R` — 10 tests, 0 failures;
- `Rscript tests/run-phase1-tests.R` — 14 tests, 0 failures;
- `Rscript tests/run-phase2-tests.R` — 18 tests, 0 failures;
- `Rscript operations/validate.R --mode development` — 23 checks, 0 issues;
- `Rscript operations/validate.R --mode checkpoint` — 33 checks, 0 issues;
- all 19 maintained R files, including the `renv` activation bootstrap,
  parsed successfully;
- all ten maintained YAML specifications/examples parsed, with expected
  success/failure outcomes matching exact issue-code sets;
- malformed, unsupported-version, duplicate-registration, invalid status,
  missing dependency, circular dependency, impossible temporal ordering, and
  future-information fixtures failed with structured issues;
- repository policy/scope checks found no machine path, executable sibling
  dependency, clinical Phase 2.2 schema, synthetic implementation, runtime,
  provider, persistence, product, app, deployment, or observability scaffold;
  and
- whitespace validation and `git diff --check` passed.

Validation used only temporary fixtures. The sibling repository remained
unchanged. No commit or push was performed.

#### Implications for Iteration 2.2

- The first domain set must be selected explicitly; the old seven-domain list
  and typed-zero-row convention are not defaults.
- Every actual domain owns a common-envelope identity and independent pre-1.0
  version supported explicitly by the bundle consumer.
- The initial profile must classify each selected domain as required,
  conditional, or optional and associate capabilities without conflating
  status.
- Domain contracts must declare keys, relationships, temporal roles, and
  controlled vocabularies while preserving the bundle's one as-of cutoff.
- Clinical cross-domain rules should extend the layered issue taxonomy rather
  than replace it with first-error exceptions.
- A future R/file/table realization must adapt to logical registrations and
  instance IDs; it cannot make its container mechanics public meaning.
- Derived state and estimates remain outputs, not canonical input domains.

#### Recommended next task

Begin **Phase 2 / Iteration 2.2 — First readmission-specific canonical domain
contracts**. First approve the smallest clinical capability profile and root
episode identity; then author only the domains and vocabularies needed to prove
root/child keys, dual-time availability, terminal/window semantics, and
independent fixture conformance. Do not begin the synthetic producer until the
approved clinical handoff passes independently.

### Iteration 2.2 — First readmission-specific canonical domain contracts (2026-08-10)

#### Planned objective

Define the smallest clinically meaningful canonical handoff needed to represent
a discharge episode, immutable source-provided baseline risk, and longitudinal
post-discharge events through the Iteration 2.1 generic bundle interface. Prove
the public boundary independently before implementing any synthetic producer
or runtime behavior.

#### Actual implementation

- Approved `platform.readmission-initial-profile@0.1.0` with a required
  `discharge_episode` root and optional `baseline_risk` and `episode_event`
  domains, each paired with one explicit capability.
- Added independently versioned `0.1.0` specifications for all three domains.
- Added `platform.baseline-value-types@0.1.0` with probability, numeric score,
  and category representations, and `platform.episode-event-types@0.1.0` with
  six deliberately bounded longitudinal evidence values.
- Defined closed records, requiredness/nullability, primary keys, compound
  baseline identity, child-to-episode foreign keys, temporal roles, window and
  terminal rules, and capability-versus-cardinality semantics.
- Added the wholly fictional, source-independent
  `reference.readmission-initial-profile-valid@0.1.0` fixture. Its two episodes
  for one patient include one source baseline, delayed event availability, an
  episode with zero events, and a readmission terminal outcome.
- Added focused pre-runtime validation for maintained clinical specifications,
  profile registration, records, controlled values, keys, relationships,
  conditional baseline values, episode windows, terminal ordering, dual-time
  rules, as-of admission, and false capability/payload claims.
- Extended the Phase 2 suite from 18 to 38 tests with explicit multi-issue
  failures for every requested episode, baseline, event, and cross-domain case.
- Advanced development/checkpoint validation and human guidance from the
  Phase 2.1 generic milestone to the completed Phase 2 generic-plus-clinical
  boundary.
- Added the authoritative `canonical-clinical-profile.md`, updated current
  architecture and plan wording, resolved Phase 2 decisions, and recorded the
  field/rule-level reconciliation outcome.

#### Reference assets inspected

The clean field, identity, cardinality, and temporal decisions were drafted
before reading the required sibling evidence. All files were inspected
read-only; no sibling dependency or modification was introduced.

| Reference evidence | Prior classification | Actual field/rule decision |
|---|---|---|
| `contracts/schemas/discharge-episode.yml` | **Adapt** | Adapted root/lineage IDs and the five episode timestamps; rejected draft identity, permissive extras, authoritative `episode_status`, facility/service/disposition/team fields, and unenforced terminal semantics |
| `contracts/schemas/baseline-risk.yml` | **Adapt** | Adapted compound source-score identity and the three representation concepts; renamed source identity, enforced exact-one representation, constrained score time, allowed explicitly late availability, and deferred prediction/calibration/source-system fields |
| `contracts/schemas/episode-event.yml` | **Adapt** | Adapted event/episode IDs and dual event/recorded time; renamed availability, enforced the episode window, and rejected subtype/status plus unbounded numeric/text EAV values |
| `contracts/vocabularies/event-types.yml` and `statuses.yml` | **Adapt** | Adapted only six relevant evidence meanings; rejected wholesale lists, source episode status, task/intervention values, and arbitrary initial extensions |
| `tests/fixtures/canonical-bundle-fixture.R` | **Adapt** | Adapted the independent-handoff and readable-fictional-fixture principles; rejected seven mandatory members, tibble/list meaning, later runtime context, and exact values |
| `tests/platform/test-canonical-boundary.R` | **Adapt selectively** | Adapted ordering independence, relationship failure, and no-synthetic-dependency tests; rejected exact old domain membership and downstream runtime/product coupling |
| `engine/R/contract-validation.R` | **Adapt** | Adapted only multi-issue field/type/key validation concepts; copied no code, package dependency, root lookup, schema API, or helper name |

No source text, implementation code, fixture data, schema document, controlled
vocabulary, version, or package dependency was copied. The field/rule review
confirmed the existing **Adapt** classifications, so the reconciliation table
did not require reclassification; a Phase 2.2 outcome section now records the
specific decisions.

#### New material created cleanly

- `contracts/canonical/domains/discharge-episode.yml`;
- `contracts/canonical/domains/baseline-risk.yml`;
- `contracts/canonical/domains/episode-event.yml`;
- `contracts/canonical/vocabularies/baseline-value-types.yml`;
- `contracts/canonical/vocabularies/episode-event-types.yml`;
- `contracts/canonical/profiles/readmission-initial-profile.yml`;
- `contracts/canonical/examples/readmission-initial-profile-valid.yml`;
- `docs/architecture/canonical-clinical-profile.md`;
- `operations/lib/canonical-clinical-validation.R`; and
- `tests/phase2/test-canonical-clinical-profile.R`.

Existing generic contracts, validators, tests, navigation, architecture/plan
status, policies, validation operations, agent guidance, open decisions, and
the reconciliation record were extended rather than replaced.

#### Decisions

1. **First domain set:** Discharge episode, baseline risk, and episode event
   are sufficient to prove root identity, observation/terminal bounds,
   immutable baseline preservation, longitudinal evidence, dual time, and
   child foreign keys. Workflow tasks, interventions, measure membership, and
   feature values remain deferred.
2. **Root identity:** `episode_id` is the canonical episode key. `patient_id`
   and `index_encounter_id` are implementation-provided local lineage; they do
   not create Patient/Encounter domains or an enterprise identity model.
3. **Episode window:** Admission is strictly before discharge, which is
   strictly before follow-up end. Events occur from discharge through the
   inclusive window end.
4. **Terminal semantics:** Optional readmission/death timestamps must be after
   discharge and within the window. Readmission cannot follow death. No source
   `episode_status` is authoritative.
5. **Baseline representation:** Each row declares probability, numeric score,
   or category and populates exactly one matching value. Probabilities are
   bounded; no calibration, normalization, or transformation occurs.
6. **Baseline timing:** `score_time` lies within the index encounter through
   discharge. `available_at` cannot precede the score or exceed as-of. A
   late-arriving baseline can conform but could not influence an earlier run.
7. **Baseline source identity:** `source_model_id` and
   `source_model_version` identify input meaning and are deliberately distinct
   from future platform provider identity.
8. **Event temporal semantics:** `event_time` is occurrence and `available_at`
   is platform availability. Availability cannot precede occurrence or exceed
   as-of; the window rule consequently excludes future candidate events.
9. **Event vocabulary:** Six portable evidence types are enough for the first
   fixture. New platform values require a new minor line plus mapping and
   conformance evidence.
10. **Requirement and capability:** The discharge root is required; baseline
    and events are optional. All three remain explicitly declared so
    unavailable and unsupported states are visible.
11. **Capability versus cardinality:** Available optional instances may have
    zero records. Unavailable or unsupported domains have neither instance nor
    payload. No empty instance fabricates unsupported behavior.
12. **Cardinality and keys:** One episode has zero or more baseline records,
    unique by episode/source/version/score-time, and zero or more events,
    unique by event ID. Both child episode IDs must resolve.
13. **Additional fields:** Initial records fail closed on unknown fields.
    Source columns stay below the boundary; no speculative extension container
    is introduced.
14. **Compatibility:** Profile, domain, and vocabulary versions are
    independent. Their semantic/key/requiredness/time/vocabulary/failure
    changes move to a new pre-1.0 minor line and fail closed until supported.
15. **Transitional implementation:** Clinical conformance remains under
    `operations/lib/`; no Phase 4 runtime package was created.

#### Surprises and deviations

The sibling baseline rule documented “at least one” representation but its
validator did not execute record rules. The clean boundary therefore made the
discriminator and exact-one population rule executable rather than preserving
advisory text.

The old event vocabulary mixed evidence with task and intervention concepts.
Keeping the first event vocabulary small made the existing architectural
separation enforceable without creating those deferred domains.

No scope or sequence deviation occurred. The architecture and implementation
plan needed only current-state updates: the formerly deferred domain selection
is now recorded, and Phase 2 is marked complete. No new Iteration 2.3 is
justified.

#### Validation evidence

The completed validation matrix passed:

- `Rscript operations/validate-documentation.R` — 4 checks, 0 issues;
- `Rscript tests/run-phase0-tests.R` — 10 tests, 0 failures;
- `Rscript tests/run-phase1-tests.R` — 14 tests, 0 failures;
- `Rscript tests/run-phase2-tests.R` — 38 tests, 0 failures;
- `Rscript operations/validate.R --mode development` — 30 checks, 0 issues;
- `Rscript operations/validate.R --mode checkpoint` — 40 checks, 0 issues;
- all 21 maintained R files and all 17 maintained YAML files parsed;
- maintained clinical specification drift and every intended invalid
  structural/relationship/vocabulary/temporal/capability mutation failed with
  structured issue codes;
- repository checks found no machine-specific path, executable sibling
  dependency, secret pattern, unlabelled patient-like fixture, synthetic
  implementation, runtime/provider, persistence, product, application,
  deployment, configuration, or observability scaffold; and
- untracked-file-aware trailing-whitespace search and `git diff --check`
  passed.

Validation uses only repository-owned assets and temporary mutations. The
sibling repository remained read-only. No commit or push was performed.

#### Implications for Phase 3

- The synthetic implementation must generate recognizable fictional source
  domains and map them into exactly these profile IDs and supported versions.
- It must declare root, baseline, and event status independently of row count;
  optional supported event/baseline instances may validly be empty.
- Mapping owns local patient/encounter identifiers, source-model identity,
  controlled event translation, score availability, event availability, and
  discarded source columns.
- Source-local failures remain distinct from domain/cross-domain/platform
  conformance; the producer returns both candidate bundle and structured local
  result.
- Generic validation may not branch on the synthetic implementation ID or
  depend on its paths, tables, generator configuration, or source names.

#### Phase 2 status

**Complete.** Iteration 2.1 supplied the generic bundle, capability, identity,
dependency, compatibility, temporal, and conformance foundation. Iteration 2.2
supplies the selected schemas/vocabularies, profile, independent fixture,
structural/relationship/vocabulary/temporal failure proof, and the minimal R
realization needed to exercise the representation-neutral boundary. Every
Phase 2 exit criterion is evidenced; another Phase 2 iteration would add scope
without a demonstrated gap.

#### Recommended next task

Begin **Phase 3 — Synthetic reference implementation** with a bounded first
iteration that defines deterministic fictional source/run identity and a
producer result, then maps only the approved three-domain profile. Re-read the
sibling generator, mappings, simulation configuration, and synthetic tests
just in time after designing the clean producer interface. Do not begin
runtime/provider work until the synthetic implementation passes the same
independent canonical handoff.

## Phase 3 — Synthetic reference implementation

### Iteration 3.1 — Synthetic reference source and canonical producer (2026-08-10)

#### Planned objective

Build the first complete source implementation beneath the approved canonical
boundary. Exercise source generation, source-local conformance, mapping, and
the existing canonical admission as distinct stages without beginning runtime,
provider, persistence, product, application, deployment, or observability work.

#### Actual implementation

- Added `implementations/synthetic-reference/` as the explicit local-source
  ownership boundary, with independent implementation, mapping, generator, and
  source-schema identities.
- Added six recognizable source feeds: patient registry, encounters,
  discharges, risk scores, activity events, and terminal outcomes. They are
  relational source records, not canonical tables with new names.
- Added deterministic base-R generation driven by a versioned configuration,
  seed, simulation reference time, canonical as-of time, and declared scale.
  The generator restores the caller's random-number state and uses no wall
  clock or external input.
- Added implementation-local schema validation that collects structural,
  field/type/nullability, key, relationship, controlled-code, temporal,
  probability, terminal-outcome, readmission-integrity, and fictional-ID
  issues. Structural defects remain reportable without crashing deeper checks.
- Added an owned mapper for exactly the approved discharge-episode,
  baseline-risk, and episode-event profile. It translates local codes and IDs,
  discards source-only fields, preserves occurrence and availability, and
  excludes later-received facts at the declared cutoff.
- Added a staged producer result with separate configuration, generation,
  source-local, mapping, and canonical status. Later stages do not run after an
  earlier failure; generic Phase 2 conformance remains the only canonical
  admission authority.
- Added test and reference configurations, the human
  `operations/generate-reference.R` operation, focused Phase 3 tests, platform
  validation composition, checkpoint rules, architecture/onboarding material,
  and an operation guide.
- Kept generated source and canonical objects in memory. No generated dataset,
  product, manifest, or log is committed or written by the operation.

#### Reference assets inspected

The clean producer interface and source set were fixed before line-reviewing
the sibling repository. The sibling remained read-only.

| Evidence | Previous classification | Actual final classification and use |
|---|---|---|
| `implementations/synthetic-demo/R/generate-source-data.R` | Adapt | **Adapt — concepts only.** Retained deterministic staged generation, relational records, repeat episodes, delayed receipts, and outcome relationships. Rejected its broad facilities/staff/task/intervention/measure/product ecosystem, downstream coupling, dependencies, exact IDs, values, and code. |
| `implementations/synthetic-demo/R/map-to-canonical.R` | Adapt | **Adapt — concepts only.** Retained explicit joins, derived identifiers, code translation, dual-time fields, and implementation-owned mapping provenance. Rejected seven-domain/draft shapes, leaked source fields, provider/product data, first-error validation, and all code. |
| `implementations/synthetic-demo/config/simulation.yml` | Adapt with review | **Reference only.** It confirmed the usefulness of declared seed and reference time. The clean implementation rejected its large mixed platform configuration, unrelated controls, placeholder identities, and scale. |
| `implementations/synthetic-demo/mappings/source-to-canonical.yml` and mapping README | Adapt | **Reference only.** They confirmed that translation ownership should be visible; no old field map, vocabulary, or text was retained. |
| `tests/platform/test-synthetic-ecosystem.R`, canonical-boundary tests, and validation-mode tests | Adapt selectively | **Adapt — test principles only.** Retained determinism, relationship failure, future-information exclusion, boundary independence, and staged-failure intent. Rejected runtime/product coupling, fixed old paths/domains/counts, and source text. |

No source code, prose, YAML structure, fixture row, identifier, or dependency
was copied. The implementation was written cleanly against the accepted Phase
2 contracts. The reconciliation document now records this outcome.

#### New material created cleanly

- `implementations/synthetic-reference/implementation.yml` and
  `source-schema.yml`;
- test/reference run configurations and five focused R implementation files;
- implementation README plus architecture and human-operation guides;
- `operations/generate-reference.R` and Phase 3 validation composition;
- `tests/run-phase3-tests.R` and the source-to-canonical test suite; and
- Phase 3 navigation, checkpoint, plan, decision, reconciliation, and working
  agreement updates.

#### Decisions

1. **Source domains:** six source-owned feeds are enough to demonstrate local
   relationships, repeat episodes, delayed feeds, and terminal facts without
   pretending to model an entire health system.
2. **Implementation identity:** `reference.synthetic-health-system@0.1.0`.
3. **Mapping identity:** `reference.synthetic-to-readmission-canonical@0.1.0`.
4. **Generator identity:**
   `reference.synthetic-health-system-generator@0.1.0`.
5. **Source schema:**
   `reference.synthetic-health-system-source-schema@0.1.0`, visibly
   `fictional_nonclinical`, with unknown tables/fields rejected.
6. **Run inputs:** generator version plus complete configuration, declared
   seed, scale, and as-of values determine the result. Wall-clock time does
   not. The simulation and canonical cutoffs are explicit and currently must
   match so the reference snapshot has one reviewable boundary.
7. **Validation ownership:** source conformance is local and multi-issue;
   mapping conformance owns translation completeness; canonical conformance is
   generic and authoritative. Their issue results are not collapsed.
8. **Capabilities:** discharge episode, baseline risk, and episode event are
   all `available`. Availability means supported and supplied as a domain
   instance, not that every episode has a baseline or event row.
9. **Retention:** do not ship prebuilt generated inputs or bundles in Phase 3.
   Code/configuration reproduce both scales; the small independent Phase 2
   fixture remains the source-independent teaching asset.
10. **Scale:** test is 4 patients/6 episodes; reference is 24 patients/36
    episodes. The latter includes repeat patients, incomplete baseline/event
    coverage, delayed and post-cutoff facts, readmission, death, and active
    episodes while remaining fast and understandable.
11. **Dependencies:** add none. Base R performs generation/mapping; the existing
    locked `yaml` dependency reads maintained specifications/configuration, so
    `renv.lock` is unchanged.
12. **Composition:** the reference is a complete implementation. Silent mixing
    of synthetic and hospital source domains remains unsupported.

#### Surprises and deviations

- A six-feed source was sufficient; the old broad operational ecosystem was
  not needed to prove the approved clinical handoff.
- Valid source history must include facts received after canonical `as_of_time`
  to prove that mapping—not generation—owns availability filtering.
- The small scale happened to contain no admitted terminal outcome at its
  cutoff, so terminal/active coverage is asserted at reference scale rather
  than forcing every semantic into every fixture.
- Source-controlled `other_observed` is intentionally valid locally but lacks
  a canonical translation. It provides a real mapping-failure scenario without
  corrupting source conformance.
- No plan or architecture dependency direction changed. The planned
  `implementations/` boundary is now realized and Phase 3 can close in one
  iteration.

#### Validation evidence

The completed validation matrix passed using repository-owned assets only:

- `Rscript operations/validate-documentation.R` — 4 checks, 0 issues;
- `Rscript tests/run-phase0-tests.R` — 10 cases, 0 failures;
- `Rscript tests/run-phase1-tests.R` — 14 cases, 0 failures;
- `Rscript tests/run-phase2-tests.R` — 38 cases, 0 failures;
- `Rscript tests/run-phase3-tests.R` — 24 focused cases, 0 failures;
- `Rscript operations/generate-reference.R --scale test` — every stage
  succeeded for 4 patients and 6 episodes;
- `Rscript operations/generate-reference.R` — every stage succeeded for 24
  patients and 36 episodes;
- `Rscript operations/validate.R --mode development` — 35 checks, 0 issues;
- `Rscript operations/validate.R --mode checkpoint` — 50 checks, 0 issues;
- all 30 maintained R and 21 maintained YAML files parsed; and
- untracked-file-aware whitespace review plus `git diff --check` passed.

Deterministic repeat runs serialized identically. A changed seed changed source
values while remaining conforming. Reference-scale stable counts were 24
patients, 42 encounters, 36 discharge episodes, 27 admitted baseline records,
38 admitted event records, 6 readmissions, 4 deaths, 11 active episodes, and 9
post-cutoff source facts excluded. Source mutation tests covered missing fields,
duplicate keys, foreign keys, codes, time order, mapping-only failure, staged
stop behavior, and distinct canonical failure.

Repository checks found no machine-specific path, executable sibling
dependency, secret pattern, unlabelled patient-like fixture, committed generated
dataset, or runtime/provider/persistence/product/application/deployment/
observability scaffold. The sibling repository was not modified. No commit or
push was performed.

#### Implications for Phase 4

- Runtime may assume only a bundle admitted through the generic canonical
  profile with explicit identity, capabilities, dependencies, as-of context,
  records, and provenance references.
- Runtime must not know the reference implementation ID, configuration scale,
  generator, mapping, six source table names, local codes, source-only fields,
  or generation procedure.
- Provider and estimand design must begin from the canonical profile and
  availability semantics. It may not reach behind the handoff or treat source
  baseline risk as a default provider output.
- Phase 4 can use this producer and the independent Phase 2 fixture as two
  boundary inputs, but neither justifies persistence, historical, or product
  assumptions.

#### Phase 3 status

**Complete.** Iteration 3.1 supplies every Phase 3 deliverable and exit item:
deterministic relational fictional generation, identities, local validation,
mapping/provenance, staged producer reporting, two scales, canonical admission,
human operation, focused tests, onboarding documentation, generated-data
policy, and generic independence. No Iteration 3.2 gap is evidenced.

#### Recommended next task

Begin **Phase 4 — Minimal governed runtime and provider** by defining one
versioned estimand and the smallest source-independent state/eligibility
contract before selecting or adapting provider code. Use only admitted
canonical bundles as input, preserve dual-time filtering, and keep estimates
separate from priority decisions. Do not introduce persistence or products
until the runtime/provider contract and conformance scenarios are accepted.

## Phase 4 — Minimal governed runtime and provider

### Iteration 4.1 — Runtime foundation, episode state, eligibility, and first estimand (2026-08-10)

#### Planned objective

Build the smallest implementation-neutral path from an admitted canonical
bundle through explicit eligibility and reproducible as-of state to a versioned
estimand request. Establish the focused internal R package, but do not create a
provider, estimate, persistence, product, application, deployment, or
observability implementation.

#### Actual implementation

- Created the valid internal `rrpruntime` R package with seven focused exports:
  admitted-input construction/validation, injected-contract validation,
  eligibility evaluation, state construction, request construction, and a
  conformance predicate.
- Added language-neutral `0.1.0` contracts for eligibility results, minimal
  episode state, the first next-day conditional readmission-hazard estimand,
  and provider-neutral estimand requests.
- Kept canonical admission, current representation resolution, repository YAML
  loading, package installation, checkpoint scanning, and CLI presentation in
  `operations/`. A generic adapter turns an admitted bundle into a normalized
  package input; the package never discovers repository paths or reads YAML.
- Implemented start-inclusive/end-exclusive follow-up eligibility, terminal
  rules at the interval start, explicit ineligibility reasons, defensive
  baseline/event availability filtering, deterministic state/request identity,
  all-baseline retention, and deterministically ordered event history.
- Added a temporary-library human operation that works with both the
  source-independent Phase 2 fixture and Phase 3 synthetic-produced bundle.
- Added focused package/cross-component tests and composed Iteration 4.1
  development/checkpoint validation.

#### Reference assets inspected

The package API, state fields, eligibility interval, as-of rule, estimand
quantity, and request boundary were designed before the required read-only
sibling inspection.

| Evidence | Prior classification | Actual final classification and use |
|---|---|---|
| `engine/R/risk-provider.R` | Adapt | **Adapt — concepts only.** Retained timestamp-based eligibility, terminal timestamps instead of mutable status, and strict availability filtering. Rejected the provider wrapper, constant provider, latest-baseline shortcut, tibble dependency, old field names, estimate output, and all code. |
| `engine/tests/testthat/test-temporal-validity.R` and `test-risk-provider-interface.R` | Adapt selectively | **Adapt — test principles only.** Retained exact terminal/window boundary, future-information, determinism, and cardinality scenarios. Rejected provider output assumptions, old fixtures, latest-baseline behavior, and testthat dependency. |
| `pipelines/functions/canonical-pipeline.R` | Do not reuse as a unit | **Do not reuse as a unit; reference only for state questions.** Elapsed follow-up and deterministic state identity were useful evidence. Wide operational/provider features, model, priority, products, measure logic, project-root loading, and reconstructed trajectories were rejected. |
| `contracts/schemas/episode-state-snapshot.yml` | Not separately final | **Reference only.** Confirmed episode/as-of/version identity; permissive draft and provider/product features were rejected. |
| `contracts/schemas/risk-estimate.yml` | Adapt later | **Deferred/reference only.** Iteration 4.1 creates no estimate, and the old output cannot define an estimand request. |
| `config/estimands.yml` | Reference only | **Do not reuse.** The remaining-window and seven-day rows lacked versioned population, event, terminal, competing-event, capability, interval, and coherence meaning. |

No reference code, specification text, fixture row, configuration, dependency,
or package structure was copied. The reconciliation document records the final
classifications.

#### New material created cleanly

- four specifications under `contracts/runtime/`;
- package metadata, README, seven R source files, and one base-R package test
  under `runtime/`;
- generic runtime loading/adaptation and validation helpers under
  `operations/lib/`;
- `operations/run-reference-runtime.R` and its complete human guide;
- 24 focused Phase 4 tests and runner; and
- runtime architecture, navigation, plan, decision, policy, validation,
  reconciliation, and agent-guidance updates.

#### Decisions

1. **Package:** `rrpruntime@0.1.0` owns only implementation-neutral admitted
   input, contract support, eligibility, state, and estimand requests.
2. **Contract loading:** language-neutral YAML is explicitly loaded by
   operations and injected. The package has no YAML dependency, project-root
   discovery, working-directory assumption, or repository file lookup.
3. **Canonical ownership:** full canonical admission and the current embedded
   realization adapter remain transitional under `operations/lib/`; repository
   scanners/checkpoints and CLI output do not belong in the package.
4. **State:** `platform.readmission-episode-state@0.1.0`; transparent IDs are
   deterministic from runtime run, episode, as-of, and specification version.
   State is built only for eligible episodes.
5. **Eligibility:** explicit `eligible`/`ineligible` status with reasons
   `eligible`, `before_discharge`, `followup_complete`, `already_readmitted`,
   `died`, and reserved required-input/capability failures. Discharge is
   inclusive; effective follow-up end is exclusive. Terminal occurrence at or
   before interval start excludes the episode, with readmission winning a tie.
6. **As-of:** Iteration 4.1 requires runtime as-of equal to admitted bundle
   as-of. Earlier replay is unsafe while root terminal facts lack their own
   availability timestamps. Baseline/event rows are still defensively filtered.
7. **Baseline:** preserve all available canonical rows, ordered by their full
   source identity. Never select latest implicitly or turn a source score into
   the platform estimand.
8. **Events:** preserve available records ordered by occurrence, availability,
   and ID; do not build provider-specific features.
9. **Estimand:**
   `platform.readmission-next-day-conditional-hazard@0.1.0` uses discharge as
   origin, a 30-day maximum effective follow-up, and target interval
   `(t, min(t + 1 day, W)]`.
10. **Quantity/terminal/coherence:** first canonical readmission is the event;
    eligibility conditions alive/readmission-free status at `t`; death during
    the interval competes. Output is one probability in `[0,1]`. Conditional
    daily hazards need not be monotone across time.
11. **Requirements:** only `platform.discharge-episode` is required for the
    estimand. Baseline risk and episode events remain optional inputs; future
    provider requirements are method-owned.
12. **Request:** `platform.readmission-estimand-request@0.1.0`; exactly one per
    eligible state, with no provider/model/estimate identity or value.
13. **Dependencies:** runtime uses base R only. Existing repository `yaml`
    remains operation-owned; no `renv.lock` dependency change is required.
    `rrpruntime` is recorded in `renv` settings as ignored repository-owned
    source because operations install it into a temporary library rather than
    restore it as an external package.

#### Surprises and deviations

- The initial canonical profile records `readmission_time` but no
  planned/unplanned classification. The estimand therefore names first
  canonical readmission explicitly and records plannedness as unresolved;
  claiming an unplanned event would exceed the admitted input's meaning.
- Strict RFC 3339 tests exposed that a permissive base-R conversion could drop
  the time-of-day component for explicit-offset values. The package now
  normalizes offsets and parses with an explicit format before every temporal
  comparison.
- Earlier runtime evaluation from a later admitted bundle was rejected for
  this line: baseline/events carry availability, but root terminal timestamps
  do not. Equality avoids a false replay guarantee while keeping the API small.
- The independent fixture contains two episodes but only one eligible state at
  its cutoff; the earlier episode is already readmitted. The synthetic test
  scale supplies six eligible states/requests.
- The architecture and phase sequence did not change. The plan needed only an
  in-progress status showing that provider execution remains Iteration 4.2.

#### Validation evidence

The final validation matrix passed using repository-owned assets and temporary
package libraries:

- documentation, Phase 0–3 regression suites, and both Phase 3 operations;
- `Rscript tests/run-phase4-tests.R` — 24 tests, 0 failures;
- `Rscript operations/run-reference-runtime.R --input independent` — 2
  eligibility results, 1 state, 1 request;
- `Rscript operations/run-reference-runtime.R --input synthetic --scale test`
  — 6 eligibility results, 6 states, 6 requests;
- development and strict Iteration 4.1 checkpoint validation;
- clean temporary package installation/loading and base-R package tests;
- built-package `R CMD check --no-manual --no-vignettes` — status OK;
- all maintained R/YAML parsing, dependency review, whitespace review, and
  `git diff --check`.

Development validation passed 44 checks with 0 issues. Strict Iteration 4.1
checkpoint validation passed 63 checks with 0 issues. No generated
state/request data were written. The sibling repository remained read-only,
and no commit or push was performed.

#### Implications for Iteration 4.2

- Provider architecture may assume one validated request references one
  eligible, versioned state and one exact estimand interval.
- A provider may declare stronger baseline/event/state requirements, but may
  not redefine estimand eligibility, interval, terminal, or probability
  semantics.
- Execution and selection wrappers own provider identity/trust; the request
  remains provider-neutral.
- Estimate records must reference request, state, estimand, provider, run, and
  interval and must enforce exactly one bounded probability per successful
  request. Failure/unsupported results remain distinct from estimates.
- Provider code must not revisit source mapping, mutate state, add priority
  policy, persist records, or build products.

#### Phase 4 status

**In progress.** Iteration 4.1 completes the runtime/state/eligibility/estimand
request foundation, but Phase 4 exit evidence requires provider specification,
controlled registration/selection, provider execution, standardized estimate
records, and provider conformance. No provider placeholder was added early.

#### Recommended next task

Implement **Iteration 4.2 — Provider contract, controlled registry, transparent
reference provider, and estimate record**. Start from the accepted request and
estimand; define provider trust/selection and failure taxonomy before adding a
deterministic visibly nonclinical provider. Prove a second tiny provider can
register without runtime edits, and keep estimates separate from priority,
persistence, and products.

### Iteration 4.2 — Provider contract, registry, reference provider, and estimate records (2026-08-11)

#### Planned objective

Complete Phase 4 from the accepted provider-neutral request: define a
language-neutral provider declaration and adapter boundary, controlled trust
and exact selection, compatibility and failure semantics, one deterministic
transparent nonclinical provider, and one standardized accepted estimate. Do
not add persistence, correction/idempotency policy, decisions, rankings,
products, application code, deployment, observability, configuration
frameworks, or CI/CD.

The declaration, registry boundary, compatibility dimensions, outcome
taxonomy, estimate identity, model-identity rule, and reference formula were
designed before inspecting the sibling implementation.

#### Actual implementation

- Advanced the focused package to `rrpruntime@0.2.0` without adding an external
  package dependency.
- Added four common-envelope provider/estimate contracts plus the concrete
  `reference.transparent-readmission-hazard@0.1.0` declaration.
- Implemented declaration conformance, exact version-range comparison, a
  process-local in-memory registry, duplicate rejection, exact ID/version
  resolution, compatibility evaluation, isolated adapter invocation,
  platform-owned output validation, structured execution outcomes,
  deterministic estimate construction, and estimate-record validation.
- Kept YAML/path loading and the explicit pairing of a declaration with its
  trusted callable in the operations layer. The package never discovers the
  repository, and ordinary data configuration cannot introduce executable
  paths or code.
- Implemented the fixed transparent reference method and an operation that
  runs either admitted input through runtime, provider, execution result, and
  estimate in a temporary package library.
- Added 31 provider/estimate tests to the 24 Iteration 4.1 tests, including a
  second constant provider defined only in the test suite.
- Extended development and checkpoint validation to the provider documents,
  package surface, both admitted-input estimation flows, exact completed-Phase
  4 file scope, and the absence of later-phase implementation.

#### Reference assets inspected

The sibling repository remained read-only and development-time only.

| Evidence | Prior classification | Actual final classification and use |
|---|---|---|
| `engine/R/risk-provider.R` | Adapt | **Adapt — concepts only.** Retained an explicit wrapper boundary, as-of isolation, and identifier/cardinality/probability checks. Rejected arbitrary function injection as public trust, latest-baseline selection, direct source/canonical inputs, tibble output, mixed eligibility/provider behavior, old output fields, and all code. |
| `engine/tests/testthat/test-risk-provider-interface.R` and `test-temporal-validity.R` | Adapt selectively | **Adapt — test principles only.** Retained determinism, bounds/cardinality failures, future-information exclusion, and terminal boundaries. Rejected old fixtures, estimands, providers, output assumptions, and testthat dependency. |
| `contracts/schemas/risk-estimate.yml` | Adapt later | **Adapt — concepts only.** Retained distinct estimate/provider/model/version/interval identity and bounded probability. Rejected permissive draft fields, baseline comparison, generation timestamp as identity, and missing request/state/run/execution provenance and failure separation. |
| `config/models.yml` | Reference only | **Reference only.** It exposed selection and identity governance gaps. String-to-function naming, an `active` trust flag, placeholder identities, and method assumptions were rejected. |
| `config/estimands.yml` | Reference only | **Do not reuse.** Its unversioned quantities do not match the accepted estimand and add no reusable provider semantics. |
| `docs/architecture/pluggable-model-assessment.md` | Reference only | **Reference only.** Controlled allowlisting/registry direction and the future non-R adapter concern were useful. The old seam, output/product coupling, and incomplete provenance assumptions were rejected. |

No reference code, specification text or structure, fixture, identifier,
configuration, data, dependency, or package layout was copied. The
reconciliation document records the same final classifications.

#### New material created cleanly

- `contracts/runtime/provider-specification.yml`;
- `contracts/runtime/provider-execution-adapter.yml`;
- `contracts/runtime/provider-execution-result.yml`;
- `contracts/runtime/readmission-risk-estimate.yml`;
- `contracts/runtime/providers/transparent-reference-provider.yml`;
- six focused provider/estimate implementation files and provider API
  documentation under `runtime/`;
- `operations/lib/provider-operation.R` and
  `operations/run-reference-estimation.R`;
- 31 focused provider/estimate tests under `tests/phase4/`;
- provider architecture and human operation guides; and
- coordinated navigation, plan, open-decision, validation, reconciliation,
  package, contract, and agent-guidance updates.

#### Decisions

1. **Ownership:** the estimand defines the quantity, a provider declares how it
   can produce that quantity, an execution result records whether one attempt
   conformed, and an estimate records only an accepted methodological result.
2. **Contracts:** `platform.provider-specification@0.1.0`,
   `platform.provider-execution-adapter@0.1.0`,
   `platform.provider-execution-result@0.1.0`, and
   `platform.readmission-risk-estimate@0.1.0` form the language-neutral suite.
3. **Trust:** executable registration requires trusted platform code to pair a
   conforming declaration with an approved callable. YAML never contains or
   locates executable code.
4. **Registry:** registration is process-local and in memory. Duplicate exact
   identities fail; selection always supplies exact provider ID and version.
   There is no implicit default or latest provider.
5. **Future adapters:** the callable R adapter realizes language-neutral
   semantics. A service or non-R adapter may later realize the same boundary,
   but this iteration does not claim external execution or define transport.
6. **Compatibility:** lifecycle, estimand ID/version range, state ID/version and
   required fields, capability status, provider-specific inputs, follow-up and
   interval limits, and one bounded probability are checked before invocation.
7. **Isolation:** the adapter receives serialized copies of only the matching
   accepted request, immutable episode state, and registered declaration. It
   cannot revisit source/canonical input, repeat eligibility, or mutate caller
   state.
8. **Outcome taxonomy:** `successful_estimate`, `unsupported`,
   `missing_required_input`, `execution_failure`, and `invalid_output` cover
   compatibility through conformance. Every failure carries a code/message and
   no estimate; `NA` never represents failure.
9. **Conformance ownership:** the platform validates identity, interval,
   cardinality, finite numeric bounds, and provenance before constructing the
   standardized estimate. Providers do not construct platform estimate IDs.
10. **Estimate identity:** deterministic comparison identity includes runtime
    run, provider execution run, request, state, estimand, provider/model,
    and interval. Durable retry/idempotency/correction semantics remain Phase 5.
11. **Model identity:** provider identity is distinct from a fitted
    model/artifact and canonical `source_model_id`. The fixed reference formula
    explicitly has no separate model artifact.
12. **Reference method:** the linear predictor is `qlogis(0.04)` plus `0.75`
    times the mean of available probability-typed baselines, `0.12` times the
    available event count capped at five, and `0.10` when any available event
    occurred in the previous seven days; absent optional inputs contribute
    zero and `plogis` returns the probability.
13. **Clinical maturity:** the reference provider is deterministic,
    inspectable conformance software only. It is not fitted, calibrated,
    clinically validated, causal, production-ready, or approved for care.
14. **Extensibility proof:** a constant provider exists only in tests and
    registers/runs through the public interfaces without editing generic
    runtime code. It is not a shipped default or general estimand claim.
15. **Later boundaries:** estimate generation remains separate from priority,
    decision, intervention, persistence, products, and application behavior.

#### Surprises and deviations

- The earlier risk-provider wrapper combined useful validation ideas with an
  unsafe public trust assumption: accepting a function directly is not enough
  to explain who approved it. The clean design therefore separates
  language-neutral declaration from trusted code registration.
- The old estimate schema had useful identity hints but treated failure and
  output too permissively. A separate execution-result record was needed so a
  failed invocation could never look like a risk row with a missing value.
- No fitted artifact exists for a fixed transparent formula. Requiring a fake
  model identity would weaken rather than strengthen provenance, so the model
  reference is explicitly optional and null here.
- The independent admitted fixture produces one request/estimate while the
  synthetic test scale produces six. This preserved the two-input evidence
  without introducing a synthetic runtime mode.
- The architecture and phase ordering did not change. Existing target
  boundaries already anticipated estimand/provider separation; the plan needed
  only its Phase 4 completion status.

#### Validation evidence

Focused evidence passed before the final repository checkpoint:

- `Rscript tests/run-phase4-tests.R` — 55 tests, 0 failures;
- `Rscript operations/run-reference-estimation.R --input independent` — 1
  eligible episode, 1 request, 1 successful estimate;
- `Rscript operations/run-reference-estimation.R --input synthetic --scale test`
  — 6 eligible episodes, 6 requests, 6 successful estimates; and
- the reference provider reports only `successful_estimate` for both supported
  flows and writes no estimates or products.

The final repository-owned validation matrix passed:

- `Rscript operations/validate-documentation.R` — 4 checks, 0 issues;
- focused Phase 0–4 suites — respectively 10, 14, 38, 24, and 55 tests,
  all passing;
- `Rscript operations/generate-reference.R` — reference-scale producer
  succeeded with 24 patients, 36 episodes, and 38 admitted event records and
  wrote no generated data;
- `Rscript operations/run-reference-runtime.R --input synthetic --scale test`
  — 6 states and 6 requests using `rrpruntime@0.2.0`;
- both reference-estimation commands — independent 1/1 and synthetic test
  6/6 successful estimates, with no persistence, ranking, or products;
- `Rscript operations/validate.R --mode development` — 53 checks, 0 issues;
- `Rscript operations/validate.R --mode checkpoint` — 72 checks, 0 issues;
- clean source-package build and
  `R CMD check --no-manual --no-vignettes` — status OK;
- all 51 maintained R files and 30 maintained YAML files parsed;
- `renv::status()` reported the restored lockfile state synchronized; and
- dependency, later-scope, sibling-independence, whitespace, and
  `git diff --check` reviews passed.

No generated runtime/provider/estimate data were written. Restoring the
already locked `yaml@2.3.10` package linked it from the local cache and changed
no dependency declaration or lockfile. The sibling repository remained
read-only, and no commit or push was performed.

#### Implications for Phase 5

- Persistence consumes the standardized state, request, execution-result, and
  estimate identities; it does not invoke a provider or reinterpret an
  estimand.
- Phase 5 must define logical append/read ports plus retry, idempotency,
  invalidation, correction, and restatement behavior before an estimate ID is
  treated as an operational storage key.
- Unsupported and failed executions may need durable operational history, but
  remain distinct from accepted estimates.
- Historical estimates must preserve their provider and optional model
  identity across later provider transitions; current code must not reconstruct
  old trajectories.
- Storage adapters, products, and the application must not become new provider
  selection paths.

#### Phase 4 status

**Complete.** Iterations 4.1 and 4.2 satisfy the minimal governed runtime and
provider exit evidence. No persistence or later-phase implementation was
introduced.

#### Recommended next task

Begin **Phase 5 — First persistent vertical slice** with logical append/read
ports and explicit operational-history semantics for runs, state, provider
execution results, and accepted estimates. Choose the smallest local reference
adapter only after idempotency, retry, correction, invalidation, and
restatement rules are explicit. Keep products and the application downstream
of those ports.
