# Hospital-facing implementation distribution architecture

## Status and authority

**Status:** authoritative Iteration 11.2 architecture decision; implementation
pending

**Decision date:** 2026-08-20

This document decides how a hospital-facing implementation project should
compose with an immutable, independently versioned Readmission Risk Pool
Platform release. It is governed by [Platform True North](../vision/platform-true-north.md),
the [platform architecture](platform-architecture.md), and the
[implementation plan](platform-implementation-plan.md). Actual work remains
recorded in the [implementation record](platform-implementation-record.md).
This document resolves the
physical adopter-packaging question left by the completed
[canonical producer foundation](canonical-producer-foundation.md) and refines
the recommendation in the earlier
[distribution and release assessment](distribution-release-assessment.md).

The decision is architectural, not implemented behavior. No hospital-facing
repository, distribution bundle, platform archive, release, tag, updater,
download operation, or release automation exists yet. The current repository
and its [operator manual](../operations/operator-manual.md) remain the only
implemented human surface.

## Decision summary

Adopt the three-level model with one refinement to the leading proposal:

1. the existing **Readmission Risk Pool Platform** remains independently
   versioned, released, usable, and testable;
2. a separately versioned **Readmission Risk Pool Hospital Implementation
   Kit** becomes the supported generic hospital-facing project; and
3. each hospital creates and owns one private implementation project from that
   kit.

An official hospital-kit release should physically carry one exact official
platform release archive plus identity, compatibility, inventory, and SHA-256
integrity metadata. Initialization should verify and safely extract that
archive into ignored, versioned, managed local state. The embedded platform is
inspectable open-source software, not a security boundary. Its integrity and
ownership boundary makes modification detectable and keeps editing it outside
the supported hospital workflow.

The kit's development source should not manually maintain a copied platform
tree or normally commit a changing extracted platform directory. The platform
archive is injected when an official kit release bundle is assembled. This is
a **partly maintained, partly generated** distribution:

```text
maintained hospital-kit scaffold + exact released platform archive
                         ↓ release construction
one hospital-facing distribution bundle
                         ↓ hospital initialization
editable private implementation + verified managed platform installation
```

The official first path is embedded and offline-capable. Silent network
retrieval is not part of initialization. An explicit exact-version download
may be added later as a development or space-saving convenience, but it must
populate and validate the same managed-release boundary and must never become
an implicit download-and-execute path.

## Problem statement

Phase 10 proves that a materially different adopter producer can satisfy the
same declaration, explicit trusted registration, exact selection, execution,
canonical admission, and conformance mechanism as the shipped synthetic
producer. It then reaches unchanged runtime, provider, history, products,
application, and deployment-artifact behavior.

What Phase 10 deliberately does not decide is how independently owned hospital
code and an immutable public platform release should coexist on disk and at
operation time. Requiring a hospital to edit or permanently fork the platform
would blur ownership, make upstream upgrades expensive, and turn platform
source layout into an adopter integration interface. Requiring two repositories
and ad hoc local paths would expose Git and composition mechanics to routine
operators. Arbitrary executable paths in configuration would weaken the trust
boundary established in Phase 10.

The chosen design must therefore provide:

- one understandable hospital project;
- a byte-identifiable platform dependency;
- editable hospital-owned source and configuration outside that dependency;
- explicit trusted executable composition without executable configuration;
- one operator-owned R environment;
- thin human operations over existing platform logic;
- isolated fictional acceptance before real-data work;
- deliberate, reversible platform upgrades; and
- the existing target-neutral deployment path.

## Current architecture facts

The decision follows these implemented facts rather than an abstract packaging
preference:

- the platform is a repository-scale system of contracts, operations, an
  internal R package, adapters, products, application code, deployment
  builders, tests, and documentation; it is not one installable R package;
- every platform script currently derives its repository root from its own
  maintained location;
- `renv.lock` describes the complete platform development and operation
  environment, while the reduced application artifact owns a smaller direct
  runtime dependency declaration;
- `config/platform-instance.yml` selects exactly one producer for one health
  system, and maintained R code—not YAML—registers its callable;
- the stable public scripts currently source the shipped composition directly,
  so an external project cannot yet substitute its trusted composition through
  those scripts without a small callable-operation seam;
- the lower-level history composition already accepts an admitted producer
  result, and the producer registry/conformance APIs already accept separately
  constructed declarations, callables, registries, selections, and invocation
  data;
