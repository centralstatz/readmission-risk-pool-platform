rrp_cli_exit_status <- function(kind) {
  statuses <- c(
    success = 0L,
    operation_failure = 1L,
    usage = 2L,
    invalid_software_context = 3L,
    interrupted = 130L
  )
  if (!rrp_resource_scalar_string(kind) || !kind %in% names(statuses)) {
    stop("Invalid internal CLI exit-status kind.", call. = FALSE)
  }
  unname(statuses[[kind]])
}

rrp_cli_nouns <- function() {
  c("software", "project", "reference", "state", "history", "products", "app", "run")
}

rrp_cli_global_help <- function() c(
  "Usage: rrp COMMAND [OPTIONS]",
  "",
  "Commands:",
  "  version                 Show the selected software context.",
  "  software ...            Inspect or manage installed software.",
  "  project ...             Work with an independent project.",
  "  reference ...           Work with the supplied fictional project.",
  "  state ...               Manage explicit project state.",
  "  history ...             Inspect or correct operational history.",
  "  products ...            Materialize or inspect logical products.",
  "  app ...                 Launch the supplied product-only app.",
  "  run ...                 Execute one attributed analytical operation.",
  "",
  "Use 'rrp <noun> --help' for noun-specific help. Only commands listed",
  "as available by that help are implemented in this software version."
)

rrp_cli_noun_help <- function(noun) {
  if (!rrp_resource_scalar_string(noun) || !noun %in% rrp_cli_nouns()) {
    stop("Invalid internal CLI help noun.", call. = FALSE)
  }
  available <- switch(
    noun,
    project = c(
      "Available now:",
      "  rrp project status [--project PATH] [--json]",
      "",
      "PATH is exact. When --project is omitted, status uses exactly the",
      "current working directory; it never searches parent or sibling paths."
    ),
    c(
      "No commands in this noun family are implemented by this software version.",
      "The noun is reserved by the accepted RRP command taxonomy."
    )
  )
  c(
    paste0("Usage: rrp ", noun, " COMMAND [OPTIONS]"),
    "",
    available
  )
}

rrp_cli_usage_condition <- function(code, message) {
  if (!rrp_diagnostic_code_is_valid(code) ||
      !rrp_diagnostic_message_is_safe(message)) {
    stop("Invalid internal CLI usage definition.", call. = FALSE)
  }
  structure(
    list(message = message, call = NULL, code = code),
    class = c("rrp_cli_usage_error", "error", "condition")
  )
}

rrp_cli_usage_abort <- function(code, message) {
  stop(rrp_cli_usage_condition(code, message))
}

rrp_cli_scalar_argument <- function(value, label) {
  if (!rrp_resource_scalar_string(value) ||
      !identical(value, trimws(value)) || grepl("[[:cntrl:]]", value) ||
      nchar(value, type = "bytes") > 512L) {
    rrp_cli_usage_abort("invalid_argument", paste0(label, " is invalid."))
  }
  value
}

rrp_cli_parse_time <- function(value, label = "Time") {
  value <- rrp_cli_scalar_argument(value, label)
  if (!grepl(
    "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
    value
  )) {
    rrp_cli_usage_abort("invalid_time", paste0(label, " must be RFC 3339 UTC."))
  }
  parsed <- suppressWarnings(as.POSIXct(
    value, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
  ))
  if (is.na(parsed) || !identical(
    format(parsed, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), value
  )) {
    rrp_cli_usage_abort("invalid_time", paste0(label, " must be RFC 3339 UTC."))
  }
  value
}

rrp_cli_parse_identity <- function(value, label = "Identity") {
  value <- rrp_cli_scalar_argument(value, label)
  if (nchar(value, type = "bytes") > 96L ||
      !grepl("^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$", value, perl = TRUE)) {
    rrp_cli_usage_abort("invalid_identity", paste0(label, " is invalid."))
  }
  value
}

