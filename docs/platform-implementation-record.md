# RRP 1.0.0 implementation record

## Status

This record begins with the clean RRP 1.0 implementation baseline. The active
tree intentionally began with only the accepted Platform True North and
Platform Architecture; no RRP 1.0 software was implemented at that point.

The published `v0.1.0` implementation and the superseded pre-reset 1.0
development line remain preserved in Git history and are not reproduced here.
They may be inspected for selective reuse, but they are not current authority.

## Clean implementation baseline

- **Target generation:** RRP 1.0.0
- **Clean-reset revision:** `815fcc2`
- **Why authority:** [Platform True North](platform-true-north.md)
- **What authority:** [Platform Architecture](platform-architecture.md)
- **Construction authority:** [Implementation Plan](platform-implementation-plan.md)
- **Historical reference release:** immutable tag `v0.1.0`
- **Development strategy:** clean-forward construction with selective,
  stage-local reuse of proven historical implementation and tests
- **Initial capability:** documentation authority only; no installed software,
  project, runtime, history, product, app, CLI, or deployment exists

## Planning foundation — 2026-09-15

The two surviving authorities were read in full and minimally corrected for
the post-reset time: nonexistent current plans, records, assessments,
transition state, old source, development-version metadata, and obsolete
documentation paths are no longer implied to exist. Their substantive RRP 1.0
product and architecture decisions were preserved.

Bounded Git reconnaissance inspected the `v0.1.0` tree and the later pre-reset
package/resource work. It confirmed credible reuse candidates in canonical
validation, provider execution, temporal runtime primitives, operational
history and DuckDB, structured results, products/YAML, the Shiny app,
artifact/integrity machinery, the fictional source, and invariant-focused
tests. It also confirmed that repository-root execution, Phase chronology,
Hospital-repository delivery, temporary runtime installation, daily-hazard
public semantics, and coexistence-only compatibility machinery do not belong
in the clean design.

The high-level roadmap was created from the cleaned authorities. Only Stage 1
was decomposed. No historical source was restored and no Stage 1 functionality,
package, test, validation operation, CI, dependency environment, CLI, project,
resource catalog, application, or deployment machinery was created.

Review before Stage 1 implementation simplified its sequence to three
increments. Stage 1 validation is now a small local repository check; hosted CI
is deferred until Stage 2 has executable package build/check/test behavior.
Stage acceptance and reconciliation remain the normal progressive-planning
lifecycle after Increment 1.C rather than a separate implementation increment.

## Stage 1 — Repository and development foundation

### Increment 1.A — Product identity and public repository essentials (complete, 2026-09-15)

Increment 1.A established `RRP.yml` as the single machine-readable product-
development identity: `readmission-risk-pool-platform` at `1.0.0-dev`, with
status `not_released`. The new README describes the intended product, current
documentation-only capability, authority order, historical boundary, safety
limits, contribution path, and Apache-2.0 license without advertising an
installation or released 1.0 product.

The standard Apache-2.0 `LICENSE`, CentralStatz `NOTICE`, and small
`.editorconfig` were reused byte-for-byte from `v0.1.0` after reviewing the
historical license assessment, repository origin, authorship history, current
year, and absence of new bundled third-party material. `SECURITY.md`,
`SUPPORT.md`, and `CONTRIBUTING.md` were adapted to the unreleased,
non-executable clean line. The old release-specific README, support matrix,
validation commands, broad ignore rules, `RELEASE.yml`, `LICENSE-STATUS.md`,
and changelog were rejected as temporally false or premature. The manually
added `.gitignore` retains only `.DS_Store`; its missing final newline was
normalized without adding speculative rules.

Static review confirmed the exact three-field YAML identity, byte-identical
license and notice reuse, complete local Markdown links, the intended 13-file
tree, no tracked symbolic links, text-format hygiene, and a clean
`git diff --check`. Public documentation consistently states that 1.0 is
unreleased and no package or operational validation is claimed.

**Current implementation state:** Increment 1.A complete; Stage 1 in progress.
There is still no installable software, package, project, clinical contract,
runtime, history, product, application, CLI, validator, CI, dependency
environment, or deployment capability.

**Next task:** implement only Increment 1.B — Human development and ownership
rules.

### Increment 1.B — Human development and ownership rules (complete, 2026-09-15)

Increment 1.B added `docs/implementation-guidance.md` as the concise human
guide for authority, progressive increment work, just-in-time historical
reuse, current ownership, readable implementation, explicit context and
dependency ownership, privacy, proportional evidence, and record discipline.
It defines responsibilities only for the 15 files that now exist and requires
future paths to enter with an accepted concrete owner; it does not reserve or
scaffold later package, contract, project, test, application, operation,
artifact, deployment, or build trees.

The new root `AGENTS.md` is a short derivative working agreement. It directs
coding agents to the same authority, human guide, increment boundary, reuse
method, privacy rules, and evidence available to maintainers. It introduces no
agent-only logic, operation, or recovery path. `CONTRIBUTING.md` now serves as
the public entry point and delegates detailed development rules to the human
guide; the README links both the human guide and the derived agent agreement.

Historical review covered the `v0.1.0` and pre-reset `AGENTS.md`, implementation
conventions, repository policies, and pre-reset Stage 1 implementation record.
Authority order, bounded work, human-readable R, direct ownership,
just-in-time reuse, dependency separation, explicit context, privacy, and
proportional evidence were adapted. Phase commands and ownership, validation
registries/profiles, transition-ledger rules, old source paths, executable
component status, Hospital/release procedures, temporary compatibility, and
dependency-environment details were rejected. No historical guidance file was
copied wholesale.

Documentary review confirmed the exact current inventory and ownership map,
complete local links, consistent authority order and `1.0.0-dev` identity, no
stale workflow/path references, no symbolic links, final-newline and whitespace
hygiene, and a clean `git diff --check`. The plan's stale top-level statement
that Stage 1 was not yet implemented was corrected to `in progress`; no
roadmap, increment, or architectural decision changed.

**Current implementation state:** Increment 1.B complete; Stage 1 remains in
progress. There is still no package, project, clinical contract, runtime,
history, product, application, CLI, validator, test suite, CI, dependency
environment, installation, artifact, or deployment capability.

**Next task:** implement only Increment 1.C — Minimal repository validation.

### Increment 1.C — Minimal repository validation (complete, 2026-09-15)

Increment 1.C added `tools/validate-repository.R` as one human-callable,
base-R maintainer operation. From the repository root,
`Rscript --vanilla tools/validate-repository.R` resolves its own source owner,
runs seven bounded repository-foundation checks, renders each category and its
issues in plain language, summarizes the result, and returns status zero only
when every check passes. It is a single script with no registry, profiles,
changed-path routing, shared validation framework, package dependency, Git-
state requirement, sibling checkout, network use, or installed-product role.

The operation checks the exact current owned file and directory inventory;
repository-local Markdown targets and heading fragments; the limited
parseability and exact three-field meaning of `RRP.yml`; agreement on product
identity, `1.0.0-dev`, and unreleased status; current Apache/notice/security/
support/contribution/README/editor/ignore assertions; path, symlink, line-ending,
final-newline, trailing-whitespace, and case-collision hygiene; and obvious
generated-output, secret-file, private-key, access-key, and token indicators.
It states explicitly that automated screening cannot prove the absence of
patient-level or confidential information and therefore does not replace human
review.

The README, contribution guide, human implementation guide, and derived agent
agreement now document the same command and narrow evidence boundary. The
ownership map adds only the concrete `tools/validate-repository.R` path. The
new `tools/` directory exists solely because that maintained file owns current
development validation; no empty future tree was introduced.

Historical review at immutable tag `v0.1.0` inspected
`operations/validate-documentation.R`,
`operations/lib/documentation-validation.R`,
`operations/lib/repository-validation.R`, and
`operations/lib/validation-result.R`. Script-relative root discovery,
actionable categorized output, repository-local link parsing, non-traversal of
linked directories, and bounded obvious-secret screening were adapted as
useful mechanics. The multi-file result framework, required-document graph,
Phase checkpoint, broad product/repository policies, sibling exception list,
validation registry/profiles, release checks, and historical path assumptions
were rejected. No historical source file was copied wholesale.

Focused evidence passed the documented command with seven checks and zero
issues. Independent temporary repository copies demonstrated status 1 and an
actionable category for a missing foundational file, malformed development
metadata, a symbolic link, a missing local-document target, and generated
output. A sensitive-looking `.env` fixture was also rejected. Direct R parsing,
repository inventory/symlink review, local-link and development-metadata review,
text hygiene, and `git diff --check` completed successfully after the record
and status updates.

### Stage 1 acceptance and reconciliation (complete, 2026-09-15)

