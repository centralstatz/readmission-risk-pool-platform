library(rrpruntime)

history_internal <- function(name) {
  get(name, envir = asNamespace("rrpruntime"), inherits = FALSE)
}

history_expect <- function(callback, code) {
  condition <- tryCatch({
    callback()
    NULL
  }, error = identity)
  stopifnot(
    inherits(condition, "rrp_history_error"),
    identical(condition$code, code),
    identical(condition$call, NULL),
    is.character(condition$message), length(condition$message) == 1L,
    nchar(condition$message, type = "bytes") <= 160L,
    !grepl("patient|episode-[0-9]|secret|/", condition$message)
  )
  invisible(condition)
}

history_scope_values <- function(
  key = "operation-001",
  analytical_time = "2026-01-20T12:00:00Z",
  created_at = "2026-01-20T12:01:00Z"
) list(
  operation_key = key,
  state_id = "rrp.state.fictional-001",
  product_id = "readmission-risk-pool-platform",
  development_version = "1.0.0-dev",
  rrp_api_version = "0.1.0",
  project_api_id = "rrp.project-api",
  project_api_version = "0.3.0",
  project_id = "fictional-hospital",
  project_version = "1.0.0",
  bundle_contract_id = "rrp.canonical-bundle",
  bundle_contract_version = "0.1.0",
  bundle_instance_id = paste0("fictional.bundle.", key),
  canonical_profile_id = "rrp.canonical-profile.readmission",
  canonical_profile_version = "0.1.0",
  producer_id = "fictional.producer",
  producer_version = "1.0.0",
  producer_implementation_id = "fictional.producer-implementation",
  producer_implementation_version = "1.0.0",
  mapping_id = "fictional.mapping",
  mapping_version = "1.0.0",
  target_id = "rrp.risk-target.readmission-remaining-30-day",
  target_version = "0.1.0",
  analytical_time = analytical_time,
  created_at = created_at
)

history_state <- function(scope, episode_id) {
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
    discharge_time = "2026-01-10T12:00:00Z",
    target_window_end = "2026-02-09T12:00:00Z",
    target_id = scope$target_id,
    target_version = scope$target_version,
    state_contract_id = "rrp.episode-state",
    state_contract_version = "0.1.0"
  )
  structure(list(
    state_contract_id = values$state_contract_id,
    state_contract_version = values$state_contract_version,
    state_id = history_internal("rrp_runtime_state_identity")(unname(values)),
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
    elapsed_seconds_since_discharge = 864000,
    remaining_seconds_through_w30 = 1728000,
    terminal_status = "none_available_through_as_of"
  ), class = c("rrp_episode_state", "list"))
}

