#' Build provider-neutral estimand requests for eligible states
#' @export
build_estimand_requests <- function(states, eligibility, runtime_context, contracts) {
  rrp_assert_runtime_conforms(validate_runtime_contracts(contracts), "Runtime contracts")
  if (!inherits(states, "rrp_episode_state_set")) {
    stop("States must come from build_episode_states().", call. = FALSE)
  }
  if (!inherits(eligibility, "rrp_episode_eligibility_set")) {
    stop("Eligibility must come from evaluate_episode_eligibility().", call. = FALSE)
  }
  request_identity <- rrp_runtime_supported_specifications()$estimand_request
  estimand_identity <- rrp_runtime_supported_specifications()$estimand
  eligibility_by_episode <- stats::setNames(
    eligibility$records,
    vapply(eligibility$records, `[[`, character(1), "episode_id")
  )
  width <- as.numeric(contracts$estimand$interval$width_days) * 86400
  records <- lapply(states$records, function(state) {
    result <- eligibility_by_episode[[state$episode_id]]
    if (is.null(result) || !identical(result$eligibility_status, "eligible")) {
      stop("Every state must resolve to one eligible result.", call. = FALSE)
    }
    start <- rrp_time_number(state$as_of_time)
    end <- min(start + width, rrp_time_number(result$effective_followup_end))
    list(
      request_id = rrp_deterministic_id(
        "request", runtime_context$run_id, state$episode_id,
        state$as_of_time, estimand_identity$specification_version
      ),
      request_specification = request_identity,
      runtime_run_id = runtime_context$run_id,
      episode_id = state$episode_id,
      state_reference = list(
        state_id = state$state_id,
        state_specification = state$state_specification
      ),
      estimand_specification = estimand_identity,
      as_of_time = state$as_of_time,
      target_interval_start = state$as_of_time,
      target_interval_end = rrp_format_time(end),
      interval_boundary = "(start, end]",
      capability_statuses = state$capability_statuses,
      input_references = state$input_references
    )
  })
  structure(list(
    runtime_context = runtime_context,
    request_specification = request_identity,
    estimand_specification = estimand_identity,
    records = records
  ), class = "rrp_estimand_request_set")
}
