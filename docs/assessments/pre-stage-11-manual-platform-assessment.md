# Pre-Stage-11 Manual Platform Assessment

Status: human-operated, non-authoritative assessment guide

Accepted implementation: `433d7eb2d90a4e237a6e5ffa00044de99534fe68`

Stage 10 closeout: `0def0c48b43d2b4cce6842d63edcbe642adfe41a`

This document is a disposable assessment aid. It is not a platform authority,
contract, installed product guide, implementation plan, or automated test. It
asks a human to experience the accepted platform before Stage 11 defines
distribution, installation, CLI, and upgrade behavior.

Do not use real patient data, credentials, private hospital mappings, or a real
clinical model in this exercise. Everything below uses the supplied fictional,
nonclinical reference project.

## Where the platform stands

RRP has progressed from repository foundations to a complete installed,
product-only local application path:

1. The repository has stable identity, public/legal metadata, human ownership
   rules, local validation, and hosted package-foundation verification.
2. `rrpruntime` and `rrpplatform` are conventional installable R packages with
   a one-way dependency from the platform package to the focused runtime.
3. A closed installed-resource catalog carries contracts, templates, assets,
   and human product documentation behind explicit-root lookup.
4. An independent project owns its manifest, authoring declarations, source
   adaptation, provider implementation, optional extensions, declarative
   branding, and project state outside the software installation.
5. A selected project producer maps project-owned source into the admitted
   canonical discharge-episode and terminal-event domains.
6. RRP constructs the singular remaining-30-day readmission-risk request,
   invokes the explicitly selected provider once for each eligible episode,
   and accepts one finite probability under the governed target.
7. Project-owned state and the supplied DuckDB adapter retain immutable scope,
   disposition, estimate, and correction history behind public logical
   operations.
8. The ordinary fictional project proves deterministic source generation,
   meaningful private identity mapping, a private predictor, project-owned
   producer/provider behavior, durable execution, and portability.
9. RRP converts governed history into a coherent three-member logical product
   set and materializes it beneath project state with validated detached
   access.
10. The installed generic Shiny application reads only those validated
    products and presents Current Risk Pool, actual trajectory, Overview,
    freshness, and bounded declarative branding.

Together, these stages mean that RRP can be built and installed, initialize and
operate an independent project, accept project-owned source, producer, and
provider behavior through governed boundaries, execute and retain the
readmission-risk lifecycle, construct and materialize presentation products,
and launch an installed product-only application.

Stage 10 intentionally does **not** provide a production distribution, polished
installer, CLI, upgrade workflow, deployment artifact, remote hosting,
authentication, or Posit Connect/OCI realization. Those absences explain some
manual steps below; they are assessment evidence for Stage 11, not defects to
work around silently.

## Keep the three locations distinct

This assessment uses three separate roots:

```text
temporary source checkout
    used only to build the packages and project the resources because
    Stage 11 distribution does not yet exist

installed RRP software
    an isolated R package library plus a distribution-shaped resource root

temporary independent project
    the adopter-owned fictional project, source, history, and products
```

After the preparation section, do not source package files, use
`devtools::load_all()`, or use the repository as the project root. Package
operations must resolve from the isolated library and resources from the
separate software root.

## 1. Prepare a disposable workspace

### Terminal — from the accepted repository root

Confirm that this checkout contains the accepted closeout and requires R 4.4 or
newer:

```sh
git rev-parse HEAD
git status --short --branch
git merge-base --is-ancestor 0def0c48b43d2b4cce6842d63edcbe642adfe41a HEAD
R --version
```

The clean starting revision used to author this guide was
`0def0c48b43d2b4cce6842d63edcbe642adfe41a`; its parent is the accepted Stage 10
implementation. A later documentation commit may naturally make `HEAD` newer,
so the ancestry check—not an assumption that `HEAD` never advances—establishes
the baseline. The checkout should be clean before assessment and should contain
no Stage 11 implementation.

Create one inspectable workspace outside the repository:

```sh
export RRP_SOURCE_ROOT="$(pwd)"
export RRP_ASSESSMENT_ROOT="$(mktemp -d /tmp/rrp-manual-assessment.XXXXXX)"
export RRP_LIBRARY="$RRP_ASSESSMENT_ROOT/library"
export RRP_ARCHIVES="$RRP_ASSESSMENT_ROOT/archives"
export RRP_SOFTWARE_ROOT="$RRP_ASSESSMENT_ROOT/software"
export RRP_PROJECT_ROOT="$RRP_ASSESSMENT_ROOT/fictional-hospital"

mkdir -p "$RRP_LIBRARY" "$RRP_ARCHIVES"
printf '%s\n' "$RRP_ASSESSMENT_ROOT"
```

Keep this terminal open. Later R sessions inherit these variables.

### What you should observe

- The assessment root is under `/tmp`, not under the repository.
- The isolated library and archive directory exist.
- The software root and project root do not yet exist.

> **Stage 11 assessment observation:** The human must choose and carry four
> roots manually. A future installation/activation experience should decide
> which locations it owns and which remain explicit operator inputs.

## 2. Build and install both packages

The current packages require R `>= 4.4.0`. Install declared external
dependencies into the isolated library, then build and install `rrpruntime`
before `rrpplatform`:

