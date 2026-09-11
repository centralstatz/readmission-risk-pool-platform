# Readmission Risk Pool platform architecture

## Status and authority

**Status:** authoritative target architecture for the RRP 1.0.0 generation;
implementation and release not yet complete

This document is the current normative architecture of the Readmission Risk
Pool (RRP). It translates [Platform True North](../vision/platform-true-north.md)
into the software, project, analytical, state, product, deployment, lifecycle,
and validation boundaries that the current
[RRP 1.0.0 implementation roadmap](platform-implementation-plan.md) must
realize.
Future contributors should be able to understand the target system here
without reconciling the assessment sequence that produced it.

The published `v0.1.0` tag remains the exact architecture and implementation
record for that release. This document does not reinterpret, migrate, amend,
or claim compatibility with those released bytes. Current executable source
still substantially implements `v0.1.0`; statements below are target
architecture until the implementation record and acceptance evidence say
otherwise.

The current [implementation plan](platform-implementation-plan.md) is the
authoritative high-level RRP 1.0.0 roadmap. The published `v0.1.0` tag retains
the completed Phase 0–11 plan as historical evidence. Supporting assessments
explain why this architecture was selected, but they do not compete with it.

## Purpose and scope

RRP is becoming conventionally installed open-source software for operating a
hospital-owned readmission-risk project. It accepts a trusted local
source-to-canonical producer, constructs temporally valid episode state,
requests one RRP-defined readmission-risk quantity from a selected provider,
retains attributable operational history, builds logical products, serves a
supplied product-only application, and builds closed deployment artifacts.

This architecture governs the development/software boundary, independent
project contract, trusted composition, singular risk target, runtime, state,
products, application, deployment, dependency ownership, upgrades, validation,
release acceptance, and the disposition of `v0.1.0` machinery. It does not
approve clinical use, define hospital policy, implement the new system,
finalize command syntax, or promise a released `1.0.0`.

## Product definition

RRP is the installed software. An RRP project is one hospital's implementation
of the software's public project contract. R is the initial implementation
technology and a host prerequisite, not the normal human interaction model.

```text
RRP development repository
        ↓ closed build and release
versioned installed RRP software
        ↓ CLI + supported programmatic operations
independent hospital-owned RRP project
        ↓ trusted producer / source mapping
canonical admission and RRP runtime
        ↓ standard RRP risk request
project-selected provider and model
        ↓ accepted estimate or structured failure
append-oriented operational history
        ↓
logical products
        ↓
supplied app / closed deployment artifact
```

One RRP installation may operate multiple separately invoked projects, but one
project and one deployment represent one health system. There is no runtime
hospital selector or multi-hospital shared analytical state. The open product
remains independently useful: no proprietary model, agent, package, service,
or CentralStatz engagement is required to operate it.

## Architectural principles

1. Local implementations own source meaning and stop at the canonical handoff.
2. RRP owns exactly one versioned, nonselectable readmission-risk target in the
   1.0.0 generation.
3. Producers and providers are the initial project extension seams; projects
   do not define target semantics or request construction.
4. Generic runtime never branches on a hospital, synthetic example, source
   system, or provider implementation identity.
5. Only information legitimately available by the declared as-of time may
   affect state or estimates.
6. Provider method is replaceable; target meaning, validation, and output
   semantics are not.
7. Structured failure is preferable to fabricated probability, silent
   fallback, or partial history.
8. Operational history is append-oriented, attributable truth. Products are
   rebuildable consumer views, not history authority.
9. Risk, decision/priority policy, tasks, interventions, measures, diagnostics,
   provenance, metrics, and audit remain distinct concepts.
10. The supplied app consumes products and never queries sources, executes a
    provider, or understands history storage internals.
11. Generated artifacts have closed target-specific closure; editable projects
    do not become immutable software artifacts.
12. Software, project, and deployment dependency environments have explicit
    owners and cannot silently override one another.
13. Software upgrades do not mutate project source or state. Project and state
    migrations are separate, explicit operations.
14. Human operators use a thin CLI over the same stable operations used by
    tests, automation, agents, and supported programmatic clients.
15. Validation rigor belongs to the lifecycle boundary whose claim it proves.
16. Published releases are immutable, reproducible from declared evidence, and
    never rewritten to accommodate forward development.
17. No repository content or ordinary diagnostic may expose PHI, credentials,
    private mappings, connection strings, raw records, or confidential material.

## System and ownership boundaries

These are distinct architectural units, even when one build machine sees more
than one of them.

