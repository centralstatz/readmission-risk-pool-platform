# Governance and validation architecture assessment

## Status and scope

**Status:** v0.2.0 governance assessment and recommendation; no authoritative
governance change implemented

This assessment evaluates the governance system used to develop and release
Readmission Risk Pool. Operational safety remains binding. The current
authority hierarchy, phase model, validation policy, documentation rules, and
release/distribution requirements are treated as evidence rather than presumed
future constraints.

The assessment is forward-only. Published Platform and Hospital Implementation
`v0.1.0` source, tags, artifacts, repositories, and evidence remain immutable.
It builds on the [installed RRP and independent project architecture
assessment](installed-software-project-model-assessment.md) and the [v0.1.0
clean-room adoption assessment](../development/hospital-implementation-v0.1.0-adoption-assessment.md).
No validator, test, workflow, authority document, `AGENTS.md`, runtime, release,
or project mechanism is changed here.

## Executive conclusion

Current RRP governance is materially over-scoped for ordinary `v0.2.0`
development. It was effective at safely constructing the first complete
vertical system and publishing `v0.1.0`, but it now makes historical phase and
Hospital-distribution completeness part of the definition of every coherent
development tree.

The clearest evidence is the default development validator. It unconditionally
composes:

- 14 repository-level validators spanning documentation through the Hospital
  distribution;
- all 12 Phase 0–11 focused test runners, currently 342 underlying tests; and
- repeated temporary package installation, integration, artifact, distribution,
  Git-realization, and clean-copy/acquisition work within those suites.

The prior documentation-only architecture assessment therefore ran 170
top-level checks, including all 94 Phase 11 tests, and took approximately nine
minutes in this workspace. The strict checkpoint adds 12 historical phase
checkpoint validators and has most recently reported 233 top-level checks. CI
runs documentation validation separately and then runs that full checkpoint,
which validates documentation again.

This breadth is not required to establish that a new Markdown assessment has
valid links and portable paths. It impedes fast feedback and makes objective
architecture work more ceremonial, but it does not prevent change absolutely:
maintainers can update code, authority documents, record text, validators, and
tests together. The problem is that the cost and coupling are universal rather
than proportional.

The essential rigor is not in question. RRP must preserve:

- canonical, estimand, provider, temporal, history, product, and compatibility
  semantics;
- software and test correctness;
- privacy, secret, fictional-fixture, and diagnostic boundaries;
- explicit executable-code trust;
- safe local mutation and explicit external mutation authorization;
- dependency and supported-environment evidence;
- generated artifact integrity and target validation; and
- exact release and publication provenance.

Much of that rigor is currently applied at the wrong lifecycle stage. Clean
source, full dependency reconstruction, complete cross-component integration,
Hospital distribution generation, pristine Git realization, acquisition
proofs, release inventories, and publication-state checks protect release or
publication boundaries. They should not be the default proof for a
documentation-only edit or an unrelated component change.

Governance can be substantially simplified without weakening analytical or
software correctness by making validation proportional to the changed
boundary, assigning checks to explicit owners, and retaining broad clean
proofs in CI, release-candidate, artifact, target, and publication workflows.

The recommended philosophy is supported by the actual system:

> Validate the smallest boundary that can be affected locally; validate
> integration where boundaries meet; validate the complete installed product
> in CI and at release; validate exact remote identity at publication.

## Current governance inventory

