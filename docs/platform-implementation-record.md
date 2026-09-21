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

## Stage 5 acceptance and reconciliation — 2026-09-17

Formal acceptance evaluated the complete committed Stage 5 baseline
`01b0d564ecbe55830542c10cfcb77d4d72366d7b`, containing accepted Increments
5.A–5.C. Public GitHub Actions evidence confirms that read-only
`package-foundation` push run `35288890797`, job `105427207401`, completed
successfully for that exact `main` revision.

The assembled boundary satisfies all 22 accepted Stage 5 criteria. Installed,
versioned, closed DCF resources own the canonical envelope, producer, bundle,
profile, and two domain contracts. The project manifest, API, and registration
contracts agree at `0.2.0`; unsupported structural `0.1.0` projects fail
explicitly. Initialization remains a two-file, inert-provider skeleton. Trusted
loading validates the selected producer declaration before execution. The one
supported operation constructs a closed request, invokes exactly the selected
hospital producer once, validates exact result identity, and delegates the
single candidate to dependency-light runtime admission.

Reconciliation against Platform True North and Platform Architecture found the
boundary both sufficient and minimal. Two materially different temporary
hospital mappings reach the same generic operation and canonical admission
path; copied-project evidence proves project-root portability. Generic package
source, manuals, and resources contain no hospital source vocabulary or
producer-identity branch. The admitted profile is deliberately small and
readmission-specific rather than a generic EHR model. Admission retains the
source-independent episode and dual-time terminal facts that Stage 6 can use
without reopening hospital mapping. Selected-provider structure remains inert,
with instrumented proof of zero provider calls.

Package posture remains exact: `rrpruntime` requires only R, imports no package,
and exports only `rrp_admit_canonical_bundle()`; `rrpplatform` imports only
`rrpruntime` and exports eight interfaces, with
`rrp_execute_producer()` the only Stage 5 addition. Producer execution and
admission write no project state or other persistent output. Controlled
failures remain bounded and diagnostics exclude raw source, canonical values,
paths, configuration, credentials, connections, SQL, and arbitrary exception
text.

No abstraction exists only to preserve historical structure, and no accepted
Stage 5 requirement remains partially implemented. No acceptance-blocking or
nonblocking reconciliation defect was found. Optional source conveniences,
including a future SQL-oriented mapping layer and broader adopter usability,
remain future usability work rather than defects. Target/eligibility/provider
execution belongs to Stage 6; history/persistence and all later product,
application, CLI, distribution, deployment, and release behavior remain
intentionally deferred.

Closeout evidence passed:

- `Rscript --vanilla tools/validate-repository.R`: all repository-foundation
  checks passed with zero issues;
- `Rscript --vanilla tools/validate-packages.R`: the complete installed
  resource, package, independent-project, canonical admission, two-hospital,
  copied-project, build, isolated install/load, and strict package-check matrix
  passed; and
- `git diff --check`: passed, with no generated validation artifact retained.

**Acceptance decision:** Stage 5 is accepted and complete. The plain-language
exit state is realized: a project-selected producer can submit
source-independent discharge episodes and dual-time readmission/death evidence
through a versioned canonical boundary, while RRP still does not construct a
risk request, invoke a provider, calculate risk, or retain operational state.

**Current implementation state:** Stages 1–5 are accepted and complete. Stage
6 has not begun.

**Next task:** detail and accept Stage 6 — Singular Target, Runtime, and Provider
Execution. Do not begin Stage 6 source implementation without separate
authorization.

## Stage 6 detailed-plan acceptance — 2026-09-18

Stage 6 — Singular Target, Runtime, and Provider Execution was detailed from
the accepted Stage 5 baseline without implementing source behavior. Planning
began from a clean `main` at
`8717c2f06b23a282e14ab8d3bdced1f882d044cc` (`Stage 5 complete`). Platform
True North, Platform Architecture, the complete plan and record, human
implementation guidance, and the coding-agent agreement were read in order.
The realized admitted-bundle type, canonical contracts, project manifest and
registration authorities, trusted loader, installed/project composition,
producer operation, package topology, exact exports, and current tests were
inspected as the factual starting point. No contradiction requires reopening
Stages 1–5.

The accepted construction sequence is:

1. **Increment 6.A — Singular target authority, eligibility, and immutable
   episode state:** add the exact target/state authorities and the pure runtime
   boundary that prepares one eligible detached episode state at the admitted
   bundle's authoritative as-of instant;
2. **Increment 6.B — Semantic provider contract and standard request/estimate
   boundary:** add request/provider/estimate authorities, advance the
   unreleased project line to `0.3.0`, and prove an explicitly supplied
   compatible provider against the RRP-owned request and estimate semantics;
   and
3. **Increment 6.C — Selected provider execution and transparent end-to-end
   proof:** add the one platform risk operation and protected transparent
   provider, then prove installed and project-owned provider substitution
   through the same admitted-bundle-to-estimate path.

Stage acceptance follows committed 6.C evidence and final reconciliation; it
is not Increment 6.D.

The central temporal decision is exact as-of equality. Stage 6 executes only
when requested analytical `t` denotes the same instant as the admitted
bundle's authoritative as-of. It does not filter a later bundle backward to an
earlier time. This both enforces the architecture's available-information rule
and avoids prematurely implementing retrospective reconstruction. A terminal
event affects eligibility only in the first admitted bundle whose exact cutoff
may legitimately include it.

Eligibility follows the target rather than workflow convention: discharge is
included; `W30` and later are excluded; a readmission or death known at or
before `t` prevents a request; and equal known readmission/death occurrence is
classified with readmission precedence. RRP constructs a minimal immutable
episode state and provider-neutral `(t,W30]` request containing only governed
episode timing and attribution. Patient and encounter identity, terminal rows,
the complete bundle, source/mapping details, arbitrary features, configuration,
paths, secrets, connections, and persistence handles do not reach providers.

The target is one installed nonselectable authority,
`rrp.risk-target.readmission-remaining-30-day@0.1.0`. Together with state,
request, provider, and estimate DCF authorities it will add exactly five
resources, taking the closed catalog from 13 to 18 by Increment 6.B. No target
registry, project target field, route, request-builder plugin, compatibility
range, or alternate quantity is planned.

The provider callable receives one detached RRP-constructed request and returns
only request identity, success/failure status, one probability or `NULL`, and a
controlled failure code. RRP constructs the accepted estimate envelope and
stamps exact software, target, state, request, project, bundle, provider,
implementation, optional model, interval, and as-of attribution. The
probability is exactly one unclassed finite base-R double in `[0,1]`; no
coercion, uncertainty, explanation, calibration, clinical-validity, decision,
or persistence meaning is accepted.

Provider declarations become semantic in the forward-only `0.3.0` project/
API/registration line. They declare exact provider API, target, state, request,
estimate, implementation, optional model, and callable facts. Producer
semantics and the closed manifest selection remain unchanged. Initialized
projects still contain exactly two files and explicitly select their own
semantically conforming unavailable provider. Structural `0.2.0` projects fail
instead of receiving a compatibility bridge or silent rewrite.

The maintained installed provider is
`rrp.provider.transparent@0.1.0` with implementation
`rrp.provider-implementation.transparent@0.1.0` and no model artifact. Its
inspectable deterministic calculation is only
`0.20 * remaining_to_target_seconds / 2,592,000`. It is explicitly
nonclinical, must be selected by exact manifest identity, follows the same
generic path as a project provider, and is never an implicit default, fallback,
or privileged runtime branch.

The planned package surface is deliberately small. `rrpruntime` remains
dependency-free and will add only `rrp_prepare_episode_state()` and
`rrp_execute_risk_provider()` beside canonical admission. `rrpplatform`
continues to import only `rrpruntime` and will add only
`rrp_execute_risk(software_catalog, project_root, admitted_bundle, episode_id,
as_of_time)` with operation ID `rrp.execute-risk`. The operation begins from
the Stage 5 admitted value and does not call a producer; complete proof invokes
the existing producer operation first at the same `t`. Stage 7 may later own
the one-run orchestration and durable attribution.

Historical reconnaissance inspected immutable `v0.1.0` runtime eligibility,
state, estimand request, provider specification/registry/compatibility/
execution, estimate, transparent provider, operation composition, runtime and
provider DCF/YAML contracts, Phase 4 runtime/provider tests, and package-native
tests. It also revisited the fixed-target assessment at revision `1e7b95c`.
Exact project selection already present on the clean line, trusted-callable and
probability checks, instant comparison, plain-value detachment, and bounded
failure mechanics are directly reusable where independently suitable.

