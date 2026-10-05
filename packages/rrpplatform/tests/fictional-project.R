library(rrpplatform)

arguments <- commandArgs(trailingOnly = TRUE)
software_root <- if (length(arguments) >= 1L) arguments[[1L]] else {
  Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
}
stopifnot(nzchar(software_root), dir.exists(software_root))
software_root <- normalizePath(software_root, winslash = "/", mustWork = TRUE)
catalog <- rrp_open_resource_catalog(software_root)

suite_root <- tempfile("rrp-fictional-project-")
dir.create(suite_root)
on.exit(unlink(suite_root, recursive = TRUE, force = TRUE), add = TRUE)

project_root <- file.path(suite_root, "fictional-project")
initialized <- rrp_initialize_fictional_project(catalog, project_root)
expected_created <- c(
  "rrp-project.dcf", "rrp-authoring.dcf", "R/register.R",
  "R/produce-canonical.R", "R/calculate-risk.R", "README.md",
  "_brand.yml", "assets/project-logo.png",
  "R/generate-source.R"
)
stopifnot(
  identical(initialized$operation_id, "rrp.initialize-fictional-project"),
  identical(initialized$status, "success"),
  identical(initialized$diagnostics, list()),
  identical(initialized$value$project_id, "fictional-reference-hospital"),
  identical(initialized$value$project_version, "1.0.0"),
  identical(initialized$value$extension_packages, list()),
  identical(initialized$value$created_paths, expected_created),
  identical(sort(list.files(
    project_root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = FALSE
  ), method = "radix"), sort(expected_created, method = "radix")),
  !dir.exists(file.path(project_root, "source")),
  !dir.exists(file.path(project_root, "state")),
  !dir.exists(file.path(project_root, "extensions")),
  grepl("Fictional Reference Hospital", paste(readLines(
    file.path(project_root, "_brand.yml"), warn = FALSE
  ), collapse = "\n"), fixed = TRUE),
  identical(
    readBin(
      file.path(project_root, "assets", "project-logo.png"), "raw", n = 8L
    ),
    as.raw(c(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a))
  )
)

context <- rrp_load_project(catalog, project_root)
doctor <- rrp_validate_project(catalog, project_root)
stopifnot(
  identical(context$producer$component_id,
            "fictional-reference-hospital.producer"),
  identical(context$provider$component_id,
            "fictional-reference-hospital.provider"),
  identical(context$producer$origin, "project"),
  identical(context$provider$origin, "project"),
  is.null(context$provider$model_id), is.null(context$provider$model_version),
  identical(doctor$status, "success"),
  identical(doctor$diagnostics[[1L]]$code, "project_state_not_initialized")
)

generator_environment <- new.env(parent = baseenv())
sys.source(
  file.path(project_root, "R", "generate-source.R"),
  envir = generator_environment, chdir = FALSE, keep.source = FALSE
)
stopifnot(identical(
  ls(generator_environment, all.names = TRUE), "rrp_generate_fictional_source"
))
generated_names <- generator_environment$rrp_generate_fictional_source(project_root)
generated_root <- file.path(project_root, "source", "generated")
expected_generated <- c(
  "events.csv", "identity-crosswalk.csv", "source.dcf", "stays.csv"
)
stopifnot(
  identical(sort(generated_names, method = "radix"), expected_generated),
  identical(sort(list.files(
    generated_root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = FALSE
  ), method = "radix"), expected_generated)
)
read_raw <- function(path) readBin(path, "raw", n = file.info(path)$size)
first_bytes <- lapply(file.path(generated_root, expected_generated), read_raw)
generator_environment$rrp_generate_fictional_source(project_root)
stopifnot(identical(
  first_bytes, lapply(file.path(generated_root, expected_generated), read_raw)
))

second_root <- file.path(suite_root, "second-fictional-project")
stopifnot(identical(
  rrp_initialize_fictional_project(catalog, second_root)$status, "success"
))
second_generator <- new.env(parent = baseenv())
sys.source(
  file.path(second_root, "R", "generate-source.R"),
  envir = second_generator, chdir = FALSE, keep.source = FALSE
)
second_generator$rrp_generate_fictional_source(second_root)
stopifnot(identical(first_bytes, lapply(file.path(
  second_root, "source", "generated", expected_generated
), read_raw)))