| Governance source | Purpose and scope today | Enforcement | Dependencies and future relevance |
|---|---|---|---|
| `AGENTS.md` | Agent working agreement, authority reading order, phase ownership, architecture rules, human operations, validation commands, release safety, and privacy | Human/agent instruction plus text assertions in Phase 0 validation | Safety, privacy, human-first operations, and architectural boundaries remain useful. Phase chronology, current Hospital model, and universal development validation are historical or over-scoped. |
| Platform True North | Durable product identity, ownership, semantic boundaries, and decision tests | Claimed top authority; required and linked by documentation validation | Most design principles remain valid under installed RRP. Acquisition/distribution wording may later require a prospective revision. |
| Platform Architecture | Current target layers, dependencies, repository shape, Hospital distribution model, and conformance expectations | Claimed authority over plan/software; required by navigation; referenced by tests/docs | Semantic layers remain relevant. Repository and Hospital delivery sections are under prospective reconsideration. |
| Platform Implementation Plan | Phase 0–11 clean-build sequence and cross-phase rules | Claimed authority; checkpoint and repository validators encode its phase shapes | Valuable historical construction plan. It should not remain the active development lifecycle after Phase 11 completion. |
| Implementation Record | Append-only evidence of planned/actual work, validation, and next steps | Human record plus many validators that grep exact headings/status phrases | Important historical provenance and decision evidence. Exact prose/headings should not be executable product requirements. |
| Implementation conventions | Readability, dependency, R-style, boundary, and change-completeness guidance | Human/agent guidance | Keep concise coding principles; scope “update everything together” to affected public interfaces. |
| Architecture assessments and open decisions | Retain evidence and recommend future choices | Human review; some assessments are required governing documents | Keep as decision evidence. Clearly label historical, current, proposed, accepted, and superseded status. |
| Documentation indexes and START HERE | Navigation and reading order | Machine-checked links and selected required targets | Broken-link and current navigation checks are valuable and fast. Requiring every historical document in central current navigation is not. |
| Machine-readable contracts | Versioned public semantics | Contract validators, unit/conformance suites, integration tests | Core scientific/software governance; keep strict and component-owned. |
| `RELEASE.yml` and governance files | Development/release versions, published state, targets, license, stewardship | Repository/checkpoint/release/publication validation | Keep as software-release authority, not normal project or unrelated component governance. |
| Operation registry and operation guides | Stable human command, side-effect, classification, recovery, and agent alignment | Phase 7 repository tests and exact command-text checks | Human-first principle remains. Validate affected operations rather than the full historical catalog after every change. |
| Repository policy validator | Sibling independence, portable executable paths, obvious secrets, fictional fixtures | Included in every development/checkpoint run | Small, cross-cutting source-safety checks are appropriate defaults; scope scans and clarify their non-exhaustive nature. |
| Documentation validator | 40 required documents, every Markdown local link, 25 navigation sources, portable paths | Standalone, included in development/checkpoint, and duplicated in CI | Keep fast document correctness. Simplify normative-document lists and distinguish current from historical archives. |
| Repository component validators | Required files, exact identities, prohibited dependencies, phase scope, record headings | All run unconditionally in development/checkpoint | Retain useful component invariants but assign ownership and run them only for affected components or broad CI. Remove phase-era absence/presence assertions after transition. |
| Phase 0–11 focused suites | Unit, contract, integration, operation, artifact, distribution, release, and publication behavior | All run unconditionally in development/checkpoint; separately callable | Keep tests, reorganize by component/boundary, and select them by change. Phase labels can remain historical aliases during migration. |
| Development validator | One aggregate of all repository validators and all Phase suites | `AGENTS.md` directs it for all intentional work | Replace as the universal local default with fast and explicit scoped validation. Retain a broad active-product integration command. |
| Checkpoint validator | Development aggregate plus every Phase checkpoint | CI on push/PR and release/publication prerequisites | Historical milestone checkpoint has outlived its name. Replace with release/integration profiles aligned to the installed product. |
| GitHub Actions validation | Restores `renv`, validates docs, then runs full checkpoint on every push/PR | Machine CI | Broad confidence belongs in CI, but duplicate docs and one serial universal job should be partitioned by ownership and lifecycle. |
| Hospital distribution/Git realization tests | Generated Hospital artifact, embedded Platform, closed inventory, pristine Git, acquisition, tamper, and wrappers | Phase 11 suite and repository/checkpoint validators | Retain as immutable v0.1.0 historical evidence. Run only when maintaining the legacy machinery until it leaves the forward product path. |
| Release preparation | Clean source, full checkpoint, exact candidates, inventories, environments, clean acquisition, and readiness | Explicit maintainer operation | Strong release-candidate rigor. Rebuild prospectively around installed software, not normal development. |
| Publication workflow | Zero-mutation preflight, remote identity, exact tags/releases, recovery, verification | Explicit authorized maintainer operation | Keep strict and publication-only. Never a local development default. |
| Artifact and target validators | Closed runtime inventory, checksums, compatibility, destination safety, target-specific Git | Component tests and explicit build/validate operations | Keep strict at generated artifact/target boundaries. Do not apply their invariants to editable source projects. |
| Root `renv` and support evidence | Reproducible maintainer/reference environment and tested R line | CI setup, doctor, repository and release validation | Keep for development/release until package topology changes. Independent projects will own separate dependency governance. |

## Current authority graph

### Claimed hierarchy

The repository explicitly states:

```text
Platform True North
        ↓
Platform Architecture
        ↓
Platform Implementation Plan
        ↓
Platform Implementation Record
        ↓
software and tests
```

`AGENTS.md` instructs agents to read and follow that chain, keep work within the
active phase, update the implementation record, use documented operations, and
run development validation during intentional work. Human operation guides
claim authority for exact commands. Contracts and tests become executable
authorities for implemented behavior but remain subordinate to accepted
architecture. `RELEASE.yml` separately owns current version and publication
state.

### Machine-enforced graph

The effective authority graph is denser:

```text
AGENTS.md ───────────────┐
  │ mandates commands   │ exact command text checked by Phase 0
  ▼                     │
validate.R ─────────────┴───────┐
  ├── documentation validator  │
  ├── 13 other repository validators
  ├── Phase 0–11 suites
  └── checkpoint: Phase 0–11 checkpoint validators
                    │
                    ├── require exact historical files/paths
                    ├── grep implementation-record headings/status
                    └── enforce phase-specific scope/absence rules

GitHub Actions → documentation validator + checkpoint validator
release preparation → checkpoint + candidate/distribution/acquisition proofs
publication preflight → checkpoint + release evidence + remote-state checks
```

Documentation validation requires named authority documents, checks links
across all Markdown, and requires selected navigation sources to link to a
fixed graph. Several repository validators read the implementation record and
require exact iteration headings. The Phase 0 checkpoint checks that
`AGENTS.md` and the human validation guide contain specific validation and
publication commands. Consequently the record describes validation, while
validation requires the record and guidance to describe itself.

### Circularity and change-lock coupling

There is no unsolvable semantic cycle, because one change can update all sides.
There is meaningful governance circularity:

1. `AGENTS.md` requires the development validator for intentional work.
2. The validator checks `AGENTS.md`, documentation authorities, exact operation
   command text, historical file layouts, and implementation-record prose.
3. Architecture changes are instructed to update architecture and plan before
   software, while the current validator defines coherence partly as continued
   presence of the architecture being changed.
