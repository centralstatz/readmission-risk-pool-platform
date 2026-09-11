# Installed software boundary and minimum RRP project contract assessment

## Status and scope

**Status:** retained forward precursor; its software/project ownership seam
remains recommended, while its provisional user-facing R-package topology is
superseded by the
[software distribution and build-reproducibility assessment](software-distribution-build-reproducibility-assessment.md)
and synthesized in the current [Platform Architecture](platform-architecture.md)

No redesign described here is implemented. References to a `v0.2.0` package
are historical proposal language, not a settled product form or next-release
designation.

This assessment defines the conceptual ownership seam between conventional
installed Readmission Risk Pool software and an independently owned RRP
project. It follows the accepted working directions in the [installed software
project-model assessment](installed-software-project-model-assessment.md) and
the [governance and validation assessment](governance-validation-architecture-assessment.md).

Published Platform and Hospital Implementation `v0.1.0` remain immutable
technical evidence. Their semantic machinery is the starting point; their
generated-distribution boundary and Phase 0–11 development process are not
future constraints. This document changes no contract, package, operation,
project loader, CLI, validator, artifact, release, or publication state.

## Executive conclusion

A conventional installed RRP boundary is feasible with the existing
machinery. The semantic flow is already divided at useful interfaces. The main
obstacle is physical composition: most orchestration, contracts, adapters,
products, application code, and deployment builders are sourced or copied from
a development-repository root. Only `rrpruntime` is currently package-shaped.

Conceptually, **install RRP** must install one coherent, versioned software
capability containing:

- namespaced orchestration and public project operations;
- canonical, runtime, provider, history, product, observability, and deployment
  contracts plus their validators;
- `rrpruntime` behavior;
- default DuckDB persistence and YAML product adapters;
- the initial product suite and supplied product-only Shiny application;
- target-neutral artifact and supported target builders/validators;
- project loading, validation, initialization, and diagnostics; and
- a synthetic example/template that uses the public project contract.

A minimum independent project is responsible for:

- one versioned, nonsecret project manifest;
- one fixed, explicitly trusted registration entry point;
- its source-to-canonical producer declaration, mapping, source-local
  validation, configuration handling, and callable;
- exact selection of its producer and estimand-to-provider composition;
- any custom estimand/provider code and dependencies it chooses to add; and
- a writable state root outside installed software.

Installed defaults mean the project does **not** need to redeclare persistence,
products, the supplied app, or a deployment target merely to use them. Those
become project declarations only when a supported override exists.

The architecture supports one development repository. Normal package build
mechanisms can install only runtime assets while retaining tests, examples,
architecture history, CI, and release tooling in the larger source repository.
A second generated Hospital software repository is not required.

The recommended provisional topology is a user-facing installed package that
owns orchestration/resources and composes the existing focused `rrpruntime`
package. This maximizes direct reuse and preserves the dependency-light
semantic core. Both should behave as one coordinated RRP software release for
users. Exact package names, independent version policy, and whether the split
earns its long-term maintenance cost require one packaging decision before
implementation.

This remains primarily refactoring and selective generalization, not
replacement of the semantic core. The two material semantic generalizations
are a governed estimand composition mechanism and injection of the selected
provider into normal history orchestration. Trusted project composition is a
new public boundary, but it builds directly on the proven producer and provider
registries.

## Evidence and method

The assessment traced the supported human scripts into their sourced operation
libraries, fixed composition, contracts, `rrpruntime`, DuckDB adapter, product
layer, YAML materializer, app, reduced artifact builder, Connect Cloud
realization, root dependency environment, generated Hospital wrappers, and
release-only machinery. It worked backward from actual `validate`, `run`,
history, products, app, artifact, and target behavior. No sibling repository or
external source was used.

Labels below distinguish three facts that are easy to conflate:

```text
where source code is maintained
        ≠
what files are installed with RRP
        ≠
what one hospital-owned project provides or generates
```

## Current operational dependency graph

### Physical composition today

Every supported user operation starts from the script's own path and derives
the Platform repository root. That one root currently acts as all of the
following:

```text
development source root
  + contract and asset catalog
  + selected installation configuration
  + executable implementation registry
  + dependency project
  + writable state root
  + artifact source catalog
```

The resulting path is:

```text
repository-relative Rscript
  → source ordered operations/lib files
  → parse repository-relative YAML contracts
  → source fixed synthetic/default adapter/product/app code
  → install runtime/ into a temporary library
  → choose repository-owned reference composition
  → read/write repository-relative build state
  → copy allowlisted repository files into an artifact/target
```

The Hospital Implementation adds a managed archive/extraction layer but then
reconstructs essentially the same repository-root runtime. It does not create
an installed-software boundary.

### Operation trace