### Terminal

```sh
export R_LIBS="$RRP_LIBRARY"
export R_LIBS_USER="$RRP_LIBRARY"
export R_ENVIRON_USER=/dev/null
export R_PROFILE_USER=/dev/null

Rscript --vanilla -e '.libPaths(c(Sys.getenv("RRP_LIBRARY"), .Library)); install.packages(
  c("DBI", "duckdb", "shiny", "bslib", "plotly", "reactable", "brand.yml"),
  lib = Sys.getenv("RRP_LIBRARY"),
  repos = "https://cloud.r-project.org",
  dependencies = c("Depends", "Imports", "LinkingTo")
)'

cd "$RRP_ARCHIVES"
R CMD build --no-manual "$RRP_SOURCE_ROOT/packages/rrpruntime"
R CMD INSTALL --library="$RRP_LIBRARY" rrpruntime_0.4.0.9000.tar.gz
R CMD build --no-manual "$RRP_SOURCE_ROOT/packages/rrpplatform"
R CMD INSTALL --library="$RRP_LIBRARY" rrpplatform_0.1.0.9000.tar.gz
cd "$RRP_SOURCE_ROOT"
```

Verify package identity, version, and installed location in a fresh process:

```sh
Rscript --vanilla -e 'for (package in c("rrpruntime", "rrpplatform")) {
  .libPaths(c(Sys.getenv("RRP_LIBRARY"), .Library))
  library(package, character.only = TRUE)
  cat(package, as.character(packageVersion(package)), find.package(package), "\n")
}'
```

Expected development package versions are:

```text
rrpruntime  0.4.0.9000
rrpplatform 0.1.0.9000
```

Both installed paths should begin with the value of `RRP_LIBRARY`.

### What you should observe

- The two package archives are in `archives/`.
- Package installation is dependency ordered.
- RRP and its non-base dependencies resolve from the disposable isolated
  library, not from the checkout or the normal user library.

> **Stage 11 assessment observation:** Source builds, dependency installation,
> package order, library configuration, and archive naming are all manual. This
> is the principal distribution/install friction Stage 11 is expected to own.

## 3. Assemble the installed software resource root

Package installation and resource distribution are intentionally separate
today. No public installed RRP operation projects the source catalog into its
distribution-shaped form. The following one-time preparation reproduces the
accepted byte-preserving projection: it copies each declared source resource
to its declared installed path and writes the installed catalog without the
source-only `Source-Path` fields.

This is the only repository-specific resource assembly in the assessment. It
is preparation for assessing the installed platform, not a proposed Stage 11
interface.

### Terminal

```sh
Rscript --vanilla - "$RRP_SOURCE_ROOT" "$RRP_SOFTWARE_ROOT" <<'RRP_RESOURCES'
args <- commandArgs(trailingOnly = TRUE)
source_root <- normalizePath(args[[1L]], winslash = "/", mustWork = TRUE)
software_root <- args[[2L]]
stopifnot(!file.exists(software_root), !dir.exists(software_root))

source_catalog <- file.path(source_root, "resources", "source-catalog.dcf")
records <- read.dcf(source_catalog, all = TRUE)
stopifnot(nrow(records) > 1L)

catalog_fields <- c(
  "Record-Type", "Catalog-ID", "Catalog-Version", "Format-Version",
  "Product-ID", "Development-Version", "Status"
)
resource_fields <- c(
  "Record-Type", "Resource-ID", "Resource-Class", "Owner-Package",
  "Installed-Path", "Format"
)
stopifnot(all(c(catalog_fields, "Source-Path", resource_fields) %in%
  colnames(records)))

dir.create(software_root, recursive = TRUE)
catalog_lines <- paste0(
  catalog_fields, ": ", as.character(records[1L, catalog_fields])
)

for (index in 2:nrow(records)) {
  source_path <- records[index, "Source-Path"]
  installed_path <- records[index, "Installed-Path"]
  destination <- file.path(software_root, installed_path)
  dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(
    file.path(source_root, source_path), destination,
    overwrite = FALSE, copy.mode = FALSE, copy.date = FALSE
  ))
  catalog_lines <- c(
    catalog_lines,
    "",
    paste0(resource_fields, ": ", as.character(
      records[index, resource_fields]
    ))
  )
}

catalog_path <- file.path(software_root, "resources", "resource-catalog.dcf")
writeLines(catalog_lines, catalog_path, useBytes = TRUE)
cat(normalizePath(software_root, winslash = "/", mustWork = TRUE), "\n")
RRP_RESOURCES
```

Validate that installed boundary through the public package operation:

```sh
Rscript --vanilla -e 'library(rrpplatform)
result <- rrp_validate_software_resources(Sys.getenv("RRP_SOFTWARE_ROOT"))
print(result)
stopifnot(rrp_operation_succeeded(result), result$value$resource_count == 54L)'
```

### What you should observe

- `software/resources/resource-catalog.dcf` exists.
- The installed catalog declares 54 resources and contains no `Source-Path`
  field.
- `rrp_validate_software_resources()` succeeds using the isolated installed
  package.

> **Stage 11 assessment observation:** Installed packages cannot currently
> discover or create their matching software resource root. A closed
> distribution must own this version-matched assembly rather than asking an
> adopter to reproduce catalog projection.

