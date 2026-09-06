# Maintainer release preparation

Iteration 11.6 provides the final local workflow for preparing the intended
Platform and Hospital Implementation `v0.1.0` releases. It does not publish.

```text
clean authoritative source
        ↓
prepare + validate + prove clean acquisition
        ↓
inspect build/releases/0.1.0
        ↓
READY FOR PUBLICATION
        ↓
STOP
```

## Products and versions

CentralStatz maintains one authoritative Platform repository. It produces an
independently versioned Platform source candidate and generated Hospital
Implementation candidate. Both first candidates target `0.1.0`; that shared
number does not establish future lockstep versioning.

The Hospital candidate embeds the exact Platform candidate archive. Its
manifest repeats the Platform candidate identity and SHA-256, and validation
requires both to match. A candidate is not a released version, Git commit, tag,
remote, push, or GitHub Release. `RELEASE.yml` keeps development-source,
intended-candidate, and publication status explicit.

## Prepare

From a clean committed authoritative worktree whose checkpoint validation
passes:

```sh
Rscript operations/prepare-release.R --version 0.1.0
```

The operation fails closed for dirty source, a version conflict, invalid
license/governance, failed checkpoint validation, mismatched candidates or
digests, unsafe generated state, a failed Git realization, or a failed clean-
acquisition workflow. It does not repair those conditions.

The ignored local result is under `build/releases/0.1.0/`:

- `platform/` contains the closed-inventory Platform archive, manifest, and
  checksum;
- `hospital/distribution-store/` contains the immutable Hospital distribution;
- `hospital/git-realization/` is an independent `main` repository with all
  files staged, zero commits, and zero remotes;
- `evidence/RELEASE-NOTES.md` contains the candidate release notes; and
- `RELEASE-PREPARATION.yml` plus its checksum record identities, digests,
  source revision, environment, validation, occurrence time, and explicit
  `not_published` status.

The acquisition proof extracts/copies candidates to unrelated temporary roots.
The Platform proof initializes, runs doctor, executes the synthetic workflow,
materializes products, validates the app, and builds/validates the reduced
artifact. The Hospital proof uses only generated operations to initialize, run
doctor, exercise synthetic acceptance, and substitute the fictional adopter.
Dependency restoration is distinct from artifact self-containment: the lock
ships, while first-time `renv::restore()` may need network and system packages.

## Inspect and revalidate

```sh
Rscript operations/prepare-release.R --version 0.1.0 --validate-only
Rscript operations/prepare-release.R --version 0.1.0 --show-readiness
```

`--validate-only` repeats artifact and acquisition validation. `--show-readiness`
checks the retained manifests, checksums, distribution, and Git realization
without rerunning the workflows. Both use the same maintainer operation as the
preparer; no agent-only release path exists.

## Support and governance

Apache-2.0, NOTICE, DCO contribution guidance, private vulnerability reporting,
best-effort/no-SLA support, and the narrow tested R/OS statement are release
prerequisites. See `LICENSE`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`, and
the bounded license review.

## Publication boundary

When the result says `READY FOR PUBLICATION`, stop and inspect the evidence.
Iteration 11.6 never commits, tags, configures a remote, pushes, calls GitHub,
creates a release, or publishes an artifact. Those side effects require a later
explicitly authorized Iteration 11.7 workflow.
