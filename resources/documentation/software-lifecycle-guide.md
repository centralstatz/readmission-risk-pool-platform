# RRP Software Lifecycle Guide

RRP keeps software installation separate from hospital projects and from
analytical state. A distribution is acquired and verified, one immutable
version is installed, that version may later be verified and activated, and an
inactive verified owned version may be uninstalled. Project source, state,
history, and products are never inputs to software installation.

The supported acquisition and selection workflow is:

1. obtain and unpack one RRP distribution through the approved local process;
2. run its standalone verifier;
3. install it with the selected compatible R and exact configured HTTPS
   repository; and
4. inspect and strictly verify the resulting exact selector; and
5. explicitly activate it when it should become the default; and
6. remove only an exact inactive realization when it is no longer needed.

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
rrp software uninstall SELECTOR --yes
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

Upgrade is deliberate composition rather than a separate mutating command:
install the newer distribution side by side, verify its exact selector, then
activate it. Run project validation separately after selection. If a retained
project is incompatible, that project command fails without changing project
source, state, history, or products. Rollback is the same exact activation
operation applied to the retained prior verified selector; it does not reverse
or rewrite analytical history or products. Before rollback, an operator may
prove the unchanged project with one explicit compatible selection such as
`rrp --software PRIOR_SELECTOR project doctor --project PATH`; that invocation
does not change the active default. After rollback, run project validation or
doctor again under the restored active realization.

Uninstall is destructive and requires the exact selector plus confirmation.
It refuses the active realization and any unknown, linked, locked, incomplete,
damaged, or otherwise unsafe target. A verified inactive target is first moved
to owned quarantine and then removed; interruption before removal restores the
original realization or reports bounded recovery-required evidence. Other
versions, `active.dcf`, and the stable shim are preserved. Removing the final
verified installation is refused even when inactive so the shared launcher
never loses its final working version-specific transport. Install another
verified realization before removing the old one. Repeating an already
completed removal fails safely. Run installed verification and software doctor
after removal to confirm the retained active realization and shared launcher
remain ready.

Development content identities may coexist beneath their development product
version. A published product version has one official content identity: an
attempt to install materially different official content under that same
version fails rather than creating a second official build.

All software lifecycle operations are independent of project paths, current
project contents, source/state/history/products, and compatibility. Project
compatibility begins only when a project command is run under the chosen
software. Installation, verification, doctor, and activation never migrate a
project, repair dependencies, download an RRP distribution, or publish
software. Side-by-side transition/rollback and exact inactive uninstall are
supported, but automatic update, retention, project/state migration, and
release-channel behavior are not.
