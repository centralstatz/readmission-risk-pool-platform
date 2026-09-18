rrp_runtime_failure_messages <- function() {
  c(
    invalid_expected_context = "Expected episode-state context is invalid.",
    invalid_admitted_bundle = "Admitted canonical bundle is invalid.",
    invalid_analytical_as_of = "Analytical as-of time is invalid.",
    analytical_as_of_mismatch = paste0(
      "Analytical as-of time does not match the admitted bundle cutoff."
    ),
    unknown_episode = "Selected episode is not present in the admitted bundle.",
    episode_before_discharge = "Selected episode is before discharge.",
    target_horizon_exhausted = "Selected episode has exhausted the target horizon.",
    episode_already_readmitted = "Selected episode has already been readmitted.",
    episode_already_dead = "Selected episode is already dead."
  )
}

rrp_runtime_abort <- function(code) {
  messages <- rrp_runtime_failure_messages()
  if (!is.character(code) || length(code) != 1L || is.na(code) ||
      !code %in% names(messages)) {
    stop("Invalid internal runtime-error definition.", call. = FALSE)
  }
  stop(structure(
    list(message = unname(messages[[code]]), call = NULL, code = code),
    class = c("rrp_runtime_error", "error", "condition")
  ))
}

rrp_episode_state_context_fields <- function() {
  c(
    "product_id", "development_version", "target_id", "target_version",
    "state_contract_id", "state_contract_version", "bundle_contract_id",
    "bundle_contract_version", "canonical_profile_id",
    "canonical_profile_version", "target_event", "conditioning",
    "endpoint_elapsed_seconds", "eligible_as_of_start",
    "eligible_as_of_end", "target_interval", "information_cutoff",
    "competing_event", "equal_time_precedence", "target_selection",
    "terminal_status"
  )
}

rrp_episode_state_fields <- function() {
  c(
    "state_contract_id", "state_contract_version", "state_id", "target_id",
    "target_version", "bundle_contract_id", "bundle_contract_version",
    "bundle_instance_id", "project_id", "project_version",
    "canonical_profile_id", "canonical_profile_version", "episode_id",
    "as_of_time", "discharge_time", "target_window_end",
    "elapsed_seconds_since_discharge", "remaining_seconds_through_w30",
    "terminal_status"
  )
}

rrp_runtime_validate_expected_context <- function(expected_context) {
  expected_values <- list(
    product_id = "readmission-risk-pool-platform",
    development_version = "1.0.0-dev",
    target_id = "rrp.risk-target.readmission-remaining-30-day",
    target_version = "0.1.0",
    state_contract_id = "rrp.episode-state",
    state_contract_version = "0.1.0",
    bundle_contract_id = "rrp.canonical-bundle",
    bundle_contract_version = "0.1.0",
    canonical_profile_id = "rrp.canonical-profile.readmission",
    canonical_profile_version = "0.1.0",
    target_event = "first_canonical_readmission",
    conditioning = "alive_and_readmission_free_through_t",
    endpoint_elapsed_seconds = 2592000,
    eligible_as_of_start = "inclusive",
    eligible_as_of_end = "exclusive",
    target_interval = "(t,W30]",
    information_cutoff = "occurred_and_available_through_t",
    competing_event = "death",
    equal_time_precedence = "readmission",
    target_selection = "prohibited",
    terminal_status = "none_available_through_as_of"
  )
  valid_shape <- rrp_canonical_plain_named_list(expected_context) &&
    identical(names(expected_context), rrp_episode_state_context_fields()) &&
    !rrp_canonical_has_unsafe_value(expected_context)
  if (!valid_shape || !identical(expected_context, expected_values)) {
    rrp_runtime_abort("invalid_expected_context")
  }
  invisible(expected_context)
}

rrp_runtime_validate_admitted_bundle <- function(admitted_bundle) {
  valid_outer <- is.list(admitted_bundle) && identical(
    class(admitted_bundle), c("rrp_admitted_canonical_bundle", "list")
  ) && identical(names(attributes(admitted_bundle)), c("names", "class"))
  if (!valid_outer || rrp_canonical_has_unsafe_value(admitted_bundle)) {
    rrp_runtime_abort("invalid_admitted_bundle")
  }
  candidate <- unclass(admitted_bundle)
  if (!rrp_canonical_plain_named_list(candidate)) {
    rrp_runtime_abort("invalid_admitted_bundle")
  }
  validation_candidate <- candidate
  for (domain in c("discharge_episode", "terminal_event")) {
    value <- validation_candidate$domains[[domain]]
    valid_default_rows <- is.data.frame(value) && identical(
      attr(value, "row.names"), seq_len(nrow(value))
    )
    if (!valid_default_rows) rrp_runtime_abort("invalid_admitted_bundle")
    if (nrow(value) > 0L) {
      attr(value, "row.names") <- c(NA_integer_, -nrow(value))
    }
    validation_candidate$domains[[domain]] <- value
  }
  canonical_context <- candidate[rrp_canonical_context_fields()]
  tryCatch(
    rrp_admit_canonical_bundle(validation_candidate, canonical_context),
    rrp_canonical_error = function(condition) {
      rrp_runtime_abort("invalid_admitted_bundle")
    }
  )
}

