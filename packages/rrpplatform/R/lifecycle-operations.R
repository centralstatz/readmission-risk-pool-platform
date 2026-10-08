rrp_lifecycle_failure <- function(condition, operation_id, message, code = NULL) {
  condition_code <- if (!is.null(code)) code else condition$code
  if (!rrp_diagnostic_code_is_valid(condition_code)) {
    condition_code <- "operation_failed"
  }
  rrp_new_operation_result(
    operation_id, "failure", NULL,
    list(rrp_new_diagnostic(condition_code, "error", message))
  )
}

rrp_lifecycle_check <- function(check_id, status, recovery_code = "none") {
  list(
    check_id = check_id,
    status = status,
    recovery_code = recovery_code
  )
}

rrp_project_status_value <- function(context) {
  list(
    project_id = unname(context$manifest[["Project-ID"]]),
    project_version = unname(context$manifest[["Project-Version"]]),
    project_contract_id = unname(context$manifest[["Project-Contract-ID"]]),
    project_contract_version = unname(
      context$manifest[["Project-Contract-Version"]]
    ),
    supported_rrp_api_version = unname(
      context$manifest[["Supported-RRP-API-Version"]]
    ),
    canonical_profile_id = unname(
      context$manifest[["Canonical-Profile-ID"]]
    ),
    canonical_profile_version = unname(
      context$manifest[["Canonical-Profile-Version"]]
    ),
    producer_id = unname(context$manifest[["Producer-ID"]]),
    producer_version = unname(context$manifest[["Producer-Version"]]),
    provider_id = unname(context$manifest[["Provider-ID"]]),
    provider_version = unname(context$manifest[["Provider-Version"]]),
    readiness = "ready",
    extension_library_status = if (dir.exists(context$extension_library_path)) {
      "available"
    } else {
      "not_initialized"
    },
    state_status = "not_initialized",
    history_status = "not_initialized",
    product_status = "absent",
    product_freshness = "not_available",
    application_status = "blocked_expected",
    product_set_id = NULL,
    materialization_id = NULL,
    source_operation_run_id = NULL,
    source_history_cutoff = NULL,
    checks = list()
  )
}

rrp_project_status_validate_value <- function(value) {
  contract <- rrp_project_lifecycle_result_contract_expected()
  fields <- strsplit(contract[["Value-Fields"]], ",", fixed = TRUE)[[1L]]
  valid <- is.list(value) && identical(names(value), fields) &&
    value$readiness %in% strsplit(
      contract[["Readiness-Values"]], ",", fixed = TRUE
    )[[1L]] &&
    value$extension_library_status %in% strsplit(
      contract[["Extension-Library-Status-Values"]], ",", fixed = TRUE
    )[[1L]] &&
    value$state_status %in% strsplit(
      contract[["State-Status-Values"]], ",", fixed = TRUE
    )[[1L]] &&
    value$history_status %in% strsplit(
      contract[["History-Status-Values"]], ",", fixed = TRUE
    )[[1L]] &&
    value$product_status %in% strsplit(
      contract[["Product-Status-Values"]], ",", fixed = TRUE
    )[[1L]] &&
    value$product_freshness %in% strsplit(
      contract[["Product-Freshness-Values"]], ",", fixed = TRUE
    )[[1L]] &&
    value$application_status %in% strsplit(
      contract[["Application-Status-Values"]], ",", fixed = TRUE
    )[[1L]] && is.list(value$checks) &&
    all(vapply(value$checks, function(check) {
      is.list(check) && identical(
        names(check), c("check_id", "status", "recovery_code")
      ) && rrp_diagnostic_code_is_valid(check$check_id) &&
        check$status %in% c("pass", "warning", "failure") &&
        rrp_diagnostic_code_is_valid(check$recovery_code)
    }, logical(1L)))
  if (!valid) stop("Invalid internal project lifecycle result.", call. = FALSE)
  invisible(value)
}

