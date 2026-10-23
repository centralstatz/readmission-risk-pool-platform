# RRP 1.0.0 — Remaining Roadmap and Public Adopter Readiness Assessment

**Status:** Assessment complete — Recommendations pending human review

**Assessment date:** 2026-10-23

## 1. Purpose, authority, and decision boundary

This assessment evaluates whether the remaining RRP 1.0.0 roadmap can produce
software that an independent technical user can publicly obtain, install, and
operate without a development checkout or private explanation from the
maintainer. It reviews the accepted implementation through Stage 12, the
successful post-Stage-12 human assessment, and the high-level Stage 13 and 14
roadmap.

This is a non-authoritative decision record. It does not revise the
[Implementation Plan](../platform-implementation-plan.md), accept a stage,
authorize implementation, or authorize publication. Recommendations below
become binding only if the human maintainer reconciles them into the governing
plan.

Authority was applied in this order:

1. [Platform True North](../platform-true-north.md);
2. [Platform Architecture](../platform-architecture.md);
3. [Platform Implementation Plan](../platform-implementation-plan.md); and
4. [Platform Implementation Record](../platform-implementation-record.md).

The assessment distinguishes:

- **Observed fact:** directly established by current source, documentation, or
  accepted evidence.
- **Inferred risk:** a plausible release or adoption problem not yet disproved
  by the remaining acceptance work.
- **Proposed decision:** a recommendation requiring human approval before it
  changes the roadmap or implementation.

No clean-system matrix, dependency installation, release build, remote query,
publication operation, or invasive runtime experiment was performed for this
assessment.

## 2. Executive recommendation

**Recommendation: retain the two remaining stages, but clarify Stage 13 before
detailing it. Do not add a third stage.**

The RRP architecture and implemented product capabilities are sufficiently
complete to support the intended public 1.0.0 software product. The accepted
system already has a closed target-specific distribution, standalone
verification, exact private dependency restoration, per-user installation,
stable CLI, explicit activation and rollback, independent projects, custom
producer/provider boundaries, durable history, analytical products, and a
standalone hospital-owned Shiny application with ordinary declared R
dependencies.

RRP is not release-ready today. The remaining material work is concentrated in
four areas:

1. finalizing and documenting the **ordinary adopter installation and first-run
   experience** separately from maintainer build and qualification workflows;
2. qualifying that exact experience on declared clean macOS arm64 and Ubuntu
   x86_64 cells, including a genuinely separate adopter project;
3. stabilizing the release-shaped distribution contract, supported R/target
   matrix, public quickstart, and release-facing documentation before Stage 13
   accepts a candidate; and
4. implementing and exercising the distinct Stage 14 freeze, metadata,
   authorization, publication, immutable verification, and public
   reacquisition workflow.

Stage 13 should also reconcile environment compatibility with the governing
principle **“we guarantee only what we have verified, but we do not prohibit
what we have not verified.”** The current installer treats the distribution's
build/resolution R version, platform, and architecture as an exact installation
allowlist. Repository inspection does not establish that exact R-version
equality is a fundamental requirement: RRP's internal artifacts are source
packages, third-party packages are restored and rebuilt under the selected host
R, the packages declare `R >= 4.4.0`, and a fresh-process realization check
already precedes atomic promotion. Build provenance, formally verified cells,
and actual technical requirements should become distinct release concepts.

Best-effort installation under a newer R such as 4.5 or 4.6 therefore appears
technically feasible on a compatible platform/architecture while retaining
exact dependency versions, repository provenance, private-library isolation,
installed-file integrity, and failure cleanup. It has **not** been
demonstrated. Exact dependency availability, compilation, and runtime behavior
under those R versions remain Stage 13 evidence questions. Cross-OS or cross-
architecture reuse is less certain because the exact dependency closure may
contain compiled packages and the current metadata has no portable target-
family semantics. The smallest 1.0 approach is to investigate and relax only
checks shown not to be technically necessary, rather than introduce a general
compatibility framework.

The current Stage 13 wording can be interpreted broadly enough to contain most
of this work, but it does not explicitly require installer usability
finalization, an executable public quickstart, or separate proof of the
ordinary installation path. That ambiguity could allow an acceptance harness
to prove isolation while leaving unfamiliar users dependent on internal
knowledge. Stage 13 should explicitly own those product-facing outcomes.

Stage 14 should remain a release and publication stage. It may implement the
governed freeze/publication mechanism, final `1.0.0` identities, release notes,
checksums, authenticity evidence, and public reacquisition proof. It should not
discover or repair installer UX, CLI discoverability, project onboarding, or
distribution-content defects after the product candidate has already been
accepted.

This is **Option B — clarify or expand existing stage responsibilities**. The
two-stage structure is sound; the acceptance boundary needs sharper language.

## 3. Evidence reviewed

### 3.1 Current accepted implementation

The review covered the following current owners and evidence:

- distribution construction and positive inclusion in
  `tools/build-distribution.R`, `tools/distribution-lib.R`, and
  `distribution/source-inclusion.dcf`;
- payload verification in `distribution/verify-distribution.R`;
- base-R installation in `distribution/install.R` and shared behavior in
  `distribution/install-engine.R`;
- stable dispatch in `distribution/rrp-shim`, the version launcher, and
  `packages/rrpplatform/R/cli.R`;
- software verification, doctor, activation, rollback, and uninstall in the
  Stage 11 package owners;
- project authoring, reference operation, producer/provider execution, durable
  history, products, and application operations in `packages/rrpplatform/` and
  `packages/rrpruntime/`;
- the portable application, standalone host, and installed documentation under
  `resources/`;
- repository, package, distribution, and installation validators under
  `tools/`;
- Ubuntu/R 4.4 hosted qualification through
  `.github/workflows/package-foundation.yml`;
- formal Stage 12 acceptance at exact revision
  `49e96471da63d07c5872a28e80f8216cd0bdef72`, hosted run `39825668962`, job
  `119988175889`; and
- the successful
  [Post-Stage-12 Standalone Application Assessment](post-stage-12-standalone-application-assessment.md)
  completed on 2026-10-23 from source revision
  `adc4e17afa4cf487794d3cef0ed23c2bff49305d`.

The post-Stage-12 exercise is valuable human evidence for the installed
fictional path and standalone application. It is not a substitute for Stage
13's clean-system, independently authored adopter, and cross-platform matrix.

### 3.2 Historical evidence inspected

Relevant immutable `v0.1.0` material was inspected for ideas, not authority:

- `RELEASE.yml` separated development identity, intended candidate identity,
  and publication status;
- `docs/operations/release-preparation.md` separated local candidate
  preparation and clean acquisition from publication;
- `docs/operations/release-publication.md` required zero-mutation preflight,
  explicit authorization, exact remote identities, checksummed assets,
  reacquisition, and bounded continuation after partial remote mutation;
- `distribution/hospital/README.md` and the fictional-adopter example showed a
  recipient-oriented start sequence and independent mapping proof; and
- the historical release assessment emphasized narrow support claims,
  checksum-verifiable acquisition, and first-release documentation.

Reusable ideas are the preparation/publication separation, exact identity and
digest binding, explicit remote-mutation authorization, public reacquisition,
and a complete independent adopter proof. The former Hospital Implementation
product, embedded Platform archive, two-repository choreography, repository-
root operations, Phase suites, and Git-state adopter rules are rejected because
they conflict with the accepted 1.0 architecture.

## 4. Current product capability classification

