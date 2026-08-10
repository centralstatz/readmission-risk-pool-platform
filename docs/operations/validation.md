# Validation operation

## Purpose

Phase 0 validation answers two different questions:

- **Development:** Is the intentionally changing repository coherent enough to
  continue development?
- **Strict checkpoint:** Does the repository also satisfy the currently declared
  Phase 0 milestone requirements?

Development success is not release, deployment, publication, product, contract,
or clinical readiness. Checkpoint success is also limited to Phase 0; later
phases will add stricter component-specific claims only when those components
exist.

## Prerequisites

- R available through `Rscript`.
- A local checkout of this repository.
- No external R packages.

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

Validate the Phase 0 milestone:

```sh
Rscript operations/validate.R --mode checkpoint
```

Run the focused Phase 0 tests directly:

```sh
Rscript tests/run-phase0-tests.R
```

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
- all Phase 0 temporary-fixture tests.

Intentional source and documentation changes are allowed. Development mode
does not impose a clean Git worktree and does not prove a milestone is complete.

## What checkpoint validation adds

Checkpoint mode runs every development check and additionally verifies:

- required Phase 0 metadata, policy, operation, and test files;
- absence of later-phase architecture directories;
- absence of `renv` state while the repository has no external dependencies;
- the explicit non-release license status; and
- agreement between human validation commands and agent guidance.

This is strict only relative to the Phase 0 contract. It does not prove:

- public release or license readiness;
- canonical contract or implementation conformance;
- runtime, provider, persistence, product, or application correctness;
- deployment-artifact or publication safety;
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
- **Premature Phase 0 content:** Remove the later-phase scaffold unless the
  implementation plan has explicitly advanced and its record documents why.

After correction, rerun the same command. Do not use development validation to
bypass a failing checkpoint. If validation behavior changes, update this guide,
the tests, `AGENTS.md`, and the implementation record together.
