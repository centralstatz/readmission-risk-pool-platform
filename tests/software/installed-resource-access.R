rrp_copy_value <- function(value) unserialize(serialize(value, NULL))

rrp_installed_fixture <- function(repository_root) {
  source_catalog <- yaml::read_yaml(file.path(
    repository_root, "distribution", "software", "resource-catalog.yml"
  ))
  schema_source <- file.path(
    repository_root, "distribution", "software", "resource-catalog-schema.yml"
  )
  schema <- yaml::read_yaml(schema_source)
  validation <- rrp_validate_installed_resource_catalog(
    source_catalog, schema, repository_root
  )
  if (!validation$passed) stop(
    "Cannot construct installed fixture from a nonconforming source catalog.",
    call. = FALSE
  )

  fixture_root <- tempfile("rrp-installed-resource-root-")
  dir.create(fixture_root)
  for (directory in c("packages", "resources", "docs", "legal", "bin")) {
    dir.create(file.path(fixture_root, directory))
  }
  installed <- rrp_installed_resource_catalog_projection(source_catalog, schema)
  catalog_path <- file.path(fixture_root, "resources", "resource-catalog.yml")
  schema_path <- file.path(
    fixture_root, "resources", "resource-catalog-schema.yml"
  )
  yaml::write_yaml(installed, catalog_path)
  copied_schema <- file.copy(schema_source, schema_path, copy.mode = TRUE)
  if (!copied_schema) stop("Could not copy installed schema fixture.", call. = FALSE)

  for (resource in source_catalog$resources) {
    destination <- file.path(fixture_root, resource$output_path)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    copied <- file.copy(
      file.path(repository_root, resource$source_path), destination,
      copy.mode = TRUE
    )
    if (!copied) stop(
      "Could not copy installed resource fixture: ", resource$resource_id,
      call. = FALSE
    )
  }
  fixture_root
}

rrp_with_installed_fixture <- function(repository_root, callback) {
  root <- rrp_installed_fixture(repository_root)
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  callback(root)
}

rrp_expect_resource_error <- function(expression, code) {
  condition <- tryCatch(
    {
      force(expression)
      NULL
    },
    error = identity
  )
  if (is.null(condition)) stop(
    "Expected installed-resource operation to fail with `", code, "`.",
    call. = FALSE
  )
  if (!inherits(condition, "rrp_resource_error") ||
      !identical(condition$code, code)) stop(
    "Expected rrp_resource_error `", code, "`; got `",
    condition$code %||% class(condition)[[1L]], "`: ", conditionMessage(condition),
    call. = FALSE
  )
  invisible(TRUE)
}

`%||%` <- function(left, right) if (is.null(left)) right else left

rrp_read_installed_fixture_catalog <- function(root) yaml::read_yaml(file.path(
  root, "resources", "resource-catalog.yml"
))

rrp_write_installed_fixture_catalog <- function(root, catalog) yaml::write_yaml(
  catalog, file.path(root, "resources", "resource-catalog.yml")
)

