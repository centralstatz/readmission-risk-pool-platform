# Distribution and first-release decision assessment

## Status and authority

**Status:** retained Iteration 11.1 decision support; superseded where the
maintainer baselined decisions in Iteration 11.2

**Assessment date:** 2026-08-20

This document identifies the maintainer decisions that must precede the first
supported release of the Readmission Risk Pool Platform. It ranks realistic
options against [True North](../vision/platform-true-north.md), the implemented
[architecture](platform-architecture.md), the
[implementation plan](platform-implementation-plan.md), the
[open decisions](open-decisions.md), and the actual
[implementation record](platform-implementation-record.md), while accounting
for a small maintainer footprint, healthcare adoption realities, and the goal
of reaching a hard foundational release cutoff before adding more product
capability.

This remains the assessment evidence that preceded maintainer decisions. It is
not itself a license grant or release authorization. Iteration 11.2 baselines
the accepted direction and selects the physical hospital-facing composition in
[Hospital-Facing Implementation Distribution](hospital-implementation-distribution-assessment.md).
That later document governs wherever this assessment describes a choice as
unresolved. Apache-2.0 installation still awaits final compatibility review,
the tested environment matrix still awaits evidence, and no release is
authorized. This is technical and governance decision support, not legal
advice.

## Iteration 11.2 resolution update

The maintainer accepted `v0.1.0`, the whole repository as the first platform
release unit, GitHub source/release authority, the shipped platform lock and
`renv::restore()`, explicit trusted producer composition, external secrets,
target-neutral deployment with Connect as reference only, CentralStatz
stewardship with Alex Zajichek as initial maintainer, Apache-2.0 subject to a
final compatibility review with MIT fallback, DCO without CLA/assignment,
best-effort support without SLA, standard security governance, and ordinary
Git/GitHub release integrity.

The prior generic “private companion” recommendation is refined into a
separately versioned hospital implementation kit. Its official release embeds
one exact platform release archive and creates a private hospital project with
one top-level R environment and fixed trusted composition. See the authoritative
decision linked above for alternatives, ownership, lifecycle, and the bounded
next proof.

## Executive recommendation

Subject to explicit maintainer approval, the most coherent first-release model
is:

```text
CentralStatz-stewarded public GitHub source repository
        ↓
Apache-2.0 repository-authored software and documentation
after ownership, dependency, asset, and trademark review
        ↓
immutable GitHub Release from signed tag v0.1.0
        ↓
maintainer-produced source archive + SHA-256 checksum
or exact-tag Git clone
        ↓
supported R line + committed renv.lock + renv::restore()
        ↓
initialize / doctor / shipped fictional reference workflow
        ↓
private adopter companion implementation pinned to the exact platform release
        ↓
explicit trusted producer registration and one exact installation selection
        ↓
human-operated estimation, history, products, app, and reduced artifact
        ↓
Connect Cloud reference realization for fictional/non-sensitive use
        ↓
operator-controlled commit, remote, publication, sharing, and deployment

Future peer target:
validated reduced artifact → OCI-compatible realization → operator environment
```

The full repository is the platform release unit. `rrpruntime` remains an
internal package and keeps its own version. Contracts, providers, adapters,
products, artifacts, and target realizations retain their independent logical
versions. The first platform release should be `0.1.0`, not `1.0.0`, because
the foundational path is coherent while external adoption, upgrades, and the
support matrix remain unproven.

At the 11.1 checkpoint, the most important unresolved implementation question
was physical composition of private adopter code. Phase 10 proved the semantic
seam, but the normal installation wired the shipped producer inside the core
tree. This assessment recommended a private companion pinned to one exact
platform release. Iteration 11.2 has since refined that recommendation into the
managed hospital implementation kit linked above; its bounded proof remains
future work. A hospital fork should not be advertised as the preferred upgrade
path.

## Current platform evidence

Phases 0–10 establish the following facts relevant to distribution:

- the repository is a multi-part platform, not one R package;
- `rrpruntime@0.3.0` is a focused internal base-R package, while operations,
  contracts, adapters, products, the Shiny app, and deployment builders live
  outside it;
- `renv.lock` records the complete development/operation environment, currently
  R 4.4.1 and exact package versions;
- the reduced artifact separately declares only R 4.1.0+, Shiny 1.10.0, and
  YAML 2.3.10 as its direct runtime roots;
- stable human operations cover initialization, doctor, producer validation,
  estimation/history, products, app, artifact, and local Connect realization;
- generated source data, DuckDB history, products, artifacts, and deployment
  repositories are ignored, reproducible outputs rather than source-release
  content;
- one installation selects one exact trusted canonical producer for one health
  system;
- Phase 10 independently proves that another source shape can satisfy the same
  seam, but does not establish production packaging of that private code;
- a target-neutral reduced artifact precedes target realization;
- the Connect realization creates a staged, uncommitted, remote-free local Git
  repository and intentionally stops before external mutation;
- diagnostics are privacy-conscious and non-retained by default;
- no release, upgrade, CI, support, security-reporting, or public contribution
  policy currently exists; and
- `LICENSE-STATUS.md` explicitly grants no permission and blocks public release
  until a final license is selected and installed.

The direct installed dependency inventory is small but not license-uniform:
YAML is BSD-3-Clause, DBI is LGPL-2.1-or-later, DuckDB and renv are MIT, Shiny
is GPL-3, and build-only rsconnect is GPL-2. A final legal/license inventory
must distinguish calling or restoring dependencies from copying, modifying, or
redistributing their content. No conclusion about derivative-work status is
made here.

The current repository has been developed and validated on macOS with R 4.4.1.
That is evidence of one environment, not a cross-platform support claim. As of
this assessment, the current R release is 4.6.1; a first release should not
silently convert the older lockfile evidence into a broad `R >= 4.1.0` support
promise.

## First-release objective

The first release should be the smallest supported distribution that realizes
the complete foundational architecture:

```text
obtain source → restore R environment → initialize / doctor
→ run fictional reference → validate an adopter producer
→ estimate and retain history → materialize products → run app
→ build reduced artifact → generate supported target realization
→ stop before operator-owned publication
```

It need not include richer UI, additional estimands/providers, intervention or
priority policy, executive measures, OCI realization, scheduling, persistent
observability, a website, rendered manuals, a plugin ecosystem, or an
enterprise installer. Those are not defects in a foundational `0.1.0` release.

## Urgency vocabulary

