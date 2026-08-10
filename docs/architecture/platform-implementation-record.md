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
