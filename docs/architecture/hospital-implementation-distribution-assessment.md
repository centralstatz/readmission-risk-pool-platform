# Generated hospital-facing implementation distribution architecture

## Status and authority

**Status:** authoritative Iteration 11.3 architecture with the Iteration 11.4
generated build/validation proof and Iteration 11.5 standalone Git realization
implemented

**Decision date:** 2026-08-20

This document defines how CentralStatz can maintain one authoritative source
repository while releasing both the reusable Readmission Risk Pool Platform and
an independently versioned hospital-facing implementation distribution. It is
governed by [Platform True North](../vision/platform-true-north.md), the
[platform architecture](platform-architecture.md), and the
[implementation plan](platform-implementation-plan.md). Actual work remains in
the [implementation record](platform-implementation-record.md).

This revision supersedes the selected **three-level / separately maintained
hospital-kit project** interpretation recorded by Iteration 11.2. The 11.2
record remains historical evidence: its embedded exact-platform, one active R
environment, explicit producer trust, thin operations, fictional acceptance,
and deployment-neutrality conclusions remain useful. Its second maintained
CentralStatz project and formal third hospital-private layer do not.

The retained [Distribution and First-Release Assessment](distribution-release-assessment.md)
remains the Iteration 11.1 evidence behind accepted release/governance choices.
The [Canonical Producer Foundation](canonical-producer-foundation.md) remains
authoritative for the trusted adopter/source composition seam.

Iteration 11.4 implements maintained source in `distribution/hospital/`, the
versioned distribution contract, a proof-only embedded Platform candidate,
build/validation operations, safe managed extraction, and independent copied
acceptance. Generated evidence remains ignored or temporary and is removed
after validation. Iteration 11.5 now realizes only that validated artifact at
an explicit external destination as an independently valid repository on
`main` with all files staged, zero commits, and zero remotes. No public
release is claimed by those construction operations. Iteration 11.6 adds
Apache-2.0 and exact final candidates; Iteration 11.7 fixes the publication
target as `centralstatz/readmission-risk-pool-hospital-implementation` and adds
the separately authorized publication/verification workflow. See the
[Hospital Implementation distribution operation](../operations/hospital-implementation-distribution.md)
and [standalone Git realization](../operations/hospital-git-realization.md).
The general [operator manual](../operations/operator-manual.md) remains
authoritative for direct Platform operation.

## Decision summary

CentralStatz maintains exactly one authoritative source repository:

```text
readmission-risk-pool-platform
        ├── platform source, contracts, runtime, products, app, operations
        ├── reference implementations and deployment builders
        ├── maintained hospital-facing templates/wrappers/docs
        ├── hospital-distribution builder and validator source
        └── all tests and release metadata logic
```

That repository produces two independently versioned release products:

```text
authoritative maintained repository
        ├── validated Platform release
        │       e.g. RRP Platform v0.1.0
        │
        └── generated Hospital Implementation release
                e.g. RRP Hospital Implementation v0.1.0
                declares/includes one exact Platform release
```

The hospital-facing product is a **generated downstream distribution**, not a
second manually edited CentralStatz repository. Hospital-facing templates,
wrappers, documentation, builder logic, and validation source live in this
repository. A builder stages an immutable distribution artifact under ignored
`build/` state, injects one exact Platform release archive, and independently
validates the result. A later separate realization may turn only that validated
artifact into a standalone remote-free Git repository.

CentralStatz's formal release architecture ends at the generated, validated,
versioned hospital-facing release. A recipient may modify the acquired source
under the applicable license. Such changes are recipient activity, not a third
CentralStatz release layer. Validation may report that modified content differs
from the released baseline; it does not prevent modification.

## Architectural correction from Iteration 11.2

### Superseded interpretation

Iteration 11.2 modeled:

```text
Level 1 Platform
        ↓
separately maintained Level 2 Hospital Implementation Kit project
        ↓
Level 3 hospital private implementation project
```

That model correctly separated generic platform logic from adopter-facing
composition, but it over-modeled two things:

- CentralStatz does not need a second source repository to maintain wrappers,
  templates, and documentation that can be generated from this repository.
