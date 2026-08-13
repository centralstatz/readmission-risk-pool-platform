phase7_assert_identical <- function(actual, expected, message = NULL) {
  if (!identical(actual, expected)) stop(
    message %||% paste0(
      "Expected ", paste(expected, collapse = ", "), "; got ",
      paste(actual, collapse = ", "), "."
    ),
    call. = FALSE
  )
  invisible(TRUE)
}

phase7_temp_database <- function() tempfile("rrp-phase7-history-", fileext = ".duckdb")

phase7_open_lifecycle <- function(repository_root, database) {
  session <- rrp_open_duckdb_persistence(
    database, rrp_read_history_contracts(repository_root), read_only = TRUE
  )
  on.exit(rrp_close_duckdb_persistence(session), add = TRUE)
  rrp_duckdb_history_lifecycle(session)
}

phase7_test_cases <- function(repository_root) list(
  "public registry is small classified and documented" = function() {
    result <- rrp_validate_operator_repository(repository_root)
    phase0_assert_true(result$passed, paste(result$issues$message, collapse = " | "))
    registry <- rrp_read_operations_registry(repository_root)
    public <- Filter(function(value) identical(value$classification, "public"), registry$operations)
    phase7_assert_identical(length(public), 13L)
    phase0_assert_true(all(vapply(registry$operations, function(value) {
      value$classification %in% c("public", "advanced", "development")
    }, logical(1))))
  },

  "initialization creates only a writable ignored local root" = function() {
    build <- tempfile("rrp-phase7-initialize-")
    on.exit(unlink(build, recursive = TRUE, force = TRUE), add = TRUE)
    result <- rrp_initialize_local_platform(repository_root, build)
    phase7_assert_identical(result$status, "succeeded")
    phase0_assert_true(dir.exists(build))
    phase0_assert_false(file.exists(file.path(build, "reference-operational-history.duckdb")))
    phase0_assert_false(dir.exists(file.path(build, "reference-products")))
  },

  "fresh doctor treats absent history products and app data as expected warnings" = function() {
    root <- tempfile("rrp-phase7-fresh-")
    dir.create(root)
    on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
    result <- rrp_doctor(
      repository_root,
      file.path(root, "history.duckdb"),
      file.path(root, "products"),
      check_runtime = FALSE
    )
    phase7_assert_identical(result$overall_status, "ready_with_warnings")
    phase7_assert_identical(result$lifecycle$operational_history, "absent")
    phase7_assert_identical(result$lifecycle$current_product_bundle, "absent")
    phase7_assert_identical(result$lifecycle$app, "blocked_expected")
    phase0_assert_false(any(result$checks$status == "failure"))
  },

  "doctor reports missing dependencies incompatibility and actionable recovery" = function() {
    root <- tempfile("rrp-phase7-bad-")
    dir.create(root)
    on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
    missing <- rrp_doctor(
      repository_root,
      file.path(root, "absent.duckdb"),
      file.path(root, "products"),
      package_available = function(package) !identical(package, "duckdb"),
      check_runtime = FALSE
    )
    phase7_assert_identical(missing$overall_status, "blocked")
    dependency <- missing$checks[missing$checks$check_id == "dependency_duckdb", ]
    phase7_assert_identical(dependency$status, "failure")
    phase0_assert_true(grepl("renv::restore", dependency$recovery, fixed = TRUE))

    incompatible <- file.path(root, "incompatible.duckdb")
    writeLines("not a DuckDB history store", incompatible)
    result <- rrp_doctor(
      repository_root, incompatible, file.path(root, "products"),
      check_runtime = FALSE
    )
    phase7_assert_identical(result$lifecycle$operational_history, "invalid")
    phase7_assert_identical(result$overall_status, "blocked")
  },

  "one platform run persists while product rebuild and app validation stay downstream" = function() {
    root <- tempfile("rrp-phase7-workflow-")
    dir.create(root)
    database <- file.path(root, "history.duckdb")
    products <- file.path(root, "products")
    on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
    run_id <- "runtime_phase7_workflow_001"
    run <- rrp_run_reference_history(
      repository_root, "test", database, runtime_run_id = run_id
    )
    phase7_assert_identical(run$run_status, "completed")
    before <- phase7_open_lifecycle(repository_root, database)
    phase7_assert_identical(before$terminal_run_count, 1L)

    build <- rrp_build_reference_products(repository_root, database, run_id)
    rrp_materialize_reference_products(build, repository_root, products)
    after <- phase7_open_lifecycle(repository_root, database)
    phase7_assert_identical(after, before, "Product materialization changed history.")
    opened <- rrp_open_reference_product_access(repository_root, products)
    phase7_assert_identical(opened$overall_status, "succeeded")
    initialized <- rrp_initialize_reference_app(opened$access)
    phase7_assert_identical(initialized$overall_status, "succeeded")
    application <- rrp_create_reference_app(opened$access)
    phase0_assert_true(inherits(application, "shiny.appobj"))
    after_app <- phase7_open_lifecycle(repository_root, database)
    phase7_assert_identical(after_app, before, "App validation changed history.")

    member <- file.path(
      products,
      yaml::read_yaml(file.path(products, "CURRENT.yml"))$bundle_directory,
      "current-episode-risk.yml"
    )
    write("corrupt", file = member, append = TRUE)
    corrupt <- rrp_doctor(
      repository_root, database, products, check_runtime = FALSE
    )
    phase7_assert_identical(corrupt$lifecycle$current_product_bundle, "invalid")
    phase7_assert_identical(corrupt$overall_status, "blocked")
  },

  "same semantic run is idempotent" = function() {
    database <- phase7_temp_database()
    on.exit(unlink(c(database, paste0(database, ".wal")), force = TRUE), add = TRUE)
    first <- rrp_run_reference_history(repository_root, "test", database)
    second <- rrp_run_reference_history(repository_root, "test", database)
    phase7_assert_identical(first$runtime_run_id, second$runtime_run_id)
    phase7_assert_identical(first$counts, second$counts)
    phase7_assert_identical(
      phase7_open_lifecycle(repository_root, database)$terminal_run_count, 1L
    )
  },

  "same-day runs accumulate actual history without missed-run backfill" = function() {
    database <- phase7_temp_database()
    on.exit(unlink(c(database, paste0(database, ".wal")), force = TRUE), add = TRUE)
    run_ids <- c("runtime_phase7_same_day_1200", "runtime_phase7_same_day_1800")
    as_of <- c("2026-08-01T12:00:00Z", "2026-08-01T18:00:00Z")
    for (index in seq_along(run_ids)) rrp_run_reference_history(
      repository_root, "test", database, run_ids[[index]], as_of[[index]]
    )
    lifecycle <- phase7_open_lifecycle(repository_root, database)
    phase7_assert_identical(lifecycle$terminal_run_count, 2L)
    phase7_assert_identical(lifecycle$run_count, 2L)
    build <- rrp_build_reference_products(repository_root, database, run_ids)
    phase7_assert_identical(
      build$products$operational_run_summary$row_count, 2L,
      "Products collapsed same-day runs or invented another run."
    )
    phase7_assert_identical(build$products$episode_risk_history$row_count, 12L)
  },

  "app remains product-only and public run remains separate from products" = function() {
    app_files <- list.files(
      file.path(repository_root, "app"), pattern = "[.]R$", recursive = TRUE,
      full.names = TRUE
    )
    app_text <- paste(unlist(lapply(app_files, rrp_read_text)), collapse = "\n")
    phase0_assert_false(any(vapply(c(
      "DBI::", "duckdb::", "rrpruntime::", "execute_provider(",
      "run_reference_history", "build_reference_products"
    ), grepl, logical(1), x = app_text, fixed = TRUE)))
    run_text <- paste(rrp_read_text(file.path(
      repository_root, "operations", "run-platform.R"
    )), collapse = "\n")
    phase0_assert_false(grepl("materialize_reference_products", run_text, fixed = TRUE))
    phase0_assert_false(grepl("runApp", run_text, fixed = TRUE))
  }
)