rrp_project_status_success <- function(
  software_catalog, project_root, expected_operation_run_id, history_cutoff
) {
  paired <- (is.null(expected_operation_run_id) && is.null(history_cutoff)) ||
    (rrp_resource_scalar_string(expected_operation_run_id) &&
      rrp_resource_scalar_string(history_cutoff))
  if (!paired) rrp_materialization_abort("product_access_failed")

  rrp_lifecycle_contracts(software_catalog)
  context <- rrp_load_project(software_catalog, project_root)
  value <- rrp_project_status_value(context)
  value$checks <- list(
    rrp_lifecycle_check("project_contract", "pass"),
    rrp_lifecycle_check("extension_library", "pass")
  )
  diagnostics <- list()

  if (!rrp_state_path_exists(context$state_path)) {
    value$readiness <- "ready_with_warnings"
    value$checks <- c(value$checks, list(
      rrp_lifecycle_check(
        "project_state", "warning", "initialize_project_state"
      ),
      rrp_lifecycle_check(
        "operational_history", "warning", "initialize_project_state"
      ),
      rrp_lifecycle_check(
        "logical_products", "warning", "materialize_products"
      ),
      rrp_lifecycle_check(
        "supplied_application", "warning", "materialize_products"
      )
    ))
    diagnostics <- list(rrp_new_diagnostic(
      "project_state_not_initialized", "warning",
      "Project state has not been initialized."
    ))
  } else {
    state_contracts <- rrp_state_contracts(software_catalog)
    rrp_state_inspect_root(context$state_path, context, state_contracts)
    value$state_status <- "compatible"
    value$history_status <- "compatible"
    value$checks <- c(value$checks, list(
      rrp_lifecycle_check("project_state", "pass"),
      rrp_lifecycle_check("operational_history", "pass")
    ))
    materialization <- rrp_product_materialization_contract(software_catalog)
    store <- file.path(
      context$state_path, materialization[["Store-Directory"]]
    )
    if (!rrp_state_path_exists(store)) {
      value$readiness <- "ready_with_warnings"
      value$checks <- c(value$checks, list(
        rrp_lifecycle_check(
          "logical_products", "warning", "materialize_products"
        ),
        rrp_lifecycle_check(
          "supplied_application", "warning", "materialize_products"
        )
      ))
      diagnostics <- list(rrp_new_diagnostic(
        "logical_products_absent", "warning",
        "Logical products have not been materialized."
      ))
    } else {
      opened <- rrp_open_product_access(
        software_catalog, project_root,
        expected_operation_run_id = expected_operation_run_id,
        history_cutoff = history_cutoff
      )
      if (!rrp_operation_succeeded(opened)) {
        condition <- structure(
          list(message = "Product access failed.", call = NULL,
            code = opened$diagnostics[[1L]]$code),
          class = c("rrp_materialization_error", "error", "condition")
        )
        stop(condition)
      }
      value$product_status <- "valid"
      value$product_freshness <- gsub(
        "-", "_", opened$value$freshness$status, fixed = TRUE
      )
      value$application_status <- "ready"
      value$product_set_id <- opened$value$product_set_id
      value$materialization_id <- opened$value$materialization_id
      value$source_operation_run_id <- opened$value$source_operation_run_id
      value$source_history_cutoff <- opened$value$source_history_cutoff
      check_status <- if (identical(value$product_freshness, "stale")) {
        "warning"
      } else {
        "pass"
      }
      value$checks <- c(value$checks, list(
        rrp_lifecycle_check(
          "logical_products", check_status,
          if (identical(check_status, "warning")) {
            "materialize_products"
          } else {
            "none"
          }
        ),
        rrp_lifecycle_check("supplied_application", "pass")
      ))
      if (identical(value$product_freshness, "stale")) {
        value$readiness <- "ready_with_warnings"
        diagnostics <- list(rrp_new_diagnostic(
          "logical_products_stale", "warning",
          "Logical products are valid but stale for the requested context."
        ))
      }
    }
  }
  rrp_project_status_validate_value(value)
  rrp_new_operation_result("rrp.project-status", "success", value, diagnostics)
}

