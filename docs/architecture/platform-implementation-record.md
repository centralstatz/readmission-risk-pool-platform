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