4. Removing or relocating an obsolete component therefore requires changing
   architecture, plan, guidance, record, validators, tests, and navigation in
   one coordinated step even when the component has no dependency on the new
   product.

This is not evidence that those files are wrong. It is evidence that historical
process completion and current product correctness are too tightly bound.

### Historical truth versus future truth

| Historical truth to retain | Future normative status |
|---|---|
| Phases 0–11 built and released the v0.1.0 system | Does not require v0.2.0 work to retain Phase 0–11 as its development lifecycle |
| The generated Hospital Implementation was the selected v0.1.0 release architecture | Does not require it to remain the v0.2.0 acquisition architecture |
| Phase tests prove what the release machinery did | Does not require every phase suite to run after every unrelated change |
| The implementation record accurately records decisions and evidence | Does not make record headings runtime or product interfaces |
| Clean source, closed inventories, and pristine Git protected exact release outputs | Does not make those states valid requirements for editable projects or documentation |
| `v0.1.0` publication targets and evidence are exact | Does not make future packaging use the same two-product release graph |

## AGENTS.md assessment

`AGENTS.md` contains several different kinds of rules that should not share one
universal lifetime.

| Rule family | Classification | Forward recommendation |
|---|---|---|
| No destructive/unapproved external mutation; no commit/push/publish/deploy without authorization | Operational safety | **KEEP GLOBAL.** |
| Never expose PHI, secrets, raw records, or private mappings | Operational safety/privacy | **KEEP GLOBAL.** Extend into project and artifact rules. |
| Sibling repository is evidence only and never a runtime dependency | Architectural/source safety | **KEEP GLOBAL** while the sibling exists. |
| Human operations and agents invoke the same tested behavior | Architectural/operational invariant | **KEEP GLOBAL**, with project-aware operations replacing historical commands later. |
| Canonical/source, estimand/provider, history/product, app, deployment, and diagnostic separations | Architectural invariants | **KEEP GLOBAL** until prospectively replaced by accepted architecture; express in component tests. |
| Human-readable R and dependency conventions | Coding/development convention | **KEEP GLOBAL** but concise. |
| Work must remain in an active numbered phase | Historical process rule | **HISTORICAL ONLY** after Phase 11; replace with versioned objectives/ADRs and component ownership. |
| Detailed ownership paragraphs for completed Phases 4–11 | Historical/current-state inventory | **KEEP BUT SCOPE** as historical navigation, then move out of the global agent contract. |
| Generated Hospital distribution is the selected physical composition | v0.1.0 architectural/release rule | **HISTORICAL ONLY** for future development if the installed-project direction is accepted. |
| Exact v0.1.0 release/publication commands in global intent mappings | Release requirement/history | **MOVE TO PUBLICATION** documentation; keep global only as “external mutation requires explicit authorization.” |
| Every meaningful iteration appends the large implementation record | Documentation/process convention | **SIMPLIFY.** Retain material ADR/assessment/release evidence, but do not require one prose schema for every change. |
| Every intentional change runs full development validation | Validation requirement | **REMOVE as a universal rule** and replace with change-scoped minimum plus explicit integration/release profiles. |
| Each component section names its focused suite | Validation guidance | **KEEP BUT SCOPE** through a maintained ownership/test manifest rather than phase prose. |
| “Do not invent alternate validation behavior” while governance is under review | Process-control rule | **KEEP** for normal work, but it cannot prohibit an explicitly authorized governance assessment. The present task's conflict is evidence for making validation profiles explicit. |
| Update versions/tests/examples/docs/record together for any interface change | Change-completeness rule | **KEEP BUT SCOPE** to affected public interfaces and compatibility claims. |

The globally binding `AGENTS.md` should eventually become shorter: operational
safety, privacy, durable component boundaries, coding conventions, change
ownership, and how to select validation. Phase history and release-specific
procedures should live in versioned history or specialized maintainer guides.

## Validation architecture map

### Current composition

`Rscript operations/validate.R --mode development` does not inspect the diff or
accept a component scope. It always loads every validation module and runs 26
result groups:

```text
14 repository validators
  documentation, repository policy, specifications, canonical, synthetic,
  runtime/provider, history, products/app, operations, application artifact,
  Connect, observability, producer, Hospital distribution

12 subprocess suites
  Phase 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
```

The latest complete run summarized 170 top-level checks. The subprocess suites
contained:

| Suite | Tests | Principal boundary | Typical relative cost |
|---|---:|---|---|
| Phase 0 | 10 | Documentation/policy fixtures and mode rules | Medium for docs because fixtures copy repository material |
| Phase 1 | 14 | Foundation specification vocabulary | Fast |
| Phase 2 | 38 | Canonical contracts, relationships, and time | Fast to medium |
| Phase 3 | 24 | Synthetic generation/mapping | Medium |
| Phase 4 | 55 | Runtime, estimand, provider, package installation | Medium |
| Phase 5 | 18 | History contracts, DuckDB atomicity/restart | Medium to expensive |
| Phase 6 | 17 | Products, materialization, app | Medium |
| Phase 7 | 8 | Human operations and clean lifecycle | Expensive integration |
| Phase 8 | 22 | Reduced artifact and Connect realization | Expensive artifact/Git integration |
| Phase 9 | 16 | Diagnostic contract/privacy/lifecycle | Fast to medium |
| Phase 10 | 26 | Producer substitution through downstream stack | Expensive integration |
| Phase 11 | 94 | Hospital distribution/Git, release preparation/publication behavior, acquisition | Most expensive and broadest legacy/release proof |

