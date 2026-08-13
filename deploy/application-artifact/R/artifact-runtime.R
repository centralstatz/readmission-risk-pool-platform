# Standalone validation and loading for a completed reduced application
# artifact. This file intentionally discovers only its injected artifact root.

rrp_artifact_specification <- function() list(
  specification_kind = "application_artifact_contract",
  specification_id = "platform.reduced-application-artifact",
  specification_version = "0.1.0"
)

rrp_artifact_validator_reference <- function() list(
  validator_id = "platform.application-artifact-validator",
  validator_version = "0.1.0"
)

rrp_artifact_runtime_files <- function() c(
  "app.R",
  "validate-artifact.R",
  "R/artifact-runtime.R",
  "R/product-foundation.R",
  "R/product-conformance.R",
  "R/yaml-product-foundation.R",
  "R/yaml-product-validation.R",
  "R/yaml-product-access.R",
  "R/app-init.R",
  "R/view-models.R",
  "R/application.R",
  "contracts/application-artifact.yml",
  "contracts/application.yml",
  "contracts/product-materialization-adapter.yml",
  "contracts/initial-risk-product-set.yml",
  "contracts/current-episode-risk.yml",
  "contracts/episode-risk-history.yml",
  "contracts/operational-run-summary.yml",
  "config/yaml-product-adapter.yml",
  "config/runtime-dependencies.yml"
)

rrp_artifact_issue <- function(category, issue_code, message, path = "$" ) {
  data.frame(
    category = category,
    severity = "error",
    issue_code = issue_code,
    message = message,
    path = path,
    stringsAsFactors = FALSE
  )
}

rrp_artifact_empty_issues <- function() data.frame(
  category = character(),
  severity = character(),
  issue_code = character(),
  message = character(),
  path = character(),
  stringsAsFactors = FALSE
)

rrp_artifact_bind_issues <- function(issues) {
  issues <- Filter(function(value) !is.null(value) && nrow(value) > 0L, issues)
  if (length(issues) == 0L) return(rrp_artifact_empty_issues())
  do.call(rbind, issues)
}

rrp_artifact_result <- function(issues = list(), manifest = NULL, application = NULL) {
  issues <- rrp_artifact_bind_issues(issues)
  structure(list(
    overall_status = if (nrow(issues) == 0L) "pass" else "fail",
    issues = issues,
    manifest = manifest,
    application = application
  ), class = "rrp_application_artifact_validation_result")
}

rrp_artifact_safe_relative_path <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path) ||
      grepl("^(/|~|[A-Za-z]:[/\\\\])", path) || grepl("\\\\", path)) return(FALSE)
  parts <- strsplit(path, "/", fixed = TRUE)[[1L]]
  !any(parts %in% c("", ".", "..")) && identical(path, paste(parts, collapse = "/"))
}

rrp_artifact_checksum <- function(path) {
  unname(as.character(tools::md5sum(path)[[1L]]))
}

rrp_artifact_string_digest <- function(value) {
  path <- tempfile("rrp-artifact-digest-")
  on.exit(unlink(path, force = TRUE), add = TRUE)
  writeLines(enc2utf8(value), path, useBytes = TRUE)
  rrp_artifact_checksum(path)
}

rrp_artifact_instance_id <- function(application_reference, product_set_id, inventory) {
  ordered <- inventory[order(vapply(inventory, `[[`, character(1), "path"), method = "radix")]
  records <- vapply(ordered, function(item) paste0(
    item$path, "=", item$checksum$algorithm, ":", item$checksum$value
  ), character(1))
  digest <- rrp_artifact_string_digest(paste(c(
    rrp_artifact_specification()$specification_id,
    rrp_artifact_specification()$specification_version,
    application_reference$application_id,
    application_reference$application_version,
    product_set_id,
    records
  ), collapse = "\n"))
  paste0("application_artifact::", digest)
}

rrp_artifact_build_id <- function(artifact_instance_id, built_at) paste0(
  "application_artifact_build::",
  rrp_artifact_string_digest(paste(artifact_instance_id, built_at, sep = "\n"))
)

