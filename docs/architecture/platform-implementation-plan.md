# RRP 1.0.0 implementation plan

## Status and authority

**Status:** authoritative high-level implementation roadmap for the RRP 1.0.0
target generation with completed Stage 1 and a proposed detailed Stage 2 plan
ready for maintainer review; Stage 2 implementation has not started

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

The high-level roadmap is intentionally big-picture; its accepted detailed
current-stage section authorizes only that stage's bounded increments. Before
a stage's source changes begin,
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

**Implementation status:** complete (2026-09-14); Increments 1.A–1.E complete

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

**Implementation status:** complete (2026-09-12)

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

**Implementation status:** complete (2026-09-14)

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

**Implementation status:** complete (2026-09-14)

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

**Implementation status:** complete (2026-09-14)

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

**Implementation status:** complete (2026-09-14)

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

### Stage 2 detailed plan — Software Source and Closed-Distribution Foundation

**Planning status:** proposed (2026-09-15); ready for maintainer review; Stage 2
implementation not started

This section details only Stage 2. It does not authorize Stage 3 installation,
launcher, CLI, shared-operation, project, analytical, history, product,
application, deployment, migration, release, publication, or acquisition work.
Implementation may begin only after maintainers accept this detailed plan.

#### Realized starting point and planning conclusion

The Stage 1 exit is clean and synchronized with `origin/main`. Ownership-routed
validation is active; the exact legacy aggregates, current-boundary adapter,
Phase evidence, Hospital machinery, and release/publication safeguards remain
classified and callable. The executable product remains substantially
`v0.1.0`-derived.

Source inspection found the following physical facts:

| Current area | Realized responsibility and constraint |
|---|---|
| `runtime/` | One buildable `rrpruntime@0.3.0` package with 17 R files, a base-R dependency posture, admitted-input/temporal/provider/history primitives, and no repository-resource discovery |
| `operations/lib/` | 35 loose files and more than 12,000 lines mixing reusable conformance/orchestration with repository validation, root discovery, temporary package installation, target construction, Hospital delivery, and release/publication lifecycles |
| `products/R`, `implementations/products/yaml/R`, `app/R` | Reusable logical product, materialization/access, and product-only application code without a package owner |
| `implementations/persistence/duckdb/R` | A reusable supplied persistence adapter with explicit `DBI`/`duckdb` dependencies and repository composition wrappers |
| `deploy/application-artifact` | Strong closed-inventory, safe-path, standalone-validation, and atomic-promotion patterns, but repository source maps and MD5 integrity |
| `deploy/connect-cloud` | Target-specific Git realization using `rsconnect`, `jsonlite`, and a root-lock projection; its semantic refactor belongs to Stage 8 |
| `contracts/`, app declarations, adapter declarations, and synthetic resources | Useful versioned resources currently discovered by repository-relative paths; Hospital contracts and repository instance configuration are not forward installed resources |
| Root `renv.lock` | A 39-package R 4.4.1 development closure combining development, persistence, app, artifact, Connect, and publication needs; it is not installed-software authority |
| Hospital/release machinery | Useful SHA-256, inventory, safe-destination, provenance, and recovery evidence coupled to the immutable two-product `v0.1.0` lifecycle |

The accepted high-level Stage 2 objective remains correct. No evidence requires
another package, a roadmap change, or a different Stage 2/3 boundary. Precision
is required in one place: Stage 2 establishes physical owners and a closed
source distribution, but it moves only implementation whose ownership is
needed for that distribution. It does not finish the public operation surface
or redesign the semantics owned by Stages 3–8.

#### Settled package and source ownership

The two-package architecture remains sound. The main package is named
`rrpplatform`; it is an internal implementation package, not the RRP product
identity or the operator interface. Source becomes conventionally grouped as:

```text
packages/
├── rrpruntime/
└── rrpplatform/

distribution/software/
├── source-manifest.yml
├── source-manifest-schema.yml
├── dependency-targets/
└── R/                         # builder/self-validator implementation

operations/
├── build-software-distribution.R
└── validate-software-distribution.R

tests/software/
```

The existing top-level contract, app-resource, adapter-declaration, synthetic,
and documentation trees may remain authoritative source locations. Their
installed output paths are owned by the source manifest and resource catalog;
source layout does not become an installed public path contract.

`rrpruntime` keeps admitted canonical input, temporal eligibility/state,
request and accepted-estimate primitives, provider compatibility/execution,
and storage-neutral history records/ports. It retains current daily-hazard
semantics and version until Stage 5 changes them. It does not gain YAML,
repository, app, DuckDB, project, diagnostic, artifact, Git, or release
dependencies.

