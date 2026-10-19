# Post-Stage-11 Manual Platform Assessment

**Status:** Human-operated, non-authoritative assessment guide — not yet
executed

**Accepted Stage 11 implementation:**
`8bb1a3798b92f5407b0772d60f067fc182f45fb3`

**Post-Stage-11 documentation baseline when authored:**
`383607c`

## A. Purpose and starting assumptions

This guide asks a platform maintainer to experience the accepted installed RRP
operator path from a clean local workspace. It repeats the central analytical
exercise in the
[Pre-Stage-11 Manual Platform Assessment](pre-stage-11-manual-platform-assessment.md),
but replaces manual package builds, package installation order, resource
projection, explicit software contexts, and direct R calls with the Stage 11
development distribution, installer, stable `rrp` launcher, and canonical CLI.

The assessment answers one practical question: can a human comfortably move
from a source-built development distribution to an installed fictional
hospital project, two governed analytical runs, two product realizations, and
two browser inspections using supported installed interfaces?

This document is not a governing architecture document, implementation plan,
formal acceptance record, automated test, hospital template, deployment guide,
or production-readiness assessment. It does not repeat automated Stage 11
acceptance or establish clinical validity. Do not use real patient data,
credentials, private hospital mappings, or a real model.

Stage 11 is formally accepted and complete. Stage 12 has not begun. The exact
accepted software implementation is the revision above; later commits through
the authoring baseline record documentation/assessment closeout and closed-
inventory registration without changing that software. Public Stage 14
acquisition does not yet exist, so this exercise uses the source repository
only to build one local development distribution. After that distribution is
copied and unpacked, all operation goes through its verifier, installer, and
installed `rrp` command.

### Prerequisites

- macOS within the demonstrated R 4.4.x development evidence boundary;
- one clean checkout containing the accepted Stage 11 implementation;
- Git, `tar`, normal R package compilation support, and either `shasum` or
  `sha256sum`;
- network access to one credential-free HTTPS R package repository; and
- enough local time for build-environment dependency provisioning followed by
  version-private installed-runtime restoration.

The commands below use `https://cloud.r-project.org`, the canonical repository
accepted by the distribution provenance checks. Keep one terminal open for the
whole walkthrough so its shell variables remain defined. Commands quote every
path; do not remove that quoting.

Record usability observations as you go:

- Was the command obvious?
- Was its output understandable and was the next step clear?
- Did the CLI expose the identity needed by the next command?
- Was installed guidance sufficient?
- Did an error offer actionable recovery?
- Did any step unexpectedly require internal implementation knowledge?

## B. Create the assessment workspace

Start in the repository root and confirm a clean post-Stage-11 line. A later
documentation-only commit may make `HEAD` newer than the authoring baseline;
the ancestry check establishes that the accepted software is present.

```sh
git rev-parse HEAD
git status --short --branch
git merge-base --is-ancestor 8bb1a3798b92f5407b0772d60f067fc182f45fb3 HEAD
R --version
```

`git status --short` should be empty, the ancestry command should exit zero,
and R should be 4.4.x. Record the actual clean source revision in your notes.

Create one disposable root outside the checkout. These variables distinguish
the development repository, build environment, copied distribution, installed
software, stable executable, and hospital-owned project.

