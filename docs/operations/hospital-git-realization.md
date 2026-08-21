# Standalone Hospital Implementation Git realization

## Purpose and authority

Iteration 11.5 gives CentralStatz maintainers a release-preparation operation
that consumes one independently validated Hospital Implementation distribution
and realizes it as a complete standalone local Git repository. It is the
Git-shaped product a hospital may eventually acquire after a separately
authorized release. It is generated output, not another maintained source
repository and not a normal hospital operation.

The operation stops at this exact boundary:

```text
validated Hospital Implementation distribution
        → standalone repository at an explicit external destination
        → Git initialized on main
        → every generated file staged
        → independent validation
        → STOP
```

There is no commit, author identity, remote, tag, push, GitHub repository,
release, publication, deployment, final license grant, or `v0.1.0` claim.

## Preconditions and source boundary

Build and validate the proof distribution separately:

```sh
Rscript operations/build-hospital-distribution.R
Rscript operations/validate-hospital-distribution.R
```

Choose a destination outside this authoritative repository whose parent
already exists. The realization operation does not build or repair the source
distribution, rebuild its Platform candidate, or copy from maintained
`distribution/hospital/` source. Its boundary is validated artifact in,
standalone repository out.

## Build and validate

Run the maintainer operations from the authoritative repository:

```sh
Rscript operations/build-hospital-git-realization.R --destination PATH
Rscript operations/validate-hospital-git-realization.R --destination PATH
```

The build operation uses the current distribution store by default. Select an
exact artifact or another store explicitly when needed:

```sh
Rscript operations/build-hospital-git-realization.R --distribution PATH --destination PATH --realized-at 2026-08-20T17:00:00Z
```

`--destination` is always required and its folder name does not participate in
logical identity. `--realized-at` is occurrence provenance, also excluded from
logical identity. The realization identity includes the realization contract
and builder versions, exact distribution instance/build/manifest, included
Platform candidate and archive digest, and every copied source checksum. No
Git commit identity is invented or required.

The repository's own validator can run from the generated destination without
this authoritative tree:

```sh
Rscript validate-git-realization.R
```

It validates the closed inventory and SHA-256 records, unchanged source
distribution, exact embedded Platform provenance, artifact-owned distribution
validation and temporary Platform doctor, absence of links/sensitive/generated
state and machine/sibling paths, and the complete Git baseline: one independent
work tree, `main`, zero commits, zero remotes, all and only generated files
staged, no unstaged/untracked/ignored changes, and no alternate/nested Git
state or local author identity.

## Destination ownership and repeat behavior

The generator owns only pristine generated realizations:

- a missing destination is staged, validated, and atomically promoted;
- the same artifact at an untouched generated destination is idempotent;
- a different validated artifact may atomically replace an untouched generated
  destination after the replacement validates;
- an unrelated directory, symbolic link, modified realization, commit, remote,
  wrong branch, unexpected Git state, or hidden ignored state is refused; and
- staging failure leaves the destination unchanged; failed promotion validation
  removes the new output or restores the prior pristine output.

Once anyone modifies, commits, or configures a remote, the destination is
outside automatic replacement. The builder never merges, repairs, resets,
deletes unknown work, or upgrades recipient changes.

## Acquisition proof and expected mutation

Before recipient customization, a temporary realization can prove the shipped
baseline using its top-level environment:

```sh
Rscript validate-git-realization.R
Rscript validate-distribution.R
Rscript operations/initialize.R
Rscript operations/doctor.R
Rscript operations/run-reference-acceptance.R
Rscript operations/run-fictional-adopter-proof.R
```

Initialization and acceptance deliberately create ignored `.rrp/` and `build/`
state. At that moment the checkout is no longer a pristine generated
realization and automatic replacement correctly stops. This does not make the
Hospital distribution invalid; it marks the transition from release-preparation
output to an operated or customized recipient repository.

## Failure and recovery

Failures are nonzero and actionable. Preserve an invalid source artifact or
destination for investigation. Correct the source by rebuilding it through its
own maintained builder; do not recalculate checksums around unexplained drift.
For a destination refusal, choose a new empty path or deliberately relocate the
recipient-owned repository. Never delete commits, remotes, or modifications to
make the generator overwrite them.

## Remaining publication boundary

The structure is suitable for a later maintainer-only release workflow, but
publication remains unauthorized. Final license/dependency/asset review,
license installation, stewardship and policy files, tested R/OS evidence,
actual Platform and Hospital release candidates, clean acquisition evidence,
checksums/manifests, naming, maintainer authorization, commit/tag/remote/push,
and GitHub Releases remain separate Phase 11 work. Platform and Hospital
Implementation versions remain independent even when their first version
numbers happen to match.