- A hospital's private customization is real use of the release, not a third
  CentralStatz product or formal release layer.

### Selected interpretation

```text
ONE maintained CentralStatz source repository
        ↓                         ↓
Platform release          generated Hospital Implementation release
                                  ↓
                          recipient acquisition/customization
                          outside CentralStatz release architecture
```

This follows the repository's established pattern: authoritative maintained
source produces independently validated downstream products. Logical product
bundles, reduced application artifacts, and Connect Git realizations already
demonstrate staging, exact inventory, provenance, independent validation, and
separation from authoritative source. The hospital distribution applies those
principles to adoption packaging without treating deployment and distribution
as the same artifact.

## Accepted Phase 11 decisions retained

This correction does not reopen the maintainer direction baselined in
Iterations 11.1 and 11.2:

| Area | Accepted direction |
|---|---|
| First Platform release | `v0.1.0`, representing the complete foundational system |
| Platform `v0.1.0` release unit | Validated whole repository source tree; future releases may later justify a narrower generated unit |
| Public authority | GitHub source repository, immutable tags, GitHub Releases, and downloadable archives |
| R dependency declaration | Platform `renv.lock` ships; `renv::restore()` is the standard declared restoration mechanism |
| Producer trust | Fixed maintained executable composition plus exact declarative selection; no executable YAML, discovery, or arbitrary loading |
| Secrets | No secrets or credentials in CentralStatz releases |
| Deployment | Connect remains a fictional/reference realization; external publication is operator-owned; future OCI is a peer target |
| Stewardship | CentralStatz Statistical & Data Sciences LLC is steward/release publisher; Alex Zajichek is initial maintainer |
| License direction | Apache-2.0 after final dependency/asset/license review; MIT fallback for a genuine unresolved incompatibility |
| Contributions | Lightweight guidance and DCO; no CLA or copyright assignment |
| Support | Best effort, no SLA or guaranteed response/resolution; optional CentralStatz services are separate |
| Security | Normal open-source security policy/private reporting; recipient owns local deployment and data security |
| Integrity | Ordinary Git/GitHub release integrity, exact inventory, and checksums; no speculative bespoke supply-chain system |
| Migration | No automatic/general migration framework before real version-transition evidence |

The exact tested R/OS matrix and final license compatibility review remain
release evidence, not reasons to change this packaging architecture.

## Terminology

### Authoritative maintained repository

Use **authoritative platform repository** for
`readmission-risk-pool-platform`. It is the only CentralStatz source repository
in this architecture. “Monorepo” is not required as product terminology; the
important property is one maintained authority.

### Platform release

**Readmission Risk Pool Platform** is the reusable source release. It remains
independently runnable and testable with the synthetic reference. The first
release is `v0.1.0`.

### Hospital-facing release

Use **Readmission Risk Pool Hospital Implementation** as the durable concept.
It communicates that the product is the normal starting point for a local
hospital implementation and contains/uses the Platform without calling itself
another platform.

Use these related terms precisely:

- **Hospital Implementation source** — maintained templates, wrappers,
  documentation, builder inputs, and validation source inside this repository;
- **Hospital Implementation distribution artifact** — immutable generated
  output built and validated under ignored local state;
- **Hospital Implementation standalone Git realization** — generated repository
  produced only from the validated artifact for later publication; and
- **Hospital Implementation release** — a published version of the validated
  generated product after explicit authorization.

“Kit” is no longer preferred because it suggests an independently maintained
starter project and does not emphasize generated release identity. “Edition”
suggests a separate product tier, “SDK” suggests a library/API, and “starter”
understates the supported end-to-end implementation surface. The canonical
generated-publication target is
`centralstatz/readmission-risk-pool-hospital-implementation`.

## Source and release ownership

### Maintained inside the authoritative repository

Maintained hospital-facing source lives under `distribution/hospital/`. This is
the selected location because the content defines a source distribution, not a
deployment target (`deploy/`) or documentation-only adoption guide
(`docs/adoption/`). The exact directory is authorized only when the builder
proof begins.

That area should own maintained inputs such as:

- hospital-facing root README/onboarding source;
- implementation and producer declaration templates;
- callable implementation scaffold;
- fixed trusted composition scaffold;
- platform-instance and nonsecret configuration templates;
- top-level operation wrapper source;
- top-level environment baseline additions, if any;
- generated-release inventory/compatibility metadata templates; and
- standalone validation source required in the downstream artifact.

Repository `operations/lib` code owns builder behavior, the artifact owns its
standalone validator runtime, and `contracts/distribution/` owns the
language-neutral hospital-distribution contract. Tests remain under the normal
repository test structure.

### Generated only

The following are outputs, never separately maintained source:

- completed Hospital Implementation distribution trees;
- copied/injected exact Platform release archives;
- completed distribution manifests and checksums;
- generated top-level lockfiles derived for a particular release;
- immutable hospital-distribution builds/current pointers;
- standalone generated Git repositories; and
- release archives or publication metadata.

Generated outputs belong under ignored `build/` state or an explicitly chosen
outside-repository destination. They are validated from their own contents and
can be regenerated from maintained source plus the declared Platform release.

### Recipient activity outside the release boundary

After acquisition, a recipient may edit, restructure, version-control, or not
version-control the distributed source as permitted by the license. It may add
local SQL, EHR/warehouse integration, mappings, configuration, documentation,
dependencies, or modifications to the bundled Platform.

Those actions are not a CentralStatz release layer. CentralStatz may document a
recommended baseline and later provide migration guidance, but the initial
architecture does not govern private repository structure, promise preservation
of arbitrary changes, or prevent modifications.

```text
validated release assumptions ≠ restrictions on recipient behavior
```

## Two release products and their relationship

### Independent versions

Platform and Hospital Implementation versions are independent semantic
identities. Equal first-release numbers may be convenient but are not an
invariant:

```text
Hospital Implementation v0.3.1 includes Platform v0.2.0
```

For the first supported line, each Hospital Implementation release should carry
exactly one Platform release version rather than a range. Exact inclusion is
clearer for provenance, offline use, environment construction, and failure
diagnosis. A future compatibility range may be introduced only after repeated
release evidence shows that one generated distribution can safely accept
multiple Platform versions.

### Conceptual release graph

```text
authoritative source revision
        ↓
validated Platform release candidate
        ↓ explicit authorization
Platform v0.1.0 tag/release/archive
        ↓ exact archive + digest
Hospital Implementation builder@version
        ↓
immutable Hospital Implementation distribution build
        ↓ independent validation
Hospital Implementation release candidate@version
        ↓ standalone Git realization
        ↓ explicit authorization
Hospital Implementation release/publication
```

The hospital-facing build cannot silently package `main`, an arbitrary working
tree, “latest,” or an unvalidated directory. A release build consumes an exact
Platform release artifact. The bounded implementation proof may use a clearly
identified test-only Platform release candidate archive because no public
release exists yet; that evidence must not be described as `v0.1.0`.

### Required Hospital Implementation metadata

A generated distribution records at least:

- its own specification identity and semantic version;
- deterministic distribution instance identity;
- build identity and declared build time, kept separate from instance identity;
- included Platform identity and exact version;
- Platform archive filename, payload identity, byte size, and SHA-256 digest;
- Platform compatibility declaration;
- hospital-distribution builder identity/version;
- complete generated file inventory and checksums;
- top-level R/environment declaration and source lock provenance;
- maintained-input provenance sufficient to reproduce the build;
- fictional/nonclinical classification of shipped examples; and
- validation status and explicit nonclaims.

These identities remain separate from Git commit, local path, operational
runtime run, producer execution, history, product-set, reduced artifact,
Connect realization, publication, and deployment identities. Git revisions may
be additional release provenance without becoming universal semantic identity.

## Embedded exact Platform release

### Accepted physical model

The generated Hospital Implementation distribution physically contains:

```text
hospital implementation distribution
├── hospital-facing scaffold, wrappers, and documentation
├── distribution identity / compatibility / inventory metadata
├── top-level environment declaration and lockfile
└── exact Platform release archive + digest metadata
```

Initialization may verify and safely extract the Platform archive into
versioned managed local state. The exact local path remains an implementation
detail. The distribution must not require a separate Platform acquisition or
network access for its normal initial workflow.

