# RRP Software Lifecycle Guide

RRP keeps software installation separate from hospital projects and from
analytical state. A distribution is acquired and verified, one immutable
version is installed, that version may later be verified and activated, and an
inactive owned version may eventually be uninstalled. Project source, state,
history, and products are never inputs to software installation.

The supported acquisition and selection workflow is:

1. obtain and unpack one RRP distribution through the approved local process;
2. run its standalone verifier;
3. install it with the selected compatible R and exact configured HTTPS
   repository; and
4. inspect and strictly verify the resulting exact selector; and
5. explicitly activate it when it should become the default.

The installation identity is derived from distribution, dependency, target R,
platform, architecture, and manifest integrity—not from a filesystem path or
time. The build identity remains distinct from the normalized distribution
identity and local installation realization. `INSTALLATION.dcf` records the
host R, exact private library/resource paths, dependency specification,
distribution manifest digest, and installation occurrence time.

Every version owns a private runtime package library. Ambient user and site
libraries cannot satisfy the dependency specification, and the runtime library
order is the version-private library followed only by base R. A dependency
download/cache or temporary restoration tool library is non-authoritative and
is not retained as a runtime library.

Installation provisions one stable per-user launcher but never selects an
active version or modifies `PATH`. The launcher resolves only installed
software and delegates to that realization's version-specific launcher. It
does not inspect a project or implement domain behavior.

Use exact selectors of the form
`PRODUCT_VERSION/DISTRIBUTION_ID`. A product version alone is insufficient
because more than one concrete distribution identity may exist beneath it.

```text
rrp software list
rrp software current
rrp software verify [--software SELECTOR]
rrp software doctor [--software SELECTOR]
rrp software activate SELECTOR
rrp --software SELECTOR COMMAND ...
```

`list` distinguishes strictly verified, active, and invalid candidates while
ignoring staging. `current` reports the independently validated activation
record or the expected no-selection warning. `verify` rechecks the closed
manifest/inventory and digests, dependency specification, private package
closure and integrity, installed resources, host R, and version launcher.
`doctor` returns the same bounded identity plus readiness checks, warnings,
and recovery codes; it diagnoses but does not repair or activate.

Activation first strictly verifies the exact realization, then atomically
replaces only `active.dcf`. Locking, preparation, verification, or promotion
failure preserves the prior valid record. Repeating activation of the same
realization is idempotent. `--software SELECTOR` selects one invocation without
changing `active.dcf`; an invalid explicit selector fails rather than falling
back to the active selection.

All software lifecycle operations are independent of project paths, current
project contents, source/state/history/products, and compatibility. Project
compatibility begins only when a project command is run under the chosen
software. Installation, verification, doctor, and activation never migrate a
project, repair dependencies, download an RRP distribution, or publish
software. Side-by-side transition/rollback proof and exact inactive uninstall
remain later Stage 11 work.
