rrp_available_baselines <- function(input, episode_id, as_of) {
  records <- Filter(function(record) {
    identical(record$episode_id, episode_id) &&
      !is.na(rrp_time_number(record$score_time)) &&
      !is.na(rrp_time_number(record$available_at)) &&
      rrp_time_number(record$score_time) <= as_of &&
      rrp_time_number(record$available_at) <= as_of
  }, input$baseline_risk)
  if (length(records) <= 1L) return(records)
  keys <- vapply(records, function(record) paste(
    record$source_model_id, record$source_model_version, record$score_time,
    rrp_null_default(record$source_reference_id, ""), sep = "\u001f"
  ), character(1))
  records[order(keys)]
}

rrp_available_events <- function(input, episode_id, as_of) {
  records <- Filter(function(record) {
    identical(record$episode_id, episode_id) &&
      !is.na(rrp_time_number(record$event_time)) &&
      !is.na(rrp_time_number(record$available_at)) &&
      rrp_time_number(record$event_time) <= as_of &&
      rrp_time_number(record$available_at) <= as_of
  }, input$episode_events)
  if (length(records) <= 1L) return(records)
  occurrence <- vapply(records, function(record) {
    rrp_time_number(record$event_time)
  }, numeric(1))
  availability <- vapply(records, function(record) {
    rrp_time_number(record$available_at)
  }, numeric(1))
  ids <- vapply(records, `[[`, character(1), "event_id")
  records[order(occurrence, availability, ids)]
}

rrp_state_capabilities <- function(input) {
  lapply(input$capabilities, function(capability) list(
    capability_id = capability$capability_id,
    status = capability$status
  ))
}

#' Construct minimal episode states for eligible episodes
#' @export
build_episode_states <- function(input, eligibility, runtime_context, contracts) {
  rrp_assert_runtime_conforms(validate_runtime_input(input), "Runtime input")
  rrp_assert_runtime_conforms(validate_runtime_contracts(contracts), "Runtime contracts")
  rrp_assert_runtime_conforms(
    rrp_validate_runtime_context(input, runtime_context), "Runtime context"
  )
  if (!inherits(eligibility, "rrp_episode_eligibility_set")) {
    stop("Eligibility must come from evaluate_episode_eligibility().", call. = FALSE)
  }
  eligible <- Filter(function(record) {
    identical(record$eligibility_status, "eligible")
  }, eligibility$records)
  episode_ids <- vapply(input$discharge_episodes, `[[`, character(1), "episode_id")
  as_of <- rrp_time_number(runtime_context$as_of_time)
  identity <- rrp_runtime_supported_specifications()$episode_state
  states <- lapply(eligible, function(result) {
    episode <- input$discharge_episodes[[match(result$episode_id, episode_ids)]]
    discharge <- rrp_time_number(episode$discharge_time)
    effective_end <- rrp_time_number(result$effective_followup_end)
    baselines <- rrp_available_baselines(input, result$episode_id, as_of)
    events <- rrp_available_events(input, result$episode_id, as_of)
    list(
      state_id = rrp_deterministic_id(
        "state", runtime_context$run_id, result$episode_id,
        runtime_context$as_of_time, identity$specification_version
      ),
      state_specification = identity,
      episode_id = result$episode_id,
      runtime_run_id = runtime_context$run_id,
      as_of_time = runtime_context$as_of_time,
      bundle_instance_id = input$bundle_instance_id,
      canonical_run_id = input$canonical_run_id,
      days_since_discharge = (as_of - discharge) / 86400,
      followup_days_remaining = (effective_end - as_of) / 86400,
      observation_status = "active_followup",
      terminal_status = "none_as_of",
      available_baseline_risk = baselines,
      available_episode_events = events,
      capability_statuses = rrp_state_capabilities(input),
      input_references = list(
        list(reference_type = "canonical_bundle", reference_id = input$bundle_instance_id),
        list(reference_type = "canonical_run", reference_id = input$canonical_run_id),
        list(
          reference_type = "eligibility_result",
          reference_id = result$eligibility_result_id
        )
      )
    )
  })
  structure(list(
    runtime_context = runtime_context,
    state_specification = identity,
    records = states
  ), class = "rrp_episode_state_set")
}
