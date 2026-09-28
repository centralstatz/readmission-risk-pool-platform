library(rrpplatform)

arguments <- commandArgs(trailingOnly = TRUE)
software_root <- if (length(arguments) >= 1L) arguments[[1L]] else {
  Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
}
stopifnot(nzchar(software_root), dir.exists(software_root))
software_root <- normalizePath(software_root, winslash = "/", mustWork = TRUE)
catalog <- rrp_open_resource_catalog(software_root)

suite_root <- tempfile("rrp-fictional-end-to-end-")
dir.create(suite_root)
on.exit(unlink(suite_root, recursive = TRUE, force = TRUE), add = TRUE)
stopifnot(!dir.exists(file.path(suite_root, ".git")))

document_ids <- c(
  "rrp.documentation.project-authoring-guide",
  "rrp.documentation.provider-request-reference",
  "rrp.documentation.fictional-reference-walkthrough"
)
document_paths <- vapply(
  document_ids, function(id) rrp_resource_path(catalog, id), character(1L)
)
stopifnot(
  length(document_paths) == 3L,
  all(file.exists(document_paths)),
  all(startsWith(document_paths, paste0(software_root, .Platform$file.sep)))
)
provider_reference <- paste(readLines(
  document_paths[[2L]], warn = FALSE, encoding = "UTF-8"
), collapse = "\n")
request_fields <- c(
  "request_contract_id", "request_contract_version", "request_id",
  "target_id", "target_version", "state_contract_id",
  "state_contract_version", "state_id", "bundle_instance_id", "project_id",
  "project_version", "episode_id", "as_of_time", "discharge_time",
  "target_interval_start", "target_interval_end", "target_interval_boundary",
  "elapsed_seconds_since_discharge", "remaining_seconds_through_w30"
)
field_positions <- vapply(request_fields, function(field) {
  regexpr(paste0("`", field, "`"), provider_reference, fixed = TRUE)[[1L]]
}, integer(1L))
stopifnot(all(field_positions > 0L), all(diff(field_positions) > 0L))

project_root <- file.path(suite_root, "fictional-project")
initialized <- rrp_initialize_fictional_project(catalog, project_root)
stopifnot(rrp_operation_succeeded(initialized))
initialized_files <- sort(list.files(
  project_root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
  include.dirs = FALSE
), method = "radix")
expected_initialized <- sort(c(
  "rrp-project.dcf", "rrp-authoring.dcf", "R/register.R",
  "R/produce-canonical.R", "R/calculate-risk.R", "R/generate-source.R",
  "README.md"
), method = "radix")
stopifnot(
  identical(initialized_files, expected_initialized),
  !dir.exists(file.path(project_root, "source", "generated")),
  !dir.exists(file.path(project_root, "state")),
  !dir.exists(file.path(project_root, "extensions")),
  !dir.exists(file.path(project_root, ".git")),
  !dir.exists(file.path(project_root, "products")),
  !dir.exists(file.path(project_root, "app"))
)

registration_text <- paste(readLines(
  file.path(project_root, "R", "register.R"), warn = FALSE
), collapse = "\n")
authoring_text <- paste(readLines(
  file.path(project_root, "rrp-authoring.dcf"), warn = FALSE
), collapse = "\n")
producer_text <- paste(readLines(
  file.path(project_root, "R", "produce-canonical.R"), warn = FALSE
), collapse = "\n")
provider_path <- file.path(project_root, "R", "calculate-risk.R")
provider_text <- paste(readLines(provider_path, warn = FALSE), collapse = "\n")
stopifnot(
  grepl("rrp_register_authored_project", registration_text, fixed = TRUE),
  !grepl("rrp_produce_canonical", registration_text, fixed = TRUE),
  grepl("Extension-Packages: none", authoring_text, fixed = TRUE),
  grepl("rrp_produce_canonical <- function", producer_text, fixed = TRUE),
  grepl("rrp_calculate_risk <- function", provider_text, fixed = TRUE),
  grepl("identity-crosswalk.csv", producer_text, fixed = TRUE),
  grepl("provider_signal", provider_text, fixed = TRUE)
)

