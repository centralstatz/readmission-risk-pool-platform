rrp_reference_baseline_probability <- function(state) {
  probabilities <- vapply(state$available_baseline_risk, function(record) {
    if (identical(record$value_type, "probability") &&
        is.numeric(record$probability) && length(record$probability) == 1L &&
        is.finite(record$probability) && record$probability >= 0 &&
        record$probability <= 1) {
      as.numeric(record$probability)
    } else {
      NA_real_
    }
  }, numeric(1))
  probabilities <- probabilities[is.finite(probabilities)]
  if (length(probabilities) == 0L) 0 else mean(probabilities)
}

rrp_reference_event_terms <- function(state) {
  events <- state$available_episode_events
  if (length(events) == 0L) return(list(count = 0, recent = 0))
  as_of <- rrp_time_number(state$as_of_time)
  event_times <- vapply(events, function(record) {
    rrp_time_number(record$event_time)
  }, numeric(1))
  ages <- as_of - event_times
  list(
    count = min(length(events), 5L),
    recent = as.numeric(any(is.finite(ages) & ages >= 0 & ages <= 7 * 86400))
  )
}

#' Execute the shipped transparent nonclinical reference method
#'
#' This adapter receives only an accepted request, its immutable state, and the
#' registered declaration. It does not access canonical or source systems.
#' @export
reference_provider_adapter <- function(request, state, provider_specification) {
  baseline <- rrp_reference_baseline_probability(state)
  events <- rrp_reference_event_terms(state)
  linear_predictor <- stats::qlogis(0.04) +
    0.75 * baseline +
    0.12 * events$count +
    0.10 * events$recent
  probability <- stats::plogis(linear_predictor)
  list(
    status = "success",
    outputs = list(list(
      request_id = request$request_id,
      state_id = state$state_id,
      episode_id = state$episode_id,
      estimand_specification = request$estimand_specification,
      target_interval_start = request$target_interval_start,
      target_interval_end = request$target_interval_end,
      interval_boundary = request$interval_boundary,
      output_type = "probability",
      estimate_value = as.numeric(probability),
      provenance_references = list(list(
        provenance_type = "provider_specification",
        provenance_id = provider_specification$provider_id,
        relationship = "computed_by",
        version_or_revision = provider_specification$provider_version
      ))
    ))
  )
}

