# Generate and validate a Connect Cloud deployment repository

This guide operates the target boundary defined by the
[Connect Cloud realization](../architecture/connect-cloud-realization.md).
It ends with a complete local Git repository. It does not publish or deploy.

## Prerequisites

- restore the repository's locked R environment;
- make Git available;
- run and materialize the fictional reference workflow; and
- build a valid current reduced application artifact.

```sh
Rscript operations/run-platform.R --scale test
Rscript operations/build-reference-products.R --scale test --materialize
Rscript operations/build-application-artifact.R
Rscript operations/validate-application-artifact.R
```

The destination parent must already exist. The destination itself may be
absent. Choose a path outside the authoritative platform repository.

## Generate

Run the registered public operation with an explicit destination:

```sh
Rscript operations/build-connect-cloud-deployment.R --destination PATH
```

For example, from the platform root:

```sh
Rscript operations/build-connect-cloud-deployment.R --destination ../connect-deployment-output
```

An explicit immutable artifact and controlled timestamp may be supplied:

```sh
Rscript operations/build-connect-cloud-deployment.R --destination PATH --artifact build/reference-application-artifacts/artifact-BUILD_DIGEST --generated-at 2026-08-13T18:00:00Z
```

Relative paths are resolved from the authoritative repository root. The folder
name does not define realization or future remote identity.

The operation validates the source artifact in a standalone subprocess,
stages the complete target repository beside the destination, creates the
pruned dependency lock and Connect manifest, validates content and Shiny
startup, initializes Git on `main`, stages all generated files, validates Git
state, and then promotes. It does not commit or configure a remote.

## Validate independently

Use the registered platform wrapper:

```sh
Rscript operations/validate-connect-cloud-deployment.R --destination PATH
```

Or, from the generated repository itself, run:

```sh
Rscript validate-connect-cloud.R
```

The second command proves that validation does not need the authoritative
platform repository. Both forms are read-only apart from removed temporary
process output.

## Output and Git state

Success leaves a standalone generated repository containing the unchanged
reduced artifact, root Connect app adapter, target declaration and checksums,
`manifest.json`, its pruned generator `renv.lock`, README, and standalone
validator. All generated files are staged. There is deliberately no commit,
remote, credential, or local author configuration.

Review `CONNECT-REALIZATION.yml`, `git status`, and validation output. The next
steps are external operator responsibilities: commit using an operator-owned
identity, create/select an appropriate remote, configure and push it, authorize
Connect Cloud access, select the branch and `app.R`, and apply deployment and
sharing governance. Those commands are not platform operations.

## Regeneration, safety, and recovery

- **Same realization:** regeneration is idempotent; existing bytes and Git
  state are preserved.
- **Changed artifact/target:** replacement is allowed only when the existing
  destination validates as an untouched, uncommitted, remote-free generated
  repository. The new candidate is validated first.
- **Unrelated or modified destination:** generation fails closed. Move it,
  choose another destination, or deliberately discard it outside this
  operation after preserving anything needed.
- **Committed or published destination:** it is no longer builder-replaceable.
  Generate to another path rather than treating publication state as platform
  ownership.
- **Interrupted staging or validation failure:** no requested destination is
  created or changed; temporary staging is removed on normal error unwinding.
- **Promotion failure:** the operation attempts to restore a prior owned
  destination and reports whether recovery succeeded.
- **Corruption or dependency mismatch:** regenerate from a separately valid
  artifact after restoring the locked platform environment. Do not hand-edit
  checksums, manifests, dependency metadata, or generated app code.

The embedded products are fictional and nonclinical. Real-data deployment
requires adopter-controlled infrastructure, privacy, security, access,
networking, retention, and governance review. No Connect Cloud or future
container security/compliance claim is made.