- the Phase 10 adopter proof supplies all source-specific code and configuration
  outside the normal installed registry and reaches the unchanged downstream
  stack;
- operational history and product state are local generated state, not source
  release content;
- the product-only reduced application artifact is independent of sources,
  producers, history implementation, and deployment target; and
- Connect Cloud is one target realization after the reduced artifact, not an
  installation or producer-composition mechanism.

These facts mean managed composition needs a small operation/composition
boundary, not changes to canonical, runtime, provider, persistence, product,
application, or deployment contracts.

## Accepted Phase 11 decisions

The maintainer has baselined the following direction. This table is
authoritative for subsequent Phase 11 work unless concrete repository evidence
shows a contradiction or the maintainer explicitly changes it.

| Area | Accepted direction | Remaining evidence, not a reopened choice |
|---|---|---|
| First platform release | `v0.1.0`, representing the complete foundational system | Assemble and validate the candidate before publication |
| Platform release unit | Validated whole repository source tree for `v0.1.0` | Future releases may use a narrower generated bundle if the development tree later warrants it |
| Public authority | GitHub source repository, immutable Git tags, GitHub Releases, and downloadable source/release archives | No release is created in 11.2 |
| R dependency construction | Platform `renv.lock` ships; `renv::restore()` is the standard declared restoration mechanism | Exact tested R/OS evidence remains required before release claims |
| Producer trust | Explicit maintained callable registration and one exact installation selection | Level-2 physical composition must preserve it |
| Secrets | External to committed platform and hospital-kit source | Operators choose approved environment/secret infrastructure |
| Deployment | Connect Cloud remains a fictional/reference realization; publication is operator-owned; future OCI is a peer target | Connect is not endorsed for hospital PHI hosting by this decision |
| Stewardship | CentralStatz Statistical & Data Sciences LLC is project steward/release publisher; Alex Zajichek is initial maintainer | Ordinary factual release metadata only; no broader IP representation |
| License direction | Apache-2.0 after final repository dependency/asset/license review; MIT is the fallback for a genuine unresolved incompatibility | No license is installed in 11.2 |
| Contributions | Lightweight guidance, DCO sign-off for external code, no CLA, no copyright assignment | Policy files remain future implementation work |
| Support | Best-effort open-source maintenance, no SLA or guaranteed response/resolution; optional CentralStatz services are separate | Use tested-environment language backed by evidence |
| Security | `SECURITY.md`, private vulnerability reporting where available, and explicit operator responsibility | No security-operations platform is implied |
| Release integrity | Normal Git/GitHub integrity, repository validation, exact inventory, and checksums | Do not add bespoke signing/SBOM/attestation machinery without need |

## Terminology and three ownership levels

### Level 1 — Readmission Risk Pool Platform

This repository and its released source tree. It owns all generic contracts,
computation, reference implementations, operations, products, application,
deployment boundaries, conformance, observability, tests, and generic
documentation. It remains independently runnable with its fictional reference
composition.

Level 1 is versioned as the platform. Its first release is `v0.1.0`. Component
contracts and implementations retain independent versions recorded in release
metadata; they are not forced to match the platform version.

### Level 2 — Readmission Risk Pool Hospital Implementation Kit

Use **hospital implementation kit** as the durable concept. “Distribution” is
appropriate for the packaged release object, “scaffold” describes only one of
its parts, and “adopter project” describes the resulting private project.
“SDK” suggests a library/API product and “second platform” incorrectly implies
ownership of generic platform semantics.

The kit is a separate, generic, independently versioned project maintained by
CentralStatz. A kit version declares exactly which platform release it carries;
version numbers do not match by invariant. For example, kit `v0.2.1` may carry
platform `v0.1.0`.

The kit owns:

- hospital-facing directory ownership and edit guidance;
- a small top-level operation surface;
- explicit trusted installation-composition scaffolding;
- adopter configuration templates without secrets;
- onboarding, reference-acceptance, conformance, and upgrade guidance;
- one top-level R environment for the composed project;
- managed-platform release metadata and integrity checks; and
- release construction that injects an exact platform archive.

It does not own copies of platform domain logic, contracts, providers,
persistence behavior, products, application behavior, or deployment builders.

No final GitHub repository name is selected here. The repository name should
make “RRP,” “hospital,” and “implementation” discoverable and should avoid
calling the kit another platform. Naming can be finalized with the first
maintained project in a later iteration.