history_provider_context <- function() list(
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

history_provider <- function(value = 0.25) list(
  component_id = "fictional.provider",
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
  implementation_id = "fictional.provider-implementation",
  implementation_version = "1.0.0",
  model_id = "fictional.model",
  model_version = "1.0.0",
  callable = function(request) list(
    request_id = request$request_id,
    status = "success",
    estimate_value = value,
    failure_code = NULL
  )
)

history_disposition_values <- function(
  scope, episode_id, patient_id = paste0("fictional-patient-", episode_id),
  outcome = "accepted_estimate", kind = "initial", related = NULL,
  analytical_key = NULL, terminal_time = "2026-01-20T12:02:00Z"
) {
  state <- if (identical(outcome, "ineligible")) NULL else
    history_state(scope, episode_id)
  provider <- history_provider()
  request <- if (is.null(state) || identical(outcome, "provider_incompatible")) {
    NULL
  } else history_internal("rrp_runtime_risk_request")(
    state, history_provider_context()
  )
  estimate <- if (identical(outcome, "accepted_estimate")) {
    rrp_execute_risk_provider(state, provider, history_provider_context())
  } else NULL
  outcomes <- list(
    ineligible = c("episode_before_discharge", "ineligible", "not_invoked"),
    accepted_estimate = c("estimate_accepted", "eligible", "succeeded"),
    provider_incompatible = c("provider_incompatible", "eligible", "not_invoked"),
    provider_declared_failure = c(
      "provider_unavailable", "eligible", "declared_failure"
    ),
    detected_failure = c("provider_execution_failed", "eligible", "detected_failure")
  )
  selected <- outcomes[[outcome]]
  provider_present <- !identical(outcome, "ineligible")
  list(
    analytical_kind = kind,
    related_analytical_run_id = related,
    analytical_key = analytical_key,
    episode_id = episode_id,
    patient_id = patient_id,
    target_id = scope$target_id,
    target_version = scope$target_version,
    analytical_time = scope$analytical_time,
    outcome = outcome,
    outcome_code = unname(selected[[1L]]),
    eligibility_status = unname(selected[[2L]]),
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
    provider_status = unname(selected[[3L]]),
    estimate = estimate,
    terminal_time = terminal_time
  )
}

history_action_values <- function(
  target, type = "invalidate", replacement = NULL,
  effective_time = "2026-01-20T12:04:00Z"
) {
  target_scope <- inherits(target, "rrp_operational_scope")
  replacement_scope <- inherits(replacement, "rrp_operational_scope")
  list(
    target_kind = if (target_scope) "operational_scope" else "analytical_run",
    target_id = if (target_scope) target$operation_run_id else target$analytical_run_id,
    target_operation_run_id = target$operation_run_id,
    action_type = type,
    effective_time = effective_time,
    reason_code = if (target_scope) "incorrect_scope" else "superseded_result",
    replacement_operation_run_id = if (is.null(replacement)) NULL else
      replacement$operation_run_id,
    replacement_analytical_run_id = if (is.null(replacement) || replacement_scope) {
      NULL
    } else replacement$analytical_run_id,
    actor_category = "operator"
  )
}

history_memory_adapter <- function() {
  store <- new.env(parent = emptyenv())
  store$scopes <- list()
  store$dispositions <- list()
  store$actions <- list()
  copy <- history_internal("rrp_history_copy")
  abort <- history_internal("rrp_history_abort")
  add <- function(collection, record, field) {
    current <- store[[collection]]
    ids <- vapply(current, `[[`, character(1L), field)
    at <- which(ids == record[[field]])
    if (!length(at)) {
      current[[length(current) + 1L]] <- copy(record)
      store[[collection]] <- current
    } else if (!identical(current[[at[[1L]]]], record)) {
      abort("identity_conflict")
    }
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
      scopes = copy(Filter(function(value) {
        value$operation_run_id %in% operations
      }, store$scopes)),
      dispositions = copy(Filter(function(value) {
        value$operation_run_id %in% operations
      }, store$dispositions)),
      actions = copy(Filter(function(value) {
        value$target_operation_run_id %in% operations ||
          (!is.null(value$replacement_operation_run_id) &&
            value$replacement_operation_run_id %in% operations)
      }, store$actions))
    )
  }
  episode_raw <- function(episode_id, target_id, history_cutoff) {
    matching <- Filter(function(value) {
      identical(value$episode_id, episode_id) && identical(value$target_id, target_id)
    }, store$dispositions)
    operations <- unique(vapply(
      matching, `[[`, character(1L), "operation_run_id"
    ))
    if (!length(operations)) return(list(
      scopes = list(), dispositions = list(), actions = list()
    ))
    parts <- lapply(operations, scope_raw)
    merge <- history_internal("rrp_history_merge_raw")
    Reduce(merge, parts)
  }
  methods <- list(
    append_scope = function(scope) add("scopes", scope, "operation_run_id"),
    append_disposition = function(disposition) {
      add("dispositions", disposition, "analytical_run_id")
    },
    append_action = function(action) add("actions", action, "action_id"),
    append_restatement = function(replacement, action) {
      collection <- if (inherits(replacement, "rrp_operational_scope")) {
        "scopes"
      } else "dispositions"
      field <- if (identical(collection, "scopes")) {
        "operation_run_id"
      } else "analytical_run_id"
      # Both preflight checks occur before either in-memory collection changes.
      current_replacement <- store[[collection]]
      replacement_ids <- vapply(current_replacement, `[[`, character(1L), field)
      replacement_at <- which(replacement_ids == replacement[[field]])
      if (length(replacement_at) &&
          !identical(current_replacement[[replacement_at[[1L]]]], replacement)) {
        abort("identity_conflict")
      }
      action_ids <- vapply(store$actions, `[[`, character(1L), "action_id")
      action_at <- which(action_ids == action$action_id)
      if (length(action_at) && !identical(store$actions[[action_at[[1L]]]], action)) {
        abort("identity_conflict")
      }
      add(collection, replacement, field)
      add("actions", action, "action_id")
      copy(list(replacement = replacement, action = action))
    },
    read_scope_history = scope_raw,
    read_episode_history = episode_raw
  )
  list(
    adapter_id = "rrp.test.in-memory-history",
    adapter_version = "0.1.0",
    contract_id = "rrp.history.port",
    contract_version = "0.1.0",
    capabilities = structure(
      as.list(rep(TRUE, 8L)),
      names = c(
        "atomic_scope_append", "atomic_episode_append",
        "atomic_restatement_append", "identical_append_idempotency",
        "conflicting_identity_rejection", "immutable_raw_retention",
        "bounded_raw_reads", "detached_reads"
      )
    ),
    methods = methods
  )
}