## 4. Start the installed-software R session

### Terminal

Start R from the same terminal so the isolated-library and assessment-root
variables remain available:

```sh
cd "$RRP_ASSESSMENT_ROOT"
R --vanilla
```

### R

```r
library_root <- normalizePath(
  Sys.getenv("RRP_LIBRARY"), winslash = "/", mustWork = TRUE
)
.libPaths(c(library_root, .Library))

library(rrpruntime)
library(rrpplatform)

assessment_root <- normalizePath(
  Sys.getenv("RRP_ASSESSMENT_ROOT"), winslash = "/", mustWork = TRUE
)
software_root <- normalizePath(
  Sys.getenv("RRP_SOFTWARE_ROOT"), winslash = "/", mustWork = TRUE
)
project_root <- Sys.getenv("RRP_PROJECT_ROOT")

stopifnot(
  startsWith(normalizePath(find.package("rrpruntime"), winslash = "/"),
    paste0(library_root, "/")),
  startsWith(normalizePath(find.package("rrpplatform"), winslash = "/"),
    paste0(library_root, "/"))
)

packageVersion("rrpruntime")
packageVersion("rrpplatform")

software_validation <- rrp_validate_software_resources(software_root)
stopifnot(rrp_operation_succeeded(software_validation))
software_validation$value

catalog <- rrp_open_resource_catalog(software_root)
```

**From this point onward, the assessment uses the isolated installed RRP
packages and the independent project.** The source checkout is no longer an
operational input.

## 5. Create the ordinary fictional project

The simplest supported entry path is the public installed operation
`rrp_initialize_fictional_project()`. It renders cataloged installed templates
transactionally at one absent destination; the human does not recreate those
files manually.

### R

```r
initialized <- rrp_initialize_fictional_project(catalog, project_root)
print(initialized)
stopifnot(rrp_operation_succeeded(initialized))

project_files <- function() sort(list.files(
  project_root,
  recursive = TRUE,
  all.files = TRUE,
  no.. = TRUE,
  include.dirs = FALSE
), method = "radix")

project_files()
```

The exact initial inventory is:

```text
rrp-project.dcf
rrp-authoring.dcf
R/register.R
R/produce-canonical.R
R/calculate-risk.R
README.md
_brand.yml
assets/project-logo.png
R/generate-source.R
```

The six ordinary standard-authoring paths are `rrp-project.dcf`,
`rrp-authoring.dcf`, the three files under `R/` other than the generator, and
`README.md`. `_brand.yml` and its contained logo are bounded standard
declarative branding. `R/generate-source.R` is the one fictional-specific
addition.

| Path | Responsibility |
| --- | --- |
| `rrp-project.dcf` | Project identity, selected producer/provider, profile, API line, extension and state paths. |
| `rrp-authoring.dcf` | Truthful implementation/mapping identities and declared extension packages. |
| `R/register.R` | Thin trusted wiring from the project loader to standard authoring registration. |
| `R/produce-canonical.R` | Project-owned source validation, temporal filtering, identity mapping, and canonical-domain return. |
| `R/calculate-risk.R` | Project-owned provider callable over the governed request and private predictor. |
| `README.md` | Project-local human orientation. |
| `_brand.yml` | Bounded standard declarative display identity and color/logo reference. |
| `assets/project-logo.png` | Safe project-contained fictional logo. |
| `R/generate-source.R` | Explicit create-only generator for deterministic fictional source files. |

### What you should observe

- This directory is now **your project for the assessment**.
- It has no source, state, products, extension library, app source, or Git
  metadata yet.
- It is an ordinary project consumer, not a special application mode.

The fictional project is appropriate because it exercises the same project,
producer, provider, history, product, and application boundaries as a
conforming hospital project without requiring a real EHR schema, real identity
resolution, real patient data, or clinical model integration.

## 6. Read the project before executing it

Open these files in an editor or print bounded excerpts:

### R

```r
cat(readLines(file.path(project_root, "rrp-project.dcf")), sep = "\n")
cat(readLines(file.path(project_root, "rrp-authoring.dcf")), sep = "\n")
cat(readLines(file.path(project_root, "R", "register.R")), sep = "\n")
cat(readLines(file.path(project_root, "R", "generate-source.R")), sep = "\n")
cat(readLines(file.path(project_root, "R", "produce-canonical.R")), sep = "\n")
cat(readLines(file.path(project_root, "R", "calculate-risk.R")), sep = "\n")
```

Look for these boundaries:

- The manifest selects exact producer and provider identities.
- The authoring record declares implementation/mapping provenance and no
  extension packages.
- Registration delegates to `rrp_register_authored_project()`; a human does not
  call that operation directly because the authoritative loader supplies its
  trusted registration context.
- The generator creates controlled source bytes but is not run implicitly.
- The producer maps source-native identities and local event vocabulary into
  the two canonical domains while keeping the crosswalk and predictor private.
- The provider maps a canonical episode back to its private signal, enforces
  availability at the request cutoff, and returns one nonclinical probability.

## 7. Generate the first source realization

Source acquisition is project-owned. The fictional reference exposes its
supported mechanism as a single function in `R/generate-source.R`; loading this
project file is intentional and distinct from sourcing installed package code.

