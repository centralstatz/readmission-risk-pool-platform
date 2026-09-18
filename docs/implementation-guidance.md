# RRP 1.0 implementation guidance

## Purpose

This document is the human guide for constructing the clean Readmission Risk
Pool (RRP) 1.0 implementation. It explains how to turn the accepted roadmap
into understandable, owned changes. It does not define product architecture,
authorize a future stage, or claim that planned software exists.

The current repository contains governing and public documentation,
development identity, repository working guidance, one local repository-
foundation validator, two conventional internal package owners,
one closed source-resource authority with a temporary installed-projection
proof, explicit-root resource access and structured resource/project validation
operations in the main package, one local package/resource-foundation validator,
and one narrowly scoped hosted workflow with successful committed Stage 2,
Stage 3, Stage 4, and Stage 5 push evidence. Stages 1–5 are accepted and
complete; Stage 6 is detailed and accepted but remains unimplemented, and the
next task is Increment 6.A only.
The software now owns strict
project contracts, an explicit trusted loader, transactional minimal-project
initialization, a bounded project doctor, and the closed installed canonical
contract family. One supported project operation executes exactly the selected
producer once, validates its closed result, and delegates its source-independent
candidate to dependency-light runtime admission. The provider remains inert,
and there is no complete installed RRP product or ordinary operator command.

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
| `packages/rrpplatform/DESCRIPTION` and `packages/rrpplatform/NAMESPACE` | Main internal package identity, sole runtime-package dependency, and exact eight-export namespace. |
| `packages/rrpplatform/R/rrpplatform-package.R`, `packages/rrpplatform/man/rrpplatform-package.Rd`, and `packages/rrpplatform/README.md` | Main-package identity and current resource-access orientation. |
| `packages/rrpplatform/R/resource-catalog.R` | Installed DCF catalog/schema validation, explicit-root catalog opening, logical resource resolution, and typed resource failures. |
| `packages/rrpplatform/man/rrp_open_resource_catalog.Rd` and `packages/rrpplatform/man/rrp_resource_path.Rd` | Focused public API contracts for explicit-root catalog opening and resource resolution. |
| `packages/rrpplatform/R/operation-result.R` | Exact common result/diagnostic constructors and validators, safe resource-error translation, structured resource validation, and the success predicate. |
| `packages/rrpplatform/R/canonical-contracts.R` | Internal exact loading and cross-reference validation for the six installed canonical specification authorities plus assembly of their exact runtime admission context. |
| `packages/rrpplatform/R/project-contracts.R` | Internal software-authority loading plus strict 0.2.0 project-manifest and kind-specific in-memory registration-result validation. |
| `packages/rrpplatform/R/project-initializer.R` | Create-only input/destination validation, safe template rendering, owned sibling staging, load-before-promotion, final-location proof, rollback, and structured initialization results. |
| `packages/rrpplatform/R/project-loader.R` | Typed project failures, explicit project-root/filesystem validation, controlled trusted registration, library separation, installed/project composition, exact selection, and project-context construction. |
| `packages/rrpplatform/R/project-doctor.R` | Thin loader-backed structural project diagnosis, closed privacy-safe summary construction, declared-location status, absent-state warning, and expected project-error translation. |
| `packages/rrpplatform/R/producer-execution.R` | Closed request/result construction and validation, exact selected-producer invocation, process-context restoration, runtime admission delegation, and bounded expected-failure translation. |
| `packages/rrpplatform/man/rrp_initialize_project.Rd` | Focused technical API contract for transactional minimal-project initialization and its exact limits. |
| `packages/rrpplatform/man/rrp_load_project.Rd` | Focused technical API contract and honest trusted-code/immutability limits for explicit project loading. |
| `packages/rrpplatform/man/rrp_validate_project.Rd` | Focused technical API contract and limits for explicit structured project diagnosis. |
| `packages/rrpplatform/man/rrp_execute_producer.Rd` | Focused technical API contract, sensitive-value boundary, and explicit limits for selected producer execution. |
| `packages/rrpplatform/man/rrp_operation_succeeded.Rd` and `packages/rrpplatform/man/rrp_validate_software_resources.Rd` | Focused public API contracts for machine-readable success inspection and structured explicit-root resource validation. |
| `packages/rrpplatform/tests/package-foundation.R`, `packages/rrpplatform/tests/resource-access.R`, and `packages/rrpplatform/tests/operation-results.R` | Base-R package-native evidence for package identity/dependency/export posture, installed resource access, exact result/diagnostic invariants, and privacy-safe translation. |
| `packages/rrpplatform/tests/canonical-contracts.R` | Base-R exact-field, installed-loading, relationship, adversarial, and direct runtime-admission integration evidence for the canonical specification family. |
| `packages/rrpplatform/tests/project-contracts.R` | Base-R positive, adversarial, privacy, path, semantic producer, capability, duplicate, and non-invocation evidence for the internal project contracts. |
| `packages/rrpplatform/tests/project-initializer.R` | Base-R exact-inventory, rendering, create-only ownership, staging/rollback, portability, privacy, and non-invocation evidence for project initialization. |
| `packages/rrpplatform/tests/project-loader.R` | Base-R explicit-root, ordering, registration, selection, filesystem, library-isolation, portability, privacy, and non-invocation evidence for project loading. |
| `packages/rrpplatform/tests/project-doctor.R` | Base-R exact result, location-status, warning, error-translation, privacy, copy-portability, execution-boundary, and non-mutation evidence for project diagnosis. |
| `packages/rrpplatform/tests/producer-execution.R` | Base-R two-mapping, request/result, exact invocation, zero-provider, copied-project, process-restoration, canonical-admission, privacy, failure, and non-mutation evidence for producer handoff. |
| `packages/rrpruntime/DESCRIPTION` and `packages/rrpruntime/NAMESPACE` | Internal runtime-package identity, dependency posture, and exact one-export namespace. |
| `packages/rrpruntime/R/canonical-admission.R` | Pure closed-value canonical candidate validation, exact identity/capability agreement, domain/temporal rules, typed safe failures, and detached admitted-bundle construction. |
| `packages/rrpruntime/man/rrp_admit_canonical_bundle.Rd` | Focused internal API contract for the exact candidate, expected context, admitted type, and failure boundary. |
| `packages/rrpruntime/R/rrpruntime-package.R`, `packages/rrpruntime/man/rrpruntime-package.Rd`, and `packages/rrpruntime/README.md` | Runtime-package orientation and current dependency-light responsibility. |
| `packages/rrpruntime/tests/canonical-admission.R` | Base-R positive, adversarial, identity, relationship, temporal, privacy, and detached-copy evidence for canonical admission. |
| `packages/rrpruntime/tests/package-foundation.R` | Base-R package-native evidence for installed identity, version, R requirement, dependencies, and exact export posture. |
| `resources/source-catalog.dcf` | Closed maintainer authority for current software-owned resources and source-to-installed mappings. |
| `resources/resource-catalog-schema.dcf` | Exact base-R DCF schema for source and projected catalog identities, fields, controlled values, and safety invariants; also the first cataloged `contract` resource. |
| `resources/contracts/operation-result.dcf` and `resources/contracts/diagnostic.dcf` | Machine-readable exact common operation-result and privacy-safe diagnostic contracts cataloged under their stable logical IDs. |
| `resources/contracts/project-manifest.dcf` and `resources/contracts/project-registration.dcf` | Machine-readable 0.2.0 authorities for the strict project manifest and kind-specific trusted-registration result. |
| `resources/contracts/canonical/specification-envelope.dcf` and `resources/contracts/canonical/canonical-producer.dcf` | Exact installed specification envelope and platform-owned semantic producer contract. |
| `resources/contracts/canonical/canonical-bundle.dcf`, `resources/contracts/canonical/profiles/readmission.dcf`, and `resources/contracts/canonical/domains/*.dcf` | Runtime-owned canonical bundle, initial readmission profile, and discharge-episode/terminal-event semantic authorities. |
| `resources/templates/project/rrp-project.dcf` and `resources/templates/project/R/register.R` | Cataloged software-owned templates for exactly the two files in a minimal initialized 0.2.0 project, including an honest unavailable producer declaration. |
| `tools/validate-packages.R` | Human-callable, base-R proof of the local package foundation, source-resource catalog/projection and canonical contract family, runtime canonical admission, installed explicit-root resource access, common result/diagnostic behavior, project contracts, trusted loading, transactional minimal-project initialization, and installed selected-producer handoff. |
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

