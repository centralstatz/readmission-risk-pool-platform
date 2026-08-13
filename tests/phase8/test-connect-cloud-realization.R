phase82_assert_identical <- function(actual, expected) {
  phase0_assert_true(identical(actual, expected), paste0(
    "Expected ", paste(expected, collapse = ", "), "; got ",
    paste(actual, collapse = ", "), "."
  ))
}

phase82_copy_tree <- function(source, destination, include_git = FALSE) {
  dir.create(destination, recursive = TRUE)
  directories <- list.dirs(source, recursive = TRUE, full.names = FALSE)
  if (!include_git) directories <- directories[
    directories != ".git" & !startsWith(directories, ".git/")
  ]
  for (directory in directories[nzchar(directories)]) dir.create(
    file.path(destination, directory), recursive = TRUE, showWarnings = FALSE
  )
  files <- list.files(
    source, recursive = TRUE, all.files = TRUE, no.. = TRUE, include.dirs = FALSE
  )
  if (!include_git) files <- files[files != ".git" & !startsWith(files, ".git/")]
  for (file in files) {
    dir.create(dirname(file.path(destination, file)), recursive = TRUE,
      showWarnings = FALSE
    )
    if (!file.copy(file.path(source, file), file.path(destination, file))) stop(
      "Could not copy Connect realization fixture.", call. = FALSE
    )
  }
  destination
}

phase82_tree_checksums <- function(root) {
  tree <- rrp_artifact_scan_tree(root)
  values <- vapply(tree$files, function(path) {
    rrp_artifact_checksum(file.path(root, path))
  }, character(1))
  structure(values, names = tree$files)
}