| Current operation | Significant dependencies and discovery | Current side effects | Future boundary |
|---|---|---|---|
| `initialize-platform.R` | Infers repository root; requires root `renv.lock`, `renv/activate.R`, operation scripts, and five installed packages | Creates/checks ignored `build/` only | Installed project initializer receives an explicit destination/project; dependency bootstrap is separate and consentful |
| `doctor.R` | Sources observability, runtime/history/product/adapter/operator files; checks repository file inventory; temporarily installs `rrpruntime`; derives default DuckDB/product paths | Read-only apart from removed probes and temporary package library | Project-aware diagnostic checks installed software, manifest/registration, dependencies, state paths, lifecycle, products, and app |
| `validate-producer.R` | Loads installed contract parsers, sources fixed `installed-producers.R`, which sources the synthetic implementation and root `config/platform-instance.yml` | In-memory only | Project validation loads the fixed trusted project registration and validates the selected producer through unchanged result/admission semantics |
| `run-platform.R` | Sources 13 operation modules plus fixed producer composition and DuckDB; temporarily installs `rrpruntime`; selects synthetic scale, reference provider, and root-relative database | Appends/idempotently persists history | Generic installed cycle receives project context, selected producer, estimand composition, provider composition, persistence port, and explicit run inputs |
| canonical admission | Producer execution calls repository-root clinical validators, which parse canonical contracts/profiles/domains from `contracts/` | In-memory only | Installed contract catalog and admission service; project supplies only candidate output and declared identities |
| estimand request construction | `runtime-operation.R` loads one estimand YAML; `rrpruntime::build_estimand_requests()` embeds its exact identity and one-day `(start, end]` calculation | In-memory only | Installed governed estimand catalog/implementation selected by project; this requires real generalization |
| provider execution | `provider-operation.R` reads provider contracts and always registers/selects `reference_provider_adapter`; history calls `rrp_execute_reference_estimation()` | In-memory results later appended | Project registration supplies exact provider selection/adapters; installed runtime retains registry, compatibility, isolation, result, and estimate checks |
| history persistence | `reference-history-operation.R` constructs lifecycle records, calls the reference provider path, sources DuckDB files, parses history contracts, and opens root-configured database | Initializes database; appends status and terminal batch; reopens for proof | Installed generic cycle plus default adapter; project owns state path, adapter selection if nondefault, backup/retention policy |
| `inspect-reference-history.R` | Temporarily installs runtime, sources DuckDB, defaults to deterministic reference run ID | Read-only | Project history query/run catalog through the persistence port; explicit run selection remains supported |
| `build-reference-products.R` | Sources product layer and YAML adapter, reads history/product contracts, defaults to reference run ID and `build/reference-products` | Optional atomic current-product publication | Installed product service reads project history selection and writes project product state through selected/default adapter |
| `launch-reference-app.R` | Sources product/YAML/app files; opens root-relative current product store; directly launches Shiny | Read-only long-running process | Installed supplied app receives validated project product access; project-specific app code is not required |
| `build-application-artifact.R` | Loads repository artifact runtime; copies 20 allowlisted app/product/YAML/contract/dependency files from source tree plus current product files | Immutable artifact directory and current pointer | Builder copies versioned installed assets plus validated project product output and records software/project provenance |
| artifact validation | Runs the artifact's own validator in a fresh R process; requires only Shiny/YAML runtime closure | Temporary validation log removed | Keep standalone closed-output validation; it does not inspect project Git or source state |
| Connect Cloud build/validation | Copies repository target templates and whole reduced artifact; prunes root `renv.lock`; uses `rsconnect`/`jsonlite`; initializes a generated Git repository | Creates/replaces an explicitly owned outside-repository target | Installed target adapter consumes exact artifact and declared dependency evidence; generated-target Git rules remain target-local |
| repository development validation | Reads the complete source/phase/release tree and runs repository validators plus all phase suites | Temporary test state removed | Maintainer-only, change-scoped source/CI/release validation; never project validation |
| Hospital distribution/release/publication | Embeds Platform archive, constructs one top-level lock, validates closed editable source, realizes pristine Git, creates candidates and remote evidence | Generated candidates and explicitly authorized remote mutation | Historical `v0.1.0` machinery; future installed-software release/publication remains maintainer-only |

### Current runtime dependency chain

```text
fixed synthetic producer
  → generic producer registry/result
  → repository-loaded canonical admission
  → temporary rrpruntime installation
  → fixed estimand request builder
  → fixed transparent provider composition
  → generic history port
  → sourced DuckDB adapter
  → sourced products + YAML materializer
  → sourced product-only app
  → repository-file-map artifact
  → repository-template target realization
```

Only the producer and provider endpoints are reference-specific in semantic
intent. Repository-root discovery makes every physical stage appear
reference-specific even where the underlying functions are generic.

## Future ownership map

