rrp_durable_abort <- function(code, message) {
  stop(structure(
    list(message = message, call = NULL, code = code),
    class = c("rrp_durable_error", "error", "condition")
  ))
}

rrp_durable_validate_key <- function(value, label = "operation") {
  if (!rrp_producer_scalar_string(value) ||
      nchar(value, type = "bytes") > 160L || grepl("[[:cntrl:]]", value)) {
    rrp_durable_abort(
      paste0("invalid_", label, "_key"),
      paste0("The ", label, " key is invalid.")
    )
  }
  invisible(value)
}

rrp_durable_canonical_time <- function(value) {
  number <- rrp_producer_timestamp_number(value)
  if (is.na(number)) rrp_durable_abort(
    "invalid_analytical_time", "The analytical time is invalid."
  )
  rendered <- format(
    as.POSIXct(number, origin = "1970-01-01", tz = "UTC"),
    "%Y-%m-%dT%H:%M:%OS6", tz = "UTC", usetz = FALSE
  )
  rendered <- sub("0+$", "", rendered)
  rendered <- sub("[.]$", "", rendered)
  paste0(rendered, "Z")
}

rrp_durable_failure_result <- function(condition, operation_id) {
  code <- if (rrp_diagnostic_code_is_valid(condition$code)) {
    condition$code
  } else {
    "operation_failed"
  }
  rrp_new_operation_result(
    operation_id = operation_id,
    status = "failure",
    value = NULL,
    diagnostics = list(rrp_new_diagnostic(
      code = code,
      severity = "error",
      message = "Durable history operation failed."
    ))
  )
}

rrp_durable_port <- function(software_catalog, project_root) {
  context <- rrp_load_project(software_catalog, project_root)
  contracts <- rrp_state_contracts(software_catalog)
  if (!rrp_state_path_exists(context$state_path)) rrp_state_abort(
    "state_uninitialized", "Project state has not been initialized."
  )
  metadata <- rrp_state_inspect_root(context$state_path, context, contracts)
  port <- rrpruntime::rrp_new_history_port(rrp_duckdb_adapter(
    file.path(context$state_path, "history.duckdb"), metadata, contracts
  ))
  list(context = context, metadata = metadata, port = port)
}

rrp_durable_scope <- function(context, metadata, admitted, operation_key, time) {
  episodes <- admitted$domains$discharge_episode$episode_id
  runtime_contracts <- rrp_runtime_contracts(
    context$software_catalog,
    rrp_canonical_contracts(context$software_catalog)
  )
  rrpruntime::rrp_new_operational_scope(list(
    operation_key = operation_key,
    state_id = unname(metadata[["State-ID"]]),
    product_id = "readmission-risk-pool-platform",
    development_version = "1.0.0-dev",
    rrp_api_version = context$manifest[["Supported-RRP-API-Version"]],
    project_api_id = context$manifest[["Project-Contract-ID"]],
    project_api_version = context$manifest[["Project-Contract-Version"]],
    project_id = admitted$project_id,
    project_version = admitted$project_version,
    bundle_contract_id = admitted$bundle_contract_id,
    bundle_contract_version = admitted$bundle_contract_version,
    bundle_instance_id = admitted$bundle_instance_id,
    canonical_profile_id = admitted$canonical_profile_id,
    canonical_profile_version = admitted$canonical_profile_version,
    producer_id = admitted$producer_id,
    producer_version = admitted$producer_version,
    producer_implementation_id = admitted$implementation_id,
    producer_implementation_version = admitted$implementation_version,
    mapping_id = admitted$mapping_id,
    mapping_version = admitted$mapping_version,
    target_id = runtime_contracts$readmission_risk_target[["Specification-ID"]],
    target_version = runtime_contracts$readmission_risk_target[["Specification-Version"]],
    analytical_time = time,
    created_at = time
  ), episodes)
}

rrp_durable_provider_evidence <- function(context, state, provider_context) {
  previous_directory <- getwd()
  on.exit(if (!identical(getwd(), previous_directory)) {
    setwd(previous_directory)
  }, add = TRUE)
  engine <- get(
    "rrp_runtime_risk_evidence",
    envir = asNamespace("rrpruntime"), inherits = FALSE
  )
  rrp_project_with_libraries(context$extension_library_path, function() {
    engine(state, rrp_risk_runtime_provider(context$provider), provider_context)
  })
}

