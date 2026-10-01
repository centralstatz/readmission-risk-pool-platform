rrp_product_abort <- function(code) {
  messages <- c(
    product_source_unavailable = "Logical product source is unavailable.",
    product_source_incomplete = "Logical product source is incomplete.",
    product_source_invalidated = "Logical product source is invalidated.",
    product_source_ambiguous = "Logical product source is ambiguous.",
    product_source_changed = "Logical product source changed during construction.",
    product_incompatible = "Logical product contracts are incompatible.",
    product_conformance_failed = "Logical product conformance failed."
  )
  stop(structure(
    list(message = unname(messages[[code]]), call = NULL, code = code),
    class = c("rrp_product_error", "error", "condition")
  ))
}

rrp_product_copy <- function(value) unserialize(serialize(value, NULL))

rrp_product_hash <- function(value, multiplier, modulus) {
  bytes <- as.integer(charToRaw(enc2utf8(value)))
  hash <- 0
  for (byte in bytes) hash <- (hash * multiplier + byte + 1) %% modulus
  as.integer(hash)
}

rrp_product_encode <- function(value) {
  if (is.null(value)) return("N")
  if (is.list(value)) {
    labels <- names(value)
    if (is.null(labels)) labels <- rep("", length(value))
    parts <- Map(function(label, item) {
      paste0(
        nchar(label, type = "bytes"), ":", label, "=",
        rrp_product_encode(item)
      )
    }, labels, value)
    return(paste0("L", length(value), "{", paste(parts, collapse = "|"), "}"))
  }
  if (length(value) != 1L) {
    return(rrp_product_encode(as.list(value)))
  }
  if (is.na(value)) return(paste0(typeof(value), ":NA"))
  rendered <- if (is.double(value)) {
    format(value, scientific = FALSE, trim = TRUE, digits = 17L)
  } else if (is.logical(value)) {
    if (value) "true" else "false"
  } else enc2utf8(as.character(value))
  paste0(typeof(value), ":", nchar(rendered, type = "bytes"), ":", rendered)
}

rrp_product_identity <- function(prefix, values) {
  encoded <- rrp_product_encode(values)
  paste0(prefix, sprintf(
    "%08x%08x",
    rrp_product_hash(encoded, 257, 2147483629),
    rrp_product_hash(encoded, 263, 2147483587)
  ))
}

rrp_product_canonical_time <- function(value) {
  valid <- is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:[.][0-9]+)?Z$",
      value, perl = TRUE)
  number <- if (valid) rrp_producer_timestamp_number(value) else NA_real_
  if (is.na(number)) rrp_product_abort("product_source_unavailable")
  rendered <- format(
    as.POSIXct(number, origin = "1970-01-01", tz = "UTC"),
    "%Y-%m-%dT%H:%M:%OS6", tz = "UTC", usetz = FALSE
  )
  rendered <- sub("0+$", "", rendered)
  rendered <- sub("[.]$", "", rendered)
  paste0(rendered, "Z")
}

rrp_product_time_number <- function(value) rrp_producer_timestamp_number(value)

rrp_product_disposition_fact <- function(value) {
  estimate <- value$estimate
  request <- value$request
  list(
    analytical_run_id = value$analytical_run_id,
    operation_run_id = value$operation_run_id,
    analytical_kind = value$analytical_kind,
    related_analytical_run_id = value$related_analytical_run_id,
    episode_id = value$episode_id,
    target_id = value$target_id,
    target_version = value$target_version,
    analytical_time = value$analytical_time,
    outcome = value$outcome,
    outcome_code = value$outcome_code,
    state_id = if (is.null(value$state)) NULL else value$state$state_id,
    request_id = if (is.null(request)) NULL else request$request_id,
    provider_id = value$provider_id,
    provider_version = value$provider_version,
    implementation_id = value$implementation_id,
    implementation_version = value$implementation_version,
    model_id = value$model_id,
    model_version = value$model_version,
    estimate_record_id = value$estimate_record_id,
    estimate_value = if (is.null(estimate)) NULL else estimate$estimate_value,
    target_interval_start = if (is.null(request)) NULL else request$target_interval_start,
    target_interval_end = if (is.null(request)) NULL else request$target_interval_end,
    target_interval_boundary = if (is.null(request)) NULL else request$target_interval_boundary
  )
}