| Capability | Current classification | Repository-grounded finding |
|---|---|---|
| Closed software distribution | Implemented | The builder emits a positive, target-specific RRP payload with two package archives, installed resources, launcher, dependency specification, manifest, identity, and SHA-256 inventory. |
| Standalone distribution verification | Implemented and qualified | The payload-contained base-R verifier operates without the development checkout and rejects closure, identity, path, link, and digest disagreement. |
| Base-R installation | Implemented and qualified | `install.R` re-verifies, restores exact dependencies, installs internal packages into a private library, validates in fresh processes, records evidence, and atomically promotes. |
| Dependency provenance and isolation | Implemented and qualified | The distribution records an exact target-specific closure and configured repository; ambient user/site libraries cannot satisfy installation. |
| Build and installation environment identity | Implemented | Distribution metadata records the build/resolution R, platform, and architecture; installation evidence separately records the actual host R executable/version/platform/architecture and incorporates them into installation identity. |
| Unverified-environment installation | Prevented by current policy/checks | `rrp_install_target()` requires exact host equality with all three distribution target fields before staging or restoration. The same exact-target assumption appears when creating a standalone application's dependency lock. No R 4.5/4.6 compatibility attempt was made. |
| Stable launcher and software lifecycle | Implemented and qualified | A per-user `rrp` shim supports list, verify, doctor, explicit activation, exact selection, rollback, and uninstall. |
| Ordinary installation usability | Partially implemented / documentation deficiency | Defaults exist for installation and executable roots, but the repository URL is required, installation does not activate, `PATH` is not edited, and the installer output does not present the complete next-step sequence. |
| Public acquisition | Absent by design | No official 1.0.0 release or public distribution asset exists before Stage 14. |
| Reference project and example | Implemented and qualified | Installed CLI commands initialize, prepare, validate, operate, materialize, and launch the fictional reference path. |
| Independent adopter authoring | Implemented interface; not independently qualified end to end | Standard project scaffolding and narrow producer/provider customization points exist, but Stage 13 still owes a separate clean adopter proof. |
| Durable history and products | Implemented and qualified | Accepted Stage 7 and 9 operations are exercised through installed workflows. |
| Standalone hospital-owned Shiny application | Implemented and qualified | Initialization, detached validation, ordinary and exact-closure execution, customization-preserving refresh, and copied-app operation passed Stage 12 evidence. |
| Cross-platform public support claim | Not yet established | Hosted Ubuntu/R 4.4 and human macOS/R 4.4 evidence exist, but the accepted Stage 13 clean matrix has not run and exact release evidence cells remain to be declared. Verified support must be reported separately from best-effort installation eligibility. |
| Release-facing documentation | Partial / stale in places | Installed guides are extensive, but no concise public acquisition-to-first-example quickstart exists and source-level `README.md`/`SUPPORT.md` still describe development-era limitations. |
| Release preparation/publication mechanism | Absent on the clean 1.0 line | Release-grade identities and verification primitives exist, but no accepted 1.0 candidate authority, changelog/release notes workflow, publication preflight, tag/asset operation, or public reacquisition mechanism exists. |

## 5. The actual current installation experience

### 5.1 What an adopter would acquire

Today, only a maintainer can build the unpublished `1.0.0-dev` distribution.
The intended future adopter input is an already-built target-specific archive.
After extraction, its top-level payload includes, in substance:

- `install.R`, `install-engine.R`, and `verify-distribution.R`;
- a version-specific launcher and stable-shim source;
- exact `rrpruntime` and `rrpplatform` package archives;
- the installed RRP resource projection and human guides;
- `dependencies/dependencies.dcf` and restoration evidence;
- product, distribution, and build identity manifests;
- a closed path/size/SHA-256 inventory; and
- `LICENSE`, `NOTICE`, `SECURITY.md`, `SUPPORT.md`, and distribution README
  material.

It deliberately does not contain third-party package archives, a hospital
project, project state, products, Git metadata, tests, deployment output, or
the development repository.

### 5.2 Simplest supported ordinary workflow today

From an already-built and extracted distribution, the simplest currently
supported flow is:

```sh
Rscript --vanilla verify-distribution.R .
Rscript --vanilla install.R --repository https://cloud.r-project.org

# If ~/.local/bin is not already on PATH, add it through normal shell policy
# or invoke the exact "Stable launcher" path printed by the installer.
rrp software list
rrp software verify --software PRODUCT_VERSION/DISTRIBUTION_ID
rrp software doctor --software PRODUCT_VERSION/DISTRIBUTION_ID
rrp software activate PRODUCT_VERSION/DISTRIBUTION_ID
rrp software current
rrp version
```

The selector is learned from `rrp software list`. On Windows, the printed
launcher is under `%LOCALAPPDATA%/RRP/bin`; on Unix-like systems it defaults to
`~/.local/bin/rrp`.

This workflow does not require a development checkout. It requires the correct
prebuilt distribution, matching R, network access to the exact configured
credential-free HTTPS repository, package compilation support if needed, and a
SHA-256 command (`sha256sum` or `shasum`).

### 5.3 Required and optional installer arguments

`install.R` currently requires:

- `--repository HTTPS_URL`.

It optionally accepts:

- `--installation-root ABSOLUTE_PATH`; and
- `--executable-root ABSOLUTE_PATH`.

Those optional paths are useful for controlled isolation and are not needed in
ordinary installation. Defaults are:

| Concern | macOS | Linux/Unix | Windows |
|---|---|---|---|
| Installation root | `~/Library/Application Support/RRP` | `$XDG_DATA_HOME/rrp`, otherwise `~/.local/share/rrp` | `%LOCALAPPDATA%/RRP` |
| Stable launcher root | `~/.local/bin` | `~/.local/bin` | `%LOCALAPPDATA%/RRP/bin` |

The selected `Rscript` supplies the host R. **Current implementation behavior**
requires exact agreement with the distribution's recorded target R version,
platform, and architecture before it attempts restoration. It separately
requires the configured repository and every restored dependency version and
integrity record to match the distribution specification. Dependencies are
obtained from that repository into a version-private R library. Existing
ambient libraries do not satisfy the closure. The exact environment equality
is current policy and implementation, not a conclusion of this assessment
about permanent technical necessity.

Installation does not activate the new realization and does not edit `PATH`,
shell profiles, or projects. These are deliberate safety boundaries. A failed
verification, network fetch, compilation, restoration, fresh-process check,
lock, conflict, or promotion leaves no promoted partial installation and does
not change an existing active version. Exact reinstall reuses a verified
realization; conflicting official content under one published version is
rejected.

### 5.4 Three workflows that must remain distinct

#### A. Developer/build workflow

The maintainer runs `tools/build-distribution.R` from an authorized source
checkout, supplies an absent output archive, resolves dependency provenance,
constructs the positive payload, and verifies the built and archived content.
This is not an adopter requirement.

#### B. Qualification workflow

`tools/validate-distribution.R` and `tools/validate-installation.R` deliberately
use explicit temporary roots, copied acquisition, controlled repositories,
clean libraries, adversarial fixtures, multiple software realizations,
complete fictional operation, standalone restoration/execution, and cleanup.
This verbosity proves isolation, reproducibility, integrity, and recovery; it
is not the ordinary user procedure.

#### C. Ordinary adopter workflow

The adopter receives the finished archive, verifies it, runs the bootstrap
with the configured repository, makes the printed stable launcher reachable,
selects and activates the exact realization, and follows a reference or
project guide. No distribution build, environment-variable choreography,
development script, or development checkout is required.

### 5.5 Assessment of the illustrative target

The conceptual flow:

```sh
tar -xf rrp-1.0.0.tar
cd rrp-1.0.0
Rscript install.R
rrp version
rrp doctor
```

is **nearly supported, but not currently the contract**:

- extraction and a distribution-local base-R installer already exist;
- `install.R` still requires an explicit repository;
- the installer does not activate, so `rrp version` needs an explicit
  `--software` selector or prior activation;
- `rrp doctor` is not one existing command: software readiness is
  `rrp software doctor`, while project readiness is `rrp project doctor`;
- `rrp` may not be discoverable until the user adds the stable launcher
  directory to `PATH`; and
- the installer output prints identity, location, launcher, and reuse status,
  but not the exact verify/doctor/activate sequence.

These differences are not architectural failures. Explicit activation and
separate software/project doctors are coherent safety decisions. Requiring the
repository URL is also defensible when repository identity is part of
reproducibility. The 1.0 product decision is whether to retain those explicit
steps with a concise executable quickstart, default the sole recorded
repository when safe, or improve installer post-success guidance. Automatic
activation and automatic shell-profile editing are not prerequisites for a
straightforward technical-user experience.

### 5.6 Environment compatibility and portability analysis

#### Three concepts the release must separate

| Concept | Meaning | Current treatment | Recommended 1.0 treatment |
|---|---|---|---|
| Build/resolution environment | R, platform, architecture, repository, exact packages, and relevant capabilities used to construct the distribution and dependency specification. | Recorded as `Target-*` metadata and bound into dependency/distribution identity. | Preserve as independently verifiable provenance; do not automatically use every value as an installation allowlist. |
| Formally verified environment | A declared cell that passed the complete Stage 13 matrix. | Ubuntu/R 4.4 hosted and macOS/R 4.4 human evidence exist, but final Stage 13 cells are not accepted. | Publish only cells that pass the complete matrix as affirmative compatibility/support evidence. |
| Technical requirements | Conditions necessary to attempt and safely complete installation and operation. | Conflated in part with exact target matching. | State the actual minimum R, supported installer/launcher capabilities, repository/package availability, UTF-8 and hashing requirements, and any justified platform/architecture constraints. |