`rrpplatform` owns reusable implementation for:

- structured conformance/result primitives and specification/resource access;
- canonical admission and current clinical-profile validation;
- producer declaration, trust, selection, execution, and result admission;
- current runtime/provider composition around `rrpruntime`, without temporary
  installation or public installed operations;
- supplied DuckDB persistence implementation and current history composition;
- privacy-safe operation-context/event primitives;
- logical products, YAML materialization/access, and supplied app support;
- target-neutral application-artifact construction and integrity primitives;
  and
- explicit software/resource context needed by later installed operations.

It does not own repository/documentation validation, CI dispatch, Phase runners,
synthetic source interpretation, project extensions, Connect-specific Git
realization, Hospital construction, release preparation/publication, GitHub
clients, or the distribution builder itself. Distribution build/validation is
a maintainer lifecycle owner under `distribution/software/`, not a third
package.

The initial `rrpplatform` direct installed dependency roots are
`rrpruntime`, `yaml`, `digest`, `DBI`, `duckdb`, and `shiny`. Exact versions and
transitive dependencies belong to a target-keyed resolution, not package code
or the root lock. `rrpruntime` remains dependency-light. `renv`, repository
validation tools, `rsconnect`, and publication clients remain development or
later lifecycle dependencies. A third package is not justified: current
clusters share one product lifecycle, and optional/heavier dependencies can be
classified without fabricating another release boundary.

#### Installed-resource classification and access

Stage 2 establishes a versioned resource catalog and one package-owned access
boundary. `rrpplatform` will export this narrow internal-software pair:

```text
rrp_open_resource_catalog(explicit_distribution_root)
rrp_resource_path(validated_catalog, resource_id)
```

The root is explicit; the catalog and distribution identity are validated;
callers request a stable logical resource ID; returned paths stay beneath the
validated distribution; and there is no current-working-directory, parent,
Git, source-checkout, environment-variable, or sibling-repository discovery.
Stage 3 may create the context from an installed version; it must not replace
this boundary with a new discovery rule.

The Stage 2 source manifest classifies content as follows:

| Class | Stage 2 treatment |
|---|---|
| Internal package source | Ship the exact normalized `rrpruntime` and `rrpplatform` package source trees |
| Current non-Hospital foundation/canonical/runtime/persistence/product/observability/application-artifact contracts | Ship as explicitly cataloged transitional product resources; current hazard identities remain visibly pre-1.0 semantics until Stage 5 |
| DuckDB and YAML adapter declarations | Ship as supplied implementation resources; repository-local example path configuration does not ship |
| App identity and static entry resources | Ship as cataloged product-only app resources; no installed launch operation is claimed |
| Synthetic implementation/configuration/schema | Ship as an inert fictional example seed with explicit nonclinical and not-yet-supported-project status; Stage 4 owns its project form and trusted entry point |
| Target-neutral artifact contract/resources | Ship for package-owned builder primitives; current artifact semantics remain unchanged |
| Normative/product documentation | Ship only README/product identity, True North, current Platform Architecture, contract orientation, software-distribution limitations, and package documentation |
| Legal/support/security | Ship `LICENSE`, `NOTICE`, `SECURITY.md`, and `SUPPORT.md` |
| Project template | No template exists yet; record the role as deferred rather than creating an empty or false project contract before Stage 4 |
| Connect-specific resources | Classify as later Stage 8 target resources and leave outside the minimal Stage 2 payload |
| `config/platform-instance.yml` and repository-local DuckDB configuration | Exclude as installation-owned/reference composition that conflicts with the future project boundary |
| Tests, fixtures, validation registry, CI, assessments, roadmap, implementation record, maintainer operations, root `renv`, Git metadata | Source/development-only; do not ship |
| Hospital distribution/contracts/wrappers and `releases/0.1.0` evidence | Historical or release-evidence-only; do not ship and do not modify |
| Release/publication/acquisition code and generated `build/` state | Maintainer-only or generated; do not ship |

Every shipped resource has a stable ID, role, owner, source path, output path,
required/optional status, media/format classification, and compatibility or
transition note. The catalog is closed: unknown IDs, duplicate identities,
unsafe paths, missing resources, symlinks, and output paths not declared by the
source manifest fail.

#### Closed distribution form, identity, and integrity

The canonical Stage 2 realization is an unpacked directory, not an archive:

```text
rrp-<software-version>-<target-id>/
├── packages/                   # normalized package source trees
├── resources/                  # catalog plus declared resources
├── docs/
├── legal/
├── bin/validate-distribution.R
└── DISTRIBUTION.yml
```

