# Repository orchestration around the implementation-neutral runtime package.
# File/specification loading and representation adaptation intentionally remain
# outside rrpruntime.

rrp_runtime_contract_paths <- function(repository_root) {
  c(
    eligibility_result = file.path(
      repository_root, "contracts", "runtime", "eligibility-result.yml"
    ),
    episode_state = file.path(
      repository_root, "contracts", "runtime", "episode-state.yml"
    ),
    estimand = file.path(
      repository_root, "contracts", "runtime", "estimands",
      "readmission-next-day-conditional-hazard.yml"
    ),
    estimand_request = file.path(
      repository_root, "contracts", "runtime", "estimand-request.yml"
    )
  )
}

rrp_read_runtime_contracts <- function(repository_root) {
  paths <- rrp_runtime_contract_paths(repository_root)
  documents <- lapply(paths, function(path) {
    parsed <- rrp_parse_yaml_specification(path)
    if (!is.null(parsed$error)) {
      stop("Could not read runtime contract: ", parsed$error, call. = FALSE)
    }
    parsed$document
  })
  names(documents) <- names(paths)
  documents
}

rrp_install_runtime_package <- function(repository_root) {
  library_root <- tempfile("rrp-runtime-library-")
  dir.create(library_root, recursive = TRUE)
  output <- tempfile("rrp-runtime-install-", fileext = ".log")
  command <- file.path(R.home("bin"), "R")
  status <- system2(
    command,
    c(
      "CMD", "INSTALL", "--no-byte-compile", "--no-staged-install",
      paste0("--library=", shQuote(library_root)),
      shQuote(file.path(repository_root, "runtime"))
    ),
    stdout = output,
    stderr = output
  )
  if (!identical(status, 0L)) {
    detail <- if (file.exists(output)) {
      paste(tail(readLines(output, warn = FALSE), 20L), collapse = " | ")
    } else {
      "no installer output"
    }
    unlink(c(library_root, output), recursive = TRUE, force = TRUE)
    stop("Could not install rrpruntime: ", detail, call. = FALSE)
  }
  previous <- .libPaths()
  .libPaths(c(library_root, previous))
  loadNamespace("rrpruntime", lib.loc = library_root)
  list(library = library_root, output = output, previous_lib_paths = previous)
}

rrp_unload_runtime_package <- function(installed) {
  if ("rrpruntime" %in% loadedNamespaces()) unloadNamespace("rrpruntime")
  .libPaths(installed$previous_lib_paths)
  unlink(c(installed$library, installed$output), recursive = TRUE, force = TRUE)
  invisible(NULL)
}

rrp_runtime_payload_records <- function(bundle, domain_id) {
  payload <- rrp_clinical_payload(bundle, domain_id)
  if (is.null(payload) || is.null(payload$records)) list() else payload$records
}

rrp_runtime_input_from_admitted_bundle <- function(bundle, admission) {
  if (!rrp_conforms(admission)) {
    stop("Canonical bundle must pass generic admission before runtime.", call. = FALSE)
  }
  rrpruntime::new_admitted_canonical_input(
    bundle_instance_id = bundle$bundle_instance_id,
    bundle_as_of_time = bundle$run_context$as_of_time,
    canonical_run_id = bundle$run_context$run_id,
    profile_specification = bundle$profile_specification,
    capabilities = bundle$capabilities,
    discharge_episodes = rrp_runtime_payload_records(bundle, "discharge_episode"),
    baseline_risk = rrp_runtime_payload_records(bundle, "baseline_risk"),
    episode_events = rrp_runtime_payload_records(bundle, "episode_event"),
    provenance_references = bundle$provenance_references,
    admission_reference = list(
      overall_status = admission$overall_status,
      evaluated_against = admission$evaluated_against,
      bundle_instance_id = bundle$bundle_instance_id
    )
  )
}

rrp_run_runtime_from_bundle <- function(
  bundle,
  repository_root,
  runtime_run_id
) {
  admission <- rrp_validate_clinical_bundle_instance(bundle, repository_root)
  if (!rrp_conforms(admission)) {
    stop("Canonical admission failed; runtime was not invoked.", call. = FALSE)
  }
  input <- rrp_runtime_input_from_admitted_bundle(bundle, admission)
  contracts <- rrp_read_runtime_contracts(repository_root)
  runtime_context <- list(
    run_id = runtime_run_id,
    as_of_time = bundle$run_context$as_of_time
  )
  input_conformance <- rrpruntime::validate_runtime_input(input)
  contract_conformance <- rrpruntime::validate_runtime_contracts(contracts)
  if (!rrpruntime::runtime_conforms(input_conformance) ||
      !rrpruntime::runtime_conforms(contract_conformance)) {
    stop("Runtime input or contract conformance failed.", call. = FALSE)
  }
  eligibility <- rrpruntime::evaluate_episode_eligibility(
    input, runtime_context, contracts
  )
  states <- rrpruntime::build_episode_states(
    input, eligibility, runtime_context, contracts
  )
  requests <- rrpruntime::build_estimand_requests(
    states, eligibility, runtime_context, contracts
  )
  structure(list(
    canonical_admission = admission,
    runtime_input_conformance = input_conformance,
    runtime_contract_conformance = contract_conformance,
    runtime_context = runtime_context,
    eligibility = eligibility,
    states = states,
    estimand_requests = requests
  ), class = "rrp_runtime_operation_result")
}

rrp_runtime_result_summary <- function(result) {
  reasons <- vapply(
    result$eligibility$records, `[[`, character(1), "eligibility_reason"
  )
  reason_counts <- as.list(table(factor(
    reasons,
    levels = c(
      "eligible", "before_discharge", "followup_complete",
      "already_readmitted", "died", "insufficient_required_input",
      "unsupported_required_capability"
    )
  )))
  reason_counts <- reason_counts[vapply(reason_counts, function(value) value > 0L, logical(1))]
  list(
    episodes_evaluated = length(result$eligibility$records),
    states_created = length(result$states$records),
    estimand_requests_created = length(result$estimand_requests$records),
    eligibility_reasons = reason_counts
  )
}
