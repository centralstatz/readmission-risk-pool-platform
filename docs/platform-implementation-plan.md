# RRP 1.0.0 implementation plan

## Status and authority

**Status:** authoritative high-level roadmap; Stages 1–4 are accepted and
complete. The next planning task is to detail Stage 5 from the accepted Stage
4 baseline; Stage 5 source implementation is not yet authorized.

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

Only the current stage is decomposed into accepted increments. Stage 4 is the
most recently detailed and accepted stage; completed Stage 1–3 detail remains
as implementation lineage. Stage 5 remains high-level until its separate
planning task. After a stage is implemented:

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
| 11 | CLI, closed distribution, installation, and upgrade | A human can build, install, verify, activate, operate, upgrade, roll back, and uninstall versioned RRP software without mutating a project, but deployment artifacts are not yet available. |
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
CLI + closed software installation lifecycle
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

### Objective and responsibilities

Define the 1.0 specification envelope, canonical bundle/profile and domains,
temporal availability rules, capabilities, producer declaration/result, and
admission operation. Execute exactly the selected trusted producer and admit
or reject its representation-independent candidate before generic behavior.

### Why here and dependencies

The generic runtime cannot be designed or tested honestly until project-owned
source interpretation stops at a precise admitted boundary. Stage 4 supplies
the trust and selection context; Stage 3 supplies resource lookup and results.

### Plain-language exit state

> A project-selected producer can submit source-independent episode data that
> RRP validates and admits with identity, relationship, capability, and
> temporal evidence. RRP still does not construct a risk request or estimate.

### Expected historical reuse

Inspect `v0.1.0` specification envelope, canonical bundle and readmission
profile contracts, validation code, producer result/admission sequence, and
their success/adversarial tests. Substantial vocabulary and relationship logic
are likely adaptable. Revise profile coverage and terminal occurrence/
availability semantics for the fixed 1.0 endpoint; keep all source-specific
tables and mapping assumptions below the handoff.

### Major deferrals

The singular target request, provider invocation, durable history, source
implementations, products, and application remain absent. Admission alone
makes no clinical-validity claim.

## Stage 6 — Singular target, runtime, and provider execution

### Objective and responsibilities

Implement the one nonselectable remaining cumulative day-30 readmission-risk
target; eligibility; immutable as-of episode state; standard request;
controlled provider registry, compatibility, and invocation; accepted estimate
semantics; and structured failures. Include a transparent nonclinical provider
as maintained example code without privileging its identity in generic runtime.

### Why here and dependencies

Runtime state can use only admitted canonical information and must resolve the
provider selected by an already validated project. This is the first stage
that can make an analytical claim, isolated from persistence and application
concerns.

### Plain-language exit state

> RRP can decide which admitted episodes are eligible at an as-of time,
> construct the one standard remaining day-30 risk request, and return one
> validated provider estimate or a structured failure. It does not yet retain
> operational history.

### Expected historical reuse

Inspect `v0.1.0` `rrpruntime` temporal/state primitives, provider registry,
compatibility/execution, bounds/cardinality validation, transparent provider,
and tests. Provider mechanics and much defensive validation are likely
substantially adaptable. The public daily-hazard estimand, shortened follow-up
logic, old estimate identities, and any source-specific assumptions must be
replaced—not renamed—with fixed-endpoint cumulative remaining-risk semantics.

### Major deferrals

Persistence, retrospective reconstruction, multiple targets, remote/non-R
providers, uncertainty/explanations, clinical model validation, decision
policy, and scheduling remain excluded.

## Stage 7 — Project state and operational history

### Objective and responsibilities

Define target-attributed logical history records and a storage-neutral port;
append atomic terminal run batches; implement idempotency/conflict, retry,
invalidation/restatement, raw/current reads, and state compatibility; and
supply a project-path local DuckDB adapter with explicit initialize, reopen,
backup, and recovery behavior.

### Why here and dependencies

History records what the complete Stage 6 computation actually knew and did.
It must precede products, which are rebuildable views of this operational
truth, while remaining separate from the physical adapter.

### Plain-language exit state

> RRP can preserve and reopen attributable run, state, request, execution,
> estimate, and correction history in project-owned storage without rewriting
> earlier facts. It still has no application-facing products.

### Expected historical reuse

Inspect `v0.1.0` history ports/records, append semantics, in-memory tests,
DuckDB schema/session/transaction adapter, interruption injection, backup, and
reopen tests. The atomicity and correction rules appear substantially reusable;
record schemas and adapter metadata require adaptation to the singular 1.0
target and independent project state. Old daily-hazard records may only be a
separately typed archive, never current estimates.

### Major deferrals

Production databases, multi-writer guarantees, automatic state migration,
retention/encryption infrastructure, products, audit, and retrospective
rescoring remain out of scope.

## Stage 8 — Fictional reference path