# Deterministic identities, closed construction, and zero-scope completion.
ids <- c("episode-002", "episode-001")
stopifnot(
  identical(
    rrp_history_membership_fingerprint(ids),
    rrp_history_membership_fingerprint(rev(ids))
  )
)
history_expect(function() rrp_history_membership_fingerprint(c(ids, ids[[1L]])),
  "invalid_scope")
scope <- rrp_new_operational_scope(history_scope_values(), ids)
scope_again <- rrp_new_operational_scope(history_scope_values(), rev(ids))
stopifnot(
  identical(scope, scope_again),
  grepl("^rrp[.]operation-run[.][0-9a-f]{16}$", scope$operation_run_id),
  grepl("^rrp[.]membership[.][0-9a-f]{16}$", scope$membership_fingerprint)
)
equal_time_scope <- rrp_new_operational_scope(
  history_scope_values(
    "operation-equal-time",
    analytical_time = "2026-01-20T12:00:00Z",
    created_at = "2026-01-20T12:00:00Z"
  ),
  "episode-equal-time"
)
stopifnot(identical(
  equal_time_scope$created_at, equal_time_scope$analytical_time
))
history_expect(function() rrp_new_operational_scope(
  history_scope_values(
    "operation-invalid-time",
    analytical_time = "2026-01-20T12:00:00Z",
    created_at = "2026-01-20T11:59:59Z"
  ),
  "episode-invalid-time"
), "invalid_scope")
equal_time_disposition <- rrp_new_episode_disposition(
  equal_time_scope,
  history_disposition_values(
    equal_time_scope, "episode-equal-time", outcome = "ineligible",
    terminal_time = equal_time_scope$analytical_time
  )
)
stopifnot(identical(
  equal_time_disposition$terminal_time,
  equal_time_disposition$analytical_time
))
history_expect(function() rrp_new_episode_disposition(
  equal_time_scope,
  history_disposition_values(
    equal_time_scope, "episode-equal-time", outcome = "ineligible",
    terminal_time = "2026-01-20T11:59:59Z"
  )
), "invalid_disposition")
zero_scope <- rrp_new_operational_scope(
  history_scope_values("operation-zero"), character()
)
port <- rrp_new_history_port(history_memory_adapter())
rrp_history_append_scope(port, zero_scope)
stopifnot(rrp_history_read_scope(port, zero_scope$operation_run_id)$progress$complete)

# Partial/complete progress and all terminal field-presence families.
rrp_history_append_scope(port, scope)
first <- rrp_new_episode_disposition(
  scope, history_disposition_values(scope, "episode-001", outcome = "accepted_estimate")
)
second <- rrp_new_episode_disposition(
  scope, history_disposition_values(scope, "episode-002", outcome = "ineligible")
)
rrp_history_append_disposition(port, first)
partial <- rrp_history_read_scope(port, scope$operation_run_id)
stopifnot(
  identical(partial$progress$dispositioned_episode_count, 1L),
  !partial$progress$complete,
  is.null(rrp_history_read_current(
    port, "episode-001", scope$target_id,
    "2026-01-20T12:00:00Z", "2026-01-20T12:03:00Z"
  ))
)
rrp_history_append_disposition(port, second)
complete <- rrp_history_read_scope(port, scope$operation_run_id)
stopifnot(
  identical(complete$progress$dispositioned_episode_count, 2L),
  complete$progress$complete,
  identical(rrp_history_read_current(
    port, "episode-001", scope$target_id,
    "2026-01-20T12:00:00Z", "2026-01-20T12:03:00Z"
  ), first)
)
for (outcome in c(
  "provider_incompatible", "provider_declared_failure", "detected_failure"
)) {
  local_scope <- rrp_new_operational_scope(
    history_scope_values(paste0("operation-", gsub("_", "-", outcome))),
    "episode-003"
  )
  local_disposition <- rrp_new_episode_disposition(
    local_scope,
    history_disposition_values(local_scope, "episode-003", outcome = outcome)
  )
  rrp_history_append_scope(port, local_scope)
  rrp_history_append_disposition(port, local_disposition)
  stopifnot(
    identical(local_disposition$outcome, outcome),
    rrp_history_read_scope(port, local_scope$operation_run_id)$progress$complete
  )
}
bad_presence <- history_disposition_values(scope, "episode-004", outcome = "ineligible")
bad_presence$provider_id <- "fictional.provider"
history_expect(function() rrp_new_episode_disposition(scope, bad_presence),
  "invalid_disposition")