Eligibility/state/request separation, exact cutoff, compatibility-before-call,
one-call execution, provider substitution, request/result agreement,
structured non-estimate outcomes, transparent-provider role, and adversarial
temporal/output fixtures are adaptable. Historical deterministic run/provenance
records are conceptual input for Stage 7 only. Daily hazard, shortened
follow-up, baseline/event feature state, estimand catalogs/routes/ranges,
runtime registry selection, retries and attempt/run IDs, old estimate
identities, raw exception issues, the historical transparent formula, YAML and
repository-root loading, Phase suites, history append, and source assumptions
are rejected.

The 17 planning-quality challenges were applied explicitly. The design operates
only from admitted source-independent input; exposes one target and one fixed
interval meaning; permits radically different provider methods behind one
request/result boundary; keeps target/protocol construction with RRP; prevents
earlier-time use of later bundles; handles competing death and equal-time
precedence; executes only exact project selection; treats the transparent
provider as ordinary; distinguishes structural estimates from clinical
validity; keeps runtime dependency-light and project/source independent;
contains no persistence; leaves a complete semantic result for Stage 7; imports
no historical-only abstraction; avoids forcing providers to reproduce RRP
envelopes; does not solve multiple-target, remote-provider, feature-store, or
model-packaging futures; and remains explainable through the governing plan
without AI assistance.

Persistence, run/attempt/history identity, retries, retrospective
reconstruction, state adapters/migration, multiple targets, additional
canonical domains/features, remote/non-R providers, provider dependency
restoration and model-artifact integrity, uncertainty/explanations,
calibration/evaluation, clinical validation, decisions, scheduling, the
maintained fictional project, products/app, CLI, distribution, deployment, and
release remain explicitly deferred to their owning later stages.

Planning validation passed `Rscript --vanilla tools/validate-repository.R`,
including current local documentation-link validation, and `git diff --check`.
Scope review confirmed that only planning/current-status documentation changed;
no package source/API/metadata, resource, test, validator, workflow, or other
implementation file changed. Package validation was intentionally not rerun
because this planning action changes no executable claim.

**Current implementation state:** Stages 1–5 remain accepted and complete.
Stage 6 is detailed and accepted for implementation, but no Stage 6 contract,
resource, package behavior, provider, operation, or test exists yet.

**Next task:** implement only Increment 6.A — Singular Target Authority,
Eligibility, and Immutable Episode State. Do not begin Increment 6.B, Increment
6.C, Stage 7, or Stage 6 acceptance.

## Stage 6 / Increment 6.A — Singular target authority, eligibility, and immutable episode state — 2026-09-18

Increment 6.A is complete. The closed source-resource authority now contains
exactly 15 entries. Two new runtime-owned DCF specifications establish the one
nonselectable target
`rrp.risk-target.readmission-remaining-30-day@0.1.0` and the detached state
contract `rrp.episode-state@0.1.0`. The specification envelope was extended
only for the two realized kinds. The target fixes the population, first
canonical readmission event, discharge origin, exact 2,592,000-second included
endpoint, eligible interval `[D,W30)`, target interval `(t,W30]`, dual
occurred-and-available cutoff, death competition, readmission equal-time
precedence, one probability quantity, prohibited target selection, and stable
eligibility failure codes. The state contract fixes its exact class, fields,
UTC timestamp representation, elapsed quantities, deterministic identity
inputs, expected context, eligible-only construction, and reference-free
detached value requirement.

`rrpplatform` now loads both resources exclusively through the validated
explicit-root catalog, requires their exact fields and identities, and checks
their target, state, canonical-bundle, canonical-profile, 30-day endpoint, and
terminal-event relationships. It assembles one closed plain-value runtime
context from those installed authorities. Software-resource validation invokes
this relationship check. No platform export was added; its exact public
surface remains eight functions.

`rrpruntime` remains base-R-only with no `Imports`, `Suggests`, or `LinkingTo`
and now exports exactly two functions. The new
`rrp_prepare_episode_state(admitted_bundle, episode_id, as_of_time,
expected_context)` revalidates the admitted canonical boundary, requires the
analytical time and bundle cutoff to denote exactly the same instant, selects
exactly one episode, verifies its target endpoint, evaluates eligibility, and
constructs one detached `c("rrp_episode_state", "list")` value. Discharge is
eligible; `W30` and later are not. A readmission or death whose occurrence and
availability are admitted through `t` prevents construction, and a same-time
readmission/death tie returns the readmission failure. Valid states contain
only governed contract, target, bundle, project, profile, episode, normalized
UTC timing, elapsed/remaining seconds, deterministic state identity, and the
controlled nonterminal status. They contain no patient or encounter identity,
terminal row, full bundle, producer/mapping/source fact, arbitrary feature,
provider, run, history, path, connection, or reference-bearing value.

Expected failures inherit from `rrp_runtime_error` and carry one stable code,
`NULL` call, and fixed bounded privacy-safe message. The target codes are
`invalid_analytical_as_of`, `analytical_as_of_mismatch`, `unknown_episode`,
`episode_before_discharge`, `target_horizon_exhausted`,
`episode_already_readmitted`, and `episode_already_dead`; invalid caller
context or a corrupted admitted value fail separately at the runtime boundary.
The canonical-admission implementation produces ordinary default row names in
its detached result, while original candidate admission accepts compact row
names. Revalidation therefore first requires exact ordinary default row names,
normalizes only a private validation copy, and reuses canonical admission. It
does not weaken or mutate either input boundary.

Historical reconnaissance inspected `v0.1.0` runtime `utils.R`,
`eligibility.R`, and `state.R`; runtime unit and Phase 4 foundation tests; and
the former eligibility-result and episode-state contracts. Explicit-offset
parsing, instant comparison, eligibility-before-state sequencing, fixed cutoff,
deterministic identity intent, and boundary-focused temporal fixtures were
adapted. Shortened horizons, daily-hazard semantics, root terminal timestamps,
baseline/generic feature state, run identity, YAML loading, repository-root
orchestration, and persistence were rejected. Current Stage 5 admission,
plain-value, timestamp, safe-condition, and detachment mechanics were reused
directly where their ownership remained correct.

Package-native evidence covers state construction at discharge and one second
before `W30`; rejection at and after `W30`; the otherwise unreachable
before-discharge eligibility guard; readmission and death before or exactly at
`t`; equal-time precedence; late availability across separately admitted
cutoffs; multi-episode isolation and unknown selection; exact-offset
equivalence and earlier/later mismatch; malformed and attributed input;
deterministic identity; exact type/field/timing shape; input nonmutation and
post-construction detachment; reference rejection; and fixed safe errors.
Platform tests cover exact installed loading, closed context assembly,
cross-resource agreement, direct admitted-bundle-to-state integration, unknown
fields, unsupported versions, and incompatible references. The maintainer
validator also proves exact 15-resource projection and byte equality, the
two-export/eight-export package posture, one-way dependency, builds, isolated
installation/loading, and package-native checks.

Local implementation evidence passed:

- `Rscript --vanilla tools/validate-repository.R`: all eight repository checks
  passed with zero issues;
- focused isolated installation plus the runtime episode-state and platform
  runtime-contract tests: passed;
- `Rscript --vanilla tools/validate-packages.R`: the complete inherited and
  Increment 6.A resource, package, project, canonical, and state matrix passed,
  including both source builds and exact `R CMD check --no-manual` status `OK`;
  and
- `git diff --check`: passed, with no generated archive, check directory,
  temporary library, projected root, or other validation output retained in
  repository source.

No discrepancy from Platform True North, Platform Architecture, or the
accepted 6.A plan was found. No provider declaration, request, estimate,
project-contract bump, provider callable, transparent provider, platform risk
operation, run identity, state write, persistence, or Stage 6 acceptance was
introduced.

**Current implementation state:** Stages 1–5 remain accepted and complete.
Increment 6.A is complete; Stage 6 remains in progress. Dependency-light
runtime can decide eligibility and construct the exact immutable state for one
admitted episode at the bundle's authoritative as-of instant, but no provider
can receive a request.

**Next task:** implement only Increment 6.B — Semantic Provider Contract and
Standard Request/Estimate Boundary. Do not begin Increment 6.C, Stage 7, or
Stage 6 acceptance.

## Stage 6 / Increment 6.B — Semantic provider contract and standard request/estimate boundary — 2026-09-18

