# Platform architecture

## Status and authority

**Status:** authoritative clean target architecture

This document translates [Platform True North](../vision/platform-true-north.md)
into the target structure of this repository. It describes logical ownership
and dependency direction, not current implementation maturity or a commitment
to any storage technology.

The target was designed before reconciling old code. The sibling
`readmission-risk-pool` repository is development-time reference evidence only.
It is not imported, sourced, symlinked, required by tests, or assumed to exist
on an adopter's machine. Any later reused asset must be brought into this
repository deliberately, adapted as required, and owned here.

## Architectural overview

```text
Organization-specific sources
        ↓
Reference / implementation source layer
        ↓
Canonical implementation boundary
        ↓
Generic runtime and computational layer
        ↓                 ↘
Operational state          Estimand + selected provider
        ↓                 ↙
Append-oriented derived operational history
        ↓
Logical application products
        ↓
Application interfaces

Operations, observability, configuration, storage ports, and deployment
cross these layers only through declared interfaces.
```

The architecture has two complementary dimensions:

- **semantic flow** from local source interpretation to user-facing products;
- **control flow** through tested operations that select, validate, run,
  persist, build, and deploy that semantic flow.

## Authority and ownership

```text
Platform True North
        ↓
Platform Architecture
        ↓
Platform Implementation Plan
        ↓
Platform Implementation Record
        ↓
Software and tests

Sibling reference repository
        ↓
Evidence and candidate assets only
```

Contracts and tests may become executable authorities for implemented
behavior, but they remain subordinate to accepted architecture. When code and
architecture disagree, the discrepancy is recorded and resolved explicitly;
the code does not silently redefine the target.

## Core identities shared across layers

The following logical identities should be established early because several
layers depend on them. Their concrete encodings remain contract decisions.

- platform and contract release;
- health-system deployment identity;
- implementation and mapping identity/version;
- canonical bundle identity and as-of context;
- declared implementation capabilities;
- operational run identity and operation identity;
- episode and relevant source lineage identities;
- state schema/version and state record identity;
- estimand identity/version;
- provider and model identity/version;
- population, decision-policy, measure, and product versions;
- derived-record identity, correction/restatement status, and provenance; and
- product set, deployment artifact, and deployment realization identity.

Identity must not assume Git commits, local file paths, or one programming
language, though reference implementations may record those as additional
provenance.

## Reference / implementation source layer

### Responsibility

This layer turns organization-specific source meaning into canonical meaning.
It owns extraction, local joins, identifier construction, code/status
translation, timestamp normalization, source validation, baseline-score
adaptation, and mapping provenance.

Examples include the synthetic health system, hospital SQL, warehouse views,
dbt models, R or Python extraction, or governed service adapters.

### Boundary

An implementation produces a candidate canonical bundle plus an
implementation conformance report. It may expose component-level validation
while being developed, but generic execution begins only after the active
bundle satisfies its declared cross-domain and capability requirements.

### Constraints

- Source names, vendor concepts, credentials, and connection details do not
  cross into generic runtime logic.
- The synthetic reference uses the same producer and conformance interfaces as
  every other implementation.
- A source implementation cannot build application products directly.
- Local source validation and canonical conformance are distinct results.
- The layer may depend on public contracts and implementation tooling; it may
  not depend on products, the application, or deployment targets.

## Canonical implementation boundary

### Responsibility

This is the public source-to-platform handoff. It is a logical specification,
not a mandated container format.

A conforming handoff conceptually carries:

- one bundle identity and declared as-of context;
- versioned canonical domain instances;
- implementation and mapping identity/version;
- declared available, unavailable, and unsupported capabilities;
- contract versions and compatibility information;
- source-to-canonical lineage sufficient for attribution;
- a structured conformance result; and
- safe failure detail for invalid or incomplete input.

### Canonical domains

The first supported profile selects a required discharge episode root plus
optional immutable baseline risk and optional longitudinal episode events.
Workflow tasks, interventions, measure membership, and optional model features
remain deferred until their owning phases provide concrete need. Derived state
and estimates are outputs, not input domains.