# Exact idempotency, content conflict, mismatch progress, and detached reads.
rrp_history_append_scope(port, scope)
rrp_history_append_disposition(port, first)
conflicting_scope <- scope
conflicting_scope$bundle_instance_id <- "fictional.bundle.conflict"
history_expect(function() rrp_history_append_scope(port, conflicting_scope),
  "identity_conflict")
conflicting_disposition <- first
conflicting_disposition$terminal_time <- "2026-01-20T12:02:30Z"
history_expect(function() rrp_history_append_disposition(port, conflicting_disposition),
  "identity_conflict")
mismatch_scope <- rrp_new_operational_scope(
  history_scope_values("operation-mismatch"), c("episode-a", "episode-b")
)
rrp_history_append_scope(port, mismatch_scope)
for (episode in c("episode-a", "episode-c")) rrp_history_append_disposition(
  port, rrp_new_episode_disposition(
    mismatch_scope,
    history_disposition_values(mismatch_scope, episode, outcome = "ineligible")
  )
)
stopifnot(!rrp_history_read_scope(port,
  mismatch_scope$operation_run_id)$progress$complete)
detached <- rrp_history_read_scope(port, scope$operation_run_id)
detached$scope$operation_key <- "changed"
stopifnot(identical(
  rrp_history_read_scope(port, scope$operation_run_id)$scope$operation_key,
  "operation-001"
))

# Continuation counts only initial dispositions; explicit retry is a new lineage.
retry_scope <- rrp_new_operational_scope(
  history_scope_values("operation-retry"), "episode-retry"
)
rrp_history_append_scope(port, retry_scope)
failed <- rrp_new_episode_disposition(
  retry_scope,
  history_disposition_values(retry_scope, "episode-retry", outcome = "detected_failure")
)
rrp_history_append_disposition(port, failed)
retry <- rrp_new_episode_disposition(retry_scope, history_disposition_values(
  retry_scope, "episode-retry", outcome = "accepted_estimate", kind = "retry",
  related = failed$analytical_run_id, analytical_key = "operator-retry-001",
  terminal_time = "2026-01-20T12:03:00Z"
))
rrp_history_append_disposition(port, retry)
retry_progress <- rrp_history_read_scope(port, retry_scope$operation_run_id)$progress
stopifnot(
  retry_progress$complete,
  identical(retry_progress$dispositioned_episode_count, 1L),
  identical(rrp_history_read_current(
    port, "episode-retry", retry_scope$target_id,
    retry_scope$analytical_time, "2026-01-20T12:03:30Z"
  ), retry)
)
invalid_retry <- rrp_new_episode_disposition(scope, history_disposition_values(
  scope, "episode-001", outcome = "accepted_estimate", kind = "retry",
  related = first$analytical_run_id, analytical_key = "invalid-retry",
  terminal_time = "2026-01-20T12:03:00Z"
))
history_expect(function() rrp_history_append_disposition(port, invalid_retry),
  "relationship_conflict")

# Episode invalidation is time-relative and preserves raw facts.
invalidation <- rrp_new_history_action(history_action_values(
  retry, effective_time = "2026-01-20T12:04:00Z"
))
rrp_history_append_invalidation(port, invalidation)
stopifnot(
  identical(rrp_history_read_current(
    port, "episode-retry", retry_scope$target_id,
    retry_scope$analytical_time, "2026-01-20T12:03:30Z"
  ), retry),
  identical(rrp_history_read_current(
    port, "episode-retry", retry_scope$target_id,
    retry_scope$analytical_time, "2026-01-20T12:04:30Z"
  ), failed),
  length(rrp_history_read_episode(
    port, "episode-retry", retry_scope$target_id,
    "2026-01-20T12:05:00Z"
  )$dispositions) == 2L
)

# Atomic episode restatement replaces, rather than mutates, the old fact.
restate_scope <- rrp_new_operational_scope(
  history_scope_values("operation-restate"), "episode-restate"
)
rrp_history_append_scope(port, restate_scope)
original <- rrp_new_episode_disposition(
  restate_scope,
  history_disposition_values(restate_scope, "episode-restate", outcome = "ineligible")
)
rrp_history_append_disposition(port, original)
replacement <- rrp_new_episode_disposition(restate_scope, history_disposition_values(
  restate_scope, "episode-restate", outcome = "accepted_estimate",
  kind = "restatement", related = original$analytical_run_id,
  analytical_key = "correction-001", terminal_time = "2026-01-20T12:05:00Z"
))
restatement <- rrp_new_history_action(history_action_values(
  original, "restate", replacement, "2026-01-20T12:05:00Z"
))
rrp_history_append_restatement(port, replacement, restatement)
stopifnot(
  identical(rrp_history_read_current(
    port, "episode-restate", restate_scope$target_id,
    restate_scope$analytical_time, "2026-01-20T12:06:00Z"
  ), replacement),
  length(rrp_history_read_episode(
    port, "episode-restate", restate_scope$target_id,
    "2026-01-20T12:06:00Z"
  )$dispositions) == 2L
)