| Unit | Owner | Mutability | Lifecycle | Validation owner |
|---|---|---|---|---|
| Development repository | RRP maintainers | Editable source | design, build, test, release | source/component/maintainer validation |
| Installed RRP software | RRP publisher; local installer controls activation | Immutable per installed version | acquire, install, verify, activate, upgrade/rollback, uninstall | distribution and installation validation |
| RRP project | Hospital/adopter | Editable trusted code and nonsecret configuration | initialize, customize, version, validate, migrate | project and extension conformance |
| Project state | Hospital/adopter | Append-oriented or explicitly migrated | initialize, run, back up, recover, retain, migrate | state adapter and history validation |
| Deployment artifact | Project/operator generated output | Immutable generated unit | build, independently validate, publish or discard | artifact validation |
| Deployment target | Hospital/operator and hosting service | Externally managed | configure, deploy, authorize, monitor, retire | target and operational governance |
| Published release | RRP publisher and release service | Immutable | prepare, authorize, publish, verify, support | release/publication verification |

```text
development repository
    ≠ installed RRP software
    ≠ RRP project
    ≠ project state
    ≠ deployment artifact
    ≠ deployment target
```

No unit discovers another by assuming the current working directory is an RRP
source checkout.

## Identity and compatibility

RRP maintains related but noninterchangeable identities for:

- RRP software product/version, distribution target/build, and installation;
- internal packages and dependency closure;
- project contract, project, and project version;
- canonical profile, producer, mapping, bundle, and as-of context;
- risk target and standard request;
- provider implementation and fitted model artifact;
- operation, analytical run, state, execution attempt, and estimate;
- history schema, record, invalidation, and restatement;
- product contract, product set, freshness, and materialization;
- deployment artifact and target realization; and
- source revision, release candidate, published release, and verification.

Git commits, filesystem paths, R objects, and deployment URLs may be provenance
but do not define semantic identity. Compatibility checks state the identities
and direction they compare; loadability alone is not conformance. The project
manifest declares its project-contract version and an explicit supported RRP
software/API range. RRP validates that declaration before trusted project code
executes. Stored-state compatibility is checked separately.

## Installed software architecture

### Installed unit

One RRP distribution installs one coordinated product containing:

```text
RRP installation
├── launcher / CLI entry point
├── stable programmatic operation API
├── private RRP-owned R package library
│   ├── rrpruntime
│   ├── main RRP implementation package
│   └── exact tested third-party runtime closure
├── contracts, schemas, defaults, and validators
├── supplied adapters, products, and app resources
├── project initializer, template, and fictional example
├── artifact and deployment-target build resources
├── user and normative product documentation
├── license, notices, support, and security material
└── software inventory, digests, compatibility, and build provenance
```

This is a responsibility map, not a fixed filesystem layout. The distribution
manifest and installed resource catalog are the discovery authority. Installed
code cannot derive a development-repository root or source ordered files into a
global environment.

### Launcher and doctor

The launcher locates the recorded R executable and installed RRP entry point,
passes explicit project/operation inputs, preserves signals and exit status,
and renders privacy-safe structured results. It contains no analytical or
project-specific logic.

Installation health is distinct from project health. An installed doctor
checks the selected R executable, RRP-owned library, package/resource inventory,
digests, loadability, permissions, and compatibility metadata. It does not open
hospital sources, execute a provider, or require initialized project state.

### Internal package topology

`rrpruntime` remains a focused, dependency-light internal package owning
admitted canonical input types, target eligibility and temporal state,
standard risk-request and accepted-estimate semantics, provider compatibility
and execution, and storage-neutral history records/ports.

One additional main implementation package owns stable operations, project
loading, resource access, diagnostics, default adapter composition,
products/app initialization, and artifact/target builders. Exact package names
and exported function names are implementation-plan decisions. More packages
require a demonstrated independent dependency, substitution, or release
boundary; files are not converted mechanically into micro-packages.

Contracts, templates, static app files, examples, licenses, and product docs
remain ordinary installed resources accessed through a stable resource API.
Package topology is invisible to ordinary operators and is not a project
contract.

### Initial installation posture

The first implementation is user-scoped and must not require administrator or
root privileges. Versions are installed side by side in immutable locations or
an equivalent atomic layout. An explicit activation pointer or launcher choice
selects the active version only after installation and project compatibility
checks succeed. System-wide installation is deferred until an adopter need and
permission/security model justify it.

## Host R architecture

R 4.4.x is the initial implementation and clean-install proof line. The first
evidence cells are macOS arm64 and Ubuntu x86_64; neither becomes a support
claim until its complete distribution-install and acceptance matrix passes.
Every build and installation records exact R version, platform, architecture,
and relevant capabilities. Broader support requires equivalent evidence.

Installation prefers an explicitly supplied R executable. A documented,
deterministic PATH/known-location fallback may be used once when no path is
supplied. RRP resolves and records the canonical executable path and thereafter
uses it; it does not silently rediscover a different R for each operation.
Doctor and runtime preflight fail clearly if that executable or its
compatibility facts change.

