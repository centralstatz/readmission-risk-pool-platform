# Repository development policies

## Purpose

These policies govern forward RRP 1.0 development and preserve the implemented
`v0.1.0` baseline. Current architecture and implementation-plan authority,
ownership-routed validation, and the transition ledger supersede Phase
chronology as development governance. Historical Phase documents remain
implementation/release evidence.

## Licensing and release status

Repository-authored software and documentation are licensed under Apache-2.0;
see [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE). License installation is
distinct from publication: [License and publication status](../../LICENSE-STATUS.md)
records the verified Platform and Hospital Implementation `v0.1.0` publication
and the current `0.2.0-dev` development state.

## Version and change records

Keep these concepts distinct:

- **Repository revision:** A Git commit identifies repository history. It does
  not define universal platform run identity, data identity, or operational
  provenance.
- **Implementation record:** The append-oriented
  [Platform Implementation Record](../architecture/platform-implementation-record.md)
  records what a meaningful iteration actually built, reused, decided,
  validated, and changed.
- **Platform/software version:** Platform and Hospital Implementation `v0.1.0`
  are independently versioned, immutable published releases. Current Platform
  development is `0.2.0-dev`; no next release version is prepared. Materially
  changed software moves forward under a new version and never retroactively
  repairs or reuses a published version number.
- **Contract/specification version:** Every current or future specification
  owns a SemVer meaning version distinct from the common format version. The
  [Specification Foundation](../architecture/specification-foundation.md)
  defines the envelope and pre-1.0 policy. Future domain phases own their
  specific contract versions.
- **Compatibility change:** Classify compatibility against explicit consumer
  support and the implemented specification foundation's pre-1.0 policy.
  Record semantic effect and migration consequences in the implementation
  record; never infer compatibility solely from filenames or Git history.

Pre-1.0 work may change rapidly, but changes remain deliberate, documented, and
tested. This convention is bookkeeping, not a promise of compatibility.

## Privacy, secrets, and committed examples

- Never commit PHI, real patient data, direct or indirect real patient
  identifiers, or extracts derived from clinical records.
- Never commit credentials, access keys, tokens, private keys, connection
  strings, local environment files, or private hospital configuration.
- Patient-level examples and fixtures committed to this repository must be
  deterministic and wholly fictional.
- Identify fictional or synthetic data visibly when a reader could reasonably
  mistake it for a real organization or patient record.
- A software fixture demonstrates executable behavior only. It is not evidence
  of clinical validity, calibration, safety, fairness, effectiveness, or
  production approval.
- Prefer small deterministic fictional values in tests. A later governed test
  process may add other approved data classes only through explicit policy and
  architecture changes.

Automated checks can detect some obvious secret patterns, local files, and
unlabelled patient-like fixtures. They cannot prove that content is free of PHI
or confidential material. Human review remains mandatory.

## Test and fixture convention

New RRP 1.0 tests are organized by the component, contract, lifecycle, or
operation whose invariant they protect, not by an implementation Phase number.
Names and runners should make that owner and claim discoverable. Existing
Phase-named suites remain unchanged and may carry current transitional evidence
where [`validation/ownership.yml`](../../validation/ownership.yml) says they do;
do not copy their chronology into new test organization.

Shared test-only helpers live under `tests/helpers/`. Tests create mutable or
intentionally invalid fixtures in temporary directories and never corrupt
maintained repository files.

Text fixtures that appear patient-level—for example, files with fields such as
`patient_id`, `medical_record_number`, or `mrn`—must visibly contain a
`fictional`, `synthetic`, or `nonclinical` classification. Binary fixture
formats require a documented sidecar policy before they may be committed.

Existing Phase-specific suites remain directly callable historical/component
evidence. Ordinary selection uses the profiles documented in
[Validation Governance](validation-governance.md), not this list:

```sh
Rscript tests/run-phase0-tests.R
Rscript tests/run-phase1-tests.R
Rscript tests/run-phase2-tests.R
Rscript tests/run-phase3-tests.R
Rscript tests/run-phase4-tests.R
Rscript tests/run-phase5-tests.R
Rscript tests/run-phase6-tests.R
Rscript tests/run-phase7-tests.R
Rscript tests/run-phase8-tests.R
```

Later unit, conformance, integration, and end-to-end suites may use additional
structure or dependencies when their owning component or lifecycle justifies
them.

## Dependency state

Every dependency has an explicit owner. Keep at least these lifecycles
distinct:

- installed RRP software dependencies;
- independent RRP project dependencies;
- provider/model-specific extension dependencies where applicable;
- deployment-target closure; and
- development-only dependencies.

Do not add a dependency to the shared root development environment merely
because it is convenient for future product, project, or provider behavior.
Stage 2 and later stages own the concrete mechanisms; this convention does not
prescribe their layouts or environment technology.

Phase 1 uses `yaml` to read the selected language-neutral specification format.
Iteration 5.2 adds `DBI` and `duckdb` solely for the concrete reference
persistence adapter and its operations. Iteration 6.2 adds app-owned `shiny`;
the materializer reuses `yaml`, and `rrpruntime` remains base-R-only. Iteration
8.1 declares only exact direct artifact runtime roots `shiny` and `yaml`; it
does not copy the broader project lock or a developer library. The repository
owns an independently created `renv.lock` and activation state; no
dependency file was copied from the sibling reference repository. Restore the
locked environment with:

```sh
Rscript -e 'renv::restore()'
```

Add a dependency only when current executable behavior uses it. Update the
lockfile, documentation, tests, and implementation record together.

`rrpruntime` is repository-owned source installed into a temporary library by
the supported operation, not an external dependency restored from a package
repository. It is therefore listed in `renv`'s ignored packages. Its
`DESCRIPTION` declares only base R; external runtime-package dependencies must
still be added to `renv.lock` if a later iteration justifies them.

## Transition shims

A compatibility or transition shim must identify the legacy boundary, reason,
owner, intended replacement or review stage, and testable retirement
condition. Record material shims in the
[Transition Ledger](transition-ledger.md). Shims may coexist with successors;
unowned permanent ambiguity may not. The 1.B current-boundary adapter and
legacy aggregate bridge remain active under their recorded conditions.
