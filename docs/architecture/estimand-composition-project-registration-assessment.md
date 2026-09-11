# Estimand composition and trusted project registration assessment

## Status and scope

**Status:** retained `v0.2.0` precursor assessment; its configurable installed-
estimand recommendation is superseded by the focused
[platform-defined readmission-risk target
assessment](readmission-risk-target-assessment.md) and the current
[Platform Architecture](platform-architecture.md)

This assessment closes the first analytical composition decision beneath the
proposed [installed software and minimum project
contract](installed-software-project-contract-assessment.md). It evaluates the
immutable `v0.1.0` implementation as technical evidence and follows the
accepted [governance and validation
direction](governance-validation-architecture-assessment.md). It does not
modify or finalize an estimand contract, project manifest, registration API,
runtime, history, product, application, artifact, package, test, release, or
publication.

The code trace, provider-injection findings, and trusted registration-result
analysis remain useful evidence. The later assessment narrows the product:
projects neither select nor register an estimand, RRP owns one standard request,
and provider selection replaces estimand-to-provider routing. This document is
not active direction where the conclusions differ.

## Executive conclusion

An executable RRP estimand is not just YAML and is not a model. It consists of:

1. an exact semantic identity/version and declaration of the quantity;
2. an exact request-builder implementation identity/version paired with a
   trusted callable owned or approved by installed RRP;
3. declared canonical profile/state/capability and output requirements;
4. a governed request/result contract and deterministic identity rules;
5. structural and behavioral conformance scenarios; and
6. provenance linking produced requests to both semantic and executable
   identities.

The semantic declaration answers **what quantity** is estimated. The request
builder operationalizes that quantity for an eligible state and as-of time.
The provider estimates the resulting request. Neither the provider nor project
configuration may redefine the estimand.

The narrowest rigorous first-generation policy is:

- projects may define/register producers;
- projects may define/register providers;
- estimands are supplied by installed RRP only;
- a project selects exactly one estimand and one exact provider for it;
- one run executes that single estimand/provider route; and
- products and the supplied app remain installed defaults.

Project-authored estimands and simultaneous multi-estimand runs are **not**
supported initially. One implemented daily hazard does not justify a generic
declarative family, and a trusted executable estimand interface would add
semantic, dependency, provenance, history, product, and app obligations before
a demonstrated use case requires them. The internal design should nevertheless
treat the supplied estimand as a resolved component, not a hard-coded singleton,
so a future contract version can add another installed estimand or a governed
extension without replacing the project model.

The fixed trusted project registration callable should return one closed,
versioned description of **available project-contributed components**:

```text
project registration result
  ├── producer entries: declaration + trusted callable + safe metadata
  └── provider entries: declaration + trusted callable + safe metadata
```

It returns no selections and initially no project estimands. Installed
components remain in an installed catalog rather than being copied into the
project result. The manifest contains exact selections; installed RRP validates
both catalogs, rejects collisions, resolves the selected producer and the
single estimand→provider route, and builds an immutable project context and
run-specific execution plan. No precedence, override, alias, range resolution,
fallback, ranking, or ambient discovery is needed.

Current history and product structures substantially support the recommended
single-estimand scope. Provider/estimand identities already flow through
requests, executions, estimates, history, product rows, and app tables. The
history cycle must accept a resolved provider instead of constructing the
transparent reference provider, and request-builder identity must be added to
provenance. The initial product-set contract remains explicitly tied to the
supplied estimand. The product-only application architecture remains sound.

Multiple estimands are structurally suggested but not safely supported:
eligibility, state, and request construction each assume one estimand; current
deterministic eligibility/state/request IDs do not consistently include the
estimand ID; the runtime result exposes one estimand specification; current
product compatibility admits one exact estimand; and the app would plot mixed
quantities together. Deferring multiple execution avoids a broad redesign while
preserving a clean path through explicit identities and routing.

## Current estimand lifecycle

### End-to-end trace

