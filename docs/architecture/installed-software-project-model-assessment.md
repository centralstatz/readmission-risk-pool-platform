# Installed RRP and independent project architecture assessment

## Status and scope

**Status:** v0.2.0 architecture assessment and recommendation; not yet accepted
target architecture

This assessment asks whether Readmission Risk Pool should move forward from the
immutable `v0.1.0` baseline as conventional installed software operating on
independently owned RRP projects. It is governed by [Platform True
North](../vision/platform-true-north.md) and evaluates, but does not amend, the
current [Platform Architecture](platform-architecture.md), [implementation
plan](platform-implementation-plan.md), or released Hospital Implementation.

The direct evidence includes the current contracts, `rrpruntime`, source and
provider composition, DuckDB history adapter, products, Shiny application,
deployment builders, operations, release machinery, the authoritative
[Hospital Implementation distribution architecture](hospital-implementation-distribution-assessment.md),
and the [v0.1.0 clean-room adoption assessment](../development/hospital-implementation-v0.1.0-adoption-assessment.md).
No redesign is implemented here, and `v0.1.0` remains unchanged.

## Executive conclusion

The installed-software plus independent-project model is feasible and is the
recommended direction for `v0.2.0-dev`. It would materially simplify the user
product while better matching the ownership boundaries already stated in True
North:

```text
installed, versioned RRP software
        ↓ validates and operates
one hospital-owned RRP project
        ↓ produces
canonical input → runtime → history → products → app/artifact
```

This does not require a rewrite of the analytical platform. A substantial
majority of its semantic machinery is reusable: specification vocabulary,
canonical admission, producer result semantics, temporal state construction,
provider registry/execution, history records and ports, DuckDB behavior,
logical products, YAML product access, the product-only app, reduced artifact,
and target realization all already have useful boundaries.

The required change is a significant packaging and orchestration refactor plus
targeted generalization. Today, only `rrpruntime` is an installable package;
most other reusable behavior is loaded by sourcing files from a Platform
repository root. Normal execution then selects repository-owned reference
contracts, provider, persistence, products, app, and deployment assets. The
Hospital product adds an embedded Platform archive, closed inventories, managed
extraction, and generated Git state around those assumptions.

The clean target should:

- package runtime code, contracts, default adapters, app assets, deployment
  assets, and project tooling as installed software resources;
- make an explicit project root and versioned project manifest the operational
  context;
- move producer, estimand, provider, dependency, state, and optional app/deploy
  selection into a validated project contract;
- keep executable registration explicit and trusted rather than executable
  YAML or remote discovery;
- generalize the runtime from one hard-coded estimand and the history operation
  from one hard-coded provider;
- retain strict contract, compatibility, temporal, history, product, and
  artifact validation; and
- remove generated-Hospital-distribution and unrelated Git-state requirements
  from future hospital use.

The governing heuristic is:

> The contracts and produced evidence remain strict; the hospital's repository
> layout and ordinary Git state are not platform invariants.

## Current architecture map

### Semantic and operational flow

| Current component | Responsibility | How it is currently reached | Important coupling |
|---|---|---|---|
| `contracts/` | Language-neutral identities, canonical, runtime, provider, history, product, diagnostic, and deployment semantics | Operations parse YAML below a repository root | Contract meaning is portable; physical discovery is repository-relative |
| `implementations/synthetic-reference/` | Fictional source generation, source validation, mapping, and canonical producer adapter | Maintained composition sources a fixed file list | Correct producer peer, but privileged as the only installed composition |
| `operations/lib/canonical-*` | Producer registry/execution and canonical admission | Sourced into operation processes | Useful generic boundary still needs repository-root contract access |
| `runtime/` (`rrpruntime`) | Admitted input, temporal eligibility/state, estimand requests, provider execution, accepted estimates, and history ports | Built and installed into a temporary library on many operations | Only conventionally package-shaped component; estimand support is exact and fixed |
| `operations/lib/provider-operation.R` | Loads provider contracts and runs estimation | Constructs only the transparent reference registry and selection | Low-level provider API is generic; normal orchestration is not |
| `implementations/persistence/duckdb/` | Durable reference history adapter | Sourced by repository operations; configuration is repository-relative | Port is generic; adapter loading and paths are reference-shaped |
| `products/R/` | Backend-neutral products, conformance, and access | Sourced by repository operations | Product semantics are reusable but not installed namespaced software |
| `implementations/products/yaml/` | Atomic YAML materialization and read-only access | Sourced by repository operations | Good default adapter; asset/config discovery is repository-relative |
| `app/` | Product-only Shiny application | App functions are sourced and injected with logical product access | Already insulated from source, provider, and persistence internals |
| `deploy/application-artifact/` | Closed target-neutral app/product runtime | Builder copies an allowlisted map of files out of the source repository | Artifact contract is sound; builder treats source-tree paths as the asset catalog |
| `deploy/connect-cloud/` | Connect Cloud local Git realization | Builder consumes the reduced artifact and repository-owned target templates | Mostly independent; repository paths and generated Git policy remain target-owned |
| `operations/` | Human control surface and orchestration | Each script derives the Platform root from its own path and sources many files | Commands are installation scripts, not project-aware software commands |
| root `renv` project | Development/reference dependency baseline | Restored inside a Platform or generated Hospital checkout | Development environment and adopter project environment are conflated |
| `distribution/hospital/` | Generates wrappers, scaffold, embedded Platform, inventories, and standalone validation | Built into a second independently versioned release and public repository | Assumes hospitals acquire and work inside generated release source |
| release/publication machinery | Builds and verifies exact Platform and Hospital releases | Maintainer operations over a clean authoritative repository | Valuable maintainer rigor, but not a user runtime concern |