rrp_product_source_snapshot <- function(port, operation_run_id, history_cutoff) {
  cutoff_number <- rrp_product_time_number(history_cutoff)
  scope_history <- tryCatch(
    rrpruntime::rrp_history_read_scope(port, operation_run_id),
    rrp_history_error = function(condition) {
      rrp_product_abort("product_source_unavailable")
    }
  )
  scope <- scope_history$scope
  if (rrp_product_time_number(scope$created_at) > cutoff_number) {
    rrp_product_abort("product_source_unavailable")
  }
  actions <- Filter(function(value) {
    rrp_product_time_number(value$effective_time) <= cutoff_number
  }, scope_history$actions)
  excluded <- Filter(function(value) {
    identical(value$target_kind, "operational_scope") &&
      identical(value$target_id, operation_run_id)
  }, actions)
  if (length(excluded)) rrp_product_abort("product_source_invalidated")

  dispositions <- Filter(function(value) {
    identical(value$operation_run_id, operation_run_id) &&
      identical(value$analytical_kind, "initial") &&
      rrp_product_time_number(value$terminal_time) <= cutoff_number
  }, scope_history$dispositions)
  episode_ids <- vapply(dispositions, `[[`, character(1L), "episode_id")
  complete <- !anyDuplicated(episode_ids) &&
    length(episode_ids) == scope$expected_episode_count &&
    identical(
      tryCatch(
        rrpruntime::rrp_history_membership_fingerprint(episode_ids),
        error = function(condition) NA_character_
      ),
      scope$membership_fingerprint
    )
  if (!complete) rrp_product_abort("product_source_incomplete")
  episode_ids <- sort(episode_ids, method = "radix")

  current <- vector("list", length(episode_ids))
  names(current) <- episode_ids
  trajectories <- vector("list", length(episode_ids))
  names(trajectories) <- episode_ids
  for (episode_id in episode_ids) {
    episode <- tryCatch(
      rrpruntime::rrp_history_read_episode(
        port, episode_id, scope$target_id, history_cutoff
      ),
      rrp_history_error = function(condition) {
        rrp_product_abort(if (identical(condition$code, "ambiguous_current")) {
          "product_source_ambiguous"
        } else "product_source_unavailable")
      }
    )
    times <- unique(vapply(Filter(function(value) {
      rrp_product_time_number(value$analytical_time) <=
        rrp_product_time_number(scope$analytical_time)
    }, episode$dispositions), `[[`, character(1L), "analytical_time"))
    if (length(times)) {
      times <- times[order(vapply(times, rrp_product_time_number, numeric(1L)),
        method = "radix")]
    }
    values <- lapply(times, function(time) tryCatch(
      rrpruntime::rrp_history_read_current(
        port, episode_id, scope$target_id, time, history_cutoff
      ),
      rrp_history_error = function(condition) {
        rrp_product_abort(if (identical(condition$code, "ambiguous_current")) {
          "product_source_ambiguous"
        } else "product_source_unavailable")
      }
    ))
    values <- Filter(Negate(is.null), values)
    if (length(values)) {
      ids <- vapply(values, `[[`, character(1L), "analytical_run_id")
      values <- values[!duplicated(ids)]
    }
    trajectories[[episode_id]] <- values
    current[[episode_id]] <- tryCatch(
      rrpruntime::rrp_history_read_current(
        port, episode_id, scope$target_id, scope$analytical_time, history_cutoff
      ),
      rrp_history_error = function(condition) {
        rrp_product_abort(if (identical(condition$code, "ambiguous_current")) {
          "product_source_ambiguous"
        } else "product_source_unavailable")
      }
    )
    if (is.null(current[[episode_id]])) {
      rrp_product_abort("product_source_unavailable")
    }
  }
  facts <- list(
    scope = unname(scope[c(
      "scope_contract_id", "scope_contract_version", "scope_record_id",
      "operation_run_id", "state_id", "product_id", "development_version",
      "rrp_api_version", "project_id", "project_version", "bundle_contract_id",
      "bundle_contract_version", "bundle_instance_id", "canonical_profile_id",
      "canonical_profile_version", "producer_id", "producer_version",
      "producer_implementation_id", "producer_implementation_version",
      "mapping_id", "mapping_version", "target_id", "target_version",
      "analytical_time", "expected_episode_count", "membership_fingerprint",
      "created_at"
    )]),
    membership = episode_ids,
    current = lapply(current, rrp_product_disposition_fact),
    trajectory = lapply(trajectories, function(values) {
      lapply(values, rrp_product_disposition_fact)
    })
  )
  list(
    scope = scope,
    episode_ids = episode_ids,
    initial_disposition_count = as.integer(length(dispositions)),
    current = current,
    trajectories = trajectories,
    facts = facts,
    fingerprint = rrp_product_identity("rrp.source-history.", facts)
  )
}

