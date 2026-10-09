# Shared, base-R installation mechanics for one verified RRP distribution.
# The distribution-local bootstrap and the installed CLI both delegate here.

rrp_install_fail <- function(code, message) {
  condition <- structure(
    list(message = sprintf("[%s] %s", code, message), call = NULL, code = code),
    class = c("rrp_install_error", "error", "condition")
  )
  stop(condition)
}

rrp_install_scalar <- function(value, label) {
  if (!is.character(value) || length(value) != 1L || is.na(value) ||
      !nzchar(value) || grepl("[[:cntrl:]]", value)) {
    rrp_install_fail("invalid_installation_input", paste(label, "is invalid."))
  }
  value
}

rrp_install_repository <- function(repository) {
  repository <- sub("/+$", "", rrp_install_scalar(repository, "Repository"))
  if (!grepl("^https://[^/?#@]+(?:/[^?#]*)?$", repository, perl = TRUE)) {
    rrp_install_fail(
      "invalid_repository",
      "Repository must be one credential-free explicit HTTPS URL."
    )
  }
  repository
}

rrp_install_default_root <- function() {
  system <- Sys.info()[["sysname"]]
  if (identical(system, "Windows")) {
    base <- Sys.getenv("LOCALAPPDATA", unset = "")
    if (!nzchar(base)) rrp_install_fail(
      "installation_root", "LOCALAPPDATA is unavailable."
    )
    return(file.path(base, "RRP"))
  }
  if (identical(system, "Darwin")) {
    return(file.path(path.expand("~"), "Library", "Application Support", "RRP"))
  }
  base <- Sys.getenv("XDG_DATA_HOME", unset = "")
  if (!nzchar(base)) base <- file.path(path.expand("~"), ".local", "share")
  file.path(base, "rrp")
}

rrp_install_normalize_root <- function(root = NULL) {
  root <- if (is.null(root)) rrp_install_default_root() else
    rrp_install_scalar(root, "Installation root")
  root <- path.expand(root)
  if (!grepl("^(?:/|[A-Za-z]:[/\\\\])", root, perl = TRUE)) {
    rrp_install_fail("installation_root", "Installation root must be absolute.")
  }
  parent <- dirname(root)
  missing <- character()
  while (!dir.exists(parent)) {
    if (identical(parent, dirname(parent))) {
      rrp_install_fail("installation_root", "Installation-root parent is unavailable.")
    }
    missing <- c(basename(parent), missing)
    parent <- dirname(parent)
  }
  parent <- normalizePath(parent, winslash = "/", mustWork = TRUE)
  candidate <- do.call(file.path, as.list(c(parent, missing, basename(root))))
  gsub("\\\\", "/", candidate)
}

rrp_install_assert_plain_directory <- function(path, code) {
  if (!dir.exists(path) || nzchar(Sys.readlink(path))) {
    rrp_install_fail(code, "A required directory is missing or linked.")
  }
  invisible(path)
}

rrp_install_create_directory <- function(path, recursive = FALSE) {
  if (!dir.exists(path) && !dir.create(path, recursive = recursive, showWarnings = FALSE)) {
    rrp_install_fail("installation_root", "An installation directory could not be created.")
  }
  rrp_install_assert_plain_directory(path, "installation_root")
}

rrp_install_copy_tree <- function(source, destination) {
  rrp_install_assert_plain_directory(source, "distribution_root")
  if (file.exists(destination) || dir.exists(destination) ||
      !dir.create(destination, showWarnings = FALSE)) {
    rrp_install_fail("installation_staging", "Distribution staging destination is unavailable.")
  }
  visit <- function(from, to) {
    entries <- list.files(from, all.files = TRUE, full.names = TRUE, no.. = TRUE)
    for (entry in entries) {
      if (nzchar(Sys.readlink(entry))) {
        rrp_install_fail("linked_path", "Distribution staging refused a symbolic link.")
      }
      target <- file.path(to, basename(entry))
      if (dir.exists(entry)) {
        if (!dir.create(target, showWarnings = FALSE)) {
          rrp_install_fail("installation_staging", "A staged directory could not be created.")
        }
        visit(entry, target)
      } else if (!isTRUE(file_test("-f", entry)) || !isTRUE(file.copy(
        entry, target, copy.mode = TRUE, copy.date = FALSE
      ))) {
        rrp_install_fail("installation_staging", "A staged file could not be copied.")
      }
    }
  }
  visit(source, destination)
  invisible(destination)
}

