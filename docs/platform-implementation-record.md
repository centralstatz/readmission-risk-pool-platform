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

## Increment 4.C — Minimal independent-project initialization (complete, 2026-09-17)

Increment 4.C began from clean synchronized commit
`aa4586274c364d8acbf6c5578240ae7fd43d7172` (`4.B complete`) on `main`.
It added exactly one public technical interface,
`rrp_initialize_project(software_catalog, project_root, project_id,
project_version)`, to `rrpplatform`. `rrpruntime` remained unchanged;
`rrpplatform` still imports only `rrpruntime`, uses no third-party dependency,
and now exports exactly six interfaces.

The closed software-resource catalog now declares the software-owned templates
`rrp.template.project-manifest` and
`rrp.template.project-registration` at
`resources/templates/project/rrp-project.dcf` and
`resources/templates/project/R/register.R`. The resource schema's already
accepted `template` class now permits the directly required `r` format in
addition to `dcf`. Source and projected resource closure, safe paths, exact
catalog mappings, regular-file/link rules, and byte-preserving projection apply
to both templates without a parallel template-discovery mechanism.

The manifest template renders exactly the 13 fields of
`rrp.project@0.1.0`. For a validated project ID and version, it selects
`<project-id>.producer` and `<project-id>.provider` at that exact project
version, declares `extensions/library` and `state`, and adds no optional field.
The registration template exposes only `rrp_register_project(project_root)`
and returns the exact `rrp.project-registration@0.1.0` result for those two
project-owned records. Their callables are structural placeholders that raise
one fixed safe error if invoked; initialization and loading never invoke them.

`packages/rrpplatform/R/project-initializer.R` reuses the installed contract
authorities and their existing identity/version predicates. It rejects invalid
or protected project identities, invalid versions, and IDs whose derived
component names exceed the accepted registration boundary before filesystem
mutation. Rendering recognizes only four fixed tokens and rejects missing or
unknown template tokens. It verifies the staged inventory is exactly
`rrp-project.dcf`, `R/register.R`, and the implied `R` directory.

Initialization is create-only. The requested destination must be absent as a
directory, file, or link; its direct parent must already be an ordinary
non-linked directory; and a case-folded sibling collision is rejected. The
operation creates a unique sibling staging directory, writes only the two
rendered files, calls the existing `rrp_load_project()` as the authoritative
staged acceptance gate, and checks the exact requested identity/selections. It
then rechecks destination absence, promotes with same-parent `file.rename()`,
and calls the same loader again so the accepted context corresponds to the
final physical root. Scoped cleanup removes only staging or promoted content
owned by the current unsuccessful attempt. Existing caller content is never
overwritten, merged, emptied, repaired, adopted, renamed, or deleted.

The initializer returns operation ID `rrp.initialize-project` through the
existing `rrp_operation_result` contract. Success contains only project,
producer, and provider identities/versions plus created relative paths
`rrp-project.dcf` and `R/register.R`; it contains no absolute root, context,
callable, timestamp, run/Git data, inventory, or future state metadata.
Expected resource, project, and narrow initialization conditions become one
error diagnostic with the originating stable code and fixed message `Project
initialization failed.` Unexpected programming errors remain visible. New
initializer-owned codes are limited to invalid project inputs/destination/
parent, existing destination, invalid template/rendering, staging failure, and
promotion failure.

Package-native evidence initializes under an unrelated temporary parent and
checks exact manifest fields, derived IDs/versions, two-file inventory, absent
state/extensions/Git, operation-result shape, successful final loading,
project origin, and safely failing placeholder callables. It copies and reloads
the project with unchanged semantic identity and new physical paths and proves
rendered files contain neither the original nor staging root. Adversarial
coverage rejects invalid/protected/overlong identities, invalid versions,
unsafe destinations, missing/file/linked parents, existing directory/file/link
destinations, token drift, malformed rendered registration, and repeat
initialization while preserving sentinels and removing owned staging state.

Historical reconnaissance inspected immutable `v0.1.0` Hospital managed-
platform extraction, release preparation, Connect realization, YAML product
materialization, and their failure tests. The narrow same-parent staging,
`on.exit` cleanup, validation-before-promotion, `file.rename()` promotion,
absent-destination refusal, and failure-sentinel mechanics were adapted.
Embedded Platform extraction, generated Hospital repositories, copied Platform
source, Hospital distribution inventories, replacement/backup semantics,
wrapper scripts, top-level `renv`, ignored `build/`, Git initialization/state,
reference-hospital identities, and Phase/release assumptions were rejected.

The maintainer package operation now recognizes the templates, initializer
source/manual/test, sixth export, and installed initialization proof. Final
validation passed source catalog/schema/contract/template closure and
projection, package parsing/native tests, both source builds, isolated
dependency-order installation/loading, exact `R CMD check --no-manual`
`Status: OK` for both packages, installed resource access, hand-authored
project loading, transactional initialization, final-location loading, copied
portability, create-only failure, and staging cleanup. Repository validation,
direct R/DCF/Rd parsing, inventory/symlink/generated-output review, and
`git diff --check` also passed. All validation projects, staging directories,
software projections, archives, libraries, and check directories remained
temporary and were removed.

No project doctor or `rrp_validate_project()`, CLI/root discovery, Git project,
dependency library/restore/lock, state directory/persistence, source/mapping,
producer/provider execution or conformance, canonical/runtime/risk behavior,
product/application, distribution, deployment, or release behavior entered.
No persistent project fixture exists. No discrepancy from the accepted plan,
Platform Architecture, or True North was found.

