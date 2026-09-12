# RRP 1.0.0 implementation plan

## Status and authority

**Status:** authoritative high-level implementation roadmap for the RRP 1.0.0
target generation with a detailed Stage 1 plan; Stage 1 implementation has not
begun

This is the one current implementation-plan authority beneath
[Platform True North](../vision/platform-true-north.md) and the
[Platform Architecture](platform-architecture.md). It defines the major stages,
dependency order, transition states, and evidence required to turn the released
`v0.1.0` implementation into the declared RRP 1.0.0 product. Where it and an
older Phase document differ, this roadmap governs forward work.

The [implementation record](platform-implementation-record.md) records what is
actually completed under this roadmap. The
[reference-asset reconciliation](reference-asset-reconciliation.md) remains the
required target-first control when old implementation or sibling-repository
evidence is considered for deliberate reuse.

The published `v0.1.0` tag preserves the exact Phase 0–11 plan,
implementation, and release evidence for that immutable release. Rewriting
this document in place does not reinterpret those bytes or erase their history.
Detailed `v0.1.0` documents and tests remain implementation evidence until a
1.0 stage deliberately replaces, reassigns, or retires them.

This is intentionally a big-picture roadmap. It authorizes the next planning
pass, not executable implementation. Before a stage's source changes begin,
that stage must be decomposed into bounded increments with concrete interfaces,
state effects, human operations, and acceptance tests. Later stages are
detailed progressively after preceding stages close; they are not decomposed
up front. RRP 1.0.0 is neither implemented nor released because this roadmap
exists. Transitional `0.2.0-dev` executable metadata remains unchanged by this
planning work.

## Starting point and destination

```text
released v0.1.0
    = immutable working implementation
    = repository-operated and physically coupled

RRP 1.0.0 architecture
    = authoritative target
    = installed software + independent projects
    = not yet implemented

this roadmap
    = forward-only path between them
```

The destination is one conventionally installed RRP software product. A thin
CLI and supported programmatic operations apply it to an explicit,
independently owned hospital project. The project supplies its producer,
mapping, selected provider/model, extension dependencies, nonsecret
configuration, and writable state. RRP owns canonical admission, one fixed
remaining cumulative day-30 risk target, request construction, execution and
history semantics, products, the supplied product-only app, and closed
artifact builders.

This is not an all-at-once rewrite. Existing semantic machinery is kept when
it still serves the new boundary; obsolete physical and delivery coupling
leaves the active path as soon as its replacement passes an explicit gate.
Temporary coexistence is allowed only with a named purpose and retirement
condition.

## Roadmap principles

1. Follow architecture ownership rather than historical Phase numbering.
2. Establish source, package, resource, and distribution ownership before
   installed operations depend on it.
3. Put one shared programmatic operation boundary beneath every client and
   keep the CLI thin.
4. Establish project recognition and trust before executing project code.
5. Stabilize the singular target and temporal semantics before versioning new
   history or products.
6. Never relabel daily-hazard records or products as cumulative risk.
7. Keep software installation, project migration, state migration, artifact
   creation, deployment, and publication separate.
8. Move validation ownership with the component or lifecycle claim.
9. Preserve a bounded working path during transition without creating a
   permanent dual architecture.
10. Require development-repository independence at installed, project,
    artifact, and release gates.

## Planning model and cadence

### Stable high-level roadmap

The ten stages in this document are the durable implementation framework for
RRP 1.0.0. They establish major boundaries, dependency order, objectives,
scope, reuse/refactor/replace posture, exit states, roadmap-level gates,
transition strategy, and major deferrals. They are not casually replanned
after each increment.

Change the high-level roadmap only when implementation evidence shows that an
architectural dependency, stage boundary, or major assumption is materially
wrong. Ordinary implementation discoveries should refine the current or next
stage plan without reopening accepted target architecture.

### Progressive stage-level planning

Detailed planning occurs immediately before the stage it governs. Do not
decompose Stages 1–10 in advance. The implementation cadence is:

```text
approve high-level RRP 1.0.0 roadmap
        ↓
detail Stage 1
        ↓
implement and validate Stage 1
        ↓
reconcile the actual Stage 1 exit state
        ↓
detail Stage 2 against that realized state
        ↓
implement, validate, and reconcile Stage 2
        ↓
detail Stage 3
        ↓
...
```

Later mechanics must be planned against the repository and software that
actually exist after earlier work, not an imagined future implementation. For
example, Stage 2's realized package/resource/distribution boundary constrains
Stage 3 installation, and Stage 3's realized operation boundary constrains
Stage 4 project loading. This roadmap preserves those dependencies without
pretending their exact downstream forms are already knowable.

Keep detailed stage plans in this document when that remains readable. A
future stage may have no detailed section until the preceding stage has closed.
Do not populate placeholder sections with speculative increments merely to make
the plan look complete. Git history preserves how current detailed authority
evolves.

### Stage-close reconciliation

Before planning Stage `N + 1`, close Stage `N` with concise evidence-based
reconciliation answering:

- what was actually implemented and which concrete decisions were realized;
- whether the declared exit state occurred and acceptance gate passed;
- which assumptions changed, if any;
- which legacy path became non-authoritative or retired;
- which temporary coexistence remains and its retirement condition;
- which new facts constrain the next stage; and
- whether a genuine contradiction or blocker requires architecture or roadmap
  revision.

This is implementation closeout, not a new broad architecture assessment.
Reopen architecture or major roadmap decisions only when actual evidence
requires it.

### Detailed-stage scope

The current stage's detailed plan may settle concrete increment ordering,
repository and package/resource changes, contracts, programmatic interfaces,
CLI surfaces, manifest/schema details, migrations, focused and downstream
tests, documentation, recovery/rollback, and increment-level acceptance. Its
detail should match that stage; it neither designs later stages nor authorizes
them.

The authority chain therefore remains:

```text
True North
    ↓
RRP 1.0.0 target architecture
    ↓
stable high-level roadmap
    ↓
current detailed stage plan
    ↓
implementation and stage-close evidence
```

## Dependency-oriented roadmap

```text
1. Authority and transition controls
        ↓
2. Software source and closed-distribution foundation
        ↓
3. Installed software and shared-operations foundation
        ↓
4. Independent project and trusted extension foundation
        ↓
5. Singular risk-target analytical vertical slice
        ↓
6. RRP 1.0 history and project-state generation
        ↓
7. Cumulative-risk products and supplied application
        ↓
8. Product-only deployment realizations
        ↓
9. Adopter acceptance, documentation, and legacy retirement
        ↓
10. RRP 1.0.0 qualification, publication, and acquisition proof
```

Validation ownership, dependency evidence, privacy/security review,
documentation, and support-matrix automation are continuous workstreams. They
start when their owning boundary appears and converge at Stages 9–10; they do
not bypass the dependency spine.

## Stage 1 — Authority and transition controls

### Objective

Make the RRP 1.0.0 architecture and roadmap operable as the active development
system without deleting or weakening `v0.1.0` evidence.

### Why now

Repository restructuring and semantic migration cannot be governed by Phase
0–11 gates for a different product. Validation and documentation authority
must be corrected before those gates obstruct or falsely certify later work.

### Major scope

- Replace phase-number routing for new work with named component and lifecycle
  validation profiles plus an explicit dependency/ownership map.
- Classify current normative, user/developer, maintainer, assessment, and
  historical documentation and plan their incremental physical separation.
- Establish a transition ledger assigning every active `v0.1.0` path or
  invariant to reuse, refactor, replacement, historical retention, or deferral.
- Update conventions for installed-resource discovery, namespaced code,
  explicit project context, package ownership, and proportional evidence.
- Preserve strict scientific, temporal, state, privacy, artifact, and release
  invariants while changing how checks are selected.

### Reuse / refactor / replace

Reuse focused tests and repository rules that still prove a current invariant.
Refactor their routing and ownership. Replace Phase 0–11 and whole-tree
checkpoint status as the forward hierarchy. Retain historical suites and
publication evidence until later retirement gates say otherwise.

### Exit state

Architecture, roadmap, contribution guidance, and validation policy agree on
what governs new work. Each current check is owned by a new profile, explicitly
legacy, or pending deliberate reassignment. The executable remains the
`v0.1.0`-derived development baseline.

### Acceptance gate

Documentation/navigation checks, validation-routing tests, and a reviewed
ownership map prove that evidence can be selected by changed boundary without
silently dropping a protected invariant. No analytical or release claim
changes.

### Deferred detail

Exact profile names, machine-readable map schema, CI layout, document moves,
and per-test reassignment wait for the detailed increment pass.

## Stage 2 — Software source and closed-distribution foundation

### Objective

Turn the repository into source that builds one closed RRP software
distribution, with physical ownership matching the two-package and installed-
resource architecture.

### Why now

