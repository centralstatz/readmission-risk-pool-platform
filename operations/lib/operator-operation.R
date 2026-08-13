# Stable human-operation support for local initialization and preflight.
# Doctor is read-only apart from temporary checks that are removed immediately.

rrp_operator_result_row <- function(
  check_id,
  category,
  status,
  message,
  recovery = NA_character_
) {
  data.frame(
    check_id = check_id,
    category = category,
    status = status,
    message = message,
    recovery = recovery,
    stringsAsFactors = FALSE
  )
}

rrp_operator_bind_results <- function(results) {
  if (length(results) == 0L) return(data.frame(
    check_id = character(), category = character(), status = character(),
    message = character(), recovery = character(), stringsAsFactors = FALSE
  ))
  do.call(rbind, results)
}

rrp_operator_overall_status <- function(checks) {
  if (any(checks$status == "failure")) return("blocked")
  if (any(checks$status == "warning")) return("ready_with_warnings")
  "ready"
}

rrp_operator_path <- function(repository_root, value) {
  if (grepl("^(/|[A-Za-z]:[/\\\\])", value)) {
    normalizePath(value, winslash = "/", mustWork = FALSE)
  } else {
    normalizePath(file.path(repository_root, value), winslash = "/", mustWork = FALSE)
  }
}

rrp_operator_default_paths <- function(repository_root) {
  configuration <- rrp_read_duckdb_configuration(repository_root)
  list(
    database = rrp_operator_path(repository_root, configuration$database_path),
    products = file.path(repository_root, "build", "reference-products")
  )
}

rrp_operator_check_writable <- function(path) {
  target <- path
  while (!dir.exists(target) && !identical(dirname(target), target)) {
    target <- dirname(target)
  }
  if (!dir.exists(target) || nzchar(Sys.readlink(target))) return(FALSE)
  probe <- tempfile(".rrp-write-check-", tmpdir = target)
  created <- file.create(probe)
  if (created) unlink(probe, force = TRUE)
  isTRUE(created)
}

rrp_initialize_local_platform <- function(repository_root, build_root) {
  required <- c("renv.lock", "renv/activate.R", "operations/doctor.R")
  missing <- required[!file.exists(file.path(repository_root, required))]
  if (length(missing) > 0L) stop(
    "Required installation files are missing: ", paste(missing, collapse = ", "),
    call. = FALSE
  )
  dependencies <- c("renv", "yaml", "DBI", "duckdb", "shiny")
  unavailable <- dependencies[!vapply(
    dependencies, requireNamespace, logical(1), quietly = TRUE
  )]
  if (length(unavailable) > 0L) stop(
    "Required packages are unavailable: ", paste(unavailable, collapse = ", "),
    ". Run Rscript -e 'renv::restore()' and retry.", call. = FALSE
  )
  if (file.exists(build_root) && !dir.exists(build_root)) stop(
    "Local build root exists but is not a directory.", call. = FALSE
  )
  if (dir.exists(build_root) && nzchar(Sys.readlink(build_root))) stop(
    "Local build root must not be a symbolic link.", call. = FALSE
  )
  if (!dir.exists(build_root) && !dir.create(build_root, recursive = TRUE)) stop(
    "Could not create the ignored local build root.", call. = FALSE
  )
  if (!rrp_operator_check_writable(build_root)) stop(
    "Local build root is not writable.", call. = FALSE
  )
  list(
    operation_id = "platform.initialize-local",
    status = "succeeded",
    build_root = normalizePath(build_root, winslash = "/", mustWork = TRUE),
    created_history = FALSE,
    created_products = FALSE
  )
}

rrp_doctor_required_files <- function() c(
  "renv.lock", "runtime/DESCRIPTION",
  "implementations/synthetic-reference/config/test.yml",
  "implementations/persistence/duckdb/adapter.yml",
  "implementations/persistence/duckdb/config/reference.yml",
  "implementations/products/yaml/adapter.yml",
  "contracts/products/initial-risk-product-set.yml",
  "app/app.R"
)