```sh
export RRP_SOURCE_ROOT="$(pwd -P)"
export RRP_ASSESSMENT_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/rrp-post-stage-11.XXXXXX")"
export RRP_BUILD_ROOT="$RRP_ASSESSMENT_ROOT/build"
export RRP_BUILD_LIBRARY="$RRP_BUILD_ROOT/library"
export RRP_DEPENDENCY_PROVENANCE="$RRP_BUILD_ROOT/dependency-provenance.dcf"
export RRP_BUILD_ARCHIVE="$RRP_BUILD_ROOT/rrp-1.0.0-dev.tar"
export RRP_ACQUISITION_ROOT="$RRP_ASSESSMENT_ROOT/acquired"
export RRP_ACQUIRED_ARCHIVE="$RRP_ACQUISITION_ROOT/rrp-1.0.0-dev.tar"
export RRP_UNPACK_ROOT="$RRP_ASSESSMENT_ROOT/unpacked"
export RRP_DISTRIBUTION_ROOT="$RRP_UNPACK_ROOT/rrp-1.0.0-dev"
export RRP_INSTALLATION_ROOT="$RRP_ASSESSMENT_ROOT/installed-software"
export RRP_EXECUTABLE_ROOT="$RRP_ASSESSMENT_ROOT/bin"
export RRP_PROJECT_ROOT="$RRP_ASSESSMENT_ROOT/fictional-hospital"
export RRP_CRAN_REPOSITORY="https://cloud.r-project.org"
export RRP_FIRST_TIME="2026-01-19T12:00:00Z"
export RRP_SECOND_TIME="2026-01-20T12:00:00Z"
export RRP_TARGET_ID="rrp.risk-target.readmission-remaining-30-day"
export RRP_APP_PORT="45811"

mkdir -p "$RRP_BUILD_LIBRARY" "$RRP_ACQUISITION_ROOT" "$RRP_UNPACK_ROOT"
printf 'Assessment root: %s\n' "$RRP_ASSESSMENT_ROOT"
test ! -e "$RRP_INSTALLATION_ROOT"
test ! -e "$RRP_EXECUTABLE_ROOT"
test ! -e "$RRP_PROJECT_ROOT"
```

### What you should observe

- Every assessment-owned path is beneath the printed temporary root.
- The installation, executable, and project roots do not exist yet.
- Nothing uses or alters the normal user R library or normal RRP installation.
- The source repository will be a build input only.

## C. Maintainer-only development distribution preparation

Public acquisition is not available until Stage 14, so a maintainer must first
build the development distribution used by this assessment. This is the only
repository-facing preparation; it is not the normal installed operator
experience. The distribution builder needs the tested external dependency
closure and `renv` as maintainer build inputs. The following exact preparation
requires the new isolated library to be empty, resolves the complete strong
dependency closure from the configured repository, installs every exact member
there, and writes the controlled provenance receipt expected by the builder.
Packages installed elsewhere on the machine are not accepted as members of
that closure. This does not manually install either RRP package and is not part
of a hospital project.

```sh
Rscript --vanilla - \
  "$RRP_SOURCE_ROOT" \
  "$RRP_BUILD_LIBRARY" \
  "$RRP_CRAN_REPOSITORY" \
  "$RRP_DEPENDENCY_PROVENANCE" <<'RRP_BUILD_DEPS'
args <- commandArgs(trailingOnly = TRUE)
source_root <- normalizePath(args[[1L]], winslash = "/", mustWork = TRUE)
library_root <- normalizePath(args[[2L]], winslash = "/", mustWork = TRUE)
repository <- args[[3L]]
receipt <- args[[4L]]
if (length(list.files(library_root, all.files = TRUE, no.. = TRUE))) {
  stop("The controlled build library must be empty.")
}
.libPaths(c(library_root, .Library), include.site = FALSE)
Sys.setenv(
  RENV_CONFIG_CACHE_ENABLED = "FALSE",
  RENV_CONFIG_AUTOLOADER_ENABLED = "FALSE",
  RENV_PATHS_LIBRARY_STAGING = file.path(dirname(library_root), "renv-staging")
)
source(file.path(source_root, "tools", "distribution-lib.R"), local = TRUE)

# Bootstrap only the restoration engine, then give it an explicit complete
# repository-derived package/version set. This prevents ambient libraries from
# satisfying transitive dependencies implicitly.
install.packages(
  "renv", lib = library_root, repos = repository, dependencies = FALSE
)
package_type <- getOption("pkgType")
if (identical(package_type, "both")) package_type <- "binary"
available <- available.packages(repos = repository, type = package_type)
direct <- distribution_direct_dependencies(source_root)
missing_direct <- setdiff(direct, rownames(available))
if (length(missing_direct)) {
  stop("Configured repository lacks: ", paste(missing_direct, collapse = ", "))
}
graph <- tools::package_dependencies(
  direct,
  db = available,
  which = c("Depends", "Imports", "LinkingTo"),
  recursive = TRUE
)
closure <- sort(
  intersect(
    unique(c(direct, unlist(graph, use.names = FALSE))),
    rownames(available)
  ),
  method = "radix"
)
specifications <- paste0(closure, "@", available[closure, "Version"])
renv::install(
  specifications,
  library = library_root,
  repos = c(CRAN = repository),
  prompt = FALSE,
  rebuild = TRUE,
  dependencies = FALSE,
  lock = FALSE
)
distribution_write_dependency_provenance(
  source_root, library_root, repository, receipt
)
cat("Build dependency provenance:", receipt, "\n")
RRP_BUILD_DEPS
```

