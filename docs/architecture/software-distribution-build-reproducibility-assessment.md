# RRP software distribution, dependency, and build-reproducibility assessment

## Status and scope

**Status:** recommended forward architecture; assessment only; no distribution,
installer, CLI, package, project, artifact, or release implementation

This assessment asks what a hospital should install when it installs the
Readmission Risk Pool (RRP), how that software should be built from this
development repository, and how independently owned RRP projects and deployment
artifacts should depend on it. It follows the current recommendations in the
[installed-software project assessment](installed-software-project-contract-assessment.md),
the [governance assessment](governance-validation-architecture-assessment.md),
and the [platform-defined readmission-risk target assessment](readmission-risk-target-assessment.md).

Published Platform and Hospital Implementation `v0.1.0` remain immutable. The
release is evidence for semantic boundaries, integrity controls, and clean
acquisition; its whole-repository Platform archive and generated Hospital
repository are not presumed to be the next product boundary. This document
changes no executable source, contract, package, dependency, operation,
artifact, release metadata, publication evidence, or remote state.

## Executive conclusion

A hospital should install **one coherent, versioned RRP software
distribution**, not treat an R package or a clone of the development repository
as the product. The narrow recommended architecture is a hybrid of an installed
software distribution and a thin R-backed command application:

```text
exact RRP source revision
        ↓ closed, reproducible software build
versioned RRP distribution
  ├── operator launcher / future CLI
  ├── stable namespaced programmatic operations
  ├── focused internal R packages
  ├── contracts, validators, defaults, products, and app resources
  └── build identity, dependency evidence, documentation, and licenses
        ↓ install against one validated host R
installed RRP software
        ↓ explicit project path and trusted project entry point
independently owned RRP project
```

R remains an appropriate initial implementation dependency. The installer
should bind an RRP installation to one explicit compatible R executable and a
private, RRP-owned package library; ordinary operators should not open R,
invoke `library()`, or source files. Bundling or managing an entire R runtime is
not justified yet. The launcher should invoke the same stable programmatic
operations used by tests, automation, agents, and a future `readmit` package.

The existing `rrpruntime` package remains a valuable dependency-light semantic
core. Most maintained orchestration now sourced from `operations/lib`, product
code, adapters, and application initialization should become one additional
namespaced implementation package rather than many premature micro-packages.
Contracts, templates, static resources, and documentation remain installed
resources, even when an internal package supplies the API used to locate and
validate them. Package topology is an implementation detail beneath the RRP
software version and compatibility boundary.

RRP and a project need distinct dependency environments. RRP owns its tested
runtime closure; a project owns producer, provider, model, and external-client
dependencies. A project may use `renv` or another supported exact lock, but it
must not replace packages inside the installed RRP environment. Initial
composition can use an RRP-first library path plus a project library, rejecting
conflicting versions of RRP-owned packages. Stronger process isolation remains
available if real provider stacks demonstrate that this is insufficient.
`readmit` is an optional project/provider dependency and never an RRP runtime
dependency.

The distribution must be built from a closed inclusion manifest. Ignore rules
may help maintainers detect irrelevant files, but `development tree minus
ignored files` is too weak as the release authority. The output needs an exact
inventory, digests, package and dependency identities, source revision,
build-tool identity, documentation classification, and independent install
proof. A versioned RRP distribution may be target-specific because R and
DuckDB dependencies can include native code; the supported platform and binary
strategy remain synthesis decisions.

Deployment closure is also target-specific. The current product-only Shiny
artifact correctly excludes producer, provider, history, and model machinery;
as a snapshot viewer it should continue embedding only the app, coherent
materialized products, required RRP resources, and exact target dependencies.
A future artifact that executes production scoring must additionally capture
the selected project's trusted producer/provider code, dependency closure,
model artifacts, configuration, persistence connectivity declarations, and
provenance. Neither artifact may depend on the development repository, the
operator's local RRP installation, or mutable project source after it is built.

This decision is sufficient to proceed to forward target-architecture
synthesis and implementation planning. The remaining installer, package-name,
platform-support, and binary-build choices are bounded implementation decisions
that should be resolved in that synthesis rather than through another broad
architecture assessment.

## Current physical dependency and distribution trace

### Repository-bound operation today

The current human entry points are `Rscript operations/...` scripts. They
derive a repository root from their own file path, source ordered files from
`operations/lib`, read contracts and configuration by repository-relative
paths, and load ordinary R modules from `products/`, `implementations/`,
`app/`, and `deploy/`. Normal runtime and history operations build
`runtime/` with `R CMD INSTALL` into a temporary library, load `rrpruntime`,
and remove that library at operation exit.

This proves that useful callable seams exist, but it is not installed-software
behavior. The repository root currently acts simultaneously as source tree,
resource locator, package build context, dependency environment, default
composition, writable-state parent, build workspace, test corpus, and release
workspace. Those roles must be separated rather than copied wholesale into a
hospital project.

### Current dependency layers

