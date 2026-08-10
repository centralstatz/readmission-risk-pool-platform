# Repository development policies

## Purpose

These Phase 0 policies establish only the bookkeeping and development-safety
rules needed before domain contracts and runtime software exist. Phase 1 will
define compatibility and specification-version vocabulary; Phase 11 will
establish release governance.

## Licensing and release status

The repository has documented open-source intent, but no final license has been
selected and no public release is authorized. The authoritative current notice
is [License status](../../LICENSE-STATUS.md). Do not describe the repository as
an open-source release until the maintainer installs approved license terms.

## Version and change records

Keep these concepts distinct:

- **Repository revision:** A Git commit identifies repository history. It does
  not define universal platform run identity, data identity, or operational
  provenance.
- **Implementation record:** The append-oriented
  [Platform Implementation Record](../architecture/platform-implementation-record.md)
  records what a meaningful iteration actually built, reused, decided,
  validated, and changed.
- **Platform/software version:** No supported software release exists in Phase
  0, so no platform version is declared yet. Introduce one when executable
  platform identity requires it; mature release rules belong to Phase 11.
- **Contract/specification version:** A public contract owns its version only
  when its implementation phase creates that contract. Phase 0 does not assign
  versions to future canonical, estimand, provider, record, or product
  specifications.
- **Compatibility change:** Until Phase 1 defines pre-1.0 compatibility
  vocabulary, record the user-visible effect and any migration consequence in
  the implementation record. Do not infer compatibility solely from filenames
  or Git history.

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

## Fixture convention

Phase-specific tests live under `tests/<phase>/` and use names beginning with
`test-`. Shared test-only helpers live under `tests/helpers/`. Tests create
mutable or intentionally invalid fixtures in temporary directories and never
corrupt maintained repository files.

Text fixtures that appear patient-level—for example, files with fields such as
`patient_id`, `medical_record_number`, or `mrn`—must visibly contain a
`fictional`, `synthetic`, or `nonclinical` classification. Binary fixture
formats require a documented sidecar policy before they may be committed.

Phase 0 tests use base R and run with:

```sh
Rscript tests/run-phase0-tests.R
```

Later unit, conformance, integration, and end-to-end suites may use additional
structure or dependencies when their owning phase justifies them.

## Dependency state

Phase 0 uses only base R. No external package dependency exists, so `renv` is
not initialized. When executable work first introduces a justified external
dependency, establish this repository's dependency state independently; never
copy a lockfile from the sibling reference repository.