The complete Stage 1 acceptance criteria were reviewed separately from the
validator result. The four-document authority chain is intact and linked; the
sole machine-readable development authority reports
`readmission-risk-pool-platform`, `1.0.0-dev`, and `not_released`; public/legal
files and text policies agree with the clean line; human, contributor, and
agent guidance share one development method; all 16 files and both non-root
directories have current owners; and the documented local operation passes
without product source, Git publication state, external services, secrets, or
historical infrastructure. Human review confirmed why each current path
exists and that the repository claims only its implemented foundation.

Reconciliation found no conflict with Platform True North or Platform
Architecture. The result preserves honest maturity, human-first operation,
privacy-conscious evidence, direct source ownership, proportional validation,
and separation of development tooling from future installed RRP software. No
roadmap dependency or architectural assumption changed. The exact Stage 1
inventory is intentionally closed; the next accepted stage must update this
validator and ownership map only as concrete new owners are introduced.

**Current implementation state:** Stage 1 complete. RRP has a truthful
development identity, public repository essentials, maintainable working
rules, and a small repository-validation path. It still has no installable
package, project, clinical contract, runtime, history, product, application,
CLI, dependency environment, CI, installation, artifact, deployment, or
release capability.

**Next task:** detail and accept Stage 2 before beginning its source
implementation.

## Stage 2 detailed-plan acceptance — 2026-09-15

Stage 1 remains complete and its repository validator passes unchanged. The
realized 16-file source map, closed validator inventory, human-first operation,
base-R/dependency restraint, and absence of packages, tests, CI, dependency
environments, or installed-product machinery were reconciled as the concrete
starting constraints for Stage 2. No Stage 1 inconsistency required correction.

The existing high-level package-foundation objective was detailed and accepted
as three implementation increments: establish the dependency-light
`rrpruntime` leaf package; add the main `rrpplatform` package and repeatable
local two-package proof; then run those same human operations in one
least-privilege hosted Ubuntu/R 4.4 workflow before stage acceptance. The plan
settles package locations, names, initial development versions, R requirement,
one-way dependency, zero-export starting posture, base-R tests, temporary
build/check/install evidence, no-development-lock decision, and bounded CI
claim. Resource access and every later product responsibility remain deferred.

Historical reconnaissance inspected the `v0.1.0` runtime package and pre-reset
commits `b9672cc`, `d31534a`, `d23e315`, and `855a4b0`. Conventional package
structure, the `rrpplatform` name, base-R build/check and isolated-library
mechanics, boundary assertions, and least-privilege hosted verification informed
the plan. No source was restored. Historical runtime/domain behavior,
compatibility loading, validation registries/profiles, Phase suites, `renv`,
resource/distribution work, and release/deployment behavior were rejected from
the Stage 2 boundary.

**Current implementation state:** Stage 1 complete; Stage 2 detailed and
accepted for implementation; Stage 2 source implementation not started. The
repository still has no internal package, installed resource, project,
clinical contract, runtime calculation, product, application, CLI, dependency
environment, distribution, deployment, or release capability.

**Next task:** implement only Increment 2.A — Dependency-light `rrpruntime`
package owner.

### Increment 2.A — Dependency-light `rrpruntime` package owner (complete, 2026-09-15)

Increment 2.A created `packages/rrpruntime/` as one conventional, loadable,
deliberately behavior-free R package. Its independent internal package identity
is `rrpruntime` version `0.3.0.9000`; it requires R 4.4.0 or newer, uses only
base R package machinery, declares no `Imports`, `Suggests`, or `LinkingTo`, and
exports no callable API. Its manually maintained package source, documentation,
README, and one package-native base-R test state the current narrow boundary
without adding placeholder canonical, eligibility, state, request, provider,
history, resource, project, or product behavior. `RRP.yml` remains the sole RRP
product-development identity at `1.0.0-dev` and `not_released`.

Package metadata uses current verifiable repository facts: the maintainer
identity already present in current Git history, the CentralStatz copyright
holder in `NOTICE`, Apache-2.0 licensing, and the configured GitHub repository
and issue tracker. No historical placeholder contact address was retained.
The current ownership map now assigns each realized package metadata, source,
documentation, and test path. The repository validator's closed inventory now
recognizes exactly the new package root and its three concrete subdirectories;
no ignore rule or speculative future directory was added. README and human/
agent guidance now distinguish this package source from installed RRP software
and from future package-lifecycle tooling.

Historical reconnaissance re-inspected `v0.1.0` `runtime/DESCRIPTION` and
`runtime/NAMESPACE`, plus pre-reset commit `d31534a` package metadata, README,
base-R build/check harness, and package-boundary assertions. Conventional
package layout, manual package documentation, DCF/namespace inspection, source
archive construction, isolated temporary-library installation, fresh-process
loading, package-native check execution, and exact check-log status inspection
were adapted. The historical `0.3.0` behavior and all R files, exports, manuals,
domain tests, daily-hazard semantics, provider/history execution, Phase
ownership, repository-root compatibility loading, temporary installer, joint
two-package harness, and broad validation machinery were rejected from this
increment. No historical source file was restored wholesale.

Focused evidence on R 4.4.1 for macOS arm64 passed: every new R file parsed;
`DESCRIPTION` parsed as DCF with the exact identity, version, R requirement,
Apache license, and absent dependency fields; the manual page parsed; and the
namespace parsed with zero exports. Static inspection found no reverse
`rrpplatform` reference or repository/sibling-discovery code. `R CMD build`
created `rrpruntime_0.3.0.9000.tar.gz` in temporary space; `R CMD INSTALL`
installed it into a new otherwise empty temporary library; and a fresh
`Rscript --vanilla` process loaded that exact installed copy and confirmed its
version and empty export set. `R CMD check --no-manual` ran the package-native
foundation test and completed with exact `Status: OK`. An initial evidence-
harness path assertion compared macOS aliases `/tmp` and `/private/tmp`
textually; normalizing both paths corrected the harness assertion without a
package-source change. All generated validation artifacts were removed.

The expanded human repository operation passed all seven checks with zero
issues. Direct source/dependency/API inspection, repository inventory and
symlink review, and `git diff --check` also passed. No accepted plan or
architecture discrepancy was found.

**Current implementation state:** Increment 2.A complete; Stage 2 remains in
progress. RRP now has one dependency-light, loadable internal runtime-package
owner with no behavior or exports. It still has no `rrpplatform` package, joint
package-validation operation, hosted CI, installed resources, project,
clinical contract, runtime calculation, history, product, application, CLI,
dependency environment, distribution, deployment, or release capability.

**Next task:** implement only Increment 2.B — Main package and local package-
boundary proof.

### Increment 2.B — Main package and local package-boundary proof (complete, 2026-09-15)

Increment 2.B created `packages/rrpplatform/` as the conventional, behavior-
free main internal implementation package at version `0.1.0.9000`. Its
metadata, manual package documentation, README, minimal source, and one base-R
package-foundation test establish only its package identity and the accepted
one-way dependency on `rrpruntime` `0.3.0.9000`. `rrpplatform` declares only
`rrpruntime` in `Imports` and imports its namespace; `rrpruntime` retains no
`Imports`, `Suggests`, or `LinkingTo` and no reverse reference. Both packages
require R 4.4.0 or newer and export no callable API. Their versions remain
independent internal identities; `RRP.yml` remains the sole product-development
identity authority at `1.0.0-dev` and `not_released`.

The new base-R maintainer operation `tools/validate-packages.R` is the single
human-callable local proof for the current two-package foundation. It requires
exactly the two accepted package roots and each package's six conventional
files; parses R, DCF, namespace, and manual sources; checks exact identities,
versions, R requirements, licensing, repository metadata, dependencies, and
zero-export namespaces; rejects package-source repository discovery and the
reverse dependency; builds both source archives in temporary space; confirms
that `rrpplatform` cannot install into an isolated library without
`rrpruntime`; installs the packages in dependency order into a fresh temporary
library; loads each from a fresh vanilla R process; runs both package-native
tests through `R CMD check --no-manual`; and requires exact `Status: OK` in
both check logs. It reports package-by-package outcomes, returns nonzero on
failure, and removes its archives, libraries, check directories, profiles, and
empty local package repository. It is not an installed command, dispatcher,
release check, or product operation.

Historical reconnaissance re-inspected pre-reset commit `d31534a` main-package
metadata, namespace, documentation, source shell, package test, package-
boundary assertions, and build/check harness. The `rrpplatform` name and
version, conventional layout, one-way package topology, base-R tests,
dependency-order temporary installation, fresh-process loading, offline check
profile, exact check-log status, and actionable failure mechanics were adapted.
The historical import and invocation of `runtime_conforms`, old runtime version
expectation, behavior-specific test, placeholder maintainer address,
repository-root source composition, compatibility loading, Phase validation,
and broader registry/profile machinery were rejected. The current namespace
uses only `import(rrpruntime)`, establishing the dependency without inventing
an exported runtime function.

