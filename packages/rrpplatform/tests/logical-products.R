library(rrpplatform)

product_internal <- function(name, package = "rrpplatform") {
  get(name, envir = asNamespace(package), inherits = FALSE)
}

product_expect <- function(callback, code) {
  condition <- tryCatch({ callback(); NULL }, error = identity)
  stopifnot(
    inherits(condition, "rrp_product_error"), identical(condition$code, code),
    identical(condition$call, NULL), nchar(condition$message, type = "bytes") <= 160L
  )
  invisible(condition)
}

product_scope_values <- function(key, time, created = time,
                                 state_id = "rrp.state.product-test") list(
  operation_key = key,
  state_id = state_id,
  product_id = "readmission-risk-pool-platform",
  development_version = "1.0.0-dev",
  rrp_api_version = "0.3.0",
  project_api_id = "rrp.project-api",
  project_api_version = "0.3.0",
  project_id = "product-test-hospital",
  project_version = "1.0.0",
  bundle_contract_id = "rrp.canonical-bundle",
  bundle_contract_version = "0.1.0",
  bundle_instance_id = paste0("product.bundle.", key),
  canonical_profile_id = "rrp.canonical-profile.readmission",
  canonical_profile_version = "0.1.0",
  producer_id = "product-test.producer",
  producer_version = "1.0.0",
  producer_implementation_id = "product-test.producer-implementation",
  producer_implementation_version = "1.0.0",
  mapping_id = "product-test.mapping",
  mapping_version = "1.0.0",
  target_id = "rrp.risk-target.readmission-remaining-30-day",
  target_version = "0.1.0",
  analytical_time = time,
  created_at = created
)

product_state <- function(scope, episode_id) {
  time_number <- function(value) as.numeric(as.POSIXct(
    value, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC"
  ))
  values <- list(
    bundle_contract_id = scope$bundle_contract_id,
    bundle_contract_version = scope$bundle_contract_version,
    bundle_instance_id = scope$bundle_instance_id,
    project_id = scope$project_id,
    project_version = scope$project_version,
    canonical_profile_id = scope$canonical_profile_id,
    canonical_profile_version = scope$canonical_profile_version,
    episode_id = episode_id,
    as_of_time = scope$analytical_time,
    discharge_time = "2026-01-01T00:00:00Z",
    target_window_end = "2026-01-31T00:00:00Z",
    target_id = scope$target_id,
    target_version = scope$target_version,
    state_contract_id = "rrp.episode-state",
    state_contract_version = "0.1.0"
  )
  structure(list(
    state_contract_id = values$state_contract_id,
    state_contract_version = values$state_contract_version,
    state_id = product_internal("rrp_runtime_state_identity", "rrpruntime")(
      unname(values)
    ),
    target_id = values$target_id,
    target_version = values$target_version,
    bundle_contract_id = values$bundle_contract_id,
    bundle_contract_version = values$bundle_contract_version,
    bundle_instance_id = values$bundle_instance_id,
    project_id = values$project_id,
    project_version = values$project_version,
    canonical_profile_id = values$canonical_profile_id,
    canonical_profile_version = values$canonical_profile_version,
    episode_id = episode_id,
    as_of_time = values$as_of_time,
    discharge_time = values$discharge_time,
    target_window_end = values$target_window_end,
    elapsed_seconds_since_discharge = as.double(
      time_number(values$as_of_time) - time_number(values$discharge_time)
    ),
    remaining_seconds_through_w30 = as.double(
      time_number(values$target_window_end) - time_number(values$as_of_time)
    ),
    terminal_status = "none_available_through_as_of"
  ), class = c("rrp_episode_state", "list"))
}