| Dependency or capability | Future ownership | Reason |
|---|---|---|
| Specification envelope/parser and conformance result vocabulary | **INSTALLED RRP SOFTWARE** | Every contract/project validator needs one supported interpretation |
| Canonical bundle/profile/domain contracts and admission | **INSTALLED RRP SOFTWARE** | RRP, not a project, owns the handoff semantics it promises to execute |
| Runtime, provider, estimate, and history contracts | **INSTALLED RRP SOFTWARE** | They define public compatibility and retained evidence |
| `rrpruntime` state, eligibility, provider, estimate, and persistence-port code | **INSTALLED RRP SOFTWARE** | Already implementation-neutral and package-shaped |
| Generic producer registry, result validation, execution, and admission orchestration | **INSTALLED RRP SOFTWARE** | It is platform behavior above local source interpretation |
| Project contract parser, loader, context, validation, and operation orchestration | **INSTALLED RRP SOFTWARE** | Users need a stable supported control surface |
| Initial estimand declaration and request builder | **INSTALLED RRP SOFTWARE** | It is the supplied rigorously defined default; extension policy is separate |
| Provider registry/compatibility/execution | **INSTALLED RRP SOFTWARE** | Projects register peers against a platform-owned interface |
| Transparent provider | **INSTALLED EXAMPLE/TEMPLATE ASSET** and optionally installed supplied demonstration component | It is useful teaching/conformance behavior, not the normal hospital model |
| History record semantics and generic persistence port | **INSTALLED RRP SOFTWARE** | Backend-independent core behavior |
| DuckDB adapter and its declaration | **INSTALLED RRP SOFTWARE** as a default adapter | It is a validated generally useful local implementation; its path is project-owned |
| Initial product contracts/builders/access interface | **INSTALLED RRP SOFTWARE** | They consume generic history and form the supplied application contract |
| YAML product materialization/access adapter | **INSTALLED RRP SOFTWARE** as a default adapter | A useful replaceable physical default |
| Supplied product-only Shiny app and application declaration | **INSTALLED RRP SOFTWARE** | Ordinary use should not copy/edit app source |
| Reduced artifact and supported target builders/validators/templates | **INSTALLED RRP SOFTWARE** | They are software capabilities operating on validated project outputs |
| Project identity, contract version, RRP compatibility, component selections, state root | **REQUIRED RRP PROJECT DECLARATION** | RRP cannot validate, compose, attribute, or safely write without them |
| Fixed registration entry-point file | **REQUIRED RRP PROJECT CODE** | It is the single explicit trust boundary for executable project composition |
| Source access, source-local validation, mapping, producer declaration/adapter | **REQUIRED RRP PROJECT CODE** | A real hospital must interpret its own source below the canonical handoff |
| Source credentials, connection details, private mappings | **REQUIRED RRP PROJECT CODE/configuration environment**, never governed manifest data | They remain hospital-owned and must not cross diagnostics/artifact boundaries |
| Exact supplied-estimand selection | **REQUIRED RRP PROJECT DECLARATION** | Runtime/provider composition must be deterministic |
| Custom estimand declaration/request builder | **OPTIONAL RRP PROJECT EXTENSION** | Required only if the project does not use a supplied supported estimand; API unresolved |
| Exact provider selection for each estimand | **REQUIRED RRP PROJECT DECLARATION** | Provider compatibility and provenance need unambiguous selection |
| Hospital provider declaration, adapter, model loader, model artifact reference | **REQUIRED RRP PROJECT CODE** for a real custom provider; otherwise an installed supplied peer may satisfy it | Model semantics and dependencies are hospital-controlled |
| Nondefault persistence/product/app/target adapters | **OPTIONAL RRP PROJECT EXTENSION** | Defaults avoid speculative mandatory configuration |
| Project dependency environment/lock and component packages | **REQUIRED PROJECT RESPONSIBILITY**; mechanism **RECONSIDER** | The executable project must reproduce its own code, but `renv` need not be the semantic project contract |
| DuckDB/history database | **GENERATED PROJECT STATE**: persistent authoritative operational state | Not software source or disposable cache |
| Materialized products and current pointer | **GENERATED PROJECT STATE**: reproducible published output | Rebuildable from history, but atomically governed while exposed |
| Diagnostic console events | Ephemeral operation output; retained sink, if later configured, is **GENERATED PROJECT STATE** | Current default intentionally retains nothing |
| Caches and staging directories | **GENERATED PROJECT STATE**: disposable/temporary | Must be safe to remove and never treated as source |
| Application artifact and target realization | **GENERATED PROJECT STATE**: immutable build output | Closed inventory/checksum applies after build, not to editable project source |
| Synthetic source, mapping, producer, configurations, tutorial | **INSTALLED EXAMPLE/TEMPLATE ASSET** | Must materialize as an ordinary conforming project, never privileged wiring |
| Architecture history, source validation, CI, tests, fixtures, release/publication tools/evidence | **MAINTAINER-ONLY MATERIAL** | Needed to develop/release RRP, not to run a project |
| Hospital archive, extraction, wrappers, closed editable inventory, pristine Git realization, two-product publication | **LEGACY/HISTORICAL MATERIAL** | Retain `v0.1.0` evidence; remove from the forward user path |
| Custom products/app ABI, multiple persistence adapters, non-R provider processes | **RECONSIDER** | Useful possible extensions without enough evidence for the minimum contract |

## Installed software boundary

### Meaning of one installed RRP release

The installed boundary is a versioned capability, not necessarily one package
directory. It must be possible to start a clean R process outside the
development repository, load RRP, point it at one project, and exercise every
supported operation without sourcing or copying files from the source checkout.

Installed code owns:

- parsing and validating built-in contracts and project manifests;
- constructing an immutable project context;
- loading one explicit trusted project registration entry point;
- registering, resolving, and validating selected components;
- orchestrating canonical admission through history and products;
- constructing the supplied app;
- building/validating artifacts and targets; and
- emitting privacy-safe structured operation results/events.

Installed resources own:

- versioned YAML contracts and supplied declarations;
- app resources and target templates;
- default adapter declarations;
- project template/example files; and
- any self-contained validation fixtures needed at runtime.

They must be found through an installed resource catalog such as package
resource lookup, never by discovering the RRP development repository.

### Plausible physical topologies

| Topology | Reuse and API clarity | Dependencies/versioning | Assets/deployment | Assessment |
|---|---|---|---|---|
| **A. One user-facing package containing everything** | Simplest user namespace and installation; would move `rrpruntime` code into a larger package | One version and dependency set, but optional Shiny/DuckDB/target dependencies can burden the core | Straightforward single resource catalog; artifact builder still selects a reduced subset | Plausible, but discards the proven dependency-light core boundary without demonstrated benefit |
| **B. User-facing RRP package composing `rrpruntime`** | Reuses the existing package substantially as-is; user API lives above it; core remains testable independently | Requires compatible package version policy, but users install one declared dependency closure | User package can own contracts, adapters, app, templates, artifact/target resources | **Provisionally recommended.** Least disruptive and clearest ownership today |
| **C. Several public packages or package plus bespoke launcher** | Could isolate app, persistence, targets, or CLI | Highest compatibility/release complexity before independent demand exists | Flexible optional installs | Do not choose now; premature physical decomposition |

Under Option B, `rrpruntime` need not become a separately marketed product.
The user-facing package declares and tests an exact compatible runtime range,
and the RRP release proves the pair. If later evidence shows no independent
value in the split, consolidation remains possible behind stable public project
operations.

The package boundary should remain compatible with a future `readmit` peer:
`readmit` may construct conforming estimand/provider/model objects or adapters,
but RRP owns project composition, execution, history, products, and deployment.

## Repository-relative behavior and installed replacements