**Current implementation state:** Increment 4.C complete; Stage 4 remains in
progress. RRP can transactionally initialize and load the smallest independent
hospital-owned project, but it has no structured project doctor yet.

**Next task:** review Increment 4.C and, if accepted, proceed to Increment 4.D
— Structured project doctor and independent-project proof.

## Increment 4.D — Structured project doctor and independent-project proof (complete, 2026-09-17)

Increment 4.D began from clean synchronized commit
`4de7bd1` (`4.C complete`) on `main`. It added exactly one exported technical
interface, `rrp_validate_project(software_catalog, project_root)`, with operation
ID `rrp.validate-project`. `rrpplatform` now exports exactly seven interfaces,
still imports only `rrpruntime`, and gained no third-party dependency;
`rrpruntime` remained dependency-free, export-free, and otherwise unchanged.

`packages/rrpplatform/R/project-doctor.R` is deliberately a thin translation
layer over one call to the authoritative `rrp_load_project()` boundary. It does
not repeat manifest, compatibility, identity, selection, registration, path,
symlink, collision, protected-name, library-shadowing, or filesystem rules.
Successful validation returns an exact closed value with fields
`project_id`, `project_version`, `project_contract_id`,
`project_contract_version`, `supported_rrp_api_version`, `producer`, `provider`,
`extension_library_status`, and `state_status`. Producer and provider each
contain only `component_id`, `component_version`, and `origin`; no context,
callable, registration data, absolute path, source, template, Git, timestamp,
run, patient, credential, or arbitrary metadata is exposed.

Declared extension-library and state locations use only `not_initialized` and
`available`. An absent extension library is valid and produces no diagnostic.
An absent state directory is also a structurally valid Stage 4 condition: the
operation remains successful and returns exactly one warning with code
`project_state_not_initialized` and fixed message `Project state has not been
initialized.` Existing ordinary locations report `available`; the doctor does
not create either location, initialize state, install dependencies, or
interpret their contents beyond the loader's existing structural rules.

Expected `rrp_project_error` conditions become one failed common result with
the originating stable code, `NULL` value, one error diagnostic, and fixed
message `RRP project validation failed.` Invalid or changed software-resource
authority remains an `rrp_resource_error` rather than being relabeled as a
project defect. No generic error handler was added, so unexpected programming
errors propagate. Doctor execution evaluates and calls the trusted registration
boundary once through the loader and never invokes selected producer/provider
callables. Trusted registration remains code rather than a security sandbox,
but the RRP doctor itself does not mutate project files, declared locations,
the working directory, global environment, or caller library paths.

Focused package-native evidence covers the exact initialized-project result,
one fixed state warning, absent extension behavior, available state/extension
behavior without content interpretation or mutation, exact predicate behavior,
privacy-safe serialization, unrelated working directory, global/library
restoration, copied-project semantic identity, and original-root independence.
An instrumented trusted registration proves one source/function execution per
doctor load and zero selected-callable invocations. Representative translated
failures cover malformed manifest, incompatible API, unsafe path, missing and
malformed registration, project identity mismatch, protected and duplicate
registration, unknown producer/provider selection, and invalid or linked
extension/state locations. Separate evidence proves resource-error ownership
and unexpected-error visibility.

The maintainer package operation now owns the doctor source, manual, focused
test, seventh export, and installed Stage 4 lifecycle proof. From isolated
installed packages and a temporary projected software-resource root, it works
in an unrelated non-Git directory, initializes the exact two-file project,
loads and doctors it, copies it elsewhere, loads and doctors the copy, observes
absent then available state/extension statuses without interpreting contents,
and translates an adversarial selection failure through the bounded doctor
result. It retains the complete source-resource catalog/schema/contract/template
and projection regressions, hand-authored project loading, create-only/staging
evidence, package topology, dependency-order installation, and package checks.

Historical reconnaissance inspected immutable `v0.1.0`
`operations/lib/operator-operation.R`, `operations/doctor.R`, the Hospital
doctor/proof wrappers, and the Phase 10 independent-adopter fixtures/tests.
Structured status/warning intent, temporary independent/copy fixtures,
installed-package acceptance, and adversarial fail-closed mechanics were
adapted. Generated Hospital repositories, wrapper delegation, Git/repository
health, copied Platform source, fixed database/product paths, temporary runtime
installation, Phase aggregates, source/provider execution, clinical semantics,
deployment/release state, and broad observability were rejected.

Final validation passed `Rscript --vanilla tools/validate-repository.R` with
all eight checks and zero issues and passed
`Rscript --vanilla tools/validate-packages.R`. The latter passed complete
catalog/projection regressions, static package boundaries, both source builds,
isolated dependency-order installation/loading, all package-native tests, the
installed initialization/load/doctor/copy/adversarial proof, and exact
`R CMD check --no-manual` `Status: OK` for both packages. Direct R/Rd parsing,
`git diff --check`, tracked inventory/symlink/generated-output review, and
working-tree artifact inspection also passed. Generated archives, check
directories, libraries, projections, projects, extension/state locations, and
staging directories were temporary and did not enter repository source.

No root selection/discovery, CLI, dependency restore/lock, state initialization
or persistence, source access/mapping, producer/provider execution or semantic
conformance, canonical admission, clinical contract, target/runtime/risk
calculation, product/application, distribution, deployment, or release behavior
was introduced. Structural project validity therefore remains distinct from
source mapping, producer semantics, provider/model validity, clinical risk
validity, and production readiness. No discrepancy from the accepted 4.D plan,
Platform Architecture, or True North was found.

