# Repository development policies

## Purpose

These policies establish the bookkeeping and development-safety rules needed
before domain contracts and runtime software exist. Phase 1 defines the common
specification and pre-1.0 compatibility vocabulary; Phase 11 will establish
release governance.

## Licensing and release status

Repository-authored software and documentation are licensed under Apache-2.0;
see [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE). License installation is
distinct from publication: [License and publication status](../../LICENSE-STATUS.md)
records that the `v0.1.0` candidate remains `not_published` until a separately
authorized publication workflow completes.

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
- **Contract/specification version:** Every current or future specification
  owns a SemVer meaning version distinct from the common format version. The
  [Specification Foundation](../architecture/specification-foundation.md)
  defines the envelope and pre-1.0 policy. Future domain phases own their
  specific contract versions.
- **Compatibility change:** Classify compatibility against explicit consumer
  support and the Phase 1 pre-1.0 policy. Record semantic effect and migration
  consequences in the implementation record; never infer compatibility solely
  from filenames or Git history.

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

Phase-specific tests run with:

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
structure or dependencies when their owning phase justifies them.

## Dependency state

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