### Integrity and inspectability

The builder and validator should verify the Platform release identity,
inventory, archive size, and SHA-256 digest. Extraction should reject unsafe
paths, traversal, and symbolic links, stage before promotion, and validate the
extracted Platform before use.

The managed copy remains inspectable open-source source. Integrity validation
describes whether it still matches the released baseline; it is not a sandbox,
license restriction, or enforcement against recipient modification. A changed
copy may be reported as different from CentralStatz's validated release
assumptions without preventing the recipient from maintaining its derivative.

### No implicit retrieval

The initial official distribution embeds the archive and performs no silent
download. Any future retrieval mode must be explicit, exact-version,
operator-authorized, and checksum-verified before extraction/execution. It must
resolve into the same managed payload semantics and must never select “latest.”

## Generated artifact and standalone repository flow

Distribution artifact construction and Git realization are separate
boundaries, as application artifact construction and Connect realization are
separate today:

```text
authoritative maintained source + exact Platform release archive
        ↓ hospital-distribution builder
ignored immutable distribution build
        ↓ artifact-owned independent validator
validated Hospital Implementation distribution artifact
        ↓ Git realization builder --destination PATH
standalone remote-free generated Git repository
        ↓ repository-owned independent validator
STOP: optional commit/remote/push/publication requires authorization
```

### Distribution artifact

The first builder should stage under an ignored hospital-distribution store,
validate before promotion, retain immutable builds, and update a current pointer
only after success. Exact path and pointer names follow the implementation
proof. The artifact should:

- contain only an allowlisted generated inventory;
- include the exact Platform archive unchanged;
- contain no Platform development working-tree dependency;
- carry no generated hospital history/products/deployments;
- validate from its own files plus an externally installed R package library;
- construct its hospital-facing operation environment without sibling paths;
- detect missing, extra, modified, linked, or incompatible members; and
- remain a distribution object, not a deployment realization.

### Standalone Git realization

A later builder may consume only a valid distribution artifact and create a
standalone Git repository at an explicit outside-repository destination. It
should follow the mature safe concepts used by the Connect realization:

- complete generated ownership and exact inventory;
- independently valid copied content;
- default branch initialized deliberately;
- generated files staged but uncommitted;
- no remote, credentials, author identity, push, or publication;
- idempotent regeneration only for unchanged owned output;
- refusal to overwrite unrelated, committed, remote-configured, or modified
  destinations; and
- validation that requires no authoritative source repository.

That generated repository is a release realization, not a second CentralStatz
source project. Maintained changes always originate here and are regenerated.

## R environment ownership

### One active hospital-facing project

The 11.2 conclusion remains sound under the generated model: the generated
Hospital Implementation root owns one active `renv` project and one
authoritative baseline lockfile for CentralStatz's released configuration.

The intended operator experience is:

```text
Hospital Implementation root
        ↓ Rscript -e 'renv::restore()'
one active project library
        ↓ top-level wrappers
managed Platform code
```

The embedded Platform archive retains the Platform's own lockfile unchanged for
release provenance and independent Platform use. Routine hospital-facing
operations do not activate or restore a nested Platform project.

### Generated baseline lock

For a Hospital Implementation release, the builder deterministically starts
from the exact included Platform release lock and adds only dependencies used
by maintained hospital-facing wrapper/scaffold behavior. The initial design
should keep those additions at zero or minimal. It must reject incompatible
version requirements rather than silently upgrade/downgrade Platform packages.

The generated manifest records the Platform lock digest, maintained dependency
additions, resulting top-level lock digest, declared R line, and validation
environment. Independent release validation restores or checks the top-level
lock in each environment that CentralStatz claims as tested and runs the
fictional baseline.

This is deterministic release construction, not a general dependency solver.
The implementation may use explicit, bounded lock transformation and exact
checks for the maintained dependency set. It must not attempt to solve arbitrary
recipient dependency conflicts.

### Recipient-added dependencies

After acquisition, a hospital may add producer or local dependencies and update
its lockfile. Those additions are outside the exact CentralStatz release
environment guarantee. The documentation may recommend deliberate `renv`
snapshot/restore and conformance testing, but the release architecture does not
promise that arbitrary packages coexist or preserve the baseline lock.

