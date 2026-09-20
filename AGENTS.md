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

It proves only current repository structure and static policy. The internal
packages have package-native base-R foundation tests. Use the
same local package/resource-foundation operation documented for people:

```sh
Rscript --vanilla tools/validate-packages.R
```

It proves the closed source-resource catalog, temporary deterministic installed
projection, explicit-root installed-package access, common resource-validation
result and privacy-safe diagnostic behavior, the exact canonical and five-
resource runtime specification families and relationships, strict 0.3.0 project
contracts, explicit trusted
project loading, transactional minimal-project initialization, exact semantic
producer and semantic provider selection, loader-backed structured project diagnosis, copied-
project portability, selected producer execution, closed request/result
validation, two distinct fictional hospital mappings, canonical admission
delegation, selected-provider end-to-end execution through both installed
transparent and project-owned implementations, exact one-call and no-default
behavior, package topology, one-way
dependency, dependency-light canonical admission, exact eligibility and
immutable episode-state construction, standard provider-neutral request,
direct one-call compatible-provider execution, accepted estimate, exact export posture, builds,
isolated install/load, and package-
native checks. Increment 7.A adds the cataloged storage-neutral scope,
disposition, action, and port contracts plus dependency-light record,
relationship, completeness, correction, and current-history semantics proven
through a test-only in-memory adapter. No root selector, dependency environment,
project state, durable history adapter, or release procedure exists on the clean line. The
read-only package-foundation workflow invokes these same two commands on push and pull-
request under Ubuntu/R 4.4. Committed push run
`35041493406` succeeded for revision
`eb2c71aa8dd7feecb8b98848f798ec18cff0a9fa`, completing Increment 2.C and Stage
2. Committed push run `35116049077`, job `104861623678`, succeeded for revision
`11fc44835c0d3862196e1af5d1ef691e781c9688`, completing Stage 3 after final
reconciliation. Increment 4.A added the cataloged project-manifest and
registration-result authorities plus internal structural validation. Increment
4.B added the sole explicit trusted project loader. Increment 4.C added the
cataloged minimal-project templates, create-only transactional initializer, and
sixth `rrpplatform` export. Increment 4.D added the seventh export,
`rrp_validate_project()`, and the complete local independent-project proof.
Committed push run `35221028009`, job `105200921084`, succeeded for revision
`f5c1fb0db47e9154b99e133a8f553bee8ea2aa16`, completing Stage 4 after final
reconciliation. Increment 5.A added the installed canonical contract authority,
semantic producer declarations, and the 0.2.0 project line without invoking a
component. Increment 5.B adds the first `rrpruntime` export for pure canonical
admission without invoking project code. Increment 5.C adds the eighth
`rrpplatform` export for exact selected-producer execution and the full local
canonical handoff proof. Committed push run `35288890797`, job `105427207401`,
succeeded for revision `01b0d564ecbe55830542c10cfcb77d4d72366d7b`, completing
Stage 5 after final reconciliation. Increment 6.A adds the cataloged singular
readmission-risk target and episode-state contract, exact installed authority
loading, and the second `rrpruntime` export for pure eligibility and detached
immutable episode-state construction. Increment 6.B adds the remaining three
runtime authorities, the exact 0.3.0 project line and semantic provider
declaration, and the third `rrpruntime` export for standard request, direct one-
call compatible-provider execution, and accepted estimates. Increment 6.C adds
the ninth `rrpplatform` export for generic selected-provider
execution, the explicitly selected protected transparent provider, and the
complete installed end-to-end proof. Committed push run `35444384900`, job
`105900696412`, succeeded for revision
`c9a8f539d07611d29ec86d4fd1ee5a308413938c`, completing Stage 6 after final
reconciliation. Stages 1–6 are accepted and complete. Increment 7.A is complete;
the next task is Increment 7.B. Do not introduce physical project state,
DuckDB/DBI, durable adapters, or later Stage 7 behavior without explicit
authorization.