generator <- new.env(parent = baseenv())
sys.source(
  file.path(project_root, "R", "generate-source.R"), generator,
  chdir = FALSE, keep.source = FALSE
)
generator$rrp_generate_fictional_source(project_root)
generated_root <- file.path(project_root, "source", "generated")
generated_files <- sort(list.files(
  generated_root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
  include.dirs = FALSE
), method = "radix")
expected_generated <- sort(c(
  "source.dcf", "stays.csv", "events.csv", "identity-crosswalk.csv"
), method = "radix")
stopifnot(identical(generated_files, expected_generated))
read_bytes <- function(path) readBin(path, "raw", n = file.info(path)$size)
generated_bytes <- lapply(file.path(generated_root, generated_files), read_bytes)

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
  nrow(stays) == 4L, nrow(crosswalk) == 12L,
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
  ),
  "provider_signal" %in% names(stays),
  "provider_signal_available_at" %in% names(stays)
)

# Add a test-owned observation to this temporary project only. It preserves the
# normal callable signature and result while recording direct provider calls;
# no instrumentation enters the package or fictional-project template.
provider_lines <- readLines(provider_path, warn = FALSE, encoding = "UTF-8")
opening <- which(grepl(
  "^rrp_calculate_risk <- function\\(project_root, request\\) \\{$",
  provider_lines
))
stopifnot(identical(length(opening), 1L))
observation_lines <- c(
  "  observation <- Sys.getenv(\"RRP_TEST_PROVIDER_CALLS\", unset = \"\")",
  "  if (nzchar(observation)) {",
  "    count <- if (file.exists(observation)) {",
  "      suppressWarnings(as.integer(readLines(observation, n = 1L)))",
  "    } else 0L",
  "    if (length(count) != 1L || is.na(count)) stop(\"invalid observation\")",
  "    writeLines(as.character(count + 1L), observation, useBytes = TRUE)",
  "  }"
)
provider_lines <- append(provider_lines, observation_lines, after = opening)
writeLines(provider_lines, provider_path, useBytes = TRUE)
provider_calls <- file.path(suite_root, "provider-calls")
old_observation <- Sys.getenv("RRP_TEST_PROVIDER_CALLS", unset = NA_character_)
Sys.setenv(RRP_TEST_PROVIDER_CALLS = provider_calls)
on.exit({
  if (is.na(old_observation)) Sys.unsetenv("RRP_TEST_PROVIDER_CALLS") else {
    Sys.setenv(RRP_TEST_PROVIDER_CALLS = old_observation)
  }
}, add = TRUE)

validated <- rrp_validate_project(catalog, project_root)
stopifnot(
  rrp_operation_succeeded(validated),
  identical(validated$value$extension_library_status, "not_initialized"),
  identical(validated$value$state_status, "not_initialized"),
  identical(validated$value$producer$origin, "project"),
  identical(validated$value$provider$origin, "project"),
  !file.exists(provider_calls)
)

as_of_time <- "2026-01-20T12:00:00Z"
first_produced <- rrp_execute_producer(catalog, project_root, as_of_time)
second_produced <- rrp_execute_producer(catalog, project_root, as_of_time)
stopifnot(
  rrp_operation_succeeded(first_produced),
  rrp_operation_succeeded(second_produced),
  identical(first_produced$value, second_produced$value),
  identical(first_produced$value$bundle_instance_id,
            second_produced$value$bundle_instance_id),
  nrow(first_produced$value$domains$discharge_episode) == 4L,
  nrow(first_produced$value$domains$terminal_event) == 2L,
  !file.exists(provider_calls),
  identical(
    generated_bytes,
    lapply(file.path(generated_root, generated_files), read_bytes)
  )
)

canonical_text <- paste(capture.output(str(first_produced$value$domains)),
                        collapse = " ")
private_markers <- c(
  "FIC STAY/", "FIC-STAY-", "LOCAL_READMIT", "LOCAL_DEATH",
  "provider_signal", "provider_signal_available_at", "identity-crosswalk",
  "2026-01-10T13:00:00Z", "2026-01-05T14:00:00Z"
)
stopifnot(!any(vapply(
  private_markers, grepl, logical(1L), x = canonical_text, fixed = TRUE
)))