rrp_product_set_identity_values <- function(scope, cutoff, fingerprint, contracts) {
  list(
    contracts$set[["Contract-ID"]], contracts$set[["Contract-Version"]],
    contracts$set[["Builder-ID"]], contracts$set[["Builder-Version"]],
    contracts$current[["Contract-ID"]], contracts$current[["Contract-Version"]],
    contracts$trajectory[["Contract-ID"]], contracts$trajectory[["Contract-Version"]],
    contracts$summary[["Contract-ID"]], contracts$summary[["Contract-Version"]],
    scope$project_id, scope$state_id, scope$operation_run_id,
    scope$scope_record_id, scope$analytical_time, cutoff, scope$target_id,
    scope$target_version, fingerprint
  )
}

rrp_product_estimate_row <- function(value, contract, set_id, trajectory = FALSE) {
  request <- value$request
  estimate <- value$estimate
  key <- if (trajectory) list(value$analytical_run_id) else list(
    value$episode_id, value$target_id, value$target_version
  )
  row <- list(
    product_row_id = rrp_product_identity("rrp.product-row.", c(list(
      contract[["Contract-ID"]], contract[["Contract-Version"]], set_id
    ), key)),
    episode_id = value$episode_id,
    target_id = value$target_id,
    target_version = value$target_version,
    analytical_time = value$analytical_time,
    estimate_value = estimate$estimate_value,
    estimate_record_id = value$estimate_record_id,
    analytical_run_id = value$analytical_run_id,
    source_operation_run_id = value$operation_run_id,
    state_id = value$state$state_id,
    request_id = request$request_id,
    provider_id = value$provider_id,
    provider_version = value$provider_version,
    implementation_id = value$implementation_id,
    implementation_version = value$implementation_version,
    model_id = if (is.null(value$model_id)) NA_character_ else value$model_id,
    model_version = if (is.null(value$model_version)) NA_character_ else value$model_version,
    target_interval_start = request$target_interval_start,
    target_interval_end = request$target_interval_end,
    target_interval_boundary = request$target_interval_boundary
  )
  if (trajectory) row <- c(row, list(
    analytical_kind = value$analytical_kind,
    related_analytical_run_id = if (is.null(value$related_analytical_run_id)) {
      NA_character_
    } else value$related_analytical_run_id
  ))
  row
}

rrp_product_rows_frame <- function(rows, fields, double_fields = character(),
                                   integer_fields = character(),
                                   logical_fields = character()) {
  if (!length(rows)) {
    output <- vector("list", length(fields))
    names(output) <- fields
    for (field in fields) output[[field]] <- if (field %in% double_fields) {
      numeric()
    } else if (field %in% integer_fields) {
      integer()
    } else if (field %in% logical_fields) logical() else character()
    return(as.data.frame(output, stringsAsFactors = FALSE, check.names = FALSE))
  }
  output <- as.data.frame(do.call(rbind, lapply(rows, function(row) {
    unlist(row[fields], use.names = FALSE)
  })), stringsAsFactors = FALSE, check.names = FALSE)
  names(output) <- fields
  for (field in double_fields) output[[field]] <- as.double(output[[field]])
  for (field in integer_fields) output[[field]] <- as.integer(output[[field]])
  for (field in logical_fields) output[[field]] <- as.logical(output[[field]])
  output
}

rrp_product_member <- function(contract, set_id, data) structure(list(
  product_contract_id = contract[["Contract-ID"]],
  product_contract_version = contract[["Contract-Version"]],
  product_instance_id = rrp_product_identity("rrp.product.", list(
    contract[["Contract-ID"]], contract[["Contract-Version"]], set_id
  )),
  product_set_id = set_id,
  row_count = as.integer(nrow(data)),
  data = data
), class = c("rrp_logical_product", "list"))

