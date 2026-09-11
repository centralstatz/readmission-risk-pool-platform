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

## Phase 5 — First persistent working vertical slice

### Iteration 5.1 — Operational history semantics and persistence ports

#### Planned objective

Define operational truth and backend-independent append/read interfaces before
selecting a storage technology. The iteration was to stop at accepted runtime
records → history semantics → logical ports, retain the completed Phase 4
boundaries, and leave a concrete reference adapter, products, application,
deployment, replay, decision policy, and observability to their authorized
later work.

#### Actual implementation

- Added `platform.operational-run-status@0.1.0` with immutable `started`,
  `completed`, `completed_with_failures`, and `failed` lifecycle facts,
  predecessor links, exact terminal summaries, and immutable run context.
- Selected operational run statuses, full episode-state snapshots,
  provider-neutral estimand requests, every provider execution result, and
  accepted estimates as the persisted terminal-batch families.
- Deliberately deferred full canonical-bundle persistence while preserving
  bundle, canonical run, implementation, mapping, input, and provenance
  references in the records that were actually used.
- Added `platform.history-invalidation@0.1.0` as an append-only overlay with
  explicit run/state/request/execution/estimate cascade semantics. Raw records
  remain retained; valid views apply invalidation closure.
- Added `platform.persistence-adapter@0.1.0` with seven logical methods and six
  required capabilities. It contains no table, file, connection, query,
  transaction-product, or vendor assumption.
- Advanced the internal package to `rrpruntime@0.3.0`. It constructs and
  validates run/invalidation records, validates atomic completed-run batches
  and adapter declarations, creates a validated port, and delegates governed
  append and read calls.
- Advanced `platform.provider-execution-result` from `0.1.0` to `0.2.0` because
  retained attempts require `runtime_run_id`, `attempt_number`, and
  `retry_of_execution_result_id`. Existing calls remain source-compatible via
  attempt-1 defaults.
- Added a test-only in-memory adapter outside the package. It proves the
  semantics without creating a durable or supported storage implementation.
- Added a focused Phase 5 runner and repository/checkpoint validation. The
  completed Phase 4 checkpoint now verifies that its owned prerequisite files
  remain; the Iteration 5.1 checkpoint owns the expanded exact history scope.

#### Old assets used or adapted

The clean design was fixed before sibling inspection. The subsequent read-only
review covered `scripts/lib/product-provenance.R`, `app/data/PRODUCT_MANIFEST.yml`,
`docs/operations/provenance-lifecycle.md`, the state/estimate/trajectory parts
of `pipelines/functions/canonical-pipeline.R`, `app/data/`, and relevant
provenance/trajectory tests.

Only principles were adapted: stable identities, coherent-set validation,
explicit input attribution, and optional count/hash tamper evidence. The old
Git A/B/C lifecycle, tracked CSV persistence, fixed product suite, current
commit cycles, synthetic/app paths, and trajectories rebuilt by running
current code over historical cutoffs were rejected as operational-history
foundations. No old code, schema text, configuration, data, identity, or
dependency was copied.

#### New clean work

New clean assets include:

- three contracts under `contracts/persistence/`;
- four package modules for history specification, records, cross-record
  conformance, and the persistence port;
- a package manual page and current provider/runtime documentation updates;
- a test-only in-memory adapter, seven focused conformance cases, and a Phase 5
  runner;
- repository and strict-checkpoint history validation; and
- the authoritative
  [Operational History Foundation](operational-history-foundation.md) plus
  navigation, operation, plan, decision, reconciliation, and agent guidance.

#### Decisions and rationale

1. **Operational truth:** retained evidence records what one admitted runtime
   knew, requested, attempted, accepted, and concluded; it is not source
   history, provenance alone, diagnostics, products, replay, or research data.
2. **Run lifecycle:** lifecycle is a two-record append sequence rather than a
   mutable run row. Invalidation is not a lifecycle status.
3. **State scope:** persist the complete current state contract because that is
   exactly what a provider could inspect. Do not claim it is sufficient for a
   future provider or state version.
4. **Canonical bundle:** defer full bundle persistence so the runtime port does
   not take ownership of source/handoff history. Preserve exact logical
   references to admitted inputs.
5. **Atomicity:** a started or failed status may append alone. A completed
   status and every batch member become visible all-or-none.
6. **Idempotency:** same identity and identical semantic content is a no-op.
   Semantic equality is authoritative; a digest may be adapter evidence.
7. **Conflict:** same identity with different content fails before mutation.
   Overwrite and delete are not port behavior.
8. **Retry:** later attempts explicitly reference the immediately prior attempt
   for the same request/provider. Failure remains retained; one later success
   may supply the one accepted estimate for that semantic key.
9. **Provider transition:** a new provider affects future runs only. Old
   estimates keep old provider/model identity unless separately invalidated.
10. **Correction/invalidation:** corrections append a reasoned invalidation;
    adapters resolve its dependency closure for valid reads.
11. **Restatement:** recomputation is a new deliberate run and identity with
    provenance to the invalidation and superseded run. No replay tool is
    implied.
12. **Reads:** exact, run, and episode-history reads expose raw or valid views.
    Current reads use only valid estimates from completed terminal runs,
    greatest as-of, then greatest terminal time, and fail an unresolved tie.
13. **Adapter ownership:** the package owns semantic validation; adapters own
    physical atomicity, durable conflict safety, validity resolution, and read
    ordering. No technology was chosen.

#### Surprises and deviations

- Phase 4 had intentionally left execution-result retry lineage undefined.
  Persistence made the absence material, so a real contract minor-line advance
  was safer than an unversioned optional field or a persistence-only wrapper.
- The earlier strict Phase 4 validator equated its exact package tree with all
  future repository scope. It was narrowed to its durable prerequisite claim;
  the new strict checkpoint now owns the authorized expansion.
- A cohesive terminal-run append is necessarily multi-family. It is not a
  generic `save_everything` API: its exact cross-record invariants and atomic
  visibility are the reason it exists.
- The implementation plan originally placed complete correction/transaction
  semantics in Phase 6. The plan now records their initial authoritative form
  in Iteration 5.1 and leaves migration/retention maturity to Phase 6.
- No human persistence command was added. A command backed only by an
  ephemeral test double would falsely imply durable supported behavior.

#### Validation evidence

Focused evidence completed during implementation:

- `Rscript tests/run-phase5-tests.R` — 7 tests, 0 failures, covering contract
  and adapter capabilities, coherent append/read, idempotency/conflict, retry,
  provider transition, invalidation/restatement, and incomplete runs; and
- `Rscript tests/run-phase4-tests.R` — 55 tests, with the one expected package
  version assertion updated from `0.2.0` to `0.3.0`, then fully passing.

The final command matrix, clean package build/check, parse, dependency, and
whitespace results are recorded in the final validation follow-up below.

#### Implications for Iteration 5.2

A concrete local reference adapter must implement all seven port methods and
affirm all six capabilities. Tests must prove atomic terminal visibility under
injected interruption, durable idempotency and conflict rejection across
processes, append-only invalidation closure, raw retention, provider
transitions, unambiguous cutoff reads, and safe restart/recovery. Its human
operation must document inputs, outputs, side effects, validation,
backup/recovery, and troubleshooting. The selected technology is a reference
choice, not a platform dependency.

#### Phase 5 status

**In progress.** Operational semantics and logical ports exist. No durable
adapter, product, application, deployment, replay, decision policy, or
observability implementation exists.

#### Recommended next task

Begin **Iteration 5.2** by evaluating the smallest local durable technology
against `platform.persistence-adapter@0.1.0`, then implement one repository
owned reference adapter and the first durable source-to-history run. Do not add
products or application behavior until the adapter passes restart, conflict,
atomicity, invalidation, and human recovery evidence.

#### Final validation follow-up

The complete repository-owned matrix passed after documentation and package
review:

- `Rscript operations/validate-documentation.R` — 4 checks, 0 issues;
- `Rscript tests/run-phase0-tests.R` — 10 tests, 0 failures;
- `Rscript tests/run-phase1-tests.R` — 14 tests, 0 failures;
- `Rscript tests/run-phase2-tests.R` — 38 tests, 0 failures;
- `Rscript tests/run-phase3-tests.R` — 24 tests, 0 failures;
- `Rscript tests/run-phase4-tests.R` — 55 tests, 0 failures;
- `Rscript tests/run-phase5-tests.R` — 7 tests, 0 failures;
- `Rscript operations/validate.R --mode development` — 59 checks, 0 issues;
- `Rscript operations/validate.R --mode checkpoint` — 81 checks, 0 issues;
- `Rscript operations/generate-reference.R` — reference scale succeeded with
  24 fictional patients, 36 discharge episodes, and 38 admitted event records,
  with no generated data written;
- `Rscript operations/run-reference-runtime.R --input synthetic --scale test`
  — 6 states and 6 requests using `rrpruntime@0.3.0`, with no provider,
  estimate, or persistence;
- `Rscript operations/run-reference-estimation.R --input synthetic --scale test`
  — 6 successful estimates using the exact reference provider, with no
  persistence, ranking, or products;
- clean `R CMD build` and
  `R CMD check --no-manual --no-vignettes` for `rrpruntime@0.3.0` — status OK;
- all 59 maintained R files and 36 YAML files parsed;
- `renv::status()` — no issues and no dependency or lockfile change; and
- storage/dependency, generated-history, sibling-worktree, whitespace, and
  `git diff --check` reviews passed.

The sibling repository remained read-only. No durable data, commit, push,
publication, deployment, or external mutation occurred.

### Iteration 5.2 — DuckDB reference persistence adapter and durable vertical slice

#### Planned objective

Evaluate DuckDB against the unchanged
`platform.persistence-adapter@0.1.0`, implement the smallest repository-owned
durable reference adapter only if it satisfies every port method and
capability, and prove one complete fictional synthetic source → canonical →
runtime → provider → operational-history run. The iteration was to stop before
products, decision policy, tasks, application, deployment, replay, and general
observability.

#### Adapter evaluation

DuckDB satisfies the clean target for a local reference: the R client conforms
to DBI; persistent single-file databases support explicit open/close and
read-only reopen; ACID transactions provide commit/rollback; primary keys and
parameterized lookup support identity conflict checks; and `CHECKPOINT`
supports a controlled closed-file backup procedure. Its native concurrency
model is suitable only with one controlled read-write process per database
file, while separately coordinated processes may inspect read-only. That
limitation is documented rather than generalized into the port.

Alternatives were considered at the architectural level. CSV/RDS files do not
naturally provide a multi-family atomic commit or safe concurrent/restart
identity check. SQLite could satisfy much of the port, but DuckDB was already
the explicitly evaluated reference candidate and supplies the required local
transaction/reopen behavior without changing the contract. A client-server
database would exceed this reference iteration and remains a valid substitute
adapter when multi-process writers or production operations require it.

#### Actual implementation

- Added `reference.duckdb-persistence@0.1.0` under
  `implementations/persistence/duckdb/`, with schema `0.1.0`, payload encoding
  `r-serialize-v3-hex@0.1.0`, adapter declaration, and minimal reference path
  configuration.
- Added adapter metadata plus separate physical tables for operational run
  statuses, episode states, estimand requests, provider execution results,
  estimates, and invalidations. The database deliberately excludes the full
  canonical bundle and all product/application records.
- Stored queryable identity, relationship, status, and time columns alongside
  an exact base-R serialized logical payload. This preserves nested state,
  integer/null/class semantics, and exact semantic round-trip without adding a
  document-encoding dependency.
- Implemented all seven port methods and six declared capabilities, including
  lifecycle preflight, append-only conflict checks, validity closure, raw and
  valid reads, deterministic history order, current cutoff selection, and
  unresolved-tie failure.
- Implemented one transaction for terminal status plus every state, request,
  execution, and estimate. Test-only failure injection occurs after each of
  the five write stages and is absent from supported operation calls.
- Added explicit non-destructive initialization, compatible reopen,
  incompatible metadata/schema failure, adapter-owned session close, read-only
  inspection, checkpointed no-overwrite backup, and validated backup reopen.
- Added `run-reference-history.R`, `inspect-reference-history.R`, and
  `backup-reference-history.R`, with authoritative human setup, side-effect,
  rerun, inspection, recovery, concurrency, direct-SQL, and troubleshooting
  guidance.
- Locked `DBI@1.3.0` and `duckdb@1.2.2` for adapter/operation behavior only.
  `rrpruntime@0.3.0` and all language-neutral contracts remain unchanged and
  contain no vendor, SQL, database-path, or connection dependency.

#### Decisions and rationale

1. **Reference technology:** DuckDB is the local reference realization, not a
   platform or production mandate.
2. **Adapter identity:** adapter, contract, physical schema, and payload
   encoding have separate explicit versions. Open requires exact support; no
   migration is silently attempted.
3. **Physical families:** the six logical history families remain separate
   tables so identity, run, episode, estimand, provider, attempt, status, and
   time are inspectable and indexable.
4. **Nested state:** complete logical records use base R serialization v3
   encoded as lowercase hexadecimal text. Exact round-trip outweighed storage
   size and cross-language portability for this small R reference. The encoding
   is versioned so another adapter may choose a portable representation.
5. **Semantic equality:** decoded `identical()` content is authoritative for
   idempotency/conflict. No digest algorithm enters the contract.
6. **Atomicity:** the adapter preflights every identity before writes and uses
   one transaction for the entire terminal batch. Started/failed remain
   independent immutable transactions as the contract requires.
7. **Ordering:** history presentation uses semantic time keys and stable ID
   tie-breakers. Current selection uses only as-of and terminal status time and
   fails a remaining tie rather than letting record ID choose meaning.
8. **Invalidation:** the adapter returns the port-defined closure for all five
   target families. Original rows always remain available raw.
9. **Initialization:** a missing path may be initialized; a compatible path is
   validated without change; unrelated, partial, or incompatible files fail.
   No destructive reinitialization switch exists.
10. **Connection ownership:** repository operations select paths and receive a
    port/session. The raw DBI connection remains captured inside adapter state.
11. **Concurrency:** one controlled platform writer process per database file
    is supported. Multi-process writing is not claimed; readers coordinate and
    use read-only sessions.
12. **Backup/recovery:** the helper validates, checkpoints, closes, copies to a
    new path, and validates the copy. Scheduling, retention, encryption,
    permissions, off-host copies, and recovery objectives remain operator work.
13. **Deterministic operation:** reference run IDs and semantic times are
    stable per scale, so a second identical command is a real durable
    idempotency demonstration rather than a duplicate run.
14. **Phase boundary:** Phase 5 closes when durable operational truth and its
    human operation are proven. Products/materialization and the minimal app
    begin in Phase 6, preserving their downstream relationship.

#### Old assets used or adapted

The clean adapter and schema design preceded sibling inspection. The later
read-only review covered `app/R/data-access.R`,
`scripts/lib/product-provenance.R`, `app/data/PRODUCT_MANIFEST.yml`, and
`docs/operations/provenance-lifecycle.md`.

Stable identities, explicit generation-input attribution, count/hash integrity
evidence, and validation before consumption were adapted as principles.
Git-revision A/B/C identity, current-commit ancestry, tracked CSV persistence,
fixed product/app paths, the eight-product manifest, and the old local-file/
database app switch were rejected for operational history. No sibling code,
schema text, data, configuration, identity, or dependency was copied.

#### New clean work

New repository-owned work comprises the adapter declaration/configuration,
four cohesive adapter modules, two operation-composition modules, three human
entry points, the DuckDB architecture and operations guides, eleven durable
adapter/end-to-end cases added to the seven logical-port cases, updated strict
checkpoint validation, dependency state, navigation, plan/architecture,
decision/reconciliation records, and agent guidance.

#### Surprises and deviations

- DBI parameter binding represents SQL null with typed `NA`, not R `NULL`; the
  physical invalidation replacement column converts only at the storage edge
  while the serialized logical record preserves `NULL` exactly.
- Base R serialization offered the smallest exact nested-state realization.
  Its cross-language limitation was preferable to adding JSON plus bespoke
  type/class restoration in this reference iteration.
- The implementation plan originally coupled the first persistence milestone
  to provisional products and an app. Once Iterations 5.1/5.2 supplied the
  complete durable exit evidence, keeping Phase 5 open would blur the boundary.
  The plan now assigns product/app deliverables to Phase 6 explicitly.
- Current DuckDB documentation has evolved around shutdown handling; the
  implementation uses the DBI disconnect surface compatible with the locked
  client and tests actual close/reopen behavior rather than assuming it.

#### Validation evidence

Focused implementation evidence during development:

- `Rscript tests/run-phase5-tests.R` — 18 tests, 0 failures: seven unchanged
  logical-port cases plus declaration/schema/init, exact six-family restart
  round-trip, restart idempotency/conflict, five interruption stages,
  retry/provider transition, every invalidation target, deterministic ordering
  and ambiguity, schema mismatch/backup, full end-to-end repeat, and boundary
  independence;
- `Rscript operations/run-reference-history.R --scale test --database <temp>`
  run twice — both reported the same completed run with 2 statuses and 6
  states, 6 requests, 6 executions, and 6 estimates after close/reopen;
- `Rscript operations/inspect-reference-history.R ... --view raw` — reported
  `started -> completed` and matching family counts through the port; and
- `Rscript operations/backup-reference-history.R ...` — checkpointed, copied
  without overwrite, reopened, and validated the backup.

The complete repository validation matrix and clean-worktree-sensitive review
are recorded in the final validation follow-up below.

#### Implications for Phase 6

- Product builders can now consume retained valid/current/history reads rather
  than reconstructing past estimates or querying adapter tables.
- Migration and retention policy must begin from recorded adapter/schema/
  encoding identities; Iteration 5.2 supplies no automatic migration promise.
- The initial product suite, logical product keys/freshness, materialization
  adapter, and Shiny product-access boundary remain deliberate new work.
- Production multi-writer, security, retention, and disaster-recovery needs may
  justify a substitute client-server adapter without changing runtime or
  contract semantics.
- Direct SQL remains debugging only and cannot become the product/app API.

#### Phase 5 status

**Complete.** The logical port and operational semantics, durable conforming
reference adapter, first complete source-to-history run, restart/rollback/
invalidation evidence, and human initialization/inspection/backup/recovery
operations are present. No gap justifies an Iteration 5.3. Phase 6 is the next
authorized implementation phase.

#### Recommended next task

Begin **Phase 6 — Operational-history and product maturity** by defining the
smallest logical product contracts and freshness/compatibility semantics over
the existing persistence reads. Do not let products or the app query DuckDB
tables, source systems, or providers, and address migration/retention only with
explicit versioned evidence.

#### Final validation follow-up

The complete repository-owned matrix passed:

- `Rscript operations/validate-documentation.R` — 4 checks, 0 issues;
- focused Phase 0–5 suites — respectively 10, 14, 38, 24, 55, and 18 tests,
  all passing;
- `Rscript operations/generate-reference.R` — reference scale succeeded with
  24 fictional patients, 36 discharge episodes, and 38 admitted events and
  wrote no generated data;
- `Rscript operations/run-reference-runtime.R --input synthetic --scale test`
  — 6 states and 6 requests with no provider or persistence;
- `Rscript operations/run-reference-estimation.R --input synthetic --scale test`
  — 6 successful estimates with no persistence, ranking, or products;
- the exact durable command run twice against one temporary database — both
  returned `runtime_synthetic_history_test_001`, `completed`, 2 statuses, and
  6 states/requests/executions/estimates after close/reopen;
- inspection reported `started -> completed`; checkpointed backup was copied to
  a new path and validated after reopen;
- `Rscript operations/validate.R --mode development` — 59 checks, 0 issues;
- `Rscript operations/validate.R --mode checkpoint` — 82 checks, 0 issues;
- clean `R CMD build` and
  `R CMD check --no-manual --no-vignettes` for `rrpruntime@0.3.0` — status OK;
- all 69 maintained R files and 35 maintained YAML files parsed;
- `renv::status()` — no issues with the independently locked `yaml@2.3.10`,
  `DBI@1.3.0`, and `duckdb@1.2.2` state; and
- repository/sibling independence, generated-database, dependency,
  later-scope, whitespace, and `git diff --check` reviews passed.

Generated temporary databases and the package-check directory were removed.
No database, product, application data, commit, push, publication, deployment,
or external-repository mutation remains. The sibling repository was read-only.

## Phase 6 — Operational-history and product maturity

### Iteration 6.1 — Logical product contracts and product-building boundary

#### Planned objective

Define and implement the smallest useful, versioned logical product layer over
the completed Phase 5 persistence reads. The iteration was to stop at valid
history → backend-neutral builders → conforming logical products → logical
access, with no physical product store, application, priority/decision policy,
source/provider invocation, replay, deployment, or observability behavior.

#### Actual implementation

- Added four language-neutral contracts under `contracts/products/`: one
  product-set contract and current-risk, persisted-risk-history, and terminal
  operational-run-summary products.
- Added a base-R `products/` boundary owning deterministic product/set/row
  identity, explicit freshness, compatibility checks, structured build
  results, multi-issue conformance, coherent set construction, and an in-memory
  logical access realization.
- Builders accept an `rrpruntime` persistence port or normalized records
  already returned by it. Port composition uses only valid run/current reads;
  it never receives a DBI connection, SQL table, repository path, source
  implementation, provider callable, or Shiny object.
- Added one read-only human operation that opens existing reference DuckDB
  history through the persistence port, selects explicit valid completed run
  IDs, builds/conforms the complete set, reports identity/freshness/status/
  counts, and discards all product objects on exit.
- Added focused Phase 6 tests and repository validation for product contracts,
  architecture, required files, current/history/run semantics, failure and
  empty behavior, conformance, access, and backend equivalence.

#### Product suite

1. `platform.current-episode-risk@0.1.0` has one row per episode + estimand
   ID/version with a current valid accepted estimate at the selected cutoff.
2. `platform.episode-risk-history@0.1.0` has one row per valid persisted
   accepted estimate and retains provider/estimand/run/restatement attribution.
3. `platform.operational-run-summary@0.1.0` has one row per selected valid
   terminal run, including completed-with-failures and exact persisted counts.
4. `platform.initial-risk-product-set@0.1.0` makes all three required core
   members. There is no partial-success initial set.