# Scope invalidation and scope restatement remain narrow shared-scope actions.
scope_invalidation <- rrp_new_history_action(history_action_values(
  scope, effective_time = "2026-01-20T12:07:00Z"
))
rrp_history_append_invalidation(port, scope_invalidation)
stopifnot(is.null(rrp_history_read_current(
  port, "episode-001", scope$target_id,
  scope$analytical_time, "2026-01-20T12:08:00Z"
)))
old_scope <- rrp_new_operational_scope(
  history_scope_values("operation-scope-old"), "episode-scope"
)
new_scope <- rrp_new_operational_scope(
  history_scope_values("operation-scope-new", created_at = "2026-01-20T12:10:00Z"),
  "episode-scope"
)
rrp_history_append_scope(port, old_scope)
old_value <- rrp_new_episode_disposition(
  old_scope, history_disposition_values(old_scope, "episode-scope", outcome = "ineligible")
)
rrp_history_append_disposition(port, old_value)
scope_restatement <- rrp_new_history_action(history_action_values(
  old_scope, "restate", new_scope, "2026-01-20T12:10:00Z"
))
rrp_history_append_restatement(port, new_scope, scope_restatement)
stopifnot(is.null(rrp_history_read_current(
  port, "episode-scope", old_scope$target_id,
  old_scope$analytical_time, "2026-01-20T12:11:00Z"
)))
new_value <- rrp_new_episode_disposition(
  new_scope,
  history_disposition_values(new_scope, "episode-scope", outcome = "accepted_estimate",
    terminal_time = "2026-01-20T12:11:00Z")
)
rrp_history_append_disposition(port, new_value)
stopifnot(identical(rrp_history_read_current(
  port, "episode-scope", old_scope$target_id,
  old_scope$analytical_time, "2026-01-20T12:12:00Z"
), new_value))

# Explicit analytical cutoff and same-time unrelated ambiguity.
early_scope <- rrp_new_operational_scope(history_scope_values(
  "operation-early", "2026-01-19T12:00:00Z", "2026-01-19T12:01:00Z"
), "episode-time")
late_scope <- rrp_new_operational_scope(history_scope_values(
  "operation-late", "2026-01-21T12:00:00Z", "2026-01-21T12:01:00Z"
), "episode-time")
for (local_scope in list(early_scope, late_scope)) {
  rrp_history_append_scope(port, local_scope)
  rrp_history_append_disposition(port, rrp_new_episode_disposition(
    local_scope, history_disposition_values(
      local_scope, "episode-time", outcome = "ineligible",
      terminal_time = local_scope$created_at
    )
  ))
}
stopifnot(identical(rrp_history_read_current(
  port, "episode-time", early_scope$target_id,
  early_scope$analytical_time, "2026-01-22T00:00:00Z"
)$operation_run_id, early_scope$operation_run_id))
ambiguous_scope <- rrp_new_operational_scope(history_scope_values(
  "operation-ambiguous", late_scope$analytical_time, "2026-01-21T12:02:00Z"
), "episode-time")
rrp_history_append_scope(port, ambiguous_scope)
rrp_history_append_disposition(port, rrp_new_episode_disposition(
  ambiguous_scope, history_disposition_values(
    ambiguous_scope, "episode-time", outcome = "ineligible",
    terminal_time = ambiguous_scope$created_at
  )
))
history_expect(function() rrp_history_read_current(
  port, "episode-time", late_scope$target_id,
  late_scope$analytical_time, "2026-01-22T00:00:00Z"
), "ambiguous_current")

# Invalid adapters, invalid cutoffs, and post-read mutation fail safely.
bad_adapter <- history_memory_adapter()
bad_adapter$capabilities$close_reopen_durability <- TRUE
history_expect(function() rrp_new_history_port(bad_adapter), "invalid_adapter")
history_expect(function() rrp_history_read_current(
  port, "episode-001", scope$target_id, "not-a-time", "2026-01-22T00:00:00Z"
), "invalid_read")

cat("rrpruntime history tests passed\n")
