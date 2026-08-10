# Reference asset reconciliation

## Status and purpose

**Status:** bootstrap assessment; revisit just in time

This document maps the clean architecture to evidence in the sibling
`readmission-risk-pool` repository. The target architecture and implementation
plan were designed first. Paths below are evidence locators, not dependencies.

`../readmission-risk-pool` is a development-time reference only. The clean
platform must never source, import, symlink, test against, deploy from, or
require it. A reused asset must be deliberately brought into this repository,
reviewed against current contracts, adapted if necessary, and thereafter owned
and tested here.

## Classification rules

- **Reuse directly** — semantics and implementation closely match an approved
  clean interface; copying still requires review, attribution, and local tests.
- **Adapt** — valuable semantics or code exist, but interfaces, ownership,
  representation, or coupling must change.
- **Reference only** — behavior, tests, or lessons are useful; implement cleanly
  rather than copy the asset.
- **Do not reuse** — the asset embodies a superseded or accidental architecture.

No asset is approved for direct reuse during bootstrap. Direct reuse requires a
just-in-time implementation-phase review, including license confirmation and a
diff-level assessment. This is intentionally more conservative than assuming
that working code is a target fit.

## Evidence reviewed

The bootstrap review followed representative implemented boundaries rather
than every file. It included:

- the old True North, status, readiness assessment, superseded refactoring plan
  and record, canonical-boundary characterization, README, and agent guidance;
- all nine canonical/derived YAML schemas and relevant vocabularies;
- the synthetic generator, mappings, configuration, and README;
- engine contract validation, temporal/provider APIs, and tests;
- generic pipeline function inventory and orchestration path;
- logical app-product access, the Shiny shell, and product manifest;
- product provenance, deployment build/publication, and operation registry;
- canonical, synthetic, product, deployment, operations, and validation tests.

Uncertain code-level decisions are marked for phase-local review.

## Subsystem reconciliation