- **Required before initial release:** publication would be ambiguous,
  unauthorized, unsafe, or unreproducible without the decision.
- **Should resolve for initial release:** not a semantic blocker, but leaving it
  open would materially weaken usability or credibility.
- **May defer:** the first release can state a narrow limitation and revisit
  the choice later.
- **Should deliberately remain open:** selecting now would constrain future
  architecture without evidence.

## High-level decision matrix

| Decision area | Main options | Recommendation | Urgency | Confidence |
|---|---|---|---|---|
| Software/content license | Apache-2.0; MIT; GPL-3 family | Apache-2.0 after legal and dependency review; MIT is the strong alternative | Required before release | Medium-high |
| Ownership, stewardship, attribution, brand | Individual; CentralStatz entity; foundation/community | CentralStatz stewardship if rights are confirmed; factual contributor credit; separate trademark policy | Required before release | Medium |
| Authoritative distribution and GitHub | Clone only; archive only; tagged GitHub release; installer/package/container | Public GitHub repository plus immutable tagged source release; clone and attached archive as peers | Required before release | High |
| Platform release form | Whole source tree; full-platform R package; prebuilt container | Whole validated source tree; keep `rrpruntime` internal | Required before release | High |
| Platform version | `0.0.1`; `0.1.0`; `1.0.0` | `0.1.0`, tagged `v0.1.0` | Required before release | High |
| Component version relationship | One synchronized version; independent versions with release manifest | Preserve independent versions and publish an exact release inventory | Required before release | High |
| R and `renv` policy | Minimum-only; exact patch; supported minor line; container-only | Commit lockfile; restore with renv; support one tested current R minor line | Required before release | High |
| OS/test matrix | One developer machine; Linux only; macOS/Windows/Linux | Test all three on one R line before claiming support; narrow claims to evidence | Required before release | High |
| Adopter producer packaging | Core fork; private companion project; private package; local extension; plugin | Private companion project with explicit trusted composition; fork as documented fallback | Required before promising adopter replacement | Medium |
| Configuration/secrets | Commit in core; commit in private implementation; environment/secret store | Nonsecret private config with adopter code; secrets only in environment/deployment secret store | Required before release | High |
| Extension trust/loading | Explicit composition; package registration; local loading; discovery/plugins | Retain explicit maintained registration and exact selection | Required before release | High |
| Deployment target roles | Connect as production default; Connect reference target; OCI required now | Connect as reference/tutorial realization for appropriate data; OCI future peer | Should resolve for release | High |
| Generated deployment ownership | Platform publishes; platform generates/operator publishes | Preserve current operator-authorization boundary | Required before release | High |
| Contribution/governance | Informal issues; minimal policy set; large foundation model | Small explicit maintainer model, CONTRIBUTING, Code of Conduct, DCO-style sign-off | Should resolve for release | Medium-high |
| Security/support | Public issues only; private reporting; formal product support | SECURITY plus private reporting; best-effort community support and separate services | Required before release | High |
| Release integrity | Tag only; signed tag/checksum; SBOM/attestations | Signed tag, immutable release, attached archive, SHA-256, release inventory; defer bespoke SBOM | Should resolve for release | Medium-high |
| Documentation/citation | Existing docs only; release docs and CFF; rendered site | Add release/install/compatibility docs, changelog, and CITATION.cff; defer rendered site | Should resolve for release | High |
| Compatibility/migrations | No policy; early-version policy; migrations before first release | State narrow `0.x` guarantees; no migration tool until a second version needs one | Required before release | High |

## 1. Licensing, ownership, attribution, and brand

### Classification

Licensing and actual copyright ownership are **required before initial
release**. Documentation/asset license treatment and brand rules should be
resolved at the same time so release contents do not carry contradictory
permissions.

### Ranked software-license options

#### 1. Recommended — Apache License 2.0

Apache-2.0 permits use, modification, internal deployment, redistribution,
commercial use, and derivative works while requiring preservation of license
and notices. Its express contributor patent grant and patent-termination terms
are valuable for an implementation platform intended for institutional and
commercial participation. It does not require hospital mappings or internal
modifications to be published merely because they are used privately.

Advantages:

- permissive for hospitals, vendors, researchers, and CentralStatz services;
- explicit patent language is clearer than MIT for institutional adopters;
- contributor and NOTICE mechanics support long-lived attribution;
- compatible with an open core plus optional paid implementation/advisory work;
- does not require a proprietary contributor agreement to accept ordinary
  upstream contributions.

Disadvantages and cautions:

- longer and administratively heavier than MIT;
- NOTICE and third-party inventory must be maintained correctly;
- Apache documents one-way GPLv3 compatibility and warns about Apache works
  becoming derivatives of GPL software; Shiny is GPL-3 and rsconnect is GPL-2,
  so counsel should review the platform's dependency and distribution form;
- a license does not settle trademark, branding, copyright ownership, data,
  or third-party asset rights.

The 11.1 assessment expected a later implementation iteration to replace
`LICENSE-STATUS.md` with the approved license/notice arrangement, update
package metadata, and produce an asset/dependency inventory. Iteration 11.2 did
not install the license; final compatibility review still precedes that work.
The choice is difficult to revoke for already released versions, while future
versions can be relicensed only with all required rights-holder permissions.

#### 2. Strong alternative — MIT

MIT provides broad permission with minimal notice and warranty language. It is
easy for hospital legal teams to recognize, simple for a small maintainer to
administer, and broadly compatible with other licenses.

Its weakness for this project is the absence of an express patent grant and a
less explicit contribution/patent framework. If the maintainer optimizes for
the lowest governance burden and legal review favors simplicity, MIT is a
credible choice. It is not materially more open than Apache-2.0 for hospital
internal use or commercial services.

#### 3. Possible but weaker for this objective — GPL-3 family

GPL-3 is a valid open-source copyleft choice. Private hospital operation does
not itself require publication, while conveyance of modified covered works
triggers source and same-license obligations. It would better preserve freedom
of redistributed platform derivatives.

For this platform, those obligations may complicate hospital vendor
integrations, private companion code, and commercial distribution without
clear evidence that reciprocal redistribution is a primary product goal.
Choosing GPL should be an affirmative values decision, not an attempt to match
the license of one runtime dependency. AGPL is not recommended: the project
has not expressed a network-copyleft objective and it could materially impede
incremental institutional adoption.

### Software, documentation, assets, trademarks, and services are distinct