RRP does not initially bundle R. Bundling adds operating-system packaging,
native library, security update, size, license, and patch-lifecycle obligations
without demonstrated need. It may be reconsidered only if the validated host-R
model proves operationally inadequate. Deployment targets own their R runtime
independently and cannot use the operator installation's recorded R path.

## Independent RRP project architecture

### Project recognition

A project is recognized only from an explicit project root containing:

1. one versioned, nonsecret root project manifest; and
2. one fixed trusted registration entry point at the location defined by the
   project-contract version.

Those locations, their contract versions, safe path rules, and project-relative
state references are public physical contract. Suggested directories for
mappings, providers, models, tests, and documentation are template conventions
unless a later contract explicitly requires them. RRP never searches parents
indefinitely, scans arbitrary code directories, or treats a Git repository as a
project by implication.

### Manifest and project ownership

The declarative manifest owns project-contract/project identity and version,
one-health-system scope, supported RRP/API and canonical-profile versions,
exact producer/provider selections, dependency/model evidence references,
state/persistence profile and writable root, and nonsecret operation settings.
Product/app/artifact overrides appear only after such extension contracts
exist.

The manifest does not contain executable R, function names, arbitrary load
paths, package-install instructions, remote code URLs, credentials, connection
strings, raw records, or target semantics. It identifies selection; it does not
make code trusted or available.

The hospital project owns source access and validation, mapping, producer and
provider declarations/callables, model artifacts, extension dependencies,
configuration, tests, docs, and all writable state. It contains no RRP source
and does not know RRP's internal package layout. Secrets come from an approved
external environment or secret service.

The initializer creates a minimal editable project, never modifies an
unrecognized existing tree, and keeps fictional examples distinct from
hospital code. Generated state is isolated from project source by default.

## Trusted registration and composition

Registration and selection are separate:

```text
trusted project registration
        ↓ declares available executable producers and providers
validated project manifest
        ↓ selects one exact producer and one exact provider
deterministic resolver
        ↓ requires one matching registered component of each kind
```

The loader executes only the fixed local registration boundary after manifest,
software, project-contract, dependency, and safe-path preflight. Registration
returns a structured result pairing declarations with trusted local callables.
It exposes project-defined producers and providers only.

The 1.0.0 registration boundary does not expose estimands, targets, request
builders, products, apps, persistence ports, deployment targets, or arbitrary
plugins. RRP defaults are registered by installed maintained code, not copied
into projects. Resolution fails closed on missing, duplicate, undeclared,
incompatible, or ambiguous components. Declarative configuration never loads a
package, file, function, or remote resource dynamically. Executable
availability, manifest selection, and clinical approval remain distinct.

## Canonical source and admission architecture

The producer owns organization-specific extraction, joins, identifiers,
vocabulary translation, timestamp normalization, source validation, mapping
provenance, and candidate bundle construction. Its dependencies remain below
the public handoff.

A successful producer result contains a candidate canonical bundle and
structured evidence. RRP admits it only after validating bundle, producer,
mapping, project, as-of and contract identities; domains, relationships, keys,
controlled values, and capabilities; occurrence/effective and availability/
recorded time roles; coverage through the target endpoint; terminal-event
occurrence and availability; and installed-contract compatibility.

The handoff is representation-independent. An in-memory R realization may be
first, but files, tables, or services cannot redefine meaning. Generic runtime
receives only admitted input and never queries a source system. The synthetic
implementation is a separately initialized fictional project using this exact
boundary, not a privileged installed composition or runtime mode.

## Singular readmission-risk target

### Target identity and meaning

RRP 1.0.0 defines one versioned, nonselectable target: remaining actual-world
cumulative probability of first canonical readmission through the fixed day-30
endpoint.

For discharge instant `D`, as-of instant `t`, and
`W30 = D + 30 × 86,400 elapsed seconds`, the requested quantity is:

```text
P(first canonical readmission occurs in (t, W30]
  | alive and without canonical readmission through t,
    admitted information legitimately available through t)
```

The endpoint is included. The episode must be discharged and eligible at `t`,
with `D <= t < W30`. RRP emits no request before discharge, at or after `W30`,
or after a known terminal event. It never manufactures zero risk for an
ineligible episode.

### Population, event, and competing death

The population is every episode admitted under the 1.0 canonical readmission
profile, not a measure, payer, service-line, or program cohort. The event is
first canonical readmission; the initial contract does not distinguish planned
from unplanned readmission.

Death before readmission competes and prevents the event. If admitted
readmission and death share an occurrence instant, readmission has precedence.
Other events may enter the information set when valid and available but are not
terminal or competing events unless a later target version says so.

### Fixed endpoint and available information