initialized_state <- rrp_initialize_project_state(catalog, project_root)
stopifnot(
  rrp_operation_succeeded(initialized_state),
  isTRUE(initialized_state$value$created),
  identical(sort(list.files(
    file.path(project_root, "state"), recursive = TRUE, all.files = TRUE,
    no.. = TRUE, include.dirs = FALSE
  ), method = "radix"), c("history.duckdb", "state.dcf")),
  !file.exists(provider_calls)
)
inspected_state <- rrp_inspect_project_state(catalog, project_root)
stopifnot(
  rrp_operation_succeeded(inspected_state),
  identical(inspected_state$value$state_status, "compatible"),
  identical(inspected_state$value$state_id, initialized_state$value$state_id)
)

operation_key <- "fictional-reference-complete-v1"
executed <- rrp_execute_durable_bundle(
  catalog, project_root, as_of_time, operation_key
)
stopifnot(
  rrp_operation_succeeded(executed),
  identical(executed$value$expected_episode_count, 4L),
  identical(executed$value$dispositioned_episode_count, 4L),
  isTRUE(executed$value$complete),
  identical(as.integer(readLines(provider_calls, n = 1L)), 1L)
)

scope_history <- rrp_inspect_scope_history(
  catalog, project_root, executed$value$operation_run_id
)
stopifnot(rrp_operation_succeeded(scope_history))
scope <- scope_history$value$scope
dispositions <- scope_history$value$dispositions
episode_ids <- first_produced$value$domains$discharge_episode$episode_id
by_episode <- setNames(dispositions, vapply(
  dispositions, `[[`, character(1L), "episode_id"
))
stopifnot(
  identical(scope$operation_key, operation_key),
  identical(scope$state_id, initialized_state$value$state_id),
  identical(scope$project_id, "fictional-reference-hospital"),
  identical(scope$bundle_instance_id,
            first_produced$value$bundle_instance_id),
  identical(scope$analytical_time, as_of_time),
  identical(scope$expected_episode_count, 4L),
  identical(scope$membership_fingerprint,
            rrpruntime::rrp_history_membership_fingerprint(episode_ids)),
  identical(scope_history$value$progress$expected_episode_count, 4L),
  identical(scope_history$value$progress$dispositioned_episode_count, 4L),
  isTRUE(scope_history$value$progress$complete),
  length(dispositions) == 4L,
  length(unique(vapply(
    dispositions, `[[`, character(1L), "analytical_run_id"
  ))) == 4L,
  identical(sort(names(by_episode), method = "radix"),
            sort(episode_ids, method = "radix")),
  all(vapply(dispositions, function(value) {
    identical(value$analytical_kind, "initial")
  }, logical(1L)))
)

stopifnot(
  identical(by_episode[["fictional.episode.001"]]$outcome,
            "accepted_estimate"),
  identical(by_episode[["fictional.episode.001"]]$outcome_code,
            "estimate_accepted"),
  identical(by_episode[["fictional.episode.001"]]$provider_status,
            "succeeded"),
  isTRUE(all.equal(
    by_episode[["fictional.episode.001"]]$estimate$estimate_value,
    0.3833333333333333
  )),
  identical(by_episode[["fictional.episode.002"]]$outcome, "ineligible"),
  identical(by_episode[["fictional.episode.002"]]$outcome_code,
            "episode_already_readmitted"),
  identical(by_episode[["fictional.episode.003"]]$outcome, "ineligible"),
  identical(by_episode[["fictional.episode.003"]]$outcome_code,
            "episode_already_dead"),
  identical(by_episode[["fictional.episode.004"]]$outcome, "ineligible"),
  identical(by_episode[["fictional.episode.004"]]$outcome_code,
            "target_horizon_exhausted"),
  all(vapply(by_episode[c(
    "fictional.episode.002", "fictional.episode.003",
    "fictional.episode.004"
  )], function(value) {
    identical(value$provider_status, "not_invoked") &&
      is.null(value$request) && is.null(value$estimate)
  }, logical(1L)))
)

