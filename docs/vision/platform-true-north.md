# Readmission Risk Pool Platform True North

## Status and authority

This document is the authoritative statement of the intended identity and
long-term direction of the Readmission Risk Pool Platform. It governs the
[platform architecture](../architecture/platform-architecture.md), which
will govern the replacement
[implementation plan](../architecture/platform-implementation-plan.md); the
linked plan currently records completed `v0.1.0` history. The
[implementation record](../architecture/platform-implementation-record.md)
records what is actually built. Forward software must conform to the complete
chain once the RRP 1.0.0 plan is accepted.

```text
Platform True North
        ↓
Clean target architecture
        ↓
Clean implementation plan
        ↓
Implementation record
        ↓
Software
```

The sibling `readmission-risk-pool` repository is outside this authority
chain. It is development-time reference evidence and a source of assets that
may be deliberately reused, adapted, consulted, or rejected. It does not
define this repository's architecture.

Use these labels when discussing maturity:

- **Design principle** — a durable rule for evaluating work.
- **Target state** — an intended capability or boundary.
- **Current state** — what this repository demonstrably supports now.
- **Open decision** — a choice requiring maintainer input when it becomes
  material.

The published `v0.1.0` release is immutable historical evidence. Current
development targets the RRP 1.0.0 architecture; target statements are not
claims that 1.0.0 is implemented, released, or clinically validated.

## Platform identity and purpose

**Target state:** Readmission Risk Pool is an open-source implementation
platform for hospital readmission management. It connects discharge episodes,
time-varying post-discharge evidence, risk estimates, operational priorities,
care-management work, outcomes, and measure lineage through replaceable,
governed interfaces.

The primary analytical unit is a discharge episode. A patient may contribute
multiple episodes over time. Risk, priority, tasks, interventions, and measure
membership are distinct concepts and must remain distinguishable.

The platform is not merely an application, model, dashboard, R package,
pipeline, or consulting deliverable. It includes:

- public canonical and extension contracts;
- implementation-owned source interpretation;
- generic computation after the canonical boundary;
- one governed readmission-risk target and replaceable model providers;
- append-oriented operational history;
- curated logical application products;
- a working supplied application;
- portable deployment builds;
- versioning, provenance, validation, observability, and operations;
- complete human documentation; and
- a synthetic reference implementation.

The platform must remain independently useful. CentralStatz may visibly
steward and support it and may offer optional professional services, but no
CentralStatz service, proprietary agent, private model, or hidden component may
be required to operate the open core.

One deployed platform instance represents one health system. Reusable source
may be deployed repeatedly, but multi-hospital SaaS tenancy is not the core
architecture.

The platform is not, by itself, clinical validation, production approval, or a
regulated clinical decision-support product. Adopters retain responsibility
for authorization, privacy, security, model governance, clinical validation,
monitoring, incident response, and operational adoption.

## Progressive implementation

**Design principle:** The platform should work early and remain working while
complete components are replaced or customized.

```text
Install RRP software
        ↓
Initialize an independent fictional project
        ↓
Run transparent default provider
        ↓
Build logical products
        ↓
Launch supplied application
        ↓
Build a reference deployment
        ↓
Replace project source mapping or provider deliberately
```

Replacement order is not fixed. The durable expectations are:

- deployment can change without changing canonical or target semantics;
- source implementation can change without changing the selected provider;
- providers can change without rewriting application code;
- applications can change without redefining canonical contracts;
- storage can change without changing logical records or products; and
- a replacement is admitted through conformance, not named conditionals in
  generic code.

Simple, valid realizations should be implemented behind intended interfaces
before more sophisticated realizations. Early local files, an in-process R
runtime, and a transparent default provider are acceptable. A shortcut that
crosses a target boundary is not.

Progressive replacement is about conforming components, not silent mixtures.
Incremental construction and validation of a local implementation are useful,
but an active end-to-end implementation must declare and satisfy coherent
identity, referential, temporal, and capability requirements. Whether partial
synthetic/local domain composition is ever supported remains an evidence-led
decision.

## Incremental adoption

**Design principle:** Individual exploration, a working prototype, a focused
pilot, and broader governed adoption are stages of one platform, not different
products requiring different architecture.