Installed operations cannot be stable while they depend on repository-root
sourcing, ordered global files, or an undefined payload. Package/resource and
distribution boundaries must precede installation, project loading, and CLI
work.

### Major scope

- Establish one main RRP implementation package beside focused `rrpruntime`.
- Rehome generic orchestration, adapters, products/app support, diagnostics,
  and artifact builders according to their owners.
- Classify contracts, schemas, defaults, app resources, project examples and
  templates, target resources, user docs, and legal material as installed
  resources accessed through a stable API.
- Separate shippable content from tests, fixtures, assessments, historical
  Hospital machinery, release evidence, and maintainer-only tools.
- Introduce a closed inclusion manifest, exact output inventory, SHA-256
  digests, target-keyed dependency closure, and normalized-content
  reproducibility rules.
- Distinguish development `renv`, installed RRP, project extension, build, and
  deployment dependency environments.
- Move executable identity onto the 1.0 development line only after the new
  distribution identity is real and validated; never alter `v0.1.0` evidence.

### Reuse / refactor / replace

Retain `rrpruntime`, current generic semantic code, contracts, adapters,
products/app resources, and inventory/digest patterns where ownership remains
sound. Refactor repository scripts and loose R files into package/resource
boundaries. Replace the full tracked tree and ignore subtraction as payload
definitions. The generated Hospital product remains historical.

### Exit state

A minimal real RRP distribution builds from declared inputs, contains only
classified output, stages its internal packages and resources, and validates
without assuming a checkout root. Legacy repository-run analytical operations
may coexist while Stage 3 builds installed behavior.

### Acceptance gate

Package build/check, resource discovery, dependency/license checks, closed-
inventory rejection, digest verification, and two independent builds on one
declared environment establish the new distribution boundary. This is not yet
a supported end-user installation claim.

### Deferred detail

Final directories, package/API names, manifest fields, archive format,
dependency acquisition, signing, and byte-identical reproducibility claims
wait for detailed planning or later evidence.

## Stage 3 — Installed software and shared-operations foundation

### Objective

Make the distribution installable, verifiable, selectable, and operable
outside the development repository through stable programmatic operations and
a thin human launcher.

### Why now

Projects must be tested against installed software, not temporary source.
A minimal launcher is useful now for installation and health; full commands
should appear only as their underlying operations mature.

### Major scope

- Implement user-scoped, side-by-side immutable installation and explicit
  activation, rollback, and uninstall boundaries.
- Resolve, validate, and record an explicit host R, initially R 4.4.x without
  bundling it.
- Install and verify the private RRP library, resource catalog, inventory,
  digests, permissions, and compatibility evidence.
- Establish the stable programmatic operation/result boundary and structured,
  privacy-safe diagnostics inherited from current operations.
- Add a thin CLI/launcher shell for version, installation doctor, and other
  capabilities only when an underlying operation exists.
- Keep parsing, explicit project context, exit status, signals, safe rendering,
  and recovery guidance out of analytical logic.

### Reuse / refactor / replace

Reuse operation classification, structured contexts/events, validation
results, doctor intent, and safe console rendering. Refactor bodies into the
main package and expose supported namespaced operations. Replace per-operation
temporary package installation and repository-root source chains on the new
path. Legacy scripts may temporarily remain comparison wrappers.

### Exit state

From exact distribution bytes, a user can install two RRP versions, verify
either, explicitly select one, roll back selection, and invoke project-neutral
operations without repository access or an interactive R session.

### Acceptance gate

Clean user-scope tests prove host-R selection, private-library isolation,
resource discovery, launcher/doctor behavior, activation atomicity, rollback,
uninstall safety, structured failures, and checkout independence on at least
one initial environment cell.

### Deferred detail

Installer/launcher technology, paths, exact CLI syntax, shell styling, broader
platform support, system-wide installation, and complete analytical commands
remain later decisions.

## Stage 4 — Independent project and trusted extension foundation

### Objective

Introduce the real RRP project lifecycle and make producer/provider code
ordinary, explicit, hospital-owned extensions of installed RRP.

### Why now

Project code must not be designed around repository internals, and the target
refactor needs a trustworthy producer/provider selection boundary.

### Major scope

- Recognize an explicit project root, versioned nonsecret manifest, and one
  fixed trusted registration entry point.
- Establish project identity/version, supported RRP/API range, exact producer
  and provider selection, dependency/model evidence, state profile/root, and
  nonsecret operation settings.
- Separate callable registration from declarative selection and reject
  missing, duplicate, ambiguous, undeclared, or incompatible entries.
- Establish an RRP-first private library plus project extension library, with
  conflict and ambient-library rejection.
- Implement safe initialization, recognition, validation, dependency checks,
  and non-mutating lifecycle behavior.
- Turn the synthetic composition into a fictional example project and retain
  a materially independent adopter fixture for conformance.

### Reuse / refactor / replace

Generalize the producer declaration/result/admission seam and provider
registry/execution pattern. Move synthetic source and transparent-provider
composition behind the same project boundary as adopter code. Replace
installation-owned producer selection and configuration-driven executable
loading. Do not add target, estimand, or request-builder registration.

### Exit state

Installed RRP can initialize, recognize, load, and validate a fictional project
outside the repository; execute only its fixed registration entry point after
preflight; and resolve exactly one producer and provider. Deep analytical
compatibility completes in Stage 5.

### Acceptance gate

External-project tests prove safe initialization, paths, manifest
compatibility, trust/selection separation, dependency isolation, model
integrity references, secret exclusion, duplicate/missing rejection, state-
root ownership, and equal treatment of fictional and independent extensions.

### Deferred detail

Exact project tree, manifest schema, registration shape, template content,
extension lock mechanism, migration command, and provider ergonomics wait for
the detailed plan.

## Stage 5 — Singular risk-target analytical vertical slice

### Objective

Establish the complete in-memory 1.0 analytical path for RRP's one remaining
cumulative day-30 readmission-risk target.

### Why now

Target, state, request, and output semantics govern every new history and
product record. They must be proved through the installed project boundary
before persistence migrates.

### Major scope

- Revise canonical admission to represent terminal occurrence separately from
  availability and prove coverage through fixed `W30`.
- Define first canonical readmission in `(t, W30]`, conditional on being alive
  and readmission-free through `t`, using only facts available through `t`;
  death competes and readmission wins an equal-time tie.
- Refactor eligibility, immutable as-of state, temporal filtering, and standard
  request construction in `rrpruntime`.
- Remove estimands, target selection, and request builders from project/runtime
  composition and retire daily hazard as public 1.0 semantics.
- Bind project-selected providers to exact target/request/API compatibility,
  probability validation, model attribution, and structured failure.
- Provide one installed example provider and a materially different project
  provider conformance path.
- Expose a nonpersistent project run through the operation API and CLI once its
  semantics pass.

### Reuse / refactor / replace

Reuse admitted-input discipline, as-of filtering, eligibility structure,
provider registry/execution, bounds/cardinality checks, standardized outcomes,
and provenance. Replace hazard estimand/request/estimate meaning rather than
renaming it. Retain hazard contracts/tests only as `v0.1.0` evidence or
provider-internal mathematics.

### Exit state

Fictional and independent-provider projects can produce a valid request and
either one attributable remaining-risk probability or structured failure
without future information, runtime source lookup, or project-defined target
semantics. The cumulative-risk path is authoritative; hazard is legacy-only.

### Acceptance gate

Evidence covers endpoint inclusion, before-discharge/after-endpoint
ineligibility, late-known terminal events, equal-time precedence, fixed
coverage, no future information, exact provider selection, malformed/failing
providers, probability bounds/cardinality, determinism, and provenance across
both projects.

### Deferred detail

Exact contract IDs, fields, signatures, provider helper APIs, clinical model
validation, remote transports, and non-R providers wait for later planning.

## Stage 6 — RRP 1.0 history and project-state generation

### Objective

Persist the new target's operational truth in hospital-owned project state
without contaminating it with `v0.1.0` daily-hazard meaning.

### Why now

History can stabilize only after target/request/result attribution is stable.
Products must consume this history rather than bridge semantics ad hoc.

### Major scope

- Version run, request/state, execution, estimate, invalidation, and
  restatement records for the 1.0 target generation.
- Preserve append orientation, atomic terminal batches, retry distinction,
  idempotency/conflict behavior, attribution, raw/valid reads, invalidation,
  and restatement.
- Refactor persistence ports and default DuckDB into installed RRP with
  project-declared writable locations.
- Add run, inspect, close/reopen, backup/recovery, and state-health operations
  over the shared API/CLI.
- Define empty-state initialization and state-version compatibility.
- Isolate legacy hazard evidence in a separately typed archive and define
  explicit project/state migration without automatic upgrade mutation.

### Reuse / refactor / replace