#### Decisions

1. **Product IDs/versions:** all initial interfaces are platform-owned active
   `0.1.0` specifications using the common YAML envelope.
2. **Product grains:** current uses episode/estimand, history uses estimate ID,
   and run summary uses runtime run ID. Each record also receives a
   deterministic product-row ID scoped to the set.
3. **Product-set identity:** the set includes exact set/member/builder versions,
   sorted source run IDs, and explicit cutoff. Paths, files, adapters, hashes,
   Git revisions, and wall-clock generation time are not logical identity.
4. **Freshness:** source cutoff, greatest represented run as-of, latest
   represented valid run, and generation time are separate fields.
5. **Compatibility:** supported upstream pre-1.0 minor lines are run `0.1`,
   state `0.1`, request `0.1`, execution result `0.2`, estimate `0.1`, and the
   initial estimand `0.1`. Storage-adapter changes are irrelevant when logical
   records are unchanged.
6. **Current semantics:** use persistence `read_current_estimate()` over the
   caller-declared closed source-run scope. Do not rerun eligibility.
7. **History semantics:** use validity-resolved accepted estimates only. Do not
   recompute trajectories; preserve provider transitions and restatement
   provenance.
8. **Failure/availability:** a valid supported zero-row product is `available`.
   Source read, compatibility, builder, conformance, or coherence failure
   fails the whole required set and exposes no consumable product collection.
9. **Backend independence:** generic product files are base R plus exported
   logical runtime reads and contain no DuckDB, DBI, SQL, source, provider,
   or application dependency.
10. **Access boundary:** exact `list_products`, `read_product`, and
    `read_product_metadata` needs are realized in memory; physical adapters are
    deferred.
11. **Retention/rebuild:** operational history remains operator-owned truth;
    product materializations may be shorter-lived and deletable without
    deleting history. Rebuild from retained compatible records is projection,
    not replay.
12. **Dependencies:** no package or lockfile dependency was added.

#### Reference assets inspected

After the clean suite and interfaces were designed, the required read-only
review covered the sibling's `app/data/`, product manifest, data-access code,
pipeline product/trajectory functions, provenance helper, and platform tests.
Coherent set identity, source attribution, deterministic order/count checks,
validation before consumption, and logical access were adapted as principles.

The fixed eight products, tracked CSV/materialization, Git/checksum/path
identity, reconstructed trajectories, synthetic metadata, priority/queue,
executive/measure/geography semantics, hard-coded paths, and app field
assumptions were rejected or deferred. No sibling code, specification,
identifier, data, configuration, or dependency was copied.

#### New material created cleanly

New work consists of four product contracts; four focused product modules; a
product operation composition module and command; architecture and human
operation guides; ten focused tests; product repository validation; updated
navigation, architecture, plan, decisions, reconciliation, agent guidance,
and this implementation record. All product identities and field meanings are
new repository-owned interfaces derived from current retained records.

#### Surprises/deviations

- The completed persistence port intentionally has no backend-wide run-list
  query. Rather than widen a stable Phase 5 boundary or inspect DuckDB tables,
  Iteration 6.1 requires explicit source run IDs. The reference command derives
  the deterministic scale run ID and permits repeated `--run-id`; broader run
  catalog/selection remains future operations/product-access work.
- A product build can legitimately succeed with zero current/history rows when
  a completed-with-failures run accepted no estimate. Treating that as failure
  would collapse availability and row cardinality.
- Source closure must be explicit: if the port's current read selects an
  estimate outside supplied run IDs, the build fails rather than mixing an
  undeclared newer history into the set.
- The Phase 6 plan was clarified as Iteration 6.1 logical products followed by
  Iteration 6.2 physical access plus minimal app. The phase sequence and Phase 6
  exit evidence did not change.

#### Validation evidence

Focused development evidence:

- `Rscript tests/run-phase6-tests.R` — 10 tests, 0 failures, covering contract
  suite/boundaries, current selection and deterministic identity, provider
  transition, invalidation/restatement, completed-with-failures/counts,
  available zero-row products, multi-issue conformance, logical access,
  in-memory/DuckDB exact equivalence, and structured read failure; and
- product construction through both the test persistence adapter and a
  temporary DuckDB adapter used the same builder and produced identical
  logical product-set metadata and rows.

The complete Phase 0–6, operation, parse, dependency, whitespace, and
checkpoint results are recorded in the final validation follow-up below.

#### Implications for Iteration 6.2

- Select one replaceable physical product adapter without changing the logical
  contracts or builder outputs.
- Validate set identity, member versions, freshness, availability, and
  coherence before any application view reads a product.
- Build the smallest fictional capability-aware app exclusively over logical
  product access; it must not read persistence/source tables or invoke runtime
  or providers.
- Do not add priority/queue/decision products until their separate governed
  semantics exist. Remaining history migration/retention maturity also
  requires deliberate scope.

#### Phase 6 status

**In progress.** The logical product and access boundary is complete for the
first suite. Physical materialization/access, the minimal application, and
remaining Phase 6 history/product maturity are not implemented.

#### Recommended next task

Begin **Iteration 6.2 — Physical product access and minimal application** by
selecting the smallest replaceable fictional product materialization adapter,
proving stale/incompatible/coherence rejection through the logical access
contract, and adding only the minimal Shiny consumer required to exercise the
three products. Keep decision policy, deployment, replay, and observability out
of scope.

#### Final validation follow-up

The complete repository-owned matrix passed on the final implementation:

- `Rscript operations/validate-documentation.R` — 4 checks, 0 issues;
- focused Phase 0–6 suites — respectively 10, 14, 38, 24, 55, 18, and
  10 tests, all passing;
- `Rscript operations/validate.R --mode development` — 70 checks, 0 issues;
- `Rscript operations/validate.R --mode checkpoint` — 93 checks, 0 issues;
- a fresh temporary `run-reference-history.R --scale test` produced one
  completed durable run with 6 states, requests, executions, and estimates;
- `build-reference-products.R` over that database reported the exact three
  products with 6 current rows, 6 persisted-history rows, and 1 run-summary
  row, then exited without writing a product file/table;
- in-memory and temporary DuckDB histories produced identical logical set
  metadata and rows under a fixed generation time;
- all 78 maintained R files and 39 YAML files parsed;
- `renv::status()` reported no issues and no dependency/lockfile change; its
  attempted repository-index refresh was unavailable in the restricted
  network environment and did not affect the consistency result;
- clean `R CMD build` and `R CMD check --no-manual --no-vignettes` for
  unchanged `rrpruntime@0.3.0` — status OK;
- `git diff --check`, generated-database/package-artifact checks, forbidden
  product dependency scans, native-pipe review, and repository status/diff
  review passed.

The restricted execution environment's renv global sandbox lock probe stalled
inside filesystem metadata inspection, so validation commands were invoked
with sandbox activation disabled for this session. The repository's own renv
project/library, snapshot dependency discovery, lockfile, and `renv::status()`
remained active and consistent. This is an execution-environment workaround,
not a documented platform operation or repository change.

Temporary databases, package archives, and check directories were removed.
No product materialization, application data, commit, push, publication,
deployment, or external mutation occurred. The sibling repository remained
read-only.

### Iteration 6.2 — Reference product materialization and minimal product-only application

#### Planned objective

Realize the logical products through one replaceable physical adapter, validate
one coherent set before access, and provide the smallest useful Shiny consumer
through that access alone. Prove history → materialize → launch without adding
deployment, scheduling, priority/decision policy, replay, or observability.

#### Materialization decision

`reference.yaml-product-bundle@0.1.0` implements
`platform.product-materialization-adapter@0.1.0`. CSV was rejected because the
contracts contain nested model, provider, estimand, implementation, mapping,
and provenance references; it would need another bespoke encoding. YAML is an
already-owned, inspectable, language-neutral dependency and remains a
replaceable reference rather than a platform requirement.

#### Actual implementation

- Added the materialization contract/declaration and YAML staging, hashing,
  validation, publication, and access modules.
- Added immutable set directories with three member documents and
  `PRODUCT_SET.yml`, selected by atomically replaced `CURRENT.yml`.
- Extended product build with opt-in `--materialize`/`--products`, preserving
  the in-memory default.
- Added product-only app initialization, presentation view models, three-view
  Shiny factory, injection-only entry, and independent launch/validate command.
- Added architecture/operations documentation, dependency state, repository
  validation, and focused materialization/application tests.

#### Decisions

1. Adapter is `reference.yaml-product-bundle@0.1.0`; physical format is one
   YAML manifest plus one YAML document per logical product.
2. Complete-set staging and immutable-directory promotion precede atomic
   same-filesystem `CURRENT.yml` replacement; partial sets are never visible.
3. Previous bundles remain for inspection/recovery until separately governed
   cleanup. Identical writes are idempotent; conflicts fail.
4. Integrity uses exact inventory, non-linked paths, YAML readability, and MD5
   manifest/member checks. MD5 detects accidental corruption, not authenticity.
5. Physical open validates integrity, compatibility, and coherence before
   returning list/read/metadata access; failures return issues and no access.
6. Freshness exposes cutoff, source as-of, latest run, generation, and
   publication. No universal stale threshold exists; old valid sets load.
7. Available zero-row products render explicit empty messages.
8. `shiny@1.10.0` is the only direct app dependency; standard Shiny and base
   graphics are sufficient.
9. Launch validates then starts, never regenerates, and can be repeated.
10. Generated databases/bundles remain ignored and uncommitted. Scheduling is
    external; missed runs create no points and same-day runs remain distinct.

#### Reference assets inspected

After clean design, sibling `app/app.R`, `app/R/data-access.R`,
`app/R/app-init.R`, `app/data/PRODUCT_MANIFEST.yml`, absent root
`manifest.json`, and `deploy/connect-cloud/` were inspected read-only. Central
access initialization, complete-manifest validation, counts/hashes,
deployment-neutral app ownership, and a later generated adapter were adapted
as principles or retained as later evidence. The eight-product suite,
CSV/RDS/path config, database switch, engine loading, tracked product
checkpoint, priority products, and Connect publication were rejected/deferred.
No code, text, data, configuration, identifier, or dependency metadata was
copied.

#### New material created cleanly

New clean work comprises the contract/declaration, three adapter modules, two
architecture guides, four app modules, operation composition and launcher,
extended build flags, focused tests, dependency/validation updates, human and
agent guidance, and evidence records.

#### Surprises/deviations

- The suite is not flat: nested references make CSV less simple than YAML.
- YAML preserves contract semantics but may normalize an integral R scalar's
  storage type; logical integer validation, identities, and values are stable.
- Sandboxed R startup could not create renv's user-cache lock, so development
  used vanilla startup until supported commands were rerun with required
  filesystem permission. Repository behavior did not change.
- The specified evidence closes Phase 6; no Iteration 6.3 polish is justified.

#### Validation evidence

Focused Phase 6 development passed 17 cases: ten unchanged logical cases plus
adapter declaration, YAML/in-memory equivalence, atomic replacement/retention,
corruption/incompatibility, old-valid freshness, zero-row/safe-failure Shiny
initialization, and irregular/multiple same-day observations. Full matrix and
manual lifecycle evidence is recorded in the final follow-up below.

#### Implications for Phase 7

Phase 7 can assume tested human commands for history, build, atomic
materialization, product validation, and local app startup. It may consolidate
callable results and adoption guidance without moving business logic into a
CLI/agent or selecting deployment/scheduling.

#### Phase 6 status

**Complete.** Logical products/builders, rebuildable durable materialization,
whole-set access validation, minimal Shiny consumption, factual freshness,
irregular/same-day history, safe empty/failure behavior, and the source-to-app
path are demonstrated without backend leakage.

#### Recommended next task

Begin **Phase 7 — Stable platform operations and adoption guides** by
inventorying callable operation surfaces and defining the smallest human
initialize/doctor/run/materialize/launch workflow. Do not add a CLI, scheduler,
deployment, or release machinery until that design shows a concrete need.

#### Final validation follow-up

The completed implementation passed the full required matrix:

- documentation — 4 checks, 0 issues;
- focused Phase 0–6 suites — 10, 14, 38, 24, 55, 18, and 17 tests,
  respectively, all passing;
- development validation — 73 checks, 0 issues;
- completed Phase 6 checkpoint — 109 checks, 0 issues, including an explicit
  Phase 6 product/materialization/application checkpoint component;
- fresh temporary history → materialization → app initialization — completed
  with 6 states, 6 requests, 6 executions, 6 estimates, product rows 6/6/1,
  atomic publication, and successful `--validate-only` Shiny construction;
- 89 maintained R files and 41 YAML files parsed with zero failures;
- `renv::status()` — no issues, with `shiny@1.10.0` and its transitive
  dependencies locked/restored; and
- clean `R CMD build` and `R CMD check --no-manual --no-vignettes` for the
  unchanged base-R-only `rrpruntime@0.3.0` — status OK;
- app/product forbidden-dependency scans, generated-data check, sibling
  worktree check, native-pipe scan, whitespace, and `git diff --check` passed.

The aggregate validation used `RENV_CONFIG_SANDBOX_ENABLED=FALSE` only because
the managed execution environment cannot coordinate renv's user-cache lock
across its nested R processes. The documented commands, repository project
library, lockfile, and test semantics were unchanged. Temporary lifecycle
state was created under `/private/tmp` and removed. No generated product or
database was added to the repository, and no commit, push, deployment,
publication, scheduling, or external mutation occurred.

## Phase 7 — Stable platform operations and adoption guides

### Iteration 7.1 — Human initialization, doctor, workflow, and adoption guidance

#### Planned objective

Turn the separately proven Phase 0–6 operations into a small stable human
operating model: restore dependencies, initialize local state, run read-only
doctor, execute one reference platform refresh, inspect operational history,
materialize products, validate the app payload, and launch the product-only app.
Keep AI optional and preserve lower-level debugging operations while excluding
scheduling, deployment, release, replay, decision policy, and observability.

#### Actual implementation

- Added `platform.initialize-local`, which verifies the installed environment
  and creates only an ignored writable local build root.
- Added `platform.doctor`, a read-only preflight with pass/warning/failure
  results and lifecycle status for environment, history, latest run, products,
  product source as-of, and app readiness.
- Added `reference.run-platform`, the one public source → canonical → runtime →
  estimand/provider → durable history command. It reuses the tested Phase 3–5
  composition and never materializes products or starts the app.
- Made history inspection usable with public defaults while retaining its
  explicit database/run/view form.
- Kept product materialization and app validation/launch as separate Phase 6
  commands and standardized their human console operation/status/next-action
  output without changing product or app semantics.
- Added a small declarative registry for stable/advanced/development operation
  classification and documentation drift checks. It contains no executable
  business logic or command router.
- Added the procedural operator manual and progressive-implementation guide,
  including component composition, cadence versus estimand horizon, missed and
  same-day runs, troubleshooting, external scheduling, and replacement duties.
- Added focused Phase 7 tests plus development/checkpoint integration for fresh
  state, doctor failures, end-to-end state transitions, idempotency, distinct
  same-day runs, downstream-only materialization/app behavior, documentation,
  and agent alignment.

#### Public operation surface

Nine public IDs are registered: local initialize, doctor, development
validation, checkpoint validation, reference platform run, history inspection,
product materialization, app validation, and app launch. Source generation,
runtime-only, estimation-only, lower-level history, in-memory product build,
history backup, documentation validation, and phase suites remain advanced or
development operations for diagnosis and maintenance.

#### Initialization decision

`renv::restore()` remains an explicit prerequisite because it may access package
repositories and change the project library. Initialization does not hide that
mutation, initialize DuckDB, create fake history/products, launch Shiny, or
touch maintained source. It only makes the ignored local state root explicit
and repeatable.

#### Doctor behavior

Doctor checks R, locked direct dependencies, required reference files/config,
temporary runtime package install/load, writable output parents, DuckDB
adapter/schema compatibility and lifecycle, complete YAML product access, and
Shiny readiness. Fresh absence of history/products is a warning and exits zero;
missing dependencies, incompatible history, corrupt product bundles, or runtime
load failure block operation and name a recovery action. Temporary probes and
package libraries are removed.

Doctor intentionally does not use Git cleanliness as readiness. Git is only the
current development acquisition path, and repository/checkpoint validation
already owns maintained/generated-state policy independently of operator
preflight.

#### Reference workflow and operation classification

The authoritative manual sequence is initialize → doctor → run platform →
inspect history → materialize products → validate app → launch app. No combined
workflow wrapper was added: the seven short commands clearly expose different
mutation boundaries, and a wrapper would add little evidence. A new run may
accept explicit run/as-of identity; the preserved deterministic default remains
idempotent for teaching and regression.

#### Scheduling, missed-run, and same-day semantics

The canonical wording is: the platform owns what a run does; the operator owns
when runs occur. External schedulers may invoke the same commands but none is
implemented or required. A missed run creates no estimate and is never
backfilled with future facts. Multiple same-day runs and overlapping one-day
estimand target intervals remain separately identified retained observations.
Product rebuild and app launch create no operational history.

#### Progressive implementation guidance

The reference source/profile/estimand/provider/DuckDB/product-set/YAML/Shiny
composition is documented as one coherent out-of-box realization, not generic
dependencies. An adopter may replace source mapping, provider, persistence,
materialization/app, and future deployment independently in any coherent order.
The guides describe each component's ownership and explicitly add no hospital
SQL, second persistence adapter, provider method, or customization framework.

#### Agent/human alignment and operations-registry decision

`AGENTS.md` now requires the operator manual first, exact operation invocation,
reporting of the human command used, aligned docs/registry/tests, no implicit
scheduling, and no unsolicited hospital-source changes. Ambiguous “refresh app”
language is rejected in favor of distinct platform run, product refresh, and
app launch intents. The operation count now justifies a minimal YAML registry
for drift metadata, but not a CLI framework, interactive menu, or executable
orchestrator.

#### Reference assets inspected

Sibling operation guides/registry, scripts, START-HERE, and agent guidance were
inspected read-only after the clean design. Stable IDs, exact command/doc
linkage, task-oriented recovery coverage, and agent-to-human operation mapping
were adapted as principles. The old full catalog, `targets` pipeline, Git
A/B/C/tracked-product refresh rules, deployment/publication operations, and
agent-only checkpoint procedures were rejected or deferred. No sibling code,
text, YAML, configuration, identifier, or dependency was copied.

#### New material created cleanly

New clean work includes three public scripts, two operation-library modules,
the operations registry, Phase 7 test runner/suite, operator manual, progressive
implementation guide, adapter lifecycle status helper, and coordinated
validation/navigation/architecture/plan/decision/agent/record updates. Existing
runtime, provider, persistence, product, and app contracts remain unchanged.

#### Surprises and deviations

- The existing deterministic Phase 5 run identity remains important for
  idempotency teaching, while an operator-owned run/as-of override was needed
  to prove actual repeated observations and multiple same-day runs.
- The persistence port intentionally has no global run catalog. Doctor's latest
  lifecycle summary therefore stays in the concrete reference adapter and does
  not widen the generic port.
- The managed execution environment again required disabling only renv's
  global sandbox lock for validation subprocesses; project lockfile semantics
  and documented human commands did not change.
- No architecture dependency changed. The plan/architecture were updated only
  to record the now-stable operation control surface and Phase 7 completion.

#### Validation evidence

The completed repository-owned matrix passed:

- documentation validation — 4 checks, 0 issues;
- focused Phase 0–7 suites — 10, 14, 38, 24, 55, 18, 17, and 8 tests,
  respectively, all passing;
- development validation — 80 checks, 0 issues;
- completed Phase 7 checkpoint — 123 checks, 0 issues;
- fresh doctor — environment ready with expected nonfatal absent history,
  product, and app-data warnings;
- temporary initialize → doctor → platform run → history inspection → product
  materialization → app validation → second same-day run → product rebuild;
  two terminal runs and 12 retained estimate points remained distinct, while
  product/app-only actions left operational history unchanged;
- missing dependency, incompatible DuckDB, corrupt current product bundle,
  exact retry idempotency, and no missed-run backfill all failed or warned with
  the intended actionable semantics;
- all maintained R and YAML parsed, `renv::status()` reported synchronized
  dependency state, `rrpruntime@0.3.0` built/checked cleanly, and whitespace plus
  `git diff --check` passed.

The aggregate R commands used `RENV_CONFIG_SANDBOX_ENABLED=FALSE` only because
the managed execution environment cannot coordinate renv's user-cache sandbox
lock across nested processes. The project library, lockfile, documented human
commands, and platform semantics were unchanged. Temporary state was removed;
no generated database/product, commit, push, deployment, publication,
scheduling, or external mutation remains.

#### Implications for deployment phase

Deployment can now assume a stable human build/materialize/app-validation
workflow, but no deployment packaging/publication exists yet. Phase 8 may build
a reduced validated application artifact and realize it for Connect Cloud or
another target without redefining upstream operations or app semantics.

#### Phase 7 status

**Complete.** Stable human entry points, fresh-install/doctor semantics,
operator/adoption/troubleshooting guidance, operation classification and drift
validation, human/agent alignment, and full reference lifecycle evidence are
present. Upgrade and release behavior remain in later planned phases rather
than forcing an unnecessary Iteration 7.2.

#### Recommended next task

Begin **Phase 8 — Deployment build and Connect Cloud reference** by defining a
target-neutral reduced application artifact contract before inspecting/adapting
old target-specific builders. Keep artifact construction separate from
publication and require explicit authority for external repository mutation.

## Phase 8 — Deployment build and Connect Cloud reference

### Iteration 8.1 — Target-neutral reduced application artifact

#### Planned objective

Define and implement the smallest versioned, target-neutral runtime unit for
the existing product-only Shiny application. Build it only from an already
validated materialized product set, validate it independently from an isolated
copy, and leave Connect Cloud realization/publication, Git destinations,
containers, credentials, and external mutation for later work.

#### Runtime-needs characterization

The app needs its three modules and Shiny factory; read-only YAML product
foundation/conformance/validation/access; the materialization, product-set, and
three product contracts plus application/adapter declarations; one coherent
current YAML bundle; and direct R/Shiny/YAML requirements. Canonical/source
generation, `rrpruntime`, provider execution, DuckDB/history, product builders
and writers, platform operations, tests, docs, `renv`, Git, and target files are
monorepo/build concerns and unnecessary at app runtime. Host/port, process
management, package installation, access control, secrets, and hosting policy
remain externally supplied.