| Stage | Current implementation | Classification |
|---|---|---|
| Semantic declaration | `contracts/runtime/estimands/readmission-next-day-conditional-hazard.yml` defines exact identity, daily conditional-hazard quantity, discharge origin, event, conditioning, effective horizon, terminal/competing-event behavior, required/optional capabilities, probability bounds, one-output cardinality, and coherence | **Hard-coded supported estimand**, but declaration separation is reusable |
| Contract discovery | `runtime-operation.R` loads that one file as `contracts$estimand` from the repository root | **Reference/source-layout coupling**; move to installed catalog |
| Semantic validation | `rrpruntime::validate_runtime_contracts()` recognizes one exact identity/version and compares its daily-hazard fields to literals | **Hard-coded to one estimand**; strong fail-closed behavior is reusable |
| Eligibility | `evaluate_episode_eligibility()` uses the estimand's maximum horizon, event/death timing, and effective follow-up end; records carry estimand identity | **Hard-coded singleton shape**; quantity-specific eligibility is real executable semantics |
| State | `build_episode_states()` consumes those eligible results and includes estimand-derived follow-up remaining, but the state-set identity is not estimand-specific | **Structurally reusable for one route; unproven/ambiguous for multiple** |
| Request construction | `build_estimand_requests()` computes `min(as_of + width, effective_end)`, fixes `(start, end]`, creates exactly one request per eligible state, and embeds the one supported estimand identity | **Executable hard-coded estimand semantics** |
| Request identity/cardinality | Request ID uses runtime run, episode, as-of, and estimand version; the request contract requires one per eligible state and no provider fields | **Single-estimand only**; ID omits estimand ID and would collide for different estimands with the same version |
| Provider declaration | Each provider lists supported estimand IDs/version ranges, follow-up/interval limits, supported state and output | **Already generic** |
| Provider compatibility | `validate_provider_compatibility()` checks active lifecycle, exact estimand/range, state version/alignment, capabilities/inputs, interval/horizon, and one bounded probability | **Already generic per request**, with static and dynamic checks currently combined |
| Provider execution | Registry resolves exact provider; adapter gets copies of request/state/declaration; output and estimate identities/interval/value are checked | **Already generic** |
| Estimate | Standard record carries estimand, provider/implementation, optional model, request, state, interval, probability, and provenance | **Already generic for supported probability estimands** |
| History batch | Persists state, request, execution result, estimate, and aggregate terminal counts atomically; retry lineage is request/provider-specific | **Reusable for one route; record collections can hold many, but multi-estimand identity behavior is unproven** |
| DuckDB | Request payload retains full estimand reference; extracted request columns include estimand ID but not version. Estimate columns include estimand ID/version and provider ID/version | **Small future generalization for multi/version queries; no blocker for one route** |
| Products | Current/history rows carry estimand/provider IDs and versions; current grain is episode+estimand; run summary lists unique estimands/providers | **Structurally capable**, but the product-set contract admits only the one exact estimand |
| Application | Tables show estimand/provider labels; app requires three product identities and never loads estimand/provider code | **Architecture generic for one route; presentation unsafe for mixed estimands** |
| Artifact | Copies product files and records product set/build/source run, app, builder, materializer, and dependency evidence | **Indirect estimand provenance only**; lacks explicit RRP/project/builder/provider composition |

### Already generic

- Provider declarations support estimand ID/version ranges.
- Provider registry and exact resolution do not name the reference provider.
- Provider output/result/estimate checks bind output to the request's estimand.
- Estimate identities include estimand ID/version and provider implementation.
- History stores arbitrary collections and relates executions/estimates through
  request IDs.
- Current/history products expose estimand and provider identity.
- Run-summary products gather unique estimand/provider references.
- The app consumes products only and displays identity labels.

### Structurally capable but unproven

- A history batch can contain more than one request and provider result.
- Product row grains distinguish estimands.
- A provider declaration can list more than one supported estimand.
- A registry can hold multiple exact provider versions.
- The app can display more than one row and identity label.

These facts do not prove multi-estimand correctness. The upstream state/request
identities and downstream selection/presentation rules still assume one
quantity.

### Hard-coded to the supplied estimand

- Supported runtime identity and semantic-field validation.
- Contract loading and the singular `contracts$estimand` member.
- Eligibility effective horizon and estimand reference.
- State construction from one estimand-specific eligibility set.
- Daily interval/request construction and one-request-per-state cardinality.
- Request-set metadata and current request ID formula.
- Reference history orchestration and provider selection.
- Initial product-set upstream estimand compatibility.

### Reference-specific naming/presentation

- `reference` operation/function names and synthetic `--scale` defaults.
- The transparent provider and its hard-coded diagnostic identity.
- App titles/nonclinical copy.
- Artifact classification and reference builder IDs.

Those should be refactored physically without changing estimand meaning.

## Executable estimand component model

### Required parts

| Component part | Why it is necessary |
|---|---|
| Semantic identity/version | Gives the quantity stable compatibility and provenance identity independent of a provider |
| Semantic declaration | Defines population/conditioning, event, time origin, interval/horizon, terminal and competing events, required capabilities, output, bounds/cardinality, and coherence |
| Request-builder reference | Identifies the executable realization of the declaration; semantic version alone cannot show which code operationalized it |
| Trusted request-builder callable | Converts validated eligibility/state/as-of into requests; temporal semantics cannot be implemented by metadata alone |
| Supported canonical profile/state/capability declaration | Allows static compatibility to fail before source access and dynamic checks to bind eligible input correctly |
| Request/output contract references | Prevents a builder or provider from changing envelope, interval, cardinality, or result meaning |
| Reproducibility declaration | States whether identical validated inputs must yield identical request candidates and whether wall clock/randomness are prohibited |
| Conformance scenarios | Exercises boundary, terminal, horizon, capability, cardinality, stable-ID, and failure cases |
| Safe dependency/provenance metadata | Lets validation prove required code is available and history/artifacts identify executable semantics without secrets |

