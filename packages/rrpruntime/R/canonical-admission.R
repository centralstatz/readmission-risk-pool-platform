rrp_canonical_failure_messages <- function() {
  c(
    invalid_expected_context = "Expected canonical context is invalid.",
    unsafe_candidate_value = "Canonical candidate contains an unsafe value.",
    invalid_candidate_shape = "Canonical candidate shape is invalid.",
    unknown_bundle_field = "Canonical candidate contains an unknown bundle field.",
    missing_bundle_field = "Canonical candidate is missing a required bundle field.",
    unsupported_bundle_contract = "Canonical bundle contract is unsupported.",
    unsupported_canonical_profile = "Canonical profile is unsupported.",
    invalid_bundle_identity = "Canonical bundle instance identity is invalid.",
    invalid_identity = "Canonical identity is invalid.",
    invalid_version = "Canonical identity version is invalid.",
    invalid_as_of_time = "Canonical as-of time is invalid.",
    bundle_identity_mismatch = "Canonical bundle identity does not match expected context.",
    project_identity_mismatch = "Canonical project identity does not match expected context.",
    producer_identity_mismatch = "Canonical producer identity does not match expected context.",
    implementation_identity_mismatch = "Canonical implementation identity does not match expected context.",
    mapping_identity_mismatch = "Canonical mapping identity does not match expected context.",
    profile_identity_mismatch = "Canonical profile identity does not match expected context.",
    as_of_time_mismatch = "Canonical as-of time does not match expected context.",
    invalid_capabilities = "Canonical capability declarations are invalid.",
    missing_capability = "A required canonical capability is missing.",
    duplicate_capability = "A canonical capability is declared more than once.",
    unsupported_capability = "Canonical candidate declares an unsupported capability.",
    unavailable_capability = "A required canonical capability is not available.",
    capability_mismatch = "Canonical capabilities do not match expected context.",
    invalid_domains = "Canonical domain collection is invalid.",
    missing_domain = "A required canonical domain is missing.",
    unknown_domain = "Canonical candidate contains an unknown domain.",
    invalid_discharge_episode = "Discharge episode domain realization is invalid.",
    invalid_discharge_episode_fields = "Discharge episode fields are invalid.",
    invalid_terminal_event = "Terminal event domain realization is invalid.",
    invalid_terminal_event_fields = "Terminal event fields are invalid.",
    invalid_domain_column_type = "Canonical domain column type is invalid.",
    invalid_domain_value = "Canonical domain contains an invalid value.",
    invalid_timestamp = "Canonical timestamp is invalid.",
    duplicate_episode_id = "Discharge episode identity is duplicated.",
    duplicate_terminal_event_id = "Terminal event identity is duplicated.",
    orphan_terminal_event = "Terminal event does not resolve to a discharge episode.",
    unsupported_event_type = "Terminal event type is unsupported.",
    multiple_readmissions = "An episode contains more than one readmission event.",
    multiple_deaths = "An episode contains more than one death event.",
    admission_not_before_discharge = "Admission must be strictly before discharge.",
    discharge_after_as_of = "Discharge occurs after the bundle as-of time.",
    invalid_followup_window = "Follow-up end is not exactly 30 elapsed days after discharge.",
    terminal_event_not_after_discharge = "Terminal event must occur strictly after discharge.",
    terminal_event_after_followup = "Terminal event occurs after the follow-up endpoint.",
    occurrence_after_availability = "Terminal event occurrence is after its availability.",
    availability_after_as_of = "Terminal event availability is after the bundle as-of time.",
    death_before_readmission = "Death occurs before a later readmission."
  )
}

rrp_canonical_abort <- function(code) {
  messages <- rrp_canonical_failure_messages()
  if (!is.character(code) || length(code) != 1L || is.na(code) ||
      !code %in% names(messages)) {
    stop("Invalid internal canonical-error definition.", call. = FALSE)
  }
  stop(structure(
    list(message = unname(messages[[code]]), call = NULL, code = code),
    class = c("rrp_canonical_error", "error", "condition")
  ))
}

rrp_canonical_bundle_fields <- function() {
  c(
    "bundle_contract_id", "bundle_contract_version", "bundle_instance_id",
    "project_id", "project_version", "producer_id", "producer_version",
    "implementation_id", "implementation_version", "mapping_id",
    "mapping_version", "canonical_profile_id", "canonical_profile_version",
    "as_of_time", "capabilities", "domains"
  )
}

