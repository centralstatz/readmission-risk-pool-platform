# Repository-wide Phase 0 policy checks.
#
# These checks catch obvious portability, dependency, secret, and fixture
# mistakes. They supplement human review; they do not claim to detect all PHI
# or confidential information.

rrp_repository_files <- function(repository_root) {
  files <- list.files(
    repository_root,
    recursive = TRUE,
    all.files = TRUE,
    full.names = FALSE,
    include.dirs = FALSE,
    no.. = TRUE
  )
  excluded <- grepl(
    paste0(
      "^([.]git|build|[.]cache|[.]tmp|tmp|",
      "renv/(library|local|cellar|lock|python|sandbox|staging))(/|$)"
    ),
    files
  )
  files[!excluded]
}

rrp_is_documentation_file <- function(path) {
  grepl("[.](md|qmd)$", path, ignore.case = TRUE)
}

rrp_is_text_file <- function(path) {
  basename(path) %in% c(".editorconfig", ".gitignore") ||
    grepl(
      "[.](R|Rmd|qmd|md|txt|csv|json|ya?ml|toml|ini|cfg|conf|sh|py|sql)$",
      path,
      ignore.case = TRUE
    )
}

rrp_read_text <- function(path) {
  tryCatch(
    readLines(path, warn = FALSE, encoding = "UTF-8"),
    error = function(condition) character()
  )
}

rrp_sibling_reference_marker <- function() {
  paste0("..", "/", "readmission-risk-pool")
}

rrp_allowed_sibling_reference_documents <- function() {
  c(
    "README.md",
    "AGENTS.md",
    "docs/START-HERE.md",
    "docs/vision/platform-true-north.md",
    "docs/architecture/platform-architecture.md",
    "docs/architecture/platform-implementation-plan.md",
    "docs/architecture/reference-asset-reconciliation.md",
    "docs/architecture/platform-implementation-record.md",
    "docs/development/repository-policies.md",
    "docs/operations/validation.md"
  )
}

rrp_phase10_configuration_authorized <- function(repository_root) {
  configuration_root <- file.path(repository_root, "config")
  if (!dir.exists(configuration_root)) return(FALSE)
  files <- sort(list.files(
    configuration_root, recursive = TRUE, all.files = TRUE,
    include.dirs = FALSE, no.. = TRUE
  ))
  identical(files, "platform-instance.yml") &&
    file.exists(file.path(
      repository_root, "contracts", "canonical", "canonical-producer.yml"
    )) &&
    file.exists(file.path(
      repository_root, "operations", "compositions", "installed-producers.R"
    ))
}

rrp_sensitive_filename <- function(path) {
  name <- basename(path)
  lower <- tolower(name)
  env_file <- identical(lower, ".env") ||
    (startsWith(lower, ".env.") && !identical(lower, ".env.example"))
  secret_file <- grepl(
    "(^|[._-])(credentials?|secrets?|access[-_]?keys?)([._-]|$)",
    lower,
    perl = TRUE
  ) || grepl("[.](pem|p12|pfx|key)$", lower)
  env_file || secret_file
}

rrp_secret_content_patterns <- function() {
  c(
    private_key = paste("BEGIN", ".*PRIVATE KEY"),
    aws_access_key = paste0("AK", "IA[0-9A-Z]{16}"),
    github_token = paste0("gh", "[pousr]_[A-Za-z0-9]{20,}")
  )
}

rrp_patient_like_fixture <- function(path, lines) {
  fixture_path <- grepl("(^|/)(fixtures|examples)(/|$)", path)
  data_file <- grepl("[.](csv|json|txt|ya?ml)$", path, ignore.case = TRUE)
  patient_fields <- grepl(
    "patient_id|patient_name|medical_record_number|(^|[^A-Za-z])mrn([^A-Za-z]|$)",
    paste(lines, collapse = "\n"),
    ignore.case = TRUE,
    perl = TRUE
  )
  fixture_path && data_file && patient_fields
}

rrp_fixture_is_visibly_fictional <- function(lines) {
  grepl(
    "fictional|synthetic|nonclinical",
    paste(lines, collapse = "\n"),
    ignore.case = TRUE,
    perl = TRUE
  )
}

