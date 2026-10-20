# RRP Installation Guide

RRP installs one verified local software distribution into an identity-stable,
version-private per-user location. Installation does not activate the software,
edit `PATH` or a shell profile, discover a project, or write project files.

## Prerequisites

Use the R 4.4.x installation that matches the distribution target. The host
must have network access to the exact credential-free HTTPS R package
repository recorded by the distribution, normal package compilation support
when that repository supplies source packages, and either `sha256sum` or
`shasum`. Credentials, when an organization requires them outside the URL,
remain an external repository-client concern and are never retained by RRP.

## Verify and install

Download the distribution through the approved local acquisition process,
unpack it, enter the extracted directory, and first verify its closed RRP-owned
payload:

```sh
Rscript --vanilla verify-distribution.R .
```

The current repository can build a local `1.0.0-dev` distribution for accepted
development validation. That local artifact is not a published download,
release, signature, production-support statement, or permission to bypass the
approved acquisition process. Verification establishes the manifest,
inventory, dependency specification, and exact RRP-owned payload bytes; it
does not establish publication.

Then use that same selected R to perform the one-command bootstrap, supplying
the exact repository URL recorded in `dependencies/dependencies.dcf`:

```sh
Rscript --vanilla install.R --repository https://cloud.r-project.org
```

The selected `Rscript` identifies the host R explicitly. The bootstrap verifies
the distribution again, restores the exact declared third-party closure into a
new private library, installs the exact `rrpruntime` and `rrpplatform`
artifacts, validates packages and resources in fresh vanilla R processes,
records a closed path/size/SHA-256 inventory of every regular file in the
realized private library, writes `INSTALLATION.dcf`, and only then promotes the
completed version. It also
provisions the stable per-user `rrp` shim; installation never activates the
new version.

The configured URL must exactly match the credential-free HTTPS repository in
the distribution's dependency specification. Restoration obtains the exact
declared versions and integrity into the new private library; ambient user or
site libraries cannot satisfy the closure. The installation record retains
the host-R, distribution, dependency-specification, private-library, resource,
manifest-integrity, and occurrence evidence needed by strict installed
verification. The installation record binds the private-library inventory
digest without changing the established installation identity. Repository
authentication, when required by local policy, stays outside retained RRP
evidence.

RRP preserves the conventional file and directory permissions produced by R
package installation. It does not recursively rewrite the private library as
read-only. Supported operations do not edit a promoted realization; strict
verification detects and rejects missing, additional, linked, nonregular, or
byte-changed library files. This is integrity detection, not a security claim
against the owning user, who can modify both local content and local evidence.

An already installed version may install another local extracted distribution
through the same engine:

```text
rrp software install PATH --repository HTTPS_URL
```

`PATH` is the extracted distribution directory. Neither path activates the new
version.

On macOS, Linux, and other Unix-like systems the stable command is installed
at `~/.local/bin/rrp`. On Windows it is installed beneath
`%LOCALAPPDATA%/RRP/bin`. Add that directory to `PATH` through your normal
shell or managed workstation configuration if it is not already present. RRP
does not edit `PATH`, shell profiles, or startup files. The
`--executable-root ABSOLUTE_PATH` option is reserved for controlled isolated
proof alongside `--installation-root`.

## Locations and recovery

The default per-user application-data root is:

- macOS: `~/Library/Application Support/RRP`;
- Linux and other Unix-like systems: `$XDG_DATA_HOME/rrp`, or
  `~/.local/share/rrp` when `XDG_DATA_HOME` is unset; and
- Windows: `%LOCALAPPDATA%/RRP`.

Each realization is stored beneath
`installations/<product-version>/<distribution-id>/` with its own `library/`,
resource projection, launcher, manifest, inventory, dependency specification,
private-library inventory, and installation record. Staging is sibling state
under the RRP root. The
`--installation-root ABSOLUTE_PATH` option is a controlled test/isolated-proof
override and does not change normal ownership.

After installation, use `rrp software list`, `rrp software verify`, and
`rrp software doctor`. Select the default only through the explicit
`rrp software activate SELECTOR` operation described in the Software Lifecycle
Guide.

A network, repository, lock, package, compilation, verification, or promotion
failure leaves no promoted partial version and does not change an existing
installation. Correct the reported condition and rerun the same command. An
exact reinstall validates and reuses the existing verified realization; a
conflicting realization fails loudly. Distinct development content identities
may coexist under the development product version for controlled testing, but
a published product version permits only one official distribution identity;
different official content under that same version is rejected. Do not edit an
installation in place. Use the Software Lifecycle Guide for side-by-side
activation, rollback, and exact inactive uninstall.

For diagnosis, run `rrp software verify --software SELECTOR` for strict exact
integrity and `rrp software doctor --software SELECTOR` for bounded readiness
and recovery guidance. Strict install, reinstall, verify, doctor, listing,
activation/rollback, and uninstall boundaries hash the complete private-library
inventory. Ordinary analytical command preflight instead checks structural
identity, package paths/versions, resources, and launch context; it is not a
full-byte verification on every command. Neither diagnostic command discovers,
opens, or associates a project. Project compatibility begins only with an
explicit project operation.

An installation record from the earlier `0.1.0` contract has no complete
private-library inventory and is therefore not silently treated as complete by
the `0.2.0` verifier. Install the current distribution as a distinct verified
realization and select it explicitly; do not fabricate evidence or modify an
older record in place.

The restoration engine used internally is not an RRP project convention.
Initialized projects receive no `renv.lock`, `renv/`, `.Rprofile`, repository
configuration, installation record, or software-library content.