The architecture already says every build and installation records its exact
environment and that support claims name only cells that pass. Recording exact
facts does not inherently require rejecting a different installation host.
“Broader support requires equivalent evidence” should govern affirmative
support claims, not turn every unqualified environment into a known
incompatibility.

#### Where exact matching currently occurs

| Restriction/check | Current behavior | Purpose classification | Assessment |
|---|---|---|---|
| Dependency snapshot target | Build records exact `getRversion()`, `R.version$platform`, and `R.version$arch`; a controlled provenance receipt must match them. | Reproducibility/integrity and build provenance. | Retain the recorded facts. They identify the environment in which the closure was resolved; they need not alone determine installation eligibility. |
| Manifest/specification target agreement | Standalone verification requires the dependency header and distribution manifest to agree exactly. | Integrity requirement. | Retain. This detects tampering and internal disagreement without comparing the verifier's own host. |
| Installer host gate | `rrp_install_target()` rejects any R-version, platform, or architecture difference before creating the installation root or restoring packages. | Exact R: conservative qualification policy/implementation simplification. Platform/architecture: conservative policy plus unresolved dependency portability risk. | Exact equality is not shown to be technically necessary in every dimension. Replace only after Stage 13 defines real eligibility rules. |
| Configured repository equality | Installer requires one credential-free HTTPS URL exactly matching every dependency record. | Reproducibility/integrity requirement. | Retain. Best-effort host compatibility does not justify changing dependency source provenance. |
| Exact dependency versions/integrity | `renv::install(package@version, rebuild=TRUE)` restores the declared closure; fresh and later verification checks exact versions and normalized DESCRIPTION integrity. | Reproducibility/integrity and technical requirement. | Retain. A newer R is permitted to attempt the same closure, not substitute newer package versions silently. |
| Internal RRP archives | `R CMD build` produces `rrpruntime_*.tar.gz` and `rrpplatform_*.tar.gz`; installation uses `R CMD INSTALL`. Neither package declares `LinkingTo` or native code; both declare `R >= 4.4.0`. | Source integrity plus minimum technical R requirement. | The RRP artifacts themselves are source packages and are not demonstrated to require the exact build R patch, OS, or architecture. |
| UTF-8 and system tools | Installer requires a usable UTF-8 locale and SHA-256 utility; restoration may require network, repository availability, compilers, and system libraries. | Technical necessity for current implementation. | Retain and document as requirements. |
| Fresh-process realization check | Before promotion, the selected host loads the exact private closure and `rrpplatform`, validates resources, and runs the version dispatcher. | Technical compatibility signal plus integrity. | Retain. It is the principal lightweight evidence that an unverified host can realize this distribution, but it is not full platform qualification. |
| Installation record/identity | Records actual host executable/version/platform/architecture; installation identity hashes those facts with distribution/build/dependency/manifest identity. | Lifecycle identity and integrity. | Retain. This already distinguishes a realization made under R 4.6 from one made under R 4.4 at the identity level. |
| Installed verify/doctor and launcher | The shim always invokes the recorded R. Verification reruns that R and requires its facts to match the installation record; CLI preflight requires the same executable and R >= 4.4.0. | Runtime integrity and technical minimum. | Retain. It prevents silent host substitution after installation while allowing the originally admitted unverified host to remain explicit. |
| Standalone dependency lock | App initialization currently requires the dependency specification target to equal the running R/platform/architecture before deriving an `renv.lock`. | Reproducibility safeguard implemented as exact-target simplification. | If installation becomes best-effort, this must use the admitted installation's actual host and verified closure rather than simply deleting the check. |
| Published-version content conflict | One published product version permits only one distribution ID beneath a software root. Target-keyed dependency specifications produce different distribution IDs, and one distribution installed under two host Rs shares one destination path. | Lifecycle simplification and official-content integrity. | Safe today but relevant to multi-target assets and multiple-R installs. Stage 13 must decide whether one realization per distribution per root is sufficient or whether selector/storage identity needs a bounded revision. |

The distribution verifier itself does not require the current machine to equal
the recorded target. That is appropriate: payload integrity is independent of
whether the local machine is eligible to install it.

#### Package portability and dependency reproducibility

The two RRP package archives are source packages, not platform binaries.
Third-party packages are not bundled. At installation time the selected host R
obtains the exact declared versions from the configured repository and asks
`renv` to rebuild them into the private library. The realized library is then
inventoried byte-for-byte. This design makes a newer-R attempt technically
plausible without weakening closure or provenance.

It does not prove that the attempt will succeed. Exact historical package
versions may be unavailable, may not compile against a newer R, may depend on
system libraries, or may contain native code incompatible with a different OS
or architecture. The current normalized package-integrity hash deliberately
excludes installation-specific `Built` metadata, while the complete realized
file inventory captures the actual installed bytes. Exact package versions
and exact host R are therefore separate identities with complementary roles.

Loosening the R gate would not inherently weaken rollback: each promoted
installation retains its exact recorded R, private library, inventory, and
installation identity. A failed attempt remains in sibling staging and cannot
change activation. The current path layout does prevent two installations of
the same distribution under different host Rs in one software root because
both target the same distribution-ID path; the second attempt fails as a
conflict rather than corrupting the first. Supporting their coexistence would
be additional lifecycle work, not a prerequisite for one safe best-effort
attempt.

#### R 4.5/4.6 scenario

For a distribution resolved under R 4.4.x and an adopter using R 4.6.x on an
otherwise compatible platform/architecture:

1. current installation stops at `rrp_install_target()` before restoration;
2. if that exact-version gate were replaced with the real minimum (`R >=
   4.4.0`) and a bounded policy check, the existing engine could attempt exact
   dependency restoration and compile/install the RRP source packages;
3. the existing fresh-process check would reject a closure that cannot load or
   satisfy RRP's installation interfaces;
4. a successful realization would record R 4.6, receive a distinct
   installation identity, and continue to invoke that exact executable; and
5. standalone app initialization would require a corresponding correction so
   its lock records the admitted actual R 4.6 environment while retaining the
   exact dependency provenance.

This is a credible **best-effort** path, not demonstrated R 4.6 compatibility.
A complete analytical matrix is unnecessary for every unverified R, but Stage
13 should perform one bounded representative newer-R investigation if a usable
runner and the exact closure are available. A successful install/fresh verify
is an installation-validation result only; it does not add R 4.6 to the
formally verified matrix. If the closure cannot restore, that is an actionable
best-effort failure, not corruption or evidence that RRP must downgrade the
user's R.

#### Operating system and architecture

The same conclusion cannot yet be applied indiscriminately across OS or CPU
architectures. RRP's own archives are source-based, but the dependency graph
includes packages with compiled code and platform/system-library constraints.
The current closure was resolved from one installed target and the metadata
does not define OS families, ABI compatibility, or architecture-independent
closure semantics. The Unix shim also does not establish a Windows transport.

For 1.0, the smallest defensible policy is:

- allow Stage 13 to consider newer R versions within a matching supported
  platform/architecture when the minimum R and all existing restoration and
  verification checks pass;
- continue producing and qualifying separate macOS arm64 and Ubuntu x86_64
  candidates unless investigation proves one artifact contract is safely
  portable between them; and
- treat other OS/architecture combinations as **unverified and not enabled by
  the current artifact contract**, rather than declaring them fundamentally
  incompatible without evidence.

A future target-family abstraction could broaden this boundary, but it is not
required to implement the compatibility philosophy for 1.0.

#### Failure safety and lightweight compatibility evidence

The existing engine already contains the needed safe-experimentation
boundaries:

- dependency/repository/compilation failures occur in owned staging;
- internal-package or fresh-process load/resource failures prevent promotion;
- interrupted or controlled failures clean staging and preserve existing
  installations;
- promotion is a same-filesystem rename only after validation;
- installation never activates, so a failed or successful attempt cannot
  change the active default;
- conflicting realized content fails loudly; and
- subsequent strict verify/doctor reruns recorded-host, closure, inventory,
  resource, and launcher checks.

Diagnostics currently collapse restoration or fresh-process failures into
bounded categories such as `dependency_restoration`, `internal_package`, and
`installation_verification`. Stage 13 should ensure their human messages make
an unverified-environment failure actionable without exposing arbitrary build
output or weakening privacy. No new compatibility subsystem is indicated.

#### Compatibility implementation alternatives