rrp_artifact_read_yaml <- function(path) {
  if (!requireNamespace("yaml", quietly = TRUE)) stop(
    "Package `yaml` is required by the reduced application artifact.", call. = FALSE
  )
  yaml::read_yaml(path)
}

rrp_artifact_scan_tree <- function(root) {
  files <- character()
  directories <- ""
  symlinks <- character()
  queue <- ""
  while (length(queue) > 0L) {
    relative_directory <- queue[[1L]]
    queue <- queue[-1L]
    directory <- if (nzchar(relative_directory)) {
      file.path(root, relative_directory)
    } else root
    children <- list.files(
      directory, all.files = TRUE, no.. = TRUE, full.names = FALSE,
      recursive = FALSE
    )
    for (child in children) {
      relative <- if (nzchar(relative_directory)) {
        paste(relative_directory, child, sep = "/")
      } else child
      path <- file.path(root, relative)
      if (nzchar(Sys.readlink(path))) {
        symlinks <- c(symlinks, relative)
      } else if (dir.exists(path)) {
        directories <- c(directories, relative)
        queue <- c(queue, relative)
      } else {
        files <- c(files, relative)
      }
    }
  }
  list(
    files = sort(files, method = "radix"),
    directories = sort(directories, method = "radix"),
    symlinks = sort(symlinks, method = "radix")
  )
}

rrp_artifact_read_documents <- function(root) {
  paths <- list(
    artifact_contract = "contracts/application-artifact.yml",
    application = "contracts/application.yml",
    materialization_contract = "contracts/product-materialization-adapter.yml",
    adapter = "config/yaml-product-adapter.yml",
    product_set = "contracts/initial-risk-product-set.yml",
    current_episode_risk = "contracts/current-episode-risk.yml",
    episode_risk_history = "contracts/episode-risk-history.yml",
    operational_run_summary = "contracts/operational-run-summary.yml",
    dependencies = "config/runtime-dependencies.yml"
  )
  documents <- lapply(paths, function(path) rrp_artifact_read_yaml(file.path(root, path)))
  names(documents) <- names(paths)
  documents
}

rrp_artifact_product_paths <- function(pointer) {
  if (!is.list(pointer) || !is.character(pointer$bundle_directory) ||
      length(pointer$bundle_directory) != 1L ||
      !grepl("^sets/bundle-[a-f0-9]{32}$", pointer$bundle_directory)) return(character())
  paste0("products/", c(
    "CURRENT.yml",
    paste0(pointer$bundle_directory, "/", c(
      "PRODUCT_SET.yml", "current-episode-risk.yml",
      "episode-risk-history.yml", "operational-run-summary.yml"
    ))
  ))
}

rrp_artifact_validate_dependencies <- function(declaration, check_installed = TRUE) {
  issues <- list()
  expected <- c(shiny = "1.10.0", yaml = "2.3.10")
  declared <- if (is.list(declaration$packages)) vapply(
    declaration$packages,
    function(value) if (is.list(value)) value$version else NA_character_,
    character(1)
  ) else character()
  shape_ok <- identical(declaration$declaration_kind, "application_runtime_dependencies") &&
    identical(declaration$declaration_version, "0.1.0") &&
    identical(declaration$r$minimum_version, "4.1.0") &&
    identical(declared[names(expected)], expected) &&
    setequal(names(declared), names(expected))
  if (!shape_ok) issues[[length(issues) + 1L]] <- rrp_artifact_issue(
    "dependencies", "invalid_runtime_dependency_declaration",
    "Runtime dependencies must declare only the supported R minimum, Shiny, and YAML versions.",
    "config/runtime-dependencies.yml"
  )
  if (check_installed && shape_ok) {
    if (getRversion() < package_version(declaration$r$minimum_version)) {
      issues[[length(issues) + 1L]] <- rrp_artifact_issue(
        "dependencies", "unsupported_r_version",
        "Installed R is older than the artifact runtime minimum.", "$runtime.r"
      )
    }
    for (package in names(expected)) {
      available <- requireNamespace(package, quietly = TRUE)
      version_ok <- available && identical(
        as.character(utils::packageVersion(package)), expected[[package]]
      )
      if (!version_ok) issues[[length(issues) + 1L]] <- rrp_artifact_issue(
        "dependencies", "runtime_package_unavailable",
        paste0("Artifact requires `", package, "@", expected[[package]], "`."),
        paste0("$runtime.packages.", package)
      )
    }
  }
  issues
}

