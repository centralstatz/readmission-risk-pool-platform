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

**Phase 2 canonical implementation boundary complete.** The repository contains the
common YAML specification envelope, pre-1.0 compatibility policy, foundational
identity/time vocabulary, and a representation-independent canonical bundle
contract plus the first clinical profile: discharge episode, optional source
baseline risk, and optional longitudinal episode events. Structured conformance
covers fields, keys, relationships, capabilities, controlled values, episode
windows, terminal outcomes, and dual-time availability. No substantive
platform runtime, synthetic generator, provider, persistence layer, product
builder, Shiny application, deployment tooling, or CI/CD has been implemented.

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
4. Read the [Specification Foundation](docs/architecture/specification-foundation.md)
   for the shared contract vocabulary.
5. Read the [Canonical Bundle Foundation](docs/architecture/canonical-bundle-foundation.md),
   [Initial Canonical Clinical Profile](docs/architecture/canonical-clinical-profile.md),
   and [platform specifications](contracts/README.md) for the current handoff.
6. Read [Reference Asset Reconciliation](docs/architecture/reference-asset-reconciliation.md)
   before considering material from the sibling repository.
7. Read the [Implementation Record](docs/architecture/platform-implementation-record.md)
   for what has actually happened.

The [documentation start page](docs/START-HERE.md) provides an ordered review,
and the [documentation index](docs/README.md) lists all current documents.

## Validate the repository

The complete human procedure and claim boundaries are documented in the
[validation operation](docs/operations/validation.md). Run in-progress checks
with:

```sh
Rscript operations/validate.R --mode development
```

Evaluate the completed Phase 2 checkpoint with:

```sh
Rscript operations/validate.R --mode checkpoint
```

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
The [current license status](LICENSE-STATUS.md) explicitly authorizes no public
release or implied license grant; final licensing and contribution policy
remain unresolved.
