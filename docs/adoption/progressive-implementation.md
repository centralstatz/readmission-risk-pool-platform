# Progressive implementation and component replacement

## Purpose

The shipped fictional reference composition is usable before any hospital
component exists. An adopter can then replace implementation-owned pieces one
at a time while keeping the platform operable. The stages below are examples,
not a mandatory sequence; every replacement enters through the same approved
contract and conformance boundary as the reference peer.

## Example progression

| Stage | Composition |
|---:|---|
| 0 | Entire fictional reference source, provider, DuckDB, YAML products, and Shiny app |
| 1 | Hospital source mapping + reference provider + DuckDB + reference products/app |
| 2 | Hospital source + conforming hospital provider + DuckDB + reference products/app |
| 3 | Hospital source/provider + conforming hospital persistence + reference products/app |
| 4 | Build the target-neutral reduced app artifact; customize conforming products/app as needed |
| 5 | Realize that validated artifact for an approved deployment target when supported |

Source, provider, persistence, product materialization, application, and later
deployment can change independently. A working combination must remain
identity-, compatibility-, capability-, and temporally coherent; progressive
replacement does not authorize silent mixtures or named exceptions in generic
code.

## Concrete source-adoption sequence

1. Obtain the platform and restore the supported environment.
2. Run the shipped synthetic reference implementation unchanged.
3. Confirm source → canonical → estimation → history → products → app →
   deployment-artifact plumbing.
4. Develop an adopter-owned callable and declaration satisfying
   `platform.canonical-producer@0.1.0`.
5. Register it explicitly in trusted installation composition and run
   `Rscript operations/validate-producer.R` using an approved fictional or
   controlled conformance scenario.
6. Change the exact single selection in `config/platform-instance.yml` only
   after conformance.
7. Continue to use the unchanged runtime/provider, persistence, products, app,
   and deployment operations.

Iteration 10.1 implements Steps 1–3 and supplies the interface, trust,
selection, and conformance machinery required by Steps 4–6. Iteration 10.2
must prove those steps with a materially different fictional adopter producer.
Turnkey hospital onboarding is therefore not yet claimed.

## Source responsibility

The local source implementation owns hospital/EHR meaning: extraction, joins,
identifier construction, status/code translation, timestamps, availability,
source validation, and mapping provenance. It may use SQL, dbt, warehouse
views, R, Python, or an approved service. Its public obligation is a conforming
approved canonical bundle/profile. Replacing source mapping must not require
changes to generic runtime, provider, persistence, products, or app logic.

The generic producer declaration, trusted callable registry, installation
selection, result, admission, and conformance surface are implemented. A
hospital-owned producer must keep extraction/configuration/secrets beneath its
callable boundary; YAML cannot load its code. Final physical packaging of that
code remains open until Iteration 10.2/Phase 11 evidence. Work with real data
also requires approved privacy, security, governance, and clinical-use controls
beyond software conformance.

## Provider responsibility

The estimand defines what quantity is estimated; the provider defines how. An
adopter can keep the transparent nonclinical reference provider while first
wiring source and local operation, then register a trusted hospital-specific
provider conforming to the same selected estimand. A provider may declare
stronger inputs but cannot redefine population, horizon, event, terminal, or
output meaning. Clinical validation and authorization remain adopter-owned.

## Persistence responsibility

DuckDB is the single-writer local reference implementation of the platform's
backend-neutral history port. An adopter may keep it where suitable or replace
it with a conforming adapter. Hospital source storage and platform operational
history storage are independent:

```text
Snowflake source → canonical → generic platform → DuckDB history
Snowflake source → canonical → generic platform → hospital persistence adapter
```

A replacement owns its connections, transactions, schema, migration,
retention, concurrency, backup, and recovery while preserving the port's
append/idempotency/conflict/invalidation/read semantics.

## Product and application responsibility

Logical products are rebuildable projections over retained valid history.
YAML is the reference physical materialization, and Shiny is the supplied
product-only app. Either may evolve or be replaced without changing historical
records or rerunning providers. A replacement app or materializer must consume
the logical product boundary and must not query sources, reach into persistence
tables, invoke providers, or reinterpret canonical meaning.

## Automation and deployment

Scheduling remains outside the platform. External approved automation invokes
the same documented operations used by humans. Iteration 8.1 supplies a
reduced validated application artifact after product materialization;
Iteration 8.2 proves a Connect Cloud local Git realization without changing
upstream semantics. The artifact itself assumes neither Git, Connect Cloud,
nor a container. A future OCI/container target may consume it as a peer.
Remote publication/deployment remains operator controlled and must not be
folded into source, provider, persistence, product, or app replacement.