The semantic declaration and builder are paired in an installed component
descriptor but remain conceptually distinct. Changing semantic meaning requires
an estimand version change. Changing builder code requires a builder
implementation version change and compatibility evidence; if observable
request semantics change, the estimand version must also change.

The provider is not part of the estimand component. Routing selects a provider
only after both components independently exist and can be checked.

## Comparison of estimand extension models

| Model | Rigor and simplicity | Flexibility/cost | Current evidence | Disposition |
|---|---|---|---|---|
| **A. Supplied estimands only** | RRP controls declaration, builder, fixtures, compatibility, and release evidence; smallest trust/dependency surface | Projects cannot introduce a new quantity without an RRP release | Exactly one rigorous implemented estimand; no adopter evidence requires a second | **Recommend initially** |
| **B. Constrained declarative families** | RRP-owned engine can preserve temporal semantics if the family has a proven closed parameter space | Requires family schema, cross-parameter coherence, identity/version rules, and more product labels | One next-day conditional hazard does not establish which dimensions are safely variable | **Defer; no generic DSL now** |
| **C. Trusted executable extension** | Can support genuinely different quantities; structural/behavioral conformance still useful | RRP cannot prove scientific validity; adds code trust, dependencies, builder ABI, provenance, review, and downstream compatibility | No full custom-estimand evidence exists | **Do not support initially** |
| **D. Hybrid supplied/family plus executable extension** | Could separate common safe families from advanced reviewed work | Combines every policy and support burden before either is needed | Long-term plausible, currently speculative | **Future contract option, not first scope** |

Model A is not a permanent assertion that only one estimand can exist. It is a
release-scope decision: installed RRP may later ship another fully governed
component, and a future project-contract version may admit constrained or
trusted extensions once their value justifies their costs.

## Recommended initial estimand policy

1. Installed RRP owns the supplied estimand declaration and builder.
2. The installed catalog may contain versioned estimand components, but the
   first release needs only the current next-day conditional hazard.
3. The manifest selects exactly one estimand ID and exact version.
4. One project context and one execution plan resolve that selection.
5. One run creates requests for exactly that estimand only.
6. Projects cannot register estimands under the initial registration contract.
7. Projects may register a compatible provider for the supplied estimand.
8. Products/app remain the supplied suite and accept only its supported output
   contract.
9. Adding another installed estimand requires component and downstream
   compatibility evidence, not an arbitrary YAML file.
10. Project-authored estimands require a later versioned extension contract and
    explicit scientific governance.

This policy provides a clean future path because selection and routing are
explicit even though their cardinality is one.

## Request-builder contract and conformance

### Boundary

For the initial supplied component, installed RRP should invoke a batch-oriented
builder with deep-copied/read-only logical inputs:

```text
validated estimand declaration/component
+ validated eligibility set
+ validated eligible state set
+ runtime context (run ID and as-of)
+ installed request contract
        ↓
structured request-build result
  ├── status/issues
  └── complete request set on success
```

Batch orientation matches the current implementation and lets RRP validate
completeness and uniqueness across all eligible states. The builder may use a
per-state internal function, but that is not a separate public orchestration
surface.

It receives no persistence port, source access, provider registry, product
access, wall-clock service, or arbitrary project context. It must not perform
I/O or mutate inputs. Quantity-specific canonical inputs should be represented
through the governed state/capability contract, not hidden project lookups.

### Responsibilities

The builder owns quantity-specific eligibility interpretation that cannot be
generic, target interval/horizon construction, boundary convention, and any
estimand-specific request payload admitted by the request contract. RRP owns
the enclosing runtime run/state references, supported request schema,
deterministic identity algorithm, collection conformance, and failure envelope.

The current implementation lets the builder construct complete request records.
For a future public extension, a safer split is for a builder to return
request candidates while RRP stamps the governed envelope and ID. That choice
can be finalized only if executable extensions are authorized; it need not
complicate the supplied-only implementation.

Request identity must at least include runtime run, state/episode, estimand ID
and version, as-of, and target interval/boundary. The current formula includes
estimand version but omits estimand ID and therefore cannot support multiple
estimands safely.

### Structural conformance

RRP can validate:

- exact estimand, builder, request-contract, run, state, and episode references;
- required/closed fields and supported types;
- RFC 3339 as-of and interval ordering/boundary;
- target interval within eligible effective follow-up;
- required capability references;
- unique deterministic request IDs;
- no provider/model fields; and
- a complete success or structured failure, never partial successful output.

### Behavioral conformance

For each supported estimand component, fixtures should prove:

- identical inputs produce identical requests when determinism is declared;
- one request per eligible state for the current estimand;
- none for ineligible, already readmitted, dead, before-discharge, or completed
  follow-up states;
- correct ordinary, horizon-truncated, and canonical-follow-up-truncated daily
  intervals;
- stable IDs and ordering independent of input ordering;
- no mutation or I/O side effects; and
- invalid inputs/results fail with structured issues before persistence.

If a future estimand has different cardinality, that cardinality belongs in its
declaration and conformance contract rather than weakening the current rule
globally.