Durable semantics include stable episode identity, child-to-episode
relationships, observation and terminal times, controlled vocabularies, and
the distinction between event occurrence and information availability.

### Representation independence

The same logical boundary may be realized as in-memory R objects, files with a
manifest, database tables, warehouse relations, or a service response. Adapters
translate representation into the logical interface. Generic behavior must not
branch on the representation.

## Generic runtime / computational layer

### Responsibility grouping

The runtime is a reusable, implementation-neutral computational library with
small cohesive APIs. It should initially group behavior that shares canonical
semantics and needs strong unit testing:

- contract and canonical-bundle validation;
- eligibility and temporal availability filtering;
- reproducible episode-state construction;
- estimand request and provider invocation contracts;
- standardized derived-record validation;
- stable decision/priority primitives when policy boundaries are defined; and
- lineage and record-identity primitives.

These functions may share types and run context but must not become one large
pipeline function. Orchestration belongs to operations; application product
construction belongs to the product layer; implementation-specific providers
belong behind provider interfaces.

### Temporal behavior

Every calculation is made for a declared as-of time. Event time describes when
something occurred; recorded or available time describes when the platform
could know it. No event, baseline, feature, task, intervention, membership, or
outcome may influence a run before its declared availability.

Eligibility and each estimand own their terminal semantics. Generic code must
not infer truth from a source status field when timestamp-based rules are the
governed basis.

### Decision separation

Estimates describe a quantity. Decision or priority policies determine how
information is used operationally. They have separate IDs, versions, inputs,
outputs, tests, and provenance. A high risk estimate does not intrinsically
mean high work priority, and a task is not evidence that an intervention
occurred.

## Estimand and model-provider layer

### Estimand registry

An estimand specification is a versioned public contract defining:

- quantity and output domain;
- eligible population and time origin;
- conditioning state and required information;
- horizon and interval boundaries;
- event, terminal, death, and competing-event semantics;
- output dimensions and missing/unsupported states;
- universal and estimand-specific coherence requirements; and
- controlled conformance scenarios.

### Provider specification

A provider declares:

- provider and implementation version;
- supported estimand versions, populations, and horizons;
- required canonical capabilities, domains, state fields, and runtime needs;
- uncertainty and explanation capabilities;
- deterministic/reproducibility behavior;
- safe missing-input, unsupported, and execution-failure behavior; and
- provider-specific conformance cases and limitations.

### Registration and selection

Providers enter a controlled registry through an explicit trust boundary.
Configuration selects only registered providers compatible with the active
estimand and implementation capabilities. Selection never consists of sourcing
an arbitrary path from ordinary data configuration. The exact shipped/local
registration policy is an open decision for the provider phase.

### Execution and conformance

Provider execution receives an estimand request and only the declared,
as-of-valid input view. The platform validates output identity, cardinality,
finite bounds, horizon alignment, temporal validity, terminal behavior, and
estimand-specific coherence before results reach persistence or products.

Software conformance is not clinical validation. Provider records and user
interfaces must preserve that distinction.

### Defaults and extensions

The reference provider should be transparent, reproducible, nonclinical, and
valid for its estimand. It is not the architecture. Advanced methods remain
optional provider packages, companion projects, local implementations, or
research unless a core use case justifies inclusion.

## Operational-history / persistence layer

### Five different record classes

| Class | Authority and purpose | Typical behavior |
|---|---|---|
| Source data | Hospital or synthetic implementation | Remains outside platform history authority |
| Canonical inputs | Validated input used by a run | May be referenced or retained according to policy |
| Operational state | Reproducible state used for computation | Versioned and attributable to run/as-of |
| Derived historical records | Estimates, retained decisions, lineage, and run facts | Append-oriented operational truth |
| Application products | Curated consumer interfaces | Rebuildable/materializable views, not history authority |

### Persistence ports

The platform defines logical append/read/query and correction/restatement
behavior for record classes without selecting a production backend. Storage
adapters own serialization, transactions, indexes, connection handling, and
backend-specific optimization.