### Level 3 — one hospital's private implementation project

A hospital creates one private project from a kit release. That project owns:

- extraction and local joins;
- local identifiers, vocabularies, and status/code translation;
- source validation and canonical mapping;
- mapping and implementation provenance;
- producer declaration and callable implementation;
- nonsecret local configuration and external secret references;
- institution-specific operational documentation;
- approved local dependency additions; and
- local history, products, artifacts, and deployment destinations.

The hospital normally edits only explicitly adopter-owned paths. It does not
normally edit the managed platform, kit wrappers, or generated ownership
metadata. One private project represents one health-system installation; it is
not a multi-hospital selector.

## Three-level fit with Phases 0–10

The model matches the existing architecture:

```text
Level 3 hospital source and mapping
        ↓ fixed trusted Level-2 composition
platform.canonical-producer@0.1.0
        ↓ canonical admission in managed Level 1
unchanged runtime → provider → history → products → app
        ↓
target-neutral reduced application artifact
        ↓
Connect reference realization or future OCI peer
```

Level 3 owns precisely the source interpretation already assigned to local
implementations. Level 2 owns orchestration and physical composition, which
belongs above the semantic handoff. Level 1 remains unaware of hospital names,
source shapes, repository locations, and secrets. The existing downstream
stack remains unchanged.

The model also retains the shipped synthetic producer in Level 1. A hospital
can prove the platform and environment before its own producer exists, and
CentralStatz can regression-test Level 1 independently from the kit or any
hospital project.

## Composition alternatives

### Trade-off matrix: adopter and distribution concerns

| Option | Adopter usability | Reproducibility / provenance | Upgrade and hospital-code separation | Offline/internal acquisition | Git burden |
|---|---|---|---|---|---|
| Direct platform fork | One tree initially, but platform and hospital ownership blur immediately | Commit records state, but upstream release identity and local changes become intertwined | Merge-heavy; local code and platform edits are difficult to distinguish | Strong after clone/archive transfer | High ongoing fork/upstream management |
| Side-by-side platform plus private companion | Clear ownership for experienced developers | Strong when both exact versions and paths are recorded | Good separation and independent histories; path coordination remains operator-owned | Strong if both repositories are transferred | Medium-high; two acquisitions and two repositories |
| Git submodule or subtree | One outer checkout conceptually | Exact submodule commit is strong; subtree provenance needs discipline | Submodule upgrades are explicit; subtree merges copy history/content | Usable after a complete recursive transfer | High for many hospital teams; submodule state is easy to misunderstand |
| Managed embedded release archive | One hospital-facing acquisition and operation root | Exact archive identity/checksum plus platform manifest | Strong ownership boundary; versioned installs permit staged replacement | Strong; archive is already present | Low for routine operators |
| Explicit bootstrap/download | Small kit source and exact remote release reference | Strong if version/checksum validation is mandatory | Similar to embedded after retrieval | Weak as the default in restricted environments | Low after acquisition, but network/repository availability becomes setup risk |
| Full platform R package | Familiar R installation for package users | Package repository/version provenance can be strong | Hospital code can remain separate | Depends on internal package repository/cache | Low at runtime, high platform refactoring cost |

### Trade-off matrix: architectural fit

| Option | Trust and `renv` fit | Existing operations | Future releases / OCI | CentralStatz burden | Refactoring required |
|---|---|---|---|---|---|
| Direct platform fork | Explicit code registration remains possible; one lock is simple | Existing scripts work after local edits, but the fork becomes the operation authority | OCI remains possible; upstream adoption becomes merge policy | Repeated fork support and conflict diagnosis | None initially, high long-term divergence |
| Side-by-side companion | Can preserve explicit composition and one chosen top-level environment | Current scripts cannot accept external composition directly; wrappers need a callable seam | Good platform independence and OCI neutrality | Support two-root/path/Git setup | Small operation seam |
| Submodule/subtree | Explicit composition remains possible; environment can be top-level | Same callable seam is needed | Technically compatible | Submodule/subtree education and failure recovery | Small operation seam plus Git-specific policy |
| Managed embedded release | Best fit for a single top-level environment and fixed trusted composition | Thin wrappers plus a small callable seam; no domain duplication | Exact platform replacement and target-neutral artifacts remain clean | Build/integrity tooling, but no copied logic maintenance | Small operation seam and managed-install initialization |
| Explicit download | Same after successful verified retrieval | Same as embedded | Same as embedded | Network/retry/cache/support behavior adds burden | Embedded seam plus retrieval behavior |
| Full platform R package | `renv` integration is conventional, but nonpackage assets and operations need another home | Would require redesigning the repository-scale operation surface | OCI possible, but package becomes an accidental release boundary | Package publishing and split-asset coordination | Major unjustified refactor |