#### Actual implementation

- Added `platform.reduced-application-artifact@0.1.0` and the versioned
  `reference.readmission-risk-application@0.1.0` declaration.
- Split read-only YAML access from materialization without changing adapter,
  product, or app semantics.
- Added a maintained standalone artifact loader/validator and target-neutral
  Shiny entry point.
- Added public build and validate operations, registry entries, operator
  guidance, and exact agent mappings.
- Added a closed source-to-artifact allowlist, staged build, immutable artifact
  directories, an atomic current pointer, and isolated vanilla-process
  validation.
- Added eleven focused success/failure tests and integrated Iteration 8.1 into
  development/checkpoint validation.

#### Artifact contract and exact contents

The completed artifact contains 27 regular files: `ARTIFACT.yml`,
`ARTIFACT.md5`, root app/validator entry points, nine R runtime/read-only access
modules, seven embedded contract/application documents, two runtime/adapter
declarations, and five files comprising the current YAML product bundle. The
manifest declares exact runtime and product member allowlists plus 25 payload
checksums. Unexpected files and all symbolic links fail.

#### Dependency decision

`config/runtime-dependencies.yml` declares only R >= 4.1.0,
`shiny@1.10.0`, and `yaml@2.3.10` as exact direct runtime roots. The full
project `renv.lock` was not copied because DBI, DuckDB, build/test, and
development dependencies are not permanent application requirements. No
developer library is bundled. A later target realization must install the
declared roots and resolve their transitive closure through its supported
mechanism.

#### Identity and integrity semantics

Artifact specification, instance, build, operational run, product set,
deployment, and publication identities remain separate. Instance identity is
deterministic from artifact/application versions, product-set ID, and all
payload paths/checksums. Build identity adds declared build time. Git revision
and output path are excluded. `ARTIFACT.md5` covers the manifest and manifest
MD5 entries cover every payload; MD5 is accidental-corruption evidence, not
authenticity or signing.

#### Build and validation operations

`Rscript operations/build-application-artifact.R` validates source products
and app construction, stages only approved regular files, writes manifest and
integrity metadata, validates staged content, atomically promotes an immutable
build, validates again, and replaces only the local current pointer. It never
creates history/products. Exact build/content retry is idempotent; a new build
time retains a new build with the same instance identity when content is
unchanged; an identity/content conflict fails.

`Rscript operations/validate-application-artifact.R` resolves an artifact store
or immutable directory and invokes the artifact's own validator in a vanilla R
subprocess with the artifact as working directory and only the installed
package library external. It validates inventory, paths, links, checksums,
declarations, product integrity/coherence/freshness, dependencies, app
initialization, and Shiny construction.

#### Sibling evidence inspected and classifications

The clean boundary preceded read-only inspection of the sibling Connect bundle
specification/builder/validator/templates, deployment tests, and publication
helper/profile/tests. Explicit allowlisting, staging, checksum/exclusion
validation, validate-before-promotion, and isolated-copy initialization were
**adapted as principles only**. The generated root adapter was **reference
only**. Destination ownership, staging/rollback, dry-run, and commit/push safety
were **deferred**. Connect identity, `rsconnect`, Git checkpoint/provenance
requirements, tracked products, broad engine/schema copying, companion
repository mutation, and fully-generated ownership as generic artifact meaning
were rejected or deferred. No sibling asset was copied and the sibling was not
modified.

#### Surprises and deviations

- The current app's clean injection boundary made a substantially smaller
  artifact possible than the old deployment bundle.
- The existing YAML adapter combined writer and reader functions in one file;
  separating read-only access was required to honor the reduced boundary but
  did not change its public contract.
- The broader project lock is honest for platform development but dishonest as
  a permanent app dependency declaration, so a small direct-runtime document
  is the artifact contract while target-specific restoration remains later.
- Build time belongs to a build occurrence, not the logical artifact instance;
  distinct IDs preserve both stability and attributable replacement.
- No architecture direction changed. Architecture and plan were clarified to
  make the target-neutral artifact an explicit stage before target realization.

#### Validation evidence

The focused Phase 8 suite passed eleven cases covering valid construction,
closed inventory, stable instance/build identity, exact retry/new-build
semantics, product-set identity/integrity, unexpected content, corruption,
missing app/product files, compatibility failure after valid resealing,
escaping symlinks, isolated vanilla-process startup, and absence of
DuckDB/history/source/provider machinery. A temporary human smoke flow ran
platform → materialize products → build artifact → standalone validation and
constructed the product-only Shiny app successfully. Full aggregate evidence
is recorded in the final follow-up below.

#### Implications for Connect Cloud realization

A later Connect builder can consume the validated artifact and add only
target-required packaging/configuration. It must not reach back into source,
runtime/provider, history, or product-building code; redefine dependency or
product meaning; or combine realization with publication. Destination
ownership and external mutation still require explicit maintainer decisions
and authority.

#### Architecture and plan effect

The dependency direction is unchanged. The deployment section now makes its
previous implicit two-stage boundary explicit, and the plan marks Iteration
8.1 complete while keeping Phase 8 in progress until a target realization and
its separate publication boundary are implemented.

#### Phase 8 status

**In progress.** Iteration 8.1 is complete: the target-neutral artifact
contract, builder, standalone validator, and isolated runtime proof exist.
Connect Cloud realization/validation and any publication operation do not.

#### Recommended next task

Begin **Phase 8 / Iteration 8.2 — Connect Cloud realization from the validated
artifact**. Define a target profile and local realization/validation adapter
that consumes only `platform.reduced-application-artifact@0.1.0`. Keep external
publication, companion-repository mutation, commit, and push out of that task
unless separately and explicitly authorized.

#### Final validation follow-up

After reconciling maintained navigation and the expanded operation registry,
the final validation matrix passed:

- `Rscript operations/validate.R --mode development`: **PASS**, 87 checks and
  zero issues, including Phase 0–8 focused suites;
- `Rscript operations/validate.R --mode checkpoint`: **PASS**, 136 checks and
  zero issues for the completed Iteration 8.1 checkpoint; and
- the focused suites reported 10, 14, 38, 24, 55, 18, 17, 8, and 11 passing
  tests for Phases 0 through 8 respectively.

The local machine had long-lived unrelated R processes holding the `renv`
sandbox lock, so the final aggregate commands were invoked with
`RENV_CONFIG_SANDBOX_ENABLED=FALSE`. This changes only `renv` activation's
process-isolation mechanism; it does not bypass dependency restoration,
checkpoint requirements, repository checks, or any test. The normal commands
remain the documented and supported human interface. The expected implicit
snapshot dependency-discovery note remained informational.

### Iteration 8.2 — Connect Cloud realization from the validated artifact

#### Planned objective

Consume only one successfully validated
`platform.reduced-application-artifact@0.1.0` and generate a complete,
standalone local Git repository suitable for operator-controlled Posit Connect
Cloud publication. Stop before commit, remote configuration/creation, push,
credentials, service APIs, or deployment. Keep the artifact target-neutral so
a later OCI/container realization can consume the same boundary as a peer.

#### Connect requirements and target contract

Current maintained Posit documentation was checked on 2026-08-13 before the
target shape was implemented. R content requires a `manifest.json` colocated
with the primary app; Connect uses the manifest to select R/install packages
rather than using `renv`; the documented Shiny flow uses a Git repository with
`app.R`; and repository, branch, and primary-file selection occur in Connect.
These requirements are recorded with official evidence links in
`docs/architecture/connect-cloud-realization.md`.

Added `platform.connect-cloud-git-realization@0.1.0`. It declares Connect Cloud
Git-backed Shiny as the target, compatibility with the exact artifact and app
versions, required target files, dependency realization, root entry point,
independent validation, source-artifact/provenance relationship, generated
repository semantics, external responsibilities, and explicit non-claims. It
does not redefine application, product, estimand, provider, persistence, or
runtime meaning.

#### Actual implementation

- Added an explicit-destination public builder and validator, operation
  registry entries, agent mappings, and human generation/recovery guide.
- Preserved the complete 27-file artifact byte-for-byte beneath `artifact/`
  and added only ten target-owned files: root app, Connect and checksum
  manifests, pruned lock, realization and checksum manifests, standalone
  validator/runtime, target contract, and README.
- Added a target-root adapter that delegates solely to the embedded artifact,
  plus a standalone validator requiring no authoritative-platform source.
- Added staged validation-before-promotion, ownership-aware idempotence and
  replacement, failure cleanup/rollback behavior, Git initialization/staging,
  and conservative refusal of unsafe destinations.
- Added eleven Connect cases to the existing eleven artifact cases and integrated
  target repository validation into development and the Phase 8 checkpoint.

#### Local repository and Git decision

The destination is explicit, outside the authoritative repository, and absent
from realization identity. The builder creates it. The generated repository is
initialized on `main` and all 37 generated regular files are staged, but no
commit, remote, credential, or repository-local author identity is created.
This is the clean boundary immediately before external publication: committing
would otherwise require inventing or altering operator identity. Git commit,
remote, publication, and Connect content identities remain separate from the
realization and artifact IDs.

#### Dependency realization decision

The artifact's direct runtime roots remain exactly `shiny@1.10.0` and
`yaml@2.3.10`. The builder traverses only their transitive requirements in the
platform lock, excludes DBI/DuckDB/runtime/build packages, retains the pruned
deployment-specific `renv.lock` as generator evidence, and uses build-only
`rsconnect@1.3.1` to generate Connect-required `manifest.json`. Connect
consumes the latter rather than the lock. Copying the platform-wide lock or a
developer library was rejected.

#### Destination ownership and regeneration

Generation validates the source independently, stages beside the destination,
validates content and isolated Shiny construction, initializes/stages Git,
validates Git state, and only then promotes. A nonexistent destination is
created. An identical owned realization is a no-touch idempotent result. A
changed artifact/target may replace only an independently valid, unmodified,
uncommitted, remote-free generated repository. Unrelated, modified, corrupt,
committed, remotely configured, symlinked, or otherwise ambiguous destinations
fail closed. Pre-promotion failure leaves the destination unchanged and
removes staging; failed replacement promotion attempts rollback. Generated
repositories are disposable outputs, not supported manual-edit branches.

#### Sibling assets inspected and classifications

The clean contract, identity, layout, dependency, Git, and destination design
preceded read-only inspection of the sibling Connect bundle declaration,
builder/validator, deployment tests, root adapter/templates, and publication
helper. Explicit allowlisting, isolated staging, checksum/inventory checks,
validate-before-promotion, destination ownership markers, and conservative
replacement were **adapted as principles only**. The old root adapter and
handoff README were **reference only**. Broad engine/schema/product copying,
tracked generated products, Git revision as run/product identity, hard-coded
companion paths, core clean-commit assumptions, and build-coupled commit/push
were **rejected**. Publication helper/remotes/push and profile-specific
assumptions were **deferred or rejected for this boundary**. No sibling code,
text, YAML, product, identifier, configuration, or dependency metadata was
copied, and the sibling was not modified.

#### New material created cleanly

New clean work comprises the realization contract, five maintained target
payload sources, build and independent-validation entry points, build and
repository validation libraries, eleven focused cases, architecture/operations
guides, and coordinated plan/decision/registry/navigation/checkpoint/agent
updates. Upstream source, canonical, runtime, provider, history, product, and
application contracts remain unchanged; target code did not enter their
boundaries.

#### Surprises and deviations

- Connect Cloud requires `manifest.json` and currently ignores `renv` for
  environment setup, so the lock is deliberately generator input rather than
  the deployed installation mechanism.
- Direct `rsconnect` discovery from the active project/library lacked enough
  reproducible source metadata. Pruning the authoritative lock before
  `writeManifest()` produced an exact auditable runtime closure without
  platform-only packages.
- Staged-but-uncommitted is safer and more honest than the older plan's implied
  local commit because the platform neither owns nor invents operator identity.
- The older plan's separate publication-operation deliverable conflicted with
  the clarified boundary. Architecture and plan now state that the platform
  generates deployable artifacts and the operator decides where to publish or
  deploy them.
- The managed environment again needed renv sandbox-lock disabling for nested
  validation only; documented commands and dependency semantics are unchanged.

#### Validation evidence

The focused Phase 8 suite passed all 22 artifact/realization cases. Connect
coverage proves exact inventory and dependencies, copied-repository standalone
validation and Shiny construction, staged/uncommitted/remote-free Git state,
idempotence, unrelated and modified destination refusal, corrupt artifact
failure before mutation, safe owned replacement after artifact change,
manifest/extra/symlink rejection, source-artifact immutability, and absence of
platform-only machinery. Final aggregate, dependency, package, parsing,
generated-state, sibling-read-only, and whitespace evidence is recorded after
the completed validation run below.

#### Implications for future targets and publication

The nested artifact remains unchanged and target-neutral; an OCI/container
realization can add its own runtime/dependency layer as a peer without knowing
Connect layout or Git semantics. This iteration intentionally specifies no OCI
endpoint. External publication guidance identifies operator responsibilities
but implements no remote, commit, push, credentials, GitHub App, Connect API,
or deployment procedure. Production use remains subject to adopter-owned
privacy, security, access, networking, retention, and governance controls.

#### Architecture, plan, and Phase 8 status

The upstream dependency direction did not change. The architecture and plan
were changed only to make the implemented local-realization/operator-
publication boundary authoritative and remove publication machinery from
platform responsibility. The ownership open decision is resolved.

**Phase 8 is complete.** Both the target-neutral artifact boundary and the
first target-specific independently valid local realization are proven.
External publication is correctly outside platform implementation; adding a
helper merely to satisfy older wording would violate the clarified boundary.

#### Recommended next task

Begin **Phase 9 / Iteration 9.1** with the smallest privacy-conscious structured
run-context/event contract and console rendering boundary for existing stable
operations. Do not add deployment sinks, scheduling, audit, metrics, or
patient-level diagnostics before their owning requirements are concrete.

#### Final validation follow-up

After dependency and documentation reconciliation, the complete matrix passed:

- `Rscript tests/run-phase8-tests.R`: **PASS**, 22 cases;
- `Rscript operations/validate-documentation.R`: **PASS**, 4 checks and zero
  issues;
- `Rscript operations/validate.R --mode development`: **PASS**, 93 checks and
  zero issues, including all Phase 0–8 suites;
- `Rscript operations/validate.R --mode checkpoint`: **PASS**, 148 checks and
  zero issues for completed Phase 8;
- focused suites reported 10, 14, 38, 24, 55, 18, 17, 8, and 22 passing tests
  for Phases 0 through 8;
- `renv::status()` reported no issues after recording `rsconnect@1.3.1` and its
  seven previously installed transitive dependencies;
- `rrpruntime@0.3.0` built and passed `R CMD check` with `Status: OK`;
- the public artifact build/validation and Connect build/validation commands
  succeeded; the generated target independently proved 37 staged files on
  uncommitted `main`, no remote, exact dependency/inventory integrity, and
  isolated Shiny construction; and
- maintained R/YAML parsing, forbidden-boundary scans, source/sibling status,
  generated-state cleanup, and `git diff --check` passed.

Aggregate commands used `RENV_CONFIG_SANDBOX_ENABLED=FALSE` only because the
managed environment cannot use renv's global sandbox process lock reliably.
The project library and lockfile remained active and checkpoint behavior was
not bypassed. Network-unavailable repository-index warnings during dependency
status/package check were nonfatal because the complete locked installed state
was present. The informational implicit-snapshot dependency-discovery timing
note remains a performance observation rather than an integrity failure.

## Phase 9 — Observability

### Iteration 9.1 — Structured run context, operational events, and privacy-conscious console diagnostics

#### Planned objective

Add the smallest implementation-neutral, privacy-conscious diagnostic boundary
around existing stable operations: a distinct operation-run context, a
versioned structured event, a callable sink, and a human console renderer.
Trace bounded lifecycle/stage progress without changing analytical history,
domain results, deterministic identities, validation semantics, or deployment
behavior. Do not add a vendor, retained log, metrics, audit, alerting,
scheduling, or patient-level diagnostic.

#### Actual work

- Added `platform.operation-run-context@0.1.0` and
  `platform.operational-diagnostic-event@0.1.0` language-neutral contracts.
- Added a base-R operations-layer context/emitter with sequential event IDs,
  explicit-offset timestamps, controlled lifecycle/severity/component/stage
  vocabulary, terminal duration, in-memory event access, and terminal-state
  enforcement.
- Added a callable sink boundary and non-retained console reference sink. Its
  normal, quiet, and debug renderer thresholds are adapter concerns; quiet
  retains warnings/errors.
- Added strict shallow scalar safe-context and related-identity allowlists,
  explicit aggregate-count keys, bounded single-line text, and rejection of
  patient-level identifiers/values, clinical/risk/features, raw/nested
  payloads, SQL, paths, connection/credential/environment content, and common
  secret forms.
- Instrumented doctor, stable reference run, logical product build/
  materialization, application-artifact build, and Connect realization through
  the common boundary. The run emits aggregate source/canonical-production,
  runtime, provider, and persistence boundaries with safe non-patient
  correlation identities.
- Preserved every existing command, operation registry identity, domain return
  object, process exit status, analytical-history record, and artifact/
  realization input. Observability remains optional at the composed reference
  history function boundary.
- Added focused contract, privacy, lifecycle, correlation, rendering,
  persistence-boundary, terminal, and RNG-independence tests plus repository
  and checkpoint integration.

#### Old assets used or adapted

The clean contract and operations boundary were designed first from True North,
the architecture, the Phase 9 plan, and current stable operation results. The
sibling repository was then reviewed only as read-only historical evidence for
logging/console patterns. No file, dependency, log schema, configuration, or
runtime behavior was copied or required. The clean implementation owns all new
contracts, code, tests, and documentation locally.

The sibling architecture assessment/refactoring-plan observations were
classified **reference only**: they confirmed that old output was fragmented
and that stable operations were the appropriate future hooks. The old scripts'
ad hoc `message()` stage/publication summaries were classified **rejected as a
contract**; their labels, Git/provenance coupling, paths, and publication
behavior were not reused. The sibling privacy cautions were consistent with
True North but added no clean executable asset. Sibling status was unchanged
before and after review.

#### Decisions and rationale

- Ownership stays under `operations/lib/`, not `rrpruntime`: console/routing is
  orchestration concern and must not become a base runtime dependency.
- Operation-run identity is unique per attempt and separate from analytical
  runtime-run identity. Related identities correlate without redefining
  products, artifacts, deployments, provenance, or validation.
- The emitter stores validated objects before invoking a callable sink. This
  keeps structured semantics independent of presentation and permits a future
  deployment-owned sink without domain-code changes.
- The only default sink is the process console. The repository creates no log
  file/table, declares no retention, and makes no audit claim.
- Unsafe mappings fail closed rather than silently serialize or partially
  redact arbitrary payloads. The allowlist is intentionally narrow and its
  automated enforcement is not certification.
- Context identity generation uses filesystem entropy and MD5 only as a local
  uniqueness mechanism and does not consume R's RNG. MD5 here is not security
  or authenticity evidence.
- Runtime stage events are emitted at actual composed boundaries. Provider
  exceptions receive a stable safe category in structured diagnostics; raw
  local error detail remains outside the event contract.

#### Surprises, deviations, and reconciliation

An initial command-wrapper sketch announced every reference-run stage before
the composed operation executed. Smoke evidence showed that this ordering was
technically correlated but operationally misleading. The final design moved
source/runtime/provider/persistence emission into the composition function via
an optional emitter so starts and completions align with real boundaries while
old callers remain unchanged.

The required temporary human workflow then exposed three diagnostic-only
integration defects that focused contract tests could not see: local-time
parsing inflated `Z`-timestamp durations, `source_run_count` was absent from
the narrow aggregate allowlist, and product deterministic identities contain
safe `|`-delimited components that the initial related-ID syntax rejected.
Exact offset normalization, one explicit aggregate key, and a bounded expanded
non-path identity alphabet fixed those issues. The same workflow also rejected
post-hoc artifact/Connect validation completion events with no start; validation
status now truthfully remains detail on the enclosing atomic build stage.

The requested word “redaction” was narrowed deliberately: structured details
reject prohibited/unknown keys and nested values rather than pretending an
arbitrary-object scrubber is safe. Console identity truncation is presentation
only; retained in-memory event objects preserve exact allowed identities.

#### Privacy and safety assessment

There is no per-patient emission. Aggregate counts and explicit provider,
runtime-run, product, artifact, materialization, and realization identities are
the only domain relationships admitted. Event text rejects common secret
assignments/private keys and raw exceptions are not copied automatically.
Generated diagnostics are ephemeral unless the invoking environment redirects
them, in which case that environment owns access and retention. These are
defense-in-depth controls, not a claim that arbitrary future messages or sinks
are privacy certified.

#### Validation evidence

The focused Phase 9 suite covers contract identity/version/common-envelope
conformance, explicit timestamp/offset normalization
and distinct context identity, ordered/correlated lifecycle, unique event IDs,
safe aggregate detail, prohibited keys/nesting/text/related identities, quiet
error visibility, event preservation independent of rendering, terminal
enforcement, sink-failure isolation, no persistent sink, and no RNG perturbation.
A real doctor run and
a temporary, explicitly identified reference platform run produced correlated
safe console lifecycles; the latter persisted the unchanged analytical record
families and completed normally. Full Phase 0–9, public-operation, package,
dependency, documentation, hygiene, sibling, and checkpoint results are added
after final validation below.

#### Architecture, plan, and Phase 9 status

The dependency spine did not change. Architecture now records the concrete
operations-owned callable sink and distinct context/event semantics. The Phase
9 plan and open decision record the bounded local realization as complete;
deployment-owned routing/retention remains unresolved by design rather than a
core gap.

**Phase 9 is complete for Iteration 9.1.** The current stable workflow is
traceable through a safe portable interface and console renderer without
claiming retained observability, metrics, audit, or production monitoring.

#### Implications and recommended next task