rrp_install_run <- function(command, arguments, environment, code, message) {
  output <- suppressWarnings(system2(
    command, arguments, stdout = TRUE, stderr = TRUE, env = environment
  ))
  status <- attr(output, "status")
  if (!is.null(status) && status != 0L) rrp_install_fail(code, message)
  output
}

rrp_install_host <- function(host_r_executable) {
  host_r_executable <- normalizePath(
    rrp_install_scalar(host_r_executable, "Host R executable"),
    winslash = "/", mustWork = TRUE
  )
  if (dir.exists(host_r_executable)) rrp_install_fail(
    "incompatible_host_r", "Host R executable is not a regular executable."
  )
  expression <- paste(
    "cat(as.character(getRversion()), R.version$platform, R.version$arch,",
    "normalizePath(file.path(R.home('bin'), 'R'), winslash='/', mustWork=TRUE),",
    "sep='\\n')"
  )
  environment <- c(
    "R_PROFILE_USER=", "R_ENVIRON_USER=", "R_LIBS_USER=", "R_LIBS_SITE="
  )
  output <- rrp_install_run(
    host_r_executable, c("--vanilla", "--slave", "-e", shQuote(expression)),
    environment, "incompatible_host_r", "Host R could not establish its target identity."
  )
  if (length(output) != 4L || !identical(
    normalizePath(output[[4L]], winslash = "/", mustWork = TRUE),
    host_r_executable
  )) rrp_install_fail(
    "incompatible_host_r", "Host R selection is not canonical."
  )
  c(
    version = output[[1L]], platform = output[[2L]],
    architecture = output[[3L]], executable = host_r_executable
  )
}

rrp_install_dcf <- function(path, code) {
  if (!file.exists(path) || !isTRUE(file_test("-f", path)) ||
      nzchar(Sys.readlink(path))) {
    rrp_install_fail(code, "Required installation metadata is missing or nonregular.")
  }
  tryCatch(
    lapply(seq_len(nrow(value <- read.dcf(path, all = TRUE))), function(index) {
      row <- value[index, , drop = TRUE]
      unlist(row[!is.na(row)], use.names = TRUE)
    }),
    error = function(condition) rrp_install_fail(code, "Installation metadata is invalid DCF.")
  )
}

rrp_install_write_dcf <- function(record, path) {
  matrix <- matrix(unname(record), nrow = 1L, dimnames = list(NULL, names(record)))
  write.dcf(matrix, file = path, width = 500L)
}

rrp_install_validate_record <- function(record) {
  fields <- c(
    "Record-Type", "Contract-ID", "Contract-Version", "Installation-ID",
    "Product-ID", "Product-Version", "Development-Version", "Distribution-ID",
    "Build-ID", "Dependency-Specification-ID", "Host-R-Executable",
    "Host-R-Version", "Platform", "Architecture", "Private-Library",
    "Resource-Root", "Distribution-Manifest-Digest", "Installed-At"
  )
  if (!is.character(record) || !identical(names(record), fields) ||
      !identical(unname(record[c(
        "Record-Type", "Contract-ID", "Contract-Version", "Product-ID",
        "Product-Version", "Development-Version"
      )]), c(
        "rrp-installation", "rrp.installation-record", "0.1.0",
        "readmission-risk-pool-platform", "1.0.0-dev", "1.0.0-dev"
      )) || any(!grepl("^[0-9a-f]{64}$", record[c(
        "Installation-ID", "Distribution-ID", "Build-ID",
        "Dependency-Specification-ID", "Distribution-Manifest-Digest"
      )])) || !grepl(
        "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
        record[["Installed-At"]]
      ) || any(!nzchar(record))) {
    rrp_install_fail("installation_record", "Installation evidence is invalid.")
  }
  invisible(record)
}

rrp_install_hash_lines <- function(lines) {
  path <- tempfile("rrp-installation-identity-")
  on.exit(unlink(path, force = TRUE), add = TRUE)
  writeLines(lines, path, useBytes = TRUE)
  rrp_sha256(path)
}