| Layer | Current physical form | Direct dependency evidence | Forward interpretation |
|---|---|---|---|
| Semantic runtime | `runtime/` R package | Base R, declared `R >= 4.1.0`; no imported storage, app, or source packages | Preserve as focused internal package; revise semantics for the accepted singular target separately |
| Specification/orchestration | sourced `operations/lib/*.R` | Base R plus repository YAML parser | Move active reusable behavior behind a namespaced installed API |
| Canonical producer | sourced reference/adopter R files and trusted registration | project/source-specific R dependencies, currently base R in examples | Project-owned extension behind installed producer contracts |
| Provider | `rrpruntime` registry plus transparent provider | provider-specific dependencies, currently base R for the reference | Project-owned or supplied provider behind the singular target contract |
| History | sourced DuckDB adapter | `DBI`, `duckdb`, `yaml` configuration | Supplied installed default adapter; project owns writable database and connection configuration |
| Products | sourced `products/R` and YAML adapter | `yaml` for reference materialization/access | Supplied installed logical products and default materializer/access adapter |
| App | sourced `app/R` | `shiny`, `yaml` through product access | Supplied installed product consumer; no source/provider access |
| Reduced artifact | explicit source map plus materialized products | direct roots `shiny@1.10.0`, `yaml@2.3.10` in current evidence | Preserve closed target-neutral product-only artifact principle |
| Connect realization | generated app wrapper, `manifest.json`, pruned lock, Git tree | build-only `rsconnect@1.3.1` and `jsonlite`; target installs declared Shiny closure | Refactor around installed build APIs and project input; preserve target-owned dependency realization |
| Development/release | root `renv.lock`, tests, validation, Git, archive and GitHub operations | R `4.4.1` and a broad locked development closure | Development and maintainer concerns, not the installed runtime dependency declaration |

The root lock currently combines development, runtime, persistence, app,
artifact-build, and publication needs. It is valuable evidence but cannot be
the future declaration of every installed or project dependency surface.

### Current `v0.1.0` physical release

The Platform `v0.1.0` candidate was the full tracked development repository.
The separately versioned Hospital Implementation generated a standalone Git
form carrying an exact Platform archive, wrappers, fixed composition, and one
top-level R environment. Release preparation and publication retained exact
candidate identities, SHA-256 digests, source commit, remote target, tag,
release, and clean-acquisition evidence.

That design was internally coherent for `v0.1.0`, but it makes source delivery,
software installation, project ownership, and release publication overlap.
Future RRP should retain its integrity and recovery principles while replacing
the two-product nested-source handoff with one installed software product plus
independent projects.

## Product boundary versus implementation-language boundary

“RRP software” is the supported product. “R packages executed by R” is the
initial implementation. These identities must not be conflated:

- The RRP software version governs operator-visible behavior, contracts,
  supplied operations, project compatibility, target meaning, products, app,
  and artifact builders.
- Internal package versions identify implementation components for diagnostics,
  dependency resolution, and build provenance. They do not require an operator
  to compose compatible packages manually.
- The host R version is a compatibility fact of an RRP installation and of
  target-specific artifacts, not the RRP product identity.
- A project declares the RRP software compatibility range it was authored
  against, not an accidental development-repository path or set of sourced
  files.
- A future `readmit` package consumes supported RRP programmatic interfaces as
  an external client. It is not the RRP product and cannot become a hidden
  requirement for operating RRP.

This separation permits RRP to change its internal package split or eventually
replace its launcher/runtime strategy without changing the project contract
solely because implementation files moved.

## Distribution architecture alternatives

| Concern | A. RRP is directly an R package | B. Software distribution with internal R package(s) | C. Dedicated CLI/application managing an R-backed runtime |
|---|---|---|---|
| Hospital installation UX | Familiar to R users; exposes libraries and R installation details | Conventional one-product install; launcher can hide packages | Most conventional UX if fully managed |
| Operational simplicity | Simple build tooling, but operators must understand R/package libraries unless wrapped | Thin launcher plus controlled internal environment | Simple for operators, materially more installer/runtime code for maintainers |
| Namespace and development ergonomics | Strong | Strong internally | Depends on an internal package/module design anyway |
| Dependency isolation | Uses ambient/user library by default; project conflicts are likely | Can install coordinated packages in an RRP-private library | Can fully manage processes/runtime, at highest complexity |
| Reproducible clean install | R-package mechanisms help, but non-package assets and exact closure need additional work | Closed product manifest can cover packages, resources, launcher, and dependencies | Strong if it owns runtime acquisition; expensive across operating systems |
| Independent projects | Possible, but package-centric UX can blur software/project environments | Explicit software/project seam | Explicit seam |
| Provider/model dependencies | Easily contaminate the same R library | Separate project dependency environment can be enforced | Strongest isolation if separate processes/environments are managed |
| Upgrades | Package upgrade may mutate a shared library in place | Versioned installation prefix supports side-by-side/atomic upgrade and rollback | Can support this, but requires custom lifecycle machinery |
| Posit Connect | Package can be deployed, but project/app closure still needs a target build | Builder can embed exact RRP package/resources plus target closure | Same result; dedicated manager adds little inside managed Connect build |
| CI/release complexity | Lowest initially | Moderate and proportional to the product boundary | Highest, especially if R is downloaded or bundled |
| Future extensibility | Good R API; human UX remains R-shaped | Good CLI and R API; internal topology can evolve | Good UX and possible language neutrality, but premature today |
| `readmit` integration | Natural package dependency, with risk of coupling RRP to it | Natural supported-client relationship | Requires an R API or subprocess protocol in addition to CLI |
| Technology leakage | High unless wrapped | Low | Lowest |

