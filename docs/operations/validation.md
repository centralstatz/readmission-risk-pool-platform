# Validation operation

## Purpose

Current validation answers two different questions:

- **Development:** Is the intentionally changing repository coherent enough to
  continue development?
- **Strict checkpoint:** Does the repository also satisfy the completed Phase
  8 reduced-artifact and Connect-realization requirements?

Development success is not release, deployment, publication, product, contract,
or clinical readiness. Checkpoint success is limited to the Phase 0 engineering
foundation, Phase 1 specification foundation, Phase 2 canonical handoff, Phase
3 fictional source implementation, completed Phase 4 runtime/provider
foundation, Iteration 5.1 operational-history contracts/ports, Iteration 5.2
DuckDB reference adapter plus durable operation, Iteration 6.1 logical
products, Iteration 6.2 physical product access plus minimal app, and Iteration
7.1 stable initialize/doctor/run/materialize/launch operations plus adoption
guidance, Iteration 8.1 target-neutral artifact construction/validation, and
Iteration 8.2 Connect Cloud standalone local Git realization/validation.

## Prerequisites

- R available through `Rscript`.
- A local checkout of this repository.
- The repository's locked R environment restored with
  `Rscript -e 'renv::restore()'`. Direct external dependencies are `yaml`,
  `DBI`, `duckdb`, app-owned `shiny`, and build-only `rsconnect`; DBI/DuckDB
  belong only to their concrete adapter, Shiny to the app, and rsconnect only
  to Connect manifest generation.

Run commands from the repository root. The scripts resolve the root from their
own location, so they do not depend on a sibling repository or a
machine-specific project path.

## Commands

Validate maintained documentation only:

```sh
Rscript operations/validate-documentation.R
```

Validate the current in-progress repository:

```sh
Rscript operations/validate.R --mode development
```

Validate the completed Phase 8 checkpoint:

```sh
Rscript operations/validate.R --mode checkpoint
```

Run the focused Phase 0 tests directly:

```sh
Rscript tests/run-phase0-tests.R
```

Run the focused Phase 1 tests directly:

```sh
Rscript tests/run-phase1-tests.R
```

Run the focused Phase 2 tests directly:

```sh
Rscript tests/run-phase2-tests.R
```

Run the focused Phase 3 tests directly:

```sh
Rscript tests/run-phase3-tests.R
```

Run the focused Phase 4 tests directly:

```sh
Rscript tests/run-phase4-tests.R
```

Run the focused Phase 5 tests directly:

```sh
Rscript tests/run-phase5-tests.R
```

Run the focused Phase 6 product/materialization/app tests directly:

```sh
Rscript tests/run-phase6-tests.R
```

Run the focused Phase 7 doctor/workflow/operation-documentation tests directly:

```sh
Rscript tests/run-phase7-tests.R
```

Run the focused Phase 8 artifact and Connect-realization tests directly:

```sh
Rscript tests/run-phase8-tests.R
```

Run the reference source-to-canonical operation:

```sh
Rscript operations/generate-reference.R
```

Run admitted canonical input through eligibility, state, and request:

```sh
Rscript operations/run-reference-runtime.R --input independent
Rscript operations/run-reference-runtime.R --input synthetic --scale test
```

Run admitted input through the exactly selected reference provider and
accepted estimate:

```sh
Rscript operations/run-reference-estimation.R --input independent
Rscript operations/run-reference-estimation.R --input synthetic --scale test
```

Run the durable fictional source-to-history path (safely repeatable):

```sh
Rscript operations/run-platform.R --profile reference --scale test
```

Run the lower-level deterministic history composition for debugging:

```sh
Rscript operations/run-reference-history.R --scale test
```

Build, conform, and inspect the logical product set from that history in memory:

```sh
Rscript operations/build-reference-products.R --scale test
```

Materialize and validate application startup:

```sh
Rscript operations/build-reference-products.R --scale test --materialize
Rscript operations/launch-reference-app.R --validate-only
```

Build and independently validate the reduced application artifact:

```sh
Rscript operations/build-application-artifact.R
Rscript operations/validate-application-artifact.R
```

