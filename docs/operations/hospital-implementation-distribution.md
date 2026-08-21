# Hospital Implementation distribution proof

## Purpose and boundary

Iteration 11.4 proves that this authoritative repository can generate a
self-contained **Readmission Risk Pool Hospital Implementation** source
distribution. The generated tree contains one exact, proof-only Platform
release-candidate archive; one active top-level `renv` project; thin operations;
an editable producer scaffold; and a clearly separate fictional adopter
example. It is generated output under ignored `build/`, not a second maintained
CentralStatz repository.

This proof does not publish a release, grant a software license, tag `v0.1.0`,
deploy an application, or authorize clinical or production use. Iteration 11.5
can separately turn only a validated artifact into a staged, uncommitted,
remote-free [standalone Git realization](hospital-git-realization.md). The
candidate version is
`readmission-risk-pool-platform@0.0.0-proof.11.4`, explicitly not Platform
`v0.1.0`.

## Build and validate

Restore the authoritative repository environment, then run:

```sh
Rscript operations/build-hospital-distribution.R
Rscript operations/validate-hospital-distribution.R
```

The build operation validates the versioned distribution contract and a
closed maintained-source allowlist, constructs a deterministic regular-file
USTAR Platform candidate, checks its internal inventory and SHA-256 identity,
copies only allowlisted Hospital source, validates the staged tree, atomically
promotes an immutable build, validates it again, and updates `CURRENT.yml` only
after success. Its default store is
`build/hospital-implementation-distributions/`.

Use explicit local paths or a repeatable proof timestamp when required:

```sh
Rscript operations/build-hospital-distribution.R --store build/my-hospital-distributions --built-at 2026-08-20T16:00:00Z
Rscript operations/validate-hospital-distribution.R --distribution build/my-hospital-distributions
```

Logical distribution identity excludes build time, output path, Git location,
runtime state, products, and publication. Build identity additionally includes
the declared build time. An identical build is idempotent; an immutable-path
content conflict fails and is preserved for inspection.

The standalone validator lives in the generated root and needs neither Git nor
the authoritative working tree:

```sh
Rscript validate-distribution.R
```

It verifies the manifest/checksum, closed file inventory, member sizes and
SHA-256 digests, absence of links and prohibited state, exact single Platform
archive, safe regular-file archive members, candidate identity/version,
compatibility, environment provenance, required wrappers/scaffold/example, and
explicit fictional/nonclinical status. Missing, extra, altered, traversing,
linked, incompatible, or drifted inputs fail closed; validation does not repair
them.

## Operate a copied distribution

Copy the promoted distribution directory to an external directory. From that
copied root, use its one top-level environment and operations:

```sh
Rscript -e 'renv::restore()'
Rscript validate-distribution.R
Rscript operations/initialize.R
Rscript operations/doctor.R
Rscript operations/run-reference-acceptance.R
Rscript operations/run-fictional-adopter-proof.R
```

Initialization validates the whole distribution and archive, safely stages
the exact declared regular files under `.rrp/platform/<candidate-digest>/`,
runs the Platform-owned doctor against staged source, and promotes only after
success. Repeating an unchanged initialization is safe. A modified managed
baseline is reported and preserved; relocate or remove that local managed
candidate deliberately before retrying.

Delegated Platform processes use `Rscript --vanilla` with the already active
top-level library. The embedded Platform `renv.lock` remains immutable
provenance; normal operation does not activate or restore a nested Platform
project. Iteration 11.4 adds no wrapper dependency, so the generated top-level
lock is byte-for-byte the exact Platform lock. A future maintained dependency
addition must be explicit and conflict-free; this proof has no general solver.
Both authoritative and generated roots ignore `build/` during implicit `renv`
dependency discovery because it contains outputs, not dependency-bearing source.

Reference acceptance uses the embedded Platform's shipped synthetic producer
and isolated `build/reference/` state. It runs doctor, runtime/provider,
DuckDB history, product build/materialization, Shiny construction, and reduced
application-artifact build/validation. It stops before target realization,
publication, or deployment.

## Implement a hospital producer

The first adopter-owned files are under `implementation/`:

- `producer.yml` declares identity, capabilities, and failure behavior;
- `platform-instance.yml` selects exactly one producer ID/version;
- `producer-configuration.yml` owns nonsecret local configuration;
- `R/producer.R` is the callable source-validation/mapping scaffold; and
- `R/composition.R` is fixed reviewed code pairing declaration and callable.

The supplied callable deliberately fails. After implementing source-local
validation and canonical mapping, validate it with:

```sh
Rscript operations/validate-producer.R
```

Only reviewed code registers executable behavior. YAML never supplies a code
path, function, package, URL, or plugin. Do not put credentials, connection
strings, private mappings, raw records, patient data, or PHI in the distributed
baseline or ordinary diagnostics.

The complete `examples/fictional-adopter/` proof is option **C** from the
architecture assessment: an empty editable baseline plus one separate,
materially different fictional example. This gives recipients a runnable trust
and composition example without implying that its denormalized source shape is
required. It reuses the Phase 10 test evidence as maintained build input; it is
not another supported reference health system.

## Recovery and remaining release work

- A failed build leaves the previous current pointer unchanged and removes its
  incomplete staging directory.
- A failed standalone validation reports stable category/issue codes. Restore
  the exact generated member; do not recalculate release checksums around an
  unexplained change.
- A failed delegated operation exits nonzero and retains only its explicitly
  selected ignored local state; no log is persisted by the wrapper.
- Reference and fictional-adopter state use different directories and are
  never inputs to one another.

The separate remote-free Git realization is now implemented for maintainer
release preparation. Remaining Phase 11 work is release hardening: final
license/dependency/asset review and license installation; contribution,
security, support, and DCO files; tested R/OS evidence; final Platform and
Hospital release candidates/manifests; clean acquisition testing; and explicit
maintainer authorization before tags, GitHub releases, or publication.