### Ranked recommendation

1. **Managed embedded immutable platform archive** — selected official
   hospital-facing distribution model.
2. **Side-by-side exact platform plus private companion** — credible advanced
   developer/fallback composition and useful implementation evidence, but not
   the default hospital operator experience.
3. **Explicit exact-version retrieval** — possible later convenience that must
   resolve into the same verified managed install; not the default.
4. **Controlled hospital fork** — temporary recovery/fallback model, not the
   supported long-term path.
5. **Git submodule/subtree** — technically viable but rejected as the primary
   hospital interface because Git mechanics become operational requirements.
6. **Full-platform R package** — rejected for the initial architecture because
   it would require major refactoring and obscure repository-scale boundaries.

The selected model is not a custom package manager. It handles one declared
platform artifact with no version solving, dependency registry, transitive
platform resolution, plugin discovery, or arbitrary package execution.

## What embedded means

### Canonical release form

An official kit release bundle physically contains:

- maintained kit scaffold, documentation, and wrappers;
- one exact official platform release archive;
- platform identity and exact platform version;
- release payload identity and source-release provenance;
- archive filename, byte size, and SHA-256 digest;
- a compatibility declaration between the kit and platform release;
- an ownership inventory distinguishing maintained, adopter-owned, generated,
  and managed paths; and
- the kit's top-level environment baseline and restoration guidance.

The exact archive filename, directory names, and manifest identifier are left
to the implementation proof. Their semantics are not open: one kit release
must carry exactly one declared platform release, and the archive bytes must
match the declared digest.

### Managed installation behavior

Initialization should:

1. validate the kit's own required inventory;
2. validate the platform archive's identity, size, and SHA-256 digest before
   extraction;
3. reject symbolic links, unsafe archive paths, traversal, undeclared payloads,
   and identity mismatches;
4. extract into a staged version-specific managed directory;
5. validate the extracted platform using platform-owned validation;
6. promote only a complete valid managed installation; and
7. update an installation-local current-platform reference only after
   successful validation.

The managed area is ignored local state and supports multiple versioned
platform installations during a future staged upgrade. Its precise name is an
implementation choice; `.rrp/platform/<version>/` is illustrative, not a
contract.

Manual changes to extracted platform files must be detectable by inventory and
checksum validation. Validation should fail with recovery that preserves the
modified tree for review and reinstalls from the known archive into a new or
clean managed location. It should never silently repair or overwrite unknown
changes.

This is an ownership/integrity boundary, not a sandbox. Users may inspect,
copy, or modify open-source code. A modified managed tree simply becomes an
unsupported local platform derivative until separately identified and
validated.

### Retrieval policy

The official initial kit should not require GitHub or any network at
initialization time. A hospital can transfer the one kit release bundle and
its own R/package installation sources through approved internal channels.

If later evidence supports an online bootstrap, it must be explicit, name one
exact release and checksum, obtain operator consent before network access, and
validate before extraction or execution. It may not silently choose “latest,”
execute downloaded code before verification, or create a second installation
model.

## R environment ownership

### One active project

The top-level private hospital project owns the one active `renv` project and
authoritative runtime lockfile. From the hospital operator's perspective,
running:

```sh
Rscript -e 'renv::restore()'
```

from the project root restores the composed installation environment. Routine
operations must start from that root or otherwise activate that same library.
They must not activate a nested managed-platform project.

The extracted platform retains its original `renv.lock`, `.Rprofile`, and
`renv` infrastructure unchanged for provenance and independent Level-1 use.
Those files are inactive when top-level kit operations call managed platform
code. The kit must not run nested `renv::restore()` operations into competing
libraries.

### Constructing the top-level lock

For an official kit release, the top-level baseline lock should be derived
from the exact embedded platform release lock and then add only dependencies
used by maintained kit behavior. A private hospital project adds producer-owned
dependencies to its own top-level lock through deliberate `renv` actions and
validation; it never edits the embedded platform lock.