rrp_canonical_context_fields <- function() {
  setdiff(rrp_canonical_bundle_fields(), c("bundle_instance_id", "domains"))
}

rrp_canonical_domain_fields <- function() {
  list(
    discharge_episode = c(
      "episode_id", "patient_id", "index_encounter_id", "admission_time",
      "discharge_time", "followup_window_end"
    ),
    terminal_event = c(
      "terminal_event_id", "episode_id", "event_type", "occurred_at",
      "available_at"
    )
  )
}

rrp_canonical_required_capability_ids <- function() {
  c("rrp.capability.discharge-episode", "rrp.capability.terminal-event")
}

rrp_canonical_plain_named_list <- function(value) {
  is.list(value) && !is.object(value) &&
    identical(names(attributes(value)), "names") &&
    is.character(names(value)) && length(names(value)) == length(value) &&
    all(nzchar(names(value))) && !anyDuplicated(names(value))
}

rrp_canonical_plain_unnamed_list <- function(value) {
  is.list(value) && !is.object(value) && is.null(attributes(value))
}

rrp_canonical_scalar_string <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    nzchar(value) && identical(value, trimws(value)) && is.null(attributes(value))
}

rrp_canonical_valid_identity <- function(value) {
  rrp_canonical_scalar_string(value) &&
    nchar(value, type = "bytes") <= 96L &&
    grepl("^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$", value, perl = TRUE)
}

rrp_canonical_valid_version <- function(value) {
  rrp_canonical_scalar_string(value) &&
    nchar(value, type = "bytes") <= 64L &&
    grepl(
      "^[0-9]+[.][0-9]+[.][0-9]+(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$",
      value, perl = TRUE
    )
}

rrp_canonical_timestamp_number <- function(value) {
  if (!rrp_canonical_scalar_string(value) || !grepl(
    paste0(
      "^[0-9]{4}-[0-9]{2}-[0-9]{2}T",
      "(?:[01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]",
      "(?:[.][0-9]+)?(?:Z|[+-](?:[01][0-9]|2[0-3]):[0-5][0-9])$"
    ),
    value, perl = TRUE
  )) return(NA_real_)
  normalized <- sub("Z$", "+0000", value)
  normalized <- sub(
    "([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", normalized, perl = TRUE
  )
  parsed <- suppressWarnings(strptime(
    normalized, format = "%Y-%m-%dT%H:%M:%OS%z", tz = "UTC"
  ))
  if (length(parsed) != 1L || is.na(parsed)) return(NA_real_)
  as.numeric(as.POSIXct(parsed, tz = "UTC"))
}

rrp_canonical_has_unsafe_value <- function(value) {
  if (is.function(value) || is.environment(value) ||
      typeof(value) %in% c(
        "externalptr", "weakref", "closure", "builtin", "special",
        "language", "symbol", "promise"
      ) || inherits(value, "connection")) return(TRUE)
  if (!is.list(value)) return(FALSE)
  any(vapply(value, rrp_canonical_has_unsafe_value, logical(1L)))
}

rrp_canonical_validate_capabilities <- function(capabilities, context = FALSE) {
  invalid_code <- if (context) "invalid_expected_context" else "invalid_capabilities"
  if (!rrp_canonical_plain_unnamed_list(capabilities)) {
    rrp_canonical_abort(invalid_code)
  }
  ids <- character(length(capabilities))
  statuses <- character(length(capabilities))
  for (index in seq_along(capabilities)) {
    capability <- capabilities[[index]]
    if (!rrp_canonical_plain_named_list(capability) ||
        !setequal(names(capability), c("capability_id", "status")) ||
        !rrp_canonical_scalar_string(capability$capability_id) ||
        !rrp_canonical_scalar_string(capability$status)) {
      rrp_canonical_abort(invalid_code)
    }
    ids[[index]] <- capability$capability_id
    statuses[[index]] <- capability$status
  }
  if (anyDuplicated(ids)) rrp_canonical_abort("duplicate_capability")
  required <- rrp_canonical_required_capability_ids()
  if (length(setdiff(ids, required)) > 0L) {
    rrp_canonical_abort("unsupported_capability")
  }
  if (length(setdiff(required, ids)) > 0L) {
    rrp_canonical_abort("missing_capability")
  }
  if (any(statuses != "available")) {
    rrp_canonical_abort("unavailable_capability")
  }
  names(statuses) <- ids
  statuses
}