rrp_product_build_from_snapshot <- function(snapshot, cutoff, contracts) {
  scope <- snapshot$scope
  set_id <- rrp_product_identity(
    "rrp.product-set.",
    rrp_product_set_identity_values(scope, cutoff, snapshot$fingerprint, contracts)
  )
  accepted_current <- Filter(function(value) {
    identical(value$outcome, "accepted_estimate")
  }, snapshot$current)
  current_rows <- lapply(accepted_current, rrp_product_estimate_row,
    contract = contracts$current, set_id = set_id)
  current <- rrp_product_rows_frame(
    current_rows, rrp_product_current_fields(), "estimate_value"
  )
  if (nrow(current)) current <- current[order(
    current$episode_id, current$target_id, current$target_version,
    method = "radix"
  ), , drop = FALSE]

  trajectory_values <- unlist(snapshot$trajectories, recursive = FALSE)
  trajectory_values <- Filter(function(value) {
    identical(value$outcome, "accepted_estimate")
  }, trajectory_values)
  trajectory_rows <- lapply(trajectory_values, rrp_product_estimate_row,
    contract = contracts$trajectory, set_id = set_id, trajectory = TRUE)
  trajectory <- rrp_product_rows_frame(
    trajectory_rows, rrp_product_trajectory_fields(), "estimate_value"
  )
  if (nrow(trajectory)) trajectory <- trajectory[order(
    trajectory$episode_id,
    vapply(trajectory$analytical_time, rrp_product_time_number, numeric(1L)),
    trajectory$analytical_run_id, method = "radix"
  ), , drop = FALSE]

  outcomes <- vapply(snapshot$current, `[[`, character(1L), "outcome")
  codes <- vapply(snapshot$current, `[[`, character(1L), "outcome_code")
  count <- function(values, selected) as.integer(sum(values %in% selected))
  summary_row_id <- rrp_product_identity("rrp.product-row.", list(
    contracts$summary[["Contract-ID"]], contracts$summary[["Contract-Version"]],
    set_id, scope$scope_record_id
  ))
  summary_row <- list(
    product_row_id = summary_row_id,
    operation_run_id = scope$operation_run_id,
    scope_record_id = scope$scope_record_id,
    state_id = scope$state_id,
    project_id = scope$project_id,
    project_version = scope$project_version,
    bundle_instance_id = scope$bundle_instance_id,
    canonical_profile_id = scope$canonical_profile_id,
    canonical_profile_version = scope$canonical_profile_version,
    producer_id = scope$producer_id,
    producer_version = scope$producer_version,
    producer_implementation_id = scope$producer_implementation_id,
    producer_implementation_version = scope$producer_implementation_version,
    mapping_id = scope$mapping_id,
    mapping_version = scope$mapping_version,
    target_id = scope$target_id,
    target_version = scope$target_version,
    analytical_time = scope$analytical_time,
    scope_created_at = scope$created_at,
    expected_episode_count = scope$expected_episode_count,
    initial_disposition_count = snapshot$initial_disposition_count,
    effective_disposition_count = as.integer(length(snapshot$current)),
    eligible_count = count(outcomes, c(
      "accepted_estimate", "provider_incompatible",
      "provider_declared_failure", "detected_failure"
    )),
    accepted_estimate_count = count(outcomes, "accepted_estimate"),
    provider_incompatible_count = count(outcomes, "provider_incompatible"),
    provider_declared_failure_count = count(outcomes, "provider_declared_failure"),
    detected_failure_count = count(outcomes, "detected_failure"),
    ineligible_count = count(outcomes, "ineligible"),
    episode_before_discharge_count = count(codes, "episode_before_discharge"),
    target_horizon_exhausted_count = count(codes, "target_horizon_exhausted"),
    episode_already_readmitted_count = count(codes, "episode_already_readmitted"),
    episode_already_dead_count = count(codes, "episode_already_dead"),
    membership_fingerprint = scope$membership_fingerprint,
    complete = TRUE
  )
  summary_integers <- rrp_product_summary_fields()[20:32]
  summary <- rrp_product_rows_frame(
    list(summary_row), rrp_product_summary_fields(),
    integer_fields = summary_integers, logical_fields = "complete"
  )
  products <- list(
    current_remaining_risk = rrp_product_member(contracts$current, set_id, current),
    remaining_risk_trajectory = rrp_product_member(
      contracts$trajectory, set_id, trajectory
    ),
    operational_scope_summary = rrp_product_member(
      contracts$summary, set_id, summary
    )
  )
  references <- lapply(products, function(value) list(
    product_contract_id = value$product_contract_id,
    product_contract_version = value$product_contract_version,
    product_instance_id = value$product_instance_id
  ))
  structure(list(
    product_set_contract_id = contracts$set[["Contract-ID"]],
    product_set_contract_version = contracts$set[["Contract-Version"]],
    product_set_id = set_id,
    builder_id = contracts$set[["Builder-ID"]],
    builder_version = contracts$set[["Builder-Version"]],
    product_id = scope$product_id,
    development_version = scope$development_version,
    rrp_api_version = scope$rrp_api_version,
    project_id = scope$project_id,
    project_version = scope$project_version,
    state_id = scope$state_id,
    source_scope_contract_id = scope$scope_contract_id,
    source_scope_contract_version = scope$scope_contract_version,
    source_disposition_contract_id = "rrp.history.episode-disposition",
    source_disposition_contract_version = "0.1.0",
    source_action_contract_id = "rrp.history.action",
    source_action_contract_version = "0.1.0",
    source_history_port_contract_id = "rrp.history.port",
    source_history_port_contract_version = "0.1.0",
    logical_history_format_version = "0.1.0",
    source_operation_run_id = scope$operation_run_id,
    source_scope_record_id = scope$scope_record_id,
    bundle_contract_id = scope$bundle_contract_id,
    bundle_contract_version = scope$bundle_contract_version,
    bundle_instance_id = scope$bundle_instance_id,
    canonical_profile_id = scope$canonical_profile_id,
    canonical_profile_version = scope$canonical_profile_version,
    producer_id = scope$producer_id,
    producer_version = scope$producer_version,
    producer_implementation_id = scope$producer_implementation_id,
    producer_implementation_version = scope$producer_implementation_version,
    mapping_id = scope$mapping_id,
    mapping_version = scope$mapping_version,
    target_id = scope$target_id,
    target_version = scope$target_version,
    source_analytical_time = scope$analytical_time,
    source_history_cutoff = cutoff,
    source_history_fingerprint = snapshot$fingerprint,
    source_history_fingerprint_algorithm = "dual_modular_hash_v1",
    member_references = references,
    members = products
  ), class = c("rrp_logical_product_set", "list"))
}