The initial conservative rule should preserve the exact versions required by
the embedded platform. Adding a hospital dependency must not silently upgrade
or downgrade a platform dependency. If an adopter dependency cannot coexist,
environment construction fails and the conflict is resolved explicitly before
the producer is selected or run.

This policy yields three related but noncompeting records:

- the platform lock: immutable release provenance and independent Level-1
  reproducibility;
- the kit baseline lock: exact platform closure plus kit dependencies; and
- the private project lock: the hospital-approved complete environment,
  including producer dependencies.

Only the last is active in the hospital project. Dependency-union and conflict
checking require implementation evidence in the next iteration; no generic
lockfile merger is authorized by this assessment.

### Upgrade environment semantics

A proposed platform upgrade creates a candidate top-level lock from the new
platform baseline plus the hospital's declared producer dependencies. It is
restored and validated in a separate candidate library. The current library
and platform selection remain active until the reference workflow, producer
conformance, and platform checkpoint pass. Dependency conflicts fail before
selection changes and never rewrite hospital code.

## Operation ownership

### Responsibility split

| Concern | Level 1 platform owns | Level 2 kit owns | Level 3 hospital owns |
|---|---|---|---|
| Domain behavior | Canonical admission, runtime/provider, history, products, app, artifact, target realizations | None | Source interpretation and producer callable only |
| Human surface | Stable callable operation behavior and direct Level-1 reference scripts | Thin top-level wrappers, project paths, composition, acceptance ordering | Invocation cadence and approved local procedures |
| Configuration | Generic validation and shipped reference defaults | Ownership/precedence and nonsecret templates | One exact local selection and producer configuration |
| Diagnostics | Structured event and callable sink contracts | Propagation and top-level recovery wording | Approved routing/retention if later implemented |
| State | Logical history/product/artifact semantics | Managed-platform install state and default project locations | Operational data, backups, retention, access, deployment destinations |

### Hospital-facing operation surface

The kit should expose a small explicit set of scripts corresponding to these
intents:

- initialize the hospital project and managed platform;
- run hospital-project doctor/preflight;
- run isolated fictional reference acceptance;
- validate the hospital implementation/producer;
- run one platform cycle;
- inspect operational history;
- materialize products;
- validate or launch the application;
- build or validate the target-neutral artifact; and
- build or validate an available target realization.

Final filenames should follow the implementation proof. They should be thin
scripts, not a CLI framework or generic router. The existing platform operation
registry may supply checked IDs, commands, classifications, and documentation
links, but must not become reflective execution.

### Delegation rules

Level 1 should expose callable operation entry points that accept explicit,
already trusted installation composition and explicit state paths. Existing
Level-1 scripts should call those same functions with the shipped reference
composition. Level-2 wrappers should call the functions with the kit-owned
composition. This prevents wrappers from copying script bodies or domain
logic.

The smallest required Level-1 change is an operation-composition seam, not an
extension loader. It accepts R objects/callables constructed by maintained
trusted code in the active project; it never accepts a configuration-supplied
file path, function name, package name, URL, or expression.

Wrappers must preserve platform result semantics, return nonzero when the
delegated operation fails, and pass through structured diagnostics without
turning them into retained history or audit. A top-level operation-run context
may correlate kit preparation and delegated platform stages, but analytical
runtime-run identity remains separate.

Adopter-specific preparation before delegation is limited to validating the
managed platform, top-level environment, platform-instance configuration,
producer declaration, trusted registration, producer-owned nonsecret
configuration shape, and required external secret presence without exposing
values. Source extraction, joins, and mapping remain inside the callable.

## Producer trust and composition

### Recommended private project layout

The following is a conceptual ownership layout, not an implemented or final
filename contract:

```text
hospital-project/
├── implementation/                 # hospital edits
│   ├── producer.yml                # declarative producer identity/capability
│   ├── R/                          # extraction, validation, mapping, adapter
│   └── README.md                   # local meaning and provenance
├── config/                         # hospital edits; no secrets
│   ├── platform-instance.yml       # one exact producer selection
│   └── producer.yml                # producer-owned nonsecret configuration
├── composition/                    # reviewed trusted code; hospital maintains
│   └── installed-producer.R        # explicit fixed registration
├── operations/                     # kit-maintained thin wrappers
├── platform-release/               # kit-managed exact archive + metadata
├── renv.lock                       # hospital-project authoritative lock
└── managed-local-state/            # ignored; name to be finalized
```