The explicit closure is the important boundary. A plain direct-dependency
installation can treat packages already visible in another user, site, or
system library as satisfied and therefore leave the controlled library
incomplete. `renv` staging and caching are kept outside that library so its
final top-level package set remains exactly the tested runtime closure plus
`renv`, as required by the provenance writer.

Build one closed archive at an absent destination:

```sh
cd "$RRP_SOURCE_ROOT"
R_LIBS_USER="$RRP_BUILD_LIBRARY" \
R_LIBS_SITE= \
RRP_CRAN_REPOSITORY="$RRP_CRAN_REPOSITORY" \
RRP_DEPENDENCY_PROVENANCE="$RRP_DEPENDENCY_PROVENANCE" \
  Rscript --vanilla tools/build-distribution.R "$RRP_BUILD_ARCHIVE"
```

The builder must finish with `PASS distribution build`, an output path, and a
distribution identity. Copy those finished bytes to the independent
acquisition area, then unpack the copy rather than the builder's working
output:

```sh
cp "$RRP_BUILD_ARCHIVE" "$RRP_ACQUIRED_ARCHIVE"
tar -xf "$RRP_ACQUIRED_ARCHIVE" -C "$RRP_UNPACK_ROOT"
test -d "$RRP_DISTRIBUTION_ROOT"
find "$RRP_DISTRIBUTION_ROOT" -maxdepth 2 -type f -print | LC_ALL=C sort
```

### What you should observe

- The archive contains one `rrp-1.0.0-dev/` payload, not the repository tree.
- It includes package archives, projected resources and documentation,
  dependency specification, manifest, inventory, installer, launchers, legal
  material, and standalone verifier.
- It contains no Git metadata, hospital project, patient data, project state,
  deployment artifact, or bundled transitive dependency archive.
- This is the only section that reads repository implementation files.

Record whether the distinction between maintainer build prerequisites and the
later user installation experience was understandable.

## D. Normal installed operator experience: verify and install RRP

Move into the copied distribution and verify its exact closed payload before
installation:

```sh
cd "$RRP_DISTRIBUTION_ROOT"
Rscript --vanilla verify-distribution.R .
```

Expected final output is `PASS distribution` followed by its exact distribution
identity. The verifier does not install, repair, or fetch anything.

Install into the assessment-specific roots with the same R used to build the
target and the repository recorded by the dependency specification:

```sh
Rscript --vanilla install.R \
  --repository "$RRP_CRAN_REPOSITORY" \
  --installation-root "$RRP_INSTALLATION_ROOT" \
  --executable-root "$RRP_EXECUTABLE_ROOT"
```

Installation may download or compile the exact specified dependency versions.
It should finish with `PASS installation`, the immutable installation path,
the stable launcher path, and `Reused: no`. It verifies the copied distribution
again, restores a version-private library, installs both exact internal package
archives, validates the staged realization in fresh vanilla R processes, and
promotes only after those checks succeed. It neither creates nor activates a
project.

Make this assessment's stable launcher the `rrp` resolved by the current
terminal, then verify that it takes precedence over any other installation:

```sh
export PATH="$RRP_EXECUTABLE_ROOT:$PATH"
command -v rrp
test -x "$RRP_EXECUTABLE_ROOT/rrp"
test "$(command -v rrp)" = "$RRP_EXECUTABLE_ROOT/rrp"
```

This changes `PATH` only in the current terminal session. It does not edit a
shell startup file, global path, system symlink, or another RRP installation.
From this point onward, the walkthrough uses the normal installed `rrp`
interface; the explicit check above proves that every such command reaches the
disposable assessment installation even if another `rrp` exists elsewhere.

### What you should observe

- `installed-software/installations/` contains one immutable realization.
- `bin/rrp` is the stable assessment-specific launcher.
- `command -v rrp` resolves exactly to that launcher.
- No RRP package was manually installed into the normal user library.
- The project path still does not exist.
- A restoration or verification failure would leave no promoted partial
  realization.

Record whether installation output made dependency restoration, verification,
and the lack of automatic activation clear.

## E. Activate and inspect installed software

Construct the exact selector from the verified distribution manifest. This
avoids guessing an identity or requiring an additional JSON tool.

```sh
export RRP_PRODUCT_VERSION="$(awk -F ': ' '$1 == "Product-Version" { print $2 }' "$RRP_DISTRIBUTION_ROOT/manifest.dcf")"
export RRP_DISTRIBUTION_ID="$(awk -F ': ' '$1 == "Distribution-ID" { print $2 }' "$RRP_DISTRIBUTION_ROOT/manifest.dcf")"
export RRP_SELECTOR="$RRP_PRODUCT_VERSION/$RRP_DISTRIBUTION_ID"

printf 'Selector: %s\n' "$RRP_SELECTOR"
rrp software list
rrp software verify --software "$RRP_SELECTOR"
rrp software doctor --software "$RRP_SELECTOR"
rrp software activate "$RRP_SELECTOR"
rrp software current
rrp software verify
rrp software doctor
rrp version
```

`verify` is strict integrity verification of one installed realization.
`software doctor` reports bounded software readiness and recovery without
opening a project. Activation changes only the installation root's active
selection. Later `project validate` and `project doctor` instead inspect one
explicit hospital project under the selected software.

### What you should observe

- Listing shows one verified but initially inactive realization.
- Exact-selector verify and doctor work before activation.
- Activation reports the exact selector, and `software current` reports it as
  active.
- Active verify and doctor report a ready installation.
- `rrp version` reports `selection: active` and the expected package/resource
  identities.
- None of these operations creates or inspects the fictional project.

Record whether PATH setup, exact selector construction, activation, verify,
and doctor felt like one coherent lifecycle.

## F. Create the fictional hospital project

Initialize the supplied project at its explicit absent destination:

```sh
cd "$RRP_ASSESSMENT_ROOT"
rrp reference init "$RRP_PROJECT_ROOT"
find "$RRP_PROJECT_ROOT" -type f -print | LC_ALL=C sort
```

Now enter the project. Existing-project commands below intentionally omit
`--project` to assess the accepted exact-current-directory behavior; RRP never
searches a parent or remembers a project.

```sh
cd "$RRP_PROJECT_ROOT"
pwd -P
sed -n '1,220p' rrp-project.dcf
sed -n '1,220p' rrp-authoring.dcf
sed -n '1,220p' README.md
```

### What you should observe

- The initialized project contains nine authoring, branding, and fictional-
  generator files.
- `R/produce-canonical.R` and `R/calculate-risk.R` are normal hospital-owned
  customization surfaces; `R/register.R` is thin RRP wiring.
- `_brand.yml` and `assets/project-logo.png` are project-owned declarative
  branding.
- There is no source, state, product, application source, private library, Git
  metadata, or installed software inside the project.

Record whether the initialized customization points and ownership boundary are
discoverable without reading the platform source tree.

## G. Prepare fictional source data

Use the installed fictional-only operation from the project directory:

```sh
rrp reference prepare-source
find source/generated -type f -print | LC_ALL=C sort
sed -n '1,120p' source/generated/source.dcf
sed -n '1,8p' source/generated/stays.csv
sed -n '1,8p' source/generated/events.csv
sed -n '1,16p' source/generated/identity-crosswalk.csv
```