**Current implementation state:** Increment 4.D complete; all four Stage 4
implementation increments are implemented. RRP can initialize, recognize,
safely load, and structurally diagnose an independent hospital-owned project
and its declared producer/provider registrations, but it cannot yet admit
source data or calculate readmission risk.

**Next task:** commit the complete Stage 4 tree, obtain successful evidence
from the unchanged hosted package-foundation workflow, and perform the separate
human-directed Stage 4 acceptance/reconciliation pass. Stage 5 is not yet
authorized.

## Stage 4 acceptance and reconciliation — 2026-09-17

Stage 4 is accepted and complete at exact committed baseline
`f5c1fb0db47e9154b99e133a8f553bee8ea2aa16` (`4.D complete`). Acceptance began
from clean synchronized `main`: local `HEAD` and `origin/main` both resolved to
that revision. GitHub Actions workflow `package-foundation` push run
`35221028009`, job `105200921084`, completed successfully against the same
`main` SHA. The unchanged read-only job checked out that commit, set up R 4.4,
and passed the existing repository- and package-foundation operations. This is
narrow hosted package/project-foundation evidence, not a distribution,
clinical, production, deployment, release, or broader support claim.

The realized architecture composes without a conflicting seam. Installed RRP
owns the validated software-resource catalog, the resource/result/project
contracts, and the two project templates. Initialization renders those
software-owned templates into exactly `rrp-project.dcf` and `R/register.R` at
an absent hospital-owned destination; the instantiated files have no template,
source-repository, staging, or original-root backreference. The manifest owns
strict project/contract/API identity, one-health-system scope, exact structural
producer/provider selections, and safe relative extension-library/state
declarations. The fixed trusted registration owns the closed project identity
plus producer/provider records. It is trusted local R code, not a sandbox.

The loader remains the sole structural authority: it revalidates the explicit
software context, validates the explicit project root, manifest, compatibility,
and declared paths before trusted code, evaluates exactly `R/register.R` once,
validates the closed registration, composes installed/project origins, and
resolves exact ID+version selections without invoking either selected callable.
The initializer uses that same loader before and after same-parent promotion;
the doctor calls it once and only translates its context or expected typed
project error into the common bounded result. Thus contracts, templates,
initializer, loader, and doctor agree on one project boundary rather than
forming parallel authorities.

The accepted project is independent of the development repository and Git.
Installed-package proof initializes it from explicit software/project contexts
in an unrelated non-Git working directory, confirms the exact two-file initial
inventory, loads and doctors it, copies it elsewhere, and reloads/rediagnoses
the copy with unchanged semantic identity and newly resolved physical paths.
No current package operation discovers a project through cwd, parents, Git,
siblings, environment variables, package installation, or a global singleton.
The temporary source-to-installed resource projection remains maintainer
evidence and is not represented as the final distribution manifest.

The extension library is a declared optional project-owned location. RRP-owned
package libraries precede it, ambient user libraries are excluded during
registration, and project content cannot shadow `rrpplatform` or `rrpruntime`.
Absence is valid; Stage 4 does not restore, install, lock, or claim dependency
closure. State is a separate safe project-owned declaration. Absence is valid
and doctor reports `not_initialized` plus the fixed
`project_state_not_initialized` warning; an existing structurally valid
directory reports `available` without content interpretation. State schemas,
history, locking, persistence, retention, backup, recovery, and migration stay
with Stage 7.

The public technical surface is exactly `rrp_initialize_project()`,
`rrp_load_project()`, `rrp_open_resource_catalog()`,
`rrp_operation_succeeded()`, `rrp_resource_path()`,
`rrp_validate_project()`, and `rrp_validate_software_resources()`.
`rrpplatform` is the sole project/operation owner and imports only
`rrpruntime`; `rrpruntime` remains dependency-light, dependency-free,
export-free, and independent upward. These are internal implementation-package
interfaces beneath the future installed CLI, not a decision that hospital
operators directly use the packages.

The closed software-resource authority contains exactly seven concrete
resources: the resource-catalog, diagnostic, operation-result, project-manifest,
and project-registration contracts plus the project-manifest and project-
registration templates. It contains no project instance, extension library,
state, source data, mapping, canonical data, model, product, application,
artifact, deployment, or release material. Source `Source-Path` ownership and
installed `Installed-Path` resolution remain distinct and byte-preserving.

Reconciliation against Platform True North and Platform Architecture found no
acceptance blocker or architectural deviation. The project is hospital-owned;
registration and exact selection are explicit; generic code remains unaware of
hospital/source identity; software/project/state/deployment lifecycles remain
separate; structured failures and diagnostics remain bounded and privacy-safe;
and the internal package topology remains invisible to ordinary operators.
The retained `v0.1.0` influence is limited to deliberately adapted registry,
structured-result, staging, independent-copy, and adversarial-test mechanics.
Generated Hospital repositories, copied Platform source, Git-state validity,
repository-root execution, root `renv`, Phase routing, daily-hazard semantics,
and release/deployment behavior did not re-enter the clean line.

Findings were classified as follows:

- **Acceptance blockers:** none.
- **Nonblocking clarifications:** pending-closeout wording in the plan, guide,
  README, and agent agreement; one target-architecture status sentence frozen
  at the clean reset; and the initializer manual's obsolete reference to a
  future doctor were corrected without changing implementation behavior.
- **Future-stage concerns:** producer semantic execution and canonical handoff
  begin with Stage 5 planning; provider/target execution, dependency closure,
  state lifecycle, CLI/distribution, products/application, deployment, and
  release remain with their planned later owners.
- **No issue:** all remaining Stage 4 ownership, composition, trust, path,
  selection, portability, privacy, validation, and scope behavior remains
  consistent with the accepted authority.