`W30` cannot be shortened by provider choice, data availability, or a source
follow-up field. Admission must prove target coverage through `W30`, or reject
the episode for this target. Broader source observation is distinct.

Every governed fact affecting eligibility or state has explicit occurrence/
effective and availability/recorded roles when those differ. Terminal
readmission and death evidence must carry both roles in the 1.0 contract. A
fact may influence a run only when its occurrence is not after `t` and it was
available by `t`. Late-recorded terminal evidence affects eligibility only
from the first run that may legitimately know it, while retaining occurrence
time in provenance.

### Nonselectability

The target contract owns population, conditioning, horizon, interval, event,
death, terminal, output, failure, and temporal meaning. RRP constructs the
standard immutable request. Projects neither register nor select estimands,
targets, or request builders; there is no estimand catalog, target router, or
multi-target execution.

Daily hazard is not a public 1.0 target. Providers may use hazards, survival,
Bayesian updating, machine learning, or external scores internally, but must
return this remaining cumulative risk. Repeated predictions are landmark
updates toward one fixed endpoint and need not be monotone.

## Runtime architecture

For each explicit project and as-of invocation, RRP performs:

```text
load and validate project
→ resolve exactly one producer and provider
→ execute producer and admit canonical result
→ evaluate target eligibility and build immutable as-of state
→ construct the standard remaining-risk request
→ validate and execute the selected provider
→ validate estimate or structured failure
→ append one atomic attributable terminal history batch
```

RRP owns project loading, admission, eligibility, temporal filtering, state and
request construction, provider execution boundaries, output validation,
failures, history orchestration, diagnostics, and provenance. The main package
owns orchestration; `rrpruntime` owns focused computation and history
primitives.

Operation-run identity remains distinct from analytical run and provider-
execution identity. State is immutable input to one request, not a universal
feature store, and cannot perform provider source lookups.

An accepted estimate is exactly one finite probability in `[0,1]` per request
and carries project, software, target, state, request, provider/model, run,
execution, and as-of attribution. Ineligibility produces no request;
incompatibility, missing input, execution error, or invalid output produces a
structured failure and no estimate. Scheduling remains external.

## Provider architecture

A provider owns method, required admitted state/capabilities, identity,
optional fitted-model identity/integrity, dependencies, determinism claims,
limitations, and safe failure behavior. It declares compatibility with the
exact RRP target and request/API versions.

RRP owns registration, selection, compatibility, input isolation, invocation,
cardinality/bounds/identity validation, and standardized results. A provider
cannot broaden the information set, redefine eligibility/endpoint/target,
query application products, or write history directly.

Provider conformance establishes software compatibility, not calibration,
fairness, effectiveness, regulatory status, or local production approval.
Those remain adopter responsibilities. The transparent provider is visibly
fictional and serves example/conformance roles, not clinical default.

Remote and non-R transports are deferred. They may later implement the same
request/result semantics if concrete transport, privacy, authentication,
timeout, and failure requirements justify them.

## Operational history and project state

The hospital owns the state root and its access, retention, backup, recovery,
encryption, and infrastructure policy. RRP supplies logical history semantics
and a default local DuckDB adapter; DuckDB is not a production requirement.

History records what RRP actually knew, requested, attempted, and accepted.
Initial retained families include run status, target-eligible state/request,
provider execution outcome, accepted estimate, and explicit invalidation/
restatement evidence.

History obeys these rules:

- new as-of runs append attributable records;
- one terminal run batch is atomic and never exposes partial success;
- retry identity is distinct from a new analytical run;
- identical identity/content is idempotent; conflict fails loudly;
- provider/model/software/target transitions retain prior facts;
- invalidation is an overlay, never physical erasure;
- restatement is a new attributed run, never silent replacement;
- raw facts and validity-resolved/current reads remain distinct; and
- rebuilding products never changes history.

The 1.0 target, request, estimate, history, and product contracts are a new
semantic/version boundary. `v0.1.0` daily-hazard records cannot be renamed,
coerced, aggregated, or presented as remaining cumulative risk. A 1.0 project
may begin prospectively with empty state. Any legacy import retains the old
target identity in a separately typed archive and cannot enter current-risk
products as a 1.0 estimate.

State migration is an explicit versioned operation. It validates source and
destination schemas, preserves/backs up source state, stages output, checks
integrity, records provenance, and promotes only after validation. It is retry-
safe and fail-closed. Software upgrade never invokes it implicitly.

## Products and supplied application

Products are versioned views of valid attributable history. Builders consume
persistence ports, not DuckDB tables, hospital sources, producer internals,
provider code, or models. Materialized products live in project state and are
rebuildable without rewriting history.

The initial migrated product family remains narrow: current eligible episode
remaining risk, retained remaining-risk trajectory/history, and terminal run
summary. Exact names/versions are plan decisions. Every product/set carries
target, provider/model where relevant, software, history-schema, freshness,
source-run, compatibility, and materialization provenance. Missing capability
is explicit; zero rows are a valid empty state.