rrp_durable_disposition_values <- function(
  context, scope, admitted, episode_id, runtime_contracts,
  analytical_kind = "initial", related_analytical_run_id = NULL,
  analytical_key = NULL
) {
  row <- admitted$domains$discharge_episode[
    admitted$domains$discharge_episode$episode_id == episode_id,
    , drop = FALSE
  ]
  prepared <- tryCatch(
    rrpruntime::rrp_prepare_episode_state(
      admitted, episode_id, scope$analytical_time,
      rrp_episode_state_expected_context(
        runtime_contracts,
        rrp_canonical_contracts(context$software_catalog)
      )
    ),
    rrp_runtime_error = identity
  )
  ineligible_codes <- c(
    "episode_before_discharge", "target_horizon_exhausted",
    "episode_already_readmitted", "episode_already_dead"
  )
  if (inherits(prepared, "rrp_runtime_error")) {
    if (!prepared$code %in% ineligible_codes) stop(prepared)
    evidence <- list(
      outcome = "ineligible", outcome_code = prepared$code,
      provider_status = "not_invoked", request = NULL, estimate = NULL
    )
    state <- NULL
    provider <- structure(vector("list", 6L), names = c(
      "provider_id", "provider_version", "implementation_id",
      "implementation_version", "model_id", "model_version"
    ))
  } else {
    state <- prepared
    evidence <- rrp_durable_provider_evidence(
      context, state,
      rrp_provider_expected_context(
        runtime_contracts,
        rrp_canonical_contracts(context$software_catalog)
      )
    )
    provider <- list(
      provider_id = context$provider$component_id,
      provider_version = context$provider$component_version,
      implementation_id = context$provider$implementation_id,
      implementation_version = context$provider$implementation_version,
      model_id = context$provider$model_id,
      model_version = context$provider$model_version
    )
  }
  c(list(
    analytical_kind = analytical_kind,
    related_analytical_run_id = related_analytical_run_id,
    analytical_key = analytical_key,
    episode_id = episode_id,
    patient_id = row$patient_id[[1L]],
    target_id = scope$target_id,
    target_version = scope$target_version,
    analytical_time = scope$analytical_time,
    outcome = evidence$outcome,
    outcome_code = evidence$outcome_code,
    eligibility_status = if (identical(evidence$outcome, "ineligible")) {
      "ineligible"
    } else {
      "eligible"
    },
    state = state,
    request = evidence$request
  ), provider, list(
    provider_status = evidence$provider_status,
    estimate = evidence$estimate,
    terminal_time = scope$analytical_time
  ))
}

rrp_durable_progress_value <- function(history) {
  list(
    operation_run_id = history$scope$operation_run_id,
    expected_episode_count = history$progress$expected_episode_count,
    dispositioned_episode_count = history$progress$dispositioned_episode_count,
    complete = history$progress$complete
  )
}

rrp_durable_execute <- function(
  software_catalog, project_root, analytical_time, operation_key,
  interrupt_after = NULL
) {
  rrp_durable_validate_key(operation_key)
  time <- rrp_durable_canonical_time(analytical_time)
  durable <- rrp_durable_port(software_catalog, project_root)
  producer <- rrp_execute_producer(software_catalog, project_root, analytical_time)
  if (!rrp_operation_succeeded(producer)) {
    condition <- structure(
      list(code = producer$diagnostics[[1L]]$code),
      class = c("rrp_durable_error", "error", "condition")
    )
    stop(condition)
  }
  admitted <- producer$value
  scope <- rrp_durable_scope(
    durable$context, durable$metadata, admitted, operation_key, time
  )
  rrpruntime::rrp_history_append_scope(durable$port, scope)
  runtime_contracts <- rrp_runtime_contracts(
    durable$context$software_catalog,
    rrp_canonical_contracts(durable$context$software_catalog)
  )
  history <- rrpruntime::rrp_history_read_scope(
    durable$port, scope$operation_run_id
  )
  committed <- vapply(Filter(function(value) {
    identical(value$analytical_kind, "initial")
  }, history$dispositions), `[[`, character(1L), "episode_id")
  episode_ids <- sort(
    admitted$domains$discharge_episode$episode_id, method = "radix"
  )
  appended <- 0L
  for (episode_id in setdiff(episode_ids, committed)) {
    disposition <- rrpruntime::rrp_new_episode_disposition(
      scope,
      rrp_durable_disposition_values(
        durable$context, scope, admitted, episode_id, runtime_contracts
      )
    )
    rrpruntime::rrp_history_append_disposition(durable$port, disposition)
    appended <- appended + 1L
    if (!is.null(interrupt_after) && appended >= interrupt_after) {
      rrp_durable_abort(
        "injected_interruption", "Injected durable operation interruption."
      )
    }
  }
  history <- rrpruntime::rrp_history_read_scope(
    durable$port, scope$operation_run_id
  )
  rrp_new_operation_result(
    "rrp.execute-durable-bundle", "success",
    rrp_durable_progress_value(history), list()
  )
}