The reference adapter may be lightweight and local while exercising the same
contract suite expected of another adapter. Production choices remain adopter
owned.

The current reference is `reference.duckdb-persistence@0.1.0`, documented in
[DuckDB Reference Persistence](duckdb-reference-persistence.md). It uses one
controlled writer process, explicit sessions, and a versioned physical schema.
This realization does not add DuckDB concepts to the port or make its
concurrency limits universal.

### Operational semantics

- Run identity and idempotency keys distinguish a retry from a new run.
- Append is the default for a new as-of time or implementation state.
- Corrections, invalidations, and restatements are explicit records or governed
  state changes; they never silently rewrite operational truth.
- Provider A history remains when provider B becomes active.
- A prospective first run is valid with no platform-created prior history.
- Rebuilding products does not alter authoritative historical records.
- Persistence does not imply retention of every raw input or creation of a
  universal feature store.

## Product layer

### Responsibility

Products are versioned logical views built from canonical current data and
derived history. Likely product families include:

- active/current episode views;
- estimate and trajectory views;
- care-management queues and workflow views;
- executive and operational summaries;
- measure membership and lineage views; and
- capability, freshness, validation, or explanatory views.

The exact default suite is an open decision. Each product contract declares
logical identity, keys, schema/version, required upstream capabilities,
freshness/as-of meaning, lineage, compatibility, and partial/unavailable
behavior.

Iteration 6.1 resolves the first deliberately narrow suite through
[`platform.initial-risk-product-set@0.1.0`](../../contracts/products/initial-risk-product-set.yml):
current valid episode/estimand risk, persisted accepted-estimate history, and
valid terminal operational-run summaries. The exact grains, coherent-set
identity, freshness, compatibility, failure behavior, builders, conformance,
and in-memory access seam are authoritative in
[Logical Product Foundation](logical-product-foundation.md). Iteration 6.2
realizes the seam with a replaceable
[YAML reference materialization](reference-product-materialization.md) and the
[minimal product-only Shiny application](reference-application.md).

### Storage independence

Product readers and writers interact with logical products, not CSV-specific
or database-specific behavior. A local file adapter may materialize products
for the reference application. A database or service adapter can replace it
without changing product builders or application modules.

### Constraints

- Products do not become the only copy of operational history.
- Product structure is not dictated by synthetic source configuration.
- Missing capability is explicit, not represented by fabricated zeroes.
- Presentation convenience fields must not silently become canonical facts.
- Product version changes include compatibility and migration consequences.

## Application layer

The supplied Shiny application consumes product contracts through a product
access service. Its initial reference renders current risk, actual retained
risk history, run status, and freshness only; later apps may add separately
contracted products.

It is insulated from:

- source-system queries and local mapping;
- canonical representation mechanics;
- provider implementation and model internals;
- persistence and product storage backend details; and
- hosting-specific packaging.

Application authorization and protected-data behavior are deployment concerns
that must be made explicit before real-data use. The fictional reference may
remain intentionally simple while never implying production readiness.

## Operations layer

Operations are the tested control surface over architectural components. An
operation declares inputs, outputs, side effects, validation performed,
diagnostics, failure/recovery behavior, and whether it is read-only or
mutating.

The expected operation families are:

- initialize and doctor;
- validate contracts, implementations, providers, products, and deployments;
- generate the synthetic reference implementation;
- build and run a declared configuration;
- select an implementation or provider;
- build/materialize products;
- launch an application;
- build and validate a local deployment realization;
- upgrade or migrate compatible state.

Names are provisional until implemented. Human commands, schedulers, agents,
and any optional client invoke the same operation implementation. Operations
may orchestrate all layers but do not absorb their domain logic.

Phase 7 stabilizes the local reference operator surface as initialize, doctor,
validate, one platform run, history inspection, product materialization, app
validation, and app launch. A lightweight registry records their IDs, commands,
mutation levels, classifications, and human guides; it is not an execution
router. The platform run creates operational history, product refresh projects
retained history, and app launch consumes the current product set. Scheduling
is external: the platform owns run behavior and the operator owns cadence.