rrp_install_target <- function(manifest, dependencies, host, repository) {
  header <- dependencies[[1L]]
  fields <- c(
    "Target-R-Version" = "version", "Target-Platform" = "platform",
    "Target-Architecture" = "architecture"
  )
  for (field in names(fields)) {
    if (!identical(header[[field]], unname(host[[fields[[field]]]])) ||
        !identical(manifest[[field]], header[[field]])) {
      rrp_install_fail("incompatible_host_r", "Host R does not match the distribution target.")
    }
  }
  repositories <- unique(vapply(
    dependencies[-1L], `[[`, character(1L), "Repository"
  ))
  repositories <- sub("/+$", "", repositories)
  if (length(repositories) != 1L || !identical(repositories, repository)) {
    rrp_install_fail(
      "repository_mismatch",
      "Configured repository does not match the dependency specification."
    )
  }
  invisible(TRUE)
}

rrp_install_environment <- function(private_library) c(
  "R_PROFILE_USER=", "R_ENVIRON_USER=",
  "R_LIBS=",
  paste0("R_LIBS_USER=", private_library),
  paste0("R_LIBS_SITE=", file.path(private_library, ".rrp-no-site-library")),
  "RENV_CONFIG_CACHE_ENABLED=FALSE", "RENV_CONFIG_AUTOLOADER_ENABLED=FALSE"
)

rrp_install_restore_dependencies <- function(
  host, dependencies, private_library, repository, tool_library
) {
  dir.create(tool_library)
  bootstrap <- paste0(
    "options(repos=c(CRAN=", encodeString(repository, quote = "\""), "));",
    "install.packages('renv',lib=", encodeString(tool_library, quote = "\""),
    ",dependencies=FALSE,quiet=TRUE)"
  )
  base_environment <- rrp_install_environment(tool_library)
  rrp_install_run(
    host[["executable"]], c("--vanilla", "--slave", "-e", shQuote(bootstrap)),
    base_environment, "dependency_restoration",
    "The private dependency restoration engine could not be obtained."
  )
  packages <- dependencies[-1L]
  specifications <- vapply(packages, function(record) paste0(
    record[["Package"]], "@", record[["Version"]]
  ), character(1L))
  restore <- paste0(
    ".libPaths(c(", encodeString(tool_library, quote = "\""), ",.Library));",
    "renv::install(c(",
    paste(vapply(specifications, encodeString, character(1L), quote = "\""),
      collapse = ","),
    "),library=", encodeString(private_library, quote = "\""),
    ",repos=c(CRAN=", encodeString(repository, quote = "\""),
    "),prompt=FALSE,rebuild=TRUE,dependencies=FALSE,lock=FALSE)"
  )
  rrp_install_run(
    host[["executable"]], c("--vanilla", "--slave", "-e", shQuote(restore)),
    base_environment, "dependency_restoration",
    "The exact private dependency closure could not be restored."
  )
  invisible(TRUE)
}

rrp_install_internal_packages <- function(host, distribution_root, private_library) {
  archives <- list.files(
    file.path(distribution_root, "packages"), pattern = "[.]tar[.]gz$",
    full.names = TRUE
  )
  descriptions <- lapply(c("rrpruntime", "rrpplatform"), function(package) {
    matches <- archives[startsWith(basename(archives), paste0(package, "_"))]
    if (length(matches) != 1L) rrp_install_fail(
      "internal_package", "An exact internal package artifact is unavailable."
    )
    list(path = matches[[1L]], description = rrp_package_description(matches[[1L]], package))
  })
  names(descriptions) <- c("rrpruntime", "rrpplatform")
  environment <- rrp_install_environment(private_library)
  for (package in names(descriptions)) {
    rrp_install_run(
      host[["executable"]], c(
        "CMD", "INSTALL", paste0("--library=", shQuote(private_library)),
        shQuote(descriptions[[package]]$path)
      ),
      environment, "internal_package",
      paste("The", package, "package could not be installed.")
    )
  }
  lapply(descriptions, `[[`, "description")
}