product_provider_context <- function() list(
  product_id = "readmission-risk-pool-platform",
  development_version = "1.0.0-dev",
  target_id = "rrp.risk-target.readmission-remaining-30-day",
  target_version = "0.1.0",
  state_contract_id = "rrp.episode-state",
  state_contract_version = "0.1.0",
  request_contract_id = "rrp.risk-request",
  request_contract_version = "0.1.0",
  provider_api_id = "rrp.provider-api",
  provider_api_version = "0.1.0",
  estimate_contract_id = "rrp.risk-estimate",
  estimate_contract_version = "0.1.0",
  request_class = "rrp_risk_request,list",
  estimate_class = "rrp_risk_estimate,list",
  target_interval_boundary = "(start,end]",
  output_type = "probability",
  output_minimum = 0,
  output_maximum = 1
)

product_provider <- function(value = 0.25, suffix = "one") list(
  component_id = paste0("product-test.provider-", suffix),
  component_version = "1.0.0",
  provider_api_id = "rrp.provider-api",
  provider_api_version = "0.1.0",
  target_id = "rrp.risk-target.readmission-remaining-30-day",
  target_version = "0.1.0",
  state_contract_id = "rrp.episode-state",
  state_contract_version = "0.1.0",
  request_contract_id = "rrp.risk-request",
  request_contract_version = "0.1.0",
  estimate_contract_id = "rrp.risk-estimate",
  estimate_contract_version = "0.1.0",
  implementation_id = paste0("product-test.provider-implementation-", suffix),
  implementation_version = "1.0.0",
  model_id = paste0("product-test.model-", suffix),
  model_version = "1.0.0",
  callable = function(request) list(
    request_id = request$request_id, status = "success",
    estimate_value = value, failure_code = NULL
  )
)

product_disposition_values <- function(
  scope, episode_id, outcome = "accepted_estimate", value = 0.25,
  kind = "initial", related = NULL, key = NULL,
  terminal = scope$analytical_time, ineligible_code = "episode_already_dead",
  provider_suffix = "one"
) {
  state <- if (identical(outcome, "ineligible")) NULL else
    product_state(scope, episode_id)
  provider <- product_provider(value, provider_suffix)
  request <- if (is.null(state) || identical(outcome, "provider_incompatible")) {
    NULL
  } else product_internal("rrp_runtime_risk_request", "rrpruntime")(
    state, product_provider_context()
  )
  estimate <- if (identical(outcome, "accepted_estimate")) {
    rrpruntime::rrp_execute_risk_provider(
      state, provider, product_provider_context()
    )
  } else NULL
  details <- switch(outcome,
    ineligible = c(ineligible_code, "ineligible", "not_invoked"),
    accepted_estimate = c("estimate_accepted", "eligible", "succeeded"),
    provider_incompatible = c("provider_incompatible", "eligible", "not_invoked"),
    provider_declared_failure = c(
      "provider_unavailable", "eligible", "declared_failure"
    ),
    detected_failure = c(
      "provider_execution_failed", "eligible", "detected_failure"
    )
  )
  provider_present <- !identical(outcome, "ineligible")
  list(
    analytical_kind = kind,
    related_analytical_run_id = related,
    analytical_key = key,
    episode_id = episode_id,
    patient_id = paste0("private-patient-", episode_id),
    target_id = scope$target_id,
    target_version = scope$target_version,
    analytical_time = scope$analytical_time,
    outcome = outcome,
    outcome_code = unname(details[[1L]]),
    eligibility_status = unname(details[[2L]]),
    state = state,
    request = request,
    provider_id = if (provider_present) provider$component_id else NULL,
    provider_version = if (provider_present) provider$component_version else NULL,
    implementation_id = if (provider_present) provider$implementation_id else NULL,
    implementation_version = if (provider_present) {
      provider$implementation_version
    } else NULL,
    model_id = if (provider_present) provider$model_id else NULL,
    model_version = if (provider_present) provider$model_version else NULL,
    provider_status = unname(details[[3L]]),
    estimate = estimate,
    terminal_time = terminal
  )
}