| Clean subsystem | Reference evidence | Classification | Evidence and target-fit assessment | Required action / risk |
|---|---|---|---|---|
| Authority hierarchy | `docs/vision/platform-true-north.md`; `docs/architecture/reference-repository-status.md` | **Reference only** | Product direction is strong, but current-state and migration wording belong to the old repository | The clean True North has been rewritten around product requirements and clean authority |
| Canonical domain semantics | `contracts/schemas/*.yml` | **Adapt** | Episode root, baseline preservation, event/recorded time, tasks versus interventions, measure lineage, state, features, and estimate shapes are strong starting semantics | Draft `0.1.0` schemas allow extras, omit bundle/capability context, and leave some record rules unenforced; reconsider required/optional fields and versions in Phase 2 |
| Canonical vocabularies | `contracts/vocabularies/event-types.yml`; `statuses.yml` | **Adapt** | Controlled vocabularies and gate validation are appropriate | Review completeness, ownership, version compatibility, and terminal/lifecycle semantics before copying |
| Canonical-boundary model | `docs/architecture/canonical-bundle-boundary.md` | **Reference only** | Excellent characterization distinguishes seven logical domains from R list mechanics and identifies as-of/provenance/capability gaps | Use its invariants and questions; do not copy its current-list representation as the specification |
| Canonical validator | `engine/R/contract-validation.R`; `pipelines/functions/canonical-pipeline.R` validation functions | **Adapt** | Structured issues, schema checks, cross-domain keys, ordering, vocabularies, and baseline availability are useful | Remove project-root/source-loading assumptions; execute accepted record rules; redesign around bundle versions/capabilities and a focused runtime API |
| Independent canonical fixture | `tests/fixtures/canonical-bundle-fixture.R`; `tests/platform/test-canonical-boundary.R` | **Adapt** | Strong proof that post-canonical behavior need not call the synthetic implementation; failure cases are valuable | Recreate against the new bundle/capability interface; current seven-required-domain R list is transitional |
| Synthetic source generator | `implementations/synthetic-demo/R/generate-source-data.R`; `config/simulation.yml` | **Adapt** | Deterministic, relational, longitudinal fictional ecosystem with repeat episodes and operational records is high-value domain knowledge | Fit to the new implementation producer and run identity; review scale/config coupling and avoid copying old product assumptions; needs just-in-time code review in Phase 3 |
| Synthetic mappings | `implementations/synthetic-demo/R/map-to-canonical.R`; `mappings/source-to-canonical.yml` | **Adapt** | Explicit joins, IDs, status/time translations, source validation, and mapping provenance demonstrate implementation ownership | Rework for new domain schemas, capability declaration, producer result, and provenance; retain no combined synthetic configuration above the handoff |
| Tiny canonical examples | `contracts/examples/*.csv`; `pipelines/functions/fixture-pipeline.R` | **Reference only** | Useful small values and failure concepts | Create new focused fixtures from accepted contracts rather than preserve the old mini-pipeline |
| Temporal eligibility and availability | `engine/R/risk-provider.R`; temporal tests; canonical cross-time checks | **Adapt** | Dual-time filtering, discharge/as-of eligibility, and readmission/death boundaries closely match target principles | Consolidate semantics under explicit estimand/eligibility contracts; add missing task, intervention, feature, membership, and terminal ordering cases |
| Current engine package shape | `engine/` | **Reference only** | Confirms that a focused internal package is operationally useful | Create a clean package later under `runtime/`; do not inherit source-loading, top-level-contract lookup, unexported-helper leakage, name, or file layout automatically |
| Constant provider | `engine/R/risk-provider.R::constant_risk_provider()` and tests | **Adapt** | Potentially useful minimal conformance/test provider | It is not necessarily valid for every estimand; bring over only after Phase 4 estimand semantics define valid behavior |
| Baseline/event placeholder provider | `pipelines/functions/canonical-pipeline.R::baseline_event_development_provider()` | **Reference only** | Transparent deterministic example demonstrates output flow | It is embedded in a mixed pipeline and predates governed estimand coherence; design the clean default from the accepted estimand rather than copy it |
| Provider wrapper/output checks | `engine/R/risk-provider.R::risk_provider()` and `validate_risk_provider_output()` | **Adapt** | As-of filtering, standardized invocation, bounds, IDs, and output tests are useful mechanics | Replace direct function injection with controlled registry/specification, declared inputs, universal plus estimand conformance, and safe failure taxonomy |
| Model/estimand configuration | `config/models.yml`; `config/estimands.yml`; `config/capabilities.yml` | **Reference only** | IDs and intended selection expose important gaps | Configuration is not executable selection; estimands lack versioned terminal/coherence semantics; capability implementation ID is inconsistent with active profile |
| Mixed post-canonical pipeline | `pipelines/functions/canonical-pipeline.R` | **Do not reuse** as a unit | It proves a working vertical path | One file mixes validation, state, provider, reconstruction, priority, measures, products, configuration, and synthetic provenance. Mine individual behavior/tests only after target APIs exist |
| State-construction behavior | `build_episode_state_snapshots()` and synthetic temporal tests | **Adapt** | Useful domain interpretation and derived fields | Reconcile schema-optional columns, state version/run identity, availability rules, and persistence semantics before code reuse |
| Priority and decision behavior | `build_prioritization()` | **Reference only** | Demonstrates the crucial separation of risk from priority | Current policy/config is reference-shaped and not a governed public decision interface; redesign after estimate/history semantics |
| Measure-lineage behavior | `build_measure_lineage_product()` and canonical membership schema | **Adapt** | Generic measure family identity and versioned membership are valuable | Separate retained lineage records from presentation products; do not make one HRRP-like reference definition universal |
| Reconstructed trajectories | `build_risk_trajectories()` | **Do not reuse** for operational history | Useful demonstration visualization only | It reruns current code over current history and can rewrite historical-looking values; Phase 5 trajectories must read persisted operational estimates |
| Application product builders | `build_application_products()`; eight CSV headers and tests | **Reference only** | The eight products reveal useful consumer needs and relationships | Schemas are implicit, all products mandatory, provider assumptions fixed, and synthetic generator fields leak into generic rows. Design versioned capability-aware products cleanly |
| Product IDs/suite | app/data manifest and README | **Reference only** | `episodes_current`, estimates/trajectories, queue, timeline, metrics, lineage, and geography are a credible candidate suite | Maintainer must choose the first default suite; no exact-eight requirement should become platform law |
| Product access layer | `app/R/data-access.R`; deployment config | **Adapt** | Logical IDs with local CSV/RDS selection and explicit unsupported database behavior point in the right direction | Introduce contract validation, capability/optional behavior, manifest freshness, and storage ports; avoid app knowledge of backend details |
| Shiny application | `app/app.R`; `app/R/app-init.R` | **Reference only** | Confirms deployment-neutral startup and product-only consumption | Current UI is a smoke shell rendering two products and loading all eight. Build a minimal clean UI from new products rather than copying layout/code |
| Product provenance | `scripts/lib/product-provenance.R`; `PRODUCT_MANIFEST.yml`; tests | **Adapt** | Coherent set identity, hashes, row counts, generation inputs, and tamper detection are high-value patterns | Separate general run/product provenance from Git-backed reference checkpoints, exact product IDs, and synthetic input paths |
| A/B/C provenance lifecycle | `docs/operations/provenance-lifecycle.md`; deployment manifests | **Reference only** | Strong reasoning for generation, reviewed product, artifact, and publication boundaries | Git commit A/B/C is a reference workflow, not hospital operational-history identity; translate principles into generic run/artifact provenance |
| Validation modes | `scripts/lib/validation-modes.R`; `test-validation-modes.R` | **Adapt** | Correctly separates development, generation, artifact, publication, and future release concerns | Rebuild around new components and operations; do not carry exact old tree checks |
| Human operations registry | `docs/operations/operations.yml`; operations guides/tests | **Adapt** | Stable IDs linked to scripts/docs and drift validation strongly support human-first operation | Create new operations only as capabilities exist; do not copy obsolete command names or sourced-file orchestration |
| Operations documentation form | `docs/operations/` | **Reference only** | Purpose/prerequisite/command/side-effect/recovery patterns are exemplary | Write clean guides against new operations rather than copying workflows tied to old paths and products |
| Connect Cloud allowlist builder | `deploy/connect-cloud/bundle.yml`; builder/validator scripts; deployment tests | **Adapt** | Explicit allowlist, generated root adapter, clean-copy validation, safe-path/secret checks, and separation from platform root are strong | Target runtime list and application will differ; builder is target-specific and should be revisited in Phase 8 |
| Generated deployment publisher | `scripts/lib/deployment-publication.R`; profiles; publication tests | **Adapt** | Staging, markers, clean state, no symlinks, tree comparison, dry run, and opt-in commit/push are mature safety patterns | Current implementation assumes Git and fully generated ownership; adapt only after clean target ownership/profile contracts are approved |
| Connect-specific files and exact manifests | `deploy/connect-cloud/templates/`; built artifacts | **Do not reuse** as architecture | Useful evidence of one target's current packaging | Generate new target files from the clean app/runtime; never place hosting adapters at the platform root |
| Cross-component tests | `tests/platform/` | **Adapt** selectively | Canonical independence, deterministic reference, future-information, tamper, app boundary, allowlist, and publication safety cases are valuable | Rewrite against new public interfaces; discard exact old filenames, IDs, row counts, and eight-product assumptions unless deliberately retained as reference fixtures |
| Exact project-structure tests | `test-project-structure.R` | **Do not reuse** | Protected the old reference distribution | Would make historical paths architectural constraints; new structure checks must identify platform versus reference-profile invariants |
| `targets` graph | `pipelines/_targets.R` | **Reference only** | Meaningful stage names aid readability and reproducibility | Orchestration technology should be selected after stable operations; do not make `targets` or its target names public contracts |
| `renv` setup | `.Rprofile`, `renv.lock`, `renv/` | **Reference only** | Demonstrates one reproducible R environment | Initialize in the clean repository only when real dependencies exist; generate a fresh lockfile |
| Advanced methodology directories | `methodology/` and related docs | **Reference only** | Useful inventory and boundary evidence | Do not bring into core during bootstrap; evaluate provider/companion/private placement when a method has a concrete use case |