**Option A — preserve exact environment matching.** This maximizes simplicity:
one dependency resolution target is one installation target, standalone lock
derivation remains unchanged, and no new policy metadata is needed. It also
turns qualification evidence into an installation prohibition even when source
packages and exact restoration could work. Exact repository/package/integrity
matching is justified; exact R-patch equality is not shown to be. This option
unnecessarily pressures users with newer R to downgrade and is not recommended
as the default 1.0 policy.

**Option B — permit compatible hosts through the existing installation proof.**
Preserve target facts as build/resolution provenance, retain exact dependency
versions/repository/integrity, enforce the package minimum R and justified
platform/architecture boundary, restore into the selected host's private
library, and promote only after the existing fresh-process and inventory
checks. Record the actual host exactly and distinguish “installation
validated” from “formally verified.” Reconcile standalone-lock derivation and
diagnostics with that admitted actual host. This is the preferred approach. It
is a bounded **medium-complexity** Stage 13 correction because it touches the
dependency/distribution contract interpretation, installer target policy,
standalone initializer, documentation, and focused adversarial evidence, but
does not require a new subsystem.

**Option C — introduce target families or compatibility ranges.** Explicit R
ranges, OS families, ABI/architecture rules, and compatibility-specific asset
selection could enable broader cross-target use and coexistence. They would
also create new versioned metadata, resolution rules, qualification semantics,
and maintenance obligations. Current evidence does not justify that complexity
for 1.0. Defer unless Stage 13 shows Option B cannot express a safe minimum.

#### Recommended 1.0 compatibility policy

- **Build provenance:** record and verify the exact R version, platform,
  architecture, repository, dependency versions/integrity, source revision,
  and build identity used to construct each artifact. These facts describe the
  build; they do not alone define all valid installation hosts.
- **Minimum technical requirements:** require at least R 4.4.0, the supported
  installer/launcher capabilities for the artifact, UTF-8, SHA-256 tooling,
  repository/network access, exact package-version availability, and necessary
  compiler/system libraries. Keep exact dependency and repository checks.
- **Formally verified environments:** name only exact Stage 13 cells that pass
  the complete matrix. These are the affirmative compatibility and support
  claims.
- **Unverified environments:** permit a bounded best-effort attempt when the
  artifact's justified platform/architecture eligibility and minimum R are
  satisfied. Report success as installation validation only. Failure remains
  safely staged and carries no support obligation.
- **Known incompatible environments:** reject only a failed technical
  requirement, a demonstrated incompatibility, or a target boundary that the
  1.0 artifact contract cannot safely express. Do not label an environment
  incompatible merely because it is absent from the verified matrix.

The maintainer need not continuously certify each R release or investigate
every best-effort failure. Normal issue reporting is sufficient; support and
future qualification decisions remain discretionary.

#### Outstanding Stage 13 decisions and uncertainties

1. Whether the existing `Target-*` fields can be truthfully defined as
   build/resolution provenance or need a small versioned contract revision with
   distinct eligibility fields.
2. Whether 1.0 permits best-effort variation only in R version on an exact
   platform/architecture, or can safely describe a slightly broader target
   family without ABI machinery.
3. Whether one installation of a distribution per software root is sufficient;
   supporting the same distribution under two host Rs side by side would
   require destination/selector reconciliation.
4. How the installer or software doctor communicates “unverified but locally
   installation-validated” without embedding a growing certification database
   or implying support.
5. Whether the exact 1.0 dependency closure remains obtainable and loadable
   under an available representative R 4.5/4.6 runner. Static inspection cannot
   answer this and no cross-version experiment was authorized here.
6. Whether separate macOS arm64 and Ubuntu x86_64 release artifacts remain the
   simplest official model once Stage 13 resolves build-target and eligibility
   semantics.

Successful installation can be reported as **installation validated in this
environment**. It must not be rendered as **RRP formally qualified or
supported in this environment**. Full analytical acceptance remains reserved
for declared Stage 13 cells.

## 6. Complete public adopter journey

The following table traces the expected journey. “Independent evidence” means
evidence beyond package-native unit behavior and beyond assumptions about the
developer's machine.

| # | User step | Current capability and interface | Documentation / evidence | Remaining ownership |
|---|---|---|---|---|
| 1 | Discover official release | Absent until publication. | Root public metadata exists but is development-oriented. | Stage 14 publishes; Stage 13 prepares accurate release-facing orientation. |
| 2 | Identify requirements and verified OS/R | Partial. Packages require R >= 4.4.0, while distributions currently enforce an exact recorded target. | Ubuntu/R 4.4 hosted and macOS/R 4.4 human evidence exist, but final verified cells and best-effort eligibility are not yet distinguished. | Stage 13 separates technical requirements, build provenance, and verified cells; Stage 14 publishes all three accurately. |
| 3 | Download correct artifact | Target-keyed build exists; public catalog/download does not. | Distribution identity and target metadata are verified internally, but portable target-family semantics do not exist. | Stage 13 stabilizes artifact/target contract and bounded best-effort policy; Stage 14 names and publishes assets. |
| 4 | Verify identity/integrity | Implemented through the payload verifier and SHA-256 inventory. | Distribution validator proves copied standalone verification and adversaries. | Stage 13 makes the public command and expected output part of quickstart; Stage 14 verifies published bytes/checksum/authenticity. |
| 5 | Extract and install | Implemented through `install.R`; repository argument and exact target equality are required. | Installation guide and complete validator exist; unverified newer-R installation is currently rejected before restoration. | Stage 13 finalizes ordinary UX, minimum requirements, compatibility policy, and clean-cell proof. |
| 6 | Restore RRP dependencies | Implemented automatically from exact specification/repository into a private library and rebuilt under the selected host. | Provenance, exact-version, integrity, failure-cleanup, and fresh-process adversaries are extensive. | Stage 13 preserves these guarantees in verified and permitted best-effort paths; Stage 14 retains dependency/build evidence. |
| 7 | Make `rrp` available | Shim is installed to a default per-user executable root; no shell editing. | Installation guide documents `~/.local/bin` and Windows location. | Stage 13 resolves/document exact discovery steps and installer guidance. |
| 8 | Diagnose installation | Exact verify and software doctor exist; activation is explicit. | Installed lifecycle tests and installation aggregate pass. | Stage 13 exercises the public quickstart sequence on clean cells. |
| 9 | Run reference example | Installed `reference init`/`prepare-source` plus project/state/run/product/app commands exist. | Operator and Fictional Reference guides; Stage 11/12 automated and manual evidence. | Stage 13 condenses and independently executes a first-success example. |
| 10 | Start separate adopter project | `rrp project init` creates the standard project scaffold. | Project Authoring Guide explains the six-file surface. | Stage 13 proves this path independently of fictional-project ownership. |
| 11 | Implement producer/provider | Narrow standard authoring adapters map hospital code into raw contracts. | Package tests prove adapters; fictional projects prove two mappings/providers. | Stage 13 proves a separately authored project and documents realistic dependency ownership. |
| 12 | Run analytics | Installed `rrp run --at ... --operation-key ...` exists. | Full fictional durable runs pass. | Stage 13 repeats with the independent adopter. |
| 13 | Materialize products | Explicit scope/cutoff materialization and status exist. | Stage 9–12 evidence covers actual/empty/fresh/stale cases. | Stage 13 independent-adopter proof. |
| 14 | Initialize standalone app | `rrp app init` creates an absent independent destination. | Stage 12 and manual assessment pass. | Stage 13 clean cells and adopter project. |
| 15 | Copy application independently | Supported: detached app contains source, immutable managed products, provenance, and dependency declaration. | Ordinary and isolated copied-app execution passed. | Stage 13 cross-platform proof. |
| 16 | Restore ordinary app dependencies | Supported by conventional `renv.lock`; RRP runtime packages are not required. | Exact isolated 72-package closure passed in `validate-installation.R`; manual assessment also exercised ordinary local R. | Stage 13 confirms declared release cells and user-facing instructions. |
| 17 | Customize hospital files | Hospital-owned source may be edited; managed `rrp-data/` is separate. | Manual post-Stage-12 assessment successfully customized CSS. | Stage 13 independent-adopter usability proof. |
| 18 | Refresh managed products | `rrp app refresh` updates only compatible managed product content and preserves hospital bytes. | Automated time-2 and human assessment evidence pass. | Stage 13 clean-cell and independent-adopter proof. |
| 19 | Inspect provenance/troubleshoot | App validation, product status, project/software doctors, and immutable provenance exist. | Adversarial validators and installed guides cover recovery. | Stage 13 ensures public navigation and messages are sufficient without internal docs. |
| 20 | Upgrade/switch/rollback | Side-by-side install, explicit selector, activation, rollback, and exact inactive uninstall exist. | Stage 11 accepted proof covers compatible and incompatible project behavior. | Stage 13 qualifies supported release-candidate behavior; a real cross-published-version migration is deferred until one exists. |