product_memory_adapter <- function() {
  store <- new.env(parent = emptyenv())
  store$scopes <- list(); store$dispositions <- list(); store$actions <- list()
  copy <- product_internal("rrp_history_copy", "rrpruntime")
  add <- function(collection, record, field) {
    values <- store[[collection]]
    ids <- vapply(values, `[[`, character(1L), field)
    at <- which(ids == record[[field]])
    if (!length(at)) values[[length(values) + 1L]] <- copy(record) else
      stopifnot(identical(values[[at[[1L]]]], record))
    store[[collection]] <- values
    copy(record)
  }
  scope_raw <- function(operation_run_id) {
    operations <- operation_run_id
    repeat {
      linked <- Filter(function(action) {
        action$target_operation_run_id %in% operations ||
          (!is.null(action$replacement_operation_run_id) &&
            action$replacement_operation_run_id %in% operations)
      }, store$actions)
      expanded <- unique(c(
        operations,
        vapply(linked, `[[`, character(1L), "target_operation_run_id"),
        unlist(lapply(linked, `[[`, "replacement_operation_run_id"),
          use.names = FALSE)
      ))
      if (setequal(expanded, operations)) break
      operations <- expanded
    }
    list(
      scopes = copy(Filter(function(x) x$operation_run_id %in% operations,
        store$scopes)),
      dispositions = copy(Filter(function(x) x$operation_run_id %in% operations,
        store$dispositions)),
      actions = copy(Filter(function(x) {
        x$target_operation_run_id %in% operations ||
          (!is.null(x$replacement_operation_run_id) &&
            x$replacement_operation_run_id %in% operations)
      }, store$actions))
    )
  }
  episode_raw <- function(episode_id, target_id, history_cutoff) {
    matches <- Filter(function(x) {
      identical(x$episode_id, episode_id) && identical(x$target_id, target_id)
    }, store$dispositions)
    operations <- unique(vapply(matches, `[[`, character(1L), "operation_run_id"))
    if (!length(operations)) return(list(
      scopes = list(), dispositions = list(), actions = list()
    ))
    Reduce(product_internal("rrp_history_merge_raw", "rrpruntime"),
      lapply(operations, scope_raw))
  }
  adapter <- list(
    adapter_id = "rrp.test.product-memory",
    adapter_version = "0.1.0",
    contract_id = "rrp.history.port",
    contract_version = "0.1.0",
    capabilities = structure(as.list(rep(TRUE, 8L)), names = c(
      "atomic_scope_append", "atomic_episode_append",
      "atomic_restatement_append", "identical_append_idempotency",
      "conflicting_identity_rejection", "immutable_raw_retention",
      "bounded_raw_reads", "detached_reads"
    )),
    methods = list(
      append_scope = function(x) add("scopes", x, "operation_run_id"),
      append_disposition = function(x) add("dispositions", x, "analytical_run_id"),
      append_action = function(x) add("actions", x, "action_id"),
      append_restatement = function(replacement, action) {
        collection <- if (inherits(replacement, "rrp_operational_scope")) {
          "scopes"
        } else "dispositions"
        field <- if (identical(collection, "scopes")) {
          "operation_run_id"
        } else "analytical_run_id"
        add(collection, replacement, field); add("actions", action, "action_id")
        copy(list(replacement = replacement, action = action))
      },
      read_scope_history = scope_raw,
      read_episode_history = episode_raw
    )
  )
  list(adapter = adapter, store = store)
}

new_product_port <- function() {
  adapter <- product_memory_adapter()
  list(port = rrpruntime::rrp_new_history_port(adapter$adapter), raw = adapter)
}

append_scope <- function(port, scope, dispositions = list()) {
  rrpruntime::rrp_history_append_scope(port, scope)
  lapply(dispositions, function(x) rrpruntime::rrp_history_append_disposition(port, x))
  invisible(scope)
}

contracts <- product_internal("rrp_product_contracts_expected")()
build <- product_internal("rrp_build_product_set_from_port")
conform <- product_internal("rrp_validate_product_set")

