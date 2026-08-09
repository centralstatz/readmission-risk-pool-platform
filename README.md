# Readmission Risk Pool Platform

Readmission Risk Pool is an open-source implementation platform for hospital
readmission management. It is intended to connect discharge episodes,
longitudinal post-discharge evidence, governed risk estimates, operational
decisions and work, outcomes, and measure lineage through replaceable,
well-documented interfaces.

This repository is the active clean implementation. It is being designed from
the documented product direction rather than migrated around the directory
structure of the earlier implementation. The sibling `readmission-risk-pool`
repository remains development-time reference evidence only and is never a
runtime or test dependency.

## Current status

**Architecture bootstrap only.** The repository currently contains governing
documentation, the clean target architecture, the phased implementation plan,
and a reconciliation of possible reference assets. No substantive platform
runtime, synthetic generator, provider, persistence layer, product builder,
Shiny application, deployment tooling, dependency environment, or CI/CD has
been implemented here yet.

The platform is not clinically validated, production-ready, or approved for
patient care.

## Direction

The intended first working realization will use a deterministic, visibly
fictional synthetic health system. It will exercise the same canonical
boundary, runtime, provider, history, products, application, and deployment
interfaces expected of an adopter. Generic code will not contain a privileged
synthetic mode.

One deployment represents one health system. The supplied Shiny application
will be an important interface, but it will not define the platform. Posit
Connect Cloud will be the reference deployment target, not a core dependency.

## Start here

1. Read [Platform True North](docs/vision/platform-true-north.md) for product
   identity and durable principles.
2. Read [Platform Architecture](docs/architecture/platform-architecture.md) for
   layers, dependency direction, prohibited dependencies, and the proposed
   repository structure.
3. Read the [Implementation Plan](docs/architecture/platform-implementation-plan.md)
   for the clean-build phases.
4. Read [Reference Asset Reconciliation](docs/architecture/reference-asset-reconciliation.md)
   before considering material from the sibling repository.
5. Read the [Implementation Record](docs/architecture/platform-implementation-record.md)
   for what has actually happened.

The [documentation start page](docs/START-HERE.md) provides an ordered review,
and the [documentation index](docs/README.md) lists all current documents.

## Authority

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

Reference evidence never enters this chain merely because it already exists.
Future reuse follows target requirement → clean design → inspect evidence →
reuse, adapt, reference, or reject.

## Contributing at this stage

Follow [AGENTS.md](AGENTS.md) and the
[implementation conventions](docs/development/implementation-conventions.md).
Open decisions are tracked in [Open decisions](docs/architecture/open-decisions.md).
Licensing and public contribution policy remain unresolved; do not assume a
license grant until maintainers select and add one.