## Producer trust and composition

### Shipped supported pattern

The generated Hospital Implementation provides maintained templates for:

- a producer declaration;
- callable extraction/source-validation/mapping/adapter implementation;
- fixed trusted composition code;
- one exact platform-instance selection document;
- nonsecret producer configuration; and
- a producer conformance operation.

The template establishes a clear editable location, but no real hospital code,
source names, mappings, configuration, credentials, or connection information
is present in the CentralStatz release.

### Explicit trust flow

```text
fixed maintained composition scaffold
        ├── sources an explicit reviewed implementation file list
        ├── reads one declarative producer specification
        ├── constructs one callable
        └── registers the declaration/callable in code
                                  ↓
platform-instance YAML selects exact producer ID@version
                                  ↓
Platform validates registration + selection + producer result
                                  ↓
canonical admission
                                  ↓
unchanged runtime → history → products → app/artifact
```

YAML does not name functions, executable file paths, packages, expressions, or
URLs. There is no directory scan, plugin discovery, remote loading, or
multi-hospital switching. A recipient changes trusted composition by editing
reviewable executable source, not by turning data configuration into code.

### Generated baseline validation

CentralStatz can validate the release without a real hospital producer:

- isolated reference acceptance uses the embedded Platform's unchanged shipped
  synthetic producer and separate fictional generated state;
- a shipped fictional adopter example or conformance fixture proves that the
  generated composition scaffold can register and run a materially different
  producer; and
- the empty/local producer template is validated structurally and remains
  blocked for normal adopter execution until a recipient supplies and selects
  conforming code.

Reference acceptance and adopter selection are distinct operation intents, not
two active hospital contexts in one installation. Generic Platform code remains
unaware of hospital names and source layout.

## Hospital-facing operation surface

The generated distribution exposes a small top-level script surface for these
intents:

- initialize the distribution and managed Platform;
- run hospital-facing doctor/preflight;
- run isolated fictional reference acceptance;
- validate the configured producer;
- run one Platform cycle;
- inspect operational history;
- materialize products;
- validate or launch the product-only application;
- build or validate the reduced application artifact; and
- build or validate an available deployment realization.

Exact filenames remain for the implementation proof. The wrappers hide
unnecessary managed Platform paths from routine adopters while keeping all
source inspectable.

Wrappers delegate to callable Platform operation behavior and provide only
distribution-root discovery, managed Platform validation, explicit
composition, top-level state paths, and hospital-facing recovery wording. They
do not copy canonical, runtime, provider, persistence, product, application,
artifact, or target logic. The existing operation registry may inform a checked
mapping but does not become a reflective CLI framework.

The smallest necessary upstream change remains a callable operation-composition
seam that accepts an already constructed trusted registry/selection and
explicit state paths. It must not accept a path/function supplied by
configuration. Existing Platform scripts should call the same functions with
the shipped reference composition.

Exit codes, structured results, and privacy-safe diagnostic lifecycle propagate
through wrappers. Operation-run identity remains distinct from analytical
runtime-run identity. No wrapper may retain diagnostics by default or turn them
into audit/history.

## Hospital-facing acquisition and baseline workflow

The validated CentralStatz release baseline is:

1. obtain one Hospital Implementation release;
2. verify its documented release integrity;
3. restore the top-level declared R environment;
4. initialize and validate/extract the embedded exact Platform release;
5. run hospital-facing doctor;
6. run isolated fictional reference acceptance;
7. inspect the maintained producer/composition scaffold;
8. validate the shipped fictional adopter conformance example;
9. demonstrate the unchanged history/products/app path;
10. build and validate the target-neutral reduced application artifact; and
11. optionally exercise a supported reference target realization, stopping
    before external publication.

After that baseline, the recipient may implement local source mapping and
composition using the documented pattern. CentralStatz validates the shipped
baseline and interfaces, not an unknown recipient's future data, code,
dependencies, clinical validity, security approval, or production operation.

The hospital does not normally acquire Platform separately, coordinate sibling
repositories, understand submodules, wire local paths, edit inside the managed
Platform tree, or keep a Platform fork merely to start local source work.