### Objective and responsibilities

Create a deterministic, visibly fictional, nonclinical project outside the
installed generic composition. Implement its source generator, mapping,
producer, transparent provider selection, dependency declaration, tests, and
documented run through canonical admission, runtime, and durable history using
the same project boundary available to adopters.

### Why here and dependencies

This is the first meaningful end-to-end computational integration point. It
follows the real boundaries rather than shaping them as a privileged example
mode and gives later product/app stages stable fictional history to consume.

### Plain-language exit state

> A human can run a normal independent fictional project from source mapping
> through durable remaining-risk history and inspect the result. RRP still has
> no logical products or application.

### Expected historical reuse

Inspect `v0.1.0` synthetic data generation, schema, mappings, producer, scales,
deterministic fixtures, and tests. Dataset construction and many canonical
failure fixtures are likely adaptable. The implementation must move into the
normal project form, adopt new target/profile identities, remove installed
synthetic special cases, and remain clearly nonclinical.

### Major deferrals

Real hospital mappings, richer EHR simulation, performance scale claims,
products/app, scheduling, and production governance remain absent.

## Stage 9 — Logical products and materialization

### Objective and responsibilities

Define and build the narrow initial product family—current eligible episode
remaining risk, retained trajectory/history, and terminal run summary—from
valid history through storage-neutral reads. Add versioned set identity,
freshness, lineage, partial/unavailable behavior, and one supplied
materialization/access adapter in project state.

### Why here and dependencies

Products are consumer interfaces over attributable history, not substitutes
for it. They follow the durable fictional path and precede any app so the UI
cannot become the accidental product contract.

### Plain-language exit state

> RRP can build, validate, store, and reopen the initial logical product set
> from project history, including a valid empty state. No supplied user
> application exists yet.

### Expected historical reuse

Inspect `v0.1.0` product identity/conformance/builders, three product roles,
YAML materializer/access adapter, integrity behavior, and tests. The logical
separation and many mechanics are likely reusable after replacing daily-hazard
fields/identities with remaining cumulative risk and routing reads through the
installed/project boundaries.

### Major deferrals

Custom products, direct physical-history queries by consumers, application
behavior, remote product services, decision queues, and metrics remain later
or explicitly deferred.

## Stage 10 — Supplied product-only application

### Objective and responsibilities

Implement the supplied Shiny application as a consumer of validated logical
product access only. Establish application identity, view models, empty/
unavailable/failure presentation, startup validation, and development/reference
launch evidence without source, provider, or persistence knowledge.

### Why here and dependencies

The app can be independently understandable only after the product interface
is stable. Its product-only closure becomes the input to distribution and
artifact work rather than dictating upstream semantics.

### Plain-language exit state

> The supplied application presents fictional remaining-risk products without
> querying sources, running a model, or reading physical history. Complete
> installed operator and deployment workflows still do not exist.

### Expected historical reuse

Inspect `v0.1.0` product-access/view-model/app separation, Shiny components,
startup validation, and zero-row/failure tests. UI structure is likely adapted
because product and target fields change; any repository-path, materialize-on-
launch, or upstream-runtime coupling is rejected.

### Major deferrals

Authentication, production authorization, custom apps, application-triggered
refresh, remote hosting, and deployment-specific behavior remain outside this
stage.

## Stage 11 — CLI, closed distribution, installation, and upgrade

### Objective and responsibilities

Complete stable programmatic operations and place a thin canonical CLI over
them. Define the closed software inclusion manifest, dependency closure,
inventory/digests/provenance, launcher, user-scoped side-by-side installation,
activation, installed/project doctors, clean uninstall, and non-mutating
upgrade/rollback. Ship only version-matched resources and human documentation.

### Why here and dependencies

The distribution can be closed only after its actual software, resources,
reference project, products, and app are known. Operator commands wrap stable
capabilities rather than preserving repository scripts as a public interface.

### Plain-language exit state

> A human can acquire a closed development build, install and verify it outside
> the source tree, initialize and operate projects through one CLI, and change
> active software versions without modifying project source or state. Product-
> only deployment artifacts are not yet implemented.

### Expected historical reuse

Inspect `v0.1.0` human operation documentation, structured operation runners,
doctor/recovery behavior, exact inventory/digest and release-candidate safety
mechanics, plus pre-reset installed-resource/package work. Adapt the stable
intent and integrity rules. Do not revive root `Rscript operations/*` as the
product UX, temporary runtime installation, whole-tree payloads, generated
Hospital distributions, ambient libraries, or Git-state adopter rules.

### Major deferrals

System-wide installation, bundled R, automated project/state migration,
remote package acquisition details, signing policy, deployment targets, and
publication remain later decisions.

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
isolation, durable history, products/app, both artifact families, version
activation/rollback, and privacy/safety failures. Close all temporary
development bridges whose replacement conditions have passed.

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