rrp_product_valid_identity <- function(value, prefix = NULL) {
  valid <- is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl("^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$", value)
  valid && (is.null(prefix) || startsWith(value, prefix))
}

rrp_product_validate_member <- function(member, contract) {
  valid <- is.list(member) &&
    identical(class(member), c("rrp_logical_product", "list")) &&
    identical(names(member), c(
      "product_contract_id", "product_contract_version", "product_instance_id",
      "product_set_id", "row_count", "data"
    )) && identical(member$product_contract_id, contract[["Contract-ID"]]) &&
    identical(member$product_contract_version, contract[["Contract-Version"]]) &&
    identical(member$product_instance_id, rrp_product_identity(
      "rrp.product.", list(member$product_contract_id,
        member$product_contract_version, member$product_set_id)
    )) && is.integer(member$row_count) && length(member$row_count) == 1L &&
    identical(member$row_count, as.integer(nrow(member$data))) &&
    identical(class(member$data), "data.frame") &&
    identical(names(member$data), strsplit(
      contract[["Row-Fields"]], ",", fixed = TRUE
    )[[1L]])
  if (!valid) rrp_product_abort("product_conformance_failed")
  fields <- names(member$data)
  selected <- function(name) {
    value <- contract[[name]]
    if (identical(value, "none")) character() else
      strsplit(value, ",", fixed = TRUE)[[1L]]
  }
  character_fields <- selected("Character-Fields")
  nullable_fields <- selected("Nullable-Fields")
  character_valid <- vapply(character_fields, function(field) {
    value <- member$data[[field]]
    is.character(value) && (field %in% nullable_fields || !anyNA(value))
  }, logical(1L))
  double_valid <- vapply(selected("Double-Fields"), function(field) {
    is.double(member$data[[field]]) && !anyNA(member$data[[field]])
  }, logical(1L))
  integer_valid <- vapply(selected("Integer-Fields"), function(field) {
    is.integer(member$data[[field]]) && !anyNA(member$data[[field]])
  }, logical(1L))
  logical_valid <- vapply(selected("Logical-Fields"), function(field) {
    is.logical(member$data[[field]]) && !anyNA(member$data[[field]])
  }, logical(1L))
  timestamps <- selected("Timestamp-Fields")
  timestamp_valid <- vapply(timestamps, function(field) {
    all(!is.na(vapply(member$data[[field]], rrp_product_time_number, numeric(1L))))
  }, logical(1L))
  if (!all(c(character_valid, double_valid, integer_valid, logical_valid,
      timestamp_valid)) || anyDuplicated(member$data$product_row_id)) {
    rrp_product_abort("product_conformance_failed")
  }
  invisible(member)
}