#' Execute one admitted bundle into durable terminal history
#' @param software_catalog A validated RRP software resource catalog.
#' @param project_root One explicit independent project directory.
#' @param analytical_time One explicit-offset RFC 3339 analytical instant.
#' @param operation_key One caller-owned idempotency key.
#' @return A common operation result containing bounded scope progress.
#' @export
rrp_execute_durable_bundle <- function(
  software_catalog, project_root, analytical_time, operation_key
) {
  tryCatch(
    rrp_durable_execute(
      software_catalog, project_root, analytical_time, operation_key
    ),
    rrp_project_error = function(condition) rrp_durable_failure_result(
      condition, "rrp.execute-durable-bundle"
    ),
    rrp_state_error = function(condition) rrp_durable_failure_result(
      condition, "rrp.execute-durable-bundle"
    ),
    rrp_producer_error = function(condition) rrp_durable_failure_result(
      condition, "rrp.execute-durable-bundle"
    ),
    rrp_canonical_error = function(condition) rrp_durable_failure_result(
      condition, "rrp.execute-durable-bundle"
    ),
    rrp_runtime_error = function(condition) rrp_durable_failure_result(
      condition, "rrp.execute-durable-bundle"
    ),
    rrp_history_error = function(condition) rrp_durable_failure_result(
      condition, "rrp.execute-durable-bundle"
    ),
    rrp_durable_error = function(condition) rrp_durable_failure_result(
      condition, "rrp.execute-durable-bundle"
    )
  )
}

rrp_history_platform_read <- function(
  operation_id, software_catalog, project_root, callback
) {
  tryCatch({
    durable <- rrp_durable_port(software_catalog, project_root)
    rrp_new_operation_result(operation_id, "success", callback(durable$port), list())
  }, rrp_project_error = function(condition) {
    rrp_durable_failure_result(condition, operation_id)
  }, rrp_state_error = function(condition) {
    rrp_durable_failure_result(condition, operation_id)
  }, rrp_history_error = function(condition) {
    rrp_durable_failure_result(condition, operation_id)
  })
}

#' Inspect raw durable scope history
#' @inheritParams rrp_execute_durable_bundle
#' @param operation_run_id One exact durable operation-run identity.
#' @return A common operation result containing detached raw scope history.
#' @export
rrp_inspect_scope_history <- function(
  software_catalog, project_root, operation_run_id
) rrp_history_platform_read(
  "rrp.inspect-scope-history", software_catalog, project_root,
  function(port) rrpruntime::rrp_history_read_scope(port, operation_run_id)
)

#' Inspect raw durable episode history
#' @inheritParams rrp_execute_durable_bundle
#' @param episode_id One exact episode identity.
#' @param target_id One exact target identity.
#' @param history_cutoff One explicit history-time cutoff.
#' @return A common operation result containing detached raw episode history.
#' @export
rrp_inspect_episode_history <- function(
  software_catalog, project_root, episode_id, target_id, history_cutoff
) rrp_history_platform_read(
  "rrp.inspect-episode-history", software_catalog, project_root,
  function(port) rrpruntime::rrp_history_read_episode(
    port, episode_id, target_id, history_cutoff
  )
)