The cost is not just 342 assertions. Multiple suites reinstall `rrpruntime`,
create isolated stores, build artifacts, initialize Git repositories, generate
Hospital distributions, and run copied acquisition flows. Repository validators
also repeat some identity, integration, and implementation-record checks that
focused suites cover more deeply.

`checkpoint` first runs the same complete development composition, then adds
all 12 Phase checkpoint validators. Those checkpoints assert required files,
historical phase boundaries, specific implementation-record headings, and
absence/presence assumptions. The current name still reports a “Phase 11
Hospital distribution checkpoint” even though Phase 11 is complete and
development is `0.2.0-dev`.

GitHub Actions runs on every push and pull request:

```text
restore full renv environment
        ↓
validate documentation
        ↓
run checkpoint
        ├── validates documentation again
        ├── runs every repository validator
        ├── runs all 342 Phase tests
        └── runs every historical checkpoint
```

### Why a documentation assessment ran everything

No dependency analysis selected the broad matrix. It ran because:

1. `AGENTS.md` states “During intentional work, run” development validation.
2. The previous assessment followed that universal instruction.
3. Development mode has no narrower profile and no change-aware routing.
4. Phase 11 is unconditionally appended just like Phase 1, regardless of
   changed files.

The documentation did not affect Hospital archive extraction, Git realization,
provider execution, DuckDB, Shiny construction, Connect packaging, or release
publication logic. Those proofs provided general regression confidence, not
evidence specifically necessary for the document.

### Duplication and accidental complexity

- Documentation validation runs standalone in CI and again inside checkpoint.
- Development runs repository validators and phase suites with overlapping
  contract, file-presence, and integration claims.
- Checkpoint adds historical checkpoint checks after all focused suites have
  already passed.
- Multiple phase suites reinstall the same internal package and rebuild related
  vertical flows rather than sharing a package/component test stage.
- Phase 10 and Phase 11 repeat downstream history/product/app/artifact evidence
  already owned by earlier components because milestone substitution and
  acquisition proofs were designed as complete vertical demonstrations.
- Validators validate documentation assertions about validators and require
  exact implementation-record narrative.
- Phase 0 checkpoint now requires license, publication, and release files added
  much later, so its name no longer represents its original scope.
- Hospital distribution repository checks and 94 tests run on all future
  development even though the forward architecture recommends retiring that
  user path.

These repetitions were defensible milestone evidence. They are poor default
change feedback after the milestones are historical.

## Governance classification matrix

| Mechanism | Classification | Protected invariant and future owner |
|---|---|---|
| Non-destructive operation, explicit external mutation authorization | **KEEP GLOBAL** | Prevents irreversible/unintended effects; repository and publication operations. |
| PHI/secret/private-data exclusions and privacy-safe diagnostics | **KEEP GLOBAL** | Protects patients and institutions; local checks plus component/project/artifact tests. |
| Portable paths and no sibling runtime dependency | **KEEP GLOBAL** | Ensures distributable software; fast repository checks and clean-install CI. |
| Durable semantic dependency boundaries from True North | **KEEP GLOBAL** | Preserves analytical architecture; component APIs and integration tests. |
| Basic documentation links and portable documentation paths | **KEEP GLOBAL** | Prevents unusable guidance; fast docs validation. |
| Fixed list of 40 “governing” documents and 25 navigation graphs | **SIMPLIFY** | Preserve current-authority discoverability through a smaller current index; move historical evidence to an archive index. |
| Exact AGENTS/human command-text equality across the full catalog | **KEEP BUT SCOPE** | Preserve human/automation parity for changed active operations; do not bind historical release commands to all work. |
| Repository-wide obvious-secret and fictional-fixture scans | **KEEP GLOBAL** | Cheap defense in depth; retain non-exhaustive wording and add project/artifact-specific checks. |
| Specification and contract parsing/identity uniqueness | **KEEP BUT SCOPE** locally; **MOVE TO CI** broadly | Run affected contract suites locally and all public-contract compatibility in CI/release. |
| Component repository required-file/prohibited-dependency checks | **KEEP BUT SCOPE** | Component owners run them when relevant; built-package inventory eventually replaces source-tree presence where appropriate. |
| Focused semantic/unit suites | **KEEP BUT SCOPE** | Run affected components locally; broader combinations in integration CI. |
| Default development aggregate of every suite | **SIMPLIFY** | Replace with fast baseline plus explicit component/integration profiles. |
| Broad active-core end-to-end reference workflow | **MOVE TO CI** | Protects cross-component compatibility without blocking every local edit. |
| Clean installed-software/example-project acceptance | **MOVE TO CI** and **MOVE TO RELEASE** | Protects package completeness and acquisition in appropriate environments. |
| All Phase 0–11 checkpoint namespaces | **HISTORICAL ONLY** | Retain v0.1.0 evidence; future validation uses component/boundary names. |
| Exact implementation-record heading/status checks | **REMOVE** from executable validation | Preserve record as historical evidence; product correctness should not depend on prose headings. |
| Phase-specific “later directory unauthorized” checks | **HISTORICAL ONLY** | They prevented premature bootstrap scaffolding; Phase 11 completion ends that purpose. |
| Full Hospital distribution/Git/acquisition suite on normal development | **HISTORICAL ONLY** as universal governance | Run only for intentional legacy changes while retained; v0.1.0 tag already preserves release proof. |
| Embedded Platform and recipient-editable closed inventories | **REMOVE** from future governance | Installed software/package inventory and project contract validation replace them. |
| Zero-commit/zero-remote checks on editable Hospital repositories | **REMOVE** from future user validation | Target/output ownership checks remain scoped to generated artifacts where necessary. |
| Closed reduced-artifact inventory and checksum validation | **KEEP BUT SCOPE** | Artifact builder/validator owns immutable deployable output integrity. |
| Connect destination/Git realization safety | **KEEP BUT SCOPE** | Connect target owns its generated output, not the project or repository generally. |
| Root `renv` consistency on every doc change | **KEEP BUT SCOPE** | Dependency/package changes, CI, clean-install, and release own it. |
| Complete environment reconstruction and supported-OS matrix | **MOVE TO CI** and **MOVE TO RELEASE** | Protects installability/support claims without repeating locally for docs. |
| Clean source and exact release inventory | **MOVE TO RELEASE** | Protects candidate provenance. |
| Clean-copy/acquisition proof | **MOVE TO RELEASE** | Protects installed release independence. Future proof should use built software/example project. |
| Tag/release absence, remote identity, credentials, partial-stage recovery | **MOVE TO PUBLICATION** | Protects irreversible external publication only. |
| Hospital source mapping/provider/estimand/config validation | **MOVE TO PROJECT CONTRACT** | Independent project validity is not RRP development-repository validity. |
| Runtime/build identity and provenance | **KEEP BUT SCOPE** to runtime/build | Captures exact execution evidence without Git/repository rigidity. |
| Package topology-specific governance | **RECONSIDER** | Establish package-agnostic principles now; select physical topology later. |
| Append-only implementation record for material assessments/releases | **KEEP BUT SCOPE** | Useful provenance, but not a test oracle or mandatory format for routine edits. |