### What you should observe

- Exactly four files appear under `source/generated/`.
- They contain four fictional stays, three event notifications, and twelve
  identity mappings.
- Native identifiers, local event codes, identity crosswalk, and
  `provider_signal` are private project inputs; the producer maps them to
  canonical identity and vocabulary.
- No real patient data or clinical model is involved.
- Repeating `reference prepare-source` should report safe reuse rather than
  overwrite conflicting content.

Record whether the command and its fictional-only boundary are clear.

## H. Validate the project and initialize state

```sh
rrp project validate
rrp state init
rrp state inspect
rrp project validate
```

### What you should observe

- The first validation recognizes the project, producer, provider, canonical
  profile, and API compatibility and warns that state is not initialized.
- State initialization creates `state/state.dcf` and
  `state/history.duckdb`; it does not run analytics or seed results.
- State inspection reports the supplied DuckDB adapter and compatible state.
- The second project validation reports `state_status: compatible`.

Do not edit `state.dcf` or query `history.duckdb` directly. Record whether the
separation between project validation and state initialization is apparent.

## I. Perform the first analytical run

The timestamp deliberately matches the pre-Stage-11 assessment rather than
the separate automated 11.H fixture. Use JSON for this mutation so the exact
generated scope identity can be captured for later commands.

```sh
export RRP_FIRST_RUN_JSON="$(rrp run \
  --at "$RRP_FIRST_TIME" \
  --operation-key post-stage-11-first \
  --json)"
printf '%s\n' "$RRP_FIRST_RUN_JSON"
export RRP_FIRST_SCOPE="$(printf '%s\n' "$RRP_FIRST_RUN_JSON" | sed -n 's/.*"operation_run_id":"\([^"]*\)".*/\1/p')"
test -n "$RRP_FIRST_SCOPE"
printf 'First scope: %s\n' "$RRP_FIRST_SCOPE"
```

Inspect the complete scope and the accepted episode's retained analytical
history through bounded CLI views:

```sh
rrp history scope --scope "$RRP_FIRST_SCOPE"
rrp history episode \
  --episode fictional.episode.001 \
  --target "$RRP_TARGET_ID" \
  --cutoff "$RRP_FIRST_TIME" \
  --json
```

### What you should observe

- The run returns one generated `operation_run_id`; no fixed scope identity was
  assumed.
- The scope reports four expected and four dispositioned episodes and
  `complete: TRUE`.
- Episode 001 is accepted at risk `0.39`; episodes 002–004 are ineligible
  because of prior readmission, prior death, and exhausted target horizon.
- Only episode 001 invokes the provider.
- CLI history output intentionally summarizes outcome and attribution without
  exposing patient/native identity or private predictor values.
- Durable history changes, but project authoring and source files do not.

The exact probability is most directly visible in the products/application;
the privacy-bounded history CLI does not render the raw estimate value. Record
whether the returned scope was easy to identify and reuse.

## J. Build and materialize the first products

The CLI composes logical construction and atomic publication, but still
requires the deliberate scope and cutoff:

```sh
rrp products materialize \
  --scope "$RRP_FIRST_SCOPE" \
  --cutoff "$RRP_FIRST_TIME" \
  --json
rrp products status \
  --scope "$RRP_FIRST_SCOPE" \
  --cutoff "$RRP_FIRST_TIME" \
  --json
```

### What you should observe

- Materialization reports one product-set and materialization identity.
- Product status reports `freshness_status: fresh` for the supplied first
  scope/cutoff.
- The coherent set has current risk `0.39`, one actual trajectory observation
  at January 19, and one scope summary reconciling four expected, one accepted,
  and three ineligible episodes.
- `state/products/current.dcf` selects one immutable set beneath
  `state/products/sets/`.
- Product materialization does not rerun the producer or provider.

Record whether the relationship among scope, cutoff, materialization, and
freshness is understandable.

## K. Launch and inspect the first application