### Current dependency shape

The semantic core is more reusable than the physical layout suggests:

```text
repository-root scripts
  ├── parse repository contracts
  ├── source repository modules and adapters
  ├── temporarily install rrpruntime from repository source
  ├── construct the shipped producer and reference provider
  ├── choose repository-relative state
  └── copy repository assets into artifacts
          ↓
      reusable semantic interfaces
          ↓
 canonical → state/request → provider → history → products → app/artifact
```

The generated Hospital Implementation does not remove this coupling. It
packages the complete Platform source as an archive, validates a closed
distribution, extracts the archive into `.rrp/platform/<digest>`, sources the
same modules from that managed tree, and delegates to reference-named
operations. This is a delivery shell around a repository runtime, not an
installed-software boundary.

## Component disposition matrix

The classifications describe the recommended forward `v0.2.0` direction. A
component can have more than one action where its semantics and physical
realization differ.

| Component or mechanism | Classification | Reason and intended disposition |
|---|---|---|
| Common specification envelope, identities, compatibility, and structured conformance | **KEEP** | These are independent of repository shape and provide the strict contract foundation the simpler model needs. |
| Canonical bundle/profile/domain contracts and admission | **KEEP** | Clean-room evidence showed independent mapped data can pass unchanged admission. Load these from installed assets rather than a source checkout. |
| Canonical producer declaration/result and explicit callable registration | **KEEP** and **MOVE INTO PROJECT CONTRACT** | The separation of declaration, trust, selection, execution, and admission is sound. The project should own its declaration, callable, and exact selection. |
| Repository-maintained `installed-producers.R` composition | **REPLACE** | It always sources and registers the synthetic implementation. Replace it with an explicit project registration boundary plus a software-owned example composition. |
| `rrpruntime` temporal eligibility, state, estimate, and history APIs | **KEEP** | They are implementation-neutral, dependency-light, namespaced, and already receive parsed inputs rather than finding source systems. |
| Exact single-estimand runtime contract set and request builder | **GENERALIZE** | The current implementation validates one identity and one daily-hazard semantic shape. Introduce governed estimand registration/selection and request construction without weakening semantics. |
| Provider specification, in-memory registry, compatibility, isolated execution, and result conformance | **KEEP** | The custom-provider clean-room diagnostic proved the low-level seam works. |
| Reference-only provider construction and execution inside the history operation | **GENERALIZE** | Normal orchestration must accept a project-built registry and exact provider selection instead of constructing the transparent provider internally. |
| Operational-history contracts and persistence port | **KEEP** | Append, atomicity, retry, invalidation, and valid/current read semantics are valuable and backend-neutral. |
| DuckDB adapter | **KEEP** and **MOVE BEHIND SOFTWARE BOUNDARY** | Ship it as a default local adapter. Project configuration owns state location; users should not source its implementation files. |
| Product contracts, builders, conformance, and access | **KEEP** | They consume history ports and are already source/provider independent. Package them behind a stable software API. |
| Fixed three-product reference suite | **KEEP as a default** and **RECONSIDER for extension** | It is a coherent useful baseline. Project-defined product extension needs a separate contract decision and is not required to establish the project model. |
| YAML product materializer/access | **KEEP** and **MOVE BEHIND SOFTWARE BOUNDARY** | It is a replaceable, validated default adapter whose physical paths should be project state, not Platform source. |
| Product-only Shiny application | **KEEP** and **MOVE BEHIND SOFTWARE BOUNDARY** | Its injected access boundary is already appropriate. Package it as the supplied app and expose project-aware launch/build operations. |
| Local app customization | **MOVE INTO PROJECT CONTRACT** and **RECONSIDER** | A project may eventually select app configuration or a conforming app implementation, but the safe extension boundary needs focused design. |
| Reduced application-artifact contract and standalone validator | **KEEP** | Closed inventory is appropriate for a generated deployment artifact, unlike an editable project. |
| Artifact builder's repository file map | **SIMPLIFY** | Resolve versioned installed assets and explicit project inputs instead of copying from a development checkout. |
| Connect Cloud realization | **KEEP as a target adapter** | It already consumes the target-neutral artifact. Keep its destination safety and target-specific Git rules isolated from project validation. |
| Operation IDs, structured results, diagnostics, and human recovery contracts | **KEEP** | They are a strong basis for a package function, small launcher, or future CLI. |
| Repository-root scripts and repeated `source()` chains | **MOVE BEHIND SOFTWARE BOUNDARY** and **REPLACE** | Convert orchestration into installed, namespaced functions taking an explicit project context. Thin launchers can call those functions. |
| Temporary installation of `rrpruntime` on each operation | **REMOVE** | Installed RRP should depend on an installed compatible runtime package or include the runtime in its own package topology. |
| Platform-root `renv` as the hospital environment | **MOVE BEHIND SOFTWARE BOUNDARY** | Retain it for maintainer development/release evidence. Each RRP project owns its own dependencies and may use a generated `renv` baseline without a nested Platform project. |
| Synthetic implementation as default installation state | **MOVE BEHIND SOFTWARE BOUNDARY** and **GENERALIZE** | Make it an example/template/acceptance project that satisfies exactly the same project contract as a hospital project. |
| Hospital distribution archive, managed extraction, whole-tree wrappers, and distribution inventory | **REMOVE** from future hospital delivery | They exist to ship a repository runtime. Installed software makes the embedded Platform and generated distribution unnecessary. |
| Closed checksums over recipient-editable implementation files | **REMOVE** | Validate declared project contracts and capture build/run provenance instead. Do not make edits invalidate software availability. |
| Pristine Hospital Git realization and zero-commit/zero-remote validation | **REMOVE** from project use | These are release-generation invariants, not analytical or project invariants. Historical `v0.1.0` evidence remains immutable. |
| Maintainer source, package, test, license, and publication validation | **KEEP** and **MOVE BEHIND SOFTWARE BOUNDARY** | Strict software release validation remains necessary but must not run as hospital project validation. |
| Two-product Platform/Hospital release graph | **SIMPLIFY** | Release installed RRP software. An optional template may be separately distributed, but it should contain no Platform source and need not be an immutable generated Hospital product. |
| General plugin discovery or executable YAML | **REMOVE / continue prohibiting** | The new project boundary needs explicit local trust, not remote or ambient code discovery. |
| Package topology, cross-language adapters, and public extension ABI | **RECONSIDER** | These choices need a focused design after accepting the project model. |