A later deployment may consume the same validated events through a separately
owned sink and explicit privacy/retention policy. Metrics should derive from a
separate metric contract, not by treating diagnostic text as a time-series
schema. Audit requirements need governed subjects, actions, access, integrity,
and retention of their own.

Proceed to Phase 10 only after choosing concrete adapter-independence evidence
with real value. Do not add a vendor sink, trace protocol, metrics backend,
audit store, or scheduler merely because the event interface now exists.

#### Final validation follow-up

The complete final matrix passed:

- `Rscript operations/validate-documentation.R`: **PASS**, 4 checks and zero
  issues;
- `Rscript operations/validate.R --mode development`: **PASS**, 99 checks and
  zero issues; the later strict checkpoint reran its full development subset
  after final diagnostic fixes;
- `Rscript operations/validate.R --mode checkpoint`: **PASS**, 159 checks and
  zero issues for completed Phase 9;
- focused suites reported 10, 14, 38, 24, 55, 18, 17, 8, 22, and 16 passing
  tests for Phases 0 through 9;
- the temporary human workflow initialized, ran doctor, persisted one normal
  six-episode fictional run, materialized the three-product set, rebuilt the
  artifact idempotently with the same identity, and generated a validated
  staged/uncommitted/remote-free Connect repository under `/tmp`;
- console inspection showed one operation-run correlation per command,
  aggregate stage events, bounded long-identity rendering, accurate duration,
  safe codes/recovery, and no patient-level values, secrets, environment dump,
  or raw payload;
- neither the repository nor the temporary workflow acquired a diagnostic
  `.log`, `.trace`, or `.ndjson` file; operational history contained only the
  normal platform-run records;
- all 72 maintained R files and 39 YAML files parsed;
- `renv::status()` reported no issues, with only offline repository-index
  warnings;
- `rrpruntime@0.3.0` built and passed `R CMD check --no-manual` with
  `Status: OK`;
- the sibling worktree remained unchanged, the clean repository had no
  generated tracked artifact, and `git diff --check` passed.

The exact human operations used `RENV_CONFIG_SANDBOX_ENABLED=FALSE` because the
managed environment blocked on renv's global sandbox lock. This did not alter
the project library, lockfile, command arguments, or checkpoint semantics. The
repeated implicit-snapshot dependency-discovery note remains a performance
observation rather than an integrity failure. No commit, push, remote,
publication, or deployment occurred.

## Phase 10 — Adapter independence

### Iteration 10.1 — Generic canonical-producer interface and adopter handoff foundation

#### Planned objective

Define the supported seam through which one configured health-system source
implementation supplies canonical data to one platform installation. Separate
declaration, trusted registration, installation selection, execution, and
admission; migrate the shipped synthetic implementation and stable run to that
seam; establish reusable conformance and safe diagnostics. Do not build the
independent adopter producer, multi-hospital semantics, dynamic loading, or
Phase 11 distribution machinery.

#### Pre-existing gap

The canonical handoff was already representation-neutral and validated, but
the adopter handoff was not executable. `run-platform.R` directly sourced five
synthetic files, and history composition called
`rrp_run_synthetic_reference()` by name. The Phase 3 result exposed source
objects and admitted canonical data inside reference-specific composition.
`--profile reference` was a per-run named gate rather than installation
composition.

#### Actual implementation

- Added `platform.canonical-producer@0.1.0` and
  `platform.canonical-producer-result@0.1.0` language-neutral semantics.
- Added declaration validation, a process-local trusted callable registry,
  duplicate rejection, exact resolution, generic execution, result validation,
  handoff identity/profile/capability/as-of checks, canonical admission,
  failure short-circuiting, and deterministic conformance.
- Added `reference.synthetic-canonical-producer@0.1.0`, adapting the existing
  source generation, local validation, and mapping behind a callable that
  removes source representation. Generic execution now owns admission.
- Added `config/platform-instance.yml` for exact single-producer selection and
  `operations/compositions/installed-producers.R` for the explicit trust
  association. YAML names no executable code.
- Refactored stable and lower-level synthetic-input operations onto the seam.
  Removed `--profile reference`; shipped `--scale` remains producer-owned
  reference configuration, not hospital selection.
- Added the public in-memory `platform.validate-producer` operation, registry
  entry, human procedure, agent mapping, focused Phase 10.1 suite, and
  repository/checkpoint validation.
- Extended existing safe diagnostics with producer/implementation/mapping/
  execution identities and resolution/execution/admission stages, with no
  persistent sink or source values.

#### Contract, result, trust, and selection decisions

Producer identity selects a trusted executable peer. Implementation identity
attributes the health-system/source context, while mapping identity attributes
interpretation; these remain distinct from canonical run/bundle, runtime run,
provider, persistence, product, operation-run, artifact, and deployment
identities. Declarations state exact profiles, explicit capabilities,
determinism, single-producer execution, configuration ownership, and prohibited
partial/fabricated output.

The callable returns producer-owned stage evidence and a candidate only after
local success. Generic execution validates the callable response, declaration
agreement, and existing canonical profile. The final result reports producer
configuration, source-local validation, mapping, and admission separately.
Any failure yields no bundle and prevents downstream execution.

The established provider trust discipline was adapted as an architectural
pattern: declarative data cannot execute code; maintained composition pairs a
declaration and callable; exact ID/version selection resolves only a registered
peer. Dynamic loading, arbitrary paths/packages, `eval(parse())`, remote code,
directory discovery, multi-producer execution, and hospital switching are
unsupported.

One versioned installation configuration selects one producer for one health-
system context. Source extraction configuration and secrets remain producer/
environment-owned below the seam. Final physical packaging of adopter code
remains open because this iteration provides no evidence favoring an in-tree
directory, private package, or companion repository.

#### Reference migration and downstream independence

Generator, source-schema, mapping, deterministic output, profile, identities,
and provenance behavior were preserved. Stable platform execution no longer
imports or invokes those pieces; it resolves the installed producer and passes
only the admitted bundle and existing provenance downstream. DuckDB continues
to store platform-created history independently of source technology. Runtime,
provider, history contracts, products, Shiny, artifacts, and Connect semantics
did not change.

#### Assets used, adapted, rejected, and new work

No additional sibling inspection was useful after clean design; Phase 3 had
already recorded the relevant old evidence. Existing clean Phase 3 behavior was
adapted behind the seam, and the clean Phase 4 registry informed the trust
pattern without moving producer logic into `rrpruntime`. Mixed pipelines,
string-to-function configuration, named source branching, executable YAML, and
automatic discovery were rejected. All new contract, code, configuration,
tests, operations, and documentation are repository-owned.

#### Surprises and deviations

- The producer seam belongs in operations/composition because it is pre-
  runtime orchestration; `rrpruntime` remains post-canonical and unchanged.
- A public producer-conformance operation was justified because humans and
  agents need the same proof before changing installation selection.
- The Phase 3 private result remains for focused implementation tests, but its
  generic adapter requests no internal admission; operational handoff uses the
  generic admission exclusively.
- Extending existing diagnostic allowlists/stages was sufficient; no new event
  contract, sink, configuration framework, or dependency was needed.

#### Validation evidence

The completed validation matrix reported:

- `Rscript --vanilla tests/run-phase10-tests.R`: **PASS**, 15 focused cases;
- `Rscript operations/validate-producer.R`: **PASS** for the exactly selected
  and registered producer;
- `Rscript operations/validate.R --mode development`: **PASS**, 113 checks and
  zero issues;
- `Rscript operations/validate.R --mode checkpoint`: **PASS**, 174 checks and
  zero issues for the Iteration 10.1 checkpoint;
- focused suites reported 10, 14, 38, 24, 55, 18, 17, 8, 22, 16, and 15
  passing tests for Phases 0 through 10;
- `Rscript operations/validate-documentation.R`: **PASS**, 4 checks and zero
  issues;
- a temporary generic run resolved and executed the configured producer,
  admitted six fictional episodes, executed the runtime/provider path, and
  persisted six states, requests, results, and accepted estimates;
- that retained history materialized and validated the unchanged three-product
  set and product-only Shiny app, built and validated an application artifact,
  then generated and independently validated a staged, uncommitted,
  remote-free Connect Cloud repository under `/tmp`;
- the unchanged Phase 3 suite passed all 24 cases, preserving reference
  generation, mapping, identity, determinism, and provenance behavior;
- `rrpruntime@0.3.0` built and passed `R CMD check --no-manual` with
  `Status: OK`;
- `renv::status()` reported no issues after offline repository-index warnings;
- all maintained R and YAML files parsed, the sibling worktree remained
  unchanged, no generated deployment state entered the clean repository, and
  `git diff --check` passed.

The exact renv-mediated operations used
`RENV_CONFIG_SANDBOX_ENABLED=FALSE` because the managed environment blocked
the global renv sandbox lock. Dependency discovery took about 30 seconds for
implicit snapshots; this remains a performance note, not an integrity failure.
No commit, push, remote, publication, or deployment occurred.

#### Architecture and plan effect

Architecture now records the concrete pre-runtime producer trust/selection
boundary and installation configuration. The Phase 10 plan is split:
Iteration 10.1 establishes the seam; Iteration 10.2 independently proves it.
No canonical clinical or downstream platform contract changed.

#### Implications for Iteration 10.2

Iteration 10.2 must independently build a materially different, realistic,
fully fictional adopter-side producer; avoid copying synthetic source shape;
register/select it through the same mechanism; pass the unchanged conformance
suite; and prove unchanged downstream behavior with isolated temporary state.
That evidence may inform adopter-code packaging, without multi-hospital
execution or named generic branches.

#### Phase 10 status

**IN PROGRESS.** Iteration 10.1 establishes and exercises the seam with the
shipped reference peer. Phase 10 is not complete until independent adopter-side
conformance proves it is not reference-shaped.

#### Recommended next task

Proceed to **Phase 10 / Iteration 10.2 — Independent adopter-side producer
conformance proof**. Do not begin Phase 11 distribution, add a second normal
reference health system, or settle extension packaging first.

### Iteration 10.2 — Independent adopter-side producer conformance proof

#### Planned objective

Attack the Iteration 10.1 producer seam from outside the shipped reference
shape. Build one materially different, deterministic, fully fictional adopter-
owned source implementation; register and select it alone through the exact
existing mechanism; run the unchanged shared conformance machinery; and prove
the same runtime/provider, isolated DuckDB, products, Shiny app, and reduced
artifact. Do not create a second shipped health system, multi-producer runtime,
dynamic loading, or Phase 11 packaging.

#### Fixture classification and location

The new material lives under `tests/phase10/fixtures/adopter-producer/`. It is
developer-facing conformance evidence, not the normal reference experience,
not a supported hospital profile, and not a scaffold to copy literally. The
default `config/platform-instance.yml` and installed composition remain
unchanged and register/select only
`reference.synthetic-canonical-producer@0.1.0`.

The isolated test composition supplies its own declaration, producer-local
source configuration, trusted callable association, and one exact platform-
instance selection. It registers only the adopter producer. Thus the proof
models replacement in another installation rather than coexistence or an
operator-facing hospital switch.

#### Materially different source representation

The source consists of two implementation-owned objects:

- `case_extract`, one denormalized discharge export containing a composite
  local case reference, opaque subject/stay tokens, local-offset admission,
  discharge, follow-up, extraction, and terminal times, and a local closure
  vocabulary; and
- `activity_feed`, a separately loaded longitudinal feed joined on the local
  case reference, with its own fact identity, local activity vocabulary,
  occurrence/load times, and finalization state.

It does not reproduce or rename the reference producer's patients,
encounters, discharges, risk scores, activity events, or outcomes. Mapping
requires a join, composite/local identifier normalization, local code
translation, explicit UTC normalization, terminal interpretation, and
availability filtering. All values are small, manually reviewable, fictional,
nonclinical, and unrelated to a vendor or real organization.

#### Independent identities

The proof uses independent, path-free logical identities:

- producer: `conformance.adopter-extract-canonical-producer@0.1.0`;
- implementation: `conformance.fictional-export-source@0.1.0`;
- source schema: `conformance.fictional-export-source-schema@0.1.0`; and
- mapping: `conformance.fictional-export-to-readmission-canonical@0.1.0`.

Producer execution identity remains invocation-owned. These identities remain
distinct from canonical bundle/run, runtime run, estimand/provider,
persistence, product, operation-run, artifact, and deployment identities.

#### Source-local validation and mapping

The adopter callable validates its own configuration and exact source schema,
then accumulates source-local issues for required/unknown objects and fields,
types/nullability, primary keys, case/feed relationships, controlled local
vocabularies, parseable timestamps, admission/discharge/follow-up ordering,
extract availability, terminal-state coherence, terminal windows, activity
windows, and occurrence/load ordering. Generic canonical validation knows none
of these raw fields.

Malformed source fails `source_local_validation`, leaves mapping and canonical
admission `not_run`, returns multiple structured issues, and exposes no
candidate or admitted bundle. Successful mapping targets the unchanged
`platform.readmission-initial-profile@0.1.0`: normalized discharge episodes
and translated episode events are available, while baseline risk is honestly
`unsupported` with no instance or fabricated rows.

#### Dual-time and capability evidence

One emergency-feed fact occurs before the normal canonical as-of but loads
after it. The early handoff excludes that fact and reports one aggregate future
source record excluded. A later as-of admits the same fact with its normalized
occurrence and availability times. Both bundles pass unchanged canonical
admission. This independently demonstrates that availability semantics belong
to the platform contract rather than the synthetic implementation.

The reference transparent provider requires only discharge capability and
declares baseline/events optional. It therefore executes successfully when the
adopter bundle declares baseline unsupported, using no fabricated input. No
generic runtime or provider code changed.

#### Same-seam trust, selection, execution, and conformance

The fixture uses `rrp_register_canonical_producer()`, exact
`rrp_resolve_canonical_producer()` selection,
`rrp_execute_canonical_producer()`, the generic structured result validator,
existing clinical admission, and
`rrp_conform_registered_canonical_producer()` without an adopter exception.
The shared conformance function passes for both the shipped reference and
adopter producer. Platform-instance configuration validation was factored into
a callable used by both default and test-owned configuration readers; its
one-context semantics did not change.

#### Isolated persistence and unchanged downstream proof

Two temporary compositions use separate DuckDB files:

- Composition A resolves the default shipped producer and reaches retained
  reference runtime/provider results, the three-product set, YAML
  materialization, and Shiny initialization.
- Composition B resolves only the adopter producer and reaches the same
  runtime, conditional-hazard estimand, transparent provider, unchanged DuckDB
  adapter, three-product contracts/builders, YAML adapter, and Shiny
  initialization, then builds and independently validates the same reduced
  application artifact.

The adopter artifact contains product-only application content. It contains no
fixture source objects/fields, producer declaration, source schema, validation,
mapping, source configuration, DuckDB history, or credentials. Numerical
estimates need not equal the reference composition; logical interface and
component compatibility are the proof.

#### Observability and negative architecture evidence

The adopter execution emits the existing producer resolution, execution, and
canonical-admission lifecycle using the unchanged diagnostic contract. Events
contain allowed producer/implementation/mapping/execution identities and
aggregate counts only. Tests reject raw object/field names, fictional record
values, paths, source payloads, and patient/episode identities in diagnostics.
No sink persists them.

Focused scans cover runtime, products, app, deployment, persistence, and
observability contracts for both synthetic and adopter raw names. Generic code
contains no adopter producer identity, filesystem location, local object,
field, vocabulary, hospital selector, or multi-tenant branch. The trusted test
composition is the only code allowed to know the fixture location.

#### Cross-combination matrix

| Source producer | Canonical profile | Runtime / estimand / provider | Persistence | Products / app |
|---|---|---|---|---|
| Shipped synthetic reference | Existing initial profile | Unchanged reference stack | DuckDB, isolated state A | Unchanged YAML products and Shiny app |
| Adopter conformance fixture | Same existing profile | Same unchanged reference stack | Same DuckDB adapter, isolated state B | Same products/app and reduced artifact |

This is component substitution between isolated one-context installations, not
concurrent multi-hospital operation.

#### Adopter packaging and scaffold findings

The proof shows the semantic handoff and explicit trusted installation
composition are sufficient when adopter-owned declaration, callable, source
configuration, and selection are supplied from a separate test-owned tree. It
does not establish that production hospitals should fork the core, place code
under `implementations/<hospital>`, use a private companion repository, ship an
R package, or use plugins. Those remain Phase 11/distribution decisions informed
by security, upgrade, acquisition, and support requirements.

Repeated structure is not yet stable enough to justify a committed scaffold.
The fixture contains source-shape-specific validation and mapping, while the
stable reusable skeleton is already the producer declaration, callable result,
explicit registration/selection, and conformance API. A future scaffold should
follow a supported packaging decision rather than copy fixture internals.

#### Assets used, adapted, rejected, and new work

No sibling inspection was useful or performed. The proof was designed from the
clean producer and canonical obligations specifically to avoid inherited
synthetic shape. Existing clean producer execution/conformance and all
downstream components were reused unchanged. The platform-instance validator
was extracted from the existing reader so both installation configurations use
one rule. All adopter schema/data/code/configuration/tests/documentation were
created cleanly in this repository.

Synthetic-shape renaming, second reference profile, second normal installed
producer, mixed history, source-aware persistence/products/app, executable
YAML, auto-discovery, plugins, persistent logs, and a packaging scaffold were
rejected.

#### Surprises and deviations

- The existing shared conformance function needed no adopter exception or
  contract change.
- The transparent provider already handled an unsupported optional baseline
  capability correctly, so no runtime/provider accommodation was necessary.
- `rrp_run_reference_history()` already accepts a resolved producer result;
  despite its historical reference name, the executable composition required
  no alternate run path.
- A test-owned explicit composition answered the packaging question far enough
  for this phase without creating public dynamic extension machinery.
- Connect realization was unnecessary to establish source replacement because
  the independently validated reduced artifact already proves the source code
  stops upstream of deployment packaging.

#### Validation evidence

The completed evidence was:

- `Rscript --vanilla tests/run-phase10-tests.R` passed all 26 focused cases,
  including the unchanged shared conformance function for both producers,
  malformed-source short circuiting, dual-time behavior, safe lifecycle
  diagnostics, the two isolated downstream compositions, adopter artifact
  validation, and source-specific negative scans that include generic
  canonical code and every downstream layer;
- the two compositions used different temporary DuckDB files and independently
  reached the unchanged runtime, estimand, provider, persistence adapter,
  products, YAML materialization, and app; the adopter composition additionally
  built and validated the reduced artifact;
- `Rscript operations/validate-documentation.R` passed 4 checks with 0 issues;
- `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript operations/validate.R --mode
  development` passed 124 checks with 0 issues;
- `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript operations/validate.R --mode
  checkpoint` passed 185 checks with 0 issues, including Phase 0–10 suites of
  10, 14, 38, 24, 55, 18, 17, 8, 22, 16, and 26 tests respectively;
- `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript
  operations/validate-producer.R` passed the normal installed
  `reference.synthetic-canonical-producer@0.1.0`, confirming the stable human
  operation and default selection remained unchanged;
- `rrpruntime@0.3.0` built and passed `R CMD check --no-manual` with
  `Status: OK`;
- `renv::status()` reported no issues after expected offline repository-index
  warnings;
- all 130 maintained R files and 55 YAML files parsed successfully;
- `git diff --check` passed, the sibling worktree remained unchanged, and no
  generated database, archive, or log entered the repository.

The renv-mediated operations used `RENV_CONFIG_SANDBOX_ENABLED=FALSE` because
the managed environment blocks the global renv sandbox lock. Implicit snapshot
dependency discovery remained slow (approximately 26–44 seconds) but was only
an advisory performance note. No commit, push, remote creation, publication,
or deployment occurred.

#### Original Phase 10 exit-criteria assessment

- **No named branch:** replacement uses no named hospital, source, storage, or
  target conditional in generic code.
- **Reference remains a peer:** the unchanged shipped declaration, default
  selection, conformance, stable workflow, and downstream composition pass.
- **Missing capability is explicit:** baseline risk is unsupported, has no
  domain instance, and downstream behavior remains valid.
- **Unrelated components do not change:** runtime package, estimand, provider,
  persistence contract/adapter, product contracts/builders/materializer, app,
  artifact contract/builder, and deployment target are unchanged.

The independent evidence satisfies the original objective: a reference
component can be replaced through architecture rather than a named exception.
No Iteration 10.3 gap remains.

#### Architecture and plan effect

Architecture and plan now record the independent substitution proof and close
Phase 10. Canonical producer, canonical clinical, runtime, provider,
persistence, product, app, artifact, and observability contract versions remain
unchanged. Final adopter-code distribution remains open for Phase 11.

#### Phase 10 status

**COMPLETE.** Iteration 10.1 established the seam; Iteration 10.2 independently
proved it with a materially different adopter-owned source and unchanged
downstream platform.

#### Recommended next task

Proceed to **Phase 11 — Distribution and open-source governance**, beginning
with explicit maintainer decisions for licensing, supported acquisition and
release forms, extension packaging, support/security policy, and the tested
R/OS matrix. Do not infer those decisions from the test-fixture layout.

## Phase 11 — Distribution and open-source governance

### Iteration 11.1 — Distribution and release decision assessment

#### Objective and authority boundary

Identify the smallest coherent set of maintainer decisions required before the
first supported packaged platform release, compare serious options against the
implemented Phase 0–10 architecture, recommend a consistent model, distinguish
release blockers from deferrable enhancements, and propose the remaining Phase
11 work. This iteration is assessment only. Recommendations are not accepted
architecture decisions, a license grant, support promise, release
authorization, or implementation of release machinery.

#### Repository evidence reviewed

The assessment reviewed True North, architecture, plan, open decisions, the
complete Phase 10 record, canonical producer and adopter handoff, reduced
artifact and observability foundations, progressive adoption, operator and
artifact/Connect procedures, the operation registry, installation selection,
producer/deployment contracts, reference implementations, repository layout,
license placeholder, package metadata, `renv.lock`, direct artifact
dependencies, README/navigation, and agent guidance.

The decisive current-state evidence was:

- the full source tree is a platform of contracts, operations, an internal
  package, adapters, products, app, and deployment builders rather than one R
  package;
