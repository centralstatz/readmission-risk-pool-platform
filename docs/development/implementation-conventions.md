# Implementation conventions

## Purpose

These conventions carry the human-readable implementation principles from
[Platform True North](../vision/platform-true-north.md) into future work. They
are deliberately concise and do not substitute for architecture or tests.

## Communicate intent

- Organize code around meaningful responsibilities and architectural stages.
- Use expressive function, object, file, operation, and test names.
- Keep inputs, outputs, side effects, extension points, and failure behavior
  discoverable.
- Comment domain, temporal, safety, compatibility, and dependency reasoning.
  Do not narrate obvious syntax.
- Give longer operations readable section boundaries when that helps a human
  follow the flow.
- Prefer small cohesive functions over compressed multipurpose pipelines.

## Choose clarity pragmatically

- Prefer native R `|>`; do not introduce `%>%`.
- Use tibbles and tidyverse tools when their vocabulary makes tabular
  transformations clearer.
- Use base R when it is simpler for system, CLI, filesystem, package,
  low-dependency, or performance-sensitive work.
- Add no dependency without a current executable need and a clear owner.
- Correctness, security, reproducibility, portability, and appropriate
  performance take precedence over stylistic conformity.
- Avoid unnecessary object systems, abstraction layers, and clever compression.

## Preserve boundaries

- Put reusable functionality behind an explicit software owner and namespace
  after its API is characterized. Entry-point scripts orchestrate owned
  functionality; they do not become its reusable implementation.
- Do not introduce reusable code that depends on `.GlobalEnv`, arbitrary
  source order, or eager repository-wide sourcing.
- Keep orchestration, reference generation, source mapping, products, app
  rendering, deployment, Git operations, and target-specific files in their
  respective owners rather than a generic runtime namespace.
- Keep source, canonical inputs, operational state, derived history, products,
  diagnostics, provenance, validation, metrics, and audit conceptually distinct.
- Do not use named implementation or deployment conditionals in generic code.

## Reuse capability, not accidental structure

Design RRP 1.0 capability against the current architecture. Prefer direct
reuse, extraction, adaptation, or relocation of proven `v0.1.0` machinery when
its semantics and ownership remain appropriate. Do not rewrite working core
capability merely for novelty or because the public software/project interface
changed.

Historical structure is not a compatibility requirement. Replace repository-
root assumptions, source-order coupling, Phase chronology, Hospital-
distribution assumptions, or Git-state adopter constraints when they conflict
with the RRP 1.0 installed-software and independent-project boundary. Existing
code is evidence, not an automatic preservation or replacement decision.

## Make context and resources explicit

- Installed behavior obtains resources through their owning component or an
  explicit resource API. Do not add upward repository-root searches or assume
  the current working directory is platform source.
- Repository-relative paths remain valid for development tools whose owner is
  this source repository.
- Project-dependent behavior receives or resolves project context through a
  supported explicit RRP mechanism. Do not infer a project from the working
  directory, arbitrary parents, source-repository identity, or Git identity.
- Keep RRP software, independent project, provider/model extension,
  deployment, and development dependency ownership distinct. The concrete
  Stage 2+ mechanisms and physical layout are intentionally not specified here.

## Test and validate by ownership

- Organize new tests by the component, contract, lifecycle, or operation whose
  invariant they protect, not by an implementation Phase number.
- Leave existing Phase-named suites in place while the ownership registry
  classifies them as current or transitional evidence.
- Use `source-changed` for ordinary local work. Broaden evidence only when the
  changed boundary or an accepted lifecycle/stage gate owns the broader claim.
  See [Validation Governance](validation-governance.md) for executable profiles.
- Proportional validation protects the correct invariants; maximum test volume
  is not rigor when it proves unrelated historical or release claims.

## Keep transitions and versions deliberate

Published `v0.1.0` artifacts and evidence are immutable. Forward software uses
forward versions; compatibility wording describes historical behavior rather
than modifying a release. Any transition shim needs an identified legacy
boundary, reason, owner, replacement/review stage, retirement condition, and a
[Transition Ledger](transition-ledger.md) entry when material.

## Make AI-assisted work maintainable

AI-generated code must be directly readable, testable, and maintainable by
humans without an agent-generated explanation. Agents invoke documented tested
operations and do not invent hidden business logic or recovery procedures.

## Complete a meaningful change

A change to a contract, estimand, provider, policy, record, product, operation,
or deployment interface should update its version and compatibility statement
as applicable, success and failure tests, examples/configuration, human
documentation, and the implementation record in the same iteration.