The recommended minimum is one Apache-2.0 policy for repository-authored code
and documentation, with exceptions recorded for third-party assets. A separate
CC BY 4.0 documentation license is possible but adds inventory and contributor
complexity without a demonstrated first-release benefit. Synthetic data and
generated outputs need an explicit statement of whether they are covered by
the repository license or separate terms.

The software license should not be used as a trademark policy. The maintainer
must decide who may use the project and CentralStatz names/logos to imply
endorsement or official distributions. Descriptive attribution and fork
identification should remain possible.

Open-source rights do not include support, warranty, clinical validation,
regulatory approval, or permission to use real data. CentralStatz may sell
implementation, advisory, hosting, validation, or support services without
changing the rights to the open-source release, provided operation of the open
core does not require those services.

### Ownership and contribution recommendation

If corporate/employment and prior-contributor rights support it, CentralStatz
should be the visible steward and release publisher, with named maintainers and
factual contributor attribution. The actual copyright holder must reflect real
legal ownership rather than branding preference.

Use inbound-equals-outbound contribution terms plus Developer Certificate of
Origin 1.1 sign-off for the initial release. Do not require copyright
assignment or a custom contributor license agreement absent a specific legal
need. DCO sign-off is a contributor certification, not itself a license or
cryptographic signature.

## 2. Acquisition, release form, and GitHub's role

### Classification

The authoritative release object and acquisition story are **required before
initial release**. GitHub's secondary community roles should be resolved at the
same time, but another documentation host may be added later.

### Ranked options

#### 1. Recommended — tagged whole-repository GitHub source release

Publish one immutable GitHub Release tied to a signed annotated `v0.1.0` tag.
Support two equivalent acquisition paths:

- download the maintainer-produced release source archive and verify its
  SHA-256 checksum; or
- clone the authoritative repository and check out the exact release tag.

The release archive serves adopters without Git history or Git expertise. The
clone serves maintainers, developers, and adopters who need controlled local
composition. Both resolve to the same maintained platform tree and
`renv.lock`.

GitHub should be the authoritative public source host, release host, issue and
pull-request workflow, security-advisory channel, and documentation entry
point. It is not a runtime host, deployment target, source system, or
operational-history service.

GitHub automatically offers tag archives, but their compressed bytes may be
regenerated with different compression settings. A separately attached release
archive plus checksum provides a byte-addressable release asset. The release
tag and manifest remain the logical authority.

#### 2. Strong alternative — exact tag clone plus GitHub-generated archives

This needs less release construction and still gives non-Git users an archive.
It is acceptable if release integrity is defined by tag/commit and extracted
contents rather than a stable archive checksum. It is weaker for hospitals
that expect a checksum-verifiable supplied package.

#### 3. Possible but weaker — clone only

Clone-only distribution matches development today but makes Git a user
prerequisite, complicates controlled transfers into restricted environments,
and conflicts with the operator manual's statement that Git is not a permanent
distribution contract.

#### 4. Not recommended for the first release — installer, full-platform R
package, or prebuilt container as the canonical object

The platform contains shell-facing operations, YAML contracts, an internal R
package, adapters, application code, and deployment builders. Turning the
whole platform into one R package would obscure those boundaries and make CRAN-
style installation semantics the architecture. An installer would add OS,
network, privilege, and upgrade behavior without evidence. A container is a
future target realization, not the authoritative editable source distribution.

`rrpruntime` being an internal package is sufficient. It may eventually be
published separately only if external consumers need it; such publication
must not replace the platform release.

### Initial release promise

The release should promise that an operator can obtain the exact source tree,
install a supported R version, restore declared R packages, run doctor, and
complete the fictional reference workflow. It should not promise unattended
installation, offline package availability, administrator-free setup, or a
production hospital environment.

## 3. Platform and component versioning

### Classification

Release numbering and the relationship among platform/component versions are
**required before initial release**.

### Ranked platform-version options

#### 1. Recommended — `0.1.0`

`0.1.0` communicates a coherent first public platform with an intentional API
surface while preserving room for evidence-led incompatible changes. It aligns
with Semantic Versioning's major-zero development meaning and with the
repository's existing pre-1.0 contract rules.

Use tag `v0.1.0`; use `0.1.0` inside release metadata. Release contents must
never be silently changed after publication.

#### 2. Possible but weaker — `1.0.0`

The foundational architecture is substantial, but external adopter packaging,
cross-platform support, upgrades, and real independent adoption are not yet
proven. `1.0.0` would overstate public compatibility stability.

#### 3. Not recommended — `0.0.1`

This suggests an exploratory snapshot rather than the completed Phase 0–10
vertical platform and would undercut the deliberate hard release cutoff.

### Independent component versions

Do not synchronize all logical identities to the platform release. The
platform release manifest should enumerate the exact included versions of:

- `rrpruntime`;
- canonical, runtime, provider, persistence, product, observability, artifact,
  and deployment contracts;
- shipped producer, provider, persistence, product materializer, app, artifact
  builder, and Connect realization; and
- the `renv.lock` digest and tested environment.

A platform patch may include a component patch, or no component change. A
contract minor may require a platform minor even when other components remain
unchanged. Keeping identities independent preserves provenance and allows
conformance to express compatibility accurately.

During `0.x`, promise compatibility only within a platform minor line:

- patch releases contain compatible fixes or documentation/validation
  clarification;
- minor releases may contain breaking changes, but must identify them,
  affected component versions, and required adopter action;
- deprecate before removal where practical, without pretending all pre-1.0
  interfaces are stable; and
- retain release tags and release notes so historical operational state remains
  attributable.

`1.0.0` should require evidence from at least one genuinely external adopter
composition, a stable supported acquisition/environment path, a demonstrated
upgrade between public releases, and maintainer confidence in the public
operation and extension surfaces.

## 4. R environment and supported/tested systems

### Classification

The R version policy and credible test matrix are **required before initial
release**. A container is **not required**.

### `renv` recommendation

Include `.Rprofile`, `renv/activate.R`, `renv/settings.json`, and `renv.lock` in
the source release. `renv::restore()` should be the supported construction of
the project R library. Restore uses the lockfile's exact package records and
repository sources; it does not install R itself or guarantee the operating
system, compiler, system libraries, network access, or future availability of
every package source.