The supplied Shiny app receives validated logical product access. It does not
query sources, run producers/providers, interpret model features, or know
persistence schemas. App reload, product materialization, and estimation are
separate operations. Authentication, protected-data handling, networking, and
production authorization belong to deployment.

Custom products/apps are not initial project extension contracts. They require
later demonstrated need and explicit compatibility/trust boundaries.

## CLI and programmatic operations

The CLI is the canonical human interface. Stable programmatic operations do
the work:

```text
CLI / tests / automation / agents / readmit / supported clients
                         ↓
             stable operation API
                         ↓
  project loader, runtime, history, products, app, artifact builders
```

The CLI owns parsing, explicit project context, invocation, safe rendering,
exit status, and recovery guidance—not domain logic. Command names, flags,
styling, and implementation language are not finalized here.

Operation categories are installation/version health; project initialization
and health; project/producer/provider/dependency validation; one run and
history inspection; product materialization and app launch; artifact and target
build/validation; and explicit activation, migration, backup, and recovery as
implemented. Each declares inputs, output, side effects, mutation class,
diagnostics, recovery, and compatibility.

Human docs, tests, automation, and agents call the same behavior. Repository
validation and release/publication remain maintainer operations, not hospital
CLI capabilities.

## Dependency architecture

The installed distribution owns internal packages, exact tested transitive
runtime closure, installed resources, and dependency provenance in a private
immutable library. The root development `renv` is not this environment.

The project owns producer/mapping and provider/model packages, optional
clients/drivers, model artifacts, and exact reproduction evidence. `renv` is an
acceptable first mechanism, but its syntax is not the permanent public
contract. The project environment is not the development environment and
cannot overwrite RRP's library.

Initially, a controlled R process places the RRP library first and a project
extension library after it. Validation rejects incompatible requirements for
RRP-owned packages, verifies model integrity, and does not accept ambient user
libraries as declared closure. Stronger process/protocol isolation begins only
when real projects demonstrate irreconcilable graphs or security/runtime need.

Build-only dependencies belong to the maintainer/builder environment.
Deployment runtime dependencies belong to the artifact's target closure.
Neither enters ordinary runtime solely because a later build uses it.

## Artifacts and deployment

```text
validated project/product inputs + exact installed RRP resources
        ↓ target-neutral artifact builder
closed independently valid artifact
        ↓ target-specific builder
closed target realization
        ↓ explicit operator-controlled publication/deployment
```

The initial deployed scope is a product-only application artifact. It contains
only the app/runtime subset, product access, contracts/resources, one frozen
coherent product set, target R/package requirements, provenance, closed
inventory, SHA-256 digests, and a self-validator. It excludes producer,
provider, model, source clients, history writer, tests, and mutable state. It
runs without the development repository, local RRP installation, or mutable
project source.

A future compute-capable artifact is distinct. If authorized, it freezes the
needed RRP runtime/resources, effective project manifest, trusted producer/
provider code, dependencies, models, nonsecret configuration, external/state
binding declarations, provenance, and validator. Secrets remain target
configuration. This boundary is defined but not promised for 1.0.0.

A target builder adds only target-required entry points and dependency metadata
around an accepted artifact. A broadly Posit-compatible realization supports
the Shiny application without changing product semantics. Posit Connect Cloud
is the first demonstrated reference/example target; self-managed Posit Connect
is a closely related hospital path but is not a support claim until its own
acceptance evidence passes. Each target owns its R/package installation.

A product-only OCI/Docker image is a separate first-class portability
realization of the same artifact boundary. It contains the same frozen products
and application semantics with the required RRP app subset, dependency closure,
provenance, inventory, digests, and validator; it does not add producers,
providers, history writers, or project state. Future closure derives from
artifact/release metadata, not the development lock. Generated Git trees and
images are disposable target outputs. Remote creation, registries, credentials,
commit/push, service authorization, sharing, networking, monitoring, and
deployment remain explicit operator actions.

## Distribution, build, and release

The development repository may contain code, contracts, tests, fixtures,
assessments, records, historical release machinery, CI, and maintainer tools
that do not ship. A distribution is built only from a closed inclusion manifest
declaring source inputs by role and permitted transformations. Ignore patterns
may classify development material, but subtraction from the source tree never
defines the payload.

The build rejects missing, duplicate, unsafe, linked, unexpected, or
unclassified output. Its manifest records product/distribution identity,
source revision, build tool, platform/R target, internal packages, dependency
closure and acquisition, contracts/resources/docs/licenses/notices, every
output path/role/size/digest, determinism claim, and validation evidence.
Development assessments, Phase history, Hospital generation, private fixtures,
and maintainer release procedures do not ship merely because they are tracked.