Reuse current history lifecycle, ports where structurally sound, DuckDB
transactions/deterministic reads, and product-independent truth. Refactor
identities and discovery around project state. Replace hazard-specific fields
and repository-local paths. Never coerce hazard records into 1.0 estimates.

### Exit state

An installed project run appends one atomic attributable 1.0 terminal batch;
later processes reopen it identically through logical ports. Failures expose
no partial success. Software activation leaves project source/state untouched,
and legacy state cannot enter current-risk reads.

### Acceptance gate

In-memory and DuckDB conformance, lifecycle, concurrency, retry/conflict,
atomic failure, invalidation/restatement, backup/reopen, compatibility,
migration failure, legacy isolation, and provenance tests pass through
external projects and installed operations.

### Deferred detail

Exact schemas/tables, migration inventory, backup format, locking, production
databases, retention, encryption implementation, and retrospective conversion
remain outside this pass.

## Stage 7 — Cumulative-risk products and supplied application

### Objective

Restore the product-only application boundary on correct 1.0 history before
pursuing visual refinement.

### Why now

Products and views cannot safely migrate until new history and validity rules
are stable. Deployment should package tested interfaces, not an interim UI or
physical database query.

### Major scope

- Version a narrow logical set for current eligible remaining risk, retained
  risk trajectory/history, and terminal run summary.
- Preserve construction from persistence ports, coherent sets, explicit empty
  states, rebuildability, freshness, and target/provider/model/software/history
  provenance.
- Refactor materialization and logical access into installed RRP with project-
  owned product state and atomic replacement.
- Update Shiny view models, labels, explanations, failures, and empty states
  for cumulative remaining risk.
- Keep estimation, product refresh, app validation, and launch as distinct
  operations surfaced through the CLI.
- Establish a functional 1.0 app baseline before optional visual refinement.

### Reuse / refactor / replace

Reuse the three product roles, neutral builders, coherent materialized set,
access seam, product-only app direction, and safe empty/failure behavior.
Refactor identities, grains, fields, provenance, discovery, and app language.
Replace hazard views; never infer cumulative risk from legacy bundles.

### Exit state

Installed RRP rebuilds and validates one coherent cumulative-risk product set
from reopened 1.0 history and launches the app using only logical access. The
app has no source, provider, model, runtime, or physical-history dependency.

### Acceptance gate

Builder/access/materialization conformance, provenance/freshness, empty/failure,
restart, and Shiny initialization/view tests pass for fictional and independent
projects. Every displayed probability describes the fixed target.

### Deferred detail

Exact product schemas, materialization format, UI framework, visual system,
accessibility refinements, and custom product/app contracts wait for later
planning or work.

## Stage 8 — Product-only deployment realizations

### Objective

Build portable product-only deployments from the same application semantics,
with Posit Connect Cloud as the first reference example and OCI/Docker as a
first-class portability realization.

### Why now

Artifact closure depends on stable products, app resources, and installed
dependency evidence. Target packaging must wrap that closure rather than drive
upstream architecture.

### Major scope

- Refactor the target-neutral artifact builder to consume exact installed RRP
  resources and one frozen coherent project product set.
- Preserve the minimal app/runtime subset, product access, contracts,
  dependencies, provenance, closed inventory, SHA-256, and self-validation.
- Create a broadly Posit-compatible realization and prove Posit Connect Cloud
  as the initial reference/example target.
- Keep self-managed Posit Connect near-adjacent through the same semantics, but
  make no support claim until it has target-specific acceptance evidence.
- Build and independently validate a product-only OCI/Docker image from the
  same product/application boundary and dependency closure.
- Keep credentials, publication, authorization, networking, sharing, and
  monitoring outside artifact construction.

### Reuse / refactor / replace

Reuse artifact/target separation, product-only exclusions, safe construction,
inventories/digests, standalone validation, and Connect Cloud lessons.
Refactor builders around installed resources and release dependency evidence.
Replace repository-root and generated-Git assumptions as upstream authority.

### Exit state

The same product set becomes independently valid Posit-compatible and OCI
realizations. Connect Cloud works without repository, project source, local
installation, mutable state, producer/provider/model, or history writer. OCI
is not a second analytical implementation.

### Acceptance gate

Inventory, digest, dependency, secret/PHI exclusion, tamper, isolated startup,
app behavior, and entrypoint tests pass for both realization families. Connect
Cloud receives reference-target evidence; self-managed Connect remains
unclaimed until separately tested.

### Deferred detail

Exact target IDs, lock formats, base image, registry, signing/attestation,
Connect administration, deployment automation, and compute-capable artifacts
wait for detailed planning or later generations.

## Stage 9 — Adopter acceptance, documentation, and legacy retirement

### Objective

Prove the installed adopter journey, finish product-facing documentation, and
remove obsolete coupling only after every replacement is demonstrated.

### Why now

Components can pass while the product remains unusable from clean bytes. Broad
retirement is safe only after the whole path works on initial environments.

### Major scope

- Exercise obtain/install/verify, example initialization/run, independent
  project initialization, custom mapping/producer, custom provider/model,
  dependency reproduction, execution, state reopen, products, app, artifact,
  and target validation without repository access.
- Complete evidence on macOS arm64 and Ubuntu x86_64 with R 4.4.x; scope
  support claims to fully passing cells.
- Produce installed user/developer documentation for installation, projects,
  mapping, providers, operations, state, products, app, artifacts, migration,
  recovery, security, and limitations.
- Reclassify assessments, Phase records, Hospital generation, and maintainer
  material away from adopter navigation.
- Retire repository scripts, temporary runtime installation, legacy
  composition, generated Hospital handoff, and historical gates from the
  active path after successors pass; retain immutable history.
- Resolve every temporary adapter and compatibility shim explicitly.

### Reuse / refactor / replace

Reuse clean-acquisition discipline, synthetic/adopter acceptance ideas,
human-first docs, and privacy/security rules. Refactor them around installed
RRP and independent projects. Replace Hospital clone/generated-repository
onboarding as current guidance while preserving `v0.1.0` evidence.

### Exit state

An adopter can operate 1.0 without reading assessments, CentralStatz history,
Phase records, generated Hospital instructions, or source-repository
procedures. No active operation depends on legacy architecture and no
unresolved permanent dual path remains.

### Acceptance gate

The end-to-end clean-install/adopter matrix passes from exact candidate-like
bytes in every claimed environment. Documentation usability, links,
privacy/secret scanning, lifecycle recovery, support limits, and a reviewed
retirement ledger pass. This establishes release eligibility, not publication.

### Deferred detail

Exact tutorials, support wording, CI provider, removal commits, deprecation
periods, migration walkthroughs, and optional UI polish wait for detailed
planning and implementation evidence.

## Stage 10 — RRP 1.0.0 qualification, publication, and acquisition proof

### Objective

Turn the accepted product into one exact immutable RRP 1.0.0 release and prove
that public bytes reproduce the adopter experience.

### Why now

Release metadata and support claims are truthful only after all installed,
project, analytical, state, product, app, deployment, and documentation gates
close.

### Major scope

- Prepare from one exact clean revision using the inclusion manifest,
  target-keyed dependencies, inventory, digests, licenses, notices, support
  statement, provenance, and normalized-content reproducibility evidence.
- Run the complete release matrix from candidate bytes, including installed,
  example/adopter, and product-only deployment workflows.
- Replace two-product Platform/Hospital publication assumptions with one RRP
  product while preserving fail-closed authorization, immutable tags/assets,
  checksums, staged recovery, and remote verification.
- Separate preparation, zero-mutation preflight, explicitly authorized
  publication, public verification, and post-release development transition.
- Acquire the public release ordinarily and repeat representative install,
  doctor, project, artifact, and integrity proofs without source access.

### Reuse / refactor / replace

Reuse Apache-2.0 governance, candidate discipline, checksummed evidence,
publication authorization, recovery, and acquisition verification. Refactor
for one installed RRP product and support matrix. Retire Hospital construction
from current publication without modifying its `v0.1.0` evidence.

### Exit state

Before authorization, the repository can report an exact 1.0.0 candidate as
ready but unpublished. After separately authorized publication, RRP 1.0.0 is
one immutable, publicly acquired and verified installed release, and
development advances without rewriting it.

### Acceptance gate

Candidate inventory/digests, all lifecycle/component matrices, licenses,
security/docs, every claimed OS/R cell, reproducibility, publication preflight,
exact remote identity, and clean public acquisition pass. Publication always
requires explicit authorization and is never implied by validation.

### Deferred detail

Exact release commands, assets, signatures, release-note template, recovery
checkpoints, support duration, and post-1.0 roadmap belong to detailed planning
and later authorization.

## Transition-state strategy

The old path remains authoritative only for what the working `v0.1.0`-derived
source currently does. The new path becomes authoritative one boundary at a
time after its gate passes.