Final local acceptance reran both authoritative human operations.
`Rscript --vanilla tools/validate-repository.R` passed all eight checks with
zero issues. `Rscript --vanilla tools/validate-packages.R` passed the complete
catalog/schema/contract/template regression, deterministic projection,
package-native tests, both source builds, isolated dependency-order
installation/loading, missing-dependency rejection, installed resource access,
hand-authored loading, initialization/load/doctor/copy/adversarial proof, and
exact `R CMD check --no-manual` `Status: OK` for both packages. R, Rd, DCF, and
DESCRIPTION parsing, `git diff --check`, inventory, symlink, confidential-text,
and generated-output hygiene passed. No generated project, state, extension,
staging directory, archive, check directory, projection, or temporary library
remained in repository source.

Stage 4 establishes only structural project validity:

```text
Installed RRP software
        ↓
explicit software context

Independent hospital project
        ↓
manifest + trusted registration
        ↓
exact structural producer/provider selections
        ↓
initialize / load / doctor

STOP

No source admission
No producer execution
No canonical data
No provider execution
No risk calculation
No state persistence
```

This is not source-mapping validity, producer conformance, canonical-data
validity, provider/model validity, clinical risk validity, production approval,
or release readiness. The accepted exit statement is literal: RRP can
initialize, recognize, safely load, and structurally diagnose an independent
hospital-owned project and its declared producer/provider registrations, but
it cannot yet admit source data or calculate readmission risk.

**Current implementation state:** Stages 1–4 accepted and complete at the
baseline above.

**Next task:** detail Stage 5 — Canonical Handoff and Producer Boundary from
the accepted Stage 4 baseline. Do not begin Stage 5 source implementation
before that plan is reviewed and accepted.

### Post-acceptance Stage 4 hands-on observation — 2026-09-17

A separate manual exercise used a simulated installed RRP environment to
initialize an independent hospital-owned project outside the source repository,
load it, run the project doctor, copy it to a different filesystem location,
and load and doctor the copy. Every supported operation succeeded. The copied
project resolved its project-owned paths from the copied root and retained no
operational dependence on the original location, confirming the portability
already established by automated Stage 4 evidence.

The exercise also found one nonblocking usability consideration:
`rrp_initialize_project()` rejects a destination beginning with `~`, while the
equivalent absolute destination succeeds. This is consistent with the accepted
strict internal path contract and is not a Stage 4 acceptance defect. No Stage
4 source or test was changed. A later user-facing interface, such as the Stage
11 CLI, may normalize an explicitly supplied home-relative path before calling
the strict internal API if human evidence justifies that convenience.

## Stage 5 detailed-plan acceptance — 2026-09-17

Stage 5 — Canonical Handoff and Producer Boundary was detailed from the
accepted Stage 4 baseline without implementing source behavior. The planning
pass began from clean synchronized `main` at `c91a641` (`Stage 4 complete`),
which records the accepted implementation baseline at `f5c1fb0`. It read
Platform True North, Platform Architecture, the current plan and record, human
implementation guidance, and the coding-agent agreement, then inspected the
realized resource/result/project contracts, trusted loader, initializer,
doctor, package topology, exports, templates, and validation boundary. No
contradiction requires reopening Stages 1–4.

The accepted Stage 5 objective is to make exactly the selected project
producer executable under one closed request/result contract and admit or
reject its minimum source-independent canonical candidate. The provider stays
structurally selected and completely inert. Successful canonical information
stays in memory; no state or history is initialized.

The accepted construction sequence is:

1. **Increment 5.A — Canonical contract authority and semantic producer
   declaration:** add the closed installed DCF specification family, advance
   the unreleased project/API/registration contracts coherently to `0.2.0`,
   and validate exact producer semantics without invoking either extension;
2. **Increment 5.B — Dependency-light canonical bundle admission:** add the
   first `rrpruntime` export and pure detached candidate admission for the
   minimum profile without executing project code; and
3. **Increment 5.C — Selected producer execution and canonical handoff proof:**
   add the one `rrpplatform` producer operation, common bounded outcomes, and
   the installed independent/copy/substitution proof.

Stage acceptance follows those increments and requires committed success from
the existing read-only hosted package-foundation workflow. It is a lifecycle
reconciliation, not a fourth implementation increment.

The minimum profile is deliberately smaller than the historical clinical
profile. It contains only a discharge-episode root and required terminal-event
capability. The root supplies episode/patient/index-encounter identity,
admission/discharge instants, and an exact follow-up end equal to 30 elapsed
days after discharge. The child domain supplies at most one first readmission
and one death per episode with separate occurrence and availability instants.
Both domain payloads may contain zero rows while their required capabilities
remain available; final acceptance must also pass a nonempty bundle so real
relationship and temporal behavior is proven. Baseline scores, generic events,
features, demographics, diagnoses, medications, tasks, interventions,
measures, and provider-specific inputs remain absent.

The first executable representation is a closed in-memory base-R adapter to a
representation-independent semantic contract. `rrpruntime` owns pure canonical
validation and admitted values; `rrpplatform` owns installed-resource loading,
project/producer orchestration, request/result validation, extension-condition
containment, and common result translation. The one-way dependency remains
unchanged. The producer request carries only exact project, producer, bundle,
profile, and as-of facts. Hospital source access, configuration, secrets,
connections, local validation, mapping, and dependencies remain behind the
trusted project closure; none is passed through generic RRP.