### R

```r
generator <- new.env(parent = baseenv())
sys.source(
  file.path(project_root, "R", "generate-source.R"),
  envir = generator,
  chdir = FALSE,
  keep.source = FALSE
)
generated <- generator$rrp_generate_fictional_source(project_root)
generated
project_files()
```

Inspect the generated source:

```r
source_root <- file.path(project_root, "source", "generated")
cat(readLines(file.path(source_root, "source.dcf")), sep = "\n")
utils::read.csv(file.path(source_root, "stays.csv"), check.names = FALSE)
utils::read.csv(file.path(source_root, "events.csv"), check.names = FALSE)
utils::read.csv(
  file.path(source_root, "identity-crosswalk.csv"), check.names = FALSE
)
```

### What you should observe

- Exactly four files now exist under `source/generated/`: `source.dcf`,
  `stays.csv`, `events.csv`, and `identity-crosswalk.csv`.
- There are four fictional stays, three event notifications, and twelve
  identity mappings.
- Native IDs and `LOCAL_*` event codes are visibly project-local.
- `provider_signal` and its availability timestamp are private provider input.
- The third notification occurred on January 19 but is unavailable until
  January 21. Its later admission demonstrates as-of behavior.

## 8. Validate the project and initialize state

`rrp_validate_project()` executes trusted registration and validates the
project boundary without invoking producer or provider behavior.

### R

```r
doctor_before_state <- rrp_validate_project(catalog, project_root)
print(doctor_before_state)
stopifnot(rrp_operation_succeeded(doctor_before_state))
doctor_before_state$value[c(
  "project_id", "project_version", "supported_rrp_api_version",
  "extension_library_status", "state_status"
)]
doctor_before_state$value$producer
doctor_before_state$value$provider
```

Expect `state_status` to be `not_initialized` and a warning diagnostic with
code `project_state_not_initialized`.

Initialize state explicitly:

```r
state_initialized <- rrp_initialize_project_state(catalog, project_root)
print(state_initialized)
stopifnot(rrp_operation_succeeded(state_initialized))
state_initialized$value

state_inspected <- rrp_inspect_project_state(catalog, project_root)
stopifnot(rrp_operation_succeeded(state_inspected))
state_inspected$value

doctor_after_state <- rrp_validate_project(catalog, project_root)
stopifnot(rrp_operation_succeeded(doctor_after_state))
doctor_after_state$value$state_status
project_files()
```

### What you should observe

- `state/state.dcf` and `state/history.duckdb` are created.
- State has a generated identity bound to the fictional project.
- Project diagnosis changes from `not_initialized` to `compatible`.
- History is initially empty; RRP has not pre-seeded fictional outcomes.

Do not edit `state.dcf` or query/write `history.duckdb` directly. Their physical
representation belongs to RRP; use public state/history operations.

## 9. Inspect the first producer boundary

Use the first accepted analytical time from the Stage 10 fictional experience:

### R

```r
first_time <- "2026-01-19T12:00:00Z"
first_produced <- rrp_execute_producer(catalog, project_root, first_time)
print(first_produced$status)
stopifnot(rrp_operation_succeeded(first_produced))

first_bundle <- first_produced$value
first_bundle$bundle_instance_id
first_bundle$domains$discharge_episode
first_bundle$domains$terminal_event
```

Conceptually:

```text
fictional source
    ↓ project-owned validation, availability filtering, identity/code mapping
project-owned producer
    ↓ closed result envelope
canonical handoff
    ↓ RRP identity, shape, relationship, capability, and temporal admission
admitted canonical bundle
```

### What you should observe

- Four canonical discharge episodes and two available terminal events are
  admitted.
- The later-available third notification is absent at this cutoff.
- Canonical output contains canonical identities and vocabulary, not native
  `FIC*` identifiers, crosswalk rows, local event codes, or `provider_signal`.
- The project owns the source meaning and truthful mapping; RRP owns the closed
  producer envelope and canonical admission rules.

## 10. Inspect the first provider boundary

Call the normal platform wrapper for the one eligible episode; do not call the
fictional provider function directly:

### R

```r
first_estimated <- rrp_execute_risk(
  catalog,
  project_root,
  first_bundle,
  "fictional.episode.001",
  first_time
)
print(first_estimated$status)
stopifnot(rrp_operation_succeeded(first_estimated))

first_estimated$value[c(
  "episode_id", "as_of_time", "target_id", "target_interval_start",
  "target_interval_end", "provider_id", "provider_version",
  "implementation_id", "implementation_version", "model_id",
  "model_version", "output_type", "estimate_value"
)]
```

Conceptually:

```text
eligible admitted episode
    ↓ detached provider-neutral request for the singular governed target
project-owned provider
    ↓ one finite probability
RRP runtime validation
    ↓
accepted risk estimate
```

### What you should observe

- The accepted estimate is exactly `0.39` for `fictional.episode.001`.
- Provider identity is `fictional-reference-hospital.provider`; model identity
  is absent in this fictional declaration.
- The target is remaining readmission risk through the fixed 30-day window,
  not baseline or discharge risk.
- This standalone inspection does not write durable history.

## 11. Execute the first governed analytical operation