Increment 6.B is complete. The closed source-resource authority now contains
exactly 18 entries. Three new runtime-owned DCF specifications establish
`rrp.risk-request@0.1.0`, `rrp.provider-api@0.1.0`, and
`rrp.risk-estimate@0.1.0`. Together with the 6.A target and episode-state
authorities they form the exact five-resource runtime family. The specification
envelope was extended only for the three realized kinds. `rrpplatform` loads
the new authorities solely through the validated explicit software catalog,
requires exact field/identity equality, checks every target/state/request/
provider/estimate relationship, and assembles the closed plain runtime provider
context. The projected installed resources remain byte-equal to source.

The unreleased project manifest, project API, and registration contract moved
atomically from `0.2.0` to the sole supported `0.3.0` line. Manifest fields did
not change. Provider registration now contains exactly component, provider API,
target, state, request, estimate, implementation, nullable model, and callable
facts. Validation requires exact installed-authority agreement, independent
bounded implementation identity, both-null or both-present model identity, and
a one-argument `request` callable without invoking it. Producer semantics are
unchanged. Structural `0.2.0` manifests, API declarations, and registration
results fail explicitly; no compatibility bridge, rewrite, range, or migration
was introduced.

Initialization still creates exactly `rrp-project.dcf` and `R/register.R` in a
new project. Its provider is project-derived, semantically conforming, declares
no separate model, and would return only the controlled
`provider_unavailable` result. Initialization, loading, project doctor, and
producer execution do not invoke it. The loader remains the sole exact project
provider-selection authority. The doctor adds only bounded implementation and
nullable model identity to its provider summary. `rrpplatform` still imports
only `rrpruntime` and still exports exactly eight functions; no platform risk
operation or installed provider exists.

`rrpruntime` remains base-R-only with no `Imports`, `Suggests`, or `LinkingTo`
and now exports exactly three functions. The new
`rrp_execute_risk_provider(episode_state, provider, expected_context)`
revalidates the closed state and its deterministic identity, validates exact
provider compatibility before invocation, constructs one deterministic
detached `c("rrp_risk_request", "list")` request for `(t,W30]`, passes only a
detached request copy to the callable, invokes it exactly once, and validates
the exact four-field result. The request contains governed contract, target,
state, bundle-instance, project, episode, time, interval, and elapsed facts; it
contains no provider identity, bundle/domain payload, source or mapping fact,
project root/path, credential, connection, feature surface, callback, state
handle, or persistence reference.

Successful provider output must contain the matching request identity, status
`success`, one unclassed finite base-R double in `[0,1]`, and `NULL` failure.
Controlled failure contains no value and only `provider_unavailable`,
`provider_input_unavailable`, or `provider_calculation_failed`. Thrown
conditions, malformed/unsafe results, mismatched request identity, and invalid
probabilities raise fixed privacy-safe `rrp_runtime_error` codes without raw
condition text. RRP constructs the exact closed detached
`c("rrp_risk_estimate", "list")` envelope and stamps all software, target,
request, state, bundle-instance, project, episode, provider, implementation,
nullable model, interval, output, and value attribution from validated context.
No estimate/run/attempt/history identity, retry, registry, fallback, model
loading, persistence, or decision field was added.

Historical reconnaissance inspected immutable `v0.1.0` estimand-request,
provider-specification, registry, compatibility, execution, estimate, and
reference-provider source; their runtime/provider contracts; and Phase 4 and
package-native tests. Compatibility-before-invocation, exact trusted callable,
detached input, one-call proof, request/result identity agreement, bounded
probability, provider substitution, structured non-estimate failure, and
adversarial output mechanics were adapted. The runtime registry, estimand
collections/ranges, arbitrary state-field and feature requirements, baseline/
event feature state, retries/attempts/run identities, raw exception issues,
historical estimate identity/provenance shapes, YAML, daily hazard, repository-
root loading, and the old reference formula were rejected.

Evidence covers exact DCF fields/identities and five-resource relationships;
the 18-resource closed projection; coherent `0.3.0` project initialization,
loading, diagnosis, copy portability, and `0.2.0` rejection; semantic provider
and model-pair validation; zero provider calls in all existing platform
operations; exact request/estimate class and field order; deterministic request
identity; fixed interval; state/request detachment and nonmutation; exact
single invocation; success and all controlled failure paths; provider-thrown,
malformed, unsafe, identity-mismatched, non-double, nonfinite, attributed,
length, and range failures; dependency and export posture; source builds;
isolated install/load; and exact package checks.

Local implementation evidence passed:

- `Rscript --vanilla tools/validate-repository.R`: all eight repository checks
  passed with zero issues;
- focused isolated runtime and platform tests for provider execution, runtime
  authority, project contracts, loader, initializer, doctor, and producer
  regression behavior: passed;
- `Rscript --vanilla tools/validate-packages.R`: the complete inherited and
  Increment 6.B resource, package, project, canonical, state, request,
  provider, and estimate matrix passed, including both source builds and exact
  `R CMD check --no-manual` status `OK`; and
- R/DCF/Rd parsing and `git diff --check`: passed, with no generated archive,
  check directory, temporary library, projected root, or other validation
  output retained in repository source.

No discrepancy from Platform True North, Platform Architecture, or the
accepted 6.B plan was found. No installed transparent provider, selected
project-provider invocation, platform risk operation, fallback/retry, provider
dependency or model loading, history, persistence, workflow change, Stage 6
acceptance, or Stage 7 behavior was introduced.

**Current implementation state:** Stages 1–5 remain accepted and complete.
Increments 6.A and 6.B are complete; Stage 6 remains in progress. Dependency-
light runtime can construct the standard request, execute one explicitly
supplied compatible provider, and accept or reject one estimate, but installed
RRP does not yet execute the provider selected by a project.

**Next task:** implement only Increment 6.C — Selected Provider Execution and
Transparent End-to-End Proof. Do not begin Stage 7 or Stage 6 acceptance.

## Stage 6 / Increment 6.C — Selected provider execution and transparent end-to-end proof — 2026-09-19

Increment 6.C is complete locally. `rrpplatform` now exports exactly nine
functions. The new `rrp_execute_risk(software_catalog, project_root,
admitted_bundle, episode_id, as_of_time)` operation validates its scalar inputs,
loads exactly the explicit project through the sole trusted loader, reconstructs
the installed canonical/runtime authority, prepares one eligible immutable
episode state, verifies project/profile agreement, and invokes exactly the
provider already selected by that project through
`rrpruntime::rrp_execute_risk_provider()`. Success returns the detached accepted
estimate in the common `rrp.execute-risk` result. Expected project, operation,
target, state, provider, and estimate failures become bounded privacy-safe
diagnostics; resource-owner failures and unexpected implementation defects are
not obscured.

Installed composition now contains one protected provider declaration,
`rrp.provider.transparent@0.1.0`, with implementation
`rrp.provider-implementation.transparent@0.1.0` and no separate model identity.
It declares exact agreement with the installed target, state, request, provider
API, and estimate authorities. Its deterministic nonclinical value is
`0.20 * remaining_to_target_seconds / 2592000`. A project must select that
identity explicitly: it is not a default, fallback, registry preference, or
clinically validated model. Project-owned compatible providers remain the
ordinary substitution boundary and execute through unchanged generic
orchestration. Protected identities remain rejected in project-owned
registration; a narrow internal validation path exists only for RRP-owned
installed declarations.

Both producer and provider execution retain the established software-first,
declared-extension-second controlled library policy and restore the caller's
library paths and working directory. Risk execution creates no state directory,
file, log, cache, request record, estimate record, run identity, retry, history,
or other persistent output. The installed source-resource authority remains
the exact 18-resource set; no provider registry or new contract resource was
introduced.

Historical reconnaissance inspected immutable `v0.1.0` reference-provider,
provider-registry, provider-execution, provider-operation, and Phase 4 provider-
foundation material. Compatibility-before-call, detached input, exact one-call
behavior, deterministic example-provider proof, provider substitution, process
restoration, and structured failure mechanics were adapted. Historical
registry-based selection, the daily-hazard reference formula, raw error text,
retry/attempt/history behavior, and repository-root orchestration were rejected.

The package-native and installed temporary-root evidence covers an existing
producer call at authoritative time `t`, runtime admission, and risk execution
at the same `t`; explicit installed transparent-provider selection; exact
formula and complete target/request/state/project/provider/implementation/model
attribution; deterministic repeat behavior; a materially different project-
owned provider through the same operation; copied-project execution from an
unrelated non-Git working directory; exact one-call and pre-invocation no-call
guards; no implicit provider default; provider-declared and RRP-detected
failures; resource-error ownership; library/working-directory/global
restoration; accepted-estimate detachment; generic-code independence from
provider/project identity; and absence of project/state mutation or output.