| After stage | Repository transition state |
|---|---|
| Roadmap establishment | New architecture and roadmap govern forward design; the old executable path remains the only implemented path |
| 1 | New governance controls new work; historical suites remain available but do not gate unrelated changes |
| 2 | Old and new physical layouts coexist; the closed distribution boundary governs new shippable content |
| 3 | Installed health and shared operations govern; legacy analytical scripts may wrap or compare during migration |
| 4 | Independent projects govern 1.0 composition; installation-owned synthetic composition is legacy-only |
| 5 | Cumulative-risk runtime/provider semantics govern; public daily hazard is retired from the 1.0 path |
| 6 | Project history governs 1.0; hazard history is isolated and never a current product source |
| 7 | New products/app govern; hazard products and views are legacy-only |
| 8 | Installed-input artifacts govern; repository-root target construction is historical comparison only |
| 9 | The installed-project path is the sole active adopter architecture; obsolete wrappers and Hospital delivery are retired |
| 10 | The published RRP 1.0.0 distribution is immutable release authority; forward development begins from it |

No stage removes the last working path before its successor passes. No shim
survives Stage 9 without an explicit purpose, owner, and retirement policy.

## Parallel workstreams

- Validation implementation and test reassignment can follow each component
  move in Stages 2–8; final matrices wait for Stages 9–10.
- User documentation can begin with installation in Stage 3, projects in Stage
  4, and provider authoring in Stage 5; final navigation waits for Stage 9.
- OS/R automation, dependency acquisition, licensing, inventory, and
  reproducibility can start in Stage 2 and mature continuously.
- Project template and example can evolve together in Stage 4, but analytical
  content cannot finalize before Stage 5.
- Product/app view design may explore cumulative-risk presentation during
  Stage 6, but contract-bound implementation waits for Stage 7.
- Posit and OCI builders may proceed in parallel after the target-neutral
  artifact contract stabilizes; neither may fork product/app semantics.
- Visual app refinement and self-managed Posit Connect investigation may
  proceed after Stage 7, but neither blocks migration or creates a support
  claim.

Parallel work never authorizes a prohibited dependency between source,
provider, product, application, or deployment layers.

## Detailed stage plans

### Stage 1 detailed plan — Authority and transition controls

**Planning status:** ready for maintainer acceptance; implementation not begun

This section details only Stage 1. It does not refine Stage 2 or authorize any
distribution, package, installation, project, analytical, state, product,
application, artifact, version, or release change.

#### Current Stage 1 inventory and findings

The current repository has one root `AGENTS.md` and no nested instruction file
inside this repository. True North, Platform Architecture, this plan, the
append-oriented implementation record, README, START HERE, and the
documentation index already distinguish the RRP 1.0.0 target from the released
`v0.1.0` baseline. The missing control is executable validation ownership, not
a new architecture hierarchy.

The implemented validation surface is:

| Current mechanism | Finding relevant to Stage 1 |
|---|---|
| `operations/validate-documentation.R` | A useful direct, focused validator for required documents, local links, maintained navigation, and portable document paths |
| `rrp_validate_repository_policies()` | Useful repository-wide checks for sibling independence, machine paths, obvious secrets, and fictional fixture classification; callable today only through sourced R code or the aggregate runner |
| `operations/validate.R` | Parses only `development` or `checkpoint`, but eagerly sources and loads nearly every current subsystem before it parses the mode |
| `rrp_validate_platform()` | `development` always composes 14 repository validators and all Phase 0–11 test processes; `checkpoint` adds every Phase 0–11 checkpoint |
| `tests/run-phase0-tests.R` through `tests/run-phase11-tests.R` | Direct callable suites with useful component and integration evidence, but ownership is encoded by historical chronology and later suites repeatedly load upstream layers |
| `rrp_validate_*_repository()` functions | Current static/boundary checks for specifications, canonical contracts, synthetic implementation, runtime, history, products/app, operations, artifacts, Connect Cloud, observability, producer composition, and Hospital distribution |
| `rrp_validate_phase*_checkpoint()` functions | Mostly completed-milestone required-file, scope, lockfile, operation, and implementation-record prose gates; useful as exact `v0.1.0` checkpoint evidence, not forward universal governance |
| Standalone producer/artifact/target/Hospital validators | Valuable lifecycle operations, but some validate forward-reusable boundaries while Hospital operations validate a delivery product that is historical for 1.0 |
| Release preparation/publication preflight and verification | High-consequence, explicit, fail-closed `v0.1.0` lifecycle controls; publication preflight calls the old checkpoint mode |
| Git-state checks | Exist inside Hospital realization and release/publication lifecycles; there is no general Git-state rule that should govern ordinary project or source validation |
| `operations/operations.yml` | Versioned registry for human operations, commands, mutation classes, and docs; it is not a validation dependency/ownership registry |
| `.github/workflows/validation.yml` | The sole CI workflow restores the root `renv`, runs documentation validation, then runs checkpoint on every push and pull request; checkpoint already includes documentation, so the work is duplicated |
| Development policies/conventions | Still describe Phase-specific test placement, pre-1.0 compatibility, repository sourcing, and the root `renv`; they need forward transition rules before Stage 2 |

Several current repository validators grep exact headings in the implementation
record to prove a completed Phase or iteration. Those checks protect historical
completion evidence but couple current execution to prose. The forward model
must keep the record append-oriented while replacing prose presence as a
component-conformance mechanism.

The current aggregate also contains repeated near-identical Phase-process
wrappers and relies on source ordering; `rrp_validate_phase8_checkpoint()` is
intentionally redefined after the artifact validator so the later Connect
definition composes both Phase 8 slices. Stage 1 should isolate this behavior as
legacy rather than carry it into the new dispatcher.

No current machine-readable file answers which validator owns a changed path,
which invariant it protects, which prerequisites it needs, or whether it is
active, transitional, or historical. Stage 1 must supply that missing control
without pretending that Stage 2+ validators already exist.

#### Chosen governance and validation model

Stage 1 will establish one small development-only validation registry, one
dispatcher, direct underlying commands, and explicit legacy bridges.

The model has four parts:

1. **Validator unit:** one exact noninteractive command with one owner boundary,
   protected invariant, path triggers, prerequisites, and disposition.
2. **Profile:** an acyclic named composition of validator units or narrower
   profiles for a lifecycle claim.
3. **Changed-path selection:** deterministic matching of repository-relative
   changed paths to active or transitional validators, followed by prerequisite
   expansion and a printed selection rationale.
4. **Legacy bridge:** the exact old development/checkpoint compositions remain
   deliberately callable but are never selected implicitly by forward local or
   CI profiles.

Validator processes run independently. The dispatcher must not reproduce the
current eager source/load chain, execute arbitrary R function names from YAML,
or evaluate shell text. It invokes only a repository-relative allowlisted
`Rscript` plus a literal argument vector from the trusted registry, captures
exit status/output, and combines results deterministically. This keeps the
registry declarative and prevents one validator's global environment from
affecting another.

Stage 1 will provide these initial profiles:

| Profile | Purpose and composition |
|---|---|
| `source-fast` | Registry self-validation, repository policy/static safety, and documentation/navigation validation; the normal prerequisite for all forward profiles |
| `source-changed` | `source-fast` plus every active-scoped or replace-later validator whose declared paths match explicit or detected changes, with prerequisites expanded |
| `ci-active` | `source-fast` plus all current forward-relevant scoped/transitional component and integration validators; excludes Hospital/release publication and historical Phase checkpoints |
| `legacy-v0.1-development` | Exact compatibility composition of the current `development` mode, clearly labeled legacy |
| `legacy-v0.1-checkpoint` | Exact compatibility composition of the current `checkpoint` mode, including historical prose/checkpoint gates |

`source-changed` is the documented local default profile, but invocation remains
explicit. With no supplied base, it considers tracked worktree, index, and
untracked paths relative to `HEAD`; an explicit base revision can support CI or
maintainer comparison. With no changed paths it still runs `source-fast` and
reports that no scoped unit was selected. Selection must never require a clean
worktree or mutate Git state.

Direct validator commands remain supported for focused diagnosis. `ci-active`
is intentionally broader than local changed-path validation but is not a
release claim. Future stages add real installed-distribution, project, and
other validators to this structure only when those components exist.

No forward release-candidate or publication profile is fabricated in Stage 1.
The current `v0.1.0` release/preflight/verify commands remain explicit legacy
lifecycle operations. Stage 10 will replace their two-product payload
assumptions while preserving authorization, immutability, recovery, and public
verification invariants.

#### Machine-readable ownership and routing design

Stage 1 will add `validation/ownership.yml` as the development-control source
for validator and profile routing. It is not an installed RRP resource,
clinical contract, project manifest, or release authorization file.

The versioned document will contain:

```text
registry_version
validators[]
    validator_id
    owner_boundary
    lifecycle_scope
    status
    invariant
    runner
        script
        arguments[]
    trigger_paths
        exact[]
        prefixes[]
        suffixes[]
    prerequisites[]
    transition_ledger_id
profiles[]
    profile_id
    purpose
    status
    includes[]
```

The allowed status vocabulary is:

- `active_global` — selected by every forward profile;
- `active_scoped` — selected by owned path/boundary;
- `composite` — profile-only composition;
- `legacy_callable` — explicit invocation only;
- `historical_evidence` — retained but not ordinarily executed;
- `replace_later` — still selected for its current path until its named
  successor passes; and
- `retire_later` — explicit legacy use only until its retirement condition.

Paths are normalized repository-relative paths. Matching supports only exact
paths, literal directory prefixes, and literal suffixes—no regular expressions,
shell expansion, parent traversal, absolute paths, or symlinked runner scripts.
IDs are unique and stable. Every referenced validator/profile/prerequisite and
transition-ledger ID must exist; profile and prerequisite graphs must be
acyclic; a validator executes at most once per run.

The registry stores scripts and argument arrays rather than shell command
strings. Stage 1 validation rejects runners outside the repository, missing or
linked scripts, unknown fields/statuses, duplicate IDs, unknown references,
unmatched active units, cycles, and profiles that directly or transitively
include a historical unit without an explicit legacy profile.

The initial owner IDs describe only real current boundaries: source policy,
documentation, validation governance, specification foundation, canonical
handoff, synthetic example, producer/provider, runtime, history/persistence,
products/application, operations/observability, application artifact, Connect
Cloud target, Hospital legacy delivery, release candidate, and publication.
Stage 2+ may add installed-distribution or project owners when executable
boundaries exist; Stage 1 does not add empty speculative validator entries.

The dispatcher will support the following Stage 1 interface:

```text
Rscript operations/validate.R --profile PROFILE
Rscript operations/validate.R --profile source-changed [--base REVISION]
Rscript operations/validate.R --profile source-changed --paths PATH...
Rscript operations/validate.R --list
Rscript operations/validate.R --explain --profile PROFILE [selection inputs]
```

`--paths` is the deterministic test/automation seam and accepts no filesystem
mutation. `--explain` validates and prints the resolved ordered units and
reasons without running them. Conflicting selectors, unknown profiles, invalid
paths/revisions, registry errors, or unavailable prerequisites fail before any
validator runs.

For compatibility, existing commands map exactly as follows and emit a visible
legacy classification:

```text
--mode development → --profile legacy-v0.1-development
--mode checkpoint  → --profile legacy-v0.1-checkpoint
```

The compatibility modes retain current composition and exit behavior so
release preflight is not accidentally altered. They stop being normative as
soon as the new profiles pass Increment 1.B, but remain callable until their
ledger retirement conditions are met.

Current repository-check functions that lack direct scripts will be exposed
through one transitional, allowlisted current-boundary runner. Its R code—not
YAML—owns the finite mapping from boundary ID to source/load sequence and
validator function. It accepts no arbitrary file or function input, is not a
future plugin API, and carries a ledger retirement stage. New forward
validators should own direct entry points rather than expand this shim.

#### Current validator disposition summary

The Stage 1 registry and transition ledger must enumerate each exact runner and
repository-check unit beneath these grouped decisions:

| Current validator or suite | Disposition | Owner/invariant and transition |
|---|---|---|
| Documentation validator | **ACTIVE / GLOBAL** | Documentation links, navigation, authority, and path portability; part of `source-fast` |
| Repository policy validator | **ACTIVE / GLOBAL** | Sibling independence, obvious secret/PHI-fixture rules, and executable path portability; gain a direct runner |
| Phase 0 runner and checkpoint | **LEGACY BUT CALLABLE** | Current validator/parser and `v0.1.0` bootstrap evidence; new non-Phase governance tests replace forward use in Stage 1 |
| Specification envelope/repository validator and Phase 1 suite | **ACTIVE / SCOPED** | Common YAML/identity/compatibility vocabulary remains current; route as specification-foundation ownership despite the command's legacy filename |
| Canonical repository validators and Phase 2 suite | **REPLACE LATER** | Protect current canonical identity/relationships/temporal rules until Stage 5 supplies the 1.0 terminal-availability and fixed-coverage contract |
| Synthetic repository validator and Phase 3 suite | **REPLACE LATER** | Protect fictional deterministic source/admission behavior until Stages 4–5 make it an ordinary project |
| Runtime/provider repository validator and Phase 4 suite | **REPLACE LATER** | Protect temporal eligibility, provider trust/failure, and current package conformance until Stage 5 replaces hazard semantics |
| History repository validator and Phase 5 suite | **REPLACE LATER** | Protect atomic append/retry/invalidation/restatement and DuckDB behavior until Stage 6 versions 1.0 history |
| Product/app repository validator and Phase 6 suite | **REPLACE LATER** | Protect product-from-history and product-only app boundaries until Stage 7 migrates semantics |
| Operator registry/repository validator and Phase 7 suite | **REPLACE LATER** | Protect documented human operations, mutation classes, and safe doctor behavior until Stages 3–7 replace repository operations |
| Artifact and Connect repository validators, Phase 8 suite/checkpoint | **REPLACE LATER** | Protect product-only closure, target separation, integrity, and no-publication behavior until Stage 8 |
| Observability repository validator and Phase 9 suite | **REPLACE LATER** | Protect privacy-safe diagnostic context/sink separation until Stage 3 moves operations into installed software |
| Canonical-producer repository validator and Phase 10 suite/checkpoint | **REPLACE LATER** | Protect trust/selection/admission and independent substitution until Stages 4–5 establish project composition |
| Hospital repository validator, Git-realization validators, and Phase 11 suite | **RETIRE LATER** | Explicit `v0.1.0` delivery evidence only; callable when that historical path is deliberately inspected, retired from active source in Stage 9 |
| Release preparation, publication tests/preflight, and public verification | **REPLACE LATER** | Explicit legacy lifecycle only; preserve clean source, authorization, immutability, recovery, checksums, and acquisition until Stage 10 replaces two-product assumptions |
| Current `development` aggregate | **COMPOSITE**, then **LEGACY BUT CALLABLE** | Freeze its exact membership as `legacy-v0.1-development`; `source-changed` becomes local authority |
| Current `checkpoint` aggregate | **LEGACY BUT CALLABLE** | Freeze as `legacy-v0.1-checkpoint`; it remains available to current release preflight but never gates unrelated 1.0 work |
| Phase/iteration required-file and implementation-record heading checks | **HISTORICAL EVIDENCE** | Retained inside the legacy checkpoint only; never auto-selected as forward component proof |
| Git cleanliness/commit/remote checks in Hospital and release code | **ACTIVE / SCOPED** | Preserve only in the destructive or immutable lifecycle that owns them; never make clean Git a project/source validity rule |

`REPLACE LATER` units remain auto-selectable for changes to the current
implemented boundary until their successor passes and the ledger advances.
`RETIRE LATER`, `LEGACY BUT CALLABLE`, and `HISTORICAL EVIDENCE` units never
enter `source-changed` or `ci-active` merely because they exist. Changes to
legacy Hospital/release paths select an explicit safety notice and their
declared legacy validator, not the unrelated forward matrix.

Each old Phase runner remains directly callable during Stage 1. The ownership
registry, not its filename, decides whether it participates in forward
validation. Renaming or physically reorganizing the suites is deferred until
their owning implementation stage can do so without duplicating or losing
tests.

#### Initial routing relationships

The registry will encode enough current relationships to make changed-path
selection safe:

| Changed boundary example | Selected evidence after `source-fast` |
|---|---|
| Normative or maintained documentation | Documentation validator; governance tests when authority/navigation files change |
| Validation registry/dispatcher or repository policy | Governance routing tests plus repository-policy and documentation validation |
| Common specification envelope/foundation | Specification suite plus canonical and current integration consumers declared against that vocabulary |
| Canonical contracts/validators | Canonical suite plus producer/runtime integrations that consume admitted bundles |
| `rrpruntime` source/package metadata | Runtime/provider suite plus history and relevant cross-layer integration suites |
| History ports or DuckDB adapter | History suite plus products and end-to-end producer integration that consume logical reads |
| Product builder/materializer/app | Product/app suite plus product-only artifact integration |
| Application artifact builder | Artifact suite plus Connect target integration |
| Connect Cloud target files | Connect/Phase 8 target slice only, with artifact prerequisite |
| Observability operation/event code | Observability suite plus instrumented-operation integration |
| Hospital/release/publication files | Only explicitly mapped legacy safety/release evidence; never all Phase suites by default |

Downstream integration units list upstream path prefixes among their own
triggers. Prerequisite edges establish order and required foundations; they do
not automatically turn every downstream consumer into a universal test.
`--explain` makes each trigger or prerequisite reason inspectable.

