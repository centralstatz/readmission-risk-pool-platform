# Readmission Risk Pool Platform True North

## Status and authority

This document is the authoritative statement of the intended identity and
long-term direction of the Readmission Risk Pool Platform. It governs the
[platform architecture](../architecture/platform-architecture.md), which
governs the [implementation plan](../architecture/platform-implementation-plan.md).
The [implementation record](../architecture/platform-implementation-record.md)
records what is actually built. Software must conform to that chain.

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

At bootstrap, this repository contains governing documentation only. Target
statements are not claims of implemented or clinically validated capability.

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
- governed estimands and model providers;
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
Acquire platform
        ↓
Run synthetic reference implementation
        ↓
Run transparent default provider
        ↓
Build logical products
        ↓
Launch supplied application
        ↓
Build a reference deployment
        ↓
Replace source, provider, storage, deployment, or interface deliberately
```

Replacement order is not fixed. The durable expectations are:

- deployment can change without changing canonical or model semantics;
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

A technically capable analyst or developer should be able to acquire the
project, run the fictional system, understand the boundaries, map approved
local data, test a conforming provider, build products, and demonstrate a
prototype without first buying services or installing enterprise
infrastructure.

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
including population eligibility, temporal filtering, reproducible state
construction, estimand requests, provider invocation, decision and priority
logic, lineage, and construction of derived records.

These responsibilities share identifiers and run context but remain separable:

- eligibility is not state construction;
- estimation is not decision policy;
- risk is not operational priority;
- a task records work to do, while an intervention records care delivered;
- measure lineage is not the organizing data model; and
- derived operational records are not application views.

## Estimands and governed model providers

**Target state:** Model providers are first-class extensions governed by the
meaning of the quantities they estimate. Technical executability alone is not
sufficient.

```text
Canonical data and state
        ↓
Versioned estimand specification
        ↓
Selected provider specification and declared capabilities
        ↓
Universal + estimand-specific + provider-specific conformance
        ↓
Standardized derived estimate records
```

Estimands own quantity meaning: population, conditioning information, time
origin, horizon, event definition, terminal and competing-event behavior,
output domain, and mathematical or temporal coherence.

Providers own method: required inputs and state fields, supported estimands,
configuration or loading, dependencies, uncertainty and explanation
capabilities, and declared limitations and failure behavior.

The platform owns controlled registration and selection, input compatibility,
future-information exclusion, standardized results, universal probability and
cardinality rules, estimand-specific conformance, safe unsupported/missing
input behavior, and provider/version provenance.

Conformance must remain distinct from clinical validity, calibration,
fairness, effectiveness, regulatory status, and local production approval.

The reference path should ship with a small number of versioned estimands and
transparent, reproducible, visibly nonclinical default providers. Advanced
Bayesian, survival, simulation, causal, or intervention-learning methods are
optional providers or research extensions, never mandatory core dependencies.

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

First-class operations will grow with the implementation and may include
initialize, doctor, validate, generate a reference implementation, build, run,
select an implementation, select a provider, build products, launch, build a
deployment, publish, and upgrade. Final names and packaging should follow
working interfaces rather than precede them.

An agent must not own unique business logic or an undocumented recovery path.
If all AI-specific files disappeared, the platform would remain operable. A
future `readmit` R package or CLI may be a convenient client or control surface,
but it must remain optional and invoke the same operations.

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

## Deployment and distribution

**Target state:** Deployment is a transformation from platform source into a
validated target-specific realization.

```text
Platform source
        ↓
Deployment build
        ↓
Target-specific realization
        ↓
Deployment or publication
```

Deployment targets own runtime packaging and validation. They must not alter
canonical, estimand, provider, product, or operational-history semantics.
Generated deployment repositories are ordinarily realizations and should not
be edited as authoritative source.

Posit Connect Cloud remains the default reference target because it provides a
practical public demonstration path. It is not a core dependency. Other
approved targets should be added from concrete needs rather than speculative
infrastructure.

The platform is intended for public open-source distribution. The initial
acquisition path may be a repository clone; releases, archives, installers,
containers, and optional clients require evidence and explicit support
decisions. No distribution wrapper may hide or duplicate platform logic.

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

The core platform owns public contracts, conformance, generic post-canonical
behavior, the synthetic reference, valid nonclinical defaults, product
interfaces, a working application and deployment, persistence and diagnostic
interfaces, operations, tests, documentation, versioning, provenance, and
open-source stewardship.

The adopter owns source queries and interpretation, local mappings and
configuration, custom provider approval, storage infrastructure and policy,
identity and access, security, deployment approval, diagnostic routing and
retention, local model and clinical governance, monitoring, incident response,
and adoption.

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
7. keeps estimand meaning ahead of provider convenience;
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