rrp_canonical_validate_expected_context <- function(expected_context) {
  fields <- rrp_canonical_context_fields()
  if (!rrp_canonical_plain_named_list(expected_context) ||
      !setequal(names(expected_context), fields) ||
      rrp_canonical_has_unsafe_value(expected_context)) {
    rrp_canonical_abort("invalid_expected_context")
  }
  identity_fields <- c(
    "bundle_contract_id", "project_id", "producer_id", "implementation_id",
    "mapping_id", "canonical_profile_id"
  )
  version_fields <- c(
    "bundle_contract_version", "project_version", "producer_version",
    "implementation_version", "mapping_version", "canonical_profile_version"
  )
  if (any(!vapply(
    expected_context[identity_fields], rrp_canonical_valid_identity, logical(1L)
  )) || any(!vapply(
    expected_context[version_fields], rrp_canonical_valid_version, logical(1L)
  ))) rrp_canonical_abort("invalid_expected_context")
  if (!identical(expected_context$bundle_contract_id, "rrp.canonical-bundle") ||
      !identical(expected_context$bundle_contract_version, "0.1.0")) {
    rrp_canonical_abort("unsupported_bundle_contract")
  }
  if (!identical(
    expected_context$canonical_profile_id,
    "rrp.canonical-profile.readmission"
  ) || !identical(expected_context$canonical_profile_version, "0.1.0")) {
    rrp_canonical_abort("unsupported_canonical_profile")
  }
  as_of <- rrp_canonical_timestamp_number(expected_context$as_of_time)
  if (is.na(as_of)) rrp_canonical_abort("invalid_expected_context")
  capabilities <- rrp_canonical_validate_capabilities(
    expected_context$capabilities, context = TRUE
  )
  list(as_of = as_of, capabilities = capabilities)
}

rrp_canonical_validate_candidate_shape <- function(candidate) {
  if (rrp_canonical_has_unsafe_value(candidate)) {
    rrp_canonical_abort("unsafe_candidate_value")
  }
  if (!rrp_canonical_plain_named_list(candidate)) {
    rrp_canonical_abort("invalid_candidate_shape")
  }
  fields <- rrp_canonical_bundle_fields()
  if (length(setdiff(names(candidate), fields)) > 0L) {
    rrp_canonical_abort("unknown_bundle_field")
  }
  if (length(setdiff(fields, names(candidate))) > 0L) {
    rrp_canonical_abort("missing_bundle_field")
  }
  invisible(candidate)
}

rrp_canonical_validate_candidate_identity <- function(candidate, expected_context) {
  identity_fields <- c(
    "bundle_contract_id", "project_id", "producer_id", "implementation_id",
    "mapping_id", "canonical_profile_id"
  )
  version_fields <- c(
    "bundle_contract_version", "project_version", "producer_version",
    "implementation_version", "mapping_version", "canonical_profile_version"
  )
  if (any(!vapply(candidate[identity_fields], rrp_canonical_valid_identity, logical(1L)))) {
    rrp_canonical_abort("invalid_identity")
  }
  if (any(!vapply(candidate[version_fields], rrp_canonical_valid_version, logical(1L)))) {
    rrp_canonical_abort("invalid_version")
  }
  if (!rrp_canonical_valid_identity(candidate$bundle_instance_id)) {
    rrp_canonical_abort("invalid_bundle_identity")
  }
  if (!identical(candidate$bundle_contract_id, "rrp.canonical-bundle") ||
      !identical(candidate$bundle_contract_version, "0.1.0")) {
    rrp_canonical_abort("unsupported_bundle_contract")
  }
  if (!identical(
    candidate$canonical_profile_id, "rrp.canonical-profile.readmission"
  ) || !identical(candidate$canonical_profile_version, "0.1.0")) {
    rrp_canonical_abort("unsupported_canonical_profile")
  }
  comparisons <- list(
    bundle_identity_mismatch = c("bundle_contract_id", "bundle_contract_version"),
    project_identity_mismatch = c("project_id", "project_version"),
    producer_identity_mismatch = c("producer_id", "producer_version"),
    implementation_identity_mismatch = c(
      "implementation_id", "implementation_version"
    ),
    mapping_identity_mismatch = c("mapping_id", "mapping_version"),
    profile_identity_mismatch = c(
      "canonical_profile_id", "canonical_profile_version"
    )
  )
  for (code in names(comparisons)) {
    fields <- comparisons[[code]]
    if (!identical(candidate[fields], expected_context[fields])) {
      rrp_canonical_abort(code)
    }
  }
  invisible(candidate)
}