### Scientific limitation

Schema and fixtures can show that code agrees with a declared set of examples.
They cannot prove that arbitrary R code defines a scientifically appropriate
quantity, that its conditioning set is defensible, or that its declaration is
truthful. A future project-authored estimand would require institutional
scientific review, documented mathematical meaning, independent fixtures, code
review, version/change control, and explicit clinical-use governance in
addition to RRP conformance. RRP validation is not scientific certification.

## Trusted registration result model

### Closed result

The fixed registration callable should return a versioned closed value with:

- registration-result contract identity/version;
- project identity matching the already parsed manifest;
- zero or more producer entries;
- zero or more provider entries; and
- no unknown component kinds or top-level fields.

The first project contract requires the selected producer to resolve from the
project entries. A provider may resolve from a project entry or an installed
supplied catalog. There is no project estimand collection in the initial result.

Each producer entry contains:

- one conforming producer declaration, including implementation/mapping
  identities and supported canonical profiles/capabilities;
- one trusted callable adapter;
- nonsecret dependency requirements not already represented by an imported
  package; and
- optional safe code/provenance references governed by the registration
  contract.

Each provider entry contains:

- one conforming provider declaration, including provider, implementation,
  optional model, supported estimand/state/output, reproducibility, and
  conformance identities;
- one trusted callable adapter;
- nonsecret dependency/model requirements; and
- optional safe provenance references.

Callables are objects, not function-name strings. Paths, package-install
commands, credentials, source records, and manifest selections are prohibited
from the returned value. Existing declarations already carry most identity and
compatibility metadata; a wrapper should not duplicate it.

### Availability versus selection

```text
installed catalog + project registration
        → available validated components

project manifest
        → exact selected composition

resolved execution plan
        → selected callable objects and services for one run
```

Registration never chooses the active producer/provider. The manifest never
names executable functions or scripts. This separation keeps configuration
declarative and composition deterministic.

## Installed and project component resolution

Installed and project components should enter one logical resolver after their
different provenance/trust checks, while retaining an `installed` or `project`
origin label.

Initial collision policy:

- exact duplicate kind+ID+version fails project loading;
- project entries cannot use reserved installed/platform/reference namespaces;
- project entries never override or shadow an installed exact component;
- different exact versions remain distinct entries when their namespaces are
  permitted;
- manifest selection uses exact ID+version and must resolve to exactly one
  entry; and
- no search order or “latest compatible” rule exists.

Installed components do not appear in or get copied into the project
registration result. The resolved project context can expose the combined
catalog for diagnostics while preserving origin and version.

The installed estimand component resolves from the installed catalog only.
The selected producer resolves from project registration. The selected provider
may be project-owned or an installed demonstration/default only when that
provider's intended-use status permits it. The transparent reference provider
must remain explicitly nonclinical.

## Manifest-selection implications

The future manifest needs exact relationships, not executable implementation:

```text
producer selection: exact producer ID + version
analysis route:
  estimand selection: exact estimand ID + version
  provider selection: exact provider ID + version
```

This is conceptual structure, not finalized `rrp.yml` syntax. A single route
keeps the estimand/provider relationship explicit even while cardinality is one.
Separate uncorrelated lists would become ambiguous later.

Aliases, compatible ranges, default provider fallback, priority order, and
runtime auto-selection are unnecessary initially. RRP software compatibility
may use a declared range at the project level, but analytical component
composition is exact. Registration entries define what exists; the manifest
defines what is selected.

Source connection details and producer invocation configuration remain below
the producer boundary. The manifest may select the producer but must not expose
credentials, arbitrary script paths, or function names.

## Pre-execution compatibility sequence

Full provider compatibility depends on actual request/state values, so it
cannot all occur before source access. The rigorous sequence separates static
composition checks from dynamic per-request checks:

```text
1. resolve explicit project root
2. parse/validate manifest and RRP compatibility
3. validate state-path syntax/ownership without mutation
4. load the one trusted registration entry point
5. validate closed registration result and component declarations
6. combine installed/project catalogs; reject collisions
7. resolve exact producer, supplied estimand, and provider route
8. validate static cross-component compatibility
9. validate declared dependencies and construct immutable project context
10. construct run-specific plan (run/as-of, invocation, persistence service)
        --- only now may clinical source access begin ---
11. execute producer and admit canonical output
12. validate actual profile/capabilities; build eligibility/state
13. run and conform the estimand request builder
14. perform dynamic provider compatibility for each request/state
        --- only after complete request conformance may history start ---
15. append started status; execute provider; append terminal batch/status
```

Static checks include lifecycle, exact identity/version, producer-declared
profile/capabilities, estimand required profile/capabilities/state/output, provider
supported estimand range, state version/required fields, maximum interval/
follow-up, output semantics, adapter contract, and package/model availability.

Dynamic checks include admitted capability status, actual state fields/inputs,
state-request alignment, interval length, and follow-up position. A provider
that is statically incompatible must never see source-derived state. A
dynamically missing input becomes a structured per-request outcome under the
existing contract.