Successful evidence on R 4.4.1 for macOS arm64 passed the documented operation
`Rscript --vanilla tools/validate-packages.R`. Both packages passed source and
documentation parsing, exact static topology and dependency/API checks, source
builds, dependency-order installation into a fresh library, fresh-process
loads, their package-native tests, and `R CMD check --no-manual` with exact
`Status: OK`. The operation also observed a nonzero package-manager failure
when installing `rrpplatform` into a separate empty library where `rrpruntime`
was unavailable.

Three additional copied temporary source trees demonstrated status 1 and the
expected actionable diagnostic for a missing `rrpplatform/NAMESPACE`, a
reverse `rrpruntime -> rrpplatform` `Imports` declaration, and an unexpected
`rrpplatform` export. Those fixtures and all successful-path artifacts were
removed. The expanded repository validator recognizes only the six realized
`rrpplatform` files, its three directories, and the package-validation tool.
The README, contribution guide, human implementation guide, agent agreement,
ownership map, and plan status now describe the same two-package state and
document the exact human command. Final repository validation and normal
path/text/generated-output hygiene passed. No accepted plan or architecture
discrepancy was found.

**Current implementation state:** Increment 2.B complete; Stage 2 remains in
progress. RRP has two conventional, behavior-free internal package owners with
an enforced `rrpplatform -> rrpruntime` dependency, zero exported APIs, and a
repeatable local package-foundation proof. It still has no hosted CI, installed
resource access, common operation result, project, clinical contract, runtime
calculation, history, product, application, CLI, dependency environment,
distribution, deployment, or release capability.

**Next task:** implement only Increment 2.C — Hosted package-foundation
verification.

### Increment 2.C — Hosted package-foundation verification (complete, 2026-09-15)

