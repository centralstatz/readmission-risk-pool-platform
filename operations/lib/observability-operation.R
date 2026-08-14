# Base-R operational diagnostics. This layer never owns analytical results.

rrp_operation_context_specification <- function() list(
  specification_id = "platform.operation-run-context",
  specification_version = "0.1.0"
)

rrp_operational_event_specification <- function() list(
  specification_id = "platform.operational-diagnostic-event",
  specification_version = "0.1.0"
)

rrp_observability_timestamp <- function(time = Sys.time()) {
  format(as.POSIXct(time, tz = "UTC"), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

rrp_observability_is_timestamp <- function(value) {
  valid <- is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl(
      "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(Z|[+-][0-9]{2}:[0-9]{2})$",
      value
    ) && !is.na(as.POSIXct(value, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"))
  if (!valid || endsWith(value, "Z")) return(valid)
  as.integer(substr(value, 21L, 22L)) <= 23L &&
    as.integer(substr(value, 24L, 25L)) <= 59L
}

rrp_observability_timestamp_number <- function(value) {
  if (!rrp_observability_is_timestamp(value)) stop(
    "Diagnostic time must include an RFC 3339 offset.", call. = FALSE
  )
  local_time <- as.numeric(as.POSIXct(
    substr(value, 1L, 19L), format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"
  ))
  if (endsWith(value, "Z")) return(local_time)
  sign <- if (substr(value, 20L, 20L) == "+") 1 else -1
  hours <- as.integer(substr(value, 21L, 22L))
  minutes <- as.integer(substr(value, 24L, 25L))
  local_time - sign * (hours * 3600 + minutes * 60)
}

rrp_observability_scalar <- function(value) {
  (is.character(value) || is.logical(value) || is.numeric(value) ||
    is.integer(value)) && length(value) == 1L && !is.na(value)
}

rrp_observability_safe_keys <- function() c(
  "profile", "scale", "status", "run_status", "validation_status",
  "data_classification", "materialized", "idempotent", "replaced",
  "as_of_time", "source_cutoff_time", "provider_id", "provider_version",
  "adapter_id", "adapter_version", "failure_category", "warning_count"
)

rrp_observability_safe_count_keys <- function() c(
  "check_count", "warning_count", "failure_count", "patient_count",
  "encounter_count", "episode_count", "source_table_count", "source_row_count",
  "source_run_count",
  "eligible_count", "ineligible_count", "request_count", "successful_count",
  "persisted_count", "product_count", "row_count", "artifact_member_count"
)

rrp_observability_unsafe_pattern <- function() paste0(
  "patient|encounter|episode|zip|location|address|clinical|feature|risk|score|",
  "probability|credential|password|secret|token|authorization|connection|",
  "sql|query|environment|payload|raw|record|path|directory"
)

rrp_validate_safe_diagnostic_mapping <- function(value, label = "details") {
  if (!is.list(value) || (length(value) > 0L &&
      (is.null(names(value)) || any(!nzchar(names(value))) || anyDuplicated(names(value))))) {
    stop(label, " must be a named mapping.", call. = FALSE)
  }
  if (length(value) == 0L) return(invisible(TRUE))
  keys <- names(value)
  aggregate_keys <- keys %in% rrp_observability_safe_count_keys()
  if (any(!aggregate_keys & grepl(
    rrp_observability_unsafe_pattern(), keys, ignore.case = TRUE
  ))) {
    stop(label, " contains a prohibited diagnostic key.", call. = FALSE)
  }
  allowed <- keys %in% rrp_observability_safe_keys() | aggregate_keys
  if (!all(allowed)) stop(
    label, " contains an unrecognized key: ", paste(keys[!allowed], collapse = ", "),
    call. = FALSE
  )
  if (!all(vapply(value, rrp_observability_scalar, logical(1)))) stop(
    label, " values must be shallow non-missing scalars.", call. = FALSE
  )
  if (any(aggregate_keys) && !all(vapply(value[aggregate_keys], function(item) {
    is.numeric(item) && is.finite(item) && item >= 0 && item == round(item)
  }, logical(1)))) stop(
    label, " aggregate counts must be finite non-negative whole numbers.",
    call. = FALSE
  )
  character_values <- value[vapply(value, is.character, logical(1))]
  for (item in character_values) rrp_validate_diagnostic_text(
    item, paste(label, "value")
  )
  invisible(TRUE)
}

rrp_observability_related_identity_keys <- function() c(
  "analytical_runtime_run_id", "product_set_id", "product_build_id",
  "artifact_instance_id", "artifact_build_id", "deployment_realization_id",
  "materialization_id", "provider_id", "provider_version", "producer_id",
  "producer_version", "implementation_id", "implementation_version",
  "mapping_id", "mapping_version", "producer_execution_id"
)

rrp_validate_related_identities <- function(value) {
  if (!is.list(value) || (length(value) > 0L &&
      (is.null(names(value)) || any(!nzchar(names(value))) || anyDuplicated(names(value))))) {
    stop("related_identities must be a named mapping.", call. = FALSE)
  }
  if (length(value) == 0L) return(invisible(TRUE))
  if (!all(names(value) %in% rrp_observability_related_identity_keys())) stop(
    "related_identities contains an unsupported identity type.", call. = FALSE
  )
  if (!all(vapply(value, function(item) {
    is.character(item) && length(item) == 1L && !is.na(item) &&
      grepl("^[A-Za-z0-9][A-Za-z0-9._:@|+-]*$", item) && nchar(item) <= 2048L
  }, logical(1)))) stop(
    "Related identities must be bounded safe identity strings.", call. = FALSE
  )
  invisible(TRUE)
}

rrp_validate_diagnostic_text <- function(value, label) {
  safe <- is.character(value) && length(value) == 1L && !is.na(value) &&
    nzchar(value) && nchar(value, type = "bytes") <= 500L &&
    !grepl("[\r\n]", value) &&
    !grepl("(password|secret|token|authorization|connection.string|patient[_ -]?id)\\s*[:=]",
      value, ignore.case = TRUE
    ) && !grepl(paste("BEGIN", "[A-Z ]*PRIVATE", "KEY"), value)
  if (!safe) stop(label, " is not safe diagnostic text.", call. = FALSE)
  invisible(TRUE)
}

rrp_new_operation_context <- function(
  operation_id,
  operation_run_id = NULL,
  attempt = 1L,
  started_at = rrp_observability_timestamp(),
  safe_context = list()
) {
  if (!is.character(operation_id) || length(operation_id) != 1L ||
      !grepl("^(platform|reference)[.][a-z0-9-]+$", operation_id)) stop(
    "Operation ID must be a stable platform operation identity.", call. = FALSE
  )
  if (!is.numeric(attempt) || length(attempt) != 1L || is.na(attempt) ||
      attempt < 1 || attempt != as.integer(attempt)) stop(
    "Operation attempt must be one positive integer.", call. = FALSE
  )
  if (!rrp_observability_is_timestamp(started_at)) stop(
    "Operation start time must include an RFC 3339 offset.", call. = FALSE
  )
  rrp_validate_safe_diagnostic_mapping(safe_context, "safe_context")
  if (is.null(operation_run_id)) {
    seed <- paste(operation_id, started_at, attempt, Sys.getpid(), tempfile(), sep = "|")
    input <- tempfile("rrp-operation-id-")
    on.exit(unlink(input, force = TRUE), add = TRUE)
    writeLines(seed, input, useBytes = TRUE)
    operation_run_id <- paste0("operation-run::", unname(tools::md5sum(input)))
  }
  if (!is.character(operation_run_id) || length(operation_run_id) != 1L ||
      !grepl("^operation-run::[a-zA-Z0-9._:-]+$", operation_run_id) ||
      nchar(operation_run_id) > 128L) stop(
    "Operation run ID is invalid.", call. = FALSE
  )
  structure(list(
    context_specification = rrp_operation_context_specification(),
    operation_run_id = operation_run_id,
    operation_id = operation_id,
    attempt = as.integer(attempt),
    started_at = started_at,
    component_reference = list(
      component_id = "platform.operations",
      component_version = "0.1.0"
    ),
    safe_context = safe_context
  ), class = "rrp_operation_context")
}

rrp_observability_components <- function() c(
  "operations", "environment", "source_implementation", "canonical_mapping",
  "canonical_validation", "canonical_boundary", "runtime",
  "provider_execution", "persistence",
  "product_build", "product_materialization", "application_artifact",
  "connect_realization", "app_validation"
)

rrp_observability_stages <- function() c(
  "operation", "preflight", "source_generation", "source_validation",
  "canonical_mapping", "canonical_validation", "producer_resolution",
  "producer_execution", "canonical_admission", "runtime_preparation",
  "provider_execution", "persistence", "product_build",
  "product_materialization", "artifact_build", "artifact_validation",
  "connect_realization", "connect_validation", "app_validation"
)

rrp_validate_operational_event <- function(event, context = NULL) {
  required <- c(
    "event_specification", "event_id", "operation_run_id", "emitted_at",
    "component", "stage", "severity", "lifecycle", "code", "message",
    "related_identities", "details"
  )
  if (!is.list(event) || !all(required %in% names(event))) stop(
    "Operational event is missing required fields.", call. = FALSE
  )
  if (!identical(event$event_specification, rrp_operational_event_specification())) stop(
    "Operational event specification is unsupported.", call. = FALSE
  )
  for (field in c("event_id", "operation_run_id", "code")) {
    if (!is.character(event[[field]]) || length(event[[field]]) != 1L ||
        is.na(event[[field]]) || !nzchar(event[[field]])) stop(
      "Operational event ", field, " is invalid.", call. = FALSE
    )
  }
  if (!is.null(context) && !identical(event$operation_run_id, context$operation_run_id)) {
    stop("Operational event correlation does not match its context.", call. = FALSE)
  }
  if (!startsWith(
    event$event_id, paste0(event$operation_run_id, "::event::")
  )) stop("Operational event ID does not match its operation correlation.", call. = FALSE)
  if (!rrp_observability_is_timestamp(event$emitted_at)) stop(
    "Operational event time must include an RFC 3339 offset.", call. = FALSE
  )
  if (!event$component %in% rrp_observability_components()) stop(
    "Operational event component is unsupported.", call. = FALSE
  )
  if (!event$stage %in% rrp_observability_stages()) stop(
    "Operational event stage is unsupported.", call. = FALSE
  )
  if (!event$severity %in% c("debug", "info", "warning", "error")) stop(
    "Operational event severity is unsupported.", call. = FALSE
  )
  lifecycles <- c(
    "operation_started", "stage_started", "stage_completed",
    "operation_completed", "operation_completed_with_warnings", "operation_failed"
  )
  if (!event$lifecycle %in% lifecycles) stop(
    "Operational event lifecycle is unsupported.", call. = FALSE
  )
  if (identical(event$lifecycle, "operation_failed") &&
      !identical(event$severity, "error")) stop(
    "Failed operation events must have error severity.", call. = FALSE
  )
  rrp_validate_diagnostic_text(event$message, "Operational event message")
  if (!grepl("^[a-z][a-z0-9_.-]+$", event$code)) stop(
    "Operational event code is invalid.", call. = FALSE
  )
  rrp_validate_related_identities(event$related_identities)
  rrp_validate_safe_diagnostic_mapping(event$details)
  if (!is.null(event$duration_ms) && (!rrp_observability_scalar(event$duration_ms) ||
      event$duration_ms < 0)) stop("Event duration must be non-negative.", call. = FALSE)
  if (!is.null(event$error_classification) &&
      (!is.character(event$error_classification) ||
        length(event$error_classification) != 1L ||
        !grepl("^[a-z][a-z0-9_]+$", event$error_classification))) stop(
    "Error classification must be one controlled identifier.", call. = FALSE
  )
  if (!is.null(event$recovery_hint)) rrp_validate_diagnostic_text(
    event$recovery_hint, "Recovery hint"
  )
  invisible(TRUE)
}

rrp_console_event_sink <- function(stream = stderr(), verbosity = "normal") {
  if (!verbosity %in% c("quiet", "normal", "debug")) stop(
    "Verbosity must be quiet, normal, or debug.", call. = FALSE
  )
  threshold <- c(debug = 1L, info = 2L, warning = 3L, error = 4L)
  minimum <- c(debug = 1L, normal = 2L, quiet = 3L)[[verbosity]]
  function(event) {
    if (threshold[[event$severity]] < minimum) return(invisible(event))
    identity <- function(value) {
      if (nchar(value) <= 72L) value else paste0(substr(value, 1L, 69L), "...")
    }
    related <- if (length(event$related_identities) == 0L) "" else paste0(
      " ", paste(paste0(
        names(event$related_identities), "=",
        vapply(event$related_identities, identity, character(1))
      ), collapse = " ")
    )
    recovery <- if (is.null(event$recovery_hint)) "" else paste0(
      " Next: ", event$recovery_hint
    )
    duration <- if (is.null(event$duration_ms)) "" else paste0(
      " duration_ms=", event$duration_ms
    )
    classification <- if (is.null(event$error_classification)) "" else paste0(
      " error_classification=", event$error_classification
    )
    writeLines(paste0(
      "[", event$emitted_at, "] ", toupper(event$severity), " ",
      event$operation_run_id, " ", event$stage, "/", event$lifecycle,
      " ", event$code, " - ", event$message, related, duration,
      classification, recovery
    ), stream)
    invisible(event)
  }
}

rrp_new_event_emitter <- function(context, sink = function(event) invisible(event),
                                  clock = Sys.time) {
  if (!inherits(context, "rrp_operation_context")) stop(
    "Emitter requires a validated operation context.", call. = FALSE
  )
  if (!is.function(sink) || !is.function(clock)) stop(
    "Emitter sink and clock must be functions.", call. = FALSE
  )
  state <- new.env(parent = emptyenv())
  state$context <- context
  state$sink <- sink
  state$clock <- clock
  state$sequence <- 0L
  state$events <- list()
  state$terminal <- FALSE
  state$operation_started <- FALSE
  state$active_stages <- character()
  state$sink_failure_count <- 0L
  class(state) <- "rrp_event_emitter"
  state
}

rrp_emit_operational_event <- function(
  emitter, component, stage, severity, lifecycle, code, message,
  related_identities = list(), details = list(), duration_ms = NULL,
  error_classification = NULL, recovery_hint = NULL
) {
  if (is.null(emitter)) return(invisible(NULL))
  if (!inherits(emitter, "rrp_event_emitter")) stop("Invalid event emitter.", call. = FALSE)
  if (isTRUE(emitter$terminal)) stop("Cannot emit after a terminal event.", call. = FALSE)
  if (identical(lifecycle, "operation_started")) {
    if (isTRUE(emitter$operation_started) || emitter$sequence != 0L) stop(
      "Operation start must be the first and only start event.", call. = FALSE
    )
  } else if (!isTRUE(emitter$operation_started)) stop(
    "Operation must start before stage or terminal events.", call. = FALSE
  )
  if (identical(lifecycle, "stage_started") && stage %in% emitter$active_stages) stop(
    "Diagnostic stage is already active.", call. = FALSE
  )
  if (identical(lifecycle, "stage_completed") && !stage %in% emitter$active_stages) stop(
    "Diagnostic stage must start before it completes.", call. = FALSE
  )
  if (lifecycle %in% c("operation_completed", "operation_completed_with_warnings") &&
      length(emitter$active_stages) > 0L) stop(
    "Successful terminal event cannot leave active stages.", call. = FALSE
  )
  next_sequence <- emitter$sequence + 1L
  event <- list(
    event_specification = rrp_operational_event_specification(),
    event_id = paste0(
      emitter$context$operation_run_id, "::event::",
      sprintf("%04d", next_sequence)
    ),
    operation_run_id = emitter$context$operation_run_id,
    emitted_at = rrp_observability_timestamp(emitter$clock()),
    component = component,
    stage = stage,
    severity = severity,
    lifecycle = lifecycle,
    code = code,
    message = message,
    related_identities = related_identities,
    details = details
  )
  if (!is.null(duration_ms)) event$duration_ms <- duration_ms
  if (!is.null(error_classification)) {
    event$error_classification <- error_classification
  }
  if (!is.null(recovery_hint)) event$recovery_hint <- recovery_hint
  rrp_validate_operational_event(event, emitter$context)
  emitter$sequence <- next_sequence
  emitter$events[[length(emitter$events) + 1L]] <- event
  if (identical(lifecycle, "operation_started")) emitter$operation_started <- TRUE
  if (identical(lifecycle, "stage_started")) {
    emitter$active_stages <- c(emitter$active_stages, stage)
  }
  if (identical(lifecycle, "stage_completed")) {
    emitter$active_stages <- setdiff(emitter$active_stages, stage)
  }
  if (lifecycle %in% c(
    "operation_completed", "operation_completed_with_warnings", "operation_failed"
  )) emitter$terminal <- TRUE
  tryCatch(
    emitter$sink(event),
    error = function(condition) {
      # Diagnostic routing must not change the operation's domain result.
      emitter$sink_failure_count <- emitter$sink_failure_count + 1L
      invisible(NULL)
    }
  )
  invisible(event)
}

rrp_emitted_events <- function(emitter) {
  if (!inherits(emitter, "rrp_event_emitter")) stop("Invalid event emitter.", call. = FALSE)
  emitter$events
}

rrp_observability_sink_failure_count <- function(emitter) {
  if (!inherits(emitter, "rrp_event_emitter")) stop("Invalid event emitter.", call. = FALSE)
  emitter$sink_failure_count
}

rrp_observability_elapsed_ms <- function(emitter) {
  started <- rrp_observability_timestamp_number(emitter$context$started_at)
  current <- as.numeric(as.POSIXct(emitter$clock(), tz = "UTC"))
  as.numeric(max(0, round((current - started) * 1000)))
}

rrp_start_operation_observability <- function(operation_id, safe_context = list(),
                                               sink = rrp_console_event_sink()) {
  context <- rrp_new_operation_context(operation_id, safe_context = safe_context)
  emitter <- rrp_new_event_emitter(context, sink)
  rrp_emit_operational_event(
    emitter, "operations", "operation", "info", "operation_started",
    "operation.started", "Operation started.", details = safe_context
  )
  emitter
}

rrp_complete_operation_observability <- function(emitter, warnings = 0L,
                                                  related_identities = list(),
                                                  details = list()) {
  lifecycle <- if (warnings > 0L) {
    "operation_completed_with_warnings"
  } else "operation_completed"
  severity <- if (warnings > 0L) "warning" else "info"
  details$warning_count <- as.integer(warnings)
  rrp_emit_operational_event(
    emitter, "operations", "operation", severity, lifecycle,
    if (warnings > 0L) "operation.completed_with_warnings" else "operation.completed",
    if (warnings > 0L) "Operation completed with warnings." else "Operation completed.",
    related_identities = related_identities, details = details,
    duration_ms = rrp_observability_elapsed_ms(emitter)
  )
}

rrp_fail_operation_observability <- function(
  emitter, code, message, recovery_hint,
  error_classification = "operation_failure"
) {
  if (is.null(emitter) || isTRUE(emitter$terminal)) return(invisible(NULL))
  rrp_emit_operational_event(
    emitter, "operations", "operation", "error", "operation_failed",
    code, message, duration_ms = rrp_observability_elapsed_ms(emitter),
    error_classification = error_classification,
    recovery_hint = recovery_hint
  )
}