## Change-scoped validation proposal

This is a conceptual routing model, not an implemented file-diff algorithm.
Maintainers should be able to add explicit validation when risk crosses more
than one row. Ambiguous changes take the union of relevant scopes.

| Change category | Required local evidence | CI/integration evidence | Not normally required locally |
|---|---|---|---|
| Documentation-only, non-authoritative | Link/navigation/portable-path check; Markdown/style check; `git diff --check` | Same fast documentation job | Runtime, DuckDB, app, artifact, Hospital, release, or acquisition suites |
| Architecture/governance assessment | Documentation checks; authority/status consistency review; `git diff --check` | Optional docs job | Full product proof unless the assessment changes executable policy |
| Authoritative architecture or governance policy | Documentation checks plus focused tests for any machine-enforced policy changed | Governance-consistency job and affected component/integration scopes | Unaffected component suites |
| Repository safety/policy code | Focused repository-policy tests and docs if behavior changes | Full fast source-safety scan | Clinical/runtime/distribution flows unless dependencies exist |
| Contract/schema vocabulary | Parser/identity checks and affected contract/conformance suite | Public contract compatibility matrix and dependent integration tests | Deployment/release publication checks |
| Canonical/producer/source mapping | Canonical and producer unit/conformance tests | Synthetic and independent-project source-to-runtime integration | App/target/release suites unless public output contracts change |
| Runtime/estimand/provider | Package unit tests, affected conformance, package check | Canonical-to-history integration with reference and alternate provider/estimand | Hospital distribution and publication proofs |
| History port or persistence adapter | History unit/adapter atomicity/restart tests | Runtime-to-products integration and supported backend CI | App/target tests unless access contracts change |
| Product/materialization/app | Product conformance, materialization, app construction tests | History-to-app integration and reduced-artifact smoke test | Source/provider/release publication tests |
| Reduced artifact | Artifact build/tamper/standalone validation | Supplied app/product integration and active target smoke tests | Hospital distribution/release publication |
| Deployment target | Artifact compatibility plus target-specific builder, safety, and standalone validation | Target environment smoke test where available | Canonical/provider/history suites unless artifact contract changed |
| Installed packaging/assets | Package build/check, installed inventory, clean-library load, synthetic example-project acceptance | Supported R/OS clean-install matrix | Legacy Hospital distribution unless intentionally maintained |
| Project contract/tooling | Project schema/trust/path/dependency tests and synthetic/custom fixture projects | Clean initialized-project end-to-end acceptance | RRP release publication checks |
| Dependency or support-matrix change | Lock/metadata consistency and affected package tests | Clean restore/install in claimed environments | Unrelated target/publication checks |
| Release tooling | Focused deterministic release/refusal/recovery tests | Dry candidate construction in CI | Live publication |
| Release candidate | Full active component and integration suite; clean package build/install; example project; artifacts/targets; licenses; dependency/support evidence; exact inventory/provenance | Repeat in supported clean environments | Retired Hospital architecture unless still a released product target |
| Publication | Zero-mutation preflight, exact candidate identity, remote/tag/release state, authorization, partial-stage recovery, remote acquisition/verification | Publication workflow only | Rebuilding unrelated components after exact candidate verification |

### Selection principles

1. A test has one primary owner and may have explicit downstream consumers.
2. Local selection should be deterministic and inspectable, with an override to
   add broader scopes.
3. CI should compute or declare affected components conservatively; path
   routing is a convenience, not the sole correctness boundary.
4. Changes to public contracts trigger declared dependent integration suites.
5. A broad active-product integration profile remains available on demand and
   on main/nightly schedules.