A technically capable analyst or developer should be able to install RRP,
initialize and run the fictional project, understand the boundaries, create a
separate local project, map approved local data, test a conforming provider,
build products, and demonstrate a prototype without first buying services or
installing enterprise infrastructure.

Low-friction exploration does not remove governance. Work with real data must
use approved environments and controls. Successful execution does not imply
clinical validity or authorization for operational use. Later adoption stages
add security, validation, monitoring, approval, and operational governance
without replacing the technical foundation.

## Synthetic reference implementation

**Target state:** The synthetic health system is the primary reference
implementation, not superficial sample data or a privileged generic-code
mode.

```text
Synthetic source system
        ↓
Synthetic source-to-canonical mapping
        ↓
Canonical conformance
        ↓
Generic runtime and default provider
        ↓
Operational history and logical products
        ↓
Working application and reference deployment
```

It should be deterministic from declared inputs, visibly fictional and
nonclinical, rich enough to demonstrate longitudinal and operational
relationships, and subject to the same public contracts as local
implementations. Generic code must not branch on a synthetic implementation
identifier.

The source may be idealized. Its purpose is to teach the implementation
boundary and prove the platform; it is not intended to reproduce the
irregularity of a commercial EHR.

## Canonical source boundary

**Design principle:** Local implementations own source-system interpretation.
Generic platform behavior begins only after a validated canonical handoff.

```text
Synthetic source, hospital SQL, warehouse views, dbt, ETL, or other local work
        ↓
Implementation-owned interpretation and mapping
        ↓
Versioned canonical implementation boundary
----------------------------------------------------------
Generic platform runtime begins
```

The boundary defines logical domains, bundle identity, as-of context,
capability declarations, mapping and implementation provenance, compatibility,
and conformance. It must not require that the handoff be an R list, a directory
of files, or database tables. A concrete adapter may use any of those
representations without redefining semantics.

The platform must expose invalid, incomplete, unavailable, or unsupported
behavior explicitly rather than fabricate values or compensate silently.
Temporal availability—including event time versus recorded time—must be
enforceable.

## Generic runtime and computational responsibilities

After conformance, the generic runtime owns implementation-neutral behavior,
including target eligibility, temporal filtering, reproducible state
construction, the standard remaining-risk request, provider invocation,
lineage, and construction of derived records. Any later decision and priority
logic remains a separate policy layer.

These responsibilities share identifiers and run context but remain separable:

- eligibility is not state construction;
- estimation is not decision policy;
- risk is not operational priority;
- a task records work to do, while an intervention records care delivered;
- measure lineage is not the organizing data model; and
- derived operational records are not application views.

## Platform-defined risk target and governed model providers

**Target state:** Model providers are first-class extensions governed by the
meaning of the quantities they estimate. Technical executability alone is not
sufficient.

```text
Canonical data and temporally valid state
        ↓
Versioned RRP risk-target specification and standard request
        ↓
Selected provider specification and declared capabilities
        ↓
Target + provider conformance
        ↓
Standardized derived estimate records
```

RRP owns one nonselectable target for the 1.0.0 generation: remaining
actual-world cumulative probability of first canonical readmission through the
fixed endpoint 30 elapsed days after discharge, conditional on being alive and
readmission-free at the current as-of time and using only admitted information
available through that time. Death before readmission competes. Daily hazard is
not a public target.

Providers own method: required admitted inputs and state fields, target/API
compatibility, configuration/loading, dependencies, fitted model artifacts,
optional uncertainty/explanation capabilities, and limitations/failure
behavior. A provider may use hazard, survival, Bayesian, machine-learning, or
other methods internally but must return the RRP-defined quantity.

The platform owns target meaning and request construction, controlled provider
registration and exact project selection, compatibility, future-information
exclusion, standardized results, probability/cardinality rules, safe failure,
and provider/model provenance. Projects do not register or select estimands,
targets, or request builders.

Conformance must remain distinct from clinical validity, calibration,
fairness, effectiveness, regulatory status, and local production approval.

The reference path should include a transparent, reproducible, visibly
nonclinical example provider. Advanced methods are optional project providers
or research extensions, never mandatory core dependencies.

## Persistent operational history

**Design principle:** The hospital remains authoritative for source history;
the platform preserves what it actually knew and produced operationally.