rrp_validate_product_set <- function(value, contracts) {
  scalar_fields <- setdiff(rrp_product_set_fields(), c(
    "member_references", "members"
  ))
  if (!is.list(value) ||
      !identical(class(value), c("rrp_logical_product_set", "list")) ||
      !identical(names(value), rrp_product_set_fields()) ||
      !identical(value$product_set_contract_id, contracts$set[["Contract-ID"]]) ||
      !identical(value$product_set_contract_version, contracts$set[["Contract-Version"]]) ||
      !identical(value$builder_id, contracts$set[["Builder-ID"]]) ||
      !identical(value$builder_version, contracts$set[["Builder-Version"]]) ||
      !all(vapply(value[scalar_fields], function(item) {
        is.character(item) && length(item) == 1L && !is.na(item) && nzchar(item)
      }, logical(1L))) ||
      !identical(value$product_id, "readmission-risk-pool-platform") ||
      !identical(value$development_version, "1.0.0-dev") ||
      !identical(value$source_scope_contract_id,
        "rrp.history.operational-scope") ||
      !identical(value$source_scope_contract_version, "0.1.0") ||
      !identical(value$source_disposition_contract_id,
        "rrp.history.episode-disposition") ||
      !identical(value$source_disposition_contract_version, "0.1.0") ||
      !identical(value$source_action_contract_id, "rrp.history.action") ||
      !identical(value$source_action_contract_version, "0.1.0") ||
      !identical(value$source_history_port_contract_id, "rrp.history.port") ||
      !identical(value$source_history_port_contract_version, "0.1.0") ||
      !identical(value$logical_history_format_version, "0.1.0") ||
      is.na(rrp_product_time_number(value$source_analytical_time)) ||
      is.na(rrp_product_time_number(value$source_history_cutoff)) ||
      rrp_product_time_number(value$source_history_cutoff) <
        rrp_product_time_number(value$source_analytical_time) ||
      !identical(names(value$members), c(
        "current_remaining_risk", "remaining_risk_trajectory",
        "operational_scope_summary"
      )) || !identical(names(value$member_references), names(value$members))) {
    rrp_product_abort("product_conformance_failed")
  }
  expected_set_id <- rrp_product_identity("rrp.product-set.", list(
    contracts$set[["Contract-ID"]], contracts$set[["Contract-Version"]],
    contracts$set[["Builder-ID"]], contracts$set[["Builder-Version"]],
    contracts$current[["Contract-ID"]], contracts$current[["Contract-Version"]],
    contracts$trajectory[["Contract-ID"]], contracts$trajectory[["Contract-Version"]],
    contracts$summary[["Contract-ID"]], contracts$summary[["Contract-Version"]],
    value$project_id, value$state_id, value$source_operation_run_id,
    value$source_scope_record_id, value$source_analytical_time,
    value$source_history_cutoff, value$target_id, value$target_version,
    value$source_history_fingerprint
  ))
  if (!identical(value$product_set_id, expected_set_id) ||
      !grepl("^rrp[.]source-history[.][0-9a-f]{16}$",
        value$source_history_fingerprint) ||
      !identical(value$source_history_fingerprint_algorithm,
        "dual_modular_hash_v1")) {
    rrp_product_abort("product_conformance_failed")
  }
  member_contracts <- list(
    current_remaining_risk = contracts$current,
    remaining_risk_trajectory = contracts$trajectory,
    operational_scope_summary = contracts$summary
  )
  for (name in names(value$members)) {
    member <- value$members[[name]]
    rrp_product_validate_member(member, member_contracts[[name]])
    reference <- value$member_references[[name]]
    if (!identical(reference, list(
      product_contract_id = member$product_contract_id,
      product_contract_version = member$product_contract_version,
      product_instance_id = member$product_instance_id
    )) || !identical(member$product_set_id, value$product_set_id)) {
      rrp_product_abort("product_conformance_failed")
    }
  }
  current <- value$members$current_remaining_risk$data
  trajectory <- value$members$remaining_risk_trajectory$data
  summary <- value$members$operational_scope_summary$data
  current_order <- if (nrow(current)) order(
    current$episode_id, current$target_id, current$target_version, method = "radix"
  ) else integer()
  trajectory_order <- if (nrow(trajectory)) order(
    trajectory$episode_id,
    vapply(trajectory$analytical_time, rrp_product_time_number, numeric(1L)),
    trajectory$analytical_run_id, method = "radix"
  ) else integer()
  current_ids <- if (nrow(current)) vapply(seq_len(nrow(current)), function(i) {
    rrp_product_identity("rrp.product-row.", list(
      contracts$current[["Contract-ID"]], contracts$current[["Contract-Version"]],
      value$product_set_id, current$episode_id[[i]], current$target_id[[i]],
      current$target_version[[i]]
    ))
  }, character(1L)) else character()
  trajectory_ids <- if (nrow(trajectory)) unname(vapply(
    trajectory$analytical_run_id, function(id) rrp_product_identity(
      "rrp.product-row.", list(
        contracts$trajectory[["Contract-ID"]],
        contracts$trajectory[["Contract-Version"]], value$product_set_id, id
      )
    ), character(1L)
  )) else character()
  summary_id <- rrp_product_identity("rrp.product-row.", list(
    contracts$summary[["Contract-ID"]], contracts$summary[["Contract-Version"]],
    value$product_set_id, value$source_scope_record_id
  ))
  paired_models <- function(data) {
    all(is.na(data$model_id) == is.na(data$model_version))
  }
  valid_rows <- identical(current_order, seq_len(nrow(current))) &&
    identical(trajectory_order, seq_len(nrow(trajectory))) &&
    identical(current$product_row_id, current_ids) &&
    identical(trajectory$product_row_id, trajectory_ids) &&
    !anyDuplicated(paste(current$episode_id, current$target_id,
      current$target_version, sep = "\r")) &&
    !anyDuplicated(paste(trajectory$episode_id, trajectory$analytical_time,
      sep = "\r")) &&
    all(current$estimate_value >= 0 & current$estimate_value <= 1) &&
    all(trajectory$estimate_value >= 0 & trajectory$estimate_value <= 1) &&
    paired_models(current) && paired_models(trajectory) &&
    all(current$target_interval_boundary == "(start,end]") &&
    all(trajectory$target_interval_boundary == "(start,end]") &&
    all(trajectory$analytical_kind %in% c("initial", "retry", "restatement")) &&
    all(vapply(current$analytical_time, rrp_product_time_number, numeric(1L)) <=
      rrp_product_time_number(value$source_analytical_time)) &&
    all(vapply(trajectory$analytical_time, rrp_product_time_number, numeric(1L)) <=
      rrp_product_time_number(value$source_analytical_time)) &&
    all(current$target_id == value$target_id) &&
    all(current$target_version == value$target_version) &&
    all(trajectory$target_id == value$target_id) &&
    all(trajectory$target_version == value$target_version) &&
    nrow(summary) == 1L && isTRUE(summary$complete[[1L]]) &&
    identical(summary$product_row_id[[1L]], summary_id) &&
    identical(summary$state_id[[1L]], value$state_id) &&
    identical(summary$project_id[[1L]], value$project_id) &&
    identical(summary$project_version[[1L]], value$project_version) &&
    identical(summary$bundle_instance_id[[1L]], value$bundle_instance_id) &&
    identical(summary$canonical_profile_id[[1L]], value$canonical_profile_id) &&
    identical(summary$canonical_profile_version[[1L]],
      value$canonical_profile_version) &&
    identical(summary$producer_id[[1L]], value$producer_id) &&
    identical(summary$producer_version[[1L]], value$producer_version) &&
    identical(summary$producer_implementation_id[[1L]],
      value$producer_implementation_id) &&
    identical(summary$producer_implementation_version[[1L]],
      value$producer_implementation_version) &&
    identical(summary$mapping_id[[1L]], value$mapping_id) &&
    identical(summary$mapping_version[[1L]], value$mapping_version) &&
    identical(summary$target_id[[1L]], value$target_id) &&
    identical(summary$target_version[[1L]], value$target_version) &&
    identical(summary$analytical_time[[1L]], value$source_analytical_time) &&
    summary$expected_episode_count[[1L]] ==
      summary$effective_disposition_count[[1L]] &&
    summary$expected_episode_count[[1L]] ==
      summary$initial_disposition_count[[1L]] &&
    summary$eligible_count[[1L]] ==
      summary$expected_episode_count[[1L]] - summary$ineligible_count[[1L]] &&
    summary$expected_episode_count[[1L]] ==
      sum(summary$accepted_estimate_count[[1L]],
        summary$provider_incompatible_count[[1L]],
        summary$provider_declared_failure_count[[1L]],
        summary$detected_failure_count[[1L]], summary$ineligible_count[[1L]]) &&
    summary$ineligible_count[[1L]] == sum(
      summary$episode_before_discharge_count[[1L]],
      summary$target_horizon_exhausted_count[[1L]],
      summary$episode_already_readmitted_count[[1L]],
      summary$episode_already_dead_count[[1L]]
    ) && identical(summary$operation_run_id[[1L]], value$source_operation_run_id) &&
    identical(summary$scope_record_id[[1L]], value$source_scope_record_id)
  if (!valid_rows) rrp_product_abort("product_conformance_failed")
  invisible(value)
}