- the locked project environment and smaller reduced-artifact dependency
  declaration serve different purposes;
- all generated clinical-like data, history, products, artifacts, and target
  repositories are reproducible ignored state rather than source release
  payload;
- Phase 10 proves source substitution and explicit trusted composition, but
  normal production packaging of private adopter code remains unimplemented;
- one installation still means one health system and one exact selected
  producer;
- Connect generation intentionally stops before commit, remote, push, sharing,
  or deployment; and
- no license, public release, CI support matrix, upgrade, security-reporting,
  contribution, or support policy currently exists.

The sibling repository was not inspected because this decision assessment is
governed by the clean repository's current release surfaces and by current
external license/tool/service behavior. Sibling evidence was **not relevant**;
no sibling asset, idea, code, prose, or configuration was used.

#### External evidence reviewed

Current primary documentation was consulted on 2026-08-20 from OSI, Apache,
GNU, SPDX, Semantic Versioning, GitHub, the Linux Foundation DCO guidance,
renv, the R Project, Posit Connect Cloud, and the Open Container Initiative.
It informed:

- MIT, Apache-2.0, and GPL rights/obligations plus Apache/GPL compatibility
  caution;
- tag-backed GitHub releases, automatic archive limitations, signed tags,
  immutable releases, security advisories, contribution/community files, and
  `CITATION.cff`;
- lockfile restore behavior and renv's explicit inability to provide R, OS,
  compiler, or system-library reproducibility;
- current R 4.6.1 availability versus this repository's R 4.4.1 lock;
- Connect Cloud's Git/branch/primary-file/`manifest.json` publication model;
  and
- OCI as the vendor-neutral future image/runtime/distribution concept.

Each source, access date, and informed decision is recorded in
`docs/architecture/distribution-release-assessment.md`. Generic practice was
not allowed to override repository-specific boundaries.

#### Decision areas and recommendations

The assessment consolidated the requested questions into twelve material
areas rather than dozens of minor choices:

1. license, ownership, attribution, assets, stewardship, and brand;
2. acquisition, whole-platform release form, and GitHub's role;
3. platform versioning and independently versioned component relationships;
4. R/renv and tested-versus-supported OS policy;
5. physical adopter producer packaging;
6. private configuration, secret ownership, and trusted loading;
7. Connect/OCI roles and generated-deployment ownership;
8. contribution governance;
9. security disclosure and support;
10. release integrity and source provenance;
11. release documentation and citation; and
12. early compatibility, upgrades, and migration limits.

The recommended coherent model, pending maintainer approval, is a
CentralStatz-stewarded public GitHub project; Apache-2.0 repository-authored
content after legal/dependency/asset review; whole-tree immutable `v0.1.0`
source release with signed tag, attached archive, checksum, and exact release
inventory; archive or exact-tag clone; one supported current R minor line plus
committed `renv.lock`; a private adopter companion implementation pinned to
the platform release and loaded only by explicit trusted composition;
environment-owned secrets; best-effort community support plus separately
available professional services; Connect as a fictional/reference realization;
operator-owned publication; and future OCI as a peer consumer of the unchanged
reduced artifact.

The assessment ranks MIT as the strong lower-burden license alternative and a
controlled hospital fork as the strongest adopter-packaging fallback. It does
not conclude that Apache-2.0 dependency compatibility, CentralStatz ownership,
the companion repository mechanism, the R/OS matrix, or any support capacity
is already approved or proven.

#### Maintainer choices still required

Seven grouped decisions require explicit human approval before Iteration 11.2:

1. actual copyright holder, steward/release publisher, maintainers, and brand
   owner;
2. software/documentation/asset license treatment after appropriate review;
3. first platform version and `0.x` compatibility promise;
4. GitHub and clone/archive roles in authoritative acquisition;
5. companion versus fork/package/local physical adopter implementation model;
6. supportable R/OS/CI matrix; and
7. contribution, security-reporting, conduct, support, and optional services
   posture.

Each is stated as a question with recommendation, alternatives, commitment,
and reversibility in the assessment. No choice was silently resolved in True
North, architecture, plan, or open decisions.

#### Decisions deliberately deferred

The assessment explicitly defers the exact OCI/Docker implementation, plugin
ecosystem, mandatory private R-package extensions, full-platform R package,
general installer, multiple R release lines/broad Linux support, formal paid
support/SLA, CLA/foundation governance, custom SBOM/attestation infrastructure,
speculative migrations, rendered website/manual stack, and any multi-hospital
or centralized-SaaS model. It names evidence that would justify revisiting each
and confirms that current boundaries preserve the useful options.

#### First-release readiness

Release blockers are human legal/ownership decisions; release identity and
compatibility approval; an approved, externally supplied adopter composition
proof; an evidence-backed R/OS matrix; license/contribution/security/support/
compatibility policy files; clean archive and exact-tag acquisition validation;
and exact release metadata/integrity. Citation metadata, issue/PR templates,
system-dependency guidance, a complete fictional companion walkthrough, and a
manual release checklist are recommended before release. OCI, installers,
richer tutorials/site output, wider matrices, package extensions, formal
migrations, and new platform capabilities are post-release enhancements rather
than blockers.

#### Recommended remaining Phase 11 structure

- **Iteration 11.2 — accepted distribution and governance foundation:** after
  maintainer decisions, install the approved license/policies/version metadata,
  prove the approved adopter packaging model, establish the environment matrix
  and required CI, and assemble an unpublished release candidate.
- **Iteration 11.3 — release-candidate validation and first packaged version:**
  validate clone/archive acquisition and the supported lifecycle in clean
  claimed environments, verify release metadata/integrity, and present the
  exact candidate for explicit human authorization. Publish `v0.1.0` only when
  authorized; no deployment occurs.

#### Files created and changed

Created `docs/architecture/distribution-release-assessment.md`. Updated the
root README, documentation index, and START HERE only to expose the assessment
and accurately state that Phase 11 is in progress. Updated agent guidance to
preserve the non-authoritative boundary, and made documentation validation
require the new maintained assessment and its governing links. Appended this
implementation record. No contract, operation, dependency, lockfile, runtime,
provider, persistence, product, app, artifact, or target behavior changed.

#### Validation evidence

The final validation matrix reported:

- `Rscript --vanilla operations/validate-documentation.R`: PASS (4 checks,
  0 issues), covering 36 required documents, 242 repository-local links, 24
  maintained navigation sources, and portable document paths;
- `Rscript --vanilla tests/run-phase0-tests.R`: PASS (10 tests);
- `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript operations/validate.R --mode
  checkpoint`: PASS (185 checks, 0 issues), including the final documentation
  counts and Phase 0 through Phase 10 suites;
- `Rscript --vanilla tests/run-phase8-tests.R`: PASS (22 tests), and
  `Rscript --vanilla tests/run-phase9-tests.R`: PASS (16 tests), rerun after a
  concurrent development-validation attempt encountered transient package
  metadata access failures while stale orphaned R workers were being removed;
- `renv::status()`: no issues found and the project is consistent, after
  expected offline repository-index warnings and dependency-discovery timing;
- parse checks: 130 maintained R files and 55 maintained YAML files parsed;
- `git diff --check`: PASS; and
- sibling status and scans for generated DuckDB, archive, and log state were
  clean.

The first final-tree development-mode attempt reported 122 of 124 checks as
passing; only Phase 8 and Phase 9 subprocesses failed during the transient
package-library contention described above. Both suites then passed in
isolation, and the final checkpoint reran the complete development matrix plus
checkpoint checks successfully. No contract or dependency changed to obtain
the pass. No commit, tag, push, release, publication, or deployment was
performed.

#### Phase 11 status

**IN PROGRESS.** Iteration 11.1 is complete as decision support only. Phase 11
cannot implement or publish a release until the maintainer accepts or replaces
the required recommendations.

#### Recommended next task

Obtain explicit maintainer answers to the seven decisions in the assessment.
Then scope Iteration 11.2 from those answers; do not install the recommended
license, companion model, support matrix, governance terms, or release identity
merely because this assessment ranks them first.

### Iteration 11.2 — Hospital-facing distribution and managed platform composition assessment

#### Objective and scope boundary

Determine whether a separately versioned generic hospital-facing distribution
should carry an exact immutable platform release as a managed dependency, and
specify ownership, environment, operation, producer-trust, lifecycle, upgrade,
maintenance, security, and deployment behavior precisely enough for a bounded
implementation proof. Baseline the maintainer decisions made after Iteration
11.1 without reopening them absent contradictory repository evidence.

This was architecture and decision baselining only. It did not create a
hospital-facing repository or release, embed or generate a platform archive,
install a license, tag or publish `v0.1.0`, add CI/release automation, implement
download/update/package/container behavior, or change platform contracts and
runtime behavior.

#### Evidence inspected

The assessment read and reconciled:

- Platform True North, architecture, implementation plan, open decisions,
  reference-asset reconciliation, the complete implementation record, and
  agent guidance;
- the Iteration 11.1 distribution/release assessment and its dependency,
  environment, acquisition, license, governance, integrity, and adopter-
  packaging evidence;
- the operator manual, operation registry, initialization and doctor entry
  points, repository-root/path behavior, `renv` activation/settings/lock
  ownership, and current generated-state conventions;
- platform-instance configuration, installed producer composition, producer
  validation/execution APIs, stable platform run, and the Phase 10 independent
  adopter composition/proof;
- operational-history, product/materialization, Shiny, target-neutral artifact,
  Connect realization, observability, and progressive adoption boundaries; and
- the actual repository tree and separation between repository-scale platform
  operation and the internal `rrpruntime` package.

The sibling repository was not inspected. The open question concerns physical
composition of interfaces already proven in the clean repository; old source
layout could not supply authoritative evidence and was not relevant. No sibling
asset, code, prose, configuration, identity, or dependency was used.

#### Maintainer decisions baselined

The iteration records these accepted directions:

1. first platform release `v0.1.0`;
2. the validated whole repository source tree as the `v0.1.0` platform release
   unit, without making that a permanent requirement for all future releases;
3. GitHub as public source/release authority with immutable tags, GitHub
   Releases, and archive acquisition;
4. a shipped platform `renv.lock` and `renv::restore()` as the standard
   declared environment construction path, without requiring Docker;
5. the existing explicit trusted producer composition, with no executable
   YAML, path/function loading, discovery, or multi-hospital switching;
6. secrets external to committed platform and adopter source;
7. Connect Cloud as reference/tutorial realization only, external publication
   operator-owned, the reduced artifact still target-neutral, and OCI deferred
   as a future peer;
8. CentralStatz Statistical & Data Sciences LLC as project steward/release
   publisher and Alex Zajichek as initial maintainer;
9. Apache-2.0 direction after final dependency/asset/license compatibility
   review, with MIT fallback for a genuine unresolved incompatibility;
10. lightweight contribution guidance, DCO, no CLA, and no copyright
    assignment;
11. best-effort open-source support without SLA or response/resolution
    guarantee, GitHub issues, and optional separate CentralStatz services;
12. normal open-source security governance and operator responsibility for
    deployment, credentials, access, PHI, and local configuration; and
13. normal Git/GitHub release integrity without speculative custom signing,
    SBOM, attestation, or supply-chain infrastructure.

The exact tested R/OS matrix remains an evidence question rather than a broad
support promise. The license remains uninstalled pending the final review, and
publication remains unauthorized.

#### Alternatives considered

Six serious physical models were compared for adopter usability,
reproducibility, provenance, upgrades, hospital-code separation, offline
installation, Git burden, security/trust, `renv`, stable operations, Phase 10
composition, future releases/OCI, CentralStatz maintenance, and refactoring:

1. direct hospital customization/fork of the platform;
2. side-by-side exact platform and private companion repositories;
3. Git submodule/subtree composition;
4. managed embedded immutable platform release archive;
5. explicit exact-version platform download during bootstrap; and
6. conversion of the repository-scale platform into an R package.

The managed embedded archive ranks first. Side-by-side composition is the
strongest advanced/fallback option. Explicit retrieval could later populate
the same managed boundary but is weaker for restricted/offline institutions.
A controlled fork remains a fallback, submodule/subtree makes Git mechanics an
operator burden, and full-package conversion requires unjustified major
refactoring.

#### Selected recommendation

The three-level model is accepted with a refined physical design:

- **Level 1:** the independently versioned and released Readmission Risk Pool
  Platform;
- **Level 2:** a separately versioned **Readmission Risk Pool Hospital
  Implementation Kit**, not another platform; and
- **Level 3:** one hospital's private implementation project created from the
  kit.

An official kit release physically carries exactly one official platform
release archive with identity, version, compatibility, inventory, byte size,
and SHA-256 metadata. Initialization verifies safe paths/content and extracts
it to staged, ignored, versioned managed local state, validates the extracted
platform, and promotes it only when complete. Modifications remain possible
because the source is open, but they are detectable and outside the normal
supported workflow. No silent network retrieval is part of initialization.

The kit uses a partly maintained, partly generated model. Its source project
maintains hospital-facing wrappers, scaffold, ownership metadata, environment
baseline, and guidance. Release construction injects the exact Level-1 archive.
No platform logic is manually copied or synchronized in Level 2.

#### Environment decision

The private top-level project owns the only active `renv` environment and
authoritative complete lock. The managed platform retains its unchanged lock
for release provenance and independent Level-1 use, but hospital operations do
not activate or restore a nested platform project. The kit baseline is derived
from the exact platform lock plus kit dependencies; the hospital deliberately
adds producer dependencies to its private top-level lock without silently
changing platform package versions.

A future upgrade builds and restores a candidate environment separately. A
dependency conflict fails before platform selection changes. No dependency
merger or alternate package manager was implemented or authorized.

#### Operation and producer composition decision

The kit will expose thin top-level scripts for initialize, doctor, fictional
acceptance, implementation/producer validation, run, history inspection,
product materialization, app validation/launch, artifact build/validation, and
supported target realization. These wrappers delegate to Level-1 callable
operations; they do not copy domain logic or turn the operation registry into
an execution framework.

The smallest necessary Level-1 addition is a callable operation-composition
seam accepting an already constructed trusted registry/selection and explicit
state paths. It must never accept a configuration-supplied executable path,
function, package, URL, or expression. Existing Level-1 scripts will use the
same functions with the shipped composition.

The private project owns one complete top-level `config/platform-instance.yml`,
one producer declaration, source/mapping/callable implementation, producer-
owned nonsecret configuration, and fixed reviewed composition code. The
composition explicitly sources a maintained file list and registers exactly
one callable; YAML only selects its exact ID/version. The embedded platform
configuration remains unchanged for isolated synthetic acceptance. Normal
hospital execution uses the top-level selection and separate hospital state.

Producer conformance is an explicit gate before normal operation. Every normal
run still validates declaration, registration, selection, structured result,
and canonical admission. Whether the first implementation reruns the complete
controlled scenario per operation or uses a bounded non-PHI conformance receipt
remains evidence for the proof.

#### Lifecycle and upgrade decision

The intended lifecycle is one kit acquisition, one top-level environment
restore, verified managed-platform initialization, isolated fictional reference
acceptance, hospital implementation, producer conformance, exact selection,
normal unchanged downstream operation, target-neutral artifact construction,
and operator-selected realization/publication.

An upgrade stages a new platform and candidate R library beside the current
installation, preserves adopter-owned files and operational history, reruns
reference acceptance, producer conformance, checkpoint, and applicable state/
product/artifact compatibility, and switches only with explicit operator
acceptance. Incompatibility leaves the prior installation usable and reports
manual changes without silently editing hospital code. No updater or migration
tool was implemented.

#### Deployment, security, and privacy effects

The kit ends upstream of the unchanged target-neutral reduced application
artifact. Connect remains a reference peer and future OCI/container realization
can consume the same artifact. Installation composition does not bake Connect
into source, producer, runtime, products, or application behavior.

Public platform/kit releases contain no PHI, credentials, connections, private
mappings, or hospital configuration. The private hospital project owns those
implementation details under local policy while secrets remain external.
Archive verification, safe extraction, fixed trusted composition, isolated
fictional state, allowlisted artifacts, and privacy-safe diagnostics are
required boundaries; checksums are integrity evidence, not signing or a
sandbox.

#### Rejected and deferred work

Rejected as the primary model: permanent hospital fork, ad hoc two-root paths,
Git submodule/subtree, executable configuration, directory/plugin discovery,
and full-platform R-package conversion.

Deferred: online retrieval, automatic updater, package-based producer
distribution, final repository/path names, OCI realization, multiple active
platform versions, generic plugin ecosystem, dependency solver, exact
ownership merge tool, formal migration framework, final R/OS matrix, license
installation, and all release/publication automation.

#### Unresolved questions

The architecture document records ten bounded questions for implementation
evidence: final kit/repository and path names, kit manifest identity/version,
platform archive provenance form, minimal callable Level-1 operation API,
wrapper filenames/surface, top-level lock construction/conflict checks,
conformance receipt versus per-run conformance, ownership-manifest upgrade
behavior, tested R/OS matrix, and final Apache-2.0 compatibility review.

#### Architecture and plan effects

Added the authoritative hospital-distribution document and summarized its
Level-1/2/3, archive, environment, operation, and trust boundaries in Platform
Architecture. Updated the Phase 11 plan to mark Iterations 11.1 and 11.2
complete as assessment/architecture, name the managed composition proof as
11.3, and leave later kit/release work explicit. Updated open decisions,
progressive adoption, the operator manual, navigation, README status, and agent
guidance. Reclassified the 11.1 assessment as historical decision support where
superseded.

No machine-readable contract, runtime code, operation command, operation
registry entry, configuration, dependency, lockfile, application, artifact,
target realization, or generated state changed.

#### Reference assets and clean work

No sibling review or asset use occurred because clean Phase 8–10 interfaces and
actual operations supplied the relevant evidence. The managed distribution
architecture, alternatives analysis, environment/operation ownership,
composition flow, lifecycle, and implementation sequence are new clean work.

#### Validation evidence

The final validation matrix reported:

- `Rscript --vanilla operations/validate-documentation.R`: PASS (4 checks,
  0 issues), covering 37 required governing documents, 259 repository-local
  links, 25 maintained navigation sources, and portable document paths;
- `Rscript --vanilla tests/run-phase8-tests.R`: PASS (22 tests);
- `Rscript --vanilla tests/run-phase9-tests.R`: PASS (16 tests);
- `Rscript --vanilla tests/run-phase10-tests.R`: PASS (26 tests);
- `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript operations/validate.R --mode
  development`: PASS (124 checks, 0 issues);
- `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript operations/validate.R --mode
  checkpoint`: PASS (185 checks, 0 issues), including Phase 0 through Phase 10
  focused suites and final documentation counts; and
- `git diff --check`: PASS.

The full operations emitted only expected informational renv dependency-
discovery timing notes. Final scans found no generated DuckDB database, product
bundle, deployment repository, release archive, hospital implementation, or
log state. The sibling worktree remained untouched. No dependency, lockfile,
contract, operation command, or configuration changed. No commit, tag, remote,
push, release, publication, or deployment was performed.

#### Phase 11 status

**IN PROGRESS.** Iteration 11.2 resolves the hospital-facing composition
architecture and baselines accepted maintainer direction. It does not implement
the kit or close the license, environment, governance-file, release-candidate,
or publication evidence required to complete Phase 11.

#### Recommended next task

Implement **Iteration 11.3 — managed composition proof** exactly as scoped in
the hospital-distribution architecture: a minimal callable Level-1 operation
seam plus a temporary external-tree, integrity-checked platform archive and
fictional adopter composition proof. Do not create or publish the production
kit repository or release in that iteration.

### Iteration 11.3 — Generated hospital-facing distribution architecture revision

#### Objective and scope boundary

Correct the Iteration 11.2 physical-maintenance model so CentralStatz maintains
only `readmission-risk-pool-platform` while producing two independently
versioned release products: the reusable Platform release and a generated
Readmission Risk Pool Hospital Implementation release. Remove a recipient's
post-download customization from the formal CentralStatz release architecture,
retain the sound embedded-release/environment/trust conclusions, and define the
smallest next implementation proof.

This was planning and documentation only. It did not add hospital-distribution
source, builder/validator code, a contract, a generated tree, a standalone Git
realization, a release archive, license, CI, release automation, Docker/OCI,
tag, commit, remote, push, publication, or deployment. It did not change
runtime behavior, dependencies, lockfiles, contracts, configuration, or the
operation registry.

#### Evidence inspected

The revision reconciled:

- True North, Platform Architecture, the implementation plan, open decisions,
  the full historical implementation record, and current agent guidance;
- both the retained Iteration 11.1 release assessment and the authoritative
  Iteration 11.2 hospital-facing composition assessment;
- Phase 10 producer declaration, trusted registry/selection, conformance, and
  independent adopter evidence;
- current one-root `renv` ownership and dependency restoration behavior;
- the stable human operation surface and progressive-adoption guidance;
- the target-neutral reduced application artifact and generated Connect Git
  realization, whose artifact-then-realization separation provides useful
  architectural precedent; and
- the repository's actual generated-state, release, and publication boundaries.

The sibling repository was not inspected. This correction concerns ownership
of future generated releases from the clean repository; old implementation
evidence was neither necessary nor authoritative. No sibling asset was used.

#### Architectural correction

Iteration 11.2 remains historical evidence of what was decided at that time.
Its selected physical interpretation was:

```text
Level 1 Platform
        ↓
separately maintained Level 2 Hospital Implementation Kit
        ↓
Level 3 hospital-private implementation project
```

Iteration 11.3 supersedes only that maintenance/layering interpretation with:

```text
one authoritative maintained repository
        ├── independently versioned Platform release
        └── independently versioned generated Hospital Implementation release
                ↓ optional later standalone Git realization
                ↓ recipient acquisition and unrestricted licensed customization
```

There is no second manually maintained CentralStatz source project. There is no
formal third CentralStatz product or release layer. Recipient modification is
real adopter activity outside the release boundary, not something CentralStatz
must model, merge, preserve, or technically prevent.

#### Decisions retained from Iterations 11.1 and 11.2