#' Diagnose one explicit project's lifecycle state
#'
#' Compose existing project, state, history, product, and application evidence
#' into a bounded read-only status. Producer and provider callables are never
#' invoked, and freshness is evaluated only when both comparison inputs are
#' supplied.
#'
#' @param software_catalog A validated explicit-root software resource catalog.
#' @param project_root One explicit existing independent-project root.
#' @param expected_operation_run_id Optional exact source operation identity.
#' @param history_cutoff Optional paired RFC 3339 UTC history cutoff.
#' @return A common RRP operation result with privacy-safe lifecycle evidence.
#' @export
rrp_project_status <- function(
  software_catalog, project_root, expected_operation_run_id = NULL,
  history_cutoff = NULL
) tryCatch(
  rrp_project_status_success(
    software_catalog, project_root, expected_operation_run_id, history_cutoff
  ),
  rrp_resource_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.project-status", "Project lifecycle diagnosis failed."
  ),
  rrp_project_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.project-status", "Project lifecycle diagnosis failed."
  ),
  rrp_state_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.project-status", "Project lifecycle diagnosis failed."
  ),
  rrp_history_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.project-status", "Project lifecycle diagnosis failed."
  ),
  rrp_materialization_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.project-status", "Project lifecycle diagnosis failed."
  ),
  error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.project-status", "Project lifecycle diagnosis failed."
  )
)

rrp_build_and_materialize <- function(
  software_catalog, project_root, operation_run_id, history_cutoff,
  failure_stage = NULL
) {
  built <- rrp_build_product_set(
    software_catalog, project_root, operation_run_id, history_cutoff
  )
  if (!rrp_operation_succeeded(built)) {
    condition <- structure(
      list(message = "Logical product construction failed.", call = NULL,
        code = built$diagnostics[[1L]]$code),
      class = c("rrp_product_error", "error", "condition")
    )
    stop(condition)
  }
  product_set <- built$value
  materialized <- rrp_product_materialize(
    software_catalog, project_root, rrp_product_copy(product_set),
    failure_stage = failure_stage
  )
  value <- c(list(
    product_set_id = product_set$product_set_id,
    source_operation_run_id = product_set$source_operation_run_id,
    source_history_cutoff = product_set$source_history_cutoff
  ), materialized)
  value <- value[c(
    "product_set_id", "source_operation_run_id", "source_history_cutoff",
    "materialization_id", "adapter_id", "adapter_version",
    "physical_format_id", "physical_format_version", "reused"
  )]
  rrp_new_operation_result(
    "rrp.build-and-materialize-products", "success", value, list()
  )
}

#' Build and atomically materialize one logical product set
#'
#' Compose the accepted logical builder and materializer with the same explicit
#' source operation and history cutoff required by their individual APIs.
#'
#' @param software_catalog A validated explicit-root software resource catalog.
#' @param project_root One explicit initialized independent-project root.
#' @param operation_run_id One exact complete governed source operation.
#' @param history_cutoff One explicit RFC 3339 UTC history cutoff.
#' @return A common RRP operation result with bounded publication evidence.
#' @export
rrp_build_and_materialize_products <- function(
  software_catalog, project_root, operation_run_id, history_cutoff
) tryCatch(
  rrp_build_and_materialize(
    software_catalog, project_root, operation_run_id, history_cutoff
  ),
  rrp_product_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.build-and-materialize-products",
    "Product build and materialization failed."
  ),
  rrp_materialization_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.build-and-materialize-products",
    "Product build and materialization failed."
  ),
  rrp_resource_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.build-and-materialize-products",
    "Product build and materialization failed."
  ),
  rrp_project_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.build-and-materialize-products",
    "Product build and materialization failed."
  ),
  rrp_state_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.build-and-materialize-products",
    "Product build and materialization failed."
  ),
  rrp_history_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.build-and-materialize-products",
    "Product build and materialization failed."
  ),
  error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.build-and-materialize-products",
    "Product build and materialization failed."
  )
)