rrp_run_installed_resource_access_tests <- function(repository_root) {
  tests <- list(
    "copied root resolves by logical ID outside repository and Git context" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        unrelated <- tempfile("rrp-unrelated-cwd-")
        dir.create(unrelated)
        on.exit(unlink(unrelated, recursive = TRUE, force = TRUE), add = TRUE)
        old <- setwd(unrelated)
        on.exit(setwd(old), add = TRUE)
        stopifnot(!dir.exists(file.path(root, ".git")))
        catalog <- rrpplatform::rrp_open_resource_catalog(root)
        path <- rrpplatform::rrp_resource_path(
          catalog, "rrp.contract.foundation-vocabulary"
        )
        stopifnot(
          startsWith(path, paste0(normalizePath(root, winslash = "/"), "/")),
          identical(
            readBin(path, "raw", n = file.info(path)$size),
            readBin(
              file.path(repository_root,
                        "contracts/foundation/foundation-vocabulary.yml"),
              "raw", n = file.info(path)$size
            )
          ),
          !"source_path" %in% names(catalog$catalog$resources[[1L]])
        )
      })
    },
    "missing explicit root and non-directory root fail closed" = function() {
      absent <- tempfile("rrp-absent-root-")
      rrp_expect_resource_error(
        rrpplatform::rrp_open_resource_catalog(absent), "missing_distribution_root"
      )
      file <- tempfile("rrp-root-file-")
      writeLines("not a root", file)
      on.exit(unlink(file), add = TRUE)
      rrp_expect_resource_error(
        rrpplatform::rrp_open_resource_catalog(file), "missing_distribution_root"
      )
    },
    "missing catalog and schema fail closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        unlink(file.path(root, "resources", "resource-catalog.yml"))
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "missing_catalog"
        )
      })
      rrp_with_installed_fixture(repository_root, function(root) {
        unlink(file.path(root, "resources", "resource-catalog-schema.yml"))
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "missing_schema"
        )
      })
    },
    "malformed and unknown catalog structure fail closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        writeLines("{]", file.path(root, "resources", "resource-catalog.yml"))
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "malformed_catalog"
        )
      })
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrp_read_installed_fixture_catalog(root)
        catalog$repository_root <- "/not/allowed"
        rrp_write_installed_fixture_catalog(root, catalog)
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "unknown_field"
        )
      })
    },
    "catalog and schema identity tampering fail closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrp_read_installed_fixture_catalog(root)
        catalog$catalog_version <- "9.9.9"
        rrp_write_installed_fixture_catalog(root, catalog)
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "invalid_catalog_identity"
        )
      })
      rrp_with_installed_fixture(repository_root, function(root) {
        path <- file.path(root, "resources", "resource-catalog-schema.yml")
        schema <- yaml::read_yaml(path)
        schema$specification_version <- "9.9.9"
        yaml::write_yaml(schema, path)
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "invalid_schema_identity"
        )
      })
    },
    "partial and duplicate resource identities fail closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrp_read_installed_fixture_catalog(root)
        catalog$resources <- catalog$resources[-1L]
        rrp_write_installed_fixture_catalog(root, catalog)
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "invalid_resource_inventory"
        )
      })
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrp_read_installed_fixture_catalog(root)
        catalog$resources[[2L]]$resource_id <-
          catalog$resources[[1L]]$resource_id
        rrp_write_installed_fixture_catalog(root, catalog)
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "duplicate_resource_id"
        )
      })
    },
    "duplicate and file-directory-conflicting outputs fail closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrp_read_installed_fixture_catalog(root)
        catalog$resources[[2L]]$output_path <-
          catalog$resources[[1L]]$output_path
        rrp_write_installed_fixture_catalog(root, catalog)
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "duplicate_output_path"
        )
      })
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrp_read_installed_fixture_catalog(root)
        catalog$resources[[2L]]$output_path <- paste0(
          catalog$resources[[1L]]$output_path, "/child.yml"
        )
        rrp_write_installed_fixture_catalog(root, catalog)
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root),
          "output_file_directory_conflict"
        )
      })
    },
    "escaping and absolute outputs fail closed" = function() {
      for (unsafe in c("../escape.yml", "/tmp/escape.yml")) {
        rrp_with_installed_fixture(repository_root, function(root) {
          catalog <- rrp_read_installed_fixture_catalog(root)
          catalog$resources[[1L]]$output_path <- unsafe
          rrp_write_installed_fixture_catalog(root, catalog)
          rrp_expect_resource_error(
            rrpplatform::rrp_open_resource_catalog(root), "unsafe_output_path"
          )
        })
      }
    },
    "missing required and extra undeclared resources fail closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrp_read_installed_fixture_catalog(root)
        unlink(file.path(root, catalog$resources[[1L]]$output_path))
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "missing_resource"
        )
      })
      rrp_with_installed_fixture(repository_root, function(root) {
        extra <- file.path(root, "resources", "contracts", "undeclared.yml")
        dir.create(dirname(extra), recursive = TRUE, showWarnings = FALSE)
        writeLines("undeclared: true", extra)
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root),
          "closed_inventory_mismatch"
        )
      })
    },
    "linked resource fails closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrp_read_installed_fixture_catalog(root)
        linked <- file.path(root, catalog$resources[[1L]]$output_path)
        target <- file.path(root, catalog$resources[[2L]]$output_path)
        unlink(linked)
        if (!file.symlink(target, linked)) stop(
          "Could not create installed-resource symlink fixture.", call. = FALSE
        )
        rrp_expect_resource_error(
          rrpplatform::rrp_open_resource_catalog(root), "linked_resource"
        )
      })
    },
    "unknown and malformed lookup IDs fail closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrpplatform::rrp_open_resource_catalog(root)
        rrp_expect_resource_error(
          rrpplatform::rrp_resource_path(catalog, "rrp.contract.not-present"),
          "unknown_resource_id"
        )
        rrp_expect_resource_error(
          rrpplatform::rrp_resource_path(catalog, ""), "invalid_resource_id"
        )
      })
    },
    "catalog and root inconsistency fails closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrpplatform::rrp_open_resource_catalog(root)
        catalog$catalog_path <- file.path(root, "resource-catalog.yml")
        rrp_expect_resource_error(
          rrpplatform::rrp_resource_path(
            catalog, "rrp.contract.foundation-vocabulary"
          ), "catalog_root_mismatch"
        )
      })
    },
    "post-open resource removal and link substitution fail closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrpplatform::rrp_open_resource_catalog(root)
        entry <- catalog$catalog$resources[[1L]]
        unlink(file.path(root, entry$output_path))
        rrp_expect_resource_error(
          rrpplatform::rrp_resource_path(catalog, entry$resource_id),
          "missing_resource"
        )
      })
      rrp_with_installed_fixture(repository_root, function(root) {
        catalog <- rrpplatform::rrp_open_resource_catalog(root)
        entry <- catalog$catalog$resources[[1L]]
        target <- catalog$catalog$resources[[2L]]
        path <- file.path(root, entry$output_path)
        unlink(path)
        if (!file.symlink(file.path(root, target$output_path), path)) stop(
          "Could not create post-open symlink fixture.", call. = FALSE
        )
        rrp_expect_resource_error(
          rrpplatform::rrp_resource_path(catalog, entry$resource_id),
          "linked_resource"
        )
      })
    },
    "post-open catalog replacement fails closed" = function() {
      rrp_with_installed_fixture(repository_root, function(root) {
        validated <- rrpplatform::rrp_open_resource_catalog(root)
        catalog <- rrp_read_installed_fixture_catalog(root)
        catalog$resources[[1L]]$compatibility$note <- "Changed after opening."
        rrp_write_installed_fixture_catalog(root, catalog)
        rrp_expect_resource_error(
          rrpplatform::rrp_resource_path(
            validated, "rrp.contract.foundation-vocabulary"
          ), "catalog_changed"
        )
      })
    }
  )

  failures <- list()
  for (name in names(tests)) {
    failure <- tryCatch({
      tests[[name]]()
      NULL
    }, error = conditionMessage)
    if (is.null(failure)) {
      cat("PASS installed access: ", name, "\n", sep = "")
    } else {
      cat("FAIL installed access: ", name, " - ", failure, "\n", sep = "")
      failures[[name]] <- failure
    }
  }
  if (length(failures) > 0L) stop(
    "Installed-resource access acceptance failed (", length(failures),
    " failures).", call. = FALSE
  )
  cat("Installed-resource access: PASS (", length(tests), " tests)\n", sep = "")
  invisible(TRUE)
}