Archive/compression format is deliberately deferred. Stage 3 may consume the
directory directly while installation mechanics are designed, and Stage 10 may
define release archives without making container bytes the Stage 2 identity.

`distribution/software/source-manifest.yml` is the sole inclusion authority.
It declares exact source inputs or exact package-source inventories by stable
ID, role, owner, permitted transformation, normalized output path, target
applicability, and required status. It contains no globs, ignore subtraction,
arbitrary functions, shell expressions, or executable configuration. Builder
code owns a finite transformation allowlist. A new tracked file never ships
merely because it appears beneath a broad directory.

The output `DISTRIBUTION.yml` records:

- manifest/schema, RRP product, development software, distribution format,
  builder, target, and build identities/versions;
- exact source revision when available plus declared-input digests and dirty
  provenance, without making Git required for validation;
- R/platform/architecture facts and the target-keyed dependency resolution;
- internal package identities and versions;
- resource-catalog identity;
- a sorted exact inventory of every output other than the manifest itself,
  with normalized relative path, role, normalized mode, byte size, and SHA-256;
- the normalized-content identity derived from stable identity fields and the
  sorted payload records;
- build time as provenance excluded from normalized identity; and
- the bounded reproducibility claim and validation evidence.

The validator accepts only regular directories/files. It rejects absolute,
empty, dot, parent-traversing, backslash, non-UTF-8, duplicate, case-fold-
colliding, file/directory-conflicting, linked, socket/device/FIFO, missing, and
undeclared paths. File modes are normalized by role; no absolute source or
temporary path enters identity. The actual tree must equal the manifest's
fixed control-file set plus inventory exactly. Every SHA-256 and the recomputed
normalized-content identity must match. Authenticity/signing and an external
archive checksum remain Stage 10 concerns.

The builder uses an explicit destination, sibling staging directory, full
validation before promotion, and an ownership marker/manifest before replacing
an existing destination. It never overwrites an unrelated path. Failed builds
remove staging; failed replacement restores the prior validated owned output
or reports exact manual recovery. These patterns adapt the current artifact,
Hospital, and Git-realization safeguards without inheriting their payload or
Git assumptions.

#### Dependency and reproducibility boundaries

The first declared dependency target is `macos-arm64-r-4.4`, matching the
realized development evidence cell. Its build record captures the exact R
patch version and `aarch64-apple-darwin` platform used. This is an evidence
target, not yet a support claim. Ubuntu and other targets require their own
resolution and later acceptance; they are not inferred from hosted source CI.

Each target resolution is distinct from the root `renv.lock` and records exact
direct/transitive package names, versions, dependency roles, source repository
or immutable acquisition reference, available upstream checksum, license, and
R/platform compatibility. Package `DESCRIPTION` files remain direct dependency
authority; the target resolution must be their complete transitive closure and
may not add undeclared ambient packages. Root `renv` may supply the maintainer
build environment, but the builder validates rather than copies or prunes it.
Project extension dependencies remain Stage 4; Connect/deployment dependency
closure remains Stage 8.

Stage 2 claims normalized-content reproducibility only. Two builds in distinct
temporary roots under the same exact R/platform, builder, source-manifest,
declared source bytes, and dependency resolution must produce identical sorted
output paths, roles, normalized modes, package/resource bytes, SHA-256 values,
and normalized-content identity. Build timestamps, temporary roots, filesystem
directory metadata, and future archive/container metadata are excluded. No
byte-identical archive, cross-platform, offline acquisition, signature, or
reproducible external repository-state claim is made.

#### Explicit answers to the Stage 2 planning questions