## Direct-reuse status

There are no bootstrap-approved **Reuse directly** assets. This does not mean
the old implementation is low quality. It means that all inspected candidates
either use draft contracts, embody an old representation, or need a clean
interface that does not exist yet. The first direct-reuse decision, if any,
must be recorded during its implementation phase after:

1. the target contract is accepted;
2. the exact old file and dependencies are reviewed;
3. licensing and attribution are confirmed;
4. copied behavior is covered by new-repository tests; and
5. no sibling-repository path remains.

## Highest-confidence candidates

These candidates appear especially valuable. “High confidence” means high
confidence in reuse of knowledge or adapted behavior, not pre-approval to copy.

| Current path | Target subsystem | Classification | Reason | Risks / required adaptation |
|---|---|---|---|---|
| `contracts/schemas/discharge-episode.yml` and `episode-event.yml` | Canonical contracts | **Adapt** | Strong episode root, observation/terminal fields, and dual event/recorded-time semantics | Review nullability, conditional rules, capability model, compatibility, corrections, and terminology |
| `contracts/schemas/baseline-risk.yml` | Baseline canonical domain | **Adapt** | Preserves source score/probability/category and provenance without silently replacing baseline | Enforce conditional value rule; distinguish adapter/model identity and availability; reconcile horizon semantics |
| `contracts/schemas/workflow-task.yml` and `intervention.yml` | Operational canonical domains | **Adapt** | Correct conceptual separation of work and care actions | Add lifecycle ordering and capability/optionality decisions |
| `docs/architecture/canonical-bundle-boundary.md` | Canonical bundle design | **Reference only** | Detailed evidence on logical domains, keys, time, metadata leakage, and R mechanics | Use questions/invariants, not the seven-member R list |
| `tests/fixtures/canonical-bundle-fixture.R` | Independent conformance fixture | **Adapt** | Proven source-independent entry at the boundary | Rebuild to the new bundle and capability representation |
| `implementations/synthetic-demo/R/generate-source-data.R` | Synthetic reference | **Adapt** | Rich deterministic fictional source ecosystem and longitudinal relationships | Needs Phase 3 line-level review, new config/run contract, and removal of downstream coupling |
| `implementations/synthetic-demo/R/map-to-canonical.R` | Synthetic producer | **Adapt** | Explicit source-owned mapping and pre-handoff validation | Reconcile new schemas, producer result, capability declarations, and provenance |
| temporal functions/tests in `engine/R/risk-provider.R` | Runtime temporal core | **Adapt** | Future-information exclusion and terminal eligibility are central, already tested behaviors | Move under accepted eligibility/estimand semantics and broaden lifecycle coverage |
| `scripts/lib/product-provenance.R` and tests | Run/product provenance | **Adapt** | Hashing, coherent set IDs, tamper detection, and input attribution are mature patterns | Remove Git-as-universal-identity, fixed product suite, and synthetic path assumptions |
| deployment builder/publication helpers and tests | Deployment operations | **Adapt** | Allowlisting, staging, generated ownership, validation, dry-run, and conservative external mutation are strong | Separate generic artifact concepts from Connect/Git/fully-generated target policy |
| operation registry/docs validator | Operations | **Adapt** | Machine-checkable human operation ↔ implementation ↔ docs mapping fits True North | Recreate incrementally around clean operations, avoiding obsolete paths and duplicated semantics |