rrp_install_verify_realization <- function(
  host, distribution_root, private_library, dependencies, internal_descriptions
) {
  packages <- dependencies[-1L]
  expected_names <- c(
    vapply(packages, `[[`, character(1L), "Package"),
    "rrpruntime", "rrpplatform"
  )
  expected_versions <- c(
    setNames(vapply(packages, `[[`, character(1L), "Version"),
      vapply(packages, `[[`, character(1L), "Package")),
    rrpruntime = unname(internal_descriptions$rrpruntime[["Version"]]),
    rrpplatform = unname(internal_descriptions$rrpplatform[["Version"]])
  )
  expected_integrity <- setNames(
    sub("^renv:", "", vapply(packages, `[[`, character(1L), "Integrity")),
    vapply(packages, `[[`, character(1L), "Package")
  )
  script <- tempfile("rrp-install-verify-", fileext = ".R")
  on.exit(unlink(script, force = TRUE), add = TRUE)
  lines <- c(
    paste0("private_library <- ", encodeString(private_library, quote = "\"")),
    paste0("software_root <- ", encodeString(distribution_root, quote = "\"")),
    paste0("expected_names <- c(", paste(vapply(expected_names, encodeString,
      character(1L), quote = "\""), collapse = ","), ")"),
    paste0("expected_versions <- c(", paste(sprintf(
      "%s=%s", vapply(names(expected_versions), encodeString, character(1L), quote = "\""),
      vapply(unname(expected_versions), encodeString, character(1L), quote = "\"")
    ), collapse = ","), ")"),
    paste0("expected_integrity <- c(", paste(sprintf(
      "%s=%s", vapply(names(expected_integrity), encodeString, character(1L), quote = "\""),
      vapply(unname(expected_integrity), encodeString, character(1L), quote = "\"")
    ), collapse = ","), ")"),
    ".libPaths(c(private_library,.Library))",
    "database <- installed.packages(lib.loc=private_library,noCache=TRUE)",
    "stopifnot(setequal(rownames(database),expected_names))",
    "paths <- vapply(expected_names,find.package,character(1L),quiet=TRUE)",
    "prefix <- paste0(normalizePath(private_library,winslash='/'),'/')",
    "stopifnot(all(startsWith(normalizePath(paths,winslash='/'),prefix)))",
    "stopifnot(identical(unname(database[names(expected_versions),'Version']),unname(expected_versions)))",
    "description_hash <- function(path) {",
    "  dcf <- read.dcf(path,all=TRUE)[1L,,drop=TRUE]",
    "  fields <- c('Package','Version','Title','Author','Maintainer','Description','Depends','Imports','Suggests','LinkingTo')",
    "  selected <- dcf[intersect(fields,names(dcf))]",
    "  selected <- selected[sort(names(selected),method='radix')]",
    "  text <- gsub('[[:space:]]','',paste(names(selected),selected,sep=': ',collapse='\\n'))",
    "  temporary <- tempfile(); on.exit(unlink(temporary,force=TRUE),add=TRUE)",
    "  writeLines(enc2utf8(text),temporary,useBytes=TRUE)",
    "  unname(tools::md5sum(temporary))",
    "}",
    "actual_integrity <- vapply(names(expected_integrity),function(package) description_hash(file.path(paths[[package]],'DESCRIPTION')),character(1L))",
    "stopifnot(identical(unname(actual_integrity),unname(expected_integrity)))",
    "library(rrpplatform)",
    "result <- rrp_validate_software_resources(software_root)",
    "stopifnot(rrp_operation_succeeded(result))",
    "status <- rrp_cli_dispatch(c('version','--json'),software_root,private_library,",
    "  normalizePath(file.path(R.home('bin'),'R'),winslash='/',mustWork=TRUE))",
    "stopifnot(identical(status,0L))"
  )
  writeLines(lines, script, useBytes = TRUE)
  rrp_install_run(
    host[["executable"]], c("--vanilla", "--slave", shQuote(script)),
    rrp_install_environment(private_library), "installation_verification",
    "Fresh-process package, resource, or dependency verification failed."
  )
  invisible(TRUE)
}

rrp_install_record <- function(
  manifest, dependencies, host, destination, installed_at,
  manifest_root = destination
) {
  manifest_digest <- rrp_sha256(file.path(manifest_root, "manifest.dcf"))
  identity <- rrp_install_hash_lines(c(
    "rrp-installation-identity-v1",
    paste0("distribution=", manifest[["Distribution-ID"]]),
    paste0("build=", manifest[["Build-ID"]]),
    paste0("dependencies=", manifest[["Dependency-Specification-ID"]]),
    paste0("r-version=", host[["version"]]),
    paste0("platform=", host[["platform"]]),
    paste0("architecture=", host[["architecture"]]),
    paste0("manifest=", manifest_digest)
  ))
  record <- c(
    "Record-Type" = "rrp-installation",
    "Contract-ID" = "rrp.installation-record",
    "Contract-Version" = "0.1.0",
    "Installation-ID" = identity,
    "Product-ID" = manifest[["Product-ID"]],
    "Product-Version" = manifest[["Product-Version"]],
    "Development-Version" = manifest[["Development-Version"]],
    "Distribution-ID" = manifest[["Distribution-ID"]],
    "Build-ID" = manifest[["Build-ID"]],
    "Dependency-Specification-ID" = dependencies[[1L]][["Specification-ID"]],
    "Host-R-Executable" = host[["executable"]],
    "Host-R-Version" = host[["version"]],
    "Platform" = host[["platform"]],
    "Architecture" = host[["architecture"]],
    "Private-Library" = file.path(destination, "library"),
    "Resource-Root" = destination,
    "Distribution-Manifest-Digest" = manifest_digest,
    "Installed-At" = installed_at
  )
  rrp_install_validate_record(record)
  record
}