rrp_runtime_format_utc <- function(value) {
  rendered <- format(
    as.POSIXct(value, origin = "1970-01-01", tz = "UTC"),
    "%Y-%m-%dT%H:%M:%OS6", tz = "UTC", usetz = FALSE
  )
  rendered <- sub("0+$", "", rendered)
  rendered <- sub("[.]$", "", rendered)
  paste0(rendered, "Z")
}

rrp_runtime_terminal_failure <- function(events, episode_id) {
  selected <- events$episode_id == episode_id
  if (!any(selected)) return(NULL)
  event_types <- events$event_type[selected]
  occurrence <- rrp_canonical_timestamp_column(events$occurred_at[selected])
  readmission <- occurrence[event_types == "readmission"]
  death <- occurrence[event_types == "death"]
  if (length(readmission) == 1L &&
      (length(death) == 0L || readmission <= death)) {
    return("episode_already_readmitted")
  }
  if (length(death) == 1L) return("episode_already_dead")
  if (length(readmission) == 1L) return("episode_already_readmitted")
  NULL
}

rrp_runtime_eligibility_failure <- function(
  analytical_as_of,
  discharge_time,
  target_window_end,
  events,
  episode_id
) {
  if (analytical_as_of < discharge_time) return("episode_before_discharge")
  if (analytical_as_of >= target_window_end) {
    return("target_horizon_exhausted")
  }
  rrp_runtime_terminal_failure(events, episode_id)
}

rrp_runtime_hash <- function(value, multiplier, modulus) {
  bytes <- as.integer(charToRaw(enc2utf8(value)))
  hash <- 0
  for (byte in bytes) hash <- (hash * multiplier + byte + 1) %% modulus
  as.integer(hash)
}

rrp_runtime_state_identity <- function(values) {
  serialized <- paste(vapply(values, function(value) {
    value <- enc2utf8(as.character(value))
    paste0(nchar(value, type = "bytes"), ":", value)
  }, character(1L)), collapse = "|")
  first <- rrp_runtime_hash(serialized, 257, 2147483629)
  second <- rrp_runtime_hash(serialized, 263, 2147483587)
  paste0("rrp.state.", sprintf("%08x%08x", first, second))
}

rrp_runtime_validate_episode_state <- function(state) {
  string_fields <- setdiff(
    rrp_episode_state_fields(),
    c("elapsed_seconds_since_discharge", "remaining_seconds_through_w30")
  )
  valid <- is.list(state) &&
    identical(class(state), c("rrp_episode_state", "list")) &&
    identical(names(attributes(state)), c("names", "class")) &&
    identical(names(state), rrp_episode_state_fields()) &&
    all(vapply(state[string_fields], rrp_canonical_scalar_string, logical(1L))) &&
    is.double(state$elapsed_seconds_since_discharge) &&
    length(state$elapsed_seconds_since_discharge) == 1L &&
    is.finite(state$elapsed_seconds_since_discharge) &&
    is.null(attributes(state$elapsed_seconds_since_discharge)) &&
    is.double(state$remaining_seconds_through_w30) &&
    length(state$remaining_seconds_through_w30) == 1L &&
    is.finite(state$remaining_seconds_through_w30) &&
    is.null(attributes(state$remaining_seconds_through_w30)) &&
    !rrp_canonical_has_unsafe_value(state)
  if (!valid) stop("Invalid internal episode-state construction.", call. = FALSE)
  invisible(state)
}