Local implementation evidence passed:

- `Rscript --vanilla tools/validate-repository.R`: all repository checks passed
  with zero issues;
- focused isolated installed-package regression and risk-execution tests:
  passed;
- `Rscript --vanilla tools/validate-packages.R`: the complete inherited and
  Increment 6.C resource, package, project, producer, runtime, and installed
  selected-provider matrix passed, including both source builds, isolated
  installation/loading, package-native tests, and exact
  `R CMD check --no-manual` status `OK`;
- R source, Rd, and DESCRIPTION parsing: passed; and
- `git diff --check` and repository-artifact inspection: passed, with no
  generated archive, check directory, temporary library, projected root, or
  other validation output retained in repository source.

No discrepancy from Platform True North, Platform Architecture, or the
accepted 6.C plan was found. No implicit provider selection, provider dependency
or model loading, retry, concurrency, remote transport, run/history identity,
persistence, product, application, CLI, distribution, deployment, release,
Stage 7 behavior, or formal Stage 6 acceptance was introduced.

**Current implementation state:** Stages 1–5 remain accepted and complete.
Increments 6.A–6.C are implemented locally, so all planned Stage 6 increments
are complete. Stage 6 remains in progress until its separately authorized
formal acceptance and reconciliation, including the plan's committed hosted
evidence boundary.

**Next task:** perform formal Stage 6 acceptance and reconciliation only after
the complete Stage 6 tree is reviewed and committed and the required hosted
workflow evidence is available. Do not begin Stage 7.

## Stage 6 acceptance and reconciliation — 2026-09-19

Stage 6 was reviewed as one realized architectural stage at the exact committed
implementation baseline `c9a8f539d07611d29ec86d4fd1ee5a308413938c`. GitHub
Actions workflow `package-foundation`, push run `35444384900`, job
`105900696412`, completed successfully for `main` at that exact SHA. The job
used Ubuntu and R 4.4 and passed checkout, repository validation, and package
validation. This hosted identity applies to the committed implementation under
review, not to the later uncommitted acceptance-documentation state.

The combined 6.A–6.C review passed every accepted Stage 6 criterion. The closed
18-resource catalog contains exactly the five governed runtime authorities for
the singular nonselectable remaining day-30 target, episode state, risk
request, provider API, and risk estimate. Target semantics remain the first
canonical readmission in `(t,W30]` conditional on being alive and
readmission-free through `t`, with `W30` exactly 2,592,000 elapsed seconds after
discharge, admitted-information cutoff, competing death, and equal-time
readmission precedence. Analytical `t` must be the same instant as the admitted
bundle cutoff; eligibility is exactly `D <= t < W30`; terminal occurrence and
availability remain distinct; and no daily-hazard, target-selection, or
retrospective-reconstruction surface exists.

Runtime constructs the deterministic, detached, closed, provider-neutral state
only for an eligible episode, then constructs the deterministic detached
standard request. Neither object exposes patient/encounter identity, source or
mapping facts, arbitrary features or domains, provider selection in the
request, paths, credentials, connections, callbacks, persistence handles, or
run/history identity. Provider compatibility is exact across API, target,
state, request, and estimate authorities before invocation, while
implementation identity remains distinct and model identity remains explicitly
nullable. The provider receives exactly one request argument. The runtime
primitive revalidates its boundary, calls exactly one supplied provider once,
accepts only the closed matching four-field result and controlled failure
codes, suppresses raw provider condition text, and returns no estimate for
malformed, mismatched, nonfinite, non-double, attributed, or out-of-range
values.

An accepted estimate is closed and detached, carries the governed target,
state, request, project, episode, provider, implementation, and nullable-model
attribution, and contains one plain finite base-R double probability in
`[0,1]`; both `0` and `1` are valid. It contains no run, attempt, history,
uncertainty, alternate horizon, classification, band, explanation,
recommendation, threshold, or clinical action. The `0.3.0` project/API/
registration line is the sole supported line, structural `0.2.0` projects fail
without a bridge, Stage 5 producer semantics remain intact, and project
initialization remains two-file and nonexecuting.

At platform level, `rrp_execute_risk()` uses an explicit validated software
catalog and project root, the sole trusted loader, the exact provider selected
by the project manifest, runtime-owned state construction, and the generic
runtime provider primitive. Only expected typed failures become bounded common
`rrp.execute-risk` diagnostics; resource-owner and unexpected defects are not
broadly hidden. Generic execution contains no provider-, implementation-,
model-, or project-identity route. The protected installed
`rrp.provider.transparent@0.1.0` declaration has implementation
`rrp.provider-implementation.transparent@0.1.0`, no model identity, requires
explicit selection, cannot be impersonated by project registration, and uses
the same generic path as a materially different project-owned provider. Its
inspectable nonclinical formula remains exactly
`0.20 * remaining_to_target_seconds / 2592000`; it is neither a default nor a
historical daily-hazard model.

Installed-system evidence passed from fictional temporary source through the
selected producer, admitted canonical bundle at authoritative `t`, eligible
state, exact selected provider, and accepted estimate. It used isolated
installed packages and byte-preserved resources from an unrelated non-Git
working directory, repeated with a copied project, demonstrated explicit
transparent-provider selection and materially different project-provider
substitution, proved one provider call for eligible execution and no call for
pre-provider failures, restored library paths and working directory, and wrote
no project state or other persistent output. The software-first then declared-
extension library policy remains intact, and no project dependency can shadow
installed RRP through the supported path.

Package posture is exact. `rrpruntime` remains base-R-only with no `Imports`,
`Suggests`, or `LinkingTo` and exports only
`rrp_admit_canonical_bundle()`, `rrp_prepare_episode_state()`, and
`rrp_execute_risk_provider()`. `rrpplatform` imports only `rrpruntime` and
exports exactly nine functions, including `rrp_execute_risk()`. Dependency
direction remains only `rrpplatform -> rrpruntime`. Installed projection is
deterministic and byte-preserving. No provider registry, later-stage resource,
permanent fictional hospital/producer, fallback, retry, parallel/remote
execution, provider dependency environment, model artifact manager, state or
history persistence, product, application, CLI, distribution, deployment,
release behavior, or other Stage 7+ capability entered.

Local acceptance evidence passed:

- `Rscript --vanilla tools/validate-repository.R`: 8 checks passed with zero
  issues;
- `Rscript --vanilla tools/validate-packages.R`: the complete resource,
  package, project, producer, canonical, state, request, provider, estimate,
  copied-project, substitution, failure, process-restoration, and no-output
  matrix passed; both source builds, dependency-order isolated install/load,
  package-native tests, and both `R CMD check --no-manual` operations completed
  with exact status `OK`;
- namespace, dependency, resource, generated-artifact, and scope inspection:
  passed; and
- `git diff --check`: passed after acceptance reconciliation.

No blocking finding or material discrepancy with Platform True North, Platform
Architecture, or the accepted Stage 6 plan was found. Two nonblocking current-
documentation defects found during review were corrected: the human dependency
summary now includes the already-realized ninth `rrpplatform` export, and the
agent evidence summary's interrupted 6.B sentence is complete. These corrections
do not change implementation behavior. All persistence, run/attempt identity,
idempotency/conflict, retry, invalidation/restatement, history access, state
adapters, locking, backup/recovery, and migration concerns remain expected
Stage 7 deferrals and are not Stage 6 defects. Stage 6 introduced no unnecessary
compatibility layer, duplicated authority, repository-root assumption, ambient
discovery, or provider-specific special case.

**Acceptance decision:** Stage 6 is accepted and complete. Stages 1–6 are now
accepted and complete. Installed RRP can admit source-independent canonical
readmission data, evaluate the singular fixed-endpoint eligibility/state
boundary at authoritative time `t`, construct the standard risk request, and
execute exactly the compatible provider selected by an independent project to
return one governed accepted risk estimate or bounded failure, while retaining
no operational state. Stage 7 has not begun.

**Next task:** detail Stage 7 — Project State and Operational History from the
accepted realized system. Do not implement Stage 7 before its separate detailed
plan is accepted.

## Stage 7 — Project state and operational history

### Increment 7.A — Logical history contracts, port, and in-memory semantics (complete, 2026-09-19)