Do not require an exact R patch version as a permanent platform semantic.
Recommend one supported R minor line and validate the release against a named
patch. At the 11.1 checkpoint, the best candidate was R 4.6.x, validated at the
then-current patch (4.6.1 at assessment time). The actual release iteration
must test and, if accepted, deliberately refresh the existing R 4.4.1 lock
rather than merely editing its version field.

An adopter who already has R may use it only if it falls within the supported
line. Project initialization must continue to avoid modifying system libraries;
renv owns the project library. Restricted hospitals may substitute an approved
internal CRAN-compatible repository or package cache, but the first release
need not build one.

Document system prerequisites separately: R installation, Git only for
clone/Connect generation, compiler toolchains when binaries are unavailable,
and package system libraries. `renv` documentation explicitly states that R,
operating system, compiler, and system libraries are outside its guarantee.

### Minimum credible matrix

Before making a cross-platform support claim, run clean automated validation on:

| Environment | Release claim after evidence |
|---|---|
| Ubuntu current LTS, R 4.6.x | Officially tested and supported reference server/development environment |
| Windows current supported runner, R 4.6.x | Officially tested and supported local development/operator environment |
| macOS current supported runner, R 4.6.x | Officially tested and supported local development/operator environment |

One R line across three operating systems is a reasonable small-project matrix.
CI is necessary to keep that claim credible. Additional R lines, Linux
distributions, architectures, and patched/development R are useful later but
not initial blockers.

Until this matrix passes, documentation must say only:

- **developed and validated on:** macOS, R 4.4.1;
- **expected to work on:** systems compatible with current R/package
  dependencies; and
- **officially supported:** none beyond the exact demonstrated environment.

If maintaining three runners is not feasible, the honest alternative is to
support Ubuntu only and label Windows/macOS expected. Broad untested claims are
not acceptable. A container could later strengthen Linux runtime
reproducibility but should not replace source-level cross-platform tests.

## 5. Adopter-owned producer packaging

### Classification

A supported physical composition model is **required before the release claims
that adopters can replace the source producer**. Phase 10 proves semantic
compatibility, not turnkey packaging.

### Option comparison

| Rank and option | Onboarding and operations | Privacy/reproducibility | Upgrade and maintenance | Trust/security | Reversibility |
|---|---|---|---|---|---|
| **1. Private companion implementation project** | Moderate initial setup; clear separation | Private mappings/config stay out of public core; exact core tag can be pinned | Clean upstream updates and independent local history | Explicit maintained composition imports/registers known code; no discovery | High; can later package the same callable |
| **2. Controlled hospital fork of core** | Lowest immediate engineering work | Private code can remain in a private fork, but public/private history mix is easy to mishandle | Repeated upstream merges and drift become hospital responsibility | Existing explicit composition works directly | Medium; extraction to companion project is possible but manual |
| **3. Private R package** | Familiar to mature R teams; package repository may be needed | Strong code/version boundary; secrets still external | Good independent versioning and testability | Package installation and explicit registration are auditable | High, but premature for one implementation |
| **4. Supported ignored local extension directory** | Easy locally | Weak transfer, backup, provenance, and reproducibility unless separately versioned | Local files can be lost or drift from core | Explicit sourcing can be safe, but path handling becomes public behavior | Medium |
| **5. Automatic plugin mechanism** | Appears convenient | Discovery and dependency state become implicit | New compatibility and lifecycle framework required | Largest code-execution and supply-chain surface | Low once ecosystem depends on it |

### Recommended initial model

Support a private companion implementation repository/project as the preferred
production shape. It should own:

- producer declaration and callable;
- source schema, validation, mapping, and conformance fixtures;
- nonsecret producer and installation configuration;
- an explicit maintained composition file that registers exactly one producer;
- its own version/release history and exact supported platform-release range;
- hospital-specific development and approval evidence; and
- references to environment-owned secrets, never secret values.

The companion should pin an exact platform tag/archive rather than track
`main`. The core should expose only the smallest explicit composition entry
needed to receive the known declaration/callable/selection. Ordinary YAML must
remain non-executable. One composed installation still represents one health
system and one selected producer.

This recommendation was medium confidence because Iteration 10.2 proved a
separately owned tree inside tests, not a physically separate repository.
Iteration 11.2 selected the refined managed-kit architecture; Iteration 11.3
must validate a temporary external-tree composition before the model becomes
supported. If that narrow proof exposes disproportionate complexity, a
controlled private fork remains the strongest fallback and must be documented
with an upstream-merge/conformance procedure.

A private R package is a good later evolution when multiple installations,
release reuse, or internal package repositories justify it. A package should
register through trusted composition; package installation must never make it
automatically active. Do not create a plugin framework or commit a fixture-copy
scaffold in the first release.

## 6. Configuration, secrets, and trusted loading

### Classification

The minimum safe boundary is **required before initial release**. A universal
secret manager should **deliberately remain open**.

### Recommended boundary

| Material | Owner and location | Source-control policy |
|---|---|---|
| Public contracts/reference defaults | Core platform release | Public and committed |
| Adopter source schema/mapping/declaration | Private companion or controlled private fork | Private version control |
| Nonsecret producer configuration | Private implementation project or deployment configuration | Private version control where appropriate |
| Installation selection | One installation's controlled configuration | Private or public only when non-sensitive |
| Database/API credentials, tokens, certificates, connection strings | Process environment or deployment-approved secret store | Never committed |
| Developer-only local secret values | Approved ignored environment file only when local policy permits | Ignored, access-controlled, never emitted |

The platform should document required environment variable names or an
injected secret-resolution boundary, not a general enterprise vault. A
deployment may map its secret store into environment variables. Diagnostics,
producer results, canonical bundles, history, products, artifacts, and release
metadata must not contain values or connection strings.

### Loading recommendation

Retain explicit maintained registration as the initial trust model:

```text
maintained installation composition
    → loads one known local file or installed private package
    → registers exact declaration + callable
    → selects exact ID/version from ordinary configuration
```

Package-based or local-file composition are physical variants of the same trust
model. Automatic directory scanning, entry-point discovery, package names from
YAML, remote loading, and `eval(parse())` remain unsupported. This is less
magical, easier to audit, and consistent with provider and producer boundaries.

## 7. Deployment realizations and ownership

### Classification

The platform/operator ownership boundary is **required before initial release**.
Connect and OCI positioning **should be explicit**, while implementing OCI may
defer.

### Connect Cloud role

Position `platform.connect-cloud-git-realization@0.1.0` as:

> the implemented reference/tutorial deployment realization for the shipped
> fictional application and for other content an adopter has independently
> determined appropriate for that service.