## Deployment layer

Phase 8 makes deployment a two-boundary transformation. The first is a
target-neutral reduced application artifact containing only the product-only
app, read-only product access/validation, required contracts/declarations, and
one coherent materialized product set. The second, target-owned, turns that
validated artifact into a Connect Cloud, container, or other realization.

A deployment target implements a build contract:

```text
validated app + coherent products + runtime dependency declaration
        ↓
target-neutral closed application artifact
        ↓
target builder
        ↓
allowlisted artifact + provenance + target validation
        ↓
local target-specific realization
        ↓
operator-controlled publication/deployment
```

Artifact realization and external publication are separate responsibilities.
The platform stops after an independently valid local deployable output.
Generated realizations have explicit ownership; external Git commits, remotes,
pushes, service credentials, and deployment remain operator controlled.

Iteration 8.2 realizes Connect Cloud as a generated, remote-free local Git
repository with staged but uncommitted files. Connect remains a reference
target, not a condition in the application or runtime. A second target should
be added as a peer adapter only when concrete requirements exist.

## Observability layer

Observability is cross-cutting but accessed through a stable, small interface.
A versioned operation-run context propagates one operation-attempt identity;
it remains distinct from analytical runtime-run identity. Versioned structured
events carry explicit-offset timestamp, operation correlation, controlled
stage/component, severity, lifecycle, relevant non-patient identities,
duration, safe code, and actionable message.

The operations layer owns a base-R emitter and callable sink boundary. The
reference console sink retains nothing and supports normal, quiet, and debug
rendering while never hiding terminal errors. Deployments own any later
routing, retention, and approved sinks. No default event contains PHI,
patient-level clinical values or identities, secrets, connection strings, raw
records, SQL, paths, or arbitrary nested payloads. Diagnostics remain
distinct from provenance, validation reports, operational metrics, and audit
records even when a run ID links them.

The concrete contract, privacy allowlist/rejection rules, lifecycle, and
implemented operation scope are defined in
[Observability Foundation](observability-foundation.md).

```text
                         observability port
                        ↗    ↑    ↑    ↖
source → canonical → runtime → history → products → app/deployment
```

Safe stage events point outward to the port. No stage reads diagnostics as an
input, so this cross-cutting capability does not change the dependency spine.

## Configuration architecture

Configuration selects declared implementations, estimands, providers,
policies, products, storage adapters, and deployment profiles. It does not
contain executable arbitrary code or redefine contract meaning.

Configuration is versioned, validated before use, scoped by owner, and
separates platform defaults, reference-instance values, adopter-local values,
and secrets. Secrets and environment-owned connection details never belong in
committed general configuration.

## Dependency direction

The primary dependency spine is:

```text
local implementation
        ↓
public canonical contracts and boundary
        ↓
generic computation
        ↓
operational history ports
        ↓
logical products
        ↓
application
```

Orthogonal dependencies point inward toward interfaces:

```text
provider implementation  → provider + estimand contracts ← generic runtime
storage adapter          → persistence/product ports      ← runtime/products
operation interface      → callable component APIs
deployment target        → application/runtime artifact contracts
observability adapter    → diagnostic interface           ← all operations
```

### Prohibited dependencies

- Generic runtime must not import synthetic or hospital implementation code.
- Runtime must not depend on app modules, deployment targets, Git, or hosting.
- Source implementations must not determine generic product structure.
- Source implementations must not bypass the canonical boundary to write
  products.
- Providers must not depend on application modules or storage internals.
- Provider selection must not be an arbitrary source-file path from ordinary
  configuration.
- Product builders must not query hospital source systems or provider internals.
- The app must not query source systems, invoke models, or understand database
  schemas used behind product ports.
- Application products must not be treated as authoritative historical storage.
- Storage adapters must not change canonical, estimand, or product semantics.
- Deployment targets must not change canonical or product semantics.
- Connect-specific files must not appear in the platform or application core.
- Observability must not become provenance, validation, metrics, or audit by
  implication.