rrp_build_product_set_from_port <- function(
  port, operation_run_id, history_cutoff, contracts
) {
  cutoff <- rrp_product_canonical_time(history_cutoff)
  first <- rrp_product_source_snapshot(port, operation_run_id, cutoff)
  product_set <- rrp_product_build_from_snapshot(first, cutoff, contracts)
  rrp_validate_product_set(product_set, contracts)
  second <- tryCatch(
    rrp_product_source_snapshot(port, operation_run_id, cutoff),
    rrp_product_error = function(condition) {
      rrp_product_abort("product_source_changed")
    },
    rrp_history_error = function(condition) {
      rrp_product_abort("product_source_changed")
    }
  )
  if (!identical(first$facts, second$facts) ||
      !identical(first$fingerprint, second$fingerprint)) {
    rrp_product_abort("product_source_changed")
  }
  rrp_product_copy(product_set)
}

rrp_product_failure_result <- function(condition) {
  code <- if (inherits(condition, "rrp_product_error")) {
    condition$code
  } else if (inherits(condition, "rrp_resource_error")) {
    "product_incompatible"
  } else if (inherits(condition, "rrp_history_error") &&
             identical(condition$code, "ambiguous_current")) {
    "product_source_ambiguous"
  } else "product_source_unavailable"
  rrp_new_operation_result(
    "rrp.build-product-set", "failure", NULL,
    list(rrp_new_diagnostic(code, "error", "Logical product construction failed."))
  )
}

#' Build one coherent logical readmission-risk product set
#'
#' Construct three detached logical products from one explicitly selected,
#' complete governed history scope and one explicit history cutoff.
#'
#' @param software_catalog A validated explicit-root software resource catalog.
#' @param project_root One explicit initialized independent-project root.
#' @param operation_run_id One exact source operation-run identity.
#' @param history_cutoff One explicit RFC 3339 UTC history cutoff.
#' @return A common RRP operation result. On success, `value` is one detached
#'   conforming `rrp_logical_product_set`.
#' @export
rrp_build_product_set <- function(
  software_catalog, project_root, operation_run_id, history_cutoff
) tryCatch({
  contracts <- rrp_product_contracts(software_catalog)
  durable <- rrp_durable_port(software_catalog, project_root)
  value <- rrp_build_product_set_from_port(
    durable$port, operation_run_id, history_cutoff, contracts
  )
  rrp_new_operation_result(
    "rrp.build-product-set", "success", value, list()
  )
}, rrp_product_error = rrp_product_failure_result,
rrp_resource_error = rrp_product_failure_result,
rrp_project_error = rrp_product_failure_result,
rrp_state_error = rrp_product_failure_result,
rrp_history_error = rrp_product_failure_result,
error = rrp_product_failure_result)
