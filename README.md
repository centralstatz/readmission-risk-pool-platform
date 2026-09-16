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

The repository presently contains product and architecture documentation,
public repository essentials, human development guidance, one local
repository-foundation validator, and two conventional internal package owners.
A closed base-R DCF source catalog now
declares its schema plus the common operation-result and diagnostic contracts
and has a temporary, deterministic installed-projection proof. `rrpplatform`
depends only on `rrpruntime` and exports explicit-root catalog opening,
logical resource resolution, structured software-resource validation, and a
success predicate; `rrpruntime` remains export-free. The repository has no
root selector, persistent installed RRP distribution, hospital project,
clinical contract, risk calculation, product, application, command-line
interface, or deployment capability.
Nothing here is a released 1.0.0 product or an approved clinical system.

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

## Local validation

From the repository root, a human can validate the current source-foundation
claims with:

```sh
Rscript --vanilla tools/validate-repository.R
```

The command checks only the current repository structure, local documentation
links, development identity, legal/public metadata, machine-readable metadata,
path and text hygiene, and obvious generated or confidential content. It does
not validate package lifecycle behavior, a project, clinical contract, runtime,
installation, deployment, or release. Automated screening cannot replace human
review for patient-level or confidential information.

Validate the local package and source-resource foundation with:

```sh
Rscript --vanilla tools/validate-packages.R
```

This operation checks the closed source catalog/schema/contracts,
resource/path safety, source closure, deterministic byte-preserving temporary
installed projection, explicit-root access through the installed main package,
common result/diagnostic behavior, privacy-safe resource failures, and
adversarial rejection behavior. It also checks exact package topology,
metadata, one-way dependency, exports, source independence, builds,
dependency-order isolated installation/loading, package-native tests, and exact
`R CMD check --no-manual` results. It is maintainer evidence, not a root
selector, product command, distribution build, or proof of runtime, clinical,
deployment, or release behavior.

The [package-foundation workflow](.github/workflows/package-foundation.yml) is
configured to run these same two human operations on pushes and pull requests
under read-only Ubuntu/R 4.4. Its first committed push run completed
successfully for the accepted 2.C revision. Stage 2 and local Increments
3.A–3.C are complete; Stage 3 still awaits committed hosted evidence and final
acceptance/reconciliation. The prior narrow hosted evidence does not establish
broader platform or support validity.

## License

Repository-authored material is licensed under the
[Apache License 2.0](LICENSE). Copyright and attribution information appears
in [NOTICE](NOTICE).
