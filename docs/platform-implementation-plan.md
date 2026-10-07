# RRP 1.0.0 implementation plan

## Status and authority

**Status:** authoritative roadmap; Stages 1–10 are accepted and complete. Stage
10 was accepted on 2026-10-05 at implementation baseline
`433d7eb2d90a4e237a6e5ffa00044de99534fe68`. The second-edition detailed Stage
11 plan is formally accepted for implementation as of 2026-10-07 after human
resolution of its initial seven planning questions. Stage 11 implementation
has not begun; Increment 11.A is the next implementation task and must be
performed as a separate action.

This plan explains how the clean Readmission Risk Pool (RRP) 1.0.0 target will
be constructed. It derives from [Platform True North](platform-true-north.md)
and the [Platform Architecture](platform-architecture.md). If this plan and
either upstream document disagree, the upstream document governs and the plan
must be corrected before source work continues.

The [Implementation Record](platform-implementation-record.md) reports what
has actually happened on the clean 1.0 line. A planned stage is not a claim
that its capability exists.

```text
Platform True North              WHY
        ↓
Platform Architecture            WHAT RRP 1.0 MUST BE
        ↓
Platform Implementation Plan     HOW WE PLAN TO BUILD IT
        ↓
Platform Implementation Record   WHAT WE HAVE ACTUALLY BUILT
        ↓
Software and evidence
```

The active line starts from the two accepted governing documents at commit
`815fcc2`. The immutable `v0.1.0` tag and later pre-reset commits are historical
evidence and a code reservoir, not active source or authority.

## Construction method

RRP 1.0 is a clean-forward implementation, not a blanket rewrite and not a
migration of the old tree. Each implementation unit follows this sequence:

```text
read the current requirement
        ↓
identify the final 1.0 owner and boundary
        ↓
inspect only relevant historical implementation and tests
        ↓
reuse, adapt, learn from, or reject that evidence
        ↓
place new work directly in its intended 1.0 owner
        ↓
validate only the claims now made
        ↓
record the actual result, limits, and next step
```

Historical code is never restored in bulk to make extraction convenient. No
legacy compatibility layer, duplicate source authority, repository-root
product model, or transitional whole-platform scaffold is part of this plan.
An implementation unit records the exact historical revision and files it
inspected, the reuse decision, and the current tests that own the resulting
invariant.

Human traceability controls the pace. A unit should introduce one coherent
responsibility, make its owner and limits visible, and leave the repository in
a state a maintainer can explain. Early stages are intentionally incomplete.
Validation proves the current layer rather than manufacturing end-to-end
operability before the needed layers exist.

## Progressive planning rule

Only the current implementation stage is decomposed before source work.
Stages 1–10 are accepted and complete; their detailed plans remain as
implementation lineage. Stage 11 is detailed and formally accepted below but
remains unimplemented; Increment 11.A proceeds only as a separate
implementation action. After a stage is implemented:

1. validate its stated exit claim;
2. reconcile the implementation with True North and the architecture;
3. update the implementation record with actual reuse, decisions, surprises,
   and remaining limits;
4. adjust the high-level roadmap only if evidence invalidated a major
   dependency or assumption; and
5. detail and accept the next stage before its source implementation begins.

Distant stages intentionally state outcomes and boundaries rather than file
layouts, function names, schemas, command syntax, or exhaustive test matrices.
Their bounded decisions are resolved just before they become material.

## Roadmap at a glance

| Stage | Capability introduced | Plain-language exit state |
|---|---|---|
| 1 | Repository and development foundation | RRP has a truthful development identity, public repository essentials, maintainable working rules, and a small repository-validation path, but no installable software. |
| 2 | Internal installed-software package foundation | RRP has conventional internal package owners and one-way dependency boundaries, but cannot yet resolve installed resources or operate a project. |
| 3 | Installed resources and shared operation foundation | Package code can resolve validated software-owned resources and return common structured operation evidence from an explicit software context, but there is no hospital project. |
| 4 | Independent project foundation | RRP can initialize, recognize, safely load, and validate an independent project and its declared extensions, but cannot yet admit clinical-domain input. |
| 5 | Canonical handoff and producer boundary | A selected project producer can submit a candidate bundle that RRP admits or rejects at a versioned canonical boundary, but RRP cannot calculate risk. |
| 6 | Singular target, runtime, and provider execution | RRP can construct its remaining day-30 risk request and obtain a validated estimate or structured failure from the selected provider, but no operational history is retained. |
| 7 | Project state and operational history | Runs append atomic, attributable, reopenable operational truth through a storage-neutral port and supplied local adapter, but no consumer products exist. |
| 8 | Fictional reference path | A normal independent fictional project exercises producer, admission, runtime, provider, and history end to end, but RRP has no application-facing products. |
| 9 | Logical products and materialization | RRP can build and validate the initial remaining-risk product family from history and materialize it in project state, but it has no supplied user application. |
| 10 | Supplied product-only application | The supplied application works only through validated products and proves the application boundary, but normal operators do not yet have the complete installed CLI and distribution. |
| 11 | CLI, closed RRP-owned-payload distribution, installation, and upgrade | A human can build, install, verify, activate, operate, upgrade, roll back, and uninstall versioned RRP software without mutating a project, but deployment artifacts are not yet available. |
| 12 | Product-only artifacts and deployment realizations | Installed RRP can build independently valid product-only artifacts and both Posit-compatible and OCI realizations without upstream compute capability. |
| 13 | Clean-system and adopter acceptance | Supported clean environments prove installed RRP, the fictional project, and a separate adopter implementation through the full implemented lifecycle, but no 1.0.0 release is yet authorized. |
| 14 | Release qualification and publication | Exact accepted bytes can be prepared, explicitly published, publicly reacquired, and verified as immutable RRP 1.0.0. |

## Architectural dependency path

The order follows ownership and dependency direction rather than historical
Phase chronology:

```text
source governance
    ↓
package owners
    ↓
installed resources + shared operation results
    ↓
independent project and trusted registration
    ↓
canonical producer handoff
    ↓
singular target + runtime + provider
    ↓
append-oriented project history
    ↓
normal fictional end-to-end project
    ↓
logical products
    ↓
product-only application
    ↓
CLI + closed RRP-owned payload + private installation lifecycle
    ↓
product-only deployment artifacts
    ↓
clean adopter acceptance
    ↓
release qualification and explicit publication
```

Later consumers never force an earlier layer to know their implementation.
The fictional path is integrated only after its real project/runtime/history
boundaries exist. Products follow durable truth; the app follows products;
artifacts follow installed software and the app. Release qualification is last
because it asserts the complete acquisition and support boundary.

## Stage 1 — Repository and development foundation

**Status:** complete; accepted and reconciled on 2026-09-15

### Objective

Establish the smallest honest source repository from which the installed RRP
software can be built deliberately. This stage gives the development line an
identity, public/legal posture, human working agreement, explicit source
ownership rules, and proportionate validation. It does not create packages,
contracts, project behavior, runtime behavior, or an operator product.

### Responsibilities introduced

- one machine-readable RRP product development identity, beginning at
  `1.0.0-dev`, distinct from package versions and a released `1.0.0`;
- public orientation, Apache-2.0 licensing/notices, security and support
  reporting, and contribution expectations appropriate to the current
  maturity;
- human-readable implementation conventions and agent/contributor instructions
  that derive from the four governing documents;
- a minimal repository policy defining source ownership, safe paths, generated
  output, prohibited confidential material, and when new directories may
  appear;
- one small, local, human-callable validation operation for the repository-
  foundation claims Stage 1 actually makes.

### Why this stage is first

Every later stage needs a truthful product identity, licensing boundary,
maintainer method, and evidence path. Creating these before package code keeps
later extraction reviewable and prevents historical scaffolding from becoming
the de facto architecture. The stage is useful even though no RRP function can
yet run.

### Dependencies

- accepted Platform True North;
- accepted Platform Architecture;
- this high-level implementation plan and fresh implementation record; and
- read-only Git history for selective comparison.

No historical executable source, sibling repository, package library, network
service, or deployment target is a dependency.

### Implementation sequence

```text
1.A — Product identity and public repository essentials
        ↓
1.B — Human development and ownership rules
        ↓
1.C — Minimal repository validation
        ↓
Stage 1 acceptance and reconciliation
        ↓
Detail Stage 2
```

### Increment 1.A — Product identity and public repository essentials

Establish one development product metadata authority with the exact value
`1.0.0-dev`. Add only the public repository documents and root policies needed
to interpret, license, secure, support, contribute to, and safely check out the
source. Reuse Apache-2.0 license and notice wording from `v0.1.0` only after
checking that the current authorship and notices remain accurate. Write the
README for the incomplete clean 1.0 line; do not recover the released product
README or advertise installation.

Expected evidence is static: the development version is singular and not
described as released; links resolve; required legal/public files agree; no
secret, patient-level, generated, or historical implementation content has
entered the tree.

### Increment 1.B — Human development and ownership rules

Add a concise human implementation guide and repository working agreement.
They define the authority chain, progressive planning/record discipline,
direct-to-final-owner reuse method, readable R conventions, dependency
ownership, explicit project context, and the rule against empty speculative
directory scaffolds. Define the initial source ownership map only for paths
that exist by the end of this stage; later owners are added with their
capability.

Expected evidence is documentary and review-based: a new maintainer can find
the authority, identify what exists, determine how to add one bounded change,
and understand what remains prohibited without reading historical plans.

### Increment 1.C — Minimal repository validation

Implement one dependency-light, local, human-callable repository validator.
It should check only current claims: expected foundational files, document
links, development identity consistency, legal/public metadata consistency,
parseability of any machine-readable development metadata, basic path/symlink
hygiene, and practical exclusions for obvious generated or confidential
content. Its result and exit status must be understandable without an agent.

Do not restore the old validation registry, validation ownership graph,
lifecycle profiles, Phase or legacy suites, release checks, changed-path
routing, compatibility transitions, or platform-wide acceptance machinery.
Do not add hosted CI in Stage 1. Validation enters only in proportion to the
repository-foundation claims that actually exist.

After Increment 1.C, Stage 1 acceptance and reconciliation follow the global
progressive-planning rule: validate the exit claim, reconcile the result,
update the implementation record, and then detail Stage 2. Those are lifecycle
actions, not another implementation increment.

### Stage 1 acceptance

Stage 1 is complete only when:

- the four-document authority chain is intact and every active link resolves;
- one development metadata authority identifies RRP as `1.0.0-dev` and no file
  implies a `1.0.0` release;
- license, notice, security, support, contribution, README, ignore, and basic
  text-format policy are accurate for the clean line;
- human/agent instructions and implementation conventions agree with the
  governing documents and have no historical workflow dependencies;
- each present source path has an understandable owner and no empty future
  architecture has been scaffolded;
- the documented local repository validation passes from a clean checkout;
- validation reports only Stage 1 claims and does not require source code,
  packages, projects, Git publication state, a sibling checkout, or secrets;
- the implementation record states actual additions, historical reuse, checks,
  surprises, and remaining non-capabilities; and
- human review can explain what exists, why every file exists, which authority
  governs it, how implementation proceeds, and which RRP capabilities remain
  absent.

### Plain-language exit state

> RRP now has a truthful development identity, public repository essentials,
> maintainable working rules, and a small repository-validation path. It still has
> no installable package, project, clinical contract, runtime, product,
> application, CLI, or deployment capability.

### Expected historical reuse

Inspect `v0.1.0` root licensing, notice, security, support, formatting, ignore,
contribution, agent, and repository-policy material. Legal text and a few
stable safety rules may be directly reusable after current-fact review;
development guidance is more likely adapted. The pre-reset Stage 1 ownership
and named-validation work is conceptual evidence for human routing, but its
transition ledger, broad profiles, Phase integration, and old-path assumptions
must not return.

### Major deferrals

Package topology, dependency environments, resource catalogs, project
contracts, runtime/domain contracts, functional tests, CLI behavior,
installation, deployment, and release mechanics all remain absent. Exact
Stage 2 files and package APIs are decided during Stage 2 planning.

## Stage 2 — Internal installed-software package foundation

**Planning status:** complete; accepted and reconciled on 2026-09-15

### Objective

Create the first two conventional executable owners required by the
architecture: a dependency-light `rrpruntime` package and one main internal
implementation package, `rrpplatform`. Establish their identities, namespaces,
one-way dependency, API visibility, package-native tests, local build/check and
isolated install/load evidence, and proportionate hosted verification. Stop
before either package owns an installed resource, project, clinical contract,
runtime calculation, operator command, or distribution lifecycle.

### Stage 1 reconciliation and inherited constraints

Stage 1 is complete and requires no corrective change before Stage 2. Stage 2
inherits these concrete constraints:

- `RRP.yml` remains the sole product-development identity authority at
  `1.0.0-dev` and `not_released`; an internal package name or version cannot
  redefine that product identity;
- `docs/implementation-guidance.md` owns the current source map, which must
  grow only when a concrete package, test, tool, or workflow path appears;
- `tools/validate-repository.R` owns repository-foundation validation and its
  closed inventory must expand atomically with each accepted new path;
- repository-relative lookup remains valid only for maintainer development
  tooling, never for package behavior intended to become installed software;
- no package, dependency environment, test framework, CI workflow, installed
  resource, or product operation currently exists; and
- generated package archives, check directories, and temporary libraries are
  evidence, not source, and must be created outside the repository or removed
  by their owning operation without speculative ignore rules.

The existing human-readable R, dependency ownership, privacy, historical-reuse,
and no-empty-scaffold conventions continue unchanged. Every increment updates
the README or implementation guidance only to the extent needed to describe
what then exists.

### Settled package-foundation decisions

| Decision | Accepted Stage 2 choice |
|---|---|
| Physical owners | Exactly `packages/rrpruntime/` and `packages/rrpplatform/`; no third package or duplicate package root. |
| Main package name | `rrpplatform`, an internal implementation namespace, not the product name, installer, CLI, project API, or separately marketed package. |
| Runtime version | `rrpruntime` begins clean development at `0.3.0.9000`, advancing the historical internal `0.3.0` identity without importing its old behavior or promising source/API compatibility. |
| Main-package version | `rrpplatform` begins at `0.1.0.9000`; it is independently versioned from both `rrpruntime` and product `1.0.0-dev`. |
| R line | Both packages require `R (>= 4.4.0)`, matching the architecture's initial implementation line without creating a final support claim. |
| Dependency direction | `rrpplatform` declares and namespace-imports `rrpruntime`; `rrpruntime` never depends on or refers to `rrpplatform`. |
| Runtime dependencies | Stage 2 `rrpruntime` has no `Imports`, `Suggests`, or `LinkingTo` dependencies and uses only base R/package machinery. |
| Main-package dependencies | Stage 2 `rrpplatform` has only `rrpruntime` in `Imports`; no resource, YAML, database, UI, project, deployment, or development dependency enters early. |
| API posture | Both namespaces initially export no callable functions. The main package imports the runtime namespace only to establish the dependency. Later cross-package calls require explicit owned exports/imports when their behavior exists. Package exports remain technical internal APIs, not the future human CLI. |
| Tests | Each package owns one base-R package-foundation test under its conventional `tests/` directory; one maintainer operation later owns cross-package topology and package-lifecycle proof. No third-party test framework is justified. |
| Development dependency environment | None. Base R 4.4, `R CMD build`, `R CMD INSTALL`, and `R CMD check` are sufficient for every Stage 2 claim. No root `renv`, lockfile, package repository, or installed-distribution closure is introduced. |

Package metadata must be conventional and accurate: package identity, title,
development version, authorship/maintainer facts, description of the narrow
current responsibility, Apache-2.0 licensing, UTF-8 encoding, R requirement,
repository URL, and issue tracker. Package-level documentation is maintained
manually in Stage 2; roxygen or another documentation generator is not a
dependency.

### Implementation sequence

```text
2.A — Dependency-light rrpruntime package owner
        ↓
2.B — Main package and local package-boundary proof
        ↓
2.C — Hosted package-foundation verification
        ↓
Stage 2 acceptance and reconciliation
        ↓
Detail Stage 3
```

The three increments follow the real dependency graph: establish the leaf
package, add its only dependent plus joint local evidence, then run that stable
human operation in a hosted environment. Documentation and stage acceptance
are updates within those lifecycle boundaries, not artificial increments.

### Increment 2.A — Dependency-light `rrpruntime` package owner

Create `packages/rrpruntime/` as a complete but deliberately behavior-free R
package. It owns its `DESCRIPTION`, empty-export `NAMESPACE`, minimal package
source/documentation, and one base-R package-foundation test. The package may
identify and document its future architectural responsibility, but it must not
implement placeholder canonical, eligibility, state, request, provider, or
history behavior.

The package test confirms installed identity/version, the R requirement, and
the absence of exported callables. Focused implementation evidence directly
parses all new R and DCF files, builds the source package, installs it into a
fresh temporary library, loads it in a fresh `Rscript --vanilla` process, runs
`R CMD check --no-manual` with exact `Status: OK`, and confirms the source tree
contains no repository/sibling discovery or reverse `rrpplatform` reference.
Archives, check directories, and libraries remain in temporary space.

In the same change, expand the current ownership map and repository validator
for only the realized runtime-package paths and directories. Historical
`rrpruntime` metadata, package layout, package-level documentation shape, and
base-R check mechanics are useful references. Historical R files, exports,
manuals, tests, version `0.3.0` behavior, daily-hazard contracts, provider and
history execution, temporary installers, and Phase ownership are rejected.

Increment 2.A stops with one loadable leaf package. It does not create
`rrpplatform`, a joint package runner, CI, installed resources, reusable runtime
primitives, or any Stage 3+ interface.

### Increment 2.B — Main package and local package-boundary proof

Create `packages/rrpplatform/` as the main internal package at
`0.1.0.9000`. Its metadata and namespace establish the sole
`rrpplatform -> rrpruntime` dependency; its minimal source/documentation and
base-R package test establish package identity, import presence, and zero
exported callables without inventing orchestration or product behavior.

Add one base-R maintainer operation at `tools/validate-packages.R`. It is the
documented human command for the complete local Stage 2 package claim and must:

- require exactly the two accepted package roots and their conventional files;
- parse package source, `DESCRIPTION`, and `NAMESPACE` metadata;
- verify exact package identities/versions, the R line, Apache license metadata,
  zero exports, the one-way dependency, and absence of unexpected/heavy
  dependencies or repository/sibling discovery in package source;
- build both packages into a temporary directory;
- install `rrpruntime` and then `rrpplatform` from the built archives into an
  otherwise empty temporary user library;
- load each from a fresh vanilla R process without an ambient user library;
- run package-native tests through `R CMD check --no-manual` and require exact
  `Status: OK` for each package; and
- render understandable package-by-package results and return nonzero status
  on any failure.

Copied temporary-tree failures should demonstrate, at minimum, rejection of a
missing package file, a reverse dependency, an unexpected export, and inability
to install the main package without its runtime dependency. The operation is
repository maintainer tooling, not an installed product command or a general
validation dispatcher.

Update the ownership map, repository validator inventory, README/contribution
guidance, and agent agreement for the exact package and validation paths now
present. Historical `tests/run-package-tests.R`, package-boundary assertions,
temporary-library isolation, install order, fresh-process loading, and strict
check-log inspection are adaptable. Historical source compatibility loaders,
active Phase regressions, registry/profile integration, and runtime semantic
tests are rejected.

Increment 2.B stops after the full two-package foundation is locally
repeatable. It adds no CI yet and no resource access, structured operation
result, project loader, runtime behavior, distribution, or dependency closure.

### Increment 2.C — Hosted package-foundation verification

Once the exact 2.B human operation passes, add one narrowly owned GitHub Actions
workflow for push and pull-request events. It uses read-only repository
permission, a maintained immutable action revision policy, Ubuntu with R 4.4,
and no repository secret. It invokes, without duplicating their logic:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
```

The workflow has no matrix, release/deployment job, artifact publication,
cache-dependent correctness, manual legacy mode, validation profile, registry,
changed-path routing, `renv` setup, or remote mutation. It proves that the
committed source-foundation and two-package claims work in one independent
hosted Ubuntu/R 4.4 environment. It does not establish a released support cell,
cross-platform equivalence, installed distribution, or clinical validity.

Update the ownership map and repository validator for the concrete workflow
path. Local evidence checks its limited triggers, read-only permission, exact
commands, absence of secrets/mutating steps, and continued package/repository
validation. Final Stage 2 acceptance requires the identity and successful
result of the hosted push or pull-request run for the committed workflow;
creating a local YAML file alone is insufficient. Commit, push, or other remote
mutation requires separate explicit authorization.

Historical least-privilege workflow structure, R 4.4 setup, exact human-command
reuse, and static no-publication assertions are adaptable. The old `ci-active`
profile, `renv` bootstrap, legacy manual dispatch, validation registry/tests,
Phase aggregates, and release/deployment vocabulary are rejected.

### Stage 2 acceptance

Stage 2 is complete only when:

- exactly two internal package roots exist and each has conventional,
  understandable metadata, namespace, source, package documentation, and
  package-native base-R evidence;
- `rrpplatform` depends only on `rrpruntime`, while `rrpruntime` has no reverse,
  heavy, project, resource, UI, database, deployment, or development dependency;
- `RRP.yml` remains the sole `1.0.0-dev` product authority and both package
  identities/versions are documented as independent internal identities;
- both packages parse and build, install and load from fresh temporary-library
  state in dependency order, and pass `R CMD check --no-manual` with exact
  `Status: OK`;
- namespace tests prove zero premature exports and reject accidental visibility,
  reverse dependency, repository discovery, or duplicate package authority;
- tests and the human package-validation operation protect only the introduced
  package topology, identity, namespace, dependency, and lifecycle invariants;
- the implementation guidance owns every new path, the expanded repository
  validator passes, and no empty future directory or persistent generated
  output remains;
- the hosted workflow, if introduced as planned, invokes the same two human
  operations under read-only Ubuntu/R 4.4, and a committed push or pull-request
  run has completed successfully; and
- no installed-resource discovery, common operation result, hospital project,
  canonical/domain contract, runtime calculation, history, product,
  application, CLI, dependency closure, distribution, deployment, or release
  behavior has entered the packages.

After the implementation increments pass, reconcile the realized packages and
evidence with True North and Platform Architecture, record actual historical
reuse and deviations, and update status. Stage acceptance is a lifecycle action,
not Increment 2.D. If hosted evidence or any other criterion remains pending,
Stage 2 remains in progress.

### Plain-language exit state

> RRP now has conventional internal software/package structure and enforced
> dependency direction, but it cannot yet resolve installed resources,
> recognize a project, or calculate anything.

### Historical reuse disposition

Reconnaissance inspected immutable `v0.1.0` `runtime/` package metadata and
namespace plus pre-reset commits `b9672cc`, `d31534a`, `d23e315`, and `855a4b0`.
The two-package layout, `rrpplatform` name, conventional metadata/documentation,
base-R package tests, strict build/check harness, isolated install/load order,
dependency/API boundary assertions, and least-privilege hosted R 4.4 pattern are
substantially reusable after simplification.

The old package contents are not reusable in Stage 2: daily-hazard input,
eligibility, requests, estimates, providers, history, canonical conformance,
and their exports/tests belong to later stages under new semantics. The former
compatibility loader, repository source chain, validation registry/profiles,
Phase suites, root `renv`, resource/distribution design, Hospital/release paths,
and broad CI workflow are also rejected from this stage.

### Major deferrals and deliberately open decisions

Stage 3 owns installed-resource catalog/access and common structured operation
results. Later stages own explicit software context, project contracts,
canonical and risk semantics, provider/history behavior, products/application,
CLI and installed distributions, dependency closure, deployment, and release.
Stage 2 therefore does not settle exported function names, resource IDs or
layout, project paths, package-to-resource mechanics, launcher/installer form,
final distribution versions, runtime third-party dependencies, dependency-lock
technology, CI matrices/caching, support cells, or release artifacts. Package
authorship/contact fields must use current verified project facts during 2.A;
no unverified address is invented by this plan.

## Stage 3 — Installed resources and shared operation foundation

**Planning status:** detailed and accepted for implementation on 2026-09-15;
Increments 3.A–3.C and Stage 3 acceptance/reconciliation completed on
2026-09-16. Hosted push run `35116049077`, job `104861623678`, passed for the
committed Stage 3 revision `11fc44835c0d3862196e1af5d1ef691e781c9688`.

### Objective

Define how current software-owned contracts, defaults, templates,
documentation, and static application assets are declared in a closed source
catalog, projected into an installed-resource catalog, and resolved by logical
ID from an explicitly supplied software root. Add one minimal structured
operation-result contract and a privacy-safe diagnostic record used by later
programmatic operations. Stop before root selection, a hospital project, any
clinical/domain resource, or a distribution lifecycle exists.

### Stage 2 reconciliation and inherited constraints

Stages 1 and 2 are complete and require no corrective change before Stage 3.
The realized repository establishes these starting constraints:

- `rrpruntime` remains the dependency-light leaf package at `0.3.0.9000`;
  `rrpplatform` at `0.1.0.9000` is its sole dependent;
- both namespaces currently export zero callable APIs and neither package owns
  product or domain behavior;
- `tools/validate-packages.R` proves exact package topology, source parsing,
  dependency direction, builds, isolated dependency-order installation and
  loading, package-native tests, and strict package checks;
- `tools/validate-repository.R` owns the closed current repository inventory,
  documentation, identity, metadata, policy, and hygiene claims;
- the read-only `package-foundation` workflow runs those same two human
  operations on push and pull request under hosted Ubuntu/R 4.4, with its
  first committed successful run recorded in the implementation record;
- `docs/implementation-guidance.md` owns the current source map and must grow
  atomically with concrete package, resource, test, or tooling paths;
- no resource catalog, installed resource, software-root abstraction, project
  context, CLI, distribution manifest, dependency environment, or domain
  behavior exists; and
- new paths, exports, and dependencies require a current responsibility and
  evidence. Generated projections and copied-root fixtures remain temporary
  evidence outside the repository.

Repository-relative lookup remains limited to maintainer validation of source
assets. Package behavior cannot infer a repository, Git checkout, sibling,
current working directory, environment variable, or installed version.

### Settled Stage 3 decisions

| Decision | Accepted Stage 3 choice |
|---|---|
| Source-resource authority | Repository-owned `resources/source-catalog.dcf` and its schema declare current source resources; maintainer validation owns source interpretation and temporary projection. |
| Package behavior owner | `rrpplatform` owns projected installed-catalog access, resource errors, operation results, diagnostics, and the first stable programmatic operations. It never consumes repository-only source paths. |
| Runtime boundary | `rrpruntime` gains no Stage 3 behavior or dependency and retains zero exports. Later runtime primitives return domain values to main-package orchestration rather than depending upward on operation or resource APIs. |
| Catalog representation | Use strict multi-record DCF parsed with base R. No YAML/JSON dependency or custom executable data format is justified. |
| Source catalog | `resources/source-catalog.dcf` is the closed maintainer authority for current software-owned resources and their source-to-installed path mapping. |
| Catalog schema | `resources/resource-catalog-schema.dcf` defines the exact catalog identities, source/projected fields, logical-ID rule, controlled resource classes, and path/collision invariants. |
| Initial identities | The catalog is `rrp.software-resources@0.1.0` with format `1.0.0`, product `readmission-risk-pool-platform`, development version `1.0.0-dev`, and status `development_unpublished`. |
| Logical IDs | IDs are lowercase, dot-separated stable names matching `^rrp[.][a-z0-9]+(?:[.][a-z0-9-]+)+$`; an ID never embeds a repository or installation path. |
| Resource entry fields | A source entry contains exactly record type, resource ID, resource class, owner package, source path, installed path, and format. The installed projection removes only the source path. |
| Resource classes | The schema represents `contract`, `default`, `template`, `documentation`, and `static_application_asset`; the catalog uses only classes backed by current resources. |
| First resource | The catalog schema itself is the first real `contract` resource, under logical ID `rrp.contract.resource-catalog`. It is required by installed catalog validation, not a placeholder for later domain work. |
| Installed projection | A deterministic in-memory/temporary projection writes `resources/resource-catalog.dcf`, the schema, and declared resources beneath a distribution-shaped explicit root. It is evidence and a future build input, not a distribution build or manifest. |
| Explicit root | Resource APIs require one caller-supplied software root, immediately canonicalize it, and never discover or select a root. The validated catalog object is the minimum Stage 3 software context. |
| Dependencies | Both packages retain their Stage 2 dependency posture. Base R DCF, filesystem, condition, and list facilities are sufficient; no third-party dependency or `renv` enters. |

The schema controls representation, not future content. Allowing a resource
class does not create an instance of that class or authorize its future
contract. All current entries are required; optional-resource semantics are
deferred until a real optional resource exists.

### Resource safety and catalog closure

A software-owned resource is a non-executable file that installed RRP must
locate by stable logical identity to support a capability RRP actually owns.
Package source, tests, maintainer-only planning/evidence, generated validation
output, hospital project content or state, credentials, and secrets are not
software-owned resources.

The source catalog is closed over the current `resources/` payload. The fixed
source catalog and schema bootstrap paths are known to validation; every other
file beneath that source resource root must have exactly one catalog entry.
Each entry names one regular, non-linked source file and one safe relative
installed path. IDs, source paths, and installed paths are unique, and paths
must also be unique after case folding and free of file/directory conflicts.

Safe relative paths use forward logical segments, contain no absolute, drive,
home, empty, dot, parent, control, or backslash segments, and remain beneath
the supplied root after canonicalization. Catalog opening rejects a missing or
linked root; malformed or unsupported catalog/schema identity; missing,
linked, non-regular, undeclared, or extra resources; duplicate IDs or paths;
case collisions; and paths that escape or conflict. Lookup rejects malformed
or unknown logical IDs and revalidates the relevant catalog/resource state so
post-open deletion, link substitution, or catalog replacement fails closed.

The schema and catalog contain no command, callable name, remote URL,
credential, project setting, clinical value, or arbitrary extension mapping.

### Source catalog, installed catalog, and distribution manifest

Three authorities remain distinct:

```text
source catalog
    declares current logical resources, source ownership, and intended
    installed relative paths
        ↓ deterministic projection
installed-resource catalog
    omits repository source paths and supports logical lookup beneath one
    explicit software root
        ↓ future distribution build, not Stage 3
distribution manifest
    closes the complete installed payload, packages, dependency closure,
    inventory, sizes, digests, provenance, and build evidence
```

Stage 3 proves only the first arrow in temporary fixtures. It does not create a
persistent installed tree, choose a final installation layout, enumerate the
complete software payload, calculate digests, classify repository exclusions,
or declare build/release identity. The future distribution manifest may use
the source catalog as one input but cannot be replaced by it.

### Package APIs and visibility

Increment 3.B introduces the first `rrpplatform` exports:

- `rrp_open_resource_catalog(software_root)` validates the fixed schema,
  projected catalog, and closed declared resources below exactly the supplied
  root, then returns a validated `rrp_resource_catalog` object; and
- `rrp_resource_path(catalog, resource_id)` resolves one exact declared ID to
  a normalized contained regular-file path after revalidation.

These are stable technical programmatic interfaces for RRP package code, not a
human CLI, installer, root selector, or project API. Invalid input or resource
state raises `rrp_resource_error`, a typed condition with a stable safe code
and bounded non-sensitive message. The condition never copies arbitrary parser
errors, resource contents, credentials, or caller paths into its message.
Constructors and lower-level validators remain package-internal.

Increment 3.C adds:

- `rrp_validate_software_resources(software_root)`, a read-only programmatic
  operation that returns the common result shape for one explicit root; and
- `rrp_operation_succeeded(result)`, the supported predicate for inspecting
  success without parsing class names or prose.

The resource catalog and condition classes are observable return/failure
contracts, but callers do not construct or mutate them through public helper
APIs. No ordinary operator command is introduced.

### Structured operation result and diagnostics

`rrpplatform` owns the operation boundary because the architecture assigns
stable operations, resource access, and diagnostics to the main package.
`rrpruntime` will own dependency-light domain computation, not orchestration
or presentation of operation outcomes.

One `rrp_operation_result` represents one operation, never an aggregate or
event stream. Its exact fields are:

- `operation_id`: one stable machine-readable operation identity;
- `status`: exactly `success` or `failure`;
- `value`: the operation-specific value on success and `NULL` on failure; and
- `diagnostics`: an ordered list of validated `rrp_diagnostic` records.

A successful result cannot contain an error diagnostic. A failed result must
contain at least one error diagnostic and no value. Constructors validate the
whole object; downstream code must use the predicate rather than parse printed
text. The initial resource-validation success value is only a safe catalog
identity/version/resource-count summary.

Each `rrp_diagnostic` has exactly `code`, `severity`, and `message`. Codes are
stable lowercase machine identifiers. Severity is the deliberately small
vocabulary `info`, `warning`, or `error`. Messages are bounded, non-empty,
single-line, maintainer-authored text and reject obvious credentials, secrets,
authorization material, connection strings, private keys, patient identifiers,
and filesystem-path disclosure. Arbitrary context/details are intentionally
absent; later work may add a closed safe context only when a real operation
requires it.

Results and diagnostics have no operation-run identity, timestamp, attempt,
stage lifecycle, sink, routing, retention, metric, trace, provenance, audit,
or analytical semantics. Printing may be concise for development, but console
rendering is not the contract.

### Implementation sequence

```text
3.A — Closed source-resource catalog and installed projection contract
        ↓
3.B — Explicit-root resource access
        ↓
3.C — Common operation result and privacy-safe diagnostics
        ↓
Stage 3 acceptance and reconciliation
        ↓
Detail Stage 4
```

The sequence follows the dependency graph: declare and validate current
resources before package code resolves them; prove access independently of the
repository before using that boundary in a real structured operation; then
add the smallest common result/diagnostic contract and exercise it through the
resource-validation operation. Planning, documentation updates, hosted
evidence, and stage acceptance are lifecycle work, not additional increments.

### Increment 3.A — Closed source-resource catalog and installed projection contract

**Implementation status:** complete on 2026-09-16; Increment 3.B is next.

Add `resources/source-catalog.dcf` and
`resources/resource-catalog-schema.dcf`. The schema is also the first cataloged
resource under `rrp.contract.resource-catalog`. Extend the ownership map and
repository validator only for these concrete paths. Extend
`tools/validate-packages.R` to validate the closed schema/catalog, source
files, path and collision invariants, and deterministic installed projection
using only base R and temporary directories.

Evidence must parse every DCF record; verify exact identities, field sets,
controlled values, product-development identity, unique logical IDs and paths,
source closure, regular-file/link/containment rules, and byte-preserving
projection; and demonstrate rejection of missing/unknown fields, duplicate
IDs/paths, unsafe/traversing paths, case collisions, file/directory conflicts,
missing or linked sources, undeclared source files, and projection drift.

Historical catalog shape, logical IDs, path checks, source-to-installed
projection, and adversarial fixtures are adaptable after simplification. The
former 48 entries, expected-count constant, compatibility notes, exclusion
families, daily-hazard content, YAML dependency, and claimed distribution
inventory are rejected. Increment 3.A adds no package export, resource lookup,
operation result, installed tree, or distribution builder.

### Increment 3.B — Explicit-root resource access

**Implementation status:** complete on 2026-09-16; Increment 3.C is next.

Implement `rrp_open_resource_catalog()` and `rrp_resource_path()` in
`packages/rrpplatform/`, with focused manual pages and package-native tests.
Update package documentation, exact namespace expectations, package validator,
repository inventory, and ownership map atomically. `rrpruntime` remains
unchanged and export-free; `rrpplatform` retains `rrpruntime` as its only
import.

Maintainer evidence builds and installs both packages, constructs the
projected root in temporary space, changes to an unrelated working directory,
and invokes the installed `rrpplatform` package against that copied root with
no repository or Git context. Success resolves the schema resource by logical
ID with byte equality. Adversarial copies must cover invalid/missing/linked
roots; malformed, missing, changed, or unsupported catalog/schema; unknown or
malformed IDs; missing, linked, non-regular, escaping, case-conflicting, and
undeclared resources; closed-inventory mismatch; and post-open mutation.

The historical explicit-root APIs, typed failures, revalidation, copied-root
proof, and containment tests are adapted. Repository discovery, installed-root
selection, source-path fallback, `getwd()` inference, Git/sibling lookup, and
distribution assumptions are rejected. Increment 3.B stops before structured
operation results, projects, CLI, installation, or domain resources.

### Increment 3.C — Common operation result and privacy-safe diagnostics

**Implementation status:** complete on 2026-09-16; its committed evidence was
included in the successful Stage 3 hosted acceptance run.

Add the operation-result and diagnostic contracts as
`resources/contracts/operation-result.dcf` and
`resources/contracts/diagnostic.dcf`, catalog them as
`rrp.contract.operation-result` and `rrp.contract.diagnostic`, and implement
their internal constructors/validators plus the two exported interfaces
`rrp_validate_software_resources()` and `rrp_operation_succeeded()` in
`rrpplatform`. Add focused manual pages and package-native contract tests, then
expand copied-root validation so the installed package returns both successful
and failed resource-validation results without leaking unsafe detail.

Tests cover exact field/class shape, status/predicate behavior, success with
zero or warning diagnostics, failure/error/value invariants, ordering,
malformed objects, code/severity/message rules, bounded single-line text,
sensitive/path-like text rejection, one-result-per-operation semantics, and
safe translation of resource errors. The source catalog/projection tests prove
the two new contracts are closed current resources.

The small status/predicate pattern from historical validation/conformance
results and the safe-code, severity, bounded-message invariants from
`v0.1.0` diagnostics are adapted. Candidate/specification-specific issue
tables, analytical identities, operation-run correlation, timestamps, event
lifecycle, emitters, sinks, safe-detail taxonomies, metrics, persistence, and
console framework are rejected. Increment 3.C adds no CLI or generalized
workflow/logging system.

### Validation and hosted evidence

The existing human operations remain the complete Stage 3 maintainer surface:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
```

Repository validation grows only for the accepted resource/package files,
links, metadata parseability, source ownership, and hygiene. Package validation
grows from Stage 2 to cover the exact new exports, contracts, catalog/projection
invariants, package-native tests, copied-root success, and adversarial resource
and result behavior while retaining build, isolated install/load, dependency,
and exact `R CMD check --no-manual` evidence. No new validation framework or
maintainer command is justified.

The existing read-only `package-foundation` workflow needs no behavioral
change: it already invokes both human operations, so committed Stage 3 source
automatically exercises their expanded claims on Ubuntu/R 4.4. Final Stage 3
acceptance requires one successful hosted push or pull-request run for the
committed complete Stage 3 implementation and records its identity. That run
does not establish a distribution support cell or broader release claim.

### Stage 3 acceptance

Stage 3 is complete only when:

- the closed source catalog contains only real current resources and conforms
  to its versioned machine-readable schema;
- catalog IDs, classes, owners, formats, source paths, and installed paths are
  exact, unique, portable, case-safe, non-conflicting, and fully classified;
- deterministic projection removes repository-only source paths, preserves
  declared resource bytes and identities, and remains distinct from a future
  full distribution manifest;
- installed `rrpplatform` code opens the projected catalog from one explicit
  root and resolves an exact logical ID without repository, Git, sibling,
  environment, or working-directory discovery;
- copied/non-repository roots work and undeclared, missing, malformed, unsafe,
  escaping, linked, changed, case-conflicting, or otherwise invalid states fail
  closed with stable safe resource errors;
- `rrpplatform` owns only the exact accepted exports while `rrpruntime` remains
  dependency-light, export-free, and independent of `rrpplatform`;
- operation results expose exact machine-inspectable success/failure and value
  invariants for one operation, and callers can inspect success without prose;
- diagnostics use the small accepted code/severity/message contract and tests
  reject arbitrary, patient-level, credential, secret, connection, raw, or
  path-leaking content;
- repository validation, expanded package validation, parsing, builds,
  isolated dependency-order install/load, package-native tests, and strict
  package checks all pass without persistent generated output;
- the unchanged read-only hosted workflow successfully runs those same human
  operations for the committed Stage 3 implementation; and
- no installed-root selection, launcher, CLI, final distribution inventory or
  digest, project, canonical/clinical contract, risk calculation, analytical
  run identity, persistent diagnostics, log/metric/audit system, product,
  deployment, or release behavior has entered.

After the increments and hosted evidence pass, reconcile the realized resource
and result boundaries with True North and Platform Architecture and record any
deviation. Stage acceptance is a lifecycle action, not Increment 3.D.

**Acceptance result:** complete on 2026-09-16. All criteria above passed for
committed revision `11fc44835c0d3862196e1af5d1ef691e781c9688`, including
read-only hosted push run `35116049077` / job `104861623678`. Reconciliation
found no deviation from Platform True North or Platform Architecture. At that
acceptance point, the next lifecycle step was to detail Stage 4 — Independent
Project Foundation from the accepted Stage 3 baseline; Stage 4 source work had
not yet been authorized.

### Plain-language exit state

> RRP package code can safely find declared installed resources and report a
> structured operation outcome from an explicit software context, but there is
> still no hospital project or risk behavior.

### Historical reuse disposition

Reconnaissance inspected pre-reset Increment 2.B at commits `a08cd8e`,
`72f67fb`, and `c459f7d`, especially its catalog/schema, source projection,
`rrp_open_resource_catalog()`, `rrp_resource_path()`, package boundary tests,
copied-root fixtures, and adversarial path/resource tests. Stable logical IDs,
explicit-root behavior, source/installed field separation, uniqueness,
case/path/link/containment checks, catalog-change detection, typed errors, and
copy independence are substantially adaptable.

The former 48-entry inventory, daily-hazard and synthetic assets,
compatibility statuses, excluded-family ledger, fixed expected count,
repository-wide distribution classification, `distribution/software/`
authority, YAML dependency, `0.2.0-dev` identity, and validation-registry/Phase
integration are rejected. Current resources enter only with their current 1.0
owner.

Reconnaissance also inspected `v0.1.0` conformance/validation results,
runtime/estimation result wrappers, operational-event contracts and code, and
privacy/adversarial tests. Machine-readable status, a success predicate,
ordered issues/diagnostics, controlled codes and severities, bounded text, and
sensitive-detail rejection inform the clean contracts. Domain-specific result
fields, operation-run/event identity, timestamps, stage lifecycle, emitters,
sinks, retention, console verbosity, large context allowlists, and historical
operation composition do not return in Stage 3.

### Major deferrals and deliberately open decisions

Installed-root discovery/selection, installation identity, launcher and CLI,
final resource locations beyond the current projection, complete distribution
inventory and SHA-256 digests, distribution build/install/upgrade, final
dependency closure, and release packaging remain later lifecycle decisions.

Stage 4 owns explicit hospital-project context, manifest, trusted registration,
project initialization, and project health. Later stages own canonical and
clinical contracts, target/runtime/provider behavior, analytical run identity,
history, products/application, deployment, and release. Persistent diagnostic
sinks, logging, tracing, metrics, audit, arbitrary diagnostic context, and
remote resource services remain deferred until concrete requirements establish
their privacy, retention, trust, and dependency boundaries.

## Stage 4 — Independent project foundation

**Status:** accepted and complete on 2026-09-17 at committed baseline
`f5c1fb0db47e9154b99e133a8f553bee8ea2aa16`.

### Objective

Introduce the smallest durable public contract that makes one explicit
directory an independent hospital-owned RRP project. Installed `rrpplatform`
must be able to initialize, recognize, safely load, and diagnose that project;
validate its nonsecret manifest, software/API compatibility, trusted
producer/provider registration, exact selections, extension-dependency
boundary, and state-location declaration; and fail safely before any source,
provider, or state behavior runs.

Stage 4 creates project structure and trust context, not a hospital workflow.
It uses Stage 3's explicit software-resource context and structured operation
results without weakening the rule that software and project roots are always
separate caller-supplied inputs.

### Stage 3 reconciliation and inherited constraints

Stages 1–3 are accepted and complete at baseline
`16a7cd1651b28a93e223ae4389135ed8558f2ccc`. No corrective change is required
before Stage 4. The realized tree establishes these constraints:

- one validated `rrp_resource_catalog` created from an explicit software root
  is the only current installed-software context;
- `rrpplatform` owns resource access, stable operations, diagnostics, and
  orchestration; it imports only `rrpruntime` and currently exports four
  resource/result interfaces;
- `rrpruntime` remains dependency-light, export-free, and independent upward;
  project ownership does not move into it;
- the source resource catalog is closed and can add only real Stage 4 contract
  or template resources with exact source/installed ownership;
- common operation results and diagnostics are small, machine-inspectable, and
  privacy-safe; low-level resource failures remain typed errors;
- the two existing human validators and read-only hosted workflow already own
  repository, package, resource, copied-root, build/install/load, and strict
  package-check evidence; and
- there is no installed distribution, launcher, CLI, root selector, dependency
  environment, project, clinical contract, runtime behavior, or writable
  state implementation to discover implicitly.

### Scope test and settled Stage 4 decisions

Every responsibility was tested against one question: is it necessary for
installed RRP to initialize, recognize, load, and structurally validate an
independent project before source admission begins?

| Responsibility | Accepted Stage 4 boundary |
|---|---|
| Project root | One caller-supplied directory, canonicalized immediately. No working-directory default, parent search, Git, environment variable, sibling, package, or software-root inference enters package behavior. |
| Software context | Project APIs receive an already validated `rrp_resource_catalog` plus the explicit project root. They never reinterpret the project as a software root or vice versa. |
| Project physical contract | Exactly one root manifest at `rrp-project.dcf` and one trusted registration file at `R/register.R`; these fixed paths are public project-contract version `0.1.0`. Other project layout remains private unless a later contract owns it. |
| Manifest representation | Strict one-record DCF parsed with base R. Unknown, duplicate, missing, multiline continuation, or unsupported fields fail closed. No YAML/JSON dependency or executable configuration enters. |
| Compatibility | The manifest declares exact project contract `rrp.project@0.1.0` and exact supported project API `rrp.project-api@0.1.0`. Exact equality is the first compatibility rule; product and internal-package versions remain separate identities, and no speculative range/semver negotiation or migration machinery is added. |
| Registration | Installed RRP evaluates only `R/register.R`, once per project load, in a fresh controlled environment and invokes exactly one `rrp_register_project(project_root)` function. The result is closed to project identity plus producer/provider records. The environment is containment against accidental global coupling, not a security sandbox. |
| Registration records | Producer and provider collections contain exact component ID, version, and trusted callable fields. Stage 4 validates structure, identity, duplicates, protected namespaces, and availability only; it never invokes the callables or claims producer/provider conformance. |
| Selection | The manifest selects one exact producer ID/version and one exact provider ID/version. Resolution is deterministic and requires exactly one match; there is no alias, latest, priority, fallback, ensemble, or data-dependent selection. |
| Defaults | Future RRP-provided components remain installed software entries under protected `rrp.` identities. Project entries cannot shadow them, and the initializer never copies an installed default into a project. No installed producer/provider default is invented in Stage 4. |
| Extension dependencies | The manifest declares one safe project-relative extension-library path. Loading places installed RRP libraries before that project library and excludes ambient user libraries from declared project resolution. Stage 4 validates separation and protected-package conflicts only; it does not restore, install, lock, or close dependencies and does not introduce `renv`. |
| Project state | The manifest declares one safe project-relative state path. Stage 4 resolves and validates the intended location without creating history, adapters, schemas, locks, transactions, retention, backup, or migration behavior. |
| Initializer | One stable programmatic operation creates only the two required project files in a previously absent destination, verifies them through the loader, and promotes them atomically. It does not create Git, state, dependency-library, source, mapping, provider, model, test, documentation, product, or deployment scaffolding. |
| Loader | One low-level technical interface validates manifest and paths before trusted code, loads registration once, resolves exact selections, and returns one immutable project context. Expected project failures are typed; no operation result is forced onto low-level callers. |
| Doctor | One read-only project-validation operation calls the same loader and translates expected typed project failures into the existing operation-result/diagnostic contract. It does not execute extensions, access source data, initialize state, install dependencies, or perform production security validation. |

Full extension dependency management, producer/provider behavior, state
management, CLI convenience, project migration/upgrade, secret management, and
environment restoration fail the scope test and remain deferred. Stage 4
settles the contracts and ownership needed by later owners without simulating
their behavior.

### Software context and project context

The two explicit contexts remain distinct:

```text
validated rrp_resource_catalog
    → installed RRP contracts/templates and current software identity

explicit project root
    → hospital-owned manifest, trusted registration, extension boundary,
      and intended state location
```

The loader receives both. It first revalidates the software resources needed
for the project contract, then canonicalizes the project root independently.
It does not compare their physical ancestry, search from one to find the other,
or require either to be a development repository. A project may be copied or
moved without changing semantic identity because no stored absolute root is
part of its contract.

The returned `rrp_project_context` is an exact immutable list containing only:

- the validated software catalog context;
- normalized project root;
- validated manifest/project identity and compatibility;
- validated registration result;
- exact resolved producer and provider records with origin;
- normalized intended extension-library location; and
- normalized intended state location.

It contains no patient data, credential, open source connection, producer or
provider result, model object, analytical run identity, persistence session,
product, application, arbitrary configuration, or ambient environment state.
New operations load a new context; Stage 4 does not serialize executable
contexts or re-source registration during one operation.

### Minimum project manifest

The public root manifest is `rrp-project.dcf`. Its logical contract identity is
`rrp.project@0.1.0`, its format is strict DCF, and it contains exactly these
required fields in the first contract version:

| Field | Meaning and rule |
|---|---|
| `Record-Type` | Exact value `rrp-project`. |
| `Project-Contract-ID` | Exact value `rrp.project`. |
| `Project-Contract-Version` | Exact value `0.1.0`. |
| `Project-ID` | Stable non-patient project identity, at most 96 bytes, matching `^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$`; the protected `rrp.` prefix is prohibited. |
| `Project-Version` | One exact version, at most 64 bytes, matching `^[0-9]+[.][0-9]+[.][0-9]+(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$`. It is project source/config identity, not RRP software or state version. |
| `Project-Scope` | Exact value `one_health_system`. |
| `Supported-RRP-API-Version` | Exact value `0.1.0`, meaning compatibility with `rrp.project-api@0.1.0`. |
| `Producer-ID` / `Producer-Version` | One exact selected producer registration identity. |
| `Provider-ID` / `Provider-Version` | One exact selected provider registration identity. |
| `Extension-Library-Path` | One safe project-relative intended library location owned by project extensions. |
| `State-Path` | One safe project-relative intended writable-state location owned by the project. |

There are no optional or extension fields. Component IDs follow the same
bounded lowercase dot/hyphen identity discipline and component versions use
the same version grammar and limit as `Project-Version`. Safe
paths reuse Stage 3's forward-segment rules: no absolute, drive, home, empty,
dot, parent, control, or backslash segments. State and extension-library paths
must be distinct, non-overlapping, contained, case-safe, non-linked through
every existing segment, and unable to conflict with the manifest or fixed
registration path. If either location already exists it must be a contained,
non-linked directory; absence is valid because Stage 4 declares ownership but
does not initialize dependencies or state.

The manifest contains no executable code, function or package-install name,
arbitrary path, remote URL, source connection, credential, secret, clinical
mapping, model declaration, raw record, canonical-profile placeholder, target,
product/app/deployment setting, or free-form operation configuration. Unknown
fields fail rather than becoming an accidental plugin/configuration surface.
Canonical profile, producer/provider semantic declarations, models, and state
profiles enter only when their owning later contracts exist; schema versioning
supports that evolution without reserving empty fields now.

The exact project API version is the Stage 4 software-compatibility surface.
The installed software catalog still identifies the development product, but
the manifest does not couple a project to one product release when exact API
compatibility is sufficient. Thus `0.1.0` is the initial one-point supported
API range, not the package version, product version, project version, state
version, or a promise of semantic-version negotiation. Later architecture
fields such as canonical-profile support, model/dependency evidence,
persistence profile, and operation settings enter the manifest only when their
owning stages supply real contracts to validate.

`resources/contracts/project-manifest.dcf` becomes the software-owned,
cataloged machine-readable authority for the manifest identity, fixed paths,
exact fields, controlled values, identity/version rules, safe-path rules, and
unknown-field prohibition. Its logical resource identity is
`rrp.contract.project-manifest`.

### Fixed trusted registration

The second required project artifact is exactly `R/register.R`. It is a
regular non-linked file beneath the explicit root; the path is fixed by the
project contract and never read from the manifest. Installed RRP evaluates it
without changing the working directory in a new environment whose parent is
the base environment, requires the environment to expose exactly one function
named `rrp_register_project`, and calls that function with the normalized
project root.

The callable returns one closed registration result with exact fields:

```text
registration_contract_id
registration_contract_version
project_id
producers
providers
```

The identity is `rrp.project-registration@0.1.0`; `project_id` must equal the
already validated manifest. `producers` and `providers` are ordered lists of
records containing exactly `component_id`, `component_version`, and `callable`.
The callable must be an R function but is never invoked in Stage 4. Collections
may be empty in the abstract contract so future installed defaults remain
possible, but the selected producer/provider must each resolve exactly once
from the combined installed/project catalog for a project to load.

Project entries retain `project` origin, cannot use the protected `rrp.`
namespace, cannot duplicate kind+ID+version, and cannot override or shadow an
installed exact identity. Different exact versions remain distinct and never
create an implicit preference. The resolver canonicalizes ordering by
kind/ID/version, then performs exact selection. Registration does not select;
the manifest does not name functions or files.

`resources/contracts/project-registration.dcf` becomes the cataloged
machine-readable authority for this closed result and entry shape under
logical ID `rrp.contract.project-registration`. It defines no producer or
provider execution signature. Those kind-specific semantic contracts belong
to Stages 5 and 6.

Registration is trusted local R code, not a sandbox. It may create closures or
load explicitly reviewed project packages through the declared extension
library, but RRP does not scan directories, recursively source code, discover
plugins/packages, download remote code, or mutate `.GlobalEnv`. RRP can
validate the returned boundary and its own ordering, not prove arbitrary local
code harmless or deterministic. Documentation must preserve that honest trust
model.

### RRP defaults and project extensions

Resolution is one closed composition step:

```text
installed RRP component catalog (protected `rrp.` identities)
        +
validated project producer/provider registration
        ↓ reject collisions; retain origin
exact manifest producer/provider selections
        ↓ require exactly one match each
immutable selected records in project context
```

Stage 4 contains no real installed producer or provider, so it does not invent
one. The resolver contract nevertheless ensures that a later RRP-provided
default remains installed and can be selected exactly without being copied
into a project. A project-selected extension resolves from trusted project
registration. A missing selection, duplicate, protected-name attempt, or
collision fails closed. There is no implicit fallback from a missing project
component to an installed default.

The Stage 4 initializer creates minimal project-owned structural producer and
provider registrations so its output can exercise registration and exact
selection honestly. Their callables have no supported execution semantics and
are never invoked by any Stage 4 interface. They are not RRP defaults,
clinical implementations, or evidence of producer/provider conformance.

### Extension dependency and state boundaries

`Extension-Library-Path` is the minimum dependency contract. It names where
project-owned extension packages may be made available, separate from the
immutable RRP libraries. During registration loading, the controlled library
order is RRP-owned package libraries first, the declared project extension
library second if present, and base/recommended R libraries as required. An
ambient user library is not accepted as declared project closure. The loader
rejects a project library that contains or attempts to override RRP-owned
packages.

No dependency lock/manifest is created while the initialized project has no
external package dependency. Stage 4 neither chooses `renv` nor promises full
dependency reproduction. Restore/install, transitive closure, package-source
evidence, model dependencies, and deployment closure enter when a real
extension requires them. The fixed project library identity is enough to
prevent project dependencies from silently becoming software dependencies.

`State-Path` establishes only a contained project-owned location. The
initializer does not create an empty state directory, and a missing location is
a valid `not_initialized` state reported safely by doctor. If present, the
loader checks only structural containment, link, directory, and ownership
rules. Stage 7 owns state initialization, schemas, persistence adapters,
transactions, history, locking, backup, recovery, retention, and migration.

### Component ownership

| Component | Stage 4 responsibility |
|---|---|
| `rrpplatform` | Owns contract parsing, typed project errors, controlled registration, installed/project composition, exact selection, project context, loader, initializer, and doctor. It is the only package gaining project APIs. |
| `rrpruntime` | Gains no project responsibility, dependency, resource, or export. It remains the downward-only behavior-free leaf until computational runtime work has an accepted owner. |
| Installed software resources | Own the two contract authorities, the two initialization templates, and later installed default component registrations. They never contain hospital configuration or writable state. |
| Hospital project | Owns the manifest values, trusted registration and project extensions, declared extension-library boundary, and declared writable-state location. It contains no RRP implementation source. |
| Maintainer tooling | Extends the existing repository/package validators only to prove realized resources, exports, packages, and independent/adversarial projects; it creates no runtime-only interpretation. |
| Future CLI/launcher | Will select software/project roots and render operations for people. Stage 4 package APIs require explicit contexts and provide no ambient selection convenience. |
| Future readmit interface | Will orchestrate later source/runtime/product operations through stable platform APIs. It owns nothing and exposes no public workflow in Stage 4. |

### Package APIs, operations, and failures

All Stage 4 behavior belongs to `rrpplatform`; `rrpruntime` remains unchanged.
The planned technical interfaces are:

- `rrp_load_project(software_catalog, project_root)`: read-only low-level load
  returning one validated `rrp_project_context` or raising a typed project
  condition;
- `rrp_initialize_project(software_catalog, project_root, project_id,
  project_version)`: mutating operation that instantiates the two software-
  owned project templates in a previously absent destination and returns one
  common operation result; and
- `rrp_validate_project(software_catalog, project_root)`: read-only project
  doctor operation returning one common operation result.

The initializer derives protected-safe project producer/provider IDs from the
validated project ID and uses the project version for their initial exact
versions. Success reports only safe project identity/version and created
relative paths. It creates a sibling staging directory, validates the complete
staged project through `rrp_load_project()`, atomically promotes only to a
still-absent destination, and removes only its owned staging state on failure.
It never overwrites, merges with, or repairs an existing path.

The doctor uses operation ID `rrp.validate-project`. Success summarizes safe
project/contract/API identity, selected component IDs/versions/origins, and
extension/state boundary status. A declared but absent state location is a
successful structural result with a fixed warning, not hidden initialization.
Expected typed project errors become one failure result with the same stable
code and fixed message `RRP project validation failed.` Unexpected programming
errors are not hidden. Doctor executes registration because that is necessary
to validate the trusted boundary, but it never invokes a selected extension,
opens a source, creates state, restores dependencies, or performs production
security checks.

Low-level failures inherit from `rrp_project_error` and contain one bounded
safe machine code, one fixed maintainer message, and no arbitrary call/path/
parser/project content. The finite failure families cover invalid root,
missing/malformed/unsupported manifest, project/API incompatibility, unsafe
project paths, missing/malformed registration, duplicate or protected
registration, unknown/ambiguous selection, invalid extension-library boundary,
and invalid state location. Implementation may refine a family only when a
caller needs stable recovery; it must not generate a speculative code catalog.

The three exports remain technical internal-platform interfaces used by later
CLI/tests/automation. They are not the eventual ordinary operator surface and
do not make either internal R package the RRP product boundary.

### Implementation sequence

```text
4.A — Project manifest and registration contracts
        ↓
4.B — Trusted registration and explicit project loading
        ↓
4.C — Minimal independent-project initialization
        ↓
4.D — Structured project doctor and independent-project proof
        ↓
Stage 4 acceptance and reconciliation
        ↓
Detail Stage 5
```

Four increments are the smallest useful sequence. Contract authority must
precede executable loading; loading must exist before initialization can prove
its output; initialization must exist before doctor and copied-project evidence
can exercise the normal lifecycle. Doctor/integration remains separate from
the mutating initializer so each operation has one reviewable side-effect
boundary.

### Increment 4.A — Project manifest and registration contracts

**Implementation status:** complete on 2026-09-16; Increment 4.B is next.

**Objective:** make the exact Stage 4 project and registration structures
software-owned, versioned, cataloged, and internally parseable without loading
project code.

**Why here:** the loader and initializer require one fixed authority for every
field, path, identity, compatibility value, and closed registration shape.

**Implementation scope:** add the manifest and registration DCF contract
resources under the logical IDs above; add them to the closed source catalog;
implement cohesive internal `rrpplatform` parsing/validation for the manifest
and non-callable portions of a registration candidate; and add focused package-
native tests, manual package-orientation updates, ownership-map entries, exact
repository inventory, and package/resource validator coverage. No callable API
need be exported yet. Base R remains sufficient.

**Non-scope:** no project directory, registration execution, context, loader,
initializer, doctor, dependency library, state directory, CLI, clinical field,
or producer/provider behavior.

**Historical reuse:** adapt strict closed-envelope and identity/version checks
from the `v0.1.0` producer/provider contracts and pre-reset project-contract
assessments. Reject YAML dependency, estimand/clinical fields, repository root,
installed-producer composition, and broad specification machinery.

**Evidence:** exact DCF/resource identity and projection checks; strict field,
value, ID/version/path, compatibility, secret-exclusion, and unknown-field
tests; malformed/missing/duplicate/control/case/path adversarial cases; source
closure; package parsing and native tests; both existing validators, builds,
isolated install/load, and strict package checks.

**Completion statement:** RRP owns exact versioned project-manifest and trusted-
registration contracts, but it cannot yet execute registration or load a
project.

### Increment 4.B — Trusted registration and explicit project loading

**Implementation status:** complete on 2026-09-16; Increment 4.C is next.

**Objective:** load one hand-authored project from explicit software and
project contexts, execute only its fixed registration boundary, resolve exact
selections, and return a minimal immutable project context.

**Why here:** initialization and doctor must reuse one proven loader rather
than independently interpreting projects.

**Implementation scope:** implement typed project errors, controlled
registration evaluation, closed-result validation, protected namespace and
duplicate/collision policy, deterministic installed/project composition, exact
selection, extension-library ordering/separation, structural state-path
resolution, the exact `rrp_project_context`, and exported
`rrp_load_project()`. Add one focused manual and package-native loader tests.
Temporary hand-authored project fixtures live only under test/validation temp
roots; no repository project scaffold is added.

**Non-scope:** no producer/provider invocation or semantic conformance, source
access, initializer, doctor/result translation, dependency restore/lock,
state creation, CLI, migration, or ambient root selection.

**Historical reuse:** directly reuse the proven exact ID/version key,
duplicate rejection, trusted-function requirement, and fail-closed lookup
mechanics from `v0.1.0` producer/provider registries where they fit. Adapt the
pre-reset closed registration-result, controlled-environment, origin/collision,
and exact-selection design. Reject `.GlobalEnv`, recursive fixed-order source
chains, repository paths, and hard-coded reference composition.

**Evidence:** successful load from unrelated working directories and copied
roots; exact context shape; registration called once; no selected callable
invoked; installed/project origin preserved; deterministic result independent
of returned order; and adversarial missing/malformed/linked entry point,
unknown fields, wrong project identity, duplicate/protected/colliding entries,
unknown/ambiguous selections, unsafe state/library paths, RRP-package shadowing,
ambient-library dependence and working-directory/Git/root discovery rejection,
plus evidence that RRP itself neither uses nor mutates `.GlobalEnv`. Because
trusted project R code is not sandboxed, the loader does not claim that it can
prevent deliberately written registration code from mutating external state.
Retain all 4.A and Stage 1–3 evidence.

**Completion statement:** installed `rrpplatform` can safely load a manually
authored independent project and resolve its declared structural extensions,
but it cannot create or diagnose a project through a structured operation.

### Increment 4.C — Minimal independent-project initialization

**Implementation status:** complete on 2026-09-17; Increment 4.D is next.

**Objective:** create the smallest valid portable Stage 4 project through one
transactional programmatic operation.

**Why here:** the initializer can be trusted only after the loader defines and
validates its exact output.

**Implementation scope:** add cataloged software-owned templates at
`resources/templates/project/rrp-project.dcf` and
`resources/templates/project/R/register.R` under logical identities
`rrp.template.project-manifest` and `rrp.template.project-registration`;
implement exported `rrp_initialize_project()` with strict identity/version
inputs, safe rendering, sibling staging, load-before-promotion,
absent-destination enforcement, rollback, and existing operation-result
translation. The instantiated project contains exactly `rrp-project.dcf` and
`R/register.R`; the registration exposes one project-owned structural producer
named `<project-id>.producer` and one provider named `<project-id>.provider`,
both at the supplied project version and matching the manifest selections. Add
focused manuals and package-native initialization/rollback tests.

The manifest template writes `extensions/library` as the declared extension
library and `state` as the declared state location. Both locations remain
absent after initialization; their explicit values establish portable
ownership without speculative empty directories.

**Non-scope:** no `.gitignore`, Git repository, README, lockfile, extension
library, state directory, source/mapping/provider/model directory, tests,
clinical example, fictional data, products, deployment files, overwrite,
repair, upgrade, migration, or CLI.

**Historical reuse:** adapt destination ownership, staging, rollback, and
idempotency/failure-test mechanics from historical initialization/build code.
Reject embedded Platform extraction, Hospital distribution inventory, wrapper
scripts, top-level `renv`, ignored `build/`, and Git realization.

**Evidence:** initialize under an unrelated temporary parent; inspect exact
two-file inventory and bytes/fields; load the result through installed
`rrpplatform`; prove no repository/Git/software source copied; copy/move and
reload; and reject existing destination, symlink/unsafe destination, invalid
identity/version, token/render drift, interrupted staging, partial promotion,
and unsafe failure text. No generated project remains in repository source.

**Completion statement:** RRP can transactionally initialize and load the
smallest independent hospital-owned project, but it has no structured project
doctor yet.

### Increment 4.D — Structured project doctor and independent-project proof

**Implementation status:** complete on 2026-09-17; included in the accepted
Stage 4 baseline.

**Objective:** expose project health through the common operation-result
contract and prove the complete Stage 4 lifecycle outside repository/Git
context.

**Why here:** doctor is meaningful only after normal initialization and loading
exist; the final proof integrates rather than duplicates those operations.

**Implementation scope:** implement exported `rrp_validate_project()` as the
read-only project doctor; translate only expected project errors to safe
diagnostics; add focused manual/package-native tests; and extend
`tools/validate-packages.R` for the full initialized/copied/adversarial project
scenario while retaining package/resource evidence. Update current ownership,
repository inventory, package README, public/human guidance, and exact export
expectations only for realized Stage 4 paths and operations.

**Non-scope:** no new validator command or framework, CLI renderer, project
root selection, producer/provider execution, source/canonical validation,
dependency installation, state initialization, production permissions or
security assessment, persistence, run identity, products, app, distribution,
deployment, or release.

**Historical reuse:** adapt structured doctor status/recovery intent and
independent-adopter/copy fixtures. Reject Hospital wrapper delegation,
repository inventory/Git-state health, fixed reference database/product paths,
temporary runtime installation, Phase aggregates, and broad observability.

**Evidence:** exact doctor success/failure shape and predicate behavior;
privacy-safe codes/messages; warnings for declared-but-uninitialized state;
unexpected-error propagation; no callable execution or mutation; the complete
independent-project proof below; all package-native tests, builds, isolated
install/load, exact strict checks, repository validation, and generated-output
hygiene. The unchanged read-only hosted workflow must later pass for the
committed complete Stage 4 tree before stage acceptance.

**Completion statement:** RRP can initialize, recognize, safely load, and
diagnose an independent project and its selected structural registrations, but
it cannot admit source data or calculate risk.

### Validation and hosted evidence

No new maintainer command or validation framework is justified. The existing
human operations remain:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
```

Repository validation grows only for real contract/template/package/manual/test
paths, links, metadata, ownership, and hygiene. Package validation grows
incrementally from Stage 3 to cover contract resources, installed parsing,
explicit-root loading, initialization, doctor, copied projects, and adversarial
project behavior while retaining exact package topology, builds, isolated
dependency-order install/load, package-native tests, and both strict package
checks.

The existing `package-foundation` workflow already invokes both operations on
push and pull request under read-only Ubuntu/R 4.4. It needs no behavior change
solely because their owned claims grow. Final Stage 4 acceptance requires one
successful hosted run for the committed complete Stage 4 tree and records the
run/job/SHA/ref/event. That remains narrow package/project-foundation evidence,
not installed-distribution, clinical, production, or OS support.

### Independent-project acceptance proof

The final local/hosted operation constructs all evidence in temporary space:

```text
build and isolate-install rrpruntime then rrpplatform
        ↓
construct an explicit temporary software-resource root
        ↓
from an unrelated working directory with no Git context,
initialize a project at an unrelated absent destination
        ↓
assert its exact two-file inventory and absence of RRP source/default copies
        ↓
load it with the explicit software catalog + project root
        ↓
resolve the exact structural producer/provider selections without invoking them
        ↓
run project doctor and inspect structured success/warning evidence
        ↓
copy the project somewhere else; load and doctor it successfully
        ↓
mutate independent copies one condition at a time
        ↓
prove safe fail-closed behavior and complete cleanup
```

Adversarial copies cover missing/linked/malformed/unknown-field/incompatible
manifest; unsafe, colliding, case-conflicting, linked, or escaping state/library
paths; missing/linked/malformed registration; wrong project identity; extra
top-level bindings/fields/kinds; non-callables; duplicates; protected RRP
identities; installed/project collisions; unknown/ambiguous selections;
extension-library RRP-package shadowing; ambient user-library dependence;
post-copy absolute-path leakage; unsafe diagnostic content; unexpected error
propagation; and destination/staging mutation failures.

The proof has no source/sibling repository access from installed child
processes, Git requirement, original absolute project path, working-directory
assumption, network, secret, real/patient-like data, `renv`, copied RRP source,
producer/provider execution, or persistent repository output.

### Stage 4 acceptance

Stage 4 is complete only when:

1. a minimal project initializes outside the source repository through one
   supported programmatic operation;
2. initialized output contains exactly the currently justified root manifest
   and fixed registration file, with no speculative tree or copied RRP source;
3. recognition/loading requires one explicit project root plus a separately
   validated explicit software context;
4. project, project-contract, and exact project-API compatibility identities
   are validated before trusted code executes;
5. the manifest is versioned, strict, nonsecret, declarative, safe, and rejects
   missing/unknown fields or executable/arbitrary configuration;
6. project-relative extension/state paths are portable, case-safe,
   non-conflicting, non-linked, contained, and unable to escape the project;
7. exactly the fixed registration entry point is loaded in a controlled
   environment and its closed result admits only producer/provider records;
8. installed defaults remain software-owned, are never copied by initialization,
   and retain protected origin/identity during resolution;
9. producer/provider selection uses exact ID/version and fails on missing,
   duplicate, ambiguous, or implicit-fallback states;
10. project extensions cannot shadow, override, or collide with protected RRP
    identities;
11. the project extension-library boundary remains structurally separate from
    installed RRP and ambient user libraries without claiming restore/closure;
12. one contained project state location is established without implementing
    state/history behavior or creating placeholder state;
13. installed package code loads the project from an unrelated working
    directory with no repository, Git, sibling, environment, or parent search;
14. an independently copied/moved initialized project loads and doctors
    successfully without its original absolute path;
15. malformed, unsafe, incompatible, changed, or ambiguous projects fail
    predictably through bounded typed project errors;
16. doctor returns exact common structured success/failure evidence, reports
    absent state honestly, and never parses prose for status;
17. failures and diagnostics retain the accepted privacy posture and never echo
    arbitrary project paths, parser content, secrets, registration code, or
    project data;
18. `rrpplatform` remains the sole project owner, imports only `rrpruntime`,
    and `rrpruntime` remains dependency-light, export-free, and independent;
19. repository validation, expanded package validation, DCF/R/Rd parsing,
    package-native tests, builds, isolated install/load, copied-project proof,
    strict package checks, hygiene, and committed read-only hosted evidence all
    pass without persistent generated output; and
20. no source admission, canonical/clinical semantics, readmission target,
    producer/provider execution, risk calculation, analytical run identity,
    history/state persistence, product, application, CLI/root selection,
    dependency restore, distribution, deployment, or release behavior enters.

After implementation and committed hosted evidence pass, reconcile the
realized project boundary with True North and Platform Architecture and record
any deviation. Stage acceptance is a lifecycle action, not Increment 4.E.

**Acceptance result:** accepted and complete on 2026-09-17. All criteria above
passed for committed revision
`f5c1fb0db47e9154b99e133a8f553bee8ea2aa16`, including unchanged read-only
hosted push workflow `package-foundation`, run `35221028009`, job
`105200921084`, result `success`. Reconciliation found no deviation from
Platform True North or Platform Architecture. The next planning task is to
detail Stage 5 — Canonical Handoff and Producer Boundary from this accepted
baseline; Stage 5 source implementation remains unauthorized until that plan
is accepted.

### Plain-language exit state

> RRP can initialize, recognize, safely load, and validate an independent
> hospital-owned project and its declared producer/provider registrations, but
> it cannot yet admit source data or calculate readmission risk.

### Historical reuse disposition

| Classification | Historical finding and disposition |
|---|---|
| Reuse directly | Exact kind/ID/version registry keys, duplicate rejection, trusted function-object checks, and fail-closed exact lookup from the `v0.1.0` producer/provider registries, after only owner/name and safe-error integration changes. |
| Adapt concept/mechanic | Explicit roots, fixed manifest and registration, manifest-before-code validation, controlled evaluation, closed results, installed/project origin, protected namespace, dependency/state separation, transactional initialization, and independent-copy/adversarial tests. |
| Reject for 1.0 | Generated Hospital repositories, copied Platform source, editable-tree closed inventories, pristine Git/branch/remote rules, root `renv`, repository-root operations, `.GlobalEnv` composition, recursive sourcing, runtime hospital selectors, Phase/distribution/release machinery, and source-relative behavior. |
| Not relevant | Daily-hazard/estimand identities, canonical execution, clinical contracts, provider computation, history, products, application, artifact, and deployment behavior; their eventual owners assess them just in time. |

Reconnaissance inspected immutable `v0.1.0`, especially
`operations/compositions/installed-producers.R`,
`operations/lib/canonical-producer-operation.R`,
`runtime/R/provider-registry.R`, the Phase 10 independent-adopter fixture/tests,
and the generated Hospital initialization, doctor, manifest, and composition
files. Exact ID/version registry keys, trusted function objects, duplicate
rejection, fail-closed lookup, one-health-system selection, structured
outcomes, materially different adopter composition, and independent-copy/
privacy failure ideas are useful.

Pre-reset revisions `f4a98a8`, `6c2ac3b`, `fd98c73`, and `c459f7d` were
inspected through the adoption assessment, installed-software/project-model
assessment, estimand-composition/project-registration assessment, and minimum
project-contract assessment. Explicit root, fixed manifest/registration,
manifest-before-code ordering, controlled evaluation, closed registration
results, installed/project origin, protected namespace, exact selection,
dependency separation, state-location declaration, and copied-project proof
are adapted conceptually to the current singular-target architecture.

The exact historical registry insertion/resolution mechanics are candidates
for direct reuse after renaming and safe-error adaptation. Historical YAML
schemas, estimand registration, daily-hazard identities, source/profile/model
semantics, history/product/app execution, and broad specification envelopes are
not relevant to Stage 4 and remain with later owners.

Generated Hospital repositories, embedded/copied Platform source, closed
inventories over editable hospital content, pristine/clean Git requirements,
branch/remote rules, top-level `renv`, temporary runtime installation,
repository-root operations, `.GlobalEnv` composition, recursive/fixed-order
sourcing, hard-coded synthetic/reference selection, runtime hospital selectors,
Phase suites, distribution validators, release wrappers, and candidate-era
status are rejected. Historical code is evidence, not a runtime dependency or
compatibility obligation.

### Major deferrals and deliberately open decisions

Stage 5 owns canonical profile identities and schemas, producer declarations,
callable execution/result semantics, source mapping, canonical admission, and
actual profile/capability compatibility. Stage 6 owns the singular target,
request, provider declaration/conformance/execution, model semantics, and any
real installed default provider. Stage 7 owns state initialization,
persistence/history, adapters, locking, backup/recovery, and state migration.

Full project dependency restoration, transitive closure, lock format, package
acquisition, reproducibility evidence, and model artifacts remain open until a
real extension requires them; `renv` is neither required nor prohibited as a
future mechanism. CLI syntax and project selection, installed-software root
selection, distribution placement, project migration/upgrade, production
identity/access control, secrets service/environment contracts, approved
external/mounted state, product/app overrides, deployment, and release remain
later work.

No project API version range negotiation is needed while only
`rrp.project-api@0.1.0` exists. Later support for more than one exact project
contract/API version must be evidence-driven and must not silently migrate
projects. The Stage 4 registration callable shape is structural only; producer
and provider semantic conformance remains deliberately unresolved until their
own stages.

## Stage 5 — Canonical handoff and producer boundary

**Status:** accepted and complete on 2026-09-17. Increments 5.A–5.C, committed
hosted evidence, and formal acceptance/reconciliation are complete. This
section records only the three accepted Stage 5 increments.

### Objective

Establish the exact supported boundary at which hospital-owned source
interpretation ends and generic RRP behavior begins. Installed RRP must be able
to construct one closed producer request, execute exactly the producer already
selected by an explicit loaded project, validate its closed result, and admit
or reject a minimum source-independent canonical bundle through versioned
identity, profile, relationship, capability, and temporal rules.

Stage 5 makes the producer executable under one supported contract. The
selected provider remains structurally registered and resolvable but is never
invoked. Successful admission remains in memory and does not initialize or
write project state.

### Stage 4 reconciliation and inherited constraints

Stages 1–4 are accepted and complete at committed baseline
`f5c1fb0db47e9154b99e133a8f553bee8ea2aa16`. No corrective source change is
required before Stage 5. The realized tree establishes these constraints:

- every project operation receives one validated explicit software-resource
  catalog and one explicit project root; no working-directory, parent, Git,
  sibling, environment-variable, or source-tree discovery is allowed;
- the project loader is the sole authority for manifest validation, trusted
  registration, installed/project composition, exact producer/provider
  selection, library separation, and immutable project-context construction;
- the selected producer and provider are trusted function objects but their
  Stage 4 callable shapes are deliberately inert and semantically unvalidated;
- `rrpplatform` owns project loading, operation orchestration, installed
  resources, and common results/diagnostics and imports only `rrpruntime`;
- `rrpruntime` is dependency-free and export-free, but its target architecture
  makes it the owner of admitted canonical types and post-handoff computation;
- project registration is trusted hospital code evaluated in a controlled
  environment, not a security sandbox; project dependencies may be used only
  through the already declared extension library after RRP-owned libraries;
- initialization still creates exactly `rrp-project.dcf` and `R/register.R`;
  it creates no source, configuration, dependency, state, test, or model tree;
- the common operation-result and diagnostic contracts allow bounded
  machine-readable results while prohibiting unsafe diagnostic content; and
- the existing repository/package validators and read-only hosted workflow are
  the evidence path to extend. No new validation framework is justified.

A post-acceptance manual installed-software exercise independently initialized,
loaded, doctored, copied, reloaded, and re-doctored a project successfully.
The copy resolved its own project paths. A leading `~` in the initializer
destination was rejected while the equivalent absolute path succeeded. That
is a deferred user-interface convenience concern, not a Stage 4 defect and not
a reason for Stage 5 to change path safety.

### Scope test and settled Stage 5 decisions

Every responsibility is tested against one question: is it required to execute
one selected hospital producer and turn its minimum candidate into admitted
canonical input without beginning provider execution, risk calculation, or
persistence?

| Responsibility | Accepted Stage 5 boundary |
|---|---|
| Semantic authority | Cataloged, installed, versioned DCF resources define one small specification envelope, producer contract, canonical bundle, readmission profile, and two domain contracts. DCF preserves the current dependency-light installed-resource model; Stage 5 does not restore YAML or create a general schema engine. |
| Current realization | The semantic handoff is representation-independent. The first executable adapter accepts one closed in-memory base-R realization. Files, tables, databases, or services may later adapt to the same semantics but are not separate Stage 5 transports. |
| Project compatibility | The project manifest gains the exact supported canonical profile ID/version. Because this is a new required public field and producer registration gains semantic fields, the development project contract, project API, and registration contract advance together from `0.1.0` to `0.2.0`. There is no silent acceptance or migration of the structural `0.1.0` form. |
| Producer declaration | The selected producer record declares exact producer, implementation, mapping, producer-API, canonical-bundle, canonical-profile, and capability identities beside its trusted callable. The provider record remains the Stage 4 structural ID/version/callable only. |
| Producer request | RRP supplies one exact immutable request containing only project and producer identity, requested bundle/profile identity, and caller-supplied as-of time. It supplies no source payload, configuration, credential, connection, project path, provider, state handle, or arbitrary options. |
| Source access | Hospital code obtains source information through its trusted producer closure and project-owned dependencies/configuration or an approved external secret/source environment. Registration already receives the explicit project root and may capture it. Generic RRP neither understands nor forwards source-system details. |
| Invocation | RRP invokes exactly the selected producer once, with exactly one request, under the accepted library ordering and without changing the working directory. There is no fallback, retry, discovery, parallel producer, or identity-specific branch. |
| Producer result | The callable returns one closed success/failure result. Success carries identities, capabilities, as-of agreement, and exactly one candidate bundle. Failure carries one controlled failure code and no bundle. Arbitrary messages, source rows, paths, exceptions, SQL, configuration, and connection details cannot cross this result boundary. |
| Canonical admission | `rrpruntime` owns one pure dependency-light admission primitive. It validates a detached candidate against the exact expected context and minimum profile, returns one validated admitted-bundle value, or raises bounded typed canonical failures for `rrpplatform` to translate. It never reads a source, project, resource path, provider, or state. |
| Operation result | `rrpplatform` owns one stable producer-execution operation returning the existing common operation result. Success contains the admitted in-memory bundle. Expected project/producer/canonical failures become fixed privacy-safe diagnostics; unexpected producer conditions are contained at the extension boundary without echoing them. Unexpected defects in RRP code remain visible rather than being relabeled as producer failures. |
| Provider boundary | The provider remains selected in project context only. Stage 5 does not validate provider semantics, construct provider input, invoke it, catch its errors, register an installed default, or interpret a model. Instrumented evidence must prove zero provider calls. |
| State boundary | Admission is in memory. No state directory, database, cache, history, run ledger, audit log, retained canonical bundle, lock, migration, or product is created or written. |
| Clinical claim | Canonical admission proves software-contract conformance only. It does not prove source correctness, clinical validity, completeness, calibration, production approval, privacy authorization, or fitness for care decisions. |

### Versioned specification and installed-resource authority

Stage 5 introduces a deliberately small closed specification family. Each
resource uses the same exact DCF envelope: specification kind, ID, version,
format version, identity scope, lifecycle status, product/development identity,
and owning package. The first specification format version is `1.0.0`; the
first semantic contract/profile/domain versions are `0.1.0`. Exact version
equality is the only supported compatibility rule in this development
generation. Unknown kinds, fields, records, IDs, versions, formats, or status
values fail closed.

The cataloged source resources and logical identities are:

| Resource | Logical identity | Semantic owner |
|---|---|---|
| `resources/contracts/canonical/specification-envelope.dcf` | `rrp.contract.specification-envelope` | Common exact metadata shared by the Stage 5 specifications. |
| `resources/contracts/canonical/canonical-producer.dcf` | `rrp.contract.canonical-producer` | Producer declaration, request, result, failure, and invocation semantics owned by `rrpplatform`. |
| `resources/contracts/canonical/canonical-bundle.dcf` | `rrp.contract.canonical-bundle` | `rrp.canonical-bundle@0.1.0` identity, exact in-memory adapter shape, capability/domain registration, and admission rules owned semantically by `rrpruntime`. |
| `resources/contracts/canonical/profiles/readmission.dcf` | `rrp.profile.readmission` | `rrp.canonical-profile.readmission@0.1.0`, the only profile supported in Stage 5. |
| `resources/contracts/canonical/domains/discharge-episode.dcf` | `rrp.domain.discharge-episode` | Exact root-domain fields, keys, cardinality, and temporal rules. |
| `resources/contracts/canonical/domains/terminal-event.dcf` | `rrp.domain.terminal-event` | Exact readmission/death event fields, vocabulary, relationship, cardinality, and dual-time rules. |

These are ordinary installed resources reached through the existing explicit
catalog. They are public semantic authorities, not executable configuration.
They name no R function, package install command, local path, source system,
hospital, provider, model, secret, or storage location. Executable package code
and tests must prove exact agreement with them. The resource catalog remains
closed; adding these resources does not turn it into dynamic discovery.

This Stage 5 envelope is intentionally not a universal specification language.
It supports only the exact kinds now required. General dependency graphs,
arbitrary conditional rules, compatibility ranges, custom validators, embedded
code, multiple profiles, and extension fields remain absent.

### Minimum readmission canonical representation

The first profile contains only an episode root and terminal outcome evidence:

```text
rrp.canonical-profile.readmission@0.1.0
├── discharge_episode   required capability; zero or more rows
└── terminal_event      required capability; zero or more rows
                         event_type = readmission | death
```

Zero rows is a valid available domain state; it is not `unavailable` or
`unsupported`. The Stage 5 acceptance scenario must nevertheless admit a
nonempty bundle so the boundary is proven with actual relationships and time
semantics rather than an empty structural object. Both capabilities are
required and `available`. A producer that cannot supply terminal-event
coverage cannot conform to this profile and may not fabricate an empty domain
while declaring the capability unavailable.

The exact logical fields are:

| Domain | Fields |
|---|---|
| `discharge_episode` | `episode_id`, `patient_id`, `index_encounter_id`, `admission_time`, `discharge_time`, `followup_window_end` |
| `terminal_event` | `terminal_event_id`, `episode_id`, `event_type`, `occurred_at`, `available_at` |

`episode_id` is the root key. A patient may have multiple episodes.
`terminal_event.episode_id` must resolve exactly one root. Identifier
construction remains producer-owned; admitted identifiers are bounded,
nonempty values but never appear in ordinary diagnostics. Unknown fields and
non-plain/reference-bearing R values fail closed.

The profile enforces:

- explicit-offset RFC 3339 instants normalized for elapsed-time comparison;
- `admission_time < discharge_time <= bundle as_of_time`;
- `followup_window_end == discharge_time + 30 * 86,400` elapsed seconds;
- at most one first `readmission` and one `death` event per episode;
- `discharge_time < occurred_at <= followup_window_end`;
- `occurred_at <= available_at <= bundle as_of_time`;
- no duplicate root or terminal-event keys and no orphan event relationship;
- death before readmission prohibits a later readmission, while equal
  occurrence instants remain valid so Stage 6 can apply the architecture's
  readmission-precedence target rule; and
- candidate/result/project/producer/profile/capability/as-of identities agree
  exactly before the value becomes admitted input.

`followup_window_end` is not a producer-selected risk horizon. The profile
requires the producer to represent coverage through the RRP-owned fixed day-30
boundary and RRP validates the exact elapsed-time equality. Stage 6 still owns
eligibility, target meaning, terminal conditioning, request construction, and
same-instant target precedence.

The two domains are sufficient because Stage 6 can identify discharged
episodes and the first known readmission/death evidence without a broad
clinical model. Baseline scores, diagnoses, medications, facilities, services,
dispositions, demographics, generic events, features, tasks, interventions,
measures, and provider-specific inputs are not required to prove the handoff.
They must not be added speculatively. A later profile revision may add a domain
only with a demonstrated runtime/provider need and its own compatibility and
conformance evidence.

### Canonical bundle and producer result

The first in-memory candidate is one exact plain named list containing:

- bundle contract ID/version and one non-patient bundle instance ID;
- project ID/version;
- selected producer ID/version;
- implementation ID/version and mapping ID/version;
- canonical profile ID/version;
- the exact authoritative as-of time;
- the exact two required capability declarations; and
- an exact named domain collection containing the two data-frame realizations
  above.

Sequence position, filename, table name, working directory, object name, or
source-system identity never supplies logical identity. A candidate contains
no functions, environments, external pointers, connections, arbitrary
attributes, executable code, source configuration, credentials, provider,
state handle, conformance flag, or free-form metadata. Admission copies and
validates the value so later producer mutation cannot alter the admitted
object.

The producer callable returns an exact plain result with contract identity,
`succeeded` or `failed` status, producer/implementation/mapping/profile/as-of/
capability agreement, one candidate bundle on success, and one controlled
failure code on failure. Success prohibits a failure code; failure prohibits a
candidate. RRP derives admission success itself and never trusts a producer-
supplied conformance flag.

The initial producer failure vocabulary is intentionally narrow:
`producer_unavailable`, `producer_source_failed`, and
`producer_mapping_failed`. It conveys which producer-owned stage stopped
without transporting local exceptions or payloads. A malformed result is an
RRP-detected `invalid_producer_result`; a condition thrown by project code is
reported as `producer_execution_failed`. Canonical issue codes identify the
failed invariant without including row values or identifiers. No generalized
logging, event stream, audit trail, or run history is introduced.

### Project-contract evolution and producer declaration

Stage 5 advances the unreleased development project contract/API and project-
registration contract to `0.2.0`. The manifest adds exactly:

- `Canonical-Profile-ID: rrp.canonical-profile.readmission`; and
- `Canonical-Profile-Version: 0.1.0`.

The trusted registration result remains closed to project identity, producers,
and providers, but records become kind-specific. A provider record retains
only `component_id`, `component_version`, and `callable`. A producer record
adds exact producer-API, canonical-bundle/profile, implementation, mapping, and
capability declarations. Registration validation checks those declarations
and exact manifest agreement without invoking the callable.

The initializer retains its exact two-file output and create-only transactional
behavior. Its generated producer record conforms semantically and its callable
returns the controlled `producer_unavailable` failure until the hospital
implements it. Its provider remains the structural unavailable callable from
Stage 4. Initialization therefore remains honest: a new project is valid
structure, not a fictional source integration or risk implementation.

Changing required fields is incompatible by design. Current source, templates,
tests, and documentation move atomically to the one supported `0.2.0` line.
The prior `0.1.0` structural contract remains accepted historical Stage 4
evidence but is not supported concurrently and is not silently upgraded.
Migration tooling, compatibility ranges, multi-version dispatch, and project
rewriting are deferred. This is planned forward development before a 1.0
release, not a reopening of Stage 4 acceptance.

### Producer request, execution, and admission operation

`rrpplatform` introduces one exported technical operation,
`rrp_execute_producer(software_catalog, project_root, as_of_time)`, with
operation ID `rrp.execute-producer`. It performs one readable sequence:

```text
revalidate explicit software context
        ↓
load explicit project through the authoritative loader
        ↓
resolve and revalidate the selected producer declaration
        ↓
construct one closed rrp_producer_request
        ↓
invoke its trusted callable once under controlled libraries
        ↓
validate the closed producer result and identity agreement
        ↓
admit the candidate through rrpruntime
        ↓
return common structured success or bounded failure
```

The request contains exactly producer API ID/version, project ID/version,
selected producer ID/version, canonical bundle/profile ID/version, and the
strict caller-supplied as-of time. It does not include the project context,
root, software catalog, provider, state path, extension-library path, source
data, configuration, credentials, connection, arbitrary `...`, or callback.

The trusted registration function already receives the normalized project
root. A producer may return a closure that captures that root and reads
hospital-owned configuration or source material. It may use declared project
dependencies because invocation repeats the established library ordering:
RRP-owned libraries first, the declared project extension library second, base
R last, and ambient user/site libraries excluded from declared resolution.
RRP does not change the working directory and restores library state after the
call.

The operation catches conditions only around the project extension call and
maps them to one fixed safe diagnostic. It validates returned content before
using it. Expected project, producer-result, and canonical-admission failures
become common failure results with `NULL` value and bounded diagnostics.
Resource-authority failures retain resource ownership, and unexpected internal
RRP conditions propagate. Success returns the validated admitted bundle as a
closed typed in-memory value; callers must treat that value as sensitive data,
not console/log output. The operation itself emits no rows or identifiers and
has no persistent side effect.

`rrpruntime` gains its first exported internal-package interface,
`rrp_admit_canonical_bundle()`. It receives the detached candidate and exact
expected identity/profile/as-of contract context assembled by `rrpplatform`.
It has no filesystem, resource-catalog, project, source, provider, operation-
result, or persistence responsibility. The one-way dependency remains
`rrpplatform` to `rrpruntime`; runtime never imports upward.

Stage 5 does not create a unique analytical-run or provider-execution identity.
The operation identity is stable, while durable run/attempt identity and
history attribution begin in Stage 7 after Stage 6 supplies an analytical
request/estimate lifecycle. Bundle instance identity remains part of the
handoff but is not persisted here.

### Component ownership

| Owner | Stage 5 responsibility |
|---|---|
| Installed resources | Own the language-neutral exact specification, producer, bundle, profile, and domain authorities. They contain no hospital instance, source configuration, data, or executable code. |
| `rrpruntime` | Owns pure canonical candidate/domain/relationship/temporal validation, typed canonical failures, detached admitted-bundle construction, and its single admission export. It gains no project, producer execution, provider, result, resource-path, or state responsibility. |
| `rrpplatform` | Owns resource loading/agreement, project-contract evolution, producer declaration/request/result validation, controlled invocation, admission orchestration, common result translation, and the producer-execution export. |
| Hospital project | Owns source access, local source validation, identifier construction, mapping, implementation/mapping identities, producer callable, project dependencies/configuration, and all sensitive source details below the boundary. |
| Provider registration | Remains structurally selected but semantically inert; Stage 5 adds no provider-owned contract or behavior. |
| Maintainer tooling | Extends current catalog, package, installed-copy, project-copy, boundary, failure, build/check, and hygiene evidence. It does not become runtime authority. |

### Implementation sequence

```text
5.A contract/profile and semantic producer declaration
        ↓
5.B dependency-light canonical admission
        ↓
5.C selected producer execution and full boundary proof
        ↓
Stage 5 acceptance and reconciliation
```

Each increment preserves all earlier repository/package/resource/project
evidence and stops before the next responsibility.

### Increment 5.A — Canonical contract authority and semantic producer declaration

**Implementation status:** complete on 2026-09-17; Increment 5.B subsequently
completed, followed by Increment 5.C.

**Objective:** establish the complete language-neutral Stage 5 handoff contract
and make a loaded project declare an exact compatible producer without
executing it.

**Why here:** runtime admission and producer invocation need one accepted set
of identities, shapes, profile semantics, and project compatibility facts.

**Implementation scope:** add and catalog the six exact DCF resources above;
extend catalog/resource validators for their exact closure; advance project
manifest, API, and registration contracts to `0.2.0`; add manifest profile
selection and kind-specific producer declaration validation; update the
initializer template, loader context, doctor summary, manuals, package tests,
ownership map, inventory, and exact export/resource expectations only as
required. The loader must still invoke no producer or provider callable.

The generated producer declaration uses project-derived implementation and
mapping identities, selects the one Stage 5 profile/capability set, and returns
the controlled unavailable result if later executed. The initialized project
inventory remains exactly two files and both declared library/state locations
remain absent.

**Public/internal interfaces changed:** no new export. Existing initialization,
loading, and doctor interfaces now recognize only the exact `0.2.0` project
contract/API and expose the selected canonical profile in their closed context/
summary. Producer records gain semantic declarations; provider records do not.

**Historical reuse:** adapt `v0.1.0` specification-envelope identity fields,
producer declaration/callable separation, exact profile/capability agreement,
canonical bundle/profile/domain vocabulary, and strict closed-field tests.
Reject YAML/parser dependency, installed-composition selection, configuration
payloads, broad generic dependency graphs, baseline-risk and generic-event
domains, estimands, and repository-root loading.

**Evidence:** exact DCF parsing, identities, versions, fields, cross-resource
references, catalog projection, and code/resource agreement; valid initialized
and hand-authored `0.2.0` projects; copied-project portability; no callable
invocation; exact producer/provider kind shapes; profile/producer/manifest
agreement; and adversarial missing/unknown/duplicate/old-version/profile/
capability/identity/declaration cases. Retain all Stage 1–4 evidence.

**Explicit exclusions:** no canonical R type or admission, producer execution,
source data or mapping, provider semantics, state write, compatibility bridge,
migration operation, YAML, dependency restore, or new validator command.

**Completion statement:** installed RRP can load a project whose selected
producer declares the exact Stage 5 handoff it intends to implement, but it
cannot yet validate or admit a candidate bundle.

### Increment 5.B — Dependency-light canonical bundle admission

**Implementation status:** complete on 2026-09-17; Increment 5.C subsequently
completed.

**Objective:** implement the pure post-handoff validator that turns one valid
candidate into an admitted canonical bundle without knowing any source or
project implementation detail.

**Why here:** admission semantics should be independently proven before trusted
project execution and orchestration can depend on them.

**Implementation scope:** add the dependency-free `rrpruntime` canonical types,
strict timestamp/identifier/shape validators, domain and cross-domain rules,
typed canonical failures, detached admitted-bundle construction, and exported
`rrp_admit_canonical_bundle()`. Add focused runtime-package documentation and
base-R tests. Extend `rrpplatform` only enough to load/normalize the exact
installed canonical resources and supply the expected context in direct
integration tests; do not invoke project code.

**Public/internal interfaces changed:** `rrpruntime` moves from zero exports to
exactly one internal-package export. `rrpplatform` gains no export in this
increment. The admitted type is a closed in-memory analytical input, not a
storage format or user-facing data model.

**Historical reuse:** adapt identity agreement, closed shapes, primary-key and
foreign-key rules, exact field rejection, elapsed-time comparisons, capability
agreement, multi-issue adversarial ideas, and dual occurrence/availability
semantics from `v0.1.0`. Replace root terminal timestamps with the explicit
dual-time terminal domain and require exact day-30 follow-up. Reject YAML/R-list
test-realization coupling, baseline score and broad event semantics, daily-
hazard logic, runtime eligibility, and repository-source resource access.

**Evidence:** valid nonempty and empty-domain candidates; detached-copy and
input-nonmutation proof; exact identity/profile/capability/as-of agreement;
multiple episodes per patient; relationship/key/cardinality rules; explicit-
offset and elapsed-day behavior including timezone offsets; endpoint inclusion;
late availability; equal readmission/death time; and adversarial unknown fields,
types, classes, reference values, duplicates, orphans, bad order, shortened/
extended follow-up, future occurrence/availability, death-before-later-
readmission, unsupported versions, and unsafe failure rendering. Retain all
prior package/build/check evidence and prove the one-way package dependency.

**Explicit exclusions:** no producer or provider call, project root, source
mapping, eligibility, risk request, state, history, products, persistence,
serialization format, transport adapter, or clinical-validity claim.

**Completion statement:** dependency-light runtime code can admit or reject the
minimum source-independent canonical candidate, but no supported project
operation executes a producer yet.

### Increment 5.C — Selected producer execution and canonical handoff proof

**Implementation status:** complete on 2026-09-17; formal Stage 5 acceptance
and reconciliation subsequently completed successfully.

**Objective:** execute exactly the selected project producer through the closed
request/result contract, admit its successful candidate, and prove hospital-
specific source logic stops at that boundary.

**Why here:** orchestration can be added only after both project declaration
and pure admission behavior have independent evidence.

**Implementation scope:** implement exported
`rrp_execute_producer(software_catalog, project_root, as_of_time)` and its exact
request/result validators, controlled library/working-directory behavior,
producer-condition containment, canonical admission delegation, common-result
translation, manual, package-native tests, and full installed independent-
project proof. Update package README, current ownership, repository inventory,
validator expectations, and public capability wording only for realized Stage
5 behavior.

**Public/internal interfaces changed:** `rrpplatform` gains exactly one export
and operation ID `rrp.execute-producer`; `rrpruntime` retains its one admission
export. No provider interface changes.

**Historical reuse:** adapt the `v0.1.0` declaration → trusted callable → exact
selection → execution → admission sequence, short-circuit behavior, fixed safe
failure results, and the materially different adopter-producer proof. Replace
installed producer composition with the already selected project producer;
replace producer-supplied arbitrary configuration with a closed RRP request;
and reject operation events, platform-instance files, synthetic default
selection, source-specific command flags, downstream runtime/history/product
execution, and Phase suites.

**Evidence:** installed packages/resources in temporary roots; unrelated
non-Git working directory; one project producer reading only project-owned
fictional source through its captured root; a second materially different
temporary source layout/field vocabulary admitted by the unchanged generic
operation; exact single invocation; correct request shape; result and candidate
identity agreement; copied-project execution resolving the copied root; safe
expected failure, malformed result, thrown-condition, and invalid-canonical
paths; library/global/working-directory restoration; zero provider calls; no
state/library creation or write; no source field names/rows/configuration in
generic package code, results, diagnostics, or installed resources; and no
persistent generated output. Retain all repository, resource, project,
package-native, build/install/load/check, and adversarial evidence.

**Explicit exclusions:** no fictional shipped producer, source connector,
provider execution, target eligibility/request, risk estimate, retries,
scheduling, run/history identity, persistence, state initialization, products,
app, CLI, distribution, deployment, or release behavior.

**Completion statement:** installed RRP can execute the exact selected
hospital-owned producer and return either an admitted canonical bundle or a
bounded structured failure, while the provider remains inert and nothing is
persisted.

### Validation and hosted evidence

No new maintainer command or workflow is planned. The human operations remain:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
```

Repository validation grows only for realized resources, package files,
manuals, tests, exports, links, ownership, and hygiene. Package validation
grows incrementally across 5.A–5.C for exact resource projection, project
contract evolution, runtime admission, installed producer execution, two
independent temporary producer compositions, copied-project behavior, privacy-
safe failures, package topology, source builds, dependency-order isolated
installation/loading, package-native tests, and exact package checks.

The existing read-only Ubuntu/R 4.4 `package-foundation` workflow already calls
both commands on push and pull request. It requires no behavioral change unless
implementation evidence demonstrates one. Final Stage 5 acceptance requires a
successful hosted run for the committed complete Stage 5 tree and records the
run/job/SHA/ref/event. Hosted success remains package/project/canonical-boundary
evidence, not clinical, production, distribution, deployment, release, or
general operating-system support.

### Human-readable Stage 5 acceptance scenario

The final proof makes the boundary tangible in temporary space:

```text
build and isolate-install rrpruntime then rrpplatform
        ↓
project an explicit installed software-resource root
        ↓
initialize an independent project outside repository/Git context
        ↓
replace only hospital-owned trusted registration/source implementation
        ↓
load and structurally validate the project
        ↓
execute its exact selected producer once with profile + as-of request
        ↓
map fictional local source fields inside project code
        ↓
return one closed candidate bundle
        ↓
admit episode + terminal-event information through rrpruntime
        ↓
inspect one common structured success result
        ↓
copy project and repeat from the copied root
        ↓
exercise a second differently shaped source producer and failure cases
        ↓
STOP

No provider execution
No risk request or estimate
No state initialization or persistence
```

The source fixtures are temporary, deterministic, visibly fictional, and have
different local names/layouts. Generic package code and installed contracts
contain neither source vocabulary. Both producers traverse the same request,
result, and admission path without a producer-ID branch.

### Stage 5 acceptance

Stage 5 is complete only when:

1. all Stage 5 semantic authorities are versioned, cataloged, closed,
   parseable DCF resources and executable code proves exact agreement;
2. the project manifest, API, and registration contracts advance coherently to
   `0.2.0`, and unsupported structural `0.1.0` projects fail explicitly rather
   than being guessed, mutated, or silently migrated;
3. initialization still creates exactly the two justified project files and a
   structurally/semantically declared unavailable producer plus inert provider;
4. project loading validates exact canonical profile and producer declaration
   agreement before invoking any selected callable;
5. provider records and behavior remain unchanged and no provider callable is
   invoked by initialization, loading, doctor, producer execution, or admission;
6. RRP constructs one closed producer request from explicit software/project
   context and strict caller-supplied as-of time;
7. the request contains no source payload, arbitrary configuration, secret,
   connection, project path, provider, state, or unrestricted option surface;
8. the selected producer is invoked exactly once under controlled library
   ordering with no fallback, discovery, retry, working-directory mutation, or
   identity-specific branch;
9. hospital code can obtain source information through its captured project
   context or approved external environment without generic RRP knowing source
   names, fields, tables, connections, or mapping rules;
10. successful producer results agree exactly with trusted declaration,
    request, project, profile, capability, mapping, implementation, and as-of
    identities and contain exactly one candidate;
11. failed producer results contain no candidate and only a controlled failure
    code; malformed results and thrown conditions become fixed bounded failures
    without echoing source or exception content;
12. the minimum profile contains only discharge episodes and dual-time first
    readmission/death evidence with exact closed fields and required available
    capabilities;
13. canonical admission validates shapes, types, identifiers, keys,
    relationships, capabilities, exact versions, and detached value semantics;
14. admission enforces admission/discharge order, exact 30-elapsed-day coverage,
    episode-relative terminal windows, occurrence/availability order, the as-of
    cutoff, terminal uniqueness, and death/readmission consistency;
15. an admitted result is an in-memory detached typed bundle and cannot be
    changed by later mutation of the producer candidate;
16. `rrpruntime` remains dependency-free and independent upward while gaining
    exactly one canonical-admission export; `rrpplatform` remains the only
    project/operation owner and gains exactly one producer-execution export;
17. two materially different temporary hospital-specific source realizations
    pass the same generic producer/admission operation without generic source-
    or producer-identity conditionals;
18. copied-project execution resolves the copy's project-owned source paths and
    retains no original-root or repository/Git dependence;
19. success/failure evidence and diagnostics do not expose patient/episode
    identifiers, source rows, field values, paths, SQL, configuration,
    credentials, connections, arbitrary exceptions, or raw payloads;
20. producer execution and admission create/write no state, history, cache,
    audit, product, application, extension library, or other persistent output;
21. repository validation, expanded package validation, DCF/R/Rd parsing,
    package-native tests, builds, isolated install/load, strict package checks,
    hygiene, and committed read-only hosted evidence all pass without retained
    generated output; and
22. no target eligibility/request, provider semantics/execution, risk
    calculation, run/history persistence, supplied fictional implementation,
    product, application, CLI, distribution, deployment, or release behavior
    enters.

After implementation and committed hosted evidence pass, reconcile the
realized boundary with True North and Platform Architecture and record any
deviation. Stage acceptance is a lifecycle action, not Increment 5.D.

**Acceptance result:** accepted and complete on 2026-09-17 at committed
revision `01b0d564ecbe55830542c10cfcb77d4d72366d7b`. Read-only hosted push run
`35288890797`, job `105427207401`, completed successfully for that exact
revision. Formal reconciliation found all 22 criteria satisfied and no
deviation from Platform True North or Platform Architecture. Stage 6 remains
unimplemented and must be separately detailed and accepted before source work.

### Plain-language exit state

> A project-selected producer can submit source-independent discharge episodes
> and dual-time readmission/death evidence that RRP validates and admits through
> a versioned canonical boundary. RRP still does not construct a risk request,
> invoke a provider, calculate risk, or retain operational state.

### Historical reuse disposition

| Classification | Historical finding and disposition |
|---|---|
| Reuse directly | Exact producer ID/version selection already recovered in Stage 4; closed trusted callable validation; primary/foreign-key, field closure, bounded timestamp, and deterministic issue-test mechanics where their code remains independently suitable. |
| Adapt concept/mechanic | `v0.1.0` specification envelope, producer declaration → callable → execution → admission sequence, producer/result identity agreement, capability versus row-cardinality distinction, bundle/profile/domain separation, implementation/mapping identity, dual occurrence/availability time, candidate non-coercion, short-circuit failure, and independent-adopter substitution proof. |
| Replace for 1.0 | YAML specifications and repository parsers become DCF installed resources plus package-owned validation; root terminal timestamps become a dual-time terminal-event domain; variable/shortened follow-up becomes exact fixed day-30 coverage; installed producer composition becomes project registration; broad conformance results become bounded common operation diagnostics. |
| Reject for Stage 5 | Baseline-risk and broad episode-event domains/vocabularies, generic dependency graph/expression machinery, source configuration payloads, platform-instance selection, source-specific CLI flags, synthetic installed default, repository-root sourcing, temporary runtime installation, Phase validation, operation-event/logging system, daily-hazard/estimand logic, downstream runtime/provider/history/product/app behavior, and generated Hospital delivery. |

Reconnaissance inspected immutable `v0.1.0`, especially
`docs/architecture/specification-foundation.md`,
`canonical-bundle-foundation.md`, `canonical-clinical-profile.md`, and
`canonical-producer-foundation.md`; `contracts/canonical/`; producer, bundle,
and clinical validators under `operations/lib/`; installed producer
composition; the synthetic producer adapter; Phase 2/10 tests; and the
independent adopter-producer fixture. It also revisited the pre-reset
`readmission-risk-target-assessment.md` at revision `1e7b95c`, whose fixed
elapsed day-30 coverage and unresolved terminal-availability finding directly
inform this Stage 5 profile.

The old code is not restored wholesale. Reuse is limited to invariant-level
logic and test ideas that fit the current installed-resource, package,
independent-project, singular-target, and privacy boundaries.

### Major deferrals and deliberately open decisions

Stage 6 owns the singular target contract, eligibility, immutable as-of state,
standard request, provider declaration/conformance/invocation, model semantics,
accepted estimate, and any transparent fictional provider. Same-time terminal
precedence becomes analytical behavior there; Stage 5 only preserves the facts.

Stage 7 owns operation/analytical run and execution-attempt identity, durable
state/history, canonical-input attribution, adapters, atomic append/retry,
locking, invalidation/restatement, backup/recovery, and migration. Stage 8 owns
the maintained fictional source generator/mapping/producer and normal complete
reference path. Products, app, CLI, distribution, deployment, and release stay
with later stages.

Stage 5 does not settle project dependency restoration/closure, secrets
providers, remote/non-R producer transports, production source connection
interfaces, additional profiles/domains/capabilities, performance/streaming,
large-bundle storage, approved record-level debugging, migration from the
development `0.1.0` project contract, or the future CLI's normalization of
home-relative paths. Those decisions require later concrete evidence and must
preserve this boundary.

## Stage 6 — Singular target, runtime, and provider execution

**Status:** accepted and complete on 2026-09-19 at committed implementation
baseline `c9a8f539d07611d29ec86d4fd1ee5a308413938c`. Increments 6.A–6.C and
formal Stage 6 acceptance and reconciliation are complete.

### Objective and responsibilities

Implement the one nonselectable remaining cumulative day-30 readmission-risk
target; eligibility; immutable as-of episode state; standard request;
controlled provider registration, compatibility, and invocation; accepted
estimate semantics; and structured failures. Include a transparent nonclinical
provider as maintained example code without privileging its identity in generic
runtime.

The exact target is:

> Remaining actual-world cumulative probability of first canonical
> readmission in `(t, W30]`, conditional on the patient being alive and
> readmission-free through `t`, using only admitted information available
> through `t`, where `W30` is exactly 30 elapsed days after discharge. Death
> before readmission competes; readmission takes precedence when readmission
> and death occur at the same instant.

Stage 6 makes that one quantity executable. It does not retain an estimate or
create an analytical run, execution attempt, history record, or state store.

### Why here and dependencies

Runtime state can use only admitted canonical information and must resolve the
provider selected by an already validated project. This is the first stage
that can make an analytical claim, isolated from persistence and application
concerns.

### Stage 5 reconciliation and inherited constraints

Stages 1–5 are accepted and complete at committed baseline
`8717c2f06b23a282e14ab8d3bdced1f882d044cc`. No corrective implementation
change is required before Stage 6. The realized tree establishes these
constraints:

- Stage 6 receives only an `rrp_admitted_canonical_bundle`; it does not inspect
  hospital source data, mapping code, producer configuration, or source schema;
- an admitted bundle already carries exact project, producer, implementation,
  mapping, profile, capability, bundle-instance, and authoritative as-of facts;
- the admitted profile contains only `discharge_episode` and dual-time
  `terminal_event` domains, and exact admission has already proved
  `followup_window_end == discharge_time + 30 * 86,400` elapsed seconds;
- project loading is the sole authority for exact provider selection,
  installed/project origin, extension-library ordering, and trusted callable
  resolution;
- the selected provider is currently only structural and cannot be invoked
  until its semantic declaration is versioned and validated;
- `rrpruntime` is dependency-free and owns canonical admission; `rrpplatform`
  owns installed resources, project loading, orchestration, operation results,
  diagnostics, and controlled project execution;
- the common operation result is intentionally small and contains no run,
  attempt, persistence, logging, or audit identity; and
- current validators and the read-only hosted workflow remain the evidence
  path. Stage 6 does not introduce another validator command or framework.

The manual clean-room Stage 5 exercise confirmed that this boundary is usable
but low-level. Stage 6 therefore makes RRP construct target, state, request, and
accepted-estimate envelopes. A provider implements only the selected analytical
calculation and the small provider result. Provider-authoring helpers and a
thinner adopter UX remain later evidence-led work.

### Scope test and settled Stage 6 decisions

Every responsibility is tested against one question: is it required to turn
one admitted episode at its authoritative as-of instant into one accepted
estimate or bounded failure from exactly the selected provider?

| Responsibility | Accepted Stage 6 boundary |
|---|---|
| Target | One installed, versioned target authority; no target registry, selector, route, project field, or request-builder extension. |
| Analytical as-of | Stage 6 requires requested `t` to be the same instant as the admitted bundle's authoritative as-of. A later bundle cannot be used to reconstruct an earlier request. |
| Eligibility | An episode is eligible exactly when `D <= t < W30` and no readmission or death known through `t` has occurred at or before `t`. Equal known readmission/death occurrence uses readmission precedence. |
| Episode state | `rrpruntime` constructs one detached, immutable, source-independent state for one eligible episode. It is not a patient record, feature store, or persistent snapshot. |
| Request | RRP constructs one exact provider-neutral request for `(t, W30]`. Providers do not construct or select target semantics. |
| Provider declaration | The exact project-selected provider declares only the identities needed to prove target/state/request/estimate compatibility and provider/model provenance. |
| Provider input | The callable receives one detached standard request only. It receives no bundle, project context/root, source data, connection, credential, persistence handle, arbitrary configuration, or callback. |
| Invocation | Exactly the selected callable is invoked once for one request under the existing controlled project-library ordering. There is no discovery, fallback, alternative, retry, or provider-identity branch. |
| Provider output | The provider returns one small closed result referring to the request. RRP constructs the accepted estimate envelope and owns all other standard attribution. |
| Accepted estimate | One detached finite base-R double in `[0,1]` plus exact target/request/state/project/software/provider/implementation/model/as-of attribution. This is software conformance, not clinical validity. |
| Transparent provider | One protected installed provider is maintained as deterministic nonclinical example code. A project must select it explicitly; it is never an implicit default or fallback. |
| State/history | Everything remains in memory. Stage 6 creates no state directory, run ledger, history adapter, retry record, cache, product, or other persistent output. |

### Target and runtime contract authority

Stage 6 adds five closed DCF resources under
`resources/contracts/runtime/`. All use specification format `1.0.0`, semantic
version `0.1.0`, exact equality, and `rrpruntime` as semantic owner:

| Source resource | Catalog logical ID | Semantic identity |
|---|---|---|
| `readmission-risk-target.dcf` | `rrp.target.readmission-risk` | `rrp.risk-target.readmission-remaining-30-day@0.1.0` |
| `episode-state.dcf` | `rrp.contract.episode-state` | `rrp.episode-state@0.1.0` |
| `risk-request.dcf` | `rrp.contract.risk-request` | `rrp.risk-request@0.1.0` |
| `risk-provider.dcf` | `rrp.contract.risk-provider` | `rrp.provider-api@0.1.0` |
| `risk-estimate.dcf` | `rrp.contract.risk-estimate` | `rrp.risk-estimate@0.1.0` |

The closed source-resource count therefore advances from 13 to exactly 18 only
after all five resources exist. `rrpplatform` loads and cross-validates them
through the existing explicit software catalog and assembles exact plain
runtime contexts. `rrpruntime` never discovers or parses a filesystem resource.
Executable code and package tests must prove exact agreement with every field.

The target authority fixes:

- base population: every episode admitted under
  `rrp.canonical-profile.readmission@0.1.0`;
- event: first canonical readmission, without a planned/unplanned claim;
- origin: exact discharge instant `D`;
- endpoint: `W30 = D + 2,592,000` elapsed seconds, endpoint included;
- eligible prediction time: `D <= t < W30`;
- interval: `(t, W30]`;
- conditioning: alive and without canonical readmission through `t`;
- information rule: only facts with occurrence/effective time and availability
  time no later than `t` may affect the state;
- competing event: death before readmission prevents readmission;
- equal-time precedence: readmission wins;
- output: exactly one finite probability in `[0,1]`; and
- selection: prohibited. This identity is provenance, never configuration.

The resources are authorities, not a target catalog or generalized schema
engine. They contain no provider implementation, hospital configuration,
clinical threshold, decision policy, persistence rule, or executable code.

### Analytical as-of and eligibility semantics

The first Stage 6 line deliberately supports only current execution:

```text
producer requested at t
        ↓
admitted bundle authoritative at the same instant t
        ↓ exact instant equality
eligibility + immutable state + request at t
```

An explicit-offset requested `as_of_time` must parse and normalize to the same
instant as `admitted_bundle$as_of_time`. Lexically different offsets denoting
the same instant agree. An earlier or later instant fails before provider code.
This prevents future knowledge in a later admitted bundle from affecting an
earlier request without inventing retrospective reconstruction. Stage 7 may
retain successive prospective runs; retrospective reconstruction remains
deferred.

For each selected episode, eligibility is exact:

| Condition at `t` | Result |
|---|---|
| `t < D` | Ineligible: before discharge. A normally admitted bundle at the same `t` cannot contain this state, but runtime still fails closed. |
| `t == D` | Eligible when no known terminal event exists. |
| `D < t < W30` | Eligible when no known terminal event exists. |
| `t == W30` or `t > W30` | Ineligible: target horizon exhausted; no zero estimate is manufactured. |
| Readmission occurred and was available by `t` | Ineligible: already readmitted, including occurrence exactly at `t`. |
| Death occurred and was available by `t` | Ineligible: already dead, including occurrence exactly at `t`. |
| Readmission and death share an occurrence instant and both are known | Ineligible as already readmitted; target precedence is readmission. |
| Terminal event occurred but was not available by `t` | It is absent from the bundle admitted at `t` and cannot affect that execution. It affects the first later execution whose admitted bundle may legitimately contain it. |

All admitted terminal rows already satisfy `occurred_at <= available_at <= t`.
Stage 6 does not reinterpret future rows, query a source, or remove information
from a later bundle to simulate an earlier cutoff.

Expected target failures use stable bounded codes, including
`invalid_analytical_as_of`, `analytical_as_of_mismatch`, `unknown_episode`,
`episode_before_discharge`, `target_horizon_exhausted`,
`episode_already_readmitted`, and `episode_already_dead`. The last four are
specific episode-ineligibility outcomes. None includes the episode identifier
or a canonical value in its message.

### Immutable episode state

`rrpruntime` owns separate pure eligibility evaluation and state construction.
Only an eligible episode receives a state. The exact first state contains:

- state contract ID/version and a deterministic in-memory state identity;
- target ID/version;
- canonical bundle contract ID/version and bundle instance ID;
- project ID/version and canonical profile ID/version;
- episode ID;
- canonical UTC representations of `as_of_time`, `discharge_time`, and `W30`;
- elapsed seconds since discharge and remaining seconds through `W30`; and
- terminal status exactly `none_available_through_as_of`.

The state omits patient ID, encounter ID, source/mapping fields, terminal-event
rows, provider identity, arbitrary canonical domains, features, diagnoses,
medications, demographics, configuration, and persistence references. Its
identity is deterministic from the exact bundle/episode/as-of/target/state
facts and is not an analytical-run or durable history identity.

All input is revalidated at the runtime boundary and copied into a closed plain
value before the exact state class is applied. Mutation of the admitted bundle
after construction cannot change the state. Eligibility remains a distinct
internal decision; state construction does not silently encode an ineligible
episode.

Increment 6.A introduces the second `rrpruntime` export:

```r
rrp_prepare_episode_state(
  admitted_bundle,
  episode_id,
  as_of_time,
  expected_context
)
```

`expected_context` is the closed target/state/software context assembled by
`rrpplatform` from installed authorities. The export is a technical
cross-package interface, not a hospital-facing API.

### Standard risk request

For one eligible state, `rrpruntime` constructs one exact detached request. The
provider receives only this request, containing:

- request contract ID/version and deterministic request ID;
- target ID/version;
- state contract ID/version and state ID;
- bundle instance ID;
- project ID/version and episode ID;
- canonical UTC as-of and discharge instants;
- target interval start equal to `t`;
- target interval end equal to `W30`;
- interval boundary exactly `(start,end]`; and
- elapsed and remaining seconds copied from the validated state.

The request is provider-neutral and contains no provider identity, target
selector, patient ID, encounter ID, complete canonical bundle, terminal-event
payload, source/mapping identity, root/path, connection, credential, arbitrary
options, feature-engineering surface, state handle, or persistence callback.
Future providers may differ radically internally but must answer this same
quantity from this same governed input. A later canonical-profile revision may
add a provider-usable field only through its own demonstrated contract change;
Stage 6 does not invent a feature system.

### Provider semantic declaration and project-contract evolution

Stage 6 advances the unreleased development project contract, project API, and
registration contract together from `0.2.0` to `0.3.0`. Manifest fields remain
closed and unchanged except for their required contract/API version values;
the project already selects one exact provider. The registration provider
record advances from structural ID/version/callable to exactly:

```text
component_id
component_version
provider_api_id
provider_api_version
target_id
target_version
state_contract_id
state_contract_version
request_contract_id
request_contract_version
estimate_contract_id
estimate_contract_version
implementation_id
implementation_version
model_id
model_version
callable
```

Provider API, target, state, request, and estimate identities must equal the
installed Stage 6 authorities. `implementation_id` and version are required
and independent from provider identity. `model_id` and `model_version` are both
`NULL` when no separate fitted model exists or both bounded identities when one
does. Model path, digest, acquisition, dependency closure, clinical approval,
and loading are not implied and remain later contract work.

The producer record and canonical profile selection remain unchanged. The
initializer still creates exactly two files and selects its project-derived
provider, but that provider now declares exact Stage 6 semantics and returns a
controlled `provider_unavailable` result if invoked. It is not replaced by the
transparent provider. Structural `0.2.0` projects fail explicitly; there is no
compatibility bridge, range negotiation, silent mutation, or migration tool
for an unreleased development contract.

The loader validates provider semantics and manifest selection before any
provider invocation. Project loading, doctor, initialization, and producer
execution continue to invoke no provider callable.

### Provider invocation and provider result

`rrpruntime` introduces one additional technical export in Increment 6.B:

```r
rrp_execute_risk_provider(
  episode_state,
  provider,
  expected_context
)
```

The closed `provider` value is assembled from the selected semantic
declaration and trusted callable; it contains no project context or root.
`expected_context` contains exact software, target, request, provider, and
estimate authorities. Runtime revalidates state and provider compatibility,
constructs the request, supplies the callable a detached copy, invokes it once,
and validates its result. `rrpplatform` surrounds the call with the already
accepted RRP-first/project-extension/base library ordering and restores process
state.

The callable receives exactly one argument, `request`, and returns exactly:

```text
request_id
status                 success | failure
estimate_value         one plain base-R double on success; NULL on failure
failure_code           NULL on success; one controlled provider code on failure
```

Controlled provider-declared failure codes are
`provider_unavailable`, `provider_input_unavailable`, and
`provider_calculation_failed`. RRP-detected failures include
`provider_incompatible`, `provider_execution_failed`,
`invalid_provider_result`, `provider_result_identity_mismatch`, and
`invalid_estimate`. Provider-thrown conditions become the fixed execution code
without their text. A malformed, unsafe, classed, attributed, executable, or
reference-bearing result fails closed. The provider cannot return an accepted
estimate object, alter target fields, or supply provenance beyond the small
result; RRP constructs the accepted envelope.

There is no registry environment inside `rrpruntime`: exact provider selection
has already occurred through the project loader. There is also no retry,
attempt number, fallback, alternate provider, timeout policy, parallel
execution, remote transport, provider source lookup, or history write.
Project registration and the provider callable remain trusted local R code,
not a security sandbox. The closed input contract prevents generic RRP from
supplying source context; provider conformance and adopter review enforce the
prohibition on hidden source/product lookups or side effects.

### Accepted estimate semantics

Successful validation produces one detached typed estimate with exact fields:

- estimate contract ID/version;
- request contract ID/version and request ID;
- state contract ID/version and state ID;
- target ID/version;
- software product ID/development version;
- bundle instance ID;
- project ID/version and episode ID;
- as-of time, target interval start/end, and `(start,end]` boundary;
- provider ID/version and implementation ID/version;
- explicit nullable model ID/version pair;
- output type exactly `probability`; and
- one unclassed base-R double `estimate_value`, finite and within `[0,1]`.

The estimate has exact closed field order and only its owned estimate class.
Integer, logical, character, `NA`, `NaN`, infinite, length-not-one, attributed,
classed, executable, environment, connection, external-pointer, or other
reference-bearing values are rejected rather than coerced. Request ID must
agree with the constructed request; every other identity is stamped from
validated RRP/project/provider context rather than trusted from provider
output. The accepted value contains no recommendation, priority, threshold,
uncertainty, interval, explanation, feature attribution, calibration,
performance, clinical-validity, production-approval, persistence, or decision
claim.

Stage 7 may wrap this exact successful result with operation-run, analytical-
run, provider-execution, retry/attempt, and durable estimate-record identities.
Stage 6 does not predeclare those persistence identities.

### Transparent maintained provider

Increment 6.C adds one installed protected provider:

```text
provider ID              rrp.provider.transparent
provider version         0.1.0
implementation ID        rrp.provider-implementation.transparent
implementation version   0.1.0
model ID/version          NULL / NULL
```

It is package-owned maintained code, explicitly labeled deterministic,
fictional, and nonclinical. Its inspectable calculation is
`0.20 * remaining_to_target_seconds / 2,592,000`, producing a finite value in
`[0, 0.20]` for every eligible request. The formula is only a conformance
demonstration and claims no calibration, discrimination, transportability,
fairness, effectiveness, clinical validity, or decision utility.

The installed-component composition exposes this record under the protected
`rrp.` namespace. A temporary test project selects it explicitly in its
manifest. Before composition, the installed record passes the same semantic
provider-declaration validator used for project-owned providers; only its
installed origin and protected namespace differ. The same generic selection/
execution path also accepts a conforming project-owned provider with a
different identity and method. Generic runtime contains no transparent-
provider conditional, and the installed provider is not copied into initialized
projects, auto-selected, used as fallback, or treated as clinically preferred.

### Component ownership

| Owner | Stage 6 responsibility |
|---|---|
| Installed resources | Own the exact target, state, request, provider, and estimate semantic authorities; contain no hospital instance, model artifact, source configuration, or executable provider. |
| `rrpruntime` | Owns pure eligibility, temporal state, request construction, provider compatibility/invocation, provider-result validation, accepted-estimate construction, typed bounded runtime failures, and two new exports. It remains independent of projects, resource paths, hospital schemas, operation results, and persistence. |
| `rrpplatform` | Owns resource loading/agreement, 0.3.0 project-contract evolution, semantic provider declaration, installed provider composition, exact project selection, controlled libraries/process restoration, common-result translation, and the one risk-execution operation. |
| Hospital project | Owns its selected provider implementation, optional model identity and future artifacts, extension dependencies, method, limitations, and clinical/model governance. It cannot redefine target, eligibility, request, or estimate semantics. |
| Maintainer tooling | Extends current package/resource/project proof for exact authorities, temporal edges, provider substitution, safe failures, builds/checks, and absence of persistent output. |
| Stage 7 | Will own run/attempt/history identities, atomic append, state adapter, retry, invalidation/restatement, and reopening. None enters Stage 6. |

### Package APIs and stable operation

At Stage 6 completion the exact technical namespace posture is planned as:

```text
rrpruntime (dependency-free)
    rrp_admit_canonical_bundle()
    rrp_prepare_episode_state()
    rrp_execute_risk_provider()

rrpplatform (Imports: rrpruntime only)
    existing eight exports
    rrp_execute_risk()
```

`rrpplatform` adds:

```r
rrp_execute_risk(
  software_catalog,
  project_root,
  admitted_bundle,
  episode_id,
  as_of_time
)
```

with operation ID `rrp.execute-risk`. It validates scalar analytical inputs
before trusted project code, loads the explicit project through
`rrp_load_project()`, loads exact runtime authorities, verifies bundle/project/
profile/as-of agreement, prepares one episode state, and executes exactly the
selected provider under controlled libraries. Expected project, target,
provider, and estimate failures become one existing common failure result with
`NULL` value and a fixed bounded diagnostic. Resource failures retain resource
ownership and unexpected generic RRP defects propagate. Success value is the
accepted in-memory estimate and must be treated as sensitive analytical data,
not diagnostic or logging content.

The operation begins from an already admitted bundle and does not call a
producer. The full Stage 6 proof first calls the existing
`rrp_execute_producer()` at `t`, then passes its admitted success value to
`rrp_execute_risk()` at the same `t`. Stage 7 may later orchestrate these
boundaries into one attributable atomic run; Stage 6 does not duplicate that
future owner.

### Implementation sequence

```text
6.A — singular target authority, eligibility, and immutable episode state
        ↓
6.B — semantic provider contract and standard request/estimate boundary
        ↓
6.C — selected provider execution and transparent end-to-end proof
        ↓
Stage 6 acceptance and reconciliation
```

Three increments are the smallest coherent sequence. Target/state semantics
must be independently proven before provider compatibility and output exist;
provider-neutral request/estimate behavior must be proven before trusted
project invocation; and installed/project provider substitution belongs with
the final orchestration proof.

### Increment 6.A — Singular target authority, eligibility, and immutable episode state

**Implementation status:** complete on 2026-09-18 and included in the accepted
Stage 6 baseline.

**Objective:** make the one RRP risk target and its eligibility/state semantics
versioned software authority, then construct one detached state from admitted
Stage 5 input without any provider behavior.

**Implementation scope:** add and catalog `readmission-risk-target.dcf` and
`episode-state.dcf`; implement exact installed loading/cross-validation in
`rrpplatform`; implement pure target/as-of/episode validation, eligibility,
state identity/construction, and bounded `rrp_runtime_error` conditions in
`rrpruntime`; export only `rrp_prepare_episode_state()`; add focused manuals,
package-native tests, ownership/inventory updates, and exact validator
expectations. The source-resource count becomes 15 in this increment.

**Historical reuse:** directly reuse current Stage 5 timestamp normalization,
plain-value, detachment, and safe-condition mechanics where they fit. Adapt the
`v0.1.0` eligibility boundary, fixed runtime/bundle cutoff, state/request
separation, deterministic identity idea, and temporal fixtures. Reject
shortened follow-up, root terminal timestamps, baseline/event feature state,
daily hazard, run identity, YAML loading, and repository orchestration.

**Evidence:** exact DCF fields/identity/reference agreement; valid state at
discharge and just before W30; rejection at/after W30; prior readmission/death
and equal-time precedence; terminal availability behavior across separately
admitted bundles; offset-equivalent exact as-of and mismatch rejection;
multi-episode selection; unknown episode; exact state shape/type/identity;
input nonmutation and post-construction detachment; no patient/encounter or
extra canonical fields; bounded safe failures; dependency/API posture; and all
inherited repository/package evidence.

**Explicit exclusions:** no provider declaration, request, estimate, project-
contract bump, provider callable, transparent provider, platform risk
operation, run identity, state write, or persistence.

**Completion statement:** dependency-light runtime can decide eligibility and
construct the exact immutable state for one admitted episode at the bundle's
authoritative as-of instant, but no provider can yet receive a request.

### Increment 6.B — Semantic provider contract and standard request/estimate boundary

**Implementation status:** complete on 2026-09-18 and included in the accepted
Stage 6 baseline.

**Objective:** define and prove the complete provider-neutral request,
compatible provider declaration, minimal provider result, and RRP-owned
accepted estimate without project-selected execution.

**Implementation scope:** add and catalog `risk-request.dcf`,
`risk-provider.dcf`, and `risk-estimate.dcf`; advance project manifest/API/
registration and templates atomically to `0.3.0`; validate exact semantic
provider declarations and nullable model identity; preserve producer semantics;
update initializer/loader/doctor for the evolved boundary without invoking a
provider; implement request construction, compatibility, one-call execution,
result validation, estimate construction, and exported
`rrp_execute_risk_provider()` in `rrpruntime`; add focused manuals/tests and
validator/ownership/inventory updates. The closed resource count becomes 18.

Direct runtime tests use temporary semantic provider values and functions,
not a project. They prove target/request/provider/result/estimate behavior
before controlled project orchestration depends on it.

**Historical reuse:** adapt exact trusted-callable checks, compatibility-before-
invocation, detached input, one-call proof, request/result identity agreement,
probability cardinality/bounds, non-estimate failures, provider substitution,
and output-adversarial tests. Reject the runtime registry environment,
supported-estimand collections/ranges, arbitrary state-field requirements,
baseline/event feature inputs, retries/attempts, raw exception issues, old
estimate/run identities, YAML, and daily-hazard contracts/formula.

**Evidence:** exact five-resource family agreement; coherent `0.3.0` project/
API/registration line; explicit `0.2.0` rejection; initialized two-file project
with semantic unavailable provider; no provider invocation during init/load/
doctor/producer execution; exact request and accepted-estimate shapes; fixed
`(t,W30]`; target/state/request/estimate compatibility; model pair rules;
plain double and `[0,1]` enforcement; success/failure conditional fields;
request mismatch, malformed/unsafe output, thrown-condition containment,
input detachment, exact one-call proof, and privacy-safe typed failures. Retain
all Stage 1–6.A evidence.

**Explicit exclusions:** no installed transparent provider, selected project
provider invocation, platform risk operation, fallback/retry, provider
dependency restoration/model loading, history, persistence, or new workflow.

**Completion statement:** runtime can construct the one standard request,
execute one explicitly supplied compatible provider, and accept or reject one
estimate, but installed RRP does not yet execute the provider selected by a
project.

### Increment 6.C — Selected provider execution and transparent end-to-end proof

**Implementation status:** complete on 2026-09-19 and included in the accepted
Stage 6 baseline.

**Objective:** invoke exactly the provider already selected by a validated
project and prove the complete admitted-bundle-to-estimate boundary with both
installed and project-owned provider implementations.

**Implementation scope:** add the protected installed transparent provider and
its installed-component registration; add exported `rrp_execute_risk()` with
operation ID `rrp.execute-risk`; reuse project loading and library control;
translate expected failures to the common result; add focused manual/package-
native tests and the full installed temporary-project proof; update package
orientation, ownership, inventory, exact namespaces, and validator assertions
only for realized behavior.

**Historical reuse:** adapt exact selection, controlled invocation,
compatibility-before-call, state/request copying, process restoration,
structured non-estimate outcomes, second-provider substitution, deterministic
example-provider proof, and probability adversarial cases. Replace the
historical transparent hazard formula with the fixed-endpoint conformance
formula above. Reject repository contract loading, installed registry
selection independent of the project, raw condition text, retry identities,
operation events, history append, Phase suites, and reference-provider special
branches.

**Evidence:** installed packages/resources in temporary roots; unrelated
non-Git working directory; existing producer operation followed by risk
execution at exact matching `t`; exact project-selected provider; one provider
call per eligible request; no provider call for invalid as-of, mismatch,
ineligible episode, incompatible declaration, or invalid state; explicit
selection of the installed transparent provider; substitution with a
materially different project-owned provider through unchanged generic code;
copied-project execution; provider-declared and RRP-detected failures; library/
working-directory/global restoration; no source vocabulary or provider-ID
branch in generic runtime; accepted estimate detachment; zero persistent
output; and all inherited builds, isolated install/load, native tests, strict
checks, repository hygiene, and hosted evidence after commit.

**Explicit exclusions:** no permanent fictional project or producer, implicit
provider default, provider dependency environment/model artifact, retries,
parallelism, remote transport, run/history identity, state initialization,
persistence, product, application, CLI, distribution, deployment, or release.

**Completion statement:** installed RRP can take an admitted episode, construct
the singular fixed-endpoint request, and return one accepted estimate or
bounded failure from exactly the selected compatible provider, while retaining
nothing operationally.

### Validation and hosted evidence

No new maintainer command or workflow is planned. The human operations remain:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
```

Repository validation grows only for concrete resource, package, manual, test,
ownership, and inventory paths. Package validation grows incrementally for the
exact target/runtime authorities, project-contract evolution, temporal edge
cases, runtime state/request/provider/estimate behavior, installed/project
provider substitution, complete producer-to-estimate proof, safe failures,
package topology, builds, isolated install/load, package-native tests, and
strict checks.

The existing read-only Ubuntu/R 4.4 `package-foundation` workflow already runs
both commands on push and pull request. It needs no behavior change unless
implementation evidence demonstrates one. Final Stage 6 acceptance requires a
successful hosted run for the committed complete Stage 6 tree and records the
run/job/SHA/ref/event. This remains software-conformance evidence, not clinical
validation, production approval, distribution support, or release evidence.

### Human-readable Stage 6 acceptance scenario

```text
build and isolate-install rrpruntime then rrpplatform
        ↓
project the exact installed software-resource root
        ↓
load an explicit temporary independent project
        ↓
execute its selected producer at t and obtain one admitted bundle
        ↓
select one episode and require analytical t == bundle authoritative as-of
        ↓
evaluate eligibility and construct detached immutable state
        ↓
construct the single RRP `(t,W30]` request
        ↓
invoke exactly the project-selected compatible provider once
        ↓
validate its minimal result and construct one accepted estimate
        ↓
repeat with explicitly selected installed transparent provider
        ↓
repeat with a different project-owned provider and copied project
        ↓
exercise temporal, compatibility, execution, output, and privacy failures
        ↓
STOP

No retry or fallback
No history or persistence
No product or decision policy
```

### Stage 6 acceptance

Stage 6 is complete only when:

1. the five Stage 6 semantic authorities are closed, versioned, cataloged DCF
   resources and code proves exact agreement, bringing the closed catalog to
   18 real resources;
2. the singular target is exactly
   `rrp.risk-target.readmission-remaining-30-day@0.1.0`, nonselectable, and
   nowhere represented as a project choice, registry entry, or route;
3. target population, event, elapsed fixed endpoint, `(t,W30]` interval,
   conditioning, information cutoff, competing death, equal-time precedence,
   and finite-probability output agree across authority and code;
4. requested analytical as-of must be the same instant as the admitted bundle
   cutoff, and later bundles cannot be used for earlier reconstruction;
5. eligibility includes exact discharge, excludes exact/after W30, excludes a
   known readmission/death at or before `t`, and applies readmission precedence
   to equal known terminal instants;
6. terminal evidence influences an execution only when admitted as available
   by that exact `t`; no future occurrence or later-available fact is used;
7. immutable state is constructed only for an eligible episode, has the exact
   minimal closed fields, is detached, and contains no patient/encounter,
   source, feature-store, provider, or persistence payload;
8. the request is RRP-constructed, provider-neutral, exact, detached, and
   unambiguously describes the fixed target without carrying a bundle, source,
   project root, secret, connection, arbitrary option, or callback;
9. project contract/API/registration advance coherently to `0.3.0`, structural
   `0.2.0` fails explicitly, and no compatibility bridge or migration enters;
10. provider declarations agree exactly with installed provider API, target,
    state, request, and estimate identities and retain separate implementation
    plus explicit nullable model identity;
11. initialization retains exactly two files and one semantically conforming
    unavailable project provider; init/load/doctor/producer operations invoke
    no provider;
12. project loading remains the sole exact provider-selection authority and
    no provider registry, discovery, latest/range choice, fallback, or
    identity-specific route appears in runtime;
13. one eligible request invokes exactly its selected provider once under
    controlled libraries with no retry, alternative, working-directory
    dependency, global dependency, or persistent side effect;
14. provider code receives only one detached standard request and cannot alter
    runtime-owned state/request values;
15. provider output is the exact four-field success/failure result; thrown,
    malformed, unsafe, mismatched, nonfinite, non-double, or out-of-range output
    yields no estimate;
16. an accepted estimate has the exact closed attribution and one finite base-R
    double in `[0,1]`, is detached, and means only a structurally conforming
    estimate of the installed RRP target;
17. failure codes/messages are bounded and diagnostics expose no episode/
    patient identifiers, canonical values, request payload, source rows,
    paths, configuration, credentials, connections, model content, or raw
    exception text;
18. the transparent provider is deterministic, inspectable, explicitly
    nonclinical, selected explicitly, and follows the same generic path as a
    materially different project provider without special-casing;
19. copied-project provider execution resolves only the copied project context
    and retains no original-root, repository, Git, or ambient-library
    dependence;
20. `rrpruntime` remains dependency-free, source/project/resource-path
    independent, and gains exactly its two planned exports; `rrpplatform`
    continues to import only `rrpruntime` and gains exactly one export;
21. producer execution plus risk execution can complete from arbitrary
    hospital-shaped source through admitted bundle to accepted estimate while
    preserving the Stage 5 source boundary;
22. no operation creates/writes project state, run history, retry ledger,
    cache, product, app, extension library, model artifact, or other persistent
    output;
23. repository/package validation, DCF/R/Rd parsing, package-native tests,
    builds, isolated install/load, strict checks, copied-project/substitution
    proof, hygiene, and committed hosted evidence all pass without retained
    generated output; and
24. no persistence, retrospective reconstruction, multiple target, remote/non-R
    provider, generalized model packaging, uncertainty, explanation, clinical
    validation, decision policy, scheduling, product, application, CLI,
    distribution, deployment, or release behavior enters.

After implementation and committed hosted evidence pass, reconcile the
realized target/runtime/provider boundary with Platform True North and Platform
Architecture and record any deviation. Stage acceptance is a lifecycle action,
not Increment 6.D.

**Acceptance result:** passed on 2026-09-19. The exact committed implementation
baseline `c9a8f539d07611d29ec86d4fd1ee5a308413938c` satisfied all criteria above.
Read-only GitHub Actions `package-foundation` push run `35444384900`, job
`105900696412`, completed successfully for that exact revision. Reconciliation
found no deviation from Platform True North or Platform Architecture. Stage 7
remains high-level and is the next stage to detail; it has not begun.

### Plain-language exit state

> RRP can decide which admitted episodes are eligible at an as-of time,
> construct the one standard remaining day-30 risk request, and return one
> validated provider estimate or a structured failure. It does not yet retain
> operational history.

### Historical reuse disposition

| Classification | Historical finding and disposition |
|---|---|
| Reuse directly | Exact ID/version project selection already recovered in Stage 4; trusted callable checks; explicit-offset parsing/instant comparison, plain-value/detached-copy mechanics, fixed bounded errors, and probability cardinality/bounds where current code remains independently suitable. |
| Adapt concept/mechanic | `v0.1.0` eligibility-before-state separation, exact bundle/runtime cutoff, immutable episode state, provider-neutral request, compatibility-before-invocation, one-call execution, request/result agreement, structured non-estimate failure, provider substitution, transparent-provider role, and temporal/output adversarial tests. |
| Conceptual evidence only | Deterministic state/request/estimate identity and provenance linkage, provider implementation/model distinction, execution outcome records, and run correlation inform future attribution but their historical record shapes are not copied into Stage 6. |
| Replace for 1.0 | YAML runtime/provider contracts become five installed DCF authorities; daily `(t,min(t+1 day,W)]` requests become fixed `(t,W30]`; root terminal fields become admitted dual-time terminal events; installed registry selection becomes exact project selection; broad provider specifications become the small closed declaration above. |
| Reject | Public daily hazard, shortened horizon, baseline-risk/generic-event state, provider-selected estimands, supported-estimand ranges, request-builder/route/registry machinery, retries/attempts/run IDs, history append, raw exception issues, historical estimate identities, reference formula, repository-root loading, Phase suites, and source assumptions. |

Reconnaissance inspected immutable `v0.1.0` `runtime/R/eligibility.R`,
`state.R`, `estimand-request.R`, `provider-specification.R`,
`provider-registry.R`, `provider-compatibility.R`, `provider-execution.R`,
`estimate.R`, `reference-provider.R`, their runtime/provider contracts,
`tests/phase4/test-runtime-foundation.R`,
`tests/phase4/test-provider-foundation.R`, and package-native runtime tests. It
also revisited the pre-reset fixed-target assessment at revision `1e7b95c`.
Historical code remains evidence and is not restored wholesale or used as a
runtime dependency.

### Major deferrals and deliberately open decisions

Stage 7 owns operation/analytical run and provider-execution-attempt identity,
durable state/history, atomic append, idempotency/conflict, retry, invalidation/
restatement, adapters, locking, backup/recovery, and migration. Stage 8 owns
the maintained fictional project/source/producer and normal complete reference
run. Products, app, CLI, distribution, deployment, and release remain later.

Stage 6 does not settle retrospective reconstruction, target catalogs or
selection, additional targets/profiles/domains/features, remote/non-R
providers, timeouts/parallelism, provider dependency restoration, model
artifact paths/digests/loading, uncertainty/explanation, calibration/model
evaluation, clinical validation, production authorization, decision policy,
scheduling, generalized debugging, or provider-authoring convenience helpers.
The detailed plan leaves no unresolved question that blocks Increment 6.A;
these are explicit later boundaries, not implementation-time ambiguity.

## Stage 7 — Project state and operational history

**Status:** accepted and complete on 2026-09-21, including the subsequently
accepted bundle-scoped operational decision. Increments 7.A–7.D, committed
hosted evidence, and formal architecture reconciliation are complete.
Storage-neutral logical history, explicit project-owned DuckDB state,
bundle-scoped durable execution/history interpretation, and bounded backup/
restore now exist. No Increment 7.E exists.

The non-authoritative reasoning record is retained at
`docs/assessments/stage-7-bundle-scope-assessment.md`; this reconciled section
is the authoritative build plan.

### Objective and responsibilities

Add durable, attributable operational truth around the accepted Stage 5/6
computation without redefining that computation. One successfully admitted
canonical bundle at authoritative analytical time `t` is the operational
scope; one discharge episode, the singular target, and `t` remain the
analytical unit; and one terminal episode disposition remains the atomic
persistence unit. RRP owns accounting for every admitted episode, including
ineligible and bounded-failure outcomes, without implying that every episode
receives a risk estimate.

Define the smallest useful three-family logical history model and storage-
neutral port; make scope completeness, partial progress, deterministic
continuation, idempotency, retry, correction, raw-read, and current-read
semantics explicit; and supply one project-path DuckDB adapter with explicit
initialize, reopen, backup, and bounded recovery behavior.

The accepted Stage 7 path is:

```text
explicit project + authoritative analytical time t + operation key
        ↓
existing selected producer and canonical admission
        ↓
one trusted admitted scope containing N discharge episodes
        ↓
deterministic sequential enumeration
        ↓
each episode through existing singular-target Stage 6 semantics
        ↓
one independently atomic terminal disposition per episode
        ↓
derived complete or incomplete scope in project-owned DuckDB state
```

History records what the accepted computation actually knew and concluded. It
does not become another target, state, request, provider, or estimate authority.

### Why here and dependencies

History records what the complete Stage 6 computation actually knew and did.
It must precede products, which are rebuildable views of this operational
truth, while remaining separate from the physical adapter.

### Stage 6 reconciliation and inherited constraints

Stages 1–6 are accepted and complete at committed baseline
`c9a8f539d07611d29ec86d4fd1ee5a308413938c`. No corrective implementation
change is required before Stage 7. The realized system fixes these inputs:

- `rrp_execute_producer()` returns one admitted canonical bundle at one exact
  authoritative `t`, or one bounded failure, and writes nothing;
- `rrp_execute_risk()` evaluates one episode at that same `t`, invokes the
  exact project-selected provider at most once, returns one accepted estimate
  or bounded failure, and writes nothing;
- the admitted bundle already attributes project, producer, implementation,
  mapping, profile, capability, bundle instance, and authoritative cutoff;
- the immutable state, standard request, and accepted estimate have governed
  closed shapes and deterministic state/request identities;
- patient identity exists in admitted `discharge_episode` data but is
  deliberately absent from provider state, request, and estimate semantics;
- the project manifest already declares one safe relative `State-Path`,
  normally `state`, that remains absent until this stage;
- the project loader is the sole authority for exact project, producer, and
  provider selection and controlled library ordering; and
- no state initialization, run identity, persistence dependency, history
  record, product, or operator command currently exists.

Stage 7 preserves the Stage 5/6 exports as nonpersistent primitives. It adds a
higher bundle-scoped operation that composes those episode-level semantics
with history construction and independent atomic episode append; it does not
silently make either accepted primitive persistent or change the Stage 6
one-call rule.

### Scope test and settled decisions

| Question | Accepted Stage 7 decision |
|---|---|
| Operational scope | One successful producer invocation and canonical admission at exact authoritative `t` establish one trusted admitted bundle containing zero or more discharge episodes. One durable operation owns accounting for that whole scope. |
| Analytical and provider unit | One analytical run concerns one admitted discharge episode, the singular target, and exact `t`. A provider execution remains one optional call for one eligible episode analytical attempt. |
| Processing and persistence | RRP enumerates admitted episode IDs deterministically and sequentially initially. Each episode receives or remains visibly pending toward one governed terminal disposition, committed independently and atomically. There is no all-episode transaction. |
| Scope completeness | Immutable scope evidence records expected count `N` and a governed/versioned membership fingerprint over canonically encoded, uniquely admitted episode IDs. Completeness is derived only when terminal-disposition membership reproduces both; no mutable completion flag or full bundle is authoritative. A zero-episode scope is complete once its scope evidence is durable. |
| Operation, analytical run, attempt | The operation-run identity is bundle-scoped and keyed by the caller operation key. Analytical-run, episode disposition, state/request, and optional provider-execution identities remain episode-scoped. There is no batch, episode-operation, loop-position, transaction, storage-row, or attempt-counter domain identity. |
| Continuation and retry | Reinvoking an incomplete matching scope continues only missing episode dispositions. An explicit provider retry is a separate later episode analytical attempt related to one terminal failure; it never occurs implicitly during continuation. |
| Ordinary rerun | A deliberately new bundle computation, even at the same `t`, receives a new operation-run identity and new episode analytical identities. It does not replace earlier history automatically. |
| Persisted representation | Preserve minimal scope provenance, expected membership evidence, and one terminal episode disposition containing exact small governed state/request/accepted-estimate objects only when those stages occurred. Do not persist the full canonical bundle or create one logical table per in-memory noun. |
| Correction model | `correction` is operator intent, not a third mutation mechanism. It is represented as either an immutable invalidation or an atomic restatement consisting of new episode or scope history plus an invalidation/replacement relationship. |
| Validity scope | Invalidation/restatement normally targets one episode analytical result. A scope-level action is allowed only for a defect in shared admission or operational provenance; individual state/request/execution/estimate fragments are never independently invalidated. |
| Raw and current history | Raw history exposes immutable scopes, partial progress, all dispositions, and actions. `rrpruntime` derives effective/current episode meaning and excludes incomplete scopes from population-level current interpretation; DuckDB does not own validity rules. |
| State lifecycle | State initialization is explicit, separate from project initialization and execution, create-only for an absent state root, and idempotently validating for an already-compatible root. Execution never initializes state implicitly. |
| Adapter | DuckDB is the one supplied local adapter, not the logical contract or a production database requirement. |
| Concurrency | One controlled writer/session per project state on a supported local filesystem. No distributed or production multi-writer claim. |
| Legacy history | No `v0.1.0` import/archive contract enters Stage 7. The clean 1.0 state begins prospectively empty; legacy import remains a later explicit migration concern. |

### Run, batch, and identity model

Stage 7 retains the minimum distinct identities required by Platform
Architecture:

1. **Operation-run identity** identifies one admitted-bundle operational scope
   and its idempotency domain. RRP derives it from initialized state identity
   and a required caller-supplied bounded, nonsecret operation key. Reusing the
   key addresses interruption and uncertain persistence without treating a
   different admitted population as the same operation.
2. **Analytical-run identity** identifies one episode/target/`t` question
   within that operation. Initial identities are deterministic from operation
   scope and analytical inputs. An explicit retry creates a new related
   analytical attempt identity; an ordinary rerun or restatement also creates
   new analytical identities and never overwrites prior facts.
3. **Provider-execution identity** identifies the exact one provider call for
   one episode analytical attempt. It is deterministic from the analytical
   attempt, request, and selected provider and is `NULL` when eligibility or
   compatibility prevents invocation.
4. Existing **state ID** and **request ID** remain the governed Stage 6
   identities. A successful execution receives one durable estimate-record ID
   derived from the provider-execution identity and accepted estimate. The
   Stage 6 estimate object is not modified to become a persistence object.
5. One immutable **history-action ID** identifies an invalidation or
   restatement relationship. There is no separate batch, episode-operation,
   correction, restatement, loop-position, transaction, storage-generated, or
   retry-counter identity.

Processing order may be deterministic without becoming identity. The exact
deterministic ID algorithms and version markers are part of the 7.A contracts.
Filesystem paths, Git state, wall-clock order, provider values, similarity of
inputs, storage row IDs, and DuckDB sequences never define semantic identity.

### Logical history record model

Stage 7 uses three logical record families rather than reproducing historical
family proliferation. Completion is derived and does not add a fourth family.

#### Operational scope

One closed immutable operational-scope record carries:

- contract, record, named-operation, and bundle-scoped operation-run identities;
- the caller operation key only in its bounded governed representation;
- initialized state identity;
- RRP product/development and relevant API/contract versions;
- project ID/version;
- canonical bundle/profile, producer, implementation, and mapping attribution;
- singular target ID/version and authoritative analytical `t`;
- expected admitted discharge-episode count `N`;
- the governed fingerprint algorithm/encoding version and deterministic
  membership fingerprint over sorted, uniquely admitted episode IDs; and
- operation start/creation and bounded provenance timestamps that never define
  analytical order.

The scope record is durable before episode enumeration and may remain
incomplete. It stores neither the full canonical bundle nor a second episode
manifest. `complete` is derived by comparing expected count and fingerprint
with the unique terminal dispositions linked to the scope; a mutable flag or
terminal scope event is not authoritative. A zero-episode scope is derivably
complete once this record is durable. Only the one initial analytical identity
derived for each admitted episode contributes to scope completeness; later
retry or restatement records do not alter the admitted-membership proof.

#### Episode execution/disposition

One closed terminal episode-disposition record carries:

- its record ID and parent operation-run and analytical-run identities;
- opaque project-owned `episode_id` and the minimal associated opaque
  `patient_id` needed by later episode/patient products;
- target eligibility outcome;
- the exact detached governed episode-state object when eligibility succeeded;
- the exact detached standard request when constructed;
- provider, implementation, and nullable model attribution when selected;
- nullable provider-execution identity and an invocation status distinguishing
  `not_invoked`, `succeeded`, `declared_failure`, and `detected_failure`;
- one bounded provider/runtime outcome code;
- nullable durable estimate-record ID; and
- the exact detached governed accepted estimate on success.

Field-presence rules make these combinations closed. The governed terminal
outcomes include ineligibility, accepted estimate, provider incompatibility,
provider-declared failure, bounded execution failure, invalid provider result,
invalid estimate, and any other explicitly governed post-admission Stage 6
failure. Ineligibility has no state, request, provider execution, or estimate.
Compatibility failure may retain state/request and selected-provider
attribution but has no provider call. A successful provider call has exactly
one accepted estimate. A failed call has no estimate.

The record does not duplicate the full canonical bundle, terminal-event rows,
or arbitrary domains. Exact state/request/estimate retention is justified
because those small governed objects establish what the provider could know,
what quantity RRP requested, and what RRP accepted without rerunning current
code. Their overlapping identities are intentional integrity evidence, not a
second semantic authority.

#### History action

One closed immutable action normally targets one existing episode analytical
run and contains action identity, target kind and identity, action type,
effective wall-clock time, bounded reason code, optional replacement scope/
analytical identity, and actor/provenance category without a person name or
free-form clinical narrative. It may instead target an operational scope only
when shared admission or scope provenance is defective, such as the wrong
bundle or authoritative `t`.

- `invalidate` excludes the targeted analytical result—or, narrowly, every
  analytical result under a defective scope—from effective/current reads and
  has no replacement.
- `restate` excludes the target and identifies newly appended replacement
  analytical history. The replacement episode disposition and action append
  atomically; a scope-level restatement uses a new operational scope rather
  than mutating membership.

An action never erases or edits its target and cannot be revoked in place. If
an action was itself mistaken, a new valid analytical run/restatement is the
supported forward correction; Stage 7 does not add an action-edit graph.

### Persistence boundary and privacy

Stage 7 persists only facts needed for durable provenance, current operational
interpretation, future product construction, and correction semantics:

- initialized state identity and compatibility metadata;
- operational-scope, episode analytical, execution, and relationship identities;
- project/software/canonical/producer/provider/model/target attribution;
- bundle instance, exact analytical time, expected episode count, and versioned
  membership fingerprint;
- opaque episode and patient linkage;
- the exact governed state, request, and accepted estimate when present;
- bounded eligibility/execution outcome; and
- immutable invalidation/restatement evidence.

It does **not** persist raw hospital source data, the full canonical bundle, a
second episode manifest, encounter identity, terminal-event rows, credentials,
connections, executable callables, project/software filesystem paths,
arbitrary source vocabulary, source-system configuration, provider exception
text, stack traces, arbitrary configuration, model content, mutable references,
application products, logs, metrics, or audit claims.

`patient_id` enters only the durable episode-attribution boundary because later
history-built products must relate multiple episodes for one patient. It does
not enter the provider state, request, estimate, diagnostic, or operation
message. Both patient and episode IDs are sensitive project-owned operational
data: supported reads return them only as data, never in diagnostics or routine
rendering. Stage 7 does not claim encryption, authorization, retention,
de-identification, audit completeness, or production privacy approval; those
remain deployment/adopter responsibilities.

The membership fingerprint is project-owned operational metadata and an
integrity/equality aid, not a security or authentication primitive. Its closed
canonical encoding and algorithm version are governed in 7.A.

### Terminal outcomes, completeness, and atomic writes

Project loading, producer execution, canonical admission, and exact-`t`
agreement precede creation or matching of a trusted operational scope. Invalid
project/resource/configuration, producer failure, canonical-admission failure,
or invalid/mismatched analytical time therefore remain bounded nonhistorical
operation failures: no trusted population exists to disposition.

After successful admission, RRP validates the uniquely admitted episode IDs,
computes expected count and the governed membership fingerprint, and
atomically creates or matches the immutable scope. It walks the admitted IDs
in deterministic order. For each episode, these outcomes are terminal and
persistable:

- accepted estimate success;
- target ineligibility for a known episode, including before discharge,
  exhausted horizon, known readmission, or known death;
- selected-provider incompatibility or other pre-invocation runtime failure;
- controlled provider-declared failure;
- RRP-detected execution/result/estimate failure with only its bounded code;
  and
- another closed, explicitly governed post-admission Stage 6 terminal failure.

An impossible unknown/malformed episode or membership invariant after
admission fails closed and leaves the scope visibly incomplete; RRP does not
fabricate a disposition. A persistence failure is never reported as a
committed disposition unless reopening by the same operation key and
analytical identity proves it exists.

Creating or matching the scope uses one short atomic write. Each episode
disposition is validated before delegation and becomes visible all-or-none in
its own transaction. A restatement transaction adds its replacement episode
disposition and history action all-or-none. No reader may observe an estimate
without its disposition or a replacement without its action. No transaction
spans evaluation of all `N` episodes.

Raw progress is the immutable scope plus `k` committed unique dispositions.
Here `k` counts only the one deterministic initial analytical identity per
admitted episode. The scope is complete exactly when `k = N`, those episode
IDs reproduce the scope membership fingerprint, and their immutable provenance
matches. Retry/restatement history does not change this proof. Until then the
scope is derivably incomplete; no extra completion record is required. A zero-
episode scope is complete when its scope evidence is durable.

### Idempotency, conflict, and retry

Idempotency is exact at two cardinalities:

- the same operation key and matching governed scope identity/provenance,
  expected count, and membership fingerprint match the existing scope;
- a complete match returns existing history without episode reexecution;
- an incomplete match deterministically re-walks admitted episode IDs, skips
  every matching terminal analytical identity, and evaluates/appends only
  missing dispositions;
- the same operation key with different governed scope evidence is an
  idempotency conflict and changes nothing;
- the same episode analytical identity and identical terminal disposition are
  idempotent; different content under that identity is a conflict; and
- a new operation key creates a genuinely new operational scope; same `t` or
  similar inputs/values alone never deduplicate a run.

If a 500-episode process ends after 347 commits, raw history exposes expected
count 500, the scope fingerprint, and 347 dispositions. Reinvocation with the
same key and exact `t` reproduces producer/admission output, matches all
immutable scope evidence, re-walks the admitted IDs, and processes only the
153 missing dispositions. An already committed disposition—including a
failure—is complete for continuation; its episode is not reexecuted and its
provider is not recalled. RRP guarantees visible attributable partial work and
deterministic continuation when reinvoked, not background completion after a
process disappears.

If producer execution or canonical admission fails while attempting to
continue, the existing scope remains incomplete and unchanged; the new failure
returns through the privacy-safe nonhistorical operation-result boundary.

An analytical/provider retry is a separate explicit later episode attempt. It
preserves the original terminal failure, uses a new analytical/provider
execution identity related to that failed predecessor, and invokes the
provider at most once. It does not occur during continuation and does not add
automatic policy, backoff, counters, fallback, branching, or hidden loops. A
changed provider/input is a new analytical run and, if intended to supersede an
earlier result, an episode restatement.

### Immutable raw and effective/current history

Raw history is every committed operational scope, episode disposition, and
history action, including incomplete progress, failures, and invalidated facts.
Nothing in an ordinary append, provider transition, project/software change,
invalidation, or restatement updates or deletes earlier logical records.

Current history is a deterministic `rrpruntime` interpretation of raw history:

1. apply only history actions effective at or before an explicit history
   cutoff;
2. derive operational-scope completeness from expected and disposition
   membership and exclude episode records from incomplete scopes from
   effective population-level interpretation while retaining them in raw
   history;
3. exclude invalidated episode results and defective scopes while retaining
   them in raw history;
4. resolve each analytical lineage to its explicit effective attempt;
5. consider the resulting terminal outcome, including success, failure, or
   ineligibility, so a newer failure/ineligibility cannot expose a stale
   estimate as though it were current;
6. for an episode and target, use the greatest analytical `t` at or before an
   explicit analytical cutoff;
7. use an explicit restatement relationship to resolve same-`t` replacement;
   and
8. fail as ambiguous if multiple unrelated effective analytical runs remain at
   the same greatest `t`.

Wall-clock time, insertion order, provider name, record ID, or physical row
order never breaks an analytical tie. Current history is calculated, not
materialized, in Stage 7. DuckDB supplies raw candidate reads; the logical
resolver remains the single authority. Stage 9 may materialize products from
this interface but may not reproduce its validity logic.

### Time semantics

Four time meanings remain explicit:

- **analytical `t`** is the exact admitted bundle cutoff and state/request
  as-of time; it determines target meaning;
- **scope creation and episode execution times** describe when platform work
  happened and never change analytical meaning or prove completeness;
- **commit time** is adapter evidence of durable visibility and never chooses
  between analytical facts; and
- **history-action effective time** controls when invalidation/restatement
  affects current interpretation.

Raw/current read operations require explicit analytical and history cutoffs
where time-relative interpretation matters. No default `Sys.time()` may make a
reproducibility claim implicit.

### Storage-neutral logical port

`rrpruntime` owns the closed history contracts, constructors/validators,
relationship rules, current-history resolver, and a small port exposing only
RRP needs:

- append or match one validated immutable operational scope;
- append one validated terminal episode disposition against that scope;
- append one validated invalidation action;
- atomically append one replacement episode disposition with its restatement
  action;
- read one raw scope and its progress by operation-run identity;
- read raw episode history through an explicit history cutoff; and
- resolve effective/current episode history through explicit analytical and
  history cutoffs.

The storage-neutral adapter declaration must affirm atomic scope, episode, and
restatement append; identical-content idempotency; conflicting-identity
rejection; immutable raw retention; completeness/progress reads; bounded raw
reads; and detached results. The supplied durable adapter must additionally
prove close/reopen durability in 7.B. The port says nothing about SQL, tables,
files, DBI connections, indexes, locks, checkpoints, or DuckDB. It is not a
generic database interface.

Adapters return detached plain records. The port validates before writes and
after reads. Adapters may use query columns to bound raw candidate retrieval,
but only `rrpruntime` applies completeness, continuation, retry, invalidation,
restatement, ambiguity, and current-selection rules.

### Package ownership and dependency strategy

| Owner | Stage 7 responsibility |
|---|---|
| `rrpruntime` | Storage-neutral operational-scope, episode-disposition, action, and identity contracts; membership fingerprint and completeness rules; record validation; port conformance; idempotency/conflict/continuation relationships; raw-to-current resolver; dependency-free in-memory conformance evidence. |
| `rrpplatform` | Installed contract/resource loading; project `State-Path` resolution; explicit initialize/open/close/inspect operations; DuckDB/DBI adapter; single-writer session control; bundle-scoped durable producer/risk orchestration; history operations; backup/restore; common privacy-safe results. |
| Independent project | Declares the existing state path and owns writable state, backup destination, retention, access, encryption, filesystem, and operating policy. It does not register a persistence implementation. |
| Stage 9 products | Consume only storage-neutral effective-history reads. They do not query DuckDB or reconstruct validity. |

Dependency direction remains:

```text
rrpplatform  ──>  rrpruntime
     │
     ├──> DBI
     └──> duckdb
```

`DBI` and `duckdb` become direct `rrpplatform` runtime dependencies in 7.B and
therefore part of the eventual installed RRP closure. They do not enter
`rrpruntime`, project extension libraries, or the public logical contracts.
No third internal adapter package is justified: Platform Architecture already
assigns default adapter composition to the main package, and there is not yet
an independent release/substitution boundary worth maintaining.

### Project state path and explicit lifecycle

The manifest-owned `State-Path` becomes operational without changing the
`0.3.0` project contract. The sole supplied adapter needs no manifest-level
profile selection yet.

```text
validated project with absent State-Path
        ↓ explicit initialize-state operation
staged state metadata + empty DuckDB history
        ↓ validate and atomic promote
initialized compatible project state
        ↓ explicit open/read/write/close
reopenable identical logical history
```

Initialization:

- resolves the safe relative path beneath the explicit validated project;
- rejects links, nonregular required files, path escape, case-folded conflict,
  overlap with project source boundaries, or an unsafe ancestor;
- creates the complete initial state in a unique sibling staging directory;
- validates it before atomic promotion;
- creates exactly `state.dcf`, a closed state metadata record, and
  `history.duckdb`, the DuckDB history file;
- removes only staging content owned by the failed attempt;
- returns success without mutation when an existing root is fully compatible;
  and
- rejects partial, unknown, malformed, incompatible, or differently owned
  existing state. There is no force/reinitialize mode.

Project initialization remains unchanged and does not create state. Durable
execution against missing state fails with bounded `state_uninitialized`
guidance. Read/write operations open the adapter only for their bounded work
and close it reliably; raw DBI connections are never returned through the
supported platform API.

### State identity and compatibility

The state metadata records one opaque state identity generated once at
initialization and never derived from a path. It also records:

- state contract and metadata format versions;
- owning RRP product identity and initializing software provenance;
- owning project ID and initializing project version;
- supported RRP/project API line;
- singular target and history-contract identities;
- logical history format version;
- adapter ID/version, physical schema version, and payload encoding version;
- created-at time; and
- the expected closed initial/live inventory.

The current project ID must equal the state owner. Project version is retained
per run and the initializing version is provenance, not an automatic equality
gate; compatible project revisions may continue the same state. Exact software
build paths are never recorded. A newer installed RRP may open state only when
all declared state/history/adapter versions are supported explicitly.

Compatible state opens without mutation. Newer unsupported, older migration-
required, malformed, partial, linked, physically corrupt, target-incompatible,
or other-project state fails closed with bounded recovery guidance. Automatic
migration and repair are absent.

Copying a project together with its state preserves project and state identity
and must reopen without reference to the original path, repository, or Git.
Copying without state yields an uninitialized project. Changing the copied
manifest's project identity makes the copied state incompatible. Stage 7 does
not merge later-divergent copies.

### DuckDB adapter, transactions, and interruption

DuckDB is a private `rrpplatform` adapter behind the logical port. Its physical
schema exposes enough scalar identity/time/status columns for bounded reads and
stores a versioned complete logical payload representation for exact roundtrip.
The concrete table layout and smallest proven payload encoding are adapter
internals selected in 7.B; their versions are compatibility metadata, not
public history contracts.

Initialization and every write use transactions. Scope creation/match is one
short atomic operation. Each terminal episode append inserts one complete
disposition and its scope relationship atomically. Restatement inserts its
replacement episode disposition and action atomically. Invalidation inserts
its one action atomically. Preflight checks all existing identities and
relationships before mutation. Physical tables need not mirror logical record
families one-for-one.

Focused failure injection must cover:

- before the transaction;
- after each logical member insertion;
- immediately before commit;
- immediately after commit but before the caller receives success; and
- each stage of atomic restatement.

After close/reopen, pre-commit failures expose none of the candidate logical
write; committed episode dispositions are complete; and post-commit uncertainty
is resolved by the same operation key and episode identity without provider
reexecution. A process may leave a truthful incomplete scope containing only
fully committed dispositions; no partial disposition/action becomes raw or
current history.

The supported concurrency posture is one writer/session per project state on
a local filesystem. DuckDB's write ownership is the initial local exclusion
mechanism; inability to acquire it fails boundedly. Stage 7 adds no persistent
lock protocol, network-filesystem support, distributed lease, concurrent-
writer merge, or production concurrency claim. Read-only inspection occurs
only through bounded adapter sessions consistent with DuckDB's constraints.

### Backup and recovery

Backup is an explicit operation, never automatic. It requires a quiescent
closed writer, validates source state, checkpoints DuckDB, copies into a new
staged backup destination without overwrite, reopens the copy read-only, and
validates state identity, schema, metadata, and logical high-water evidence
before promotion. The backup directory contains exactly `backup.dcf` and the
checkpointed `history.duckdb`. The closed manifest records backup contract/
version, state/project identity, history/adapter/schema versions, creation
time, source high-water commit identity/counts, and payload file name/size. It
does not claim malicious-tamper detection or cryptographic authenticity.

Recovery has three bounded meanings:

1. normal reopen validates metadata/schema and relies on DuckDB transaction
   recovery so only committed scopes, dispositions, and actions appear;
2. uncertain append recovery reuses the operation key and episode identity to
   return existing committed work or continue only missing dispositions; and
3. explicit restore validates a closed backup and restores it transactionally
   into an absent declared state path.

Restore never overwrites, merges with, or repairs an existing state root. An
operator must first preserve/remove an unusable root under local policy. Stage
7 does not promise repair of arbitrary database corruption, point-in-time
recovery, scheduled/off-host backup, retention, encryption, replication,
disaster recovery objectives, or restore across incompatible state versions.

### Relationship to Stage 5/6 execution

The new durable operation composes rather than alters the existing primitives:

```text
preflight explicit initialized state + operation key
        ↓ existing rrp_execute_producer() semantics at t
        ↓ existing admission truth
        ↓ create/match admitted-bundle operational scope
        ↓ deterministically enumerate every admitted episode
        ↓ for each missing episode, use existing Stage 6 semantics
        ↓ build and atomically append one terminal disposition
        ↓ derive complete/incomplete scope from membership evidence
        ↓ common operation result containing only safe identity/status evidence
```

The implementation may factor existing internal Stage 5/6 helpers so the
durable orchestrator can receive governed state/request/outcome evidence, but
the existing public operations retain their inputs, outputs, one-call behavior,
and zero-persistence semantics. Stage 7 owns admitted-bundle enumeration and
accountability; each analytical/provider/persistence unit remains one episode.
Vectorization, parallelism, scheduling, queues/workers, cohort selection beyond
the admitted bundle, and product scoring remain later concerns.

### Increment 7.A — Logical history contracts, port, and in-memory semantics

**Implementation status:** complete on 2026-09-19; Increment 7.B is next.

**Objective:** establish the complete storage-neutral operational-history
meaning before selecting physical storage.

**Scope and ownership:** add the cataloged operational-scope, episode-
disposition, history-action, and history-port authorities with `rrpruntime`
ownership. Add dependency-free constructors/validators; bundle-scoped
operation and episode-scoped analytical identities; governed membership
fingerprint encoding; expected-cardinality, scope/episode relationship,
progress, and completeness rules; idempotency/conflict and continuation
semantics; retry/correction distinctions; raw/current interpretation; and a
test-only in-memory adapter solely to prove the logical contract.

**Interfaces introduced:** logical append/match-scope, append-terminal-episode,
append-invalidation, append-restatement, read-raw-scope/progress, read-raw-
episode-history, and read-current-episode-history operations. Exact exported R
names and namespace count are settled during implementation without widening
this semantic surface.

**Historical reuse:** substantially reuse validate-before-delegate port
composition, identical-content idempotency, conflict failure, detached records,
and in-memory conformance mechanics. Adapt population provenance, episode
iteration, retry/current/invalidation tests, and actions to the three-family
scope/disposition/action model. Reject historical YAML, daily-hazard/estimand
fields, five separate analytical families, started/failed lifecycle records,
multi-attempt batches, giant population transactions, and family-level
invalidation cascades.

**Evidence:** contract/catalog closure; exact field/presence and relationship
tests; deterministic scope/analytical identities and fingerprint; zero, one,
and multiple episode scopes; success/ineligibility/failure dispositions;
partial and complete progress; count/fingerprint mismatch; idempotent repeat
and conflict; continuation versus retry; episode/scope invalidation and
restatement; incomplete-scope current gate; analytical/history cutoffs;
ambiguity failure; detachment/privacy; base-R package-native tests; package
build/check; repository validation and hygiene.

**Exclusions:** no project path, state directory, DuckDB/DBI, durable file,
platform orchestration, backup, product, migration, or legacy import.

**Completion statement:** dependency-light runtime can validate and interpret
storage-neutral immutable bundle scopes, episode dispositions, completeness,
and current history, but no project can initialize or retain them durably.

### Increment 7.B — Explicit project state and DuckDB adapter

**Implementation status:** complete on 2026-09-20; Increment 7.C is next.

**Objective:** realize the accepted logical history port in explicit,
project-owned local state without analytical orchestration.

**Scope and ownership:** add the project-state metadata and installed DuckDB-
adapter authorities under `rrpplatform`; add `DBI` and `duckdb` as its direct
dependencies; implement safe state-path resolution, staged initialization,
compatibility inspection, private open/close sessions, exact logical roundtrip,
atomic scope/episode/action/restatement append, raw scope-progress and bounded
history reads, and close/reopen. State may contain incomplete and complete
operational scopes, independently committed episode dispositions, and history
actions. Update the project doctor to report absent, compatible, or
incompatible state without creating or repairing it.

**Interfaces introduced:** stable platform operations to initialize and inspect
project state; protected adapter/session composition used by later operations.
The raw connection, SQL schema, and table names remain private.

**Historical reuse:** substantially reuse explicit non-destructive initialize,
schema metadata, adapter-owned connection lifecycle, transaction wrapper,
preflight idempotency/conflict, deterministic raw reads, close/reopen, and
interruption injection. Adapt from repository config to manifest `State-Path`,
from six tables to the 1.0 logical model, and from optional dependencies to
owned package dependencies. Evaluate raw BLOB versus another exact versioned
payload encoding with a bounded implementation spike; record the chosen
adapter-internal format.

**Evidence:** missing/existing/partial/linked/unsafe state; staged cleanup;
idempotent compatible initialization; other-project and every compatibility
mismatch; exact scope/disposition/action roundtrip; incomplete progress and
derived completion; operation-key conflict; copied project with and without
state; arbitrary non-Git working directory; single-writer contention;
transaction injection at every scope/episode/action boundary; reopen after
rollback/commit; in-memory/DuckDB semantic equivalence; dependency direction;
isolated install/load and strict package checks.

**Exclusions:** no producer/provider execution, durable run operation, history
correction operation, backup/restore, migration, remote adapter, or product.

**Completion statement:** an explicit project can initialize and reopen a
compatible empty/local history store and the adapter can durably satisfy the
logical port, but normal RRP computation still does not write it.

### Increment 7.C — Bundle-scoped durable operation and history interpretation

**Implementation status:** complete on 2026-09-20; Increment 7.D is next.

**Objective:** connect the accepted Stage 5/6 computation to terminal history
without changing its episode-level analytical semantics, while making RRP
accountable for every episode in one successfully admitted bundle.

**Scope and ownership:** add one `rrpplatform` durable operation taking an
explicit software catalog, project root, analytical `t`, and operation key.
Preflight initialized state; execute the existing selected producer and
canonical admission; create or match the admitted-bundle scope; enumerate its
episode IDs deterministically; and, for each missing analytical identity,
evaluate unchanged Stage 6 semantics and atomically append one terminal
disposition. Derive completeness and return bounded common evidence. Add
supported raw/current scope and episode inspection, explicit episode retry,
episode invalidation/restatement, and narrowly justified scope correction over
the same port. Factor internal evidence only as necessary while preserving all
existing public primitive behavior.

**Interfaces introduced:** bundle-scoped durable execution; raw scope-progress
and raw/current episode-history inspection with explicit cutoffs; deterministic
continuation under the same operation key; explicit retry linked to one failed
episode attempt; episode correction; narrow scope correction; and atomic
restatement. Exact public technical names and export count are recorded during
implementation.

**Historical reuse:** conceptually adapt producer-once population
orchestration, episode eligibility iteration, provider-only-for-eligible
execution, attributable provenance, retry lineage, current-read, and
restatement tests. Reject repository-root discovery, generated reference
source, daily-hazard runs, one giant population transaction, started/failed
lifecycle machinery, automatic retry, and raw error retention.

**Evidence:** installed temporary source-to-producer-to-admission-to-bundle-
scope execution with multiple materially different episode outcomes; zero-
episode completion; explicit ineligibility and bounded provider failures;
nonhistorical producer/admission failures; one-call and pre-provider zero-call
guards per episode; full count/fingerprint completion; interrupted subset with
visible incomplete progress; same-key continuation of only missing episodes;
no provider recall for committed dispositions; scope mismatch conflict;
explicit retry distinct from continuation; episode and narrow scope
correction; raw/current gating and ambiguity; privacy-safe results; process
restoration; state-only mutation; copied-project execution; no Stage 5/6
primitive persistence regression.

**Exclusions:** no vectorized/batch provider inference, parallelism, production
concurrency, scheduling, queue/worker/lease machinery, automated retry,
persisted loop cursor, cohort selection outside the admitted bundle,
retrospective reconstruction, product/materialization, app, CLI, or backup.

**Completion statement:** installed RRP can own one admitted-bundle scope,
sequentially and atomically disposition every admitted episode, expose and
continue incomplete work deterministically, interpret raw/current history, and
correct it append-only, but has no supported backup/restore proof.

### Increment 7.D — Backup, bounded recovery, and complete installed proof

**Implementation status:** complete on 2026-09-21; committed hosted evidence
and formal Stage 7 acceptance are recorded below.

**Objective:** close the local project-state lifecycle and prove the complete
Stage 7 claim under interruption and independent installed use.

**Scope and ownership:** add explicit create-only checkpointed backup and
absent-destination restore operations, backup manifest validation, lifecycle
documentation, full installed state/history proof, repository ownership and
validator updates, and any narrowly required hosted dependency setup. Do not
change the logical history model.

**Interfaces introduced:** explicit project-state backup and restore plus
bounded lifecycle/doctor evidence. There is no automatic backup agent or repair
command.

**Historical reuse:** substantially reuse quiescent DuckDB checkpoint-copy,
read-only reopen validation, and restart tests. Adapt backup identity to project
state and add create-only staged restore. Reject active-WAL copying, overwrite,
merge, arbitrary corruption repair, enterprise backup claims, and repository
operation wrappers.

**Evidence:** backup only while writer is quiescent; create-only destination;
manifest and database validation; complete-history backup; backup of a
partially processed scope; exact raw scope/disposition/action equality after
restore; preserved derived completeness; deterministic continuation after
recovery to the same complete logical history as uninterrupted execution;
normal reopen; pre/post-commit recovery; corrupted/incomplete/incompatible
backup failure; source preserved on every failure; installed packages/resources
from an unrelated non-Git directory; copied project; clean generated-artifact
inspection; package builds/checks; repository/package validators; and committed
hosted workflow evidence before separate Stage 7 acceptance.

**Exclusions:** no scheduled/off-host backup, retention, encryption, access
control, replication, point-in-time restore, physical corruption repair,
migration, multi-writer service, products, app, CLI, distribution, or deployment.

**Completion statement:** RRP can explicitly initialize, append, reopen,
inspect, continue, back up, and restore complete or incomplete supplied local
project history with bounded recovery guarantees. Formal Stage 7 acceptance
and architecture reconciliation were completed as a separate lifecycle action,
not Increment 7.E.

### Validation and hosted evidence

The existing human operations remain the source-validation entry points:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
```

Package validation grows incrementally for the closed history/state resources,
dependency-free runtime port, in-memory conformance, DBI/DuckDB dependency
closure, explicit state lifecycle, atomicity/interruption, durable operation,
raw/current interpretation, corrections, backup/recovery, copied-project
portability, builds, isolated dependency-order install/load, package-native
tests, and strict checks. No separate general validation framework is added.

The read-only `package-foundation` workflow should continue to invoke the same
human operations. It may gain only the dependency setup required to install
the now-declared `rrpplatform` closure. Final Stage 7 acceptance requires a
successful hosted run for the exact committed complete Stage 7 implementation
and records workflow/run/job/SHA/ref/event. Passing software evidence is not a
production database, privacy, security, audit, clinical, or disaster-recovery
claim.

That requirement passed for the exact committed implementation at
`387976b15739071d8f685d316d2eb712707479ca`: `package-foundation` push run
`35589769595`, job `106301272647`, completed successfully on `main`. The job
passed checkout, R 4.4 setup, declared external dependency installation,
repository validation, and package validation.

### Human-readable Stage 7 acceptance scenario

```text
build and isolate-install rrpruntime then rrpplatform with DBI/DuckDB
        ↓
project exact installed resources into a temporary software root
        ↓
create and load an explicit independent project
        ↓
confirm project State-Path is absent
        ↓
explicitly initialize compatible project state
        ↓
run one producer and admit a multi-episode bundle at t
        ↓
persist one immutable scope with expected count + membership fingerprint
        ↓
sequentially evaluate materially different episode outcomes
        ↓
atomically append each terminal episode disposition
        ↓
prove complete count/fingerprint and raw/current interpretation
        ↓
repeat the same operation key and prove no episode/provider reexecution
        ↓
interrupt after a subset, reopen, and prove visible incomplete progress
        ↓
reinvoke the same matching scope and process only missing dispositions
        ↓
exercise scope conflict, explicit episode retry, episode/scope correction,
restatement, and ambiguity
        ↓
checkpoint complete and incomplete backups, restore create-only, and continue
        ↓
repeat with copied project state
        ↓
STOP

No hidden retry or fallback
No partial episode disposition and no silent admitted-episode omission
No rewrite of earlier facts
No product or application
```

### Stage 7 acceptance

Stage 7 is complete only when:

1. operational-scope, episode-disposition, history-action, port, project-state,
   and DuckDB-adapter authorities are closed, versioned, cataloged, and owned
   without duplicate authority;
2. one operation-run means one successfully admitted bundle at exact `t`, while
   one analytical run means one admitted episode, singular target, and `t`;
3. provider execution and atomic terminal persistence remain episode-scoped,
   with at most one provider call per eligible analytical attempt;
4. expected admitted count and a governed/versioned deterministic fingerprint
   over canonically encoded unique episode IDs establish immutable scope
   membership without persisting the full bundle;
5. scope completeness is derived only when the unique initial episode-
   disposition membership reproduces both expected cardinality and
   fingerprint; retries/restatements do not alter this proof, zero-episode
   behavior is proved, and no mutable flag is authoritative;
6. every admitted episode is dispositioned or visibly pending, and governed
   records distinguish ineligibility, accepted estimate, provider
   incompatibility/declaration, detected execution/result/estimate failure,
   and other closed post-admission terminal outcomes;
7. pre-admission project/producer/admission failures are not falsely recorded,
   and an impossible post-admission invariant defect leaves an incomplete
   scope rather than a fabricated disposition;
8. operation-run, analytical-run, provider-execution, state/request, and action
   identities are distinct only for the settled purposes; no batch, episode-
   operation, attempt-counter, loop-position, transaction, or storage identity
   is added;
9. the scope is created/matched atomically and each complete episode
   disposition is independently atomic; no transaction spans all episodes;
10. exact governed state/request/estimate objects are retained only when
    constructed, with closed presence/cardinality/relationship rules;
11. minimal patient/episode linkage exists only in history and does not broaden
    Stage 6 provider input or diagnostics;
12. source data, full bundles/manifests, encounter/terminal rows, secrets,
    paths, callables, raw exceptions, source vocabulary/configuration, model
    content, and arbitrary data are absent from history;
13. the same operation key and matching scope continues missing dispositions
    or returns complete history, while conflicting scope evidence fails before
    mutation;
14. a matching committed episode disposition is never reexecuted or appended
    twice, including after interruption or uncertain post-commit return;
15. interruption after any committed subset leaves attributable raw incomplete
    progress; reinvocation reproduces scope, re-walks deterministically, and
    processes only missing episodes without a persisted cursor or queue;
16. continuation is distinct from explicit provider retry; retry is one new
    related episode analytical/provider attempt, preserves the original
    failure, calls at most once, and cannot hide policy, fallback, or loops;
17. genuinely new same-`t` computation uses new operation/analytical identities
    and never silently replaces history;
18. earlier facts remain append-only; normal invalidation/restatement is
    episode-scoped, while scope correction is limited to shared admission or
    provenance defects and uses the same history-action family;
19. raw history returns scopes, incomplete progress, dispositions, and actions;
    current/effective interpretation is derived only by `rrpruntime`;
20. incomplete-scope episodes are gated from effective population-level
    interpretation, while episode + target + analytical `t` remains the
    analytical current-history key;
21. retries, corrections, analytical/history cutoffs, scope validity, and same-
    `t` ambiguity produce exact deterministic current outcomes; wall-clock,
    commit, insertion, or storage order never breaks an analytical tie;
22. the storage-neutral port supports scope/episode/action append, progress,
    completeness, and bounded raw/current reads without database/path/SQL
    vocabulary;
23. `rrpruntime` remains base-R-only and project/resource/path independent;
    `rrpplatform` alone owns DBI/DuckDB, project state, and orchestration;
24. project state initialization is explicit, staged, non-destructive,
    path/link-safe, and idempotently validating for compatible state;
25. missing, partial, malformed, linked, other-project, unsupported,
    migration-required, target-incompatible, or physically invalid state fails
    closed without automatic repair/migration;
26. state reopens independently of repository, Git, original location, or
    ambient library, with copied-project and one-writer local behavior proved;
27. DuckDB exact roundtrip, scope progress/completeness, transaction failure
    injection, reopen, and in-memory semantic equivalence are proved;
28. complete and incomplete state backups are explicit, quiescent,
    checkpointed, create-only, reopened, and validated; staged restore
    preserves active/source state on failure;
29. restored incomplete scope continues to the same complete logical history as
    uninterrupted execution, while broader repair/DR claims remain absent;
30. accepted Stage 5/6 public operations remain nonpersistent and preserve
    their one-episode/one-provider-call behavior unchanged;
31. no legacy import, retrospective rescoring, product/materialization,
    application, CLI, scheduling, queue/worker, parallel/vectorized execution,
    production concurrency, distribution, deployment, audit, retention/
    encryption, migration, or Stage 8 behavior enters;
32. repository/package validation, parsing, package-native/in-memory
    conformance, transaction injection, installed temporary-system proof,
    builds, isolated install/load, strict checks, hygiene, committed hosted
    evidence, and final authority reconciliation all pass without retained
    generated output or deviation from True North/Architecture.

Formal reconciliation against Platform True North, Platform Architecture, the
exit state, and all 32 criteria passed on 2026-09-21 for the exact committed
baseline above. The architecture's earlier singular "terminal run batch"
wording was clarified to express the accepted bundle-scoped operation with an
atomic scope write, independently atomic terminal episode dispositions,
visible incomplete progress, and derived completeness. No implementation or
contract correction was required. Stage 7 is accepted and complete.

### Plain-language exit state

> A hospital project can produce and admit zero or more discharge episodes at
> an authoritative time. RRP owns that admitted scope, processes every episode
> through the governed risk path sequentially if necessary, and atomically
> records either its accepted estimate or governed terminal disposition. After
> interruption or reopening, the project can determine whether the scope is
> complete, safely continue missing work, and account for what happened to the
> admitted population. It still has no application-facing products.

### Historical reuse disposition

Reconnaissance inspected immutable `v0.1.0`
`runtime/R/history-specification.R`, `history-records.R`,
`history-conformance.R`, `persistence-port.R`, the persistence contracts,
`tests/helpers/in-memory-history-adapter.R`, operational-history tests,
DuckDB foundation/schema/session/adapter source and declaration, DuckDB tests,
`runtime/R/eligibility.R`, `operations/lib/runtime-operation.R`,
`provider-operation.R`, `reference-history-operation.R`, and the operational-
history and DuckDB architecture documentation.

| Classification | Historical finding and Stage 7 disposition |
|---|---|
| Reuse substantially | Validate-before-delegate storage-neutral port; adapter capability declaration; detached record validation; identical-content idempotency; conflicting-identity failure; append-only truth; explicit non-destructive initialization; adapter-owned connection lifecycle; transactional append; metadata/schema validation; close/reopen; injected interruption; quiescent checkpoint-copy backup; in-memory and durable conformance proof. |
| Adapt concept/mechanic | Producer-once population orchestration, episode enumeration and eligibility, provider-only-for-eligible execution, bundle/run provenance, provider-attempt lineage, current selection, invalidation/restatement, query columns plus complete payload, read-only reopen, ambiguity failure, backup validation, and prospective empty state. Adapt to one bundle-scoped operation with independently atomic episode dispositions, the singular cumulative target, Stage 5/6 objects, project `State-Path`, explicit operation keys, deterministic continuation, and derived completeness. |
| Obsolete under 1.0 | Daily-hazard/estimand semantics, canonical-run identity, repository-root operations, generated reference source, started/failed lifecycle records, one giant population transaction, incomplete detail for ineligible admitted episodes, multiple provider attempts inside one run, five separately persisted analytical families, family-level invalidation cascade, YAML active contracts, optional repository lock dependencies, and current selection by terminal wall-clock tie-break. |
| Deferred beyond Stage 7 | Legacy archive/import, general migration, production/client-server adapters, multi-writer coordination, encryption/retention/access infrastructure, audit, replay/rescoring, performance indexing claims, and enterprise backup/disaster recovery. |

Historical source is evidence only. No `v0.1.0` record or database is accepted
as current 1.0 state, and no compatibility layer or historical dependency is
introduced.

### Major deferrals and deliberately open adapter details

Stage 8 owns the maintained fictional project, convenience authoring choices,
and normal reference run; Stage 9 owns products/materialization. Stage 7
excludes vectorized/batch inference, parallel processing, chunking/performance
tuning, production concurrency, scheduling, queues/workers/leases, automated
provider retry/fallback, cohort selection outside the admitted bundle,
retrospective rescoring, changed-model migration, production databases,
multi-writer guarantees, network filesystems, automatic migration, legacy
import, retention/encryption/access infrastructure, audit/compliance systems,
enterprise backup/disaster recovery, model artifact preservation, full source
or canonical snapshots, products, app, CLI, distribution, deployment, and
release behavior.

The precise private DuckDB table/index layout and smallest exact payload
encoding remain reversible adapter-internal choices for the bounded 7.B spike.
They must be versioned and prove the accepted logical semantics but do not need
governing-plan permanence. No other unresolved question blocks Increment 7.A.

## Stage 8 — Fictional reference path

**Status:** accepted and complete on 2026-09-28 at exact committed baseline
`87a7e2848fadbd5cd7e4a6aec11908a546d096a3`. Increments 8.A–8.C and the
separate formal acceptance/reconciliation are complete; hosted push run
`36463026242`, job `109066072183`, passed for that baseline.

### Objective and responsibilities

Establish the supported normal hospital authoring path over the accepted raw
producer and provider extension contracts, then use one deterministic,
visibly fictional, nonclinical independent project as its first realistic
adopter. The project owns explicit source generation, source-local meaning,
canonical mapping and identity resolution, private predictor meaning, and an
inspectable project-owned risk calculation. RRP owns the invariant
registration, protocol, canonical-bundle, compatibility, request/result,
admission, estimate, and durable-history machinery around those hospital-
authored callables. Stage 8 also introduces the first version-matched installed
product documentation so the normal interface can be understood without the
development repository.

The result must be one architecture:

```text
normal hospital mapping
        ↓
RRP standard-authoring adapter
        ↓
accepted raw producer contract
        ↓
canonical admission

normal hospital risk calculation
        ↓
RRP standard-authoring adapter
        ↓
accepted raw provider contract
        ↓
Stage 6 execution and Stage 7 history
```

The raw contracts remain supported lower-level extension boundaries for
unusual integrations. The standard layer reduces ceremony; it does not create
a second ingestion, target, provider, or execution path.

### Why here and dependencies

This is the first meaningful end-to-end computational integration point. It
follows the real boundaries rather than shaping them as a privileged example
mode and gives later product/app stages stable fictional history to consume.

Stages 4–7 now provide all lower layers needed to make an evidence-led
authoring choice: explicit projects and trusted registration, selected
producer execution and canonical admission, singular-target provider
execution, and durable bundle-scoped history. Earlier temporary hospital
fixtures proved the raw seams but also showed that a normal author currently
has to reproduce substantial protocol structure. Stage 8 therefore uses the
fictional project as a usability and ownership forcing function, not merely as
another direct raw-contract fixture.

### Reconciled current-state constraints

The accepted committed baseline is
`c40263646988a930014c4e97eb925b5bc495e0ba` (`Stage 7 complete`). Stage 8
inherits these facts without reopening them:

- `rrp-project.dcf` and fixed trusted `R/register.R` remain the two physical
  project-recognition requirements under `rrp.project@0.3.0`;
- registration is trusted local R evaluated from one explicit project root
  under RRP-first, declared-extension-second library ordering and is not a
  security sandbox;
- the manifest selects exact producer and provider IDs/versions while the raw
  registration result supplies their declarations and callables;
- `rrp_execute_producer()` constructs the closed producer request, validates
  the closed result, and delegates one candidate bundle to
  `rrpruntime::rrp_admit_canonical_bundle()`;
- `rrp_execute_risk()` and `rrp_execute_durable_bundle()` use the exact
  selected provider through the Stage 6 request/result boundary;
- that provider receives the unchanged flat, detached 19-field
  `rrp.risk-request@0.1.0`; the request contains canonical `episode_id` as its
  only canonical domain identifier and does not contain source IDs, a
  crosswalk, arbitrary predictors, or provider/model identity;
- the installed transparent provider is protected, explicit, nonclinical,
  and not a default;
- the project manifest already declares one safe relative extension-library
  path and one state path; no dependency installer or lockfile exists;
- the initializer currently emits only a manifest plus verbose raw
  registration with unavailable producer/provider callables;
- project validation/doctor executes and validates registration but never
  invokes either selected callable; and
- the closed resource schema already admits the `documentation` class and
  explicit `rrp_resource_path()` access, but currently admits only `dcf` and
  `r` formats and catalogs no installed product document.

Stage 8 does not change the meaning, version, or availability of the raw
project manifest, registration, producer, provider, canonical, runtime, or
history contracts. A hand-authored raw `0.3.0` project remains valid. The new
normal layer is an optional supported realization that compiles to those exact
contracts.

### Authoring-boundary decision

The standard authoring capability is owned by `rrpplatform` and governed by
one installed `rrp.project-authoring@0.1.0` authority. It fixes a small,
closed, safe-path-aware convention for a standard project:

```text
rrp-project.dcf             existing project selection and path authority
rrp-authoring.dcf           implementation/mapping/model metadata
R/register.R                generated thin trusted wiring; normally untouched
R/produce-canonical.R       hospital source access and canonical mapping
R/calculate-risk.R          hospital model/engine invocation and probability
README.md                   concise generated customization map
```

These additional paths are required only when a project chooses the supported
standard authoring realization. They do not become new recognition markers,
and RRP does not scan arbitrary project files or infer a project from them.
The installed authority defines the exact paths, expected one-function
bindings, function arguments, result alternatives, metadata fields, and
failure-code subsets. The existing manifest remains the selection authority;
the authoring metadata must agree with it and cannot select a target, profile,
contract, source technology, or executable path.

`rrp-authoring.dcf` declares only metadata RRP cannot truthfully infer:

- producer implementation ID/version;
- mapping ID/version;
- provider implementation ID/version; and
- an optional model ID/version pair, either both absent or both valid.

It also declares the exact project-extension package/version inventory, using
an explicit empty value for a base-R-only project. RRP validates declared
packages against the manifest-owned extension library and retains its existing
software-first anti-shadowing rule. This is an installed-closure preflight,
not package acquisition, dependency solving, a source lockfile, or a claim of
reproducible installation; those broader lifecycle responsibilities remain
later work.

The manifest supplies project, selected component, profile, API, extension,
and state facts. RRP derives producer/provider API identities, canonical
bundle/profile and required capability declarations, singular target, state,
request, and estimate compatibility from installed authority. Ordinary
authors do not repeat those fields.

The package-level `rrp_register_authored_project(project_root)` interface is
the sole standard adapter entry point. It validates the authoring authority,
manifest agreement, metadata, dependency inventory, safe fixed files, exact
bindings, and callable signatures without invoking either callable. It then
returns the same closed `rrp.project-registration@0.3.0` result accepted by the
existing loader. A single `rrp_authoring_failure(code)` constructor represents
only an existing producer- or provider-declared failure; the adapter admits a
code only when it belongs to the applicable raw contract. Arbitrary thrown
conditions remain detected execution failures whose text is suppressed.

The exact public names above are selected to make the generated wiring and
normal code inspectable. Implementation may refine a private helper name, but
it may not change the described files, callable responsibilities, or one-path
adaptation without first correcting this plan.

### Normal producer authoring

The current raw producer author must construct or repeat all of the following:
producer API, component, implementation, mapping, bundle, profile and
capability identities; a 15-field success/failure envelope; the 16-field
candidate bundle envelope; bundle-instance identity; project/request
agreement; conditional failure fields; and the actual two canonical domains.
Only the source access, local interpretation, canonical-row construction, and
implementation/mapping provenance are hospital-specific.

The standard producer file therefore defines exactly one function,
`rrp_produce_canonical(project_root, as_of_time)`. The explicit root permits
portable access to project-owned files, clients, configuration, or model
artifacts without a working-directory assumption. The explicit authoritative
time permits source availability filtering. On success it returns one plain
named list containing exactly `discharge_episode` and `terminal_event` data
frames in their installed canonical field order. On a controlled failure it
returns an `rrp_authoring_failure` carrying one existing producer failure code.
It returns no producer/result envelope, capability declaration, candidate
bundle, registration record, or admission result.

The hospital author remains responsible for:

- obtaining approved source data through any suitable local mechanism;
- source-local validation and interpretation;
- cohort/source extraction choices that do not redefine the canonical
  profile;
- translating local fields, identifiers, codes, timestamps, and availability
  meaning into the two exact canonical domains; and
- maintaining truthful implementation and mapping identities/versions.

RRP validates the standard return shape, constructs the raw producer result
and canonical candidate, derives fixed capabilities and all invariant
contract identities, and delegates unchanged to canonical admission. It also
constructs a deterministic valid bundle-instance ID from a versioned,
length-delimited encoding of the request, declared producer/mapping identity,
and exact returned domain content. The encoding and non-cryptographic identity
algorithm belong to the installed authoring authority and tests; a changed
domain realization at the same declared context cannot silently reuse the
same normal-path bundle identity.

The raw producer escape hatch remains appropriate when an advanced project
must construct a representation other than the standard in-memory domain
list, declare a future supported capability variation, integrate a remote or
non-R protocol, or otherwise needs direct control that the normal adapter does
not expose. It still returns the existing raw contract and reaches the same
admission function. SQL/DBI, files, Parquet, DuckDB, APIs, and project packages
are source-access choices inside the standard callable, not separate ingestion
architectures.

### Normal provider/model authoring

The current raw provider author must repeat component, provider API, target,
state, request, estimate, implementation, and optional model compatibility;
accept exactly one request; and build the closed four-field result envelope
with matching request identity and conditional success/failure fields. Only
canonical-to-local resolution, private predictor acquisition/engineering,
model/engine loading, legitimate model-specific transformation, calculation,
and implementation/model provenance are hospital-specific.

The standard provider file therefore defines exactly one function,
`rrp_calculate_risk(project_root, request)`. The explicit project root supports
portable project-owned data access, packages, artifacts, and engines;
`request` remains the existing detached governed Stage 6 request and is not
widened with arbitrary features, configuration, source data, or callbacks. On
success the function returns one plain finite base-R double probability in
`[0,1]`. On a controlled failure it returns an `rrp_authoring_failure` carrying
one existing provider failure code, including
`provider_input_unavailable` when a required private input is unavailable.

The unchanged request has exact class `c("rrp_risk_request", "list")` and is
one flat named list with these 19 fields in contractual order:

```text
request_contract_id              scalar character
request_contract_version         scalar character
request_id                       scalar character
target_id                        scalar character
target_version                   scalar character
state_contract_id                scalar character
state_contract_version           scalar character
state_id                         scalar character
bundle_instance_id               scalar character
project_id                       scalar character
project_version                  scalar character
episode_id                       scalar character
as_of_time                       scalar character, RFC 3339 UTC
discharge_time                   scalar character, RFC 3339 UTC
target_interval_start            scalar character, RFC 3339 UTC
target_interval_end              scalar character, RFC 3339 UTC
target_interval_boundary         scalar character, exactly (start,end]
elapsed_seconds_since_discharge  finite unclassed base-R double
remaining_seconds_through_w30    finite unclassed base-R double
```

`episode_id` is the canonical episode identity and the only canonical domain
identifier supplied. `as_of_time` is authoritative analytical time `t`;
`target_interval_start` equals `t`, and the request asks for remaining first-
readmission probability through the inclusive fixed day-30 endpoint. Before
invocation RRP has admitted the canonical bundle, established episode
eligibility and immutable state at `t`, selected and compatibility-checked the
provider, constructed deterministic request identity, and detached the plain
request.

The request deliberately omits canonical `patient_id` and
`index_encounter_id`, admission and terminal-event rows, the canonical bundle,
native/source identifiers, crosswalks, arbitrary predictors, project paths,
credentials, connections, callbacks, provider/model identity, prior
estimates, products, and history. The separately supplied `project_root` is the
hospital-owned context for resolving private model data; it is not inserted
into the provider-neutral raw request.

The hospital/model author remains responsible for:

- loading or invoking the project-owned model, score, package, or engine;
- resolving canonical `request$episode_id` to any local model-data identity;
- obtaining and engineering arbitrary private predictors without widening the
  RRP canonical model or request;
- ensuring every model-specific input is legitimate for
  `request$as_of_time` and never uses future information or redefines the
  cohort, target, or interval;
- returning the probability for the installed singular RRP target; and
- maintaining truthful provider implementation and optional model artifact
  identities/versions.

RRP governs the analytical question and cutoff. The hospital provider governs
the correctness and temporal validity of its private model inputs for that
cutoff. RRP does not understand or validate temporal provenance inside every
hospital field, query, API response, feature, or external score, and Stage 8
does not add a temporal-feature-validation framework.

Native hospital identifiers may serve as canonical identifiers only when they
legitimately satisfy the canonical contract and local privacy/governance
requirements. Otherwise the hospital assigns stable conforming canonical
identities and retains its own downstream resolution. The project is the
shared ownership boundary through which its producer and provider coordinate
that resolution. RRP does not add native IDs to the request, own or persist a
crosswalk, retain source IDs in state/history, add arbitrary predictors to the
canonical bundle, define a universal predictor schema, or become a feature
store merely for provider convenience.

RRP derives fixed semantic compatibility from installed target/runtime
authority, adapts the standard callable to the raw one-argument provider
callable, constructs the matching four-field provider result, and leaves
request construction, execution containment, output validation, and accepted-
estimate construction to the unchanged Stage 6 path. A standard project with
no distinct fitted model omits both model fields; the provider implementation
identity still identifies its calculation. A real fitted artifact supplies
both model fields. Stage 8 does not package, locate, digest, train, approve, or
monitor that artifact.

The raw provider escape hatch remains appropriate for unusual execution
protocols, service-backed adapters, advanced lifecycle management, or other
future conforming integrations that need direct result-envelope control. It
still registers through `R/register.R` and is subject to the same Stage 6
compatibility and execution semantics. No engine-specific branch enters RRP.

Ordinary authors must be able to learn the complete request and normal output
contract from the initialized project and installed product documentation,
without reading `rrpplatform`, `rrpruntime`, DCF internals, or tests. Generated
`R/calculate-risk.R` therefore contains a compact accurate comment block that
states the class, flat structure, exact fields/types, interval and identity
meaning, deliberate omissions, and success/failure alternatives, then points
by stable resource identity and runnable `rrp_resource_path()` example to the
complete installed provider-request reference. It is an orientation surface,
not a duplicate manual. Generated `R/produce-canonical.R` similarly describes
its explicit inputs and exact two-domain success return and points to the
installed authoring guide.

### Final role of `R/register.R`

The fixed trusted registration boundary remains unchanged because it provides
explicit executable composition, exact one-root loading, and fail-closed
selection without ambient discovery. In a normally initialized project,
however, `R/register.R` is generated thin stable wiring whose only binding is
`rrp_register_project(project_root)` and whose only responsibility is to call
`rrpplatform::rrp_register_authored_project(project_root)`.

Normal authors edit the two authoring callables and declarative metadata, not
the generated wiring. Project initialization creates every standard-authoring
file transactionally and makes the two customization points visible in the
generated README. Advanced authors may deliberately replace `R/register.R`
with a direct raw registration, but then own the full lower-level contract.
There is no upward search, directory scan, arbitrary executable DCF/YAML,
remote loading, naming heuristic, or implicit plugin discovery.

### Initialized-project representation and usability target

Stage 8 changes the normal output of `rrp_initialize_project()` from the
current two-file raw skeleton to the six-file standard-authoring scaffold
listed above. The manifest/registration contract remains `0.3.0`; the added
files are governed by the separate authoring contract and compile to that raw
line. Initial producer and provider functions return the existing controlled
`producer_unavailable` and `provider_unavailable` failures so initialization,
loading, and doctor remain honest and nonexecuting.

A new maintainer or adopter should need to understand four project-owned
surfaces for ordinary customization: the manifest selections/paths, the small
authoring metadata record, the producer mapping function, and the provider
risk function. Only the latter two contain hospital-specific executable logic.
The generated README explains this division, the trusted status of project
code, the extension library, the raw escape hatch, and how to resolve the
installed product documents through the explicit software-resource catalog.
It does not teach all raw envelope fields as the normal workflow or duplicate
the installed manuals.

Stage 8 implementation must record a bounded human inspection answering:

- how many generated files exist and which two normally require logic edits;
- which raw producer/provider fields the author no longer reproduces;
- whether the mapping is understandable from canonical authority without
  reading adapter internals;
- whether the risk function is understandable without reading provider
  protocol internals;
- whether any normal step still requires editing `R/register.R`; and
- whether the hospital/RRP identity, private-predictor, and temporal
  responsibility boundaries are visible from the initialized project alone;
  and
- whether a human can resolve the detailed installed documentation without
  repository or package-internal access.

If normal use still requires manual reproduction of most raw declarations or
envelopes, Increment 8.A is incomplete.

### Installed product documentation and teaching hierarchy

Stage 8 introduces product documentation as an installed, version-matched RRP
capability rather than assuming development documentation ships. The three
classes remain distinct:

- repository architecture, plan, record, implementation/contribution
  guidance, and assessments are development/maintainer documentation and are
  not assumed to ship;
- installed product documentation is cataloged hospital-user material usable
  without the development Git repository; and
- the generated project README and focused callable comments are project-local
  orientation that links to, but does not reproduce, the installed material.

Their teaching relationship is:

```text
generated project scaffold
        ↓ what do I edit and what reaches these callables?
installed product documentation
        ↓ what are the exact contracts, semantics, responsibilities,
          and supported behaviors?
fictional reference project
        ↓ show the same production architecture working end to end
```

The first installed set is exactly three concise single-source Markdown
resources:

1. **Project Authoring Guide:** the standard scaffold, trusted-code boundary,
   normal edit surfaces, producer/provider callables, canonical identity and
   source/mapping responsibilities, canonical-to-local provider resolution,
   private model inputs and analytical cutoff, extension dependencies,
   controlled failures, standard adapter, and raw-registration escape hatch;
2. **Provider Request Reference:** the unchanged request class, flat ordered
   19-field structure, R types and meanings, identities, timestamps, interval,
   pre-invocation guarantees, deliberate omissions, normal success/failure
   returns, private predictor/temporal responsibility, and relationship to the
   lower-level raw four-field provider result; and
3. **Fictional Reference Walkthrough:** the supported installed package-level
   path through fictional initialization, inspection, explicit source
   generation, mapping, validation, state initialization, durable execution,
   history inspection, repeat, and copy/reopen, including the fictional
   identity and provider-only predictor example.

`rrpplatform` owns access because it already owns the resource catalog,
project lifecycle, and authoring boundary. The existing resource machinery is
extended only to admit controlled Markdown beneath the governed `resources/`
source tree, declare each document in the closed source catalog, project bytes
unchanged into the installed catalog/tree, assign stable resource identities,
and resolve them through existing `rrp_resource_path()`. No documentation-
specific package API or duplicate `docs/user/` authority is planned.

Stage 8 begins an incremental installed product-documentation track. Later
stages add only material for capabilities then realized: logical products in
Stage 9, application use in Stage 10, installation/CLI/upgrade and ordinary
documentation discovery in Stage 11, deployment in Stage 12, clean-system/
adopter troubleshooting in Stage 13, and release-quality assembly/generated
publication formats in Stage 14. Exact later documents and formats remain
progressive decisions. User-facing product documentation is introduced and
versioned with the supported capability it explains rather than reconstructed
only at release time; later HTML/PDF/manual outputs derive from maintained
sources rather than unrelated duplicate prose. Stage 8 adds no documentation
site, PDF/publication pipeline, CLI browser, or later-stage manual.

### Fictional reference project and source generation

The supplied reference is realized as an ordinary independent project at a
caller-selected absent destination. Cataloged installed template assets and a
package-level `rrp_initialize_fictional_project(software_catalog,
project_root)` operation create it transactionally through the same safe,
create-only initialization machinery and validate it through the same loader.
The assets are visible teaching material, not registered installed components;
generic execution learns nothing about a fictional project ID. A copied
realization remains valid after the original is removed.

The project has the standard six-file layout plus these fictional-only source
surfaces:

```text
R/generate-source.R          explicit deterministic project-owned generator
source/generated/source.dcf  generated fictional-source provenance
source/generated/stays.csv   generated stay facts and bounded model input
source/generated/events.csv  generated local terminal-event notifications
source/generated/identity-crosswalk.csv
                             generated native-to-canonical identity mapping
```

Generated CSV files do not exist in the installed template and are never
authoritative source. The generator is called explicitly before RRP execution,
creates only the project-contained absent `source/generated` destination, and
fails rather than silently overwriting unknown content. A repeated invocation
with the same declared reference inputs must reproduce byte-identical tables
or validate the identical existing realization. Runtime does not generate
source implicitly.

The generator uses fixed literal scenarios, one fixed RFC 3339 reference
instant, and deterministic ordered output; randomness and therefore a seed are
unnecessary. `source.dcf` records the fictional generator ID/version, dataset
ID/version, fixed reference instant, nonclinical classification, exact table
names, and expected row counts. It is project-owned provenance used by source-
local validation and does not add a canonical or history field. The small
human-inspectable realization contains several discharge episodes with
eligible active cases, a prior available readmission, a prior available death,
and an exhausted day-30 horizon so durable history contains both accepted
estimates and governed ineligibility dispositions. Every identifier and label
is visibly prefixed as fictional, and the project README states that all data
and risk values are nonclinical simulation artifacts.

The generated source deliberately differs from canonical data. Native
stay/person identifiers are visibly fictional, and at least one source
identity is intentionally invalid under the canonical identifier grammar so
the example cannot imply that hospital IDs always equal RRP IDs. The small
explicit crosswalk maps native stay identity to valid canonical episode (and
related patient/encounter where needed) identities. It is project data—not an
installed RRP resource, canonical field, state/history table, or input known to
generic RRP code. A reversible string trick is insufficient because the
example must teach hospital-owned identity resolution.

`stays.csv` additionally carries one bounded, visibly fictional, nonclinical
provider-only predictor and its availability time. The producer joins native
keys through the crosswalk, constructs canonical episode/event IDs, translates
local terminal codes, normalizes timestamps, calculates the exact elapsed
day-30 endpoint, filters terminal facts by availability at the requested
as-of, and explicitly discards native keys, the crosswalk, and model-only
fields from its two returned canonical data frames. This is meaningful but
bounded source interpretation, not an EHR simulator or general feature table.

The fictional project's normal provider is project-owned. It receives the
unchanged request, resolves `request$episode_id` through the project-owned
crosswalk to the native fictional stay, retrieves the provider-only predictor,
requires its availability through `request$as_of_time`, and uses it in one
simple deterministic, inspectable, bounded, explicitly nonclinical probability
calculation. Missing or late predictor input exercises the existing
`provider_input_unavailable` authoring failure. The exact small formula and
fictional values are implementation choices protected by these invariants;
they need not reproduce the installed transparent timing-only relationship.

The callable returns only the governed probability through
`rrp_calculate_risk(project_root, request)`, declares a distinct fictional
provider implementation, and has no model artifact identity. The project does
not select the installed transparent provider for its main path, because doing
so would fail to prove normal provider authoring and private predictor
resolution. Separate regression evidence retains the installed provider and
direct raw project-provider paths.

The fictional project declares an empty extension-package inventory and uses
base R only. It does not add a ceremonial dependency. Standard-authoring tests
prove that declared package/version mismatches fail before callable invocation,
while inherited project-loader evidence continues to prove RRP-first library
ordering, permitted extension-package resolution, ambient-library exclusion,
and anti-shadowing. Package acquisition, dependency solving, source digests,
and `renv` remain outside Stage 8.

### Human-runnable package-level path

Before the Stage 11 CLI exists, the documented reference path uses only
supported package operations plus the explicit trusted fictional generator:

```text
open one explicit installed software-resource catalog
        ↓
resolve the three version-matched installed product documents
        ↓
initialize the supplied fictional project at an absent destination
        ↓
read its README, mapping, provider, manifest, and authoring metadata
        ↓
explicitly run the project-owned source generator
        ↓
inspect native identities, project crosswalk, and provider-only predictor
        ↓
validate the project and explicitly initialize project state
        ↓
run rrp_execute_durable_bundle() with declared t and operation key
        ↓
inspect scope and episode/current history through supported operations
        ↓
repeat the same key, reproduce producer/admission evidence, and prove no
episode/provider reexecution after the complete scope matches
```

The cataloged Fictional Reference Walkthrough supplies complete R calls and
always takes explicit software/project roots. The project-local README and
callable comments orient the local edits and point to stable installed
resource identities. None adds a CLI, infers a root from Git or the working
directory, sources repository operations, or exposes DuckDB/SQL as the human
history interface.

### Non-privilege and architecture tests

The fictional project is acceptable only if both architecture tests answer
yes:

1. replacing its source, mapping, identity resolution, predictor retrieval,
   and risk calculation with hospital implementations leaves the standard
   scaffold, adapter, raw contracts, canonical admission, risk execution, and
   durable-history machinery unchanged; and
2. replacing its thin registration with a direct raw registration can express
   equivalent producer/provider behavior through the already accepted lower-
   level contracts.

Evidence must additionally prove no fictional project/native ID, crosswalk
path, source filename/field/code, predictor name, calculation, or branch
appears in generic runtime/execution/history code; no installed component is
selected implicitly; standard and direct-raw fixtures reach the same existing
contract validators; the project runs after copying from installed resources
in an unrelated non-Git directory; and execution has no repository-root or
source-tree access. Only template acquisition/materialization is special.
Installed fictional templates cannot execute until realized as an explicit
project selected by the caller.

### Stable handoff to Stage 9

The accepted reference run leaves one initialized independent project's
ordinary Stage 7 store containing a complete deterministic fictional scope at
the declared reference `t`, accepted estimates for eligible cases, explicit
ineligibility dispositions for terminal/exhausted cases, provider/producer/
mapping attribution, membership evidence, and derived completeness. Stage 9
must consume it only through supported history operations or later product
interfaces; it may not depend on fictional source tables, mapping functions,
private DuckDB schema, storage order, project ID branches, or a checked-in
database. The generator plus documented operation reproduces the history;
generated source, database, backup, and product artifacts remain untracked.

### Increment 8.A — Supported standard project authoring boundary

**Implementation status:** complete. Its implementation and inherited
regressions are included in the exact committed Stage 8 hosted evidence and
formal acceptance recorded above.

**Objective:** add the smallest supported normal producer/provider authoring
capability and make it the discoverable default scaffold for newly initialized
independent projects while preserving every raw extension path.

**Scope and ownership:** add and catalog the
`rrp.project-authoring@0.1.0` authority under `rrpplatform`; implement closed
metadata, extension-package inventory, fixed-file/binding/signature checks,
safe isolated evaluation, authoring failure tokens, deterministic normal-path
bundle identity, and raw producer/provider adapters. Export
`rrp_register_authored_project()` and `rrp_authoring_failure()`. Replace the
installed initializer templates atomically with the six-file standard
scaffold, including exact provider-request and focused producer comments plus
README orientation/resource lookup. Admit controlled Markdown, catalog the
installed Project Authoring Guide and Provider Request Reference under
`rrpplatform`, retain create-only staging/promotion, and update loader/doctor/
ownership/catalog/validator/package documentation only for realized behavior.

**Interfaces/contracts changed:** one new authoring authority, the two
interfaces above, and the narrow resource-catalog format admission needed for
closed Markdown documentation; no change to the `0.3.0` manifest,
registration, producer, provider, canonical, runtime, or history contracts.
In particular, `rrp.risk-request@0.1.0` remains the exact flat 19-field Stage 6
request. The exact standard producer/provider file names, bindings, arguments,
success values, failure token, metadata, and dependency declaration are those
defined in this Stage 8 plan. `R/register.R` remains the sole trusted
registration entry point and compiles the standard layer into the raw result.

**Historical reuse:** adapt the current initializer's installed-template,
token-rendering, exact-inventory, staged validation, and atomic promotion;
reuse current safe-path, controlled-library, callable-containment, closed-
result, detachment, and bounded-diagnostic mechanics. Historical producer
adapter constructors inform envelope ownership, but repository-root
composition, installed producer registries, arbitrary producer configuration,
and YAML executable selection do not return.

**Evidence:** standard initialized inventory and generated guidance; exact
request class/fields/types/output alternatives visible from the scaffold;
focused producer return guidance; installed authoring/request documents
resolvable by stable identity outside Git; scaffold/document/contract
agreement; load and doctor without callable invocation; exact metadata and
dependency rules; producer domains adapted to the existing 15-field result and
16-field candidate; provider scalar/failure adapted to the existing four-field
result; deterministic content-sensitive bundle identity; controlled failures
and thrown-error containment; malformed, unsafe, extra-binding, wrong-
signature, linked/path-conflicting, missing-package, wrong-version, and RRP-
shadowing failure; positive declared temporary extension-package resolution
under the controlled library order; standard/raw semantic equivalence
fixtures; unchanged direct raw projects; existing installed transparent
provider; copied project; process restoration; builds, isolated install/load,
strict checks, and inherited regressions.

**Explicit exclusions:** no fictional source/project yet; no SQL, DBI, Parquet,
API, database, engine, or model-specific helper; no native-ID/crosswalk or
predictor persistence; no universal feature schema/store or temporal-feature
validator; no dependency installation or lockfile; no new target/canonical
domain; no execution/history change; no documentation-specific API/site/PDF/
publication framework; no CLI.

**Completion condition:** a new independent project visibly exposes two small
normal customization points, states the exact provider input/output contract
and hospital/RRP identity/predictor/time responsibilities, resolves the two
installed detailed documents without Git, and loads as the same raw producer/
provider registration, while advanced direct raw projects remain valid. No
Stage 8 reference data or durable history yet exists.

### Increment 8.B — Fictional project, meaningful mapping, and project provider

**Implementation status:** complete. Its exact-revision hosted evidence and
the complete Stage 8 hosted evidence are recorded; formal Stage 8 acceptance
is complete.

**Objective:** implement the deterministic fictional hospital as an ordinary
consumer of the completed 8.A authoring capability.

**Scope and ownership:** add cataloged installed fictional-project template
assets and `rrp_initialize_fictional_project()` under `rrpplatform`; implement
the project-owned create-only source generator, source-local checks, mapping,
explicit identity crosswalk, provider-only predictor and availability check,
standard provider callable, metadata, empty dependency declaration, teaching
README, and installed Fictional Reference Walkthrough. Keep fictional
vocabulary and behavior in those assets and their focused tests. Use the same
loader, producer admission, provider, and state boundaries as any project.

**Interfaces/contracts changed:** one package-level fictional-project
initializer and its cataloged template inventory; no generic synthetic
component, source contract, canonical/source-ID/predictor field, provider
contract, target, or history schema. The crosswalk and predictor remain
project data. The realized project uses the 8.A files and functions exactly.

**Historical reuse:** selectively adapt `v0.1.0` deterministic ID/table ideas,
explicit reference time, source/canonical vocabulary separation, joins,
terminal-code translation, occurrence/availability filtering, fictional
classification, scale summaries, and invariant-focused failure fixtures.
Reduce six tables and large seeded scales to two small literal fact tables plus
one explicit bounded identity crosswalk and the current two-domain profile.
Adapt transparent nonclinical calculation mechanics to one project-only,
time-aware fictional predictor under the current fixed-endpoint target.

**Evidence:** explicit byte-deterministic generation; create-only generated
path; visibly fictional values; understandable scale; source schema/key/time/
code failures before mapping; at least one native identity rejected by the
canonical grammar; explicit canonical-to-native crosswalk resolution;
meaningful fact-table translation and availability filtering; exact canonical
domains; no native ID/crosswalk/predictor leakage; provider retrieval of one
project-only predictor by `request$episode_id`, cutoff check against
`request$as_of_time`, deterministic probability, and controlled missing/late
input failure; installed walkthrough; empty extension package inventory;
copied project; no installed-provider bypass; no generic fictional identity/
crosswalk/source/predictor/calculation branch; and inherited 8.A/raw contract
tests.

**Explicit exclusions:** no realistic EHR simulator, large benchmark, real
data, credentials, connection convention, identity service, general feature
table/store, clinical model, generated database, durable reference run,
product, app, CLI, distribution, or deployment.

**Completion condition:** an independently realized fictional project can
explicitly generate meaningful local source, map noncanonical native identity,
reach admitted canonical data, resolve a provider-only predictor back from the
canonical request identity, and produce accepted project-provider estimates
through the standard layer. Its durable Stage 7 reference history is not yet
the accepted installed proof.

### Increment 8.C — Installed end-to-end reference proof and human runbook

**Implementation status:** complete. The exact committed implementation passed
hosted `package-foundation` run `36463026242`, job `109066072183`, and the
separate architecture reconciliation accepted Stage 8 on 2026-09-28.

**Objective:** prove the complete Stage 8 exit state from installed packages
and resources outside the repository and document the exact human package-
level path.

**Scope and ownership:** add the focused end-to-end installed proof, use the
cataloged Fictional Reference Walkthrough as the human runbook, perform bounded
human authoring/documentation inspection, update package/repository ownership
and validators, and make only the narrow corrections revealed by that proof.
Realize a fresh fictional project from installed templates, explicitly
generate source, validate and initialize it, run one complete durable scope,
inspect history, repeat idempotently, copy and rerun/reopen where applicable,
and retain no generated repository artifact.

**Interfaces/contracts changed:** none planned. A newly discovered need to
alter the 8.A authoring contract must be reconciled explicitly rather than
hidden in the proof. No general reference runner or CLI is added solely to
script the acceptance scenario.

**Historical reuse:** adapt only useful `v0.1.0` reference-scale expectations,
canonical failure cases, end-to-end reference tests, and human teaching
sequence. Reject repository-root operations, generated installed composition,
privileged reference commands, old daily-hazard history, products/app coupling,
and distribution-era wrappers.

**Evidence:** both authoritative local validators; resource/catalog closure;
all three Markdown documents resolve by stable identity outside Git and their
links/references agree with realized interfaces; generated README/callable
comments identify normal edits and installed references; package-native
authoring and fictional tests; source/package parsing; builds; dependency-order
isolated install/load; strict checks; unrelated non-Git installed execution;
no source-tree access; explicit source generation; project validation/state
initialization; canonical-ID to project-crosswalk to provider-only-predictor
execution; proof that private fields do not enter canonical/history structures;
eligible/ineligible outcomes; accepted fictional estimates; scope/
dispositions/completeness; raw/current history inspection; same-key
deterministic producer/admission reproduction with no episode/provider
reexecution after complete match; copied-project portability; dependency
isolation; raw escape-hatch regression; no privileged branch; generated-
artifact/hygiene checks; and successful hosted workflow evidence for the exact
committed Stage 8 implementation before formal acceptance.

The human inspection records project file count, ordinary edit surfaces,
removed protocol ceremony, `R/register.R` non-editing, exact request
discoverability, mapping/model readability, installed-document resolution, and
the visible hospital/RRP identity, predictor, temporal, and protocol boundary.

**Explicit exclusions:** no products or materialization, app dataset or Shiny
work, CLI, package installer, closed distribution, scheduling, deployment,
release, production governance, clinical validation, or performance/support
claim.

**Completion condition:** a human can follow supported package-level steps
against installed RRP to create, understand, generate, validate, initialize,
run, repeat, copy, and inspect the normal fictional project through complete
durable history; understand exactly what to edit and what the provider receives;
and access version-matched detailed product documentation with no repository or
privileged execution path. Formal Stage 8 acceptance and architecture
reconciliation follow as a separate lifecycle action, not Increment 8.D.

### Validation and hosted evidence

The existing maintainer operations remain:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
```

Validation grows only for the cataloged authoring/reference/documentation
assets, Markdown projection/access and link/reference consistency, standard
adapter and raw equivalence, updated initializer, deterministic fictional
identity/crosswalk/predictor path, package-native tests, installed non-Git
path, exact namespaces and dependencies, builds, isolated install/load, strict
checks, and repository hygiene. It must not become a separate Stage 8
framework or revive Phase suites.

The read-only Ubuntu/R 4.4 `package-foundation` workflow should continue to
invoke those same human operations. No CI behavior change is planned unless
the new installed proof reveals a real dependency/setup need. Formal Stage 8
acceptance requires a successful hosted run for the exact committed complete
Stage 8 implementation and records workflow/run/job/SHA/ref/event. That is
software evidence only, not clinical, production, dependency-reproduction, or
release evidence.

### Human-readable Stage 8 acceptance scenario

```text
build and isolate-install rrpruntime then rrpplatform with declared closure
        ↓
project the exact installed software-resource root
        ↓
resolve the Project Authoring Guide, Provider Request Reference, and
Fictional Reference Walkthrough without repository access
        ↓
initialize one normal project and inspect its standard authoring scaffold
        ↓
realize the supplied fictional project at an unrelated absent destination
        ↓
inspect its two hospital logic files and declarative metadata
        ↓
explicitly generate the small fictional source tables
        ↓
inspect noncanonical native identity, explicit project crosswalk, and the
provider-only time-aware predictor
        ↓
validate the project and initialize its absent state
        ↓
execute one durable bundle at the fixed fictional analytical time
        ↓
inspect complete scope plus accepted and ineligible episode dispositions
        ↓
repeat the same operation key, reproduce producer/admission evidence, and
perform no episode/provider reexecution after the complete scope matches
        ↓
copy/reopen the project and inspect the same supported history
        ↓
prove direct raw producer/provider projects remain valid
        ↓
STOP

No product or application
No implicit source generation or state initialization
No privileged fictional runtime branch
No RRP-owned crosswalk, predictor store, or documentation-specific API
No repository, Git, working-directory, or ambient-library dependence
```

### Stage 8 acceptance

Stage 8 is complete only when:

1. the installed authoring authority closes the standard metadata, files,
   bindings, signatures, return alternatives, dependency declaration, and raw
   adaptations without duplicating any existing semantic authority, while the
   installed documentation remains explanatory rather than a competing
   contract;
2. new normal projects receive the six-file discoverable scaffold, contain
   only two hospital-specific logic files, and need no manual raw registration
   or envelope construction; their comments and README expose the exact normal
   callable inputs/outputs, edit surfaces, and installed documentation lookup;
3. generated `R/register.R` remains the sole fixed trusted entry point, is thin
   stable wiring, is not normally edited, and performs no discovery;
4. standard producer authors own source access/interpretation and exact
   canonical-domain content, native-to-canonical assignment, and any local
   crosswalk while RRP owns canonical requirements, API/profile/capability
   identities, bundle/result construction, content-sensitive bundle identity,
   and admission handoff;
5. standard provider authors own canonical-to-local resolution, private
   predictor retrieval/engineering and cutoff validity, model/engine
   invocation, and one governed probability while RRP owns analytical time,
   target/runtime compatibility, request construction, raw result, execution
   containment, validation, and accepted-estimate construction;
6. implementation/mapping/provider identity and optional paired model identity
   remain explicit and truthful while every invariant contract identity is
   derived from installed authority;
7. standard declared failures map only to existing raw codes, arbitrary
   errors remain privacy-safe detected failures, and no source/model/private
   condition content enters diagnostics; missing/late private input uses the
   existing provider-input-unavailable behavior;
8. normal adapters return exactly the existing raw registration, producer,
   bundle, and provider structures and invoke the unchanged admission/runtime/
   history paths rather than parallel engines;
9. direct raw `0.3.0` producer/provider registration remains valid and covered
   as the advanced escape hatch, with no compatibility fork or forced
   migration;
10. fixed authoring files are resolved safely below one explicit project root,
    exact bindings/signatures are validated without callable invocation, and
    no scan, parent search, remote load, or executable configuration appears;
11. extension package/version declaration is closed and validated under the
    existing RRP-first controlled library policy without adding a package
    manager, solver, source lock, or artificial fictional dependency;
12. exactly three version-matched Markdown product documents are closed
    catalog resources, resolve through existing explicit resource access
    outside Git, and agree with the scaffold and installed semantic contracts;
13. the fictional project is independently realized from installed visible
    templates and is never an installed registered component or generic-code
    branch;
14. its explicit generator produces byte-deterministic, visibly fictional,
    nonclinical, human-inspectable source at one declared reference time and
    never runs implicitly during RRP execution; at least one native identity
    is unsuitable as a canonical identity and an explicit project-owned
    crosswalk supplies the valid resolution;
15. local source tables differ materially from canonical domains through
    names, relationships, codes, identifiers, timestamp representation, and a
    provider-only time-aware predictor; mapping performs real joins/
    translation/availability filtering and excludes private model data;
16. source-local invalidity fails before mapping, canonical invalidity remains
    RRP admission responsibility, and native IDs, crosswalks, model-only
    fields, and arbitrary predictors never cross the canonical boundary or
    enter generic state/history where prohibited;
17. the selected reference provider is project-owned, transparent,
    deterministic, nonclinical, has truthful implementation/null-model
    identity, resolves canonical request identity through the private
    crosswalk, checks one private predictor against `request$as_of_time`, uses
    it in the probability, and reaches the unchanged Stage 6 path without
    selecting or special-casing the installed provider;
18. the reference dataset produces stable eligible and distinct ineligible
    cases, accepted estimates, terminal dispositions, exact membership, and a
    derived-complete durable scope suitable for later Stage 9 proof;
19. the complete reference path and all three documents run/resolve from
    installed packages/resources in an unrelated non-Git location with
    explicit roots and no repository/source-tree access;
20. copied-project execution/reopen uses only the copied root, and no original
    path, working directory, Git state, or ambient user/site library is an
    operational dependency;
21. same-key repeat of complete history performs no episode/provider work,
    while ordinary raw/current inspection returns the accepted Stage 7
    evidence without direct DuckDB access;
22. package-native tests prove standard-to-raw equivalence, retained raw paths,
    deterministic generation/mapping/crosswalk/predictor/provider behavior,
    controlled failures, dependency isolation, documentation agreement, and
    architectural non-privilege without duplicating all Stage 5–7 adversarial
    suites;
23. the cataloged human path uses supported package operations, identifies the
    normal edit surfaces, completely documents the unchanged 19-field request,
    explains canonical/local identity and private predictor/time
    responsibilities, and requires no knowledge of package internals, every
    low-level protocol field, or any Stage 11 CLI;
24. repository/package validation, parsing, package-native tests, builds,
    isolated install/load, strict checks, installed proof, hygiene, and exact
    committed hosted evidence all pass with no retained generated source,
    project state, database, backup, product, archive, or check artifact;
25. bounded human inspection confirms that the standard layer materially
    removes protocol ceremony, the request is discoverable, the three teaching
    surfaces agree, and hospital meaning/data/time responsibility is clearly
    separated from RRP governance; and
26. no product/materialization, app, CLI, dependency installer/lockfile,
    scheduler, deployment, distribution, release, production-support,
    clinical-validation, feature/crosswalk service, documentation site/PDF/
    publication framework, or other Stage 9+ capability enters.

After implementation and exact committed hosted evidence pass, reconcile the
realized authoring/reference path with Platform True North and Platform
Architecture. Stage acceptance is a separate lifecycle action; no Increment
8.D is planned.

### Plain-language exit state

> A human can run a normal independent fictional project from source mapping
> through durable remaining-risk history and inspect the result, understand
> what to edit and exactly what the provider receives, see canonical identity
> resolved to private model data by project code, and use the corresponding
> version-matched installed product documentation without the development
> repository. RRP still has no logical products or application.

### Historical reuse disposition

Reconnaissance inspected immutable `v0.1.0`
`implementations/synthetic-reference/R/generate-source.R`,
`source-validation.R`, `map-to-canonical.R`, `producer.R`,
`canonical-producer-adapter.R`, `identity-configuration.R`, its source schema,
test/reference configurations, implementation/producer declarations and
README; `runtime/R/reference-provider.R`; Phase 3 synthetic producer tests;
and the Phase 10 independent-adopter producer fixture. Distribution-era local
producer/composition scaffolds were also inspected for the previous handoff
burden.

| Classification | Historical finding and Stage 8 disposition |
|---|---|
| Reuse substantially | Visibly fictional identities/classification; deterministic explicit source construction; fixed reference instant; separate source-local validation; meaningful source/canonical vocabulary; joins, explicit identity mapping, code translation, occurrence/availability filtering; canonical leakage tests; human-inspectable summaries; materially different adopter fixtures; transparent nonclinical calculation; invariant-focused failure cases. |
| Adapt concept/mechanic | Reduce the six-table seeded reference/test scales to two small literal fact tables plus one explicit identity crosswalk; map only the current discharge-episode and terminal-event profile; move all behavior into an ordinary initialized project; adapt producer results through the new standard layer; use the unchanged remaining-to-day-30 provider request with one project-owned time-aware fictional predictor; run through current durable bundle history. |
| Reject | Installed synthetic registration/defaults, generated reference composition, repository-root loading, `.GlobalEnv` composition, arbitrary YAML producer configuration, privileged reference commands, old baseline-risk/generic-event domains, daily-hazard estimands and provider formula, old run/history identities, product/application coupling, Phase aggregation, Hospital distribution wrappers, and source-tree runtime dependence. |
| Defer | Richer hospital source tooling, SQL/database helpers, remote/service/Flux adapters, fitted-model packaging and integrity, package acquisition/lockfiles, large scales/performance, products/app, CLI, distribution, deployment, production governance, and clinical validation. |

Historical material remains evidence only. No historical synthetic data,
configuration, generated composition, or privileged execution path becomes
current authority.

### Major deferrals and open questions

There is no unresolved architectural question that blocks review and
acceptance of this detailed plan. Implementation still must prove that the
chosen fixed files and two normal callables remove the observed ceremony; if
the bounded human inspection disproves that, the authoring contract must be
reconciled within Stage 8 rather than papered over.

Real hospital mappings, source-specific helpers, SQL/DBI conventions,
connection/credential management, richer EHR simulation, project package
acquisition and full reproducibility, model artifact packaging/digests/loading,
remote/non-R engines, training/evaluation/calibration/approval/monitoring,
universal predictor schemas, feature stores, RRP-owned source-ID registries or
crosswalks, arbitrary predictor persistence or temporal validation, performance
scale claims, automated operations, products/materialization, application,
CLI, documentation sites/PDF/publication pipelines, distribution, deployment,
release, clinical validation, and production governance remain absent. Future
source or engine conveniences may adapt into the standard callable boundaries;
they must not establish separate ingestion or provider architectures.

## Stage 9 — Logical products and materialization

**Status:** accepted and complete on 2026-10-02 at exact committed
implementation baseline `a13a181a09bf5b981b41030cf58e6f49225df7d4`.
Increments 9.A–9.C, exact-revision hosted evidence, and formal architecture
reconciliation are complete. Stage 10 has not begun.

### Objective and responsibilities

Build one narrow, versioned, all-or-nothing logical product set from governed
Stage 7 history: current accepted remaining risk, retained accepted remaining-
risk trajectory, and one effective operational-scope summary. Products are
consumer interfaces over attributable history, not analytical authority and
not aliases for the supplied physical format.

Stage 9 owns product contracts and conformance, deterministic logical identity,
storage-neutral construction, lineage, explicit valid-empty and unavailable
behavior, contextual freshness, one dependency-light materialization/access
adapter under project state, and a complete installed fictional proof. It does
not reinterpret hospital source, invoke a producer or provider, alter history,
or design the Stage 10 application.

### Why here and dependencies

Products are consumer interfaces over attributable history, not substitutes
for it. They follow the durable fictional path and precede any app so the UI
cannot become the accidental product contract.

Stages 6–8 now supply the actual upstream boundary: one singular remaining-
risk target; detached request and estimate records; append-oriented scope,
disposition, retry, invalidation, and restatement semantics; explicit project
state; public storage-neutral scope, episode, and current-history reads; and
one ordinary fictional project with complete durable history. Stage 9 must
project those facts and may not recover an earlier daily-hazard architecture.

### Governing product principles

1. Stage 7 logical history is analytical authority. A product is a validated,
   rebuildable consumer projection of an explicitly bounded history view.
2. Logical product meaning, product-set identity, physical materialization,
   and read access are distinct responsibilities.
3. Builders use only the `rrpruntime` history port and logical reads. They do
   not query DuckDB, know table names, inspect database files, or depend on an
   adapter transaction layout.
4. One build is anchored to one explicit effective complete operational scope,
   one analytical cutoff from that scope, and one explicit history cutoff.
   There is no implicit "latest database row" or ambient current scope.
5. All three required products succeed and conform as one coherent set, or no
   consumable logical set exists. Stage 9 has no partial logical product set.
6. Zero rows are valid where the contract permits them. Empty is never a
   synonym for failed or unavailable.
7. A physically intact historical product set may remain valid while becoming
   stale relative to explicitly supplied newer history expectations.
8. Materialized products are derived project state. They never mutate history,
   cannot repair it, and can be deleted and rebuilt without loss of analytical
   truth.
9. Consumers use validated logical access, not physical filenames or storage
   internals.
10. Product schemas expose the least consumer information needed. Native IDs,
    crosswalks, predictors, source paths, credentials, and source records stay
    private.

### Reconciled realized dependencies

Stage 9 inherits these accepted facts without reopening them:

- `rrp.history.operational-scope@0.1.0` defines one admitted bundle, exact
  membership evidence, analytical time, project/producer/mapping/bundle/target
  provenance, and derived completeness;
- `rrp.history.episode-disposition@0.1.0` retains ineligibility, accepted
  estimate, provider failure, retry, and restatement evidence with the
  immutable state/request/estimate that actually occurred;
- `rrp.history.action@0.1.0` overlays invalidation and restatement without
  deleting raw facts;
- `rrp_history_read_scope()` returns one raw scope, its dispositions/actions,
  and derived progress;
- `rrp_history_read_episode()` returns bounded immutable episode history at an
  explicit history cutoff;
- `rrp_history_read_current()` resolves one effective disposition from only
  complete, noninvalid scopes at explicit analytical and history cutoffs,
  follows retry/restatement leaves, and rejects unrelated same-time ambiguity;
- `rrpplatform` can obtain the same port from one explicit project root while
  the DuckDB schema remains private;
- project state is currently an exact two-file `rrp.project-state@0.1.0`
  realization, so placing derived products under it requires an explicit
  compatible contract evolution rather than an undeclared directory; and
- the Stage 7 backup artifact intentionally contains authoritative state/history
  only. Stage 9 may not silently make a derived product store part of that
  recovery guarantee.

### Settled Stage 9 scope decisions

| Question | Detailed-plan decision |
|---|---|
| What is a logical product? | One closed, versioned, detached data-frame projection constructed from governed history and validated independently of its builder or storage format. |
| What is the build population? | The unique admitted episode membership of one explicit effective complete source scope. |
| What is current? | Effective history for each source member at the source scope's analytical time and the caller's explicit history cutoff. |
| Is a complete scope required? | Yes. Incomplete, invalidated, ambiguous, unreadable, or unsupported source history is unavailable; it is not a partial product. |
| What enters trajectory? | Only effective accepted estimates that actually occurred at distinct governed analytical times through the source analytical cutoff. |
| What is summarized? | The effective outcome accounting for the one selected operational scope at the chosen history cutoff. |
| Are there three independent builds? | No. One build produces exactly three required members with one source snapshot and product-set identity. |
| Is partiality supported? | No. Analytical/provider failures remain truthful rows/counts upstream; interrupted physical writes are a materialization concern, not a partial logical set. |
| Does Stage 7 need a new read? | No. Explicit scope selection plus bounded logical reads and optimistic start/end equality are sufficient; no port or DuckDB interface change is proposed. |
| Where are products stored? | In a closed optional `products/` subdirectory under the manifest-owned project state root. |
| Are products backed up? | No. The supplied Stage 7 backup remains authoritative-history-only; products are rebuildable and restore leaves them absent. |
| Supplied format | Flat base-R DCF metadata plus three CSV member files; no new serialization dependency. |

### Logical product and set model

The logical layers are:

```text
governed Stage 7 history
        ↓
bounded source-history snapshot
        ↓
three logical product builders
        ↓
independent member conformance
        ↓
coherent product-set conformance
        ↓
optional DCF/CSV materialization
        ↓
validated storage-neutral access
```

A logical member is a detached list with exact class and fields for product
contract identity/version, deterministic product instance ID, product-set ID,
integer row count, and one exact ordered base-R data frame. It has no path,
connection, callable, adapter, or mutable reference. An unavailable member is
not serialized inside an apparently successful set; availability is expressed
by success or failure of the all-required set build, while zero rows remain a
valid available member.

The product set is a detached list containing its contract and builder
identity, deterministic set ID, project/state/target compatibility, source
scope identity, source analytical time, source history cutoff and fingerprint,
exact three member references, and the members. It is not a materialization
manifest and contains no file names, checksums, build-attempt identity, or
wall-clock build time. Equivalent source views therefore produce the same
logical object rather than merely the same nominal identity.

### Source selection, coherence, and storage-neutral reads

`rrp_build_product_set()` receives one explicit `operation_run_id` and one
explicit RFC 3339 UTC `history_cutoff`. The selected scope must exist, be
effective rather than invalidated or superseded at that cutoff, and be derived
complete. If a scope was restated, the original is unavailable and the caller
supplies the replacement operation identity explicitly; the builder does not
hide a source-selection decision.

The builder obtains source membership only from unique initial dispositions
whose count and membership fingerprint reproduce the selected scope. For every
member it reads bounded episode history and uses `rrp_history_read_current()`
at the source analytical time and at each distinct candidate analytical time.
It therefore inherits Stage 7 retry, correction, cutoff, and ambiguity rules
instead of recreating them.

Construction uses an optimistic storage-neutral snapshot:

1. read and validate the selected scope and all member episode/current values
   at the explicit cutoffs;
2. construct one canonical ordered source representation and deterministic
   source-history fingerprint;
3. derive and independently validate all product members and their set;
4. repeat the same bounded logical reads; and
5. succeed only when the second representation is identical to the first.

An append affecting the bounded source during construction produces
`product_source_changed` and no set. Records after the declared history cutoff
are outside that set. A later backdated correction may make the old set stale
when freshness is next evaluated, but cannot make the already built set lie
about the exact source fingerprint it used. This gives one coherent source
view without coupling product code to a DuckDB transaction or extending the
history port.

### Product 1 — current accepted remaining risk

**Identity:** `rrp.product.current-remaining-risk@0.1.0`.

**Consumer question:** for the selected complete scope, which admitted
episodes have one effective accepted remaining-risk estimate at that scope's
analytical time and the declared history cutoff?

**Grain:** at most one row per `episode_id` plus exact target identity/version.
The source population is the selected scope membership. Ineligible episodes
and effective provider failures have no row. They remain accounted for in the
scope-summary member.

"Current" means the result of the Stage 7 current-history resolver using:

- analytical cutoff = selected scope `analytical_time`; and
- history cutoff = the explicit build `history_cutoff`.

The builder includes a row only when that effective disposition is
`accepted_estimate`. It never searches backward for the last accepted
probability when the current effective disposition is a failure or
ineligibility. A successful retry or restatement is current only because Stage
7 resolves it as the effective leaf. A valid zero-row current product means no
scope member has an effective accepted estimate; it is not a build failure.

**Exact row fields:**

- `product_row_id`;
- `episode_id`;
- `target_id`, `target_version`;
- `analytical_time`;
- `estimate_value`, `estimate_record_id`;
- `analytical_run_id`, `source_operation_run_id`;
- `state_id`, `request_id`;
- `provider_id`, `provider_version`;
- `implementation_id`, `implementation_version`;
- paired nullable `model_id`, `model_version`; and
- `target_interval_start`, `target_interval_end`,
  `target_interval_boundary`.

Rows order by episode ID, target ID, and target version. The row identity is
deterministic from the member contract, product-set ID, episode ID, and target
identity. There is no patient, encounter, native, predictor, priority, action,
or category field.

### Product 2 — accepted remaining-risk trajectory

**Identity:** `rrp.product.remaining-risk-trajectory@0.1.0`.

**Consumer question:** what effective accepted remaining-risk estimates were
actually produced for each current-scope episode through the selected
analytical and history cutoffs?

**Grain:** one effective accepted analytical disposition per episode and
analytical time. The builder enumerates distinct analytical times present in
bounded raw history and asks the Stage 7 current resolver for each cutoff. It
deduplicates identical effective analytical-run identities that arise when a
later invalidated point falls back to an earlier valid point.

The member contains no daily hazard, interpolation, imputed day, survival
curve, retrospectively rerun provider result, or synthesized observation.
Irregular runs and multiple runs on one calendar day remain separate exact
timestamps. A one-point trajectory is valid; an episode with no effective
accepted estimate contributes no row; the entire product may validly have zero
rows.

Invalidated estimates are absent. An analytical restatement contributes only
the effective replacement. A successful explicit retry replaces its failed
parent at the same analytical time; an unsuccessful or invalidated retry does
not create an estimate point. Provider/model transitions remain attributed on
the rows on which they actually occurred.

**Exact row fields:** the current-product fields plus
`analytical_kind` and nullable `related_analytical_run_id`. Row identity is the
effective `analytical_run_id` under the member contract and set identity.
Ordering is episode ID, analytical time, then analytical-run ID.

### Product 3 — effective operational-scope summary

**Identity:** `rrp.product.operational-scope-summary@0.1.0`.

This name replaces the roadmap shorthand "terminal run summary" because the
realized Stage 7 unit is an operational scope whose episode dispositions
commit independently. The member summarizes one selected effective complete
scope at the build history cutoff; it is not a dashboard, business KPI, source
outcome rate, or mutable run-status record.

**Grain:** exactly one row for the selected operational scope, including a
zero-episode scope.

**Exact row fields:**

- `product_row_id`, `operation_run_id`, `scope_record_id`, `state_id`;
- `project_id`, `project_version`;
- `bundle_instance_id`, `canonical_profile_id`,
  `canonical_profile_version`;
- `producer_id`, `producer_version`, `producer_implementation_id`,
  `producer_implementation_version`, `mapping_id`, `mapping_version`;
- `target_id`, `target_version`, `analytical_time`, `scope_created_at`;
- `expected_episode_count`, `initial_disposition_count`,
  `effective_disposition_count`, `eligible_count`;
- `accepted_estimate_count`, `provider_incompatible_count`,
  `provider_declared_failure_count`, `detected_failure_count`;
- `ineligible_count`, plus counts for `episode_before_discharge`,
  `target_horizon_exhausted`, `episode_already_readmitted`, and
  `episode_already_dead`;
- `membership_fingerprint`; and
- `complete`, which must be true for a successful set.

Effective outcome counts use one Stage 7-resolved disposition per member at
the source analytical time/history cutoff and must sum to expected membership.
The initial count separately proves durable scope completeness. The summary
does not claim one singular provider identity because a scope can contain no
provider invocation or attributable retry/provider transitions; provider/model
identity remains exact on estimate products. Its row identity is deterministic
from the summary contract, product-set identity, and source scope identity.

### Product-set contract, identity, and versions

One installed `rrp.product-set.initial-readmission-risk@0.1.0` contract
requires exactly the three member contracts above and builder
`rrp.product-builder.initial-readmission-risk@0.1.0`. No member is optional.

The minimum installed semantic authority is four DCF resources: the three
member contracts and one set contract. A fifth DCF resource owns the supplied
materialization/access adapter and its physical format. Access behavior is
part of that adapter authority rather than a speculative separate plugin
contract.

The deterministic product-set ID is computed from a versioned length-delimited
encoding of:

- product-set contract and builder identities/versions;
- exact three member contract identities/versions;
- project ID and state ID;
- source operation-run and scope-record identities;
- source analytical time and history cutoff;
- target identity/version; and
- exact source-history fingerprint.

Paths, adapter/format identity, checksums, publication time, and Git revision
are excluded. Rebuilding the same logical source yields the same logical set
and the same set/member/row identities. Product instance IDs add the member
contract; row IDs add the contract row key. No separate product-build identity
or generation timestamp is needed; the physical current pointer records the
publication event.

Semantic product/set versions change when fields, requiredness, grain,
meaning, ordering, identity, build availability, or compatibility changes. The
materialization version changes for physical layout/encoding changes without
renaming unchanged logical semantics. Each physical publication has a
materialization ID derived from logical set ID, adapter/format version, and
exact physical member digests.

### Lineage model

Set-level lineage owns project/state, source scope/record, bundle, profile,
producer/mapping, target, analytical time, history cutoff, source fingerprint,
builder, and contracts. The scope-summary row exposes the bounded subset needed
to explain cohort construction and counts.

Estimate members expose row-level episode, analytical run, source operation,
state, request, estimate, provider implementation/model, target interval, and
probability attribution. They do not embed the complete disposition, request,
state, scope, or action records. Consumers can use retained IDs with supported
history operations when deeper investigation is authorized.

### Validity, freshness, staleness, and availability

These states are distinct:

- **valid** — contracts, row types/order/identity, set coherence, and any
  physical integrity/compatibility checks pass;
- **fresh** — a caller supplied an expected operation-run identity and current
  history cutoff, and the selected source plus recomputed fingerprint matches
  the materialized set;
- **stale** — the set remains valid and attributable, but the caller's explicit
  expected source scope differs or the governed source fingerprint has changed;
- **not evaluated** — no expected source context was supplied; RRP never
  invents a time threshold or discovers an ambient latest scope; and
- **unavailable** — governed source history cannot produce the required
  coherent set, so the build exposes no product collection.

A stale set remains readable with its truthful lineage and freshness result;
policy may refuse it later, but Stage 9 does not silently delete it or call it
invalid. Integrity, compatibility, or coherence failure exposes no access
object.

Freshness evaluation accepts expected operation-run identity and evaluation
history cutoff as a paired explicit input. Different expected scope means
stale. The same scope is reread at the evaluation cutoff and compared with the
stored source fingerprint; later retry, invalidation, or restatement affecting
that view means stale. A newly completed scope is recognized only when its
identity is explicitly supplied, preserving the no-discovery boundary.

### Empty, unavailable, and partial behavior

Valid empty semantics are exact:

- the current-risk member may have zero rows;
- the trajectory member may have zero rows;
- a completed zero-episode source scope yields two zero-row members and one
  zero-count scope-summary row; and
- provider failures can yield no estimate rows while the summary remains
  available and truthful.

Unavailable is a failed build with no product set, caused by absent/unreadable
state, missing scope, incomplete membership, invalidated/superseded source,
unsupported contract/version, ambiguous effective history, missing effective
member disposition, inconsistent start/end reads, or conformance failure.
Unavailable is never serialized as an apparently successful empty member.

Stage 9 deliberately chooses **no partial logical product sets**. Stage 7's
incomplete scope is truthful analytical partiality, but it is insufficient for
a consumer cohort and therefore unavailable to Stage 9. Provider failures are
complete governed dispositions, not partiality. A crashed materialization is
an unpublished physical staging failure; the preceding complete current set
remains visible.

### Invalidation, restatement, and provider retry

The source scope itself must be effective at the build history cutoff. Scope
invalidation makes it unavailable. Scope restatement requires the caller to
select the replacement explicitly. Existing product materializations are not
mutated; when evaluated against corrected history they become stale.

Analytical invalidation/restatement and retry are resolved only by Stage 7
current-history semantics. Current risk represents the single effective
disposition at the source time and includes it only when accepted. Trajectory
contains each distinct effective accepted point and omits invalidated parents.
A successful retry may create the effective estimate at the parent's analytical
time. Product code does not rank attempts, fall back to a prior accepted value,
or decide which correction wins.

### Materialization ownership and project-state evolution

Materialized products belong under the manifest-owned state root as optional,
derived, rebuildable state:

```text
state/
├── state.dcf
├── history.duckdb
└── products/
    ├── current.dcf
    └── sets/
        └── <materialization-id>/
            ├── product-set.dcf
            ├── current-remaining-risk.csv
            ├── remaining-risk-trajectory.csv
            └── operational-scope-summary.csv
```

Increment 9.B explicitly evolves `rrp.project-state` to `0.2.0`. The root
remains closed: the two required core files plus at most the fixed `products/`
directory, whose own authority closes every path beneath it. State
initialization still creates only the two authoritative history files; the
product directory appears only after successful materialization. This is the
smallest honest change because the accepted `0.1.0` state inventory prohibits
all directories.

The `rrp.project-state-backup` authority also advances to `0.2.0` to state
explicitly that the supplied checkpointed backup includes authoritative
history only and excludes derived products. Restore into absent state therefore
creates no product store. A restored project rebuilds products explicitly.
There is no silent Stage 7 backup expansion, product/history merge, or product
recovery claim.

The existing `rrp.adapter.duckdb-history@0.1.0` authority names the exact
supported project-state contract/version. It therefore advances to `0.2.0`
solely to declare compatibility with the evolved state contract; the DuckDB
tables, history payload representation, history-port behavior, transaction
semantics, and physical schema version remain unchanged. State, adapter, and
backup compatibility declarations move together. Development states created
under the old line are rejected rather than silently adopted or migrated.

Whole-project copying carries materialized products and must reopen them from
the copied root. Deleting only `state/products/` is safe and never touches
history. Materialization cannot write to `history.duckdb` or `state.dcf`.

### Supplied DCF/CSV materializer

One `rrp.product-materialization@0.1.0` authority owns supplied adapter
`rrp.materializer.dcf-csv@0.1.0`, physical format
`rrp.product-format.dcf-csv@0.1.0`, the fixed layout, nullable CSV encoding,
exact member names, methods, and validation categories. Flat product schemas
make base-R CSV sufficient; DCF owns closed metadata. This avoids adding YAML
or another runtime dependency merely for the first realization.

`product-set.dcf` records materialization/adapter/format identity, exact logical
set metadata, member contract/instance identity, row count, relative file,
byte size, and MD5 digest. `current.dcf` points to one immutable set directory,
repeats materialization/set identity and manifest size/digest, and records
publication time. MD5 is bounded accidental-corruption evidence, not
authenticity, security, or release integrity.

CSV fields use exact contract order and base-R types. Nullable paired model and
related-run fields use one explicit empty-string physical encoding and restore
to paired logical `NA_character_` values; required strings may never be empty.
Readers reject unknown columns, reordered columns, malformed quoting, wrong
types, noncanonical numbers/timestamps, duplicate keys, and row-order drift.

### Atomicity, replacement, and integrity

Materialization proceeds as:

```text
validate complete logical set
        ↓
write one owned same-filesystem staging directory
        ↓
write members and manifest with size/digest evidence
        ↓
reopen and validate staged realization
        ↓
atomically promote immutable set directory
        ↓
validate through staged current pointer
        ↓
atomically replace current pointer
        ↓
reopen current access
```

Consumers observe the previous complete set, the new complete set, or a
fail-closed unavailable pointer—never a falsely complete mixture. Pointer
replacement failure preserves or restores the previous valid pointer. The same
logical/physical content is idempotent; conflicting content at an existing
materialization identity fails. Prior immutable set directories remain until a
future explicit retention operation; Stage 9 adds no cleanup policy.

The materializer removes only its owned staging path on ordinary failure.
Recognizable nonlinked orphan staging directories are reported and may be
removed by the next materialization before writing; access ignores unpublished
staging while validating only the pointer-selected set. Unknown or linked
entries fail closed rather than becoming an unrestricted product store.

The immutable directory is named by materialization identity, not logical set
identity. Equivalent DCF/CSV bytes therefore reuse the same directory, while a
future compatible physical realization of the same logical set could have a
different materialization identity without changing product meaning. When the
same realization is already current, repeat publication returns its existing
evidence without rewriting a timestamped manifest or pointer.

Opening validates, in order:

1. state/product root safety and closed pointer/selected-set paths;
2. pointer and manifest parseability, inventory, sizes, and MD5 digests;
3. adapter/format/product contract compatibility;
4. each member's schema, types, order, row IDs, and row count;
5. exact three-member product-set identity and shared lineage; and
6. optional contextual freshness.

Integrity or compatibility failure yields privacy-safe structured diagnostics
and no access object. No physical digest enters logical product identity.

### Access adapter and future consumer boundary

The validated access object is detached and contains the opened set metadata,
the three validated logical members, and freshness facts; it exposes no path,
DB connection, mutable environment, or writer. The minimum consumer operations
are:

- list exact product identity/version, row count, set identity, source
  analytical/history times, and freshness status; and
- read one exact product identity/version from that set, returning a detached
  copy or metadata-only copy.

Stage 10 consumes these logical operations. It does not inspect DCF/CSV,
`current.dcf`, state layout, or DuckDB. A future physical adapter may construct
the same access object without changing product meaning or the application.

### Public package interface plan

All Stage 9 behavior belongs to `rrpplatform`; `rrpruntime` exports and history
contracts remain unchanged. Five new exports are proposed:

1. `rrp_build_product_set(software_catalog, project_root,
   operation_run_id, history_cutoff)` returns a common operation result whose
   success value is one detached conforming logical set. Existing interfaces
   cannot own product-specific schema or set coherence.
2. `rrp_materialize_product_set(software_catalog, project_root,
   product_set)` validates and publishes one complete set under project state,
   returning bounded set/materialization identity. It is separate from build
   so logical behavior remains independently testable.
3. `rrp_open_product_access(software_catalog, project_root,
   expected_operation_run_id = NULL, history_cutoff = NULL)` validates and
   opens the current materialization. Expected source inputs are both absent or
   both supplied; they evaluate freshness without ambient discovery.
4. `rrp_list_products(product_access)` is a pure detached inventory operation
   over an already validated access object.
5. `rrp_read_product(product_access, product_id, product_version,
   metadata_only = FALSE)` returns one detached exact member or its metadata.

Build, materialize, and open return the existing common structured operation
result and privacy-safe diagnostics. List/read are pure accessors that validate
the access object and raise one typed bounded product-access error on misuse.
No convenience aliases, generic registration API, custom builder/materializer
extension seam, direct store-path export, or product discovery API is added.

### Failure model

The contract families should keep a small bounded vocabulary:

- `product_source_unavailable` — state/scope/history cannot be read;
- `product_source_incomplete` — selected scope membership is not complete;
- `product_source_invalidated` — selected scope is not an effective source;
- `product_source_ambiguous` — Stage 7 cannot resolve unique effective history;
- `product_source_changed` — optimistic start/end logical reads differ;
- `product_incompatible` — contract/version/state/target mismatch;
- `product_conformance_failed` — a logical member or set violates its contract;
- `product_materialization_failed` — staging/promotion/publication failed;
- `product_integrity_failed` — physical inventory/size/digest/parse validation failed;
- `product_materialization_incompatible` — adapter/format/set version is unsupported; and
- `product_access_failed` — current pointer/set cannot be opened safely.

Valid empty is success. Stale and not-evaluated are freshness facts, not
failure codes. Diagnostics never include row content, source/native identity,
predictor values, paths, credentials, arbitrary conditions, or serialized
history.

### Privacy boundary

Consumer-facing products contain canonical `episode_id` only where their
purpose requires episode-level rows. `patient_id` and encounter ID are omitted
from the initial suite; grouping or display need is not yet evidence for wider
exposure. Native IDs, crosswalk values, private predictors and availability,
source event codes, source paths, credentials/connections, raw canonical rows,
and model artifacts are prohibited.

Set manifests and diagnostics are likewise bounded. Products may contain
provider/model identity and estimate lineage already accepted into history,
but never provider-private input. Static and dynamic fictional proofs search
logical objects and materialized bytes for known private markers.

### Fictional Stage 9 proof

The installed proof extends the accepted ordinary fictional project without a
product-specific branch or source change:

1. isolate-install packages and project exact resources outside Git;
2. initialize the normal fictional project, explicitly generate source, and
   initialize state;
3. execute complete scopes at two legitimate analytical times before the late
   fictional terminal notification is available, producing two actual
   accepted estimates for the same episode without interpolation;
4. select the later complete scope and build all three products;
5. verify one current estimate, the exact two-point trajectory, effective
   summary counts, lineage, ordering, and private-field exclusion;
6. materialize, close, reopen, list, and read all three through logical access;
7. repeat the same build/materialization idempotently;
8. copy the project/state to an unrelated non-Git root and reopen the same set;
9. execute a newer complete scope and prove the old set remains valid/readable
   but is stale only when evaluated against that explicit newer source;
10. build a completed zero-episode fictional scope at a pre-discharge cutoff
    and prove two empty members plus one zero-count summary row;
11. corrupt/incompatibly alter disposable copied materializations and prove
    integrity/compatibility failure with no access; and
12. prove no product/app/CLI code queries DuckDB or invokes project callables.

The test may use current fictional source at earlier/later cutoffs; it does not
change the fictional project merely to manufacture product behavior.

### Historical reuse disposition

Reconnaissance inspected immutable `v0.1.0` product contracts for current
episode risk, episode risk history, operational run summary, initial product
set, and materialization adapter; `products/R/` identity, conformance, builder,
and access code; the YAML adapter declaration/implementation/validation/access;
Phase 6 logical/materialized product tests; and the logical product and
reference materialization architecture documents.

| Classification | Stage 9 disposition |
|---|---|
| Reuse substantially | Three narrow roles; history as authority; independent product/set conformance; deterministic logical identity excluding path/time/digest; all-required coherent set; valid zero rows; no partial set; current selection delegated to history semantics; actual irregular trajectory points; provider/model attribution; list/read access; immutable bundles plus one current pointer; staged whole-set validation; distinct integrity/compatibility/coherence/freshness; old-valid-set readability without a universal stale threshold. |
| Adapt | Replace daily-hazard/estimand/run records with the singular remaining-risk target and Stage 7 scopes/dispositions; use one explicit complete source scope and its members; add retry/restatement semantics; replace repository source loading with installed DCF authorities; place output in explicit project state; replace YAML/nested references with flat DCF/CSV; use current RRP identity grammar/hash mechanics and common operation results. |
| Reject | Daily hazard, multi-estimand routing, old run-status families, reconstructed daily/weekly trajectories, automatic latest-run discovery, repository-root source chains, generated Hospital composition, direct DuckDB/table reads, product/app coupling, YAML as a required new dependency, Git/checksum logical identity, fixed build paths, partial successful core sets, priority/queue/decision fields, executive/readmission metrics, and synthetic-specific product branches. |
| Defer | Custom products/materializers, retention cleanup, remote/service/object storage, authentication, application view models, scheduler/refresh policy, distribution/artifacts, performance scale, clinical validation, and production governance. |

### Implementation sequence

Stage 9 is proposed as three dependency-ordered increments.

#### Increment 9.A — Logical product contracts and storage-neutral builders

**Status:** complete on 2026-09-30. Increment 9.B subsequently completed on
2026-10-01.

**Objective:** establish the four installed semantic authorities, exact three
logical schemas, deterministic source/set/member/row identity, independent
conformance, and one public builder over existing Stage 7 logical reads.

**Scope:** add product contract resources and `rrpplatform` internal loading,
snapshot/fingerprint, builders, validators, and `rrp_build_product_set()`.
Implement complete-source, current, trajectory, summary, lineage, empty,
unavailable, retry, invalidation/restatement, ambiguity, optimistic-coherence,
privacy, and detachment behavior. Update resource/package ownership and local
validators only for those realized files.

**Interfaces/contracts changed:** four new product resources and one
`rrpplatform` export. No canonical, target, request, estimate, history-port,
history-record, project, or physical state contract changes.

**Historical reuse:** reuse/adapt the identity, independent conformance,
all-required set, zero-row, history-delegation, and invariant-focused Phase 6
mechanics above; reject old analytical and repository shapes.

**Evidence:** exact authority/catalog closure; pure builder/conformance tests
with test-only in-memory history port; all three schemas and ordering; complete,
zero, incomplete, retry, invalidation, restatement, ambiguity, changing-read,
and privacy cases; equivalence through supplied DuckDB port; no DBI/DuckDB/source
vocabulary in builder code; parsing, build/install/load, strict checks, and
inherited regressions.

**Explicit exclusions:** no physical product directory, state/backup change,
materializer/access, fictional installed product proof, application, or CLI.

**Completion condition:** a caller can build or receive a structured bounded
failure for one exact coherent detached three-product set solely through
existing storage-neutral history behavior.

#### Increment 9.B — Project-state materialization and validated access

**Status:** complete on 2026-10-01. Increment 9.C subsequently completed its
local implementation evidence on 2026-10-01.

**Objective:** publish one complete logical set into a closed, replaceable
DCF/CSV realization under project state and reopen it through storage-neutral
access.

**Scope:** add the materialization authority; evolve project-state,
DuckDB-adapter compatibility, and backup authorities to `0.2.0` with a closed
optional product subroot and explicit backup exclusion; implement staging,
immutable bundle promotion, current-pointer replacement, exact inventory/size/
MD5/parse/contract/coherence validation, contextual freshness, reopen, list,
and read operations; and add the remaining four exports.

**Interfaces/contracts changed:** one new materialization authority; explicit
`0.2.0` project-state, DuckDB-adapter, and state-backup authorities; four
`rrpplatform` exports. Stage 7 logical history contracts, port behavior, and
DuckDB physical schema remain unchanged. Because 1.0 is unreleased and no
migration capability exists, tests recreate development state under the
coherent `0.2.0` authority line; no silent adoption or migration of `0.1.0`
state is claimed.

**Historical reuse:** substantially reuse staged immutable bundles, current
pointer, validation ordering, idempotent/conflicting publication, old-valid
readability, and logical access; adapt YAML/nested metadata into DCF/flat CSV
with current path safety and common diagnostics.

**Evidence:** absent/create-only product store, exact closed layout, successful
round trip, deterministic rebuild, replacement retaining prior valid set,
injected interruption at each boundary, prior-pointer preservation, orphan
staging behavior, corruption/incompatibility/coherence failures, copied-project
reopen, stale/not-evaluated/fresh results, product deletion without history
change, backup excluding products, restore with products absent and successful
rebuild, exact namespaces/dependencies, strict checks, and inherited state/
recovery regressions.

**Explicit exclusions:** no product backup, migration, automated retention,
custom/remote materializer, object storage, application, scheduler, CLI,
distribution, or deployment.

**Completion condition:** one complete set can be materialized, safely replaced,
closed, reopened, validated, listed, and read without exposing physical format
to consumers or weakening authoritative history.

#### Increment 9.C — Installed fictional product proof and human guidance

**Status:** complete on 2026-10-01. Exact revision
`a13a181a09bf5b981b41030cf58e6f49225df7d4` subsequently passed hosted
`package-foundation` run `36922905508`, job `110573063816`, and Stage 9 was
formally accepted on 2026-10-02.

**Objective:** prove the complete Stage 9 exit state from isolated installed
software and the ordinary fictional project.

**Scope:** add one cataloged version-matched Logical Products Guide, the
installed non-Git proof described above, validator/ownership integration, and
only corrections revealed by that proof. No new interface is planned.

**Historical reuse:** retain useful v0.1.0 human sequence and materialized
round-trip/corruption/irregular-time expectations; reject reference-operation
wrappers, repository roots, products/app coupling, and generated Hospital
paths.

**Evidence:** both authoritative validators; installed resource resolution;
two actual fictional estimates; exact three-member build; valid empty set;
lineage/privacy; materialize/reopen/access; idempotency/replacement/staleness;
copy portability; corrupt/incompatible denial; state backup/restore boundary;
no source-tree, Git, working-directory, ambient-library, physical-history, app,
or privileged fictional dependency; builds, isolated install/load, strict
checks, hygiene, and successful exact-revision hosted workflow before formal
Stage 9 acceptance.

**Explicit exclusions:** no Shiny/application data, CLI, distribution,
deployment, release, scheduling, performance/support claim, or clinical
validation.

**Completion condition:** a human can use installed package operations to
build, understand, materialize, reopen, inspect, compare freshness, delete/
rebuild, and recover the initial product set from ordinary fictional history,
including a valid empty realization, with no app or repository dependency.

### Validation and hosted evidence

The existing human operations remain authoritative:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
```

Validation grows only for cataloged product/state authorities, package-native
logical/materialization/access tests, installed fictional proof, exact exports
and dependencies, builds, isolated install/load, strict checks, path/privacy
hygiene, and the existing hosted Ubuntu/R 4.4 workflow. No parallel Stage 9
framework, Phase suite, direct SQL product test, or application test is added.

Formal Stage 9 acceptance completed on 2026-10-02 after all three increments,
human review, exact committed hosted run `36922905508` / job `110573063816`
for `a13a181a09bf5b981b41030cf58e6f49225df7d4`, and reconciliation with True
North and Platform Architecture.

### Stage 9 acceptance

Stage 9 is complete only when:

1. the exact three logical product contracts and one coherent set contract are
   installed, versioned, closed, and independent of physical representation;
2. one explicit effective complete operational scope and history cutoff define
   the build population and bounded source view;
3. builders use only the Stage 7 port/logical reads and contain no DuckDB, SQL,
   database path, source, producer, provider, or app behavior;
4. optimistic repeated reads reject changing source and a deterministic source
   fingerprint attributes the exact successful view;
5. current risk contains only the unique effective accepted disposition at the
   selected analytical/history cutoffs and never falls back independently to a
   prior accepted estimate;
6. trajectory contains only actual effective accepted estimates at governed
   analytical times, preserves provider/model transitions, and performs no
   interpolation, imputation, daily-hazard conversion, or replay;
7. scope summary has exactly one row whose effective outcome counts account
   for all admitted members and whose initial count/fingerprint prove complete
   source membership;
8. invalidation, restatement, and retry behavior is inherited from Stage 7;
   ambiguous or missing effective history fails closed;
9. all three members share exact project/state/source/target/set lineage and
   independent conformance catches malformed builder output;
10. set/member/row identities are deterministic and content-sensitive while
    publication time, path, format, and digest remain nonsemantic, and an
    equivalent rebuild produces the same logical set rather than a timestamp-
    varied object;
11. current and trajectory zero-row products plus one zero-count summary form
    a valid available set for a completed zero-episode scope;
12. incomplete or invalid source yields no consumable set, and no partial
    logical set exists;
13. valid, fresh, stale, not-evaluated, unavailable, invalid, and physical
    interruption states remain distinguishable;
14. stale but intact products remain readable with truthful lineage and no
    invented platform time threshold;
15. the coherent project-state, DuckDB-adapter, and state-backup `0.2.0`
    authority line remains closed while admitting only the controlled optional
    product store; the DuckDB physical schema is unchanged and materialization
    cannot alter authoritative state metadata or history;
16. the supplied DCF/CSV adapter stages and validates a complete set before
    publishing one current pointer, retains the prior set on failure, and
    rejects conflicting immutable identity;
17. exact inventory, sizes, MD5, parseability, adapter/format compatibility,
    member conformance, and set coherence are checked before access;
18. one validated access object lists and reads detached logical products with
    no physical filename or connection API;
19. state backup/restore remains history-only and explicit; restored products
    are absent and rebuildable, while ordinary whole-project copying reopens
    products from the copied root;
20. canonical episode ID is the only episode-level consumer identifier and no
    patient/encounter/native/crosswalk/predictor/source-path/private data leaks;
21. installed fictional evidence produces two actual trajectory points, one
    current risk row, exact summary counts, a valid empty set, idempotent
    materialization, stale comparison, copy/reopen, and corruption rejection;
22. the cataloged Logical Products Guide truthfully explains source selection,
    semantics, emptiness, freshness, state/backup, and access without implying
    an app, CLI, installation, clinical, or production claim;
23. package/repository validation, parsing, package-native tests, builds,
    isolated install/load, strict checks, installed proof, hygiene, and exact
    committed hosted evidence all pass; and
24. no application, Shiny work, custom product/materializer, direct physical-
    history query, scheduler, CLI, distribution, deployment, release, business
    KPI, decision queue, performance/support, clinical-validation, or Stage 10
    behavior enters.

### Plain-language exit state

> RRP can build, validate, materialize, close, reopen, and read one coherent
> three-product set from an explicit complete project-history scope, including
> valid empty risk/trajectory products, truthful effective outcome summary,
> contextual freshness, and rebuildable project-state storage. History remains
> authoritative and no supplied user application exists yet.

### Major deferrals and unresolved review decisions

Custom/user-defined products, product registries/plugins, arbitrary
materializers, direct physical-history access, application behavior, Shiny,
remote product services, object storage, automated retention/cleanup,
authentication, decision/priority queues, interventions, executive/readmission
metrics, dashboards, scheduling, CLI, installer/distribution, deployment,
release, production governance, performance claims, clinical validation, and
Stage 10 implementation remain excluded.

No unresolved architectural blocker remains inside the accepted plan. Its
acceptance confirmed two deliberate choices before 9.A began:

1. evolve project-state, DuckDB-adapter compatibility, and backup authorities
   to a coherent `0.2.0` line so a closed optional rebuildable product subroot
   is allowed but remains outside supplied backup; and
2. use one dependency-light flat DCF/CSV adapter instead of restoring the
   historical YAML dependency and nested representation.

That initial acceptance authorized only Increment 9.A. Increments 9.B and 9.C
were later authorized explicitly and completed. Formal reconciliation found
no implementation deviation, corrected only durable architecture/status
documentation, and accepted Stage 9 on 2026-10-02. Stage 10 remains not begun
and requires separate detailed planning and authorization.

## Stage 10 — Supplied product-only application

**Planning status:** detailed and internally reconciled on 2026-10-02 from the
accepted Stage 9 baseline, revised on 2026-10-02 to establish the initial
Shiny, bslib, and Plotly UI foundation, and revised again on 2026-10-04 for
Reactable, standard `_brand.yml`, and bounded installed frontend assets.
Implementation has not begun. The increments below are separately
authorizable, beginning with 10.A.

### Objective and exit state

Implement one generic RRP-supplied Shiny application inside installed RRP
software. It consumes only one validated detached Stage 9 product-access
snapshot, transforms that snapshot through a presentation-only view-model
layer, and presents a useful current risk pool, actual episode trajectory, and
scope overview. Establish the narrow programmatic launch operation that later
operator interfaces can wrap, while keeping launch analytically read-only.

The fictional project is the controlled acceptance environment; it neither
owns nor defines the application. The same installed application must work for
any conforming project whose current product set satisfies the accepted
contracts.

Stage 10 deliberately keeps the application small in workflows, views,
analytical concepts, customization, and operational responsibility. That
limited product surface does not justify a technical demonstration or default-
widget experience: within the accepted scope, information hierarchy,
responsive layout, typography, spacing, cards, controls, states, tables, and
interactive graphics must form one intentionally polished modern analytical
product. This quality intent permits bounded RRP-owned installed CSS and, only
when a concrete selected-component interaction requires it, JavaScript. It
does not authorize a broad design system, JavaScript application, animation
framework, or general theming engine.

> The supplied application presents the validated remaining-risk products of
> an RRP project without querying hospital sources, executing risk providers,
> building products, or reading physical history. The fictional reference
> project proves the same installed application through the same product-only
> interface available to any conforming RRP project. Complete installed
> operator and deployment workflows still do not exist.

### Why here and governing boundary

Stage 9 now provides the stable consumer boundary needed to keep the
application out of analytical execution:

```text
hospital-owned source / producer / provider
                    ↓
             governed history
                    ↓
       coherent logical product set
                    ↓
        validated detached access
                    ↓
       supplied installed application
```

The app begins with validated logical access. It has no source, canonical,
admission, eligibility, provider, history-port, DuckDB, materialization-format,
or product-builder knowledge. Application startup never runs a producer,
provider, retry, correction, product build, publication, source selection, or
refresh. Product evaluation/materialization and app launch remain separate
explicit actions.

The application follows products because UI requirements cannot redefine
their meaning. It precedes distribution and artifact work so Stages 11 and 12
can wrap a real stable application instead of inventing its lifecycle.

### Settled planning decisions

| Question | Detailed-plan decision |
|---|---|
| 1. Installed source owner | `rrpplatform` owns executable application, view-model, startup, and launch code as ordinary installed package R code. No separate package, repository, or project app tree is introduced. |
| 2. Application identity | Add one installed `rrp.application.supplied@0.1.0` DCF authority because startup, later artifacts, and compatibility need a stable app identity. It governs required product contracts, the Shiny/bslib/Plotly/Reactable component foundation, RRP-owned installed presentation assets, brand-interpretation authority, and read-only posture; the installed implementation remains attributable to the `rrpplatform` package version. |
| 3. Programmatic launch | Export exactly one new operation, `rrp_launch_app()`, with the signature settled below. No CLI is added. |
| 4. Pre-Shiny validation | Revalidate software authority, project, optional standard branding and contained assets, current materialization/access, exact product inventory/versions, coherent set, and direct app dependencies before starting Shiny. |
| 5. Launch input | The public operation receives an explicit software catalog and project root, plus an optional paired expected operation-run/history-cutoff freshness context. It does not accept arbitrary product frames or physical paths. |
| 6. App data input | Platform startup opens validated access once and injects only a detached closed application model into the app constructor. UI/server code receives neither project root nor software catalog. |
| 7. View-model boundary | Pure package functions read the three logical members and perform only ordering, formatting, paging, direct descriptive aggregation, selection, and deterministic table-, sparkline-, chart-, and tooltip-ready shaping. They do not alter product meaning. Standard branding is separately adapted into a closed detached presentation model before component rendering. |
| 8. Initial views | Two top-level views: **Current Risk Pool** and **Overview**. Episode detail and trajectory appear from selection within Current Risk Pool rather than as a third global area. |
| 9. Episode selection | Search/filter/sort a bounded current-risk table and provide one synchronized selector over the union of current and retained-trajectory canonical episode IDs, with current episodes first. This keeps historical-only trajectories discoverable without introducing a patient/native identifier. |
| 10. Plotting technology | Use Plotly as the presentation-only interactive graphics renderer. Episode trajectory points and deliberately formatted tooltips correspond only to actual governed observations. A restrained connector may show observation order but is explicitly non-interpolating; Plotly never receives project, access, history, or analytical infrastructure. |
| 11. Table technology | Use Reactable as the RRP-owned interactive operational-table foundation for Current Risk Pool, with deliberate cell/control styling, deterministic search/filter/sort/paging/selection, and actual-observation sparklines. Do not add DT or expose arbitrary project table schemas/renderers. |
| 12. Descriptive summaries and risk encoding | Direct count, minimum, maximum, median, quartiles, and distribution of accepted current estimates; scope membership and accepted/failure/ineligibility counts; and the existing ineligibility subcounts. A direct monotonic continuous visual encoding of accepted probability is permitted when exact numeric probability remains visible and color is not the sole signal. No threshold, bin, named risk category, priority, recommendation, or inferred outcome is allowed. |
| 13. Product states | Valid empty is a normal polished app state; absent, corrupt, or incompatible products fail before Shiny; stale remains readable with a prominent warning; not-evaluated is shown neutrally and never called fresh. |
| 14. Stale launch | Yes. A valid stale set launches normally with its original lineage and a persistent stale status treatment. It is never auto-refreshed. |
| 15. Branding input | Use one optional standard project-root `_brand.yml`; do not retain `rrp-presentation.dcf` or define an RRP-specific branding syntax. RRP consumes it through appropriate existing Posit branding tooling identified during 10.A reconnaissance. |
| 16. Brand interpretation | Add `rrp.project-brand@0.1.0` to govern RRP's supported interpretation, defaults, containment, closed-model conversion, and failure policy—not the external `_brand.yml` schema. Valid unsupported concepts are ignored; malformed branding fails startup. |
| 17. Initial supported concepts | Resolve the actual standard fields/API in 10.A, then interpret only organization/display identity where the standard supplies a suitable concept, primary brand color, and one bounded project-local logo suitable for app identity/header treatment. Do not invent an RRP field when the standard differs. |
| 18. Default composition | Absence returns immutable RRP defaults. Supported standard concepts overlay only their bounded presentation roles. Branding cannot alter analytical meaning, filtering, product content, freshness, runtime, or behavior. |
| 19. Logo and assets | Support one standard `_brand.yml` logo role when a suitable upstream representation exists. The asset must be safely contained in the project; absolute paths and remote runtime dependencies are rejected. Exact project-local containment and initializer inventory are settled in 10.A from actual upstream semantics. |
| 20. Project-contract effect | The manifest/project API and six authoring paths remain `0.3.0`/`0.1.0`. `_brand.yml` and a contained logo asset where used are optional, declarative, and governed by the independent RRP interpretation authority. Standard and fictional initializers make the supported input discoverable; exact new inventories follow 10.A reconnaissance rather than a speculative file count. Existing/direct-raw projects without branding remain valid. |
| 21. Product compatibility | The app authority requires the exact initial product-set and all three member contracts at `0.1.0`; startup verifies exact inventory and versions through public logical access. Unsupported evolution fails closed until a new app contract supports it. |
| 22. Repository-independent tests | Build and install packages/resources into temporary roots, initialize/copy an ordinary project outside Git, and construct the app only through installed code and validated access. |
| 23. Application evidence | Pure table/sparkline/chart/tooltip view-model tests, Reactable and Plotly widget/data inspection, UI/tag structure checks, `shiny::testServer()` interaction tests, installed-asset and standard-branding proof, and one supervised child-process loopback launch/termination smoke test. Qualitative polish receives bounded human review; no pixel-perfect browser or rendered-output snapshots are required. |
| 24. Acceptance | All three increments, installed generic/reference proof, exact state handling, analytical nonmutation, package checks, and exact committed hosted evidence pass, followed by separate formal Stage 10 reconciliation. |
| 25. Later-stage boundary | Stage 11 owns CLI/distribution/install/upgrade; Stage 12 owns frozen product-only artifacts and target realizations. Stage 10 adds neither. |

### Ownership and installed-application model

`rrpplatform` remains the main installed owner because it already owns
validated product access and human-facing project operations. `rrpruntime`
must not import Shiny or acquire application behavior. A new application
package would add distribution and dependency boundaries without providing an
independent extension or lifecycle, so it is rejected.

The intended source ownership is package R modules for application contracts,
startup, view models, components, and launch, plus bounded application-owned
web assets installed with `rrpplatform`. RRP may ship CSS needed to integrate
the bslib shell, Reactable table, Plotly graphics, branding, and application
states into one visual language. JavaScript is permitted only when a concrete
interaction cannot reasonably be realized through the selected R/Shiny
component stack. These assets are RRP implementation, never hospital-owned
executable customization. They are never sourced from the development
repository or copied into a project. The application and brand-interpretation
authorities, branding templates/assets, RRP web assets, and final human guide
remain cataloged installed software resources under their existing owners.

```text
installed RRP software
├── rrpruntime                       no app dependency
├── rrpplatform
│   ├── validated product access
│   ├── app startup + view models
│   ├── supplied Shiny/bslib UI/server
│   ├── Reactable + Plotly components
│   ├── installed RRP CSS + justified JS
│   └── programmatic launcher
└── installed authorities/docs/templates

independent project
├── existing authoring/registration files
├── optional _brand.yml            declarative branding only
├── optional contained logo asset  bounded branding input
└── state/products                  validated input, not app source
```

Project copying changes neither application source nor identity. An RRP
software upgrade can replace the supplied application without rewriting a
project. Hospital projects may provide standard `_brand.yml` and its accepted
contained logo, but no arbitrary CSS, JavaScript, HTML, Shiny modules,
component configuration, Plotly configuration, Reactable renderers, or other
executable UI hooks. Stage 10 does not establish custom app source or arbitrary
hospital UI execution as an extension boundary.

### Application and brand-interpretation authorities

Add cataloged `rrp.application.supplied@0.1.0`. Its closed DCF record names the
application owner/UI foundation, required
`rrp.product-set.initial-readmission-risk@0.1.0`, the exact three product
members at `0.1.0`, the Shiny/bslib/Plotly/Reactable component foundation,
`rrp.project-brand@0.1.0`, RRP-owned installed web assets where required, and
the requirements for validated detached access and analytical read-only
startup. It does not duplicate product fields, reproduce the external branding
schema, encode CSS selectors or component styling constants, freeze package
versions, prescribe the sparkline renderer, or become an artifact/deployment
manifest.

Add cataloged `rrp.project-brand@0.1.0`. It governs RRP's interpretation of an
optional standard project-root `_brand.yml`, not the standard branding
specification itself. It defines:

- the exact project-local discovery location;
- use of appropriate existing Posit branding parsing/validation tooling rather
  than a parallel YAML parser or RRP-owned branding schema;
- the small RRP 1.0 supported concept set and immutable defaults;
- conversion into a closed detached RRP presentation model;
- project-local logo containment and validation;
- safe failure for malformed branding and ignoring valid unsupported concepts;
  and
- the prohibition on branding changing analytical or application behavior.

Increment 10.A reconnaissance must confirm the actual upstream package/API and
standard field names before implementation. The intended initial concepts are
organization/display identity or the closest suitable standard metadata,
primary brand color, and one standard logo role suitable for the app header.
If no suitable standard display-identity concept exists, RRP documents the
actual supported mechanism rather than inventing a proprietary field. A logo
must resolve within the project under explicit safe containment rules; remote
runtime assets and absolute filesystem paths are not accepted. The exact
contained project location and initializer inventory follow that
reconnaissance rather than this plan guessing the external schema.

Absent `_brand.yml` produces the RRP product name, accessible default theme,
and default identity treatment. A richer valid standard file may contain
concepts RRP does not yet interpret; those concepts do not expand behavior and
do not fail merely for being unsupported. Malformed branding or an invalid/
unsafe supported value fails before app construction. Supported branding may
influence identity, primary accent, logo, bslib theme composition, and bounded
Reactable/Plotly/RRP-CSS styling. It never controls target meaning,
eligibility, probability semantics, thresholds, filters, hidden rows,
products, provider/source selection, calculations, freshness, refresh, or
runtime behavior.

Brand color and analytical probability encoding remain distinct. RRP may
harmonize them visually, but a project's primary color never defines the
direction or meaning of the probability scale. Exact probability remains text,
and freshness, failure, selection, and risk remain understandable without
color alone.

Adding optional standard branding changes initializer inventory and cataloged
template/asset evidence only. It does not change `rrp.project@0.3.0`,
`rrp.project-api@0.3.0`, registration, or
`rrp.project-authoring@0.1.0`'s six executable/documentation paths. Broad
typography, secondary/tertiary palettes, component-specific color settings,
custom text/navigation/layout, hospital CSS/HTML/JavaScript, and executable UI
modules remain excluded from version `0.1.0`.

### Programmatic launch and startup

The one new public operation is:

```r
rrp_launch_app(
  software_catalog,
  project_root,
  expected_operation_run_id = NULL,
  history_cutoff = NULL,
  launch_browser = interactive(),
  port = NULL
)
```

`expected_operation_run_id` and `history_cutoff` retain the existing all-or-
nothing pairing. Their absence produces `not-evaluated`; their presence
delegates unchanged contextual freshness to `rrp_open_product_access()`.
`launch_browser` is one scalar logical. `port` is absent or a validated local
nonprivileged integer. Stage 10 binds the development/reference server to
loopback; public host/network exposure is not configurable here.

Startup performs this sequence before `shiny::runApp()`:

```text
validate installed app/product/brand-interpretation authority and assets
        ↓
validate explicit project and optional standard branding/contained logo
        ↓
open current products through rrp_open_product_access()
        ↓
verify exact app-required inventory and compatibility
        ↓
read three detached products through rrp_read_product()
        ↓
construct and validate one closed application model
        ↓
construct supplied shiny.appobj
        ↓
run locally on loopback
```

Expected failures return the common operation result with one bounded,
privacy-safe application diagnostic and start no server. The operation returns
success only after a successfully started app session exits normally. A
missing direct dependency is detected before startup. Unexpected package
defects remain visible under existing diagnostic policy.

The internal constructor accepts only the closed application model, including
separate detached analytical and presentation parts. It has no catalog, root,
path, DBI handle, product writer, or project callable. Products are read once
at startup into a detached snapshot; supported branding is parsed and reduced
to the closed presentation model before construction. Shiny reactivity changes
selection and presentation only. Re-launch is the explicit way to pick up a
new current materialization or project-local branding change.

Launching may execute the already accepted trusted project-registration load
inside platform access, but it invokes no producer or provider. Tests prove
that RRP-managed history, product bytes, pointer, state metadata, and source
remain unchanged before and after startup and supervised shutdown. This is the
precise analytical read-only claim; arbitrary trusted project registration is
not misrepresented as a security sandbox.

### View-model architecture

The application boundary is:

```text
rrp_product_access              supported project branding
        ↓ exact logical reads             ↓
closed detached product snapshot   closed detached presentation model
                 ↓                              ↓
          pure presentation transforms and composition
                 ↓
current-pool / episode / overview view models
                 ↓ table/sparkline/chart/tooltip-ready data
Reactable + Plotly inside bslib, RRP assets, and Shiny selection state
```

Product access owns integrity, compatibility, coherence, detachment, and
freshness. View models own deterministic display ordering, bounded paging,
string search over canonical episode identity, exact provider/model filters,
probability/time formatting, direct descriptive summaries, table-ready rows,
actual-observation sparkline data, chart-ready rows, deliberately formatted
tooltip-ready values, optional deterministic continuous probability encoding,
the union of current and retained-trajectory episode choices, and selected-
episode state. UI/server owns controls, reactive selection, rendering, and
status communication. Reactable and Plotly receive only detached presentation
data and remain replaceable without changing analytical or product contracts.

The view-model layer may derive elapsed/remaining follow-up context only from
the supplied analytical and target-interval timestamps and must label the
derivation. It may compute ordinary descriptive statistics directly from
accepted estimate values. It may not select another scope, substitute a prior
estimate, infer missing points, classify risk, decide priority, join private
data, reinterpret failure, or call an analytical operation.

### Initial application experiences

#### Current Risk Pool

This is the landing view. It answers: **Who currently has the highest accepted
remaining readmission risk?**

Reactable presents current rows in descending `estimate_value`, with stable
canonical episode tie-breaking. It displays canonical episode ID, exact
formatted probability, analytical as-of time, target endpoint/follow-up
context, provider/model attribution where present, and one compact truthful
trajectory sparkline. It includes episode-ID search, exact provider/model
filtering when meaningful, explicit sorting, bounded paging/window behavior,
displayed/total counts, row selection, and a synchronized episode selector.
The selector includes retained-trajectory episodes that have no current
estimate, labels their noncurrent state, and lists current episodes first.
Sorting is presentation only and is labeled as neither priority nor a clinical
recommendation.

Each sparkline contains only that episode's actual governed trajectory
observations in their real order. It never synthesizes daily values,
interpolates analytical estimates, invents a discharge baseline, carries a
prior value forward, replays a provider, or implies continuous monitoring. One
actual observation is a valid intentional one-point sparkline; no observation
produces an explicit unavailable/no-history state. The sparkline is a scanning
aid, not another product or a replacement for the full Plotly detail. Its exact
renderer is an implementation choice within the accepted stack; Stage 10 adds
no dependency solely for sparklines without demonstrated need.

The exact numeric probability always remains visible. A cell may additionally
use a deterministic continuous intensity, bar, accent, or comparable encoding
that maps directly and monotonically from the accepted probability. It may not
introduce a cutoff, bin, named class, recommendation, or sole color-only signal,
and the hospital brand color does not define its semantic scale.

This is a deliberately styled RRP operational experience, not a generic data-
grid framework. Density, headers, typography, alignment, numeric formatting,
selection/hover, risk emphasis, sparkline sizing, pagination, responsiveness,
empty states, provider/model display, and bslib-card integration must form the
same visual language as the Plotly detail. DT, arbitrary hospital table
schemas, and project-defined cell renderers are excluded.

Selecting an episode opens an adjacent/detail region without another product
read. That region supplies exact current lineage and the trajectory experience
below. The UI does not invent patient names, encounter IDs, local IDs,
diagnoses, services, units, or other hospital-private fields absent from the
contract.

A zero-row current product shows a polished **No current accepted risk
estimates** state with scope time, freshness, and a statement that empty is
valid—not a blank table or error.

#### Episode Risk Trajectory

The detail answers: **How has this episode's accepted remaining readmission
risk changed across actual governed evaluations?** It filters only the already
loaded `rrp.product.remaining-risk-trajectory@0.1.0` member by the selected
canonical episode.

Plotly renders large visible interactive markers only at actual
`analytical_time` observations on a fixed probability scale. Deliberately
configured tooltips may show the presentation-ready analytical time, derived
elapsed follow-up context, probability, provider/implementation/model identity
where present, analytical kind, and target interval already available through
the accepted product/application model. They must be concise and formatted for
RRP rather than dump raw Plotly fields. A compact exact-observation table
accompanies the chart. A restrained connector may communicate observation
order, but its caption must state that the line is not an estimate between
points. Hover applies to actual markers rather than synthesized points, and no
interpolated value is exposed through tooltip or table.

The renderer must intentionally control typography, margins, percentage and
axis formatting, grid prominence, markers and hover states, connector and
legend behavior, whitespace, responsiveness, modebar behavior, and integration
with its surrounding `bslib` card/theme. State remains understandable without
color alone. Exact style values are implementation details, and the optional
project primary color cannot become arbitrary Plotly configuration.

One observation renders one marker and an explicit single-observation note.
No matching history renders an unavailable detail state without changing the
current pool. The app never invents discharge-time baseline risk, reconstructs
daily values, carries a prior value forward, replays a provider, or implies
continuous monitoring.

#### Overview

The second top-level view answers: **What does the current accepted risk pool
look like, and what happened in its selected source scope?**

From current risk it shows the accepted-current count, minimum, maximum,
median, quartiles, and may use Plotly for a neutral remaining-risk distribution
when that materially improves comprehension. It presents no high/medium/low
category or threshold. From the exact one-row
operational summary it shows expected/effective membership, accepted estimate,
provider-incompatible, provider-declared-failure, detected-failure, and total
ineligible counts, followed by the existing before-discharge, horizon-
exhausted, already-readmitted, and already-dead subcounts. Count reconciliation
and source scope/analytical time remain visible.

The overview does not become executive reporting, readmission-rate
measurement, care-management queueing, outcome attribution, or clinical
performance evaluation.

### Product-state and startup UX

| State | Stage 10 behavior |
|---|---|
| Valid and freshness not evaluated | Launch normally. Show neutral **Freshness not evaluated** status plus source analytical time/history cutoff; do not imply fresh. |
| Valid and fresh | Launch normally with restrained **Fresh for the supplied comparison context** status. |
| Valid and stale | Launch normally with a persistent prominent warning, original lineage, and read-only content. Explain that refresh/materialization is a separate operation. |
| Valid empty | Launch the normal app shell with polished empty current/trajectory summaries and the complete zero-count scope overview. |
| Products absent | Return bounded `application_products_unavailable` startup failure, no server, and guidance that products must be built/materialized separately. |
| Corrupt/incoherent | Preserve validated-access denial, return bounded `application_product_integrity_failed`, and expose no rows. |
| Incompatible contract | Return bounded `application_products_incompatible`, start no server, and do not parse physical files directly. |
| `_brand.yml` absent | Compose exact RRP presentation defaults and launch normally. |
| Valid branding with unsupported concepts | Ignore unsupported concepts, apply only the declared RRP subset, and launch normally. |
| Branding malformed or supported logo/value unsafe | Return bounded `application_brand_invalid`, start no server, and do not silently apply invalid supported input. |
| Required application/branding dependency unavailable | Return bounded `application_dependency_unavailable` before construction; package installation/check evidence should normally prevent this state. |

No state triggers product creation, materialization, repair, retention cleanup,
history access by the UI, or analytical execution.

### Dependency decision

Add `shiny`, `bslib`, `plotly`, and `reactable` as direct `rrpplatform`
application dependencies. Shiny owns application lifecycle, reactivity,
controls, selection, local serving, server behavior, and test-server support.
`bslib` owns the responsive shell, navigation, cards/panels, summary
presentation, theme composition, status treatment, and bounded primary-color
integration. Plotly earns a direct declaration because point-native hover,
responsive interaction, deliberate marker/line styling, configurable axes and
labels, and controlled modebar behavior are core to presenting longitudinal
remaining-readmission-risk trajectories at product quality. Reactable earns a
direct declaration because Current Risk Pool is a primary operational product
experience requiring responsive deterministic search/filter/sort/paging/
selection, deliberate cell presentation, and compact trajectory context rather
than incidental raw table output.

Use the narrow existing Posit branding dependency/API actually required to
parse and validate standard `_brand.yml`; 10.A reconnaissance must confirm the
mechanism rather than this plan guessing a package relationship or freezing an
unnecessary dependency. RRP adapts the validated upstream representation into
its closed presentation model and does not implement a parallel YAML parser or
branding specification.

Plotly and Reactable are presentation-only: validated products become a closed
detached application snapshot, pure view models produce component-ready data,
and only that data reaches the renderers. They have no project-root, product-
access, physical-file, history, DuckDB, producer/provider, construction,
materialization, or hospital-source knowledge. Base R still performs view-
model transforms and descriptive statistics. Do not add DT, ggplot2, dashboard
frameworks, broad theming systems, Highcharter/Highcharts, or arbitrary
JavaScript visualization libraries without another concrete requirement.
Highcharts-based rendering remains unselected for this potentially distributed/
commercial hospital product. Exact dependency versions and transitive closure
remain later distribution evidence; direct semantic dependencies are declared
when implemented.

The frontend responsibility split is:

```text
Shiny                 lifecycle, reactivity, controls, local serving
bslib                 responsive shell, layout, cards, theme composition
Reactable             interactive operational Current Risk Pool table
Plotly                 detailed interactive analytical graphics
RRP installed assets  bounded coherent styling and justified interaction
```

RRP-owned CSS is an accepted implementation capability. JavaScript is added
only for a concrete unmet interaction, not because an asset mechanism exists.
Neither becomes a hospital extension seam or standalone frontend framework.
`rrpruntime` remains free of application dependencies. Project extension
libraries do not supply application packages or override RRP's installed
application or branding dependency closure.

### Fictional reference and installed acceptance proof

The final proof starts from isolated installed packages/resources in an
unrelated non-Git directory, realizes the ordinary fictional project, and
uses the accepted Stage 8–9 operations to create its inputs before app testing.
That setup is evidence preparation, not launcher behavior.

Evidence must prove:

1. the generic app and brand-interpretation contracts, branding templates,
   RRP web assets, and guide resolve from installed software, while executable
   app code resolves from the installed `rrpplatform` namespace;
2. normal and fictional initialization add the exact accepted `_brand.yml` and
   contained logo inputs established by 10.A–10.B, with no `app/`, `app.R`, UI,
   module, `www`, arbitrary CSS/JS/HTML, or application source;
3. app startup uses only `rrp_open_product_access()`, `rrp_list_products()`,
   and `rrp_read_product()` at the boundary and does not invoke build,
   materialize, producer, provider, durable execution, retry, or correction;
4. the later fictional set renders one current estimate
   `0.3833333333333333`, its two actual observations `0.39` and
   `0.3833333333333333`, and the exact four-member scope accounting without a
   fictional branch;
5. Reactable ranking/search/filter/sort/paging and row/episode selection are
   deterministic; displayed probabilities remain exact; any continuous
   encoding is monotonic, noncategorical, and not the sole signal;
6. per-row sparklines and full Plotly trajectory/tooltip/table data contain only
   actual governed observations, while separately materialized first-scope and
   no-history cases prove intentional one-point and unavailable behavior
   without fabricated points;
7. direct current-risk summaries and exact operational counts reconcile;
8. the pre-discharge zero-member set produces the complete normal empty UX;
9. not-evaluated, fresh, and stale statuses are visibly distinct and stale
   content remains readable;
10. absent products fail boundedly; disposable corrupt and incompatible copies
    are denied before Shiny construction;
11. absent `_brand.yml` uses RRP defaults; valid supported standard branding
    applies only the accepted identity/color/logo subset; richer valid content
    adds no unsupported behavior; malformed input and unsafe logo containment
    fail safely;
12. fresh-process construction, installed RRP asset resolution, and one
    supervised loopback launch/termination work after copying the project to an
    unrelated non-Git location, without external branding dependencies;
13. product/state/history/source bytes and counts are unchanged by app
    preparation, interaction, launch, and shutdown; producer/provider call
    counters remain zero;
14. logical values, view models, rendered text, diagnostics, and application
    objects contain no known native IDs, crosswalk, predictor, source path,
    credential, connection, physical product path, or database handle; project
    branding supplies no arbitrary executable frontend content and cannot
    change analytical values, filtering, or products; and
15. the source repository, Git, working directory, ambient user library,
    physical history schema, and fictional project identity are unnecessary.

Automated evidence owns contracts; pure deterministic table, sparkline, chart,
and tooltip view models; exact probability text; search/filter/paging/selection
behavior; actual-observation-only two-/one-/zero-point component data;
monotonic noncategorical probability encoding if realized; Shiny server and
Reactable/Plotly widget-data structure; brand defaults/supported/unsupported/
malformed behavior; logo containment; installed RRP asset resolution; copied-
project portability; executable-customization denial; dependency boundaries;
analytical nonmutation; repository-independent construction; and launch smoke
behavior. It does not freeze exact HTML/CSS selectors or compare SVG/canvas
pixels. A bounded human review checks Reactable density/readability and polish,
sparkline usefulness, probability encoding, table/chart coherence, branding
and logo treatment, information hierarchy, typography, spacing, controls,
customized tooltips, responsive behavior, and polished freshness/empty/stale/
warning states. The review asks whether the narrow surface plausibly forms one
coherent modern analytical product rather than unrelated default widgets,
without making a production-accessibility or clinical-fitness claim.

### Historical reuse disposition

Reconnaissance inspected immutable `v0.1.0` `app/application.yml`,
`app/R/app-init.R`, `app/R/view-models.R`, `app/R/app.R`, `app/app.R`,
`docs/architecture/reference-application.md`, product access, Phase 6
materialized-product/app tests, and reduced application-artifact runtime where
it clarified dependency and injection boundaries.

| Classification | Stage 10 disposition |
|---|---|
| Reuse substantially | Product-access injection; defensive exact product startup; one detached load before reactivity; pure presentation view models; descending-risk display without priority meaning; canonical episode selection; actual observation points; provider/model attribution; zero-row state; safe unavailable startup; app-object and server-level tests; product-only dependency principle. |
| Adapt | Replace fictional-reference identity with generic installed `rrp.application.supplied`; replace old daily-hazard/estimand/YAML product configuration with accepted Stage 9 DCF/CSV logical access; use standard `_brand.yml` only as declarative branding input; replace source-tree `app/` sourcing with installed package code/assets; retain actual-point, canonical-selection, provider/model-attribution, and deterministic presentation-shaping concepts while evolving to Reactable, truthful sparklines, Plotly, bslib, contextual freshness, and the bounded brand-interpretation authority. |
| Reject | Repository-root discovery; generated hospital app source; project `app/`; YAML analytical/product parsing in UI; materialize-on-launch; direct DuckDB/history reads; producer/provider/runtime invocation; app-driven refresh; old run/estimand semantics; fictional wording/branches; full artifact/Connect wrappers; deployment assumptions; raw error pages; arbitrary hospital CSS/JS/HTML/modules or table/chart definitions. |
| Defer | Closed app artifact, standalone validator, target manifests, Connect/OCI realization, full dependency closure, authentication/authorization, full `_brand.yml` coverage, advanced typography and complex palettes, remote brand assets, custom navigation/layout/apps, scheduling, monitoring, production accessibility certification, performance scale, and clinical validation. |

### Implementation sequence

Stage 10 is decomposed into three dependency-ordered increments. Planning does
not authorize any increment.

#### Increment 10.A — Installed application authority, startup, view models, and launch boundary

**Objective:** establish the generic installed app identity and one read-only
product-to-application path that later UI work and the future CLI can reuse.

**Scope:** add/catalog the application and brand-interpretation authorities;
add Shiny, bslib, Plotly, and Reactable as direct `rrpplatform` application
dependencies; perform bounded reconnaissance of the actual Posit branding
package/API and standard fields; declare the narrow required branding
dependency; implement standard `_brand.yml` parsing/adaptation, defaults, one
closed presentation model, and project-local logo containment; establish
installed RRP frontend-asset ownership/resolution; implement application-model
construction, pure current/trajectory/summary view models, deterministic table-
/sparkline-/chart-/tooltip-ready data, generic shell, bounded startup failures,
and the single `rrp_launch_app()` export. Keep executable code and RRP assets in
installed package ownership. Anticipate the selected components but do not yet
claim final table, sparkline, chart, branding, or cross-component polish. Do
not yet change project templates.

**Interfaces/contracts changed:** new `rrp.application.supplied@0.1.0` and
`rrp.project-brand@0.1.0` authorities plus one public launch operation. The
brand authority governs RRP interpretation, not a replacement YAML schema.
Package dependencies and namespace grow only as stated. No project, product,
history, state, materialization, producer, provider, or runtime contract
changes.

**Historical reuse:** substantially reuse access injection, defensive startup,
pure view-model, app-object, and zero/failure mechanics; adapt them to current
contracts, installed package/assets ownership, Reactable/Plotly, and standard
branding; reject source-tree app sourcing, old YAML analytical configuration,
and fictional identity.

**Evidence:** exact app authority/catalog closure; direct dependency and export
posture; valid/not-evaluated/fresh/stale/empty application-model construction;
absent/corrupt/incompatible prelaunch failure; absent/supported/unsupported/
malformed brand behavior; safe logo containment; installed asset resolution;
pure deterministic view models whose table, sparkline, chart, and tooltip data
contain only governed values/observations; exact product inventory/version
enforcement; app components receive no roots/paths/handles; generic
`shiny.appobj`; supervised loopback start/stop; state-byte and call-count
nonmutation; parsing, build, isolated install/load, strict check, and inherited
regressions.

**Explicit exclusions:** no branding template or initializer inventory change,
final component styling or visual experiences, installed app guide, fictional
full acceptance, CLI, artifact, or deployment.

**Completion condition:** installed `rrpplatform` can validate one existing
product realization, construct a generic product-only app object, and launch
it locally through one stable read-only operation, while invalid inputs start
no Shiny server.

#### Increment 10.B — Useful core experiences and bounded presentation

**Dependencies:** completed 10.A startup, view-model, and launch boundary.

**Objective:** complete the useful first application and the smallest safe
hospital-owned visual identity extension.

**Scope:** implement the two-view navigation; a deliberately styled Reactable
Current Risk Pool with deterministic ranking/search/filter/sort/paging/
selection, truthful required sparklines, and useful continuous probability
encoding if realized; the intentionally customized full Plotly episode
trajectory and exact observation table; the scope/current overview with a
Plotly descriptive chart only if it materially improves comprehension; exact
freshness/empty/stale treatments; and responsive polished bslib composition.
Use bounded installed RRP CSS for cross-component integration and JavaScript
only if one concrete interaction cannot reasonably be achieved otherwise.
Add/catalog standard and fictional `_brand.yml` plus the accepted contained
logo asset where applicable, apply the governed default/custom identity,
primary color, and logo treatment, and update initializer inventories exactly
without changing their six authoring paths or generating app source.

**Interfaces/contracts changed:** realize the already accepted optional
standard branding input and contained asset in supplied templates. No new
authority, public export, or manifest, project API, authoring, product, target,
history, state, or materialization version change.

**Historical reuse:** retain presentation-only sorting, selection, actual
point, provider attribution, empty-state, and status ideas; replace raw tabs/
tables and fictional title with the generic bslib/Reactable/Plotly experience
and current fields; intentionally add truthful compact trajectory context and
standard branding while preserving actual observations and deterministic
presentation shaping. Do not recover generated Hospital app files or a broad
theming system.

**Evidence:** exact view-model/component agreement; deterministic Reactable
filtering/paging/selection and exact numeric values; actual-observation-only
two-/one-/zero-point sparklines and full trajectories; deterministic tooltip-
ready values; direct summary calculations and reconciliation; monotonic
continuous probability encoding if used; no thresholds/bins/categories/
interpolation; Reactable/Plotly widget-data and Shiny server tests; intentional
table density, cell, axes, percentage, marker, connector, tooltip, controls,
legend/modebar, responsiveness, and card/theme integration without freezing
style constants as contracts; default/supported/unsupported/invalid branding;
logo containment; safe color/text and non-color-only state treatment; installed
asset resolution; updated initializer exact inventories, copied projects, raw-
project omission, and no generated app source or hospital CSS/JS/HTML;
inherited Stage 8 authoring and Stage 9 product regressions.

**Explicit exclusions:** full branding coverage, advanced typography/complex
palettes, remote brand assets, hospital CSS/JS/HTML, custom views/navigation,
project app directory, authentication, app refresh, CLI, artifact, or
deployment.

**Completion condition:** the same installed application provides the complete
current-pool, actual-trajectory, and overview experiences under RRP defaults or
one bounded standard project brand, without changing analytical content or
application ownership.

#### Increment 10.C — Installed fictional application proof and human guidance

**Dependencies:** completed 10.A–10.B generic app, component, branding, and
presentation behavior.

**Objective:** prove the complete Stage 10 exit state through installed
software and the ordinary fictional project, and document the exact human
package-level launch boundary.

**Scope:** add one cataloged version-matched Supplied Application Guide; add the
complete installed non-Git fictional acceptance proof and bounded human UX
review of the coherent bslib + Reactable + Plotly + RRP-assets experience;
update ownership/validators/documentation only for realized behavior; make
only corrections revealed by the proof.

**Interfaces/contracts changed:** none planned. A newly discovered contract or
public-interface need must be reconciled explicitly rather than hidden in the
proof.

**Historical reuse:** adapt useful Phase 6 app initialization, server test,
zero/failure, and teaching sequence; reject Phase aggregation, repository
operations, artifact/deployment coupling, and fictional-specific application
identity.

**Evidence:** the complete 15-point installed proof above, including Reactable,
sparklines, Plotly, default/custom standard branding, accepted logo, installed
RRP assets, copied/non-Git operation, product states, analytical nonmutation,
privacy, and executable-customization denial; guide resolution and agreement;
source/package/Rd parsing; exact resource closure; package-native application
and inherited regressions; dependency-order builds; isolated install/load;
fresh-process construction; strict checks; supervised launch cleanup; process/
artifact hygiene; both human validators; and successful exact-revision hosted
workflow before formal Stage 10 acceptance.

**Explicit exclusions:** CLI/distribution/install, product-only artifact,
Connect/OCI realization, authentication, remote hosting, deployment,
publication, support/performance claim, or clinical validation.

**Completion condition:** a human using installed RRP package operations can
launch the same generic useful supplied app for the ordinary fictional or any
conforming project with existing validated products, understand its state and
bounded standard branding, and observe no analytical mutation, arbitrary
hospital frontend execution, or project-owned app source. Formal acceptance/
reconciliation remains a separate lifecycle action, not Increment 10.D.

### Validation and hosted evidence

The existing human operations remain authoritative:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
```

Validation grows only for cataloged application/brand-interpretation
authorities and branding templates/assets/guide, package application/view-
model/launcher tests, updated exact initializer inventories, installed
fictional app proof, Shiny/bslib/Plotly/Reactable and upstream-branding-tool
dependency/namespace posture, installed RRP asset resolution, builds, isolated
install/load, strict checks, path/privacy/process hygiene, and inherited Stage
8–9 behavior. No application-specific framework, Phase suite, browser snapshot
system, deployment test, or parallel product reader is added.

The existing read-only Ubuntu/R 4.4 `package-foundation` workflow continues to
invoke those same human operations. CI behavior changes only if the new direct
application dependencies demonstrate a real provisioning requirement. Formal
Stage 10 acceptance remains separate after all three increments, bounded human
review, a successful hosted run for the exact committed complete Stage 10
implementation, and reconciliation with True North and Platform Architecture.

### Stage 10 acceptance

Stage 10 is complete only when:

1. the supplied application is generic installed RRP software owned by
   `rrpplatform`, not a fictional or project-owned app;
2. `rrp.application.supplied@0.1.0` closes application identity, the Shiny/
   bslib/Plotly/Reactable foundation, required product compatibility,
   `rrp.project-brand@0.1.0`, installed RRP asset ownership, and read-only
   posture without duplicating product, branding, style, or artifact schemas;
3. exactly one public launch operation accepts explicit software/project
   context, optional paired freshness context, local browser/port controls,
   starts only on loopback, and is suitable for later CLI wrapping;
4. startup validates software, project, optional standard branding/contained
   assets, current product access, exact three-member inventory/versions, and
   dependencies before Shiny;
5. absent, corrupt, incoherent, or incompatible products start no server and
   return bounded privacy-safe failures without physical fallback;
6. the app receives one closed detached product snapshot plus one closed
   detached presentation model and no root, path, connection, writer, project
   callable, source, provider, or history object;
7. launch and interaction invoke no producer/provider, build, materialize,
   retry, correction, source selection, refresh, or state/history mutation;
8. pure view models remain presentation-only, deterministically produce table-
   /sparkline-/chart-/tooltip-ready data, and cannot introduce fallback,
   fabricated points, interpolation, thresholds, priority, clinical
   categories, private joins, or new analytical meaning; Reactable and Plotly
   receive only detached presentation data;
9. Current Risk Pool uses a deliberately styled interactive Reactable
   experience with deterministic risk ranking, exact useful timing and
   attribution, search/filter/sort/bounded paging, synchronized row/canonical-
   episode selection, lineage/status context, and polished valid-empty behavior;
10. each Current Risk Pool sparkline contains only its episode's actual
    governed observations with correct two-/one-/zero-point behavior; any
    continuous probability encoding is direct, deterministic, monotonic, non-
    categorical, not the sole signal, and accompanied by exact numeric text;
11. Episode Risk Trajectory displays only actual governed observations as
    intentionally customized Plotly markers with concise corresponding
    tooltips, exact table detail, truthful optional visual connection, and
    correct two-point, one-point, and no-history behavior; no graphical element
    invents intermediate or other analytical meaning;
12. Overview presents only direct current-risk descriptive summaries and exact
    operational-scope/outcome reconciliation; if Plotly is used there, it is
    only for a direct descriptive visualization that improves comprehension,
    with no business KPI or clinical decision semantics;
13. not-evaluated, fresh, stale, empty, unavailable, integrity-failed, and
    incompatible states remain visibly and operationally distinct, while valid
    stale products remain readable;
14. `rrp.project-brand@0.1.0` governs RRP's bounded interpretation of standard
    project-root `_brand.yml`; appropriate existing Posit tooling parses and
    validates it, RRP does not reproduce the schema, absent branding uses
    immutable defaults, valid unsupported concepts are ignored, malformed or
    unsafe supported input fails, and branding remains presentation-only;
15. the supported branding subset is limited to a suitable standard
    organization/display identity concept, primary color, and one bounded
    contained logo as confirmed in 10.A; brand identity never defines the
    analytical probability scale, and absolute/remote assets are denied;
16. normal and fictional initialization add only the exact optional standard
    branding/contained-asset inventory accepted after 10.A reconnaissance,
    retain six existing authoring paths, generate no app source or hospital
    CSS/JS/HTML, and leave direct raw/existing projects without branding valid;
17. `shiny`, `bslib`, `plotly`, and `reactable`, plus only the narrow upstream
    branding dependency actually required, remain outside `rrpruntime` and
    project extensions and are justified by realized behavior;
18. executable app code and bounded RRP-owned CSS/justified JavaScript run from
    installed software; cataloged authorities/templates/assets/docs resolve
    from installed resources; hospital projects cannot inject arbitrary CSS,
    JavaScript, HTML, UI modules, or component definitions; and no runtime
    repository, Git, working-directory, ambient-library, or sibling checkout
    dependency exists;
19. the ordinary fictional proof exercises the exact generic app with actual
    `0.39` and `0.3833333333333333` observations, exact later current/scope
    content, Reactable/sparkline/Plotly behavior, one-point and valid-empty sets,
    default/custom branding and logo, freshness states, copying, installed
    assets, and bounded denial;
20. application models, rendered values, diagnostics, and tests retain only
    canonical/product content and exclude known native IDs, crosswalk,
    predictor, source, credential, connection, physical path, and database
    internals; branding cannot change analytical values, filtering semantics,
    product content, freshness, or runtime behavior;
21. automated component/server/Reactable/Plotly/branding/asset/launch evidence
    plus bounded human review show a narrow coherent modern experience with
    deliberate hierarchy, table density, sparklines, probability encoding,
    branding/logo, spacing, states, controls, tooltips, responsiveness, and
    chart/card integration rather than unrelated default widgets, without a
    pixel-perfect, production-accessibility, clinical, performance, or support
    claim;
22. repository/package validation, exact catalog closure, parsing, package-
    native and installed regressions, builds, isolated/fresh-process loading,
    strict checks, process cleanup, hygiene, and exact committed hosted
    evidence pass; and
23. no CLI, distribution, installer, artifact, Connect/OCI target,
    authentication, remote hosting, deployment, custom-app or unrestricted
    theming framework, hospital executable frontend hook, scheduler, production
    monitoring, or Stage 11–12 behavior enters.

### Relationship to Stages 11 and 12

Stage 10 supplies the installed app, application authority, pure view models,
programmatic loopback launcher, bounded standard branding interpretation,
installed presentation assets, and package-level human guide. Stage 11 may
expose a CLI command over `rrp_launch_app()` and must close the installed
distribution, dependency resolution, installation, activation, upgrade, and
uninstall lifecycle without changing app semantics. Stage 10 does not
preselect that command syntax or installer.

Stage 12 consumes the accepted installed app and a frozen validated coherent
product set to build target-neutral product-only artifacts and Posit/OCI
realizations. It owns standalone artifact inventory, dependency closure,
entrypoints, self-validation, and target behavior. Stage 10 does not copy its
app into an artifact or introduce deployment configuration.

### Major deferrals

Authentication; authorization and roles; production identity management;
custom hospital apps; hospital-authored CSS, JavaScript, HTML, UI modules, or
component definitions; unrestricted theming; full `_brand.yml` feature
coverage; advanced typography and secondary/complex palette interpretation;
remote brand assets; custom navigation/layout; multi-logo/media management;
clinical thresholds, priorities, queues, recommendations, or hidden filtering;
application-triggered build/refresh; producer/provider/history execution;
scheduler/background work; CLI; distribution/installer/upgrade; standalone
artifacts; Connect/OCI/remote hosting; object-storage product access;
deployment; monitoring/telemetry; production accessibility certification;
performance/SLA/support claims; clinical validation; browser/pixel snapshot
matrices; and Stage 11–12 implementation remain outside Stage 10.

No unresolved architectural question blocks 10.A. Planning selected reversible
package-level choices and deliberately leaves deployment-scale, broader media/
branding, custom-app, and operator syntax decisions with their later owners.

## Stage 11 — CLI, closed RRP-owned-payload distribution, installation, and upgrade

**Planning status:** second-edition detailed plan formally accepted for
implementation on 2026-10-07; implementation has not begun. Stages 1–10 remain
the accepted baseline. Increment 11.A is the next implementation task. This
acceptance does not select release bytes or claim an installed distribution
exists.

The reviewed decisions settle the `rrp` command taxonomy, exact-current-
directory project default, versioned JSON output, base-R first-install
bootstrap, repository-restored dependency model, OS-standard user locations,
project-independent activation, and release-version provenance. They govern
this Stage 11 construction plan. Package APIs still receive explicit normalized
software/project contexts; the CLI merely resolves the exact working directory
when a project argument is omitted. Likewise, an operator may validate a
project before changing versions, but installation and activation themselves
have no project input or project awareness. Compatibility is enforced when
software is explicitly asked to operate on a project.

### Objective and stage boundary

Complete only the stable programmatic operations needed for human lifecycle
intent and place one thin canonical CLI over them. Build an intentional closed
RRP-owned software payload with a reproducible third-party dependency
specification; install it user-scoped in immutable side-by-side versions;
restore each version's dependencies from configured R repositories into its
private library; verify, activate, roll back, and uninstall those versions;
and operate independent projects without making a project part of an
installation. The installed product carries its exact private R package
library, governed resources, reference resources, launcher, version-matched
human documentation, inventory, integrity and dependency-realization evidence,
and provenance.

The distribution and CLI expose the already accepted producer, provider,
history, product, and application behavior. Stage 11 may add package-owned
orchestration where the manual assessment demonstrated a missing stable
operator intention, but it may not reimplement those semantics in command
parsing or redesign an accepted Stage 1–10 boundary without specific evidence.

Internet access to configured R package repositories is an acceptable install
prerequisite. A distribution does not redistribute or physically close every
third-party package artifact, and offline installation is not a Stage 11
claim. Product-only artifacts and target deployment remain Stage 12. Clean
support-cell, dependency restoration on each claimed OS/R cell, and independent-
adopter qualification remain Stage 13. Release qualification,
signing/publication decisions, remote publication, and public acquisition
remain Stage 14.

### Accepted starting model

The pre-Stage-11 assessment proved that the accepted software already works
outside the development checkout when two packages, one projected software
resource root, and one independent project are supplied explicitly. The
current software owners are:

- dependency-light `rrpruntime`, which owns canonical admission, episode
  state, provider execution, and storage-neutral logical history;
- `rrpplatform`, which owns resource access, independent-project loading and
  initialization, standard authoring adaptation, the supplied DuckDB state
  adapter, durable operation, logical products and materialization, the
  product-only application, and all current public project operations;
- the installed resource catalog, which closes 54 governed contracts,
  templates, assets, and five product documents into one explicit software
  root; and
- an independent project, which owns source acquisition/adaptation, producer
  and provider code, optional extension library, configuration, branding,
  durable state, products, and local operational decisions.

The accepted public package layer has the individual operations needed to
initialize and validate a project, initialize/inspect/backup/restore state,
execute producer/risk/durable work, inspect and correct history, build and
materialize products, open/read products, and launch the app. It does not yet
own a distribution builder, installation registry, active-version resolver,
installed doctor, CLI renderer, reference-source preparation operation, one
operator-level product build-and-publish operation, or a complete read-only
project lifecycle summary. Those are Stage 11 gaps, not reasons to move
accepted analytical behavior into a launcher.

The following identities and locations remain distinct throughout Stage 11:

| Boundary | Meaning and owner | Stage 11 rule |
| --- | --- | --- |
| Development/source repository | Maintainer-owned packages, resources, tests, assessments, governing records, and build tools | A build input only; never an installed payload or project prerequisite. |
| Built RRP distribution | One validated, target-described artifact with a closed RRP-owned payload and reproducible dependency specification | Acquisition input; not yet an installation, not an offline CRAN mirror, and contains no hospital project. |
| Installed RRP version | One verified distribution realized beneath a user-owned RRP software root after dependency restoration into its private library | Immutable after promotion and independently addressable by software version and integrity metadata. |
| Active RRP version | The installed version selected by one small atomic user activation record, or an explicit per-invocation selector | Selection state only; activation does not copy into or edit projects. |
| Independent project root | Explicit hospital-owned manifest, registration/authoring code, configuration, branding, and declared paths | Never stored inside, inventoried by, or deleted with an installation. |
| Project-owned source and state | Hospital source/mapping/model inputs plus RRP-managed history/products beneath the project's declared state path | Operated through compatible installed software; never silently migrated by installation or activation. |
| Product-only artifact | A frozen independently valid app/product deployment input | Remains absent until Stage 12 and is not another name for a software distribution. |

The software distribution is therefore not a generated Hospital repository,
and an independent project is not a partially installed copy of RRP.

### Evidence from the manual workflow

The manual assessment is the executable decomposition beneath the future UX.
Stage 11 treats its steps as follows:

| Manual action | Lifecycle owner | Stage 11 treatment |
| --- | --- | --- |
| Choose source, archive, isolated-library, software-resource, and project roots | Build/install/project responsibilities were mixed | The builder owns build roots, the installer owns the OS-standard user software root, and the launcher resolves the selected installation. A project command uses `--project PATH` when supplied and otherwise the exact current directory. |
| Install third-party dependencies, build two internal packages, and install them in order | Distribution build and installation | Remove from normal adopter work. The distribution carries the reproducible dependency specification and exact RRP packages; installation restores from configured repositories into one version-private library, then verifies it. |
| Project 54 resources and remove source-only catalog fields | Distribution build | Perform deterministically at build time and validate inside the distribution. No adopter sees or reproduces `Source-Path`. |
| Set library/environment variables, start vanilla R, load packages, and open the software catalog | Launcher/runtime selection | Hide behind the version launcher. It fixes the private library, package paths, resource root, and R process environment before package dispatch. |
| Initialize the ordinary or fictional project | Project lifecycle | Require a positional `PATH` naming the new destination and retain the initializer's existing create/absence safeguards. The exact-current-directory default does not apply to creation. |
| Edit project manifest, source mapping, provider/model, and configuration | Project/hospital | Retain as explicit human-owned work. The CLI may orient and validate it but must not synthesize hospital semantics. |
| Source and invoke the fictional generator | Fictional/reference-only behavior | Add a narrowly named installed reference operation and CLI path. Do not invent a generic hospital source-acquisition protocol. |
| Validate the project and initialize state | Project lifecycle | Expose separate validation and explicit state initialization; neither runs implicitly during install or activation. |
| Invoke producer and one provider directly for inspection | Lower-level R API / adopter diagnostics | Keep the accepted APIs. They are not required normal-run CLI commands unless implementation evidence justifies a focused nonpersistent check. |
| Supply analytical time and operation key for a durable run | Normal project operation | Retain both as explicit safety/provenance inputs; the CLI validates syntax, invokes `rrp_execute_durable_bundle()`, and prominently returns the operation-run identity. |
| Carry scope IDs and cutoffs into product construction/materialization | Normal project operation | Preserve explicit scope/cutoff selection, but add one package-owned build-and-materialize intention so the CLI does not implement product composition. |
| Inspect scope/episode/current history | Project inspection | Expose focused read-only CLI views over the accepted APIs. Do not expose DuckDB or SQL as the human contract. |
| Launch, interrupt, rerun, rebuild, and relaunch the app | Normal project operation | Expose run, product materialization, and app launch as deliberately separate commands. The launcher owns subprocess/signal behavior; app launch still never refreshes analytics. |
| Exercise later fictional death/source scenarios | Fictional teaching behavior | Retain in the reference walkthrough/API evidence; do not turn scenarios into generic platform modes. |
| Manually remember package/resource/project compatibility | Software and project diagnostics | Add separate installed and project doctors with bounded responsibilities and shared diagnostics. |

This preserves meaningful explicit choices—project location (a path or the
exact current directory), analytical time, operation key, source scope,
history cutoff, backup destination, and corrective intent—while removing build
layout, dependency order, library selection, resource projection, and package-
loading knowledge from ordinary operation.

### Two lifecycles and their intersection

The software lifecycle is:

```text
acquire and unpack one RRP distribution
        ↓
validate its closed RRP-owned payload, dependency specification, and prerequisites
        ↓
restore dependencies and install one immutable user-scoped version
        ↓
verify installed inventory, private library, resources, and launcher
        ↓
activate/select that verified version
        ↓
install and verify another version beside it
        ↓
activate the new version or reselect the prior version
        ↓
uninstall only an inactive explicitly selected installation
```

The project lifecycle is:

```text
initialize one independent project at a chosen destination
        ↓
hospital configures source/mapping/provider and dependencies
        ↓
validate or diagnose the project with selected installed software
        ↓
initialize/inspect/backup/recover project state explicitly
        ↓
run one attributed analytical operation
        ↓
inspect history and materialize one explicit product realization
        ↓
launch the supplied product-only application
```

They meet only at invocation:

```text
shared user launcher
        ↓ resolve active or explicitly selected verified installation
version-specific launcher
        ↓ fix host R + private RRP library + matching resources
rrpplatform CLI dispatcher
        ↓ receive explicit project root and check compatibility
accepted project/package operation
        ↓
independent project source/state
```

The launcher never discovers or registers projects. A command operating on an
existing project uses exactly `--project PATH` when supplied; otherwise it
normalizes the exact current working directory once and passes that explicit
root to the package API. It never searches parents, remembers a last project,
interprets Git, or scans sibling directories. Project/reference creation
instead requires a positional destination `PATH`; omission never means the
current directory, and the destination must satisfy the existing initializer's
create/absence safeguards. Every operation on an existing project checks the
manifest/API and other owning compatibility boundaries against the selected
software before mutation.

Installation, activation, rollback, and uninstall accept no project arguments,
inspect no projects, and persist no project/software association. Changing the
activation record changes only future default software selection. The launcher
owns one coherent per-invocation selection capability for every command: absent
an explicit selector it uses the active verified installation; with one it uses
that specified verified installation for this invocation only and leaves the
active record unchanged. For project commands, software selection and project
resolution remain independent inputs, and neither creates a persistent
association. Exact secondary selector spelling remains an implementation
choice. The two lifecycles meet only when the selected software is asked to
operate on a resolved project root. An incompatible operation fails clearly
without modifying the project; the operator may change the project separately
or reactivate an older compatible software version.

### Proposed on-disk ownership and runtime model

Stage 11 adopts one logical user-owned RRP home with an injectable root for
tests. Its default is the operating system's conventional per-user application-
data location rather than an R user library or project directory. The exact
macOS/Linux spellings are finalized in 11.A, using platform conventions rather
than a hard-coded home expansion. The logical shape is:

```text
RRP user application-data root/
├── installations/
│   └── <software-version>/<distribution-integrity-id>/
│       ├── INSTALLATION.dcf
│       ├── distribution manifest, inventory, and digests
│       ├── bin/                 version-specific launcher/entry material
│       ├── library/             exact private R package library
│       └── resources/           matching projected catalog and resources
├── active.dcf                   one atomic regular-file selection record
└── staging/                     installer-owned, failed safely and cleaned

user executable location/
└── rrp                          small shared selector, not version logic
```

Each installation is self-contained after restoration. No authoritative
package or dependency is shared across version roots, so verification and
uninstall have exact ownership. A package download/cache used by the selected
restoration engine is non-authoritative and is never searched as a runtime
library. `active.dcf` names an exact verified installation through a safe
relative identity and is replaced atomically only after software verification.
A regular record is preferred to a symlink for portable, inspectable, no-link
safety. The stable per-user `rrp` shim contains no RRP domain logic; it validates
selection enough to reach the version launcher.

One installation records the canonical absolute path to the supplied host R
4.4.x executable, exact R version/platform/architecture, software version,
distribution integrity, dependency specification and restoration evidence,
configured repository provenance safe to retain, installation time/path, and
manifest digest. R itself is not bundled. The version launcher starts that R
with vanilla user startup behavior, constructs `.libPaths()` as version-private
library then base R only, verifies that `rrpruntime`, `rrpplatform`, and every
declared runtime dependency resolve at the required version beneath that
library, and passes the matching resource root directly to package dispatch.
Ambient user/site libraries cannot satisfy or substitute the dependency
specification. Project extension packages are added later by the accepted
trusted loader, after the RRP library, under the existing anti-shadowing rules.

Subprocesses inherit an explicit immutable execution context—R executable,
installation root, private library, resources, and software/integrity identity.
For a project command, the CLI additionally resolves the supplied path or exact
working directory once and passes that explicit project root; subprocesses do
not rediscover it. Long-running app launch receives and reports the same
context and has conventional signal/exit behavior. Advanced direct R use
remains possible through documented explicit library and software-root inputs,
but ambient `library(rrpplatform)` is not the canonical installed experience.

Install, activate, rollback, and uninstall never write outside the selected
user software home and shared launcher location. In particular they never
write, inventory, back up, migrate, or delete a project root. Uninstall refuses
the active installation, refuses ambiguous/tampered ownership, and removes
only an exact version root after its installed ownership record is validated.

### Distribution and dependency-restoration model

Three claims remain separate:

1. **Build:** a maintainer operation assembles and validates one distribution
   containing a closed RRP-owned payload and reproducible dependency
   specification from declared source inputs and resolution evidence.
2. **Acquire:** an operator obtains those exact bytes and verifies their
   manifest/digests. Stage 11 accepts a local path; network discovery/download
   and signing policy remain deferred.
3. **Restore/install:** a user-scoped bootstrap validates the acquired RRP
   artifact, restores the reproducibly specified third-party dependency
   environment from explicitly configured R repositories, and realizes/
   validates one private installation without the development repository or
   ambient R library.

The source inclusion authority is a positive role-classified allowlist, not
Git tracking minus ignores. The generated distribution manifest records at
least product and development/distribution versions, distribution and build
identities, source revision/state, builder identity/version, target R/platform/
architecture, package identities, the reproducible dependency specification
and repository/source resolution evidence, resource catalog identity,
licenses/notices, normalization claim, validation evidence, and every RRP-owned
output path/role/size/SHA-256 digest. The build rejects missing, duplicate,
unsafe, linked, case-conflicting, unclassified, or unexpected RRP-owned
members. Normalized-content reproducibility is required for those declared
inputs; byte-identical compressed archives are not claimed until separately
proved.

A local builder may optionally label a fully inventoried working-tree build as
an unqualified development artifact, but it may not hide dirty/uncommitted
provenance or imply release readiness. The authoritative 11.H acceptance build
comes from one exact clean committed revision. This is a maintainer build-input
rule, not a Git-state requirement for installing software or operating a
project.

The payload contains only intentional installed-software material:

- exact `rrpruntime` and `rrpplatform` package artifacts plus a reproducible,
  validated specification of the complete tested third-party runtime closure,
  but not necessarily the third-party package artifacts themselves;
- the projected installed resource catalog and all governed contracts,
  templates, application assets, fictional/reference templates, and existing
  five product documents;
- Stage 11 installation, CLI, version-management, diagnostics, and recovery
  documentation added as cataloged version-matched product resources;
- the version-specific CLI entry, the small bootstrap installer/standalone
  distribution verifier, and shared-launcher material;
- product/version/build metadata and package/dependency provenance; and
- applicable Apache-2.0, NOTICE, third-party license, security/support, and
  compatibility information.

Build-time resource assembly reads `resources/source-catalog.dcf`, copies only
its declared regular source members to installed paths, writes the installed
catalog without `Source-Path`, and validates the result through the ordinary
public resource operation. The installed artifact contains neither the source
catalog nor a development source-path dependency.

The payload excludes governing plans/records/assessments, maintainer tests and
CI, repository validators and release tools, `.git`, the development dependency
environment as installed authority, package check/build output, arbitrary
repository files, local caches, credentials, patient-like private inputs, an
initialized project, project source/state/products, and Stage 12 deployment
artifacts. The supplied fictional material remains cataloged template/document
content; no generated fictional source, history, or product state ships.

The dependency specification fixes the tested package graph sufficiently to
restore and verify it reproducibly for the declared R/platform target. The
installer uses explicit configured repository URLs or snapshots and records
safe repository/package/version/source/integrity evidence; credentials remain
external and are never retained. Network/repository failure leaves staging
unpromoted. A package absent from the private library, at the wrong version, or
resolved only from an ambient library is installation failure.

Terms such as required, exact, and closure in this dependency context describe
the precision of the specified and verified installed environment. They do not
mean that the distribution contains or redistributes every transitive third-
party artifact byte. Only the RRP-owned payload is physically closed and
inventoried by the distribution.

`renv` is a strong candidate restoration engine and must be evaluated during
implementation. If selected, its lock and machinery are internal distribution,
installer, and release details—not the permanent public architecture. No RRP
project gains `renv/`, `renv.lock`, `.Rprofile`, repository settings, or a new
dependency mental model as a result. The public requirement is the reproducible
dependency specification, configured-repository restoration, isolated private
library, and verified realization. Stage 11 does not promise offline install or
redistribute the entire CRAN closure.

The distribution-local bootstrap is exactly one small base-R entry such as
`Rscript --vanilla install.R`. It validates the RRP-owned manifest/inventory and
dependency specification, then invokes the same shared installation mechanics
used later by `rrp software install PATH`. It does not separately implement
dependency resolution, package installation, activation, or repair. Human
guidance is simply download, unpack, enter the directory, and run that one
command with compatible host R and repository access.

### Canonical CLI design

The canonical command is `rrp`, with the accepted shallow noun-based taxonomy.
It is a thin transport over stable package operations. It owns argument
parsing, software selection, exact project-root resolution, confirmation for
destructive/corrective intent, invocation,
privacy-safe rendering, process/signal handling, and exit status. It does not
parse clinical data, construct canonical bundles/requests/history/products,
query DuckDB, interpret product semantics, or implement recovery itself.

The accepted taxonomy is shallow and intent-oriented; 1.0 adds no flat aliases:

| Proposed command/family | Operator intent and underlying owner | Inputs and meaningful output | Mutation | Stage 11 status |
| --- | --- | --- | --- | --- |
| `rrp version` | Identify launcher, active/selected distribution, host R, and package/API versions; installation/CLI layer | Optional software selector; exact identities and paths safe to display | Read-only | Required |
| `rrp software list/current` | Inspect installed versions and active selection; installation registry | User software home; verified/tampered/active status | Read-only | Required |
| `rrp software verify` | Strictly prove one installed inventory, digests, packages, resources, launcher, and recorded R; installation verifier plus `rrp_validate_software_resources()` | Exact selector; structured pass/failure evidence | Read-only with removed temporary probes | Required |
| `rrp software doctor` | Explain whether the selected installation can operate and how to recover; installed doctor | Optional selector; checks/warnings/failures/recovery | Read-only with removed probes | Required |
| distribution-local `Rscript --vanilla install.R` and later `rrp software install PATH` | Validate the RRP payload, restore its reproducibly specified dependency environment, and realize it user-scoped through shared installation mechanics | Unpacked distribution path, compatible R, configured repositories, optional test-only installation root; installed identity/evidence | Creates one immutable installation; does not activate or inspect projects | Required |
| `rrp software activate SELECTOR` | Change the atomic default after software-only verification | Exact installed selector; prior/new selection | Replaces activation record only; accepts no project input | Required |
| `rrp software uninstall SELECTOR` | Remove one verified inactive owned installation | Exact selector and confirmation; deleted installation identity | Deletes only exact inactive version root | Required |
| `rrp project init PATH` | Create the standard independent scaffold; `rrp_initialize_project()` | Required positional destination `PATH`, which must satisfy existing create/absence safeguards, plus project tokens; created inventory | Creates project source only | Required; creation never defaults to the current directory |
| `rrp reference init PATH` / `rrp reference prepare-source [--project PATH]` | Create and prepare the supplied fictional teaching project; bounded reference operation | Required positional destination `PATH` satisfying create/absence safeguards for creation; for preparation, supplied project path or exact current directory; fictional source identity/inventory | Creates fictional project or its absent deterministic source area | Required for reference acceptance; creation never defaults to the current directory and this is never generic ingestion |
| `rrp project validate [--project PATH]` | Validate manifest, trusted registration, selections, extensions, and selected-software compatibility without invoking producer/provider; `rrp_validate_project()` | Supplied path or exact current directory; structured conformance | Read-only | Required; also the explicit compatibility preflight when desired |
| `rrp project doctor/status [--project PATH]` | Diagnose operational readiness or summarize nonmutating lifecycle state; new package-owned composition of existing validators/readers | Supplied path or exact current directory plus optional freshness comparison; bounded state/history/product/app facts and recovery | Read-only with removed probes | Required |
| `rrp state init/inspect/backup/restore [--project PATH]` | Manage the already accepted explicit project-state lifecycle; existing state/recovery APIs | Resolved project and backup path; state/backup identity and status | Read-only, create-only state/backup, or explicit absent-state restore as named | Required; restore retains existing safeguards and confirmation |
| `rrp run --at TIME --operation-key KEY [--project PATH]` | Execute one durable admitted bundle; `rrp_execute_durable_bundle()` | Resolved project plus explicit analytical time/key; operation-run ID and outcome summary | Append/idempotent project history | Required |
| `rrp history scope/episode/current ... [--project PATH]` | Inspect logical history without storage knowledge; accepted history readers | Resolved project plus exact identities/cutoffs | Read-only | Required |
| `rrp history retry/invalidate/restate ... [--project PATH]` | Invoke existing explicit corrective semantics with reason/identity and confirmation | Resolved project plus exact scope/episode/action inputs; action/result identity | Append-only correction or retry semantics | Required advanced recovery, not part of a normal run |
| `rrp products materialize --scope ID --cutoff TIME [--project PATH]` | Construct and atomically publish one coherent product set; new package-owned composition of existing build/materialize APIs | Resolved project plus explicit complete scope/cutoff; product-set identity, inventory, freshness | Adds immutable set and advances current pointer | Required |
| `rrp products status [--project PATH] [...]` | Inspect current validated realization/freshness; product access APIs | Resolved project and optional comparison context; current set/member/freshness status | Read-only | Required |
| `rrp app launch [--project PATH] [--scope ID --cutoff TIME]` | Launch the accepted product-only app; `rrp_launch_app()` | Resolved project and optional freshness context, loopback host/port/browser flags | Long-running read-only process | Required |

`software upgrade` is deliberately not a separate mutating primitive: upgrade
is install, verify, then activate. Project compatibility is checked later when
that software is asked to validate or operate on a project. Rollback is
activation of an exact retained prior installation. The accepted 1.0 taxonomy
adds no convenience aliases that collapse these lifecycle steps.

Standalone producer/provider inspection remains available through the public R
APIs and tests. It does not enter the first normal CLI merely because a method
exists. The accepted raw registration boundary likewise remains an advanced R
extension surface rather than a command family. Source acquisition for a real
hospital stays project-owned; only the supplied fictional generator has a
reference command.

Default output is concise human text with stable diagnostic codes and recovery
guidance. `--json` explicitly requests the one canonical machine-readable
rendering. Its public schema is stable and versioned; it maps deliberately
selected privacy-safe fields from the same underlying operation result and
never blindly serializes an internal R object or takes a second behavior path.
Human progress is separated from JSON output. DCF/tabular output is not another
public CLI contract. Success is exit 0; operation/conformance failure is
nonzero; invalid usage is distinguishable; interrupted long-running commands
use conventional signal status in both modes. Neither rendering exposes raw
project callables, environment contents, connections, patient records,
credentials, private mappings, or other internal/private material.

### Verification and doctor boundaries

Four intentionally different checks prevent a new generic “check everything”
operation:

| Operation | Owns | Does not own |
| --- | --- | --- |
| Distribution validation | Acquired RRP-owned manifest/inventory/digests, exact internal package artifacts, reproducible dependency specification, projected resources, licenses/docs, target/build provenance, safe paths/links | Downloaded third-party bytes, host installation paths, active selection, or any project |
| Installed verification | Exact installed manifest/inventory/digests, dependency-specification agreement and restoration evidence, recorded host R, private package paths/versions, resource catalog, launcher/activation agreement | Project configuration, source behavior, history contents, or repair |
| Installed doctor | Verification result plus host R executability/compatibility, activation resolution, permissions/temp probes, dependency loadability, and actionable warnings | Project discovery, installation repair, package download, activation, or migration |
| Project validation/doctor | Explicit project identity/API compatibility, trusted registration/selections/extensions, state compatibility, safe history/product lifecycle summaries, freshness when comparison is supplied, and recovery guidance | Installation inventory, source/EHR connectivity by default, clinical/model validity, state mutation, automatic product refresh, or database repair |

Existing operations supply most project evidence: `rrp_validate_project()`,
`rrp_inspect_project_state()`, logical history readers,
`rrp_open_product_access()`, and application startup validation. Stage 11 adds
only a package-owned read-only composition and exact lifecycle status contract;
it must not infer “latest” analytical truth where an identity/cutoff is needed.
Project doctor may report source/provider behavior as “not exercised” and point
to explicit lower-level conformance operations rather than invoking hospital
code unexpectedly.

Fresh installations may be healthy with no project. Fresh projects may be
healthy with uninitialized state or absent products, expressed as warnings or
expected lifecycle states rather than fabricated data. Corrupt/incompatible
state blocks relevant project operations and is preserved. Stale products
remain valid/readable with the accepted warning. Doctor never initializes,
repairs, migrates, runs, rebuilds, activates, or deletes.

### Upgrade, rollback, uninstall, and compatibility

Installation stages a new version under a temporary sibling, restores the
reproducibly specified dependency environment from configured repositories
into that version's private library, installs the exact RRP packages using the
recorded R, validates package paths/versions/resources/inventory in fresh
processes, writes the
installation record last, and atomically promotes only after success. Network,
repository, compilation, dependency, or verification failure leaves the active
record and all prior installations unchanged; incomplete staging is bounded
and recoverable. An identical exact installation is idempotent. A conflicting
immutable identity fails loudly.

Activation is a software-only operation. It verifies one candidate installation
and atomically replaces the active selection. It accepts no project path,
discovers and opens no project, retains no project registry or association, and
does not claim project compatibility. Failure preserves the old activation
record. An operator who wants advance compatibility evidence runs an explicit
`rrp project validate` with the candidate selected; that is project convenience,
not an activation prerequisite.

Software/project compatibility is governed by product/API, canonical, target,
producer/provider, state, history, product, application, and dependency
versions at their existing owners. It is checked when the selected software is
asked to validate, diagnose, or operate on the resolved project. An
incompatible operation fails before mutation and explains the boundary. The
operator may separately update the project through an authorized process or
reactivate an older version; activation itself does neither.

Durable operational scope already retains product/development/API and component
attribution. No distribution/build/installation identity is added to history.
Platform Architecture principle 16 and its release section establish that a
published version/tag/assets are immutable, reproducible from declared
evidence, never rewritten for forward development, and never rebuilt in place.
The historical `v0.1.0` publication procedure demonstrates the same authority:
after verified publication it advanced development to `0.2.0-dev` and never
changed the published tag. Therefore one published product version identifies
one official release content; a materially different official build under the
same version is invalid, not another provenance case to encode. Development
executions continue to use existing development/component provenance. Install
manifests and digests still prove local integrity but are not analytical
identity and require no history/state schema change or migration.

Rollback is the software-only reactivation of a still-installed verified prior
version. It does not inspect projects or undo runs, products, manifest edits,
state migration, or project changes made while another version was active. A
later project operation through that version performs compatibility checks and
may fail without mutation. This is not permission to rewrite project state.

Uninstall requires an exact inactive selector. It validates ownership against
the installation manifest, refuses unexpected or linked content rather than
deleting ambiguously, removes only that version root, and leaves the shared
launcher while another installation exists. Removing the final inactive
installation may remove an empty activation record/shared launcher only through
their own exact ownership rules. Projects are never inputs to deletion and are
never traversed.

Automated project migration and state migration are not Stage 11 escape
hatches. An incompatible project remains untouched and operable with its prior
installed version. Migration planning/implementation requires a separate
authorized lifecycle and source/state preservation evidence.

### Historical reuse assessment

Reconnaissance covered immutable `v0.1.0` operation documentation/registry,
operator doctor, Hospital distribution contract/builder/standalone validator,
release preparation/acquisition proof, Phase 11 adversarial distribution tests,
and the later pre-reset installed-software/project-model assessment.

| Historical concept | Classification | Stage 11 disposition |
| --- | --- | --- |
| Operation IDs, declared purpose/mutation/classification/documentation, structured result and stable diagnostics | Directly reusable in intent | Rehouse under package-owned operations and the CLI command table; retain explicit mutation/recovery reporting. |
| Human operator manual organized by intention and recovery, with read-only doctor severities | Reusable after adaptation | Produce version-matched installed guides for explicit projects/installations; remove repository commands and reference-only defaults. |
| Doctor rows, pass/warning/failure aggregation, no-repair behavior, removed write probes, and nonzero blocking status | Reusable after adaptation | Split into installed and project doctors and reuse current 1.0 operation-result/diagnostic contracts. |
| Positive source map, safe regular-file copying, no-link/path checks, exact inventories, SHA-256, staged validation/promotion, idempotency/conflict, and standalone copied validation | Directly reusable in mechanics after owner/format adaptation | Apply to a package/resource/launcher distribution and version installation, not a Hospital or whole-repository tree. |
| Logical instance identity separate from build occurrence/path/time | Directly reusable | Define distribution content identity separately from build and installation occurrence; exclude output/project paths. |
| Clean acquisition proof with no authoritative/sibling lookup | Reusable after adaptation | Validate a local distribution, repository-restored private library/resources, and non-Git project outside source. Network use for configured dependency repositories is recorded rather than prohibited. |
| Release-preparation clean revision, governance/license checks, immutable tag/assets, conflict behavior, and post-release development transition | Directly reusable policy; implementation partly later | Use exact source/build provenance for accepted development builds and preserve one-content-per-published-version authority; keep release authorization/publication in Stage 14. |
| Historical root/top-level `renv` environment | Conceptually useful only as restoration evidence | Evaluate `renv` as internal per-installation machinery; never expose its files or mental model in hospital projects or normal CLI operation. |
| Platform candidate as full tracked tree, embedded Platform archive, managed extraction, generated Hospital distribution/Git realization | Obsolete under RRP 1.0 | Do not restore. The payload is installed software and an independent project remains separately owned. |
| Root `Rscript operations/*`, repository-root inference/source chains, temporary `rrpruntime` installation per command | Obsolete | Replace with installed namespaced dispatch through a version launcher. |
| Closed checksums over recipient-editable hospital implementation and pristine Git/remote rules | Obsolete | Inventory immutable software only; validate project contracts/compatibility without Git requirements. |
| Pre-reset recommendation for installed contracts/default adapters/app, explicit project context, private software library, and separation of maintainer/project validation | Directly reusable architecture intent | Already realized in Stages 2–10; Stage 11 supplies its distribution and human lifecycle. |

Historical code is a test/mechanics reservoir. It is not copied wholesale and
does not establish a second active operation registry, YAML-based executable
configuration, generated Hospital product, ambient library path, global project
ownership, or byte-closed/offline third-party package mirror.

### Open questions after planning iteration 2

**Remaining implementation-blocking questions: none.** Human review resolved
the prior seven questions as recorded throughout this second-edition plan.
Exact flag spelling beyond the accepted command forms, colors, progress
indicators, archive filenames, internal function names, selection of a capable
dependency-restoration engine, and repository-client mechanics are bounded
implementation choices. They must satisfy the contracts and evidence here but
do not require another product/architecture decision unless implementation
uncovers contradictory evidence.

The first edition's seven-increment sequence becomes eight increments below.
Distribution assembly and network-backed private-library realization are now
separate evidence boundaries, and project-independent activation/installed
diagnosis is proved before the side-by-side transition lifecycle.

### Increment 11.A — Lifecycle authorities and stable operation completion

**Objective:** encode the reviewed lifecycle/output decisions and add only the
contracts and stable package operations that later CLI/distribution behavior
must delegate to.

**Architectural responsibility:** `rrpplatform` continues to own project and
product orchestration; distribution/installation authorities own software
lifecycle identity, inventory, compatibility, and result shapes. The CLI owns
none of their semantics.

**Concrete scope and expected surfaces:**

- catalog exact distribution, dependency-specification, installation,
  activation, installed-doctor, project-status/doctor, and versioned JSON CLI-
  result authorities needed by the accepted decisions, using dependency-light
  parseable formats;
- define product/distribution/build/installation/activation identities and
  compatibility without conflating them with package/project/state identity;
- add a package-owned read-only project lifecycle diagnosis/status operation
  composed from existing validators/readers;
- add one package-owned logical-build-plus-materialize operation over the
  accepted product APIs, preserving explicit scope/cutoff and atomic
  publication;
- add the narrow installed fictional-source preparation operation required by
  reference acceptance without generalizing hospital ingestion; and
- preserve existing durable product/development/API/component attribution;
  distribution/build/installation identity remains software integrity evidence
  and does not change history contracts or state.

**Non-goals:** no CLI parser, distribution archive, installer, launcher,
activation, dependency restoration, project migration, source adapter, history
schema, new risk semantics, automatic run/product refresh, or app change.

**Dependencies:** accepted Stages 1–10 and the reviewed decisions above.

**Acceptance and evidence:** exact contract/resource closure; package-native
positive/adversarial tests; status/doctor read-only and privacy evidence;
product composition equivalence with the existing two calls; fictional-only
guarding; exact export/dependency posture; both packages build/check/install;
existing Stage 4–10 regressions; repository/package validators. Tests must
prove no project mutation by status/doctor and no product/history mutation on
failed composition.

**Historical reuse:** adapt operation-result/doctor severity and recovery
semantics; do not restore the old operation registry or repository doctor.

**Documentation:** update installed technical/user documents only for realized
operations, ownership guidance, source catalog, package references, and the
implementation record. Record the reviewed decisions actually realized.

### Increment 11.B — Version-specific CLI foundation and deterministic runtime

**Objective:** implement the thin package-backed command dispatcher and one
version-specific invocation boundary before adding broad project commands.

**Architectural responsibility:** a small launcher establishes exact R/library/
resource context; `rrpplatform` parses and dispatches to stable operations and
renders common results.

**Concrete scope and expected surfaces:** implement the accepted single `rrp`
launcher grammar and shallow noun families, help/version, common path/time/
identity parsing, exact-working-directory project resolution, default human
output, explicit `--json` against the versioned privacy-safe schema,
diagnostic/exit mapping, safe confirmation, subprocess context, signal
behavior, and exact software-root/private-library preflight. Initially prove
`version` and bounded read-only dispatcher commands against an explicitly
supplied installed context; active selection arrives in 11.F.

**Non-goals:** no domain logic, distribution build, installation registry,
shared active launcher, implicit project discovery, shell completion, remote
calls, telemetry, or styled interactive framework.

**Dependencies:** 11.A.

**Acceptance and evidence:** fresh-process invocation from unrelated working
directories; exact package/resource resolution; ambient-library and user-
profile exclusion; usage/success/warning/failure/interruption statuses; exact
human/JSON semantic equivalence; curated JSON fields/schema version and
invalid-object denial; privacy-safe diagnostics; no mutation for read-only
commands; package-native and isolated-installed tests.

**Historical reuse:** operation purpose/mutation metadata and wrapper exit
semantics are adaptable; root script path inference/source chains are rejected.

**Documentation:** add cataloged CLI conventions/help discovery documentation,
package references, ownership/validator entries, and the implementation record.

### Increment 11.C — Project lifecycle CLI and operator intentions

**Objective:** expose the smallest coherent project-facing command set over
accepted APIs and the 11.A compositions.

**Architectural responsibility:** the CLI transports explicit intent and
context; packages remain the behavior owner; project code/state remain outside
the installation.

**Concrete scope and expected surfaces:** implement standard/reference project
initialization with required positional destination paths governed by existing
create/absence safeguards and no current-directory default; fictional source
preparation; project validate/doctor/status; state initialize/inspect/backup/
restore; durable run, focused history reads and corrections, product
materialization/status, and app launch from the command table. For operations
on an existing project, use exactly `--project PATH` when supplied and
otherwise the exact current directory; never search parents or retain project
state. Continue to require explicit analytical/correction identities. Render
returned IDs so subsequent commands are usable. Preserve separation among run,
products, and app.

**Non-goals:** no generic source acquisition, project editor/wizard, scheduled
runs, daemon, automatic refresh, arbitrary SQL, clinical/model validation,
project discovery/registry, migration, custom app logic, or deployment.

**Dependencies:** 11.B and the corresponding accepted Stage 4–10 operations.

**Acceptance and evidence:** command-level success/failure tests over standard,
fictional, copied non-Git, empty, incompatible, stale, and corrupt-safe
fixtures; supplied-path precedence, exact-CWD default, and parent-search/
remembered-project denial; exact mutation assertions per command; controlled
confirmation for restore/corrections; no direct DuckDB/source internals; app
supervision; API-versus-human/JSON result equivalence; all package regressions/
build/check/install.

**Historical reuse:** adapt the old operator manual's intent/recovery teaching
and thin-wrapper discipline; reject reference-default roots and repository
operation scripts.

**Documentation:** catalog an installed Operator Guide that explains explicit
project context, command intents, IDs/cutoffs, mutation/recovery, advanced R
APIs, and the reference-versus-hospital boundary; update help, ownership,
validators, and implementation record.

### Increment 11.D — Closed RRP payload and reproducible dependency specification

**Objective:** transform exact maintained source into one independently
verifiable distribution foundation containing the completed RRP-owned CLI,
packages, resources, documentation, standalone verifier, and reproducible
third-party dependency specification.

**Architectural responsibility:** maintainer build tooling owns assembly; the
generated distribution manifest/inventory owns payload discovery; ordinary
installed code never reads development source paths.

**Concrete scope and expected surfaces:** add the positive RRP source inclusion
authority; exact `rrpruntime`/`rrpplatform` artifacts; a target-keyed
reproducible specification of the tested dependency graph plus repository/
source/integrity provenance; resource projection; license/document/version-launcher
inclusion; generated manifest/inventory/SHA-256 for the RRP-owned payload;
normalized-content identity; staging/promotion; archive creation; and a
distribution-contained standalone validator. Require one explicit output
destination and preserve existing output on failure. Evaluate `renv` and other
capable restoration engines against the public requirements without making the
engine a project or CLI contract. Do not add a placeholder bootstrap: 11.E
adds the real small bootstrap when shared installation mechanics exist.

**Non-goals:** no whole-tree archive, root development environment as installed
authority, bundled transitive CRAN artifacts/local package mirror, offline-
installation claim, package registry publication, signing, bootstrap/user
installation, active pointer, project content, artifact/deployment build, or
release claim.

**Dependencies:** 11.C and the clean accepted-build policy above.

**Acceptance and evidence:** deterministic logical identity for equal declared
inputs; exact inventory/digests/roles; missing/extra/altered/linked/traversing/
case-conflicting/dependency-specification drift failures; standalone copied
payload validation with no checkout/sibling lookup; projected 54-plus-Stage-11
resource closure; exact internal package and dependency-specification/license
agreement; no bundled third-party-closure assumption; source-tree hygiene and
cleanup.

**Historical reuse:** adapt v0.1.0's positive source map, safe copy, tar/inventory,
SHA-256, instance/build identity, atomic promotion, standalone validation, and
adversarial tests. Reject embedded full Platform and Hospital payloads.

**Documentation:** add maintainer build/validation guidance and installed
distribution contents/acquisition-integrity guidance; update ownership,
validators, and implementation record.

### Increment 11.E — Bootstrap installation and private dependency restoration

**Objective:** install one local distribution into an immutable OS-standard
per-user version root by restoring and verifying its dependency specification
inside a private R library.

**Architectural responsibility:** a small base-R bootstrap delegates to shared
installation mechanics that own staging, configured-repository restoration,
private-library realization, and promotion. It owns no project behavior or
second installer implementation.

**Concrete scope and expected surfaces:** realize the accepted OS-standard per-
user application-data layout and test override; record/validate host R; accept
explicit configured R repositories; restore the environment described by the
reproducible dependency specification into a staged version-private library
without ambient substitution; install
the exact RRP packages; validate package/resource/dependency agreement in fresh
processes; write installation evidence; and promote only after success. Add
the small distribution-local `install.R` and installed `rrp software install
PATH` path over the same mechanics; include bootstrap/shared-install material
in the positive distribution authority; rebuild and independently validate the
complete installable distribution. Do not activate in this increment.

**Non-goals:** no system/root install, bundled R, offline guarantee, bundled
third-party closure, PATH/profile editing without explicit operator action,
activation, project input/registry/source/state change, migration, shared
runtime library, background update, distribution discovery, or publication.

**Dependencies:** 11.D.

**Acceptance and evidence:** the documented download/unpack/`Rscript --vanilla
install.R` path from a copied distribution outside Git; configured-repository
restoration with recorded safe provenance; network/repository/lock/package/
compile failures preserve existing installations; idempotent exact reinstall
and loud conflict; exact private package resolution in fresh processes;
ambient/user/site-library adversarial proof; bootstrap and later CLI install
equivalence; no project lookup or project file access; no `renv` or equivalent
files in initialized projects; source-tree and staging cleanup.

**Historical reuse:** staged extraction/promotion and dependency restoration
evidence are adaptable; nested Platform extraction, a hospital top-level
`renv`, offline embedded closure, and repository doctor are rejected.

**Documentation:** catalog Installation and Software Lifecycle guides covering
prerequisites, local acquisition, configured repositories, private restoration,
roots, R selection, failure recovery, internal-only restoration machinery, and
ownership; update help/ownership/validators/record.

### Increment 11.F — Active-version resolution, installed verification, and software doctor

**Objective:** install the stable per-user `rrp` shim, select verified software
independently of projects, and make installed health understandable.

**Architectural responsibility:** the shared shim and activation owner resolve
only installed software; the version launcher establishes deterministic R/
library/resource context; installed verification and doctor inspect only
software/environment readiness.

**Concrete scope and expected surfaces:** install the stable executable shim in
the appropriate per-user executable convention; implement list/current, exact
software selector override, strict installed verification, software doctor,
and atomic activation; pass the immutable version context to fresh R processes;
record no project path; and preserve prior activation on any verification or
pointer failure. Activation accepts only an installed selector. An operator may
separately run project validation under an explicitly selected version, but no
association is stored.

**Non-goals:** no project input/discovery/registry/compatibility gate,
dependency repair, automatic activation during later installs, project/state
mutation, migration, background updater, remote discovery, or uninstall.

**Dependencies:** 11.E.

**Acceptance and evidence:** OS-standard default and isolated test-root
behavior; shared-shim invocation from unrelated directories; exact active and
explicit-selector resolution; atomic activation and failure preservation;
strict manifest/dependency/private-library/resource verification; doctor
pass/warning/failure/recovery semantics; ambient-library denial; explicit proof
that install/verify/doctor/activate neither locate nor access a project; human
and JSON equivalence; conventional signals/status.

**Historical reuse:** adapt doctor aggregation, removed probes, pointer
promotion, and thin wrapper behavior. Reject repository defaults, project
preflight inside activation, and any last-project state.

**Documentation:** complete installed verification, activation, selector, shim,
and software-doctor guidance; document that project compatibility begins only
at a project command; update ownership/validators/record.

### Increment 11.G — Side-by-side upgrade, rollback, and exact uninstall

**Objective:** prove the complete non-mutating software version transition
lifecycle over retained independent projects.

**Architectural responsibility:** version management changes only installed
software and activation state. A subsequent project operation, not activation,
decides whether selected software may operate on its resolved project.

**Concrete scope and expected surfaces:** install two distinct development
versions/builds side by side; verify and activate the newer one without project
access; show that an incompatible project operation fails clearly without
mutation; reactivate the prior verified version without project access; show
that the project can then be separately operated when compatible; uninstall an
exact inactive version; handle final-version/shared-launcher rules; and
preserve actionable evidence/recovery. Official published-version conflicts
fail rather than model multiple materially different official builds under one
version.

**Non-goals:** no in-place overwrite, automatic project/state migration,
downgrade transformation, automatic deletion/retention policy, remote updater,
release channel, or rollback of analytical history/products.

**Dependencies:** 11.F and two controlled distinct development identities
whose compatibility claims are explicit.

**Acceptance and evidence:** side-by-side inventory isolation; activation and
rollback atomicity; activation has no project input; incompatible project
operation fails before mutation; project regular-file/state digests prove all
software lifecycle operations are nonmutating; history retains existing
software/component attribution without distribution fields; active/tampered/
unknown uninstall refusal; inactive exact removal; other versions/shared
launcher remain functional; repeated cleanup is bounded.

**Historical reuse:** immutable build/pointer/idempotency/conflict patterns are
adaptable. v0.1.0 two-product release coupling and publication rollback are not.

**Documentation:** complete upgrade/rollback/uninstall and compatibility
recovery guidance; update help, validators, ownership, and implementation
record.

### Increment 11.H — Clean installed operation proof and Stage 11 closeout

**Objective:** prove the complete Stage 11 operator experience from exact local
distribution bytes outside the repository and reconcile it with True North and
the architecture.

**Architectural responsibility:** acceptance composes the supported development distribution,
installer, launcher, CLI, package APIs, independent project, and software
lifecycle without adding behavior.

**Concrete scope and expected surfaces:** run a supervised clean temporary-user
proof from a copied distribution; restore dependencies/install/verify/activate;
record configured repository/restoration evidence; initialize and prepare
the fictional project; validate and initialize state; execute two governed
analytical times; inspect history; materialize products; construct/launch the
app; run both doctors; install/verify/activate a second development version;
encounter a controlled incompatible project operation without mutation;
operate the unchanged project with a compatible selection; roll back by
software-only activation; uninstall the inactive version; and
retain bounded privacy-safe acceptance evidence. Complete version-matched
human guidance and hosted verification appropriate to the new build/install
claim.

**Non-goals:** no independent hospital/adopter authoring acceptance (Stage 13),
deployment artifact/target (Stage 12), public download/publication (Stage 14),
clinical validation, migration, or production support claim.

**Dependencies:** 11.A–11.G complete and locally accepted.

**Acceptance and evidence:** repository/package/CLI/distribution/install tests;
both package build/check/install; standalone RRP payload validation; no
source/sibling/ambient-library lookup after acquisition; exact configured-
repository dependency restoration and failure evidence; exact RRP inventory/
digests/provenance; copied non-Git project; run/history/product/app
equivalence with Stage 10; signal/process cleanup; two-version lifecycle;
project nonmutation by software changes; privacy/adversarial failures; hosted
workflow success on the exact committed candidate before formal acceptance.

**Historical reuse:** adapt clean acquisition and standalone copied validation
while permitting declared dependency-repository access; do not restore release
publication or generated Hospital acceptance.

**Documentation:** finalize installed Operator, Installation, and Software
Lifecycle guides; append actual implementation/evidence to the implementation
record; then perform a separate formal Stage 11 acceptance and architecture
reconciliation. Do not mark Stage 11 complete merely because one local script
passes.

### Final Stage 11 operator acceptance experience

The accepted command taxonomy permits a final human workflow no more complex
than this illustrative sequence:

```text
download and unpack the appropriate RRP development distribution
        ↓
cd <unpacked-distribution>
Rscript --vanilla install.R
  (restores the declared dependencies from configured R repositories)
        ↓
rrp software verify
rrp software doctor
        ↓
rrp reference init ~/Projects/fictional-hospital
cd ~/Projects/fictional-hospital
rrp reference prepare-source
rrp project validate
rrp state init
        ↓
rrp run --at 2026-01-19T12:00:00Z --operation-key accepted-first
rrp history scope --scope <returned-id>
rrp products materialize \
  --scope <returned-id> --cutoff 2026-01-19T12:00:00Z
rrp app launch \
  --scope <returned-id> --cutoff 2026-01-19T12:00:00Z
        ↓
repeat run + materialization at a later analytical time
and observe the actual two-point trajectory after relaunch
        ↓
rrp project doctor
rrp project status --json
        ↓
rrp software install /local/newer-distribution
rrp software verify --software <newer-selector>
rrp software activate <newer-selector>
        ↓
rrp project validate
operate the same project if compatible;
otherwise fail without mutation and select compatible software
        ↓
rrp software activate <prior-selector>
rrp software uninstall <inactive-selector>
```

The human no longer builds packages, resolves dependency order, projects
resources, configures R libraries, opens catalogs, loads packages, or knows
source-repository paths. They need access to the configured R package
repositories during installation but do not manage restoration internals.
They still deliberately choose project location,
configure hospital-owned source/model behavior, name analytical time and
operation identity, select product/history context, authorize corrective/
destructive actions, and decide which verified software version is active.

### Stage 11 acceptance criteria and plain-language exit state

Stage 11 is acceptable only when:

1. one positive inclusion authority builds a non-repository distribution with
   exact closed RRP-owned package/resource/document/installer/launcher content,
   reproducible dependency specification, inventory, SHA-256, and provenance;
2. copied RRP payload bytes validate without source, sibling, Git, project, or
   maintainer state; installation may access only configured dependency
   repositories and never an ambient user/site library;
3. the one-command base-R bootstrap and later `rrp software install PATH` share
   installation mechanics, restore the specified dependency environment from
   configured repositories, and promote one exact immutable version with its
   own private library/resources and recorded host R;
4. the shared launcher deterministically reaches the active or explicitly
   selected version, leaves the active record unchanged for a per-invocation
   selection, and cannot resolve RRP packages from ambient libraries;
5. installed verify/doctor and project validate/doctor have distinct truthful
   scope, structured results, exit status, and recovery without repair;
6. the canonical `rrp` noun taxonomy invokes package-owned operations for the
   complete reference project run/history/product/app path, requires an
   explicit positional destination for project/reference creation, defaults
   existing-project commands to the exact current directory, honors explicit
   `--project`, never searches parents, and introduces no parallel domain
   implementation;
7. default human output and explicit `--json` are equivalent renderings with
   meaningful exit status, a stable versioned JSON schema, and deliberate
   privacy-safe fields;
8. install, activate, failed activation, rollback, and uninstall accept no
   project input, discover/associate no project, and never silently alter or
   delete project source/state;
9. incompatible software/project combinations fail when a project operation is
   requested and before project mutation, while prior installed versions remain
   independently selectable;
10. exact inactive uninstall removes only owned installed content and refuses
   active, unknown, linked, unexpected, or tampered targets;
11. version-matched installed guidance teaches acquisition integrity,
    configured-repository restoration and private-library isolation without
    exposing restoration-engine machinery as the project/user model,
    installation, CLI, project operation, diagnostics, upgrade/rollback,
    uninstall, advanced R access, and all deferrals; and
12. clean local and hosted evidence passes on the exact candidate, followed by
    formal reconciliation against True North and Platform Architecture.

> A human can acquire a development distribution with a closed RRP-owned
> payload and reproducible dependency specification, restore/install and verify
> it outside the source tree, initialize and operate an independent project
> naturally from its directory through one CLI, and select, upgrade, roll back,
> and uninstall side-by-side RRP software without any software lifecycle action
> inspecting or modifying project source/state. Product-only deployment
> artifacts are not yet implemented.

### Major deferrals

System-wide/root installation; bundled or automatically installed R; Windows
support beyond a separately accepted support cell; automatic PATH/profile
editing; remote RRP-distribution discovery/download, release channels, RRP
package registries, or update services; offline installation and redistribution
of the full third-party package closure; signing/key/transparency policy;
shared mutable dependency caches as runtime authority; automated project or
state migration;
project discovery/registry; scheduling/daemons/background refresh; generic
hospital source acquisition; authentication/authorization; telemetry/remote
monitoring; product-only artifacts; Posit Connect/Connect Cloud or other target
realizations; OCI/container deployment; remote deployment; Stage 13 clean
independent-adopter/support-matrix acceptance, including clean restoration from
configured package repositories on each claimed OS/R cell but not an artificial
offline/bundled-closure test; Stage 14 release qualification,
tagging, publication, public acquisition, and public immutability evidence; and
clinical validation remain outside Stage 11.

## Stage 12 — Product-only artifacts and deployment realizations

### Objective and responsibilities

Build a closed target-neutral product-only application artifact from exact
installed resources and a frozen coherent product set. Add independent
self-validation, inventory/digests/provenance, then realize the same artifact
for a broadly Posit-compatible target with Connect Cloud evidence and for an
OCI/Docker target. Keep build, validation, and external deployment distinct.

### Why here and dependencies

Artifact closure depends on a real installed software boundary and stable
product/app subset. Target wrappers come last within the stage so they cannot
redefine upstream behavior.

### Plain-language exit state

> RRP can generate and independently validate portable product-only
> application artifacts for Posit-compatible and OCI environments. Publishing
> or deploying them is still an explicit external operator action.

### Expected historical reuse

Inspect `v0.1.0` target-neutral artifact allowlist, inventory/integrity,
standalone validation, and Connect Cloud realization. These mechanics are
likely adaptable to installed inputs and release dependency evidence. OCI is
new work sharing the accepted artifact; Hospital Git realization and any
compute-capable payload are excluded.

### Major deferrals

Remote deployment, credentials, registry ownership, production networking,
monitoring, self-managed Posit support claims, and compute-capable artifacts
remain operator-owned or future work.

## Stage 13 — Clean-system and adopter acceptance

### Objective and responsibilities

Prove the architecture's complete clean-install matrix on declared macOS arm64
and Ubuntu x86_64 evidence cells: distribution install/doctor, fictional
project, separate adopter project, custom producer and provider, dependency
isolation, reproducible dependency restoration from configured repositories,
durable history, products/app, both artifact families, version activation/
rollback, and privacy/safety failures. This matrix does not require bundled
third-party artifacts or offline installation unless later evidence creates
that distinct product requirement. Close all temporary development bridges
whose replacement conditions have passed.

### Why here and dependencies

Only a complete candidate can prove that the development tree, installed
software, project, state, and artifacts are genuinely independent. This stage
turns accumulated component evidence into a supportable system claim before
release metadata is frozen.

### Plain-language exit state

> Independent clean environments and a separately authored adopter project
> prove the complete RRP 1.0 product boundary and supported platform cells. The
> software is accepted as a release candidate but is not yet published as
> version 1.0.0.

### Expected historical reuse

Inspect `v0.1.0` independent adopter, Hospital acquisition, clean-copy,
artifact, publication preflight, and privacy/adversarial tests for invariant
ideas. Rehouse still-valid proofs under current lifecycle owners. The Hospital
product, embedded archive, two-release relationship, Phase aggregates, and
Git cleanliness as project validity do not return.

### Major deferrals

Clinical validation, production authorization, additional OS/R cells,
performance/service objectives, signing mechanism, and actual remote
publication remain outside this acceptance claim.

## Stage 14 — Release qualification and publication

### Objective and responsibilities

Freeze exact `1.0.0` candidate identity from a clean authorized revision;
produce licenses, notices, changelog, support/security, source and distribution
artifacts, dependency/build evidence, checksums and any accepted authenticity
evidence; require explicit publication authorization; verify immutable remote
identity/assets; and prove public reacquisition, installation, doctor, example,
and recovery behavior.

### Why here and dependencies

Publication is a lifecycle mutation, not another form of development
validation. It follows complete Stage 13 acceptance so release tooling never
defines or compensates for missing product behavior.

### Plain-language exit state

> The exact accepted RRP 1.0.0 software is immutably published, publicly
> reacquirable, independently verifiable, and supported by complete release
> evidence; forward development can begin only under a new development
> identity.

### Expected historical reuse

Inspect `v0.1.0` release preparation/publication separation, authorization
guards, exact tag/asset verification, checksum handling, recovery, and public
acquisition proof. Substantial safety mechanics may be adapted to one installed
RRP product. The two-product Platform/Hospital release choreography, full-tree
payload, and version-specific hard-coding must not return.

### Major deferrals

Publication provider, signing technology, final asset formats, retention, and
support-matrix expansion are decided from Stage 13 evidence. No publication,
tag, remote, or release is authorized by this plan itself.

## Cross-stage validation growth

Validation enters with its owner and grows only with real claims:

| Capability present | Evidence added |
|---|---|
| Source foundation | structure, links, identity, legal/public consistency, hygiene |
| Packages | build/check, isolated install/load, namespace and dependency direction |
| Resources/operations | catalog/access adversarial cases, structured result/privacy checks |
| Projects | recognition, trust, paths, compatibility, dependencies, secret exclusion |
| Canonical/provider/runtime | specification and semantic conformance, temporal and failure cases |
| History | atomicity, retry, conflict, invalidation/restatement, reopen/recovery |
| Products/app | logical conformance, freshness/lineage, product-only integration |
| Distribution/installation | closure, inventory/digests, environment isolation, lifecycle safety |
| Artifacts/targets | independent closure, boundary, integrity, target behavior |
| Acceptance/release | clean matrices, adopter proof, authorization, acquisition, immutability |

Named lifecycle/component profiles may be introduced once there is more than
one executable owner to route. No future validator is predeclared merely to
resemble the final system. Passing software validation never implies clinical
validity, deployment approval, or publication authorization.

## Historical evidence intentionally excluded from the design

The following may be inspected for lessons but are not planned compatibility
requirements:

- repository-root scripts, global source order, or current-working-directory
  discovery as installed behavior;
- the generated Hospital Implementation repository, embedded Platform archive,
  or two-product adopter/release model;
- Phase 0–11 chronology, Phase-named test ownership, frozen legacy aggregates,
  and transition machinery whose only purpose was coexistence with that tree;
- temporary per-operation installation of runtime packages;
- full tracked-repository distribution payloads or ignore-subtraction closure;
- Git commits, remotes, or clean working trees as project identity or validity;
- public daily-hazard target/request/estimate/product semantics or silent
  conversion of those records into 1.0 remaining risk;
- generic runtime conditionals for synthetic, hospital, source-system, or
  provider implementation identity; and
- compatibility shims whose only consumer is historical repository behavior.

The `v0.1.0` release itself remains immutable and usable in its own historical
context. Exclusion from this design is not alteration of that release.

## Decisions deliberately left to progressive planning

The architecture settles responsibilities; later detailed plans will settle
mechanisms when evidence is available. Deliberately open items include:

- later exported APIs and package source files beyond the accepted Stage 3
  resource/result boundary;
- installed layout, launcher/installer technology, activation location, and
  exact host-R discovery mechanics;
- later domain resource, project, canonical, target/request, provider, history,
  product, artifact, and realization identifiers and schemas;
- project registration file syntax and extension dependency/conflict mechanics;
- final distribution placement of packages and ordinary installed resources;
- final distribution manifest, dependency resolution, reproducibility,
  archive, signature/authenticity, and acquisition mechanisms;
- migration and any separately typed legacy-history archive contract;
- artifact, Connect Cloud, and OCI build details and support cells;
- validation profile graph, CI matrix, and release support matrix; and
- release host/provider and explicit remote publication procedure.

Each decision is resolved in the first stage that needs it. A decision that
would change an accepted architectural responsibility must update the
architecture explicitly before implementation.

## Roadmap completion test

Before calling RRP 1.0.0 complete, maintainers must be able to read the four
governing documents in order and then inspect source/evidence to show that:

- the blank-slate roadmap still derives from the accepted target rather than
  historical layout;
- useful historical implementation was selectively reused without importing
  historical architecture;
- each responsibility has the owner and dependency direction defined by the
  architecture;
- a human can follow the implementation record from the minimal baseline to
  the installed, project-based product;
- no mechanism exists solely to keep a superseded workflow alive; and
- the complete clean-install, independent adopter, artifact, and publication
  acceptance described by the architecture has passed for every claimed
  support cell.