rrp_install_verify_payload_projection <- function(root) {
  inventory <- rrp_install_dcf(file.path(root, "inventory.dcf"), "installation_conflict")
  if (length(inventory) < 2L) rrp_install_fail(
    "installation_conflict", "Installed distribution inventory is incomplete."
  )
  paths <- vapply(inventory[-1L], `[[`, character(1L), "Path")
  if (any(!vapply(paths, rrp_safe_relative_path, logical(1L)))) rrp_install_fail(
    "installation_conflict", "Installed distribution inventory is unsafe."
  )
  projection <- tempfile("rrp-installed-payload-")
  dir.create(projection)
  on.exit(unlink(projection, recursive = TRUE, force = TRUE), add = TRUE)
  for (path in c("manifest.dcf", "inventory.dcf", paths)) {
    source <- file.path(root, path)
    destination <- file.path(projection, path)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    if (!isTRUE(file.copy(source, destination, copy.mode = TRUE, copy.date = FALSE))) {
      rrp_install_fail("installation_conflict", "Installed distribution evidence is incomplete.")
    }
  }
  rrp_verify_distribution(projection)
}

rrp_install_existing <- function(
  destination, expected, host, dependencies, internal_descriptions
) {
  records <- rrp_install_dcf(file.path(destination, "INSTALLATION.dcf"), "installation_conflict")
  if (length(records) != 1L ||
      !identical(records[[1L]][names(expected)[names(expected) != "Installed-At"]],
        expected[names(expected) != "Installed-At"])) {
    rrp_install_fail(
      "installation_conflict", "Existing installation identity or evidence conflicts."
    )
  }
  rrp_install_validate_record(records[[1L]])
  rrp_install_verify_payload_projection(destination)
  rrp_install_verify_realization(
    host, destination, file.path(destination, "library"), dependencies,
    internal_descriptions
  )
  records[[1L]]
}

rrp_install_make_read_only <- function(root) {
  entries <- list.files(root, all.files = TRUE, full.names = TRUE,
    recursive = TRUE, include.dirs = TRUE, no.. = TRUE)
  files <- entries[!dir.exists(entries)]
  directories <- c(entries[dir.exists(entries)], root)
  file_status <- if (length(files)) {
    Sys.chmod(files, mode = "0444", use_umask = FALSE)
  } else logical()
  executables <- c(file.path(root, "bin", "rrp"), file.path(root, "install.R"))
  executables <- executables[file.exists(executables)]
  executable_status <- if (length(executables)) {
    Sys.chmod(executables, mode = "0555", use_umask = FALSE)
  } else logical()
  directory_status <- if (length(directories)) {
    Sys.chmod(directories, mode = "0555", use_umask = FALSE)
  } else logical()
  if (any(!c(file_status, executable_status, directory_status))) {
    rrp_install_fail(
      "installation_promotion", "Promoted installation could not be made immutable."
    )
  }
  invisible(root)
}

rrp_install_result <- function(record, destination, reused) list(
  installation_id = unname(record[["Installation-ID"]]),
  product_version = unname(record[["Product-Version"]]),
  distribution_id = unname(record[["Distribution-ID"]]),
  build_id = unname(record[["Build-ID"]]),
  dependency_specification_id = unname(record[["Dependency-Specification-ID"]]),
  installation_root = destination,
  private_library = unname(record[["Private-Library"]]),
  resource_root = unname(record[["Resource-Root"]]),
  host_r_version = unname(record[["Host-R-Version"]]),
  platform = unname(record[["Platform"]]),
  architecture = unname(record[["Architecture"]]),
  reused = isTRUE(reused)
)