The first reproducibility claim is normalized content reproducibility: equal
declared source, tool, platform/R target, and dependency inputs yield equal
installed inventory and digests. Ordering, permissions, line endings, locale,
timestamps, metadata, and compression are controlled or excluded from content
identity. Byte-identical archives are claimed only after independent proof.

Internal packages declare direct dependencies; a target-keyed release
resolution records the transitive closure and immutable acquisition evidence.
The development lock is not the distribution or project lock.

Source validation, distribution build, installation proof, candidate
validation, publication, and public acquisition are separate claims. Release
preparation uses an exact clean commit. Publication requires explicit
authorization, immutable version/tag/assets, integrity/authenticity evidence,
recovery, and verification. Published releases are never rebuilt in place.

## Documentation architecture

| Class | Answers | Prospective treatment |
|---|---|---|
| Normative product architecture | What is RRP now? | `docs/architecture/`; current authority, version-matched in releases |
| User/developer product docs | How do I install, create, map, provide, run, deploy, and recover? | prospective `docs/user/`; ships or is version-linked |
| Internal development evidence | Why was architecture chosen? | prospective `docs/development/assessments/`; source only |
| Historical release evidence | What was previously built/released? | prospective `docs/history/` plus immutable tags/evidence |
| Maintainer docs | How is RRP built, tested, released, and recovered? | prospective `docs/maintainers/`; source/maintainer tooling |

The current tree is transitional. Assessments remain decision evidence, while
this document controls where they differ. Detailed canonical/runtime/provider/
history/product/app/deployment documents describe implemented `v0.1.0`
boundaries until prospectively revised. The Phase plan and implementation
record are historical evidence.

The 1.0 plan must schedule documentation reclassification rather than moving
the tree in this synthesis. Git tags preserve release-specific architecture;
current normative architecture evolves in place rather than accumulating a
parallel tree per version. Installed docs use a closed version-matched product
subset and exclude internal CentralStatz reasoning/process.

## Upgrade, compatibility, and migration

A project declares supported RRP software/API and project-contract versions.
RRP checks canonical, target, provider, dependency, state, product, and
artifact compatibility at their owning boundaries.

A software upgrade installs a new immutable version beside the active version,
verifies it, and validates projects before activation. It never changes project
manifest, registration, producer/provider code, dependency declarations,
models, history, products, or configuration. Activation is separate from
installation; the previous version remains selectable for rollback until an
explicit uninstall/retention action. Rollback does not reverse migrations.

Project migration is an explicit adopter-controlled source/config change for a
project-contract evolution. RRP may produce a plan or staged copy but cannot
silently overwrite the project. State migration is separately authorized and
versioned, with source preservation/backup, staging, integrity and semantic
checks, provenance, retry/failure behavior, and validated promotion. Software
upgrade, project migration, and state migration may have prerequisites but are
never one implicit action.

## Validation and governance

Validation is proportional to the claim and routed by ownership.

| Boundary | Required evidence |
|---|---|
| Fast source | formatting, links, schemas, static policy, dependency/build-manifest consistency |
| Component/package | focused unit/conformance tests, API checks, `R CMD build/check`, dependency/license metadata |
| Integration | declared downstream combinations for changed public boundaries; synthetic and independent adopter compositions |
| Installed distribution | inventory/digests, paths/permissions, host R, private-library isolation, resources, launcher/doctor, install/activate/rollback/uninstall |
| Project | manifest/paths/trust/selections, dependencies/model, secret exclusion, state safety, compatibility |
| Producer/provider | canonical/temporal or target/request conformance and failures; clinical validation remains separate |
| Runtime/history | target/temporal/output semantics, atomicity, retry, invalidation/restatement, provenance |
| Artifact/target | closed runtime, integrity, secret exclusion, independence, self-validation, target behavior |
| Release candidate | clean build, support matrix, licenses/docs, clean install, adopter acceptance, artifact proof |
| Publication | authorization, exact remote/tag/assets, checksums/signatures, recovery, public acquisition/install |

The plan replaces phase-number routing with named profiles and a machine-
readable dependency/ownership map. Broad active-product matrices run in CI and
release preparation, while local checks follow affected boundaries. High-
consequence scientific, privacy, state, artifact, and publication invariants
remain strict.

Phase 0–11 suites, prose gates, Hospital acquisition, and whole-repository
checkpoints remain `v0.1.0` evidence or legacy checks. They do not govern
unrelated 1.0 work. No test is removed until its current invariant is reassigned
or deliberately retired. Diagnostics, validation, provenance, metrics, and
audit remain distinct; passing software tests never implies clinical approval.

## Clean-install and release acceptance

An RRP 1.0.0 candidate is acceptable only when clean environments prove from
exact candidate bytes, outside the development repository:

```text
install user-scoped RRP and verify host R/software
→ initialize and run the supplied fictional project
→ initialize a separate independent adopter project
→ replace its producer/mapping and register a custom provider/model
→ reproduce dependencies and validate compatibility
→ execute, append, close, and reopen history
→ build/materialize/validate products and initialize the app
→ build and independently validate the product-only artifact
→ realize and validate the Posit Connect Cloud reference target
→ build and validate the product-only OCI/Docker realization
```

The proof has no development/sibling repository access, Hospital distribution,
ambient undeclared library, maintainer Git-state requirement, real data,
credential, or project mutation by installation. Evidence retains source,
build, inventory, digest, R/platform, dependency, install/doctor, project,
component, runtime/history/product/artifact, and publication/acquisition
identities and privacy-safe results. Support claims name only cells that pass.

## Relationship to `readmit`

`readmit` is a separate optional user-facing R package built on supported RRP
programmatic interfaces. It may help construct, fit, package, test, or operate
providers and models. It belongs to a project/provider environment, is not
required for RRP, and cannot register a target or redefine the risk quantity.
Readmit-backed and independently implemented providers are conformance peers.
This architecture does not design or version `readmit`.

## `v0.1.0` reuse and retirement map

| Existing machinery | 1.0.0 disposition | Action |
|---|---|---|
| Identity/specification envelope | **REUSE SUBSTANTIALLY** | Retain vocabulary; revise estimand/Hospital identities |
| Producer result/admission/trusted callable pattern | **GENERALIZE / MOVE TO PROJECT** | Preserve stage separation; project registers producer |
| Synthetic producer | **RETAIN AS EXAMPLE** | Normal fictional project, not installed composition |
| `rrpruntime` temporal/state/provider/history core | **REFACTOR INTO INSTALLED SOFTWARE** | Preserve package; replace hazard request semantics |
| Provider registry/execution/result checks | **REUSE SUBSTANTIALLY** | Bind to singular target/project selection |
| Transparent provider | **RETAIN AS EXAMPLE** | Nonclinical conformance tool |
| Daily-hazard contracts | **REPLACE** | New target/request/estimate; no relabeling |
| History ports and append/atomic/retry/invalidation rules | **REUSE SUBSTANTIALLY** | New target-attributed schema/project state |
| DuckDB adapter | **REFACTOR INTO INSTALLED SOFTWARE** | Supplied default with project path |
| Logical products and three roles | **REUSE / REFACTOR** | Remaining-risk semantics and identities |
| YAML materializer/access | **REFACTOR INTO INSTALLED SOFTWARE** | Supplied default/project product state |
| Product-only Shiny app | **REFACTOR INTO INSTALLED SOFTWARE** | Preserve product-only boundary |
| Structured operations/diagnostics | **REUSE SUBSTANTIALLY** | Stable API under CLI |
| Repository-root scripts/source chains | **REPLACE** | Namespaced operations/explicit project |
| Temporary runtime install per operation | **RETIRE FROM ACTIVE PRODUCT PATH** | Runtime ships installed |
| Root `renv` | **SIMPLIFY / RETAIN FOR DEVELOPMENT** | Not installed/project authority |
| Reduced artifact/target separation | **REUSE SUBSTANTIALLY** | Installed inputs and SHA-256 closure |
| Connect Cloud realization | **REFACTOR** | Posit-compatible artifact/release dependency evidence; Cloud remains the reference target |
| OCI/Docker realization | **ADD FROM SHARED ARTIFACT** | Product-only portable realization; no compute-capable semantics |
| Full Platform tree as payload | **REPLACE** | Closed installed distribution |
| Generated Hospital release/embedded archive | **RETIRE FROM ACTIVE PRODUCT PATH** | Preserve `v0.1.0` history |
| Hospital Git/wrappers | **RETAIN AS HISTORICAL EVIDENCE** | No normal 1.0 role |
| Inventory, acquisition, publication recovery | **REUSE SUBSTANTIALLY** | Reassign to correct lifecycle |
| Phase 0–11 validation hierarchy | **REPLACE** | Lifecycle/component profiles |
| Two-product publication machinery | **REFACTOR LATER** | Preserve authorization/immutability, replace payload assumptions |
| Decision/workflow/metrics/scheduling | **DEFER** | Preserve separation; no 1.0 promise |

## Superseded forward directions

The following are not competing current options:

- generated Hospital repositories are not normal acquisition;
- the full development repository is not installed software;
- RRP is not defined as one user-facing R package;
- projects do not register/select estimands, targets, or request builders;
- daily hazard is not the public target;
- the development `renv` is not universal dependency authority;
- repository scripts are not the future human surface;
- Phase 0–11 is not the forward plan/validation hierarchy;
- clean Git, zero commits/remotes, and whole-tree checks are not project
  validity requirements; and