The project manifest will add exact canonical-profile ID/version fields and
the producer registration record will add exact producer API, bundle/profile,
implementation, mapping, and capability declarations. This incompatible
required-field change advances the development project contract, project API,
and registration contract from `0.1.0` to `0.2.0`. The current tree is
unreleased and supports one exact line, so old Stage 4 structural projects will
fail explicitly rather than receive a compatibility bridge or silent rewrite.
The initializer will continue to create exactly two files and will register a
semantically conforming producer that returns a controlled unavailable result
until hospital code implements it. Provider registration semantics do not
change.

Historical reconnaissance inspected immutable `v0.1.0` specification,
canonical bundle/profile/domain, producer declaration/result/admission,
synthetic adapter, installed producer composition, Phase 2/10 tests, and the
independent adopter-producer fixture. The pre-reset fixed-target assessment at
revision `1e7b95c` was also revisited. Useful concepts are the exact identity
envelope, declaration/callable separation, implementation and mapping
identity, capability/cardinality distinction, candidate non-coercion,
primary/foreign-key and closed-field rules, dual-time availability,
short-circuit failure, and materially different source-substitution proof.

Those concepts are adapted to installed DCF resources, current package owners,
project registration, the singular fixed endpoint, explicit terminal-event
availability, common bounded operation results, and two temporary independent
producer fixtures. Historical YAML/parser dependency, broad baseline/event
model, generic dependency graph, installed/platform-instance producer
composition, producer configuration payload, synthetic default, source-
specific flags, Phase validators, operation-event/logging machinery,
daily-hazard/estimand semantics, downstream runtime/history/products/app, and
generated Hospital delivery are rejected for Stage 5.

The detailed acceptance criteria require two differently shaped temporary
hospital-source implementations to cross the same generic boundary without a
source or producer-ID branch, copied-project execution to use the copied root,
zero provider calls, fixed privacy-safe failures, no state writes, and complete
resource/package/build/check/hosted evidence. Admission remains software
conformance only; it does not claim source truth, clinical validity,
calibration, production authorization, or release readiness.

Planning/repository validation passed the human repository-foundation command,
local Markdown-link and status review, R/YAML parsing owned by that validator,
`git diff --check`, and working-tree inventory/hygiene review. Package
validation was not rerun because this task changed only planning and current-
status documentation and introduced no resource, package, export, dependency,
test, or workflow behavior.

No genuine unresolved architectural decision blocks implementation. Decisions
about target/provider execution, durable run/history identity, the maintained
fictional producer, dependency restoration, remote transports, additional
canonical domains, large-bundle/storage mechanics, products, app, CLI,
distribution, deployment, and release remain deliberately with later stages.

**Current implementation state:** Stages 1–4 remain accepted and complete.
Stage 5 is detailed and accepted, but no Stage 5 source behavior exists.

**Next task:** implement only Increment 5.A — Canonical contract authority and
semantic producer declaration. Do not begin Increment 5.B, Increment 5.C, or
Stage 6.

## Stage 5 / Increment 5.A — Canonical contract authority and semantic producer declaration — 2026-09-17

Increment 5.A is complete. The clean line now contains one cataloged, installed,
closed DCF specification family for the canonical handoff: the common
specification envelope, canonical producer contract, canonical bundle contract,
readmission profile, discharge-episode domain, and terminal-event domain. The
resources use specification format `1.0.0` and semantic version `0.1.0`, retain
their `rrpplatform` or `rrpruntime` semantic owners, and establish exact bundle,
profile, domain, capability, key, relationship, dual-time, and fixed day-30
follow-up facts. They contain no executable configuration, source-system
identity, hospital data, provider/model input, state, or storage location.

`rrpplatform` now owns one internal canonical-contract loader that reaches all
six resources only through the explicit validated software catalog, requires
their exact fields and values, and validates the producer/bundle/profile/domain/
capability references as one coherent set. The existing structured software-
resource validation operation also loads the canonical and project authorities,
so its successful result now proves more than catalog shape while retaining the
same bounded result surface. No canonical value or admission implementation was
added to `rrpruntime`; it remains dependency-free and export-free.

The unreleased project manifest contract, project API, and registration
contract advanced atomically from `0.1.0` to `0.2.0`. The manifest now requires
the exact `rrp.canonical-profile.readmission@0.1.0` identity. Producer records
are kind-specific and declare exact component, producer-API, canonical-bundle,
canonical-profile, implementation, mapping, capability, and callable facts.
Both discharge-episode and terminal-event capabilities must be present exactly
once with status `available`. Provider records deliberately retain only
component ID, component version, and callable. Validation rejects old,
unknown, missing, additional, duplicated, incompatible, protected, or malformed
declarations without invoking a selected callable.

The loader validates the canonical authority before trusted project
registration and includes the selected canonical profile plus the complete
semantic producer record in its closed context. The doctor reports the profile
and bounded producer implementation/mapping identities but no callable,
capability payload, path, or arbitrary registration content. Initialization
still creates exactly `rrp-project.dcf` and `R/register.R`, leaves extension and
state locations absent, and remains create-only and transactional. Its generated
producer declares the exact 5.A semantics and, only if invoked later with a
request, returns the controlled `producer_unavailable` result with no candidate.
Its provider retains the structural unavailable callable. Initialization,
loading, and doctor invoke neither component.

The implementation required two small corrections exposed by the evolved
contract. Template rendering now supplies the four manifest tokens separately
from the six registration tokens, preserving strict token closure without
requiring implementation/mapping placeholders in the manifest. Test fixture
source paths are rendered with explicit ASCII quoting instead of locale-
dependent fancy quotes. Neither correction expands product behavior.

