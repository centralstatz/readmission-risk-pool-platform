# Repository orchestration for provider contract loading and reference execution.
# The rrpruntime package receives parsed documents and trusted adapters; it
# never discovers these paths itself.

rrp_provider_contract_paths <- function(repository_root) {
  c(
    provider_specification = file.path(
      repository_root, "contracts", "runtime", "provider-specification.yml"
    ),
    execution_adapter = file.path(
      repository_root, "contracts", "runtime", "provider-execution-adapter.yml"
    ),
    execution_result = file.path(
      repository_root, "contracts", "runtime", "provider-execution-result.yml"
    ),
    estimate = file.path(
      repository_root, "contracts", "runtime", "readmission-risk-estimate.yml"
    )
  )
}

rrp_read_provider_contracts <- function(repository_root) {
  paths <- rrp_provider_contract_paths(repository_root)
  documents <- lapply(paths, function(path) {
    parsed <- rrp_parse_yaml_specification(path)
    if (!is.null(parsed$error)) {
      stop("Could not read provider contract: ", parsed$error, call. = FALSE)
    }
    parsed$document
  })
  names(documents) <- names(paths)
  documents
}

rrp_read_reference_provider_specification <- function(repository_root) {
  path <- file.path(
    repository_root, "contracts", "runtime", "providers",
    "transparent-reference-provider.yml"
  )
  parsed <- rrp_parse_yaml_specification(path)
  if (!is.null(parsed$error)) {
    stop("Could not read reference provider specification: ", parsed$error, call. = FALSE)
  }
  parsed$document
}

rrp_reference_provider_registry <- function(repository_root) {
  contracts <- rrp_read_provider_contracts(repository_root)
  specification <- rrp_read_reference_provider_specification(repository_root)
  registry <- rrpruntime::new_provider_registry()
  rrpruntime::register_provider(
    registry,
    specification,
    rrpruntime::reference_provider_adapter,
    contracts$provider_specification
  )
  list(
    registry = registry,
    contracts = contracts,
    specification = specification
  )
}

rrp_execute_reference_estimation <- function(
  runtime_result,
  repository_root,
  provider_execution_run_id
) {
  registered <- rrp_reference_provider_registry(repository_root)
  runtime_contracts <- rrp_read_runtime_contracts(repository_root)
  states <- runtime_result$states$records
  state_by_id <- stats::setNames(
    states,
    vapply(states, `[[`, character(1), "state_id")
  )
  requests <- runtime_result$estimand_requests$records
  execution_results <- lapply(requests, function(request) {
    state <- state_by_id[[request$state_reference$state_id]]
    rrpruntime::execute_provider(
      registered$registry,
      registered$specification$provider_id,
      registered$specification$provider_version,
      request,
      state,
      provider_execution_run_id,
      runtime_contracts,
      registered$contracts
    )
  })
  estimates <- lapply(Filter(function(result) {
    identical(result$execution_status, "successful_estimate")
  }, execution_results), `[[`, "estimate_record")
  structure(list(
    runtime_result = runtime_result,
    provider_specification = registered$specification,
    provider_execution_run_id = provider_execution_run_id,
    execution_results = execution_results,
    estimates = estimates
  ), class = "rrp_estimation_operation_result")
}

rrp_estimation_result_summary <- function(result) {
  statuses <- vapply(
    result$execution_results, `[[`, character(1), "execution_status"
  )
  levels <- c(
    "successful_estimate", "unsupported", "missing_required_input",
    "execution_failure", "invalid_output"
  )
  counts <- as.list(table(factor(statuses, levels = levels)))
  list(
    eligible_episodes = length(result$runtime_result$states$records),
    estimand_requests = length(result$runtime_result$estimand_requests$records),
    successful_estimates = length(result$estimates),
    execution_statuses = counts
  )
}