rrp_cli_normalize_directory <- function(path, working_directory, label) {
  path <- rrp_cli_scalar_argument(path, label)
  working_directory <- rrp_cli_scalar_argument(
    working_directory, "Working directory"
  )
  base <- tryCatch(
    normalizePath(working_directory, winslash = "/", mustWork = TRUE),
    error = function(condition) NULL
  )
  candidate <- if (!is.null(base) && !grepl(
    "^(?:/|[A-Za-z]:[/\\\\])", path, perl = TRUE
  )) file.path(base, path) else path
  normalized <- tryCatch(
    normalizePath(candidate, winslash = "/", mustWork = TRUE),
    error = function(condition) NULL
  )
  if (is.null(normalized) || !dir.exists(normalized)) {
    rrp_cli_usage_abort("invalid_path", paste0(label, " must be an existing directory."))
  }
  normalized
}

rrp_cli_resolve_project <- function(project, working_directory = ".") {
  selected <- if (is.null(project)) working_directory else project
  rrp_cli_normalize_directory(selected, working_directory, "Project path")
}

rrp_cli_creation_destination <- function(arguments, working_directory = ".") {
  if (length(arguments) != 1L) {
    rrp_cli_usage_abort(
      "destination_required", "Project creation requires one destination path."
    )
  }
  destination <- rrp_cli_scalar_argument(arguments[[1L]], "Destination path")
  base <- normalizePath(working_directory, winslash = "/", mustWork = TRUE)
  if (!grepl("^(?:/|[A-Za-z]:[/\\\\])", destination, perl = TRUE)) {
    destination <- file.path(base, destination)
  }
  gsub("\\\\", "/", destination)
}

rrp_cli_parse_options <- function(arguments, allowed_value_options = character()) {
  values <- structure(
    vector("list", length(allowed_value_options)),
    names = allowed_value_options
  )
  json <- FALSE
  yes <- FALSE
  positionals <- character()
  index <- 1L
  while (index <= length(arguments)) {
    argument <- arguments[[index]]
    if (identical(argument, "--json")) {
      if (json) rrp_cli_usage_abort("duplicate_option", "Option --json was supplied more than once.")
      json <- TRUE
      index <- index + 1L
      next
    }
    if (identical(argument, "--yes")) {
      if (yes) rrp_cli_usage_abort("duplicate_option", "Option --yes was supplied more than once.")
      yes <- TRUE
      index <- index + 1L
      next
    }
    if (startsWith(argument, "--")) {
      option <- sub("^--", "", argument)
      if (!option %in% allowed_value_options) {
        rrp_cli_usage_abort("unsupported_option", "The supplied option is not supported here.")
      }
      if (!is.null(values[[option]])) {
        rrp_cli_usage_abort("duplicate_option", paste0("Option --", option, " was supplied more than once."))
      }
      if (index == length(arguments) || startsWith(arguments[[index + 1L]], "--")) {
        rrp_cli_usage_abort("missing_option_value", paste0("Option --", option, " requires a value."))
      }
      values[[option]] <- arguments[[index + 1L]]
      index <- index + 2L
      next
    }
    positionals <- c(positionals, argument)
    index <- index + 1L
  }
  list(values = values, json = json, yes = yes, positionals = positionals)
}

rrp_cli_parse <- function(arguments, working_directory = ".") {
  if (!is.character(arguments) || anyNA(arguments)) {
    rrp_cli_usage_abort("invalid_arguments", "CLI arguments are invalid.")
  }
  if (!length(arguments) || identical(arguments, "help") ||
      identical(arguments, "--help")) {
    return(list(kind = "help", noun = NULL, json = FALSE))
  }

  command <- arguments[[1L]]
  if (command %in% rrp_cli_nouns() &&
      length(arguments) == 2L && identical(arguments[[2L]], "--help")) {
    return(list(kind = "help", noun = command, json = FALSE))
  }
  if (identical(command, "help")) {
    rrp_cli_usage_abort("unsupported_help_form", "Use rrp <noun> --help for noun help.")
  }
  if (identical(command, "version")) {
    options <- rrp_cli_parse_options(arguments[-1L])
    if (length(options$positionals) || options$yes) {
      rrp_cli_usage_abort("invalid_version_arguments", "Version accepts only --json.")
    }
    return(list(kind = "operation", command = "version", json = options$json))
  }
  if (!command %in% rrp_cli_nouns()) {
    rrp_cli_usage_abort("unsupported_command", "The supplied command is not supported.")
  }
  if (length(arguments) < 2L) {
    rrp_cli_usage_abort("missing_subcommand", "A noun subcommand is required.")
  }
  action <- arguments[[2L]]
  if (identical(command, "project") && identical(action, "status")) {
    options <- rrp_cli_parse_options(arguments[-c(1L, 2L)], "project")
    if (length(options$positionals) || options$yes) {
      rrp_cli_usage_abort(
        "invalid_project_status_arguments",
        "Project status accepts only --project PATH and --json."
      )
    }
    project <- rrp_cli_resolve_project(
      options$values$project, working_directory
    )
    return(list(
      kind = "operation", command = "project_status", json = options$json,
      project_root = project
    ))
  }
  rrp_cli_usage_abort(
    "command_not_implemented",
    "This noun command is not implemented by the selected software version."
  )
}