The `rrpruntime` package uses only base R package machinery, has no `Imports`,
`Suggests`, or `LinkingTo`, and exports exactly
`rrp_admit_canonical_bundle()`. `rrpplatform` imports only
`rrpruntime` and exports exactly `rrp_execute_producer()`,
`rrp_initialize_project()`,
`rrp_load_project()`,
`rrp_open_resource_catalog()`,
`rrp_operation_succeeded()`, `rrp_resource_path()`,
`rrp_validate_project()`, and `rrp_validate_software_resources()`. No
dependency environment exists yet. Do not introduce one by convenience,
preselect its physical layout here, or treat a future development lock as the
installed, project, provider, or deployment authority.

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
local package/resource-foundation evidence operation from the repository root:

```sh
Rscript --vanilla tools/validate-packages.R
```

It validates the exact closed DCF catalog/schema/contracts, including the
canonical specification family and relationships plus the 0.2.0 project-
manifest and registration authorities, current source resources, safe paths
and collisions, source closure, and deterministic byte-preserving
installed projection with copied adversarial fixtures. It also
proves pure runtime canonical admission with exact identities, capabilities,
closed domain shapes, key/relationship/cardinality rules, explicit-offset and
elapsed-time semantics, bounded failures, and detached input behavior. It also
proves explicit and copied project loading, transactional minimal-project
initialization, structured loader-backed diagnosis, absent/available declared
location status, controlled registration, semantic producer declaration,
exact selection, selected-callable non-invocation, context separation, typed
failures, and library/global/working-directory restoration during structural
operations. It executes two materially different fictional hospital-owned
mappings through the unchanged generic producer operation, proves exact one-
call and zero-provider behavior, validates closed request/result and admission
agreement, repeats execution after a project copy, and verifies bounded
failures plus no project/state mutation. It checks exact
package layout, metadata, dependency direction and exports, and
repository independence; builds both source packages; proves that the main
package cannot install without the runtime dependency; installs them in
dependency order into a fresh temporary library; loads each in a fresh vanilla
R process; exercises installed resource resolution plus successful and failed
common resource-validation results against explicit copied roots from an
unrelated working directory; and requires exact `Status: OK` from each
package's `R CMD check --no-manual`. Projections, fixtures, archives, libraries,
check directories, and the local empty package repository are temporary and
removed after the operation.