## Synthetic reference acceptance

The synthetic reference remains authored and maintained only once in the
Platform source. The Hospital Implementation release exposes it through a
top-level acceptance wrapper that:

- verifies the embedded Platform payload;
- invokes the Platform's unchanged shipped composition and operations;
- uses isolated fictional/nonclinical state;
- reports Hospital Implementation and included Platform identities;
- reaches products/application and the reduced artifact for release evidence;
- propagates Platform exit status and safe diagnostics; and
- stops before external publication.

The wrapper does not copy the generator or mapping and does not make synthetic
identity a generic runtime mode. Acceptance proves the released environment and
composition baseline, not real-data integration or clinical/production fitness.

## Deployment neutrality

Hospital distribution remains upstream of deployment:

```text
generated Hospital Implementation release
        ↓ explicit producer composition
canonical admission → runtime → history → products
        ↓
target-neutral reduced application artifact
        ├── Connect reference realization
        └── future OCI/container peer realization
```

The hospital-facing builder packages Platform source and wrappers; it does not
alter the reduced artifact. Hospital-facing operations delegate to the same
artifact builder/validator. Connect concepts do not enter producer composition,
environment ownership, or distribution identity. CentralStatz release
publication is separately maintainer-controlled; recipient deployment remains
operator-owned.

## CentralStatz release validation and responsibility boundary

### CentralStatz validates

Before a Hospital Implementation release candidate is authorized, evidence
must establish:

- generation from maintained source in this repository;
- exact Hospital Implementation identity/version and generated inventory;
- exact included Platform release identity/version/archive/digest;
- compatible Platform and Hospital Implementation declarations;
- no unexpected or linked files and safe archive paths;
- no PHI, real patient data, credentials, connection strings, hospital-specific
  mappings, private source configuration/code, real operational history,
  products, deployment state, or repositories/remotes;
- coherent top-level baseline lock and claimed tested environments;
- independent validation without the authoritative working tree;
- isolated synthetic reference acceptance;
- fictional adopter producer conformance through explicit trusted composition;
- unchanged history/products/app/reduced-artifact behavior;
- exact failure on tamper, missing content, incompatibility, or unsafe paths;
  and
- complete human acquisition, operation, limitation, and recovery guidance.

### CentralStatz responsibility ends

The release boundary ends at the distributed validated product and its factual
documentation. CentralStatz does not validate or promise:

- recipient modifications after acquisition;
- arbitrary added packages or dependency combinations;
- local extraction queries, mappings, data, credentials, infrastructure, or
  deployments;
- private Git/repository organization;
- automatic reconciliation with later releases;
- clinical validity, security approval, compliance, production readiness, or
  support beyond the stated best-effort policy; or
- preservation of a recipient's arbitrary changes during future upgrades.

Documentation can give good-practice guidance, but those responsibilities do
not become CentralStatz packaging architecture.

## Security and privacy scope

The distribution builder/validator owns release-content exclusions only. Both
CentralStatz release products contain no PHI, real patient records, credentials,
connection strings, hospital-specific mappings, private source configuration,
hospital source code, operational history, real products, or hospital
deployment state.

Archive and inventory checks provide exact release provenance and corruption
detection. They are not code signing, malware analysis, access control, a
sandbox, or enforcement against a recipient. After acquisition, data handling,
secrets, infrastructure, access, backups, monitoring, incident response, and
deployment security are recipient-owned.

No encryption system, secret store, enterprise identity, signing service,
SBOM, attestation system, or security operations platform is required by this
architecture.

## Release evolution and recipient-local migration

### CentralStatz release evolution

CentralStatz updates maintained hospital-facing source in this repository and
generates a new Hospital Implementation release. A new release may change:

- wrappers or documentation;
- templates/composition scaffold;
- generated distribution contract/inventory;
- top-level baseline environment;
- included exact Platform release; and
- compatibility declarations.

Those changes receive their own Hospital Implementation version. They do not
require matching the Platform version.

### Recipient-local migration

A recipient who customized an older distribution decides how to adopt a later
release. For the first release, CentralStatz does not promise an updater,
automatic merge, or preservation of arbitrary recipient changes. Release notes
should state compatibility impact and may provide manual guidance.