The current path that most depends on undocumented maintainer knowledge is not
the analytical core. It is the transition from a downloaded archive to a
reachable, activated `rrp` command and then to the shortest reference example.
The information exists across several installed guides, but no single public
release entry point currently composes it.

## 7. Remaining work inventory

Items marked **Required** are blockers for the intended 1.0.0 outcome. “Stage
13 clarification” means the high-level stage plausibly contains the work but
should name it explicitly before detailed planning.

| Area / item | Current state and evidence | User-facing consequence | Recommended change | 1.0? / owner | Dependencies / effort | Acceptance evidence needed |
|---|---|---|---|---|---|---|
| Ordinary installer UX | Installer works, has safe defaults, but requires repository and stops before activation; `distribution/install.R`, Installation Guide. | A new user must assemble repository, PATH, selector, verify/doctor, and activation steps. | Decide explicit repository versus safe recorded default; retain explicit activation unless evidence favors otherwise; print exact next steps and document launcher invocation when PATH is absent. | **Required**; Stage 13 clarification. | Depends on target/repository policy; small–medium. | Clean user follows only public quickstart and reaches `rrp version` plus software doctor. |
| Public quickstart | No single acquisition-to-first-example procedure; information is split among distribution, installation, lifecycle, CLI, operator, and reference guides. | Technically capable users can succeed, but must reconstruct the sequence. | Add one concise executable public quickstart covering verify, install, launcher, activation, diagnosis, and first fictional run. | **Required**; Stage 13 clarification, frozen/published in Stage 14. | Depends on finalized installer and artifact names; medium documentation work. | Independent clean-system execution from only released material. |
| Release-shaped distribution contract | Target-specific closed builder exists, currently hard-coded to `rrp-1.0.0-dev`; `tools/build-distribution.R`. | Stage 14 could discover naming, compression, target-selection, or content issues too late. | Stabilize candidate artifact structure, supported target mapping, naming pattern, and ordinary installation behavior before Stage 13 acceptance; leave final `1.0.0` freeze to Stage 14. | **Required**; Stage 13 clarification. | Depends on support cells and version policy; medium. | One release-shaped unpublished candidate per supported cell verifies and installs without checkout. |
| Exact verified matrix | R >= 4.4.0 package declarations coexist with exact distribution target matching; Stage 13 names macOS arm64 and Ubuntu x86_64 but not exact verified R patches or independent eligibility rules. | User may infer either broader support than proved or incompatibility where only evidence is absent. | Declare exact verified cells, minimum technical requirements, and artifact eligibility separately; make metadata and docs agree. | **Required**; Stage 13 existing/clarified. | Human support decision; small design, potentially high execution. | Fresh evidence in every verified cell; ineligible combinations fail clearly; eligible unverified combinations are not labeled supported. |
| Build provenance versus installation eligibility | Current `Target-*` metadata serves both provenance and an exact installer allowlist. Source-package installation and existing verification suggest newer-R attempts can be safe without changing exact dependencies. | Users on a technically viable R 4.5/4.6 host are forced to downgrade or rebuild despite no demonstrated incompatibility. | Define minimum technical requirements and verified cells separately; preserve exact build facts; permit bounded best-effort installation where justified; reconcile standalone lock derivation and diagnostics. | **Required policy/implementation decision**; Stage 13 clarification. | Contract interpretation, installer, app initializer, focused tests/docs; medium. | Exact verified cells still pass; one representative unverified newer-R attempt is safely accepted or fails without promotion; success is not labeled qualified. |
| Cross-OS/architecture portability | Internal RRP archives are source packages, but target-keyed closure can contain compiled dependencies and no ABI/target-family model exists. | Treating all targets as portable could create late runtime failures; treating all mismatches as incompatible blocks possible compatibility. | Retain separate declared target artifacts for 1.0 unless bounded investigation proves portability; describe other targets as unverified/not enabled rather than inherently incompatible. | **Required boundary decision**; Stage 13. | Dependency/launcher reconnaissance; small decision, potentially larger if broadened. | Qualified macOS arm64/Ubuntu x86_64 assets; explicit safe rejection outside enabled target policy. |
| macOS arm64 clean acceptance | Human macOS evidence exists but used a development machine and locally built candidate. | It does not by itself prove clean public-style acquisition. | Execute the accepted clean cell with ordinary install and independent adopter path. | **Required**; Stage 13 existing. | Access to clean runner/machine; high evidence cost. | Recorded target identity and complete clean workflow. |
| Ubuntu x86_64 clean acceptance | Hosted Ubuntu/R 4.4 validator passes from checkout. | Strong implementation evidence, but not necessarily an ordinary public acquisition/quickstart exercise. | Add an ordinary prebuilt-artifact path distinct from the developer build/qualification path. | **Required**; Stage 13 clarification. | CI/test harness arrangement; medium. | Clean job acquires only candidate artifact and public instructions, then installs and operates. |
| Independent adopter project | Standard authoring exists; fictional proof is repository-supplied. Stage 13 already calls for a separate adopter. | Release could otherwise prove only its own example and hide adopter authoring assumptions. | Author a separate test-owned project from the normal initializer, with materially independent data mapping/provider and its own legitimate R dependencies. | **Required**; Stage 13 existing. | Depends on clean installed software; medium–high. | End-to-end run/history/products/app/refresh without fictional registration reuse. |
| Project onboarding documentation | Project Authoring Guide is strong but distributed among installed docs and template comments. | A new team may not know which guide to read after reference success. | Add a short transition from reference example to standard project, with explicit hospital-owned responsibilities and safe-data boundary. | **Required**; Stage 13 clarification. | Depends on independent adopter exercise; medium. | Independent user completes scaffold and locates producer/provider customization without raw protocol reconstruction. |
| Standalone app portability | Implemented and extensively qualified, including exact isolated restoration and manual browser use. | No product gap; support claims remain limited to tested cells. | Do not redesign. Re-run within Stage 13 matrix and surface concise operator instructions. | **Required evidence**, not new behavior; Stage 13 existing. | Supported-cell dependencies; medium evidence cost. | Detached ordinary/exact-closure execution, customization-preserving refresh, provenance, cleanup. |
| Public metadata and navigation | Root `README.md` and `SUPPORT.md` retain development-era statements; installed guides are versioned and complete. | Public visitors may receive stale maturity/support information or miss installation entry points. | Reconcile README, support/security wording, compatibility, and navigation for the candidate. | **Required**; Stage 13 content, Stage 14 final identities. | Depends on support/matrix decisions; small–medium. | Link/documentation validation plus unfamiliar-user review. |
| Development bridge closure | Roadmap requires closure; hard-coded `1.0.0-dev`, local build language, and development-only identities remain intentionally. | Publishing them unchanged would misidentify official software. | Inventory each bridge and assign either Stage 13 candidate behavior or Stage 14 version freeze. | **Required**; Stage 13 inventory/qualification, Stage 14 final transition. | Version/release authority; medium. | No development-only path or claim remains in published artifacts. |
| Release authority and candidate identity | `RRP.yml` says `1.0.0-dev`/`not_released`; no clean-line release authority exists. | Exact official candidate/publication state cannot yet be governed. | Add a minimal accepted release-state authority during Stage 14 preparation, separating development, candidate, and publication identity. | **Required**; Stage 14 existing/clarified. | Exact accepted Stage 13 revision; medium. | Fail-closed candidate construction names exact source, targets, artifacts, and unpublished state. |
| Release notes/changelog/support matrix | No changelog or 1.0 release notes workflow; legal files exist. | Users cannot evaluate change scope, compatibility, or supported cells. | Produce concise changelog/release notes and final support/security/compatibility statements. | **Required**; Stage 14 existing. | Stage 13 decisions/evidence; small–medium. | Candidate metadata review and closed artifact inclusion. |
| Publication/preflight/recovery | No clean-line publication operation exists. Historical v0.1.0 has useful patterns. | Manual tagging/upload could publish wrong or unverified bytes and be hard to resume safely. | Implement zero-mutation preflight, explicit authorization, exact tag/asset checks, idempotent verification, and bounded partial-failure continuation appropriate to one RRP product. | **Required**; Stage 14 existing. | Release provider and authenticity decisions; high. | Adversarial local tests, preflight with no mutation, then authorized published-state verification. |
| Public reacquisition | Not possible before publication. | Release cannot be called independently obtainable. | Download official asset from its public location, verify external checksum/authenticity, install, diagnose, run example, and exercise recovery. | **Required**; Stage 14 existing. | Successful publication; high final evidence cost. | Evidence names exact tag, asset, digest, target, install, doctor, example, and recovery outcome. |
| Bundled dependencies / GUI installer / hosted app | Deliberately absent and not required by architecture. | Users need R, repository access, terminal use, and ordinary Shiny hosting knowledge. | Keep deferred unless Stage 13 evidence proves a concrete need. | **Optional/post-1.0**. | New product justification; high. | None for 1.0. |