### Alternative A: directly installed R package

An R package provides namespaces, documentation, dependency metadata,
installability, and `R CMD check` with little custom machinery. It remains an
excellent internal implementation mechanism and exposes a natural
programmatic API. As the complete product boundary, however, it would make a
hospital reason about R libraries and package installation; does not by itself
own project initialization, static contracts, templates, executables, private
dependency closure, target builders, or lifecycle validation; and makes it too
easy for project packages to change RRP's dependency graph. The product has
already outgrown “one package installed into an ambient library.”

### Alternative B: software distribution containing internal packages

This option makes RRP the released and installed identity while reusing R's
mature namespace and package tooling. It can install a launcher, a private
package library, ordinary resources, documentation, templates, a build
manifest, and exact dependency evidence as one coordinated unit. Projects can
remain small and independent. It adds a software build/installer boundary, but
that boundary is required by the desired product experience rather than
incidental complexity.

### Alternative C: dedicated CLI/application runtime manager

A fully managed CLI could acquire R, create environments, supervise processes,
and present a language-neutral facade. That may eventually be appropriate for
broad cross-platform distribution. No current evidence shows that bundling R
or writing a substantial native runtime manager solves an adopter problem that
a thin launcher plus validated host R cannot solve. It would immediately add
platform-specific installers, security updates, runtime patching, licensing,
signing, native build infrastructure, and support obligations.

### Recommendation: narrow B/C hybrid

Use Alternative B as the product and build boundary, with the narrow useful
part of C: a small installed launcher is the canonical human entry point and
invokes stable R-backed operations. The launcher does not initially download,
bundle, or generally manage R. This yields conventional operation and private
software dependencies without inventing a second analytical runtime.

## Recommended installed-software architecture

The conceptual installed unit is one immutable, versioned prefix or equivalent
platform-native installation containing:

```text
RRP installation
├── launcher / future CLI entry point
├── RRP-owned private R package library
│   ├── rrpruntime
│   ├── main RRP orchestration package
│   └── exact tested third-party runtime closure
├── installed resources
│   ├── contracts and schemas
│   ├── supplied adapter/provider declarations
│   ├── product and application resources
│   ├── project template and fictional example
│   └── target-build templates/resources
├── user and normative product documentation
├── license, notices, support, and security material
└── software manifest, digests, dependency/build provenance
```

This tree is illustrative, not a committed path layout. The invariant is that
all installed resources are discoverable from installation metadata or package
resource APIs, never from a development repository root or the current working
directory.

The installation should be replaceable only through an explicit
install/upgrade operation. Project runs must not write inside it. Side-by-side
versions or an atomic current-version pointer are preferable to mutating a
live package library in place, but the exact update mechanism is deferred.

## R runtime ownership

### Initial host prerequisite

Requiring a compatible host R is sufficient for the next generation. It keeps
the first implementation close to proven code and lets RRP focus on the actual
software/project seam. The installation workflow should:

1. accept an explicitly supplied R executable or apply one documented,
   deterministic discovery policy;
2. resolve and record its canonical executable path;
3. run a compatibility probe before installing packages;
4. record R version, platform, architecture, and relevant capabilities in
   installation evidence; and
5. make the launcher use that recorded executable rather than rediscovering an
   arbitrary `R`/`Rscript` on every invocation.

The exact discovery order is an implementation-plan decision. Silent switching
among PATH entries is not acceptable.

### Validation ownership

R compatibility appears at several boundaries for different reasons:

- **distribution build:** proves internal packages and dependency artifacts
  were built for a declared R/platform target;
- **software installation:** proves the selected host executable satisfies the
  distribution's supported range and can load the installed closure;
- **project validation:** proves project dependencies and provider code are
  compatible with that installed RRP/R combination;
- **runtime preflight:** detects that the recorded executable or installed
  library has disappeared or changed materially before work begins; and
- **deployment artifact:** declares and validates the R version/runtime expected
  by the target independently of the operator workstation.

These are intentionally repeated facts, not one universal validator.

### No bundled R initially

Bundling R would improve hermeticity and may later simplify unsupported host
configurations, but it creates operating-system packaging, patch/update,
security, size, native-library, and license-notice responsibilities. Those costs
are not yet justified by clean-install evidence. Reassess only if a supported
host-R matrix proves unreliable or adopter installation burden remains high
after the thin-launcher distribution exists.

On Connect, the hosting target—not the operator installation—owns R and package
installation. The artifact must state a supported R requirement and exact
package closure in the target's accepted mechanism. Local RRP discovery state
must never leak into that artifact.

## Internal R package and module topology

### Preserve `rrpruntime`

`rrpruntime` has a coherent responsibility: admitted canonical input,
eligibility/state/request semantics, provider compatibility/execution,
structured estimates, and storage-neutral history ports. Its base-R-only
dependency posture makes the scientific core easier to test, embed, and reason
about. It should remain distinct unless synthesis shows that the accepted
singular-target refactor eliminates rather than clarifies that boundary.

### Add one main implementation package