The current cycle already builds/admit requests before appending `started` and
persists provider outcomes atomically afterward. That valuable failure boundary
should remain.

## Provider-routing model

Routing is declared in the manifest, resolved in the project context, and bound
to callable objects in the execution plan:

```text
exact manifest estimand/provider pair
  → exact catalog resolution
  → static compatibility
  → immutable route in run plan
  → dynamic request/state compatibility
  → provider execution
```

The registration result supplies providers but contains no routing. The
provider declaration remains the authority for which estimand versions,
states, capabilities, intervals, horizons, and outputs it supports.

Initially:

- one provider is selected for the one estimand;
- one provider may declare support for multiple estimands for future reuse, but
  the run uses only the selected route;
- multiple providers for one estimand, ensembles, fallback, ranking, A/B
  routing, and provider selection by data availability are unsupported; and
- provider failure remains a failure outcome, not a trigger for implicit
  fallback.

This preserves estimand/provider separation and exact attribution.

## Project context and execution plan

The distinction is useful and small.

### Resolved project context

Created once per project load in one R process, it contains:

- validated manifest/project/RRP identities;
- installed contract/catalog identity;
- validated project registration result;
- available component catalogs with origin labels;
- exact resolved producer and estimand/provider route;
- static compatibility/dependency evidence; and
- resolved state configuration/services safe for later operations.

It contains no patient data, producer result, runtime as-of, or open mutable
run transaction.

### Run-specific execution plan

Constructed from the context for one invocation, it adds:

- runtime and producer execution IDs;
- as-of time and producer invocation configuration handle;
- exact producer callable;
- exact estimand declaration, builder reference/callable;
- exact provider declaration/callable route;
- persistence port/session factory; and
- operation event/provenance context.

The plan is immutable in-process and inspectable before execution. It is not a
serialized executable artifact. This separation prevents app/product/diagnose
operations from pretending they need run-specific source/model composition.

## Registration loading, trust, and lifecycle

The project manifest is validated before code loading. Installed RRP then
evaluates only the fixed registration file in a fresh controlled environment
whose intended visible API is documented. It calls one expected registration
callable and validates the returned value.

The registration file is trusted R code. It may define callables directly,
import them from project-owned packages, or explicitly source other project
files using its own reviewed logic. RRP itself does not scan or recursively
source the project. A package-based component returns imported function objects
through the same result. A controlled environment reduces accidental global
coupling but does not constrain malicious or careless code and is not a
sandbox.

Registration is evaluated once when a project is loaded into a process and
cached only in that immutable in-memory context. Each new command/process loads
it again. It is not serialized, persisted as an executable cache, or reloaded
mid-operation. If code changes between operations, the next load produces new
dependency/code provenance; an already running operation continues with its
resolved closures.

Run/build provenance records approved nonsecret registration/component digests
and package/component versions, not serialized functions. Which files a
registration callable sourced is project responsibility unless a future package
or component contract supplies a closed inventory.

## Producer relationship

Producer registration should use the same high-level vocabulary—declaration,
callable, identity/version, dependencies, provenance, exact resolution—without
forcing producer/provider fields into one generic schema. Their existing
contracts and failure stages remain distinct.

The initial project may register one or more producer entries but selects
exactly one producer. Allowing unused registered entries does not create runtime
ambiguity because resolution is exact; implementations may choose to require
only selected components to pass expensive conformance scenarios.

The manifest owns producer selection. Source configuration/secrets remain
producer-owned outside the manifest. Before source access, RRP checks the
producer declaration supports the project's selected canonical profile and
declares capabilities compatible with the supplied estimand. After execution,
the existing producer result and canonical admission prove actual profile,
identity, capability, as-of, and bundle conformance.

No producer semantic redesign is necessary.

## Single versus multiple estimands

| Scope | Benefits | Required changes/risks | Decision |
|---|---|---|---|
| **A. Exactly one selected estimand per project/run** | Small manifest/plan, current scientific meaning and products/app remain coherent | Replace hard-coded singleton with one resolved component; inject provider; add builder provenance | **Initial scope** |
| **B. Register/offer many, select one per run** | Different analytical runs without changing project manifest | Run-specific selection authority, comparison/mixed history/product rules, operation inputs and provenance | Defer until a real workflow needs it |
| **C. Execute multiple in one run** | One source/state cycle could produce multiple quantities | Estimand-specific eligibility/state, collision-free IDs, route/failure policy, product compatibility, app filtering/plots, larger atomic batches | Explicitly unsupported initially |

Specific blockers to Scope C are:

- runtime contracts and result sets contain one estimand;
- eligibility and effective follow-up are estimand-dependent;
- eligibility/state IDs do not include estimand identity;
- request IDs omit estimand ID;
- state records include estimand-derived follow-up but no estimand reference;
- current estimate lookup selects by estimand ID but not version;
- the initial product set supports one exact estimand;
- the app's episode history plot mixes rows and colors by provider rather than
  separating quantities; and