Increment 7.A establishes the complete dependency-light logical history
foundation without creating project state or selecting physical storage. Four
new `rrpruntime`-owned DCF authorities are admitted through the closed source
catalog: immutable bundle-scoped operational scope, terminal episode
disposition, append-only invalidation/restatement action, and the storage-
neutral history port. The resource inventory now contains exactly 22 entries
and projects the four history authorities byte-for-byte with the existing
software resources.

The interrupted implementation was recovered rather than restarted. Its four
catalog declarations and record-family direction were retained. Explicit
closed-field constructors replaced fragile positional assembly, and the
partial relationship/current resolver was completed around one central graph
validator. The partial port's `close_reopen_durability` requirement was removed:
close/reopen is physical-adapter evidence owned by 7.B, not a truthful
capability of the 7.A test-only in-memory adapter. The Stage 7 plan now states
that boundary explicitly without changing the accepted durable 7.B target.

`rrpruntime` advances from `0.3.0.9000` to `0.4.0.9000`, retains no `Imports`,
`Suggests`, or `LinkingTo`, and exports exactly 15 technical interfaces: the
existing three canonical/state/provider primitives plus 12 history record,
port, append, and read interfaces. Deterministic operation-run identity uses
initialized state identity, the fixed named operation, and caller operation
key. Initial analytical identity uses operation, episode, target/version, and
analytical time; explicit retry/restatement identity additionally uses kind,
predecessor, and bounded analytical key. Nullable identity inputs use the
governed literal-null encoding. Admitted membership uses sorted unique UTF-8
episode IDs with count and byte-length prefixes before the existing dual-
modular hash. The fingerprint is deterministic equality/integrity evidence,
not a security primitive.

Scope completeness is derived only from unique initial dispositions whose
count and membership fingerprint reproduce the immutable scope; zero-episode
scopes are complete immediately, partial or mismatched scopes remain visibly
incomplete, and retry/restatement records do not alter progress. Closed outcome
rules distinguish ineligibility, accepted estimate, compatibility failure,
provider-declared failure, and detected failure, including exact state,
request, provider-execution, and estimate presence. Relationship validation
enforces scope target/time provenance, one initial disposition per admitted
episode identity within a scope, failure-only explicit retry, nonbranching
lineage, narrow scope-action reasons, and matching atomic restatements.

Raw reads retain immutable scopes, outcomes, failures, and actions. Current
episode interpretation requires explicit analytical and history cutoffs,
excludes incomplete and invalidated scopes, applies only effective actions,
resolves retry/restatement lineage, permits a newer terminal failure or
ineligibility to remain current, and fails rather than using insertion order or
identity to break unrelated same-time ambiguity. Port writes validate before
delegation; reads validate detached records and relationships afterward.
Because scope creation and terminal disposition are operational events that
follow exact-`t` admission and processing, their timestamps may equal but may
not precede the authoritative analytical time. Focused constructor tests prove
equality and later times and reject either operational timestamp before `t`.

The package-native history test owns the only adapter introduced here. It is a
dependency-free process-local in-memory conformance fixture, not production
software. It proves zero/one/multiple-episode scope behavior; success,
ineligibility, compatibility, declared-failure, and detected-failure records;
partial/complete and fingerprint-mismatch progress; exact idempotency and
conflict; continuation versus explicit retry; episode/scope invalidation and
restatement; analytical/history cutoffs; incomplete-scope gating; same-time
ambiguity; detached reads; bounded diagnostics; and atomic logical
restatement. It creates no project path or retained state.

Historical reconnaissance inspected immutable `v0.1.0`
`runtime/R/history-records.R`, `runtime/R/persistence-port.R`,
`runtime/R/history-conformance.R`, and
`tests/helpers/in-memory-history-adapter.R`. Validate-before-delegate port
composition, exact-content idempotency/conflict, detached records, and the
in-memory conformance technique were adapted. Historical YAML authority,
daily-hazard/estimand semantics, five analytical families, started/failed run
lifecycle, multi-attempt batches, giant completed-population transactions, and
family-level invalidation cascades were rejected.

Local evidence passed the complete proportional checkpoint:

- `Rscript --vanilla tools/validate-repository.R`: all eight repository checks
  passed with zero issues;
- `Rscript --vanilla tools/validate-packages.R`: exact 22-resource closure and
  projection, all package-native tests including in-memory history conformance,
  both source builds, dependency-order isolated installation/loading, both
  strict `R CMD check --no-manual` operations with `Status: OK`, and all prior
  installed project/producer/provider regressions passed;
- direct R parsing of package and validator source and exact comparison of the
  four history DCF documents against their hard-coded validator authorities
  passed; and
- generated-artifact review and `git diff --check` passed.

**Current implementation state:** Increment 7.A is complete; Stage 7 remains in
progress. Dependency-light runtime can construct, validate, append through,
and interpret storage-neutral immutable history, but no project can initialize,
retain, close/reopen, back up, or restore it. No project state directory, DBI,
DuckDB, durable database/file, production adapter, producer/provider durable
orchestration, product, application, CLI, migration, or legacy import exists.

**Next task:** implement only Increment 7.B — Explicit project state and DuckDB
adapter.

### Increment 7.B — Explicit project state and DuckDB adapter (complete, 2026-09-20)

Increment 7.B realizes the accepted 7.A logical history port in explicit local
project state without connecting ordinary producer or provider computation to
history. `rrpplatform` now directly imports `DBI`, `duckdb`, and `rrpruntime`,
and exports exactly 11 technical interfaces after adding
`rrp_initialize_project_state()` and `rrp_inspect_project_state()`. The package
remains version `0.1.0.9000`; the existing project/API line remains `0.3.0`.
Raw connections, SQL, table names, adapter construction, and failure injection
remain protected implementation details.

Two platform-owned installed authorities extend the closed resource catalog to
exactly 24 entries. `rrp.project-state` defines the exact two-file inventory
(`state.dcf` and `history.duckdb`), closed metadata, opaque non-path-derived
state identity, project/API/target/logical-history provenance, compatibility
rules, and prohibition on automatic migration or repair. The
`rrp.adapter.duckdb-history` authority fixes the adapter and physical-schema
versions, four private tables, query columns, transaction families, bounded
read posture, private-session lifecycle, and single controlled local writer.
The manifest's existing safe relative `State-Path` remains the sole location
authority.

Initialization is explicit, create-only, and non-destructive. It validates the
loaded project and state authorities, creates only necessary owned parent
segments, constructs metadata and the empty database in a project-root staging
directory, validates the staged state, atomically promotes it, and removes
owned staging/empty-parent residue on failure. Repeating initialization against
compatible state succeeds idempotently without changing its identity; partial,
linked, unknown, malformed, corrupt, other-project, or incompatible state is
rejected rather than repaired. Inspection is nonmutating and reports
`not_initialized`, `compatible`, or a bounded typed failure. The project doctor
now delegates to that inspection: absence remains a warning, compatible state
is reported as such, and incompatibility is a failure without creation or
repair.

The private DuckDB realization opens and closes one bounded connection for each
port operation, validates schema and embedded metadata before use, and returns
detached logical records. Indexed scalar columns support bounded scope and
episode/target relationship reads, while each row also stores its complete
logical record. Exact preflight comparison provides same-content idempotency
and different-content identity conflict. Scope, disposition, and action writes
each use one transaction; restatement inserts its replacement disposition and
action in one transaction. Rollback leaves neither partial row, while an
injected post-commit interruption is recovered by the normal idempotent retry.
Incomplete and complete scopes, independently committed dispositions, and
independently committed actions therefore remain valid physical states. The
accepted runtime layer continues to own completeness and raw/current semantic
interpretation.

The bounded payload-format evaluation selected
`r-serialize-v3-xdr-hex-v1`: base-R serialization version 3 with XDR enabled,
encoded as canonical lowercase hexadecimal text. A raw DuckDB BLOB would avoid
the two-times text expansion but adds driver-specific raw/list binding and
retrieval behavior without improving 7.B semantics. The chosen representation
is a deterministic scalar, preserves the exact validated R logical object
through close/reopen, is easy to reject when malformed, and is explicitly
versioned and private so a later physical-schema migration can replace it. The
storage cost is accepted for this correctness-first local reference adapter;
the payload is not a public interchange format or a security encoding.

Historical reconnaissance inspected immutable `v0.1.0`
`implementations/persistence/duckdb/R/foundation.R`, `session.R`, `schema.R`,
and `adapter.R`, plus `tests/phase5/test-duckdb-persistence.R`. Explicit
non-destructive initialization, schema metadata, adapter-owned connection
lifecycle, transaction/preflight mechanics, deterministic reads, version-3
hex payloads, close/reopen, and interruption injection were adapted. The old
repository configuration, six analytical-family tables, physical validity
logic, giant batch transaction, optional dependency posture, backup/restore,
and legacy migration/import were rejected.

