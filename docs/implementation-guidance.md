# RRP 1.0 implementation guidance

## Purpose

This document is the human guide for constructing the clean Readmission Risk
Pool (RRP) 1.0 implementation. It explains how to turn the accepted roadmap
into understandable, owned changes. It does not define product architecture,
authorize a future stage, or claim that planned software exists.

The current repository contains governing and public documentation,
development identity, repository working guidance, one local repository-
foundation validator, two deliberately behavior-free internal package owners,
one local package-foundation validator, and one narrowly scoped hosted workflow
whose first committed run remains pending. There is no executable RRP product
behavior or installed RRP software.

## Read authority before source

Read the governing documents in this order:

1. [Platform True North](platform-true-north.md) — why RRP exists;
2. [Platform Architecture](platform-architecture.md) — what the completed RRP
   1.0 system must be;
3. [Implementation Plan](platform-implementation-plan.md) — how the system will
   be constructed; and
4. [Implementation Record](platform-implementation-record.md) — what the clean
   line has actually constructed.

Authority flows downward. Current implementation is established by the record
and repository, not by target-state language in the architecture or by code in
Git history. If a lower document conflicts with a higher one, reconcile the
conflict before implementation continues.

## Work progressively

Work within the current accepted increment:

1. inspect the working tree and the latest implementation record;
2. identify the exact current requirement and its final architectural owner;
3. inspect relevant historical evidence only when it can inform that
   requirement;
4. implement one coherent responsibility directly under its intended owner;
5. validate the claims introduced or affected, in proportion to their risk;
6. update documentation and the implementation record with the actual result;
   and
7. stop at the increment boundary unless broader work was explicitly
   authorized.

An agent session or maintainer work session is not automatically an increment.
Resume coherent unfinished work from its trustworthy checkpoint rather than
inventing extra roadmap levels or restarting it for procedural neatness.

At stage close, validate the plain-language exit state, reconcile the realized
system with True North and the architecture, update the record, and only then
detail the next stage. Early stages may be intentionally incomplete. Do not add
compatibility machinery merely to simulate whole-platform operation.

## Reuse historical implementation deliberately

The immutable `v0.1.0` tag and later pre-reset commits are evidence and a code
reservoir, not current source or authority. Use this sequence:

```text
current requirement
        ↓
intended RRP 1.0 owner and interface
        ↓
relevant historical code, tests, or lessons
        ↓
direct reuse, adaptation, reference only, or rejection
        ↓
current owned implementation and evidence
```

Record the inspected revision/material and the actual decision. Reused or
adapted material becomes owned, documented, and validated in this repository.
It must not depend at runtime or test time on another checkout.

Do not restore old trees for convenience or preserve repository-root execution,
source-order coupling, Phase chronology, generated Hospital repositories,
daily-hazard public semantics, Git-state adopter rules, or coexistence-only
bridges as 1.0 compatibility requirements. Historical existence alone is not
a reason either to retain or rewrite an implementation.

## Current source ownership

All current files are maintained by the RRP project. Their responsibilities are
closed to the following present paths:

| Path | Current responsibility |
|---|---|
| `docs/platform-true-north.md` | Highest product-purpose and durable-principle authority. |
| `docs/platform-architecture.md` | Normative target architecture for RRP 1.0. |
| `docs/platform-implementation-plan.md` | Authoritative construction order and current accepted increment. |
| `docs/platform-implementation-record.md` | Append-forward account of clean-line work actually completed. |
| `docs/implementation-guidance.md` | Human development method, conventions, and current ownership map. |
| `RRP.yml` | Sole machine-readable product-development identity authority. |
| `README.md` | Public orientation, current maturity, and navigation. |
| `CONTRIBUTING.md` | Public contribution entry point and sign-off expectation. |
| `SECURITY.md` | Vulnerability-reporting and current security-support boundary. |
| `SUPPORT.md` | Community-support channel and current support limitations. |
| `LICENSE` and `NOTICE` | Repository license, copyright, and attribution. |
| `.editorconfig` | Basic text-format defaults. |
| `.gitignore` | Ignore rules justified by current checkout behavior. |
| `AGENTS.md` | Concise coding-agent working agreement derived from this human guide. |
| `.github/workflows/package-foundation.yml` | Read-only push/pull-request invocation of the two existing human validators on Ubuntu/R 4.4. |
| `packages/rrpplatform/DESCRIPTION` and `packages/rrpplatform/NAMESPACE` | Main internal package identity, sole runtime-package dependency, and zero-export namespace. |
| `packages/rrpplatform/R/rrpplatform-package.R`, `packages/rrpplatform/man/rrpplatform-package.Rd`, and `packages/rrpplatform/README.md` | Behavior-free main-package source and human/package documentation. |
| `packages/rrpplatform/tests/package-foundation.R` | Base-R package-native evidence for installed identity, version, R requirement, runtime import, and absent exports. |
| `packages/rrpruntime/DESCRIPTION` and `packages/rrpruntime/NAMESPACE` | Internal runtime-package identity, dependency posture, and zero-export namespace. |
| `packages/rrpruntime/R/rrpruntime-package.R`, `packages/rrpruntime/man/rrpruntime-package.Rd`, and `packages/rrpruntime/README.md` | Behavior-free package source and human/package documentation. |
| `packages/rrpruntime/tests/package-foundation.R` | Base-R package-native evidence for installed identity, version, R requirement, dependencies, and absent exports. |
| `tools/validate-packages.R` | Human-callable, base-R proof of the complete local two-package foundation. |
| `tools/validate-repository.R` | Human-callable, base-R validation of current repository-foundation claims. |