The target architecture distinguishes:

```text
Hospital/source data
        ↓
Canonical inputs used by a run
        ↓
Operational state
        ↓
Historically meaningful derived records
        ↓
Logical application products
```

At a declared as-of time, a run constructs the versioned state used for
eligibility, estimation, decisions, lineage, and products. State snapshots,
estimates, retained decisions, and related run provenance should persist when
they carry independent operational or governance meaning.

Routine refreshes should append attributable records. A later provider,
platform version, correction, or source change must not silently rewrite what
the platform produced earlier. Retry, duplicate, correction, invalidation, and
restatement semantics must be explicit.

A hospital should be able to start prospectively from current approved state.
It need not fabricate historical predictions. A persisted state is what a run
used; it is not a universal feature warehouse guaranteed to support every
future model. Retrospective reconstruction and rescoring are optional
analytical capabilities, not mandatory core behavior.

Persistence is defined through logical identities and read/write behavior, not
one database. The reference may use lightweight local storage. Production
deployments choose approved backends, retention, access, correction, archival,
and growth policies.

## Logical products and application boundary

**Design principle:** Products are versioned, curated logical interfaces, not
the historical system of record and not aliases for a storage format.

Products may include current episode views, trajectories, care-management
queues, summaries, lineage, and capability-dependent views. Builders select
and aggregate canonical or derived history; they do not reinterpret source
systems. Products declare identity, compatibility, freshness, lineage, and
unavailable or partial behavior.

The supplied Shiny application is an important interface, but it is not the
platform. It consumes logical products or stable product services. It must not
query hospital sources, invoke model-specific implementations, or depend on
storage-backend internals. Another interface may replace it without changing
upstream semantics.

## Human-first, agent-enhanced operations

**Design principle:** Every meaningful supported operation must be executable
and recoverable by a knowledgeable human through complete documentation and a
tested implementation. Agents are optional interfaces to those same
operations.

```text
Human operations documentation
        ↓
Tested platform operations
        ↑
Agents, skills, scripts, schedulers, and future clients
```

The CLI is the canonical human operational interface. A stable programmatic
API performs the work and is shared by the CLI, tests, automation, agents, and
supported clients. Operation categories include software/project health,
project initialization and validation, run/history, products/app, artifacts,
and explicit upgrade or migration as those capabilities are implemented. Final
command syntax follows working interfaces rather than preceding them.

An agent must not own unique business logic or an undocumented recovery path.
If all AI-specific files disappeared, the platform would remain operable. The
future `readmit` R package is an optional client/provider-development tool over
supported interfaces, not the RRP CLI, runtime, or target authority.

## Observability, provenance, validation, metrics, and audit

**Target state:** A portable, privacy-conscious observability interface spans
setup, implementation mapping, conformance, computation, providers,
persistence, products, application startup, deployment building, publication,
and scheduled operation.

Run identity should connect stages to structured, actionable diagnostics and,
where appropriate, provenance, validation results, and operational metrics.
Diagnostics must avoid PHI, patient-level clinical values, credentials,
connection strings, and raw records by default. Verbosity, routing, retention,
and approved record-level debugging are deployment-owned. Retention must be
bounded.

These concepts are related but not interchangeable:

- provenance explains what inputs, configuration, and versions made a result;
- diagnostics explain what happened during execution;
- validation reports record conformance findings;
- operational metrics summarize behavior and health; and
- governed audit records have separately defined durability, access, and
  completeness obligations.

Ordinary logs must never be described as a clinical or regulatory audit trail
without a governed design establishing that property.

## Installation, deployment, and distribution

**Target state:** RRP is one versioned installed software distribution operating
on an independently owned project. Deployment is a separate transformation of
validated installed/project outputs into a closed target realization.

```text
Development source → closed software build → installed RRP
                                           ↓ explicit project
                              validated project products
                                           ↓ artifact build
                              target-neutral closed artifact
        ↓
Target-specific realization
        ↓
Deployment or publication
```

The software distribution may contain internal R packages, but R is an
implementation dependency rather than the operator experience. RRP and each
project own separate dependency environments. Installation is versioned and
non-mutating with respect to project source and state.