rrp_artifact_static_compatibility <- function(documents) {
  issues <- list()
  artifact_contract <- documents$artifact_contract
  application <- documents$application
  if (!identical(list(
    specification_kind = artifact_contract$specification_kind,
    specification_id = artifact_contract$specification_id,
    specification_version = artifact_contract$specification_version
  ), rrp_artifact_specification())) issues[[length(issues) + 1L]] <- rrp_artifact_issue(
    "compatibility", "unsupported_artifact_contract",
    "Embedded artifact contract identity/version is unsupported.",
    "contracts/application-artifact.yml"
  )
  expected_application <- list(
    specification_kind = "application",
    specification_id = "reference.readmission-risk-application",
    specification_version = "0.1.0"
  )
  actual_application <- application[c(
    "specification_kind", "specification_id", "specification_version"
  )]
  if (!identical(actual_application, expected_application) ||
      !identical(application$entry_point, "app.R") ||
      !identical(application$required_product_set, list(
        specification_kind = "product_set_contract",
        specification_id = "platform.initial-risk-product-set",
        specification_version = "0.1.0"
      ))) issues[[length(issues) + 1L]] <- rrp_artifact_issue(
    "compatibility", "unsupported_application",
    "Embedded application identity, entry point, or product-set requirement is unsupported.",
    "contracts/application.yml"
  )
  issues
}

rrp_load_application_artifact_runtime <- function(root, envir = parent.frame()) {
  files <- c(
    "product-foundation.R", "product-conformance.R",
    "yaml-product-foundation.R", "yaml-product-validation.R",
    "yaml-product-access.R", "app-init.R", "view-models.R", "application.R"
  )
  for (file in files) sys.source(file.path(root, "R", file), envir = envir)
  invisible(TRUE)
}