Launch the installed product-only application in the foreground on the fixed
loopback port:

```sh
rrp app launch \
  --scope "$RRP_FIRST_SCOPE" \
  --cutoff "$RRP_FIRST_TIME" \
  --port "$RRP_APP_PORT" \
  --browser
```

The command blocks while Shiny runs. It should open
`http://127.0.0.1:45811`; if the browser does not open automatically, open that
URL manually. Inspect before stopping it with Ctrl+C in the terminal. An
interrupt result/exit 130 is expected for this manual foreground shutdown;
closing the browser tab alone may not stop Shiny.

### What you should observe

- **Current Risk Pool:** one current row at exactly `39.0%`, analytical time
  January 19, remaining follow-up, one-marker sparkline, and
  `fictional-reference-hospital.provider` attribution.
- **Episode Risk Trajectory:** one actual marker and one exact observation
  row—no fabricated daily points.
- **Overview:** four expected, one accepted, and three ineligible episodes,
  including one each for readmission, death, and exhausted horizon.
- **Freshness and branding:** fresh product context, Fictional Hospital name,
  colors, and contained logo.
- There are two top-level views, Current Risk Pool and Overview; trajectory is
  detail for the selected episode.
- The application reads products only. It does not calculate risk, invoke the
  producer/provider, materialize products, or mutate history.

Record navigation clarity, terminology, attribution, visual behavior, and
whether stopping the foreground application was obvious.

## L. Perform the second analytical run

Leave the fictional source bytes unchanged and advance analytical time by one
day with a distinct operation key:

```sh
export RRP_SECOND_RUN_JSON="$(rrp run \
  --at "$RRP_SECOND_TIME" \
  --operation-key post-stage-11-second \
  --json)"
printf '%s\n' "$RRP_SECOND_RUN_JSON"
export RRP_SECOND_SCOPE="$(printf '%s\n' "$RRP_SECOND_RUN_JSON" | sed -n 's/.*"operation_run_id":"\([^"]*\)".*/\1/p')"
test -n "$RRP_SECOND_SCOPE"
test "$RRP_SECOND_SCOPE" != "$RRP_FIRST_SCOPE"
printf 'Second scope: %s\n' "$RRP_SECOND_SCOPE"

rrp history scope --scope "$RRP_FIRST_SCOPE"
rrp history scope --scope "$RRP_SECOND_SCOPE"
rrp history episode \
  --episode fictional.episode.001 \
  --target "$RRP_TARGET_ID" \
  --cutoff "$RRP_SECOND_TIME" \
  --json
```

### What you should observe

- The second complete scope is distinct and covers the same four episodes.
- Episode 001 has a second actual accepted estimate,
  `0.3833333333333333`; its earlier `0.39` observation remains in history.
- The other three episodes retain their ineligibility reasons.
- The episode-history JSON now reports two analytical summaries.
- Source files remain unchanged; only governed history advances.

Record whether accumulated history and the distinction between the two scopes
are clear from CLI output.

## M. Build and materialize updated products

```sh
rrp products materialize \
  --scope "$RRP_SECOND_SCOPE" \
  --cutoff "$RRP_SECOND_TIME" \
  --json
rrp products status \
  --scope "$RRP_SECOND_SCOPE" \
  --cutoff "$RRP_SECOND_TIME" \
  --json
```

### What you should observe

- A second immutable product set is published and `current.dcf` advances.
- Product status is fresh for the second scope and January 20 cutoff.
- Current risk advances from `0.39` to `0.3833333333333333`.
- The actual trajectory contains exactly two observations:

```text
2026-01-19T12:00:00Z  0.39
2026-01-20T12:00:00Z  0.3833333333333333
```

- The scope summary still reconciles four expected, one accepted, and three
  ineligible episodes.
- The newer scope determines current membership; accumulated governed episode
  history supplies the two-point trajectory.

Record whether the CLI made it clear that products changed only because the
human explicitly selected and materialized the newer context.

## N. Relaunch and inspect the application