> Future versions may provide migration guidance, but recipients who modify
> distributed files are responsible for reconciling those local changes.

Formal migration tooling remains deferred until a real version transition and
adopter evidence establish the required semantics. Operational history remains
governed by its own compatibility and backup rules; this distribution decision
does not authorize silent history migration or deletion.

## Alternatives and consequences

### Selected — one repository, generated Hospital Implementation release

This is the best fit because it preserves one authoritative source, one copy of
Platform logic, independently versioned release products, offline acquisition,
explicit trust, and independent validation. It adds a bounded distribution
builder/validator but no synchronization between source repositories.

### Rejected — separately maintained CentralStatz kit repository

It could work technically, but creates a second source authority, release-input
synchronization, duplicate wrapper/documentation maintenance, and avoidable Git
coordination. A generated standalone repository can provide the same acquisition
shape without becoming maintained source.

### Rejected — formal third CentralStatz hospital-private layer

Hospitals will customize releases, but their private work is outside the
CentralStatz release graph. Modeling it as a third product overstates governance
and complicates upgrades/security without changing the shipped artifact.

### Retained fallback/evidence options

Direct Platform acquisition remains independently supported. Controlled forks,
side-by-side development compositions, or private packages may be recipient
choices. Git submodules, executable configuration, directory/plugin discovery,
implicit downloads, and full-Platform package conversion are not the supported
hospital-facing baseline.

## Iteration 11.4 implementation evidence

The proof resolves the previously open construction details as follows:

1. `distribution/hospital/` is the maintained source boundary and
   `platform.hospital-implementation-distribution@0.1.0` is the contract.
2. The proof identity is
   `readmission-risk-pool-hospital-implementation@0.0.0-proof.11.4`; it is not
   a public release.
3. immutable builds and the atomic current pointer live under
   `build/hospital-implementation-distributions/`; standalone Git layout is
   intentionally still deferred.
4. the embedded candidate is deterministic regular-file USTAR source with an
   internal closed inventory and version `0.0.0-proof.11.4`, not `v0.1.0`.
5. `rrp_validate_selected_canonical_producer()` and
   `rrp_run_selected_platform_cycle()` are the smallest new callable seam;
   existing scripts and generated composition call the same behavior.
6. generated wrappers own only root/state selection, initialization,
   delegation, and recovery wording.
7. the top-level lock exactly equals the candidate Platform lock with zero
   maintained additions; nonzero additions fail this bounded proof.
8. option C is selected: an editable fail-closed scaffold plus a complete,
   separate fictional adopter example reused from the Phase 10 evidence.
9. logical distribution, build-occurrence, Platform-candidate, runtime,
   product, artifact, Git, and publication identities remain distinct.

Independent tests copy the distribution outside the repository, validate and
initialize it, run synthetic acceptance and the adopter-backed cycle through
unchanged DuckDB/products/app/reduced-artifact behavior, and cover the required
tamper, incompatibility, trust, state-isolation, and hidden-dependency cases.
Generated proof state is temporary or ignored and is removed after validation.

The exact tested R/OS release matrix, final Apache-2.0 compatibility review and
policy files, final candidate manifests, and publication form remain
release-hardening work.

## Iteration 11.5 implementation evidence

The standalone realization closes the artifact-to-repository boundary without
creating another source authority:

1. `platform.hospital-implementation-git-realization@0.1.0` declares exact
   source-distribution, Platform, inventory, provenance, Git-state, validation,
   ownership, and nonclaim semantics.
2. `R/git-realization-runtime.R`, its contract, and
   `validate-git-realization.R` are already members of the validated
   distribution; the realization builder does not copy maintained Hospital
   source or rebuild either upstream artifact.
3. an explicit outside-repository destination is staged and validated before
   atomic promotion; folder name and realization time are not logical identity.
4. the repository contains the unchanged distribution plus only
   `HOSPITAL-GIT-REALIZATION.yml`, its SHA-256 file, and root `.git` metadata.
5. Git is initialized on `main`; all generated files are staged with zero
   commits, remotes, tags, credentials, or local author configuration.