| # | Decision from repository evidence |
|---:|---|
| 1 | Yes. `rrpruntime` is already focused; all other reusable implementation shares one RRP product lifecycle and fits `rrpplatform` without a third package |
| 2 | `rrpruntime` owns admitted-input, temporal eligibility/state, request/estimate, provider compatibility/execution, and storage-neutral history primitives; it owns no resource, repository, app, adapter, project, or lifecycle discovery |
| 3 | `rrpplatform` owns reusable conformance/resource, canonical/producer orchestration, supplied adapters, diagnostics, products/app, and target-neutral artifact implementation, but not CLI/project/release/target-specific lifecycle behavior |
| 4 | Pure reusable code now loose under `operations/lib`, `products/R`, `implementations/products/yaml/R`, `implementations/persistence/duckdb/R`, `app/R`, and target-neutral artifact code moves or is split into the main package |
| 5 | Repository validators/wrappers, Phase composition, synthetic source implementation as project-like code, Connect Git realization, Hospital machinery, and release/publication clients remain repository-owned until their assigned stages |
| 6 | The exact package sources, non-Hospital current contracts, supplied adapter declarations, app/artifact resources, inert fictional seed, narrow normative/product docs, and legal/support/security files ship |
| 7 | Tests/fixtures, assessments/records/roadmap, CI/validation machinery, root lock, repository configs, Git metadata, Hospital/release evidence, maintainer tooling, and generated state do not ship |
| 8 | An explicit distribution root opens a validated versioned catalog; logical resource IDs resolve beneath it through `rrpplatform`; no path search or working-directory inference is allowed |
| 9 | `distribution/software/source-manifest.yml` is the sole closed inclusion authority; finite code owns transformations |
| 10 | The exact inventory is every regular output other than `DISTRIBUTION.yml`, plus the fixed manifest itself, with path, role, normalized mode, size, and SHA-256 |
| 11 | Per-member SHA-256, normalized-content identity, manifest/package/dependency/resource identities, and validation evidence prove integrity; signing/authenticity wait for Stage 10 |
| 12 | Stage 2 supports identical normalized payload inventories, bytes, SHA-256 values, and content identity across two same-environment builds—not byte-identical archives or cross-platform equivalence |
| 13 | Package metadata declares direct installed roots; a target-keyed resolution declares exact transitive closure; root `renv` remains development-only and is neither copied nor pruned into product authority |
| 14 | The Stage 2 software target is represented now. Project extension and deployment/Connect target dependencies are classified but deferred to Stages 4 and 8 |
| 15 | One validated unpacked directory is sufficient; archive, installer, activation, and public acquisition forms are deferred |
| 16 | New package/resource/distribution code cannot derive a checkout root, source loose files, infer CWD, inspect Git for operation, or depend on sibling repositories |
| 17 | Existing repository wrappers, eager legacy validation, temporary runtime installation, root configs, and target/release operations may coexist outside the new distribution path under ledger controls |
| 18 | The product moves from `0.2.0-dev` to `1.0.0-dev` only in 2.F after the complete Stage 2 distribution gate passes; no release or `1.0.0` claim is made |
| 19 | Reuse closed source maps, tree scans, safe paths, atomic promotion/recovery, SHA-256, sorted inventories, build/content identity separation, and provenance patterns after removing owner-specific assumptions |
| 20 | Do not carry forward full-tree/ignore-subtraction payloads, MD5 as distribution integrity, generated Hospital/Git layout, root-lock pruning, clean-Git adopter rules, or repository/sibling discovery |
| 21 | Package build/check, catalog/resource tests, closed-input/output failures, dependency/license validation, outside-checkout self-validation, SHA-256/tamper checks, and two-build normalized equivalence prove Stage 2 without claiming installation |
| 22 | Stage 3 may assume exact package source, cataloged resources, a target-keyed closure, a self-validating closed directory, and explicit software context; it must add installation, activation, host-R binding, doctor, API operations, and launcher behavior |

#### Increment dependency graph

```text
2.A Package topology and source ownership
        ↓
2.B Installed-resource catalog and access boundary
        ↓
2.C Core implementation extraction and repository compatibility
        ↓
2.D Product, app, and artifact implementation ownership
        ↓
2.E Closed distribution, dependency, and integrity machinery
        ↓
2.F Stage 2 acceptance, identity transition, and closeout
```

Each increment establishes one reviewable architectural fact. Sequential work
keeps one package/resource authority and avoids simultaneous large moves through
the same namespace. No increment may remove the last working repository path
before its successor and compatibility evidence pass.

##### 2.A — Package topology and source ownership

###### Objective and order

Create the two real package source owners before moving reusable code or
building a distribution. Later resource and distribution code must have a
stable namespace and dependency direction.

###### Scope and ownership changes

- Relocate the unchanged `rrpruntime` package source to
  `packages/rrpruntime/` and update owned development/test references.
- Create `packages/rrpplatform/` with package metadata, namespace, base result
  primitives, and no public operation or project API.
- Declare `rrpplatform -> rrpruntime`; prohibit the reverse dependency.
- Establish package versions independently from RRP product identity;
  initially `rrpplatform@0.1.0.9000` and unchanged `rrpruntime@0.3.0`.
- Add package-owned base-R tests and non-Phase validation owners/triggers.
- Add one finite development-only package-source compatibility loader for
  repository operations/tests that cannot yet consume installed packages.

###### Reuse, coexistence, and non-scope

