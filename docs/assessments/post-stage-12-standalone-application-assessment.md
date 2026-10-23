# Post-Stage-12 Assessment — Standalone Application

**Status:** Human-operated, non-authoritative assessment — completed
successfully on 2026-10-23; procedure retained for reuse

**Accepted Stage 12 implementation:**
`49e96471da63d07c5872a28e80f8216cd0bdef72`

**Formal Stage 12 acceptance closeout when authored:**
`3158d78ecca3c6430ef2a55d769561efb83e55e8`

**Completion evidence:**
[Post-Stage-12 Standalone Application Assessment completion record](../platform-implementation-record.md#post-stage-12-standalone-application-assessment-completion-record-2026-10-23)

## A. Purpose and boundary

This guide asks a human maintainer to experience the accepted Stage 12
standalone-application workflow directly:

```text
generate app/
    → run it with ordinary R
    → copy it away from the project
    → run the detached copy
    → customize the project application
    → materialize a later analytical product set
    → refresh only the original app/rrp-data/
    → copy and run the refreshed application
```

The practical question is:

> Can I use RRP to generate a self-contained, hospital-owned Shiny
> application, move that application somewhere unrelated to the RRP project,
> run it with ordinary local R, and later repeat that process with updated
> analytical products without losing application source?

This assessment follows the human-first and evidence-recording conventions of
the
[Post-Stage-11 Manual Platform Assessment](post-stage-11-manual-platform-assessment.md).
Its first phase condenses that assessment's accepted distribution build,
verification, installation, activation, and fictional-project preparation so
this document can start without an RRP installation. The detailed assessment
remains focused on inspecting, copying, running, customizing, refreshing, and
comparing standalone applications.

This document is not an automated test, governing authority, formal acceptance
record, production deployment procedure, comprehensive CLI tutorial, Stage 13
adopter exercise, or release qualification. Stage 12 is already formally
accepted. A usability finding here should be recorded and assessed on its own
merits; it does not automatically reopen that acceptance.

The platform developer completed this procedure successfully on 2026-10-23.
The linked completion record is the concise historical certification; the
commands, expected results, troubleshooting, and cleanup below remain the
reusable human procedure.

Use only the supplied fictional, nonclinical project. Do not use real patient
data, credentials, private hospital mappings, or a real model.

## B. Phase 1 — Prepare RRP and the fictional project

Start on macOS with ordinary R 4.4.x and no required RRP installation, RRP
project, or generated application. The host also needs Git, `tar`, `awk`,
either `sha256sum` or `shasum`, normal package-compilation tools when the
repository supplies source packages, network access to
`https://cloud.r-project.org`, and two available loopback ports. Keep one
terminal open throughout so the exported variables persist.

There is no published Stage 14 RRP acquisition yet. The supported acquisition
for this development assessment is therefore the same maintainer-only path as
the Post-Stage-11 assessment: build one closed local `1.0.0-dev` distribution
from this repository, copy it into an independent acquisition location, verify
the copy, and install from that verified payload. The accepted Stage 12
implementation revision is
`49e96471da63d07c5872a28e80f8216cd0bdef72`; formal acceptance was recorded at
`3158d78ecca3c6430ef2a55d769561efb83e55e8`. The commands below require both
revisions in the ancestry of a clean checkout and print the exact later source
revision actually used. Record that revision with the assessment. This local
artifact is accepted development evidence, not a published download or
release.

### Create three isolated locations

Run this block from anywhere inside the RRP repository:

```sh
export RRP_SOURCE_ROOT="$(git rev-parse --show-toplevel)"
cd "$RRP_SOURCE_ROOT"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 49e96471da63d07c5872a28e80f8216cd0bdef72 HEAD
git merge-base --is-ancestor 3158d78ecca3c6430ef2a55d769561efb83e55e8 HEAD
export RRP_SOURCE_REVISION="$(git rev-parse HEAD)"

export RRP_SOFTWARE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/rrp-post-stage-12-software.XXXXXX")"
export RRP_ASSESSMENT_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/rrp-post-stage-12-project.XXXXXX")"
export RRP_DETACHED_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/rrp-post-stage-12-detached.XXXXXX")"
export RRP_BUILD_ROOT="$RRP_SOFTWARE_ROOT/build"
export RRP_BUILD_LIBRARY="$RRP_BUILD_ROOT/library"
export RRP_DEPENDENCY_PROVENANCE="$RRP_BUILD_ROOT/dependency-provenance.dcf"
export RRP_BUILD_ARCHIVE="$RRP_BUILD_ROOT/rrp-1.0.0-dev.tar"
export RRP_ACQUISITION_ROOT="$RRP_SOFTWARE_ROOT/acquired"
export RRP_ACQUIRED_ARCHIVE="$RRP_ACQUISITION_ROOT/rrp-1.0.0-dev.tar"
export RRP_UNPACK_ROOT="$RRP_SOFTWARE_ROOT/unpacked"
export RRP_DISTRIBUTION_ROOT="$RRP_UNPACK_ROOT/rrp-1.0.0-dev"
export RRP_INSTALLATION_ROOT="$RRP_SOFTWARE_ROOT/installed-software"
export RRP_EXECUTABLE_ROOT="$RRP_SOFTWARE_ROOT/bin"
export RRP_CRAN_REPOSITORY="https://cloud.r-project.org"
export RRP_SHELL_PATH_BEFORE_ASSESSMENT="$PATH"
export RRP_PROJECT_ROOT="$RRP_ASSESSMENT_ROOT/fictional-hospital"
export RRP_ORIGINAL_APP="$RRP_PROJECT_ROOT/app"
export RRP_TIME_1_APP="$RRP_DETACHED_ROOT/app-time-1"
export RRP_TIME_2_APP="$RRP_DETACHED_ROOT/app-time-2"
export RRP_STANDALONE_LIBRARY="$RRP_DETACHED_ROOT/library"
export RRP_RESTORE_TOOL_LIBRARY="$RRP_DETACHED_ROOT/restore-tool-library"
export RRP_TIME_1="2026-01-19T12:00:00Z"
export RRP_TIME_2="2026-01-20T12:00:00Z"
export RRP_TIME_1_PORT="45821"
export RRP_TIME_2_PORT="45822"

mkdir -p "$RRP_BUILD_LIBRARY" "$RRP_ACQUISITION_ROOT" "$RRP_UNPACK_ROOT"
printf 'Source revision: %s\n' "$RRP_SOURCE_REVISION"
printf 'Software root:  %s\n' "$RRP_SOFTWARE_ROOT"
printf 'Project root:   %s\n' "$RRP_ASSESSMENT_ROOT"
printf 'Detached root:  %s\n' "$RRP_DETACHED_ROOT"
test ! -e "$RRP_INSTALLATION_ROOT"
test ! -e "$RRP_EXECUTABLE_ROOT"
test ! -e "$RRP_PROJECT_ROOT"
test ! -e "$RRP_TIME_1_APP"
test ! -e "$RRP_TIME_2_APP"
```

These roots establish three deliberately separate concerns:

- **RRP software installation:** `$RRP_SOFTWARE_ROOT` contains the controlled
  build library, copied distribution, installed realization, private runtime
  library, and assessment-only launcher.
- **RRP fictional project:** `$RRP_PROJECT_ROOT` contains project source,
  durable analytical state and products, and the original managed `app/`.
- **Detached application location:** `$RRP_DETACHED_ROOT` contains only copied
  standalone applications and, when chosen later, their ordinary R dependency
  library.

None is a normal user library or default RRP location. If another RRP is
already installed, these explicit roots and the later exact `command -v` check
leave it untouched and prevent this session from silently using it.

### Build and obtain the verified local distribution

Provision the exact dependency closure into the empty build library and write
the controlled provenance receipt required by the accepted distribution
builder:

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

cd "$RRP_SOURCE_ROOT"
R_LIBS_USER="$RRP_BUILD_LIBRARY" \
R_LIBS_SITE= \
RRP_CRAN_REPOSITORY="$RRP_CRAN_REPOSITORY" \
RRP_DEPENDENCY_PROVENANCE="$RRP_DEPENDENCY_PROVENANCE" \
  Rscript --vanilla tools/build-distribution.R "$RRP_BUILD_ARCHIVE"

cp "$RRP_BUILD_ARCHIVE" "$RRP_ACQUIRED_ARCHIVE"
tar -xf "$RRP_ACQUIRED_ARCHIVE" -C "$RRP_UNPACK_ROOT"
test -d "$RRP_DISTRIBUTION_ROOT"
cd "$RRP_DISTRIBUTION_ROOT"
Rscript --vanilla verify-distribution.R .
```

The final build and verification messages must report `PASS distribution
build` and `PASS distribution`. Do not continue from an unverified payload.
This is the only repository-facing portion of the assessment.

### Install and activate the isolated realization

Install with the same R and exact configured repository, make only the
assessment launcher first on this terminal's `PATH`, then activate the exact
manifest selector:

```sh
cd "$RRP_DISTRIBUTION_ROOT"
Rscript --vanilla install.R \
  --repository "$RRP_CRAN_REPOSITORY" \
  --installation-root "$RRP_INSTALLATION_ROOT" \
  --executable-root "$RRP_EXECUTABLE_ROOT"

export PATH="$RRP_EXECUTABLE_ROOT:$PATH"
test -x "$RRP_EXECUTABLE_ROOT/rrp"
test "$(command -v rrp)" = "$RRP_EXECUTABLE_ROOT/rrp"

export RRP_PRODUCT_VERSION="$(awk -F ': ' '$1 == "Product-Version" { print $2 }' "$RRP_DISTRIBUTION_ROOT/manifest.dcf")"
export RRP_DISTRIBUTION_ID="$(awk -F ': ' '$1 == "Distribution-ID" { print $2 }' "$RRP_DISTRIBUTION_ROOT/manifest.dcf")"
export RRP_SELECTOR="$RRP_PRODUCT_VERSION/$RRP_DISTRIBUTION_ID"

rrp software verify --software "$RRP_SELECTOR"
rrp software doctor --software "$RRP_SELECTOR"
rrp software activate "$RRP_SELECTOR"
rrp software current
rrp version
```

Installation must end with `PASS installation`; verification and doctor must
succeed; `software current` must name `$RRP_SELECTOR`; and `command -v rrp`
must remain exactly `$RRP_EXECUTABLE_ROOT/rrp`. The procedure does not use,
replace, activate, or uninstall any pre-existing RRP realization.

**Checkpoint**

- **Action:** Build, verify, install, activate, and resolve the isolated RRP
  realization.
- **Expected result:** The exact copied distribution is verified, the isolated
  selector is active, and this terminal resolves only its temporary launcher.
- **Observed result:** ________________________________________________
- **Result:** [ ] Pass  [ ] Fail

Exact source revision used: __________________________________________

### Create the project and its first product set

Create and prepare the ordinary fictional project, validate it, and initialize
its project-owned state:

```sh
rrp reference init "$RRP_PROJECT_ROOT"
rrp reference prepare-source --project "$RRP_PROJECT_ROOT"
rrp project validate --project "$RRP_PROJECT_ROOT"
rrp state init --project "$RRP_PROJECT_ROOT"
rrp state inspect --project "$RRP_PROJECT_ROOT"
```

Run the first governed analytical context and retain its generated scope
identity. No fixed scope is assumed:

```sh
export RRP_TIME_1_RUN_JSON="$(rrp run \
  --at "$RRP_TIME_1" \
  --operation-key post-stage-12-time-1 \
  --project "$RRP_PROJECT_ROOT" \
  --json)"
printf '%s\n' "$RRP_TIME_1_RUN_JSON"
export RRP_TIME_1_SCOPE="$(printf '%s\n' "$RRP_TIME_1_RUN_JSON" | \
  sed -n 's/.*"operation_run_id":"\([^"]*\)".*/\1/p')"
test -n "$RRP_TIME_1_SCOPE"

rrp products materialize \
  --scope "$RRP_TIME_1_SCOPE" \
  --cutoff "$RRP_TIME_1" \
  --project "$RRP_PROJECT_ROOT" \
  --json
rrp products status \
  --scope "$RRP_TIME_1_SCOPE" \
  --cutoff "$RRP_TIME_1" \
  --project "$RRP_PROJECT_ROOT" \
  --json
```

Expected fictional time-1 presentation is one current accepted episode at
`39.0%`, one actual trajectory observation, and a four-episode scope containing
one accepted and three ineligible episodes. Product status should be fresh for
the exact returned scope and cutoff. Initialization alone would not have
created these products; the explicit run and materialization are required.

**Checkpoint**

- **Action:** Create and materialize the first governed analytical context.
- **Expected result:** A nonempty scope identity and one fresh compatible
  product set are reported.
- **Observed result:** ________________________________________________
- **Result:** [ ] Pass  [ ] Fail

## C. Phase 2 — Initialize and inspect the project application

Create the normal standalone application at the absent default destination and
validate it:

```sh
rrp app init \
  --scope "$RRP_TIME_1_SCOPE" \
  --cutoff "$RRP_TIME_1" \
  --project "$RRP_PROJECT_ROOT" \
  --json
rrp app validate --project "$RRP_PROJECT_ROOT" --json
test -d "$RRP_ORIGINAL_APP"
find "$RRP_ORIGINAL_APP" -maxdepth 3 -print | LC_ALL=C sort
```

The exact generated root contains:

```text
app/
├── app.R
├── R/
├── www/rrp.css
├── README.md
├── renv.lock
├── LICENSE
├── NOTICE
├── rrp-initialization.dcf
├── rrp-source-inventory.dcf
└── rrp-data/
    ├── current.dcf
    ├── presentation.dcf
    └── sets/
```

The hospital owns `app.R`, `R/`, `www/`, `README.md`, `renv.lock`, deployment
configuration, Git metadata, and additional source/assets. RRP reserves only
`rrp-data/` for managed products, current selection, presentation, provenance,
and bounded refresh metadata. The two root DCF records describe the initial
supplied baseline; routine refresh does not rewrite them.

Do not manually edit `rrp-data/`, `current.dcf`, product CSV files, inventories,
or digests.

**Checkpoint**

- **Action:** Initialize, validate, and inspect the project `app/` directory.
- **Expected result:** The complete conventional Shiny layout exists, validates,
  and clearly separates hospital-owned source from `rrp-data/`.
- **Observed result:** ________________________________________________
- **Result:** [ ] Pass  [ ] Fail

## D. Prepare ordinary R dependencies

Application-directory portability and R-package availability are separate.
Copying `app/` copies its source, frozen products, and exact `renv.lock`; it
does not install packages on another machine or into another R library. The
standalone runtime needs `shiny`, `bslib`, `plotly`, `reactable`, and their
declared transitive closure. It does not need `rrpplatform`, `rrpruntime`, DBI,
DuckDB, the `rrp` command, or the analytical project.

### Option A — Use compatible packages already available to ordinary R

Check the four direct runtime packages:

```sh
Rscript --vanilla -e 'required <- c("shiny", "bslib", "plotly", "reactable"); missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]; if (length(missing)) { cat("Missing:", paste(missing, collapse = ", "), "\n"); quit(status = 1L) }; cat("Direct standalone packages available\n")'
```

If this succeeds, the main walkthrough can use the ordinary local R library.

### Option B — Restore the declared closure into an isolated library

Use this when packages are missing or when you want to experience exact
lock-based restoration. `renv` is only the restoration tool; the generated
application has no automatic activation file and does not require `renv` after
the selected library is populated.

Keep the restoration tool and application runtime closure in separate
assessment-owned libraries. This avoids modifying a normal user library and
keeps `renv` out of the declared application closure:

```sh
mkdir "$RRP_RESTORE_TOOL_LIBRARY" "$RRP_STANDALONE_LIBRARY"
Rscript --vanilla - \
  "$RRP_RESTORE_TOOL_LIBRARY" \
  "$RRP_CRAN_REPOSITORY" <<'RRP_INSTALL_RENV'
args <- commandArgs(trailingOnly = TRUE)
tool_library <- normalizePath(args[[1L]], winslash = "/", mustWork = TRUE)
install.packages(
  "renv", lib = tool_library, repos = args[[2L]], dependencies = FALSE
)
RRP_INSTALL_RENV

Rscript --vanilla - \
  "$RRP_ORIGINAL_APP" \
  "$RRP_STANDALONE_LIBRARY" \
  "$RRP_RESTORE_TOOL_LIBRARY" <<'RRP_RESTORE'
args <- commandArgs(trailingOnly = TRUE)
app <- normalizePath(args[[1L]], winslash = "/", mustWork = TRUE)
library <- normalizePath(args[[2L]], winslash = "/", mustWork = TRUE)
tool_library <- normalizePath(args[[3L]], winslash = "/", mustWork = TRUE)
.libPaths(c(tool_library, .Library), include.site = FALSE)
stopifnot(requireNamespace("renv", quietly = TRUE))
renv::restore(
  project = app,
  lockfile = file.path(app, "renv.lock"),
  library = library,
  prompt = FALSE
)
cat("Standalone library:", library, "\n")
RRP_RESTORE
```

The main workflow does not require manually auditing the current 72-package
closure. Stage 12 automated qualification already established exact isolated
resolution. This optional path lets the human observe dependency preparation
without installing either RRP package into the standalone library or reading
the RRP installation's private runtime library.

Record which option you used: __________________________________________

## E. Run the original application with ordinary R

For Option A, launch from a normal terminal with ordinary R:

```sh
Rscript --vanilla -e 'shiny::runApp(Sys.getenv("RRP_ORIGINAL_APP"), host = "127.0.0.1", port = as.integer(Sys.getenv("RRP_TIME_1_PORT")), launch.browser = TRUE)'
```

For Option B, select only the isolated standalone library plus base R before
launch:

```sh
Rscript --vanilla - \
  "$RRP_ORIGINAL_APP" \
  "$RRP_STANDALONE_LIBRARY" \
  "$RRP_TIME_1_PORT" <<'RRP_RUN_APP'
args <- commandArgs(trailingOnly = TRUE)
.libPaths(
  c(normalizePath(args[[2L]], mustWork = TRUE), .Library),
  include.site = FALSE
)
shiny::runApp(
  normalizePath(args[[1L]], mustWork = TRUE),
  host = "127.0.0.1", port = as.integer(args[[3L]]), launch.browser = TRUE
)
RRP_RUN_APP
```

If the browser does not open, visit `http://127.0.0.1:45821`. Navigate between
Current Risk Pool and Overview, select the accepted episode, inspect its
trajectory, refresh the browser page, and confirm local styling/assets render.
Stop the foreground application with Ctrl+C; closing the browser tab alone may
not stop its R process.

Expected time-1 observations are the fictional `39.0%` accepted risk and one
actual trajectory point. No analytical command runs when the application
starts.

**Checkpoint**

- **Action:** Launch the original project application using ordinary R.
- **Expected result:** Navigation, product displays, branding, CSS, and local
  assets work without an RRP runtime call or missing-package error.
- **Observed result:** ________________________________________________
- **Result:** [ ] Pass  [ ] Fail

## F. Copy and run the detached time-1 application

Copy the entire directory—not selected source files and not project state—to
the unrelated detached root:

```sh
test ! -e "$RRP_TIME_1_APP"
cp -R "$RRP_ORIGINAL_APP" "$RRP_TIME_1_APP"
test -f "$RRP_TIME_1_APP/app.R"
test -f "$RRP_TIME_1_APP/renv.lock"
test -f "$RRP_TIME_1_APP/rrp-data/current.dcf"
rrp app validate --app "$RRP_TIME_1_APP" --json
```

A Finder copy of the complete `app` directory is equally valid. Rename the
copied folder `app-time-1`; do not reconstruct it from individual files.

Launch the detached directory with ordinary R, using Option A:

```sh
Rscript --vanilla -e 'shiny::runApp(Sys.getenv("RRP_TIME_1_APP"), host = "127.0.0.1", port = as.integer(Sys.getenv("RRP_TIME_1_PORT")), launch.browser = TRUE)'
```

Or repeat the Option B launcher with `$RRP_TIME_1_APP` as its first argument.

The detached app reads the frozen products in its own `rrp-data/`. It does not
call the originating project, project state, materializations, installed RRP,
or source repository. The installed `rrp app validate` command above is an
optional structural check; it is not part of launching the app. Once package
dependencies are available, the launch itself uses only ordinary R and Shiny.

Inspect the same pages, risk value, trajectory, and assets, then stop it with
Ctrl+C.

**Checkpoint**

- **Action:** Copy the complete app elsewhere and launch the detached copy.
- **Expected result:** The copy validates and independently presents the same
  time-1 products without any source-project path or RRP runtime command.
- **Observed result:** ________________________________________________
- **Result:** [ ] Pass  [ ] Fail

## G. Make one visible hospital-owned customization

Customize the original project application, not `rrp-data/` and not the
detached time-1 snapshot. Open:

```sh
open -e "$RRP_ORIGINAL_APP/www/rrp.css"
```

Append this bounded CSS block:

```css
/* BEGIN post-stage-12 assessment customization */
.rrp-brand-name::after {
  content: " — standalone assessment";
  color: #7a3e00;
  font-weight: 500;
}
/* END post-stage-12 assessment customization */
```

Save the file and rerun the original application using the command from
Section E. The navigation brand should now end with “— standalone assessment.”
The application should otherwise behave identically. Remove exactly that
bounded block to restore the original style if desired.

Validate after the edit:

```sh
rrp app validate --project "$RRP_PROJECT_ROOT" --json
```

Managed products should remain valid. Initial source-baseline drift is
informational because the hospital legitimately owns this CSS; RRP must not
rewrite it during refresh.

**Checkpoint**

- **Action:** Append the CSS customization and rerun the original app.
- **Expected result:** The visible suffix appears, managed validation still
  succeeds, and `rrp-data/` remains untouched.
- **Observed result:** ________________________________________________
- **Result:** [ ] Pass  [ ] Fail

## H. Produce a distinct time-2 product set

Return to the original project. Keep fictional source bytes unchanged, advance
analytical time by one day, and use a distinct operation key:

```sh
export RRP_TIME_2_RUN_JSON="$(rrp run \
  --at "$RRP_TIME_2" \
  --operation-key post-stage-12-time-2 \
  --project "$RRP_PROJECT_ROOT" \
  --json)"
printf '%s\n' "$RRP_TIME_2_RUN_JSON"
export RRP_TIME_2_SCOPE="$(printf '%s\n' "$RRP_TIME_2_RUN_JSON" | \
  sed -n 's/.*"operation_run_id":"\([^"]*\)".*/\1/p')"
test -n "$RRP_TIME_2_SCOPE"
test "$RRP_TIME_2_SCOPE" != "$RRP_TIME_1_SCOPE"

rrp products materialize \
  --scope "$RRP_TIME_2_SCOPE" \
  --cutoff "$RRP_TIME_2" \
  --project "$RRP_PROJECT_ROOT" \
  --json
rrp products status \
  --scope "$RRP_TIME_2_SCOPE" \
  --cutoff "$RRP_TIME_2" \
  --project "$RRP_PROJECT_ROOT" \
  --json
```

Expected fictional time-2 output is a distinct scope and product set, current
risk approximately `38.3%`, and a trajectory containing the retained `39.0%`
time-1 observation plus the new time-2 observation. This is a governed run and
materialization, not an application-side calculation.

**Checkpoint**

- **Action:** Run and materialize the second explicit analytical context.
- **Expected result:** The scope differs from time 1 and products are fresh for
  the exact time-2 scope/cutoff.
- **Observed result:** ________________________________________________
- **Result:** [ ] Pass  [ ] Fail

## I. Refresh and inspect the original application

Refresh only the original project application from the already-materialized
time-2 set:

```sh
rrp app refresh \
  --scope "$RRP_TIME_2_SCOPE" \
  --cutoff "$RRP_TIME_2" \
  --project "$RRP_PROJECT_ROOT" \
  --json
rrp app validate --project "$RRP_PROJECT_ROOT" --json
```

Refresh does not run analytics or materialize products. It stages and validates
one compatible frozen set under the original application's `rrp-data/`, then
atomically advances its current record. It does not search for or update the
detached time-1 copy.

Rerun the original with ordinary R. Confirm:

- current accepted risk is approximately `38.3%`;
- the actual trajectory contains two observations;
- the source scope/product identity differs from time 1; and
- the “— standalone assessment” CSS suffix remains visible.

Stop the application with Ctrl+C. Reopen the time-1 detached copy and confirm
it still shows `39.0%` with one actual trajectory observation and does not gain
the later product set. The two directories are snapshots, not synchronized
installations.

**Checkpoint**

- **Action:** Refresh and run the original, then recheck detached time 1.
- **Expected result:** Original app shows time 2 and retains its customization;
  detached app remains an unchanged time-1 snapshot.
- **Observed result:** ________________________________________________
- **Result:** [ ] Pass  [ ] Fail

## J. Copy and run the refreshed time-2 application

Keep the first copy intact and make a second complete snapshot:

```sh
test ! -e "$RRP_TIME_2_APP"
cp -R "$RRP_ORIGINAL_APP" "$RRP_TIME_2_APP"
rrp app validate --app "$RRP_TIME_1_APP" --json
rrp app validate --app "$RRP_TIME_2_APP" --json
```

Launch the time-2 copy with Option A:

```sh
Rscript --vanilla -e 'shiny::runApp(Sys.getenv("RRP_TIME_2_APP"), host = "127.0.0.1", port = as.integer(Sys.getenv("RRP_TIME_2_PORT")), launch.browser = TRUE)'
```

Or repeat the Option B launcher with `$RRP_TIME_2_APP` and port `45822`.
If desired, run time 1 on `45821` and time 2 on `45822` simultaneously in two
terminals.

Expected comparison:

| Snapshot | Products | Trajectory | Assessment CSS |
|---|---|---|---|
| `app-time-1` | Time 1, `39.0%` | One actual observation | Absent; copied before the edit |
| `app-time-2` | Time 2, approximately `38.3%` | Two actual observations | Present |

Both copies run without the originating project. Stop each foreground process
with Ctrl+C.

**Checkpoint**

- **Action:** Copy and run the refreshed application independently.
- **Expected result:** Both snapshots run; their visible products differ as
  expected; the time-2 copy retains hospital-owned customization.
- **Observed result:** ________________________________________________
- **Result:** [ ] Pass  [ ] Fail

## K. Optional manual replacement workflow

A likely hospital workflow is manual directory replacement after reviewing a
fresh project application copy:

1. Refresh the authoritative project `app/` through `rrp app refresh`.
2. Stop the detached Shiny process completely.
3. Preserve or version any detached-only hospital changes.
4. Replace the detached directory with a complete fresh copy of the project
   `app/` directory using Finder or ordinary filesystem tools.
5. Relaunch it with ordinary R and confirm the new products.

This is manual hospital-owned file management. `rrp app init` is create-only
and is not an overwrite/update command. `rrp app refresh` updates only the
explicit original or `--app PATH` supplied to that command; it never remotely
synchronizes arbitrary copies.

> **Customization risk:** replacing a detached directory removes changes that
> exist only in that detached copy. Merge, back up, or version those changes
> before replacement. RRP does not merge or upgrade hospital application
> source.

Optional observation: _________________________________________________

## L. Assessment results

The platform developer reported the following results for the completed
2026-10-23 walkthrough. A future assessor may copy this table and reset its
result cells when reusing the procedure.

| Checkpoint | Result | Observations / issues |
|---|---|---|
| Original project `app/` generated and validated | Successful | Initialization and validation passed. |
| Original app launched with ordinary R | Successful | Launched through `Rscript --vanilla` and `shiny::runApp()`. |
| Complete time-1 directory copied | Successful | Copied outside the fictional project. |
| Detached time-1 app launched | Successful | Launched through ordinary R/Shiny. |
| Detached app displayed analytical products and local assets | Successful | No reported discrepancy. |
| Human-owned customization was visible | Successful | CSS edit remained usable; validation reported expected source-baseline drift. |
| Distinct second product set generated | Successful | Time-2 run and materialization completed. |
| Original app managed refresh succeeded | Successful | Managed content advanced to time 2. |
| Hospital-owned customization survived refresh | Successful | Customized source remained intact. |
| Original app displayed time-2 products | Successful | Refreshed app launched through ordinary R/Shiny. |
| Detached time-1 copy remained unchanged | Successful | Retained its time-1 product set. |
| Refreshed time-2 copy launched independently | Successful | Validated and launched through ordinary R/Shiny. |

Record the human evaluation:

- Was the generated application straightforward to locate and inspect?
  _________________________________________________________________
- Was copying the complete directory sufficient?
  _________________________________________________________________
- Did detached launch feel like running an ordinary Shiny app?
  _________________________________________________________________
- Was dependency preparation reasonable and understandable?
  _________________________________________________________________
- Was the application meaningfully customizable?
  _________________________________________________________________
- Did managed refresh behave as expected without changing source?
  _________________________________________________________________
- Was the original-versus-detached snapshot distinction clear?
  _________________________________________________________________
- Would this workflow be practical for a hospital analyst?
  _________________________________________________________________
- Unexpected behavior or usability friction:
  _________________________________________________________________
- Documentation gaps or potential future improvements:
  _________________________________________________________________

**Overall assessment:** [x] Successful  [ ] Successful with observations
[ ] Unsuccessful  [ ] Not completed

Human usability observations are subsequent assessment evidence. They are not
automated validation and do not themselves amend architecture, implementation,
formal Stage 12 acceptance, release status, or deployment support.

## M. Troubleshooting

### Distribution preparation or installation fails

Stop at the failing command. Confirm R 4.4.x, the named HTTPS repository,
network access, package-compilation prerequisites, and `sha256sum` or `shasum`
are available. Rerun only with a newly created software root and empty build
library; do not substitute ambient packages, skip standalone verification, or
install either RRP package directly from the checkout.

### `app/` does not exist

Initialization is a separate create-only operation. Confirm a compatible fresh
product set exists, then run `rrp app init` with its exact scope and cutoff.
Do not create `app/` manually before initialization.

### No compatible materialized set is available

Run the explicit analytical command, retain its returned scope, materialize
that exact scope/cutoff, and check `rrp products status`. Project initialization
does not create analytical products.

### Initialization refuses an existing destination

This is expected fail-closed behavior, even for an empty directory. Choose an
absent `--output` path or deliberately remove only a disposable destination
after inspecting it. There is no overwrite option.

### `shiny` or another declared package is missing

Use Section D, Option B to restore the generated `renv.lock` into the isolated
assessment library. Do not install `rrpplatform` or `rrpruntime` into the
standalone runtime.

### Local assets do not load

Confirm the entire directory was copied, including `R/`, `www/`, `rrp-data/`,
and hidden content if hospital additions introduced any. Launch the directory
root containing `app.R`; do not launch a source file individually.

### A copied app still shows old products

Detached copies are snapshots and do not synchronize. Refresh the original
project application, stop the detached process, make a new complete copy, and
relaunch that new directory.

### Refresh cannot find the requested scope/cutoff

Use the exact `operation_run_id` returned by `rrp run`, the identical RFC 3339
UTC cutoff used for materialization, and the explicit originating project.
RRP does not infer the latest run.

### Refresh rejects incompatible products

Leave the existing application intact. Inspect `rrp products status` for the
exact scope/cutoff and correct the analytical/materialization selection. Do not
edit `rrp-data/current.dcf` or product files manually.

### The CSS customization is not visible

Confirm you edited the original project's `www/rrp.css`, saved it, and launched
that same directory. Restart Shiny and hard-refresh the browser. The time-1
copy was intentionally made before customization and should not show it.

### Two applications cannot use the same port

Use separate foreground R sessions and distinct ports such as `45821` and
`45822`. Stop an old process with Ctrl+C before reusing its port.

### An application remains running during directory replacement

Stop its foreground R process with Ctrl+C and confirm the local URL no longer
responds before replacing files. Do not replace a directory being served.

## N. Optional cleanup

Stop every assessment Shiny process first and preserve any notes you want to
keep. Return to the retained source checkout, restore the shell's earlier
`PATH`, and print and validate all three exact disposable targets:

```sh
cd "$RRP_SOURCE_ROOT"
export PATH="$RRP_SHELL_PATH_BEFORE_ASSESSMENT"
hash -r

printf 'Software cleanup target: %s\n' "$RRP_SOFTWARE_ROOT"
printf 'Project cleanup target:  %s\n' "$RRP_ASSESSMENT_ROOT"
printf 'Detached cleanup target: %s\n' "$RRP_DETACHED_ROOT"
test -d "$RRP_SOFTWARE_ROOT"
test -d "$RRP_ASSESSMENT_ROOT"
test -d "$RRP_DETACHED_ROOT"
case "$(basename "$RRP_SOFTWARE_ROOT")" in
  rrp-post-stage-12-software.*) ;;
  *) printf 'Refusing unexpected software target\n' >&2; exit 1 ;;
esac
case "$(basename "$RRP_ASSESSMENT_ROOT")" in
  rrp-post-stage-12-project.*) ;;
  *) printf 'Refusing unexpected project target\n' >&2; exit 1 ;;
esac
case "$(basename "$RRP_DETACHED_ROOT")" in
  rrp-post-stage-12-detached.*) ;;
  *) printf 'Refusing unexpected detached target\n' >&2; exit 1 ;;
esac
```

The supported `rrp software uninstall SELECTOR --yes` operation removes an
exact verified **inactive** realization, but deliberately refuses the final
installed realization. It is neither required nor appropriate for this
single-realization disposable proof. After the guards above, ordinary removal
of the three assessment-owned temporary roots cleans up the isolated build,
copied distribution, installation, project, detached applications, and both
standalone dependency libraries together:

```sh
rm -rf "$RRP_SOFTWARE_ROOT" "$RRP_ASSESSMENT_ROOT" "$RRP_DETACHED_ROOT"
test ! -e "$RRP_SOFTWARE_ROOT"
test ! -e "$RRP_ASSESSMENT_ROOT"
test ! -e "$RRP_DETACHED_ROOT"
```

Never apply that cleanup to an existing hospital project, installed RRP root,
normal R library, source repository, home directory, or unresolved variable.

## Assessment boundary

This assessment stops after the human experiences original and detached
time-1 applications, one hospital-owned CSS customization, a governed time-2
product refresh, and an independently launched time-2 copy. It does not test
external hosting, deployment, authentication, protected-data controls,
production model governance, Stage 13 adopter qualification, Stage 14 release,
or publication. The documented assessment was completed successfully on
2026-10-23. Its result remains subsequent human assessment evidence rather
than formal stage acceptance, automated validation, release qualification, or
deployment evidence.