## Current inhibitors to installed-software behavior

The coupling labels describe effort and reach, not importance.

| Inhibitor | Nature | Coupling | Required change |
|---|---|---|---|
| Only the narrow runtime is a package; operations, products, adapters, app, and builders are sourced files | Incidental physical architecture | Deeply coupled across the current control surface | Create an installed software boundary for orchestration and runtime assets; preserve the underlying functions where possible. |
| Every human script infers `repository_root` from its own location | Incidental | Moderately coupled | Resolve an explicit project root separately from installed software resources. |
| Contracts and declarations are loaded from fixed repository paths | Incidental | Easily removable once packaged | Load versioned built-in contracts through an installed asset catalog; load project declarations from the project. |
| `rrpruntime` is built and installed into a temporary library during operations | Incidental | Easily removable | Depend on the installed compatible runtime rather than compiling source per command. |
| The installed producer composition always sources the synthetic implementation | Incidental composition choice | Moderately coupled | Let a trusted project entry point register one declared producer; package the synthetic implementation as an example project. |
| Producer execution still receives a Platform repository root for admission/contracts | Incidental | Moderately coupled | Inject a contract catalog/admission service and a distinct project context rather than one overloaded root. |
| Runtime contract discovery and validation recognize exactly one estimand | Intentional first-slice limitation | Moderately coupled | Add an estimand catalog/registry and estimand-specific executable semantics. This is real generalization, not just configuration. |
| Request construction embeds daily-hazard interval and identity behavior | Intentional first-slice limitation | Moderately coupled | Dispatch request construction through a validated supported estimand implementation. |
| History orchestration calls `rrp_execute_reference_estimation()` and records the reference provider | Incidental orchestration choice | Moderately coupled | Inject selected provider composition and derive provenance/diagnostics from the selected declaration. |
| Reference persistence and product operations source concrete adapters and default paths from the Platform tree | Incidental | Moderately coupled | Register packaged defaults and resolve project-owned state/configuration paths. |
| Product building defaults to deterministic reference run IDs and reference-named operations | Incidental | Easily to moderately removable | Build from project run catalogs or explicit project run selections without changing logical products. |
| App loading sources the repository app tree | Incidental | Easily removable | Package the supplied app and construct it from project product access. |
| Artifact building copies an exact map of development-repository files | Incidental | Moderately coupled | Copy installed runtime assets and selected project app/config inputs into the same validated artifact contract. |
| Connect realization resolves target templates from the Platform repository | Incidental | Easily removable | Ship target templates as installed assets; continue consuming the artifact. |
| Root `renv` state represents both developer software and adopter runtime | Distribution consequence | Moderately coupled | Separate the maintainer environment from each project environment and lock the installed RRP dependency in the project. |
| Hospital initialization depends on an embedded archive and managed extraction | Generated-distribution consequence | Deeply coupled to Hospital delivery, not to the semantic core | Retire this path for future versions once installed acquisition exists. |
| Whole-distribution inventory includes intended editable content | Machinery defect | Easily removable only by leaving the distribution model; otherwise awkward | Do not inventory mutable project source as installed software. Capture run/build digests instead. |
| Published users are exposed to candidate and pristine-Git validation | Release-generation leakage | Easily removable | Keep those checks solely in maintainer release workflows. |
| Reference, platform, and hospital wrapper names carry implementation identity into normal commands | Productization issue | Moderately coupled | Give operations project-aware intent and treat the reference as one explicit example project. |