stays <- read.csv(
  file.path(generated_root, "stays.csv"), colClasses = "character",
  na.strings = character(), check.names = FALSE, stringsAsFactors = FALSE
)
crosswalk <- read.csv(
  file.path(generated_root, "identity-crosswalk.csv"),
  colClasses = "character", na.strings = character(), check.names = FALSE,
  stringsAsFactors = FALSE
)
stopifnot(
  any(!grepl(
    "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$", stays$native_stay_id,
    perl = TRUE
  )),
  identical(
    crosswalk$canonical_id[
      crosswalk$identity_type == "episode" &
        crosswalk$native_id == "FIC STAY/001"
    ],
    "fictional.episode.001"
  )
)

as_of_time <- "2026-01-20T12:00:00Z"
produced <- rrp_execute_producer(catalog, project_root, as_of_time)
stopifnot(
  identical(produced$status, "success"),
  nrow(produced$value$domains$discharge_episode) == 4L,
  nrow(produced$value$domains$terminal_event) == 2L,
  identical(
    produced$value$domains$terminal_event$event_type,
    c("readmission", "death")
  ),
  !"fictional.event.003" %in%
    produced$value$domains$terminal_event$terminal_event_id
)
canonical_text <- paste(capture.output(str(produced$value$domains)), collapse = " ")
stopifnot(
  !grepl("FIC ", canonical_text, fixed = TRUE),
  !grepl("FIC-", canonical_text, fixed = TRUE),
  !grepl("LOCAL_", canonical_text, fixed = TRUE),
  !grepl("provider_signal", canonical_text, fixed = TRUE),
  !grepl("identity-crosswalk", canonical_text, fixed = TRUE)
)

estimated <- rrp_execute_risk(
  catalog, project_root, produced$value, "fictional.episode.001", as_of_time
)
stopifnot(
  identical(estimated$status, "success"),
  identical(estimated$value$episode_id, "fictional.episode.001"),
  identical(estimated$value$provider_id,
            "fictional-reference-hospital.provider"),
  isTRUE(all.equal(estimated$value$estimate_value, 0.3833333333333333))
)

copy_project <- function(name) {
  parent <- file.path(suite_root, paste0(name, "-parent"))
  dir.create(parent)
  stopifnot(file.copy(
    project_root, parent, recursive = TRUE, copy.mode = FALSE,
    copy.date = FALSE
  ))
  file.path(parent, basename(project_root))
}

missing_root <- copy_project("missing-predictor")
missing_path <- file.path(missing_root, "source", "generated", "stays.csv")
missing_stays <- read.csv(
  missing_path, colClasses = "character", na.strings = character(),
  check.names = FALSE, stringsAsFactors = FALSE
)
missing_stays$provider_signal[[1L]] <- ""
write.csv(missing_stays, missing_path, row.names = FALSE, quote = FALSE)
missing <- rrp_execute_risk(
  catalog, missing_root, produced$value, "fictional.episode.001", as_of_time
)
stopifnot(
  identical(missing$status, "failure"),
  identical(missing$diagnostics[[1L]]$code, "provider_input_unavailable")
)

late_root <- copy_project("late-predictor")
late_path <- file.path(late_root, "source", "generated", "stays.csv")
late_stays <- read.csv(
  late_path, colClasses = "character", na.strings = character(),
  check.names = FALSE, stringsAsFactors = FALSE
)
late_stays$provider_signal_available_at[[1L]] <- "2026-01-21T12:00:00Z"
write.csv(late_stays, late_path, row.names = FALSE, quote = FALSE)
late <- rrp_execute_risk(
  catalog, late_root, produced$value, "fictional.episode.001", as_of_time
)
stopifnot(
  identical(late$status, "failure"),
  identical(late$diagnostics[[1L]]$code, "provider_input_unavailable")
)

source_failure_root <- copy_project("source-failure")
event_path <- file.path(
  source_failure_root, "source", "generated", "events.csv"
)
events <- read.csv(
  event_path, colClasses = "character", na.strings = character(),
  check.names = FALSE, stringsAsFactors = FALSE
)
events$event_code[[1L]] <- "UNKNOWN_LOCAL_CODE"
write.csv(events, event_path, row.names = FALSE, quote = FALSE)
source_failure <- rrp_execute_producer(
  catalog, source_failure_root, as_of_time
)
stopifnot(
  identical(source_failure$status, "failure"),
  identical(source_failure$diagnostics[[1L]]$code, "producer_source_failed")
)

duplicate_root <- copy_project("duplicate-key")
duplicate_path <- file.path(
  duplicate_root, "source", "generated", "stays.csv"
)
duplicate_stays <- read.csv(
  duplicate_path, colClasses = "character", na.strings = character(),
  check.names = FALSE, stringsAsFactors = FALSE
)
duplicate_stays$native_stay_id[[2L]] <- duplicate_stays$native_stay_id[[1L]]
write.csv(duplicate_stays, duplicate_path, row.names = FALSE, quote = FALSE)
duplicate <- rrp_execute_producer(catalog, duplicate_root, as_of_time)
stopifnot(
  identical(duplicate$status, "failure"),
  identical(duplicate$diagnostics[[1L]]$code, "producer_source_failed")
)