rrp_doctor_repository_checks <- function(repository_root, package_available) {
  results <- list()
  supported_r <- getRversion() >= "4.1.0"
  results[[length(results) + 1L]] <- rrp_operator_result_row(
    "r_version", "environment", if (supported_r) "pass" else "failure",
    paste0("R ", getRversion(), if (supported_r) " is supported." else " is unsupported."),
    if (supported_r) NA_character_ else "Install R 4.1.0 or newer."
  )
  packages <- c("renv", "yaml", "DBI", "duckdb", "shiny")
  for (package in packages) {
    available <- isTRUE(package_available(package))
    version <- if (available) as.character(utils::packageVersion(package)) else "unavailable"
    results[[length(results) + 1L]] <- rrp_operator_result_row(
      paste0("dependency_", package), "dependencies",
      if (available) "pass" else "failure",
      paste0(package, ": ", version),
      if (available) NA_character_ else "Run Rscript -e 'renv::restore()'."
    )
  }
  required <- rrp_doctor_required_files()
  missing <- required[!file.exists(file.path(repository_root, required))]
  results[[length(results) + 1L]] <- rrp_operator_result_row(
    "required_repository_files", "installation",
    if (length(missing) == 0L) "pass" else "failure",
    if (length(missing) == 0L) {
      paste(length(required), "required reference files are present.")
    } else paste("Missing:", paste(missing, collapse = ", ")),
    if (length(missing) == 0L) NA_character_ else "Restore the maintained installation files."
  )
  results
}

rrp_doctor_history_check <- function(repository_root, database_path) {
  if (!file.exists(database_path)) return(list(
    check = rrp_operator_result_row(
      "operational_history", "lifecycle", "warning",
      "Operational history is absent; this is expected before the first run.",
      "Run Rscript operations/run-platform.R --profile reference --scale test."
    ),
    state = list(status = "absent", latest_runtime_run_id = NULL)
  ))
  if (nzchar(Sys.readlink(database_path))) return(list(
    check = rrp_operator_result_row(
      "operational_history", "lifecycle", "failure",
      "Operational history path is a symbolic link.",
      "Select a regular local DuckDB path and preserve the linked file for review."
    ),
    state = list(status = "invalid", latest_runtime_run_id = NULL)
  ))
  history_contracts <- rrp_read_history_contracts(repository_root)
  opened <- tryCatch(
    rrp_open_duckdb_persistence(database_path, history_contracts, read_only = TRUE),
    error = function(condition) condition
  )
  if (inherits(opened, "condition")) return(list(
    check = rrp_operator_result_row(
      "operational_history", "lifecycle", "failure",
      paste("Operational history is unavailable:", conditionMessage(opened)),
      "Preserve the database and use compatible code or a validated backup."
    ),
    state = list(status = "invalid", latest_runtime_run_id = NULL)
  ))
  on.exit(rrp_close_duckdb_persistence(opened), add = TRUE)
  summary <- rrp_duckdb_history_lifecycle(opened)
  status <- if (summary$terminal_run_count > 0L) "available" else "initialized"
  list(
    check = rrp_operator_result_row(
      "operational_history", "lifecycle", "pass",
      paste0("Operational history is ", status, "; terminal runs: ",
        summary$terminal_run_count, ".")
    ),
    state = list(status = status, latest_runtime_run_id = summary$latest_runtime_run_id)
  )
}

rrp_doctor_product_check <- function(repository_root, product_store) {
  pointer <- file.path(product_store, "CURRENT.yml")
  if (!dir.exists(product_store) && !file.exists(product_store)) return(list(
    check = rrp_operator_result_row(
      "product_bundle", "lifecycle", "warning",
      "Current product bundle is absent; this is expected before materialization.",
      "After a run, materialize with Rscript operations/build-reference-products.R --scale test --materialize."
    ),
    state = list(status = "absent", source_as_of_time = NULL), access = NULL
  ))
  if (nzchar(Sys.readlink(product_store)) || nzchar(Sys.readlink(pointer))) return(list(
    check = rrp_operator_result_row(
      "product_bundle", "lifecycle", "failure",
      "Product store or current pointer is a symbolic link.",
      "Rebuild a regular local product store from authoritative history."
    ),
    state = list(status = "invalid", source_as_of_time = NULL), access = NULL
  ))
  opened <- rrp_open_reference_product_access(repository_root, product_store)
  if (!identical(opened$overall_status, "succeeded")) return(list(
    check = rrp_operator_result_row(
      "product_bundle", "lifecycle", "failure",
      paste("Current product bundle is invalid:", opened$message),
      "Rebuild products from authoritative operational history; do not edit bundle files."
    ),
    state = list(status = "invalid", source_as_of_time = NULL), access = NULL
  ))
  freshness <- opened$access$freshness()
  list(
    check = rrp_operator_result_row(
      "product_bundle", "lifecycle", "pass",
      paste0("Current product bundle is valid at source as-of ",
        freshness$source_as_of_time, ".")
    ),
    state = list(status = "valid", source_as_of_time = freshness$source_as_of_time),
    access = opened$access
  )
}