No listed inhibitor is a fundamental analytical barrier. The two most
substantive generalization tasks are estimand execution and project-owned
trusted composition. The distribution machinery is deeply implemented but
architecturally removable because downstream semantic interfaces do not depend
on it.

## Proposed conceptual target architecture

### Software boundary

An RRP software release should provide installed, versioned access to:

- public contract documents and their validators;
- canonical admission and producer result machinery;
- runtime state, estimand, provider, estimate, and history behavior;
- default persistence and product-materialization adapters;
- logical products and the supplied product-only app;
- reduced artifact and supported deployment-target builders;
- project initialization, loading, validation, execution, inspection, app,
  and build operations; and
- the synthetic example/template and conformance fixtures.

The development repository may still contain architecture records, tests,
release automation, governance, source fixtures, and maintainers' environment.
Normal package/build rules should exclude those from the installed runtime.
Installed resource lookup replaces development-repository path lookup.

This assessment does not decide whether the software is one R package, a small
family of packages, or a package plus a launcher. A minimal first topology
could retain `rrpruntime` and add one user-facing `rrp` package that owns
orchestration, installed contracts/assets, default adapters, app, and project
operations. A single larger package may be simpler if the internal package
split provides no independent release value. That choice requires the next
assessment.

### Project boundary

A project is hospital-owned source plus generated local state. The minimum
physical contract should be driven by required responsibilities, not a fixed
decorative directory tree.

At minimum it needs:

1. **One project manifest**, for example `rrp.yml`, declaring:
   - project contract version and stable project identity/version;
   - one-health-system scope;
   - compatible RRP and canonical-profile versions;
   - exact selected producer;
   - selected estimand or estimands;
   - exact provider selection for each selected estimand;
   - selected persistence, product, app, and deployment profiles where the
     software defaults are not sufficient; and
   - nonsecret state/output locations or references.
2. **One explicit trusted registration entry point** under a fixed project
   convention. It registers project-owned producer, estimand implementation
   where applicable, provider, and optional adapters. The project is executable
   code the operator has chosen to trust; YAML still does not evaluate code or
   name arbitrary remote functions.
3. **Producer-owned implementation material**: declaration, source
   configuration, validation, mapping, and callable. Its exact internal files
   are not a Platform invariant.
4. **Any project-defined estimand/provider declarations and executable
   adapters**, each with exact identity/version and conformance evidence.
5. **A project dependency declaration or lock**, owned by the project and
   including the exact installed RRP line plus local implementation
   dependencies. RRP may initialize a baseline; the hospital owns later
   additions and approval.
6. **Ignored/generated state locations** for history, products, artifacts,
   caches, and temporary files. Generated state is not project source.

Optional custom products, app modules, or deployment configuration should
appear only when the corresponding extension contract exists. Directories such
as `sources/`, `mappings/`, `estimands/`, and `providers/` may be helpful
defaults, but the platform needs declared components and a fixed trusted entry
point—not every directory name.

### Discovery and invocation

RRP should receive a project root explicitly, either from the current working
directory when a unique manifest is present or from an explicit project
argument. It should not search for a Platform source checkout, inspect sibling
repositories, infer execution from Git state, or scan arbitrary code folders.