## Assets intentionally not used as foundations

- The mixed `canonical-pipeline.R` file is not the runtime architecture.
- The baseline/event placeholder is not the provider-extension design.
- Recomputed weekly trajectories are not operational history.
- Eight fixed CSV products are not the universal product suite.
- The smoke Shiny app is not the application product definition.
- Git commits A/B/C are not general run identity or persistence semantics.
- Exact old paths and structure tests are not clean repository requirements.
- Connect Cloud templates and manifests are not core platform files.
- `targets`, `renv`, and the old internal package layout are not selected merely
  because they worked previously.

## Just-in-time review checkpoints

- **Phase 2:** re-read all canonical schemas, vocabularies, validation code,
  compatibility notes, canonical fixture, and boundary tests.
- **Phase 3:** line-review generator, mappings, simulation configuration,
  synthetic integration tests, and fictional safety language.
- **Phase 4:** line-review temporal/provider code and tests, but design the
  estimand and registry before considering copied code.
- **Phases 5–6:** inspect state/product builders and provenance only after
  history/product contracts exist; reject reconstructed-history behavior.
- **Phase 7:** inspect operation registry, scripts, and human guides against the
  clean operation API.
- **Phase 8:** inspect builder, validator, publication helper, profiles, and
  tests against approved target ownership.
- **Phase 9:** inspect structured validation and console reporting as evidence;
  do not infer an observability system that was not present.

Every checkpoint should update this document or record a changed classification
in the implementation record.

## Phase 2.2 field/rule review outcome

The first clinical profile was designed cleanly before the Phase 2 evidence was
re-read. The review retained the existing **Adapt** classifications; no asset
became eligible for direct reuse and no classification changed materially.

| Evidence | Adapted semantic | Rejected or deferred shape |
|---|---|---|
| `contracts/schemas/discharge-episode.yml` | episode/patient/index-encounter identity; admission, discharge, follow-up, readmission, and death timestamps | draft versioning, permissive extras, source `episode_status`, facility/service/disposition/team fields, and unenforced terminal rules |
| `contracts/schemas/baseline-risk.yml` | compound episode/model/version/score-time identity and preservation of probability/score/category | provider-ambiguous model naming, advisory-only value rule, prediction/calibration fields, required source system, and inherited discharge-availability assumption |
| `contracts/schemas/episode-event.yml` | event identity, episode foreign key, and event-versus-recorded time | subtype/status and unbounded numeric/text value fields, required source-system mechanics, and missing episode-window enforcement |
| `contracts/vocabularies/` | versioned controlled event values | wholesale event/status lists, task/intervention concepts, and arbitrary namespaced extensions in the initial line |
| `tests/fixtures/canonical-bundle-fixture.R` | direct source-independent handoff and typed zero-row test intent | seven mandatory R members, tibble/container shape, later runtime context, and exact old values |
| `tests/platform/test-canonical-boundary.R` | ordering independence, foreign-key failure, and no synthetic import principles | old exact-domain set and post-canonical runtime/product coupling |
| `engine/R/contract-validation.R` | multi-issue field/type/key validation principle | code, package dependencies, root discovery, schema API, and first-error boundary behavior |

The resulting clean differences and precise field semantics are authoritative in
[Initial Canonical Clinical Profile](canonical-clinical-profile.md) and are
recorded in the Phase 2.2 implementation record.