Recovery preserved the coherent partial implementation and made only bounded
corrections revealed by focused and strict evidence. These included preserving
typed state failures across connection wrappers, classifying writer-lock
unavailability, correcting a stale fixture resource count, eliminating one
`R CMD check` namespace note, forwarding complete installed library paths to
nested process proofs, clearing only the check-owned relative `R_TESTS` hook in
those child processes, and updating the older installed doctor regression to
require initialized compatible state rather than accepting an arbitrary state
directory. No accepted 7.A record, relationship, identity, completeness,
retry, correction, or current-history semantic changed.

Package-native evidence covers missing/existing/partial/linked/unsafe state;
exact inventory and all compatibility fields; staging and promotion cleanup;
idempotent initialization; other-project state; exact scope, disposition, and
action roundtrip; incomplete progress and derived completion; operation-key
conflict; raw/current and restatement behavior; detached reads; copied projects
with and without state; arbitrary non-Git working directory; fresh-process
reopen; separate-process writer contention; and injected interruption before,
during, and after every scope/disposition/action/restatement transaction. The
same scenarios run against a dependency-free in-memory fixture and the DuckDB
adapter to prove logical equivalence.

Final proportional evidence passed:

- `Rscript --vanilla tools/validate-repository.R`: all eight repository checks
  passed with zero issues;
- `Rscript --vanilla tools/validate-packages.R`: exact 24-resource authority
  and projection, both static package boundaries and source builds, negative
  dependency-order proof, all package-native tests, dependency-order isolated
  installation/loading, both strict `R CMD check --no-manual` operations with
  `Status: OK`, and all installed resource/project/producer/provider
  regressions passed;
- direct R, DESCRIPTION, and Rd parsing passed; and
- generated-artifact review and `git diff --check` passed.

Post-commit hosted acceptance exposed one validation-environment assumption,
not a state/history defect. The clean Ubuntu runner had neither `DBI` nor
`duckdb`, while the local R installation happened to provide both in
`.Library`; the validator's deliberately narrowed library search therefore
made the hosted `rrpplatform` installation fail before its package-native
tests. The read-only workflow now explicitly installs only these two declared
external dependencies. The validator discovers those declared installations,
copies only them into controlled temporary platform and negative-proof
libraries, and uses a separate empty temporary library for the dependency-light
`rrpruntime` install/load/check. The negative platform installation now asserts
that `DBI` and `duckdb` resolve from its controlled library and that the sole
unavailable dependency is `rrpruntime`. A platform-positive library receives
the same external packages plus an explicit installation of the built internal
`rrpruntime` archive before `rrpplatform` is installed and checked. This keeps
the original isolated-validation meaning while removing reliance on a
developer's ambient library.

Focused reconciliation proved the external-only negative library failed with
exactly `dependency ‘rrpruntime’ is not available`. The complete local
checkpoint then passed repository validation, controlled dependency
provisioning, the isolated dependency-light runtime check, the platform check
with its declared internal and external dependencies, all 7.B DuckDB tests,
all inherited installed regressions, and both strict checks with `Status: OK`.
A new committed hosted run remains required to confirm this workflow correction
in the clean runner. No 7.B runtime, state, history, contract, package metadata,
or API semantic changed.

**Current implementation state:** Increment 7.B is complete locally; Stage 7
remains in progress. An explicit project can initialize, inspect, copy, and
reopen a compatible local DuckDB history store, and the protected adapter
durably satisfies the accepted logical port. Normal RRP computation still does
not write history. No durable bundle-run or continuation orchestration,
supported correction operation, automatic retry, backup/restore, migration,
remote adapter, product, application, CLI, release, or deployment behavior was
introduced.

**Next task:** implement only Increment 7.C — Bundle-scoped durable operation
and history interpretation.

### Increment 7.C — Bundle-scoped durable operation and history interpretation (complete, 2026-09-20)

Increment 7.C connects the existing Stage 5 producer/admission boundary, Stage
6 episode/provider semantics, Stage 7.A logical history, and Stage 7.B durable
port without changing those public primitives. `rrpplatform` now exports
exactly 18 interfaces after adding `rrp_execute_durable_bundle()`, explicit
failed-attempt retry, three bounded scope/episode/current reads, and generic
append-only invalidation/restatement operations. The main operation accepts an
explicit software catalog, project root, analytical time, and caller operation
key. It preflights compatible initialized state, executes the selected producer
once, admits the candidate, and only then creates or exactly matches the
immutable admitted-bundle scope.

Admitted episode identities are sorted deterministically. Each missing initial
analytical identity is evaluated with unchanged Stage 6 eligibility and
provider semantics and appended in its own atomic transaction. Terminal
records distinguish ineligibility, accepted estimates, provider incompatibility,
provider-declared failure, and detected execution/result/estimate failure with
bounded codes and the exact governed state/request/estimate evidence permitted
by the accepted history contract. The public Stage 6 provider primitive keeps
its exact result/error behavior; a protected runtime evidence path now shares
that same validation and one-call engine with durable orchestration. Project
registration incompatibility remains the existing earlier Stage 6 project-load
failure and is therefore nonhistorical; the terminal `provider_incompatible`
mapping applies to a post-admission runtime compatibility failure and is proved
at the protected runtime boundary without weakening trusted project loading.

Completeness remains derived solely from the initial disposition count and
membership fingerprint. Repeating a complete operation reexecutes the producer
to reestablish the admitted population but invokes no provider and adds no
history. Reopening an interrupted matching operation likewise skips every
committed terminal initial disposition, including failures, and evaluates only
missing episodes. A changed admitted population under the same operation key
conflicts with the immutable scope. No canonical bundle, loop cursor, mutable
completion flag, or second episode manifest is persisted.

`rrp_retry_episode()` accepts only a provider-declared or detected failed
analytical attempt, creates one deterministic related retry identity from a
caller key, invokes the currently selected compatible provider at most once,
and preserves the original failure. Repeating the same retry key returns the
committed child without another provider call; a second different child for
the same parent is rejected before invocation. Retry records do not affect scope
completeness and no retry occurs during continuation. The three supported read
operations delegate to the accepted storage-neutral raw scope, raw episode,
and current-history semantics with explicit analytical/history cutoffs where
applicable. The correction operations construct governed actions and delegate
episode or narrowly justified scope invalidation and atomic restatement to the
existing runtime port; no update or deletion path was added.

Historical reconnaissance inspected immutable `v0.1.0`
`operations/lib/reference-history-operation.R`,
`runtime/R/history-records.R`, and
`tests/phase5/test-operational-history.R`. Producer-once population flow,
provider-only-for-eligible evaluation, bounded failure attribution, retry
lineage, append-only invalidation/restatement, and current-read test concepts
were adapted. Repository-root discovery, generated reference source, daily
hazard semantics, started/failed lifecycle records, one giant population
transaction, separately persisted analytical families, automatic retry, raw
exception retention, and wall-clock current tie-breaking were rejected.

Package-native evidence covers accepted, ineligible, provider-declared,
detected, and protected incompatible outcomes; exact zero/one-call behavior;
zero-episode completion; full count/fingerprint completion; nonhistorical
producer failure; same-key exact repeat and population conflict; interrupted
partial visibility and continuation of only missing episodes; explicit retry
to a distinct related attempt; raw/current cutoffs; episode invalidation and
atomic restatement; narrow scope restatement; process-context restoration;
state-only mutation; close/reopen through every operation; and copied-project
execution with copied compatible state. Existing runtime provider/history and
Stage 5/6 execution suites remain regression owners for their unchanged public
primitives.

The closed repository inventory, package layout, exact export checks, package
README, human ownership map, and technical documentation now include the 7.C
owner, tests, and operations. Final validation passed repository validation,
package-native tests, source builds, controlled dependency-order installation,
isolated load, both strict `R CMD check --no-manual` operations with `Status:
OK`, installed Stage 3–7 regressions, direct R/Rd parsing, generated-artifact
review, and `git diff --check`.

**Current implementation state:** Increment 7.C is complete; Stage 7 remains
in progress. Installed RRP can create or continue one admitted-bundle durable
scope, independently commit every episode's terminal disposition, explicitly
retry failed provider attempts, inspect raw/current history, and correct
history append-only. There is still no backup/restore, migration, remote
adapter, product/materialization, application, CLI, distribution, release, or
deployment behavior.