rrp_canonical_validate_domains <- function(domains) {
  if (!rrp_canonical_plain_named_list(domains)) {
    rrp_canonical_abort("invalid_domains")
  }
  expected <- names(rrp_canonical_domain_fields())
  if (length(setdiff(names(domains), expected)) > 0L) {
    rrp_canonical_abort("unknown_domain")
  }
  if (length(setdiff(expected, names(domains))) > 0L) {
    rrp_canonical_abort("missing_domain")
  }
  invisible(domains)
}

rrp_canonical_validate_data_frame <- function(value, fields, domain) {
  invalid_code <- paste0("invalid_", domain)
  field_code <- paste0("invalid_", domain, "_fields")
  valid_attributes <- setequal(
    names(attributes(value)), c("names", "class", "row.names")
  )
  if (!is.data.frame(value) || !identical(class(value), "data.frame") ||
      !valid_attributes || !identical(names(value), fields) ||
      .row_names_info(value, type = 1L) > 0L) {
    if (is.data.frame(value) && !identical(names(value), fields)) {
      rrp_canonical_abort(field_code)
    }
    rrp_canonical_abort(invalid_code)
  }
  valid_columns <- vapply(value, function(column) {
    is.character(column) && is.null(attributes(column)) && !anyNA(column)
  }, logical(1L))
  if (any(!valid_columns)) rrp_canonical_abort("invalid_domain_column_type")
  invisible(value)
}

rrp_canonical_validate_identifier_column <- function(values) {
  if (any(!vapply(as.list(values), rrp_canonical_valid_identity, logical(1L)))) {
    rrp_canonical_abort("invalid_domain_value")
  }
  invisible(values)
}

rrp_canonical_timestamp_column <- function(values) {
  parsed <- vapply(as.list(values), rrp_canonical_timestamp_number, numeric(1L))
  if (anyNA(parsed)) rrp_canonical_abort("invalid_timestamp")
  unname(parsed)
}

rrp_canonical_validate_discharge_episode <- function(episodes, as_of) {
  fields <- rrp_canonical_domain_fields()$discharge_episode
  rrp_canonical_validate_data_frame(episodes, fields, "discharge_episode")
  for (field in c("episode_id", "patient_id", "index_encounter_id")) {
    rrp_canonical_validate_identifier_column(episodes[[field]])
  }
  if (anyDuplicated(episodes$episode_id)) {
    rrp_canonical_abort("duplicate_episode_id")
  }
  admission <- rrp_canonical_timestamp_column(episodes$admission_time)
  discharge <- rrp_canonical_timestamp_column(episodes$discharge_time)
  followup <- rrp_canonical_timestamp_column(episodes$followup_window_end)
  if (any(admission >= discharge)) {
    rrp_canonical_abort("admission_not_before_discharge")
  }
  if (any(discharge > as_of)) rrp_canonical_abort("discharge_after_as_of")
  if (any(followup != discharge + 30 * 86400)) {
    rrp_canonical_abort("invalid_followup_window")
  }
  list(discharge = discharge, followup = followup)
}