It may be the easiest documented tutorial deployment, but it is not the
universal default, a recommended production hospital host, or evidence of PHI,
HIPAA, security, clinical, or organizational approval. Posit's current process
uses a GitHub repository, branch, primary file, and `manifest.json`; sharing and
automatic republish are service-side choices. Those facts do not authorize the
platform to publish or determine data suitability.

### Future OCI role

The current target-neutral architecture is sound:

```text
validated reduced application artifact
        ├── Connect Cloud Git realization
        └── future OCI-compatible image/context realization
```

Use **OCI-compatible realization** as the architectural term; Docker may be one
builder/runtime. OCI defines interoperable image, runtime, and distribution
specifications without binding the platform to one vendor. A future
realization would package R, system libraries, exact application dependencies,
runtime user/filesystem/network defaults, health checks, and image provenance
for health-system-controlled infrastructure.

OCI is not required for `0.1.0`. It becomes compelling when a real adopter
needs controlled Linux runtime packaging, private registries, infrastructure
policy, or repeatable deployment beyond Connect Cloud. Implementing it now
would add image security, patching, registry, architecture, and base-image
decisions without an adopter requirement.

### Generated-output ownership

Preserve the Phase 8 rule for every target:

- platform: validate upstream artifact, generate local target output, record
  identities/inventory, validate independently, and stop;
- operator/deployment: choose destination, review content, supply credentials,
  commit/tag if relevant, create remotes/registries, push, publish, configure
  access/networking/secrets/retention, and authorize use.

Future container support may generate a build context or image locally, but
registry login/push and deployment mutation remain externally authorized.
This boundary is reversible at a future operation level, but broadening it
would require an explicit security and authorization design.

## 8. Contribution governance and stewardship

### Classification

Clear contribution terms and maintainership **should resolve for initial
release**. A large governance structure may defer.

### Ranked options

1. **Recommended:** a small named maintainer model with `CONTRIBUTING.md`,
   `CODE_OF_CONDUCT.md`, a short governance/maintainer statement, pull-request
   guidance, and DCO 1.1 sign-off.
2. **Strong alternative:** inbound-equals-outbound contributions without DCO,
   accepted through reviewed pull requests. This is lower friction but records
   less explicit rights provenance.
3. **Possible later:** a CLA or foundation governance model, justified only by
   institutional contributors, relicensing needs, or distributed authority.
4. **Not recommended:** undocumented issue/PR acceptance controlled by hidden
   maintainer practice.

The contribution guide should point to architecture authority, human-readable
implementation conventions, exact validation, fictional/PHI rules, contract
versioning, and the prohibition on source-specific generic branches. It should
explain that acceptance is discretionary and that no contribution creates a
support obligation.

Adopt a standard Code of Conduct only if the maintainer names a confidential
reporting contact and is willing to enforce it. Issue and pull-request templates
are useful before release, especially for bug reports that request versions and
safe reproduction without patient data. Extensive committees, voting rules,
working groups, and a contributor ladder can wait for actual participation.

## 9. Security disclosure and support

### Classification

A public security channel, scope, and supported-version statement are
**required before initial release**. The support promise is also a maintainer
capacity decision.

### Security recommendation

Add `SECURITY.md` and enable GitHub private vulnerability reporting. State:

- which platform release lines currently receive security fixes;
- how to report privately and what safe information to include;
- never to attach PHI, secrets, private mappings, or production extracts;
- coordinated disclosure expectations without promising a fixed SLA;
- scope covering platform code, release/distribution behavior, and unsafe
  diagnostics or artifact leakage;
- dependencies and deployments may require upstream/vendor coordination;
- operators own infrastructure hardening, access controls, network/security
  configuration, secret management, monitoring, incident response, backups,
  and local approval; and
- the project makes no HIPAA, regulatory, clinical-safety, or production-
  authorization claim.

Public issues are not a vulnerability channel. GitHub private reporting and
repository security advisories provide a small-maintainer workflow for private
report, fix, and later disclosure.

### Support recommendation

Ranked positions:

1. **Recommended:** community/best-effort issue support for the supported
   release plus clearly separate optional CentralStatz professional services.
2. **Strong alternative:** community-only support if no service offering is
   ready.
3. **Defer:** formal paid product support with response commitments.

`SUPPORT.md` should distinguish bug reports, usage questions, hospital
implementation assistance, clinical/model governance, infrastructure support,
and security reports. The open-source license grants software rights, not
warranty, implementation success, production support, or an SLA. Professional
services must remain optional and contractually separate from community rights.

## 10. Release integrity and source provenance

### Classification

An attributable, immutable release is **required**; the stronger checksum and
signing package **should resolve for initial release**. Bespoke attestations and
SBOM automation may defer.

### Recommended minimum

1. validate a clean release candidate from outside the maintainer's working
   library;
2. create a signed annotated `v0.1.0` tag on the reviewed commit;
3. create a draft GitHub Release with final release notes;
4. attach a maintainer-produced source archive, `SHA256SUMS`, and a small
   release manifest enumerating platform/component/contract versions, lockfile
   digest, tested R/OS matrix, and validation result;
5. publish as an immutable release if the repository setting is available;
6. retain the tag, release notes, checksums, and archive permanently.

GitHub's immutable-release feature locks the associated tag/assets and creates
a release attestation. That is useful low-burden integrity evidence. Signed
tags establish publisher identity. SHA-256 verifies attached bytes. None proves
the code is secure or clinically valid.

Do not conflate this source provenance with canonical mapping provenance,
analytical run identity, operational history, artifact checksums, or deployment
realization identity. MD5 inside current generated products/artifacts detects
accidental corruption only and is not the release-authenticity mechanism.

A generated SBOM and build attestations become valuable when the project ships
containers or additional built binaries, or when institutional procurement
requires them. They need not block a source-only `0.1.0` if the exact lockfile
and third-party license inventory are present.

## 11. Release documentation and citation

### Classification

Installation, release, compatibility, safety, and adopter-composition guidance
**should resolve for initial release**. A rendered site and long-form tutorials
may defer.

### Required release documentation set

- root README and START HERE with the release maturity and supported path;
- license, notices, ownership/stewardship, and third-party inventory;
- installation/acquisition guide covering archive and clone paths, checksum,
  supported R, `renv::restore()`, initialization, and doctor;
