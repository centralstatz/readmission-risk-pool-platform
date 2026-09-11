# RRP 1.0.0 implementation plan

## Status and authority

**Status:** authoritative high-level implementation roadmap for the RRP 1.0.0
target generation; implementation has not begun

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

The next task is:

> **Detailed implementation planning for RRP 1.0.0 Stage 1.**

Expand this document with the bounded Stage 1 increments while preserving the
stable roadmap. Each increment should name prerequisites, boundary changes,
compatibility/state effects, old-path transition, human operation,
documentation, focused and downstream evidence, recovery, and completion
state. Do not detail Stage 2 until Stage 1 has been implemented, validated, and
reconciled. Use a separate detailed plan only if expansion would materially
reduce clarity.

That next pass must settle only the bounded implementation choices needed for
Stage 1. It must not collapse software upgrade, project migration, state
migration, deployment, or publication, and Stage 1 source work must not begin
before its detailed sequence is accepted.