One additional internal package should initially own the reusable installed
surface now spread across sourced modules:

- project loading and trusted registration;
- contract/resource discovery and validation;
- operation orchestration and structured diagnostics;
- supplied DuckDB and YAML adapter composition;
- product construction and access;
- supplied app initialization;
- artifact/target build and validation APIs; and
- stable programmatic entry points used by the launcher.

This is a responsibility boundary, not a settled package name. Splitting every
adapter, product, validator, or operation into a separate package would expand
version coordination without demonstrated independent reuse. A component
should become a third package only when it has a separately valuable dependency
boundary, release cadence, or substitution contract.

### Keep resources as resources

YAML contracts, schemas, application/static files, templates, example data,
licenses, and end-user Markdown do not become R functions merely to fit package
tooling. They should be declared distribution inputs and installed as ordinary
versioned resources, with a stable API returning their paths or parsed forms.
Project state and model artifacts never enter an installed package.

### Stable programmatic interface

The supported API beneath the launcher should accept explicit project and
operation inputs and return structured results. It should not expose repository
root discovery, source-order requirements, `.GlobalEnv` mutation, or temporary
package installation. Internal functions and package divisions can change
without changing that public operation contract.

## Ownership matrix: development, installation, project, artifact, maintainer

| Category | Development repository | Installed RRP | Independent project | Deployment artifact | Optional maintainer/developer tooling |
|---|---:|---:|---:|---:|---:|
| Launcher and stable operation API | Source | **Yes** | No | Only target entry point/API subset needed | Build/test helpers |
| Internal R packages/modules | Source and package tests | **Built packages and closure** | No | Exact required built/runtime subset | Package build/check tools |
| Risk target, canonical, provider, history, product, and artifact contracts | Authoritative source | **Yes, current supported set** | Compatibility references only | Exact required subset | Schema generators/review tools |
| Validators | Source and tests | **Product/project/runtime validators** | Invoked against project | Self/target validators | Repository, packaging, release validators |
| Default DuckDB/YAML adapters | Source | **Yes** | Configuration and writable state | Only when the artifact uses them | Adapter tests/fixtures |
| Supplied products and product-only app | Source | **Yes** | Select/use/configure within supported bounds | **Yes when selected** | Product/app tests |
| Producer mapping | Fictional example only | Template/example, not active hospital code | **Yes** | Only for compute-capable artifact | Conformance fixtures |
| Provider implementation and model | Transparent example/default only if supported | Supplied provider if product policy keeps one | **Selected custom provider/model** | Only for compute-capable artifact | Provider conformance/evaluation tools |
| Project manifest and trusted registration | Schema/template | Loader/schema | **Yes** | Frozen effective composition as applicable | Example generators |
| Writable history/products/cache/logs | No committed real state | No | **Yes** | Only target-required immutable products or target state bindings | Test-only state |
| Project dependency declaration/lock | Example/schema | Compatibility logic | **Yes** | Resolved target closure, not mutable project lock by default | Lock validation/generation support |
| Runtime dependency declaration/lock | Build source/evidence | **Yes, exact RRP closure** | No ownership | Re-resolved/frozen for target | Dependency build/update tools |
| Application/deployment builders | Source | **Supported builders/validators** | Supplies explicit inputs | Generated output | Additional target/build tooling may be optional |
| User and normative product docs | Source | **Yes or version-matched published copy** | Project-local guide/config comments | Minimal operation/deployment guide | Doc build tools |
| Assessments, implementation record, phase history | **Yes** | No | No | No | **Yes** |
| Repository CI and broad source tests | **Yes** | No | No | No | **Yes** |
| Executable conformance examples | Source | Minimal fictional examples where users need them | Optional copy | Only if operationally required | Full fixtures remain development-only |
| Hospital distribution/Git machinery | Historical source while retained | No | No | No | Legacy-only until retired |
| Release/publication machinery and evidence | Source/evidence | No, except public release identity | No | No | **Yes** |

The same logical asset may have source in the repository and a built form in
the installation. The matrix assigns operational ownership, not merely file
presence.

## Build inventory strategy

### Exclusion-oriented build

An ignore file is familiar and grants development freedom, but it defines the
product as an open set: every new unignored file silently becomes releasable.
That is especially risky for internal assessments, fixtures, private-looking
example configuration, build state, publication tooling, and future developer
assets. Reviewing a growing negative list is also poor proof of intended
contents.

### Inclusion-oriented build

A closed manifest can name source inputs by role, define transformations such
as building internal packages, and reject missing, duplicate, unsafe,
unclassified, or unexpected output. It directly supports provenance,
checksums, documentation classification, licenses, and independent validation.
It is more maintenance, but that maintenance is an explicit review of the
software product boundary.

### Recommended hybrid

Use a **closed inclusion manifest as authority** and an optional exclusion or
classification check as maintainer ergonomics. The builder should consume only
declared tracked inputs from an exact source revision. Ignore patterns can
prevent irrelevant material from being considered and can flag new
unclassified paths, but must never widen the distribution.

The built manifest should record at least:

- RRP product ID and version;
- source revision and clean-source/material-input identity;
- distribution format and target platform identity;
- build-tool and manifest-schema identities;
- internal package names, versions, source archives/binaries, and digests;
- host R compatibility and build R identity;
- exact third-party dependency closure and acquisition provenance;
- installed contracts, schemas, defaults, resources, templates, and docs;
- every output path, role, size, and cryptographic digest;
- license/notice attribution;
- build mode and determinism claim;
- validation evidence and build instance identity; and
- explicit exclusions/nonclaims where they prevent misinterpretation.

The source manifest should classify directories or controlled groups where
that remains reviewable; the output inventory must enumerate exact files.
Generated package metadata, dependency indexes, and normalized archives are
outputs rather than undeclared source inputs.

## Documentation ownership and distribution

| Documentation class | Examples | Treatment |
|---|---|---|
| Normative product architecture | current risk target, canonical/project/provider interfaces, product and artifact invariants | Ship a version-matched supported subset and publish the same version online where practical |
| User/developer product documentation | install, initialize, map a source, implement/select a provider, validate, run, inspect, build products/app/artifacts, troubleshoot | Ship or make reliably available as part of the software version; installed help must work offline for core operations |
| Project template guidance | manifest fields, trusted registration, dependency/model/state layout, fictional example | Ship with initializer resources and copy only project-owned guidance into a new project |
| Internal development evidence | assessments, investigation notes, implementation reasoning, full implementation record, phase narratives | Development repository only |
| Maintainer/release documentation | source build, dependency update, release candidate, signing/publication/recovery | Development or optional maintainer tooling, not ordinary installation |
| Historical release evidence | Phase 0–11 completion, Hospital candidate/publication evidence | Retain immutably in source/release records; do not install as current product guidance |

Current `docs/architecture` mixes normative descriptions, historical
implemented-state documentation, and forward assessments. A later governance
refactor should give those classes explicit metadata or locations and a current
product index. Moving files is not necessary to decide the distribution:
the closed build manifest can initially include only reviewed product-facing
documents. Internal CentralStatz process, release-candidate detail, and design
deliberation must not leak merely because they are tracked Markdown.

Normative architecture benefits from both installed and published forms. The
installed copy guarantees version alignment and offline inspection; a public
site improves discovery. The site must preserve version selection rather than
silently presenting future semantics as the installed release.

## CLI and programmatic-interface role

The CLI should be the canonical human operational interface, and the stable
programmatic operations should perform the work:

```text
operator / automation / agent / readmit client
                  ↓
          supported interface
        CLI       or       R API
                  ↓
     common structured operation functions
                  ↓
 project loader → validation → runtime/products/app/builders
```

The CLI is responsible for argument parsing, project selection, calling the
installed API, rendering privacy-safe diagnostics, exit status, and clear
recovery guidance. It must not duplicate canonical, target, provider, history,
product, or artifact logic. This assessment does not approve command names,
flags, interactive behavior, or a CLI implementation technology.

The callable boundaries behind the current scripts that should become stable
software operations include:

- initialize a project from the installed template;
- inspect installation health and project health separately;
- validate project manifest, trusted producer/provider registration,
  dependencies, and compatibility;
- run the platform for one explicit project/as-of invocation;
- inspect attributable operational history;
- construct and materialize the supported logical products;
- initialize or launch the supplied product-only application;
- build and validate a target-neutral application artifact; and
- realize and validate supported deployment targets.

Repository validation, Hospital distribution, and release publication scripts
are not hospital-facing installed operations. Tests should call the same
programmatic functions as the launcher, not execute a private alternate
workflow. A future `readmit` package should normally use the R API to construct
or validate providers; shelling through the CLI is available to generic
automation but is not the richest R integration.

## Project dependency ownership

### Separate environments

The installed software owns an immutable RRP dependency environment. Each
project owns a distinct dependency declaration and exact reproducibility
evidence for its trusted extensions. These are not interchangeable lockfiles:

```text
RRP software environment
  RRP packages + exact supported third-party closure
                   │ stable interfaces
                   ▼
project environment
  producer/mapping + provider + model/client dependencies
```

The project may use `renv` initially because it is already proven and familiar,
but the project contract should specify required dependency evidence and
reproduction behavior rather than make a particular lockfile format permanent
public semantics. The project lock excludes RRP's managed packages or records
them only as compatibility references; it must not reinstall a second mutable
RRP implementation over the software installation.

### Initial compatibility rule

For the first implementation, invoke trusted project code in a controlled R
process with:

1. the immutable RRP library taking precedence;
2. a project library containing producer/provider-only dependencies;
3. explicit rejection of a project that requires incompatible versions of
   packages owned by RRP; and
4. pre-execution checks of R, RRP API/contract, provider target, package, model,
   and external-client compatibility.

This avoids duplicating the entire RRP closure while preserving deterministic
ownership. If real projects require incompatible dependency graphs, execute
extensions across a stronger process/protocol boundary rather than allowing
ambient library order to choose behavior. That complexity should be driven by
evidence.

### Dependency categories

- **RRP runtime dependencies:** built and tested by the RRP release; installed
  into the RRP environment.
- **Producer/mapping dependencies:** declared and locked by the project; source
  credentials and connection strings remain external secrets.
- **Provider dependencies:** declared and locked by the project unless the
  provider is supplied by RRP.