```text
operator selects project root
        ↓
RRP loads installed contracts and validates project manifest
        ↓
fixed trusted project entry point registers declared components
        ↓
RRP validates exact registration, selection, and compatibility
        ↓
normal project operation executes
```

The software discovers only the manifest, the fixed registration boundary,
and files explicitly governed by project/component contracts. Source-system
locations and secrets remain below the producer/provider boundary and outside
ordinary diagnostics and deployment artifacts.

### Internal orchestration

The current callable pieces should be composed into a generic cycle:

```text
project producer composition
        ↓
canonical admission using installed contracts
        ↓
selected estimand implementation creates governed requests
        ↓
selected compatible provider executes
        ↓
selected persistence port appends terminal batch
        ↓
products → materialization → supplied/custom app → artifact → target
```

The supplied synthetic project registers the same way. It is no longer an
installation mode or the only composition hard-coded in Platform source.

## Validation redesign

### Maintainer and software-release validation

This layer remains strict and may care about the development repository:

- source tests, documentation, licenses, dependency declarations, and CI;
- exact built-package/runtime inventory and installed-asset completeness;
- package/source release provenance, checksums, tags, and publication state;
- contract compatibility and conformance suites;
- synthetic example project and deployment-target acceptance;
- reproducible construction from clean maintained source; and
- exclusion of secrets, generated state, and unauthorized assets from the
  software release.

Current release preparation, publication evidence, whole-source validation,
and Git safety belong here. Future release mechanics can be simplified around
the chosen software package, but historical `v0.1.0` evidence remains retained.

### RRP project validation

This layer validates only what is necessary to operate one project:

- project manifest identity, version, one-health-system scope, and installed
  RRP compatibility;
- required dependency availability and the project's declared environment;
- explicit trusted component registration and exact selection;
- producer declaration, controlled source-local test scenario, result, and
  canonical admission;
- estimand declaration/implementation and provider compatibility;
- persistence configuration and safe accessible state paths;
- product/app compatibility and optional deployment configuration; and
- privacy-safe failure behavior and absence of secrets in governed metadata.

It should not require a Git repository, a particular branch, a clean index,
zero commits/remotes, an unmodified template, a closed inventory of hospital
code, a Platform archive, CentralStatz candidate status, or development phase
knowledge.

### Runtime and build provenance

Mutable project source can still produce attributable, reproducible evidence.
Each run or build should record, as appropriate:

- exact RRP software and contract versions;
- project identity/version and project-manifest digest;
- producer, implementation, mapping, estimand, provider, optional model,
  persistence, product, app, artifact, and target identities/versions;
- approved digests of relevant nonsecret code/configuration inputs;
- runtime run, operation run, product set, artifact, and realization identity;
- as-of, occurrence, build, and publication times with their distinct meaning;
- source snapshot or governed input references without copying PHI or secrets;
  and
- artifact inventories/checksums where immutability is actually required.

Git commit may be optional additional provenance. It must not be the universal
identity or a precondition for local validation. Digests of raw patient data or
secret-bearing configuration should not be introduced casually; source
attribution must follow hospital governance and the existing privacy boundary.

### Mechanisms that should disappear from project validation

- Hospital distribution and pristine-Git realization validation;
- checksums over recipient-owned implementation directories;
- candidate/publication-state checks;
- managed Platform archive extraction;
- nested Platform lock activation or validation;
- whole-development-tree inventories; and
- release-generation terminology and internal phase assertions.

Closed inventories remain appropriate for built software packages and
deployment artifacts because those are generated immutable outputs.

## Extensibility assessment

### Source-to-canonical mapping

The source boundary is already close to the target. The canonical producer
contract accepts a declaration plus explicitly registered callable and returns
a structured result before unchanged admission. Phase 10 and the clean-room
diagnostic both proved materially different local source shapes can reach this
boundary.

The main changes are physical:

- move the declaration, mapping, configuration, and callable into the project;
- replace `installed-producers.R` with the project's fixed trusted registration
  entry point;
- give the producer a project context rather than a Platform repository root;
- inject installed canonical contracts/admission services; and
- provide example-project guidance and local mapping conformance operations.

The platform still must not know source table names, credentials, SQL, vendor
codes, or local identifiers. The synthetic project should teach the same
sequence: validate source, map, return a candidate, and pass admission.

### Estimands

Estimand rigidity is an artifact of the deliberately narrow first runtime, not
a fundamental property of history, products, or provider execution. It is,
however, more than a configuration problem.

Currently hard-coded behavior includes:

- `rrp_runtime_supported_specifications()` naming exactly
  `platform.readmission-next-day-conditional-hazard@0.1.0`;
- repository contract loading selecting one exact estimand file;
- runtime validation comparing the complete supported daily-hazard semantic
  shape;
- request construction calculating one-day `(start, end]` intervals and using
  the one fixed identity; and