## 8. Recommended Stage 13 / Stage 14 boundary

The governing principle is supported by the repository evidence:

> Stage 13 should complete and independently qualify adopter-facing software
> behavior. Stage 14 should freeze, publish, and verify the accepted release.

### 8.1 Stage 13 should own

- the final ordinary distribution verification, installation, launcher
  discovery, activation, and doctor experience;
- the exact formally verified macOS arm64 and Ubuntu x86_64 R/target cells,
  stated separately from minimum technical requirements and permitted
  best-effort environments;
- the distinction between build/resolution provenance and installation
  eligibility, including a decision on each current exact R/platform/
  architecture check;
- any minimal compatibility relaxation justified by Stage 13 evidence while
  retaining exact dependency versions/provenance, private isolation, actual-
  host installation identity, fresh verification, and atomic failure safety;
- bounded evidence that one representative unverified newer-R attempt either
  validates successfully without becoming a support claim or fails safely,
  when such a runner and exact closure are reasonably available;
- a release-shaped but unpublished candidate distribution for every claimed
  cell;
- a concise, public-style, executable quickstart from extracted artifact to
  first working fictional example;
- a separate independently authored adopter project using the supported normal
  producer/provider surface;
- complete history, products, standalone app, copied-app restoration,
  customization-preserving refresh, provenance, rollback, privacy, failure,
  and recovery proof in the accepted matrix;
- reconciliation of adopter-facing README/support/navigation and removal or
  allocation of temporary development bridges; and
- explicit evidence that the ordinary path works separately from the
  deliberately explicit maintainer qualification harness.

Some of these are already reasonably implied by “complete clean-install and
independent-adopter matrix.” The clarification is needed so Stage 13 cannot
accept only the existing development-oriented aggregate while leaving the
ordinary release entry point unexercised.

### 8.2 Stage 14 should own

- freezing the exact authorized source revision and changing intended product
  identity from `1.0.0-dev` to official `1.0.0`;
- constructing the final artifacts from the already accepted Stage 13
  distribution contract and supported-target matrix;
- publishing exact build provenance, minimum technical requirements, formally
  verified environments, permitted best-effort behavior, and known
  incompatibilities without converting one category into another;
- final license/notice, changelog, release notes, support/security, dependency,
  build, checksum, and authenticity evidence;
- a zero-mutation release preflight and explicit human publication
  authorization;
- immutable tag/release/asset publication and exact remote verification;
- public reacquisition and execution of the already accepted ordinary
  installation, doctor, example, and recovery path; and
- bounded handling and evidence for publication partial failure.

Stage 14 may implement the release-governance and remote-publication machinery;
that machinery is not adopter product behavior. If final artifact assembly
reveals a need to change installer behavior, artifact structure, dependency
semantics, or public commands, the candidate should return to Stage 13
qualification rather than treating publication work as product acceptance.

### 8.3 Post-1.0 deferrals

Bundled third-party package closure, a graphical installer, automatic shell
profile edits, exhaustive certification of every new R/OS release, a general
target-family/ABI compatibility model, Windows support, Docker/OCI artifacts,
Posit deployment automation, hosted applications, clinical validation,
production authorization/security design, migration across a real future
release, signing infrastructure beyond the accepted authenticity mechanism,
and enterprise support/SLA remain legitimate deferrals unless Stage 13 exposes
a concrete release blocker.

## 9. Roadmap structure options

### Option A — Retain Stages 13 and 14 unchanged

This is defensible only under a generous reading. Stage 13 already names
distribution installation, doctor, independent adopter, isolation,
standalone/copy/refresh, version lifecycle, recovery, and release-candidate
exit. Stage 14 already names artifact preparation, metadata, publication, and
public reacquisition. A disciplined detailed plan could place all necessary
work under those phrases.

The risk is governance ambiguity: “acceptance” can be read as exercising
existing mechanisms rather than completing the ordinary installation product.
The current aggregate starts from a development checkout and deliberately uses
explicit roots and fixtures. The unchanged wording does not compel a public
quickstart, a distinct ordinary path, or separation of verified support from
technical installation eligibility. **Not recommended.**

### Option B — Clarify existing responsibilities

Make ordinary adopter installation, release-shaped candidate packaging,
public-style documentation, and independent execution of the quickstart
explicit Stage 13 deliverables. Add a bounded compatibility-policy decision so
Stage 13 preserves exact build/dependency provenance while admitting safe
best-effort environments independently from the formal matrix. Clarify that
Stage 14 consumes these accepted behaviors, freezes official identity,
publishes, and reacquires without introducing product behavior.

This preserves progressive planning, existing dependencies, and the clean
acceptance/publication split. It avoids hiding implementation inside an
acceptance stage while also avoiding a new layer of governance for a bounded
set of closely coupled tasks. **Recommended.**

### Option C — Add an adopter-experience stage

A separate installer/adopter-experience stage before clean-system acceptance
would make the work highly visible. It would also force renumbering or insert a
new boundary between product completion and qualification.

The current installer, lifecycle, CLI, authoring surface, and standalone app
already exist. The remaining changes are finalization, documentation, and
qualification, not a new architectural subsystem. A new stage would add
handoff and acceptance overhead without an independent product dependency.
It becomes justified only if detailed Stage 13 planning discovers a larger
installer redesign or a new acquisition architecture. **Not presently
recommended.**

## 10. User-facing release readiness

The desired expectation is achievable but not yet established:

> A technically capable R user unfamiliar with this repository can obtain the
> official distribution, follow one installation entry point, and reach a
> working reference example without consulting development documentation or
> asking the maintainer for missing mechanics.

The minimum release-facing documentation should include:

1. **Environment policy:** build provenance, minimum technical requirements,
   exact formally verified OS/R cells, permitted best-effort environments,
   known incompatibilities, artifact mapping, system tools, repository/network
   and compilation prerequisites.
2. **Acquisition:** official release location, correct artifact selection,
   extraction, checksum/authenticity, and payload verification.
3. **Installation:** the exact `install.R` command, repository rule, defaults,
   optional path overrides, what is downloaded, and failure cleanup.
4. **Command discovery:** printed launcher path, `PATH` guidance without
   automatic profile mutation, and direct-path fallback.
5. **Selection and diagnostics:** how to obtain a selector, verify, run software
   doctor, activate, confirm current, and interpret common failures.
6. **First working example:** a short fictional sequence with fixed example
   times/keys or a maintained wrapper that ends in fresh products and an app.
7. **Adopter transition:** how normal project initialization differs from the
   fictional reference and where hospital producer/provider code belongs.
8. **Standalone application:** initialize, validate, run with ordinary R,
   restore declared dependencies, copy, customize, and refresh managed content.
9. **Change/recovery:** side-by-side install, exact selection, rollback,
   uninstall, state backup/restore boundary, and nonmigration warning.
10. **Support and limitations:** security channel, best-effort support,
    nonclinical status, no production authorization, and explicit deferrals.

A small, clear, executable quickstart should be a 1.0 release requirement. It
need not conceal legitimate analytical configuration or collapse the complete
operator guide into one command.

## 11. Acceptance-strategy assessment

### 11.1 Appropriate evidence cells

macOS arm64 and Ubuntu x86_64 are reasonable initial cells for the demonstrated
developer and server contexts. They support an honest narrow affirmative
claim. Windows or additional R lines must not be described as formally
verified without evidence, but lack of qualification should not by itself be
described as technical incompatibility.

The phrase “R 4.4” is not precise enough for formal qualification evidence.
Detailed Stage 13 planning must name the exact R patch used in each verified
cell. That precision need not make the verified patch the only installable
patch. Package declarations of `R >= 4.4.0` establish a current code-level
minimum, not proof of every newer R; the restored exact closure and installer
checks establish whether a particular unverified host can complete bounded
installation validation.

