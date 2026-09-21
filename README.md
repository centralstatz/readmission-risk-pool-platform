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
A closed base-R DCF source catalog now declares its schema, common result and
diagnostic contracts, exact project contracts, the initial canonical
specification family, all five singular runtime contracts, the two minimal-
project templates, and the project-state, DuckDB-adapter, and backup authorities, with a
temporary deterministic installed-projection proof.
`rrpplatform` transactionally initializes an absent independent project and
loads it from separate explicit software and project contexts, executing only
its fixed trusted registration boundary and resolving exact semantic
producer/provider selections without invoking them during loading. It reports the same
loader-owned assessment through a bounded project doctor. Producer declarations
now identify the exact canonical profile, bundle, implementation, mapping, and
required available capabilities, while providers declare exact target, state,
request, estimate, implementation, and nullable model compatibility. One
supported operation now executes exactly the selected producer once
through a closed request/result contract and delegates a successful detached
candidate to runtime admission. A second operation prepares one eligible
episode state and invokes exactly the explicitly selected compatible provider
once, returning an accepted in-memory estimate. Projects may select the
protected installed nonclinical transparent provider or a compatible
project-owned provider; no provider is selected by default.
`rrpruntime` provides the three pure dependency-light computation primitives—
canonical admission, eligible episode-state preparation, and direct compatible-
provider execution—and now also owns storage-neutral logical operational-
history records, a small port, completeness, and raw/current interpretation. It validates exact identity,
capability, closed-domain, key,
relationship, explicit-offset time, dual-time, and 30-elapsed-day rules and
returns detached in-memory admitted bundles and immutable target-specific
episode states, or bounded typed failures. State preparation requires the
bundle cutoff and analytical as-of to denote the same instant, admits only
`D <= t < W30`, and rejects episodes already readmitted or dead through the
available-information cutoff. `rrpplatform` now explicitly initializes and
inspects a project-owned two-file state root and privately realizes the logical
history port through bounded DBI/DuckDB sessions with exact transactional
append and close/reopen behavior. Normal producer/risk computation still
writes nothing. An explicit durable operation now owns one admitted-bundle
scope, terminal episode dispositions, deterministic continuation, bounded
history inspection, explicit retry, and append-only correction. The repository
also supports explicit create-only checkpointed state backup and restore into
an absent compatible project state. It has no root selector, persistent
installed RRP distribution, scheduled/off-host backup, migration, product,
application, command-line interface, or deployment capability.
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

This operation checks the closed source catalog/schema/contracts, including
the exact canonical specification family, all five singular runtime
authorities, and their cross-references,
resource/path safety, source closure, deterministic byte-preserving temporary
installed projection, explicit-root access through the installed main package,
common result/diagnostic behavior, strict project-contract behavior, explicit
trusted project loading, transactional minimal-project initialization, exact
semantic producer and structural provider selection, structured project
diagnosis, selected producer execution through two materially different
fictional hospital mappings, copied-project portability, typed privacy-safe
project/resource failures, adversarial rejection behavior, and direct
installed-authority/runtime canonical admission, exact single producer
invocation, selected provider execution through both installed transparent and
project-owned implementations, process restoration, copied-project behavior,
and no project/state mutation. It also checks runtime eligibility, immutable
episode state, standard request, direct semantic-provider execution, minimal
result, and accepted estimate behavior. Package-native checks additionally
prove explicit state initialization/inspection, compatibility, private
DuckDB-port roundtrip, transactions, interruption, copied-project reopen, and
writer exclusion. The operation also checks exact package topology,
metadata, one-way dependency, exports, source independence, builds,
dependency-order isolated installation/loading, package-native tests, and exact
`R CMD check --no-manual` results. It is maintainer evidence, not a root
selector, product command, distribution build, proof of clinical validity,
deployment, or release behavior.

The [package-foundation workflow](.github/workflows/package-foundation.yml) is
configured to run these same two human operations on pushes and pull requests
under read-only Ubuntu/R 4.4. Its first committed push run completed
successfully for the accepted 2.C revision. A later committed push run
completed successfully for the complete Stage 3 revision, so Stages 1–3 are
accepted and complete. This narrow hosted evidence does not establish broader
platform or support validity. The complete Stage 4 revision also passed the
same hosted workflow and has been formally accepted, so Stages 1–4 are complete.
The initializer, loader, doctor, and producer operation are internal technical
interfaces; ordinary operator commands remain absent. The complete Stage 5
revision passed the same hosted workflow and has been formally accepted, so
Stages 1–5 are complete. The complete Stage 6 revision also passed the hosted
workflow and has been formally accepted. The complete Stage 7 revision passed
the same hosted workflow and its architecture reconciliation, so Stages 1–7
are accepted and complete. Stage 7 provides logical history, explicit project
state and DuckDB, durable execution/history interpretation, and bounded backup/
restore. Stage 8 is detailed in the implementation plan and awaits review and
acceptance; no Stage 8 source implementation has begun.

## License

Repository-authored material is licensed under the
[Apache License 2.0](LICENSE). Copyright and attribution information appears
in [NOTICE](NOTICE).