Generate and independently validate a standalone local Connect repository:

```sh
Rscript operations/build-connect-cloud-deployment.R --destination PATH
Rscript operations/validate-connect-cloud-deployment.R --destination PATH
```

The default generated database is ignored under `build/`. Inspection and
backup commands are documented in
[Durable Reference History](reference-history.md).

Each command exits with status `0` on success and nonzero status on failure.
Validation is read-only apart from temporary test fixtures created under the
operating system's temporary directory and removed by the test process.

## What documentation validation checks

- required governing-document presence;
- repository-local Markdown link targets;
- maintained navigation from the root README, docs index, START HERE, and
  governing documents;
- obvious machine-specific filesystem paths; and
- prohibited local-file URIs.

The validator does not request external URLs and does not attempt to render all
Markdown dialects.

## What development validation checks

Development mode composes:

- documentation validation;
- executable/configuration independence from the sibling reference repository;
- absence of sibling-targeting symlinks;
- portable paths in executable and configuration content;
- obvious secret filenames and common token/private-key patterns;
- visible fictional classification for patient-like committed fixtures; and
- specification-envelope, foundation-example, generic canonical-bundle,
  clinical domain/profile/vocabulary, fictional clinical fixture, synthetic
  implementation/source-schema/configuration, runtime/provider/estimate
  contract/package, both source-independent and synthetic reference-flow
  conformance, operational-history contract/backend-independence checks,
  concrete DuckDB adapter boundary checks, logical-product
  contract/builder/conformance/access checks, YAML materialization/integrity,
  product-only application boundary checks, target-neutral artifact
  contract/source allowlist/dependency/boundary checks, and Connect target
  contract/allowlist/dependency/Git/publication-boundary checks;
  and
- all Phase 0, Phase 1, Phase 2, Phase 3, Phase 4, Phase 5, and focused
  Phase 6, Phase 7, and Phase 8 tests.

Intentional source and documentation changes are allowed. Development mode
does not impose a clean Git worktree and does not prove a milestone is complete.

## What checkpoint validation adds

Checkpoint mode runs every development check and additionally verifies:

- required Phase 0 through Iteration 5.2 metadata, policy, operation,
  specification, package, implementation, and test files;
- presence of the approved three-domain clinical profile and the one approved
  synthetic reference implementation, with no committed generated datasets;
- a conforming reference-scale source-to-canonical run and completed Phase 3
  implementation-record entry;
- the preserved Phase 4 runtime/provider/estimate package scope and contracts,
  clean temporary installation/loading, two admitted-input flows, two
  provider-estimation flows, and Iteration 4.2 implementation-record entry;
- the exact operational-history contract/port scope, conforming DuckDB adapter,
  durable operation, and Iterations 5.1/5.2 implementation-record entries;
- the Phase 6 three-product core, backend-neutral builder, YAML adapter,
  product-only app, human operations, focused tests, and implementation record;
- the Phase 7 operation registry, initialization, read-only doctor, stable
  one-run entry point, operation classification/documentation, fresh-state and
  repeat-workflow evidence, adoption guide, and human/agent alignment;
- the Iteration 8.1 artifact contract/application declaration, exact closed
  runtime allowlist, build/validation operations, direct dependency
  declaration, isolated app proof, focused tests, and implementation record;
- the Iteration 8.2 Connect contract, exact generated inventory, source-artifact
  relationship, pruned dependency closure and target manifest, remote-free
  staged/uncommitted Git state, destination safety, isolated validation, human
  operations, and implementation record;
- an independently owned `renv` lockfile recording `yaml`, `DBI`, `duckdb`, and
  `shiny` with required transitive packages plus build-only `rsconnect`;
- the explicit non-release license status; and
- agreement between human validation commands and agent guidance.

This is strict only relative to the completed Phase 0–8 fictional
source-to-local-deployable-repository boundary. It does not prove:

- public release or license readiness;
- clinical provider validity, production persistence/materialization, or final
  application UX;
- remote Git publication, Connect service deployment, or another target;
- security or privacy certification;
- absence of all PHI or secrets; or
- clinical validity or production approval.

## Structured result