#### Documentation and authority approach

Stage 1 uses classification and navigation, not a broad move:

- True North, Platform Architecture, and this plan remain current normative
  authority.
- The implementation record remains append-oriented evidence, not a prose API
  that future component validators scrape for conformance.
- `docs/development/` remains internal development guidance and will gain the
  validation-governance and transition-ledger documents.
- Existing assessment status labels and the documentation index continue to
  identify internal decision evidence.
- Existing `v0.1.0` component and operations documents remain clearly labeled
  as current implemented/historical boundaries until their replacement stage.
- Hospital and release documents remain maintainer/historical guidance for the
  immutable release, not ordinary 1.0 adopter navigation.
- No empty future `docs/user/`, `docs/history/`, or `docs/maintainers/`
  directory is created in Stage 1. Broad physical reclassification waits until
  real product content and distribution ownership justify it.

Stage 1 will add `docs/development/validation-governance.md` as the human
explanation of profiles, changed-path selection, direct/legacy use, failure
behavior, CI composition, and how later stages register validators. It will
update `docs/operations/validation.md`, README/START HERE/indexes, and the
operation registry only enough to point to the new current commands and label
old modes accurately.

`AGENTS.md` will stay concise. It will point agents to the accepted detailed
Stage 1 plan, the ownership registry, the documented profile-selection rule,
and the same human validation commands. It will explicitly retain target versus
implemented-state language and prohibit unrelated Hospital/release proofs as a
default. It will not duplicate registry entries or architecture.

#### Transition-ledger approach

Stage 1 will add `docs/development/transition-ledger.md` as an operational,
reviewed table. Each stable `transition_id` records current location/purpose,
protected invariant, disposition, current authority status, replacement stage,
coexistence need, retirement condition, and notes from the latest completed
stage. Every validation unit links to one ledger ID; non-validation machinery
is tracked directly in the ledger.

The initial ledger must include at least:

| Machinery | Initial forward disposition | Coexistence and retirement control |
|---|---|---|
| Repository-root operation scripts | Replace with installed shared operations/CLI across Stages 2–8 | Remain current executable wrappers until each successor operation passes; no new product logic added to them without an explicit transition reason |
| `operations/lib` source chain | Split by eventual package/resource owner | Remains current implementation; Stage 2 starts physical ownership using the ledger rather than moving files opportunistically |
| `rrpruntime` | Reuse and refactor | Retained package; Stage 2 installs it and Stage 5 replaces hazard semantics |
| Foundation/canonical contracts | Reuse foundation, refactor clinical target inputs | Current admission remains executable until Stage 5; old contract identity remains historical afterward |
| Estimand/daily-hazard contracts | Replace | Current runtime/history remains callable only during transition; never renamed or imported as 1.0 cumulative risk |
| Provider registry/execution | Reuse and bind to project/target | Current installation selection coexists until Stages 4–5 pass |
| History ports and DuckDB adapter | Reuse/refactor | Current hazard state remains isolated; Stage 6 establishes new state authority and migration rules |
| Products/materializer/app | Reuse boundary, refactor semantics | Current hazard views remain until Stage 7 product/app acceptance, then become legacy-only |
| Application artifact and Connect Cloud | Reuse/refactor | Current repository-built realization remains until Stage 8 installed-input artifact proof |
| Generated Hospital distribution/Git realization | Retire from active path | Retain for `v0.1.0` evidence and explicit legacy verification until Stage 9 retirement review |
| Root `renv` | Retain for development only | Remains current dependency mechanism; Stage 2 separates installed closure without treating the lock as payload |
| Phase runners/checkpoints/prose gates | Reassign, replace, or retain legacy as classified above | Stage 1 removes universal authority; later stages retire individual units only after successor evidence |
| Release/publication tooling | Preserve safeguards, replace payload later | Explicit `v0.1.0` lifecycle only until Stage 10 implements the one-product release path |
| Documentation authorities | Keep current authority; progressively reclassify implementation docs | Minimal labels/navigation now; broad user/history/maintainer organization completes by Stage 9 |

The ledger is updated in every later stage close. An item cannot move to
`retired` without named successor evidence or an explicit decision that its
invariant no longer belongs to the target architecture. Temporary shims must
have an owner, purpose, and retirement condition from creation.

#### Development-convention changes

Before Stage 2, the conventions and repository policies will require that new
1.0 work:

- place reusable product code behind a namespace rather than source-order or
  `.GlobalEnv` coupling;
- discover product resources through an owner API, never by inferring a
  repository root;
- accept explicit project context whenever a project boundary is involved;
- identify package, installed-resource, project-extension, build-only, and
  deployment dependency ownership without treating root `renv` as universal;
- organize new tests by component/lifecycle ownership rather than new Phase
  directories or Phase runner names;
- select validation through the registry/profile appropriate to the changed
  boundary and record broader evidence only where required;
- preserve a transition shim only with a ledger entry and tested retirement
  condition;
- use forward-only identities and never amend or relabel `v0.1.0`; and
- retain the existing clarity, comments, native-pipe, dependency-minimization,
  safety, portability, and human-first operation rules.

These are ownership conventions, not a Stage 2 directory or package design.
Stage 1 will not prescribe the final source tree, package names, installed
layout, resource catalog, or distribution manifest.

#### CI implications

After the dispatcher and documentation are accepted, the existing single CI
workflow will:

- retain checkout, Ubuntu, R 4.4, root-development `renv`, and read-only token
  posture;
- replace separate documentation plus universal checkpoint steps with one
  `ci-active` invocation, which already composes `source-fast` once;
- validate the ownership registry and print resolved profile membership in the
  job output;
- exclude Hospital generation, clean acquisition, release preparation,
  publication, and historical checkpoint gates from ordinary push/PR CI;
- keep an explicit manual `workflow_dispatch` path for
  `legacy-v0.1-development` or `legacy-v0.1-checkpoint` when maintainers need
  exact regression evidence; and
- add future jobs/profiles only when later-stage components and environment
  claims exist.

Stage 1 does not design the macOS/Ubuntu clean-install support matrix, package
build matrix, deployment matrix, or release workflow. CI alignment proves that
local and hosted governance agree; it does not imply 1.0 support or release
readiness.

#### Protected-invariant continuity

| Protected invariant | Stage 1 control and forward owner |
|---|---|
| Specification/canonical validity | Current foundation/canonical units remain selected by their paths; future contracts replace them only with conformance evidence |
| Temporal correctness | Runtime/provider and producer integration units remain transitional scoped checks until Stage 5 |
| History integrity | History/DuckDB units remain transitional scoped checks until Stage 6 |
| Privacy and secret exclusion | Repository policy is global; observability privacy tests remain scoped; human review remains mandatory |
| Dependency integrity | Lock/specification/artifact checks retain current ownership; Stage 2 adds distribution dependency evidence rather than replacing these silently |
| Artifact integrity and target separation | Artifact/Connect units remain scoped until Stage 8 successors pass |
| Release immutability | Published evidence is untouched; release preparation/verification remains explicit legacy lifecycle evidence until Stage 10 |
| Publication authorization and recovery | Publication commands/tests are never in ordinary profiles and remain fail-closed, explicit, and callable |
| Documentation links and authority | Documentation validation is in `source-fast`; governance tests cover required authority pointers |
| Destructive-operation safety | Existing artifact/Hospital/release destination, pristine-output, no-overwrite, and no-remote rules stay with those lifecycle validators |

Reclassification changes routing, not the meaning or strength of an invariant.
A Stage 1 registry test must fail if a protected invariant loses every current
validator and lacks an explicit pending replacement reason.

#### Stage 1 increments

##### 1.A — Ownership registry and transition baseline

###### Objective

Create the declarative ownership model and actionable inventory that every
later Stage 1 change uses.

###### Why this increment comes now

Dispatcher, documentation, and CI changes would otherwise encode independent
classifications and recreate ambiguity. Registry/status semantics and the
transition ledger must be accepted first.

###### Scope

- Add `validation/ownership.yml` with the exact schema and initial current
  validator/profile inventory described above.
- Add `docs/development/validation-governance.md` and
  `docs/development/transition-ledger.md`.
- Add a non-Phase governance test runner and tests for registry parsing,
  schema/status/path safety, unique IDs, references, graph acyclicity, full
  current-validator coverage, and ledger linkage.
- Record the exact membership of both existing aggregate modes before either
  is modified.

###### Explicit non-scope

Do not change `operations/validate.R`, CI, existing validator behavior,
packages, contracts, runtime, operations, or release state.

###### Existing machinery disposition

Inventory and classify current functions, Phase runners, standalone validators,
and release operations without renaming, moving, or deleting them. Reuse the
common YAML reader/validation result vocabulary only where it does not make the
registry a product contract.