The revision found no incompatibility with the accepted first Platform release
identity `v0.1.0`, whole-tree initial release unit, GitHub source/tag/release
authority, shipped lock and `renv::restore()`, explicit trusted producer
composition, CentralStatz stewardship, conditional Apache-2.0 direction with
MIT fallback, DCO/no CLA, best-effort support/no SLA, normal security and
release-integrity governance, Connect as reference only, external deployment
ownership, OCI as a future peer, and no speculative migration framework.

The strongest Iteration 11.2 physical conclusion is also retained: an official
Hospital Implementation distribution carries one exact Platform release
archive with Platform identity/version, archive identity, SHA-256 integrity,
compatibility, and inventory/provenance. Initialization may extract that source
into managed local state. Integrity validation describes whether the local copy
still matches the released baseline; it is not a security boundary and does
not prevent recipient modification.

#### Selected maintenance and terminology model

The durable product concept is **Readmission Risk Pool Hospital
Implementation**. “Distribution” describes the generated release form; “kit”
is no longer the primary noun because it suggested a separately maintained
project. Final repository/archive filenames remain an implementation detail.

All hospital-facing templates, wrappers, documentation source, metadata logic,
builder/validator source, conformance evidence, and tests belong in this
authoritative repository. The preferred future conceptual ownership area is
`distribution/hospital/`, with exact layout deferred to implementation. The
directory was not created. Generated trees under ignored `build/` state and
standalone Git realizations are outputs, never maintained source.

#### Release graph and identities

Platform and Hospital Implementation are independent release products and do
not need matching versions. Each Hospital Implementation release declares its
own identity/version plus the included exact Platform identity/version/archive
digest, compatibility, builder identity/version, direct environment metadata,
and generated inventory. These identities remain distinct from runtime runs,
product sets, application artifacts, target realizations, and incidental Git
commit identities.

The first implementation may choose equal version numbers for convenience,
but equality is not a compatibility rule. A later Hospital Implementation
release may carry the same Platform with wrapper/documentation changes, or a
newer exact Platform release with explicit compatibility evidence.

#### Generated artifact and later Git realization

The selected construction boundary has two separate future stages:

```text
authoritative repository
        ↓ build immutable Hospital Implementation artifact
        ↓ independently validate artifact
        ↓ later realize artifact at an explicit destination
        ↓ independently validate remote-free staged Git repository
        ↓ optional separately authorized publication
```

Iteration 11.4 should implement only the artifact and its independent
validator. A later operation may consume only a validated artifact to create a
self-contained, remote-free, staged-but-uncommitted Git repository. Neither
generated output becomes source authority, and no operation may silently add a
remote, commit, push, or publish.

#### Environment ownership

The generated Hospital Implementation root owns the one routinely active
`renv` environment. Its deterministic baseline lock is derived from the exact
Platform lock plus only maintained wrapper dependencies and is validated as a
coherent whole. The embedded Platform lock remains release provenance; routine
use does not activate a nested project. Recipient-added dependencies are
permitted but fall outside CentralStatz's exact released-baseline guarantee.
No dependency solver or arbitrary environment merge is introduced.

#### Producer composition and operations

The generated baseline preserves `platform.canonical-producer@0.1.0`:
declaration and callable scaffolds are separate, trusted maintained R code
performs explicit registration, one complete platform-instance document makes
one exact selection, and conformance validates the result before canonical
admission. YAML never names executable code, generic Platform code never knows
hospital names, and plugin/path/function discovery remains prohibited.

Generated thin operations will conceptually cover initialization, doctor,
fictional reference acceptance, producer validation, platform execution,
history inspection, product materialization, app validation/launch, reduced
artifact build/validation, and target realization build/validation. They must
delegate to callable Platform behavior and contain no copied domain logic.
Exact wrapper filenames remain Iteration 11.4 implementation detail.

The embedded Platform's shipped fictional reference configuration remains
unchanged and runs in isolated state. A separate fictional adopter example
will prove the generated scaffold, while normal adopter execution fails clearly
until conforming producer code is supplied. The same unchanged downstream
runtime, history, products, app, reduced target-neutral artifact, and deployment
realizations remain reachable.

#### Validation responsibility and release boundary

CentralStatz validates that its generated distribution is reproducible and
self-contained; embeds exactly the declared Platform archive; has matching
identity, digest, inventory, compatibility, and environment metadata; exposes
the documented wrappers and trust seam; passes isolated fictional reference and
adopter conformance evidence; reaches unchanged downstream behavior; contains
no development-only working-tree assumptions; and contains no PHI, real patient
data, credentials, connection strings, hospital mappings/source configuration,
private hospital code, operational history, products from real data, or
hospital-specific deployment state.

CentralStatz's architecture responsibility ends at that generated, validated,
versioned release and any separately authorized publication of it. Recipients
may edit, restructure, privately version, or replace distributed content under
the applicable license. Such changes may no longer match validated release
assumptions. Future guidance may help reconciliation, but automatic migration
or preservation of arbitrary recipient changes is not promised for `v0.1.0`.

#### Alternatives and consequences

Rejected as the maintained model: a second CentralStatz kit repository, manual
source synchronization, a formal CentralStatz-governed hospital-private layer,
separate normal acquisition of Platform and kit, submodules, executable YAML,
automatic plugins, and a full Platform fork as the recommended baseline.

Deferred: exact generated layout and wrapper filenames, formal manifest schema,
lock derivation mechanics, conformance receipt form, immutable build naming,
standalone Git realization, migration tools, package-based extensions, tested
R/OS matrix, final license installation, release candidates, and publication.

The simplification reduces maintenance and upgrade promises without weakening
the Phase 10 trust boundary, one-health-system scope, inspectability, offline
acquisition, or deployment neutrality. It requires no upstream contract or
runtime redesign.

#### Architecture, plan, and guidance effects

Replaced the selected model in the authoritative hospital-distribution
architecture and summarized it in Platform Architecture. Updated the Phase 11
sequence, open-decision register, progressive-adoption guide, operator-manual
future-state note, README/status, documentation navigation, and `AGENTS.md`.
The retained Iteration 11.1 assessment now points to the 11.3 correction while
remaining historical decision evidence. The Iteration 11.2 record above is
unchanged and this entry appends the correction explicitly.

No machine-readable specification, dependency, lockfile, runtime source,
operation, registry, configuration, application, artifact, deployment target,
license, or generated state changed.

#### Validation evidence

The final validation matrix reported:

- `Rscript --vanilla operations/validate-documentation.R`: PASS (4 checks,
  0 issues), covering 37 required governing documents, 259 repository-local
  links, 25 maintained navigation sources, and portable document paths;
- `Rscript --vanilla tests/run-phase8-tests.R`: PASS (22 tests);
- `Rscript --vanilla tests/run-phase9-tests.R`: PASS (16 tests);
- `Rscript --vanilla tests/run-phase10-tests.R`: PASS (26 tests);
- `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript --vanilla
  operations/validate.R --mode development`: PASS (124 checks, 0 issues);
- `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript --vanilla
  operations/validate.R --mode checkpoint`: PASS (185 checks, 0 issues),
  including Phase 0 through Phase 10 suites;
- independent parse validation: PASS for 131 maintained R files and 55
  maintained YAML files;
- `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript --vanilla -e
  'renv::status()'`: exit 0, “No issues found — the project is in a consistent
  state”; restricted-network CRAN index lookup warnings and the expected
  dependency-discovery timing note did not change that local consistency
  result; and
- `git diff --check`: PASS.

The ignored `build/` directory remained empty. Final scans found no generated
Hospital Implementation tree, release archive, deployment repository, nested
Git repository, DuckDB database, product bundle, or log. The only matching
archive below the repository was the expected installed `renv` package-cache
source tarball, not release state. The sibling worktree remained clean and was
not modified. No dependency, lockfile, contract, executable operation, or
configuration changed. No commit, tag, remote, push, release, publication, or
deployment was performed.

#### Phase 11 status

**IN PROGRESS.** Iteration 11.3 establishes corrected architecture only. No
hospital-distribution builder, generated release, standalone repository,
license, release candidate, tag, CI, publication, or deployment exists.

#### Recommended next task

Implement **Iteration 11.4 — generated Hospital Implementation distribution
build/validation proof**. Add the smallest maintained hospital-facing inputs,
versioned manifest, immutable ignored artifact builder, deterministic top-level
environment baseline, thin wrappers, explicit producer composition, synthetic
reference and fictional adopter proof, and independent artifact validator in
this repository. Prove unchanged history/products/app/reduced-artifact behavior
and fail-closed identity/digest/inventory drift. Do not add the standalone Git
realization, final release/governance candidate, publication, push, or deploy.

### Iteration 11.4 — Generated Hospital Implementation distribution build/validation proof

#### Planned objective and scope boundary

Prove the Iteration 11.3 one-repository/two-release-product architecture by
generating a complete, self-validating Readmission Risk Pool Hospital
Implementation artifact under ignored local state. The proof had to embed one
exact unpublished Platform candidate, own one top-level R environment, expose
thin human operations and the Phase 10 explicit producer trust seam, and run
both synthetic reference acceptance and a materially different fictional
adopter workflow from an external copied tree through unchanged history,
products, app, and reduced artifact.

The iteration explicitly stopped before standalone Hospital Git realization,
commit, remote, push, public archive/release, `v0.1.0` tag, license installation,
release CI, OCI/container work, online retrieval, updater/migration machinery,
publication, or deployment.

#### Maintained source area and distribution contract

Added `distribution/hospital/` as the sole maintained Hospital Implementation
source area inside this authoritative repository. It owns only generated-root
README/onboarding source, a standalone distribution runtime/validator, thin
wrapper source, an editable producer/trusted-composition/configuration
scaffold, and a separate fictional adopter example composition. It contains no
copy of Platform runtime, provider, persistence, product, Shiny, or deployment
logic.

Added `platform.hospital-implementation-distribution@0.1.0` under
`contracts/distribution/`. The generated manifest separates Hospital release,
logical distribution instance, build occurrence/time, embedded Platform
candidate, runtime run, product, reduced artifact, Git, and publication
identities. It declares a closed inventory with member sizes/SHA-256, exact
candidate filename/size/digest/identity/version, compatibility, builder and
environment provenance, fictional/nonclinical classification, passed
validator identity, and explicit nonclaims.

The proof Hospital identity is
`readmission-risk-pool-hospital-implementation@0.0.0-proof.11.4`. It is not a
public release and carries no license grant.

#### Platform release-candidate construction

The builder constructs an allowlisted deterministic regular-file USTAR archive
from current Platform source required by the recipient workflow. It excludes
development tests, unrelated architecture documentation, Hospital builder
source, repository-wide validation entry points, generated state, Git, caches,
and local libraries. The archive contains its own
`PLATFORM-CANDIDATE.yml`, exact internal inventory and SHA-256 values, lock
digest, compatibility declaration, and deterministic
`platform_release_candidate::...` identity.

The candidate version is `0.0.0-proof.11.4` with status
`proof_only_not_published_not_v0.1.0`. It is not a fabricated Platform
`v0.1.0`, Git tag, release, or latest lookup. The Hospital builder copies the
completed archive unchanged and performs no network retrieval.

#### Builder, immutable identity, and integrity

Added the human operations:

```text
Rscript operations/build-hospital-distribution.R
Rscript operations/validate-hospital-distribution.R
```

The builder validates the contract envelope and maintained source allowlist,
stages exact regular files, constructs and validates the Platform candidate,
generates the closed Hospital manifest/checksum, independently validates the
staging tree, atomically promotes an immutable build, validates the promoted
tree, and atomically replaces `CURRENT.yml` only after success. The default
store is `build/hospital-implementation-distributions/`.

Distribution instance identity is deterministic from logical release,
candidate, environment, and exact payload content. Build identity additionally
includes declared build time. Rebuilding identical logical inputs at another
path/time preserves instance identity; the occurrence identity changes only
with time. Repeating the same build is idempotent, and conflicting content at
an immutable destination fails without replacement.

#### One top-level environment and safe Platform extraction

Iteration 11.4 has zero maintained wrapper dependencies. The generated
top-level `renv.lock` is therefore byte-for-byte the exact Platform candidate
lock, with both digests recorded. A bounded conflict check rejects any declared
addition; no general solver, silent upgrade, or downgrade exists. The generated
root is the one active project. Delegated Platform processes run with
`Rscript --vanilla` and the already active library, so the extracted Platform's
retained lock remains provenance and does not activate a nested project.

The artifact-owned initializer first validates the closed Hospital tree and
archive. Its pure-R USTAR reader checks header checksum, safe relative names,
regular-file type, duplicates, size, and digest; traversal, absolute paths,
backslashes, links, special members, malformed headers, and undeclared content
fail closed. Extraction stages under `.rrp/platform/`, verifies the exact
candidate tree, runs Platform-owned doctor against staged source, and promotes
only after success to `.rrp/platform/<candidate-digest>/`. Identical state is
idempotent. Modified managed source is preserved and rejected with actionable
drift guidance rather than silently repaired.

#### Callable Platform seam and thin wrappers

Added only two reusable upstream functions:
`rrp_validate_selected_canonical_producer()` and
`rrp_run_selected_platform_cycle()`. They accept an already trusted registry,
exact selection, invocation, explicit database/run configuration, and optional
event emitter, then reuse existing producer admission and history behavior.
The established `operations/validate-producer.R` and
`operations/run-platform.R` now call that same seam with the unchanged shipped
composition.

Generated wrappers own distribution-root discovery, managed candidate
validation, explicit state paths, reviewed composition construction,
delegation, exit status, and Hospital-specific recovery text. Platform scripts
continue to own canonical, runtime/estimand/provider, DuckDB, products, Shiny,
reduced artifact, and diagnostic behavior. No generic CLI framework,
reflective registry execution, executable YAML, package/function/path discovery,
or copied Platform operation/domain logic was added.

#### Producer scaffold, example decision, and trust

The editable `implementation/` baseline contains one declaration, one exact
platform-instance selection, one nonsecret producer-owned configuration, one
callable scaffold, and one fixed composition file. The callable deliberately
returns a failed structured producer result until a recipient implements
source-local validation and canonical mapping. Normal validation therefore
fails clearly before runtime rather than fabricating data.

Implementation evidence selected option C: ship the empty editable scaffold
and a clearly separate complete fictional adopter example. This ranks highest
for onboarding and post-release seam verification while avoiding the claim
that the example's denormalized `case_extract`/`activity_feed` shape is required.
The example reuses the Phase 10 test-owned fictional source/mapping assets as
allowlisted build inputs and adds Hospital-specific fixed composition. It is
not a second supported reference implementation.

The trust model is unchanged: declarations and selections are data; reviewed
code explicitly registers one callable; selection names one exact ID/version;
YAML cannot name executable paths, functions, packages, URLs, or plugins.

#### Synthetic acceptance and external fictional adopter proof

The generated `operations/run-reference-acceptance.R` delegates entirely to
the embedded Platform's unchanged shipped synthetic composition. From an
external copy it initializes, runs doctor and one Platform cycle, writes
isolated DuckDB history, builds/materializes the unchanged logical products,
constructs the product-only Shiny app, and builds/validates the unchanged
target-neutral reduced artifact. It stops before target realization or
publication.

The separate fictional-adopter proof uses the generated trust/composition
pattern, shared producer conformance/admission, and the smallest callable
Platform cycle seam. It reaches the same unchanged runtime/estimand/provider,
DuckDB, products, app, and reduced artifact from materially different source
evidence. Reference state uses `build/reference/`; adopter state uses
`build/fictional-adopter/`. Tests prove both complete and remain isolated.

#### Independent validation, tamper evidence, and exclusions

The generated artifact owns `validate-distribution.R` plus a standalone
runtime. It validates without Git or the authoritative tree: manifest checksum,
closed file inventory, member size/digest, symlink prohibition, exact one
candidate archive, safe internal archive inventory, candidate identity/version,
compatibility, lock provenance, top-level environment, required operations and
trust scaffolding, fictional status, and prohibited generated/sensitive-shaped
content.

The 36-case focused suite proves valid contract/source/candidate/build,
deterministic and immutable identities, digest verification, safe/idempotent
extraction, one top-level environment, no nested activation, shared callable
seam, thin delegates, true external-copy operation, both full workflows,
isolated DuckDB/product/artifact state, and a clear fail-closed scaffold. It
also covers missing/changed/wrong/extra archives, wrong SHA/candidate identity,
traversal, archive link, missing/extra Hospital members, manifest change,
managed drift, incompatible declaration, lock conflict, unknown producer,
declaration/callable identity mismatch, failed conformance, delegated nonzero
status, prohibited content, and hidden machine/authoritative/sibling paths.

The generated baseline contains no `.git`, authoritative tests, architecture
scratch, DuckDB history, products, target realization, credentials, secrets,
real source/mappings/data, PHI, caches, developer library, or absolute local
path. Generated distributions, managed candidates, history, products, and
artifacts are ignored or temporary and are removed after final validation.

#### Decisions, surprises, deviations, and reference assets

The proof confirmed that no new Platform domain or contract redesign was
needed; the callable seam was limited to composition. A deterministic pure-R
USTAR implementation was chosen so safe member inspection/extraction does not
trust an external tar extractor or accept links/special entries. Existing
Platform operation scripts load a small set of general validation helpers even
when running; those helper sources remain in the candidate so the unchanged
scripts stay operable, while repository-wide validation entry points and tests
remain excluded.

The local managed `renv` sandbox lock in this execution environment required
`RENV_CONFIG_SANDBOX_ENABLED=FALSE` for repository-root validation commands;
generated delegated processes already use `--vanilla` and the active library.
This is an execution-environment workaround, not a generated contract or
dependency change. Added `.renvignore` with only `build/` so generated proof,
history, product, and deployment state cannot inflate implicit dependency
discovery or appear to introduce release dependencies; generated roots carry
the same rule.

No sibling repository was inspected or modified. The only adapted evidence was
the clean repository's own Phase 10 materially different fictional producer
fixture. Existing Phase 8 atomic build/current-pointer and independent
validation patterns informed the clean design; no old asset was copied. All
contract, builder/runtime, archive logic, wrappers, scaffold, documentation,
tests, and validation code are new clean work owned here.

#### Validation evidence

The final validation matrix reported:

- `Rscript operations/validate-documentation.R`: PASS (4 checks, 0 issues),
  covering 37 required documents, 263 local links, 25 navigation sources, and
  portable paths;
- `Rscript tests/run-phase11-tests.R`: PASS (36 tests), including complete
  external-copy synthetic and fictional-adopter workflows and tamper cases;
- `Rscript tests/run-phase0-tests.R`: PASS (10 tests),
  `Rscript tests/run-phase7-tests.R`: PASS (8 tests), and
  `Rscript tests/run-phase10-tests.R`: PASS (26 tests) after updating the
  repository-policy, public-operation-count, and shared-cycle expectations;
- `Rscript operations/build-hospital-distribution.R --built-at
  2026-08-20T18:30:00Z`: succeeded with one unpublished candidate and immutable
  distribution; `Rscript operations/validate-hospital-distribution.R`:
  succeeded with 38 closed inventory members and passed temporary extracted
  Platform doctor validation;
- development validation: PASS (150 checks, 0 issues), including every Phase
  0–11 suite;
- checkpoint validation: PASS (212 checks, 0 issues), including every completed
  phase checkpoint and the Iteration 11.4 repository/record evidence;
- clean `rrpruntime@0.3.0` source build and
  `R CMD check --no-manual --no-vignettes`: `Status: OK`; restricted-network
  package-index warnings did not affect local package checks;
- independent parse validation: PASS for 154 maintained R files and 59
  maintained YAML files;
- `renv::status()`: exit 0, “No issues found -- the project is in a consistent
  state”; expected restricted-network index warnings and the known implicit
  dependency-discovery timing note were nonfatal;
- `git diff --check`: PASS; and
- final hygiene scans found no generated Hospital distribution, Platform
  candidate archive, managed extraction, DuckDB history, product/artifact
  bundle, deployment repository, nested Git repository, or retained log.

Because the managed execution sandbox's `renv` sandbox lock made ordinary
profile activation repeatedly rescan, the final composed development,
checkpoint, and tightened Hospital build/validation commands used
`R_PROFILE_USER=/dev/null` and the exact locked project library. The same
documented operation scripts and validation modes ran unchanged. The Hospital
operations were also exercised earlier with normal project activation plus the
already documented `RENV_CONFIG_SANDBOX_ENABLED=FALSE` local workaround. No
network access, dependency restoration, lockfile update, or release action
occurred.

#### Architecture, plan, operations, and documentation effects

Updated Platform Architecture, the Phase 11 implementation sequence, Hospital
distribution assessment, open decisions, progressive adoption, root status,
documentation navigation, operator/validation guidance, operation registry,
and `AGENTS.md`. Added repository/checkpoint validation for the actual source,
contract, ignore, thin-delegation, operation-registration, record, and focused
test boundaries. No dependency or lockfile changed.

#### Phase 11 status

**IN PROGRESS.** Iteration 11.4 closes the foundational generated-artifact
proof. Phase 11 still lacks standalone Hospital Git realization, final
license/dependency/asset compatibility review and license installation,
contribution/security/support/DCO policies, tested release R/OS evidence, final
Platform and Hospital release candidates/manifests, clean acquisition evidence,
maintainer authorization, tags, GitHub releases, and publication.

#### Recommended next task

Use two bounded remaining increments. First implement a **standalone Hospital
Implementation Git realization** that consumes only an independently validated
distribution, produces an exact remote-free staged repository at an explicit
outside-repository destination, validates it, and stops before commit/remote/
push. Then implement one **release-candidate and governance hardening**
iteration covering final license review/installation, policies, tested R/OS
matrix, both product candidates and clean-acquisition evidence, followed by a
separately authorized publication action. This grouping keeps realization
mechanics distinct from legal/release authorization without introducing
another architecture phase.

### Iteration 11.5 — Standalone Hospital Implementation Git realization

**Status:** implemented on 2026-08-20; Phase 11 remains in progress

#### Planned objective

Consume one independently validated Hospital Implementation distribution and
realize it as the exact standalone Git-shaped product a hospital may later
acquire. The operation must use an explicit outside-repository destination,
stage and validate before promotion, initialize `main`, stage every generated
file, and stop with zero commits and remotes. It must neither reach maintained
Hospital source nor rebuild the distribution or Platform candidate. Safe
regeneration may own pristine generated output only; modifications, commits,
remotes, links, suspicious Git state, and unrelated destinations must be
preserved and refused. Publication, release governance, and licensing remain
outside this iteration.