- **Model artifacts:** project-owned, content-addressed or otherwise
  integrity-checked, versioned in project provenance, and loaded only by the
  selected provider.
- **External clients/drivers:** project-owned when used only by mapping or a
  custom provider; explicit compatibility and secret/config separation apply.
- **Deployment-only dependencies:** resolved by the artifact target and not
  added to normal RRP/project execution merely to enable a later deployment.

`readmit` belongs in the provider/project environment. A readmit-generated
provider declares its supported RRP target/API and its own package/model
closure. RRP validates and invokes the resulting provider through the same
contract as any other provider; RRP must install and run without `readmit`.

## Clean installation and external-operation proof

A future release is genuinely installed software only when an isolated proof
can perform this sequence without the source checkout:

```text
acquire exact published RRP distribution and checksum/signature evidence
→ install against an explicitly selected compatible R
→ verify installed inventory, packages, resources, launcher, and dependency closure
→ invoke installation doctor outside the source repository
→ initialize a new independent project in an unrelated empty directory
→ replace fictional mapping with a test adopter producer
→ install/reproduce project dependencies and register one conforming provider
→ validate project, producer, provider, target compatibility, and writable state
→ execute one attributable run and reopen durable history
→ build and validate products
→ initialize the product-only app
→ build and independently validate a supported deployment artifact
```

The proof environment must not contain or discover the development repository,
use repository-relative paths, source development files, mutate installed
software, require a Git repository/branch/remote, invoke Hospital distribution
machinery, or inherit undeclared user libraries. It should include both a
supplied synthetic project and an independently shaped fictional adopter
project. No real hospital data, credentials, or mappings belong in the proof.

Retained evidence should include distribution digest/signature, source and
build identity, installation manifest, selected R/platform facts, dependency
closure and acquisition sources, installer/doctor results, project/example
identity and dependency evidence, operation/artifact result identities, and
privacy-safe logs. Temporary data and packages need not be retained when their
digests and reconstructible inputs are.

## Software build and release reproducibility

### Lifecycle boundaries

| Boundary | Owns | Must not claim |
|---|---|---|
| Source repository validation | source quality, contracts, component tests, dependency declarations, build inputs | that a distribution was installed or published |
| Software distribution build | transformation of an exact source revision into one closed RRP payload | project validity, runtime success, or publication |
| Internal package validation | namespace/API behavior, package metadata, declared dependencies, package build/check | whole-product installability by itself |
| Installation validation | selected R, installed inventory, loadability, launcher/resource discovery, isolation | a hospital project/provider is valid |
| Project validation | project manifest, trust, dependencies, producer/provider/model/state compatibility | correctness of installed RRP internals or clinical fitness |
| Runtime validation/provenance | admitted input, temporal validity, singular target, provider execution, attributable history | build or publication integrity |
| Deployment-artifact build | exact target-specific runnable closure and frozen effective inputs | remote deployment or production authorization |
| Release-candidate validation | clean-source rebuild, distribution integrity, clean install, examples, support matrix, licenses/docs | that a remote release exists |
| Publication | authorized immutable upload/tag/release and recovery state | successful external acquisition until verified |
| Published-release verification | remote identity, downloaded digest/signature, clean install/smoke from public bytes | ongoing production fitness at a hospital |

### Exact build identity

One release candidate should derive from one exact source revision, one
versioned distribution manifest, one build-tool version, and declared
platform/R targets. The build must fail closed on dirty or undeclared material
according to the release policy, construct internal packages rather than
temporary-install source directories, copy only declared resources, resolve
the intended dependency closure, produce an exact output inventory, and
independently validate the staged result.

The product version is not the Git commit. The commit and build-tool identity
are provenance. Internal package versions may be coordinated but do not replace
the product version. Runtime runs record the installed RRP and contract/target/
provider/project identities, not the development Git state.

### Determinism claim

The build must state whether it promises:

- **semantic/content reproducibility:** the same declared inputs yield the same
  installed files and digests after defined normalization; or
- **byte-for-byte archive reproducibility:** the final archive bytes also match.

At minimum, file ordering, permissions, path separators, generated metadata,
timestamps, locale, line endings, package-build nondeterminism, and compression
must be controlled or excluded from content identity. Build time can remain
provenance without perturbing the deterministic software instance identity.
Do not claim byte-for-byte reproducibility until clean independent builders
prove it.

### Dependency evidence

Internal package metadata should declare direct dependencies; an RRP release
lock/resolution manifest should record the exact transitive closure used for
each supported platform/R target. Package archives or immutable repository
references and checksums are needed when registry state alone cannot reconstruct
the release. The broad development `renv.lock` remains a developer environment,
not the distribution lock. Security or compatibility updates produce a new RRP
build/release identity; published payloads remain immutable.

## Deployment and Posit Connect dependency closure

### Preserve the artifact/target separation

The current target-neutral reduced artifact is a strong model: it has a closed
inventory, deterministic content identity, integrity checks, explicit direct
runtime roots, a coherent product set, a self-validator, and no target or
publication identity. The Connect realization then owns target files and
dependency realization. Those boundaries should survive even though their
builders move from repository scripts into installed software.

### Distinguish artifact profiles

Not every deployment needs every project component.