6. Release validation never relies solely on a changed-file calculation.
7. Retired/historical tests remain runnable from the historical tag or an
   explicit legacy scope; they do not stay in the universal active matrix.

## Fast checks and expensive proofs

### Fast default development validation

The normal local default should target feedback measured in seconds, preferably
under a minute for an unchanged tree:

- syntax/parsing for changed R/YAML files;
- documentation links/navigation when Markdown changes;
- portable paths, obvious secrets, and fictional-fixture classification;
- repository hygiene and `git diff --check`; and
- changed component's fast unit/contract tests when determinable.

It should report selected scopes and explain how to request broader validation.

### Component-scoped validation

Each maintained component should declare its source, contracts, focused tests,
and downstream integration triggers. Examples are canonical, runtime/provider,
history/DuckDB, products/app, artifact, target, project tooling, and release
tooling. Phase runner names may remain compatibility aliases temporarily, but
new ownership should not use phase numbers.

### Integration validation

Integration profiles should test meaningful seams rather than every historical
milestone:

- example project → canonical → runtime/provider → history;
- history → products → app;
- products/app → reduced artifact;
- artifact → each supported target; and
- independent project substitution across the supported stack.

Run them when an upstream/downstream contract changes, before merge for affected
areas, and as broad CI on the main branch or scheduled cadence.

### CI validation

CI can afford broader confidence but should remain understandable and
parallelizable:

- fast source/docs/policy job;
- package/component jobs;
- contract compatibility job;
- active-core integration jobs;
- packaging/clean-install matrix; and
- artifact/target jobs.

Pull requests can run affected jobs plus a conservative core set. Main/nightly
can run the full active matrix. CI should not repeat the same document check
inside another job unless the second boundary validates a distinct built
artifact.

### Release-candidate validation

Release preparation should be comprehensive and clean:

- all active supported components and integrations;
- package build/check and exact installed inventory;
- clean dependency/install reconstruction in supported environments;
- synthetic/example and independent-project acceptance;
- artifact and supported target validation;
- license, security, support, compatibility, migration, and changelog state;
- deterministic promises and exact candidate provenance; and
- clean acquisition independent of the development checkout.

This is where broad cost is justified.

### Publication validation

Publication should validate the already prepared immutable candidate, not
silently rebuild it. It owns authorization, remote/repository identity,
tag/release conflicts, checksums, staged recovery, upload, and post-publication
acquisition. The existing fail-closed principles remain strong.

## Phase-governance assessment

Phase 0–11 served an important bootstrap purpose: each milestone created a
working boundary and prevented premature scaffolding. Completion of Phase 11
means that sequence has fulfilled its role.

Future `v0.2.0` development should not continue through a Phase 0–11 validation
hierarchy. Recommended status:

- Phase documents and record entries remain immutable historical implementation
  evidence for `v0.1.0`.
- Phase test runners remain callable aliases while tests are reassigned to
  component and boundary ownership.
- Phase checkpoint validators stop defining current development coherence.
- New work is organized by product objective, architecture decision, component,
  compatibility impact, and release milestone—not by extending old phase
  numbers.
- Release notes and ADRs reference historical phases only when explaining
  provenance or migration.

Historical assertions such as “no later-phase directory,” “Iteration heading
must exist,” or “Phase 11 Hospital distribution files remain present” protect
past sequencing, not the installed RRP product. They should become historical
tests or be retired prospectively once equivalent current invariants have an
owner.

## Proposed future governance layers

| Layer | Governs | Examples of strict evidence | Must not govern |
|---|---|---|---|
| Repository development | Safe, portable, readable RRP source | docs, syntax, secrets/PHI defenses, coding rules, non-destructive operations | Hospital project Git state or release ceremony |
| Component/package | One module's public and internal behavior | unit/conformance tests, dependency metadata, package check, installed assets | Unrelated targets or historical phases |
| Integration/CI | Compatibility between active boundaries | example and alternate-component vertical paths, supported environment matrix | Exact live publication state |
| Software release | Exact installable RRP candidate | full active suite, clean install, inventory, license, provenance, acquisition | Mutable hospital implementation files |
| Publication | Exact immutable remote product | authorization, remote identity, tags/releases, upload digest, recovery, verification | Recomputing scientific outputs unnecessarily |
| RRP project | One hospital-owned implementation | project manifest, trust, producer/estimand/provider compatibility, safe paths, dependencies | RRP development repository shape or unrelated Git state |
| Runtime/build provenance | What one run/build used and produced | exact identities/versions, approved config/code digests, as-of/run/build IDs | Source-control cleanliness as universal identity |
| Deployment artifact | Immutable deployable runtime unit | closed inventory, checksums, product/app compatibility, secret exclusion | Editable project inventory |
| Deployment target | One target realization and its mutation boundary | target dependencies, entry point, destination ownership, target smoke test | Canonical/model semantics or project repository rules |

These owners can intentionally repeat a check when the same fact protects a
different boundary. For example, package tests validate source behavior;
release clean-install tests validate that packaging actually includes it; and
artifact validation confirms the selected subset is deployable. Repetition
without a distinct boundary should be removed.

## Documentation governance

Documentation validation is not itself the main cost. The standalone validator
is fast and usefully checks all local links and machine-specific paths. The
over-scope comes from treating documentation correctness as an entry into the
universal development matrix and from centralizing historical and current
authority.

Prospective simplification should:

- retain a fast all-Markdown broken-link and portability scan;
- maintain one concise current architecture/governance index;
- distinguish current normative documents, proposed assessments, superseded
  decisions, and historical release evidence explicitly;