**Next task:** implement only Increment 7.D — Backup, bounded recovery, and
complete installed proof. Do not begin Stage 7 acceptance or Stage 8.

### Increment 7.D — Backup, bounded recovery, and complete installed proof (complete, 2026-09-21)

Increment 7.D began from clean committed baseline
`290904bed36246878feb9bd9d70589fef42fd587` (`7.C complete`). It closes the
supported local project-state lifecycle without changing the accepted 7.A
logical records/port, 7.B state identity and DuckDB adapter, or 7.C durable
execution and continuation semantics. `rrpplatform` now exports exactly 20
interfaces after adding `rrp_backup_project_state()` and
`rrp_restore_project_state()`.

The backup interface takes an explicit software catalog, source project root,
and absent backup destination. It loads and validates the source project and
state, refuses an existing/invalid destination, builds in an owned sibling
staging directory, opens the source database under DuckDB's existing exclusive
writer ownership, validates it, issues `CHECKPOINT`, derives logical high-water
evidence, and copies the stable database while that source session still owns
the writer boundary. The copy is reopened read-only and the complete staged
artifact is validated before create-only atomic promotion. Interruption cleanup
removes only staging/final content owned by that attempt; source logical history
is never edited. Active writer ownership fails boundedly as `state_unavailable`
rather than waiting indefinitely or copying an active WAL.

The closed artifact contains exactly:

```text
backup.dcf
history.duckdb
```

The new cataloged `rrp.project-state-backup` 0.1.0 authority defines its exact
inventory and manifest. The manifest records backup/product identity and
version; source state and project identity; project API, state, logical-history,
target, history-record/port, adapter, physical-schema, and payload-encoding
compatibility; creation time; one high-water commit identity derived from the
state identity plus ordered record-family identities; scope, disposition, and
action counts; and the payload filename and byte size. It does not reproduce
operational scopes, episode dispositions, actions, canonical data, project
source, or project configuration. The existing metadata embedded in DuckDB
remains state authority.

The restore interface takes the same explicit software/project context and one
existing artifact. It requires the destination project's declared state path
to be wholly absent, validates exact artifact inventory and regular-file
posture, reads and validates the database's embedded state metadata against the
independently loaded destination project, verifies the closed manifest,
high-water identity/counts, payload size, schema, metadata, and database
reopenability, then copies into an owned project staging directory. It writes
`state.dcf` from the exact validated embedded metadata, revalidates the staged
normal two-file state, and atomically promotes it. Any failure—including an
injected post-promotion interruption—leaves destination state absent. Existing,
partial, linked, incompatible, or unknown destination state is never
overwritten, merged, adopted, repaired, or migrated.

The integrity boundary deliberately uses exact inventory, closed manifest,
payload size, deterministic logical high-water identity/counts, exact state
metadata/schema compatibility, and DuckDB read-only reopening. No extra digest
dependency was justified. This detects the tested missing, partial, malformed,
incompatible, size-mismatched, invalid-metadata, and unreadable/corrupt
artifacts, but is not authentication, tamper-proofing, encryption, or a claim
that every possible same-size physical corruption is detected.

Package-native evidence starts two equivalent paths from the same restored
empty state identity. The uninterrupted path reaches complete history. The
recovery path commits two initial dispositions, exposes incomplete progress,
backs up, restores into an absent compatible copied project, reopens in a fresh
process, and invokes ordinary `rrp_execute_durable_bundle()` continuation. A
sentinel proves already committed episodes are not sent to the provider again;
committed failures are not retried. Final raw scope, disposition/action,
membership, and derived completeness evidence is exactly equal to the
uninterrupted path. There is no persisted cursor or special recovery engine.

A complete-history roundtrip additionally preserves accepted, ineligible, and
failure dispositions, an explicit retry, invalidation, restatement, raw reads,
current interpretation, and derived completeness. Transaction-boundary tests
back up and restore both a before-commit append failure (candidate absent) and
an after-commit uncertain append (record present and identical retry
idempotent). Other evidence covers empty state, create-only backup/restore,
failure cleanup, source reopen after failed backup, active-writer rejection,
destination absence after every failed restore, incompatible project identity,
copied-project portability, state-only mutation, and ordinary doctor behavior.
The doctor remains inspection-only and never initializes, backs up, restores,
or repairs state.

Historical reconnaissance inspected immutable `v0.1.0`
`implementations/persistence/duckdb/R/session.R`, the related foundation/schema/
adapter files, `operations/backup-reference-history.R`,
`operations/lib/duckdb-persistence-operation.R`, and
`tests/phase5/test-duckdb-persistence.R`. Quiescent writer acquisition,
`CHECKPOINT`, non-overwriting physical copy, read-only reopen validation, and
restart proof were substantially adapted. The file-only repository operation,
repository-root path resolution, active-WAL copying, overwrite/merge, arbitrary
repair, migration/import, retention, scheduling, off-host transport, and
enterprise disaster-recovery claims were rejected.

The closed repository inventory, package layout, 25-resource catalog and
projection, exact 20-export assertions, package README/technical documentation,
human ownership map, and validator now own the backup authority, lifecycle
implementation, and recovery evidence. The independent installed proof builds
and installs both packages, projects exact installed resources, runs from an
unrelated non-Git directory, creates independent fictional projects, exercises
complete/incomplete backup and restore, continues in a fresh process, and
reopens the final history through supported operations.

Final validation passed:

- `Rscript --vanilla tools/validate-repository.R`: eight checks, zero issues;
- `Rscript --vanilla tools/validate-packages.R`: 25-resource authority and
  projection, static boundaries, controlled external dependencies, both source
  builds, negative dependency-order proof, package-native tests, isolated
  installs/loads, both strict `R CMD check --no-manual` operations with
  `Status: OK`, all inherited installed regressions, and the installed non-Git
  backup/recovery proof;
- direct changed R/Rd parsing and focused installed lifecycle tests passed;
- generated-artifact inspection and `git diff --check` passed.

**Current implementation state:** Increment 7.D is complete. RRP can
explicitly initialize, append, reopen, inspect, continue, back up, and restore
complete or incomplete supplied local project history with bounded recovery
guarantees. Exact committed hosted evidence and formal Stage 7 acceptance are
recorded below. There is no scheduled or off-host backup, retention/rotation,
encryption, access-control system, replication, point-in-time recovery, WAL
shipping, corruption repair, overwrite/merge restore, migration/import,
multi-writer service, product, application, CLI, distribution, release, or
deployment behavior.

The next lifecycle action was committed hosted verification followed by the
formal Stage 7 acceptance and architecture reconciliation recorded below.

## Stage 7 acceptance and architecture reconciliation — 2026-09-21

Stage 7 was reviewed as one realized architectural stage at exact committed
baseline `387976b15739071d8f685d316d2eb712707479ca` (`7.D complete`). The
working tree was clean and local `main` matched `origin/main`. GitHub Actions
workflow `package-foundation`, push run `35589769595`, job `106301272647`,
completed successfully for `main` at that exact SHA. The Ubuntu job used R 4.4
and passed checkout, declared DBI/DuckDB dependency installation, repository
validation, and the complete package validator.

The combined 7.A–7.D review passed every accepted Stage 7 criterion. One
successfully admitted canonical bundle at exact analytical time `t` is the
durable operational scope; one discharge episode, the singular target, and
that same `t` remain the analytical/provider/persistence unit. `rrpruntime`
owns the three closed logical record families, deterministic identities and
membership fingerprint, relationship and field-presence validation, derived
completeness, retry/correction rules, current-history interpretation, and the
storage-neutral port while remaining base-R-only. `rrpplatform` alone owns
project-state lifecycle, DBI/DuckDB, the private physical schema and payload,
durable admitted-bundle orchestration, supported history operations, and
backup/restore. The independent hospital project owns its explicit local state;
installed software, project source, and writable state remain distinct. The
accepted Stage 5/6 producer and one-episode risk operations remain
nonpersistent when called directly.

Scope evidence retains governed project/profile, producer/mapping, bundle,
target, analytical-time, expected-count, and deterministic membership evidence
without copying the canonical bundle or adding an episode manifest, persisted
cursor, lifecycle machine, or mutable completion flag. Completeness is derived
only when unique initial terminal dispositions reproduce both expected count
and fingerprint; zero-episode scope is complete when durable, partial scope is
visibly incomplete, and retry/restatement history cannot change original
membership. Each admitted episode can be accounted for as ineligible, accepted
estimate, post-admission provider incompatibility, provider-declared failure,
or detected failure. Registration-time provider incompatibility still fails
during project loading before an episode execution context exists, so it is
nonhistorical and does not contradict the accountability rule. Likewise,
project, producer, or admission failure creates no scope because operational
scope is defined only by successful admission.

