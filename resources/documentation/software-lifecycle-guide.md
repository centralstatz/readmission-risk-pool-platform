# RRP Software Lifecycle Guide

RRP keeps software installation separate from hospital projects and from
analytical state. A distribution is acquired and verified, one immutable
version is installed, that version may later be verified and activated, and an
inactive owned version may eventually be uninstalled. Project source, state,
history, and products are never inputs to software installation.

Increment 11.E realizes only acquisition-from-a-local-path and installation.
The supported workflow is:

1. obtain and unpack one RRP distribution through the approved local process;
2. run its standalone verifier;
3. install it with the selected compatible R and exact configured HTTPS
   repository; and
4. retain the returned installation identity and location for later software
   verification and activation.

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

Installation never selects an active version, creates a shared launcher,
modifies `PATH`, associates software with a project, migrates a project or its
state, repairs dependencies, downloads an RRP distribution, or publishes
software. Active selection, installed verification/doctor, side-by-side
upgrade/rollback, and exact inactive uninstall are later Stage 11 increments.
