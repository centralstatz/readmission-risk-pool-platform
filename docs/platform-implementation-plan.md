# RRP 1.0.0 implementation plan

## Status and authority

**Status:** authoritative high-level roadmap; Stage 1 is complete and Stage 2
implementation is in progress with Increment 2.B complete

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

Only the current stage is decomposed into accepted increments. Stage 2 is the
current detailed stage; completed Stage 1 detail remains as implementation
lineage. After a stage is implemented:

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

**Planning status:** detailed and accepted; implementation in progress with
Increment 2.B complete

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

### Objective and responsibilities

Define how software-owned contracts, defaults, templates, documentation, and
static application assets are cataloged, projected into a future distribution,
and resolved by logical ID from an explicit software root. Add the minimal
common structured operation result and privacy-safe diagnostic vocabulary used
by later programmatic operations. Keep source catalogs distinct from a future
distribution manifest.

### Why here and dependencies

Projects and analytical packages need stable resource and result boundaries;
implementing them first avoids repository-path discovery and incompatible
one-off operation return shapes. This stage depends on the package owners but
not on any clinical resource existing yet.

### Plain-language exit state

> RRP package code can safely find declared installed resources and report a
> structured operation outcome from an explicit software context, but there is
> still no hospital project or risk behavior.

### Expected historical reuse

Inspect pre-reset Increment 2.B's closed resource catalog/schema,
explicit-root `rrp_open_resource_catalog()` and `rrp_resource_path()` design,
copied-root adversarial tests, and `v0.1.0` conformance/operation-event
primitives. The access safety and tests are likely adaptable; the old 48-entry
catalog and transitional daily-hazard inventory are not current content and
must be rebuilt incrementally from actual 1.0 resources.

### Major deferrals

Installed-root selection, the final distribution inventory/digests, launcher,
project context, analytical run identity, persistent diagnostic sinks, metrics,
and audit remain out of scope.

## Stage 4 — Independent project foundation

### Objective and responsibilities

Define and implement the public project contract: explicit root, versioned
nonsecret manifest, fixed trusted registration entry point, safe paths,
software/API compatibility, separate extension dependencies, exact producer
and provider selection, project state location, initializer, loader, doctor,
and failure behavior. RRP defaults remain installed code; only producers and
providers are registrable project extensions.

### Why here and dependencies

Every source, provider, state, and product operation requires unambiguous
project ownership. The project boundary therefore precedes canonical and
runtime code and uses Stage 3's resource and operation primitives.

### Plain-language exit state

> RRP can initialize, recognize, safely load, and validate an independent
> hospital-owned project and its declared producer/provider registrations, but
> it cannot yet admit source data or calculate readmission risk.

### Expected historical reuse

Inspect `v0.1.0` producer registration/result boundary and isolated adopter
fixtures plus the pre-reset project architecture experiments, if any. Reuse
fail-closed selection, safe-path, secret-exclusion, and independent-copy test
ideas. Generated Hospital Implementation repositories, copied RRP source,
Git-state validity, free-form composition sourcing, and runtime hospital
selectors are specifically excluded.

### Major deferrals

Canonical profile details, producer execution/admission, target semantics,
runtime, persistence, project migration, and production identity/access
controls remain later work.

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

- exact internal main-package name, exported API, and initial source files;
- installed layout, launcher/installer technology, activation location, and
  exact host-R discovery mechanics;
- final resource, project, canonical, target/request, provider, history,
  product, artifact, and realization identifiers and schemas;
- project registration file syntax and extension dependency/conflict mechanics;
- the physical split between packages and ordinary installed resources;
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
