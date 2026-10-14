# Stage 11 Architecture, Implementation, and Operational Assurance Assessment

**Status:** non-authoritative assessment supporting a later formal Stage 11
acceptance decision. This document neither accepts Stage 11 nor authorizes
Stage 12.

**Assessment date:** 2026-10-14

## 1. Assessment identity and scope

This assessment challenges the integrated realization of Stage 11 — CLI,
closed RRP-owned-payload distribution, installation, and upgrade — against the
accepted architecture and all twelve Stage 11 acceptance criteria.

The implementation under assessment is exact committed revision
`8bb1a3798b92f5407b0772d60f067fc182f45fb3`. The assessment began from clean
local `main` at documentation-only revision
`efb77df62e0aedfad28d1718ea98d666eca08252`, one commit ahead of
`origin/main`. That later commit changes only the implementation plan and
implementation record to record formal 11.H acceptance; it does not change the
assessed software or evidence. The working tree was clean before this
assessment began.

Revision-matched hosted evidence is GitHub Actions `package-foundation` run
[`38557934052`, job `115831602654`](https://github.com/centralstatz/readmission-risk-pool-platform/actions/runs/38557934052/job/115831602654).
The public workflow metadata identifies `main`, exact head SHA
`8bb1a3798b92f5407b0772d60f067fc182f45fb3`, Ubuntu, R 4.4, completed status,
and successful repository, package, distribution, and installation/software-
lifecycle steps.

The assessment covers increments 11.A–11.H as one installed operator system:
lifecycle contracts and operations, CLI parsing/rendering, distribution build
and standalone verification, dependency specification, bootstrap/private
restoration, stable and version-specific launchers, installed verification and
doctor, activation, side-by-side selection, rollback, exact uninstall, and the
clean fictional installed proof. It does not reassess clinical validity or
authorize deployment, adopter qualification, public acquisition, or release.

## 2. Executive assessment

All twelve Stage 11 criteria have credible implementation and execution
evidence. Eleven are **Established**. Criterion 11 is **Established with
limitation** because the installed operator documentation is complete and
version-matched, but three source-tree status summaries still say that 11.H is
awaiting hosted/formal acceptance.

No blocking finding, contradicted criterion, unexecuted critical verifier, or
material architecture deviation was found. The final installer correction is
present in the assessed revision and is exercised by the successful hosted
proof: the staged-realization script is invoked through `--file=`, must emit one
exact sentinel after its assertions, runs in a required UTF-8 context, and uses
the same locale-independent DESCRIPTION normalization established against the
dependency authority and installed verifier. Failure occurs before promotion.

The recommendation is **B. Ready after documentation-only reconciliation**.
The formal Stage 11 closeout should reconcile the stale source-tree status
summaries and may then make the separate acceptance decision. No production
change or repeated full acceptance run is indicated by this assessment.

## 3. Governing architecture and requirements

Authority was applied in this order:

1. [Platform True North](../platform-true-north.md);
2. [Platform Architecture](../platform-architecture.md);
3. [Platform Implementation Plan](../platform-implementation-plan.md); and
4. [Platform Implementation Record](../platform-implementation-record.md).

The governing responsibilities are:

- one user-scoped installed RRP product with exact packages, resources,
  dependencies, identity, and provenance;
- a thin human CLI over package-owned operations, with privacy-safe structured
  results and meaningful exit status;
- independent software and project lifecycles that meet only when selected
  software explicitly operates on a resolved project;
- immutable side-by-side software, project-independent selection and
  activation, explicit compatibility checking at project operation, and no
  implicit project/state migration;
- a closed positive distribution boundary with standalone verification and a
  reproducibly specified external dependency environment; and
- deployment artifacts, independent-adopter qualification, release
  publication, and clinical/support claims deferred to their later stages.

The detailed Stage 11 plan resolves activation as project-independent. A
project compatibility check may be run before activation as operator practice,
but is not an activation input or prerequisite; compatibility is enforced when
selected software is asked to operate on that explicit project.

## 4. Assessment methodology and evidence

The assessment separated five questions for each guarantee:

1. what the accepted requirement says;
2. which production owner implements it;
3. what verification is intended to exercise it;
4. whether available evidence shows that verification actually ran; and
5. what remains unproved or deferred.

Reviewed implementation included:

- `distribution/source-inclusion.dcf`, `tools/build-distribution.R`,
  `tools/distribution-lib.R`, and `distribution/verify-distribution.R`;
- `distribution/install.R`, `distribution/install-engine.R`, and
  `distribution/rrp-shim`;
- `packages/rrpplatform/exec/rrp`, `R/cli.R`, `R/software-lifecycle.R`, and
  the package-owned lifecycle operations;
- `tools/validate-distribution.R`, `tools/validate-installation.R`, package-
  native CLI/lifecycle tests, and the hosted workflow; and
- the installed Command-Line, Operator, Distribution, Installation, Software
  Lifecycle, Fictional Reference, Logical Products, and Supplied Application
  guidance.

Evidence reviewed included the complete implementation record for 11.A–11.H,
formal acceptance of each increment, both failed 11.H hosted candidates, the
final correction, local macOS/R 4.4.1 evidence, the exact hosted Ubuntu/R 4.4
job metadata, and the current 67-resource catalog and 33-export namespace.

The two failed 11.H candidates were treated as evidence, not erased history.
Revision `d94f08ae8e352c292cad1ed2d0f2f2313a1f5a49` exposed an attribution-poor
combined harness assertion. Revision
`7d075dc40810d04c99a9b0920934ade7609fe816` then exposed a production verifier
that was passed to R as an ignored positional argument. The accepted revision
was specifically checked for the corrected execution boundary and regression
evidence.

## 5. Stage 11 acceptance-criteria assessment

| # | Requirement, implementation, and evidence | Installed path and limitations | Result |
|---|---|---|---|
| 1 | The positive authority in `distribution/source-inclusion.dcf` closes two package sources and direct payload roles. The builder emits exact package artifacts, projected resources, dependency specification, normalized identity, manifest, inventory, sizes, and SHA-256 digests. Two builds preserve logical distribution identity while build occurrence differs. Negative evidence rejects undeclared/missing sources, unsafe/duplicate destinations, missing/extra/altered/linked/case-conflicting members, incorrect roles/digests, and dependency drift. | The resulting artifact is used by the complete installed proof. Archive-byte reproducibility is not claimed; normalized content identity is the accepted scope. | **Established** |
| 2 | The payload-contained base-R verifier independently checks exact closure, paths, links, manifest/inventory agreement, package/resource identities, dependencies, legal metadata, and digests. Validation copies and verifies payload bytes outside Git and rejects damaged bytes. Installation uses only the explicit HTTPS repository, selected host R, declared system hash tools, copied distribution, installed software, and independent project; poison startup files and ambient libraries cannot satisfy runtime closure. | The real copied distribution is the installation input in `tools/validate-installation.R`. Network-free installation is not claimed because configured repository access is intentional. | **Established** |
| 3 | `install.R` and installed `rrp software install` delegate to `rrp_install_distribution()`. It validates host/target/repository, stages bytes, restores exact versions into one private library, installs both internal packages, runs fresh verification, writes installation evidence, and promotes by same-filesystem rename before provisioning the shim. Repository/host mismatch, restoration/package/verification/promotion failures, locks, conflicts, and shim conflicts fail closed and clean owned staging. | The bootstrap and later CLI path both run in the installed proof and exact reinstall is idempotent. No project input, activation, or project `renv` state is involved. | **Established** |
| 4 | The stable shim resolves an exact active or per-invocation selector, exports recorded R/library/resource/installation context, and `exec`s the version launcher. The version launcher clears startup/library inputs and the dispatcher preflight performs full installed verification. Active-record byte snapshots prove explicit selection does not activate; poisoned ambient packages are rejected. Invalid selectors, pointers, and damaged installations fail before domain operation. | Stable-shim, active, explicit, and management-transport paths are exercised from unrelated directories. | **Established** |
| 5 | `rrp_verify_installed_software()` is strict and `rrp_software_doctor()` turns the same verified boundary into bounded readiness/recovery output without repair. Project validate/doctor instead load only the explicit project under selected software. Human and JSON positive cases, invalid active selection, damaged installation, absent software, incompatible project API, and nonmutation are exercised. | Software doctor output is checked not to contain the project path. Project diagnosis requires explicit/CWD resolution and never becomes software activation state. | **Established** |
| 6 | `rrp_cli_parse()` owns a closed noun grammar and delegates to package operations for project/reference creation, state, run, history, products, and app. Creation requires one destination; existing-project commands use exact `--project` or exact CWD, never parent/Git/registry discovery. The installed proof executes the complete reference path through the stable shim. | Parser/package tests prove exact CWD and no-parent behavior; 11.H proves the real installed transport and retained package owners. | **Established** |
| 7 | Human and versioned JSON renderings are derived from the same curated operation result. Tests cover schema shape, field allowlists, rendering equivalence, success/warning/operation/usage/context/interrupt exits, confirmation, and sensitive-field exclusion. The clean proof exercises both renderings for both doctors and lifecycle commands. | Doctor can exit successfully while reporting a bounded blocked/warning diagnosis; this is documented diagnostic success, not a claim that the diagnosed subsystem is ready. | **Established** |
| 8 | Installer, installed verify/doctor, activation, rollback, and uninstall APIs accept no project argument and own no project registry. The clean proof snapshots both an unrelated working directory and the complete retained fictional project around installation, selection, activation, failed activation, rollback, damage checks, reinstall, and uninstall. | Compatibility is deliberately absent from software lifecycle operations and begins only in an explicit project command. | **Established** |
| 9 | A second valid development realization changes the project API from 0.3.0 to 0.4.0. It installs and activates without project access; subsequent project validate/doctor reject the retained project with `incompatible_project_api` before mutation. The prior realization remains strictly verified and works through `--software` without changing active bytes, then works after explicit rollback. | The fixture is controlled compatibility evidence rather than a migration mechanism. | **Established** |
| 10 | Exact uninstall acquires the lifecycle lock, resolves and fully verifies one inactive target, refuses final-verified removal, quarantines by rename, and removes only that owned tree. Tests cover confirmation, active, unknown, malformed, linked, lifecycle/install locks, stale quarantine, controlled post-quarantine failure, damage, repeated removal, retained active record, retained shim, and retained realization health. | Interruption recovery is bounded to the owned quarantine; there is no automatic retention policy. | **Established** |
| 11 | Eleven cataloged installed documents cover acquisition integrity, exact repository restoration, PATH/manual activation, CLI syntax, project operation, doctors, side-by-side change, rollback, uninstall, recovery, advanced R access, and deferrals. The resource catalog and distribution verifier close and validate them. | The installed guidance is complete. Source-tree `README.md`, `docs/implementation-guidance.md`, and `AGENTS.md` still describe 11.H as pending hosted/formal acceptance; see S11-NB-01. | **Established with limitation** |
| 12 | The implementation record preserves complete local repository/package/distribution/installation evidence, both package builds/checks, parsing/hygiene, and macOS/R 4.4.1 execution. Hosted job `115831602654` proves that the same exact `8bb1a37...` revision ran and passed all four workflow validators on Ubuntu/R 4.4, including the corrected complete installation proof. This assessment separately reconciles architecture and implementation without declaring acceptance. | Hosted metadata establishes step execution and outcome; detailed bounded evidence remains in validator output and the implementation record rather than a new repository artifact. | **Established** |

No criterion is **Not established** or **Contradicted**.

## 6. Integrated architecture and implementation assessment

### Ownership and layering

The implementation retains the accepted owner split. Build/provenance logic is
maintainer-owned. The distribution-local bootstrap and shared engine own
restoration and installation. The stable shim only selects software; the
version launcher establishes R/library/resource context; the package dispatcher
parses and invokes stable operations. Project, analytical, history, product,
and application semantics remain with their pre-Stage-11 package owners.

No parallel domain implementation was found in shell launchers, the builder,
or the installer. The distribution remains a closed RRP-owned payload plus an
external dependency specification, not a generated Hospital repository or a
project. The accepted resource and package surfaces remain 67 catalog entries,
33 `rrpplatform` exports, the same package dependencies, and the existing
analytical contracts.

### Identity and integrity chain

The components agree on the relevant identity scopes:

- the distribution manifest and inventory bind product/development version,
  distribution/build identity, target R/platform/architecture, dependency
  specification, catalog, source state, and file digests;
- the installation record binds those distribution facts to canonical host R,
  private library, resource root, manifest digest, and installation identity;
- the selector binds product version and distribution identity;
- the activation record binds selector identity and installation identity;
- installed verification rechecks manifest/inventory bytes, exact nonlibrary
  tree, dependency closure/versions/DESCRIPTION integrity, internal packages,
  resources, host R, and launcher; and
- CLI preflight, activation, doctor, and uninstall call the same installed
  verification authority before trusting or mutating lifecycle state.

The shim intentionally performs only bounded transport checks; it is not a
second integrity authority. Full verification occurs in dispatcher preflight
before an operation. Installation and standalone distribution verification
have wider or different scopes because they respectively prove staged
realization and acquired payload, which is architecturally appropriate.

### Failure atomicity and lifecycle integrity

Invalid payloads fail before restoration. Restoration and fresh verification
occur under attempt-owned staging. Only a verified staged realization is
renamed to its final path; immutability failure or shim-provision failure
removes that new destination. Existing exact content is verified and reused,
while conflicts fail without overwrite.

Activation verifies the target, writes a staged record, replaces only
`active.dcf`, validates the promoted record, and restores the prior bytes on a
controlled post-promotion failure. Explicit selection never writes that
record. Uninstall fully verifies an inactive exact target, quarantines only
that tree, restores on the exercised post-quarantine failure, and preserves
the active installation and shim. Evidence shows one realization cannot
substitute its private library or identity for another.

## 7. Verification effectiveness and integrity assurance

No remaining critical success-without-execution path was found.

- Distribution build invokes the payload verifier through `Rscript`, checks
  process status, archives only after success, extracts the archive, and invokes
  that copied verifier again before promotion. Distribution-native adversarial
  cases require the intended bounded reason rather than any error.
- The standalone verifier is a separate base-R implementation over copied
  bytes. It computes actual file digests and exact tree closure instead of
  trusting builder output.
- Dependency provenance tests separately cover absent/untrusted installed
  provenance, noncanonical repositories without receipts, and missing,
  malformed, repository/target/version/integrity/closure-mismatched receipts.
- Fresh installation verification now passes its generated script to R with
  `--file=`, checks process status, and accepts only the exact
  `rrp-install-verification-ok` output produced after package, path, version,
  dependency-integrity, resource, and real CLI assertions.
- The independent integrity probe also runs through `--file=`, requires its
  own exact sentinel, compares installer and runtime hashes to the recorded
  specification under `LC_ALL=C`, and proves a controlled DESCRIPTION change
  produces a different rejected digest.
- Installed verification runs a second fresh script with exact three-line host
  R output after private-library/resource assertions. CLI preflight invokes the
  full verifier, so a damaged selected realization cannot reach an operation.
- Activation and uninstall discard no verification result before mutation.
  Controlled failures, byte snapshots, reason-specific diagnostics, and
  post-operation verification establish preservation and cleanup.
- The complete installed path runs through the real stable shim and version
  launcher from unrelated directories under poisoned startup and ambient
  library settings. It does not substitute direct package calls for the
  operator acceptance path.
- The hosted workflow calls the four documented validators directly. Public
  job metadata confirms every step completed successfully for the exact
  assessed SHA.

Some integrity logic is intentionally shared: CLI preflight, activation,
doctor, and uninstall rely on one installed verifier rather than duplicating
it. That is a single authority, not circular evidence, because standalone
payload checks, staged fresh-process checks, an independent integrity probe,
tamper tests, and hosted execution challenge it from other boundaries.

The DESCRIPTION canonicalization is coupled to the accepted `renv` integrity
meaning, but the builder records `renv` output while installer and runtime
implement and compare the normalized hash over actual installed bytes. A
future upstream algorithm disagreement would fail closed at installation or
preflight rather than accept an unproved realization.

## 8. Cross-platform and operational assumptions

The complete validator ran locally on macOS with R 4.4.1 and on hosted Ubuntu
with R 4.4. The successful Ubuntu run is direct evidence for the corrected
UTF-8 installation context, DESCRIPTION normalization, POSIX launchers,
permissions, SHA-256 tool fallback, private restoration, process supervision,
and lifecycle sequence on that cell. Local evidence covers the corresponding
macOS implementation and lifecycle path.

Implementation inspection additionally establishes:

- explicit control-character rejection and canonical absolute path handling;
- systematic argument quoting across R and POSIX subprocess boundaries;
- a safely shell-quoted software root embedded into the stable shim;
- same-root staging for distribution, installation, activation, and uninstall
  rename operations;
- directory-based lifecycle locks and explicit stale-quarantine refusal;
- startup and ambient-library isolation in both installer and launcher; and
- `sha256sum` with `shasum -a 256` fallback, documented as a prerequisite.

The full acceptance fixture uses isolated temporary overrides and does not
directly exercise the normal macOS `~/Library/Application Support/RRP` path or
a deliberately space-bearing installation root. Quoting and normalization
support that case by inspection, but direct support-cell evidence remains a
bounded Stage 13 assurance opportunity (S11-NB-02). Windows branches in R code
do not constitute Windows support: the current stable/version launchers and
acceptance supervision are POSIX shell, and Windows remains outside the
demonstrated cells. Filesystems without the assumed same-filesystem atomic
rename and permission behavior are likewise outside current evidence.

## 9. Human operator workflow assessment

The installed documents provide an executable workflow without source-tree or
package-layout knowledge:

- the Installation Guide requires standalone verification, an explicit exact
  HTTPS repository, compatible selected R, and manual PATH configuration when
  `~/.local/bin` is not already present;
- installation provisions the shim but does not activate; software list,
  verify, and doctor can use management transport before activation, while
  ordinary commands require an active or explicit realization;
- the Command-Line and Operator guides show the actual accepted argument
  placement, explicit creation destinations, exact CWD/`--project` behavior,
  returned scope handoff, source preparation, state initialization, two-time
  runs, products, foreground application, and both doctors;
- the Software Lifecycle Guide explains exact selectors, per-invocation
  selection, explicit activation, compatibility timing, rollback, uninstall
  confirmation, refusal cases, and recovery; and
- the Fictional Reference Walkthrough uses the actual governed times
  `2026-01-20T12:00:00Z` and `2026-01-21T12:00:00Z` and teaches returned-scope
  reuse rather than a hidden latest value.

The plan's compact `Rscript --vanilla install.R` line is explicitly
illustrative; the installed guide supplies the required `--repository` option.
Likewise its example time is not a hidden default. The actual CLI and installed
walkthrough require explicit accepted values. These are not operator-facing
discrepancies.

## 10. Findings, limitations, and residual risks

### Blocking findings

None.

### Nonblocking findings

#### S11-NB-01 — Source-tree status summaries lag formal 11.H acceptance

- **Severity:** Nonblocking.
- **Affected criteria:** 11 and 12.
- **Locations:** `README.md`, the introductory current-state text in
  `docs/implementation-guidance.md`, and the current-evidence narrative in
  `AGENTS.md`.
- **Evidence:** each still says 11.H awaits revision-matched hosted validation
  and formal acceptance, while the authoritative plan/record and exact hosted
  evidence establish that 11.H is formally accepted.
- **Impact:** installed operator guidance and implementation behavior remain
  correct, but a source-tree maintainer can receive an outdated maturity
  summary.
- **Bounded resolution:** reconcile those three summaries during the formal
  Stage 11 closeout. Do not change installed behavior or rewrite history.
- **Must acceptance wait?** No implementation evidence is missing, but the
  formal closeout should make this documentation-only reconciliation before or
  atomically with the acceptance declaration.

#### S11-NB-02 — Space-bearing normal installation paths lack direct full-cell evidence

- **Severity:** Nonblocking.
- **Affected criteria:** 3 and 4.
- **Locations:** default path and quoting logic in
  `distribution/install-engine.R`, `distribution/rrp-shim`, and the installed
  Installation Guide; full proof in `tools/validate-installation.R`.
- **Evidence:** code normalizes and quotes absolute roots, and macOS local
  validation passed, but the complete isolated proof uses temporary override
  roots without a deliberately embedded space rather than the normal macOS
  `Application Support` destination.
- **Impact:** no observed defect; this limits the directness of evidence for one
  platform-sensitive path case.
- **Bounded resolution:** include a space-bearing/default-location case in the
  later clean support-cell qualification when that cell is claimed.
- **Must acceptance wait?** No. The current Stage 11 claim is supported by
  implementation inspection and two demonstrated POSIX cells; broader support
  qualification is deferred.

### Deferred findings

#### S11-D-01 — Product-only artifacts and target realizations

- **Severity:** Deferred to Stage 12.
- **Affected criterion:** none; explicitly outside Stage 11.
- **Impact and resolution:** Stage 11 installs operator software but produces no
  closed deployment artifact, Posit realization, or OCI image. Stage 12 owns
  that evidence. Formal Stage 11 acceptance must not imply it.

#### S11-D-02 — Independent adopter and broader support-cell qualification

- **Severity:** Deferred to Stage 13.
- **Affected criterion:** none beyond the explicit evidence boundary.
- **Impact and resolution:** Ubuntu/R 4.4 and local macOS/R 4.4.1 development
  evidence do not establish Windows or universal platform support, nor an
  independent hospital's authoring/restoration experience. Stage 13 owns those
  claims.

#### S11-D-03 — Publication and public acquisition assurance

- **Severity:** Deferred to Stage 14.
- **Affected criterion:** none; explicitly outside Stage 11.
- **Impact and resolution:** no tag, signature, public asset, release channel,
  public download, or public immutability evidence exists. Stage 14 owns release
  qualification and publication.

## 11. Overall assessment conclusion

**Recommendation: B. Ready after documentation-only reconciliation.**

The integrated Stage 11 implementation satisfies its accepted architecture and
all twelve acceptance criteria. Evidence demonstrates the real installed
operator path, not merely package functions or named tests. Critical
verification executes in fresh processes with checked status and explicit
completion evidence; the formerly dormant installer verification is corrected
and independently challenged. Distribution, dependency, installed identity,
selection, activation, diagnosis, and uninstall agree on the realization they
trust. Failure paths preserve prior software and independent projects.

No blocking production or evidence weakness remains. The only immediate
closeout work is the bounded reconciliation in S11-NB-01. S11-NB-02 belongs to
later support-cell assurance and does not weaken the demonstrated Stage 11
boundary. The deferred findings must remain outside any Stage 11 acceptance
claim.

This conclusion is a recommendation, not formal Stage 11 acceptance.

## 12. Recommended next action

Perform the separate formal Stage 11 architecture reconciliation and acceptance
as a documentation-only closeout. In that change:

1. reconcile the stale Stage 11/11.H source-tree summaries identified by
   S11-NB-01;
2. record this assessment and the exact revision-matched hosted evidence;
3. state the demonstrated platform/evidence boundary without upgrading it to a
   production support claim;
4. preserve S11-NB-02 for Stage 13 support-cell qualification and S11-D-01
   through S11-D-03 for their owning later stages; and
5. do not begin Stage 12 until Stage 11 has been separately accepted.