# Normal, irregular, current no-fallback, identity, fingerprint, and privacy.
fixture <- new_product_port()
early <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("early", "2026-01-20T09:15:00Z"),
  c("episode-a", "episode-b")
)
early_a <- rrpruntime::rrp_new_episode_disposition(
  early, product_disposition_values(early, "episode-a", value = 0.2)
)
early_b <- rrpruntime::rrp_new_episode_disposition(
  early, product_disposition_values(early, "episode-b", value = 0.3)
)
late <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("late", "2026-01-20T14:37:00Z"),
  c("episode-b", "episode-a")
)
late_a <- rrpruntime::rrp_new_episode_disposition(
  late, product_disposition_values(
    late, "episode-a", value = 0.4, provider_suffix = "two"
  )
)
late_b <- rrpruntime::rrp_new_episode_disposition(
  late, product_disposition_values(
    late, "episode-b", outcome = "ineligible",
    ineligible_code = "episode_already_dead"
  )
)
append_scope(fixture$port, early, list(early_b, early_a))
append_scope(fixture$port, late, list(late_b, late_a))
set_one <- build(fixture$port, late$operation_run_id,
  "2026-01-20T15:00:00Z", contracts)
set_same <- build(fixture$port, late$operation_run_id,
  "2026-01-20T15:00:00Z", contracts)
set_later <- build(fixture$port, late$operation_run_id,
  "2026-01-20T16:00:00Z", contracts)
current <- set_one$members$current_remaining_risk$data
trajectory <- set_one$members$remaining_risk_trajectory$data
summary <- set_one$members$operational_scope_summary$data
stopifnot(
  identical(set_one, set_same),
  identical(set_one$source_history_fingerprint,
    set_later$source_history_fingerprint),
  !identical(set_one$product_set_id, set_later$product_set_id),
  nrow(current) == 1L, identical(current$episode_id, "episode-a"),
  identical(current$estimate_value, 0.4),
  nrow(trajectory) == 3L,
  identical(trajectory$analytical_time,
    c("2026-01-20T09:15:00Z", "2026-01-20T14:37:00Z",
      "2026-01-20T09:15:00Z")),
  nrow(summary) == 1L, identical(summary$expected_episode_count, 2L),
  identical(summary$accepted_estimate_count, 1L),
  identical(summary$ineligible_count, 1L),
  identical(summary$episode_already_dead_count, 1L),
  grepl("^rrp[.]product-set[.][0-9a-f]{16}$", set_one$product_set_id),
  all(grepl("^rrp[.]product-row[.][0-9a-f]{16}$",
    c(current$product_row_id, trajectory$product_row_id, summary$product_row_id)))
)
conform(rrp_product_copy <- unserialize(serialize(set_one, NULL)), contracts)
mutated <- unserialize(serialize(set_one, NULL))
mutated$members$current_remaining_risk$data$product_row_id[[1L]] <- "wrong"
product_expect(function() conform(mutated, contracts), "product_conformance_failed")
text <- paste(capture.output(dput(set_one)), collapse = " ")
stopifnot(!grepl("private-patient|patient_id|predictor|source_path|credential",
  text, ignore.case = TRUE))
returned <- unserialize(serialize(set_one, NULL))
returned$members$current_remaining_risk$data$estimate_value[[1L]] <- 0
stopifnot(identical(current$estimate_value, 0.4))

# Valid zero-episode scope and valid zero-row estimate members.
empty_fixture <- new_product_port()
empty_scope <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("empty", "2026-01-21T12:00:00Z"), character()
)
append_scope(empty_fixture$port, empty_scope)
empty_set <- build(empty_fixture$port, empty_scope$operation_run_id,
  "2026-01-21T12:00:00Z", contracts)
stopifnot(
  nrow(empty_set$members$current_remaining_risk$data) == 0L,
  nrow(empty_set$members$remaining_risk_trajectory$data) == 0L,
  identical(empty_set$members$operational_scope_summary$data$expected_episode_count, 0L)
)