Exact repeat and interruption semantics are coherent. Every invocation
reexecutes producer/admission to reproduce immutable scope evidence. A complete
match performs no episode/provider work; an incomplete match deterministically
skips committed initial dispositions—including failures—and processes only
missing identities; changed evidence under the same operation key conflicts.
Continuation fills missing initial dispositions, while explicit retry creates
one deterministic related analytical/provider attempt after a committed
eligible failure, preserves the original result, is idempotent under the same
retry key, rejects competing children, and never changes scope completeness.
There is no automatic retry.

Raw history remains append-only. Invalidation retains its target; restatement
atomically appends replacement plus action; episode correction is normal and
scope correction is limited to shared admission/provenance defects. Current
history is derived by `rrpruntime` from complete valid scopes and explicit
analytical/history cutoffs, resolves declared retry/restatement lineage, and
fails unrelated same-time ambiguity instead of using wall-clock, insertion, or
storage order. Analytical `t` remains distinct from operational timestamps;
scope creation and terminal times may equal or follow `t`, so retrospective
processing remains valid without allowing operational events to precede their
analytical state.

Physical state is exactly the project-owned two-file root `state.dcf` plus
`history.duckdb`. Initialization is explicit, staged, create-only, path/link
safe, non-destructive, and idempotent only for compatible state; partial,
unknown, corrupt, other-project, unsupported, and migration-required state fail
closed. Scope, disposition, action, and replacement-plus-action writes retain
their accepted transaction boundaries. DuckDB details, including the versioned
`r-serialize-v3-xdr-hex-v1` exact logical payload, remain private. One
controlled local writer is the supported posture.

Backup is a separate exact two-file artifact, `backup.dcf` plus checkpointed
`history.duckdb`. Its manifest is artifact authority while embedded database
metadata remains restored-state authority. Backup is quiescent, checkpointed,
staged, validated, and create-only; restore validates and stages into an absent
destination and reconstructs `state.dcf` from embedded metadata. Neither path
overwrites, merges, adopts, repairs, or migrates state. Integrity is bounded to
exact inventory, payload size, logical high-water identity/counts, metadata and
schema compatibility, and reopenability. It does not claim authentication,
tamper-proofing, encryption, or detection of every same-size corruption.

Recovery evidence proves logical-history equivalence, not byte identity,
between uninterrupted execution and partial execution followed by backup,
restore, fresh-process ordinary continuation, and completion. Committed
dispositions are not sent to providers again, committed failures are not
retried, and missing ineligible episodes require no provider call. Pre-commit
uncertainty leaves a record absent for normal continuation; post-commit
uncertainty leaves it present and recognizable by idempotent identity without a
duplicate analytical execution. Copied project/state reopening depends on
opaque project/state identity and compatibility, not repository location, Git,
original path, or working directory.

The complete installed proof built and isolated-installed both packages,
projected exact resources, and ran from an unrelated non-Git directory against
independent temporary projects through state initialization, durable execution,
incomplete inspection, backup, absent-state restore, fresh reopen,
continuation, and complete history. Persistence remains limited to accepted
governed provenance, sensitive opaque patient/episode linkage, detached
state/request/estimate evidence, bounded outcomes, and immutable actions. Raw
source data, canonical-bundle copies, terminal rows, secrets, paths, callables,
raw exceptions, model content, and unbounded diagnostics remain excluded; no
production privacy, security, audit, or disaster-recovery claim is made.

The final public inventory is justified: `rrpruntime` exports 15 interfaces
(three accepted computation primitives and 12 logical-history interfaces), and
`rrpplatform` exports 20 interfaces, with every Stage 7 addition corresponding
to supported state, durable execution, inspection, retry/correction, or backup/
restore behavior rather than test convenience. The installed catalog contains
25 resources. Its four logical-history, two state/adapter, and one backup
authorities are stable distinct contract boundaries rather than scaffolding.

Reconciliation found no scheduler, queue, worker, lease, background
continuation, automatic retry or fallback, persisted cursor, batch/vectorized
provider inference, parallel or production multi-writer orchestration,
retrospective canonical reconstruction, outside-bundle cohort selection,
scheduled/off-host backup, retention/rotation, encryption, replication,
point-in-time recovery, corruption repair, migration/import, product,
application, CLI, distribution, or deployment behavior. The architecture's
older singular "terminal run batch" wording was clarified to describe the
accepted atomic scope creation plus independently atomic episode dispositions,
truthful incomplete progress, and derived completeness. This was an authority-
wording reconciliation, not an implementation defect or a new increment.

Proportional closeout evidence passed repository validation and documentation
hygiene after these documentation-only updates; the exact committed package
implementation had already passed the hosted complete package matrix above.
No package, resource, contract, test, validator, or workflow behavior changed.

**Acceptance decision:** Stage 7 is formally accepted and complete. The exit
condition is satisfied: a hospital project can durably own one successfully
admitted zero-or-more-episode scope, account for each episode through a
governed terminal disposition, derive completeness, continue missing work
after interruption/reopen, and explicitly back up and restore complete or
incomplete local history with bounded recovery guarantees. It still has no
application-facing products.

**Next task:** detail and accept Stage 8 — Fictional Reference Path. Stage 8 may
assume installed package/resource behavior, independent projects, selected
producer to canonical admission, the singular provider/risk path,
project-owned durable history, continuation, explicit retry, append-only
correction/current interpretation, and bounded backup/restore/recovery. Do not
begin Stage 8 implementation before its separate detailed plan is accepted.

## Stage 8 detailed-plan preparation — 2026-09-21

Stage 8 was detailed as planning only from clean synchronized `main` at
`c40263646988a930014c4e97eb925b5bc495e0ba` (`Stage 7 complete`). Platform
True North, Platform Architecture, the complete implementation plan and record,
Stage 7 acceptance, implementation guidance, and agent agreement were read in
order. Reconnaissance inspected the realized project manifest/registration and
fixed trusted loader; initializer/templates; project validation; selected
producer, canonical admission, target/state/request/provider/estimate,
transparent provider, durable execution/history, installed-resource, and
extension-library boundaries; current hand-authored fictional/custom package
tests; and the Stage 5 manual/adopter evidence.

Immutable `v0.1.0` reconnaissance covered synthetic source generation,
source-local schema and validation, canonical mapping, producer/adapter and
identity configuration, deterministic test/reference scales, canonical
failure and reference tests, the historical transparent provider, the
independent-adopter producer fixture, and distribution-era local composition.
The detailed plan selectively retains deterministic fictional data, meaningful
source/canonical separation, dual-time filtering, fixture ideas, and
transparent nonclinical calculation while rejecting privileged installed
synthetic composition, repository-root execution, obsolete domains/daily
hazards, and distribution-era wiring.

The proposed Stage 8 sequence is:

1. **Increment 8.A — Supported standard project authoring boundary:** add one
   `rrpplatform`-owned standard authoring authority and adapter that turns two
   narrow project functions plus declarative identity/dependency metadata into
   the unchanged raw producer/provider registration contracts, and make that
   discoverable six-file form the normal initialized project;
2. **Increment 8.B — Fictional project, meaningful mapping, and project
   provider:** realize one installed-template-backed independent fictional
   project with explicit deterministic two-table source generation, real
   source-to-canonical translation, and a project-owned transparent provider;
   and
3. **Increment 8.C — Installed end-to-end reference proof and human runbook:**
   prove the complete normal path outside Git/source, record bounded human
   authoring observations, and leave deterministic ordinary Stage 7 history
   for later product work.

The raw project/producer/provider contracts remain the supported advanced
escape hatch and are not versioned or weakened. Normal generated
`R/register.R` becomes thin stable wiring, not the ordinary edit surface. RRP
owns invariant identities, capabilities, envelopes, bundle construction,
semantic compatibility, admission, request/result and accepted-estimate
construction; the hospital owns source meaning, canonical rows, risk
calculation, implementation/mapping/provider identity, and optional model
identity. The fictional project uses no artificial external dependency and no
installed-provider shortcut. No Stage 8 source, resource, project, package,
test, API, validator, workflow, or generated artifact was created in this
planning pass.

**Planning state:** the Stage 8 detailed plan is ready for maintainer review
and acceptance but is not yet accepted or authorized for implementation. No
increment is complete. The next lifecycle action is review and acceptance of
the detailed Stage 8 plan; only then may Increment 8.A begin.