Deployment targets own runtime packaging and validation. They must not alter
canonical, target, provider, product, or operational-history semantics.
Generated deployment repositories are ordinarily realizations and should not
be edited as authoritative source.

Posit Connect Cloud remains the default reference target because it provides a
practical public demonstration path. It is not a core dependency. Other
approved targets should be added from concrete needs rather than speculative
infrastructure.

The development repository is not the installed payload. A closed inclusion
manifest, exact output inventory, dependency/build evidence, cryptographic
digests, and clean installation proof define a distribution. Hospitals do not
normally clone or modify platform source. Generated Hospital Implementation
repositories remain `v0.1.0` history rather than the forward product boundary.

The initial deployed artifact is product-only and excludes producers,
providers, models, and history writers. A compute-capable artifact is a later,
distinct profile. No distribution or target wrapper may duplicate or redefine
platform logic.

## Upgrade and migration separation

**Design principle:** software upgrades do not silently mutate independent
projects or their state.

```text
install and verify a new RRP version
        ↓
validate a project against it
        ↓
activate explicitly or retain the prior version
```

Project migration explicitly changes project source/configuration. State
migration explicitly transforms persistent state with source preservation,
staging, validation, and provenance. Neither is an installer side effect.
Side-by-side or equivalently atomic software versions must permit validation
and rollback before an old installation is removed.

## Human-readable implementation

**Design principle:** Code communicates intent. Major stages, assumptions,
temporal reasoning, boundaries, extension points, and consequential decisions
should be discoverable to a technically capable reader.

Prefer focused responsibilities, expressive names, readable decomposition,
and comments that explain why rather than narrate obvious syntax. Longer
operations should expose meaningful stages. Avoid clever compression and
dependencies that do not earn their cost. Correctness, safety, reproducibility,
portability, and appropriate performance take precedence over stylistic
uniformity.

For R, use native `|>`; use tidyverse tools where they make transformations
clearer, and base R where it is simpler for system, CLI, filesystem,
low-dependency, or performance-sensitive work. AI-generated code must be
directly understandable and maintainable by people.

The repository should be educational: documentation and implementation
together should teach the platform's data, temporal, provider, persistence,
product, deployment, and operational boundaries.

## Stewardship and ownership boundaries

The core platform owns the installed distribution, public project/canonical/
target/provider/history/product/artifact contracts, conformance, generic
post-canonical behavior, fictional example project, valid nonclinical defaults,
product interfaces, supplied app/deployment builders, operations, tests,
documentation, versioning, provenance, and open-source stewardship.

The adopter owns an independent project: source access/interpretation, mapping
and producer, selected provider/model and extension dependencies, model
artifacts, nonsecret configuration, writable state and storage policy, identity
and access, secrets, deployment approval, diagnostic routing/retention, local
model/clinical governance, monitoring, incident response, and adoption.

CentralStatz and third parties may own optional providers, integrations,
extensions, and professional services. Their value is expertise and judgment,
not gated access to the platform.

Outside the core direction are mandatory proprietary models, hidden core
functionality, forced service or agent use, a full commercial-EHR simulator,
multi-hospital hosted tenancy, one universal deployment architecture, an
enterprise data warehouse, a universal historical feature store, mandatory
retrospective rescoring, and replacement of the EHR as clinical system of
record.

## Decision test

Before accepting a material change, ask whether it:

1. follows this document rather than inherited implementation shape;
2. preserves or creates a valid working reference path;
3. lets the affected component be replaced independently;
4. keeps generic code unaware of local sources and named implementations;
5. strengthens a versioned, storage-independent public interface;
6. preserves temporal validity, provenance, and attributable history;
7. keeps the singular RRP target ahead of provider convenience;
8. separates risk, decisions, work, interventions, products, and audit;
9. remains human-operable without AI or a proprietary service;
10. keeps the app separate from source, model, and storage internals;
11. preserves deployment portability and one-health-system scope;
12. emits actionable, privacy-conscious operational evidence;
13. keeps optional methodology outside mandatory core dependencies;
14. communicates its intent to future human maintainers; and
15. states maturity and clinical-use limitations honestly.

Open decisions are tracked in [Open decisions](../architecture/open-decisions.md)
and should be resolved just before the phase that needs them, not prematurely.