target_id <- scope$target_id
episode_histories <- lapply(episode_ids, function(episode_id) {
  result <- rrp_inspect_episode_history(
    catalog, project_root, episode_id, target_id, as_of_time
  )
  stopifnot(rrp_operation_succeeded(result),
            length(result$value$dispositions) == 1L)
  result$value
})
current_histories <- lapply(episode_ids, function(episode_id) {
  result <- rrp_inspect_current_history(
    catalog, project_root, episode_id, target_id, as_of_time, as_of_time
  )
  stopifnot(rrp_operation_succeeded(result), !is.null(result$value))
  result$value
})
stopifnot(identical(
  vapply(current_histories, `[[`, character(1L), "analytical_run_id"),
  vapply(dispositions[match(episode_ids, vapply(
    dispositions, `[[`, character(1L), "episode_id"
  ))], `[[`, character(1L), "analytical_run_id")
))

history_text <- paste(capture.output(dput(list(
  scope = scope_history$value,
  episodes = episode_histories,
  current = current_histories
))), collapse = " ")
stopifnot(!any(vapply(
  private_markers, grepl, logical(1L), x = history_text, fixed = TRUE
)))

before_repeat <- scope_history$value
reproduced <- rrp_execute_producer(catalog, project_root, as_of_time)
repeated <- rrp_execute_durable_bundle(
  catalog, project_root, as_of_time, operation_key
)
after_repeat <- rrp_inspect_scope_history(
  catalog, project_root, executed$value$operation_run_id
)
stopifnot(
  rrp_operation_succeeded(reproduced),
  identical(reproduced$value, first_produced$value),
  identical(reproduced$value$bundle_instance_id,
            first_produced$value$bundle_instance_id),
  rrp_operation_succeeded(repeated),
  identical(repeated$value, executed$value),
  identical(as.integer(readLines(provider_calls, n = 1L)), 1L),
  rrp_operation_succeeded(after_repeat),
  identical(after_repeat$value, before_repeat),
  length(after_repeat$value$dispositions) == 4L
)

copy_parent <- file.path(suite_root, "copied-parent")
dir.create(copy_parent)
stopifnot(file.copy(
  project_root, copy_parent, recursive = TRUE, copy.mode = FALSE,
  copy.date = FALSE
))
copied_root <- file.path(copy_parent, basename(project_root))
copied_validation <- rrp_validate_project(catalog, copied_root)
copied_state <- rrp_inspect_project_state(catalog, copied_root)
copied_scope <- rrp_inspect_scope_history(
  catalog, copied_root, executed$value$operation_run_id
)
copied_current <- rrp_inspect_current_history(
  catalog, copied_root, "fictional.episode.001", target_id,
  as_of_time, as_of_time
)
copied_repeat <- rrp_execute_durable_bundle(
  catalog, copied_root, as_of_time, operation_key
)
stopifnot(
  rrp_operation_succeeded(copied_validation),
  identical(copied_validation$value$state_status, "compatible"),
  rrp_operation_succeeded(copied_state),
  identical(copied_state$value, inspected_state$value),
  rrp_operation_succeeded(copied_scope),
  identical(copied_scope$value, before_repeat),
  rrp_operation_succeeded(copied_current),
  identical(copied_current$value,
            by_episode[["fictional.episode.001"]]),
  rrp_operation_succeeded(copied_repeat),
  identical(copied_repeat$value, executed$value),
  identical(as.integer(readLines(provider_calls, n = 1L)), 1L),
  !identical(normalizePath(copied_root), normalizePath(project_root)),
  !dir.exists(file.path(copied_root, ".git")),
  !dir.exists(file.path(copied_root, "extensions"))
)

if (length(arguments) >= 2L && nzchar(arguments[[2L]])) {
  installed_library <- normalizePath(
    arguments[[2L]], winslash = "/", mustWork = TRUE
  )
  dependency_paths <- vapply(
    c("rrpplatform", "rrpruntime", "DBI", "duckdb"),
    function(package) normalizePath(
      find.package(package), winslash = "/", mustWork = TRUE
    ), character(1L)
  )
  stopifnot(all(startsWith(
    dependency_paths, paste0(installed_library, .Platform$file.sep)
  )))
}

cat("rrpplatform fictional installed end-to-end tests passed\n")