- existing operator manual and validation guide;
- progressive-adoption guide plus a production-oriented adopter producer
  packaging/composition guide;
- release/compatibility/upgrade policy;
- `CHANGELOG.md` and version-specific release notes;
- `SECURITY.md`, `SUPPORT.md`, `CONTRIBUTING.md`, Code of Conduct, and concise
  maintainer/governance statement;
- tested versus supported environment matrix and system prerequisites;
- deployment-positioning cautions for Connect and operator ownership; and
- `CITATION.cff` with factual title, authors/steward, version, release date,
  repository URL, and license after those values are approved.

GitHub surfaces a root `CITATION.cff` as a “Cite this repository” action and
can render common software citation forms. A DOI or archival repository is a
later option; do not invent one. A website, Quarto/Typst/PDF manuals, polished
hospital tutorial, engineering-principles explainer, and broader examples are
post-release enhancements unless usability testing shows a blocking gap.

## 12. Compatibility, upgrades, and migration

### Classification

A written early-release policy is **required before initial release**. Formal
migration machinery **may defer** because there is no earlier public release to
migrate.

### Recommended policy

- platform `0.x` patch releases preserve the public operation and contract
  behavior of that minor line;
- a platform minor release may break an interface only with explicit release
  notes, affected-version inventory, and a supported recovery or migration
  statement;
- independently versioned contracts continue to use their existing pre-1.0
  compatibility rules;
- adopter producers declare exact supported canonical producer/profile
  versions and rerun conformance against every platform upgrade;
- private companion implementations pin exact platform releases and upgrade
  deliberately;
- DuckDB operational history is backed up before upgrade and opened only by a
  release that explicitly supports its physical schema;
- products and reduced/deployment artifacts are rebuilt from authoritative
  valid history rather than migrated in place;
- generated Connect repositories are regenerated from a new valid artifact,
  never patched as release state; and
- prior source releases remain available to inspect or operate retained history
  when no forward migration exists.

The first release can honestly state that cross-release DuckDB migration has
not yet been needed or implemented. Before any future release changes a
physical history schema or retained record, it must provide tested migration,
side-by-side preservation, or an explicit incompatibility/retention procedure.
Do not build speculative migration commands in `0.1.0`.

## Recommended coherent end-to-end release model

The individual recommendations fit together as follows:

1. The maintainer confirms copyright, stewardship, branding, and an approved
   permissive license after reviewing all repository and dependency assets.
2. The entire source tree becomes the `0.1.0` platform release; logical
   component versions remain independent and are inventoried.
3. GitHub hosts the authoritative public source, signed tag, immutable release,
   archive/checksum, issues, contributions, and private security workflow.
4. Adopters download the verified archive or check out the exact tag.
5. They install the supported R line, restore `renv.lock`, initialize, run
   doctor, and complete the fictional reference workflow.
6. A real adopter keeps source mappings and configuration in a private
   companion implementation pinned to that platform release, with secrets in
   its approved environment/deployment store.
7. Trusted maintained composition explicitly registers exactly one producer;
   configuration selects its exact ID/version and cannot load code.
8. Existing human operations run estimation, preserve DuckDB history,
   materialize products, run the app, and build the reduced artifact.
9. The existing Connect target remains the convenient fictional/reference
   realization; operator authorization begins at commit/remote/push/deploy.
10. A future OCI target consumes the same validated reduced artifact without
    becoming the source release or altering upstream semantics.

This model preserves a small open core, one-health-system context, component
substitution, human operability, private adopter ownership, and deployment
choice without requiring centralized SaaS or CentralStatz services.

## Maintainer decisions requested by Iteration 11.1

The following choices were unresolved at the Iteration 11.1 checkpoint. The
resolution update near the start of this document and the later hospital-
distribution architecture now record the accepted direction; the original
questions are retained as decision provenance.

### Decision 1 — Copyright holder, steward, and brand owner

**Question**

Who has the rights to license the current work, who will publish and steward the
project, who are the initial maintainers, and which names/logos are protected?

**Recommended choice**

CentralStatz as visible steward/release publisher if actual rights permit;
factual contributor attribution; a concise separate trademark/branding policy.

**Why**

Users need an accountable source without making CentralStatz services a runtime
dependency. The repository cannot infer ownership from Git authorship or brand.

**Alternatives**

Individual ownership with CentralStatz sponsorship; shared contributor
ownership; later transfer to a foundation.

**What choosing this commits us to**

Accurate copyright notices, maintainer contacts, release authority, brand-use
rules, and contribution provenance.

**What remains reversible**

Stewardship and governance can evolve; already granted release rights cannot be
withdrawn from compliant recipients.

### Decision 2 — Repository-authored content license

**Question**

Which approved open-source license covers software and documentation, and are
any assets separately licensed?

**Recommended choice**

Apache-2.0 for repository-authored software and documentation after legal,
Shiny/rsconnect dependency, asset, and ownership review; record exceptions.

**Why**

It combines permissive institutional/commercial use with an express patent
grant and clearer long-lived notice terms.

**Alternatives**

MIT as the strongest low-burden alternative; GPL-3 only if reciprocal
redistribution is an affirmative project goal.

**What choosing this commits us to**

License/NOTICE installation, dependency and asset inventory, package metadata,
contribution terms, and compliance for every release.

**What remains reversible**

Future versions can change only with required rights-holder permission;
existing releases remain under their granted terms.

### Decision 3 — First platform version and compatibility promise

**Question**

Should the first supported platform be `0.1.0`, and what stability is promised
during `0.x`?

**Recommended choice**

Release `0.1.0`; patches compatible within a minor line; minors may break only
with explicit impact and migration/recovery notes; retain independent component
versions.

**Why**

It recognizes a coherent foundation without overstating adopter/upgrade
maturity.

**Alternatives**

`1.0.0` after stronger external evidence; `0.0.1` as a weaker experimental
signal.

**What choosing this commits us to**

Tag/release conventions, release inventory, changelog, and disciplined
compatibility statements.

**What remains reversible**

The path and criteria to `1.0.0`; component versions continue independently.

### Decision 4 — Authoritative acquisition and GitHub role

**Question**

Will GitHub host the authoritative public source and releases, and will clone
and a checksum-verifiable archive both be supported?

**Recommended choice**

Yes: signed immutable GitHub release with attached source archive/SHA-256 plus
exact-tag clone; GitHub also hosts issues, PRs, and private security reports.

**Why**

It supports restricted/non-Git acquisition and normal development without
inventing an installer or package registry.

