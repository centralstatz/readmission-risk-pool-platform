# Maintainer release publication

This is the authoritative human procedure for publishing the independently
versioned Readmission Risk Pool Platform and generated Hospital Implementation.
It is a maintainer-only operation. It is not hospital operation, deployment, or
permission to change any unrelated repository.

```text
clean release-state commit
        ↓ prepare exact candidates
PUBLICATION PREFLIGHT: PASS
        ↓ explicit --publish only
Platform tag/push/release/verification
        ↓
generated Hospital repository/commit/tag/release/verification
        ↓
tracked publication evidence + next development state
```

## Authority and fixed targets

`RELEASE.yml` is the target authority. For `v0.1.0` it fixes:

- Platform: `centralstatz/readmission-risk-pool-platform` on `main` through
  `origin`;
- Hospital Implementation:
  `centralstatz/readmission-risk-pool-hospital-implementation`;
- exact tags `v0.1.0` for both independently versioned products; and
- Apache-2.0, CentralStatz stewardship, and unpublished candidate state.

The Hospital repository is a generated public target. CentralStatz development
continues only in the Platform repository; future Hospital releases are
regenerated from it. A recipient may modify an acquired Hospital release under
the license, but those changes do not flow back as CentralStatz source authority.

## Prepare the immutable source

Implement and validate release changes, create the signed-off release-state
commit, and from that exact clean commit run:

```sh
Rscript operations/prepare-release.R --version 0.1.0
```

Do not alter release contents between preparation and tagging. Preparation
evidence must name the exact release commit.

## Zero-mutation preflight

Run:

```sh
Rscript operations/publish-release.R --version 0.1.0 --preflight
```

Preflight performs no remote mutation. It checks the exact repository, branch,
remote and authenticated owner; Git/GitHub capability; clean source and author
identity; checkpoint/governance; exact preparation and acquisition evidence;
candidate identity/digests; tag/release absence; safe Hospital target state;
branch rules; and private-vulnerability-reporting state. Any disagreement exits
nonzero before a remote is changed.

The command must print:

```text
PUBLICATION PREFLIGHT: PASS
Remote mutation: NOT PERFORMED
```

## Explicit publication

Only an explicitly authorized maintainer runs:

```sh
Rscript operations/publish-release.R --version 0.1.0 --publish
```

The `--publish` flag is mandatory; invocation without an explicit mode cannot
mutate a remote. After repeating the full preflight, the operation visibly
prints `REMOTE MUTATION: AUTHORIZED`, enables and verifies Platform private
vulnerability reporting when needed, and proceeds Platform first.

The Platform tag targets the exact preparation revision. The operation pushes
without force, creates a non-draft/non-prerelease GitHub Release, attaches the
deterministic Platform archive and checksum, downloads that published asset,
checks its SHA-256, and runs recipient acquisition.

Only after Platform verification may the operation create the public Hospital
repository without remote initialization. It copies the exact validated
standalone realization, configures only its intended remote, makes the initial
signed-off release commit, tags and pushes `v0.1.0`, creates the Hospital GitHub
Release, then clones the public tag to an unrelated temporary directory. That
clone must pass content/distribution validation, initialize, doctor, synthetic
acceptance, the fictional-adopter substitution proof, and exact embedded-
Platform digest checks. Neither release performs deployment.

## Partial failure and recovery

Publication across two repositories is not atomic. After preflight, each
completed stage is checksummed under ignored
`build/releases/0.1.0/publication/`. Stages distinguish Platform tag/release/
verification, Hospital repository/commit/tag/release/verification, and final
completion.

If a stage fails after remote mutation:

- preserve the remote and local evidence;
- do not delete a repository, release, or tag;
- do not force-push or rewrite history;
- inspect `PUBLICATION-STATE.yml` and the reported failing stage; and
- rerun only through the same operation.

A rerun continues only when already-completed remote identities match the
retained commit, tag, release, candidate, and digest. An unrelated existing
repository, tag, release, commit, or asset is a conflict, not idempotent state.

## Verify published state

After publication, repeat remote identity verification with:

```sh
Rscript operations/publish-release.R --version 0.1.0 --verify
```

Publication is complete only when both remote tags/releases and the exact
Platform/Hospital relationship match checksummed publication evidence.

## Post-release development transition

Only after both products verify, the publication operation writes tracked
`releases/0.1.0/PUBLICATION.yml` evidence, changes development source to
`0.2.0-dev`, clears unprepared next-release targets, and adds an Unreleased
changelog section. Maintainers then update the implementation record/status,
run final development and checkpoint validation, create a separate signed-off
post-release development commit, and push `main`. The published `v0.1.0` tag is
never changed. The Hospital repository remains at its release state.

## Published v0.1.0 outcome

The authorized 2026-09-06 execution completed every recorded stage and
published:

- [Readmission Risk Pool Platform v0.1.0](https://github.com/centralstatz/readmission-risk-pool-platform/releases/tag/v0.1.0)
  at source commit `7a3cca66db2cdd6f7796918282db294bbb7eb4e8`; and
- [Readmission Risk Pool Hospital Implementation v0.1.0](https://github.com/centralstatz/readmission-risk-pool-hospital-implementation/releases/tag/v0.1.0)
  at generated commit `62d374292f51c69a6c97cf247b64ec49c05ba858`.

The Platform archive SHA-256 is
`01eb816252ac181385b5b658bdd528e35481fa7ab4176646047bbd9029a7bb27`,
and the Hospital evidence records the same embedded digest. Durable identities
and occurrence timestamps are in
[`releases/0.1.0/PUBLICATION.yml`](../../releases/0.1.0/PUBLICATION.yml).
Current development is `0.2.0-dev`; no next release is prepared.