rrp_validate_repository_policies <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  files <- rrp_repository_files(repository_root)
  checks <- list()
  issues <- list()

  # Development-time sibling discussion belongs in documentation. Executable
  # and configuration files may never make the sibling a dependency.
  sibling_count <- 0L
  marker <- rrp_sibling_reference_marker()
  allowed_reference_documents <- rrp_allowed_sibling_reference_documents()
  documentation_files <- files[vapply(files, rrp_is_documentation_file, logical(1))]
  for (file in documentation_files) {
    lines <- rrp_read_text(file.path(repository_root, file))
    matches <- grep(marker, lines, fixed = TRUE)
    if (length(matches) > 0L && !file %in% allowed_reference_documents) {
      for (line_number in matches) {
        sibling_count <- sibling_count + 1L
        issues[[length(issues) + 1L]] <- rrp_issue(
          "sibling_independence", "unapproved_sibling_reference_document",
          "Sibling path appears outside approved architecture/reference guidance.",
          file, line_number
        )
      }
    }
  }
  for (file in files[!vapply(files, rrp_is_documentation_file, logical(1))]) {
    path <- file.path(repository_root, file)
    if (!rrp_is_text_file(file)) next
    lines <- rrp_read_text(path)
    matches <- grep(marker, lines, fixed = TRUE)
    for (line_number in matches) {
      sibling_count <- sibling_count + 1L
      issues[[length(issues) + 1L]] <- rrp_issue(
        "sibling_independence", "executable_sibling_reference",
        "Executable or configuration content references the sibling repository.",
        file, line_number
      )
    }
  }

  symlink_count <- 0L
  for (file in files) {
    target <- Sys.readlink(file.path(repository_root, file))
    if (nzchar(target) && grepl(marker, target, fixed = TRUE)) {
      symlink_count <- symlink_count + 1L
      issues[[length(issues) + 1L]] <- rrp_issue(
        "sibling_independence", "sibling_symlink",
        "Symlink target depends on the sibling repository.", file
      )
    }
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "sibling_independence", sibling_count + symlink_count == 0L,
    "approved documentation-only sibling references"
  )

  portability_count <- 0L
  for (file in files[vapply(files, rrp_is_text_file, logical(1))]) {
    if (rrp_is_documentation_file(file)) next
    lines <- rrp_read_text(file.path(repository_root, file))
    machine_lines <- grep(rrp_machine_path_pattern(), lines, perl = TRUE)
    uri_lines <- grep(rrp_local_file_uri(), lines, fixed = TRUE)
    for (line_number in machine_lines) {
      portability_count <- portability_count + 1L
      issues[[length(issues) + 1L]] <- rrp_issue(
        "portable_repository_paths", "machine_specific_path",
        "Executable or configuration content contains a machine-specific path.",
        file, line_number
      )
    }
    for (line_number in uri_lines) {
      portability_count <- portability_count + 1L
      issues[[length(issues) + 1L]] <- rrp_issue(
        "portable_repository_paths", "local_file_uri",
        "Executable or configuration content contains a local-file URI.",
        file, line_number
      )
    }
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "portable_repository_paths", portability_count == 0L,
    "no machine-specific executable paths"
  )

  sensitive_files <- files[vapply(files, rrp_sensitive_filename, logical(1))]
  for (file in sensitive_files) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "secrets_policy", "sensitive_filename",
      "Repository contains a file whose name indicates credentials or secrets.", file
    )
  }

  secret_count <- 0L
  patterns <- rrp_secret_content_patterns()
  for (file in files[vapply(files, rrp_is_text_file, logical(1))]) {
    lines <- rrp_read_text(file.path(repository_root, file))
    for (pattern_name in names(patterns)) {
      matches <- grep(patterns[[pattern_name]], lines, perl = TRUE)
      for (line_number in matches) {
        secret_count <- secret_count + 1L
        issues[[length(issues) + 1L]] <- rrp_issue(
          "secrets_policy", paste0("possible_", pattern_name),
          "Repository contains content resembling a secret.", file, line_number
        )
      }
    }
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "secrets_policy", length(sensitive_files) + secret_count == 0L,
    "no obvious secret files or token patterns"
  )

  fixture_count <- 0L
  for (file in files) {
    if (!grepl("[.](csv|json|txt|ya?ml)$", file, ignore.case = TRUE)) next
    lines <- rrp_read_text(file.path(repository_root, file))
    if (rrp_patient_like_fixture(file, lines) && !rrp_fixture_is_visibly_fictional(lines)) {
      fixture_count <- fixture_count + 1L
      issues[[length(issues) + 1L]] <- rrp_issue(
        "fictional_fixture_policy", "unlabelled_patient_fixture",
        paste(
          "Patient-like fixture is not visibly classified as fictional,",
          "synthetic, or nonclinical."
        ),
        file
      )
    }
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "fictional_fixture_policy", fixture_count == 0L,
    "patient-like fixtures require visible fictional classification"
  )

  rrp_validation_result(
    "Repository policy validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase0_checkpoint <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()

  required_files <- c(
    ".editorconfig",
    ".gitignore",
    "LICENSE-STATUS.md",
    "docs/development/repository-policies.md",
    "docs/operations/README.md",
    "docs/operations/validation.md",
    "operations/validate-documentation.R",
    "operations/validate.R",
    "operations/lib/validation-result.R",
    "operations/lib/documentation-validation.R",
    "operations/lib/repository-validation.R",
    "operations/lib/platform-validation.R",
    "tests/run-phase0-tests.R"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (file in missing) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase0_required_files", "missing_phase0_file",
      "Required Phase 0 file is missing.", file
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase0_required_files", length(missing) == 0L,
    paste(length(required_files), "required Phase 0 files")
  )

  deferred_directories <- c("observability")
  premature <- deferred_directories[
    dir.exists(file.path(repository_root, deferred_directories))
  ]
  if (dir.exists(file.path(repository_root, "config")) &&
      !rrp_phase10_configuration_authorized(repository_root)) {
    premature <- c(premature, "config")
  }
  for (directory in premature) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase0_scope", "premature_architecture_directory",
      "Directory belongs to a later implementation phase.", directory
    )
  }

  checks[[length(checks) + 1L]] <- rrp_check(
    "phase0_scope", length(premature) == 0L,
    "no still-unauthorized configuration or observability scaffolding"
  )

  license_path <- file.path(repository_root, "LICENSE-STATUS.md")
  license_text <- if (file.exists(license_path)) {
    paste(rrp_read_text(license_path), collapse = "\n")
  } else {
    ""
  }
  license_ok <- grepl(
    "no public release[[:space:]]+is[[:space:]]+authorized",
    license_text,
    perl = TRUE
  ) &&
    grepl("not a software[[:space:]]+license", license_text, perl = TRUE)
  if (!license_ok) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "license_status", "unclear_license_status",
      "License notice must state that no release is authorized and no license is supplied.",
      "LICENSE-STATUS.md"
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "license_status", license_ok,
    "explicit non-release policy without provisional legal terms"
  )

  validation_doc <- file.path(repository_root, "docs", "operations", "validation.md")
  agent_doc <- file.path(repository_root, "AGENTS.md")
  operation_commands <- c(
    "Rscript operations/validate-documentation.R",
    "Rscript operations/validate.R --mode development",
    "Rscript operations/validate.R --mode checkpoint",
    "Rscript tests/run-phase0-tests.R",
    "Rscript tests/run-phase1-tests.R",
    "Rscript tests/run-phase2-tests.R",
    "Rscript tests/run-phase3-tests.R",
    "Rscript operations/generate-reference.R",
    "Rscript tests/run-phase4-tests.R",
    "Rscript tests/run-phase5-tests.R",
    "Rscript tests/run-phase6-tests.R",
    "Rscript tests/run-phase7-tests.R",
    "Rscript tests/run-phase8-tests.R",
    "Rscript tests/run-phase9-tests.R",
    "Rscript operations/run-reference-runtime.R",
    "Rscript operations/run-reference-history.R --scale test",
    "Rscript operations/build-reference-products.R --scale test",
    "Rscript operations/build-reference-products.R --scale test --materialize",
    "Rscript operations/launch-reference-app.R --validate-only",
    "Rscript operations/build-application-artifact.R",
    "Rscript operations/validate-application-artifact.R",
    "Rscript operations/build-connect-cloud-deployment.R --destination PATH",
    "Rscript operations/validate-connect-cloud-deployment.R --destination PATH"
  )
  operations_text <- if (file.exists(validation_doc)) {
    paste(rrp_read_text(validation_doc), collapse = "\n")
  } else {
    ""
  }
  agents_text <- if (file.exists(agent_doc)) {
    paste(rrp_read_text(agent_doc), collapse = "\n")
  } else {
    ""
  }
  undocumented <- operation_commands[!vapply(
    operation_commands,
    function(command) grepl(command, operations_text, fixed = TRUE),
    logical(1)
  )]
  agent_commands <- c(
    operation_commands[2:3],
    "Rscript tests/run-phase6-tests.R",
    "Rscript tests/run-phase7-tests.R",
    "Rscript tests/run-phase8-tests.R",
    "Rscript tests/run-phase9-tests.R",
    "Rscript operations/build-reference-products.R --scale test",
    "Rscript operations/build-application-artifact.R",
    "Rscript operations/validate-application-artifact.R",
    "Rscript operations/build-connect-cloud-deployment.R --destination PATH",
    "Rscript operations/validate-connect-cloud-deployment.R --destination PATH"
  )
  agent_missing <- agent_commands[!vapply(
    agent_commands,
    function(command) grepl(command, agents_text, fixed = TRUE),
    logical(1)
  )]
  for (command in undocumented) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "human_agent_alignment", "undocumented_command",
      paste0("Human validation guide omits command: ", command),
      "docs/operations/validation.md"
    )
  }
  for (command in agent_missing) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "human_agent_alignment", "agent_command_mismatch",
      paste0("Agent guidance omits human command: ", command), "AGENTS.md"
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "human_agent_alignment", length(undocumented) + length(agent_missing) == 0L,
    "human guide and agent guidance use tested commands"
  )

  rrp_validation_result(
    "Phase 0 checkpoint validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}
