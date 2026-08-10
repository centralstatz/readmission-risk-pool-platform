#' Construct an admitted, representation-neutral runtime input
#'
#' Representation adapters call this only after canonical admission. The
#' package does not resolve files, YAML, tables, or embedded fixture payloads.
#' @export
new_admitted_canonical_input <- function(
  bundle_instance_id,
  bundle_as_of_time,
  canonical_run_id,
  profile_specification,
  capabilities,
  discharge_episodes,
  baseline_risk = list(),
  episode_events = list(),
  provenance_references = list(),
  admission_reference
) {
  structure(list(
    bundle_instance_id = bundle_instance_id,
    bundle_as_of_time = bundle_as_of_time,
    canonical_run_id = canonical_run_id,
    profile_specification = profile_specification,
    capabilities = capabilities,
    discharge_episodes = discharge_episodes,
    baseline_risk = baseline_risk,
    episode_events = episode_events,
    provenance_references = provenance_references,
    admission_reference = admission_reference
  ), class = "rrp_admitted_canonical_input")
}

rrp_runtime_capability_status <- function(input, capability_id) {
  matches <- Filter(function(capability) {
    is.list(capability) && identical(capability$capability_id, capability_id)
  }, input$capabilities)
  if (length(matches) != 1L) return(NA_character_)
  matches[[1L]]$status
}

rrp_validate_episode_input <- function(episodes) {
  issues <- list()
  if (!rrp_named_records(episodes) || length(episodes) == 0L) {
    return(list(rrp_runtime_issue(
      "runtime.input.episodes", "invalid_discharge_episode_input",
      "Runtime input requires one or more discharge episode records.",
      "$.discharge_episodes"
    )))
  }
  required <- c("episode_id", "discharge_time", "followup_window_end")
  ids <- character()
  for (index in seq_along(episodes)) {
    record <- episodes[[index]]
    path <- paste0("$.discharge_episodes[", index, "]")
    missing <- required[!required %in% names(record)]
    if (length(missing) > 0L) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "runtime.input.required_episode_fields", "missing_runtime_episode_field",
        paste0("Runtime episode fields are missing: ", paste(missing, collapse = ", "), "."),
        path
      )
      next
    }
    ids <- c(ids, record$episode_id)
    if (!rrp_is_scalar_string(record$episode_id) ||
        !rrp_is_timestamp(record$discharge_time) ||
        !rrp_is_timestamp(record$followup_window_end)) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "runtime.input.episode_values", "invalid_runtime_episode_value",
        "Episode identity and required times must be valid scalar values.", path
      )
    }
  }
  if (anyDuplicated(ids)) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "runtime.input.episode_identity", "duplicate_runtime_episode_id",
      "Runtime episode IDs must be unique.", "$.discharge_episodes"
    )
  }
  issues
}

#' Validate the admitted canonical interface needed by runtime
#' @export
validate_runtime_input <- function(input) {
  target <- rrp_identity("runtime_input", "platform.admitted-canonical-runtime-input", "0.1.0")
  issues <- list()
  if (!inherits(input, "rrp_admitted_canonical_input")) {
    return(rrp_runtime_result(target, list(rrp_runtime_issue(
      "runtime.input.class", "invalid_runtime_input",
      "Input must be constructed by an admitted canonical representation adapter.", "$"
    ))))
  }
  for (field in c("bundle_instance_id", "canonical_run_id")) {
    if (!rrp_is_scalar_string(input[[field]])) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "runtime.input.identity", "invalid_runtime_input_identity",
        paste0("Runtime input field must be one non-empty string: ", field, "."),
        paste0("$.", field)
      )
    }
  }
  if (!rrp_is_timestamp(input$bundle_as_of_time)) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "runtime.input.time", "invalid_bundle_as_of_time",
      "Admitted runtime input requires an explicit-offset bundle cutoff.",
      "$.bundle_as_of_time"
    )
  }
  profile <- input$profile_specification
  if (!is.list(profile) ||
      !identical(profile$specification_id, "platform.readmission-initial-profile") ||
      !identical(profile$specification_version, "0.1.0")) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "runtime.input.profile", "unsupported_runtime_profile",
      "Runtime supports only the admitted initial readmission profile line.",
      "$.profile_specification"
    )
  }
  if (!identical(rrp_runtime_capability_status(
    input, "platform.discharge-episode"
  ), "available")) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "runtime.input.capability", "required_runtime_capability_unavailable",
      "Discharge episode capability must be available.", "$.capabilities"
    )
  }
  if (!is.list(input$admission_reference) ||
      !identical(input$admission_reference$overall_status, "pass")) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "runtime.input.admission", "canonical_input_not_admitted",
      "Runtime input requires a passing canonical admission reference.",
      "$.admission_reference"
    )
  }
  issues <- c(issues, rrp_validate_episode_input(input$discharge_episodes))
  for (field in c("baseline_risk", "episode_events")) {
    if (!rrp_named_records(input[[field]])) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "runtime.input.optional_records", "invalid_runtime_optional_records",
        paste0("Runtime input `", field, "` must be a record collection."),
        paste0("$.", field)
      )
    }
  }
  rrp_runtime_result(target, issues)
}