rrp_cli_mutation_requires_confirmation <- function(mutation) {
  mutation <- rrp_cli_scalar_argument(mutation, "Mutation classification")
  if (!mutation %in% c(
    "read_only", "create_only", "append_or_idempotent", "corrective",
    "destructive"
  )) stop("Invalid internal CLI mutation classification.", call. = FALSE)
  !identical(mutation, "read_only")
}

rrp_cli_confirm <- function(
  mutation, assume_yes = FALSE, interactive_session = interactive(),
  read_response = readline
) {
  if (!rrp_cli_mutation_requires_confirmation(mutation)) return(TRUE)
  if (isTRUE(assume_yes)) return(TRUE)
  if (!isTRUE(interactive_session) || !is.function(read_response)) return(FALSE)
  identical(
    trimws(tolower(read_response("Type yes to continue: "))), "yes"
  )
}

rrp_cli_context_failure <- function(code, message) {
  rrp_new_operation_result(
    "rrp.cli-preflight", "failure", NULL,
    list(rrp_new_diagnostic(code, "error", message))
  )
}

rrp_cli_normalized_paths <- function(paths) {
  vapply(paths, function(path) {
    normalizePath(path, winslash = "/", mustWork = TRUE)
  }, character(1L), USE.NAMES = FALSE)
}

rrp_cli_preflight <- function(software_root, private_library, host_r_executable) {
  context_error <- function(code = "invalid_software_context") {
    rrp_cli_context_failure(code, "The selected installed software context is invalid.")
  }
  values <- c(software_root, private_library, host_r_executable)
  if (!is.character(values) || length(values) != 3L || anyNA(values) ||
      any(!nzchar(values))) return(context_error())
  paths <- tryCatch(
    rrp_cli_normalized_paths(values),
    error = function(condition) NULL
  )
  if (is.null(paths) || !dir.exists(paths[[1L]]) || !dir.exists(paths[[2L]]) ||
      dir.exists(paths[[3L]])) return(context_error())
  software_root <- paths[[1L]]
  private_library <- paths[[2L]]
  host_r_executable <- paths[[3L]]

  actual_r <- tryCatch(
    normalizePath(file.path(R.home("bin"), "R"), winslash = "/", mustWork = TRUE),
    error = function(condition) ""
  )
  if (!identical(host_r_executable, actual_r) ||
      getRversion() < numeric_version("4.4.0")) return(context_error("incompatible_host_r"))

  expected_libraries <- rrp_cli_normalized_paths(c(private_library, .Library))
  actual_libraries <- tryCatch(
    rrp_cli_normalized_paths(.libPaths()),
    error = function(condition) character()
  )
  if (!identical(actual_libraries, expected_libraries)) {
    return(context_error("invalid_private_library"))
  }

  required_packages <- c(
    rrpplatform = "0.1.0.9000", rrpruntime = "0.4.0.9000",
    DBI = NA_character_, duckdb = NA_character_, shiny = NA_character_,
    bslib = NA_character_, plotly = NA_character_, reactable = NA_character_,
    `brand.yml` = NA_character_
  )
  package_paths <- tryCatch(
    vapply(names(required_packages), find.package, character(1L), quiet = TRUE),
    error = function(condition) character()
  )
  if (length(package_paths) != length(required_packages)) {
    return(context_error("missing_private_dependency"))
  }
  package_paths <- rrp_cli_normalized_paths(package_paths)
  private_prefix <- paste0(private_library, "/")
  if (any(!startsWith(package_paths, private_prefix))) {
    return(context_error("ambient_library_resolution"))
  }
  for (package in names(required_packages)[!is.na(required_packages)]) {
    if (!identical(
      as.character(utils::packageVersion(package)), required_packages[[package]]
    )) return(context_error("incompatible_rrp_package"))
  }

  resources <- rrp_validate_software_resources(software_root)
  if (!rrp_operation_succeeded(resources)) return(context_error("invalid_resource_root"))
  catalog <- tryCatch(
    rrp_open_resource_catalog(software_root),
    error = function(condition) NULL
  )
  if (is.null(catalog)) return(context_error("invalid_resource_root"))
  contracts <- tryCatch(
    rrp_lifecycle_contracts(catalog),
    error = function(condition) NULL
  )
  if (is.null(contracts)) return(context_error("invalid_resource_root"))

  list(
    software_root = software_root,
    private_library = private_library,
    host_r_executable = host_r_executable,
    catalog = catalog,
    cli_contract = contracts$cli_json
  )
}