| Artifact role | Required closure | Deliberate exclusions |
|---|---|---|
| Product-only app snapshot | exact app/runtime subset, contracts, product-access adapter, coherent materialized products, R/package target declaration, provenance, validator | producer, provider, model, source clients, DuckDB history writer, writable project state |
| Compute-capable RRP deployment | exact required RRP runtime/resources, frozen effective project manifest, trusted producer/provider code, dependency closure, model artifacts, persistence/external-client declarations, app/products if selected, provenance, validator | development repository, unselected plugins/examples, secrets, ambient libraries |

The first row describes the current Connect use case and preserves the app's
architectural independence from sources and providers. The second is a future
artifact type, not authorization to expand the app artifact.

### Connect realization

For a product-only Shiny target, the generated content must carry the exact RRP
app/product-access subset and immutable product snapshot needed at runtime. It
must produce the Connect-supported dependency manifest from the artifact's
declared closure, record the requested/supported R version, and validate on the
target or a faithful clean build environment. It cannot depend on the local RRP
private library or project lockfile being visible to Connect.

The current realization prunes the development lock to Shiny/YAML roots and
uses `rsconnect` to generate `manifest.json`; Connect installs packages from
that target declaration. This is useful evidence, but future builders should
derive closure from the built artifact and release dependency metadata rather
than a root development lock. `rsconnect`/`jsonlite` remain builder dependencies
unless the selected target mechanism requires them at runtime.

If a future Connect deployment executes scoring, its artifact must freeze the
selected project composition and include producer/provider packages and model
artifacts or immutable resolvable references accepted by policy. Secrets and
live credentials remain target configuration, never artifact members. The
artifact records nonsecret configuration shape and required bindings.

## Governance and validation ownership

Future validation should be routed by lifecycle and dependency ownership:

| Owner | Principal evidence |
|---|---|
| Software source | fast universal checks, contract/schema validation, affected component tests, dependency/build-manifest validation, integration triggered by public boundaries |
| Internal package | package unit tests, namespace/API conformance, `R CMD build/check`, dependency and license metadata |
| Installed distribution | closed inventory/digests, safe paths/permissions, install/update/uninstall behavior, private-library isolation, resource discovery, launcher/doctor smoke tests |
| Project | manifest schema/version, explicit trusted registration, dependency/model evidence, writable-state safety, no embedded secrets, installed-RRP compatibility |
| Producer/provider | focused conformance, temporal/target compatibility, structured failure, deterministic promises, and separate scientific/local approval where applicable |
| Runtime | canonical admission, no-future-information rules, singular target request/output, provider isolation, history atomicity/attribution/retry/invalidation |
| Artifact/target | exact closed closure, integrity, secret exclusion, self-validation, target dependency/runtime realization, independence from source/install/project |
| Release candidate | clean exact build, support matrix, licenses/docs, clean install, synthetic/adopter end-to-end proof, artifact build proof |
| Published release | remote identities, authorization/recovery, checksums/signatures, clean public acquisition/install/smoke |

Current canonical, provider, history, product, artifact, observability/privacy,
and publication tests contain important invariant evidence and should be
reassigned to these owners. The Phase 0–11 suite names, implementation-record
text gates, whole-repository checkpoint on every change, Hospital distribution
and Git-realization proofs, and exact `v0.1.0` acquisition path remain historical
evidence. Their concepts survive only where mapped above; their chronology is
not the future validation architecture.

Strictness remains high where consequences are high: canonical meaning,
temporal validity, singular risk-target identity, provider compatibility,
trusted code, append-oriented history, privacy/secrets, dependency closure,
artifact integrity, provenance, and immutable publication. A documentation
assessment does not need to rebuild a Hospital repository to preserve those
controls.

## `v0.1.0` disposition

| `v0.1.0` asset or principle | Forward disposition |
|---|---|
| Canonical admission and source-local producer seam | **Reuse/refactor** into installed contracts and project loader |
| Provider registry, compatibility, structured execution/failure | **Reuse/refactor** for the one platform-defined risk target |
| `rrpruntime` package and base-R core | **Reuse/refactor** as internal package; replace hazard semantics prospectively, never relabel history |
| DuckDB history port/adapter and append/atomic/retry/invalidation rules | **Reuse** as supplied installed default with project-owned state |
| Logical products, YAML materialization/access, product-only app | **Reuse/refactor** for new target names/meaning and installed resource discovery |
| Human operation intent and structured diagnostics | **Reuse/refactor** behind stable installed APIs and launcher |
| Reduced artifact closed inventory and target separation | **Reuse**; derive from installed/project inputs rather than repository paths |
| Connect manifest/dependency realization and independent validation | **Reuse/refactor** from artifact-owned closure; generated Git is target-specific rather than the general product handoff |
| Exact inventory, SHA-256, clean candidate/acquisition, fail-closed replacement, publication recovery | **Reuse** at distribution/release/publication boundaries |
| Full tracked Platform repository as user release payload | **Remove from forward distribution design**; retain historical release bytes/evidence |
| Generated Hospital Implementation with embedded Platform archive/top-level lock | **Remove from forward acquisition architecture**; retain immutable `v0.1.0` history |
| Hospital wrappers, initialization, Git realization | **Historical/retire** after replacement clean-install proof exists |
| Root repository `renv` as universal environment | **Keep for development, split prospectively** from release, installed-software, project, and artifact dependency evidence |
| Phase-numbered universal validation and implementation-record gates | **Historical/refactor** into lifecycle/component ownership |
| Release/publication scripts and evidence | **Reuse principles; replace payload assumptions** for the next authorized release workflow |