# Incomplete, unavailable, invalidated, and ambiguous sources are bounded.
incomplete <- new_product_port()
incomplete_scope <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("incomplete", "2026-01-22T12:00:00Z"),
  c("episode-a", "episode-b")
)
append_scope(incomplete$port, incomplete_scope, list(
  rrpruntime::rrp_new_episode_disposition(
    incomplete_scope,
    product_disposition_values(incomplete_scope, "episode-a", value = 0.1)
  )
))
product_expect(function() build(incomplete$port, incomplete_scope$operation_run_id,
  "2026-01-22T13:00:00Z", contracts), "product_source_incomplete")
product_expect(function() build(incomplete$port, "missing.operation",
  "2026-01-22T13:00:00Z", contracts), "product_source_unavailable")

invalid <- new_product_port()
invalid_scope <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("invalid", "2026-01-23T12:00:00Z"), "episode-a"
)
invalid_disposition <- rrpruntime::rrp_new_episode_disposition(
  invalid_scope, product_disposition_values(invalid_scope, "episode-a")
)
append_scope(invalid$port, invalid_scope, list(invalid_disposition))
invalid_action <- rrpruntime::rrp_new_history_action(list(
  target_kind = "operational_scope", target_id = invalid_scope$operation_run_id,
  target_operation_run_id = invalid_scope$operation_run_id,
  action_type = "invalidate", effective_time = "2026-01-23T12:01:00Z",
  reason_code = "incorrect_scope", replacement_operation_run_id = NULL,
  replacement_analytical_run_id = NULL, actor_category = "operator"
))
rrpruntime::rrp_history_append_invalidation(invalid$port, invalid_action)
product_expect(function() build(invalid$port, invalid_scope$operation_run_id,
  "2026-01-23T13:00:00Z", contracts), "product_source_invalidated")

point_invalidation <- new_product_port()
point_early <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("point-early", "2026-01-23T09:00:00Z"), "episode-a"
)
point_early_value <- rrpruntime::rrp_new_episode_disposition(
  point_early, product_disposition_values(point_early, "episode-a", value = 0.15)
)
point_late <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("point-late", "2026-01-23T10:00:00Z"), "episode-a"
)
point_late_value <- rrpruntime::rrp_new_episode_disposition(
  point_late, product_disposition_values(point_late, "episode-a", value = 0.65)
)
append_scope(point_invalidation$port, point_early, list(point_early_value))
append_scope(point_invalidation$port, point_late, list(point_late_value))
before_invalidation <- build(
  point_invalidation$port, point_late$operation_run_id,
  "2026-01-23T11:00:00Z", contracts
)
point_action <- rrpruntime::rrp_new_history_action(list(
  target_kind = "analytical_run",
  target_id = point_late_value$analytical_run_id,
  target_operation_run_id = point_late$operation_run_id,
  action_type = "invalidate", effective_time = "2026-01-23T10:01:00Z",
  reason_code = "superseded_result", replacement_operation_run_id = NULL,
  replacement_analytical_run_id = NULL, actor_category = "operator"
))
rrpruntime::rrp_history_append_invalidation(point_invalidation$port, point_action)
after_invalidation <- build(
  point_invalidation$port, point_late$operation_run_id,
  "2026-01-23T11:00:00Z", contracts
)
stopifnot(
  identical(after_invalidation$members$current_remaining_risk$data$estimate_value,
    0.15),
  nrow(after_invalidation$members$remaining_risk_trajectory$data) == 1L,
  identical(
    after_invalidation$members$remaining_risk_trajectory$data$analytical_run_id,
    point_early_value$analytical_run_id
  ),
  !identical(before_invalidation$source_history_fingerprint,
    after_invalidation$source_history_fingerprint)
)