- Connect Git realization is not software acquisition.

Assessments remain decision evidence. Detailed `v0.1.0` documents/contracts
remain accurate for that release only where this architecture supersedes them.

## Non-goals and deferrals

The initial 1.0.0 implementation does not require bundled R; system-wide
installation; remote/non-R providers; multiple targets or estimand plugins;
custom products/apps; a compute-capable artifact; a production database;
scheduling; decision/priority/work/intervention/measure features;
hazard-to-risk conversion; retrospective fabricated predictions; a universal
feature store; uncertainty/explanation, calibration, fairness, monitoring,
metrics, alerts, or audit systems; multi-hospital tenancy; automatic migration;
or mandatory `readmit`, agent, service, or proprietary dependencies.

Deferred features enter only through concrete requirements and preserve
ownership and target semantics rather than speculative plugin surfaces.

## Bounded implementation decisions

This architecture settles the product boundary, user-scoped side-by-side
posture, host-R line/discovery principle, two-package topology, project
registration/selection split, dependency isolation, inclusion manifest,
documentation taxonomy, product-only artifact scope, validation ownership, and
1.0.0 target generation.

The implementation plan must finalize launcher/installer technology and paths;
package names/APIs; project manifest and registration schema/paths; 1.0 target,
canonical, request, provider, history, and product IDs/schemas; distribution
manifest/build/signing details; project dependency/conflict mechanics;
migration and legacy archive contracts; artifact/Connect Cloud/OCI versions;
validation profile graph; documentation move sequence; and the release support
matrix.

These are bounded plan decisions, not reasons for another broad assessment.
Use reversible spikes where evidence is needed before an irreversible choice.

## Release and versioning direction

This document adopts **RRP 1.0.0 as the target generation** because it creates
the first intended stable conventional product boundary: installed software,
independent projects, CLI/API, separate dependencies/upgrades, one cumulative
risk target, and new history/product compatibility. There is no mature
`v0.1.0` compatibility promise that a `0.2.0` label needs to preserve, and a
minor pre-1.0 label would obscure the deliberate new adopter contract.

This is not a release claim. Distinguish the accepted **1.0.0 target
architecture**, forthcoming **1.0.0 implementation development**, and a future
**released 1.0.0** that exists only after acceptance and publication. Current
`0.2.0-dev` metadata is transitional and changes only in an implementation-plan
increment.

## Architecture acceptance criteria

Implementation planning may begin when maintainers accept that RRP is one
installed product; projects contain no RRP source; producer/provider are the
only initial executable seams; the cumulative day-30 target is singular;
terminal availability and fixed endpoint are enforced; hazard history is not
relabeled; software/project/state/artifact lifecycles and dependencies are
separate; upgrades are non-mutating; product-only deployment is first scope;
validation is lifecycle-owned; and 1.0.0 is a target, not released state.

No implementation should begin while an active authority still asserts a
contradictory target. Detailed old documents may remain as clearly classified
implementation/history evidence until planned replacement.

## Implementation-plan bridge

The authoritative [RRP 1.0.0 implementation roadmap](platform-implementation-plan.md)
sequences governance, source/distribution ownership, installed operations,
independent projects, singular-target analytics, new history, products/app,
Posit and OCI product-only realizations, adopter acceptance/legacy retirement,
and release qualification. It is organized by architecture-owned stages rather
than Phase chronology.

Detailed planning is progressive: Stage 1 is decomposed before Stage 1 begins,
then each later stage is planned only after its predecessor has been
implemented, validated, and reconciled against the declared exit state. Each
increment will state what remains working, reuse/replacement, compatibility and
state effects, human operation, and proportional evidence. The high-level
roadmap changes only if implementation evidence invalidates a major dependency
or assumption. Legacy release assets remain unchanged until replacement
acceptance makes retirement safe.

## Prohibited dependencies

- Installed operations may not require the development or sibling repository.
- Runtime may not import project producers/providers, Shiny, targets, Git,
  release tooling, or `readmit`.
- Project code may not modify/source installation internals.
- Producers may not bypass admission or build products.
- Providers may not redefine target/eligibility, broaden available state, query
  products, or write history.
- Product builders may not query sources/provider internals; the app may not
  invoke runtime/providers or query physical history.
- Product-only artifacts may not include source/provider/model/history writers.
- Targets may not change canonical, target, history, or product semantics.
- Project dependencies may not silently override RRP-owned packages.
- Configuration may not contain executable code, arbitrary load paths, remote
  code, PHI, or secrets.
- Installation/upgrades may not mutate project source or state.
- Agents/clients may not own unique logic or recovery procedures.
- Nothing may depend on `../readmission-risk-pool`.