rrp_cli_version_result <- function(context) {
  header <- context$catalog$catalog$header
  value <- list(
    product_id = unname(header[["Product-ID"]]),
    development_version = unname(header[["Development-Version"]]),
    rrpplatform_version = as.character(utils::packageVersion("rrpplatform")),
    rrpruntime_version = as.character(utils::packageVersion("rrpruntime")),
    r_version = paste(R.version$major, R.version$minor, sep = "."),
    platform = R.version$platform,
    architecture = R.version$arch,
    resource_catalog_id = unname(header[["Catalog-ID"]]),
    resource_catalog_version = unname(header[["Catalog-Version"]]),
    selection = "explicit_version_context"
  )
  rrp_new_operation_result("rrp.version", "success", value, list())
}

rrp_cli_value_fields <- function(operation_id) {
  switch(
    operation_id,
    "rrp.version" = c(
      "product_id", "development_version", "rrpplatform_version",
      "rrpruntime_version", "r_version", "platform", "architecture",
      "resource_catalog_id", "resource_catalog_version", "selection"
    ),
    "rrp.project-status" = strsplit(
      rrp_project_lifecycle_result_contract_expected()[["Value-Fields"]],
      ",", fixed = TRUE
    )[[1L]],
    character()
  )
}

rrp_cli_validate_curated_value <- function(value, operation_id) {
  fields <- rrp_cli_value_fields(operation_id)
  if (!length(fields) || !is.list(value) || !identical(names(value), fields)) {
    stop("CLI result contains an unsupported value shape.", call. = FALSE)
  }
  if (identical(operation_id, "rrp.project-status")) {
    rrp_project_status_validate_value(value)
  } else if (!all(vapply(value, function(field) {
    is.character(field) && length(field) == 1L && !is.na(field) && nzchar(field)
  }, logical(1L)))) {
    stop("CLI version result contains an invalid value.", call. = FALSE)
  }
  invisible(value)
}

rrp_cli_result_payload <- function(result, cli_contract) {
  rrp_validate_operation_result(result)
  if ((!is.list(cli_contract) && !is.character(cli_contract)) ||
      !identical(unname(cli_contract[["Schema-ID"]]), "rrp.cli-result") ||
      !identical(unname(cli_contract[["Schema-Version"]]), "1.0.0")) {
    stop("CLI result schema authority is invalid.", call. = FALSE)
  }
  if (!result$operation_id %in% c(
    "rrp.version", "rrp.project-status", "rrp.cli", "rrp.cli-preflight"
  )) stop("CLI result operation is unsupported.", call. = FALSE)
  if (identical(result$status, "success")) {
    rrp_cli_validate_curated_value(result$value, result$operation_id)
    rrp_cli_json_encode(result$value)
  } else if (!is.null(result$value)) {
    stop("Failed CLI results cannot contain a value.", call. = FALSE)
  }
  diagnostics <- lapply(result$diagnostics, function(diagnostic) {
    list(
      code = diagnostic$code,
      severity = diagnostic$severity,
      message = diagnostic$message
    )
  })
  list(
    schema_version = unname(cli_contract[["Schema-Version"]]),
    operation_id = result$operation_id,
    status = result$status,
    value = result$value,
    diagnostics = diagnostics
  )
}