###### Compatibility / transition effect

The old `development` and `checkpoint` commands remain authoritative executable
behavior. The new registry becomes the accepted classification source but has
no dispatch effect yet.

###### Human/agent workflow effect

Maintainers and agents can inspect one file to determine owner, status,
invariant, and planned transition, but continue invoking existing commands
until 1.B.

###### Validation / evidence

YAML parsing, registry/ledger conformance tests, inventory comparison against
current aggregate membership, documentation links, Markdown hygiene, and diff
scope. Tests must include duplicate/cycle/unsafe-path/unknown-reference and
unclassified-current-validator failures.

###### Recovery / rollback

The increment is additive. Revert its bounded files if validation fails; no
existing execution path or state needs restoration.

###### Completion state

Every meaningful current check has one explicit disposition, owner/invariant,
command or historical status, and transition link; the two old composites have
captured exact membership; no future component validator is invented.

###### Documentation / record update

Update the plan only if inventory evidence changes it, link the two development
documents from the documentation index, and append the 1.A implementation-
record entry.

##### 1.B — Profile dispatcher and legacy compatibility bridge

###### Objective

Make named, ownership-routed validation executable while preserving exact old
aggregate behavior under explicit legacy names.

###### Why this increment comes now

It depends on the accepted registry and frozen legacy membership from 1.A.
Instructions and CI cannot switch until selection and compatibility are tested.

###### Scope

- Add the small routing/parser library and transitional allowlisted current-
  boundary runner.
- Give repository policy validation a direct noninteractive entry point.
- Refactor `operations/validate.R` to validate the registry, resolve named
  profiles/changed paths, run independent subprocesses once in deterministic
  order, combine exit status, and support list/explain behavior.
- Implement `source-fast`, `source-changed`, `ci-active`, and the two explicit
  legacy profiles.
- Preserve `--mode development|checkpoint` as deprecated compatibility aliases
  with exact membership and visible legacy diagnostics.
- Add non-Phase tests for parsing, matching, prerequisite/profile expansion,
  deterministic order, deduplication, failure propagation, explain-only
  behavior, dirty/untracked paths, and legacy equivalence.

###### Explicit non-scope

Do not rewrite component validators, move Phase tests, create future package/
distribution/project validators, alter release preflight behavior, or remove a
legacy mode.

###### Existing machinery disposition

Reuse validation result rendering and direct scripts. Wrap current repository-
function validators through a finite code-owned compatibility adapter. Isolate
the eager `platform-validation.R` aggregate behind legacy profiles; do not use
its source chain for forward dispatch.

###### Compatibility / transition effect

`source-changed` becomes the normative local validation entry point after this
increment passes. Existing mode commands and direct Phase runners still work;
publication preflight continues to receive exact checkpoint semantics.

###### Human/agent workflow effect

Maintainers and agents select a named profile or direct validator and can
explain why it was selected. Narrow work no longer implicitly launches all
Phase and Hospital/release evidence.

###### Validation / evidence

Focused governance tests plus fixture repositories/path sets prove every
documented mapping, invalid input, safe runner constraint, process isolation,
combined failures, signal/exit handling, selection explanation, exact legacy
membership, and no mutation. Run `source-fast`, representative
`source-changed --paths` cases, and explain both legacy profiles without
executing their expensive matrices.

###### Recovery / rollback

Implement the dispatcher in a bounded change while retaining the original
aggregate functions. If the new path fails, revert `operations/validate.R` and
new routing files; exact old modes remain available and no product state was
changed.

###### Completion state

Named profiles resolve and execute deterministically, current changed paths
select owned evidence, legacy aliases resolve to frozen old membership, and no
forward profile includes Hospital/release/checkpoint prose evidence implicitly.

###### Documentation / record update

Document the tested CLI semantics in validation governance and the operations
guide, update the operation registry with the new current profile commands and
legacy classifications, and append the 1.B record entry.

##### 1.C — Authority, documentation, and development-convention alignment

###### Objective

Make human and agent instructions use the new development-control model and
give Stage 2 safe forward conventions.

###### Why this increment comes now

It depends on 1.A's accepted classifications. It may proceed alongside most of
1.B, but final command wording waits for the dispatcher interface to pass.

###### Scope

- Update `AGENTS.md`, README, START HERE, documentation index, validation
  operations guide, repository policies, implementation conventions, and the
  operation registry as described above.
- Add or refine status labels only where a reader could mistake `v0.1.0`
  implementation/operations/release material for 1.0 authority.
- Establish non-Phase test organization, namespaced code/resource ownership,
  explicit project-context, dependency-owner, transition-shim, proportional-
  validation, and forward-versioning conventions.
- Link current authority, validation governance, and transition ledger without
  duplicating their contents.

###### Explicit non-scope

Do not move the documentation tree broadly, create empty future directories,
rewrite historical documents/records, specify Stage 2 layout, or change any
product operation.

###### Existing machinery disposition

Reuse current authority/navigation and human-first operation documentation.
Replace Phase-test/default-checkpoint language only where it claims forward
governance. Preserve exact historical commands under clearly labeled legacy
sections.

###### Compatibility / transition effect

The RRP 1.0 authority chain, current detailed Stage 1 plan, ownership registry,
and proportional profile selection become normative for contributors. Current
executable behavior remains explicitly `v0.1.0`-derived.

###### Human/agent workflow effect

Humans and agents use the same `source-changed`, `source-fast`, direct, CI, and
explicit legacy operations; neither is instructed to run unrelated Hospital or
release proofs for ordinary work.

###### Validation / evidence

Documentation validator, operation-registry validation targeted to the changed
commands, authority/stale-language scans, link/status review, Markdown hygiene,
and tests that required human/agent commands match registry commands.

###### Recovery / rollback

Revert the bounded instruction/documentation changes if they get ahead of 1.B.
Legacy docs and commands remain intact in Git and no executable/state rollback
is required.

###### Completion state

No maintained current instruction requires Phase chronology to choose forward
validation; document classes are understandable; Stage 2 conventions prohibit
new repository-root/source-order/Phase-governance coupling.

###### Documentation / record update

These documents are the increment's primary output. Append the 1.C record entry
with the exact classification and convention changes; do not rewrite older
entries.

##### 1.D — CI alignment and deliberate legacy execution

###### Objective

Make hosted validation agree with local ownership routing while preserving an
intentional way to request exact `v0.1.0` regression evidence.

###### Why this increment comes now

CI can change only after the dispatcher/profile tests pass and human/agent
commands are aligned.

###### Scope

- Replace duplicate documentation plus checkpoint execution on push/PR with
  one `ci-active` invocation.
- Retain the existing Ubuntu/R 4.4/root-`renv` setup as current development
  infrastructure.
- Add manual workflow selection for the two explicit legacy profiles with
  least-privilege permissions and no publication/deployment step.
- Make resolved profile/validator membership visible in CI evidence.
- Add static tests for workflow/profile agreement and prohibition of ordinary
  CI inclusion of Hospital, release preparation, or publication commands.

###### Explicit non-scope

Do not add Stage 2 package/distribution jobs, support-matrix claims, macOS
cells, deployment, secrets, release triggers, scheduled jobs, or remote
mutation.

###### Existing machinery disposition

Reuse the current workflow, R line, `renv` restore, and read-only permissions.
Replace universal checkpoint as the push/PR command. Keep legacy checkpoint
available only through explicit manual selection and existing maintainer
release behavior.

###### Compatibility / transition effect

Ordinary CI now represents active source coherence, not `v0.1.0` release
readiness. Exact legacy validation remains deliberate and separately labeled.

###### Human/agent workflow effect

Local `source-changed` and hosted `ci-active` have documented complementary
roles. Maintainers can request old evidence without making it every
contributor's default.

###### Validation / evidence

Parse and statically validate the workflow; assert push/PR resolves only
`ci-active`, manual legacy input is allowlisted, permissions remain read-only,
documentation is not duplicated, and no release/deployment command appears.
Run governance tests and observe one successful `ci-active` workflow before
closing the increment.

###### Recovery / rollback

Revert only the workflow change if hosted execution fails; the local dispatcher
and explicit legacy commands remain usable. Do not weaken required branch
protection merely to obtain a pass.

###### Completion state

Push/PR CI runs the active composite once, manual legacy profiles are available,
local and CI docs agree, and no CI path can publish or deploy.

###### Documentation / record update

Update validation governance/operations with hosted versus local roles and
append the 1.D implementation-record evidence, including the observed CI run.

##### 1.E — Stage 1 acceptance and closeout

###### Objective

Prove the complete development-control transition, record the realized Stage 1
state, and establish the factual inputs allowed for Stage 2 planning.

###### Why this increment comes now

It composes 1.A–1.D. Stage 2 cannot safely plan physical restructuring until
routing, instructions, ledger, and CI agree and no protected invariant has
been orphaned.

