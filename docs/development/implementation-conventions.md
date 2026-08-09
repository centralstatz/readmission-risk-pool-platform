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

- Put reusable implementation-neutral computation in the internal runtime
  package only after its API is characterized.
- Keep orchestration, reference generation, source mapping, products, app
  rendering, deployment, Git operations, and target-specific files outside it.
- Keep source, canonical inputs, operational state, derived history, products,
  diagnostics, provenance, validation, metrics, and audit conceptually distinct.
- Do not use named implementation or deployment conditionals in generic code.

## Make AI-assisted work maintainable

AI-generated code must be directly readable, testable, and maintainable by
humans without an agent-generated explanation. Agents invoke documented tested
operations and do not invent hidden business logic or recovery procedures.

## Complete a meaningful change

A change to a contract, estimand, provider, policy, record, product, operation,
or deployment interface should update its version and compatibility statement
as applicable, success and failure tests, examples/configuration, human
documentation, and the implementation record in the same iteration.