| Current behavior | Why it cannot remain runtime behavior | Conventional replacement |
|---|---|---|
| Infer Platform root from `--file` | Assumes use inside source checkout | Public function/launcher receives explicit project path; package finds only its own resources |
| `source(operations/lib/*.R)` in fixed order | Exposes internal files/order and bypasses a namespace | Namespaced installed functions with explicit exports/internal calls |
| Parse `contracts/...` below root | Makes source layout a runtime API | Versioned installed contract/resource catalog |
| Temporarily run `R CMD INSTALL runtime/` | Rebuilds software during every operation | Normal installed dependency on compatible `rrpruntime` |
| Source `installed-producers.R` and synthetic files | Privileges the reference composition | Fixed project registration entry point plus installed example project |
| Pass `repository_root` to producer execution/admission | Conflates software and project contexts | Separate installed contract/admission service and project context |
| Source DuckDB/product/YAML/app implementations | Treats reusable software as loose scripts | Package namespaces and registered installed defaults |
| Read `config/platform-instance.yml` | One repository-owned instance masquerades as deployment selection | Project manifest owns exact selections |
| Read/write `build/...` below Platform | Writes into installed/development software | Project context resolves declared state root and derived output locations |
| Copy app/contracts/R files through repository source maps | Requires full development source at build time | Builder reads installed resource manifest plus validated project outputs/extensions |
| Prune root `renv.lock` for Connect | Couples target dependency resolution to maintainer environment | Build dependency closure from released software metadata, artifact requirements, and project environment as relevant |
| Hospital wrapper locates/extracts embedded Platform archive | Distributes source tree as runtime | Install released RRP normally; project contains no embedded Platform |
| Reference run IDs and `--scale` defaults | Encodes example identity in generic lifecycle | Project/run context generates or accepts non-patient run IDs; scale remains example-producer configuration only |

## Minimum RRP project contract

### Minimum physical form

The smallest coherent project needs only:

```text
PROJECT_ROOT/
  rrp.yml                 # versioned, declarative, nonsecret manifest
  R/register.R            # fixed trusted executable boundary
  <project-owned files>   # layout private to the project/registered components
  <state root>            # generated and normally ignored; may be elsewhere
```

The filenames are recommended placeholders, not finalized public names. The
contract should fix the manifest and registration locations once chosen so RRP
does not recursively scan source folders or execute a path supplied by YAML.
Component internals such as `sources/`, `mappings/`, `providers/`, and `models/`
are template conveniences, not project validity rules.

### Minimum manifest information

| Required information | Why RRP actually needs it |
|---|---|
| Project-contract identity/version | Selects the parser and compatibility rules before executing project code |
| Stable project ID and project version | Supports non-patient identity, compatibility, diagnostics, run/build provenance, and migrations |
| One-health-system/non-multitenant scope | Preserves the established deployment/privacy boundary |
| Compatible RRP software version range (initially likely exact tested line) | Fails closed before incompatible code/contract execution |
| Exact expected canonical profile identity/version | Makes the producer/runtime semantic handoff explicit before source execution |
| Exact selected producer ID/version | Resolves one registered source composition unambiguously |
| Selected estimand ID/version list | Defines the quantities the run will request; one is sufficient initially |
| Exact provider ID/version for every selected estimand | Makes execution routing and compatibility deterministic |
| Project state root | Separates writable history/products/artifacts from installed software and makes side effects inspectable |

The manifest should use the common specification envelope if that vocabulary
remains supported, but project-specific field names and range syntax require a
versioned contract decision. Project ID must be a safe institutional/project
identifier, not a patient identifier.

### Deliberately absent from the minimum manifest

- Source credentials, connection strings, raw paths containing private detail,
  SQL, mapping tables, or secrets.
- Arbitrary R function names, scripts, URLs, packages to install, or remote
  plugin locations.
- DuckDB/YAML/product/app/target selections when installed defaults are used.
- A required Git repository, branch, commit, clean index, remote, or pristine
  template checksum.
- CentralStatz development phase, release-candidate, or publication state.
- Custom product/app configuration before those extension contracts exist.
- Redundant implementation/mapping/provider declarations already returned by
  trusted registration and checked against manifest selections.

Dependency declarations belong to component definitions and the project
environment, not as an unbounded package-install list in the manifest.

### Project context

After declarative validation, installed RRP should create one immutable context
containing:

- normalized explicit project root and manifest location;
- parsed project identity, compatibility, profile, selections, and state root;
- installed RRP/contract catalog identity;
- resolved registration boundary;
- validated component registry/composition; and
- resolved state/service handles appropriate to the requested operation.

Passing this context replaces passing `repository_root`. It must not contain
credentials or patient-level values merely for convenience. Operations may
derive narrower runtime/build contexts from it.

## Project discovery and trusted registration boundary

### Project-root resolution

The initial supported rule should be explicit:

1. A callable operation accepts a project path.
2. A thin human launcher may default to the current working directory only when
   the exact manifest exists there.
3. The resolved path becomes one normalized project root.
4. No upward search, environment-variable precedence, sibling probing, Git-root
   inference, or fallback to the installed package directory occurs.

Controlled upward search is convenient but can silently select the wrong
clinical context in nested directories. An environment variable is useful for
automation but introduces ambient state. Neither is necessary for the minimum
contract. A reusable project context object avoids repeated discovery during
one process.

### Registration responsibilities

The fixed project entry point should expose one callable that returns a
structured composition rather than mutating `.GlobalEnv`. Its responsibilities
are to provide:

- producer declarations and trusted callables;
- estimand declarations plus approved request builders when project extension
  is supported;
- provider declarations and trusted adapters/model loaders;
- optional declared adapter/app/target extensions only when supported; and
- component dependency/provenance metadata that contains no secrets.

Installed RRP then:

1. validates the manifest before execution;
2. sources only the fixed local registration file into a controlled environment;
3. invokes the one expected callable;
4. validates the closed structure and every declaration;
5. registers only callable objects returned through supported interfaces;
6. resolves every manifest selection exactly once; and
7. validates cross-component compatibility before source access or state
   mutation.