Increment 2.C introduced one narrowly owned workflow at
`.github/workflows/package-foundation.yml`. On push and pull-request events it
runs one job on `ubuntu-latest`, installs R 4.4, and invokes exactly the two
existing human operations:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
```

The workflow grants only `contents: read`, persists no checkout credentials,
uses no repository secret, and contains no matrix, cache, dependency bootstrap,
artifact handling, manual/legacy mode, registry/profile routing, changed-path
selection, release, deployment, or remote mutation. External actions are
pinned to full immutable revisions: `actions/checkout` v7.0.1 at
`3d3c42e5aac5ba805825da76410c181273ba90b1` and `r-lib/actions` v2.12.1 at
`d3c5be51b12e724e68f33216ca3c148b66d5f0b6`. The workflow's claim is only that
the committed repository and two-package foundation reproduce their existing
human validation in one independent hosted Ubuntu/R 4.4 environment.

Historical reconnaissance inspected `.github/workflows/validation.yml` at
pre-reset commits `d23e315` and `855a4b0` and at immutable tag `v0.1.0`.
Push/pull-request triggers, explicit read-only contents permission, one Ubuntu
job, R 4.4 setup, and calling maintained human validation operations were
adapted. Floating action tags were replaced with verified full commit SHAs and
checkout credential persistence was disabled. Historical `workflow_dispatch`,
legacy profile choices, `ci-active`, validation registries, `renv` setup,
Phase/checkpoint aggregates, and release/deployment vocabulary were rejected.

The repository validator now owns the concrete `.github/` path and an eighth
static policy check that requires the accepted workflow shape. Dependency-light
local YAML parsing succeeded, and direct policy inspection confirmed the exact
push/pull-request triggers, read-only permission, pinned actions, Ubuntu/R 4.4,
two exact commands, and absence of secrets or excluded CI behavior. The
repository and package validators both passed from the working repository;
both packages again built, installed and loaded in dependency order, and
completed `R CMD check --no-manual` with exact `Status: OK`. Normal inventory,
link, path, text, symlink, generated-output, and `git diff --check` hygiene also
passed. No portability defect was found during locally available inspection or
execution, so no package or validation-operation correction was required.

During the local implementation task, README, contribution guidance, human
implementation guidance, the ownership map, agent guidance, and plan status
were aligned to the locally implemented workflow. No commit, push, pull
request, or GitHub Actions run was performed by that task.

The workflow was subsequently committed and pushed as revision
`eb2c71aa8dd7feecb8b98848f798ec18cff0a9fa` (`2.C workflow added`). GitHub
Actions push run [`35041493406`](https://github.com/centralstatz/readmission-risk-pool-platform/actions/runs/35041493406),
job `104622122884`, ran workflow `package-foundation` from
`.github/workflows/package-foundation.yml` and completed successfully on its
first attempt. GitHub's run and job evidence identifies that exact head SHA,
the `push` event, Ubuntu runner, successful R 4.4 setup, and successful
`Validate repository foundation` and `Validate package foundation` steps.
This independently confirms that the committed 2.C workflow exercised the two
existing human operations in the accepted hosted environment.

Inspection of the committed workflow reconfirmed its `contents: read`
permission, disabled checkout credential persistence, immutable action pins,
and absence of secrets, matrices, dependency-environment setup, registry or
profile routing, artifacts, release, deployment, publication, or remote-
mutation behavior. The hosted result therefore satisfies the bounded 2.C
claim without expanding it.

**Current implementation state:** Increment 2.C complete. The successful
hosted run establishes independent execution of the existing repository and
package-foundation validation for the accepted committed revision.

### Stage 2 acceptance and reconciliation (complete, 2026-09-15)

The realized repository was evaluated against every accepted Stage 2
criterion after Increment 2.C closed:

- exactly `packages/rrpruntime/` and `packages/rrpplatform/` are package roots,
  and each owns conventional metadata, namespace, source, documentation, and
  a base-R package-native test;
- `rrpplatform` depends only on and namespace-imports `rrpruntime`, while
  `rrpruntime` has no `Imports`, `Suggests`, or `LinkingTo` dependency and no
  reverse main-package reference;
- package identities and development versions remain independent of the
  `1.0.0-dev` RRP product identity in `RRP.yml`;
- both namespaces export zero callable APIs and contain no premature product
  or runtime behavior;
- source and metadata parsing, source builds, isolated dependency-order
  installation and loading, package-native tests, and exact
  `R CMD check --no-manual` `Status: OK` results pass through the repeatable
  human package-validation operation;
- current ownership, closed repository inventory, links, metadata, path,
  symlink, text, generated-output, and confidential-material safeguards pass
  through the repository-validation operation; and
- the committed read-only Ubuntu/R 4.4 workflow successfully ran those same
  two human operations, with the concrete hosted identity recorded above.

No installed-resource lookup, common structured operation result, hospital
project, clinical contract, risk calculation, history, product, application,
CLI, dependency closure, distribution, deployment, or release capability is
present. No empty future scaffold or persistent validation output remains.

This result is consistent with Platform True North: it advances a small,
human-operable, testable open-source foundation without overstating clinical
or production maturity. It is also consistent with Platform Architecture:
the two final internal package owners and one-way dependency are established,
while installed resources, explicit software context, projects, domain
contracts, operations, and later lifecycles remain with their future owners.
The package identities do not displace product identity, and the hosted check
does not create a released support cell. No discrepancy, architectural
conflict, acceptance blocker, or material deviation from the accepted Stage 2
plan was found.

**Current implementation state:** Stage 2 complete. RRP now has conventional
internal software/package structure and enforced dependency direction, but it
cannot yet resolve installed resources, recognize a project, or calculate
anything.

**Next task:** detail and accept Stage 3 — Installed resources and shared
operation foundation. Do not begin Stage 3 source implementation before that
detail is accepted.

## Stage 3 detailed-plan acceptance — 2026-09-15

Stages 1 and 2 remain complete. The realized two-package foundation, exact
`rrpplatform -> rrpruntime` dependency, zero-export starting posture, local
repository/package validators, successful hosted package-foundation run, and
closed ownership map were reconciled as Stage 3's starting constraints. No
architectural inconsistency or corrective Stage 1/2 change was found. The tree
still contains no resource catalog, installed resource, explicit software-root
API, project, CLI, dependency environment, or domain behavior.

The high-level Stage 3 objective was detailed and accepted as three increments:
establish a closed base-R DCF source catalog and deterministic installed
projection; add main-package explicit-root catalog opening and logical resource
resolution; then add the minimal common operation-result and privacy-safe
diagnostic contracts and exercise them through a read-only software-resource
validation operation. This is the smallest dependency-ordered sequence that
keeps declaration, access, and operation evidence independently reviewable.

The plan assigns all Stage 3 behavior to `rrpplatform`, consistent with the
architecture's main-package ownership of resource access, stable operations,
and diagnostics. `rrpruntime` remains dependency-light, export-free, and does
not depend upward. The accepted main-package APIs require an explicit software
root and do no current-directory, Git, parent, sibling, environment, launcher,
or installed-version discovery. No new package dependency is planned: base R
DCF, filesystem, condition, and list facilities are sufficient.

The source catalog is intentionally not a distribution manifest. It records
only current logical resources, classes, package owners, formats, source paths,
and intended installed relative paths. A temporary installed projection strips
repository-only source paths for copied-root tests. Complete payload closure,
packages, dependencies, sizes, digests, build provenance, installation, and
release inventory remain later work. The catalog schema itself is the first
truthful resource needed by this boundary; operation-result and diagnostic
contracts enter only with Increment 3.C. No clinical or placeholder resource
is authorized.

Historical reconnaissance inspected pre-reset resource work at `a08cd8e`,
`72f67fb`, and `c459f7d`, including the former catalog/schema, projection,
explicit-root APIs, package-boundary checks, and copied/adversarial tests.
Logical IDs, source/installed separation, explicit-root semantics,
path/link/containment and collision rules, revalidation, typed failure, and
copy independence informed the plan. The 48-entry transitional catalog,
daily-hazard/synthetic resources, compatibility and exclusion ledgers, fixed
count, YAML dependency, old product identity, distribution assumptions, and
Phase/registry integration were rejected.

Reconnaissance also inspected `v0.1.0` conformance/validation and
runtime/estimation result shapes plus the operational-event contracts,
implementation, and privacy tests. Machine-inspectable status, success
inspection, stable codes/severity, ordered diagnostics, bounded messages, and
sensitive-detail rejection were adapted conceptually. Domain-specific issue
tables, operation-run identity, timestamps, lifecycle events, emitters, sinks,
context taxonomies, persistence, metrics, audit, and console frameworks remain
outside Stage 3.

Validation will extend the existing two human operations rather than add a
framework or command. Package-native tests own focused contracts;
`tools/validate-packages.R` owns catalog projection, copied-root/adversarial
access, result/privacy behavior, builds, isolated installation/loading, and
strict checks; and `tools/validate-repository.R` owns the expanded source
inventory and hygiene. The existing read-only hosted workflow needs no design
change and must successfully run those expanded operations for the committed
complete Stage 3 implementation before stage acceptance.

**Current implementation state:** Stages 1 and 2 complete; Stage 3 detailed and
accepted for implementation; Stage 3 source implementation not started. RRP
still cannot resolve a software resource, return a common operation result,
recognize a hospital project, or calculate risk.

**Next task:** implement only Increment 3.A — Closed source-resource catalog
and installed projection contract.

## Increment 3.A — Closed source-resource catalog and installed projection contract (complete, 2026-09-16)

Increment 3.A established the first software-resource authority without adding
installed package behavior. `resources/source-catalog.dcf` is now the closed
maintainer source catalog. It declares catalog identity
`rrp.software-resources@0.1.0`, format `1.0.0`, product
`readmission-risk-pool-platform`, development version `1.0.0-dev`, and status
`development_unpublished`. Its sole resource is the required catalog schema,
owned by `rrpplatform` as `rrp.contract.resource-catalog` with class `contract`
and format `dcf`.

`resources/resource-catalog-schema.dcf` defines the exact source and projected
record fields, fixed source and installed catalog paths, logical-ID expression,
controlled resource classes, package owners and format, and the accepted
uniqueness, case-folding, safe-relative-path, file/directory-conflict, regular-
file, non-link, source-closure, and projection-omission rules. Both authorities
are strict multi-record DCF interpreted with base R. No YAML, JSON, package
dependency, dependency environment, or executable resource content was added.

The existing repository validator now owns the two concrete files and
`resources/` directory and checks their base-R DCF parseability as part of the
closed repository inventory and normal path, symlink, text, generated-output,
and confidential-material hygiene. The ownership map, human guidance, public
orientation, contribution guidance, agent agreement, and plan status were
updated to describe the realized boundary and identify 3.B as next.

The existing package/resource validator now performs substantive maintainer
validation of the schema, source catalog, product-development identity,
controlled values, initial logical mapping, source file state, closed resource
inventory, path uniqueness/case folding and file/directory safety. It creates
only temporary distribution-shaped roots, writes the installed catalog at
`resources/resource-catalog.dcf`, removes only `Source-Path` from resource
records, copies the schema byte-for-byte to its declared installed path, and
revalidates catalog identity, mapping, resource state, closure, and
containment. Two independent projections must have identical paths and bytes;
all projections and fixtures are removed by the validator.

Copied temporary adversarial fixtures prove rejection for missing and unknown
schema/resource fields, unsupported schema/catalog/product identity, duplicate
logical IDs and exact paths, unsafe absolute/drive/home/empty/dot/parent/
backslash/control paths, source and installed case collisions, source and
installed file/directory conflicts, missing/linked/non-regular sources,
undeclared source files, installed-catalog drift, and projected-resource byte
drift. These fixtures never mutate repository authority. Direct base-R parsing
of the validator and both DCF files passed; repository validation passed all
eight static checks; package/resource validation passed all positive and
adversarial resource checks, both package builds, isolated dependency-order
installation/loading, package-native tests, and both exact
`R CMD check --no-manual` `Status: OK` results. Direct inspection reconfirmed
that `rrpruntime` remains dependency-free and export-free and `rrpplatform`
still imports only `rrpruntime` and exports nothing. Normal `git diff --check`,
source-inventory, symlink, and generated-artifact hygiene passed with no
persistent validation output.

Historical reconnaissance used pre-reset revisions `a08cd8e`, `72f67fb`, and
`c459f7d`. Stable logical IDs, explicit source-to-installed mapping, safe path
and containment checks, symlink rejection, uniqueness/case/file-directory
collision checks, deterministic source-path-stripping projection, byte
preservation, and copied adversarial fixtures were adapted and simplified.
The former 48-entry catalog, fixed expected count, compatibility annotations,
exclusion and deferred-role ledgers, daily-hazard and synthetic resources,
YAML representation/dependency, old product version, distribution authority,
and Phase/registry integration were rejected.

No package source, namespace, metadata, or package-native test changed. There
is still no package resource-opening or lookup API, typed resource condition,
structured operation result, persistent installed tree, distribution builder,
hospital project, clinical/domain contract, runtime calculation, provider,
history, product, application, CLI, dependency closure, deployment, or release
capability. The existing hosted workflow was not changed or run; the local
uncommitted 3.A result makes no new hosted claim.

**Current implementation state:** Increment 3.A complete; Stage 3 remains in
progress. The repository has a closed one-resource source catalog and a
deterministic temporary installed-projection contract, while both packages
remain behavior-free with zero exports.

**Next task:** implement only Increment 3.B — Explicit-root resource access.

## Increment 3.B — Explicit-root resource access (complete, 2026-09-16)

Increment 3.B made the installed projection established by 3.A consumable by
installed `rrpplatform` code. The main package now exports exactly
`rrp_open_resource_catalog(software_root)` and
`rrp_resource_path(catalog, resource_id)`. `rrpruntime` is unchanged,
dependency-free, and export-free; `rrpplatform` continues to import only
`rrpruntime` and has no new package dependency.

`packages/rrpplatform/R/resource-catalog.R` owns strict installed DCF parsing,
the exact 3.A schema and projected-catalog contract, safe path and link checks,
closed installed-resource validation, catalog opening, logical resolution, and
typed resource failures. Opening accepts exactly one caller-supplied software
root, rejects missing or linked roots, canonicalizes that root, and reads only
the fixed installed schema and catalog beneath it. It performs no current-
directory, parent, Git, sibling, environment-variable, repository, package-
installation, or installed-version discovery and has no source-catalog or
`Source-Path` fallback.

A successful open returns a list with exact class
`c("rrp_resource_catalog", "list")` and fields `software_root`,
`catalog_path`, `schema_path`, and `catalog`. The stored root and fixed paths are
normalized; the catalog contains only its installed header and installed
resource records. The object is the minimum validated software context needed
for lookup, not mutable general configuration and not an installed-root
selector.

`rrp_resource_path()` accepts only that exact catalog shape and a logical ID
matching the accepted pattern. It reopens and revalidates the schema, catalog,
closed inventory, and resource files beneath the stored explicit root before
each lookup, compares the current validated catalog with the opened state, and
returns only a normalized contained regular-file path for one exact declared
ID. Unknown and malformed IDs, caller mutation, catalog replacement, resource
deletion or link substitution, and invalidated schema/resource state fail
closed rather than returning a stale path.

All resource-access failures inherit from `rrp_resource_error` and contain
exactly a bounded single-line maintainer message, `NULL` call, and stable
lowercase machine code. Root, catalog/schema, catalog-contract, resource-state,
lookup, closed-inventory, and post-open change failures have distinct codes.
Messages do not copy parser conditions, supplied paths or IDs, resource
contents, credentials, secrets, authorization material, connection strings,
or patient-level content. The condition constructor and all parsers,
validators, and path helpers remain internal.

Package-native evidence was added in
`packages/rrpplatform/tests/resource-access.R`. Twelve focused base-R test
groups construct their own temporary installed fixtures and cover successful
open/resolve behavior from an unrelated directory; exact catalog class/shape;
missing, malformed, linked, and unsupported roots/catalogs/schemas; exact field
sets; malformed and unknown IDs; missing, linked, and non-regular resources;
unsafe, case-conflicting, and file/directory-conflicting paths; undeclared
files; malformed or caller-mutated catalog objects; safe error shape and
non-disclosure; and post-open catalog, schema, deletion, and link mutation.
These tests depend only on the installed package and temporary fixture state,
not the repository working directory.

The maintainer package validator now expects exactly the two main-package
exports and all new source, manual, and test files. It builds and installs both
packages in dependency order, projects the source resources into temporary
installed form, changes an independent R process to an unrelated directory
with no Git context, loads `rrpplatform` from the isolated library, opens only
the supplied projected root, resolves `rrp.contract.resource-catalog`, and
compares the resolved bytes with a separately copied expected source. It then
deletes the projected schema after opening and proves lookup returns the typed
`missing_schema` failure without path disclosure or fallback. All temporary
roots, copies, archives, libraries, profiles, and check directories are
removed.

Historical reconnaissance inspected the former implementation and evidence at
pre-reset revision `c459f7d`, principally
`packages/rrpplatform/R/resource-catalog.R`, its two manual pages, and
`tests/software/installed-resource-access.R`. Explicit caller-supplied root
handling, immediate canonicalization, logical lookup, typed conditions,
path/link/containment and closure checks, reopening before lookup, copied-root
proof, and post-open mutation fixtures were adapted. YAML parsing and
dependency, the 48-resource/fixed-count model, distribution-root terminology
and assumptions, compatibility metadata, source-path fallback, old product
identity, repository/Git discovery, parser/path detail in error messages, and
Phase/registry machinery were rejected.

Direct source, namespace, and manual parsing passed. Focused installation and
package-native execution passed all twelve resource-access groups. The complete
human package/resource operation retained every 3.A positive and adversarial
claim; both packages built and installed in dependency order; fresh-process
loads observed the exact export sets; both package checks ended with exact
`Status: OK`; and the installed copied-root, byte-equality, and post-open
mutation proof passed. Repository validation passed all eight checks, and
normal `git diff --check`, source-inventory, path, symlink, and generated-
artifact hygiene passed. The existing hosted workflow was unchanged and no
hosted 3.B claim was made.

No automatic root discovery/selection, CLI, installer, persistent installed
tree, distribution manifest, digest verification, dependency environment,
common operation result, diagnostic record, hospital project, canonical or
clinical contract, risk runtime/provider, history, product, application,
deployment, or release behavior was added.

**Current implementation state:** Increment 3.B complete; Stage 3 remains in
progress. Installed `rrpplatform` code can consume one explicitly supplied
validated installed-resource root and resolve current resources by logical ID,
but it cannot select that root or return a common structured operation result.

**Next task:** implement only Increment 3.C — Common operation result and
privacy-safe diagnostics.

## Increment 3.C — Common operation result and privacy-safe diagnostics (complete locally, 2026-09-16)

Increment 3.C added the final local implementation increment of Stage 3 while
leaving stage acceptance open. The closed source catalog now declares
`resources/contracts/operation-result.dcf` as
`rrp.contract.operation-result` and `resources/contracts/diagnostic.dcf` as
`rrp.contract.diagnostic`. Both are `dcf` contract resources owned by
`rrpplatform`, retain identical source and intended installed paths, and pass
the established source-closure, path, deterministic projection, and projected
byte-equality rules. No fixed resource-count constant replaced catalog
closure.

The diagnostic contract has exact class
`c("rrp_diagnostic", "list")` and exact fields `code`, `severity`, and
`message`. Internal package construction and validation require a bounded
lowercase machine code, exactly one of `info`, `warning`, or `error`, and a
nonempty trimmed single-line maintainer-authored message of at most 240 bytes.
Diagnostics have no arbitrary details/context field. Obvious patient
identifiers, credentials, passwords, secrets, authorization/bearer material,
access tokens/keys, connection strings, private keys, raw input/content, and
filesystem-path-like text are rejected.

The operation-result contract has exact class
`c("rrp_operation_result", "list")` and exact fields `operation_id`,
`status`, `value`, and `diagnostics`. One controlled operation ID describes one
operation; status is exactly `success` or `failure`; diagnostics are an unnamed
ordered list of exact diagnostics. Success permits zero, informational, or
warning diagnostics but no error. Failure requires at least one error
diagnostic and a `NULL` value. No timestamp, run/correlation identity, stage,
duration, metric, provenance, arbitrary metadata, persistence, log, or audit
field was introduced. Constructors and general validators remain internal.

`rrpplatform` now exports exactly `rrp_open_resource_catalog()`,
`rrp_operation_succeeded()`, `rrp_resource_path()`, and
`rrp_validate_software_resources()`. The success predicate validates the full
result contract and returns one exact logical value; malformed result-like
lists are rejected rather than interpreted. The resource-validation operation
uses only the existing explicit caller-supplied root behavior. Success returns
operation ID `rrp.validate-software-resources`, status `success`, no
diagnostics, and only catalog ID, catalog version, and catalog-derived resource
count. Expected `rrp_resource_error` failures are translated narrowly to
status `failure`, `NULL` value, and one error diagnostic that retains the stable
resource code but uses the fixed message `Software resource validation
failed.` It does not copy the condition message, caller path, parser detail,
resource ID/content, or unsafe input; unexpected internal errors are not
hidden by a general condition translator. The two established low-level
resource APIs retain their typed-error behavior unchanged.

Package-native tests cover exact class/field shapes, all accepted severities,
code and text bounds, single-line/trimmed messages, sensitive and path-like
text, malformed and extra fields, ordered diagnostics, exact status and
operation identity, zero/info/warning success, error-free success, required
failure evidence and `NULL` value, malformed predicate inputs, explicit-root
copied fixtures, safe representative resource-error translation, and exact
success-predicate results. The maintainer validator also validates both DCF
contracts exactly, preserves the complete 3.A/3.B adversarial catalog/access
evidence, resolves all three current resources with projected byte equality,
and exercises successful and failed results through installed `rrpplatform`
from an unrelated working directory without repository or Git context. An
initial strict package check exposed a test-fixture ordering error: replacing
the whole catalog produced the earlier `malformed_catalog` failure before the
intended field check. The fixture was corrected to inject unsafe fields into a
complete catalog so it now proves `invalid_catalog_fields` translation without
weakening either contract. A subsequent copied-root harness run exposed an
over-escaped backslash assertion in its generated child-process expression;
the assertion was replaced with an explicit literal-character check. Both
findings were evidence-harness defects and required no package-behavior change.

Historical reconnaissance inspected `v0.1.0` and pre-reset revision `c459f7d`,
principally `operations/lib/conformance-result.R`,
`operations/lib/validation-result.R`,
`operations/lib/observability-operation.R`, the runtime/estimation operation
wrappers, and related diagnostic/privacy evidence. Machine-inspectable status,
predicate inspection, severity-derived success, stable safe codes, bounded
messages, ordering, and adversarial privacy checks were adapted. Candidate and
specification issue tables, domain/analytical result identities, operation-run
correlation, timestamps, attempts, lifecycle events, emitters, sinks,
retention, safe-context/detail taxonomies, console verbosity, persistence,
metrics, tracing, audit, Phase/registry integration, and historical operation
composition were rejected.

The complete local human surface passed after those focused harness corrections.
Repository validation reported eight checks and zero issues. Package/resource
validation proved the exact catalog/schema/contracts, source closure,
deterministic byte-preserving projection, all positive and adversarial
resource cases, exact four/zero export sets, unchanged one-way dependency,
both package builds, rejection of main-package installation without
`rrpruntime`, isolated dependency-order installation/loading, package-native
tests, copied-root success/failure and privacy evidence, and exact
`R CMD check --no-manual` `Status: OK` for both packages. Direct R source,
namespace, DCF, and Rd parsing, `git diff --check`, source inventory, symlink,
path, and persistent generated-artifact hygiene also passed. `rrpruntime`
remains unchanged, dependency-free, and export-free; `rrpplatform` still
imports only `rrpruntime`; the hosted workflow was unchanged and no new hosted
claim was made.

No installed-root discovery/selection, installation identity, CLI, hospital
project/context, canonical or clinical contract, readmission target, risk
runtime/provider/model behavior, analytical run identity, history, product,
application, dependency closure, distribution, deployment, persistent
diagnostic sink, event/logging/metrics/audit framework, or release machinery
was added.

**Current implementation state:** Increment 3.C is complete locally and all
three Stage 3 implementation increments are present. RRP package code can find
declared installed resources and return one small machine-readable,
privacy-safe operation outcome from an explicit software context. Stage 3 is
not yet accepted or complete because the committed hosted evidence and final
True North/Architecture reconciliation have not occurred.

**Next action:** after human review and commit, obtain the successful hosted
`package-foundation` evidence for the committed complete Stage 3 tree, record
its run identity, reconcile the realized Stage 3 boundary with Platform True
North and Platform Architecture, and then accept/close Stage 3. There is no
Increment 3.D, and Stage 4 must not begin before that lifecycle action.

## Stage 3 acceptance and reconciliation (complete, 2026-09-16)

Stage 3 was assessed from clean committed baseline
`11fc44835c0d3862196e1af5d1ef691e781c9688` on `main`, with local `main` and
`origin/main` at that same revision before this record-only closeout work. That
baseline contains the complete 3.A–3.C implementation and no uncommitted source
change. No Increment 3.D was created.

The complete local human surface was rerun from that baseline. Repository
validation passed all eight checks with zero issues. Package/resource
validation passed the exact catalog, schema, and contract checks; deterministic
byte-preserving projection; all positive and adversarial resource cases; exact
package topology, dependency direction, and four/zero export posture; both
source builds; rejection of `rrpplatform` installation without `rrpruntime`;
isolated dependency-order install/load; package-native tests; copied-root
installed access and structured success/failure evidence; and exact
`R CMD check --no-manual` `Status: OK` for both packages. The operation removed
its temporary archives, libraries, projections, fixtures, and check trees.

The committed hosted evidence is GitHub Actions push run
[`35116049077`](https://github.com/centralstatz/readmission-risk-pool-platform/actions/runs/35116049077),
job
[`104861623678`](https://github.com/centralstatz/readmission-risk-pool-platform/actions/runs/35116049077/job/104861623678).
The run used workflow `package-foundation` from
`.github/workflows/package-foundation.yml`, event `push`, branch `main`, head
SHA `11fc44835c0d3862196e1af5d1ef691e781c9688`, run attempt 1, and completed
successfully on 2026-09-16. Its sole `validate` job completed successfully on
Ubuntu with R 4.4; checkout, R setup, repository validation, and package
validation all succeeded. The workflow remained read-only and invoked exactly
the same two documented human operations. This is committed Stage 3 evidence,
not a distribution support-cell, runtime, clinical, deployment, or release
claim.

The realized source-resource inventory contains exactly these logical
identities, all `contract` resources owned by `rrpplatform` in `dcf` format:

- `rrp.contract.resource-catalog` at
  `resources/resource-catalog-schema.dcf`;
- `rrp.contract.diagnostic` at `resources/contracts/diagnostic.dcf`; and
- `rrp.contract.operation-result` at
  `resources/contracts/operation-result.dcf`.

`resources/source-catalog.dcf` is closed over those three current files and
conforms to `resources/resource-catalog-schema.dcf`; there is no fixed expected
resource count. Temporary projection creates the installed catalog, removes
only `Source-Path`, preserves the three identities and source bytes, and does
not establish a final installation layout, distribution inventory, or
distribution lifecycle.

The exact package posture is `rrpruntime` version `0.3.0.9000` with no
`Imports`, `Suggests`, `LinkingTo`, or exports, and `rrpplatform` version
`0.1.0.9000` importing only `rrpruntime`. `rrpplatform` exports exactly
`rrp_open_resource_catalog()`, `rrp_operation_succeeded()`,
`rrp_resource_path()`, and `rrp_validate_software_resources()`. No third-party
package dependency or `renv` environment exists, and both packages remain
internal implementation components rather than the product interface.

Installed resource access requires one explicit caller-supplied software root,
canonicalizes it, validates the projected catalog and closed inventory,
resolves exact logical IDs, and revalidates state before lookup. Copied roots
outside the repository work. Changed or unsafe state fails closed through
stable `rrp_resource_error` conditions. There is no current-directory, parent,
Git, sibling-repository, environment-variable, package-installation,
source-path, or installed-version discovery or fallback.

The realized diagnostic has exact class `c("rrp_diagnostic", "list")` and exact
fields `code`, `severity`, and `message`. Code is bounded to 64 lowercase
letters, digits, or underscores, starts with a letter, and matches
`^[a-z][a-z0-9_]*$`; severity is exactly `info`, `warning`, or `error`; message
is nonempty, trimmed, single-line, maintainer-authored text of at most 240
bytes. There is no context/details field, and validation rejects obvious
patient identifiers, credentials, secrets, authorization material, connection
strings, private keys, raw content, control characters, and path-like payload.
This is a small operation diagnostic, not an observability framework or a
claim of complete privacy/security classification.

The realized operation result has exact class
`c("rrp_operation_result", "list")` and exact fields `operation_id`, `status`,
`value`, and `diagnostics`. One result represents one operation; status is
exactly `success` or `failure`; diagnostics are an ordered unnamed list of
valid diagnostics. Success can carry a value and zero or non-error diagnostics;
failure requires `NULL` value and at least one error. The public predicate
validates the whole object before returning one logical result, so malformed
result-like lists are not silently interpreted. No run/correlation identity,
timestamp, event lifecycle, orchestration, metric, log, trace, audit,
persistence, or arbitrary metadata/context entered.

`rrp_validate_software_resources()` is the first operation using that common
result. Success returns the controlled operation ID, catalog identity/version,
and catalog-derived resource count. Expected typed resource failures become a
valid failure result that preserves the stable resource code and uses one fixed
safe message without copying path, parser, resource, or input detail.
Unexpected internal errors are not caught by a generalized translator. The
explicit-root requirement is unchanged, and the lower-level catalog and lookup
APIs continue to raise typed resource errors rather than being forced through
operation-result wrappers.

Every accepted Stage 3 criterion is satisfied:

- **Closed current catalog and schema — Satisfied.** The three real current
  contract resources are the catalog schema, diagnostic contract, and
  operation-result contract; the source catalog conforms to its versioned DCF
  schema and closure rejects undeclared payload.
- **Exact portable classification — Satisfied.** IDs, classes, owners, formats,
  source paths, and installed paths are exact, unique, safe after case folding,
  non-conflicting, and fully classified.
- **Deterministic projection boundary — Satisfied with documented non-blocking
  clarification.** Projection removes only repository source paths, preserves
  resource bytes and identities, and is temporary evidence rather than a
  distribution manifest or settled final layout.
- **Explicit-root installed access — Satisfied.** Installed `rrpplatform` opens
  and resolves the projected catalog only from its caller-supplied canonical
  root, with no repository, Git, sibling, environment, or working-directory
  discovery.
- **Copied-root and fail-closed behavior — Satisfied.** Independent copied roots
  work; malformed, unsafe, missing, undeclared, escaping, linked, changed,
  case-conflicting, and related invalid states fail with stable safe typed
  resource errors.
- **Package and API boundary — Satisfied.** `rrpplatform` imports only
  `rrpruntime` and exports exactly the four accepted resource/result APIs;
  `rrpruntime` remains dependency-light, export-free, and independent of its
  dependent.
- **Machine-inspectable operation result — Satisfied.** One exact result carries
  controlled success/failure, value, and ordered diagnostics, with whole-object
  validation and predicate inspection that requires no prose parsing.
- **Privacy-safe diagnostic contract — Satisfied with documented non-blocking
  clarification.** Diagnostics use only the bounded code/severity/message
  shape, and evidence rejects arbitrary detail, patient-level, credential,
  secret, connection, raw-content, control, and path-like text. These bounded
  filters do not claim to be a complete privacy/security system.
- **Complete local evidence and hygiene — Satisfied.** Parsing, both documented
  validators, builds, isolated installation/loading, package-native tests, and
  strict package checks passed without persistent generated output.
- **Committed hosted evidence — Satisfied.** Run `35116049077`, job
  `104861623678`, for the exact complete Stage 3 commit identified above.
- **Deferred-capability exclusion — Satisfied.** No installed-root
  discovery/selection, installation identity, launcher, CLI, complete
  distribution manifest/digests, final dependency closure, distribution
  build/install/upgrade, hospital project/context, project
  manifest/registration, canonical or clinical contract, readmission target,
  runtime/provider/model behavior, analytical run identity, operational
  history, logical product, application behavior, deployment, persistent
  diagnostic/logging/tracing/metrics/audit system, or release behavior entered.

Reconciliation found no deviation from Platform True North. The implementation
advances composable, explicit, fail-closed, privacy-aware foundations without
claiming clinical validity, production readiness, or a hospital workflow. It
also matches Platform Architecture: `rrpplatform` owns resource access and
operation evidence; `rrpruntime` remains the downward-only computational leaf;
software context is explicit; stable logical resource identity is independent
of physical layout; diagnostics are structured and safe; and no project,
clinical, runtime, product, distribution, or deployment responsibility was
pulled forward.

Two boundaries are worth carrying into later planning but are not deviations
or blockers: the current installed projection is temporary evidence rather
than a complete installed distribution, and the diagnostic filters enforce the
accepted small obvious-pattern boundary rather than claiming a complete
privacy/security classification system. Stage 4 must establish the independent
project and trusted registration boundary without turning the Stage 3 explicit
software-root APIs into ambient root discovery.

**Current implementation state:** Stage 3 is accepted and complete. RRP package
code can safely find declared installed resources and report a structured,
privacy-safe operation outcome from an explicit software context, but there is
still no hospital project or risk behavior.

**Next task:** detail Stage 4 — Independent Project Foundation from the accepted
Stage 3 baseline. Do not begin Stage 4 source implementation before that
separate planning and acceptance action.

## Stage 4 detailed-plan acceptance — 2026-09-16

Stage 4 was detailed from clean committed Stage 3 baseline
`16a7cd1651b28a93e223ae4389135ed8558f2ccc`. Stages 1–3 remain accepted and no
corrective implementation change was needed. This planning action introduced
no project file, contract resource, package API, test, fixture, validator,
dependency environment, CLI, or other Stage 4 implementation.

The detailed plan answers the minimum-project question with two fixed public
artifacts beneath one explicit project root: strict nonsecret
`rrp-project.dcf` and trusted `R/register.R`. The manifest declares exact
project/contract/API identity, one-health-system scope, exact producer/provider
selection, and safe project-relative extension-library and state locations.
The registration entry point returns a closed project identity plus structural
producer/provider ID, version, and callable records. Registration is evaluated
once in a controlled environment after manifest/path compatibility checks;
selection is exact, collisions and protected `rrp.` identities fail closed,
and Stage 4 never executes or semantically conforms an extension.

The plan assigns project contracts, loading, initialization, doctor, errors,
and context to `rrpplatform`; `rrpruntime` remains unchanged. Project APIs take
the validated Stage 3 software catalog and a separate explicit project root.
The project library may follow installed RRP libraries but cannot replace them;
no ambient library, restore, lock, or `renv` contract is introduced. State is
only a safe declared location and remains uninitialized until its owning stage.
Initialization creates exactly the manifest and registration file in a new
destination through staging/load-before-promotion; doctor reuses the loader and
the common Stage 3 operation-result/diagnostic boundary.

Four implementation increments were accepted: 4.A project manifest and
registration contracts; 4.B trusted registration and explicit project loading;
4.C minimal independent-project initialization; and 4.D structured project
doctor plus the copied/adversarial independent-project proof. This ordering
keeps declarative authority, trusted loading, mutation, and health/integration
evidence independently reviewable.

Historical reconnaissance inspected `v0.1.0` producer composition and registry,
provider registry, independent-adopter fixtures/tests, and generated Hospital
initialization/doctor/composition, plus pre-reset revisions `f4a98a8`,
`6c2ac3b`, `fd98c73`, and `c459f7d`. Exact selection, duplicate rejection,
trusted callable pairing, fail-closed resolution, explicit roots, closed
registration results, controlled environments, dependency/state separation,
and copied-project tests were selected for direct reuse or adaptation.
Repository/global source chains, generated Hospital delivery, copied Platform
source, editable closed inventories, pristine Git rules, runtime hospital
selectors, root `renv`, Phase machinery, daily-hazard/estimand semantics, and
distribution/release behavior were rejected.

Canonical profiles, producer execution/admission, target/provider semantics,
risk computation, state/history, full dependency restoration, CLI/root
selection, project migration, secrets and production access control, products,
application, distribution, deployment, and release remain deferred. No
contradiction with Platform True North or Platform Architecture was found; the
plan narrows final target responsibilities to the structural facts that exist
before Stage 5 rather than reserving placeholder fields or behaviors.

**Current implementation state:** Stages 1–3 complete; Stage 4 detailed and
accepted for implementation; no Stage 4 source implementation has occurred.

**Next task:** implement only Increment 4.A — Project manifest and registration
contracts.

## Increment 4.A — Project manifest and registration contracts (complete, 2026-09-16)

Increment 4.A established two software-owned, versioned DCF authorities without
creating or loading a hospital project. `resources/contracts/project-manifest.dcf`
is cataloged exactly once as `rrp.contract.project-manifest` and defines the
strict future `rrp-project.dcf` contract `rrp.project@0.1.0`.
`resources/contracts/project-registration.dcf` is cataloged exactly once as
`rrp.contract.project-registration` and defines the closed in-memory result
contract `rrp.project-registration@0.1.0`. Both are `contract` resources owned
by `rrpplatform`, projected byte-for-byte at their source-relative installed
paths, and increase the naturally closed software-resource inventory from
three to five entries without adding a fixed count assertion.

The manifest authority permits exactly the 13 accepted required fields and no
optional or unknown fields. Internal `rrpplatform` code strictly parses one
single-line DCF record; validates the fixed record, contract, one-health-system,
and exact `rrp.project-api@0.1.0` compatibility values; enforces bounded
lowercase project/component identities, reserves the `rrp.` namespace against
project identity and project registration while permitting a manifest to
select a future installed `rrp.` component, and enforces the accepted bounded
version grammar; and validates the two project-relative
paths for portable forward-segment syntax, case-folded equality/overlap, and
conflict with each other or `rrp-project.dcf` / `R/register.R`. This increment
validates only syntax and declared relationships. It has no project root and
therefore makes no containment, existence, ownership, or symlink claim about a
real filesystem.

The same internal owner validates a supplied in-memory registration candidate
with exactly `registration_contract_id`, `registration_contract_version`,
`project_id`, `producers`, and `providers`. Producer/provider collections are
plain ordered unnamed lists and may be empty. Each entry has exactly
`component_id`, `component_version`, and a function object; duplicate exact
kind/ID/version identities, protected `rrp.` identities, malformed versions,
named or otherwise malformed collections, extra/missing fields, and
non-functions fail closed. Validation preserves collection order and callable
objects but never invokes them. Cross-checking project identity against a
manifest, executing `R/register.R`, composing installed/project entries, and
resolving selections remain Increment 4.B responsibilities.

The nonsecret boundary follows the accepted closed-contract strategy rather
than introducing a general security scanner. The field vocabulary admits no
credential, source, model, clinical, target, product, deployment, executable,
or arbitrary-configuration field. Bounded obvious-pattern checks additionally
reject patient/MRN, password/secret/credential/token/authorization/key,
connection-string, private-key, remote-URL, and common executable-expression
forms where flexible identity/path values could otherwise carry them. Tests
and documentation state no claim of comprehensive secret or privacy
classification.

Historical implementation was revisited at immutable `v0.1.0`, especially
`runtime/R/provider-registry.R`,
`operations/lib/canonical-producer-operation.R`, producer/provider identity
helpers, safe-path mechanics, and the independent-adopter evidence. Pre-reset
project assessments at `f4a98a8`, `6c2ac3b`, `fd98c73`, and `c459f7d` were
also rechecked. Exact ID/version keys, closed named structures, duplicate
rejection, trusted function-object checks, fail-closed validation, forward
relative-path checks, and nonsecret registration/selection separation were
adapted. YAML/specification frameworks, estimand/daily-hazard and clinical
fields, installed composition, generated Hospital repositories, repository-
root and `.GlobalEnv` sourcing, Git validity, Phase validation, and
distribution/release behavior were rejected.

`packages/rrpplatform/tests/project-contracts.R` supplies focused positive and
adversarial evidence for exact manifest parsing; missing, unknown, duplicate,
malformed, multi-record, and multiline DCF; fixed identity/compatibility;
bounded IDs and versions; protected namespaces; path syntax, overlap, case,
and fixed-path conflicts; obvious unsafe content; exact registration/result
shape; empty and multiple collections; callable structure; duplicates; and
non-invocation. An initial strict check found two test/code issues: atomic test
data could not remove a field by assigning `NULL`, and unqualified `setNames()`
and `combn()` created avoidable package-check notes. The fixture now removes
the field by selection, and the implementation uses direct base-R naming and
pair construction. A subsequent adversarial test showed that the singular
`credential` marker did not reject the plural path segment `credentials`; the
bounded marker expression was corrected. No accepted contract changed.

The complete local package/resource operation then passed. It proved exact
five-resource catalog closure, both new contract identities and fields,
malformed-contract rejection, deterministic byte-identical projection,
installed copied-root lookup and internal authority loading, unchanged exact
four/zero export posture, unchanged `rrpplatform -> rrpruntime` dependency,
both package builds, isolated dependency-order installation/loading, all
package-native tests, and exact `R CMD check --no-manual` `Status: OK` for both
packages. Repository validation, direct R/DCF/Rd/namespace parsing, source and
installed byte comparison, inventory, symlink/generated-output review, and
`git diff --check` also passed. All validator output remained temporary and
was removed. The hosted workflow was unchanged and no hosted claim was made.

No `rrpplatform` export or third-party dependency was added, and `rrpruntime`
was unchanged. There is no project directory or template, registration-file
loading or invocation, project context/loader/initializer/doctor, filesystem
project-root validation, installed/project composition, selection resolution,
producer/provider execution or semantic conformance, dependency activation or
restoration, state creation/history, source/canonical/target behavior, CLI,
distribution, deployment, or release behavior. No discrepancy from the
accepted plan, Platform Architecture, or True North was found.

**Current implementation state:** Increment 4.A complete; Stage 4 remains in
progress. RRP owns exact versioned project-manifest and trusted-registration
contracts, but it cannot yet execute registration or load a project.

**Next task:** review Increment 4.A and, if accepted, proceed to Increment 4.B
— Trusted registration and explicit project loading.

## Increment 4.B — Trusted registration and explicit project loading (complete, 2026-09-16)

Increment 4.B began from clean committed baseline
`7392537f0c92522f5bc6f674da1514407156cba8` (`4.A complete`) on `main`;
that branch was one local commit ahead of `origin/main`, and no uncommitted
change was present. The increment added exactly one public technical interface,
`rrp_load_project(software_catalog, project_root)`, to `rrpplatform`.
`rrpruntime` was unchanged. The main package still imports only
`rrpruntime`, uses no third-party dependency, and now exports exactly the four
Stage 3 interfaces plus this loader.

`packages/rrpplatform/R/project-loader.R` owns the realized boundary. It first
revalidates the two required project-contract resources through the supplied
Stage 3 `rrp_resource_catalog`, canonicalizes only the separately supplied
project root, and reads exactly `rrp-project.dcf`. Manifest contract/API,
identity, selection, and path declarations are validated before
`R/register.R` is examined or executed. The loader performs no current-
directory, parent, Git, sibling, environment-variable, software-root,
installation, or package-location discovery for the project.

Real filesystem validation now resolves the declared extension-library and
state paths beneath the canonical project root. Existing segments must be
case-exact and non-linked; an existing final target must be a directory; and
containment, separation, overlap, fixed-artifact, and case rules fail closed.
Both locations may be absent and are then returned only as normalized intended
paths. Neither is created. The fixed manifest and registration artifacts must
be ordinary non-linked files, including a non-linked `R` segment for the
registration entry point.

After all declarative and structural checks, the loader evaluates exactly
`R/register.R` once with `sys.source()` in a new environment whose parent is
`baseenv()`. That environment must expose exactly one binding,
`rrp_register_project`, and it must be a function. The function receives the
normalized project root exactly once. Source/evaluation failures and callable
failures become bounded typed project failures without copying source, parser,
path, or arbitrary returned error text. This controlled environment reduces
accidental global coupling but is explicitly not a security sandbox; trusted
project code can still perform arbitrary R effects.

Registration loading temporarily places the libraries owning the installed
`rrpplatform` and `rrpruntime` packages first, an existing declared project
extension library second, and the base/recommended R library afterward.
Ambient user and site libraries are excluded from this declared resolution
window. The caller's prior library paths are restored on both success and
failure. A project extension library is rejected if a direct entry or package
`DESCRIPTION` attempts to shadow `rrpplatform` or `rrpruntime`. The loader
does not restore, install, lock, close, or otherwise manage dependencies.

The existing 4.A registration validator now raises the same typed low-level
project conditions while retaining its closed result, project identity,
collection, component ID/version, callable, protected-name, and duplicate
rules. The loader requires registration `project_id` to match the manifest,
canonicalizes producer/provider registration order by exact ID/version,
combines it with the deliberately empty current installed-component set,
retains `project` or future `installed` origin, rejects exact collisions,
and resolves each manifest selection by exact ID plus version. Missing and
ambiguous selection have distinct codes. There is no precedence, alias,
latest, range, fallback, ensemble, or data-dependent choice, and selected
callables are never invoked.

The returned object has exact class
`c("rrp_project_context", "list")` and exact fields
`software_catalog`, `project_root`, `manifest`, `registration`,
`producer`, `provider`, `extension_library_path`, and `state_path`.
Selected records contain only component ID, version, callable, and origin. It
is an in-process validated snapshot: package code does not mutate it after
construction, and later operations should load a new context rather than
serialize or treat it as a mutable project session.

Expected low-level failures inherit from `rrp_project_error` and contain only
`message`, `call = NULL`, and stable `code`. The realized finite codes
cover invalid, missing, non-directory, or linked roots; missing, linked,
malformed, unsupported, or API-incompatible manifests; unsafe project paths;
invalid extension/state boundaries; missing, linked, or malformed
registration; invalid results; project identity mismatch; protected or
duplicate registration; installed/project collision; and unknown or ambiguous
producer/provider selection. Messages are fixed, bounded, single-line
maintainer text and never echo absolute fixture paths, manifest/registration
content, parser output, secret-like values, or callable error text. Software-
resource invalidation retains its existing `rrp_resource_error` owner rather
than being mislabeled as a project failure.

Focused package-native evidence in
`packages/rrpplatform/tests/project-loader.R` constructs only temporary
hand-authored projects. It covers exact context shape, separate explicit
software/project roots, unrelated working directories, no parent/Git/
environment discovery, missing/non-directory/linked roots, copied-project
portability, manifest-before-code sentinels, ordinary fixed files, malformed
registration and closed-environment bindings, exact one-time evaluation and
registration call, identity reconciliation, protected/duplicate/collision
behavior, exact/unknown/ambiguous selection, deterministic ordering, project
and installed origin, absent/present/non-directory/linked/case-conflicting
state and library paths, RRP-package shadowing, declared temporary project-
package resolution, ambient-library rejection, library restoration on success
and failure, software-resource revalidation, no `.GlobalEnv` or working-
directory mutation by RRP, safe failures, and selected-callable non-invocation.
No persistent project fixture or extension package entered source.

The maintainer package operation now expects the loader source, manual, test,
and exact fifth export; permits source evaluation only at the single fixed
`sys.source()` registration boundary; and adds an installed-package proof
that loads a hand-authored project and unrelated copy outside repository/Git
context, checks exact context/selection/origin/order/call-count/non-invocation,
and exercises one safe typed selection failure. It retains the complete
Stage 1–3 and 4.A catalog, projection, resource, result, package, build,
isolated install/load, package-native, and strict-check evidence.

Historical reconnaissance revisited immutable `v0.1.0`
`runtime/R/provider-registry.R`,
`operations/lib/canonical-producer-operation.R`,
`operations/compositions/installed-producers.R`, and the Phase 10 independent-
adopter fixture/tests, plus pre-reset assessments at `f4a98a8`, `6c2ac3b`,
`fd98c73`, and `c459f7d`. Exact ID/version keys, duplicate rejection,
trusted function-object validation, fail-closed lookup, closed registration,
origin, collision, and independent-copy mechanics were reused or adapted.
`.GlobalEnv` composition, recursive/fixed-order sourcing, repository roots,
generated Hospital repositories, copied Platform source, Git validity,
hard-coded reference composition, daily-hazard/estimand behavior, and
Phase/distribution/release machinery were rejected.

Focused implementation validation exposed three harness/static issues without
changing the accepted contract. The old blanket package-source prohibition on
all `source()` calls was narrowed to permit exactly one `sys.source()` call
in `project-loader.R`; all other source evaluation remains prohibited.
`R CMD check` identified unqualified `file_test()` usage, which was replaced
with dependency-free filesystem checks rather than adding an import. The
installed-proof fixture initially copied a directory to a nonexistent target
using unsupported `file.copy()` semantics; it now copies beneath an existing
temporary parent. Final repository and package validation passed with all
generated archives, libraries, check directories, projected software roots,
projects, extension packages, and scripts removed by their temporary owners.

No initializer, template, persistent project, structured project doctor,
operation-result translation, CLI/root convenience, producer/provider
execution or semantic conformance, source/canonical behavior, dependency
restore/lock, state creation or persistence, runtime/history, product,
application, distribution, deployment, or release behavior was introduced.
The completion statement is therefore literal: installed `rrpplatform` can
safely load a manually authored independent project and resolve its declared
structural extensions, but it cannot create or diagnose a project through a
structured operation.

**Current implementation state:** Increment 4.B complete; Stage 4 remains in
progress.

**Next task:** review Increment 4.B and, if accepted, proceed to Increment 4.C
— Minimal independent-project initialization.