- partial success semantics across estimand routes have not been defined.

These are solvable future changes, but they are not free capacity already
proved by list-valued structures.

## History, products, application, and artifact implications

### History

For the recommended one-route scope, history is **reusable with small
generalization**:

- requests, execution results, and estimates already carry estimand identity;
- execution and estimate identities carry provider identity and implementation;
- terminal counts and atomicity remain valid;
- retry/invalidation remain tied to exact request/provider/record identities;
  and
- no schema rewrite is required solely to inject a custom provider.

Add an exact request-builder implementation reference to request/run provenance
so history can answer which executable semantics operationalized the estimand.
Project and RRP software identities also belong in run provenance. Whether
those require new fields or governed provenance entries is a contract decision.

Multi-estimand support would require collision-free eligibility/state/request
identity, explicit state sharing versus per-estimand state, version-aware
current reads, and migration review. That is a later history decision.

### Products

The existing product rows already carry estimand/provider identities, current
grain is episode+estimand, history preserves transitions, and run summaries
list unique references. The product layer is therefore not intrinsically tied
to provider implementation code.

However, `platform.initial-risk-product-set@0.1.0` explicitly admits only the
current estimand identity/version, and builders reject another. A custom
estimand cannot claim compatibility merely because it also returns a
probability. It would need a product-contract compatibility decision covering
quantity/output/labels. Under the supplied-only one-route policy, products can
remain semantically unchanged while their code is packaged and provenance is
extended.

Estimand extension does not necessarily require custom product plugins. A
future estimand with the same governed probability/interval row semantics may
be admitted by a generalized installed product suite after explicit review.

### Application

The app architecture remains product-only and requires no estimand code. Its
tables already display exact estimand/provider strings. For one supplied
estimand, only reference naming/presentation and added metadata labels need
physical refactoring.

Multiple quantities would require explicit filtering/faceting and quantity-
aware labels. The current history plot filters only by episode and would connect
or compare heterogeneous quantities, so it cannot be called multi-estimand-safe.
The app must continue to consume product metadata, never registration objects
or builder/provider callables.

### Artifact and provenance

The current artifact indirectly contains estimand/provider evidence through
product files and source run IDs, but its top-level build provenance does not
explicitly state the analytical composition.

Minimum future artifact/build evidence should identify:

- RRP software and project ID/version/manifest digest;
- producer, implementation, and mapping ID/version;
- estimand semantic ID/version;
- request-builder implementation ID/version;
- provider and provider implementation ID/version;
- optional model ID/version/digest when present;
- source runtime run IDs and as-of/cutoff;
- product set/build/materialization and application IDs/versions; and
- artifact builder/dependency identities.

This answers what quantity, executable estimand semantics, provider/model, and
software/project context produced the artifact. It must not contain source
credentials, patient-level values, raw records, private mappings, or unsafe
digests of secret-bearing inputs.

## Failure semantics

| Failure | Detection boundary | Source/state effect | Structured outcome |
|---|---|---|---|
| Malformed manifest/selection | Project validation | No project code, source, or mutation | Project conformance issues |
| Registration load/call failure | Project loading | Trusted code may have its own effects; RRP has not accessed source or state | Registration failure; no context/plan |
| Malformed/unknown registration field or declaration | Project validation | No RRP source access or state mutation | Component conformance issues |
| Duplicate/colliding identity | Catalog composition | No source or mutation | Deterministic duplicate/collision error |
| Unknown exact producer/estimand/provider selection | Context resolution | No source or mutation | Unknown selection issue |
| Static producer↔profile↔estimand↔provider incompatibility | Context/plan validation | No source or mutation | Compatibility issues; no plan |
| Dependency/model unavailable | Context/plan preflight | No source or mutation | Dependency issue with recovery guidance |
| Unsafe/unavailable state target | Context/plan preflight | No source or mutation | State ownership/readiness issue |
| Producer failure | Producer execution | Source may have been accessed; no started history or downstream runtime | Existing structured producer failure |
| Canonical admission failure | Producer/admission | Source accessed; no history mutation | Existing producer result with admission failure |
| Request-builder execution/nonconformance | Runtime preparation | Admitted data/state exist in memory; no started history | Structured request-build failure; no partial request set |
| Dynamic provider incompatibility/missing input | Per-request compatibility | Started history only after complete requests; provider may not be invoked | Existing unsupported/missing-input execution result in atomic terminal batch |
| Provider adapter failure/invalid output | Provider execution | Started history exists | Existing failed execution result; terminal `completed_with_failures` and no fabricated estimate |
| Multi-estimand partial failure | Unsupported initially | None | Must be defined before multi-route support |

Project registration code is trusted and can perform arbitrary effects despite
the intended contract. Documentation and review must tell the truth; the
platform can control its own ordering, not sandbox local R.

## Future `readmit` compatibility

The initial policy lets a future `readmit` package provide a provider/model for
the supplied RRP estimand immediately:

```text
readmit exports provider declaration + adapter/model
  → project registration returns those objects
  → manifest selects exact provider for supplied estimand
  → RRP validates and executes public contracts
```

RRP need not inspect `readmit` internals. Package metadata/dependency checks and
provider/model provenance identify the implementation.

If `readmit` later provides new estimands, that requires the future estimand
extension contract described here: semantic declaration, approved request
builder, conformance evidence, explicit registration/selection, downstream
compatibility, and scientific governance. Reserving this boundary does not make
`readmit` a core dependency or promise that arbitrary `readmit` estimands are
accepted.

## Synthetic and adopter composition checks

Existing evidence supports the recommended composition without a new fixture:

```text
synthetic project evidence
  project/source-specific producer
  + supplied next-day estimand
  + supplied transparent provider

materially different adopter evidence
  independent source shape and producer
  + same supplied estimand
  + same downstream runtime/history/products/app/artifact

provider contract evidence
  same supplied estimand
  + a second registered constant provider
```

The Phase 10 adopter proof demonstrates source/producer substitution through
the downstream stack. Phase 4 provider tests demonstrate that another exact
provider registers and executes without runtime edits. Normal history
orchestration has not yet composed those two substitutions simultaneously
because it constructs the reference provider. Injecting the resolved provider
route is therefore the required generalization; no evidence requires a custom
estimand in the first project generation.

A future acceptance project should combine a materially different producer
with a project provider for the supplied estimand through the public loader.
That is implementation evidence to create later, not a fixture needed to reach
this assessment conclusion.

## Minimum viable extension policy

| Component | Initial policy | Cardinality/selection |
|---|---|---|
| Producers | Project-defined through existing declaration/result semantics | Registration may expose one or more; manifest selects exactly one |
| Estimands | Installed RRP supplied only; no project estimand registration or declarative family | Manifest selects exactly one; one run executes exactly one |
| Request builder | Installed and paired with selected estimand | Exactly one builder; complete all-or-fail request set |
| Providers/models | Installed demonstration peers and project-defined trusted providers | Registration may expose zero or more; manifest routes the estimand to exactly one provider; no fallback/ensemble |
| Persistence/materialization | Installed defaults | Project selects only when a supported nondefault extension exists |
| Products/application | Installed initial suite and product-only app | No project plugin surface in first contract |
| Artifact/target | Installed builders over exact project output | Explicit operation/profile; not analytical plugin discovery |

This is a controlled extension model, not a general plugin ecosystem.

## v0.1.0 reuse and generalization matrix

| Machinery | Disposition | Reason/next use |
|---|---|---|
| Current estimand YAML semantic declaration | **MOVE TO INSTALLED CATALOG** and **REUSE AS-IS** semantically | Supplied governed quantity |
| Repository-relative estimand parser/loading | **REFACTOR PHYSICALLY** | Installed resource/catalog service |
| `rrp_runtime_supported_specifications()` singleton | **GENERALIZE** | Resolve one selected installed component rather than hard-code identity |
| Literal semantic checks in `validate_runtime_contracts()` | **GENERALIZE** | Estimand-component validator and supplied-estimand conformance |
| Eligibility/effective-follow-up logic | **GENERALIZE narrowly** | Invoke selected supplied estimand semantics; one route initially |
| Daily request builder | **MOVE TO INSTALLED CATALOG** and **REUSE AS-IS** for supplied estimand | Pair exact builder reference with declaration |
| Request ID formula | **REPLACE** before multi-estimand support | Include estimand ID and complete semantic interval identity |
| Request/result conformance | **REUSE AS-IS** plus builder/provenance fields | Independent validation of builder/provider outputs |
| Provider declarations | **REUSE AS-IS** | Already express estimand/state/output compatibility |
| Provider registry/exact resolution | **REUSE AS-IS** | Combine validated installed/project providers without override |
| Provider compatibility | **REUSE AS-IS** and split static/dynamic orchestration | Preserve per-request checks; fail static incompatibility earlier |
| Provider execution/estimate construction | **REUSE AS-IS** | Already isolated, exact, bounded, and structured |
| Transparent provider | **RETAIN AS EXAMPLE** / installed nonclinical peer | Never implicit clinical fallback |
| Producer registry/result/execution | **REUSE AS-IS** with project-context path refactor | Project-contributed producer entries |
| `installed-producers.R` composition | **REPLACE** | Closed project registration result and exact manifest resolution |
| Reference provider construction in history | **MOVE TO PROJECT REGISTRATION/MANIFEST SELECTION** and **GENERALIZE** | Inject exact resolved route |
| History record collections/atomicity/retry/invalidation | **REUSE AS-IS** for one route | Add project/RRP/builder provenance |
| DuckDB request extracted columns/current lookup | **DEFER** | Version-aware/multi-estimand query changes only when needed |
| Product row estimand/provider fields and grains | **REUSE AS-IS** | Correct attribution for supplied single route |
| Initial product-set exact estimand support | **REUSE AS-IS** initially; **REQUIRES FOLLOW-UP** for another estimand | Prevent false compatibility |
| App product-only boundary and identity columns | **REUSE AS-IS** architecturally | Reference copy refactor; multi-estimand UI deferred |
| App history plotting across all episode rows | **REQUIRES FOLLOW-UP** before multi-estimand | Would mix quantities |
| Artifact product/run provenance | **GENERALIZE** | Add RRP/project/estimand-builder/provider/model composition |
| Project estimand registration | **DEFER** | No demonstrated first-generation need |
| Constrained estimand-family DSL | **DEFER** | One quantity supplies insufficient evidence |
| Multiple simultaneous estimands | **DEFER** | Requires runtime/history/product/app identity/cardinality design |