#' Prepare immutable state for one admitted episode
#'
#' Revalidate an admitted canonical bundle, enforce the singular target's exact
#' analytical cutoff and eligibility rules, and return one detached minimal
#' episode state. Expected failures are raised as `rrp_runtime_error`
#' conditions with stable `code` values and bounded messages.
#'
#' @param admitted_bundle One `rrp_admitted_canonical_bundle`.
#' @param episode_id One exact admitted episode identity.
#' @param as_of_time One explicit-offset RFC 3339 analytical instant. It must
#'   denote the same instant as the admitted bundle's authoritative cutoff.
#' @param expected_context The closed target, state, canonical, and software
#'   context assembled by the calling orchestration boundary.
#'
#' @return A detached object with class `c("rrp_episode_state", "list")`.
#' @export
rrp_prepare_episode_state <- function(
  admitted_bundle,
  episode_id,
  as_of_time,
  expected_context
) {
  rrp_runtime_validate_expected_context(expected_context)
  if (!rrp_canonical_scalar_string(as_of_time)) {
    rrp_runtime_abort("invalid_analytical_as_of")
  }
  analytical_as_of <- rrp_canonical_timestamp_number(as_of_time)
  if (is.na(analytical_as_of)) rrp_runtime_abort("invalid_analytical_as_of")

  admitted <- rrp_runtime_validate_admitted_bundle(admitted_bundle)
  if (!identical(
    admitted$bundle_contract_id, expected_context$bundle_contract_id
  ) || !identical(
    admitted$bundle_contract_version, expected_context$bundle_contract_version
  ) || !identical(
    admitted$canonical_profile_id, expected_context$canonical_profile_id
  ) || !identical(
    admitted$canonical_profile_version,
    expected_context$canonical_profile_version
  )) rrp_runtime_abort("invalid_admitted_bundle")

  bundle_as_of <- rrp_canonical_timestamp_number(admitted$as_of_time)
  if (!identical(analytical_as_of, bundle_as_of)) {
    rrp_runtime_abort("analytical_as_of_mismatch")
  }
  if (!rrp_canonical_valid_identity(episode_id)) {
    rrp_runtime_abort("unknown_episode")
  }
  episodes <- admitted$domains$discharge_episode
  selected <- which(episodes$episode_id == episode_id)
  if (length(selected) != 1L) rrp_runtime_abort("unknown_episode")
  episode <- episodes[selected, , drop = FALSE]
  discharge_time <- rrp_canonical_timestamp_number(episode$discharge_time)
  target_window_end <- rrp_canonical_timestamp_number(
    episode$followup_window_end
  )
  expected_end <- discharge_time + expected_context$endpoint_elapsed_seconds
  if (!identical(target_window_end, expected_end)) {
    rrp_runtime_abort("invalid_admitted_bundle")
  }
  eligibility_failure <- rrp_runtime_eligibility_failure(
    analytical_as_of,
    discharge_time,
    target_window_end,
    admitted$domains$terminal_event,
    episode_id
  )
  if (!is.null(eligibility_failure)) rrp_runtime_abort(eligibility_failure)

  canonical_as_of <- rrp_runtime_format_utc(analytical_as_of)
  canonical_discharge <- rrp_runtime_format_utc(discharge_time)
  canonical_end <- rrp_runtime_format_utc(target_window_end)
  identity_values <- list(
    admitted$bundle_contract_id, admitted$bundle_contract_version,
    admitted$bundle_instance_id, admitted$project_id, admitted$project_version,
    admitted$canonical_profile_id, admitted$canonical_profile_version,
    episode_id, canonical_as_of, canonical_discharge, canonical_end,
    expected_context$target_id, expected_context$target_version,
    expected_context$state_contract_id,
    expected_context$state_contract_version
  )
  state <- structure(list(
    state_contract_id = expected_context$state_contract_id,
    state_contract_version = expected_context$state_contract_version,
    state_id = rrp_runtime_state_identity(identity_values),
    target_id = expected_context$target_id,
    target_version = expected_context$target_version,
    bundle_contract_id = admitted$bundle_contract_id,
    bundle_contract_version = admitted$bundle_contract_version,
    bundle_instance_id = admitted$bundle_instance_id,
    project_id = admitted$project_id,
    project_version = admitted$project_version,
    canonical_profile_id = admitted$canonical_profile_id,
    canonical_profile_version = admitted$canonical_profile_version,
    episode_id = episode_id,
    as_of_time = canonical_as_of,
    discharge_time = canonical_discharge,
    target_window_end = canonical_end,
    elapsed_seconds_since_discharge = as.numeric(
      analytical_as_of - discharge_time
    ),
    remaining_seconds_through_w30 = as.numeric(
      target_window_end - analytical_as_of
    ),
    terminal_status = expected_context$terminal_status
  ), class = c("rrp_episode_state", "list"))
  rrp_runtime_validate_episode_state(state)
  state
}