rrp_install_distribution <- function(
  distribution_root, repository, host_r_executable,
  installation_root = NULL, progress = function(message) invisible(message),
  failure_stage = ""
) {
  if (!is.function(progress)) rrp_install_fail(
    "invalid_installation_input", "Progress handler is invalid."
  )
  distribution_root <- normalizePath(
    rrp_install_scalar(distribution_root, "Distribution root"),
    winslash = "/", mustWork = TRUE
  )
  repository <- rrp_install_repository(repository)
  host <- rrp_install_host(host_r_executable)
  progress("Verify distribution")
  verified <- rrp_verify_distribution(distribution_root)
  manifest <- verified$manifest
  dependencies <- verified$dependencies
  rrp_install_target(manifest, dependencies, host, repository)

  root <- rrp_install_normalize_root(installation_root)
  rrp_install_create_directory(root, recursive = TRUE)
  installations <- file.path(root, "installations")
  staging <- file.path(root, "staging")
  rrp_install_create_directory(installations)
  rrp_install_create_directory(staging)
  version_root <- file.path(installations, manifest[["Product-Version"]])
  rrp_install_create_directory(version_root)
  destination <- file.path(version_root, manifest[["Distribution-ID"]])
  lock <- file.path(staging, paste0(
    ".lock-", manifest[["Product-Version"]], "-", manifest[["Distribution-ID"]]
  ))
  if (!dir.create(lock, showWarnings = FALSE)) rrp_install_fail(
    "installation_locked", "An installation of this exact distribution is already in progress."
  )
  on.exit(if (dir.exists(lock)) unlink(lock, recursive = TRUE, force = TRUE), add = TRUE)

  internal_descriptions <- lapply(c("rrpruntime", "rrpplatform"), function(package) {
    archives <- list.files(file.path(distribution_root, "packages"),
      pattern = paste0("^", package, "_.*[.]tar[.]gz$"), full.names = TRUE)
    if (length(archives) != 1L) rrp_install_fail(
      "internal_package", "An exact internal package artifact is unavailable."
    )
    rrp_package_description(archives[[1L]], package)
  })
  names(internal_descriptions) <- c("rrpruntime", "rrpplatform")
  prospective <- rrp_install_record(
    manifest, dependencies, host, destination,
    format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    manifest_root = distribution_root
  )
  if (dir.exists(destination) || file.exists(destination)) {
    if (!dir.exists(destination) || nzchar(Sys.readlink(destination))) {
      rrp_install_fail("installation_conflict", "Existing installation target is unsafe.")
    }
    progress("Validate identical existing installation")
    record <- rrp_install_existing(
      destination, prospective, host, dependencies, internal_descriptions
    )
    return(rrp_install_result(record, destination, TRUE))
  }

  stage <- tempfile(".stage-", tmpdir = staging)
  if (!dir.create(stage, showWarnings = FALSE)) rrp_install_fail(
    "installation_staging", "Installation staging could not be created."
  )
  on.exit(if (dir.exists(stage)) unlink(stage, recursive = TRUE, force = TRUE), add = TRUE)
  progress("Stage verified distribution")
  payload_stage <- file.path(stage, "payload")
  rrp_install_copy_tree(distribution_root, payload_stage)
  rrp_verify_distribution(payload_stage)
  installation_stage <- file.path(stage, "installation")
  if (!dir.create(installation_stage, showWarnings = FALSE)) rrp_install_fail(
    "installation_staging", "Installation realization could not be staged."
  )
  entries <- list.files(payload_stage, all.files = TRUE, full.names = TRUE, no.. = TRUE)
  if (!all(file.rename(entries, file.path(installation_stage, basename(entries))))) {
    rrp_install_fail("installation_staging", "Distribution content could not be staged.")
  }
  unlink(payload_stage, recursive = TRUE, force = TRUE)
  private_library <- file.path(installation_stage, "library")
  dir.create(private_library)
  tool_library <- file.path(stage, "restoration-tool")

  controlled_failures <- c(
    before_restoration = "dependency_restoration",
    before_internal_packages = "internal_package",
    before_verification = "installation_verification",
    before_promotion = "installation_promotion"
  )
  if (failure_stage %in% names(controlled_failures)) rrp_install_fail(
    unname(controlled_failures[[failure_stage]]),
    "Controlled installation failure."
  )
  progress("Restore exact private dependency closure")
  rrp_install_restore_dependencies(
    host, dependencies, private_library, repository, tool_library
  )
  progress("Install exact RRP packages")
  internal_descriptions <- rrp_install_internal_packages(
    host, installation_stage, private_library
  )
  progress("Verify staged installation in a fresh process")
  rrp_install_verify_realization(
    host, installation_stage, private_library, dependencies,
    internal_descriptions
  )
  record <- rrp_install_record(
    manifest, dependencies, host, destination,
    format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    manifest_root = installation_stage
  )
  rrp_install_write_dcf(record, file.path(installation_stage, "INSTALLATION.dcf"))
  progress("Promote immutable installation")
  if (file.exists(destination) || dir.exists(destination) ||
      !isTRUE(file.rename(installation_stage, destination))) {
    rrp_install_fail(
      "installation_promotion", "Completed installation could not be atomically promoted."
    )
  }
  tryCatch(
    rrp_install_make_read_only(destination),
    error = function(condition) {
      entries <- list.files(
        destination, all.files = TRUE, full.names = TRUE, recursive = TRUE,
        include.dirs = TRUE, no.. = TRUE
      )
      if (length(entries)) Sys.chmod(entries, mode = "0755", use_umask = FALSE)
      Sys.chmod(destination, mode = "0755", use_umask = FALSE)
      unlink(destination, recursive = TRUE, force = TRUE)
      stop(condition)
    }
  )
  rrp_install_result(record, destination, FALSE)
}