ambiguous <- new_product_port()
amb_one <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("amb-one", "2026-01-24T12:00:00Z"), "episode-a"
)
amb_two <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("amb-two", "2026-01-24T12:00:00Z"), "episode-a"
)
append_scope(ambiguous$port, amb_one, list(
  rrpruntime::rrp_new_episode_disposition(
    amb_one, product_disposition_values(amb_one, "episode-a", value = 0.2)
  )
))
append_scope(ambiguous$port, amb_two, list(
  rrpruntime::rrp_new_episode_disposition(
    amb_two, product_disposition_values(amb_two, "episode-a", value = 0.3)
  )
))
product_expect(function() build(ambiguous$port, amb_two$operation_run_id,
  "2026-01-24T13:00:00Z", contracts), "product_source_ambiguous")

# Retry and restatement inherit Stage 7 leaf resolution.
retry_fixture <- new_product_port()
retry_scope <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("retry", "2026-01-25T12:00:00Z"), "episode-a"
)
failed <- rrpruntime::rrp_new_episode_disposition(
  retry_scope, product_disposition_values(
    retry_scope, "episode-a", outcome = "detected_failure"
  )
)
retry <- rrpruntime::rrp_new_episode_disposition(
  retry_scope, product_disposition_values(
    retry_scope, "episode-a", value = 0.55, kind = "retry",
    related = failed$analytical_run_id, key = "retry-one",
    terminal = "2026-01-25T12:01:00Z"
  )
)
append_scope(retry_fixture$port, retry_scope, list(failed))
failed_set <- build(retry_fixture$port, retry_scope$operation_run_id,
  "2026-01-25T13:00:00Z", contracts)
stopifnot(
  nrow(failed_set$members$current_remaining_risk$data) == 0L,
  nrow(failed_set$members$remaining_risk_trajectory$data) == 0L,
  identical(
    failed_set$members$operational_scope_summary$data$detected_failure_count,
    1L
  )
)
rrpruntime::rrp_history_append_disposition(retry_fixture$port, retry)
retry_set <- build(retry_fixture$port, retry_scope$operation_run_id,
  "2026-01-25T13:00:00Z", contracts)
stopifnot(
  identical(retry_set$members$current_remaining_risk$data$estimate_value, 0.55),
  identical(retry_set$members$remaining_risk_trajectory$data$analytical_kind,
    "retry"),
  !identical(failed_set$source_history_fingerprint,
    retry_set$source_history_fingerprint)
)

restate_fixture <- new_product_port()
old_scope <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("restate-old", "2026-01-26T12:00:00Z"), "episode-a"
)
old_value <- rrpruntime::rrp_new_episode_disposition(
  old_scope, product_disposition_values(old_scope, "episode-a", value = 0.1)
)
new_value <- rrpruntime::rrp_new_episode_disposition(
  old_scope, product_disposition_values(
    old_scope, "episode-a", value = 0.7, kind = "restatement",
    related = old_value$analytical_run_id, key = "correction-one",
    terminal = "2026-01-26T12:01:00Z"
  )
)
append_scope(restate_fixture$port, old_scope, list(old_value))
restatement <- rrpruntime::rrp_new_history_action(list(
  target_kind = "analytical_run", target_id = old_value$analytical_run_id,
  target_operation_run_id = old_scope$operation_run_id,
  action_type = "restate", effective_time = "2026-01-26T12:02:00Z",
  reason_code = "superseded_result",
  replacement_operation_run_id = old_scope$operation_run_id,
  replacement_analytical_run_id = new_value$analytical_run_id,
  actor_category = "operator"
))
rrpruntime::rrp_history_append_restatement(
  restate_fixture$port, new_value, restatement
)
restate_set <- build(restate_fixture$port, old_scope$operation_run_id,
  "2026-01-26T13:00:00Z", contracts)
stopifnot(
  identical(restate_set$members$current_remaining_risk$data$estimate_value, 0.7),
  nrow(restate_set$members$remaining_risk_trajectory$data) == 1L,
  identical(restate_set$members$remaining_risk_trajectory$data$analytical_kind,
    "restatement")
)