#### Actual work

Added `platform.hospital-implementation-git-realization@0.1.0`, its generated
manifest/checksum form, the distribution-carried standalone runtime and
validator, authoritative maintainer builder/validation operations, repository
validation, and focused success/failure/acquisition evidence. A generated
repository is the unchanged validated distribution at its root plus only
`HOSPITAL-GIT-REALIZATION.yml`, its SHA-256 file, and local `.git` metadata.
The distribution's own validator recognizes that exact envelope while still
checking every original distribution member and Platform candidate.

The operation boundary is now:

```text
independently validated Hospital distribution
        → copy exact regular files to external staging
        → write self-contained realization identity/provenance
        → validate closed content
        → git init --initial-branch=main
        → git add --all
        → validate pristine Git state
        → atomically promote or restore prior pristine output
        → run artifact-owned standalone validator
        → STOP
```

The build command defaults only to the existing Hospital distribution store;
it never invokes its builder. `--distribution` selects another exact artifact
or store, `--destination` is mandatory, and `--realized-at` is optional
occurrence provenance. The independent validator runs from the realized tree
with the active package library and no authoritative-tree lookup.

#### Realization contract and identity/provenance

The realization manifest records its specification, deterministic instance
identity, occurrence time, exact Hospital distribution specification/release/
instance/build/manifest SHA-256, included Platform identity/version/candidate/
archive SHA-256, builder identity/version/operation, expected repository files,
per-source-member byte sizes and SHA-256 values, Git semantics, provenance,
validation evidence, status, and explicit nonclaims.

Logical identity includes the realization specification and builder versions,
exact distribution instance/build/manifest, included Platform candidate and
archive digest, and every copied source member. Destination, folder name,
realization time, commit, tag, remote, publication, runtime run, products,
artifacts, and deployment are excluded. Git commit identity is neither present
nor required. Platform and Hospital Implementation versions remain independent.

#### Source artifact and repository boundary

The contract, `R/git-realization-runtime.R`, and
`validate-git-realization.R` are themselves allowlisted distribution members.
The realization builder loads them only after artifact-owned distribution
validation passes. It does not copy from maintained `distribution/hospital/`,
does not build a distribution, does not build a Platform candidate, and does
not import CentralStatz distribution/Git builder operations into the realized
repository or its embedded Platform candidate.

The realization is adoption/distribution release preparation, not deployment.
Connect-specific manifests, application realization behavior, credentials,
publication APIs, or service concepts were not introduced. Hospital
distribution and Git-realization operations are now explicitly classified as
`maintainer`; the stable public Platform onboarding surface remains 14
operations and the generated Hospital artifact retains its separate thin
hospital-facing wrapper surface.

#### Destination, ownership, refusal, and rollback

Missing destinations are allowed only when their regular parent already
exists outside the authoritative repository and outside the source artifact.
Staging occurs beside the destination so promotion is a same-parent rename.
An existing destination must pass the complete in-process realization and Git
baseline before it is considered generator-owned. The same realization is an
idempotent no-op even when a later occurrence time is supplied. A different
validated source may replace a pristine generated destination only after the
replacement stages and validates.

Unrelated directories, non-directory paths, symbolic links, source/destination
containment, changed or missing members, extra/untracked/ignored content,
unstaged changes, commits, remotes, wrong branches, local author/work-tree
configuration, nested `.git`, Git alternates/modules/worktrees/shallow state,
and nonportable/sensitive/sibling content fail with actionable issues. No merge,
reset, repair, recipient upgrade, or silent deletion exists. Promotion moves a
validated prior destination aside, restores it if new promotion/validation
fails, and removes that backup only after standalone validation succeeds.

> The generator owns only pristine generated realizations. Once modified,
> committed, or configured with a remote, the destination is outside automatic
> replacement.

#### Independent validation and acquisition proof

The generated validator verifies its exact contract and manifest checksum,
closed inventory, every copied size/SHA-256, exact distribution and embedded
Platform provenance, validation evidence/nonclaims, no links/path escapes,
machine/sibling/sensitive exclusions, one independent root Git directory,
`main`, zero commits/remotes, exact staged index, no unstaged/untracked/ignored
state, and no suspicious or nested Git metadata. It invokes the original
artifact-owned distribution validator, which safely extracts the Platform to a
temporary directory and runs Platform doctor. GitHub and the authoritative
source tree are unnecessary.

A separate temporary realized repository passes standalone Git and
distribution validation, initialization, Hospital doctor, complete synthetic
reference acceptance, and the materially different fictional-adopter proof.
Those workflows reach unchanged DuckDB history, products, Shiny construction,
and reduced application artifact behavior. Initialization/operation creates
ignored `.rrp` and `build` state and deliberately transitions that checkout
out of pristine generator ownership.

#### Tests and failure cases

The Phase 11 suite now covers contract/envelope, source allowlist, generated
Git shape, independent validators, artifact validation inside the Git envelope,
identity/path/time behavior, idempotent regeneration, changed-source pristine
replacement, Platform/distribution identity propagation, full acquisition,
and absence of authoritative builder/source leakage. Required failure evidence
covers missing/invalid/tampered source, unrelated/modified/committed/remote
destination, destination link, suspicious/nested Git, tampered/missing/extra
member, metadata mismatch, embedded Platform digest mismatch, branch mismatch,
unexpected commit/remote, unstaged or ignored state, machine path, and hidden
sibling dependency. Failures never silently repair unknown state.

#### Old assets used or adapted

No sibling-repository asset was inspected, copied, modified, or required. The
implemented Connect Cloud realization supplied in-repository architectural
evidence for explicit destination, staged validation, Git initialization,
pristine ownership, atomic replacement/rollback, and independent validation.
Hospital realization code is new and intentionally omits Connect target,
manifest, app, dependency-pruning, and deployment behavior. The Iteration 11.4
artifact and validator are reused as the unchanged sole input boundary.

#### Decisions, surprises, and deviations

- Selected a direct root realization rather than nesting the distribution in a
  subdirectory, preserving the eventual hospital acquisition experience.
- Added only two generated realization metadata files. The artifact validator
  excludes those and root `.git` only when the complete regular realization
  envelope is present; the realization validator owns their content and Git
  semantics.
- Realization time remains inspectable occurrence provenance but never changes
  logical identity. When an existing pristine destination has the same logical
  identity, regeneration retains its original bytes rather than rewriting only
  the timestamp.
- Exact source distribution build identity participates in realization
  identity because the realization consumes one physical validated artifact,
  even when two builds share a logical distribution instance.
- Maintainer tooling required an explicit operation classification distinct
  from public onboarding, advanced debugging, and development validation.
- No release version was bumped or fabricated: both generated products remain
  proof-only and unpublished, and `LICENSE-STATUS.md` still grants no license.

#### Validation evidence

The final validation matrix reported:

- `Rscript tests/run-phase11-tests.R`: PASS (55 tests), including independent
  distribution/Git validators, complete synthetic/adopter acquisition, and all
  required ownership, Git-state, identity, tamper, path, and refusal cases;
- `Rscript tests/run-phase8-tests.R`: PASS (22 tests),
  `Rscript tests/run-phase10-tests.R`: PASS (26 tests), and
  `Rscript tests/run-phase7-tests.R`: PASS (8 tests);
- development validation: PASS (159 checks, 0 issues), including every Phase
  0–11 focused suite;
- checkpoint validation: PASS (221 checks, 0 issues), including the Iteration
  11.5 repository and implementation-record evidence;
- documentation validation: PASS (4 checks, 0 issues), covering 37 required
  documents, 271 local links, 25 navigation sources, and portable paths;
- final direct Hospital distribution build/validation: succeeded with
  distribution instance
  `hospital_implementation_distribution::475d0187647ad9e94494b790343c6f837a9eaf6f5f44d1c4dbccb2afeb21b75e`,
  build
  `hospital_implementation_distribution_build::1114327144f53ed37cd91abe5a0b309377d34eb451cfc2682383d84587a44de4`,
  candidate
  `platform_release_candidate::d8beaf1117f96226743c1494cd5ccad2d123cb83636bf38290fe7b0d2afbbff5`,
  and 41 exact inventory members;
- final direct Git build/validation: succeeded with realization
  `hospital_implementation_git_realization::2a6e1202f245a4b2cbd57f2df0487e937fdfa44948b14a21973011b8f234b456`,
  `main`, all generated files staged, zero commits/remotes, passed source
  distribution validation, and explicit `not_published` status;
- clean `rrpruntime@0.3.0` source build and
  `R CMD check --no-manual --no-vignettes`: `Status: OK`; restricted-network
  package-index warnings did not affect local checks;
- independent parse validation: PASS for 159 maintained R files and 60
  maintained YAML files;
- `renv::status()`: exit 0, “No issues found -- the project is in a consistent
  state”; the known implicit dependency-discovery timing note and restricted-
  network index warnings were nonfatal; and
- final documentation, whitespace, Git diff, generated-state, nested-Git,
  sensitive-file, and sibling-worktree hygiene checks passed.

The managed execution environment's ordinary `renv` activation can repeatedly
rescan and contend on its sandbox lock. Final composed validation and direct
maintainer commands therefore used `R_PROFILE_USER=/dev/null` with the exact
locked project library; the documented scripts and modes ran unchanged. No
network access, restoration, dependency/lockfile change, commit, remote, tag,
push, release, or publication occurred. Temporary distribution stores, package
checks, and Git destinations were removed after evidence collection.

#### Documentation and later implications

Added the maintainer-facing standalone Git guide and updated the distribution
guide, operator manual, validation guide, operation index/registry, root and
documentation navigation, Platform Architecture, implementation plan, Hospital
distribution assessment, open decisions, contracts index, and `AGENTS.md`.
Publication can later consume this exact validated staged shape without
restructuring it, but commit authorship, release identity, remote configuration,
push, GitHub Release creation, and release attachment remain unauthorized.

#### Phase 11 status and exact remaining work

**IN PROGRESS.** Artifact construction and standalone Git realization are now
proved. Before a deliberate first-release cutoff, Phase 11 still requires the
final Apache-2.0 dependency/asset/license compatibility review and license
installation; stewardship/copyright metadata; CONTRIBUTING and DCO guidance;
SECURITY and SUPPORT; release notes/changelog/citation metadata if justified;
tested R/OS matrix and CI evidence; actual Platform `v0.1.0` candidate; a
Hospital Implementation candidate generated from that exact Platform
candidate/release; clean acquisition evidence; final checksums/manifests and
repository/release naming; explicit maintainer authorization; and separate
commit/tag/remote/push/GitHub Release/publication actions.

#### Recommended next task

Implement one bounded **release-candidate and governance hardening** iteration:
complete the final license review/installation and policy files, establish only
the R/OS support matrix actually tested, assemble exact unpublished Platform
and Hospital release candidates from this realized structure, and prove clean
acquisition. Stop again for explicit maintainer authorization before any
commit, tag, remote, push, GitHub Release, or publication action.

### Iteration 11.6 — v0.1.0 release-candidate and governance hardening

#### Objective and settled decisions

Turn the proven 11.4–11.5 artifact pipeline into the final local preparation
workflow for intended Platform `v0.1.0` and independently versioned Hospital
Implementation `v0.1.0`, then stop before publication. This iteration used the
settled one-authoritative-repository/two-release-product model, whole-tree first
Platform release, exact embedded Platform archive, one Hospital `renv`
environment, fixed trusted producer composition, external secrets, best-effort
support, CentralStatz stewardship, DCO/no-CLA contributions, and Apache-2.0
direction without reopening them.

#### License review and installed governance

The bounded review inspected the 41 packages recorded by `renv.lock`, installed
DESCRIPTION license metadata, `rrpruntime`, tracked source, generated contents,
asset extensions, reference-repository reconciliation, and maintained examples.
R dependencies are restored rather than bundled; their MIT, BSD, LGPL, and GPL
licenses remain their own. No image, font, binary, vendored dependency tree, or
copied third-party source ships. Reference evidence supplied principles only
and is neither copied nor required. No concrete Apache-2.0 blocker was found.

Installed the standard Apache License 2.0 in `LICENSE`, CentralStatz copyright
and stewardship in `NOTICE`, and updated `LICENSE-STATUS.md` to distinguish the
license grant from `not_published` release status. `rrpruntime` now declares
Apache License (>= 2). Added the evidence-focused license review,
`CONTRIBUTING.md` with DCO 1.1 sign-off through `git commit -s` and no CLA,
`SECURITY.md` with GitHub private vulnerability reporting and no invented email,
and `SUPPORT.md` with best-effort/no-SLA/no-entitlement terms. Added a concise
`CHANGELOG.md`; `CITATION.cff` was deliberately omitted because no scholarly
publication metadata is needed or available.

#### Version, support, and candidate semantics

`RELEASE.yml` is the small release authority: development source is
`0.1.0-dev`; intended Platform and independently versioned Hospital candidates
are `0.1.0`; publication is `not_published`; expected tag `v0.1.0` is recorded
but explicitly nonexistent. Candidate identity remains distinct from source
revision, occurrence time, Git commit/tag, and GitHub Release.

The truthful local claim is R 4.4.1 on `aarch64-apple-darwin20` / Darwin 25.5.0.
The release supports the R 4.4.x line through the shipped lock and standard
`renv::restore()` path. Windows and other R minors are untested. A minimal
read-only GitHub Actions workflow declares R 4.4 on Ubuntu; Ubuntu becomes
tested evidence only after that workflow succeeds. First restoration may need
network access and system libraries; third-party packages are not embedded.

#### Implementation and release evidence

The 11.4 candidate builder now accepts explicit intended versions, candidate
status, and source revision. Proof defaults remain for lower-level regression
tests. Release mode inventories the complete tracked authoritative source unit,
adds the candidate manifest, creates deterministic regular-file USTAR, and
retains closed size/SHA-256 evidence. Hospital build/validation accepts proof
or final unpublished-candidate status and continues to require one exact
embedded candidate, matching digest, exact top-level lock, closed inventory,
and artifact-owned validation. The Git realization keeps its deterministic
identity and staged/uncommitted/remote-free semantics while describing a final
candidate without claiming publication.

`Rscript operations/prepare-release.R --version 0.1.0` is the sole primary
maintainer interface. It fails on dirty/uncommitted source, version conflict,
invalid governance/license, failed checkpoint, existing unexpected output,
candidate/digest mismatch, failed artifact/Git validation, or failed recipient
proof. It orchestrates existing builders and validators under
`build/releases/0.1.0/`, then emits checksummed `RELEASE-PREPARATION.yml` with
versions, identities, archive SHA-256, source revision, governance/support,
environment, validation, occurrence time, and explicit `not_published` state.
`--validate-only` repeats acquisition validation; `--show-readiness` inspects
retained evidence without rerunning workflows.

The Platform acquisition proof extracts to an unrelated temporary root and
runs initialize, doctor, synthetic platform/history, product materialization,
app validation, and reduced-artifact build/validation. The Hospital proof copies
the complete standalone Git realization to another temporary root, invokes its
own validator, initializes, runs doctor and synthetic acceptance, and runs the
fictional-adopter substitution. Neither proof looks up the authoritative tree
or sibling repository. Preparation time is provenance, never logical identity.

Agent mappings invoke the same maintainer command for prepare, validate, and
show-readiness intents. `Publish v0.1.0` is explicitly unimplemented and
unauthorized. The operation registry classifies release preparation as
`maintainer`; generated hospital wrappers do not expose it.

#### Assets, surprises, deviations, and refusal behavior

No sibling repository was inspected or modified. Existing 11.4 deterministic
archive, distribution, standalone validator, and 11.5 Git realization patterns
were adapted in place. No new generalized release framework, dependency solver,
secrets system, publication API, Docker/OCI, or analytical capability was
introduced.

Whole-repository enumeration initially made every proof regression repeatedly
archive documentation and tests. The implementation retains the bounded legacy
allowlist for proof-default tests while final candidate status selects the full
tracked release unit. Release preparation still requires a clean source tree,
so a missing/deleted tracked file or untracked source cannot enter a candidate
silently. Local `renv` implementation directories were also added to
`.gitignore` to keep Git cleanliness checks bounded and truthful.

Recovery from an interrupted validation retained the coherent partial tree and
discarded no valid implementation work. Focused reruns found four bounded
integration defects: the release-area exception had changed a stable Git
destination diagnostic; the Phase 7 exact maintainer-operation count had not
included release preparation; the Phase 4 checkpoint still required the former
placeholder `runtime/LICENSE`; and missing-path `Sys.readlink()` behavior on
macOS made an absent release destination appear occupied. The fixes preserve
the stable diagnostic, assert the fifth maintainer operation, replace the stale
file requirement with explicit Apache package-metadata validation, and test
absent versus symbolic-link release paths. A clean copied repository without a
restored project library also proved that `renv` preflight blocks before any
candidate state; constructing the locked environment allowed preparation to
continue without changing source or requiring network access.

No silent repair occurs. Existing release output is preserved; manifest,
archive, distribution, realization, governance, version, environment, source
cleanliness, or acquisition disagreement blocks readiness. No commit, author
identity, tag, remote, push, GitHub API call, release, publication, or external
repository mutation is implemented.

#### Tests and validation

Phase 11 focused tests cover Apache state, governance/DCO/security/support,
tested support claims, version authority, whole-tree Platform candidate status,
deterministic identity/inventory/checksum, exact Hospital embedding and
independent version metadata, staged/uncommitted/remote-free Git state,
orchestration, release evidence fields, acquisition command coverage, dirty
source refusal, version conflict, and missing license/governance in addition to
the complete 11.4–11.5 regression suite.

The final validation matrix reported:

- documentation validation: PASS (4 checks, 0 issues), covering 39 required
  governing documents, 287 repository-local links, 25 maintained navigation
  sources, and portable document paths;
- Phase 11 focused validation: PASS (68 tests), including complete independent
  synthetic/adopter acquisition, release candidate identity/digest/inventory,
  Git safety, governance, refusal, and absent/link output-state evidence;
- Phase 8, Phase 10, and Phase 7 regressions: PASS (22, 26, and 8 tests);
- development validation: PASS (171 checks, 0 issues), including every Phase
  0–11 suite; checkpoint validation: PASS (233 checks, 0 issues), including the
  installed Apache package metadata and Iteration 11.6 record;
- clean committed-copy `prepare`, retained `--validate-only`, and
  `--show-readiness`: PASS; the Platform candidate contains 297 tracked source
  members, the Hospital candidate embeds its exact identity/SHA-256, the Git
  realization is `main` with all files staged and zero commits/remotes, both
  acquisition proofs pass, and status is `READY FOR PUBLICATION` while
  `not_published`;
- clean `rrpruntime@0.3.0` source build and
  `R CMD check --no-manual --no-vignettes`: `Status: OK`; restricted-network
  package-index warnings did not affect local checks;
- `renv::status()`: exit 0, “No issues found -- the project is in a consistent
  state”; dependency-discovery timing and restricted-network repository-index
  warnings were nonfatal;
- independent parsing: PASS for 162 maintained R files and 62 maintained YAML
  files; and
- final whitespace, Git diff, generated-state, nested-Git, sensitive-file,
  machine-path, sibling-independence, and repository hygiene checks: PASS.

The final candidate identities and digests remain in ignored checksummed
`RELEASE-PREPARATION.yml` evidence rather than this tracked record. Embedding a
whole-repository candidate's own digest in a member of that candidate would be
circular. No network restoration, lockfile change, authoritative commit, tag,
remote, push, GitHub Release, publication, or external repository mutation
occurred.

#### Phase 11 status and remaining boundary

**IN PROGRESS — READY FOR PUBLICATION.** Local release preparation and its
architecture are complete, but Phase 11 is not complete because nothing has
been published. The only recommended final task is **Phase 11 / Iteration 11.7
— explicit maintainer publication workflow and first v0.1.0 release**: final
authorization, release commit, tag/remote verification, pushes, GitHub Platform
and Hospital releases/artifact attachment, post-publication verification, and
transition to the next development version. None is authorized here.

### Iteration 11.7 — Explicit maintainer publication workflow and first v0.1.0 release

#### Objective and publication authorization

Complete Phase 11 by turning the exact Iteration 11.6 candidates into the first
actual public Platform and generated Hospital Implementation releases. This
iteration explicitly authorizes only the controlled release commits, tags,
GitHub repositories/releases, artifact uploads, pushes, remote acquisition,
and post-release development transition described by the task. It prohibits
force-push, deletion, history rewrite, unrelated repository mutation, and
publication after any failed preflight check.

#### Capability assessment before implementation

The authoritative source was clean `main` at `754901d`, exactly matching the
public `origin` at
`centralstatz/readmission-risk-pool-platform`. No local or remote `v0.1.0` tag
or GitHub Release existed. Authenticated GitHub identity `zajichek` was an
active `centralstatz` administrator with Platform push/admin permission and a
successful authenticated Git push dry-run. The intended public Hospital target
`centralstatz/readmission-risk-pool-hospital-implementation` was absent and the
organization allowed public repository creation. No branch rules protected
`main`. Git and curl were available; `gh` was not, so the existing authenticated
HTTPS credential and GitHub REST API were selected without an architecture
change. Platform private vulnerability reporting was disabled but could be
enabled and verified through the authenticated API after the zero-mutation
preflight and before release exposure.

#### Implemented publication boundary

Added `operations/publish-release.R` with mandatory `--preflight`, `--publish`,
or `--verify` mode. No invocation defaults to mutation. `RELEASE.yml` fixes the
Platform repository/remote/branch, generated Hospital repository, and both
`v0.1.0` tags. Credential-safe REST helpers keep the GitHub token in process
memory and off command arguments, evidence, and diagnostics.

The complete preflight reuses exact 11.6 preparation validation, requires clean
source at the prepared revision, reruns the checkpoint, checks governance,
release notes, authorship, authenticated owner/repository permission, branch
rules, tag/release absence, Hospital target state, and vulnerability-reporting
state, and performs zero remote mutation. Explicit publication proceeds
Platform first, uploads the deterministic candidate archive and checksum,
downloads and proves that published artifact, creates the generated public
Hospital repository only after Platform verification, commits the exact
validated realization, publishes it, and clones the public tag for standalone
validation, synthetic acceptance, and fictional-adopter proof.