- move Phase 0–11 material into a stable historical index rather than requiring
  every current navigation source to present it as active guidance;
- replace the 5,000-plus-line implementation record as a machine test oracle
  with shorter ADRs, changelog/release evidence, or a versioned decision index;
- validate operation documentation only when active operation contracts or
  commands change; and
- require runtime/integration tests for executable examples, not ordinary prose.

The implementation record remains appropriate for this assessment because it
is a material prospective architecture decision and current policy asks for an
append-only account. That fact does not justify requiring an entry for every
future documentation or implementation edit, nor exact-heading checks.

## Governance under one software repository and independent projects

The installed-RRP direction simplifies ownership:

```text
RRP development repository governance
        → source, packages, contracts, tests, releases

RRP project contract
        → hospital code, component selection, dependencies, local state

deployment artifact/target validation
        → immutable built output and target realization
```

The following current governance exists principally because those boundaries
were intertwined and should leave the future user path:

- generating a separate Hospital software product from the Platform tree;
- embedding and extracting a complete Platform source archive;
- a top-level Hospital lock derived from the embedded Platform lock;
- closed distribution checksums over hospital-editable source;
- Hospital wrappers that locate and source managed Platform operations;
- pristine zero-commit/zero-remote Hospital repository realization;
- recipient acquisition tests coupled to Platform release generation; and
- two coordinated publication targets for one usable installation.

One RRP source repository can use ordinary package build rules to ship only
runtime assets. Independent projects are governed by project contracts, not by
the source repository's phase plan. Generated deployment artifacts can remain
closed and exact without making projects closed and exact.

## Package-topology-independent governance

Whether future RRP is one package, several packages, a package plus launcher,
or another conventional installed form, governance should require:

- explicit component ownership and dependency direction;
- versioned public contracts and compatibility declarations;
- a stable project-loading/trust boundary;
- focused unit/conformance tests for each public component;
- an exact built/installable asset inventory;
- clean-install and example-project acceptance;
- declared runtime versus build/test dependencies;
- supported R/OS evidence proportional to claims;
- upgrade/migration notes for incompatible public changes;
- release provenance independent of local project Git state; and
- optional clients such as `readmit` to conform without becoming hidden core
  dependencies.

Governance should not encode the number of packages, internal directory names,
or a CLI before those are chosen. It should test externally meaningful
interfaces and built contents.

## Controls that remain strict

The following controls should not be relaxed by governance migration:

1. Canonical structural, relationship, vocabulary, capability, and dual-time
   conformance.
2. Estimand population, time origin, event, horizon, terminal, competing-event,
   output, and coherence meaning.
3. Explicit trusted provider/producer/estimand registration; no executable YAML,
   arbitrary remote loading, or ambient plugin discovery.
4. Provider compatibility, isolated execution, cardinality, finite bounds,
   failure, and accepted-estimate provenance.
5. Temporal availability and future-information exclusion.
6. Append-oriented history, atomic terminal batches, idempotency/conflict,
   invalidation/restatement, and deterministic valid/current reads.
7. Product identity, coherence, freshness, compatibility, and separation from
   historical authority.
8. Product-only app behavior and deployment targets that cannot redefine
   analytical semantics.
9. Privacy-safe diagnostics, no PHI/secrets/private mappings in source or
   ordinary outputs, and safe fictional fixtures.
10. Explicit mutation targets, conservative replacement, and authorization for
    commit, push, publication, or deployment.
11. Exact dependency, compatibility, environment, license, and provenance
    evidence for a supported software release.
12. Closed inventory, checksum, and independent validation for immutable built
    software and deployment artifacts when promised.
13. Exact tag/release identity, partial-stage recovery, and remote acquisition
    verification at publication.

These are scientific, software, privacy, or irreversible-operation invariants.
They remain strict even when they stop running after unrelated changes.

## Controls that become scoped or historical

- universal Phase 0–11 validation after every intentional edit;
- exact historical phase headings as test inputs;
- phase-specific repository absence/presence checks after bootstrap;
- current navigation that presents every historical architecture decision as
  normative;
- full Hospital distribution and acquisition proof for unrelated RRP changes;
- clean source and `renv` consistency for Markdown-only work;
- repeated temporary package installation across unrelated suites;
- Git branch/commit/remote requirements outside generated target or
  release/publication boundaries;
- whole-repository inventories outside release construction;
- candidate/publication-state assertions outside release tooling;
- exact full-catalog agent/human command string checks after unrelated changes;
  and
- requirement that every meaningful change use the same large implementation-
  record format.

## Governance migration implications

If accepted, forward `v0.2.0-dev` governance should change in deliberate steps:

1. Adopt a concise current governance policy stating boundary-proportional
   validation and explicit validation owners.
2. Reclassify Phase 0–11 plan/checkpoints and the generated Hospital architecture
   as immutable `v0.1.0` history rather than current development law.
3. Shorten `AGENTS.md` to safety, durable architecture, current workflow, and
   scoped validation selection; move legacy release commands to maintainer
   documentation.
4. Introduce named validation profiles such as fast, component, integration,
   packaging, release, and publication without relying solely on Git diff
   inference.
5. Create a machine-readable ownership/dependency map from source/contracts to
   focused suites and downstream integration triggers.
6. Reorganize or alias Phase suites under component/boundary names, preserving
   tests while removing phase chronology from active routing.