Reuse `rrpruntime` code and semantics without reformat-driven churn. Do not
change hazard, provider, history, public operation, app, or artifact behavior.
The compatibility loader may use explicit repository paths only on the legacy
source path; it is excluded from the distribution, linked to
`operation-library-chain`, and retires when Stage 3 and later component
successors no longer source package code.

###### Evidence and acceptance

Both packages parse, build, install into isolated temporary libraries, load in
dependency order, and pass `R CMD check --no-manual` with zero errors/warnings
and only an explicitly reviewed internal-package note allowlist. Static tests
reject `.GlobalEnv`, arbitrary source ordering, repository/sibling lookup, and
reverse/heavy dependencies in `rrpruntime`. Existing runtime/provider/history
tests pass unchanged. Missing package files and stale `runtime/` references
fail.

###### Recovery, ledger, documentation, and deferral

Perform the relocation in one bounded Git change so ordinary revert restores
the prior source location; never leave duplicate package authorities. Update
`runtime-package`, `operation-library-chain`, registry paths, package docs, and
the implementation record. Installed selection/activation, operation APIs,
CLI, project loading, and analytical changes remain Stages 3–5.

##### 2.B — Installed-resource catalog and access boundary

###### Objective and order

Define which non-code assets are RRP software and how owned code resolves them
before extracting code that reads contracts or app resources.

###### Scope and ownership changes

- Add the closed versioned resource catalog and catalog schema beneath
  `distribution/software/`.
- Classify every candidate resource using the ship/exclude table above and
  declare exact source-to-output mappings; do not use globs.
- Implement the explicit-root `rrpplatform` catalog/open/path API with safe-
  path, identity, duplicate, containment, symlink, and missing-resource checks.
- Add the minimal distribution-facing documentation and explicit
  `development_unpublished`/nonclinical/not-installed limitation text.
- Preserve current contract identities and label daily-hazard resources as
  transitional rather than relabeling them.

###### Reuse, coexistence, and non-scope

Reuse current contract, adapter, app, synthetic, normative, legal, security,
and support bytes where their role fits. Do not create a project manifest,
template, target contract, cumulative-risk resource, installer, or user CLI.
Repository operations may continue reading current source paths until 2.C/2.D
delegate through the new owner.

###### Evidence and acceptance

Catalog schema/conformance tests cover all declared fields, exact stable IDs,
uniqueness, safe normalized paths, source/output existence, classification,
and forbidden resource classes. After a package build/install in a temporary
library, resources resolve from an explicit copied distribution root while CWD,
Git availability, and source-checkout location vary. Missing, extra, linked,
escaping, duplicate, and identity-tampered catalog cases fail closed.

###### Recovery, ledger, documentation, and deferral

This increment is additive until the catalog passes; failed classification can
be reverted without moving source assets. Add an `installed-resource-
foundation` ledger item and validation owner. Stage 3 owns installed-root
selection; Stage 4 owns the real example project/template; Stages 5–8 replace
resource semantics and target resources.

##### 2.C — Core implementation extraction and repository compatibility

###### Objective and order

Move the reusable post-source implementation needed for a coherent software
payload behind `rrpplatform` after its resources can be resolved explicitly.

###### Scope and ownership changes

- Split pure conformance/specification, canonical admission, canonical-
  producer, runtime/provider composition, current history composition,
  DuckDB-adapter, and observability code from repository loading/validation.
- Move the pure implementation into cohesive `rrpplatform` files and declare
  the exact `yaml`, `DBI`, `duckdb`, and `rrpruntime` dependencies it uses.
- Replace internal repository-root contract reads with the 2.B catalog API.
- Keep synthetic source interpretation outside the package; it crosses only
  the existing producer/canonical boundary.
- Convert existing repository operations/tests to one finite compatibility
  loader or thin delegation while retaining their commands and behavior.

###### Reuse, coexistence, and non-scope

Reuse logic and tests at diff level; extract responsibilities rather than
rewrite algorithms. Do not implement installed operations, project context,
new provider selection, cumulative-risk semantics, new history records, or
state migration. No duplicate reusable implementation may remain in
`operations/lib` after its package-owned counterpart is accepted.

###### Evidence and acceptance

Package unit/conformance tests plus current canonical, producer, runtime,
provider, observability, and DuckDB/history evidence prove success/failure,
identity, temporal, atomicity, and privacy behavior is unchanged. Static checks
prove package code has no repository-root, synthetic-identity, source-system,
project, app, Git, release, or `.GlobalEnv` dependency. Legacy human operations
produce equivalent structured results through their bounded source bridge.

###### Recovery, ledger, documentation, and deferral