The package-foundation GitHub Actions workflow invokes these same two human
operations on pushes and pull requests using read-only repository permission,
Ubuntu, and R 4.4. Its external action revisions are pinned to full immutable
commit SHAs and checkout credentials are not persisted. It has no secret,
matrix, cache, dependency bootstrap, artifact, release, deployment, or mutation
behavior. A locally valid workflow is not hosted evidence: Increment 2.C and
Stage 2 closed only after committed push run `35041493406` succeeded for
revision `eb2c71aa8dd7feecb8b98848f798ec18cff0a9fa` and that result was recorded.
Stage 3 closed only after committed push run `35116049077`, job
`104861623678`, succeeded for revision
`11fc44835c0d3862196e1af5d1ef691e781c9688` and final reconciliation found no
deviation from True North or the architecture. Increment 4.A established the
two project contract authorities and internal structural validators. Increment
4.B added the explicit trusted project-loading API. Increment 4.C added the two
cataloged templates and transactional create-only initializer. Increment 4.D
added the thin structured project doctor and complete installed independent-
project proof. Stage 4 closed at revision
`f5c1fb0db47e9154b99e133a8f553bee8ea2aa16` after hosted push run
`35221028009`, job `105200921084`, succeeded and final reconciliation found no
deviation from True North or the architecture. Stage 5 — Canonical Handoff and
Producer Boundary established semantic authority and producer declaration in
5.A, pure runtime canonical admission in 5.B, and selected producer execution
with the complete local handoff proof in 5.C. Committed push run `35288890797`,
job `105427207401`, succeeded for revision
`01b0d564ecbe55830542c10cfcb77d4d72366d7b`; final reconciliation found no
deviation from True North or the architecture. Stages 1–5 are accepted and
complete. Stage 6 is detailed and accepted for implementation but no Stage 6
source exists. The next task is Increment 6.A — Singular Target Authority,
Eligibility, and Immutable Episode State; later Stage 6 increments remain
unauthorized.

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