The controlled environment reduces accidental namespace leakage; it is not a
security sandbox. Trust comes from an operator explicitly selecting and
reviewing the local project and dependency environment. RRP must not recursively
source project files, evaluate YAML as code, discover arbitrary installed
plugins, download code, or imply that validation makes hostile R code safe.

## Source-to-canonical boundary

The existing producer interface is substantially the correct public seam:

```text
hospital-owned source access/configuration
  → hospital-owned source-local validation and mapping
  → registered producer callable
  → structured producer adapter result
  → installed RRP result validation and canonical admission
```

The project must implement its source interpretation, source-local schema and
validation, mapping, implementation/mapping identities, declaration, and
callable. Internal representation is not an RRP project-layout invariant. A
constrained declarative mapping language may be offered later, but arbitrary
real source systems require trusted executable code; YAML alone should not be
pretended sufficient.

Installed RRP supplies the producer registry, declaration/result contract,
stage/failure behavior, canonical contracts, admission, diagnostics, and
conformance harness. Current producer-result semantics can remain substantially
unchanged. The callable should receive a project-owned invocation/configuration
context rather than the Platform root. Source details and secrets never cross
the canonical boundary.

The synthetic project must implement this exact public path. Its `test` and
`reference` scale are producer-specific configuration, not generic RRP modes.

## Estimand boundary

### Installed responsibility

RRP owns the semantic contract for an estimand it can execute, validation of
identity/version and population/time/event/horizon/terminal/competing-event/
output/coherence meaning, request-set conformance, and propagation through
provider compatibility, estimates, history, products, and provenance.

The initial next-day conditional-hazard estimand and its request builder should
ship as installed software. A project selects it exactly without reimplementing
its semantics.

### Project extension responsibility

A custom estimand, if supported, must register a versioned semantic declaration
and either:

- belong to an installed, constrained declarative family whose request builder
  RRP owns; or
- provide a trusted request-construction adapter satisfying a stronger public
  conformance contract.

Simply loading arbitrary estimand YAML is insufficient because current request
construction contains executable temporal semantics.

### Current blockers and initial scope

`rrpruntime` currently recognizes exactly one estimand and constructs one-day
`(start, end]` requests directly. Provider declarations/history/product keys
already carry estimand identity, so downstream representation is promising,
but multiple estimands have not been proven through operation summaries and
the supplied app.

The minimum project contract may represent a list and provider mapping without
promising multiple simultaneous estimands in the first implementation. A
focused estimand-composition decision must choose shipped-only versus constrained
declarative versus trusted executable extension and define cardinality before
implementation planning is final.

## Provider and model boundary

The installed provider interface is already close to the target. RRP should
retain declaration validation, an in-memory explicit registry, exact
resolution, estimand/state/capability/time compatibility, isolated callable
execution, structured failures, output/cardinality/bounds conformance, and
accepted estimate construction.

A project registration provides a provider declaration and trusted adapter. A
real provider may also own model artifact loading, feature construction from
the admitted state, package dependencies, and nonsecret model identity/digest.
Credentials or patient-level data remain outside declarations and diagnostics.

Generic orchestration must receive:

```text
provider registry
+ estimand-to-provider exact selections
+ runtime/estimand/provider contracts
+ execution identity
```

It must not call `rrp_execute_reference_estimation()` or emit literal transparent
provider identity. The transparent provider becomes an installed example or
supplied demonstration peer registered through the same interface.

Non-R services, remote model endpoints, secret acquisition, model calibration,
and model-update lifecycles are not required for the minimum project contract
and need separate contracts before support.

## Dependency boundary

### RRP software dependencies

Package metadata owns dependencies required by installed RRP itself. Based on
current executable behavior, the closure includes the runtime package, YAML
parsing, default DBI/DuckDB persistence, Shiny for the supplied app, and target
builder packages such as `jsonlite`/`rsconnect` where that capability is
installed or suggested. Optional capabilities should not force unnecessary
core attachment, but their tested versions must be explicit.

The root `renv` remains maintainer development/release evidence; it is not the
hospital's runtime environment.

### Project dependencies

The project owns packages required by mappings, producers, estimands, providers,
models, and optional extensions. Installed RRP should be represented as a normal
project dependency with a compatible version. Registered component definitions
should declare enough nonsecret dependency requirements for project validation
to check the current library before execution.

RRP should not silently install packages or control the hospital's complete
library during validate/run. Project initialization may offer a dependency
baseline only through an explicit, documented operation.

### `renv` disposition

A project-owned `renv.lock` is a strong supported default because it can capture
the exact RRP and project package closure. It should not be a semantic condition
for recognizing a project: hospitals may use other controlled environment
mechanisms. The project contract should require reproducible dependency evidence
at validation/build/release boundaries, not one tool unless support policy later
chooses it.

Normal restoration must not invalidate the project because an embedded Platform
archive differs. Compatibility is checked against installed RRP and component
contracts, not a nested source tree.

### Build/deployment dependencies

An artifact builder computes the closure for the artifact's actual executable
contents. The current reduced app artifact needs Shiny and YAML, not DBI,
DuckDB, providers, or `rrpruntime`, because it consumes materialized products
only. Provider-specific dependencies enter a future artifact only if that
artifact actually executes the provider. This distinction prevents project
dependency freedom from bloating or contaminating a display-only artifact.

Exact lock generation and how local/package/archive dependencies are made
available to deployment targets still require a focused packaging/dependency
decision.

## State, history, and products boundary

### State classification

| State/output | Current location/behavior | Future ownership and durability |
|---|---|---|
| DuckDB operational history | `build/reference-operational-history.duckdb` by default | Project-owned persistent authoritative state; backup/retention/migration governed explicitly |
| Materialized YAML products | `build/reference-products` with atomic immutable bundle/current pointer | Project-owned reproducible generated state; do not hand-edit while exposed |
| Operation diagnostics | Console plus optional callable in-memory sink; no default retention | Ephemeral by default; any future retained sink is separate project state with privacy policy |
| Temporary package libraries/logs | Per-operation temp directories/files | Disappear from normal operation once software is installed |
| Builder staging | Hidden temporary directories under output parents | Disposable and removed/rolled back; target/builder owns safety |
| Application artifacts | Immutable build directories plus current pointer | Project-owned generated build output with closed inventory/checksum |
| Connect realization | Explicit outside-repository generated Git tree | Generated target output; target rules apply only inside it |
| Release/Hospital build state | Root `build/releases` and distribution stores | Maintainer-only legacy/release state, never project state |