6. only a complete pristine generated destination may be idempotently retained
   or replaced by another validated artifact. Any modification, commit, remote,
   branch drift, link, ignored state, alternate/nested Git state, or unrelated
   content ends generator ownership and is refused without merge or repair.
7. the artifact-owned validator independently proves exact inventory and
   provenance, the original distribution's standalone validation and temporary
   Platform doctor, and the Git baseline without the authoritative source tree.
8. temporary acquisition runs initialization, doctor, synthetic reference
   acceptance, and the materially different adopter workflow through unchanged
   history, products, app, and reduced artifact behavior.

The generated repository is publication-ready in structure only until the
separate maintainer workflow consumes an exact final candidate. Iteration 11.6
installed Apache-2.0 and candidate evidence; Iteration 11.7 owns remote
publication without changing this generator's pristine boundary.

Online retrieval, automatic upgrade/merge, recipient dependency solving,
dynamic plugins, OCI realization, and broad migration infrastructure remain
deliberately deferred.

## Implemented Iteration 11.4 — generated distribution build/validation proof

Iteration 11.4 implements the smallest in-repository proof of the generated
Hospital Implementation artifact. It creates or publishes no permanent
external repository or release.

### Scope

1. Add a focused maintained hospital-distribution source area inside this
   repository, preferably `distribution/hospital/`, containing only the
   scaffold, wrappers, docs, and metadata templates needed by the proof.
2. Define a versioned hospital-distribution contract/manifest with separate
   distribution instance/build identity, exact included Platform candidate
   identity/version/archive/digest, compatibility, environment provenance,
   inventory, validation, fictional classification, and nonclaims.
3. Add a builder that stages an immutable distribution under ignored `build/`
   state and injects an exact allowlisted Platform release-candidate archive.
   Because `v0.1.0` is not released, identify the input as a test release
   candidate and do not manufacture a release/tag claim.
4. Add an artifact-owned standalone validator that verifies exact inventory,
   checksums, safe paths, no symlinks, embedded archive identity/integrity,
   top-level environment coherence, content exclusions, and independence from
   the authoritative working tree.
5. Extract the current stable operations into the smallest callable Platform
   seam required for thin generated wrappers; keep existing Platform scripts
   invoking the same functions with the shipped composition.
6. Generate one top-level baseline lock deterministically from the Platform
   candidate lock plus only explicit maintained wrapper dependencies; reject
   conflicts and do not build a general solver.
7. Prove isolated synthetic reference acceptance from a copied distribution
   and prove the Phase 10 materially different fictional producer through the
   generated explicit composition scaffold and unchanged downstream history,
   products, app, and reduced artifact.
8. Test tampered/missing/extra archives and files, unsafe extraction, modified
   managed content, incompatible identities/dependencies, unknown producer,
   failed conformance, exit/diagnostic propagation, and absence of sensitive or
   generated operational content.
9. Update human documentation, operation registry, validation, and agent
   mappings only for operations actually implemented by the proof.
10. Leave every built distribution, extracted Platform, database, product,
    artifact, and temporary adopter state ignored and removed after tests.

### Explicit exclusions

Do not implement the standalone Git realization, external destination
replacement, remote/commit/push/publication, actual `v0.1.0` release, final
license, CI matrix, online download, updater, dependency solver, OCI, dynamic
plugins, or recipient migration tooling in Iteration 11.4.

### Exit evidence

An independently copied generated distribution validates and runs the complete
fictional baseline through the reduced artifact without the authoritative source
tree; the fictional adopter producer substitutes through explicit trusted
composition; tamper/incompatibility fails safely; and no generated artifact is
maintained or published.

## Completed release boundary and future increments

### Release/governance candidate

Iteration 11.6 completed license/governance/security/support files, narrow
tested-environment evidence, exact Platform and Hospital candidates, and
candidate archives/checksums/manifests.

### Publication

Iteration 11.7 published and remotely verified the independently versioned
Platform and Hospital Implementation `v0.1.0` releases after explicit
authorization. Publication is not deployment, and no hospital-specific state
is part of either release. Future versions must repeat the same fail-closed
boundary with newly authorized targets and evidence.
