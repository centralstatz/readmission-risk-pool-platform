phase8_copy_directory <- function(source, destination) {
  dir.create(destination, recursive = TRUE)
  directories <- list.dirs(source, recursive = TRUE, full.names = FALSE)
  for (directory in directories[nzchar(directories)]) dir.create(
    file.path(destination, directory), recursive = TRUE, showWarnings = FALSE
  )
  files <- list.files(source, recursive = TRUE, all.files = TRUE, no.. = TRUE)
  for (file in files) if (!dir.exists(file.path(source, file))) {
    if (!file.copy(file.path(source, file), file.path(destination, file))) stop(
      "Could not copy artifact test fixture.", call. = FALSE
    )
  }
  destination
}

phase8_create_fixture <- function(repository_root, suite_root) {
  database <- file.path(suite_root, "history.duckdb")
  products <- file.path(suite_root, "products")
  artifacts <- file.path(suite_root, "artifacts")
  run <- rrp_run_reference_history(repository_root, "test", database)
  build <- rrp_build_reference_products(
    repository_root,
    database,
    run$runtime_run_id,
    product_generated_at = "2026-08-01T13:00:00Z"
  )
  rrp_materialize_reference_products(
    build, repository_root, products, "2026-08-01T13:30:00Z"
  )
  artifact <- rrp_build_reference_application_artifact(
    repository_root, products, artifacts, "2026-08-01T14:00:00Z"
  )
  list(
    database = database,
    products = products,
    artifacts = artifacts,
    artifact = artifact,
    build = build
  )
}

phase8_reseal_artifact <- function(root) {
  manifest_path <- file.path(root, "ARTIFACT.yml")
  manifest <- yaml::read_yaml(manifest_path)
  manifest$inventory <- lapply(manifest$inventory, function(item) {
    item$checksum$value <- rrp_artifact_checksum(file.path(root, item$path))
    item
  })
  manifest$artifact_instance_id <- rrp_artifact_instance_id(
    manifest$application_reference,
    manifest$source_product_set$product_set_id,
    manifest$inventory
  )
  manifest$artifact_build_id <- rrp_artifact_build_id(
    manifest$artifact_instance_id,
    manifest$build_provenance$built_at
  )
  yaml::write_yaml(manifest, manifest_path, handlers = list(
    integer = function(value) as.integer(value)
  ))
  writeLines(rrp_artifact_checksum(manifest_path), file.path(root, "ARTIFACT.md5"))
  invisible(root)
}