Nothing in this disposition modifies or invalidates the published tag,
artifacts, checksums, release record, or support statement.

## Risks and tradeoffs

| Decision | Risk/cost | Mitigation or decision gate |
|---|---|---|
| Software distribution above R packages | New installer, manifest, prefix, and upgrade responsibilities | Keep launcher thin; reuse package/build tools; implement one supported platform path before broadening |
| Host R prerequisite | PATH/version drift and hospital installation burden | Bind one explicit executable at install; validate in doctor/runtime; publish a narrow support matrix |
| RRP-private package library | Disk duplication and package patch lifecycle | Treat closure as coordinated immutable software; rebuild releases for updates; avoid duplicating it in projects |
| Separate project environment | Conflicting transitive package requirements | RRP-first resolution and fail-closed checks initially; add process isolation only with evidence |
| Two internal packages | Coordinated versioning and cross-package API maintenance | One product version and compatibility manifest; do not create more packages without a clear boundary |
| Closed inclusion manifest | Every shipped file/category change needs explicit maintenance | Make classification review a build check and support controlled groups plus exact output inventory |
| Installed normative docs | Documentation can drift or enlarge payload | Build from the same revision, version it, and include only declared product-facing classes |
| Thin CLI over R | Startup/errors can still expose R internals | Stable result/error contract and renderer; no domain logic in launcher |
| Target-specific artifacts | More than one artifact profile/build path | Introduce only demonstrated profiles; preserve shared artifact identity/integrity primitives |
| Replacing Hospital distribution | Loss of proven handoff workflow before replacement matures | Retain legacy source/tests until clean installed-software/adopter proof reaches release readiness |
| Native dependency binaries | Platform-specific builds and supply-chain evidence | Define supported OS/R matrix, trusted acquisition, checksums, and clean builders before release |
| Reproducibility ambition | Byte-identical archives can consume effort without user value | Promise content reproducibility first; prove stronger determinism before claiming it |

## Unresolved decisions for synthesis and planning

The architecture direction is settled enough, but the next synthesis must make
the following choices explicit before implementation increments are sequenced:

1. supported operating-system, architecture, and R-version matrix for the
   first installed distribution;
2. install prefix, privilege model, user versus system installation, and
   side-by-side upgrade/rollback/uninstall behavior;
3. explicit R selection and deterministic fallback discovery policy;
4. launcher implementation and packaging mechanism, without designing domain
   command syntax prematurely;
5. main implementation package name, exported operation API, package version
   relationship, and whether `rrpruntime` remains separately versioned;
6. source distribution-manifest schema, output manifest, digest/signature
   policy, and first determinism claim;
7. source-versus-binary internal/dependency package build and trusted package
   acquisition strategy for each supported target;
8. project dependency declaration/lock format, RRP-owned package conflict rule,
   and threshold for separate-process isolation;
9. exact project template, installed example, and clean-room adopter proof;
10. current normative/user/internal documentation taxonomy and versioned
    publication route;
11. first artifact profiles and whether compute-capable deployment is in the
    initial implementation generation;
12. Connect R-version selection and generation from artifact-owned dependency
    evidence;
13. lifecycle validation ownership manifest, CI profiles, and transition off
    universal Phase suites; and
14. release version designation after the redesigned compatibility boundary and
    implementation scope are known.

These choices should be resolved together because installation layout,
dependency isolation, build targets, clean proof, and release CI constrain one
another. A small implementation spike may test host-R discovery, private-library
installation, and clean external invocation, but it should follow—not replace—the
accepted synthesis.

## Readiness for target-architecture synthesis

Another broad focused assessment is not required. The forward decisions now
form a coherent chain:

```text
one installed RRP software product
        ↓
thin canonical human launcher + stable programmatic API
        ↓
independent project owns producer, provider, dependencies/model, and state
        ↓
one RRP-defined remaining cumulative 30-day risk target
        ↓
lifecycle-owned validation and target-specific closed artifacts
```

Proceed to target-architecture synthesis and an incremental implementation
plan. That work should reconcile True North, architecture, plan, governance,
project contract, target contract, packaging, deployment, and migration
language into one accepted forward authority. It should preserve `v0.1.0` as
immutable evidence, stage replacement proofs before retiring legacy machinery,
and avoid choosing the next release number until the compatibility scope is
clear.

## Validation posture for this assessment

This is documentation-only architecture work. The current global instruction
to run the full development validator would execute historical Phase 0–11 and
Hospital distribution/acquisition proofs. As already identified in the
governance assessment, those checks do not provide causal evidence for the
content, links, navigation, or formatting of this assessment. The explicit task
therefore governs: validation is limited to the supported documentation
validator, direct documentation/diff review, Markdown trailing-whitespace
inspection, and `git diff --check`.

No complete development/checkpoint, Phase, Hospital, release, acquisition, or
publication suite is run. This proportional scope does not weaken any
executable claim because this assessment changes none.