Historical reconnaissance reused only concepts already accepted during Stage 5
planning from immutable `v0.1.0`: exact specification identity, producer
declaration/callable separation, implementation and mapping identity,
capability agreement, closed bundle/profile/domain vocabulary, relationship
rules, and adversarial exact-field evidence. Those concepts were adapted to
installed DCF resources, the current explicit-root catalog, the independent
project contract, the smaller two-domain readmission profile, and current
package ownership. Historical YAML/parser dependencies, generic dependency
graphs, producer configuration payloads, installed default selection,
baseline-risk/generic-event domains, estimands, repository-root loading, Phase
validation, generated Hospital delivery, and downstream runtime/history/
product/application behavior were rejected.

Evidence added or extended includes exact canonical-resource loading and
installed byte equality, cross-reference and owner agreement, unknown-field and
unsupported-version rejection, `0.2.0` hand-authored and initialized projects,
old-version/profile/API/declaration/capability/identity/duplicate rejection,
kind-specific producer/provider shapes, copied-project portability, controlled
unavailable-producer behavior, and instrumented zero-call proof for load and
doctor. The exact public namespace remains seven `rrpplatform` exports and zero
`rrpruntime` exports; the package dependency remains one-way.

Final local evidence passed:

- `Rscript --vanilla tools/validate-repository.R`: all eight repository checks,
  zero issues;
- `Rscript --vanilla tools/validate-packages.R`: exact source catalog and all
  13 resources, canonical/project contracts, adversarial fixtures,
  deterministic installed projection, package-native tests, both source builds,
  missing-dependency rejection, isolated dependency-order install/load,
  explicit installed-resource access, independent/copy project loading,
  transactional initialization and doctor proof, and exact `Status: OK` from
  both `R CMD check --no-manual` runs; and
- focused package tests, R/Rd/DCF parsing, repository inventory/hygiene, and
  `git diff --check` completed without a retained generated source artifact.

The completion statement is literal: installed RRP can load and diagnose an
independent `0.2.0` project whose selected producer declares the exact Stage 5
handoff it intends to implement. RRP still cannot admit a candidate canonical
bundle or execute the selected producer. There is no compatibility bridge or
migration operation for the historical structural `0.1.0` project form.

**Current implementation state:** Stages 1–4 remain accepted and complete.
Stage 5 is in progress; Increment 5.A is complete.

**Next task:** implement only Increment 5.B — Dependency-light canonical bundle
admission. Do not begin Increment 5.C, Stage 6, or Stage 5 acceptance.

## Stage 5 / Increment 5.B — Dependency-light canonical bundle admission — 2026-09-17

Increment 5.B is complete. `rrpruntime` now has its first and only export,
`rrp_admit_canonical_bundle(candidate, expected_context)`. The package remains
dependency-free with no `Imports`, `Suggests`, or `LinkingTo`; it has no
knowledge of `rrpplatform`, resource catalogs, projects, roots, registration,
producer/provider callables, source systems, state, persistence, products, or
repository layout. `rrpplatform` still imports only `rrpruntime` and retains
exactly its seven existing exports.

The expected context is one closed plain named list containing exact bundle-
contract, project, producer, implementation, mapping, canonical-profile,
capability, and authoritative as-of facts. The candidate is the 5.A closed
plain named-list adapter with the same identity/context fields, one bounded
non-patient bundle instance ID, exactly two available capability records, and
the exact named `discharge_episode` and `terminal_event` base-data-frame
domains. All scalar and column values are plain character values; unknown,
missing, classed, attributed, reference-bearing, executable, or coercion-
requiring content fails closed. No malformed value is dropped, renamed,
sorted, filled, repaired, or converted.

Admission validates exact supported bundle/profile versions and exact expected
project, producer, implementation, mapping, profile, capability, and as-of
agreement. Explicit-offset RFC 3339 timestamps are normalized only to compare
instants. Equivalent instants with different offsets agree; the admitted value
retains the submitted representation. Discharge episodes require bounded
nonempty identifiers, unique episode keys, permit multiple episodes per
patient, require admission before discharge, prohibit discharge after as-of,
and require `followup_window_end` to equal discharge plus exactly
`30 * 86,400` elapsed seconds.

Terminal events require bounded unique IDs, exact episode foreign keys, only
`readmission` or `death`, at most one of each type per episode, occurrence
strictly after discharge and through the inclusive follow-up endpoint,
occurrence no later than availability, and availability no later than bundle
as-of. Death before a later readmission fails; equal readmission/death
occurrence instants remain valid for Stage 6 target precedence. Required
capability availability remains distinct from row cardinality, so either
available domain may contain zero rows and an entirely empty two-domain bundle
is valid.

Success returns the copied candidate with exact class
`c("rrp_admitted_canonical_bundle", "list")`. Runtime reconstructs every
supported list, data frame, and atomic vector, does not mutate the caller's
candidate, and does not retain mutable references to it. Later mutation of the
original outer identity, episode data, or terminal-event data cannot change the
admitted value. The type is only sensitive in-memory analytical input; no
serialization, transport, persistence, database, or user-facing data model was
introduced.

Expected failures inherit from `rrp_canonical_error` and contain only
`message`, `call = NULL`, and stable bounded `code`. Fixed maintainer-authored
messages identify the invariant family without rendering patient, episode, or
event identifiers; field values; rows; raw candidate content; paths; source
information; SQL; credentials; or arbitrary object/condition text. Runtime did
not import or duplicate the main package's common operation-result system.
Translation into that system remains an Increment 5.C orchestration
responsibility.