rrp_canonical_validate_terminal_event <- function(events, episodes, episode_times, as_of) {
  fields <- rrp_canonical_domain_fields()$terminal_event
  rrp_canonical_validate_data_frame(events, fields, "terminal_event")
  for (field in c("terminal_event_id", "episode_id")) {
    rrp_canonical_validate_identifier_column(events[[field]])
  }
  if (anyDuplicated(events$terminal_event_id)) {
    rrp_canonical_abort("duplicate_terminal_event_id")
  }
  if (any(!events$event_type %in% c("readmission", "death"))) {
    rrp_canonical_abort("unsupported_event_type")
  }
  episode_index <- match(events$episode_id, episodes$episode_id)
  if (anyNA(episode_index)) rrp_canonical_abort("orphan_terminal_event")
  event_keys <- paste(events$episode_id, events$event_type, sep = "\u001f")
  if (anyDuplicated(event_keys[events$event_type == "readmission"])) {
    rrp_canonical_abort("multiple_readmissions")
  }
  if (anyDuplicated(event_keys[events$event_type == "death"])) {
    rrp_canonical_abort("multiple_deaths")
  }
  occurred <- rrp_canonical_timestamp_column(events$occurred_at)
  available <- rrp_canonical_timestamp_column(events$available_at)
  discharge <- episode_times$discharge[episode_index]
  followup <- episode_times$followup[episode_index]
  if (any(occurred <= discharge)) {
    rrp_canonical_abort("terminal_event_not_after_discharge")
  }
  if (any(occurred > followup)) {
    rrp_canonical_abort("terminal_event_after_followup")
  }
  if (any(occurred > available)) {
    rrp_canonical_abort("occurrence_after_availability")
  }
  if (any(available > as_of)) rrp_canonical_abort("availability_after_as_of")

  for (episode_id in unique(events$episode_id)) {
    selected <- events$episode_id == episode_id
    readmission <- occurred[selected & events$event_type == "readmission"]
    death <- occurred[selected & events$event_type == "death"]
    if (length(readmission) == 1L && length(death) == 1L && death < readmission) {
      rrp_canonical_abort("death_before_readmission")
    }
  }
  invisible(events)
}

rrp_canonical_copy_plain_value <- function(value) {
  if (is.data.frame(value)) {
    columns <- lapply(value, function(column) column[])
    return(structure(
      columns,
      names = names(value), row.names = attr(value, "row.names"),
      class = "data.frame"
    ))
  }
  if (is.list(value)) {
    copied <- lapply(value, rrp_canonical_copy_plain_value)
    if (!is.null(names(value))) names(copied) <- names(value)
    return(copied)
  }
  value[]
}

#' Admit a canonical bundle candidate
#'
#' Validate one detached, source-independent canonical candidate against an
#' exact expected context and return a detached admitted bundle. Expected
#' failures are raised as `rrp_canonical_error` conditions with stable `code`
#' values and bounded messages.
#'
#' @param candidate A closed plain named list containing the exact canonical
#'   bundle fields and the `discharge_episode` and `terminal_event` data frames.
#' @param expected_context A closed plain named list containing the exact
#'   bundle, project, producer, implementation, mapping, profile, capability,
#'   and authoritative as-of facts expected by the caller.
#'
#' @return An object with class `c("rrp_admitted_canonical_bundle", "list")`.
#' @export
rrp_admit_canonical_bundle <- function(candidate, expected_context) {
  expected <- rrp_canonical_validate_expected_context(expected_context)
  rrp_canonical_validate_candidate_shape(candidate)
  rrp_canonical_validate_candidate_identity(candidate, expected_context)

  candidate_as_of <- rrp_canonical_timestamp_number(candidate$as_of_time)
  if (is.na(candidate_as_of)) rrp_canonical_abort("invalid_as_of_time")
  if (!identical(candidate_as_of, expected$as_of)) {
    rrp_canonical_abort("as_of_time_mismatch")
  }
  candidate_capabilities <- rrp_canonical_validate_capabilities(
    candidate$capabilities
  )
  if (!identical(
    candidate_capabilities[sort(names(candidate_capabilities), method = "radix")],
    expected$capabilities[sort(names(expected$capabilities), method = "radix")]
  )) rrp_canonical_abort("capability_mismatch")

  rrp_canonical_validate_domains(candidate$domains)
  episodes <- candidate$domains$discharge_episode
  events <- candidate$domains$terminal_event
  episode_times <- rrp_canonical_validate_discharge_episode(
    episodes, candidate_as_of
  )
  rrp_canonical_validate_terminal_event(
    events, episodes, episode_times, candidate_as_of
  )

  admitted <- rrp_canonical_copy_plain_value(candidate)
  class(admitted) <- c("rrp_admitted_canonical_bundle", "list")
  admitted
}
