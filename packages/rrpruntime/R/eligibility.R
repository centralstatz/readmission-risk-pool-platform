rrp_validate_runtime_context <- function(input, runtime_context) {
  issues <- list()
  if (!is.list(runtime_context) || !rrp_is_scalar_string(runtime_context$run_id)) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "runtime.context.identity", "invalid_runtime_run_id",
      "Runtime context requires one non-empty run_id.", "$.runtime_context.run_id"
    )
  }
  if (!is.list(runtime_context) || !rrp_is_timestamp(runtime_context$as_of_time)) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "runtime.context.time", "invalid_runtime_as_of_time",
      "Runtime context requires one explicit-offset RFC 3339 as-of time.",
      "$.runtime_context.as_of_time"
    )
  } else if (!identical(runtime_context$as_of_time, input$bundle_as_of_time)) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "runtime.context.bundle_cutoff", "runtime_bundle_as_of_mismatch",
      "Iteration 4.1 requires runtime as-of to equal the admitted bundle cutoff.",
      "$.runtime_context.as_of_time"
    )
  }
  rrp_runtime_result(
    rrp_identity("runtime_context", "platform.runtime-context", "0.1.0"),
    issues
  )
}

rrp_effective_followup_end <- function(episode, estimand) {
  discharge <- rrp_time_number(episode$discharge_time)
  canonical_end <- rrp_time_number(episode$followup_window_end)
  maximum <- discharge + as.numeric(estimand$followup$maximum_horizon_days) * 86400
  min(canonical_end, maximum)
}

rrp_episode_eligibility_reason <- function(episode, as_of, effective_end) {
  discharge <- rrp_time_number(episode$discharge_time)
  readmission <- rrp_time_number(episode$readmission_time)
  death <- rrp_time_number(episode$death_time)
  if (as_of < discharge) return("before_discharge")
  readmitted <- !is.na(readmission) && readmission <= as_of
  died <- !is.na(death) && death <= as_of
  if (readmitted && (!died || readmission <= death)) return("already_readmitted")
  if (died) return("died")
  if (as_of >= effective_end) return("followup_complete")
  "eligible"
}

#' Evaluate estimand eligibility independently from estimation
#' @export
evaluate_episode_eligibility <- function(input, runtime_context, contracts) {
  rrp_assert_runtime_conforms(validate_runtime_input(input), "Runtime input")
  rrp_assert_runtime_conforms(validate_runtime_contracts(contracts), "Runtime contracts")
  rrp_assert_runtime_conforms(
    rrp_validate_runtime_context(input, runtime_context), "Runtime context"
  )
  as_of <- rrp_time_number(runtime_context$as_of_time)
  identity <- rrp_runtime_supported_specifications()$eligibility_result
  estimand_identity <- rrp_runtime_supported_specifications()$estimand
  records <- lapply(input$discharge_episodes, function(episode) {
    effective_end <- rrp_effective_followup_end(episode, contracts$estimand)
    reason <- rrp_episode_eligibility_reason(episode, as_of, effective_end)
    list(
      eligibility_result_id = rrp_deterministic_id(
        "eligibility", runtime_context$run_id, episode$episode_id,
        runtime_context$as_of_time, identity$specification_version
      ),
      eligibility_specification = identity,
      episode_id = episode$episode_id,
      runtime_run_id = runtime_context$run_id,
      as_of_time = runtime_context$as_of_time,
      estimand_specification = estimand_identity,
      eligibility_status = if (identical(reason, "eligible")) "eligible" else "ineligible",
      eligibility_reason = reason,
      effective_followup_end = rrp_format_time(effective_end)
    )
  })
  structure(list(
    runtime_context = runtime_context,
    eligibility_specification = identity,
    estimand_specification = estimand_identity,
    records = records
  ), class = "rrp_episode_eligibility_set")
}
