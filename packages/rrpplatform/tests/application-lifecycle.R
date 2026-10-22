library(rrpplatform)

internal <- function(name) get(name, envir = asNamespace("rrpplatform"),
  inherits = FALSE)
parse_cli <- internal("rrp_cli_parse")

stopifnot(
  identical(as.list(formals(rrp_refresh_app)), as.list(alist(
    software_catalog = , project_root = , scope_id = , history_cutoff = ,
    app_path = NULL
  ))),
  identical(as.list(formals(rrp_validate_app)), as.list(alist(
    software_catalog = , app_path =
  )))
)

suite <- tempfile("rrp-app-lifecycle-foundation-")
dir.create(suite)
on.exit(unlink(suite, recursive = TRUE, force = TRUE), add = TRUE)
project <- file.path(suite, "project")
application <- file.path(suite, "detached-app")
dir.create(project)
dir.create(application)

refresh <- parse_cli(c(
  "app", "refresh", "--scope", "scope.2", "--cutoff",
  "2026-01-21T12:00:00Z", "--project", project, "--app", application,
  "--json"
), suite)
detached <- parse_cli(c("app", "validate", "--app", application), suite)
project_default <- parse_cli(c("app", "validate", "--project", project), suite)
stopifnot(
  identical(refresh$command, "app_refresh"),
  identical(refresh$app_path, normalizePath(application, winslash = "/")),
  identical(refresh$project_root, normalizePath(project, winslash = "/")),
  identical(refresh$operation_run_id, "scope.2"),
  identical(refresh$history_cutoff, "2026-01-21T12:00:00Z"),
  isTRUE(refresh$json),
  identical(detached$command, "app_validate"),
  is.null(detached$project_root),
  identical(detached$app_path, normalizePath(application, winslash = "/")),
  identical(project_default$app_path,
    file.path(normalizePath(project, winslash = "/"), "app"))
)

refresh_value <- list(
  application_id = "rrp.application.supplied", application_version = "0.1.0",
  application_path = normalizePath(application, winslash = "/"),
  previous_product_set_id = "set.1", product_set_id = "set.2",
  materialization_id = "materialization.2",
  source_operation_run_id = "scope.2",
  source_history_cutoff = "2026-01-21T12:00:00Z", changed = TRUE,
  managed_content_status = "valid", inactive_set_count = 1L,
  stale_work_count = 0L
)
validate_value <- list(
  application_id = "rrp.application.supplied", application_version = "0.1.0",
  application_path = normalizePath(application, winslash = "/"),
  managed_content_status = "valid", product_set_id = "set.2",
  materialization_id = "materialization.2",
  source_operation_run_id = "scope.2",
  source_history_cutoff = "2026-01-21T12:00:00Z",
  managed_inventory_status = "valid", initial_provenance_status = "available",
  source_baseline_status = "drifted", inactive_set_count = 1L,
  invalid_inactive_set_count = 0L, stale_work_count = 0L
)
execute <- internal("rrp_cli_execute")
refresh_result <- execute(refresh, list(catalog = NULL), list(
  app_refresh = function() internal("rrp_new_operation_result")(
    "rrp.refresh-app", "success", refresh_value, list()
  )
))
validate_result <- execute(detached, list(catalog = NULL), list(
  app_validate = function() internal("rrp_new_operation_result")(
    "rrp.validate-app", "success", validate_value, list()
  )
))
schema <- c("Schema-ID" = "rrp.cli-result", "Schema-Version" = "1.0.0")
stopifnot(
  identical(refresh_result$value, refresh_value),
  identical(validate_result$value, validate_value),
  identical(internal("rrp_cli_result_payload")(refresh_result, schema)$value,
    refresh_value),
  identical(internal("rrp_cli_result_payload")(validate_result, schema)$value,
    validate_value)
)

invalid_refresh <- rrp_refresh_app(
  list(), project, "scope.2", "2026-01-21T12:00:00Z", application
)
invalid_validation <- rrp_validate_app(list(), application)
stopifnot(
  identical(invalid_refresh$status, "failure"),
  is.null(invalid_refresh$value),
  identical(invalid_refresh$diagnostics[[1L]]$code,
    "application_refresh_failed"),
  identical(invalid_validation$status, "failure"),
  is.null(invalid_validation$value),
  identical(invalid_validation$diagnostics[[1L]]$code,
    "application_validation_failed")
)

refresh_body <- paste(deparse(body(internal("rrp_app_refresh"))), collapse = "\n")
validate_body <- paste(deparse(body(rrp_validate_app)), collapse = "\n")
stopifnot(
  grepl("rrp_app_structural_access", refresh_body, fixed = TRUE),
  grepl("file.rename", refresh_body, fixed = TRUE),
  !grepl("rrp_execute_durable_bundle", refresh_body, fixed = TRUE),
  !grepl("rrp_build_and_materialize_products", refresh_body, fixed = TRUE),
  !grepl("rrp_load_project", refresh_body, fixed = TRUE),
  !grepl("sys.source", validate_body, fixed = TRUE),
  !grepl("rrp_app_structural_access", validate_body, fixed = TRUE)
)

cat("rrpplatform application lifecycle foundation tests passed\n")