7. Split CI into fast, component/package, integration, packaging, and
   artifact/target jobs; remove duplicated documentation validation.
8. Keep a broad active-product matrix on main/nightly and a full clean matrix
   for release candidates.
9. Remove implementation-record prose matching from correctness gates and use
   contract/version/release metadata for machine claims.
10. Move Hospital distribution/Git tests to an explicit legacy scope until the
    forward delivery path is replaced; never alter the historical tag/evidence.
11. Replace whole-source/Hospital release checks with installed-software and
    example-project proofs only when the package/project architecture exists.
12. Document a temporary transition rule so governance refactoring can remain
    safely validated without requiring the obsolete universal matrix to prove
    every documentation decision.

No test needs to be deleted merely to establish this structure. Tests can first
be tagged, owned, and routed; obsolete code/removal decisions can follow after
the installed product replaces it.

## Risks of simplification and mitigations

| Simplification | Risk | Retained protection |
|---|---|---|
| Do not run every suite locally | Cross-component regression may be found later | Declared downstream triggers, affected integration locally, broad main/nightly CI, full release matrix |
| Route tests by changed component | Path rules may miss semantic dependencies | Machine-readable dependency ownership, conservative union, manual broader override, public-contract triggers |
| Make Phase checkpoints historical | Valuable milestone invariants may disappear unnoticed | Translate still-current invariants into component/package/integration tests before retiring checkpoints |
| Stop treating implementation-record prose as executable | Decisions may drift from code | Use versioned contracts, ADR status, release metadata, changelog, and focused documentation review |
| Remove Hospital tests from universal validation | Legacy code could silently decay | Freeze historical release; run explicit legacy suite only when legacy files change until retirement |
| Narrow governing-document lists | Users may miss important history | Separate concise current index from complete historical archive index; keep all links valid |
| Move broad checks to CI | Developers may merge late failures | Fast pre-push/PR component checks, parallel CI, clear ownership, branch protection when adopted |
| Move dependency reconstruction to CI/release | Local environment drift may hide problems | Validate dependency metadata on relevant changes; clean-install matrix; exact release reconstruction |
| Scope artifact/target tests | Upstream changes may break deployment | Declare artifact/target as downstream of product/app and installed-asset contracts |
| Separate project governance | Unsafe project code could bypass source controls | Explicit project trust boundary, project contract validation, no executable YAML/remote discovery, artifact secret exclusion |
| Simplify release pipeline around installed software | First-release provenance protections might be lost | Preserve clean candidate, exact inventory, checksums, clean acquisition, immutable publication, and recovery semantics |

## Questions requiring follow-up

1. What are the exact validation component names and dependency graph after
   removing phase numbers from active routing?
2. Should local selection require an explicit `--scope`, infer from changed
   paths, or combine both?
3. What fast checks are truly universal, and what time budget should define
   “fast” on supported developer environments?
4. Which integration profiles run on every pull request, only when affected,
   on main, or nightly?
5. Which v0.1.0 Hospital/release tests remain runnable on `main` during the
   transition, and when may they move entirely to the historical tag?
6. What replaces the implementation record for active ADRs, compatibility
   decisions, and release evidence?
7. Which documents are current normative authority versus proposed,
   superseded, or historical, and how should navigation expose them?
8. How should package checks and clean-install matrices be partitioned before
   package topology is decided?
9. What branch protection or required CI jobs should be adopted once jobs are
   scoped?
10. How are project-contract validators versioned and distributed separately
    from RRP repository validators?
11. Which provenance and artifact checks intentionally repeat at component,
    release, and publication boundaries?
12. What temporary validation policy governs the governance-refactor change
    itself without becoming self-exempting or circular?

## Recommended next task

The previously recommended **installed package and minimum RRP project contract
assessment** remains the next architecture task. No additional governance
assessment must precede it.

The decision gate is maintainer acceptance or revision of the principles in
this document: proportional validation, explicit ownership, Phase 0–11 as
historical evidence, strict release/publication boundaries, and separate
project validation. The next assessment should follow the documentation-only
validation posture used here and should add a concrete package/project
ownership map that can also seed the future validation dependency map.

Before implementation of installed software begins, the first authorized
`v0.2.0` engineering increment should establish the new governance/validation
profiles or implement them alongside the package-boundary refactor. This avoids
making every package-design iteration pay for the retired Hospital release
ceremony while ensuring active-core integration and release rigor remain
available.

## Validation posture for this assessment

Current `AGENTS.md` says to run `Rscript operations/validate.R --mode
development` during intentional work. That command would execute all 14
repository validators and all Phase suites, including Phase 11 distribution,
Git-realization, release, and acquisition proofs. The explicit task authority
for this governance assessment instead requires minimum non-destructive
documentation validation and requires the conflict to be recorded.

The broad rule is therefore treated as evidence rather than silently ignored.
It protects general repository regression confidence, but it has no causal
relationship to whether this new Markdown document has valid links, portable
paths, correct navigation, or clean formatting. No executable source, contract,
dependency, package, runtime, artifact, distribution, release, or publication
state changes in this assessment.

Validation is intentionally limited to:

- the supported documentation validator;
- direct inspection of the affected navigation and record changes;
- Markdown trailing-whitespace and repository diff checks; and
- repository status confirming the exact documentation-only scope.

The complete development/checkpoint matrices, focused Phase suites, Hospital
build/validation, release preparation, acquisition proof, and publication
preflight are not necessary evidence for this assessment and are not run.