Stage 13 should retain the complete matrix for the verified cells and add
focused policy/adversarial evidence for best-effort eligibility. If practical,
one representative newer-R run on a matching platform/architecture should
prove that exact restoration and fresh installation verification either pass
or fail safely. That run is useful evidence about the implementation, not a
new support cell and not a commitment to repeat the matrix for every R release.

### 11.2 Evidence already strong

- Ubuntu/R 4.4 hosted validation runs the repository, package, distribution,
  and complete installation/software-lifecycle aggregates.
- The installation aggregate copies the distribution away from source,
  restores into a private library, excludes ambient dependency satisfaction,
  and verifies failure cleanup.
- It exercises activation/rollback, two analytical times, durable history,
  products, real repeated HTTP requests, ordinary and exact isolated
  standalone execution, customization-preserving refresh, and adversaries.
- Stage 12 proves the copied application does not need the development
  checkout, installed RRP packages, originating project/state, or RRP private
  library.
- The human post-Stage-12 assessment confirms browser-level behavior on macOS.

### 11.3 Missing or ambiguous evidence

- A genuinely clean macOS arm64 acquisition/install cell has not yet been
  accepted.
- The hosted workflow builds from the checkout before testing; it does not
  separately prove that an unfamiliar user can start with only a prebuilt
  candidate and public quickstart.
- The current standard/fictitious project evidence does not yet satisfy Stage
  13's separately authored adopter requirement.
- No final exact verified R patch/artifact matrix or distinct best-effort
  eligibility policy is declared.
- R 4.5/4.6 installation feasibility is supported by static implementation
  evidence only; exact closure availability, compilation, and runtime loading
  have not been tried.
- Cross-OS/architecture use of one target-keyed artifact is unresolved and
  should not be inferred from source-package format alone.
- Public artifact selection, public download, and public checksum/authenticity
  cannot be proved until Stage 14.
- The intended public quickstart has not been executed as a single maintained
  acceptance path by an independent user or clean test.

The first three are a combination of product/documentation and test-
infrastructure gaps. Public download is correctly a Stage 14 evidence gap, not
a Stage 13 product defect.

## 12. Stage 14 publication readiness

### 12.1 Foundations already available

- content-sensitive distribution, build, and installation identities;
- exact source inclusion and closed payload inventory;
- target-specific dependency specification and configured repository
  provenance;
- separately recorded build/distribution and actual installation-host
  identities;
- SHA-256 verification and standalone payload verifier;
- exact installed evidence, immutable version roots, and fail-closed conflict
  behavior;
- license, notice, security, support, contribution, and governance foundations;
- a clean installed acquisition proof and release-grade recovery semantics; and
- historical `v0.1.0` preparation/publication patterns that can be selectively
  adapted to one current RRP software product.

### 12.2 Still absent or unresolved

- an exact clean-line release authority separating development, intended
  candidate, and publication state;
- official `1.0.0` version transitions across product/package/artifact
  metadata;
- final artifact names, compression/formats, and target-to-asset mapping;
- a changelog and release notes;
- final statements separating build provenance, minimum requirements,
  formally verified environments, best-effort installation, and known
  incompatibilities;
- a deterministic preparation operation over the exact accepted Stage 13
  revision and complete target matrix;
- final checksum/authenticity format and any provider-specific attestation
  decision;
- zero-mutation publication preflight, explicit authorization, remote
  tag/release/asset creation, and exact verification;
- bounded continuation/recovery after partial remote mutation; and
- public reacquisition, verification, installation, doctor, first example, and
  recovery evidence.

Release preparation and publication should remain different states. Candidate
construction and validation must perform no remote mutation. Actual
publication must require explicit human authorization and must operate only on
the exact accepted candidate. Publication failure must preserve evidence and
must not delete or rewrite already-published identities.

Bundled CRAN packages, platform-native executables, container images, or hosted
Shiny applications are not implied by the current product objective.

## 13. Roadmap coverage matrix

| Intended 1.0 outcome | Required capability/experience | Current status | Existing evidence | Current roadmap owner | Gap if completed literally | Recommended disposition |
|---|---|---|---|---|---|---|
| Publicly obtain official software | Immutable official release and discoverable target assets | Absent | Closed local distribution only | Stage 14 | None if Stage 14 is fully implemented | Retain Stage 14 ownership. |
| Choose a suitable download | Verified target matrix, technical requirements, and artifact mapping | Unresolved | Exact target binding exists; evidence cells and best-effort policy are not final | Stage 13/14 implicit | User could confuse build target, supported cell, and install eligibility | Separate the three concepts in Stage 13; publish them in Stage 14. |
| Verify downloaded bytes | Standalone identity, inventory, digest, authenticity instructions | Implemented except public authenticity | Distribution adversaries pass | Stage 14 public verification | Public checksum mechanism not selected | Stage 13 qualifies verifier UX; Stage 14 selects/publishes authenticity evidence. |
| Install without checkout | Distribution-local installer, private restoration, safe defaults | Implemented | Complete local/hosted installation proof | Stage 13 | No core capability gap | Explicitly test ordinary path from prebuilt candidate. |
| Attempt an unverified newer R safely | Minimum-R eligibility, exact restoration, actual-host identity, fresh verification, atomic failure | Partially present but blocked by exact target gate | Static code shows the required safety mechanisms; no R 4.5/4.6 run exists | Stage 13 not explicit | A potentially compatible user is rejected solely for environment inequality | Adopt bounded Option B, reconcile standalone lock, and prove safe success/failure without expanding support claims. |
| Install straightforwardly | One discoverable command path and actionable next steps | Partial | Guides exist; no integrated quickstart | Not explicit enough | Qualification could pass while user reconstructs PATH/activation sequence | Explicit Stage 13 deliverable. |
| Diagnose and invoke RRP | Stable launcher, verify/doctor, selection/activation | Implemented | Stage 11 accepted evidence | Stage 13 | `rrp doctor` shorthand does not exist, but is unnecessary | Preserve separate doctors; document exact commands and direct launcher fallback. |
| Reach a working example | Maintained fictional first-run path | Implemented | Automated and human fictional proofs | Stage 13 | No single public executable quickstart | Require clean execution of public quickstart. |
| Configure own project | Standard scaffold and narrow producer/provider customization | Implemented interface | Package/reference evidence | Stage 13 explicitly names adopter | Full independent adopter proof still pending | Retain and strengthen Stage 13 acceptance. |
| Retain governed analytics | Durable history and products | Implemented | Accepted Stages 7–9 and installed proof | Stage 13 matrix | None beyond cross-cell/adopter qualification | Requalify, do not redesign. |
| Produce independent app | Initialize/copy/run/restore/customize/refresh | Implemented | Stage 12 automated + human evidence | Stage 13 matrix | None beyond declared-cell/adopter qualification | Requalify and improve navigation only. |
| Change software safely | Side-by-side install, activate, rollback, uninstall | Implemented | Stage 11 accepted evidence | Stage 13 matrix | No real released predecessor exists for migration proof | Prove mechanics; defer real cross-release migration. |
| Understand support/limits | Accurate README, install/support/security/compatibility docs | Partial | Installed guides strong; root summaries stale | Stage 14 mentions docs | Stage 14 might need product-doc changes after candidate acceptance | Reconcile substance in Stage 13; freeze identities in Stage 14. |
| Trust official identity | Exact candidate, metadata, checksums, immutable remote | Partial foundations | Identity/digest chain exists; release workflow absent | Stage 14 | None if Stage 14 is implemented without product changes | Retain Stage 14 and require zero-mutation preflight. |
| Reacquire independently | Public download → verify → install → example → recovery | Absent until release | Historical v0.1.0 pattern only | Stage 14 explicitly | None | Retain exact Stage 14 evidence. |

**Answer to the matrix question:** if Stages 13 and 14 are completed under the
broadest reasonable interpretation, nothing material need remain. If they are
completed only to their literal minimum, Stage 13 could accept the explicit
development-oriented qualification harness without finalizing or exercising a
single ordinary user path, and Stage 14 could then encounter artifact/document
requirements while preparing publication. The architecture is sufficient; the
roadmap wording should close that acceptance ambiguity.

## 14. Proposed roadmap adjustments for human review

No changes in this section have been applied to the authoritative plan.

### Adjustment 1 — Name ordinary installation as Stage 13 product work

- **Existing responsibility:** prove distribution installation and doctor in
  the complete clean-install matrix.
- **Ambiguity:** this may be read as validating the current explicit harness,
  not finalizing the unfamiliar-user path.
- **Proposed addition:** Stage 13 completes and accepts the simplest supported
  distribution verification, installation, launcher discovery, exact
  selection/activation, and software-doctor workflow using ordinary defaults
  wherever appropriate; the path must require no development checkout or
  internal environment-variable knowledge.