Move one responsibility cluster at a time within the increment and retain the
last passing commit as rollback. Update `operation-library-chain`,
`root-operation-scripts`, `provider-registry-execution`, `history-persistence`,
and `runtime-package` evidence without retiring them. Stages 3–6 own their final
operation, project, target, and history forms.

##### 2.D — Product, app, and artifact implementation ownership

###### Objective and order

Complete the main-package physical boundary for downstream product-only
capabilities before defining the distribution payload.

###### Scope and ownership changes

- Move logical product, YAML materialization/access, supplied Shiny app, and
  target-neutral application-artifact implementation into `rrpplatform`.
- Declare `digest` and `shiny` direct dependencies and use the resource catalog
  for product/app/artifact contracts and declarations.
- Preserve existing app/product separation and artifact output semantics; map
  package-owned source into the same legacy artifact members where required.
- Extract generic safe-path, tree inventory, SHA-256, staging, promotion, and
  recovery primitives without importing Connect, Hospital, Git, or publication
  identity.
- Keep Connect-specific realization code and dependency projection in its
  repository owner until Stage 8.

###### Reuse, coexistence, and non-scope

Reuse current builders, conformance, empty/failure behavior, product-only app,
closed artifact validation, and atomic replacement. MD5 remains only where
required by unchanged `v0.1.0` product/artifact contracts; the new software
distribution uses SHA-256. Do not change product grains/identities, UI meaning,
artifact profiles, Connect behavior, or deployment dependencies.

###### Evidence and acceptance

Package tests and current product/materialization/app/artifact suites pass with
no source/provider/history leakage. Static checks prove the main package does
not import `rsconnect`, Git, Hospital, or publication code. Legacy artifact
construction remains independently valid and byte/semantic inventory changes,
if any are rejected unless explicitly shown to be path-only and contract-
preserving.

###### Recovery, ledger, documentation, and deferral

Use the finite compatibility loader until Stage 7/8 successors pass; restore
the prior source mapping on failed equivalence. Update
`products-materializer-application`, `application-artifact-connect`,
`operation-library-chain`, and package ownership evidence without retiring the
current product, app, artifact, or Connect paths. Stages 7 and 8 own semantic
replacement and installed-input target realizations.

##### 2.E — Closed distribution, dependency, and integrity machinery

###### Objective and order

Build the first deliberate RRP software payload only after both package and
resource owners are real.

###### Scope and ownership changes

- Add the source manifest/schema, initial `macos-arm64-r-4.4` dependency-
  target declaration, finite builder, standalone self-validator, and build/
  validate maintainer operations.
- Build only the declared directory form with exact package/resource/docs/
  legal/control members and `DISTRIBUTION.yml`.
- Generate and verify target-keyed direct/transitive dependency and license
  evidence independently of root `renv`.
- Enforce closed inclusion/output, path/file/symlink safety, normalized modes,
  SHA-256, content/build identity separation, source/build provenance, atomic
  promotion, and safe owned replacement.
- Add one-build component evidence and the lifecycle two-build comparison.

###### Reuse, coexistence, and non-scope

Adapt existing source-map, scan, inventory, SHA-256, deterministic identity,
staging, safe-destination, and recovery patterns. Reject full-tree enumeration,
ignore subtraction, MD5 distribution integrity, root-lock projection, Git
payload identity, Hospital nesting, and publication behavior. Do not install,
activate, archive, sign, publish, deploy, or execute a project.

###### Human operations and evidence

Register and document these maintainer operations with explicit inputs,
outputs, side effects, recovery, and troubleshooting:

```sh
Rscript operations/build-software-distribution.R \
  --target macos-arm64-r-4.4 --destination PATH
Rscript operations/validate-software-distribution.R --distribution PATH
Rscript operations/validate.R --profile software-distribution-acceptance
```

Tests cover success; missing/duplicate/conflicting/undeclared input and output;
unsafe types/paths/links; corruption and manifest/dependency/license tampering;
unrelated destination refusal; failed promotion recovery; no repository/Git/
sibling lookup; one external copied-tree validation; and two independent
normalized-equivalent builds. No network or remote mutation is implicit.

###### Recovery, ledger, documentation, and deferral

Generated outputs remain ignored and disposable. A failed build never changes
the last validated owned destination. Add a `software-distribution-foundation`
ledger item and update `development-renv`; no release/publication or Hospital
row is retired. Stage 3 owns installation; Stage 8 owns deployment closure;
Stage 10 owns archive/signing/publication/acquisition.

##### 2.F — Stage 2 acceptance, identity transition, and closeout

###### Objective and order

Prove the complete distribution boundary, reconcile actual implementation, and
move executable product identity to the 1.0 development line only if every
Stage 2 gate passes.