rrp_cli_json_string <- function(value) {
  codepoints <- utf8ToInt(enc2utf8(value))
  encoded <- vapply(codepoints, function(codepoint) {
    if (codepoint == 34L) return("\\\"")
    if (codepoint == 92L) return("\\\\")
    if (codepoint == 8L) return("\\b")
    if (codepoint == 9L) return("\\t")
    if (codepoint == 10L) return("\\n")
    if (codepoint == 12L) return("\\f")
    if (codepoint == 13L) return("\\r")
    if (codepoint < 32L) return(sprintf("\\u%04x", codepoint))
    intToUtf8(codepoint)
  }, character(1L), USE.NAMES = FALSE)
  paste0("\"", paste0(encoded, collapse = ""), "\"")
}

rrp_cli_json_encode <- function(value) {
  if (is.null(value)) return("null")
  if (is.character(value) && length(value) == 1L && !is.na(value)) {
    return(rrp_cli_json_string(value))
  }
  if (is.logical(value) && length(value) == 1L && !is.na(value)) {
    return(if (value) "true" else "false")
  }
  if ((is.integer(value) || is.double(value)) && length(value) == 1L &&
      !is.na(value) && is.finite(value) && is.null(attributes(value))) {
    return(format(value, scientific = FALSE, trim = TRUE, digits = 15L))
  }
  if (!is.list(value) || !identical(class(value), "list")) {
    stop("CLI JSON contains an unsupported value.", call. = FALSE)
  }
  names_value <- names(value)
  if (is.null(names_value)) {
    return(paste0(
      "[", paste(vapply(value, rrp_cli_json_encode, character(1L)), collapse = ","), "]"
    ))
  }
  if (length(names_value) != length(value) || any(!nzchar(names_value)) ||
      anyDuplicated(names_value)) {
    stop("CLI JSON object names are invalid.", call. = FALSE)
  }
  members <- vapply(seq_along(value), function(index) paste0(
    rrp_cli_json_string(names_value[[index]]), ":",
    rrp_cli_json_encode(value[[index]])
  ), character(1L))
  paste0("{", paste(members, collapse = ","), "}")
}

rrp_cli_render_json <- function(result, cli_contract, connection) {
  payload <- rrp_cli_result_payload(result, cli_contract)
  writeLines(rrp_cli_json_encode(payload), connection, useBytes = TRUE)
  invisible(payload)
}

rrp_cli_human_value <- function(value, prefix = character()) {
  if (is.null(value)) return(character())
  if (!is.list(value)) {
    label <- paste(prefix, collapse = ".")
    return(paste0(label, ": ", as.character(value)))
  }
  if (!length(value)) return(character())
  if (is.null(names(value))) {
    lines <- character()
    for (index in seq_along(value)) {
      lines <- c(lines, rrp_cli_human_value(value[[index]], c(prefix, index)))
    }
    return(lines)
  }
  lines <- character()
  for (name in names(value)) {
    lines <- c(lines, rrp_cli_human_value(value[[name]], c(prefix, name)))
  }
  lines
}

rrp_cli_render_human <- function(result, cli_contract, connection) {
  payload <- rrp_cli_result_payload(result, cli_contract)
  lines <- c(
    paste0("Operation: ", payload$operation_id),
    paste0("Status: ", payload$status)
  )
  if (!is.null(payload$value)) {
    lines <- c(lines, rrp_cli_human_value(payload$value))
  }
  for (diagnostic in payload$diagnostics) {
    lines <- c(lines, paste0(
      toupper(diagnostic$severity), " [", diagnostic$code, "] ",
      diagnostic$message
    ))
  }
  writeLines(lines, connection, useBytes = TRUE)
  invisible(payload)
}

rrp_cli_usage_result <- function(condition) {
  rrp_new_operation_result(
    "rrp.cli", "failure", NULL,
    list(rrp_new_diagnostic(condition$code, "error", conditionMessage(condition)))
  )
}

rrp_cli_internal_failure <- function() {
  rrp_new_operation_result(
    "rrp.cli", "failure", NULL,
    list(rrp_new_diagnostic(
      "cli_internal_failure", "error", "The command could not be completed safely."
    ))
  )
}

rrp_cli_interrupted_result <- function() {
  rrp_new_operation_result(
    "rrp.cli", "failure", NULL,
    list(rrp_new_diagnostic(
      "operation_interrupted", "error", "The command was interrupted."
    ))
  )
}