The public kit should provide templates and explanations, not real hospital
values. The private project replaces the templates with institution-owned
code. No PHI, credentials, connection strings, or private mappings enter the
public kit or Level-1 release.

### Explicit trust flow

```text
fixed maintained Level-2/3 composition code
        ├── sources a reviewed fixed list of adopter implementation files
        ├── reads the adopter producer declaration
        ├── constructs the callable with producer-owned configuration
        └── registers exactly that declaration/callable
                                  ↓
top-level config/platform-instance.yml selects exact ID@version
                                  ↓
platform validates declaration + registry + selection
                                  ↓
producer conformance and canonical admission
                                  ↓
unchanged downstream operation
```

The source-file list is literal maintained code in the private project. It is
not discovered by scanning directories and is not supplied by YAML. Modifying
that composition is an explicit code review event, exactly like modifying any
other trusted executable source.

### Platform-instance ownership

The hospital project supplies one complete top-level
`config/platform-instance.yml`; it is not an overlay onto or mutation of the
embedded platform file. Level-1 configuration validation should accept the
explicit document supplied by the calling composition instead of discovering
it from the platform root. The embedded file remains immutable and continues
to select the synthetic producer for Level-1 independent use and reference
acceptance.

Normal hospital operations receive only the top-level selection and the
registry constructed by trusted composition. Generic platform code remains
unaware of hospital names and paths. Multi-producer registration is unnecessary
for the initial kit; the private composition should register exactly the one
selected hospital producer.

### Conformance gate

The kit must provide an explicit producer-conformance operation using an
approved fictional or controlled producer-owned scenario before normal local
execution. Initialization does not imply conformance. Doctor should report
whether the exact selected producer/platform/environment combination has been
validated when a safe non-PHI receipt mechanism is implemented.

Normal execution must always repeat declaration, registration, selection,
result, and canonical-admission validation. It may additionally require a
current conformance receipt keyed to platform, producer, implementation,
mapping, and relevant configuration identities. The next proof should choose
the smallest fail-closed mechanism and must not persist source rows or secrets
in such a receipt.

## Initial installation lifecycle

### 1. Acquisition

The hospital obtains one official kit distribution through an approved
transfer. It verifies the kit release integrity according to its release
instructions. Git is optional for the operator; a hospital development team
may place the resulting private project under its own approved private version
control.

### 2. Environment restoration

The operator installs the tested R line and restores the one top-level lockfile
from the project root. Restricted environments may use approved internal R
package repositories or preprovisioned caches; the kit does not bundle package
binaries or promise an offline CRAN mirror.

### 3. Initialization

The kit initializer validates and extracts the exact embedded platform into
managed local state. It creates no operational history, products, artifact,
deployment, credentials, or real-data connection. Repetition is idempotent for
identical valid state and fails closed on drift.

### 4. Reference acceptance

A top-level acceptance operation invokes the embedded platform's shipped
synthetic composition in isolated fictional state. It runs doctor and the
supported reference lifecycle through at least products/app and, for release
acceptance, the target-neutral artifact. The hospital need not know or type
the managed platform path.

Reference acceptance never uses the hospital's producer selection or real
state. Its generated history/products/artifacts live in a separate acceptance
area and cannot be mistaken for hospital operational state.

### 5. Local implementation

The hospital edits only adopter-owned implementation, configuration, and local
documentation. Secrets stay in approved external facilities. Source-specific
tests use fictional, deidentified, or otherwise approved controlled data under
local policy and never enter the public repositories.

### 6. Producer conformance and selection

The reviewed composition registers the hospital callable. The complete
top-level platform-instance document selects its exact producer ID/version.
The kit validates conformance before normal execution and fails without a
canonical bundle if any stage fails.

### 7. Normal execution

Top-level wrappers delegate to Level-1 operations with explicit local state
paths and the trusted composition. The existing downstream runtime, provider,
history, product, app, artifact, and diagnostic semantics do not change.

### 8. Deployment

After products are materialized, the hospital builds the existing
target-neutral reduced application artifact. A separately chosen target
realization consumes it. Connect Cloud remains available for fictional
reference/tutorial use; real-data publication requires operator-owned target,
privacy, security, access-control, network, and governance decisions.

## Upgrade lifecycle

A kit version declares exactly one carried platform release. A later kit
release may update only kit guidance/wrappers, or may carry a newer platform
release. Upgrade is a staged validation, never an in-place overwrite or silent
merge.

Conceptually:

1. acquire and verify the new kit release;
2. compare kit, platform, contract, operation, and environment compatibility
   declarations before changing current state;
3. preserve and back up hospital operational history and the current private
   project according to local policy;
4. stage the new platform archive beside the current managed version;
5. construct and restore a candidate top-level R library from the new platform
   baseline plus hospital producer dependencies;
6. run the new platform's isolated fictional reference acceptance;
7. run the unchanged hospital producer code through declaration, registry,
   selection, conformance, and canonical admission against the candidate;
8. run platform checkpoint and applicable history/product/artifact
   compatibility checks against safe test or copied state;
9. report every incompatibility and required manual change without editing
   hospital code; and
10. switch the managed platform and environment selection only after explicit
    operator acceptance.

An incompatible candidate leaves the prior platform, environment, and hospital
source unchanged and usable. Product bundles and deployment realizations are
rebuildable; operational history is preserved and never silently migrated or
discarded. A future migration operation must be designed only when an actual
version transition requires it.

The kit's ownership inventory should distinguish:

- replaceable kit-maintained files;
- immutable managed platform payload;
- adopter-owned files that an upgrade may never overwrite;
- generated local state; and
- local files whose modification requires manual reconciliation.

No updater or merge mechanism is implemented in 11.2.

## Maintaining Level 1 and Level 2

Use a partly maintained, partly generated model:

### Maintained in the platform repository

- generic semantic and operation interfaces;
- the independent synthetic reference;
- platform validation and release inventory;
- the minimal callable composition seam needed by trusted external shells; and
- conformance tests proving an external composition does not alter downstream
  behavior.

### Maintained in the hospital-kit project

- hospital-facing wrappers and their operation registry;
- implementation/configuration templates;
- ownership and compatibility declarations;
- onboarding, acceptance, conformance, and upgrade guidance;
- top-level environment baseline construction; and
- kit release assembly/validation behavior.

### Generated only for a kit release

- the exact platform archive copied from an official Level-1 release;
- its pinned identity/checksum in the completed kit manifest;
- the distributable combined bundle; and
- any derived release inventory.

No Level-1 R source, contract, operation script, app file, or deployment builder
is manually copied into Level 2. A platform fix is made and released in Level
1, then a kit release deliberately updates its one declared platform artifact.
A kit-only documentation or wrapper fix can release without changing the
platform version.

CentralStatz therefore maintains two intentional products but only one copy of
platform logic. Cross-project validation checks the declared platform artifact
and operation interface rather than synchronizing duplicate files.

## Security and privacy boundaries

The architecture establishes these boundaries without claiming a complete
security system:

- the platform release and generic kit are public and contain no PHI, private
  mappings, credentials, connection strings, or hospital secrets;
- the hospital project is private and governed by the hospital;
- the embedded archive is checksum-verified before extraction and the managed
  tree is integrity-validated before use;
- archive extraction rejects links and path traversal;
- configuration cannot name executable files, functions, packages, URLs, or
  expressions;
- only fixed reviewed composition code registers the callable;
- initialization performs no silent network retrieval or execution of
  unverified bytes;
- secrets remain external and diagnostics report presence/status only, never
  values;
- fictional acceptance state is isolated from hospital operational state;
- generated deployment artifacts contain only their declared allowlist and no
  source implementation or secrets; and
- operators remain responsible for infrastructure, identity/access, network,
  credentials, PHI handling, backups, retention, incident response, clinical
  validation, and production authorization.

Checksums establish accidental-corruption and exact-payload evidence; they are
not code signing, malware analysis, sandboxing, or a claim that modified open
source cannot execute.

## Deployment neutrality

Hospital implementation packaging and application deployment remain separate:

```text
private hospital producer
        ↓
canonical admission → runtime → history → products
        ↓
target-neutral reduced application artifact
        ├── Connect Cloud reference realization
        └── future OCI/container realization
```

The kit may wrap artifact and realization operations, but it neither changes
the artifact nor adds Connect concepts to source composition. The managed
platform release carries whichever peer target realizations that exact release
supports. External publication always remains separately authorized and
operator-owned.

## Synthetic reference acceptance

The synthetic reference remains a Level-1 component and must not be copied or
reimplemented in the kit. The kit exposes it through one top-level acceptance
operation that:

- uses the managed platform's unchanged shipped composition;
- uses isolated fictional generated state;
- delegates to platform-owned operations and validation;
- reports the platform and kit versions tested;
- propagates platform exit status and safe diagnostics; and
- stops before external publication.