###### Scope

- Run the concrete Stage 2 acceptance matrix below from the final source state.
- Audit package/resource/distribution inventory, dependency roles, validation
  ownership, transition links, docs, and complete Stage 2 diff.
- Perform two independent builds and outside-checkout validation on the one
  declared target without claiming end-user installation support.
- If all gates pass, change forward product development identity from
  `0.2.0-dev` to `1.0.0-dev`, rebuild/revalidate that exact identity, mark Stage
  2 complete, and record the realized Stage 3 inputs.
- If any gate fails, leave Stage 2 in progress and identity at `0.2.0-dev`.

###### Non-scope and coexistence

Do not install or activate software for a user, create a launcher/CLI or shared
operation API, initialize a project, change analytical/history/product/app
semantics, alter `v0.1.0`, publish, or retire legacy paths. Existing repository
operations may still use the recorded compatibility loader.

###### Evidence, recovery, ledger, and documentation

Run the accepted lifecycle profile once plus focused documentation, dependency,
package, resource, registry/ledger, R/YAML, hygiene, and `git diff --check`
evidence. Do not run Hospital/release/publication/acquisition workflows merely
for ceremony; immutable evidence is checked by diff/inventory. Revert only the
identity/status closeout if the final rebuild fails. Append a planned-versus-
actual reconciliation and update all affected ledger rows without claiming
retirement. Stage 3 detailed planning becomes next only after closeout passes.

#### Validation ownership and proportional execution

Stage 2 adds non-Phase validator ownership rather than extending chronology:

| Proposed validator/profile | Routing |
|---|---|
| `package.rrpruntime` | `active_scoped`; package paths trigger it; included in `ci-active` |
| `package.rrpplatform` | `active_scoped`; main-package paths trigger it; included in `ci-active` |
| `repository.software-resources` | `active_scoped`; source manifest/catalog/shipped-resource paths trigger it; included in `ci-active` |
| `repository.software-distribution` | `active_scoped`; builder/manifest/dependency-target paths trigger a bounded one-build proof; included in `ci-active` |
| `lifecycle.software-distribution-acceptance` | lifecycle-only two-build/outside-checkout evidence; excluded from ordinary `source-changed` and `ci-active` |
| `software-distribution-acceptance` | explicit profile composing package/resource/distribution prerequisites and the lifecycle validator |

Existing component validators remain until package-owned successors prove the
same invariants and registry/ledger/test routing are updated together.
`source-changed` selects affected package/resource/distribution checks and
prerequisites. `source-fast` stays bounded. `ci-active` gains current package,
resource, and one-build distribution coherence but not the expensive two-build
lifecycle proof. Exact legacy aggregates remain frozen and do not gain Stage 2
members.

#### Concrete Stage 2 acceptance gate

Stage 2 closes only when every row passes:

| Gate | Required evidence |
|---|---|
| Package topology | Exactly `rrpruntime` and `rrpplatform` are internal packages; both parse/build/load/check; dependency direction and version identities are valid |
| Physical ownership | Reusable shipped R code has one package owner; no distributed code uses `.GlobalEnv`, arbitrary source order, checkout discovery, or loose repository sourcing |
| Resource ownership | Every shipped non-code asset has one catalog ID/role/owner and resolves from an explicit copied distribution context through the package API |
| Shippable classification | Declared package/resource/docs/legal content is complete; tests, fixtures, assessments, records, CI, root lock/config, Hospital, release evidence, and maintainer tooling are absent |
| Closed inputs and outputs | Missing/duplicate/conflicting/unsafe inputs fail; actual output equals the fixed control set plus manifest inventory; undeclared output fails |
| Integrity and tamper resistance | All member SHA-256 values, sizes, roles, package/resource/dependency references, and normalized-content identity verify; corruption fails distinctly |
| Dependency and license closure | Package direct dependencies equal a complete exact target resolution with source/checksum/license evidence; root development, project, build, and deployment roles remain distinct |
| Repository independence | A copied distribution validates in a separate process/directory with different CWD, no Git requirement, no source/sibling lookup, and no ambient undeclared package use |
| Reproducibility | Two distinct builds under the same exact declared environment have identical normalized paths, roles, modes, bytes, SHA-256 values, and normalized-content identity; no archive-byte claim is made |
| Compatibility and non-change | Current canonical/provider/runtime/history/product/app/artifact and privacy behavior remains semantically unchanged; daily hazard remains explicitly transitional; legacy operations remain callable |
| Lifecycle separation | Build/validate performs no installation, project mutation, deployment, release, publication, acquisition, credential, network, tag, commit, push, or remote action |
| Governance and hygiene | New validators/triggers/prerequisites/ledger links are complete; docs and operations agree; R/YAML/package metadata parse; secrets/PHI, generated files, stale paths, and `git diff --check` pass |
| Identity and handoff | Only after all prior rows pass does the exact rebuilt distribution declare `1.0.0-dev`; Stage 2 reconciliation records limitations and factual Stage 3 assumptions |

