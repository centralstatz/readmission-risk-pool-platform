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