- the reference provider and normal history orchestration supporting only that
  request.

Already generic downstream behavior includes:

- provider declarations listing supported estimand identity/version ranges;
- compatibility checking a request against those declarations;
- request, execution, estimate, and history records carrying estimand
  identity/version;
- persistence reads filtering by estimand; and
- logical current/history product keys retaining estimand identity/version.

Project-declared estimands therefore require a governed **estimand catalog or
registry**, not arbitrary YAML substitution. Each supported estimand needs:

- a versioned semantic declaration;
- validation of event, population, conditioning, time origin, horizon,
  terminal/competing-event, output, and coherence meaning;
- an approved request-construction implementation or membership in a supported
  declarative estimand family;
- compatibility with the selected canonical profile/state contract;
- controlled conformance scenarios; and
- provider compatibility validation through existing identity/version rules.

Multiple estimands can coexist conceptually. The history model already stores
many requests and estimates and products key by estimand. The runtime would
create requests for each selected compatible estimand, and selection would map
each estimand to an exact provider. Product/app presentation and cardinality
must be tested, but no current evidence requires one estimand globally.

The next architecture must decide whether `v0.2.0` supports only a registry of
software-shipped estimands, project-authored estimands from a constrained
declarative family, or trusted project-authored executable estimand adapters.
That trust and semantic-conformance choice deserves a focused follow-up; simply
accepting arbitrary estimand YAML would weaken rigor.

### Providers

The provider registry and execution contract can remain largely unchanged.
The minimum architectural change is to generalize orchestration:

```text
project declaration + trusted adapter
        ↓ register_provider()
exact project selection
        ↓ validate_provider_compatibility()
generic history cycle
        ↓ execute_provider()
accepted execution/estimate records
```

Specifically, a generic estimation operation should receive the provider
registry, exact selection, runtime/estimand contracts, and execution identity.
The generic history cycle should receive that composition instead of calling
`rrp_execute_reference_estimation()`. Diagnostics and terminal provenance
should derive provider identity from the selected declaration rather than a
literal reference ID. The transparent provider then becomes a registered
default/example peer.

This preserves explicit trust, compatibility, adapter isolation, structured
failures, bounds/cardinality validation, and estimate provenance. If multiple
estimands are selected, provider selection is keyed by estimand rather than one
installation-wide provider string.

### Persistence and history

The history port and DuckDB adapter need no semantic redesign for the project
model. RRP should ship/register DuckDB as a default local adapter, while the
project declares the adapter and owns the database location, retention,
backup, and environment. A future adapter continues to satisfy the same port.

Run discovery and user-friendly run selection are weaker than the core port:
current product operations often know deterministic reference run IDs. A
project control surface will need a project run catalog/query or explicit run
selection without making storage tables public. That is an orchestration/query
addition, not a history rewrite.

### Products and application

The product builders consume a persistence port, and the app consumes logical
product access. Both already sit behind the desired boundaries. The initial
three-product suite and supplied Shiny app can remain defaults.

Required changes are:

- package product and app code rather than sourcing repository files;
- resolve history, product stores, and app configuration from project context;
- remove reference run-ID and reference-operation defaults;
- carry selected estimand/provider/project provenance through existing rows and
  artifact metadata; and
- define a separate contract before allowing custom product builders or app
  implementations to enter the supported path.

The app must continue to avoid source queries, provider invocation, and
persistence-backend knowledge.

### Deployment and application artifacts

The reduced artifact remains the right boundary. Its closed inventory protects
a generated deployable object, not an editable project. The builder should use
installed RRP app/runtime assets plus one validated project product set and any
supported project app configuration. The artifact should identify the exact
RRP/project/estimand/provider/product inputs used.

Connect Cloud can continue as a peer target consuming the artifact. Its Git
initialization, allowlist, dependency lock, destination ownership, and
standalone validation are target-specific output rules. They must not become
requirements on the hospital's project repository. Other targets can consume
the same artifact later.

## Synthetic/reference role

The synthetic implementation should become all of the following, using one
shared project form where practical:

- an installed example project a new user can materialize and run;
- an optional initialization template;
- a tutorial explaining source-to-canonical mapping and component selection;
- a release acceptance project; and
- a small conformance fixture for fast tests.

Its generator and mapping remain useful. What should disappear is its
privileged position in the only maintained installation composition and the
need for `--scale`-shaped reference behavior in generic commands. Reference
configuration may still expose fictional test/reference scales inside that
example project's producer.

## Repository and software-package implications

### Option A — installed RRP plus independent projects

**Recommended primary model.** It gives the cleanest software/hospital
ownership, normal dependency upgrades, minimal Git assumptions, and direct
alignment with canonical/provider/project boundaries. It requires packaging
work and a stable project loader but removes the embedded Platform and most
Hospital release machinery from future use.