`rrpplatform` gained no export. Its installed canonical-contract owner now has
one internal assembler that verifies the exact six loaded 5.A authorities and
derives the full runtime expected context from those authorities plus explicit
caller-supplied identity and as-of facts. Package-native integration loads the
DCF authorities through an explicit temporary installed-resource catalog,
assembles that context, directly constructs a candidate fixture, and admits it
through `rrpruntime`. It executes no project registration, producer, or
provider callable.

Historical reconnaissance inspected immutable `v0.1.0`
`operations/lib/canonical-bundle-validation.R`,
`operations/lib/canonical-clinical-validation.R`,
`operations/lib/canonical-producer-validation.R`, `runtime/R/utils.R`, and the
Phase 2 canonical profile tests. Closed mapping/field checks, primary- and
foreign-key validation, duplicate detection, exact capability agreement,
explicit-offset timestamp parsing, normalized elapsed-time comparison,
dual occurrence/availability rules, candidate non-coercion, and adversarial
fixture ideas were adapted to the current dependency-free runtime owner and
two-domain fixed-day-30 contract. YAML, repository-root loaders, generalized
dependency graphs, broad generic events, baseline risk, daily hazard,
estimands, runtime eligibility, provider execution, Phase result aggregation,
operation logging, state/history, products/application, and Hospital delivery
were rejected.

Focused positive evidence admitted a meaningful two-episode candidate with one
patient contributing both episodes, terminal evidence, offset-equivalent
instants, later availability, equal readmission/death occurrence, and an event
at the exact follow-up endpoint. Separate evidence admitted zero-row domains,
proved a daylight-saving offset change still represents exactly 30 elapsed
days, proved caller-input nonmutation and post-admission detachment, and
rejected unknown/missing fields or domains; unsupported types/classes or
attributes; functions, environments, and connections; malformed identifiers
and timestamps; duplicate keys; orphans; unsupported event vocabulary;
terminal cardinality violations; admission/discharge/as-of errors; shortened
or extended follow-up; endpoint overflow; occurrence/availability reversal;
future availability; death before later readmission; all expected identity
mismatches; unsupported bundle/profile versions; and missing, duplicate,
unsupported, or unavailable capabilities. Unsafe injected content did not
appear in rendered failures.

Focused installation and native execution passed before the full checkpoint.
A strict runtime `R CMD check --no-manual` completed with exact `Status: OK`;
the surrounding temporary shell wrapper then used zsh's reserved `status`
variable after the successful check. That harness-only error was corrected for
subsequent work and its owned temporary check tree was removed; no package
behavior changed.

The final complete local package operation passed once after implementation:
`Rscript --vanilla tools/validate-packages.R` validated the exact source
catalog and all 13 installed resources, deterministic projection, canonical
and project authorities, dependency-light admission, all package-native and
inherited adversarial tests, both package builds, main-package missing-
dependency rejection, isolated dependency-order installation/loading,
installed explicit-root resource and independent-project proofs, and exact
`Status: OK` from both strict package checks. No archive, check directory,
temporary library, projection, or project fixture remained in repository
source.

Final static closeout also passed. The repository command
`Rscript --vanilla tools/validate-repository.R` reported all eight checks and
zero issues. Direct
parsing covered 22 R files, 10 Rd files, and all 15 package/resource DCF files;
namespace/metadata inspection confirmed `rrpruntime` has no package dependency
and exactly one export while `rrpplatform` imports only `rrpruntime` and retains
exactly seven exports. Repository inventory, symlink/generated-artifact review,
and `git diff --check` passed. No producer/provider callable was invoked and no
persistent output was created. A final runtime-only strict check after the last
future-occurrence adversarial fixture again ended with exact `Status: OK`.

No contradiction, ambiguity, or deviation from the accepted 5.A authority,
Stage 5 plan, Platform Architecture, or True North was found. This increment
does not establish source truth, completeness, clinical validity, calibration,
production approval, or fitness for care decisions.

**Current implementation state:** Stages 1–4 remain accepted and complete.
Stage 5 remains in progress; Increments 5.A and 5.B are complete. Dependency-
light runtime code can admit or reject the minimum source-independent canonical
candidate, but no supported project operation executes a producer yet.

**Next task:** implement only Increment 5.C — Selected producer execution and
canonical handoff proof. Do not begin Stage 6 or Stage 5 acceptance.

## Stage 5 / Increment 5.C — Selected producer execution and canonical handoff proof — 2026-09-17

Increment 5.C is complete. `rrpplatform` now exports
`rrp_execute_producer(software_catalog, project_root, as_of_time)` as its eighth
and only new interface. The operation validates the explicit-offset RFC 3339
as-of value before project code, loads the explicit project only through
`rrp_load_project()`, obtains the exact selected semantic producer, invokes that
callable exactly once, validates its closed result, and delegates the candidate
to `rrpruntime::rrp_admit_canonical_bundle()`. Its operation identity is
`rrp.execute-producer`. `rrpruntime` remains dependency-free with exactly its
one admission export, and `rrpplatform` continues to import only `rrpruntime`.

The producer request is a plain closed named list in the exact installed-
contract order: `producer_api_id`, `producer_api_version`, `project_id`,
`project_version`, `producer_id`, `producer_version`, `canonical_bundle_id`,
`canonical_bundle_version`, `canonical_profile_id`,
`canonical_profile_version`, and `as_of_time`. It contains no root, catalog,
project context, provider, state or extension path, source configuration or
data, connection, credential, SQL, callback, persistence handle, arbitrary
metadata, or `...`. Hospital source access remains entirely inside the trusted
project closure created when registration receives the normalized project
root.