rrp_install_engine_arguments <- function(arguments) {
  values <- list(
    distribution = NULL, repository = NULL, installation_root = NULL,
    result = NULL
  )
  index <- 1L
  while (index <= length(arguments)) {
    name <- switch(arguments[[index]],
      "--distribution" = "distribution",
      "--repository" = "repository",
      "--installation-root" = "installation_root",
      "--result" = "result",
      NULL
    )
    if (is.null(name) || index == length(arguments) ||
        startsWith(arguments[[index + 1L]], "--") || !is.null(values[[name]])) {
      rrp_install_fail("invalid_installation_input", "Installer invocation is invalid.")
    }
    values[[name]] <- arguments[[index + 1L]]
    index <- index + 2L
  }
  if (any(vapply(values[c("distribution", "repository", "result")], is.null,
    logical(1L)))) rrp_install_fail(
    "invalid_installation_input", "Installer invocation is incomplete."
  )
  values
}

rrp_install_engine_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  values <- rrp_install_engine_arguments(arguments)
  result_path <- path.expand(values$result)
  parent <- normalizePath(dirname(result_path), winslash = "/", mustWork = TRUE)
  result_path <- file.path(parent, basename(result_path))
  if (file.exists(result_path) || dir.exists(result_path)) rrp_install_fail(
    "invalid_installation_input", "Installer result destination must be absent."
  )
  result <- rrp_install_distribution(
    values$distribution, values$repository,
    normalizePath(file.path(R.home("bin"), "R"), winslash = "/", mustWork = TRUE),
    values$installation_root
  )
  record <- c(
    "Record-Type" = "rrp-install-result",
    "Installation-ID" = result$installation_id,
    "Product-Version" = result$product_version,
    "Distribution-ID" = result$distribution_id,
    "Build-ID" = result$build_id,
    "Dependency-Specification-ID" = result$dependency_specification_id,
    "Installation-Root" = result$installation_root,
    "Private-Library" = result$private_library,
    "Resource-Root" = result$resource_root,
    "Host-R-Version" = result$host_r_version,
    "Platform" = result$platform,
    "Architecture" = result$architecture,
    "Reused" = if (result$reused) "true" else "false"
  )
  rrp_install_write_dcf(record, result_path)
  invisible(result)
}

if (sys.nframe() == 0L) {
  script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  status <- tryCatch({
    if (length(script_argument) != 1L) rrp_install_fail(
      "invalid_installation_input", "Cannot determine installer-engine path."
    )
    script_path <- normalizePath(sub("^--file=", "", script_argument),
      winslash = "/", mustWork = TRUE)
    source(file.path(dirname(script_path), "verify-distribution.R"), local = TRUE)
    rrp_install_engine_main()
    0L
  }, error = function(condition) {
    cat(conditionMessage(condition), "\n", file = stderr())
    1L
  })
  quit(save = "no", status = status, runLast = FALSE)
}