The durable operation is distinct from the two boundary inspections above. It
selects and invokes the producer, admits the bundle, evaluates each member,
invokes the provider for eligible members, and appends one complete governed
scope to project history.

### R

```r
first_run <- rrp_execute_durable_bundle(
  catalog,
  project_root,
  first_time,
  "manual-assessment-first"
)
print(first_run)
stopifnot(rrp_operation_succeeded(first_run), isTRUE(first_run$value$complete))

first_operation_run_id <- first_run$value$operation_run_id
first_run$value
```

### What you should observe

- The result reports one operation-run identity, four expected episodes, four
  dispositions, and `complete = TRUE`.
- Episode 001 is accepted at `0.39`.
- Episode 002 is ineligible because it was already readmitted.
- Episode 003 is ineligible because it was already dead.
- Episode 004 is ineligible because the target horizon was exhausted.
- Only the eligible episode invokes the provider.
- `state/history.duckdb` changes, but the project gains no new executable or
  source file.

## 12. Inspect the first governed history

### R

```r
first_scope <- rrp_inspect_scope_history(
  catalog, project_root, first_operation_run_id
)
stopifnot(rrp_operation_succeeded(first_scope))

first_scope$value$scope
first_scope$value$progress

first_dispositions <- first_scope$value$dispositions
data.frame(
  episode_id = vapply(first_dispositions, `[[`, character(1L), "episode_id"),
  outcome = vapply(first_dispositions, `[[`, character(1L), "outcome"),
  outcome_code = vapply(
    first_dispositions, `[[`, character(1L), "outcome_code"
  ),
  estimate_value = vapply(first_dispositions, function(value) {
    if (is.null(value$estimate)) NA_real_ else value$estimate$estimate_value
  }, numeric(1L))
)

target_id <- first_scope$value$scope$target_id
first_episode_history <- rrp_inspect_episode_history(
  catalog, project_root, "fictional.episode.001", target_id, first_time
)
first_current_history <- rrp_inspect_current_history(
  catalog, project_root, "fictional.episode.001", target_id,
  first_time, first_time
)
stopifnot(
  rrp_operation_succeeded(first_episode_history),
  rrp_operation_succeeded(first_current_history)
)
first_current_history$value$estimate$estimate_value
```

### What you should observe

- Scope history answers which admitted membership and analytical time the run
  represents and whether all members reached a terminal disposition.
- Dispositions distinguish accepted, ineligible, incompatible, declared
  failure, and detected failure outcomes. This realization has one accepted,
  three ineligible, and no provider failures.
- Episode history retains the actual accepted estimate and its attribution.
- Public reads return detached logical values; no direct DuckDB knowledge is
  required.

## 13. Build the first Stage 9 product set

Logical construction reads one explicit complete history scope at one explicit
history cutoff and returns a detached three-member set. It does not publish
files yet.

### R

```r
first_built <- rrp_build_product_set(
  catalog,
  project_root,
  first_operation_run_id,
  first_time
)
print(first_built$status)
stopifnot(rrp_operation_succeeded(first_built))

first_product_set <- first_built$value
first_product_set$product_set_id
names(first_product_set$members)
vapply(first_product_set$members, function(member) nrow(member$data), integer(1L))
```

The set authority is
`rrp.product-set.initial-readmission-risk@0.1.0` and its members are:

1. current remaining risk;
2. actual remaining-risk trajectory; and
3. operational scope summary.

Logical product construction determines content and lineage. Physical
materialization is the next, separate operation.

### What you should observe

- Current risk has one row at `0.39`.
- Trajectory has one actual observation at `2026-01-19T12:00:00Z`.
- Scope summary has one row reconciling four expected, one eligible/accepted,
  and three ineligible episodes.
- `state/products/` still does not exist.

## 14. Materialize and read the first products

### R

```r
first_published <- rrp_materialize_product_set(
  catalog, project_root, first_product_set
)
print(first_published)
stopifnot(rrp_operation_succeeded(first_published))

first_access_result <- rrp_open_product_access(
  catalog, project_root, first_operation_run_id, first_time
)
stopifnot(rrp_operation_succeeded(first_access_result))
first_access <- first_access_result$value

first_inventory <- rrp_list_products(first_access)
first_inventory

first_current <- rrp_read_product(
  first_access, "rrp.product.current-remaining-risk", "0.1.0"
)
first_trajectory <- rrp_read_product(
  first_access, "rrp.product.remaining-risk-trajectory", "0.1.0"
)
first_summary <- rrp_read_product(
  first_access, "rrp.product.operational-scope-summary", "0.1.0"
)

first_current$data
first_trajectory$data
first_summary$data
project_files()
```

### What you should observe

- `state/products/current.dcf` points to an immutable realization below
  `state/products/sets/`.
- That set contains `product-set.dcf` plus three CSV members.
- Product access reports `fresh` because expected operation and cutoff were
  supplied.
- Current remaining risk represents the one current accepted estimate.
- Trajectory contains the one actual retained observation—no invented daily
  points.
- Scope summary directly reconciles accepted/failure/ineligible counts.

## 15. Launch and inspect the first application

`rrp_launch_app()` is blocking. Run it at the R prompt, inspect the browser,
then return to R by interrupting the operation with Ctrl+C. Closing a browser
tab alone may not stop the R Shiny process.

### R

```r
rrp_launch_app(
  catalog,
  project_root,
  expected_operation_run_id = first_operation_run_id,
  history_cutoff = first_time,
  launch_browser = TRUE
)
```

### Browser / Shiny application

Inspect:

- **Current Risk Pool:** one current row, exact `39.0%`, continuous risk bar,
  a one-marker sparkline, analytical time, remaining follow-up, provider/model
  attribution, episode search, exact filters, sorting, and paging.
- **Episode Risk Trajectory:** one actual marker, fixed probability scale,
  exact tooltip, and one-row observation table.
- **Overview:** current count and direct distribution values plus four expected,
  one accepted, and three ineligible with the three realized subcategories.
- **Branding/state:** Fictional Hospital identity/logo and a fresh product
  realization.

### What you should observe

- There are exactly two top-level views: Current Risk Pool and Overview.
- Trajectory is contextual to the selected episode, not a third top-level view.
- One analytical run produces one observation, not a fabricated trend.
- The app reads products; it does not invoke the producer/provider, write
  history, or build/materialize products.

After inspection, press Ctrl+C in the R terminal. New results require another
platform operation, new products, and a relaunch. That is intentional Stage 10
behavior.

## 16. Perform the second analytical run

The fictional source files do not change. The next accepted scenario advances
the authoritative as-of time by one day; the producer re-applies availability
and the provider calculates remaining risk at the newer cutoff.

### R

```r
second_time <- "2026-01-20T12:00:00Z"

second_produced <- rrp_execute_producer(catalog, project_root, second_time)
stopifnot(rrp_operation_succeeded(second_produced))
second_produced$value$domains$discharge_episode
second_produced$value$domains$terminal_event

second_run <- rrp_execute_durable_bundle(
  catalog,
  project_root,
  second_time,
  "manual-assessment-second"
)
print(second_run)
stopifnot(rrp_operation_succeeded(second_run), isTRUE(second_run$value$complete))

second_operation_run_id <- second_run$value$operation_run_id
second_scope <- rrp_inspect_scope_history(
  catalog, project_root, second_operation_run_id
)
stopifnot(rrp_operation_succeeded(second_scope))
second_scope$value$progress

second_episode_history <- rrp_inspect_episode_history(
  catalog, project_root, "fictional.episode.001", target_id, second_time
)
stopifnot(rrp_operation_succeeded(second_episode_history))
vapply(
  second_episode_history$value$dispositions,
  function(value) {
    if (is.null(value$estimate)) NA_real_ else value$estimate$estimate_value
  },
  numeric(1L)
)
project_files()
```

### What you should observe

- The source bytes are unchanged; analytical interpretation advances from
  January 19 to January 20.
- A distinct governed operation is complete for the same four episodes.
- Episode 001 now has another actual accepted estimate,
  `0.3833333333333333`; the earlier `0.39` remains in history.
- The remaining episodes keep the same ineligibility reasons.
- Durable execution changes history, not the project authoring/source files.

## 17. Build and materialize the newer products

### R

```r
second_built <- rrp_build_product_set(
  catalog,
  project_root,
  second_operation_run_id,
  second_time
)
stopifnot(rrp_operation_succeeded(second_built))
second_product_set <- second_built$value

second_published <- rrp_materialize_product_set(
  catalog, project_root, second_product_set
)
stopifnot(rrp_operation_succeeded(second_published))

second_access_result <- rrp_open_product_access(
  catalog, project_root, second_operation_run_id, second_time
)
stopifnot(rrp_operation_succeeded(second_access_result))
second_access <- second_access_result$value

second_inventory <- rrp_list_products(second_access)
second_current <- rrp_read_product(
  second_access, "rrp.product.current-remaining-risk", "0.1.0"
)
second_trajectory <- rrp_read_product(
  second_access, "rrp.product.remaining-risk-trajectory", "0.1.0"
)
second_summary <- rrp_read_product(
  second_access, "rrp.product.operational-scope-summary", "0.1.0"
)

second_inventory
second_current$data
second_trajectory$data
second_summary$data

data.frame(
  realization = c("first", "second"),
  product_set_id = c(
    first_access$product_set_id,
    second_access$product_set_id
  ),
  analytical_time = c(
    first_access$source_analytical_time,
    second_access$source_analytical_time
  ),
  current_risk = c(
    first_current$data$estimate_value,
    second_current$data$estimate_value
  ),
  trajectory_rows = c(
    nrow(first_trajectory$data),
    nrow(second_trajectory$data)
  )
)
project_files()
```

### What you should observe

- The first and second product-set identities differ.
- The first immutable set remains stored while `current.dcf` advances to the
  second materialization.
- Current risk advances from `0.39` to `0.3833333333333333`.
- Trajectory now contains exactly these two actual observations:

```text
2026-01-19T12:00:00Z  0.39
2026-01-20T12:00:00Z  0.3833333333333333
```

- Scope reconciliation remains four expected, one eligible/accepted, and three
  ineligible.

## 18. Relaunch and inspect the changed application

### R

```r
rrp_launch_app(
  catalog,
  project_root,
  expected_operation_run_id = second_operation_run_id,
  history_cutoff = second_time,
  launch_browser = TRUE
)
```

### Browser / Shiny application

Confirm that:

- current probability is now `38.3%`;
- the row sparkline has two actual markers and one visual connector;
- the trajectory has the exact `0.39` and `0.3833333333333333` observations;
- the exact observation table has two rows;
- analytical time advances to January 20;
- provider attribution is unchanged;
- scope facts remain reconciled; and
- product state is fresh for the supplied expected operation/cutoff.

The application did not learn, poll, or refresh itself. The visible change
exists because the human deliberately executed a later analytical operation,
built a new logical product set, materialized it, stopped the old app, and
relaunched against the newer products.

Stop the second app with Ctrl+C.

## 19. Optional third progression: later-available death

This accepted fictional scenario is optional. At January 22, the third source
notification has become available. It reports that episode 001 died on January
19, so the newer scope makes that episode ineligible while its earlier accepted
trajectory remains governed historical evidence.

### R

```r
third_time <- "2026-01-22T12:00:00Z"
third_run <- rrp_execute_durable_bundle(
  catalog,
  project_root,
  third_time,
  "manual-assessment-third"
)
stopifnot(rrp_operation_succeeded(third_run), isTRUE(third_run$value$complete))

third_scope <- rrp_inspect_scope_history(
  catalog, project_root, third_run$value$operation_run_id
)
stopifnot(rrp_operation_succeeded(third_scope))

third_built <- rrp_build_product_set(
  catalog,
  project_root,
  third_run$value$operation_run_id,
  third_time
)
stopifnot(rrp_operation_succeeded(third_built))
stopifnot(rrp_operation_succeeded(rrp_materialize_product_set(
  catalog, project_root, third_built$value
)))

third_access_result <- rrp_open_product_access(
  catalog, project_root, third_run$value$operation_run_id, third_time
)
stopifnot(rrp_operation_succeeded(third_access_result))
third_access <- third_access_result$value

rrp_read_product(
  third_access, "rrp.product.current-remaining-risk", "0.1.0"
)$data
rrp_read_product(
  third_access, "rrp.product.remaining-risk-trajectory", "0.1.0"
)$data
rrp_read_product(
  third_access, "rrp.product.operational-scope-summary", "0.1.0"
)$data
```

### What you should observe

- Current remaining risk has zero rows because no episode is currently
  eligible/accepted in the selected newer scope.
- Retained trajectory still contains the two actual earlier accepted estimates.
- Scope summary now reports episode 001 as already dead in addition to the
  existing ineligible outcomes.
- A relaunch would show a coherent empty Current Risk Pool while retaining the
  historically inspectable trajectory episode.

## 20. Watch the project evolve on disk

Use `project_files()` at the checkpoints above. The expected progression is:

| Checkpoint | Files/state added or changed |
| --- | --- |
| Project creation | Nine initialized authoring/branding/reference files. |
| Source generation | Four project-owned files under `source/generated/`. |
| State initialization | `state/state.dcf` and `state/history.duckdb`. |
| First durable run | Durable history changes inside `history.duckdb`; no new public file family. |
| First materialization | `state/products/current.dcf` and one immutable set containing one DCF manifest and three CSV members. |
| Second durable run | History accumulates another governed scope/estimate. |
| Second materialization | A second immutable set appears and the current pointer advances. |

Observe these paths, but do not edit state, history, current pointers, or
materialized product members manually.

## 21. Ownership experienced in this assessment

| Concern | Owner |
| --- | --- |
| Source/EHR acquisition and adaptation | Project/hospital |
| Canonical producer and local mapping | Project/hospital |
| Native-to-canonical identity and predictor legitimacy | Project/hospital |
| Risk provider/model behavior and provenance | Project/hospital |
| Canonical/runtime/result validation | RRP |
| Producer/provider protocol envelopes and selection | RRP |
| Durable analytical history | RRP, within project-owned state |
| Logical product construction | RRP |
| Product materialization and validated access | RRP, within project-owned state |
| Supplied application and executable composition | RRP |
| Declarative identity/color/logo branding | Project/hospital |

The raw registration, producer, and provider contracts remain available as
lower-level extension boundaries. This fictional project uses the narrower
standard-authoring path that RRP adapts into those contracts.

## 22. Current friction to notice

These observations are not Stage 11 designs or recommendations. Record how they
feel during the exercise:

> **Stage 11 assessment observation:** Obtaining runnable software currently
> requires a source checkout, external dependency installation, two package
> builds, dependency-ordered installation, and manual resource projection.

> **Stage 11 assessment observation:** The operator must configure and retain an
> isolated library root, software root, project root, analytical times,
> operation keys, operation-run identities, and product cutoffs.

> **Stage 11 assessment observation:** Every lifecycle action is an R function
> call. There is no canonical terminal command, activation mechanism, or
> installed doctor that combines package/resource/project readiness.

> **Stage 11 assessment observation:** Project registration is correctly hidden
> behind the trusted loader, but the distinction between validation, standalone
> producer/provider inspection, durable execution, logical construction, and
> materialization requires deliberate explanation.

> **Stage 11 assessment observation:** Repeated runs require the human to
> coordinate analytical operation, product construction, publication, and app
> relaunch. Stage 10 intentionally performs no automatic refresh.

Do not solve these points during the assessment. They are direct evidence for
later Stage 11 planning.

## Questions to answer before Stage 11

- Did the independent project boundary feel understandable?
- Was it obvious what belonged to RRP versus the project/hospital?
- Was source generation and canonical production understandable?
- Was the difference between native identity and canonical identity clear?
- Was the provider boundary and singular remaining-risk target understandable?
- Was the difference between standalone producer/provider inspection and the
  durable operation clear?
- Could I tell which episodes were accepted, failed, or ineligible and why?
- Did durable history feel observable without exposing DuckDB internals?
- Was the distinction between logical construction and physical
  materialization clear?
- Did the relationship between history, products, and application presentation
  make sense?
- Did the first app launch reflect the first governed realization?
- Did the second operation visibly accumulate actual trajectory history?
- Was it obvious why the application required relaunch?
- Which R operations felt like they should become CLI commands?
- Which build, dependency, resource-projection, and library steps should
  disappear behind Stage 11 installation?
- What information did I have to carry manually between operations?
- Where did I need implementation knowledge that a hospital adopter should not
  need?
- What should installation, activation, upgrade, rollback, and uninstall own?

Do not answer these questions in this document. Record the human's observations
separately after performing the assessment.

## 23. Cleanup

First ensure every application invocation has been interrupted and the R prompt
has returned. Then exit R without saving workspace state:

### R

```r
q(save = "no")
```

Back in the original terminal, inspect the target one last time and remove only
the disposable assessment workspace:

### Terminal

```sh
printf 'Disposable assessment root: %s\n' "$RRP_ASSESSMENT_ROOT"
test -n "$RRP_ASSESSMENT_ROOT"
test "$RRP_ASSESSMENT_ROOT" != "/"
rm -rf -- "$RRP_ASSESSMENT_ROOT"
```

This removes the isolated library, package archives, software resource root,
fictional project, source, history, and products together. It does not remove
or modify the source repository.

## Public-operation inventory used

Every RRP function called as an installed platform operation above is exported:

| Package | Public operation | Purpose/effect |
| --- | --- | --- |
| `rrpplatform` | `rrp_validate_software_resources(software_root)` | Validate the explicit installed resource boundary; no mutation. |
| `rrpplatform` | `rrp_open_resource_catalog(software_root)` | Open validated explicit-root resource access; no mutation. |
| `rrpplatform` | `rrp_initialize_fictional_project(catalog, project_root)` | Transactionally create the absent nine-file fictional project. |
| `rrpplatform` | `rrp_validate_project(catalog, project_root)` | Execute trusted registration and report bounded project/state status without producer/provider invocation. |
| `rrpplatform` | `rrp_initialize_project_state(catalog, project_root)` | Create compatible state metadata and empty DuckDB history. |
| `rrpplatform` | `rrp_inspect_project_state(catalog, project_root)` | Inspect compatible state without mutation. |
| `rrpplatform` | `rrp_execute_producer(catalog, project_root, as_of_time)` | Invoke selected producer once and return an admitted detached canonical bundle. |
| `rrpplatform` | `rrp_execute_risk(catalog, project_root, bundle, episode_id, as_of_time)` | Prepare one eligible state, invoke the selected provider once, and return an accepted estimate. |
| `rrpplatform` | `rrp_execute_durable_bundle(catalog, project_root, analytical_time, operation_key)` | Execute/admit/evaluate one scope and append complete durable terminal history. |
| `rrpplatform` | `rrp_inspect_scope_history(catalog, project_root, operation_run_id)` | Read detached raw scope history and progress. |
| `rrpplatform` | `rrp_inspect_episode_history(catalog, project_root, episode_id, target_id, history_cutoff)` | Read detached episode history through a history cutoff. |
| `rrpplatform` | `rrp_inspect_current_history(catalog, project_root, episode_id, target_id, analytical_cutoff, history_cutoff)` | Read one effective current disposition. |
| `rrpplatform` | `rrp_build_product_set(catalog, project_root, operation_run_id, history_cutoff)` | Construct the detached three-member logical set. |
| `rrpplatform` | `rrp_materialize_product_set(catalog, project_root, product_set)` | Publish the validated set and advance the current pointer. |
| `rrpplatform` | `rrp_open_product_access(catalog, project_root, expected_operation_run_id, history_cutoff)` | Validate/reopen detached product access and assess freshness. |
| `rrpplatform` | `rrp_list_products(product_access)` | List exact product identity/version/lineage metadata. |
| `rrpplatform` | `rrp_read_product(product_access, product_id, product_version)` | Return one detached logical product. |
| `rrpplatform` | `rrp_launch_app(catalog, project_root, expected_operation_run_id, history_cutoff, launch_browser, port)` | Validate current products/branding and run the installed loopback application until stopped. |
| `rrpplatform` | `rrp_operation_succeeded(result)` | Interpret a validated common operation result. |

Two necessary actions are not installed RRP public operations:

1. pre–Stage 11 resource projection from the accepted source checkout; and
2. explicit execution of the fictional project's own source generator.

The first is a genuine distribution/install capability gap. The second is
intentional project-owned source behavior and is not supposed to become an RRP
analytical implementation detail.