###### Scope

- Run the concrete Stage 1 acceptance matrix below.
- Audit every current validator/runner against registry and ledger coverage.
- Confirm the code-change allowlist contains only Stage 1 governance,
  validation-routing, tests, docs, and CI files.
- Complete the Stage-close reconciliation template with actual evidence.
- Mark Stage 1 complete in this plan and append its implementation record only
  if every gate passes.

###### Explicit non-scope

Do not create, move, or design Stage 2 packages/resources/distribution content;
do not change target architecture, runtime semantics, version metadata, or
release state; do not begin detailed Stage 2 planning inside the closeout.

###### Existing machinery disposition

No additional machinery is replaced here. Verify the dispositions already
implemented, leave legacy commands callable, and record any temporary
coexistence exactly.

###### Compatibility / transition effect

Stage 1 closes only when named profiles are the forward control system and the
`v0.1.0` executable baseline remains behaviorally unchanged. Detailed Stage 2
planning then becomes authorized; Stage 2 implementation does not.

###### Human/agent workflow effect

Maintainers and agents can rely on documented profile selection and the ledger.
The next agent reads the reconciliation before designing Stage 2.

###### Validation / evidence

Run registry/governance tests, documentation and repository policy validators,
representative changed-path selection fixtures, `source-fast`, `ci-active`
once as the broad active checkpoint, R/YAML parsing, workflow static checks,
Markdown/link checks, `git diff --check`, and an exact legacy-profile membership
comparison. Do not execute Hospital generation, release preparation,
publication, or clean acquisition.

###### Recovery / rollback

If the gate fails, leave Stage 1 in progress and repair the owning increment.
Because changes are development controls only, revert the failing bounded
increment through normal Git history if necessary; never reset user work or
alter product/state/release data.

###### Completion state

Every concrete Stage 1 gate passes, CI evidence agrees, the reconciliation is
recorded, no high-level roadmap revision is required or any required revision
is explicitly approved, and the plan names detailed Stage 2 planning as next.

###### Documentation / record update

Update this Stage 1 planning status/actual close state, the transition ledger,
validation governance, and relevant navigation. Append the final Stage 1
implementation/reconciliation entry with validation evidence and Stage 2
constraints.

#### Increment dependency graph

```text
1.A Ownership registry and transition baseline
        ├──────────────→ 1.B Profile dispatcher and legacy bridge
        │                         ↓
        └──────────────→ 1.C Authority/docs/conventions
                                  │
                     1.B + 1.C ───┘
                                  ↓
                         1.D CI alignment
                                  ↓
                         1.E Acceptance/closeout
```

After 1.A settles IDs/statuses, documentation classification and convention
drafting in 1.C may proceed in parallel with dispatcher implementation in 1.B.
The final command and workflow wording in 1.C waits for 1.B tests. Increment
1.D requires both. No other parallelism is worth weakening the control order.

#### Concrete Stage 1 acceptance gate

Stage 1 closes only when all of the following are evidenced:

1. **Authority:** maintained current navigation resolves True North → Platform
   Architecture → high-level roadmap/current Stage 1 plan → implementation
   record → software, with `v0.1.0` clearly immutable/historical and 1.0 clearly
   not implemented.
2. **Registry integrity:** the ownership registry parses, uses only allowed
   values/paths/runners, has unique and resolvable IDs, acyclic graphs, complete
   current inventory coverage, and valid transition links.
3. **Selection correctness:** fixture path sets prove documentation,
   specification, internal runtime, history, product/app, artifact, Connect,
   observability, and legacy release mappings; output states each selection
   reason and executes no unit twice.
4. **Profile separation:** `source-fast`, `source-changed`, and `ci-active`
   contain no implicit Hospital generation, release preparation/publication,
   or historical checkpoint/prose gates.
5. **Legacy availability:** direct Phase runners and both legacy aggregate
   profiles remain callable; dry-run/explain membership is exactly the frozen
   pre-Stage 1 composition, including the checkpoint used by release preflight.
6. **Invariant continuity:** every protected invariant in the continuity table
   has at least one current owner/validator or an explicit pending replacement
   with stage and coexistence control.
7. **Human/agent alignment:** `AGENTS.md`, validation operations, operation
   registry, development policies/conventions, and profile help expose the same
   commands, meanings, side effects, and legacy labels.
8. **Documentation classification:** normative, development/assessment,
   implemented `v0.1.0`, historical release, and maintainer documents are
   distinguishable without broad relocation; links/navigation pass.
9. **Transition control:** every required machinery category exists in the
   actionable ledger, and each temporary shim has an owner and retirement
   condition.
10. **CI agreement:** push/PR uses `ci-active` once, manual legacy execution is
    explicit, permissions remain read-only, and a hosted run passes.
11. **Behavioral non-change:** diff scope contains no runtime, canonical,
    provider, persistence, product, app, artifact payload, release/version, or
    publication behavior change; `ci-active` passes the current forward-
    relevant component/integration matrix.
12. **Repository hygiene:** all changed R and YAML parse, governance tests,
    documentation validation, repository policy validation, Markdown hygiene,
    secret/PHI rules, and `git diff --check` pass.

The acceptance report lists selected validator IDs and results rather than
claiming that historical suites were “skipped” without classification. Failure
of any item leaves Stage 1 in progress and does not authorize Stage 2 planning.

#### Stage-close reconciliation template

At Increment 1.E, append a concise record using this structure:

```text
Stage 1 reconciliation

Planned versus actual increments
    1.A ... planned / actual / deviation
    1.B ... planned / actual / deviation
    1.C ... planned / actual / deviation
    1.D ... planned / actual / deviation
    1.E ... planned / actual / deviation

Realized validation model
    registry/schema version
    active local and CI profiles
    dispatcher/compatibility behavior

Current-check disposition
    reassigned
    legacy callable
    historical evidence
    replace/retire later
    pending with reason

Authority and conventions actually changed
Legacy paths made non-authoritative or retired
Temporary coexistence and retirement conditions
Changed assumptions or surprises
Facts constraining Stage 2 detailed planning
Stage 1 acceptance results and CI evidence
High-level architecture/roadmap revision required: yes/no + rationale
Next authorized task
```

The reconciliation records facts from implementation. It must not be filled
with planned assertions, invent a broad reassessment, or pre-design Stage 2.

#### Stage 2 handoff assumptions

After—and only after—the Stage 1 gate and reconciliation pass, detailed Stage
2 planning may assume:

- RRP 1.0.0 authority and this high-level roadmap govern forward work;
- named ownership/lifecycle profiles, not Phase chronology, select validation;
- the registry and dispatcher can accept new real validators without making
  them universal or executing arbitrary configuration;
- repository/static/documentation safety remains globally protected, and
  relevant current component/integration invariants remain scoped during
  transition;
- legacy `v0.1.0` development/checkpoint, Hospital, and release evidence is
  explicitly available but not a forward default;
- new source, package, and resource work must use namespaces, explicit
  ownership, installed-resource APIs, explicit context, dependency owners, and
  non-Phase tests;
- the transition ledger identifies which current physical machinery Stage 2
  may reuse, move, wrap, or eventually retire and the evidence required first;
- documentation authority and implemented-versus-target status are clear; and
- the executable analytical platform, release/version metadata, and published
  `v0.1.0` evidence are unchanged by Stage 1.

These assumptions authorize **detailed Stage 2 planning only**. They do not
choose the final package tree, resource layout, inclusion manifest, dependency
acquisition mechanism, or distribution implementation, and they do not
authorize Stage 2 source changes.

## Intentionally deferred beyond the initial 1.0.0 path

This roadmap does not add bundled R, system-wide installation, remote/non-R
providers, multiple targets, project estimands/request builders, custom
product/app plugins, a compute-capable artifact, production database mandate,
scheduling, source credentials in artifacts, automatic migration, universal
feature storage, decision/priority/work/intervention systems,
metrics/alerts/audit platforms, multi-hospital tenancy, mandatory `readmit`, or
clinical validation claims.

Self-managed Posit Connect is adjacent to the Posit-compatible artifact, but
support waits for its own acceptance evidence. OCI/Docker here is product-only;
it does not imply producer/provider/history compute inside the image.

## Next planning step

After this detailed Stage 1 plan is accepted, the next task is:

> **Implement RRP 1.0.0 Stage 1, beginning with Increment 1.A.**

Implement the five bounded increments in dependency order, preserving a
coherent repository and recording actual evidence at each close. Do not detail
Stage 2 until Stage 1 has been implemented, validated, and reconciled. Do not
implement Stage 2 until its later detailed plan is accepted.

Stage 1 changes only development control. It must not collapse software
upgrade, project migration, state migration, deployment, or publication, or
leak into the Stage 2 product/distribution foundation.