This table does not reserve future paths. Add a directory only when an accepted
increment introduces a concrete responsibility that needs it, and update this
ownership map in the same change. Do not create empty package, contract,
project, runtime, test, application, operation, artifact, deployment, or build
trees in anticipation of the roadmap.

Generated output is not authoritative source. Add an ignore rule only when a
real local artifact exists and its owning increment defines creation, recovery,
and cleanup behavior.

## Implementation conventions

- Organize work around focused architectural responsibilities.
- Use expressive file, function, object, operation, and test names. Keep
  inputs, outputs, side effects, extension points, and failure behavior visible.
- Comment domain, temporal, safety, compatibility, and architectural reasons;
  do not narrate obvious syntax.
- Prefer small cohesive functions and readable stages over compressed,
  multipurpose pipelines or speculative abstraction layers.
- In R, use native `|>`, not `%>%`. Use tidyverse tools when they clarify a
  transformation and base R when it is simpler for system, CLI, filesystem,
  package, dependency-light, or performance-sensitive work.
- Put reusable code behind an explicit owner and namespace once its
  responsibility is introduced. Do not create reusable `.GlobalEnv`, arbitrary
  source-order, or eager repository-wide sourcing dependencies.
- Repository-relative paths are acceptable for repository-owned development
  tooling only. Installed behavior will resolve resources through its owning
  interface, and project-dependent behavior will require explicit supported
  project context rather than current-directory, parent-search, source-tree,
  or Git inference.
- Organize future tests by the component, contract, lifecycle, or operation
  whose invariant they protect—not by historical Phase number.
- Keep target state, current capability, conformance, clinical validity,
  production authorization, and release status explicitly distinct.
- Optimize first for correctness, safety, reproducibility, portability, and
  human comprehension. Add performance complexity only with evidence.

AI-assisted work must be directly understandable, testable, and maintainable
without an agent-generated explanation. Agents are optional consumers of the
same guidance and operations available to people; they must not own hidden
logic or unique recovery procedures.

## Dependency ownership

Add no dependency before current executable behavior uses it and its lifecycle
owner is explicit. Keep these future dependency responsibilities distinct:

- RRP development tooling;
- installed RRP software;
- independent project extensions;
- provider/model extensions; and
- deployment-target closure.

The `rrpruntime` package currently uses only base R package machinery and has
no `Imports`, `Suggests`, or `LinkingTo`. `rrpplatform` imports only
`rrpruntime`; neither package exports a callable API. No dependency environment
exists yet. Do not introduce one by convenience, preselect its physical layout
here, or treat a future development lock as the installed, project, provider,
or deployment authority.

## Privacy and committed evidence

Never commit patient data, direct or indirect real patient identifiers,
credentials, tokens, keys, connection strings, private hospital mappings, raw
clinical records, local secret files, or confidential business material.

Future patient-like examples and fixtures must be deterministic, visibly
fictional or synthetic, and owned by an implemented capability. Such fixtures
demonstrate software behavior only; they do not establish clinical validity,
calibration, fairness, effectiveness, production approval, or regulatory
status. Automated detection can assist but cannot replace human review.

## Evidence and completion

Validation proves only the claim owned by the current change. Run the current
repository-foundation validator from the repository root:

```sh
Rscript --vanilla tools/validate-repository.R
```

It checks the owned current inventory, local documentation links, the exact
development identity and parseable metadata, legal/public metadata, basic path,
symlink, and text hygiene, and obvious generated or confidential material. It
has a human-readable result and nonzero status on failure. Automated checks
cannot prove that content is free of patient or confidential information, so
human review remains required.

Each internal package owns one base-R package-foundation test. Run the complete
local two-package evidence operation from the repository root:

```sh
Rscript --vanilla tools/validate-packages.R
```

It checks exact package layout, metadata, dependency direction, zero-export
namespaces, and repository independence; builds both source packages; proves
that the main package cannot install without the runtime dependency; installs
them in dependency order into a fresh temporary library; loads each in a fresh
vanilla R process; and requires exact `Status: OK` from each package's
`R CMD check --no-manual`. Temporary archives, libraries, check directories,
and the local empty package repository are removed after the operation.

The package-foundation GitHub Actions workflow invokes these same two human
operations on pushes and pull requests using read-only repository permission,
Ubuntu, and R 4.4. Its external action revisions are pinned to full immutable
commit SHAs and checkout credentials are not persisted. It has no secret,
matrix, cache, dependency bootstrap, artifact, release, deployment, or mutation
behavior. A locally valid workflow is not hosted evidence: Increment 2.C and
Stage 2 remain pending until a committed workflow run succeeds and its identity
and result are recorded.

There is no platform acceptance operation or installed product validation yet.
Neither local validator nor this narrow hosted workflow implies runtime,
clinical, installation, deployment, release, or final support-cell validity.

Do not invent commands or restore historical validators to make an evidence
list look complete. Hosted software verification begins no earlier than Stage
2, when executable package build/check/test behavior gives it a real claim.

For every completed increment, append the implementation record with:

- the objective and actual result;
- current material added or changed;
- historical material inspected and its reuse/adaptation/rejection decision;
- consequential decisions, surprises, or deviations;
- validation performed and inherited evidence, clearly distinguished;
- capability that remains absent; and
- the next authorized task.

Update a governing document explicitly if evidence changes it. Keep public
orientation and contribution guidance aligned with current capability. Do not
commit, push, publish, deploy, or otherwise mutate an external system unless
the current request explicitly authorizes that action.