The minimum manifest should declare one state root. The initial software can
derive conventional sublocations for history, products, artifacts, caches, and
temporary work. Per-adapter overrides should be added only when a demonstrated
deployment needs them.

Mutation checks must ensure an operation writes only to its resolved owned
target and never inside an installed package. Whether absolute/external state
roots and symbolic links are supported is a deployment-policy decision; fail
closed initially and document mounted-volume needs before generalizing.

### History and run selection

Operational-history contracts and the persistence port remain installed RRP
behavior. The project selects/configures a default adapter and owns the state.
Append, atomic terminal batches, retry/conflict, invalidation, and valid/current
read semantics remain strict.

Current scripts know deterministic reference run IDs. Generic project products
and inspection require a supported logical run-list/query service or explicit
run IDs; they must not expose DuckDB tables as the public API. This is an
orchestration addition, not a history semantic rewrite.

### Products

The initial product suite, builders, conformance, product-access interface, and
YAML adapter can remain installed defaults. Product operations receive a
project persistence port/run selection and write the project product store.
They must retain estimand/provider/project provenance and compatibility.

Custom product builders are not necessary for the minimum project contract.
They require a separate extension decision before the manifest gains product
plugin fields.

## Application and deployment boundary

### Supplied application

The product-only app is already the right seam. It receives logical product
access and does not know sources, mappings, providers, persistence, or hosting
targets. It should live entirely in installed RRP and launch against the
validated project product store. A hospital should not copy or edit its source
for ordinary use.

The current title and fictional/nonclinical wording are reference-specific and
must become installed default configuration or example-project presentation,
without allowing configuration to redefine analytical semantics. Optional
custom app modules or replacements are future extensions, not required project
code.

### Target-neutral artifact

For the existing product-only deployment shape:

```text
installed RRP app/runtime resources
  + validated project materialized products
  + exact runtime dependency evidence
  → closed target-neutral artifact
```

The artifact should not include source credentials, mapping/provider code,
DuckDB, full history, or the entire project because the deployed app does not
execute them. It should record exact RRP, project manifest, application,
product set/build, source run, estimand/provider, builder, and dependency
identities/digests as appropriate without leaking protected data.

The current artifact contract's closed inventory, checksums, product/app
compatibility, immutable build directories, atomic current pointer, and
standalone validation remain substantially valid. Its source map must change
from development-tree files to installed resources and explicit project
outputs. Whether the artifact carries selected source files, installed package
trees, package archives, or installation metadata is a packaging/target choice,
not a project-layout invariant.

### Connect and other targets

Connect Cloud remains a target adapter consuming the artifact. Installed RRP
ships its templates/validator; the builder resolves dependency evidence without
pruning the maintainer root lock. Destination ownership, staged Git, no remote,
and standalone validation remain rules of that generated output only.

Future deployment that also runs prediction/history would be a different
artifact profile with project code, provider dependencies, secrets supplied at
runtime, writable state, and stronger operational controls. It must not be
inferred from the current display-only artifact.

## Synthetic example-project boundary

The current synthetic source generator, validation, mapping, producer, two
scales, and transparent provider remain useful as:

- an installed project template/example;
- tutorial material;
- a demonstration dataset/generator;
- fast producer/contract fixtures; and
- clean-install/release acceptance.

One materialized synthetic project must contain the same manifest and fixed
registration entry point expected of a hospital. It uses public installed APIs,
declares/selects its producer, estimand, and provider, owns its state root, and
runs outside the RRP development checkout. RRP release tests may use smaller
fixtures internally, but normal example execution receives no privileged
registry, hidden path, fixed Platform configuration, or generic `--scale`
special case.

## Public operation and API categories

Exact names and CLI syntax remain undecided. The supported installed behavior
needs these callable categories:

| Category | Project context and input | Output | Side effect and validation boundary |
|---|---|---|---|
| Initialize project | Explicit destination, optional template/profile | Structured created-file/dependency guidance result | Creates only a new/owned project skeleton; never initializes clinical state implicitly |
| Load/validate project | Explicit root; optional controlled conformance scenario | Immutable project context and structured issues | Read-only except removed temporary checks; validates manifest, registration, dependencies, selections, compatibility, and safe paths |
| Diagnose | Project context | Structured environment/lifecycle readiness and recovery | Read-only; distinct from semantic project validation |
| Run | Context, run ID/as-of, producer invocation | Structured run/producer/provider/history summary | Source access plus append/idempotent project history; no products/app/deploy |
| Inspect history | Context and explicit/logically selected run/view | Logical history/read result | Read-only through persistence port |
| Build/materialize products | Context, run selection/cutoff, output intent | Product-set result/materialization identity | Reads history; optionally atomically replaces current project products |
| Construct/launch app | Context/product access, host/port | App object or long-running process result | Reads products only; no run or product refresh |
| Build/validate artifact | Context, exact product set, destination/profile | Immutable artifact identity/validation | Writes only owned artifact store; validates closed output |
| Build/validate target | Exact artifact, target, explicit destination | Target realization identity/validation | Target-scoped generated mutation; no remote deployment unless separately authorized |

Stable project-author interfaces will be needed for:

- project manifest/context validation;
- producer registration/result construction;
- estimand registration/request construction if extension is supported;
- provider registration and execution adapter contracts;
- persistence/product/app/target extensions only when deliberately public; and
- operation results, diagnostics, and provenance.