# A second-read change cannot produce a successful incoherent set.
changing <- new_product_port()
changing_scope <- rrpruntime::rrp_new_operational_scope(
  product_scope_values("changing", "2026-01-27T12:00:00Z"), "episode-a"
)
changing_failure <- rrpruntime::rrp_new_episode_disposition(
  changing_scope, product_disposition_values(
    changing_scope, "episode-a", outcome = "detected_failure"
  )
)
changing_retry <- rrpruntime::rrp_new_episode_disposition(
  changing_scope, product_disposition_values(
    changing_scope, "episode-a", value = 0.8, kind = "retry",
    related = changing_failure$analytical_run_id, key = "late-retry",
    terminal = "2026-01-27T12:01:00Z"
  )
)
append_scope(changing$port, changing_scope, list(changing_failure))
base_read <- changing$port$adapter$methods$read_scope_history
base_append <- changing$port$adapter$methods$append_disposition
reads <- 0L
changing$port$adapter$methods$read_scope_history <- function(operation_run_id) {
  reads <<- reads + 1L
  if (reads == 2L) base_append(changing_retry)
  base_read(operation_run_id)
}
product_expect(function() build(changing$port, changing_scope$operation_run_id,
  "2026-01-27T13:00:00Z", contracts), "product_source_changed")

# Supplied persistent-port equivalence and public common-result behavior.
software_root <- Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
if (nzchar(software_root) && dir.exists(software_root)) {
  catalog <- rrp_open_resource_catalog(software_root)
  installed_contracts <- product_internal("rrp_product_contracts")(catalog)
  stopifnot(
    identical(names(installed_contracts), names(contracts)),
    all(vapply(names(contracts), function(name) {
      identical(unlist(installed_contracts[[name]], use.names = TRUE),
        contracts[[name]])
    }, logical(1L)))
  )
  root <- tempfile("rrp-product-project-")
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  initialized <- rrp_initialize_fictional_project(catalog, root)
  stopifnot(rrp_operation_succeeded(initialized))
  generator <- new.env(parent = baseenv())
  sys.source(file.path(root, "R", "generate-source.R"), generator,
    chdir = FALSE, keep.source = FALSE)
  generator$rrp_generate_fictional_source(root)
  stopifnot(rrp_operation_succeeded(rrp_initialize_project_state(catalog, root)))
  execution <- rrp_execute_durable_bundle(
    catalog, root, "2026-01-20T12:00:00Z", "product-proof"
  )
  stopifnot(rrp_operation_succeeded(execution))
  public <- rrp_build_product_set(
    catalog, root, execution$value$operation_run_id, "2026-01-20T12:00:00Z"
  )
  stopifnot(rrp_operation_succeeded(public))
  persistent <- product_internal("rrp_durable_port")(catalog, root)
  raw <- rrpruntime::rrp_history_read_scope(
    persistent$port, execution$value$operation_run_id
  )
  memory <- new_product_port()
  rrpruntime::rrp_history_append_scope(memory$port, raw$scope)
  lapply(raw$dispositions, function(x) {
    rrpruntime::rrp_history_append_disposition(memory$port, x)
  })
  lapply(raw$actions, function(x) {
    rrpruntime::rrp_history_append_invalidation(memory$port, x)
  })
  equivalent <- build(
    memory$port, execution$value$operation_run_id,
    "2026-01-20T12:00:00Z", installed_contracts
  )
  stopifnot(identical(public$value, equivalent))
  unavailable <- rrp_build_product_set(
    catalog, root, "missing.operation", "2026-01-20T12:00:00Z"
  )
  stopifnot(
    !rrp_operation_succeeded(unavailable), is.null(unavailable$value),
    identical(unavailable$diagnostics[[1L]]$code, "product_source_unavailable")
  )
}

cat("rrpplatform logical product tests passed\n")