- **Effect:** detailed planning must decide the repository default/argument,
  post-install instructions, PATH fallback, and activation sequence before
  clean acceptance.

### Adjustment 2 — Require an executable public quickstart

- **Existing responsibility:** fictional reference project and independent
  adopter project are in the matrix.
- **Ambiguity:** no single maintained document must connect acquisition to the
  first successful result.
- **Proposed addition:** Stage 13 produces and executes one concise public-style
  quickstart from extracted prebuilt candidate through verification,
  installation, diagnostics, activation, and a working fictional example.
- **Effect:** documentation becomes acceptance input, not a Stage 14 editorial
  afterthought.

### Adjustment 3 — Stabilize release-shaped packaging before publication

- **Existing responsibility:** Stage 13 exits with an accepted candidate;
  Stage 14 prepares release artifacts.
- **Ambiguity:** final artifact structure, target mapping, and names could be
  treated entirely as Stage 14 implementation.
- **Proposed clarification:** Stage 13 accepts the adopter-visible artifact
  structure, supported target mapping, payload behavior, and naming convention
  through unpublished release-shaped candidates. Stage 14 supplies official
  `1.0.0` identity, final release metadata, and published asset instances.
- **Effect:** publication cannot mask a packaging/product change. Any such
  change returns to Stage 13 evidence.

### Adjustment 4 — Separate ordinary-path and qualification-path evidence

- **Existing responsibility:** Stage 13 calls for clean-system proof.
- **Ambiguity:** the existing complete validator is intentionally more explicit
  than a user workflow.
- **Proposed addition:** acceptance records both (a) deep isolation/adversarial
  qualification and (b) the documented ordinary path from a prebuilt candidate
  on each supported cell. They may share implementation but must be separately
  attributable.
- **Effect:** test infrastructure cannot substitute for usability evidence, and
  the ordinary path cannot substitute for integrity/adversarial proof.

### Adjustment 5 — State the Stage 14 no-new-product rule

- **Existing responsibility:** freeze, prepare, publish, verify, and reacquire.
- **Ambiguity:** artifact production may reveal changes and absorb them during
  release work.
- **Proposed addition:** Stage 14 may implement release-governance/publication
  machinery but may not change adopter-facing installation, commands,
  distribution semantics, project behavior, or application behavior without
  returning the affected candidate to Stage 13 acceptance.
- **Effect:** preserves the release boundary while allowing necessary
  publication tooling.

### Adjustment 6 — Separate environment requirements from qualification evidence

- **Existing responsibility:** Stage 13 proves clean macOS arm64 and Ubuntu
  x86_64 installation/acceptance cells and records exact environment evidence;
  Stage 14 publishes support and build evidence.
- **Ambiguity:** current target-keyed metadata and installer behavior make the
  build/resolution R, platform, and architecture an exact installation
  allowlist. The roadmap does not distinguish provenance, formal support, and
  genuine technical requirements.
- **Proposed clarification:** Stage 13 must classify each environment check,
  preserve exact build provenance and dependency/integrity guarantees, state
  actual minimum requirements, and implement the smallest safe relaxation for
  best-effort installation in unverified environments where justified.
  Successful installation remains installation validation, not formal
  qualification. Stage 14 publishes the accepted categories and behavior
  without introducing a compatibility mechanism.
- **Implementation implications:** review `Target-*` contract meaning;
  `rrp_install_target()`; actual-host installation identity and destination
  conflict behavior; standalone dependency-lock derivation; verify/doctor
  diagnostics; and focused failure tests. Prefer minimum-R plus existing exact
  restoration/fresh verification on an otherwise eligible target. Do not
  weaken repository, package-version, integrity, isolation, or promotion
  checks.
- **Acceptance evidence:** all declared Stage 13 cells pass unchanged; current
  mismatch adversaries continue to reject genuinely invalid prerequisites; a
  representative unverified newer-R attempt, when practical, either installs
  and verifies without gaining support status or fails before promotion and
  leaves activation/existing installations unchanged; documentation labels
  build, verified, unverified, and incompatible states truthfully.
- **Explicit deferrals:** exhaustive testing of every R/OS release, a general
  target-family or ABI framework, broad cross-OS/cross-architecture artifact
  claims, Windows support, bundled R, and automatic compatibility
  certification.

No stage renumbering, additional stage, installer design, or final artifact
format should be approved merely by accepting this assessment.

## 15. Conclusions and requested decisions

### 1. Is the architecture sufficiently complete?

**Yes.** The accepted architecture contains the complete software, project,
analytical, product, application, distribution, installation, and lifecycle
boundaries needed for the intended public product. Remaining gaps are release
finalization, independent qualification, usability/documentation integration,
and publication—not a missing foundational subsystem.

### 2. What is the simplest installation already supported?

Acquire and extract a matching prebuilt distribution; run
`verify-distribution.R`; run `install.R --repository HTTPS_URL`; invoke the
printed stable launcher or add its normal per-user directory to `PATH`; use
`software list`, exact verify/doctor, explicit activate, `software current`,
and `version`. It does not require the development checkout.

### 3. What prevents suitability for an unfamiliar R user?

The mechanics work, but repository selection, launcher discovery, selector
transfer, verification/doctor, activation, and the first reference example are
not composed into one public executable path. Release target selection is not
final, build provenance is currently conflated with installation eligibility,
and source-level public summaries are not yet candidate-ready.

### 4. What implementation work remains before release?

Finalize ordinary installer/post-install UX; separate build provenance,
minimum technical requirements, verified cells, and best-effort eligibility;
make the smallest justified target-check/standalone-lock correction; declare
exact support cells and artifact mapping; stabilize release-shaped candidates;
reconcile public docs; prove a separate adopter; run ordinary and deep
qualification paths on both cells; close development bridges; then implement
exact candidate/version, release metadata, preflight, authorized publication,
immutable verification, and public reacquisition.

### 5. Does Stage 13 adequately own that work?

**Structurally yes, textually not quite.** Its current outcomes are broad enough
but do not explicitly require ordinary installer finalization, a public
quickstart, separate ordinary-path evidence, or a distinction between verified
support and safe best-effort compatibility. Clarification is recommended
before detailed planning.

### 6. Does Stage 14 appropriately separate publication?

**Yes in principle.** Its freeze/publish/reacquire responsibilities are sound.
It should be clarified not to introduce or repair adopter-facing product
behavior after Stage 13 acceptance.

### 7. Retain, clarify, or expand the roadmap?

**Retain two stages and clarify their responsibilities (Option B).**

### 8. Is an additional stage justified?

**No.** The remaining adopter-experience work is bounded finalization and
qualification of already implemented architecture. Reconsider only if Stage
13 planning uncovers a substantive new installer/acquisition subsystem.

### 9. Most important release blockers

1. no final ordinary installation/first-run path accepted on clean supported
   cells;
2. no accepted separation of build provenance, minimum requirements, verified
   environments, and best-effort installation eligibility;
3. no exact release support matrix and artifact mapping;
4. no genuinely independent adopter end-to-end qualification;
5. no release-ready public quickstart and reconciled public metadata;
6. remaining `1.0.0-dev` and development-bridge identities;
7. no clean-line release preparation/publication/recovery mechanism; and
8. no official public artifact, immutable verification, or public
   reacquisition evidence.

### 10. Next authorized planning action

The maintainer should review this assessment and, if the recommendation is
accepted, authorize a **documentation-only reconciliation of the high-level
Stage 13/14 roadmap boundary** using the six adjustments above. Only after
that reconciliation should Stage 13 be detailed and accepted for
implementation. This assessment does not itself authorize either action.

## 16. Final readiness judgment

RRP 1.0.0 is **architecturally capable and implementation-substantive, but not
yet ready for public acquisition**. The remaining roadmap can reach the stated
product outcome without a new stage, provided Stage 13 explicitly completes
and qualifies the ordinary adopter experience and Stage 14 is kept to release
freeze, publication, and public verification.

The key distinction is not “more automation versus less automation.” It is
whether the exact path presented to a new technical user is itself a maintained
and accepted product path, and whether its technical eligibility rules are
separate from the environments in which the maintainer makes affirmative
support claims. RRP can preserve dependency reproducibility, distribution
integrity, private isolation, exact actual-host identity, and atomic failure
safety while permitting a bounded best-effort newer-R attempt. Implementing and
validating that distinction in Stage 13 is the smallest roadmap change that
materially reduces 1.0 release risk without promising broad compatibility.