phase8_test_cases <- function(repository_root, suite_root) {
  fixture <- phase8_create_fixture(repository_root, suite_root)
  artifact_path <- fixture$artifact$artifact_path
  copy_number <- 0L
  copy_artifact <- function() {
    copy_number <<- copy_number + 1L
    phase8_copy_directory(
      artifact_path,
      file.path(suite_root, paste0("artifact-copy-", copy_number))
    )
  }

  list(
    "valid reduced artifact construction has exact required inventory" = function() {
      result <- fixture$artifact
      phase8_assert_identical(result$overall_status, "succeeded")
      phase8_assert_identical(result$validation$overall_status, "pass")
      manifest <- result$validation$manifest
      phase8_assert_identical(length(manifest$inventory), 25L)
      files <- rrp_artifact_scan_tree(result$artifact_path)$files
      phase8_assert_identical(length(files), 27L)
      phase0_assert_true(all(c("app.R", "validate-artifact.R") %in% files))
    },

    "artifact instance is stable while build identity owns build time" = function() {
      same <- rrp_build_reference_application_artifact(
        repository_root, fixture$products, fixture$artifacts,
        "2026-08-01T14:00:00Z"
      )
      phase0_assert_true(same$idempotent)
      phase8_assert_identical(
        same$artifact_instance_id, fixture$artifact$artifact_instance_id
      )
      phase8_assert_identical(same$artifact_build_id, fixture$artifact$artifact_build_id)
      later <- rrp_build_reference_application_artifact(
        repository_root, fixture$products, fixture$artifacts,
        "2026-08-01T15:00:00Z"
      )
      phase8_assert_identical(
        later$artifact_instance_id, fixture$artifact$artifact_instance_id
      )
      phase0_assert_false(identical(
        later$artifact_build_id, fixture$artifact$artifact_build_id
      ))
      phase8_assert_identical(
        length(list.dirs(file.path(fixture$artifacts, "artifacts"),
          recursive = FALSE
        )),
        2L
      )
    },

    "embedded product set identity and integrity match the source" = function() {
      manifest <- yaml::read_yaml(file.path(artifact_path, "ARTIFACT.yml"))
      phase8_assert_identical(
        manifest$source_product_set$product_set_id,
        fixture$build$product_set$product_set_id
      )
      result <- rrp_validate_application_artifact(artifact_path)
      phase8_assert_identical(result$overall_status, "pass")
    },

    "unexpected and prohibited content is rejected" = function() {
      copy <- copy_artifact()
      dir.create(file.path(copy, "tests"))
      writeLines("development leak", file.path(copy, "tests", "leak.txt"))
      result <- rrp_validate_application_artifact(copy, construct_app = FALSE)
      phase8_assert_identical(result$overall_status, "fail")
      phase0_assert_true("artifact_inventory_mismatch" %in% result$issues$issue_code)
    },

    "artifact member corruption is detected" = function() {
      copy <- copy_artifact()
      write("corrupt", file = file.path(copy, "R", "application.R"), append = TRUE)
      result <- rrp_validate_application_artifact(copy, construct_app = FALSE)
      phase0_assert_true("artifact_member_checksum_mismatch" %in% result$issues$issue_code)
    },

    "missing application content is rejected" = function() {
      copy <- copy_artifact()
      unlink(file.path(copy, "app.R"))
      result <- rrp_validate_application_artifact(copy, construct_app = FALSE)
      phase0_assert_true("missing_required_artifact_file" %in% result$issues$issue_code)
    },

    "application product compatibility failure survives valid integrity" = function() {
      copy <- copy_artifact()
      path <- file.path(copy, "contracts", "application.yml")
      application <- yaml::read_yaml(path)
      application$required_product_set$specification_version <- "0.2.0"
      yaml::write_yaml(application, path)
      phase8_reseal_artifact(copy)
      result <- rrp_validate_application_artifact(copy, construct_app = FALSE)
      phase0_assert_true("unsupported_application" %in% result$issues$issue_code)
    },

    "escaping symbolic links are rejected without traversal" = function() {
      copy <- copy_artifact()
      outside <- file.path(suite_root, "outside.txt")
      writeLines("outside", outside)
      linked <- file.symlink(outside, file.path(copy, "escape-link"))
      phase0_assert_true(linked)
      result <- rrp_validate_application_artifact(copy, construct_app = FALSE)
      phase0_assert_true("artifact_symbolic_link" %in% result$issues$issue_code)
    },

    "isolated copied artifact constructs the app in a vanilla process" = function() {
      copy <- copy_artifact()
      result <- rrp_validate_completed_application_artifact(copy)
      phase8_assert_identical(result$overall_status, "pass")
      phase0_assert_true(any(grepl(
        "isolated product-only Shiny construction", result$output, fixed = TRUE
      )))
    },

    "artifact contains no upstream runtime or development machinery" = function() {
      files <- rrp_artifact_scan_tree(artifact_path)$files
      prohibited_prefixes <- c(
        "operations/", "runtime/", "implementations/", "tests/", "docs/",
        "history/", "source/", "provider/"
      )
      phase0_assert_false(any(vapply(files, function(path) any(startsWith(
        path, prohibited_prefixes
      )), logical(1))))
      r_files <- files[grepl("[.]R$", files)]
      text <- paste(unlist(lapply(file.path(artifact_path, r_files), readLines,
        warn = FALSE
      )), collapse = "\n")
      phase0_assert_false(any(vapply(c(
        "DBI::", "duckdb::", "rrpruntime::", "read_run_history(",
        "execute_provider(", "generate_source"
      ), grepl, logical(1), x = text, fixed = TRUE)))
      dependencies <- yaml::read_yaml(file.path(
        artifact_path, "config", "runtime-dependencies.yml"
      ))
      phase8_assert_identical(sort(names(dependencies$packages)), c("shiny", "yaml"))
    },

    "missing embedded product member fails closed" = function() {
      copy <- copy_artifact()
      pointer <- yaml::read_yaml(file.path(copy, "products", "CURRENT.yml"))
      unlink(file.path(
        copy, "products", pointer$bundle_directory, "episode-risk-history.yml"
      ))
      result <- rrp_validate_application_artifact(copy, construct_app = FALSE)
      phase8_assert_identical(result$overall_status, "fail")
      phase0_assert_true(any(result$issues$issue_code %in% c(
        "artifact_inventory_mismatch", "artifact_member_checksum_mismatch"
      )))
    }
  )
}
phase8_assert_identical <- function(actual, expected, message = NULL) {
  if (!identical(actual, expected)) stop(
    message %||% paste0(
      "Expected ", paste(expected, collapse = ", "), "; got ",
      paste(actual, collapse = ", "), "."
    ),
    call. = FALSE
  )
  invisible(TRUE)
}
