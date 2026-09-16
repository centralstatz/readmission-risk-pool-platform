# Working agreement for coding agents

## Read first

Before changing this repository, read:

1. `docs/platform-true-north.md`;
2. `docs/platform-architecture.md`;
3. `docs/platform-implementation-plan.md`;
4. `docs/platform-implementation-record.md`; and
5. `docs/implementation-guidance.md`.

The first four documents define why, what, planned order, and actual state.
The implementation guide is the human development method and current source-
ownership reference. This file adds no agent-only product rule or procedure.

## Work within the accepted increment

- Inspect the working tree and current record before acting. Preserve
  unrelated or user-owned changes.
- Follow the accepted increment and stop at its boundary. Do not introduce
  later-stage behavior or speculative directory scaffolding.
- Place new behavior directly under the owner required by the RRP 1.0
  architecture. Do not infer architecture from historical layout or whichever
  code already exists.
- Keep target state and current implemented capability distinct.
- Update the implementation record with actual work, decisions, validation,
  limits, and the next task.

## Reuse history without restoring it

Inspect `v0.1.0` or relevant pre-reset commits just in time after establishing
the current requirement and intended owner. Reuse or adapt only semantics that
still fit the 1.0 architecture, recover useful invariant-focused tests with
their eventual owner, and record the decision.

Never restore the historical tree wholesale, create a legacy compatibility
layer, or make this repository depend on another checkout. Historical Phase
chronology, repository-root execution, generated Hospital repositories,
temporary runtime installation, daily-hazard public semantics, and Git-state
adopter rules are not forward architecture.

## Keep work human-readable and safe

- Follow `docs/implementation-guidance.md` for implementation, dependency,
  path, privacy, and evidence conventions.
- Agents use the same documented operations and recovery paths as people. Do
  not invent hidden logic, secret procedures, or an AI-only interface.
- Never add PHI, patient-level clinical values, credentials, keys, connection
  strings, raw records, private hospital mappings, or confidential material.
- Do not commit, push, publish, deploy, or mutate an external repository or
  service unless the user explicitly authorizes it.

## Current evidence boundary

Use the same repository-foundation operation documented for people:

```sh
Rscript --vanilla tools/validate-repository.R
```

It proves only current repository structure and static policy. The behavior-
free internal packages have package-native base-R foundation tests. Use the
same local package/resource-foundation operation documented for people:

```sh
Rscript --vanilla tools/validate-packages.R
```

It proves the closed source-resource catalog, temporary deterministic installed
projection, package topology, one-way dependency, zero-export namespaces,
builds, isolated install/load, and package-native checks. No installed resource
API, dependency environment, platform operation, or release procedure exists
on the clean line. The read-only package-foundation workflow invokes these same
two commands on push and pull-request under Ubuntu/R 4.4. Committed push run
`35041493406` succeeded for revision
`eb2c71aa8dd7feecb8b98848f798ec18cff0a9fa`, completing Increment 2.C and Stage
2. Increment 3.A is complete; the next authorized source task is only Increment
3.B. Do not claim broader evidence or begin a later Stage 3 increment.