relationship_root <- copy_project("unresolved-relationship")
relationship_path <- file.path(
  relationship_root, "source", "generated", "events.csv"
)
relationship_events <- read.csv(
  relationship_path, colClasses = "character", na.strings = character(),
  check.names = FALSE, stringsAsFactors = FALSE
)
relationship_events$native_stay_id[[1L]] <- "FIC-MISSING-STAY"
write.csv(
  relationship_events, relationship_path, row.names = FALSE, quote = FALSE
)
relationship <- rrp_execute_producer(
  catalog, relationship_root, as_of_time
)
stopifnot(
  identical(relationship$status, "failure"),
  identical(relationship$diagnostics[[1L]]$code, "producer_source_failed")
)

time_root <- copy_project("invalid-time")
time_path <- file.path(time_root, "source", "generated", "stays.csv")
time_stays <- read.csv(
  time_path, colClasses = "character", na.strings = character(),
  check.names = FALSE, stringsAsFactors = FALSE
)
time_stays$provider_signal_available_at[[1L]] <- "2026-01-01T00:00:00Z"
write.csv(time_stays, time_path, row.names = FALSE, quote = FALSE)
invalid_time <- rrp_execute_producer(catalog, time_root, as_of_time)
stopifnot(
  identical(invalid_time$status, "failure"),
  identical(invalid_time$diagnostics[[1L]]$code, "producer_source_failed")
)

mapping_failure_root <- copy_project("mapping-failure")
crosswalk_path <- file.path(
  mapping_failure_root, "source", "generated", "identity-crosswalk.csv"
)
invalid_crosswalk <- read.csv(
  crosswalk_path, colClasses = "character", na.strings = character(),
  check.names = FALSE, stringsAsFactors = FALSE
)
invalid_crosswalk$canonical_id[[1L]] <- "INVALID CANONICAL ID"
write.csv(invalid_crosswalk, crosswalk_path, row.names = FALSE, quote = FALSE)
mapping_failure <- rrp_execute_producer(
  catalog, mapping_failure_root, as_of_time
)
stopifnot(
  identical(mapping_failure$status, "failure"),
  identical(mapping_failure$diagnostics[[1L]]$code, "producer_mapping_failed")
)

changed_path <- file.path(generated_root, "stays.csv")
changed_bytes <- read_raw(changed_path)
writeBin(c(changed_bytes, charToRaw("changed\n")), changed_path)
generation_condition <- tryCatch({
  generator_environment$rrp_generate_fictional_source(project_root)
  NULL
}, error = identity)
stopifnot(
  inherits(generation_condition, "error"),
  identical(
    conditionMessage(generation_condition),
    "Generated fictional source already exists and differs."
  )
)

# The source mutation above belongs only to the original; use the untouched
# second realization for the positive copied-project portability proof.
portable_parent <- file.path(suite_root, "portable-clean-parent")
dir.create(portable_parent)
stopifnot(file.copy(
  second_root, portable_parent, recursive = TRUE, copy.mode = FALSE,
  copy.date = FALSE
))
portable_root <- file.path(portable_parent, basename(second_root))
portable <- rrp_execute_producer(catalog, portable_root, as_of_time)
portable_estimate <- rrp_execute_risk(
  catalog, portable_root, portable$value, "fictional.episode.001", as_of_time
)
stopifnot(
  identical(portable$status, "success"),
  identical(portable$value$domains, produced$value$domains),
  identical(portable_estimate$status, "success"),
  !dir.exists(file.path(portable_root, ".git")),
  !dir.exists(file.path(portable_root, "state"))
)

walkthrough <- rrp_resource_path(
  catalog, "rrp.documentation.fictional-reference-walkthrough"
)
walkthrough_text <- paste(readLines(
  walkthrough, warn = FALSE, encoding = "UTF-8"
), collapse = "\n")
stopifnot(
  grepl("rrp_initialize_fictional_project", walkthrough_text, fixed = TRUE),
  grepl("rrp_generate_fictional_source", walkthrough_text, fixed = TRUE),
  grepl("rrp_execute_durable_bundle", walkthrough_text, fixed = TRUE)
)

existing <- rrp_initialize_fictional_project(catalog, project_root)
stopifnot(
  identical(existing$status, "failure"),
  identical(existing$diagnostics[[1L]]$code, "project_destination_exists")
)

cat("rrpplatform fictional-project tests passed\n")
