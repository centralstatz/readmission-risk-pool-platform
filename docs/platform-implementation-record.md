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