rrp_validate_application_artifact <- function(
  root,
  construct_app = TRUE,
  check_dependencies = TRUE
) {
  issues <- list()
  root_link <- nzchar(Sys.readlink(root))
  root <- normalizePath(root, mustWork = FALSE)
  if (!dir.exists(root) || root_link) return(rrp_artifact_result(list(
    rrp_artifact_issue(
      "integrity", "artifact_root_unavailable",
      "Artifact root must be an existing regular directory, not a symbolic link.", "$"
    )
  )))
  tree <- rrp_artifact_scan_tree(root)
  if (length(tree$symlinks) > 0L) for (path in tree$symlinks) {
    issues[[length(issues) + 1L]] <- rrp_artifact_issue(
      "integrity", "artifact_symbolic_link",
      "Symbolic links are prohibited in a closed application artifact.", path
    )
  }
  required_root <- c("ARTIFACT.yml", "ARTIFACT.md5", "app.R", "validate-artifact.R")
  missing_root <- setdiff(required_root, tree$files)
  for (path in missing_root) issues[[length(issues) + 1L]] <- rrp_artifact_issue(
    "inventory", "missing_required_artifact_file",
    "A required artifact root file is missing.", path
  )
  if (length(missing_root) > 0L) return(rrp_artifact_result(issues))

  manifest_path <- file.path(root, "ARTIFACT.yml")
  checksum_text <- trimws(readLines(file.path(root, "ARTIFACT.md5"), warn = FALSE))
  if (length(checksum_text) != 1L ||
      !grepl("^[a-f0-9]{32}$", checksum_text) ||
      !identical(checksum_text, rrp_artifact_checksum(manifest_path))) {
    issues[[length(issues) + 1L]] <- rrp_artifact_issue(
      "integrity", "artifact_manifest_checksum_mismatch",
      "ARTIFACT.md5 does not match ARTIFACT.yml.", "ARTIFACT.md5"
    )
    return(rrp_artifact_result(issues))
  }
  manifest <- tryCatch(rrp_artifact_read_yaml(manifest_path), error = function(value) value)
  if (inherits(manifest, "condition") || !is.list(manifest)) return(
    rrp_artifact_result(c(issues, list(rrp_artifact_issue(
      "integrity", "invalid_artifact_manifest",
      "ARTIFACT.yml is not readable YAML metadata.", "ARTIFACT.yml"
    ))))
  )
  required_manifest <- c(
    "artifact_specification", "artifact_instance_id", "artifact_build_id",
    "application_reference", "source_product_set", "freshness",
    "runtime_requirements", "required_runtime_files", "required_product_members",
    "inventory", "integrity", "build_provenance", "compatibility",
    "validation_evidence"
  )
  missing_manifest <- setdiff(required_manifest, names(manifest))
  for (field in missing_manifest) issues[[length(issues) + 1L]] <- rrp_artifact_issue(
    "contract", "missing_artifact_manifest_field",
    paste0("Artifact manifest is missing required field `", field, "`."),
    paste0("ARTIFACT.yml#", field)
  )
  if (!identical(manifest$artifact_specification, rrp_artifact_specification())) {
    issues[[length(issues) + 1L]] <- rrp_artifact_issue(
      "compatibility", "unsupported_artifact_specification",
      "Artifact manifest contract identity/version is unsupported.",
      "ARTIFACT.yml#artifact_specification"
    )
  }

  inventory <- manifest$inventory
  inventory_ok <- is.list(inventory) && length(inventory) > 0L && all(vapply(
    inventory,
    function(item) is.list(item) && rrp_artifact_safe_relative_path(item$path) &&
      is.character(item$role) && length(item$role) == 1L && nzchar(item$role) &&
      is.list(item$checksum) && identical(item$checksum$algorithm, "md5") &&
      is.character(item$checksum$value) && length(item$checksum$value) == 1L &&
      grepl("^[a-f0-9]{32}$", item$checksum$value),
    logical(1)
  ))
  if (!inventory_ok) {
    issues[[length(issues) + 1L]] <- rrp_artifact_issue(
      "inventory", "invalid_artifact_inventory",
      "Artifact inventory entries require safe paths, roles, and MD5 checksums.",
      "ARTIFACT.yml#inventory"
    )
    return(rrp_artifact_result(issues, manifest))
  }
  inventory_paths <- vapply(inventory, `[[`, character(1), "path")
  if (anyDuplicated(inventory_paths)) issues[[length(issues) + 1L]] <- rrp_artifact_issue(
    "inventory", "duplicate_artifact_inventory_path",
    "Artifact inventory paths must be unique.", "ARTIFACT.yml#inventory"
  )
  expected_actual <- sort(c("ARTIFACT.yml", "ARTIFACT.md5", inventory_paths), method = "radix")
  if (!identical(tree$files, expected_actual)) issues[[length(issues) + 1L]] <-
    rrp_artifact_issue(
      "inventory", "artifact_inventory_mismatch",
      paste0(
        "Closed inventory differs from disk. Unexpected: ",
        paste(setdiff(tree$files, expected_actual), collapse = ", "),
        "; missing: ", paste(setdiff(expected_actual, tree$files), collapse = ", "), "."
      ),
      "$"
    )
  for (index in seq_along(inventory)) {
    item <- inventory[[index]]
    path <- file.path(root, item$path)
    if (!file.exists(path) || nzchar(Sys.readlink(path)) ||
        !identical(rrp_artifact_checksum(path), item$checksum$value)) {
      issues[[length(issues) + 1L]] <- rrp_artifact_issue(
        "integrity", "artifact_member_checksum_mismatch",
        "Artifact member is missing, linked, or differs from its declared checksum.",
        item$path
      )
    }
  }

  pointer <- tryCatch(
    rrp_artifact_read_yaml(file.path(root, "products", "CURRENT.yml")),
    error = function(value) value
  )
  product_paths <- if (inherits(pointer, "condition")) character() else {
    rrp_artifact_product_paths(pointer)
  }
  declared_runtime <- unlist(manifest$required_runtime_files, use.names = FALSE)
  declared_products <- unlist(manifest$required_product_members, use.names = FALSE)
  if (!identical(declared_runtime, rrp_artifact_runtime_files()) ||
      !identical(declared_products, product_paths) ||
      !setequal(inventory_paths, c(declared_runtime, declared_products))) {
    issues[[length(issues) + 1L]] <- rrp_artifact_issue(
      "inventory", "unsupported_artifact_allowlist",
      "Manifest runtime/product allowlists do not match the closed artifact contract.",
      "ARTIFACT.yml#required_runtime_files"
    )
  }
  prohibited_directories <- c(
    "source", "implementations", "runtime", "operations", "tests", "docs",
    "history", "database", "provider", "canonical", ".git", "renv"
  )
  first_parts <- vapply(strsplit(inventory_paths, "/", fixed = TRUE), `[[`, character(1), 1L)
  if (any(first_parts %in% prohibited_directories)) issues[[length(issues) + 1L]] <-
    rrp_artifact_issue(
      "scope", "prohibited_platform_content",
      "Artifact contains prohibited upstream, development, history, or target content.", "$"
    )
  if (nrow(rrp_artifact_bind_issues(issues)) > 0L) return(
    rrp_artifact_result(issues, manifest)
  )

  documents <- tryCatch(rrp_artifact_read_documents(root), error = function(value) value)
  if (inherits(documents, "condition")) return(rrp_artifact_result(c(issues, list(
    rrp_artifact_issue(
      "compatibility", "artifact_document_read_failure",
      conditionMessage(documents), "contracts"
    )
  )), manifest))
  issues <- c(issues, rrp_artifact_static_compatibility(documents))
  issues <- c(
    issues,
    rrp_artifact_validate_dependencies(documents$dependencies, check_dependencies)
  )
  dependency_reference <- list(
    declaration_file = "config/runtime-dependencies.yml",
    declaration_version = documents$dependencies$declaration_version
  )
  if (!identical(manifest$runtime_requirements, dependency_reference)) {
    issues[[length(issues) + 1L]] <- rrp_artifact_issue(
      "dependencies", "runtime_requirement_reference_mismatch",
      "Artifact manifest does not reference the embedded dependency declaration.",
      "ARTIFACT.yml#runtime_requirements"
    )
  }
  application_reference <- list(
    application_id = documents$application$specification_id,
    application_version = documents$application$specification_version
  )
  if (!identical(manifest$application_reference, application_reference)) {
    issues[[length(issues) + 1L]] <- rrp_artifact_issue(
      "compatibility", "application_reference_mismatch",
      "Artifact and embedded application identities differ.",
      "ARTIFACT.yml#application_reference"
    )
  }
  if (!identical(manifest$validation_evidence, c(
    rrp_artifact_validator_reference(), list(status = "passed")
  ))) issues[[length(issues) + 1L]] <- rrp_artifact_issue(
    "validation", "invalid_artifact_validation_evidence",
    "Artifact must declare the supported validator and passed staged validation.",
    "ARTIFACT.yml#validation_evidence"
  )

  opened <- tryCatch(rrp_open_yaml_product_access(
    file.path(root, "products"),
    documents$materialization_contract,
    documents$adapter,
    documents[c(
      "product_set", "current_episode_risk", "episode_risk_history",
      "operational_run_summary"
    )]
  ), error = function(value) value)
  if (inherits(opened, "condition") ||
      !identical(opened$overall_status, "succeeded")) {
    issues[[length(issues) + 1L]] <- rrp_artifact_issue(
      "products", "artifact_product_validation_failed",
      if (inherits(opened, "condition")) conditionMessage(opened) else opened$message,
      "products"
    )
  } else {
    product_set <- opened$validation$manifest$product_set
    expected_source <- list(
      specification = product_set$product_set_specification,
      product_set_id = product_set$product_set_id
    )
    expected_freshness <- list(
      source_cutoff_time = product_set$source_cutoff_time,
      source_as_of_time = product_set$source_as_of_time,
      latest_source_runtime_run_id = product_set$latest_source_runtime_run_id,
      product_generated_at = product_set$product_generated_at,
      product_published_at = opened$validation$pointer$published_at
    )
    if (!identical(manifest$source_product_set, expected_source) ||
        !identical(manifest$freshness, expected_freshness)) {
      issues[[length(issues) + 1L]] <- rrp_artifact_issue(
        "products", "artifact_product_metadata_mismatch",
        "Artifact source product identity or freshness differs from the embedded bundle.",
        "ARTIFACT.yml#source_product_set"
      )
    }
  }

  expected_instance <- rrp_artifact_instance_id(
    application_reference,
    manifest$source_product_set$product_set_id,
    inventory
  )
  expected_build <- rrp_artifact_build_id(
    expected_instance,
    manifest$build_provenance$built_at
  )
  if (!identical(manifest$artifact_instance_id, expected_instance) ||
      !identical(manifest$artifact_build_id, expected_build)) {
    issues[[length(issues) + 1L]] <- rrp_artifact_issue(
      "identity", "invalid_artifact_identity",
      "Artifact instance/build identity does not match its declared semantic inputs.",
      "ARTIFACT.yml#artifact_instance_id"
    )
  }
  if (!identical(manifest$integrity, list(
    algorithm = "md5",
    purpose = "accidental_corruption_detection_not_authenticity",
    manifest_checksum_file = "ARTIFACT.md5"
  ))) issues[[length(issues) + 1L]] <- rrp_artifact_issue(
    "integrity", "unsupported_artifact_integrity_declaration",
    "Artifact integrity declaration is unsupported.", "ARTIFACT.yml#integrity"
  )
  compatibility <- list(
    product_set = documents$application$required_product_set,
    materialization_adapter = list(
      adapter_id = documents$adapter$adapter_id,
      adapter_version = documents$adapter$adapter_version
    ),
    application = application_reference
  )
  if (!identical(manifest$compatibility, compatibility)) {
    issues[[length(issues) + 1L]] <- rrp_artifact_issue(
      "compatibility", "artifact_compatibility_declaration_mismatch",
      "Artifact compatibility declaration does not match embedded declarations.",
      "ARTIFACT.yml#compatibility"
    )
  }
  if (nrow(rrp_artifact_bind_issues(issues)) > 0L) return(
    rrp_artifact_result(issues, manifest)
  )

  application <- NULL
  if (construct_app) {
    initialized <- tryCatch(
      rrp_initialize_reference_app(opened$access),
      error = function(value) value
    )
    if (inherits(initialized, "condition") ||
        !identical(initialized$overall_status, "succeeded")) {
      issues[[length(issues) + 1L]] <- rrp_artifact_issue(
        "application", "artifact_application_initialization_failed",
        if (inherits(initialized, "condition")) {
          conditionMessage(initialized)
        } else initialized$message,
        "app.R"
      )
    } else {
      application <- tryCatch(
        rrp_create_reference_app(opened$access),
        error = function(value) value
      )
      if (inherits(application, "condition") ||
          !inherits(application, "shiny.appobj")) {
        issues[[length(issues) + 1L]] <- rrp_artifact_issue(
          "application", "artifact_application_construction_failed",
          if (inherits(application, "condition")) {
            conditionMessage(application)
          } else "Application entry point did not construct a Shiny application.",
          "app.R"
        )
        application <- NULL
      }
    }
  }
  rrp_artifact_result(issues, manifest, application)
}