rrp_cli_execute <- function(parsed, context, operation_overrides = list()) {
  if (!is.list(parsed) || !identical(parsed$kind, "operation")) {
    stop("Invalid internal parsed CLI command.", call. = FALSE)
  }
  operation <- switch(
    parsed$command,
    version = function() rrp_cli_version_result(context),
    project_status = function() rrp_project_status(
      context$catalog, parsed$project_root
    ),
    stop("Invalid internal CLI command.", call. = FALSE)
  )
  if (!is.null(operation_overrides[[parsed$command]])) {
    operation <- operation_overrides[[parsed$command]]
  }
  if (!is.function(operation)) stop("Invalid internal CLI operation.", call. = FALSE)
  operation()
}

rrp_cli_execute_safely <- function(parsed, context, operation_overrides = list()) {
  tryCatch(
    rrp_cli_execute(parsed, context, operation_overrides),
    interrupt = function(condition) rrp_cli_interrupted_result(),
    error = function(condition) rrp_cli_internal_failure()
  )
}

#' Dispatch one version-specific RRP command
#'
#' Parse and execute one command after validating an explicitly supplied
#' installed software context. This is the package-owned dispatcher used by
#' the version-specific launcher; it does not select an active installation.
#'
#' @param arguments Character command arguments excluding the executable name.
#' @param software_root Explicit installed software-resource root.
#' @param private_library Explicit version-private R package library.
#' @param host_r_executable Explicit host R executable used for this process.
#' @param working_directory Exact working directory used for omitted project
#'   context.
#' @param output Connection for normal command output.
#' @param error Connection for usage and failure output.
#' @return Invisibly, one integer process exit status.
#' @export
rrp_cli_dispatch <- function(
  arguments, software_root, private_library, host_r_executable,
  working_directory = ".", output = stdout(), error = stderr()
) {
  json_requested <- is.character(arguments) &&
    sum(arguments == "--json", na.rm = TRUE) == 1L
  context <- tryCatch(
    rrp_cli_preflight(software_root, private_library, host_r_executable),
    error = function(condition) rrp_cli_context_failure(
      "invalid_software_context",
      "The selected installed software context is invalid."
    )
  )
  if (inherits(context, "rrp_operation_result")) {
    fallback <- c("Schema-ID" = "rrp.cli-result", "Schema-Version" = "1.0.0")
    renderer <- if (json_requested) rrp_cli_render_json else rrp_cli_render_human
    tryCatch(
      renderer(context, fallback, error),
      error = function(condition) writeLines(
        "ERROR [invalid_software_context] The selected installed software context is invalid.",
        error, useBytes = TRUE
      )
    )
    return(invisible(rrp_cli_exit_status("invalid_software_context")))
  }

  parsed <- tryCatch(
    rrp_cli_parse(arguments, working_directory),
    rrp_cli_usage_error = identity
  )
  if (inherits(parsed, "rrp_cli_usage_error")) {
    result <- rrp_cli_usage_result(parsed)
    renderer <- if (json_requested) rrp_cli_render_json else rrp_cli_render_human
    renderer(result, context$cli_contract, error)
    return(invisible(rrp_cli_exit_status("usage")))
  }
  if (identical(parsed$kind, "help")) {
    writeLines(
      if (is.null(parsed$noun)) rrp_cli_global_help() else rrp_cli_noun_help(parsed$noun),
      output, useBytes = TRUE
    )
    return(invisible(rrp_cli_exit_status("success")))
  }

  result <- rrp_cli_execute_safely(parsed, context)
  interrupted <- length(result$diagnostics) == 1L &&
    identical(result$diagnostics[[1L]]$code, "operation_interrupted")
  exit <- if (interrupted) {
    "interrupted"
  } else if (tryCatch(
    rrp_operation_succeeded(result), error = function(condition) FALSE
  )) {
    "success"
  } else {
    "operation_failure"
  }
  renderer <- if (isTRUE(parsed$json)) rrp_cli_render_json else rrp_cli_render_human
  rendered <- tryCatch(
    {
      renderer(result, context$cli_contract, if (identical(exit, "success")) output else error)
      TRUE
    },
    error = function(condition) FALSE
  )
  if (!rendered) {
    fallback <- rrp_cli_internal_failure()
    rrp_cli_render_human(fallback, context$cli_contract, error)
    exit <- "operation_failure"
  }
  invisible(rrp_cli_exit_status(exit))
}
