# RRP Installation Guide

RRP installs one verified local software distribution into an immutable,
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

Then use that same selected R to perform the one-command bootstrap, supplying
the exact repository URL recorded in `dependencies/dependencies.dcf`:

```sh
Rscript --vanilla install.R --repository https://cloud.r-project.org
```

The selected `Rscript` identifies the host R explicitly. The bootstrap verifies
the distribution again, restores the exact declared third-party closure into a
new private library, installs the exact `rrpruntime` and `rrpplatform`
artifacts, validates packages and resources in fresh vanilla R processes, writes
`INSTALLATION.dcf`, and only then promotes the completed version.

An already installed version may install another local extracted distribution
through the same engine:

```text
rrp software install PATH --repository HTTPS_URL
```

`PATH` is the extracted distribution directory. Neither path activates the new
version.

## Locations and recovery

The default per-user application-data root is:

- macOS: `~/Library/Application Support/RRP`;
- Linux and other Unix-like systems: `$XDG_DATA_HOME/rrp`, or
  `~/.local/share/rrp` when `XDG_DATA_HOME` is unset; and
- Windows: `%LOCALAPPDATA%/RRP`.

Each realization is stored beneath
`installations/<product-version>/<distribution-id>/` with its own `library/`,
resource projection, launcher, manifest, inventory, dependency specification,
and installation record. Staging is sibling state under the RRP root. The
`--installation-root ABSOLUTE_PATH` option is a controlled test/isolated-proof
override and does not change normal ownership.

A network, repository, lock, package, compilation, verification, or promotion
failure leaves no promoted partial version and does not change an existing
installation. Correct the reported condition and rerun the same command. An
exact reinstall validates and reuses the existing immutable realization; a
conflicting realization fails loudly. Do not edit an installation in place.

The restoration engine used internally is not an RRP project convention.
Initialized projects receive no `renv.lock`, `renv/`, `.Rprofile`, repository
configuration, installation record, or software-library content.
