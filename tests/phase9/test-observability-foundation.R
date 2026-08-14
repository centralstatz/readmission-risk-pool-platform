phase9_test_cases <- function(repository_root) list(
  "context has a distinct stable contract and explicit timestamp" = function() {
    context <- rrp_new_operation_context(
      "platform.doctor", "operation-run::test-001", started_at = "2026-08-13T12:00:00Z",
      safe_context = list(profile = "reference", episode_count = 3L)
    )
    phase0_assert_true(inherits(context, "rrp_operation_context"))
    phase0_assert_true(identical(
      context$context_specification$specification_id,
      "platform.operation-run-context"
    ))
    phase0_assert_false("runtime_run_id" %in% names(context))
  },

  "event lifecycle is ordered and correlated" = function() {
    context <- rrp_new_operation_context(
      "platform.doctor", "operation-run::test-002", started_at = "2026-08-13T12:00:00Z"
    )
    emitter <- rrp_new_event_emitter(
      context, clock = function() as.POSIXct("2026-08-13 12:00:01", tz = "UTC")
    )
    rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started."
    )
    rrp_emit_operational_event(
      emitter, "environment", "preflight", "info", "stage_started",
      "doctor.started", "Readiness stage started."
    )
    rrp_emit_operational_event(
      emitter, "environment", "preflight", "info", "stage_completed",
      "doctor.completed", "Readiness stage completed.",
      details = list(check_count = 4L)
    )
    rrp_complete_operation_observability(emitter)
    events <- rrp_emitted_events(emitter)
    phase0_assert_true(length(events) == 4L)
    phase0_assert_true(length(unique(vapply(
      events, `[[`, character(1), "event_id"
    ))) == 4L)
    phase0_assert_true(all(vapply(
      events, `[[`, character(1), "operation_run_id"
    ) == context$operation_run_id))
    phase0_assert_true(identical(events[[4L]]$lifecycle, "operation_completed"))
    phase0_assert_true(identical(events[[4L]]$duration_ms, 1000))
    phase0_assert_true(identical(
      rrp_observability_timestamp_number("2026-08-13T07:00:00-05:00"),
      rrp_observability_timestamp_number("2026-08-13T12:00:00Z")
    ))
  },

  "unsafe diagnostic keys and nested payloads are rejected" = function() {
    phase0_assert_error(
      rrp_new_operation_context(
        "platform.doctor", "operation-run::unsafe",
        safe_context = list(patient_id = "123")
      ),
      "prohibited diagnostic key"
    )
    phase0_assert_error(
      rrp_new_operation_context(
        "platform.doctor", "operation-run::unsafe-value",
        safe_context = list(profile = "password=not-safe")
      ),
      "not safe diagnostic text"
    )
    phase0_assert_error(
      rrp_new_operation_context(
        "platform.doctor", "operation-run::negative-count",
        safe_context = list(patient_count = -1L)
      ),
      "finite non-negative whole numbers"
    )
    phase0_assert_error(
      rrp_new_operation_context(
        "platform.doctor", "operation-run::nested",
        safe_context = list(profile = list(name = "reference"))
      ),
      "shallow non-missing scalars"
    )
    phase0_assert_error(
      rrp_new_operation_context(
        "platform.doctor", "operation-run::data-frame",
        safe_context = list(profile = data.frame(value = "reference"))
      ),
      "shallow non-missing scalars"
    )
    phase0_assert_error(
      rrp_new_operation_context(
        "platform.doctor", "operation-run::raw",
        safe_context = list(payload_count = 4L)
      ),
      "prohibited diagnostic key"
    )
  },

  "invalid severity and missing correlation are rejected" = function() {
    context <- rrp_new_operation_context(
      "platform.doctor", "operation-run::validation",
      started_at = "2026-08-13T12:00:00Z"
    )
    emitter <- rrp_new_event_emitter(context)
    event <- rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started."
    )
    invalid_severity <- event
    invalid_severity$severity <- "critical"
    phase0_assert_error(
      rrp_validate_operational_event(invalid_severity, context),
      "severity is unsupported"
    )
    missing_correlation <- event
    missing_correlation$operation_run_id <- "operation-run::different"
    phase0_assert_error(
      rrp_validate_operational_event(missing_correlation, context),
      "correlation does not match"
    )
    invalid_event_id <- event
    invalid_event_id$event_id <- "unrelated::event::0001"
    phase0_assert_error(
      rrp_validate_operational_event(invalid_event_id, context),
      "event ID does not match"
    )
    phase0_assert_false(rrp_observability_is_timestamp(
      "2026-08-13T12:00:00+25:99"
    ))
    invalid_classification <- event
    invalid_classification$error_classification <- "raw exception"
    phase0_assert_error(
      rrp_validate_operational_event(invalid_classification, context),
      "controlled identifier"
    )
  },

  "aggregate counts are permitted without patient identifiers" = function() {
    context <- rrp_new_operation_context(
      "reference.run-platform", "operation-run::aggregate",
      safe_context = list(
        patient_count = 10L, episode_count = 12L, source_run_count = 1L
      )
    )
    phase0_assert_true(context$safe_context$patient_count == 10L)
    phase0_assert_error(
      rrp_new_operation_context(
        "reference.run-platform", "operation-run::identifier-count",
        safe_context = list(patient_id_count = 10L)
      ),
      "prohibited diagnostic key"
    )
  },

  "unsafe free text is rejected" = function() {
    context <- rrp_new_operation_context(
      "platform.doctor", "operation-run::text", started_at = "2026-08-13T12:00:00Z"
    )
    emitter <- rrp_new_event_emitter(context)
    rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started."
    )
    phase0_assert_error(rrp_emit_operational_event(
      emitter, "operations", "operation", "error", "operation_failed",
      "operation.failed", "password=not-safe"
    ), "not safe diagnostic text")
  },

  "patient-level related identities are unsupported" = function() {
    context <- rrp_new_operation_context(
      "platform.doctor", "operation-run::related", started_at = "2026-08-13T12:00:00Z"
    )
    emitter <- rrp_new_event_emitter(context)
    phase0_assert_error(rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started.",
      related_identities = list(episode_id = "episode-1")
    ), "unsupported identity type")
    phase0_assert_error(rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started.",
      related_identities = list(product_set_id = "unsafe/path")
    ), "bounded safe identity strings")
  },

  "console rendering respects quiet and preserves errors" = function() {
    output <- character()
    connection <- textConnection("output", "w", local = TRUE)
    on.exit(try(close(connection), silent = TRUE), add = TRUE)
    context <- rrp_new_operation_context(
      "platform.doctor", "operation-run::console", started_at = "2026-08-13T12:00:00Z"
    )
    emitter <- rrp_new_event_emitter(
      context, rrp_console_event_sink(connection, "quiet"),
      clock = function() as.POSIXct("2026-08-13 12:00:01", tz = "UTC")
    )
    rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started."
    )
    rrp_fail_operation_observability(
      emitter, "operation.failed", "Operation failed safely.", "Run doctor."
    )
    close(connection)
    phase0_assert_true(length(output) == 1L)
    phase0_assert_true(grepl("ERROR", output[[1L]], fixed = TRUE))
    phase0_assert_true(grepl(
      "error_classification=operation_failure", output[[1L]], fixed = TRUE
    ))
    phase0_assert_true(grepl("Next: Run doctor.", output[[1L]], fixed = TRUE))
  },

  "debug rendering remains an explicit safe adapter mode" = function() {
    output <- character()
    connection <- textConnection("output", "w", local = TRUE)
    on.exit(try(close(connection), silent = TRUE), add = TRUE)
    emitter <- rrp_new_event_emitter(
      rrp_new_operation_context(
        "platform.doctor", "operation-run::debug",
        started_at = "2026-08-13T12:00:00Z"
      ),
      rrp_console_event_sink(connection, "debug")
    )
    rrp_emit_operational_event(
      emitter, "operations", "operation", "debug", "operation_started",
      "operation.debug_started", "Safe debug operation started."
    )
    close(connection)
    phase0_assert_true(length(output) == 1L)
    phase0_assert_true(grepl("DEBUG", output[[1L]], fixed = TRUE))
  },

  "event storage is independent of console visibility" = function() {
    output <- character()
    connection <- textConnection("output", "w", local = TRUE)
    on.exit(try(close(connection), silent = TRUE), add = TRUE)
    context <- rrp_new_operation_context(
      "platform.doctor", "operation-run::stored", started_at = "2026-08-13T12:00:00Z"
    )
    emitter <- rrp_new_event_emitter(
      context, rrp_console_event_sink(connection, "quiet")
    )
    rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started."
    )
    phase0_assert_true(length(rrp_emitted_events(emitter)) == 1L)
    phase0_assert_true(length(output) == 0L)
  },

  "diagnostic identity generation does not consume the analytical RNG" = function() {
    set.seed(904L)
    expected <- stats::runif(1L)
    set.seed(904L)
    invisible(rrp_new_operation_context("platform.doctor"))
    observed <- stats::runif(1L)
    phase0_assert_true(identical(observed, expected))
  },

  "terminal lifecycle prevents later emission" = function() {
    emitter <- rrp_new_event_emitter(rrp_new_operation_context(
      "platform.doctor", "operation-run::terminal", started_at = "2026-08-13T12:00:00Z"
    ))
    rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started."
    )
    rrp_complete_operation_observability(emitter)
    phase0_assert_error(rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started."
    ), "Cannot emit after a terminal event")
  },

  "lifecycle rejects completion before start and active-stage success" = function() {
    emitter <- rrp_new_event_emitter(rrp_new_operation_context(
      "platform.doctor", "operation-run::ordering", started_at = "2026-08-13T12:00:00Z"
    ))
    phase0_assert_error(
      rrp_complete_operation_observability(emitter),
      "Operation must start"
    )
    rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started."
    )
    rrp_emit_operational_event(
      emitter, "environment", "preflight", "info", "stage_started",
      "preflight.started", "Preflight started."
    )
    phase0_assert_error(
      rrp_complete_operation_observability(emitter),
      "cannot leave active stages"
    )
  },

  "sink failures do not alter structured lifecycle" = function() {
    emitter <- rrp_new_event_emitter(
      rrp_new_operation_context(
        "platform.doctor", "operation-run::sink-failure",
        started_at = "2026-08-13T12:00:00Z"
      ),
      sink = function(event) stop("sink unavailable")
    )
    event <- rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started."
    )
    phase0_assert_true(identical(event$lifecycle, "operation_started"))
    phase0_assert_true(length(rrp_emitted_events(emitter)) == 1L)
    phase0_assert_true(rrp_observability_sink_failure_count(emitter) == 1L)
  },

  "contracts parse and declare the implemented identities" = function() {
    if (!requireNamespace("yaml", quietly = TRUE)) stop("yaml package required")
    context <- yaml::read_yaml(file.path(
      repository_root, "contracts", "observability", "operation-run-context.yml"
    ))
    event <- yaml::read_yaml(file.path(
      repository_root, "contracts", "observability", "operational-event.yml"
    ))
    phase0_assert_true(identical(
      context$specification_id, rrp_operation_context_specification()$specification_id
    ))
    phase0_assert_true(identical(
      event$specification_id, rrp_operational_event_specification()$specification_id
    ))
    phase0_assert_true("operation_failed" %in% event$lifecycle_events)
    phase0_assert_true(rrp_conforms(rrp_validate_specification_envelope(context)))
    phase0_assert_true(rrp_conforms(rrp_validate_specification_envelope(event)))
  },

  "instrumented operations contain no persistent diagnostic sink" = function() {
    source_text <- paste(readLines(file.path(
      repository_root, "operations", "lib", "observability-operation.R"
    ), warn = FALSE), collapse = "\n")
    phase0_assert_false(grepl("write.csv", source_text, fixed = TRUE))
    phase0_assert_false(grepl("writeLines(event", source_text, fixed = TRUE))
    phase0_assert_false(grepl("DBI::", source_text, fixed = TRUE))
  }
)