#' Inspect effective current durable episode history
#' @inheritParams rrp_inspect_episode_history
#' @param analytical_cutoff One explicit analytical-time cutoff.
#' @return A common operation result containing one current disposition or NULL.
#' @export
rrp_inspect_current_history <- function(
  software_catalog, project_root, episode_id, target_id,
  analytical_cutoff, history_cutoff
) rrp_history_platform_read(
  "rrp.inspect-current-history", software_catalog, project_root,
  function(port) rrpruntime::rrp_history_read_current(
    port, episode_id, target_id, analytical_cutoff, history_cutoff
  )
)

rrp_retry_execute <- function(
  software_catalog, project_root, operation_run_id, analytical_run_id, retry_key
) {
  rrp_durable_validate_key(retry_key, "retry")
  durable <- rrp_durable_port(software_catalog, project_root)
  history <- rrpruntime::rrp_history_read_scope(durable$port, operation_run_id)
  matches <- Filter(function(value) {
    identical(value$analytical_run_id, analytical_run_id)
  }, history$dispositions)
  if (length(matches) != 1L || !matches[[1L]]$outcome %in% c(
    "provider_declared_failure", "detected_failure"
  )) rrp_durable_abort("invalid_retry_target", "The retry target is invalid.")
  parent <- matches[[1L]]
  children <- Filter(function(value) {
    identical(value$related_analytical_run_id, parent$analytical_run_id)
  }, history$dispositions)
  if (length(children)) {
    existing <- Filter(function(value) {
      identical(value$analytical_kind, "retry") &&
        identical(value$analytical_key, retry_key)
    }, children)
    if (length(existing) == 1L) {
      retry <- existing[[1L]]
      return(rrp_new_operation_result(
        "rrp.retry-episode", "success",
        list(
          operation_run_id = operation_run_id,
          analytical_run_id = retry$analytical_run_id,
          related_analytical_run_id = parent$analytical_run_id,
          outcome = retry$outcome,
          outcome_code = retry$outcome_code
        ), list()
      ))
    }
    rrp_durable_abort(
      "retry_target_already_used", "The retry target already has a child attempt."
    )
  }
  runtime_contracts <- rrp_runtime_contracts(
    durable$context$software_catalog,
    rrp_canonical_contracts(durable$context$software_catalog)
  )
  evidence <- rrp_durable_provider_evidence(
    durable$context, parent$state,
    rrp_provider_expected_context(
      runtime_contracts,
      rrp_canonical_contracts(durable$context$software_catalog)
    )
  )
  provider <- list(
    provider_id = durable$context$provider$component_id,
    provider_version = durable$context$provider$component_version,
    implementation_id = durable$context$provider$implementation_id,
    implementation_version = durable$context$provider$implementation_version,
    model_id = durable$context$provider$model_id,
    model_version = durable$context$provider$model_version
  )
  values <- c(list(
    analytical_kind = "retry",
    related_analytical_run_id = parent$analytical_run_id,
    analytical_key = retry_key,
    episode_id = parent$episode_id,
    patient_id = parent$patient_id,
    target_id = parent$target_id,
    target_version = parent$target_version,
    analytical_time = parent$analytical_time,
    outcome = evidence$outcome,
    outcome_code = evidence$outcome_code,
    eligibility_status = "eligible",
    state = parent$state,
    request = evidence$request
  ), provider, list(
    provider_status = evidence$provider_status,
    estimate = evidence$estimate,
    terminal_time = parent$analytical_time
  ))
  retry <- rrpruntime::rrp_new_episode_disposition(history$scope, values)
  rrpruntime::rrp_history_append_disposition(durable$port, retry)
  rrp_new_operation_result(
    "rrp.retry-episode", "success",
    list(
      operation_run_id = operation_run_id,
      analytical_run_id = retry$analytical_run_id,
      related_analytical_run_id = parent$analytical_run_id,
      outcome = retry$outcome,
      outcome_code = retry$outcome_code
    ), list()
  )
}