rrp_doctor <- function(
  repository_root,
  database_path,
  product_store,
  package_available = function(package) requireNamespace(package, quietly = TRUE),
  check_runtime = TRUE
) {
  checks <- rrp_doctor_repository_checks(repository_root, package_available)
  dependencies_ready <- !any(vapply(checks, function(value) {
    identical(value$category[[1L]], "dependencies") &&
      identical(value$status[[1L]], "failure")
  }, logical(1)))
  installed <- NULL
  if (check_runtime && dependencies_ready) {
    installed <- tryCatch(
      rrp_install_runtime_package(repository_root),
      error = function(condition) condition
    )
    runtime_ready <- !inherits(installed, "condition")
    checks[[length(checks) + 1L]] <- rrp_operator_result_row(
      "runtime_package", "runtime", if (runtime_ready) "pass" else "failure",
      if (runtime_ready) {
        "rrpruntime installed and loaded in a temporary library."
      } else paste("rrpruntime could not install/load:", conditionMessage(installed)),
      if (runtime_ready) NA_character_ else {
        "Restore dependencies, then run Rscript tests/run-phase4-tests.R."
      }
    )
    if (runtime_ready) on.exit(rrp_unload_runtime_package(installed), add = TRUE)
  } else if (check_runtime) {
    checks[[length(checks) + 1L]] <- rrp_operator_result_row(
      "runtime_package", "runtime", "failure",
      "rrpruntime installability was not checked because dependencies are unavailable.",
      "Restore dependencies and rerun doctor."
    )
  }
  writable <- rrp_operator_check_writable(dirname(database_path)) &&
    rrp_operator_check_writable(dirname(product_store))
  checks[[length(checks) + 1L]] <- rrp_operator_result_row(
    "local_output_writable", "environment", if (writable) "pass" else "failure",
    if (writable) "Local history/product parent locations are writable." else {
      "A local history/product parent location is not writable or is linked."
    },
    if (writable) NA_character_ else "Choose regular writable local output paths."
  )

  runtime_ready <- !check_runtime || (
    !is.null(installed) && !inherits(installed, "condition")
  )
  if (dependencies_ready && runtime_ready) {
    history <- rrp_doctor_history_check(repository_root, database_path)
    products <- rrp_doctor_product_check(repository_root, product_store)
  } else {
    history <- list(
      check = rrp_operator_result_row(
        "operational_history", "lifecycle", "failure",
        "Operational history compatibility could not be checked.",
        "Restore dependencies and rerun doctor."
      ),
      state = list(status = "unknown", latest_runtime_run_id = NULL)
    )
    products <- list(
      check = rrp_operator_result_row(
        "product_bundle", "lifecycle", "failure",
        "Product bundle compatibility could not be checked.",
        "Restore dependencies and rerun doctor."
      ),
      state = list(status = "unknown", source_as_of_time = NULL), access = NULL
    )
  }
  checks[[length(checks) + 1L]] <- history$check
  checks[[length(checks) + 1L]] <- products$check
  app_status <- if (identical(products$state$status, "valid") &&
      isTRUE(package_available("shiny"))) "ready" else if (
        identical(products$state$status, "absent") && isTRUE(package_available("shiny"))
      ) "blocked_expected" else "blocked"
  app_severity <- if (identical(app_status, "ready")) "pass" else if (
    identical(app_status, "blocked_expected")
  ) "warning" else "failure"
  checks[[length(checks) + 1L]] <- rrp_operator_result_row(
    "reference_app", "application", app_severity,
    paste0("Reference app status: ", app_status, "."),
    if (identical(app_status, "ready")) NA_character_ else if (
      identical(app_status, "blocked_expected")
    ) "Run the platform, materialize products, then validate the app." else {
      "Restore Shiny or rebuild a valid current product bundle."
    }
  )
  checks <- rrp_operator_bind_results(checks)
  list(
    operation_id = "platform.doctor",
    overall_status = rrp_operator_overall_status(checks),
    checks = checks,
    lifecycle = list(
      reference_environment = if (any(checks$status == "failure")) "blocked" else "ready",
      operational_history = history$state$status,
      latest_valid_run = history$state$latest_runtime_run_id,
      current_product_bundle = products$state$status,
      product_source_as_of = products$state$source_as_of_time,
      app = app_status
    )
  )
}

rrp_print_doctor <- function(result) {
  cat("Operation: ", result$operation_id, "\n", sep = "")
  cat("Status: ", result$overall_status, "\n\n", sep = "")
  for (index in seq_len(nrow(result$checks))) {
    check <- result$checks[index, ]
    cat(sprintf("%-7s %-24s %s\n", toupper(check$status), check$check_id, check$message))
    if (!is.na(check$recovery) && nzchar(check$recovery)) cat(
      "        recovery: ", check$recovery, "\n", sep = ""
    )
  }
  cat("\nLifecycle\n")
  for (name in names(result$lifecycle)) cat(
    "  ", name, ": ", result$lifecycle[[name]] %||% "none", "\n", sep = ""
  )
  invisible(result)
}