**Alternatives**

Clone plus automatic archives; a non-GitHub release host if governance or
organizational policy requires it.

**What choosing this commits us to**

Repository administration, durable tags/releases, release-asset retention, and
a documented release checklist.

**What remains reversible**

Mirrors, archival DOI, website, installer, or additional registries may be
added later; GitHub remains distinct from runtime deployment.

### Decision 5 — Initial adopter implementation packaging

**Question**

Should production adopter code live in a core fork, private companion project,
private R package, or supported local directory?

**Recommended choice**

Private companion implementation project pinned to one exact platform release,
using a narrow explicit trusted composition entry; document a controlled fork
as fallback until the external proof passes.

**Why**

It best separates private mappings/secrets from public upstream and gives a
tractable upgrade/version history without dynamic plugins.

**Alternatives**

Controlled private core fork; private R package for mature R organizations.

**What choosing this commits us to**

A small composition interface, conformance operation against external-owned
code, configuration precedence, example layout, and upgrade documentation in
the later managed-composition implementation.

**What remains reversible**

The companion callable can later move into a package; the semantic producer
contract and one-instance rule remain unchanged.

### Decision 6 — Supported R/OS matrix and CI capacity

**Question**

Which R minor line and operating systems can the maintainer genuinely test and
support for the first release?

**Recommended choice**

R 4.6.x at the current patch across current Ubuntu LTS, Windows, and macOS,
with clean automated validation; support one R line only.

**Why**

It covers the main development/server contexts with a bounded small-project
matrix and avoids claiming the untested `R >= 4.1.0` range.

**Alternatives**

Ubuntu-only official support with Windows/macOS expected; retain R 4.4.x only
if current-package validation cannot pass and document its lifecycle risk.

**What choosing this commits us to**

CI maintenance, deliberate lockfile refresh, system-prerequisite docs, and
tested/supported wording for each release.

**What remains reversible**

Add R lines, OS versions, architectures, or container validation later.

### Decision 7 — Community, security, and support posture

**Question**

Who accepts contributions and security reports, which versions receive fixes,
and what help is actually promised?

**Recommended choice**

Named small maintainer model; DCO-based contributions; standard Code of
Conduct; GitHub private vulnerability reporting; best-effort community support;
optional CentralStatz professional services under separate terms; no SLA.

**Why**

It is credible for a small healthcare-adjacent open-source project and clearly
separates software rights from services, security coordination, and production
responsibility.

**Alternatives**

Community-only support; no DCO; formal paid support later.

**What choosing this commits us to**

Maintained contacts, moderation and vulnerability-response capacity, support
scope, governance files, and honest supported-version updates.

**What remains reversible**

Maintainer count, issue/discussion channels, professional offerings, response
targets, or later foundation governance.

## Decisions to deliberately defer

| Decision | Why premature | Evidence that should trigger it | Preserved option |
|---|---|---|---|
| Exact OCI builder/runtime/base image | No target implementation or hospital infrastructure requirement exists | A real approved deployment needs controlled Linux packaging/private registry | Reduced artifact is already target-neutral |
| Docker branding as architecture | Docker is one OCI ecosystem tool, not the logical target | An implementation selects Docker-specific workflows | OCI peer-target language avoids lock-in |
| Automatic plugin ecosystem | One trusted producer per installation is sufficient and safer | Multiple independently distributed extensions need a lifecycle/discovery contract | Explicit declarations/registries can underpin a later plugin design |
| Mandatory private R-package extensions | Only one test-owned adopter peer exists | Repeated implementations or internal R repositories show package value | Callable/declaration can move into a package unchanged |
| Full-platform R package/CRAN release | Platform responsibilities exceed one package | External consumers demand a package-only subset | `rrpruntime` remains a valid independently packageable component |
| General installer/bootstrap executable | No cross-platform install failure evidence or privilege model | User research shows restore/setup is the adoption bottleneck | Archive/clone plus documented restore remains inspectable |
| Multiple R release lines and broad Linux matrix | Small maintainer capacity and no demand | Adopters require older enterprise R/distributions | Current source/renv model is not tied to one OS forever |
| Formal paid support/SLA | No service capacity or contract terms are established | CentralStatz intentionally launches a support product | Best-effort/open-source boundary stays clear |
| CLA/copyright assignment/foundation transfer | No contributor scale, relicensing need, or distributed governance exists | Institutional contribution or governance complexity emerges | DCO/inbound-equals-outbound preserves provenance |
| Custom signing service, SBOM, and attestation pipeline | Source-only release has a small dependency set and no release CI yet | Binary/container artifacts or procurement requirements emerge | Signed immutable release and manifest provide a foundation |
| Formal cross-version migration framework | No prior public release requires migration | A proposed release changes history/contracts materially | Versioned records, backups, rebuildable products, and old releases preserve choices |
| Website and rendered documentation stack | Maintained Markdown already covers the full human path | Usability testing finds navigation/format a material barrier | Docs are renderer-neutral source |
| Multi-hospital installation or centralized SaaS | Contradicts current one-instance architecture | True North changes through explicit maintainer decision | Reusable deployment remains possible per health system |

## First-release readiness gaps

### Release blockers

1. **Human legal/ownership decision:** confirm copyright authority,
   stewardship, license, documentation/assets, third-party inventory, and brand.
2. **Release identity decision:** accept platform `0.1.0`, tagging convention,
   independent component inventory, and `0.x` compatibility policy.
3. **Adopter packaging decision and proof:** select the companion/fork model and
   validate one separately owned installation composition without weakening
   trusted registration.
4. **Supported environment evidence:** choose R/OS scope, refresh the lock
   deliberately if required, and pass clean validation on every claimed
   environment. CI is necessary for a multi-OS claim.
5. **Release/governance policy files:** license/notices, contribution,
   maintainership, conduct, security, support, compatibility, and changelog.
6. **Acquisition and release validation:** prove archive and exact-tag paths in
   a fresh directory/library through the supported fictional lifecycle.
7. **Release metadata/integrity:** release manifest, archive/checksum, exact
   component inventory, release notes, and publisher/tag procedure.

### Recommended before release

- `CITATION.cff` after identity/license/version are approved;
- concise issue and pull-request templates with safe-data reminders;
- system-dependency and restricted/internal-package-repository guidance;
- one complete adopter companion walkthrough using fictional data;
- explicit Connect reference-only positioning in release-facing docs; and
- a manual release checklist tested once before publication.

