# Readmission Risk Pool

Readmission Risk Pool (RRP) is an open-source implementation platform for
hospital readmission management. Its intended 1.0 product connects hospital-
owned source implementations, a governed canonical boundary, one defined
remaining day-30 readmission-risk target, replaceable model providers,
attributable operational history, logical products, a supplied application,
and portable deployment builds.

## Current state

This repository is the clean implementation line for RRP 1.0. Its current
development identity is `1.0.0-dev`, with [RRP.yml](RRP.yml) as the sole
machine-readable product-development identity authority.

The repository presently contains product and architecture documentation plus
public repository essentials. It has no installable software, package,
hospital project, clinical contract, runtime, product, application, command-
line interface, or deployment capability. Nothing here is a released 1.0.0
product or an approved clinical system.

The published `v0.1.0` release remains immutable historical evidence in Git.
The 1.0 implementation may selectively reuse proven historical work, but it is
being constructed directly around the accepted 1.0 architecture rather than
restoring the former source tree.

## Governing documents

Read the active authority in this order:

1. [Platform True North](docs/platform-true-north.md) — why RRP exists;
2. [Platform Architecture](docs/platform-architecture.md) — what the completed
   RRP 1.0 system must be;
3. [Implementation Plan](docs/platform-implementation-plan.md) — how RRP 1.0
   will be built; and
4. [Implementation Record](docs/platform-implementation-record.md) — what the
   clean 1.0 line has actually built.

## Safety and maturity

RRP 1.0 is not implemented, released, clinically validated, production-ready,
or authorized for patient care. Do not place patient data, credentials,
connection strings, private hospital mappings, raw records, or confidential
business material in this repository or public reports.

See [SECURITY.md](SECURITY.md) for vulnerability reporting and
[SUPPORT.md](SUPPORT.md) for the current support boundary.

## Contributing

The [RRP 1.0 implementation guidance](docs/implementation-guidance.md) defines
the human development method, current source ownership, and evidence boundary.
Contributions are welcome when they follow that guidance and the current
accepted increment; see [CONTRIBUTING.md](CONTRIBUTING.md). Coding agents must
also follow the derived [working agreement](AGENTS.md).

## License

Repository-authored material is licensed under the
[Apache License 2.0](LICENSE). Copyright and attribution information appears
in [NOTICE](NOTICE).
