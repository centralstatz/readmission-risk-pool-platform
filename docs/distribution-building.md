# Building an RRP software distribution

Increment 11.D supplies one maintainer operation that creates a closed,
independently verifiable RRP-owned payload. Run it from any directory and give
one explicit, nonexistent `.tar` destination:

```sh
RRP_CRAN_REPOSITORY=https://cloud.r-project.org \
  Rscript --vanilla tools/build-distribution.R /absolute/output/rrp-1.0.0-dev.tar
```

The build requires R 4.4 or later, the packages needed by the two internal RRP
packages, `renv` for normalized installed-package integrity records, and either
`sha256sum` or `shasum`. A concrete HTTPS CRAN repository must be supplied in
`RRP_CRAN_REPOSITORY` (or configured in `options("repos")`); the command does
not download dependencies or mutate an R library.

Installed-package metadata and restoration-source provenance are related but
not identical. A local canonical-CRAN source installation may carry an exact
`Repository: CRAN` annotation in each installed `DESCRIPTION`. Controlled
binary repositories can omit that annotation or use their own repository
label. The hosted workflow therefore provisions the complete closure into a
new, otherwise empty library from one explicit HTTPS repository and emits a
temporary `RRP_DEPENDENCY_PROVENANCE` receipt. The build accepts that receipt
only when its target, repository URL, closed package set, exact versions, and
integrity hashes match the tested library. A missing or mismatched annotation
without such a receipt still fails closed, and a noncanonical configured
repository always requires the receipt; a package name alone never
establishes provenance. The receipt is build-environment evidence and is not
included as another distribution contract or dependency lock.

## Inputs and dependency specification

[`distribution/source-inclusion.dcf`](../distribution/source-inclusion.dcf)
is the positive input authority. It names every package source file and direct
payload file. Package test directories are explicitly development-only. The
existing software resource catalog, rather than a second list, expands the
complete installed-resource projection. Missing declarations, undeclared
package-source additions, links, nonregular files, unsafe paths, duplicate
destinations, and case conflicts fail closed.

The build resolves the complete non-base `Depends`, `Imports`, and `LinkingTo`
closure, copies that closure into a temporary controlled library, and proves in
a fresh vanilla process that every resolved package comes from that library
rather than an ambient user or site library. It records exact package
versions, the configured repository URL, repository source type, and the
normalized `renv` package-record hash in a target-keyed DCF specification.
`renv` was selected because its records support exact versions, configured
repositories, private libraries, and deterministic failure in later restore
work. The DCF authority remains the public distribution fact; the restoration
engine is an internal implementation choice and is not a hospital-project or
CLI contract. No package archive or local mirror is bundled, and no offline
installation claim is made.

## Assembly, identity, and failure recovery

The operation stages positive package projections, builds both package source
archives without installing them, projects the exact resource catalog, writes
the dependency specification, and constructs the payload. Its standalone
verifier runs before and after deterministic tar creation and extraction. Only
then is the completed archive renamed to the requested destination.

`Distribution-ID` is SHA-256 over the payload's `identity.txt`, whose canonical
lines record normalized declared source/resource digests plus the dependency-
specification digest. The standalone verifier recomputes that identity. It excludes time,
temporary paths, usernames, checkout location, traversal order, and Git state.
The concrete inventory separately authenticates every payload file, including
package archive bytes; `Build-ID` and `Built-At` describe only that build
occurrence. R package archives can contain tool-generated timestamps, so equal
logical inputs are required to yield equal distribution identity, not equal
archive bytes.

An existing output is never replaced. Any failure reports its stage, removes
temporary staging, and leaves source, projects, installations, and the requested
destination untouched. Run the standalone verifier shown in the installed
distribution guide to diagnose an extracted payload. Maintainer adversarial
proof is available through:

```sh
Rscript --vanilla tools/validate-distribution.R
```

The separate complete installation proof performs one real configured-
repository restoration from a copied distribution, then reuses that immutable
realization for fresh-process, ambient-library, exact-reinstall, and installed
CLI equivalence evidence:

```sh
RRP_CRAN_REPOSITORY=https://cloud.r-project.org \
  Rscript --vanilla tools/validate-installation.R
```

It requires network access and may compile packages when binaries are not
available. All acquisition, restoration, installation, and failure fixtures
are temporary and outside the repository.
