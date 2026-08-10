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