phase8_test_cases <- function(repository_root, suite_root) {
  database <- file.path(suite_root, "connect-history.duckdb")
  products <- file.path(suite_root, "connect-products")
  artifacts <- file.path(suite_root, "connect-artifacts")
  run <- rrp_run_reference_history(repository_root, "test", database)
  product_build <- rrp_build_reference_products(
    repository_root, database, run$runtime_run_id,
    product_generated_at = "2026-08-02T13:00:00Z"
  )
  rrp_materialize_reference_products(
    product_build, repository_root, products, "2026-08-02T13:30:00Z"
  )
  artifact <- rrp_build_reference_application_artifact(
    repository_root, products, artifacts, "2026-08-02T14:00:00Z"
  )
  source_checksums <- phase82_tree_checksums(artifact$artifact_path)
  destination <- file.path(suite_root, "connect-deployment")
  deployment <- rrp_build_connect_cloud_deployment(
    repository_root, artifact$artifact_path, destination,
    "2026-08-02T14:30:00Z"
  )

  list(
    "valid Connect realization has exact target inventory and dependency closure" = function() {
      phase82_assert_identical(deployment$overall_status, "succeeded")
      phase0_assert_false(deployment$idempotent)
      result <- rrp_validate_connect_cloud_realization(destination)
      phase82_assert_identical(result$overall_status, "pass")
      tree <- rrp_connect_scan_tree(destination)
      phase82_assert_identical(length(tree$files), 37L)
      phase0_assert_true(all(c(
        "app.R", "manifest.json", "renv.lock", "artifact/ARTIFACT.yml"
      ) %in% tree$files))
      manifest <- rrp_connect_read_json(file.path(destination, "manifest.json"))
      phase82_assert_identical(rrp_connect_package_version(
        manifest$packages$shiny
      ), "1.10.0")
      phase82_assert_identical(rrp_connect_package_version(
        manifest$packages$yaml
      ), "2.3.10")
      phase0_assert_false(any(c("DBI", "duckdb", "rsconnect", "renv") %in%
        names(manifest$packages)))
    },

    "standalone copied Git repository validates and constructs Shiny" = function() {
      isolated <- phase82_copy_tree(
        destination, file.path(suite_root, "connect-isolated"), include_git = TRUE
      )
      result <- rrp_validate_completed_connect_cloud_deployment(isolated)
      phase82_assert_identical(result$overall_status, "pass")
      phase0_assert_true(any(grepl(
        "isolated product-only Shiny construction", result$output, fixed = TRUE
      )))
    },

    "generated repository is remote-free staged and uncommitted" = function() {
      remotes <- rrp_connect_git(destination, "remote")
      head <- rrp_connect_git(destination, c("rev-parse", "--verify", "HEAD"))
      status <- rrp_connect_git(destination, c("status", "--porcelain=v1"))
      phase82_assert_identical(remotes$status, 0L)
      phase82_assert_identical(length(remotes$output), 0L)
      phase0_assert_false(identical(head$status, 0L))
      phase0_assert_true(length(status$output) == 37L)
      phase0_assert_true(all(startsWith(status$output, "A  ")))
    },

    "identical owned-destination regeneration is idempotent" = function() {
      prior <- yaml::read_yaml(file.path(destination, "CONNECT-REALIZATION.yml"))
      result <- rrp_build_connect_cloud_deployment(
        repository_root, artifact$artifact_path, destination,
        "2026-08-02T15:00:00Z"
      )
      current <- yaml::read_yaml(file.path(destination, "CONNECT-REALIZATION.yml"))
      phase0_assert_true(result$idempotent)
      phase0_assert_false(result$replaced)
      phase82_assert_identical(current, prior)
    },

    "unrelated existing destination is never overwritten" = function() {
      unrelated <- file.path(suite_root, "unrelated-destination")
      dir.create(unrelated)
      sentinel <- file.path(unrelated, "keep.txt")
      writeLines("not generated", sentinel)
      phase0_assert_error(
        rrp_build_connect_cloud_deployment(
          repository_root, artifact$artifact_path, unrelated,
          "2026-08-02T15:10:00Z"
        ),
        "not safe for generated replacement"
      )
      phase82_assert_identical(readLines(sentinel), "not generated")
    },

    "modified generated destination is refused without mutation" = function() {
      modified <- phase82_copy_tree(
        destination, file.path(suite_root, "modified-destination"),
        include_git = TRUE
      )
      write("local edit", file = file.path(modified, "README.md"), append = TRUE)
      before <- readLines(file.path(modified, "README.md"))
      phase0_assert_error(
        rrp_build_connect_cloud_deployment(
          repository_root, artifact$artifact_path, modified,
          "2026-08-02T15:20:00Z"
        ),
        "not safe for generated replacement"
      )
      phase82_assert_identical(readLines(file.path(modified, "README.md")), before)
    },

    "invalid artifact fails before destination or staging mutation" = function() {
      corrupt <- phase82_copy_tree(
        artifact$artifact_path, file.path(suite_root, "corrupt-artifact")
      )
      write("corrupt", file = file.path(corrupt, "R", "application.R"), append = TRUE)
      failed_destination <- file.path(suite_root, "failed-connect-destination")
      before_staging <- list.files(suite_root, pattern = "^[.]rrp-connect-cloud-staging-")
      phase0_assert_error(
        rrp_build_connect_cloud_deployment(
          repository_root, corrupt, failed_destination,
          "2026-08-02T15:30:00Z"
        ),
        "valid standalone reduced artifact"
      )
      phase0_assert_false(file.exists(failed_destination))
      phase82_assert_identical(
        list.files(suite_root, pattern = "^[.]rrp-connect-cloud-staging-"),
        before_staging
      )
    },

    "failed post-promotion validation restores an owned destination" = function() {
      recovery <- file.path(suite_root, "promotion-recovery")
      candidate <- file.path(suite_root, "promotion-candidate")
      dir.create(recovery)
      dir.create(candidate)
      writeLines("prior", file.path(recovery, "state.txt"))
      writeLines("candidate", file.path(candidate, "state.txt"))
      promotion <- rrp_connect_cloud_promote(candidate, recovery, TRUE)
      phase0_assert_error(
        rrp_connect_cloud_finish_promotion(
          promotion, list(overall_status = "fail")
        ),
        "prior owned destination was restored"
      )
      phase82_assert_identical(readLines(file.path(recovery, "state.txt")), "prior")
    },

    "changed source artifact safely replaces only an owned destination" = function() {
      later <- rrp_build_reference_application_artifact(
        repository_root, products, artifacts, "2026-08-02T16:00:00Z"
      )
      old_id <- yaml::read_yaml(
        file.path(destination, "CONNECT-REALIZATION.yml")
      )$realization_id
      result <- rrp_build_connect_cloud_deployment(
        repository_root, later$artifact_path, destination,
        "2026-08-02T16:30:00Z"
      )
      phase0_assert_true(result$replaced)
      phase0_assert_false(result$idempotent)
      phase0_assert_false(identical(result$realization_id, old_id))
      phase82_assert_identical(
        rrp_validate_connect_cloud_realization(destination)$overall_status,
        "pass"
      )
    },

    "manifest corruption unexpected files and symlinks fail independently" = function() {
      corrupted <- phase82_copy_tree(
        destination, file.path(suite_root, "corrupt-connect"), include_git = TRUE
      )
      write("corrupt", file = file.path(corrupted, "manifest.json"), append = TRUE)
      result <- rrp_validate_connect_cloud_realization(corrupted, check_git = FALSE)
      phase0_assert_true("connect_manifest_checksum_mismatch" %in%
        result$issues$issue_code)

      unexpected <- phase82_copy_tree(
        destination, file.path(suite_root, "unexpected-connect"), include_git = TRUE
      )
      writeLines("unexpected", file.path(unexpected, "extra.txt"))
      result <- rrp_validate_connect_cloud_realization(unexpected, check_git = FALSE)
      phase0_assert_true("connect_inventory_mismatch" %in% result$issues$issue_code)

      linked <- phase82_copy_tree(
        destination, file.path(suite_root, "linked-connect"), include_git = TRUE
      )
      phase0_assert_true(file.symlink(
        file.path(suite_root, "outside"), file.path(linked, "escape")
      ))
      result <- rrp_validate_connect_cloud_realization(linked, check_git = FALSE)
      phase0_assert_true("realization_symbolic_link" %in% result$issues$issue_code)
    },

    "realization excludes platform machinery and leaves source artifact unchanged" = function() {
      phase82_assert_identical(
        phase82_tree_checksums(artifact$artifact_path), source_checksums
      )
      files <- rrp_connect_scan_tree(destination)$files
      phase0_assert_false(any(vapply(c(
        "operations/", "runtime/", "implementations/", "products/", "tests/",
        "docs/", "source/", "provider/", "history/"
      ), function(prefix) any(startsWith(files, prefix)), logical(1))))
      boundary_files <- unlist(lapply(c("app", "products", "runtime",
        "implementations/synthetic-reference"), function(directory) {
          list.files(file.path(repository_root, directory), recursive = TRUE,
            full.names = TRUE, pattern = "[.](R|yml)$"
          )
        }), use.names = FALSE)
      boundary_text <- paste(unlist(lapply(boundary_files, readLines, warn = FALSE)),
        collapse = "\n"
      )
      phase0_assert_false(grepl("Connect Cloud", boundary_text, fixed = TRUE))
    }
  )
}
