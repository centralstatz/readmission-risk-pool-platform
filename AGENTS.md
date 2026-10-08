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
project loading, transactional six-authoring-path standard-project
initialization plus bounded declarative branding resources,
exact standard-authoring adaptation to the raw producer/provider contracts,
transactional seven-authoring-path fictional-project initialization with the
same branding resources, explicit
byte-deterministic source generation, private identity-crosswalk mapping,
time-aware project-provider execution, and exact six-document installed
guidance,
complete installed non-Git fictional durable execution, scope/episode/current
history, private-field exclusion, same-key provider non-reexecution, and
copied-project/state reopen,
deterministic content-sensitive bundle identity, controlled authoring failures,
closed extension-package preflight, installed Markdown guidance, exact semantic
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
through a test-only in-memory adapter. Increment 7.B adds explicit project
state plus the supplied transactional DuckDB adapter. Increments 7.C and 7.D
add bundle-scoped durable execution/history interpretation and explicit
create-only checkpointed backup/absent-state restore. Increment 9.A adds the
four logical-product authorities and exact storage-neutral three-member
builder. Increment 9.B adds the materialization authority, coherent 0.2.0
state/adapter/backup line, staged immutable DCF/CSV publication, validated
detached access, contextual freshness, and product-excluding recovery.
Increment 9.C adds the Logical Products Guide and complete installed non-Git
fictional actual/empty product, reopen, staleness, copy, denial, deletion, and
history-only recovery proof. No root selector, dependency environment,
scheduled/off-host backup, migration, or release procedure exists on the clean
line. Increment 10.A adds two cataloged authorities, one installed RRP-owned
CSS asset, bounded standard `_brand.yml` interpretation, safe contained
PNG/JPEG logo detachment, one-time exact product snapshots, pure component-
ready view models, a generic Shiny/bslib + Reactable/Plotly shell, and the 29th
`rrpplatform` export for loopback-only read-only launch. Final application
experiences, initializer branding, and the installed guide remain deferred to
10.B–10.C. The
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
reconciliation. Increment 7.A established
the storage-neutral logical history foundation. Increment 7.B adds the two
platform-owned state authorities, direct DBI/DuckDB dependencies, explicit
initialize/inspect operations, compatible-state doctor, and private
transactional DuckDB adapter behind the unchanged runtime port. Increments
7.C and 7.D add durable bundle execution/history interpretation and bounded
backup/restore. Committed push run `35589769595`, job `106301272647`, succeeded
for exact revision `387976b15739071d8f685d316d2eb712707479ca`; final
reconciliation found no implementation deviation and clarified the target
architecture's atomic-history wording. Stages 1–7 are accepted and complete.
Increment 8.A establishes the cataloged standard-authoring authority, normal
six-file scaffold, producer/provider adapters, two installed product documents,
and 22-export `rrpplatform` surface while preserving direct raw projects.
Increment 8.B adds the cataloged seven-file ordinary fictional project,
explicit byte-deterministic source generator, local identity crosswalk,
meaningful two-domain mapping, project-owned private-predictor provider, third
installed product document, and 23-export `rrpplatform` surface. Increment 8.B
passed hosted run `36453663714`, job `109034402424`, for exact revision
`20091b7231d68ced55e1dda25a8f1bf0e0410a82`. Increment 8.C adds the complete
installed non-Git durable reference proof and completed human runbook. Exact
revision `87a7e2848fadbd5cd7e4a6aec11908a546d096a3` passed hosted run
`36463026242`, job `109066072183`; formal reconciliation found no architecture
deviation. Stages 1–8 are accepted and complete. Increment 9.A adds four
cataloged logical-product authorities, the 24th `rrpplatform` export, and
storage-neutral coherent construction of the detached current-risk,
actual-trajectory, and effective-scope-summary set. Increment 9.B adds the
cataloged materialization authority, the 28-export
`rrpplatform` surface, coherent state/adapter/backup versioning, and the
supplied validated DCF/CSV publication/access lifecycle. Increment 9.C adds the
Logical Products Guide and complete installed non-Git fictional actual/empty
product, reopen, staleness, copy, denial, deletion, and history-only recovery
proof. Exact revision `a13a181a09bf5b981b41030cf58e6f49225df7d4` passed hosted
run `36922905508`, job `110573063816`; formal reconciliation accepted Stage 9.
Stages 1–9 are accepted and complete. Increment 10.A established installed
application authority, detached product-only startup/view models, bounded
branding interpretation, and loopback launch. Increment 10.B adds the complete
Current Risk Pool and Overview experiences, actual-observation sparklines and
Plotly detail, exact observation and scope presentation, responsive RRP-owned
CSS, and initialized standard/fictional branding resources. Increment 10.C
adds the cataloged Supplied Application Guide and coherent installed non-Git
fictional application proof. Exact revision
`433d7eb2d90a4e237a6e5ffa00044de99534fe68` passed hosted run `37348810704`,
job `111894155548`; formal reconciliation accepted Stage 10. Stages 1–10 are
accepted and complete. The Stage 11 detailed plan is formally accepted.
Increment 11.A is locally implementation-complete with seven cataloged
lifecycle/result authorities, a 62-resource closed catalog, the 32-export
`rrpplatform` surface, read-only project lifecycle status, Stage 9 build-plus-
materialize composition, guarded installed fictional-source preparation, and
complete local package validation. Stage 11 remains incomplete; 11.B+ have not
begun.