### Option B — installed RRP plus an optional starter/template repository

**Useful optional acquisition aid.** A small template can contain `rrp.yml`, a
fixed trusted registration entry point, fictional/local placeholders, tests,
and ordinary project environment files. It must depend on an installed exact
RRP version and contain no copied or embedded Platform source.

The template can live as installed material generated by `rrp init`, or in a
separate repository if independent discovery materially helps users. A
separate repository introduces template-version drift and maintenance, so it
should not be presumed necessary.

### Option C — users clone the full RRP source repository

**Reject as the normal hospital model.** It offers source inspectability and
simple maintainer debugging but conflates software development with use,
requires repository layout knowledge, complicates upgrades and dependencies,
and recreates the clean-room failure mode. Source clones remain appropriate
for RRP contributors and sophisticated integrators, not routine adopters.

### Future role of the Hospital Implementation repository

The separate generated Hospital Implementation repository is not necessary
under Option A. Its `v0.1.0` tag and release remain immutable historical
products. Forward options are:

- make no new Hospital Implementation release and direct new adopters to
  installed RRP plus project initialization; or
- redefine a future repository/version as a minimal ordinary starter project,
  clearly separated from the old generated-source product.

The second option should be chosen only if repository-based discovery adds
value beyond an installed template. It must not embed Platform source, enforce
pristine Git state, or checksum hospital-owned files.

### Normal software packaging

The separate Hospital repository currently compensates for the lack of a
complete installed software unit. Standard packaging can solve that problem
more directly:

- package R functions in namespaces instead of sourcing files;
- place versioned contracts, default declarations, app assets, target
  templates, and example project material in installed data/resources;
- use package build rules such as `.Rbuildignore` to exclude maintainer docs,
  tests, release evidence, development configuration, and generated state;
- validate the exact installed asset inventory during software release;
- declare runtime dependencies through package metadata and artifact-specific
  manifests; and
- keep the authoritative development repository larger than the installed
  user runtime without shipping the whole tree.

The current repository has no top-level package build boundary or
`.Rbuildignore`; only `runtime/` has package metadata. This confirms that the
packaging change is material, but it does not imply the semantic code must be
rewritten.

## Implications for future `readmit`

The installed-RRP/project model creates a cleaner eventual boundary for a
higher-level `readmit` R package:

- `readmit` could construct or help validate objects satisfying published RRP
  estimand, provider, model-artifact, or canonical-mapping contracts;
- a `readmit` provider adapter could register explicitly in a hospital project
  without modifying RRP source;
- exact package and contract versions could express compatibility;
- RRP would continue to own execution, history, products, and artifact
  conformance; and
- `readmit` would remain optional rather than an acquisition or runtime
  requirement.

This assessment does not assign `readmit` orchestration ownership or design its
API. The important implication is that project-owned registration is a stable
consumer boundary, unlike editing or embedding the Platform repository.

## Migration implications for v0.2.0-dev

All changes are forward-only. Published `v0.1.0` source, tags, archives,
Hospital repository, and evidence remain untouched.

| Action | Forward change |
|---|---|
| **Preserve** | Canonical and producer contracts, temporal runtime, provider execution, history semantics/ports, DuckDB behavior, logical products, YAML access, product-only app, artifact contract, target boundary, observability, and human-operation principles. |
| **Generalize** | Estimand catalog/request construction, provider selection in the history cycle, component registration/selection, project run discovery, and reference-named defaults. |
| **Refactor** | Move sourced modules and repository-relative contract/assets into installed namespaces/resources; make operations accept explicit project context and injected component composition. |
| **Replace** | Replace generated Hospital acquisition with software installation plus project initialization; replace maintained synthetic installation composition with a normal example-project composition. |
| **Remove from future user path** | Embedded Platform archive/extraction, Hospital distribution inventory, checksums over editable implementation, pristine Hospital Git validation, nested release-candidate language, and whole-tree Hospital wrappers. |
| **Keep maintainer-only** | Development-repository validation, software/package release integrity, GitHub publication safety, historical `v0.1.0` evidence, and source governance. |

A migration guide should eventually show a `v0.1.0` recipient how to move
their producer declaration, mapping/callable, provider code, nonsecret
configuration, dependencies, and existing compatible history into a new RRP
project. History migration must be assessed before promising that an existing
DuckDB file can be adopted unchanged. No automatic migration is implied.

## Primary sources of accidental complexity

1. **Distribution compensates for missing installation packaging.** The whole
   Platform is embedded because most runtime assets are not installable.
2. **Repository root is overloaded.** It means software assets, selected
   installation, project configuration, dependency environment, generated
   state, and operation location at once.
