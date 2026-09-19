library(rrpruntime)

rrp_provider_test_internal <- function(name) {
  get(name, envir = asNamespace("rrpruntime"), inherits = FALSE)
}

rrp_provider_test_context <- function() {
  list(
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
}

rrp_provider_test_state <- function() {
  values <- list(
    bundle_contract_id = "rrp.canonical-bundle",
    bundle_contract_version = "0.1.0",
    bundle_instance_id = "fictional.bundle",
    project_id = "fictional-health-system",
    project_version = "1.0.0",
    canonical_profile_id = "rrp.canonical-profile.readmission",
    canonical_profile_version = "0.1.0",
    episode_id = "episode-001",
    as_of_time = "2026-01-20T12:00:00Z",
    discharge_time = "2026-01-10T12:00:00Z",
    target_window_end = "2026-02-09T12:00:00Z",
    target_id = "rrp.risk-target.readmission-remaining-30-day",
    target_version = "0.1.0",
    state_contract_id = "rrp.episode-state",
    state_contract_version = "0.1.0"
  )
  identity <- rrp_provider_test_internal("rrp_runtime_state_identity")(
    unname(values)
  )
  structure(list(
    state_contract_id = values$state_contract_id,
    state_contract_version = values$state_contract_version,
    state_id = identity,
    target_id = values$target_id,
    target_version = values$target_version,
    bundle_contract_id = values$bundle_contract_id,
    bundle_contract_version = values$bundle_contract_version,
    bundle_instance_id = values$bundle_instance_id,
    project_id = values$project_id,
    project_version = values$project_version,
    canonical_profile_id = values$canonical_profile_id,
    canonical_profile_version = values$canonical_profile_version,
    episode_id = values$episode_id,
    as_of_time = values$as_of_time,
    discharge_time = values$discharge_time,
    target_window_end = values$target_window_end,
    elapsed_seconds_since_discharge = 864000,
    remaining_seconds_through_w30 = 1728000,
    terminal_status = "none_available_through_as_of"
  ), class = c("rrp_episode_state", "list"))
}

rrp_provider_test_provider <- function(callable, model = FALSE) {
  list(
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
    model_id = if (model) "fictional.model" else NULL,
    model_version = if (model) "2.0.0" else NULL,
    callable = callable
  )
}

rrp_provider_test_expect <- function(callback, code) {
  condition <- tryCatch({
    callback()
    NULL
  }, error = identity)
  stopifnot(
    inherits(condition, "rrp_runtime_error"),
    identical(condition$code, code),
    identical(condition$call, NULL),
    is.character(condition$message), length(condition$message) == 1L,
    nchar(condition$message, type = "bytes") <= 160L,
    !grepl("episode-001|fictional|2026-|secret|/", condition$message)
  )
  invisible(condition)
}

evidence <- new.env(parent = emptyenv())
evidence$calls <- 0L
evidence$request <- NULL
provider <- rrp_provider_test_provider(function(request) {
  evidence$calls <- evidence$calls + 1L
  evidence$request <- request
  list(
    request_id = request$request_id,
    status = "success",
    estimate_value = 0.25,
    failure_code = NULL
  )
})
state <- rrp_provider_test_state()
state_before <- unserialize(serialize(state, NULL))
estimate <- rrp_execute_risk_provider(
  state, provider, rrp_provider_test_context()
)
request_fields <- c(
  "request_contract_id", "request_contract_version", "request_id",
  "target_id", "target_version", "state_contract_id",
  "state_contract_version", "state_id", "bundle_instance_id", "project_id",
  "project_version", "episode_id", "as_of_time", "discharge_time",
  "target_interval_start", "target_interval_end", "target_interval_boundary",
  "elapsed_seconds_since_discharge", "remaining_seconds_through_w30"
)
estimate_fields <- c(
  "estimate_contract_id", "estimate_contract_version",
  "request_contract_id", "request_contract_version", "request_id",
  "state_contract_id", "state_contract_version", "state_id", "target_id",
  "target_version", "product_id", "development_version",
  "bundle_instance_id", "project_id", "project_version", "episode_id",
  "as_of_time", "target_interval_start", "target_interval_end",
  "target_interval_boundary", "provider_id", "provider_version",
  "implementation_id", "implementation_version", "model_id",
  "model_version", "output_type", "estimate_value"
)
stopifnot(
  identical(evidence$calls, 1L), identical(state, state_before),
  identical(class(evidence$request), c("rrp_risk_request", "list")),
  identical(names(evidence$request), request_fields),
  grepl("^rrp[.]request[.][0-9a-f]{16}$", evidence$request$request_id),
  identical(evidence$request$target_interval_start, state$as_of_time),
  identical(evidence$request$target_interval_end, state$target_window_end),
  identical(evidence$request$target_interval_boundary, "(start,end]"),
  identical(class(estimate), c("rrp_risk_estimate", "list")),
  identical(names(estimate), estimate_fields),
  identical(estimate$request_id, evidence$request$request_id),
  identical(estimate$provider_id, provider$component_id),
  is.null(estimate$model_id), is.null(estimate$model_version),
  identical(estimate$output_type, "probability"),
  identical(estimate$estimate_value, 0.25),
  is.double(estimate$estimate_value), is.null(attributes(estimate$estimate_value)),
  !any(c(
    "patient_id", "source", "bundle", "project_root", "credentials",
    "features", "provider_id", "model_id"
  ) %in% names(evidence$request))
)

second <- rrp_execute_risk_provider(
  state, rrp_provider_test_provider(function(request) list(
    request_id = request$request_id, status = "success",
    estimate_value = 0.25, failure_code = NULL
  )), rrp_provider_test_context()
)
stopifnot(identical(estimate, second))
evidence$request$episode_id <- "changed"
stopifnot(identical(estimate$episode_id, "episode-001"))

modeled <- rrp_execute_risk_provider(
  state,
  rrp_provider_test_provider(function(request) list(
    request_id = request$request_id, status = "success",
    estimate_value = 0.5, failure_code = NULL
  ), model = TRUE),
  rrp_provider_test_context()
)
stopifnot(
  identical(modeled$model_id, "fictional.model"),
  identical(modeled$model_version, "2.0.0")
)

for (boundary in c(0, 1)) {
  local_boundary <- boundary
  bounded <- rrp_execute_risk_provider(
    state,
    rrp_provider_test_provider(function(request) list(
      request_id = request$request_id, status = "success",
      estimate_value = local_boundary, failure_code = NULL
    )),
    rrp_provider_test_context()
  )
  stopifnot(identical(bounded$estimate_value, local_boundary))
}

for (failure in c(
  "provider_unavailable", "provider_input_unavailable",
  "provider_calculation_failed"
)) {
  local_failure <- failure
  rrp_provider_test_expect(function() rrp_execute_risk_provider(
    state, rrp_provider_test_provider(function(request) list(
      request_id = request$request_id, status = "failure",
      estimate_value = NULL, failure_code = local_failure
    )), rrp_provider_test_context()
  ), failure)
}

incompatible <- provider
incompatible$target_version <- "9.9.9"
rrp_provider_test_expect(function() rrp_execute_risk_provider(
  state, incompatible, rrp_provider_test_context()
), "provider_incompatible")
bad_model <- provider
bad_model$model_id <- "fictional.model"
rrp_provider_test_expect(function() rrp_execute_risk_provider(
  state, bad_model, rrp_provider_test_context()
), "provider_incompatible")
bad_state <- state
bad_state$state_id <- "rrp.state.0000000000000000"
rrp_provider_test_expect(function() rrp_execute_risk_provider(
  bad_state, provider, rrp_provider_test_context()
), "provider_incompatible")

rrp_provider_test_expect(function() rrp_execute_risk_provider(
  state, rrp_provider_test_provider(function(request) {
    stop("secret raw provider failure", call. = FALSE)
  }), rrp_provider_test_context()
), "provider_execution_failed")
rrp_provider_test_expect(function() rrp_execute_risk_provider(
  state, rrp_provider_test_provider(function(request) list(
    request_id = "other.request", status = "success",
    estimate_value = 0.5, failure_code = NULL
  )), rrp_provider_test_context()
), "provider_result_identity_mismatch")

invalid_results <- list(
  function(request) list(
    request_id = request$request_id, status = "other",
    estimate_value = 0.5, failure_code = NULL
  ),
  function(request) c(list(
    request_id = request$request_id, status = "success",
    estimate_value = 0.5, failure_code = NULL
  ), list(extra = "not-allowed")),
  function(request) structure(list(
    request_id = request$request_id, status = "success",
    estimate_value = 0.5, failure_code = NULL
  ), class = "unsafe"),
  function(request) list(
    request_id = request$request_id, status = "failure",
    estimate_value = 0.5, failure_code = "provider_unavailable"
  )
)
for (callable in invalid_results) {
  rrp_provider_test_expect(function() rrp_execute_risk_provider(
    state, rrp_provider_test_provider(callable), rrp_provider_test_context()
  ), "invalid_provider_result")
}

for (value in list(
  -0.01, 1.01, NaN, Inf, NA_real_, 1L, TRUE, "0.5", c(0.2, 0.3),
  structure(0.5, unit = "probability")
)) {
  local_value <- value
  rrp_provider_test_expect(function() rrp_execute_risk_provider(
    state, rrp_provider_test_provider(function(request) list(
      request_id = request$request_id, status = "success",
      estimate_value = local_value, failure_code = NULL
    )), rrp_provider_test_context()
  ), "invalid_estimate")
}

cat("rrpruntime risk-provider tests passed\n")