Internal details include source-file order, repository root discovery, YAML
parser helpers, default file maps, reference IDs/scales, staging algorithms,
and temporary package installation. They should not become compatibility APIs.

Thin scripts or a future CLI may translate arguments and render results, but
must call the same installed operations. The callable boundary comes first.

## Development repository and packaging implications

The one authoritative repository should contain:

```text
package source and installed-resource source
contracts/schemas and compatibility metadata
default adapters, products, app, artifact and target resources
example-project source/templates
unit, conformance, integration and clean-install tests
developer documentation and architecture/history
maintainer dependency environment
CI, release and publication tooling/evidence
legacy v0.1.0 evidence while retained
```

Only the first four groups, plus user-facing installed documentation needed to
operate/extend RRP, belong in installed software. Package resource manifests
and ordinary build exclusion rules can omit development tests, history,
release evidence, root configuration, CI, and generated state. Release
validation must inspect the built/installed inventory and run the synthetic
project from a clean unrelated location.

The source repository may remain monorepo-shaped even if it builds two internal
packages. A generated Hospital repository is unnecessary because a package
archive/binary plus a small project template already separates immutable
software from editable hospital code.

Release source, installed package contents, project source, generated state,
deployment artifact, and target realization each need their own inventory and
provenance rules. One whole-tree checksum cannot represent all six ownership
types.

## Relationship to future `readmit`

The project registration and exact component-selection boundary allows a
future `readmit` package to provide:

- estimand declarations or builders belonging to a supported RRP contract;
- provider adapters and model objects;
- calibration/update components with explicit identity;
- source-mapping helpers; or
- conformance tooling.

A project explicitly registers/selects those components and declares the
`readmit` dependency. RRP validates public contracts and executes through them;
it does not inspect `readmit` internals or require `readmit` for default core
operation. No `readmit` API is designed here.

## v0.1.0 reuse and disposition matrix

| Existing machinery | Disposition | Forward use |
|---|---|---|
| Specification foundation and YAML envelopes | **REUSE SUBSTANTIALLY AS-IS** | Installed contract/project parsing and identity foundation |
| Canonical bundle/profile/domain semantics and admission | **REUSE SUBSTANTIALLY AS-IS** | Installed canonical service |
| Canonical producer declaration/result/registry/execution | **REUSE SUBSTANTIALLY AS-IS** plus path refactor | Public project producer seam |
| `rrpruntime` eligibility/state/provider/estimate/history ports | **REUSE SUBSTANTIALLY AS-IS** | Focused installed runtime dependency |
| Operations/lib orchestration | **REFACTOR INTO INSTALLED SOFTWARE** | Namespaced project-aware services receiving context/composition |
| Runtime contract and resource loading | **REFACTOR INTO INSTALLED SOFTWARE** | Installed resource catalog rather than repository paths |
| Estimand support/request construction | **GENERALIZE** | Governed selected estimand(s), not one embedded identity/interval |
| Reference provider construction in normal history | **GENERALIZE** and **REPLACE** | Inject project provider composition; reference peer becomes example |
| `installed-producers.R` and root platform-instance config | **MOVE INTO PROJECT CONTRACT** and **REPLACE** | Fixed project registration plus minimum manifest selections |
| Synthetic implementation | **RETAIN AS EXAMPLE** | Ordinary materialized example/template and acceptance project |
| DuckDB adapter | **REFACTOR INTO INSTALLED SOFTWARE** | Installed default selected/configured through project context |
| History semantics and database contents | **REUSE SUBSTANTIALLY AS-IS**; migration **REQUIRES FOCUSED ASSESSMENT** | Project persistent state with unchanged logical port where compatible |
| Products and product-access interface | **REFACTOR INTO INSTALLED SOFTWARE** | Installed default logical product service |
| YAML materializer/access | **REFACTOR INTO INSTALLED SOFTWARE** | Installed default physical adapter over project product state |
| Product-only Shiny app | **REFACTOR INTO INSTALLED SOFTWARE** | Supplied default app; remove reference-only presentation defaults |
| Reduced artifact contract/validator | **REUSE SUBSTANTIALLY AS-IS** | Closed generated app artifact |
| Artifact repository source map | **REPLACE** | Installed resource manifest plus project output selection |
| Connect realization semantics | **REUSE SUBSTANTIALLY AS-IS** with installed resource/dependency refactor | Target adapter over exact artifact |
| Observability context/events/emitter | **REFACTOR INTO INSTALLED SOFTWARE** | Project-aware operation diagnostics; no default retention |
| Human operation intent/structured recovery | **REUSE SUBSTANTIALLY AS-IS** | Callable installed operations and later thin launcher |
| Reference-named scripts/default IDs/scales | **REMOVE FROM ACTIVE PRODUCT PATH** | Preserve inside example-specific guidance only |
| Root `renv` | **MAINTAINER-ONLY MATERIAL** | Development/CI/release environment, not project dependency authority |
| Hospital distribution, archive extraction, editable closed inventory | **RETAIN AS HISTORICAL/LEGACY** and **REMOVE FROM ACTIVE PRODUCT PATH** | Immutable `v0.1.0` evidence only |
| Hospital pristine Git realization and two-product release graph | **RETAIN AS HISTORICAL/LEGACY** | No normal project or future installed-release requirement |
| Release provenance, clean acquisition, publication safety concepts | **REUSE SUBSTANTIALLY AS-IS** at the correct lifecycle | Future installed-software candidate/publication proof |
| Custom estimand API and multiple-estimand orchestration | **REQUIRES FOCUSED ASSESSMENT** | Blocks final public project/component contract |
| Project dependency/lock and deployment dependency reconstruction | **REQUIRES FOCUSED ASSESSMENT** | Blocks install/build reproducibility promises |
| Custom products/app and non-R provider services | **REQUIRES FOCUSED ASSESSMENT** only before those features are promised | Not blockers for the minimum default path |