3. **Release integrity is applied to mutable user source.** Closed inventories
   and pristine Git checks cross the ownership cutoff they were meant to
   protect.
4. **Reference composition became normal orchestration.** Generic interfaces
   exist below functions whose names and call graphs still select reference
   implementations.
5. **One active estimand is encoded as the runtime contract set.** A valid first
   vertical slice is treated as the universe of estimand execution.
6. **Repeated source loading substitutes for a software namespace.** Thin
   scripts must know file order and tree layout, increasing coupling and making
   hospital wrappers necessary.
7. **Development, release, installation, project, and deployment validation are
   not cleanly separated.** Each layer has valid rigor, but applying it at the
   wrong layer creates false failures without improving analytical safety.

## Risks and tradeoffs

| Risk introduced by simplification | Preserve rigor without repository rigidity |
|---|---|
| Project code is executable and potentially unsafe | Require explicit operator-selected project root, a fixed trusted registration entry point, no remote discovery, no executable YAML, and clear trust documentation. |
| Mutable projects weaken reproducibility | Record exact software/component versions and approved code/config digests per run/build; encourage project version control without requiring a particular Git state. |
| Custom estimands can change scientific meaning silently | Require versioned semantic declarations, estimand-specific validation/conformance, compatible request builders, and exact provider declarations. |
| Multiple estimands complicate cardinality and UI behavior | Make selections explicit, preserve estimand keys throughout history/products, and add cross-estimand tests before support. |
| Packaging can omit contracts or runtime assets | Validate the built/installed package inventory and run the synthetic example from a clean installed environment. |
| Project dependency freedom can break compatibility | Generate a supported baseline, validate installed versions before execution, and fail closed on incompatible RRP/component contracts. |
| Project-relative paths can escape or overwrite unrelated state | Normalize explicit project paths, distinguish source and generated state, reject unsafe/link targets where mutation occurs, and document recovery. |
| Custom app/product behavior could bypass architecture | Admit extensions only through explicit product/access/app contracts; keep the supplied app product-only. |
| Provenance digests could expose sensitive information | Hash only approved nonsecret material, store source references rather than raw data, and retain current diagnostic/privacy allowlists. |
| Removing Hospital release checks could be mistaken for removing release rigor | Keep strict maintainer package/release and generated-artifact validation; remove only checks applied to mutable project operation. |
| Pre-1.0 extension APIs may change | State compatibility narrowly, version every contract, and provide explicit migration notes rather than implying stability. |

Scientific reproducibility comes from governed meaning, exact versions,
validated inputs/outputs, attributable execution, retained history, and build
evidence. It does not require CentralStatz to control whether an adopter's Git
repository has a remote or uncommitted file.

## Questions requiring follow-up assessments

1. What is the smallest installed package topology: expand `rrpruntime`, add a
   user-facing `rrp` package, or consolidate into one package?
2. What exact project manifest fields and compatibility rules are required for
   the first project contract?
3. How is the fixed trusted project registration entry point loaded and
   isolated without creating dynamic plugin discovery?
4. Which assets belong in installed software, generated project templates, or
   maintainer-only source, and how is installed inventory tested?
5. Is `renv` required for supported projects, a generated default, or one
   permitted dependency-management choice?
6. Does `v0.2.0` initially support only shipped estimands, a constrained
   declarative estimand family, or trusted executable project estimands?
7. How are multiple estimands mapped to providers and represented in operation
   summaries and the supplied app?
8. What model-artifact, package dependency, non-R process, and secret-loading
   boundaries are required for real providers?
9. How should a project discover/select retained runs without exposing DuckDB
   schema or weakening history semantics?
10. Which product/app customizations are supported in the first project
    contract, and which remain advanced extensions?
11. Can existing `v0.1.0` DuckDB history and product state be adopted safely,
    or is an explicit export/import migration required?
12. Should the public Hospital repository stop at `v0.1.0` or become an
    ordinary optional template in a future independently explained release?
13. Which interfaces should a future `readmit` package consume without making
    it a core dependency?

## Recommended next assessment

The single most useful next assessment is an **installed package and minimum
RRP project contract assessment**.

It should produce an exact, reviewable mapping from every file/function needed
for `validate`, `run`, `products`, `app`, and `build` into either:

- installed RRP code/resource;
- required project declaration or trusted code;
- optional project extension; or
- maintainer-only development/release material.

It should then specify the minimum project manifest, project-root resolution,
fixed trusted registration entry point, dependency ownership, generated-state
layout, and callable operation inputs/outputs. The synthetic implementation
should be used as the design example, not implemented as a new project during
that assessment.

That decision is the prerequisite for safe implementation sequencing. It
establishes the software/project ownership boundary before separately
generalizing estimands or building any CLI.