Passing acceptance proves that acquisition, extraction, environment,
platform, products, app, and artifact can operate together. It does not prove
the hospital producer, real data, clinical validity, security approval, or
production readiness.

## Unresolved implementation questions

These questions remain for evidence in the implementation proof and do not
reopen the selected architecture:

1. the final project/repository name and exact managed/archive/state paths;
2. the initial kit version and identity of its physical manifest;
3. whether the platform archive is a maintainer-attached release asset or a
   content-verified archive derived from the exact tag;
4. the smallest callable Level-1 operation API that avoids wrapper duplication;
5. exact top-level wrapper filenames and which advanced Level-1 operations are
   intentionally not exposed;
6. how the candidate top-level lock is constructed and checked without
   inventing a general dependency solver;
7. whether a bounded non-PHI conformance receipt is necessary or conformance
   should execute on each normal run in the initial implementation;
8. exact ownership-manifest behavior for future kit upgrades;
9. the tested R minor line and OS matrix supported by release evidence; and
10. completion of the Apache-2.0 dependency/asset/license review.

An online retrieval mode, automatic updater, package-based producer, OCI
realization, multiple platform versions active in one run, and generic plugin
discovery remain deliberately deferred.

## Recommended Iteration 11.3 — managed composition proof

The smallest next implementation increment should prove the physical seam
without creating or publishing the real hospital-kit repository.

### Scope

1. Extract the current stable producer validation and run orchestration into
   small callable Level-1 operation functions that accept an already
   constructed trusted composition and explicit state paths. Preserve the
   existing scripts by making them call those functions with the shipped
   composition.
2. Define a narrow draft managed-platform release descriptor and ownership
   inventory sufficient for one exact archive, SHA-256 validation, compatible
   platform identity/version, and managed/adopter/generated path classes.
3. In tests only, construct a temporary hospital-project tree outside the
   platform source, create a temporary archive from an allowlisted current
   platform candidate, verify it, and extract it into temporary managed state.
   Retain no archive or extracted tree in the repository.
4. Put a materially different fictional adopter producer in the temporary
   top-level implementation area. Use fixed trusted composition code and a
   complete top-level platform-instance document; do not load a code path from
   YAML.
5. Prove one top-level environment can run isolated synthetic reference
   acceptance, adopter producer conformance, one adopter-backed history run,
   products/app construction, and the unchanged target-neutral artifact.
6. Test archive tampering, managed-tree modification, unsafe extraction,
   unknown selection, failed conformance, dependency incompatibility, state
   separation, nonzero exit propagation, and absence of source/secrets from
   artifacts and diagnostics.
7. Document the exact proposed hospital-kit tree and human operations based on
   evidence from the proof.

### Explicit exclusions

Iteration 11.3 should not create the production hospital-kit repository,
publish a bundle, install a license, tag `v0.1.0`, implement network download,
build an updater, add OCI, add dynamic loading, or claim a release-ready R/OS
matrix. Those belong only after the composition proof validates the seam and
the remaining license/environment evidence is complete.

### Exit evidence

The proof succeeds when an isolated temporary hospital project operates an
exact integrity-checked managed platform through thin wrappers, substitutes
its explicitly trusted fictional adopter producer, reaches unchanged
downstream behavior, and fails safely on drift or incompatibility without
editing platform or adopter source. That evidence can then justify creating
the separately maintained hospital-kit project in a later bounded iteration.

## Consequences

### Benefits

- hospitals receive one understandable starting distribution;
- public platform and private hospital code retain clear ownership;
- restricted/offline onboarding does not require GitHub at initialization;
- platform upgrades are exact, staged, and reversible rather than permanent
  fork merges;
- the Phase 10 trust boundary remains explicit;
- one top-level R environment avoids nested-project ambiguity;
- Level 1 and Level 2 can version and release independently; and
- deployment remains target-neutral.

### Costs

- CentralStatz must maintain a second project and a validated kit-release
  construction step;
- the platform needs a small callable operation/composition seam;
- the kit must own archive extraction, integrity, path ownership, and
  top-level environment validation;
- platform and hospital dependency conflicts require explicit resolution; and
- upgrades need staged validation and cannot be promised as automatic.

These costs are bounded and arise from real ownership/offline requirements.
They are smaller than supporting permanent forks, two-repository ad hoc paths,
or a full-platform package conversion.