### Post-release enhancements

- OCI realization, private registry guidance, and image SBOM/attestations;
- richer adopter tutorials, rendered site/PDF, and additional examples;
- additional R/OS/architecture coverage;
- installer or optional client if evidence shows a need;
- package-based producer distribution if repeated implementations justify it;
- formal migration tooling when a real version transition needs it; and
- broader product, UI, provider, policy, or operational capabilities already
  identified in True North.

The absence of these enhancements does not prevent a complete foundational
platform release.

## Phase 11 sequence proposed by Iteration 11.1

This sequence was the 11.1 recommendation before maintainer decisions and the
managed hospital-distribution assessment. The current authoritative sequence
is in the [implementation plan](platform-implementation-plan.md).

### Iteration 11.1 — Distribution and release decision assessment

**Exit evidence:** this maintained assessment identifies decisions, ranked
options, recommendations, human choices, deferrals, release gaps, and external
evidence without adopting or implementing them.

### Iteration 11.2 — Accepted distribution and governance foundation

Begin only after the maintainer answers the required decisions.

**Scope:** install the chosen license/notices and ownership metadata; add
contribution/security/support/governance policies; establish platform version
and release manifest; implement and test the narrow approved adopter packaging
composition; define and validate the R/OS matrix; add CI only as required for
those claims; write acquisition, compatibility, release, and citation metadata.

**Exit evidence:** a release candidate can be assembled from maintained source;
both the shipped reference and approved external adopter composition pass; all
support/security/license statements are present; no release is yet published.

### Iteration 11.3 — Release-candidate validation and first packaged version

**Scope:** exercise clone and archive acquisition in clean environments; restore
dependencies; run the supported lifecycle and claimed OS matrix; verify
inventory/licenses/checksum/tag/release notes; perform final privacy, generated-
state, sibling-independence, and documentation review; then present the exact
release candidate for explicit maintainer authorization.

**Exit evidence:** after human authorization, the signed immutable `v0.1.0`
source release is published with its archive/checksum/manifest and no
deployment. That deliberate hard cutoff completes Phase 11. If publication is
not authorized, the validated candidate remains unpublished and Phase 11
remains in progress.

## External sources consulted

All sources below were accessed on 2026-08-20. Primary or official project
documentation was preferred. Project architecture remains controlling where a
generic practice conflicts with implemented boundaries.

| Source | Decision informed |
|---|---|
| [Open Source Initiative: MIT License](https://opensource.org/license/MIT) | MIT permissions, notice obligation, warranty disclaimer |
| [Apache Software Foundation: Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.html) | Copyright/patent grants, notices, patent termination |
| [Apache Software Foundation: GPL compatibility](https://www.apache.org/licenses/GPL-compatibility.html) | One-way Apache-2.0/GPLv3 compatibility caution |
| [GNU Project: GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) | Copyleft, private use, conveyance, source obligations |
| [Open Source Initiative: Open Source Definition](https://opensource.org/osd) | Commercial/field-of-endeavor neutrality of authentic open source |
| [Semantic Versioning 2.0.0](https://semver.org/) | `0.x`, `1.0.0`, immutable released versions, tag convention |
| [GitHub: About releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases) | Tag-backed releases and automatic source archives |
| [GitHub: Downloading source archives](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives) | Archive content/compression stability and exact-commit guidance |
| [GitHub: Immutable releases](https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases) | Tag/asset immutability and automatic release attestation |
| [GitHub: Commit signature verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification) | Signed tag/commit publisher verification |
| [GitHub: Security policy](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/configure-vulnerability-reporting/add-security-policy) | `SECURITY.md` contents and reporting guidance |
| [GitHub: Private vulnerability reporting](https://docs.github.com/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability/) | Private reporter-to-maintainer workflow |
| [GitHub: Contribution guidelines](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/setting-guidelines-for-repository-contributors) | Discoverable `CONTRIBUTING.md` and issue/PR guidance |
| [GitHub: Code of Conduct guidance](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/adding-a-code-of-conduct-to-your-project) | Conduct policy and maintainer enforcement obligation |
| [Linux Foundation: DCO guidance](https://bestpractices.linuxfoundation.org/ip/contribution-mechanisms-dco.html) | DCO purpose and distinction from a license/contract |
| [GitHub: Citation files](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-citation-files) | Root `CITATION.cff` discovery and software citation rendering |
| [renv: restore](https://rstudio.github.io/renv/reference/restore.html) | Lockfile-driven project-library restoration |
| [renv: introduction and caveats](https://rstudio.github.io/renv/articles/renv.html) | R/OS/compiler/system-library limits of renv reproducibility |
| [renv: package installation](https://rstudio.github.io/renv/articles/package-install.html) | Binary/source installation and system dependency implications |
| [R Project](https://www.r-project.org/) | Current R release (4.6.1 at assessment date) and supported platforms |
| [Posit Connect Cloud: deploy Shiny with R](https://docs.posit.co/connect-cloud/how-to/r/shiny-r.html) | `manifest.json` role for R/Shiny content |
| [Posit Connect Cloud: new publish](https://docs.posit.co/connect-cloud/user/publish/01-new.html) | GitHub repository/branch/file selection, sharing, and republish controls |
| [Open Container Initiative](https://opencontainers.org/) | Vendor-neutral image/runtime/distribution architecture |

## Open questions at the Iteration 11.1 checkpoint

These questions record what remained unanswered when the assessment was
written. Most are resolved by the Iteration 11.2 update; exact environment
evidence, final license review, and implementation details remain open.

1. Who legally owns the existing work and will serve as initial release
   publisher, security contact, conduct contact, and maintainer?
2. Does legal review accept Apache-2.0 for the repository's actual dependency
   and asset composition, or prefer MIT/GPL?
3. Should repository-authored documentation use the software license or a
   separate content license?
4. Which names/logos require a trademark or official-distribution policy?
5. Can the maintainer sustain three-OS CI and best-effort issue/security
   response, or should the support claim be narrower?
6. Is a private companion implementation repository operationally acceptable
   to the first intended hospital adopter, and how may it acquire/pin the core
   within local security policy?
7. Does the maintainer want DCO sign-off for the first contribution workflow?
8. Is immutable GitHub Release functionality available for the intended public
   repository and organization plan?

Until those are answered, `LICENSE-STATUS.md` remains authoritative and public
release remains unauthorized.