- AI agents and future clients must not contain unique platform logic.
- Advanced methodology must not become a mandatory runtime dependency.
- Generic code must not branch on named hospitals or synthetic identity.
- No runtime, test, or deployment may depend on the sibling reference
  repository.

## Proposed repository structure

Only `docs/` is populated during bootstrap. The following is the intended
top-level layout, to be created just in time by implementation phases.

| Directory | Responsibility and contents | Must not contain | Role and dependencies |
|---|---|---|---|
| `contracts/` | Language-neutral schemas/specifications for canonical bundles, estimands, providers, derived records, products, diagnostics, and compatibility | Executable source mappings, app views, backend logic | Public; depended on by every conforming implementation |
| `implementations/` | Source-owned producers/mappings and concrete reference adapters; includes synthetic source and DuckDB persistence realizations | Generic runtime, provider registry internals, app products | Public reference/example plus adopter-owned implementations; depends on contracts, logical ports, and implementation tooling |
| `runtime/` | Internal R package for stable implementation-neutral computation and logical ports | Orchestration, source extraction, app rendering, deployment, Git/publication | Internal platform component with public-ish APIs; depends on contracts and minimal R libraries |
| `products/` | Product specifications, builders, suite composition, and product storage ports/adapters | Historical authority, source queries, UI rendering | Public logical interface; depends on contracts, runtime records, and persistence reads |
| `app/` | Supplied Shiny application and product-access boundary | Source mappings, provider code, persistence backend queries, hosting adapters | Replaceable public reference app; depends only on product interfaces and app configuration |
| `operations/` | Callable operation implementations, human entry points, operation registry, and recovery contracts | Unique domain algorithms or hidden agent procedures | Public control surface; orchestrates components through their APIs |
| `deploy/` | Target adapters, declarations, and standalone validation payloads used by deployment builders | Canonical or model semantics, authoritative app source, external publication credentials | Public reference targets; depends on stable artifact/operation interfaces |
| `config/` | Versioned platform defaults, reference selections, examples, and configuration schemas where not contract-owned | Secrets, executable code, private hospital values | Public/default and local override boundary; interpreted by operations/components |
| `tests/` | Cross-component, conformance, fixture, architecture, and end-to-end tests | Production runtime data or private source material | Public evidence; depends on public interfaces and explicit fixtures |
| `docs/` | Vision, architecture, implementation record, developer, adoption, operations, and user documentation | Undocumented executable procedures | Public human authority; describes all supported interfaces |

Generated builds, local data, operational stores, caches, and secrets are not
architectural source directories. Their eventual locations must be ignored,
configurable, and governed by operations rather than becoming repository APIs.

## Role of R and the internal package

The platform is not an R package. R is expected to be the first implementation
language because Shiny and much accumulated platform knowledge are R-based.

A focused internal package under `runtime/` is useful because it provides a
namespace, dependency declarations, unit tests, installation/versioning, and a
clear reusable API boundary. Its intended responsibilities are:

- contract and canonical-bundle validation;
- temporal eligibility and availability rules;
- state construction primitives;
- estimand/provider request and result contracts;
- provider conformance utilities;
- derived-record identities and validation; and
- persistence/product port definitions only where they are computationally
  reusable.

It does not own project orchestration, reference-source generation, local
mapping, provider implementation packages, product materialization workflows,
app rendering, deployment publication, Git operations, or target-specific
files.

No package scaffold is created during bootstrap. Package name, dependency
budget, and exact exported API follow the contracts phase. Conceptual contracts
remain language- and storage-neutral so future Python, service, database, or
command-line adapters can be considered without rewriting platform meaning.

## Architecture conformance

Every implementation phase should add evidence proportional to the boundary it
introduces: schema examples, unit tests, conformance fixtures, integration
tests, end-to-end reference checks, documentation, and an implementation-record
entry. Exact repository-tree assertions must identify whether they protect a
platform contract, a reference profile, or a deployment target.

Architecture changes require an explicit update here and in the implementation
plan before code establishes a conflicting dependency.