#' Explicitly retry one failed provider attempt
#' @inheritParams rrp_inspect_scope_history
#' @param analytical_run_id One failed provider analytical-run identity.
#' @param retry_key One caller-owned retry identity key.
#' @return A common operation result with bounded retry evidence.
#' @export
rrp_retry_episode <- function(
  software_catalog, project_root, operation_run_id, analytical_run_id, retry_key
) tryCatch(
  rrp_retry_execute(
    software_catalog, project_root, operation_run_id, analytical_run_id, retry_key
  ),
  rrp_project_error = function(condition) rrp_durable_failure_result(
    condition, "rrp.retry-episode"
  ),
  rrp_state_error = function(condition) rrp_durable_failure_result(
    condition, "rrp.retry-episode"
  ),
  rrp_runtime_error = function(condition) rrp_durable_failure_result(
    condition, "rrp.retry-episode"
  ),
  rrp_history_error = function(condition) rrp_durable_failure_result(
    condition, "rrp.retry-episode"
  ),
  rrp_durable_error = function(condition) rrp_durable_failure_result(
    condition, "rrp.retry-episode"
  )
)

rrp_history_action_result <- function(operation_id, expression) tryCatch({
  value <- force(expression)
  rrp_new_operation_result(operation_id, "success", value, list())
}, rrp_project_error = function(condition) {
  rrp_durable_failure_result(condition, operation_id)
}, rrp_state_error = function(condition) {
  rrp_durable_failure_result(condition, operation_id)
}, rrp_history_error = function(condition) {
  rrp_durable_failure_result(condition, operation_id)
}, rrp_durable_error = function(condition) {
  rrp_durable_failure_result(condition, operation_id)
})

#' Append one supported durable-history invalidation
#' @inheritParams rrp_execute_durable_bundle
#' @param target_kind Either `analytical_run` or `operational_scope`.
#' @param target_operation_run_id The target's operation-run identity.
#' @param target_id The target analytical-run or operation-run identity.
#' @param effective_time One explicit history effective time.
#' @param reason_code One bounded governed reason code.
#' @param actor_category Either `maintainer` or `operator`.
#' @return A common operation result containing the appended action.
#' @export
rrp_invalidate_history <- function(
  software_catalog, project_root, target_kind, target_operation_run_id,
  target_id, effective_time, reason_code, actor_category
) rrp_history_action_result("rrp.invalidate-history", {
  durable <- rrp_durable_port(software_catalog, project_root)
  action <- rrpruntime::rrp_new_history_action(list(
    target_kind = target_kind,
    target_id = target_id,
    target_operation_run_id = target_operation_run_id,
    action_type = "invalidate",
    effective_time = effective_time,
    reason_code = reason_code,
    replacement_operation_run_id = NULL,
    replacement_analytical_run_id = NULL,
    actor_category = actor_category
  ))
  rrpruntime::rrp_history_append_invalidation(durable$port, action)
  action
})

#' Atomically append one supported durable-history restatement
#' @inheritParams rrp_invalidate_history
#' @param replacement A validated replacement disposition or operational scope.
#' @return A common operation result containing replacement and action evidence.
#' @export
rrp_restate_history <- function(
  software_catalog, project_root, target_kind, target_operation_run_id,
  target_id, replacement, effective_time, reason_code, actor_category
) rrp_history_action_result("rrp.restate-history", {
  durable <- rrp_durable_port(software_catalog, project_root)
  scope <- inherits(replacement, "rrp_operational_scope")
  disposition <- inherits(replacement, "rrp_episode_disposition")
  if ((identical(target_kind, "operational_scope") && !scope) ||
      (identical(target_kind, "analytical_run") && !disposition)) {
    rrp_durable_abort(
      "invalid_restatement", "The history restatement is invalid."
    )
  }
  action <- rrpruntime::rrp_new_history_action(list(
    target_kind = target_kind,
    target_id = target_id,
    target_operation_run_id = target_operation_run_id,
    action_type = "restate",
    effective_time = effective_time,
    reason_code = reason_code,
    replacement_operation_run_id = replacement$operation_run_id,
    replacement_analytical_run_id = if (scope) {
      NULL
    } else {
      replacement$analytical_run_id
    },
    actor_category = actor_category
  ))
  rrpruntime::rrp_history_append_restatement(durable$port, replacement, action)
})