The accepted producer result is likewise one exact plain closed list containing
producer-contract identity/version, status, producer identity/version,
implementation identity/version, mapping identity/version, canonical-profile
identity/version, authoritative canonical as-of time, capabilities, candidate,
and failure code. Every declaration and request fact must agree exactly. A
successful result has one non-null candidate and no failure code; a failed
result has no candidate and exactly one of `producer_unavailable`,
`producer_source_failed`, or `producer_mapping_failed`. Unknown, missing,
additional, classed, malformed, inconsistent, executable, environment,
connection, language, or other reference-bearing result content fails closed
as `invalid_producer_result`; no coercion or repair occurs.

Selected-producer invocation reuses the accepted project extension-library
policy: installed RRP package libraries precede an existing project extension
library, permitted base/recommended libraries follow, and ambient user/site
libraries are excluded. The caller's `.libPaths()` and working directory are
restored even when trusted producer code changes them. The request itself does
not change the working directory, and no `.GlobalEnv` mutation is required.
This is controlled trusted-extension execution, not a sandbox. The selected
provider remains structurally present but is never invoked; there is no retry,
fallback, alternate selection, source-layout search, or installed default.

Producer-thrown errors are contained only around the hospital-owned callable
and become `producer_execution_failed` without their text. Valid declared
producer failures retain their fixed codes. Expected project failures use the
existing project codes with a fixed loading message, producer-result failures
use fixed producer messages, and runtime-owned `rrp_canonical_error` codes are
translated with a fixed canonical-admission message. All become the existing
common operation-result failure with one bounded error diagnostic. Unexpected
defects in generic RRP code and resource-authority failures are not broadly
relabeled. Success contains the detached admitted canonical bundle directly and
an empty diagnostic list; that value may contain sensitive analytical data and
is not safe diagnostic/logging content.

Focused package-native evidence uses temporary fictional independent projects.
Hospital A reads `incoming/encounters.csv` through encounter-oriented local
fields and maps them to the two canonical domains. Hospital B uses separate
`stays/`, `events/returns.csv`, and `events/deaths.csv` files with materially
different local field vocabulary and mapping code. Both pass through the same
unchanged generic operation and are admitted through the same installed
canonical authority. Those filenames, fields, rows, and mappings occur only in
the temporary test implementation; validator evidence rejects their presence
in generic package source/manuals or installed resources.

The same evidence copies Hospital A to an unrelated location, deletes the
original, and obtains the same admitted semantics through the copied closure's
captured root. It runs from an unrelated non-Git working directory. Successful
execution plus an internal repeat guard proves exactly one producer call; an
instrumented provider that would fail if called proves zero provider calls.
File inventory and digests prove that manifests, registration, and fictional
source files are unchanged. An existing extension library remains empty and an
absent extension library and state directory remain absent, proving that the
operation creates neither and writes no persistent output.

Adversarial orchestration evidence covers all three controlled producer
failures; producer-thrown private condition text; missing, additional, classed,
unsafe, unsupported-status, and inconsistent results; producer,
implementation, mapping, profile, capability, and as-of disagreement at both
result and candidate boundaries; an invalid private canonical value; invalid
as-of short-circuiting before even a project-root check; and bounded project
loading failure. The full Stage 5.B canonical adversarial matrix remains owned
by `rrpruntime` and was not duplicated.

Targeted historical reconnaissance inspected immutable `v0.1.0`
`operations/lib/canonical-producer-operation.R`,
`operations/compositions/installed-producers.R`, and
`tests/phase10/test-independent-adopter-producer.R`. Exact selected-callable
execution, single invocation, short-circuiting, fixed safe failure translation,
result/candidate/admission separation, and materially different adopter
producer proof were adapted to the current explicit-project and package-owned
boundaries. Installed producer composition, producer-supplied arbitrary
configuration, source flags, operation events, platform-instance files,
repository-root execution, synthetic defaults, downstream history/products,
and Phase suites were rejected.

Focused fresh build, dependency-order isolated install, and producer-execution
tests passed. During final validation, the expanded namespace exposed stale
seven-export assertions in three inherited package tests and one installed
resource-access child-process check. Only those assertions were updated to the
current exact eight-export posture; the affected project-contract, loader, and
initializer suites then passed in a fresh isolated installation.

Final local evidence passed:

- `Rscript --vanilla tools/validate-repository.R`: all eight repository checks,
  zero issues;
- `Rscript --vanilla tools/validate-packages.R`: exact source catalog and all
  13 resources, deterministic projection, inherited resource/project/canonical
  adversarial evidence, both source builds, missing-dependency rejection,
  dependency-order isolated install/load, exact `Status: OK` for both strict
  `R CMD check --no-manual` runs, installed resource/loading/initialization
  proofs, and the installed two-hospital/copy producer handoff proof; and
- R/Rd parsing, exact dependency/export inspection, targeted artifact and
  interruption-residue review, repository hygiene, and `git diff --check`
  completed without a retained archive, check tree, temporary library,
  projected root, project fixture, staging directory, or generated source
  artifact.

No shipped producer, source connector/configuration framework, provider
execution, eligibility, target, risk estimate, retry, scheduling, run/history
identity, state initialization, persistence, cache, product, application, CLI,
distribution, deployment, or release behavior was introduced. No
contradiction or deviation from the accepted 5.C plan, Platform Architecture,
or True North was found.

**Current implementation state:** Stages 1–4 remain accepted and complete.
Stage 5 remains in progress; Increments 5.A, 5.B, and 5.C are complete. Stage 5
has not yet undergone formal acceptance and reconciliation.

**Next task:** perform only formal Stage 5 acceptance and reconciliation. Do not
begin Stage 6 without separate authorization.