```sh
rrp app launch \
  --scope "$RRP_SECOND_SCOPE" \
  --cutoff "$RRP_SECOND_TIME" \
  --port "$RRP_APP_PORT" \
  --browser
```

Open `http://127.0.0.1:45811` if necessary. Stop the application with Ctrl+C
after inspection.

### What you should observe

- **Current Risk Pool:** the current probability is `38.3%` at January 20.
- **Episode Risk Trajectory:** two real markers, one connector, exact `0.39`
  and `0.3833333333333333` tooltips, and a two-row observation table.
- **Overview:** current count/distribution and the same reconciled four-member
  scope.
- **Freshness and branding:** fresh second product context with unchanged
  fictional branding and provider attribution.
- The visible transition from one to two observations required a second run,
  explicit materialization, shutdown, and relaunch. The app did not poll,
  recalculate, or mutate history.

Record whether the analytical change and retained trajectory are evident to a
human without inspecting internal files.

## O. Final inspection and assessment notes

After the second application stops, run the final supported diagnoses from the
project directory:

```sh
rrp state inspect
rrp products status \
  --scope "$RRP_SECOND_SCOPE" \
  --cutoff "$RRP_SECOND_TIME"
rrp project status \
  --scope "$RRP_SECOND_SCOPE" \
  --cutoff "$RRP_SECOND_TIME" \
  --json
rrp project doctor \
  --scope "$RRP_SECOND_SCOPE" \
  --cutoff "$RRP_SECOND_TIME"
```

Expected final state is one independent fictional project with unchanged
authoring/source files, compatible DuckDB state, two complete governed scopes,
two retained accepted observations for episode 001, two immutable product
sets, a fresh current pointer to the second set, and application readiness.
Software doctor remains a separate project-unaware diagnosis.

Complete this table only after personally performing the walkthrough:

| Step | Result | Observations / issues |
|---|---|---|
| Distribution acquisition | Not run | |
| Installation | Not run | |
| Software verification | Not run | |
| Reference project initialization | Not run | |
| Source preparation and project/state validation | Not run | |
| First run and products | Not run | |
| First application inspection | Not run | |
| Second run and products | Not run | |
| Updated application inspection | Not run | |
| Final project diagnosis | Not run | |

Also record:

- commands or arguments that were difficult to discover;
- output that obscured the next required identity or action;
- terminology that required knowledge of platform internals;
- places where installed guidance was insufficient;
- error or recovery messages encountered;
- unexpected interaction with the normal user environment; and
- bounded improvement opportunities, without treating this assessment as
  authority to implement them.

## P. Optional cleanup

First ensure no application process remains in the foreground and copy any
notes you want to retain outside the disposable root. Print and validate the
exact cleanup target before removing it:

```sh
printf 'Cleanup target: %s\n' "$RRP_ASSESSMENT_ROOT"
test -n "$RRP_ASSESSMENT_ROOT"
test -d "$RRP_ASSESSMENT_ROOT"
case "$(basename "$RRP_ASSESSMENT_ROOT")" in
  rrp-post-stage-11.*) ;;
  *) printf 'Refusing unexpected cleanup target\n' >&2; exit 1 ;;
esac
```

Because installed realizations are deliberately read-only, make only this
validated disposable assessment tree writable and remove only that tree:

```sh
chmod -R u+w "$RRP_ASSESSMENT_ROOT"
rm -rf "$RRP_ASSESSMENT_ROOT"
```

Do not apply those commands to a normal RRP installation, another project, the
source repository, a home directory, or an unresolved variable. This cleanup
does not exercise the supported exact-uninstall lifecycle; upgrade, rollback,
and uninstall are intentionally outside this focused manual assessment.

## Assessment boundary

This walkthrough deliberately stops after the two-run installed application
experience and final diagnosis. It is not a Stage 11 regression suite,
adversarial distribution test, side-by-side lifecycle exercise, production
hospital onboarding, deployment assessment, clinical model evaluation, public
release qualification, or Stage 12 work. Its status remains **not yet
executed** until a maintainer runs the commands and records actual results.