## Risks and tradeoffs

| Decision | Risk | Required protection |
|---|---|---|
| Execute project registration code | Local code may be unsafe or surprising | Explicit root/trust action, one fixed entry point, no remote/plugin discovery, controlled environment, clear non-sandbox warning |
| Keep manifest minimal | Important behavior could become implicit | Installed defaults are versioned and inspectable; operation prints resolved composition; add fields only for demonstrated choices |
| Use package resources | Build could omit or alter contracts/assets | Closed installed inventory, clean-install example acceptance, versioned resource catalog |
| Retain `rrpruntime` as internal package | Cross-package version skew | Coordinated release compatibility, clean-library install tests, no user assembly of arbitrary versions |
| Let projects own dependencies | Environment drift can break execution | Component dependency declarations, preflight validation, project-owned reproducible lock/evidence, exact build closure |
| Do not require `renv` semantically | Supported environments may diverge | Define supported dependency evidence and test at least one standard workflow; fail on incompatible installed versions |
| Move writable state to projects | Unsafe path configuration could overwrite unrelated data | Explicit normalized state root, per-operation ownership checks, atomic/append semantics, conservative replacement |
| Make synthetic project ordinary | Reference tests may lose convenient hidden wiring | Installed example fixture and clean acceptance use the same public loader; internal fixtures remain separate |
| Generalize estimands | Semantic meaning or cardinality may become inconsistent | Versioned declarations, governed builders, conformance scenarios, provider/product/app integration tests |
| Inject project providers | Model code/dependencies may fail unpredictably | Existing compatibility/isolation/result checks, explicit dependencies, structured terminal failures, exact provenance |
| Keep display-only artifact reduced | Users may assume it runs prediction | Explicit artifact profile/capabilities and documentation; separate future operational artifact |
| Retire Hospital delivery | Existing adopters need migration/history continuity | Preserve `v0.1.0`, publish forward migration guidance, assess history import before promising compatibility |
| One repository builds more than one package | Release process becomes more complex | One coordinated software release and ownership map; reconsider split if independent package value never appears |

## Remaining architecture decisions

| Priority | Question | Why it matters / blocking status | Further evidence or assessment |
|---:|---|---|---|
| 1 | What estimand registration and request-construction forms are supported first, and are multiple estimands executable in one run? | **Blocks implementation planning** for manifest, provider mapping, runtime API, history summaries, products, and app cardinality | Focused estimand-composition assessment using current fixed builder, provider compatibility, history keys, and app/product behavior |
| 2 | What exact structured value does project registration return, and how is it loaded/tested without global mutation? | **Blocks public project API implementation** | Prototype-free contract assessment against synthetic and independent adopter fixtures; define closed component kinds and lifecycle |
| 3 | Is Option B the durable package topology and how are its packages versioned/released together? | **Blocks package skeleton/build plan**, though not conceptual ownership | Package inventory/dependency analysis; built-package resource experiment may follow only after architecture acceptance |
| 4 | What dependency evidence is required for projects, and how are local/project provider dependencies captured in deployment? | **Blocks supported init/validate/build reproducibility claims** | Focused dependency/packaging assessment across `renv`, package metadata, model artifacts, clean installation, and Connect manifests |
| 5 | What is the exact project-manifest schema and compatibility-range syntax? | **Blocks contract implementation**, but most required information is now known | Synthesize after decisions 1–4; test every field against an operation that consumes it |
| 6 | How are runs listed/selected through the history port? | Blocks ergonomic products/inspection, not the core run cycle | Add logical query requirements without exposing DuckDB schema |
| 7 | Can `v0.1.0` DuckDB/history be adopted directly? | Blocks migration promises, not greenfield `v0.2.0` implementation | Compatibility and export/import assessment using exact released schema/records |
| 8 | How are absolute/mounted state paths, symlinks, retention, and backups governed? | Blocks particular production deployments, not an initial conservative local project | Deployment/storage threat and operations assessment |
| 9 | Are custom products or apps supported in the initial project contract? | Does not block default products/app | Defer until a real extension case identifies required ABI and safety boundaries |
| 10 | Are remote/non-R providers supported? | Does not block in-process R provider composition | Separate execution/secrets/network contract if demanded |
| 11 | Does the Hospital repository end at `v0.1.0` or later become a lightweight template? | Does not block installed software | Product/discovery decision after installed initialization exists |

## Recommended next task

There is not yet enough information to synthesize a responsible final target
architecture and implementation plan. Ownership, the minimal manifest inputs,
project-root rule, state boundary, default app/artifact flow, and provisional
package direction are now clear, but the highest-risk executable extension is
not.

The next focused task should be an **estimand composition and trusted project
registration assessment**. It should define the structured registration result,
the supplied-versus-project estimand boundary, request-builder trust and
conformance, exact estimand-to-provider selection, single/multiple estimand
cardinality, and the pre-execution compatibility sequence. It should use the
current synthetic and materially different adopter fixtures as evidence without
implementing the loader.

A second focused **package/dependency and build-reproducibility assessment**
should then confirm Option B or consolidation, installed asset inventory,
project dependency evidence, clean installation, and deployment closure. After
those two decisions, RRP should have enough evidence to synthesize the accepted
target architecture, version the minimum project contract, and write an
implementation plan. History migration and custom app/product/non-R-provider
work can remain later scoped decisions.

## Validation posture for this assessment

This document changes architecture assessment, navigation, and the
append-oriented implementation record only. Under the accepted governance
direction, directly relevant evidence is documentation structure, links,
navigation, portability, formatting, and exact diff scope.

The historical full Phase 0–11 development/checkpoint matrices, Hospital
distribution, clean-copy acquisition, release preparation, and publication
proofs do not establish whether this conceptual installed/project ownership map
is internally readable or correctly linked. They are intentionally not run.
No executable behavior, contract, dependency, package, state, artifact, or
release claim is changed.