Package build/check and bounded distribution coherence run in current validation
as owned. The final two-build acceptance runs once at 2.F and later at release
boundaries, not after every local edit. Passing this gate means the software
payload is defined; it does not mean a supported installation exists.

#### Transition-ledger expectations

| Existing/new item | Expected Stage 2 effect |
|---|---|
| `runtime-package` | Update physical/package/dependency evidence; keep Stage 5 semantic replacement open |
| `root-operation-scripts` | Partially delegate through package-owned code; remain until installed operation successors pass |
| `operation-library-chain` | Remove reusable implementation from the eager chain; retain a finite source compatibility bridge with Stage 3–8 retirement conditions |
| `provider-registry-execution` | Gain a package owner without changing project/target semantics; Stages 4–5 remain replacement owners |
| `history-persistence` | Gain a package owner/default-adapter dependency declaration; Stage 6 semantics/state remain open |
| `products-materializer-application` | Gain package/resource owners; Stage 7 semantics remain open |
| `application-artifact-connect` | Package-own target-neutral primitives; Connect remains repository-owned until Stage 8 |
| `development-renv` | Root lock remains development-only; Stage 2 adds an independent target-keyed software closure and satisfies that separation evidence without retiring the root environment |
| `hospital-distribution-git` | Unchanged historical/retire-later path; excluded from the new payload |
| `release-publication-tooling` | Unchanged explicit `v0.1.0` lifecycle; excluded from the new payload until Stage 10 replacement |
| `installed-resource-foundation` | New active catalog/access boundary; later stages revise content through the same owner |
| `software-distribution-foundation` | New active closed-inclusion/inventory/integrity boundary; Stage 3 consumes it and Stage 10 qualifies/releases it |

Copying or moving code does not by itself retire an old row. Retirement occurs
only when the row's accepted successor condition passes.

#### Stage 2 exit and Stage 3 handoff

The accepted Stage 2 exit will provide:

- two buildable/checkable internal package source trees with one-way
  `rrpplatform -> rrpruntime` dependency;
- one explicit catalog of installed resources and an explicit-context resource
  API with no checkout-root assumptions;
- one closed, self-identifying unpacked software distribution built only from
  declared inputs;
- exact output inventory, SHA-256, target-keyed dependency/license evidence,
  source/build provenance, and a truthful normalized-content claim;
- independent copied-tree validation and two-build equivalence on one evidence
  target;
- `1.0.0-dev` product identity only after complete acceptance; and
- retained, classified legacy repository operations for comparison and
  continuity.

Stage 3 may assume those facts. It must still design and implement user-scoped
side-by-side installation, exact host-R selection, private-library population,
installed manifest verification, activation/rollback/uninstall, installation
doctor, stable shared operation results, and the thin launcher. Stage 2 neither
details nor implements them.

#### Explicit Stage 2 deferrals and planning quality result

Deferred: package binary acquisition/vendoring; archive/compression/signing;
installer and activation paths; public CLI syntax; project manifest/template/
registration/dependencies; cumulative-risk contracts; 1.0 history/products/UI;
Connect/OCI realization; multi-platform support claims; public release and
acquisition; and general analytical-framework extraction.

The plan passes the fresh-design, reuse, legacy-path, scope, stage-boundary,
recognizability, and generality tests. It leads to conventional package source
plus a declared distribution; reuses proven behavior and safety patterns;
keeps temporary compatibility outside the payload; assigns every increment to
the distribution boundary; leaves Stage 3+ responsibilities explicit; and
keeps generic build/resource/integrity code free of unnecessary readmission
semantics without creating a separate generic platform.

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

## Next review and implementation step

The proposed detailed Stage 2 plan is ready for maintainer review. The next
step is:

> **Review and accept or revise the detailed RRP 1.0.0 Stage 2 plan.**

Only after acceptance may implementation begin with **Increment 2.A — Package
topology and source ownership**. Do not begin 2.B or later increments with 2.A,
and do not detail Stage 3 until Stage 2 has been implemented, validated, and
reconciled.

Stage 1 changes only development control. It must not collapse software
upgrade, project migration, state migration, deployment, or publication, or
leak into the Stage 2 product/distribution foundation.