Each operation reports a scope, the checks executed, `PASS` or `FAIL`, and
actionable issues with file and line context where available. Callable
functions under `operations/lib/` produce those results; command-line scripts
only compose, print, and return process status. Console output is not an
observability, provenance, metrics, or audit system.

## Common failures and recovery

- **Broken local link:** Correct the relative target or restore the maintained
  document. Do not replace it with a machine-local path.
- **Missing navigation target:** Add the required link to the named navigation
  source after confirming the authority chain.
- **Machine-specific path or local-file URI:** Replace it with a
  repository-relative link or portable instruction.
- **Executable sibling reference:** Remove the source/import/configuration
  dependency. If old behavior is relevant, discuss it in maintained
  documentation and own any deliberately adapted asset in this repository.
- **Possible secret:** Remove and rotate a real secret as appropriate. Do not
  weaken the detector to retain sensitive material.
- **Unlabelled patient-like fixture:** Replace it with deterministic fictional
  values and add a visible fictional, synthetic, or nonclinical classification.
- **Malformed or unsupported specification:** Correct YAML syntax, restore the
  required envelope field, or select an explicitly supported format/specification
  version. Do not silently coerce an unknown contract.
- **Canonical bundle conformance:** Correct bundle/instance identity,
  requirement/status declarations, dependency references, or temporal
  availability. Expected-failure examples must retain their declared issue
  codes.
- **Canonical clinical conformance:** Correct field types, keys, source-model
  identity, controlled values, child episode references, episode/terminal
  windows, or capability/payload contradictions. Optional available domains
  may use zero records; unavailable/unsupported domains may not claim data.
- **Synthetic source conformance:** Correct implementation identity/configuration,
  source keys and relationships, local codes, temporal order, or mapping
  translation. Source-local and canonical issues belong to different stages.
- **Runtime contract/input failure:** Restore supported runtime specifications,
  pass only canonically admitted input through the representation adapter, and
  keep runtime as-of equal to the bundle cutoff.
- **Eligibility/state/request failure:** Correct interval/terminal rules,
  availability filtering, deterministic state identity, or request linkage.
  Never fabricate a risk or invoke a provider to hide ineligibility.
- **Provider declaration/selection failure:** Restore a conforming declaration,
  trusted adapter pairing, and exact registered ID/version. Never load
  executable code from ordinary configuration or select an implicit latest
  provider.
- **Provider compatibility/input failure:** Correct lifecycle, estimand/state
  version ranges, target interval, required capability, state field, or
  provider-specific input. Unsupported and missing-input results must not
  invoke the adapter.
- **Provider execution/output failure:** Preserve a structured failure with no
  estimate; correct adapter exceptions or request/state/episode identity,
  interval, cardinality, provenance, finite-value, and probability-bound
  violations before retrying.
- **DuckDB initialization/schema failure:** Preserve the file, verify adapter
  and schema metadata, and select compatible code or a validated backup. No
  destructive reinitialize or migration exists.
- **DuckDB lock/restart failure:** Stop competing writers, close sessions, and
  reopen through the adapter. One platform writer process is supported; an
  incomplete started run cannot supply a current estimate.
- **History identity conflict:** Preserve the accepted record and investigate
  differing content. Use a new run identity only for a new intentional run.
- **Logical product source/compatibility failure:** Preserve history, inspect
  the selected valid run scope and exact supported record/estimand versions,
  and do not reinterpret failure as a zero-row product.
- **Logical product conformance/coherence failure:** Correct all structured
  field/key/order/freshness/upstream/set issues before consumption. Do not
  expose a partial core set or query DuckDB directly.
- **Application artifact failure:** Preserve source products, reject unexpected
  files/symlinks or altered checksums, restore exact R/Shiny/YAML requirements,
  and rebuild the complete artifact. Do not add DuckDB/source/provider code or
  edit generated metadata to force acceptance.
- **Premature later-phase content:** Remove the scaffold unless the
  implementation plan has explicitly advanced and its record documents why.

After correction, rerun the same command. Do not use development validation to
bypass a failing checkpoint. If validation behavior changes, update this guide,
the tests, `AGENTS.md`, and the implementation record together.