rrp_fictional_reference_identity <- function(context) {
  identical(context$manifest[["Project-ID"]], "fictional-reference-hospital") &&
    identical(context$manifest[["Project-Version"]], "1.0.0") &&
    identical(
      context$manifest[["Canonical-Profile-ID"]],
      "rrp.canonical-profile.readmission"
    ) &&
    identical(context$manifest[["Canonical-Profile-Version"]], "0.1.0") &&
    identical(
      context$manifest[["Producer-ID"]],
      "fictional-reference-hospital.producer"
    ) && identical(context$manifest[["Producer-Version"]], "1.0.0") &&
    identical(
      context$manifest[["Provider-ID"]],
      "fictional-reference-hospital.provider"
    ) && identical(context$manifest[["Provider-Version"]], "1.0.0")
}

rrp_prepare_fictional_source_success <- function(software_catalog, project_root) {
  context <- rrp_load_project(software_catalog, project_root)
  if (!rrp_fictional_reference_identity(context)) {
    condition <- structure(
      list(message = "The project is not the supplied fictional project.",
        call = NULL, code = "fictional_project_required"),
      class = c("rrp_project_error", "error", "condition")
    )
    stop(condition)
  }
  resource <- rrp_resource_path(
    software_catalog, "rrp.template.fictional-project-source-generator"
  )
  environment <- new.env(parent = baseenv())
  tryCatch(
    sys.source(resource, envir = environment, chdir = FALSE, keep.source = FALSE),
    error = function(condition) stop(structure(
      list(message = "Installed fictional source generator is invalid.",
        call = NULL, code = "fictional_source_generator_invalid"),
      class = c("rrp_resource_error", "error", "condition")
    ))
  )
  if (!identical(ls(environment, all.names = TRUE),
      "rrp_generate_fictional_source")) {
    rrp_resource_abort(
      "fictional_source_generator_invalid",
      "Installed fictional source generator is invalid."
    )
  }
  generator <- get(
    "rrp_generate_fictional_source", envir = environment, inherits = FALSE
  )
  generated <- file.path(context$project_root, "source", "generated")
  reused <- rrp_state_path_exists(generated)
  paths <- tryCatch(
    generator(context$project_root),
    error = function(condition) stop(structure(
      list(message = "Fictional source preparation failed.", call = NULL,
        code = if (rrp_state_path_exists(generated)) {
          "fictional_source_conflict"
        } else {
          "fictional_source_preparation_failed"
        }),
      class = c("rrp_project_error", "error", "condition")
    ))
  )
  value <- list(
    project_id = "fictional-reference-hospital",
    dataset_id = "fictional.reference.source",
    dataset_version = "1.0.0",
    classification = "fictional_nonclinical",
    source_status = "realized",
    reused = reused,
    created_paths = sort(
      file.path("source", "generated", paths), method = "radix"
    )
  )
  rrp_new_operation_result(
    "rrp.prepare-fictional-source", "success", value, list()
  )
}

#' Prepare the supplied fictional project's deterministic source
#'
#' Execute the cataloged installed fictional generator for only the exact
#' supplied reference-project identity. This is not a general ingestion API.
#'
#' @param software_catalog A validated explicit-root software resource catalog.
#' @param project_root One explicit supplied fictional-project root.
#' @return A common RRP operation result with bounded fictional-source evidence.
#' @export
rrp_prepare_fictional_source <- function(software_catalog, project_root) {
  tryCatch(
    rrp_prepare_fictional_source_success(software_catalog, project_root),
    rrp_resource_error = function(condition) rrp_lifecycle_failure(
      condition, "rrp.prepare-fictional-source",
      "Fictional source preparation failed."
    ),
    rrp_project_error = function(condition) rrp_lifecycle_failure(
      condition, "rrp.prepare-fictional-source",
      "Fictional source preparation failed."
    ),
    error = function(condition) rrp_lifecycle_failure(
      condition, "rrp.prepare-fictional-source",
      "Fictional source preparation failed."
    )
  )
}