## Risks and tradeoffs

| Choice/extensibility | New risk or cost | Invariant/mitigation |
|---|---|---|
| Project producer registration | Trusted source code and local dependencies | Existing producer declaration/result/admission, explicit project trust, one exact selection |
| Project provider registration | Trusted model code, dependency/model failure | Existing provider contract, static/dynamic compatibility, isolated copies, structured outcomes, exact provenance |
| Closed registration result | New public component descriptor contract | Version it, prohibit unknown fields/selections/paths, retain kind-specific validators |
| Combined installed/project catalogs | Collision or accidental shadowing | Preserve origin, reserved namespaces, fail exact duplicates, no override/precedence |
| One estimand/provider route | Less flexibility across analyses | Matches proven lifecycle; versioned manifest change remains explicit; later route cardinality can evolve |
| Supplied estimands only | RRP release required for a new quantity | Maintains scientific/executable coherence while real extension requirements are gathered |
| Installed estimand catalog abstraction | Some generalization before a second estimand | Justified because project selection, provider routing, provenance, and removal of hard-coded identity already require resolution |
| Request-builder identity/provenance | Additional contract/version bookkeeping | Necessary to answer which executable semantics produced requests |
| Static compatibility before source | Declarations may overstate actual data availability | Preserve dynamic request/state checks after admission; do not treat static checks as proof of actual input |
| In-memory registration caching | Code changes are not picked up mid-process | Context is an immutable operation snapshot; new process/load sees changes and new provenance |
| No registration sandbox | Trusted code can perform arbitrary actions | Honest trust model, reviewed explicit project root, no remote/ambient discovery; conformance is not security |
| Defer multi-estimand | Later identities/contracts may need version changes | Include exact estimand identity in new component/route/provenance design now; do not promise compatibility prematurely |

Every accepted extension cost protects a demonstrated need: hospitals must own
source mapping and providers, while RRP must retain quantity definition,
compatibility, execution, and attribution. No comparable evidence currently
justifies project estimands, fallback routing, or multi-estimand execution.

## Remaining decisions

### Blockers for the implementation plan

The estimand/registration architecture is sufficiently closed. The remaining
blockers now belong to the expected package/dependency/build assessment:

1. Confirm the user-facing package plus `rrpruntime` topology or choose
   consolidation, including coordinated version compatibility.
2. Define the exact installed asset/catalog inventory and lookup mechanism.
3. Define project component dependency metadata, supported environment evidence,
   and whether/how `renv` is the default rather than a semantic requirement.
4. Define clean installation and project/provider dependency acceptance.
5. Define artifact/deployment dependency closure and representation of installed
   or local component packages.

After that assessment, target architecture synthesis can finalize the manifest
and registration-result schemas using the decisions here.

### Safe deferrals

- Project-authored estimands and scientific approval workflow.
- Constrained declarative estimand families.
- Multiple selected estimands or per-run selection changes.
- Multiple providers, fallback, ensembles, ranking, and routing policy.
- Multi-estimand history identity/query migration and app presentation.
- Custom product/app plugins.
- Non-R/remote providers and secrets/network contracts.
- Existing `v0.1.0` history migration.
- Public Hospital repository disposition after installed project initialization.

## Recommended next task

This assessment closes estimand composition and trusted project registration
sufficiently for the first implementation generation. No additional analytical
composition assessment must precede packaging work.

Proceed next to the planned **package/dependency and build-reproducibility
assessment**. It should test the provisional user-facing-package plus
`rrpruntime` direction against exact source/resource inventories, dependency
classes, project-owned environments, clean installation, example/adopter
composition, and reduced artifact/Connect closure. It should preserve the
supplied-only single-estimand policy and closed producer/provider registration
result established here.

Only after that assessment should RRP synthesize the target architecture,
finalize versioned project/registration contracts, and produce an implementation
plan.

## Validation posture for this assessment

This assessment changes Markdown architecture, navigation, and implementation
history only. Direct code/contract inspection answered the architectural
questions; executing current tests would demonstrate existing behavior already
recorded by `v0.1.0`, not validate the prospective policy choice.

Validation is therefore limited to documentation/navigation checks, direct
diff and scope inspection, Markdown trailing-whitespace inspection, and `git
diff --check`. Historical Phase 0–11, Hospital distribution/acquisition,
release, publication, and unrelated runtime suites are intentionally not run.