Checksummed ignored publication state records every irreversible stage. A
rerun may continue only from exact identity-matched state. No code deletes a
remote object, force-pushes, rewrites history, or treats unrelated existing
state as idempotent. Only after both releases verify may tracked publication
evidence be written and development advance to `0.2.0-dev`; that transition is
committed separately after final validation. The public Hospital repository is
documented as generated output, never a second maintained source authority.

#### Tests, documentation, and execution status

Focused deterministic tests cover maintainer classification, explicit
authorization, preflight non-mutation, repository/branch/dirty/revision/
readiness/authentication/tag/release/Hospital conflicts, exact tag and digest
relationships, stage recovery/idempotency, prohibited rollback, evidence,
development-transition gating, generated-source authority, and human/agent
command alignment. The maintainer publication guide documents commands,
ordering, partial failure, rerun, verification, and post-release work.

**Execution status at the immutable release-state cutoff:** publication
machinery is implemented and live publication is authorized, but no mutation
has yet occurred. Final validation, exact candidate identities, actual GitHub
release evidence, post-publication verification, development transition, and
Phase 11 completion are appended below only after they occur; they are not
predicted inside the `v0.1.0` source contents.

#### Prepublication validation and immutable identities

Local validation completed before the publication boundary: documentation
validation passed 4 checks; the focused Phase 11 suite passed 93 tests and the
strengthened publication subset then passed 26 tests; Phase 7, 8, and 10
regressions passed 8, 22, and 26 tests; development validation passed 170
checks; and Phase 0 policy validation passed 10 tests. `rrpruntime@0.3.0`
built and completed `R CMD check --no-manual --no-vignettes` with `Status: OK`.
`renv::status()` reported a consistent project after nonfatal restricted-network
repository-index warnings. Independent parsing covered 166 R files and 62 YAML
files without failure. Documentation, generated-state, nested-Git, sensitive-
file, machine-path, sibling-independence, repository-hygiene, and
`git diff --check` evidence passed.

The signed-off immutable release-state commit is
`7a3cca66db2cdd6f7796918282db294bbb7eb4e8`. Exact preparation from that clean
revision passed the complete checkpoint, governance, Platform candidate,
Hospital distribution, Hospital Git realization, support, and both acquisition
proofs. Its stable identities are:

- Platform candidate
  `platform_release_candidate::6037e0117bd920d7fd4e951e96ba14ba01f159c7f99c99bf0989eab28237736f`;
- Platform archive SHA-256
  `01eb816252ac181385b5b658bdd528e35481fa7ab4176646047bbd9029a7bb27`;
- Hospital distribution
  `hospital_implementation_distribution::7b8aae7f0cbb0a68f45fe215a0d77466ded7074142a7340a3dddf73f43112f66`;
  and
- Hospital Git realization
  `hospital_implementation_git_realization::b54ee70ae11c4c1a6b9ffd2a17528153a2409f71560371b38f6a085c46d28667`.

The separate live preflight repeated the complete checkpoint and returned
`PUBLICATION PREFLIGHT: PASS` with `Remote mutation: NOT PERFORMED`. A final
code review before that gate tightened partial-state reconciliation so a
retained Platform or Hospital tag/release/branch stage must still exist at its
exact recorded identity; missing or unrecorded remote state is a conflict.

#### Actual publication and remote verification

The explicitly authorized publication began only after the mutating invocation
repeated the same successful preflight and printed `REMOTE MUTATION:
AUTHORIZED`. Platform private vulnerability reporting was enabled and verified.
The operation then completed all checksummed stages without force-push,
deletion, history rewrite, unrelated repository mutation, or partial failure.

The actual public products are:

- [Readmission Risk Pool Platform v0.1.0](https://github.com/centralstatz/readmission-risk-pool-platform/releases/tag/v0.1.0),
  GitHub Release `383743898`, annotated tag `v0.1.0`, release commit
  `7a3cca66db2cdd6f7796918282db294bbb7eb4e8`, and attached archive digest
  `01eb816252ac181385b5b658bdd528e35481fa7ab4176646047bbd9029a7bb27`;
  and
- [Readmission Risk Pool Hospital Implementation v0.1.0](https://github.com/centralstatz/readmission-risk-pool-hospital-implementation/releases/tag/v0.1.0),
  GitHub Release `383749269`, annotated tag `v0.1.0`, and generated release
  commit `62d374292f51c69a6c97cf247b64ec49c05ba858`.

Published Platform verification downloaded the attached archive and checksum,
matched the prepared SHA-256, and reran the full Platform acquisition proof.
Published Hospital verification cloned the public tag into an unrelated
temporary root, validated the generated content and distribution, ran
initialize, doctor, synthetic acceptance, and the fictional-adopter proof, and
confirmed the embedded Platform identity/digest. Publication ran from
`2026-09-06T22:59:25Z` through `2026-09-06T23:38:08Z`; these timestamps are
occurrence provenance, not identity. Checksummed durable evidence is retained
under `releases/0.1.0/`. Both GitHub-hosted Ubuntu R 4.4 publication-triggered
validation runs also completed successfully.

#### Development transition, final status, and next work

Only after both releases verified, `RELEASE.yml` advanced to authority version
2 with `v0.1.0` published, retained history/evidence, current development
`0.2.0-dev`, and no intended next version or prepared candidate. `CHANGELOG.md`
now has an empty Unreleased section. Published-state governance validates the
checksummed evidence, while release preparation remains restricted to an
explicit unpublished intended target. Current-facing architecture, operations,
support, acquisition, and agent guidance now describe the actual releases; the
historical 11.1–11.6 record remains unchanged.

Final post-publication validation passed documentation validation with 4 checks
and 297 links, independent parsing of 166 R files and 63 YAML files,
development validation with 170 checks and 0 issues, and the strict checkpoint
with 233 checks and 0 issues. The checkpoint included all focused suites and
the Phase 11 suite passed 94 tests. Release preparation also correctly refused
the already-published `v0.1.0` target, proving that the development transition
did not silently reopen the publication boundary.

**Phase 11 status: COMPLETE.** Readmission Risk Pool Platform `v0.1.0` is
**PUBLISHED**, and Readmission Risk Pool Hospital Implementation `v0.1.0` is
**PUBLISHED**. The next task is not another Phase 11 cleanup iteration: define
and authorize the first post-`v0.1.0` product increment against the
`0.2.0-dev` baseline. No next release target, production deployment, clinical
authorization, or automated release cadence is implied.

## v0.2.0 development assessments

### Installed RRP and independent project architecture assessment (2026-09-11)

#### Objective and authority boundary

Assess whether the forward `0.2.0-dev` architecture should replace the
generated Hospital Implementation delivery model with conventionally installed
RRP software operating on independently owned hospital projects. Identify what
currently prevents that model, classify existing machinery, distinguish
maintainer validation from project validation and build/run provenance, and
recommend the next assessment. This work is assessment only: it does not amend
the authoritative architecture, implement a package/project loader, repair or
rewrite `v0.1.0`, or prepare a new release.

#### Evidence inspected

The assessment reconciled True North, architecture, plan, reference-asset
record, implementation record, implementation conventions, current release
authority, the clean-room v0.1.0 adoption assessment, producer/runtime/provider/
history/product/app/artifact/Connect architecture, progressive adoption, the
Hospital distribution decision, repository layout, contracts, configuration,
package metadata, human scripts, operation libraries, fixed reference
composition, persistence and product adapters, app source, deployment builders,
Hospital templates/wrappers/validators, and release/publication separation.

No sibling repository or external source was needed. No old or released asset
was copied or modified.

#### Conclusion

The installed-software plus independent-project model is feasible and is the
recommended direction for `v0.2.0-dev`. It materially simplifies acquisition,
ownership, dependencies, operation, and upgrades while better matching existing
architectural boundaries. The analytical platform does not require a rewrite.

A substantial majority of semantic machinery is reusable: common contracts,
canonical admission, producer result semantics, `rrpruntime` temporal/provider/
history behavior, DuckDB semantics, products, YAML materialization, the
product-only app, reduced artifact, Connect target boundary, observability, and
operation result/recovery principles. Numeric reuse percentages were
deliberately not fabricated.

The material work is packaging and orchestration refactoring plus two real
generalizations. Only `rrpruntime` is currently package-shaped; most reusable
behavior is sourced from fixed Platform repository paths, operations infer a
repository root, the shipped source composition is the only installed
composition, and builders copy repository assets. Estimand validation/request
construction supports one exact quantity, while normal history orchestration
constructs the transparent reference provider despite the generic provider
registry beneath it.

#### Recommended conceptual boundary

Installed RRP should own namespaced runtime/orchestration, versioned contracts,
default adapters, the supplied app, deployment assets, project tooling, and the
synthetic example. One explicit project root should own a versioned manifest,
trusted registration entry point, source-to-canonical implementation, selected
estimands/providers, dependency environment, configuration, and generated state
locations. Configuration remains non-executable; the operator explicitly trusts
the selected project and RRP loads only a fixed registration boundary rather
than scanning plugins or remote code.

Maintainer/software release validation may continue to enforce clean source,
tests, package inventory, licensing, provenance, checksums, tags, and
publication. Project validation should enforce manifest/component contracts,
compatibility, mapping admission, provider/estimand conformance, dependencies,
and safe state paths without inspecting unrelated Git state. Runtime and build
provenance should record exact software/component identities plus approved
nonsecret code/configuration and artifact digests; mutable project source does
not remove attributable reproducibility.

#### Disposition and migration implications

- **Preserve:** canonical/producer contracts, temporal runtime, provider
  execution, operational history, logical products, YAML access, product-only
  app, artifact/target contracts, diagnostics, and human-operation principles.
- **Generalize:** estimand registration/request construction, provider
  injection into history, project component selection, run discovery, and
  reference-named defaults.
- **Refactor:** sourced modules and repository-relative assets into installed
  namespaces/resources; make operations accept project context and explicit
  component composition.
- **Replace:** generated Hospital acquisition with installed RRP plus project
  initialization; represent synthetic behavior as a conforming example project.
- **Remove from the future user path:** embedded Platform extraction, Hospital
  closed inventories, checksums over editable implementation, pristine Hospital
  Git validation, nested candidate language, and whole-tree wrappers.
- **Retain as maintainer/history:** immutable `v0.1.0` releases and evidence,
  development/source validation, and controlled software publication.

The generated public Hospital repository is unnecessary under the recommended
primary model. Its v0.1.0 history remains immutable. A future lightweight
template repository is optional and should exist only if it improves discovery
beyond an installed project template; it must not embed Platform source.

#### Risks and nonclaims

Simplification must not weaken executable-code trust, estimand meaning,
provider compatibility, temporal validity, append-oriented history, dependency
compatibility, privacy, provenance, or artifact integrity. Those controls move
to contract, project, run/build, and software-release boundaries rather than
disappearing. This assessment does not choose package topology, exact project
manifest fields, estimand extension class, dependency manager, history
migration, custom app/product ABI, template repository fate, or a future
`readmit` API.

#### Files and validation

Created
`docs/architecture/installed-software-project-model-assessment.md`; updated the
documentation index and START HERE navigation; and appended this record. No
contract, runtime, operation, adapter, product, app, deployment, distribution,
dependency, release authority, tag, or publication changed.

Final validation reported:

- documentation validation: PASS (4 checks, 0 issues), covering 40 required
  governing documents, 303 repository-local links, 25 maintained navigation
  sources, and portable document paths;
- Phase 0 focused tests: PASS (10 tests);
- development validation: PASS (170 checks, 0 issues), including every Phase
  0–11 focused suite and 94 Phase 11 tests; and
- `git diff --check`: PASS, with only this assessment document, navigation,
  and implementation-record entry changed in the clean working tree.

#### Recommended next task

Perform one installed-package and minimum-RRP-project-contract assessment. Map
every dependency of validate/run/products/app/build into installed assets,
required project declarations/code, optional project extensions, or
maintainer-only material; then specify project-root resolution, manifest,
trusted registration, dependency ownership, generated-state layout, and
callable operation boundaries. Do not build a CLI or new implementation before
that ownership contract is accepted.

### Governance and validation architecture assessment (2026-09-11)

#### Objective and authority boundary

Assess whether governance and validation built around the Phase 0–11 bootstrap,
generated Hospital distribution, and first-release workflow remain
proportionate for forward `0.2.0-dev` work. Operational safety remained
binding, while current architecture, phase, documentation, and validation
governance were evaluated as evidence. This assessment does not enact its
recommendations or change `v0.1.0`, `AGENTS.md`, authoritative governance,
validators, tests, workflows, software, artifacts, or publication state.

#### Evidence and conclusion

The assessment traced the authority hierarchy, all repository validators, the
development/checkpoint composition, Phase 0–11 aggregators, CI, release and
publication operations, documentation rules, repository/Git assertions, and
artifact, Connect, and Hospital proofs. Current development validation always
runs 14 repository validators and all 12 Phase suites, currently 342 underlying
tests; checkpoint adds all historical phase checkpoints, and CI separately
runs documentation validation before checkpoint repeats it.

Current governance is materially over-scoped for ordinary development. It
couples narrow edits to historical milestone and release/distribution proofs,
uses implementation-record prose and old phase shapes as machine inputs, and
makes objective architecture change unnecessarily coordinated and costly. The
scientific, software, privacy, trust, mutation-safety, artifact-integrity,
dependency, compatibility, provenance, release, and publication invariants
remain essential. They should be owned by the smallest relevant component or
lifecycle boundary rather than universally exercised.

The recommendation is proportional validation: fast default checks,
component-owned suites, explicit integration profiles, broader CI, complete
clean release-candidate proof, exact publication verification, and separate
RRP-project validation. Phase 0–11 remains immutable `v0.1.0` provenance but
should not remain the active `v0.2.0` development hierarchy. Historical tests
can first be retained behind explicit ownership/legacy scopes; no test must be
deleted to establish the new model.

#### Disposition and next task

Created
`docs/architecture/governance-validation-architecture-assessment.md` and added
it to the documentation index and START HERE reading order. The implementation
record remains appropriate for this material prospective assessment, but the
assessment recommends ending exact record-prose checks and using concise ADR,
compatibility, changelog, and release evidence for future active governance.

The installed-package and minimum-RRP-project-contract assessment remains the
next architecture task. Before implementation begins, maintainers should accept
or revise the proportional-validation, explicit-ownership, historical-phase,
and lifecycle-boundary principles; the governance profiles can then be
established before or alongside the package-boundary refactor.

#### Validation posture and result

Current `AGENTS.md` ordinarily directs intentional work to run full development
validation. That would invoke every repository validator and Phase 0–11 suite,
including Hospital distribution, Git-realization, release, and acquisition
proofs unrelated to these Markdown changes. The task explicitly required the
governance under assessment not to serve as unquestioned proof of its own
necessity. This conflict is recorded rather than silently ignored.

Validation was therefore intentionally limited to the directly affected
documentation boundary. The supported documentation validator passed 4 checks
with 0 issues, covering 40 required documents, 305 repository-local links, 25
maintained navigation sources, and portable paths. Direct review, Markdown
trailing-whitespace inspection, repository status, and `git diff --check` were
also used to confirm the documentation-only scope. The complete development
and checkpoint matrices, focused Phase suites, Hospital build/validation,
release preparation, acquisition proof, and publication preflight were not run:
they provide broad regression or lifecycle evidence, not evidence necessary to
establish this assessment's document, navigation, or formatting correctness.

### Installed software boundary and minimum project contract assessment (2026-09-11)

#### Objective and scope

Trace the actual `v0.1.0` operational dependency graph and define the
prospective ownership seam between conventional installed RRP software and an
independently owned RRP project. The accepted `v0.2.0` direction treats Phase
0–11 and generated Hospital delivery as immutable historical evidence rather
than future architecture. This work is assessment only and changes no package,
contract, operation, loader, CLI, validator, artifact, dependency, release, or
publication state.

#### Evidence and findings

The assessment traced initialize, doctor, producer validation, run, canonical
admission, estimand request construction, provider execution, history,
products, app, reduced artifact, and Connect realization from human scripts
through sourced libraries, contracts, fixed composition, adapters, package
code, dependencies, state, and builders. It also separated normal runtime
assets from repository development, Hospital distribution, and release
machinery. No sibling repository or external source was used.

Conventional installation is feasible without replacing the semantic core.
Canonical and producer contracts, `rrpruntime`, provider execution, history
ports, DuckDB behavior, products, YAML access, the product-only app, artifact
integrity, target isolation, and diagnostics remain substantially reusable.
Current coupling is chiefly physical: scripts infer the Platform root, source
ordered files, parse source-tree contracts, temporarily install `rrpruntime`,
select reference components, use root-relative state, and copy repository files
into artifacts.

The installed release should provide namespaced orchestration, contracts and
validators, runtime, default adapters, products/app, artifact/target tooling,
project operations, and an ordinary synthetic example. The minimum project
provides one versioned nonsecret manifest, one fixed trusted registration entry
point, its producer/mapping and selected/custom components, exact
estimand-to-provider selections, dependencies, and one writable state root.
Installed defaults keep persistence, products, app, and target fields out of
the minimum manifest unless overridden.

The provisional physical recommendation is one user-facing RRP package that
composes the existing focused `rrpruntime` package as one coordinated software
release. Project paths are explicit; current-directory use is allowed only
when the manifest is directly present. No upward search, ambient plugin
discovery, executable YAML, arbitrary remote loading, or project Git-state
requirement is proposed. Registration is trusted local R code, not a security
sandbox, and returns a validated structured composition without global
mutation.

#### Generalization and remaining decisions

Two substantive generalizations remain: estimand identity and interval logic
are embedded in the current request builder, and normal history orchestration
constructs the transparent reference provider instead of receiving the
project's selected provider composition. Project registration builds on the
existing producer/provider registries, while repository-root loading, reference
IDs/scales, temporary installation, and artifact source maps become installed
resource/context concerns.

The next focused assessment should decide estimand composition and the trusted
registration result together: supplied versus project estimands, request-builder
trust/conformance, single/multiple cardinality, exact provider routing, and the
pre-execution compatibility sequence. A subsequent package/dependency/build
assessment should confirm the package split, installed inventory, project
dependency evidence, clean installation, and deployment closure. Those are
needed before synthesizing final target architecture and an implementation
plan; history migration and custom app/product/non-R-provider support can
remain later decisions.

#### Files and validation posture

Created
`docs/architecture/installed-software-project-contract-assessment.md`; updated
the documentation index and START HERE navigation; and appended this record.
The accepted proportional-validation posture limits this documentation-only
assessment to documentation/navigation validation, direct diff/scope review,
Markdown whitespace inspection, and `git diff --check`. Historical Phase
0–11, Hospital distribution/acquisition, release, and publication proofs do not
validate this ownership assessment and were not run. The supported documentation
validator passed 4 checks with 0 issues, including 308 repository-local links
and 25 maintained navigation sources; affected Markdown had no trailing
whitespace, and `git diff --check` passed.

### Estimand composition and trusted project registration assessment (2026-09-11)

#### Objective and scope

Resolve the estimand-composition and trusted-registration questions blocking
the prospective installed-RRP/independent-project architecture. The assessment
traces current request construction, provider compatibility and execution,
history, products, application, and artifact behavior, then recommends the
narrowest rigorous first-generation extension policy. It changes no software,
contract, operation, validator, test, artifact, dependency, release, or
publication state, and leaves immutable `v0.1.0` behavior untouched.

#### Evidence, findings, and decision

An executable estimand requires more than a semantic YAML declaration: it pairs
exact semantic and request-builder identities with a trusted callable,
compatibility requirements, request/result conformance, deterministic identity,
and provenance. Current `v0.1.0` cleanly separates estimand requests from
providers and carries estimand/provider identity through accepted estimates and
products, but request construction and normal provider injection remain fixed.
History and products can represent the one supported route; current request
identity, history query keys, product compatibility, and app presentation do
not safely support simultaneous estimands.

The recommended initial policy is therefore supplied estimands only. A project
may contribute producers and providers, while its manifest selects exactly one
producer, one installed estimand, and one exact provider route for a run.
Trusted registration returns a closed set of available project producer and
provider components; it does not select components, register estimands, mutate
globals, or override installed entries. Installed and project catalogs remain
distinct inputs to deterministic resolution, with duplicate exact identities
and reserved-namespace collisions failing closed.

Compatibility is staged: validate manifest identity, registration shape,
catalog resolution, and declared producer/estimand/provider relationships
before source access; validate canonical results after production; then apply
request-specific provider compatibility after admitted state exists. The
resolved immutable project context is distinct from each run-specific
execution plan. One route has no fallback, ranking, ensemble, or implicit
latest-version behavior.

#### Implications and next task

Existing producer admission, provider registry/execution, structured outcomes,
history ports, product builders, app, artifact integrity, and Phase 10 adopter
evidence are reusable with bounded generalization. Implementation must inject
the resolved provider, introduce an explicit request-builder boundary and
builder provenance, and include estimand identity in future request IDs before
custom or multiple estimands are considered. Default products and app remain
installed RRP capabilities; custom product/app plugins and multi-estimand
presentation are deferred.

Created
`docs/architecture/estimand-composition-project-registration-assessment.md`
and added it to the documentation index and START HERE reading order. The next
focused task is the package/dependency and build-reproducibility assessment;
after that, target architecture can be synthesized and versioned project and
registration contracts finalized.

#### Validation posture

The accepted proportional-validation posture limits this documentation-only
assessment to documentation/navigation validation, direct diff/scope review,
Markdown trailing-whitespace inspection, and `git diff --check`. Historical
Phase 0–11, Hospital distribution/acquisition, full development/checkpoint,
release, and publication proofs do not validate the prospective policy and
were intentionally not run. The supported documentation validator passed 4
checks with 0 issues, covering 40 required governing documents, 310
repository-local links, 25 maintained navigation sources, and portable
document paths; affected Markdown had no trailing whitespace, and `git diff
--check` passed.
