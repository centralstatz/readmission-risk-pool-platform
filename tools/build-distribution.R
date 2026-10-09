#!/usr/bin/env Rscript

script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_argument) != 1L) stop("Cannot determine build script path.", call. = FALSE)
script_path <- normalizePath(sub("^--file=", "", script_argument), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
source(file.path(repository_root, "tools", "distribution-lib.R"), local = TRUE)

build_distribution <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (length(arguments) != 1L || !nzchar(arguments[[1L]])) {
    distribution_stop(
      "output_destination",
      "Usage: Rscript --vanilla tools/build-distribution.R /absolute/nonexistent/output.tar"
    )
  }
  output <- arguments[[1L]]
  if (!grepl("^[A-Za-z]:|^/", output) || !grepl("[.]tar$", output)) {
    distribution_stop("output_destination", "Output must be one explicit absolute .tar path.")
  }
  output <- normalizePath(output, winslash = "/", mustWork = FALSE)
  output_parent <- dirname(output)
  if (!dir.exists(output_parent) || nzchar(Sys.readlink(output_parent))) {
    distribution_stop("output_destination", "Output parent must be an existing nonlinked directory.")
  }
  if (file.exists(output) || dir.exists(output)) {
    distribution_stop("output_conflict", "Output already exists and will not be replaced.")
  }

  stage <- tempfile(".rrp-distribution-stage-", tmpdir = output_parent)
  dir.create(stage)
  on.exit(unlink(stage, recursive = TRUE, force = TRUE), add = TRUE)
  package_build_root <- file.path(stage, "package-build")
  dir.create(package_build_root)
  payload_name <- "rrp-1.0.0-dev"
  payload <- file.path(stage, payload_name)
  dir.create(payload)

  cat("[1/9] Validate positive source authority\n")
  authority <- distribution_source_authority(repository_root)
  resources <- distribution_resource_authority(repository_root)

  cat("[2/9] Resolve tested dependency specification\n")
  dependencies <- distribution_dependency_specification(repository_root)
  dependency_path <- file.path(payload, "dependencies", "dependencies.dcf")
  distribution_write_dcf(dependencies$records, dependency_path)

  cat("[3/9] Build exact internal package artifacts\n")
  package_artifacts <- list()
  for (record in authority$packages) {
    package <- record[["Package"]]
    package_artifacts[[package]] <- distribution_build_package(
      record, repository_root, package_build_root,
      if (identical(package, "rrpplatform")) resources else NULL
    )
  }

  roles <- character()
  add_role <- function(path, role) {
    if (path %in% names(roles) || tolower(path) %in% tolower(names(roles))) {
      distribution_stop("payload_destination", paste("Duplicate payload destination:", path))
    }
    roles[[path]] <<- role
  }
  for (package in sort(names(package_artifacts), method = "radix")) {
    artifact <- package_artifacts[[package]]
    destination <- file.path(payload, "packages", artifact$filename)
    distribution_copy(artifact$path, destination)
    add_role(paste0("packages/", artifact$filename), "internal-package")
  }

  cat("[4/9] Project installed resources and direct payload\n")
  distribution_project_resources(resources, repository_root, payload)
  add_role("resources/resource-catalog.dcf", "resource-catalog")
  for (path in resources$installed_paths) add_role(path, "installed-resource")
  for (record in authority$direct) {
    destination <- record[["Destination-Path"]]
    distribution_copy(file.path(repository_root, record[["Source-Path"]]),
                      file.path(payload, destination),
                      identical(record[["Role"]], "version-launcher") ||
                        identical(record[["Role"]], "standalone-verifier") ||
                        identical(record[["Role"]], "bootstrap-installer"))
    add_role(destination, record[["Role"]])
  }
  add_role("dependencies/dependencies.dcf", "dependency-specification")

  cat("[5/9] Generate normalized identity, manifest, and inventory\n")
  identity <- distribution_source_identity(
    authority, resources, repository_root, dependency_path
  )
  distribution_id <- identity$id
  writeLines(identity$lines, file.path(payload, "identity.txt"), useBytes = TRUE)
  add_role("identity.txt", "distribution-identity")
  inventory <- distribution_inventory(payload, roles, distribution_id)
  inventory_path <- file.path(payload, "inventory.dcf")
  distribution_write_dcf(inventory, inventory_path)
  built_at <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  build_id <- distribution_hash_lines(c(distribution_id, built_at, as.character(Sys.getpid())))
  source_revision <- tryCatch(
    trimws(system2("git", c("-C", repository_root, "rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE)[[1L]]),
    error = function(e) "unavailable"
  )
  source_status <- tryCatch(
    if (length(system2("git", c("-C", repository_root, "status", "--porcelain"), stdout = TRUE, stderr = FALSE))) "modified" else "clean",
    error = function(e) "unavailable"
  )
  manifest <- c(
    "Record-Type" = "rrp-distribution",
    "Contract-ID" = "rrp.distribution-manifest",
    "Contract-Version" = "0.1.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Product-Version" = "1.0.0-dev",
    "Development-Version" = "1.0.0-dev",
    "Distribution-ID" = distribution_id,
    "Build-ID" = build_id,
    dependencies$target,
    "Dependency-Specification-ID" = dependencies$id,
    "Resource-Catalog-ID" = resources$header[["Catalog-ID"]],
    "Inventory-Digest" = distribution_sha256(inventory_path),
    "Source-Revision" = source_revision,
    "Source-State" = source_status,
    "Built-At" = built_at
  )
  distribution_write_dcf(list(manifest), file.path(payload, "manifest.dcf"))

  cat("[6/9] Run payload-contained standalone verifier\n")
  verifier_environment <- c("R_PROFILE_USER=", "R_ENVIRON_USER=", "R_LIBS_USER=", "R_LIBS_SITE=")
  result <- system2(file.path(R.home("bin"), "Rscript"),
                    c("--vanilla", file.path(payload, "verify-distribution.R"), payload),
                    stdout = TRUE, stderr = TRUE, env = verifier_environment)
  if (!is.null(attr(result, "status")) && attr(result, "status") != 0L) {
    distribution_stop("standalone_verification", paste(result, collapse = "\n"))
  }

  cat("[7/9] Create archive\n")
  staged_archive <- file.path(stage, "completed.tar")
  old <- setwd(stage)
  on.exit(setwd(old), add = TRUE)
  utils::tar(staged_archive, files = payload_name, compression = "none", tar = "")
  setwd(old)
  if (!file.exists(staged_archive)) distribution_stop("archive", "Archive creation failed.")

  cat("[8/9] Extract and independently verify archive\n")
  extracted <- file.path(stage, "extracted")
  dir.create(extracted)
  utils::untar(staged_archive, exdir = extracted)
  extracted_payload <- file.path(extracted, payload_name)
  result <- system2(file.path(R.home("bin"), "Rscript"),
                    c("--vanilla", file.path(extracted_payload, "verify-distribution.R"), extracted_payload),
                    stdout = TRUE, stderr = TRUE, env = verifier_environment)
  if (!is.null(attr(result, "status")) && attr(result, "status") != 0L) {
    distribution_stop("archive_verification", paste(result, collapse = "\n"))
  }

  cat("[9/9] Promote completed archive\n")
  if (file.exists(output) || !isTRUE(file.rename(staged_archive, output))) {
    distribution_stop("promotion", "Completed archive could not be atomically promoted.")
  }
  cat(sprintf("PASS distribution build\nOutput: %s\nDistribution-ID: %s\n", output, distribution_id))
  invisible(list(output = output, distribution_id = distribution_id,
                 dependency_count = length(dependencies$packages)))
}

passed <- tryCatch({ build_distribution(); TRUE }, error = function(e) {
  cat("FAIL distribution build\n", conditionMessage(e), "\n", file = stderr())
  FALSE
})
if (!passed) quit(save = "no", status = 1L, runLast = FALSE)
