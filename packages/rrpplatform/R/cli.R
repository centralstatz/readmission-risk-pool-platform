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
      "  rrp project init PATH --project-id ID --project-version VERSION [--json]",
      "  rrp project validate [--project PATH] [--json]",
      "  rrp project doctor [--project PATH] [--scope ID --cutoff TIME] [--json]",
      "  rrp project status [--project PATH] [--scope ID --cutoff TIME] [--json]",
      "",
      "Initialization requires PATH. Existing-project commands use exactly",
      "--project PATH or the current directory and never search for a project."
    ),
    reference = c(
      "Available now:",
      "  rrp reference init PATH [--json]",
      "  rrp reference prepare-source [--project PATH] [--json]"
    ),
    state = c(
      "Available now:",
      "  rrp state init [--project PATH] [--json]",
      "  rrp state inspect [--project PATH] [--json]",
      "  rrp state backup PATH [--project PATH] [--json]",
      "  rrp state restore PATH [--project PATH] [--yes] [--json]"
    ),
    history = c(
      "Available now:",
      "  rrp history scope --scope ID [--project PATH] [--json]",
      "  rrp history episode --episode ID --target ID --cutoff TIME [--project PATH] [--json]",
      "  rrp history current --episode ID --target ID --at TIME --cutoff TIME [--project PATH] [--json]",
      "  rrp history retry --scope ID --analytical-run ID --retry-key KEY [--project PATH] [--yes] [--json]",
      "  rrp history invalidate --target-kind KIND --scope ID --target ID --effective-at TIME --reason CODE --actor CATEGORY [--project PATH] [--yes] [--json]",
      "  rrp history restate --target-kind KIND --scope ID --target ID --replacement-scope ID [--replacement-analytical-run ID] --effective-at TIME --reason CODE --actor CATEGORY [--project PATH] [--yes] [--json]"
    ),
    products = c(
      "Available now:",
      "  rrp products materialize --scope ID --cutoff TIME [--project PATH] [--json]",
      "  rrp products status [--scope ID --cutoff TIME] [--project PATH] [--json]"
    ),
    app = c(
      "Available now:",
      "  rrp app launch [--scope ID --cutoff TIME] [--project PATH] [--port PORT] [--browser] [--json]"
    ),
    run = c(
      "Available now:",
      "  rrp run --at TIME --operation-key KEY [--project PATH] [--json]"
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

rrp_cli_parse_version <- function(value, label = "Version") {
  value <- rrp_cli_scalar_argument(value, label)
  if (nchar(value, type = "bytes") > 64L || !grepl(
    "^[0-9]+[.][0-9]+[.][0-9]+(?:-[a-z0-9]+(?:[.-][a-z0-9]+)*)?$",
    value, perl = TRUE
  )) rrp_cli_usage_abort("invalid_version", paste0(label, " is invalid."))
  value
}

rrp_cli_parse_choice <- function(value, choices, label) {
  value <- rrp_cli_scalar_argument(value, label)
  if (!value %in% choices) {
    rrp_cli_usage_abort("invalid_argument", paste0(label, " is invalid."))
  }
  value
}

rrp_cli_parse_port <- function(value) {
  value <- rrp_cli_scalar_argument(value, "Port")
  if (!grepl("^[0-9]+$", value) || nchar(value) > 5L) {
    rrp_cli_usage_abort("invalid_port", "Port is invalid.")
  }
  port <- suppressWarnings(as.integer(value))
  if (is.na(port) || port < 1024L || port > 65535L) {
    rrp_cli_usage_abort("invalid_port", "Port is invalid.")
  }
  port
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

rrp_cli_path_from_working_directory <- function(path, working_directory) {
  path <- rrp_cli_scalar_argument(path, "Path")
  base <- tryCatch(
    normalizePath(working_directory, winslash = "/", mustWork = TRUE),
    error = function(condition) NULL
  )
  if (is.null(base) || !dir.exists(base)) {
    rrp_cli_usage_abort("invalid_path", "Working directory is invalid.")
  }
  candidate <- if (grepl("^(?:/|[A-Za-z]:[/\\\\])", path, perl = TRUE)) {
    path.expand(path)
  } else {
    file.path(base, path)
  }
  gsub("\\\\", "/", candidate)
}

rrp_cli_absent_destination <- function(path, working_directory) {
  candidate <- rrp_cli_path_from_working_directory(path, working_directory)
  parent <- tryCatch(
    normalizePath(dirname(candidate), winslash = "/", mustWork = TRUE),
    error = function(condition) NULL
  )
  if (is.null(parent) || !dir.exists(parent) || file.exists(candidate) ||
      dir.exists(candidate)) {
    rrp_cli_usage_abort(
      "invalid_destination", "Destination must be absent with an existing parent."
    )
  }
  file.path(parent, basename(candidate))
}

rrp_cli_existing_path <- function(path, working_directory, label = "Path") {
  candidate <- rrp_cli_path_from_working_directory(path, working_directory)
  normalized <- tryCatch(
    normalizePath(candidate, winslash = "/", mustWork = TRUE),
    error = function(condition) NULL
  )
  if (is.null(normalized)) {
    rrp_cli_usage_abort("invalid_path", paste0(label, " must exist."))
  }
  normalized
}

rrp_cli_parse_options <- function(
  arguments, allowed_value_options = character(), allowed_flags = character()
) {
  values <- structure(
    vector("list", length(allowed_value_options)),
    names = allowed_value_options
  )
  json <- FALSE
  yes <- FALSE
  flags <- structure(as.list(rep(FALSE, length(allowed_flags))),
    names = allowed_flags)
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
    if (startsWith(argument, "--") &&
        sub("^--", "", argument) %in% allowed_flags) {
      flag <- sub("^--", "", argument)
      if (isTRUE(flags[[flag]])) {
        rrp_cli_usage_abort(
          "duplicate_option", paste0("Option --", flag, " was supplied more than once.")
        )
      }
      flags[[flag]] <- TRUE
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
  list(
    values = values, flags = flags, json = json, yes = yes,
    positionals = positionals
  )
}

rrp_cli_require_values <- function(options, names, label) {
  missing <- names[vapply(names, function(name) {
    is.null(options$values[[name]])
  }, logical(1L))]
  if (length(missing)) rrp_cli_usage_abort(
    "missing_required_option", paste0(label, " requires its documented options.")
  )
  invisible(options)
}

rrp_cli_require_pair <- function(left, right, label) {
  if (xor(is.null(left), is.null(right))) rrp_cli_usage_abort(
    "paired_options_required", paste0(label, " options must be supplied together.")
  )
  invisible(TRUE)
}

rrp_cli_operation <- function(command, options, ...) {
  c(list(
    kind = "operation", command = command, json = options$json,
    assume_yes = options$yes
  ), list(...))
}

rrp_cli_parse <- function(arguments, working_directory = ".") {
  if (!is.character(arguments) || anyNA(arguments)) {
    rrp_cli_usage_abort("invalid_arguments", "CLI arguments are invalid.")
  }
  if (!length(arguments) || identical(arguments, "help") ||
      identical(arguments, "--help")) {
    return(list(kind = "help", noun = NULL, json = FALSE))
  }

  noun <- arguments[[1L]]
  if (noun %in% rrp_cli_nouns() && length(arguments) == 2L &&
      identical(arguments[[2L]], "--help")) {
    return(list(kind = "help", noun = noun, json = FALSE))
  }
  if (identical(noun, "help")) rrp_cli_usage_abort(
    "unsupported_help_form", "Use rrp <noun> --help for noun help."
  )
  if (identical(noun, "version")) {
    options <- rrp_cli_parse_options(arguments[-1L])
    if (length(options$positionals) || options$yes) rrp_cli_usage_abort(
      "invalid_version_arguments", "Version accepts only --json."
    )
    return(rrp_cli_operation("version", options))
  }
  if (!noun %in% rrp_cli_nouns()) rrp_cli_usage_abort(
    "unsupported_command", "The supplied command is not supported."
  )

  if (identical(noun, "run")) {
    options <- rrp_cli_parse_options(
      arguments[-1L], c("at", "operation-key", "project")
    )
    rrp_cli_require_values(options, c("at", "operation-key"), "Run")
    if (length(options$positionals) || options$yes) rrp_cli_usage_abort(
      "invalid_run_arguments", "Run arguments are invalid."
    )
    return(rrp_cli_operation(
      "run", options,
      project_root = rrp_cli_resolve_project(
        options$values$project, working_directory
      ),
      analytical_time = rrp_cli_parse_time(options$values$at, "Analytical time"),
      operation_key = rrp_cli_parse_identity(
        options$values[["operation-key"]], "Operation key"
      )
    ))
  }

  if (length(arguments) < 2L) rrp_cli_usage_abort(
    "missing_subcommand", "A noun subcommand is required."
  )
  action <- arguments[[2L]]
  remaining <- arguments[-c(1L, 2L)]

  if (identical(noun, "project") && identical(action, "init")) {
    options <- rrp_cli_parse_options(
      remaining, c("project-id", "project-version")
    )
    rrp_cli_require_values(options, c("project-id", "project-version"),
      "Project initialization")
    if (length(options$positionals) != 1L || options$yes) rrp_cli_usage_abort(
      "invalid_project_init_arguments",
      "Project initialization requires one destination and project identity/version."
    )
    return(rrp_cli_operation(
      "project_init", options,
      destination = rrp_cli_absent_destination(
        options$positionals[[1L]], working_directory
      ),
      project_id = rrp_cli_parse_identity(
        options$values[["project-id"]], "Project identity"
      ),
      project_version = rrp_cli_parse_version(
        options$values[["project-version"]], "Project version"
      )
    ))
  }
  if (identical(noun, "project") && action %in% c(
    "validate", "doctor", "status"
  )) {
    allowed <- if (action %in% c("doctor", "status")) {
      c("project", "scope", "cutoff")
    } else "project"
    options <- rrp_cli_parse_options(remaining, allowed)
    if (length(options$positionals) || options$yes) rrp_cli_usage_abort(
      if (identical(action, "status")) {
        "invalid_project_status_arguments"
      } else {
        "invalid_project_arguments"
      },
      "Project command arguments are invalid."
    )
    if (action %in% c("doctor", "status")) rrp_cli_require_pair(
      options$values$scope, options$values$cutoff, "Freshness"
    )
    return(rrp_cli_operation(
      paste0("project_", action), options,
      project_root = rrp_cli_resolve_project(
        options$values$project, working_directory
      ),
      operation_run_id = if (is.null(options$values$scope)) NULL else {
        rrp_cli_parse_identity(options$values$scope, "Operation-run identity")
      },
      history_cutoff = if (is.null(options$values$cutoff)) NULL else {
        rrp_cli_parse_time(options$values$cutoff, "History cutoff")
      }
    ))
  }

  if (identical(noun, "reference") && identical(action, "init")) {
    options <- rrp_cli_parse_options(remaining)
    if (length(options$positionals) != 1L || options$yes) rrp_cli_usage_abort(
      "invalid_reference_init_arguments",
      "Reference initialization requires one destination."
    )
    return(rrp_cli_operation(
      "reference_init", options,
      destination = rrp_cli_absent_destination(
        options$positionals[[1L]], working_directory
      )
    ))
  }
  if (identical(noun, "reference") && identical(action, "prepare-source")) {
    options <- rrp_cli_parse_options(remaining, "project")
    if (length(options$positionals) || options$yes) rrp_cli_usage_abort(
      "invalid_reference_prepare_arguments",
      "Reference source preparation arguments are invalid."
    )
    return(rrp_cli_operation(
      "reference_prepare_source", options,
      project_root = rrp_cli_resolve_project(
        options$values$project, working_directory
      )
    ))
  }

  if (identical(noun, "state") && action %in% c(
    "init", "inspect", "backup", "restore"
  )) {
    options <- rrp_cli_parse_options(remaining, "project")
    needs_path <- action %in% c("backup", "restore")
    if (length(options$positionals) != if (needs_path) 1L else 0L ||
        (options$yes && !identical(action, "restore"))) rrp_cli_usage_abort(
      "invalid_state_arguments", "State command arguments are invalid."
    )
    path <- if (!needs_path) NULL else if (identical(action, "backup")) {
      rrp_cli_absent_destination(options$positionals[[1L]], working_directory)
    } else {
      rrp_cli_existing_path(
        options$positionals[[1L]], working_directory, "Backup path"
      )
    }
    return(rrp_cli_operation(
      paste0("state_", action), options,
      project_root = rrp_cli_resolve_project(
        options$values$project, working_directory
      ), backup_path = path
    ))
  }

  if (identical(noun, "history") && action %in% c(
    "scope", "episode", "current", "retry", "invalidate", "restate"
  )) {
    value_options <- switch(
      action,
      scope = c("scope", "project"),
      episode = c("episode", "target", "cutoff", "project"),
      current = c("episode", "target", "at", "cutoff", "project"),
      retry = c("scope", "analytical-run", "retry-key", "project"),
      invalidate = c(
        "target-kind", "scope", "target", "effective-at", "reason",
        "actor", "project"
      ),
      restate = c(
        "target-kind", "scope", "target", "replacement-scope",
        "replacement-analytical-run", "effective-at", "reason", "actor",
        "project"
      )
    )
    options <- rrp_cli_parse_options(remaining, value_options)
    if (length(options$positionals) ||
        (options$yes && !action %in% c("retry", "invalidate", "restate"))) {
      rrp_cli_usage_abort(
        "invalid_history_arguments", "History command arguments are invalid."
      )
    }
    required <- switch(
      action,
      scope = "scope",
      episode = c("episode", "target", "cutoff"),
      current = c("episode", "target", "at", "cutoff"),
      retry = c("scope", "analytical-run", "retry-key"),
      invalidate = c(
        "target-kind", "scope", "target", "effective-at", "reason", "actor"
      ),
      restate = c(
        "target-kind", "scope", "target", "replacement-scope",
        "effective-at", "reason", "actor"
      )
    )
    rrp_cli_require_values(options, required, "History command")
    target_kind <- if (action %in% c("invalidate", "restate")) {
      rrp_cli_parse_choice(
        options$values[["target-kind"]],
        c("analytical_run", "operational_scope"), "Target kind"
      )
    } else NULL
    if (identical(action, "restate")) {
      analytical <- options$values[["replacement-analytical-run"]]
      if (identical(target_kind, "analytical_run") && is.null(analytical)) {
        rrp_cli_usage_abort(
          "missing_required_option",
          "Analytical restatement requires --replacement-analytical-run."
        )
      }
      if (identical(target_kind, "operational_scope") && !is.null(analytical)) {
        rrp_cli_usage_abort(
          "invalid_history_arguments",
          "Scope restatement cannot include --replacement-analytical-run."
        )
      }
    }
    parse_optional_identity <- function(name, label = "Identity") {
      value <- options$values[[name]]
      if (is.null(value)) NULL else rrp_cli_parse_identity(value, label)
    }
    parse_optional_time <- function(name, label) {
      value <- options$values[[name]]
      if (is.null(value)) NULL else rrp_cli_parse_time(value, label)
    }
    return(rrp_cli_operation(
      paste0("history_", action), options,
      project_root = rrp_cli_resolve_project(
        options$values$project, working_directory
      ),
      operation_run_id = parse_optional_identity("scope", "Operation-run identity"),
      episode_id = parse_optional_identity("episode", "Episode identity"),
      target_id = parse_optional_identity("target", "Target identity"),
      analytical_time = parse_optional_time("at", "Analytical cutoff"),
      history_cutoff = parse_optional_time("cutoff", "History cutoff"),
      analytical_run_id = parse_optional_identity(
        "analytical-run", "Analytical-run identity"
      ),
      retry_key = parse_optional_identity("retry-key", "Retry key"),
      target_kind = target_kind,
      effective_time = parse_optional_time("effective-at", "Effective time"),
      reason_code = if (is.null(options$values$reason)) NULL else {
        rrp_cli_parse_choice(
          options$values$reason,
          c(
            "incorrect_input", "incorrect_scope", "incorrect_provenance",
            "superseded_result"
          ),
          "Reason code"
        )
      },
      actor_category = if (is.null(options$values$actor)) NULL else {
        rrp_cli_parse_choice(
          options$values$actor, c("maintainer", "operator"), "Actor category"
        )
      },
      replacement_operation_run_id = parse_optional_identity(
        "replacement-scope", "Replacement operation-run identity"
      ),
      replacement_analytical_run_id = parse_optional_identity(
        "replacement-analytical-run", "Replacement analytical-run identity"
      )
    ))
  }

  if (identical(noun, "products") && action %in% c("materialize", "status")) {
    options <- rrp_cli_parse_options(
      remaining, c("scope", "cutoff", "project")
    )
    if (length(options$positionals) || options$yes) rrp_cli_usage_abort(
      "invalid_product_arguments", "Product command arguments are invalid."
    )
    if (identical(action, "materialize")) {
      rrp_cli_require_values(options, c("scope", "cutoff"),
        "Product materialization")
    } else {
      rrp_cli_require_pair(options$values$scope, options$values$cutoff,
        "Product freshness")
    }
    return(rrp_cli_operation(
      paste0("products_", action), options,
      project_root = rrp_cli_resolve_project(
        options$values$project, working_directory
      ),
      operation_run_id = if (is.null(options$values$scope)) NULL else {
        rrp_cli_parse_identity(options$values$scope, "Operation-run identity")
      },
      history_cutoff = if (is.null(options$values$cutoff)) NULL else {
        rrp_cli_parse_time(options$values$cutoff, "History cutoff")
      }
    ))
  }

  if (identical(noun, "app") && identical(action, "launch")) {
    options <- rrp_cli_parse_options(
      remaining, c("scope", "cutoff", "project", "port"), "browser"
    )
    if (length(options$positionals) || options$yes) rrp_cli_usage_abort(
      "invalid_app_arguments", "Application launch arguments are invalid."
    )
    rrp_cli_require_pair(options$values$scope, options$values$cutoff,
      "Application freshness")
    return(rrp_cli_operation(
      "app_launch", options,
      project_root = rrp_cli_resolve_project(
        options$values$project, working_directory
      ),
      operation_run_id = if (is.null(options$values$scope)) NULL else {
        rrp_cli_parse_identity(options$values$scope, "Operation-run identity")
      },
      history_cutoff = if (is.null(options$values$cutoff)) NULL else {
        rrp_cli_parse_time(options$values$cutoff, "History cutoff")
      },
      port = if (is.null(options$values$port)) NULL else {
        rrp_cli_parse_port(options$values$port)
      },
      launch_browser = isTRUE(options$flags$browser)
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
  mutation %in% c("corrective", "destructive")
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

rrp_cli_confirmation_result <- function() {
  rrp_new_operation_result(
    "rrp.cli", "failure", NULL,
    list(rrp_new_diagnostic(
      "confirmation_required", "error",
      "This corrective operation requires explicit confirmation."
    ))
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
    "rrp.initialize-project" = c(
      "project_id", "project_version", "canonical_profile_id",
      "canonical_profile_version", "producer_id", "provider_id",
      "created_path_count"
    ),
    "rrp.initialize-fictional-project" = c(
      "project_id", "project_version", "canonical_profile_id",
      "canonical_profile_version", "producer_id", "provider_id",
      "created_path_count"
    ),
    "rrp.validate-project" = c(
      "project_id", "project_version", "project_contract_id",
      "project_contract_version", "supported_rrp_api_version",
      "canonical_profile_id", "canonical_profile_version", "producer_id",
      "producer_version", "provider_id", "provider_version",
      "extension_library_status", "state_status"
    ),
    "rrp.prepare-fictional-source" = c(
      "project_id", "dataset_id", "dataset_version", "classification",
      "source_status", "reused", "created_path_count"
    ),
    "rrp.initialize-project-state" = c(
      "state_status", "state_id", "project_id", "state_contract_id",
      "state_contract_version", "adapter_id", "adapter_version",
      "physical_schema_version", "payload_encoding_version", "created_at",
      "created"
    ),
    "rrp.inspect-project-state" = c(
      "state_status", "state_id", "project_id", "state_contract_id",
      "state_contract_version", "adapter_id", "adapter_version",
      "physical_schema_version", "payload_encoding_version", "created_at"
    ),
    "rrp.backup-project-state" = c(
      "backup_status", "backup_id", "source_state_id", "project_id",
      "backup_contract_id", "backup_contract_version"
    ),
    "rrp.restore-project-state" = c(
      "state_status", "state_id", "project_id", "state_contract_id",
      "state_contract_version", "adapter_id", "adapter_version",
      "physical_schema_version", "payload_encoding_version", "created_at",
      "restored", "backup_id"
    ),
    "rrp.execute-durable-bundle" = c(
      "operation_run_id", "expected_episode_count",
      "dispositioned_episode_count", "complete"
    ),
    "rrp.inspect-scope-history" = c(
      "operation_run_id", "analytical_time", "expected_episode_count",
      "dispositioned_episode_count", "complete", "record_count",
      "action_count"
    ),
    "rrp.inspect-episode-history" = c(
      "record_count", "action_count", "analytical_runs"
    ),
    "rrp.inspect-current-history" = c(
      "found", "operation_run_id", "analytical_run_id",
      "related_analytical_run_id", "analytical_kind", "analytical_time",
      "outcome", "outcome_code", "provider_status"
    ),
    "rrp.retry-episode" = c(
      "operation_run_id", "analytical_run_id", "related_analytical_run_id",
      "outcome", "outcome_code"
    ),
    "rrp.invalidate-history" = c(
      "action_id", "target_kind", "target_operation_run_id", "target_id",
      "action_type", "effective_time", "reason_code", "actor_category"
    ),
    "rrp.restate-history" = c(
      "action_id", "target_kind", "target_operation_run_id", "target_id",
      "action_type", "effective_time", "reason_code", "actor_category",
      "replacement_operation_run_id", "replacement_analytical_run_id"
    ),
    "rrp.build-and-materialize-products" = c(
      "product_set_id", "source_operation_run_id", "source_history_cutoff",
      "materialization_id", "adapter_id", "adapter_version",
      "physical_format_id", "physical_format_version", "reused"
    ),
    "rrp.open-product-access" = c(
      "product_set_id", "materialization_id", "source_operation_run_id",
      "source_analytical_time", "source_history_cutoff", "freshness_status",
      "expected_operation_run_id", "expected_history_cutoff"
    ),
    "rrp.launch-app" = c("application_id", "application_version"),
    character()
  )
}

rrp_cli_plain_safe_value <- function(value) {
  if (is.null(value)) return(TRUE)
  if ((is.character(value) || is.logical(value) || is.integer(value) ||
      is.double(value)) && length(value) == 1L && !is.na(value) &&
      (!is.double(value) || is.finite(value)) && is.null(attributes(value))) {
    return(TRUE)
  }
  if (!is.list(value) || !identical(class(value), "list")) return(FALSE)
  names_value <- names(value)
  if (!is.null(names_value) && (length(names_value) != length(value) ||
      any(!nzchar(names_value)) || anyDuplicated(names_value))) return(FALSE)
  all(vapply(value, rrp_cli_plain_safe_value, logical(1L)))
}

rrp_cli_validate_analytical_summaries <- function(values) {
  is.list(values) && is.null(names(values)) && all(vapply(values, function(value) {
    is.list(value) && identical(class(value), "list") && identical(
      names(value), c(
        "operation_run_id", "analytical_run_id", "related_analytical_run_id",
        "analytical_kind", "analytical_time", "outcome", "outcome_code",
        "provider_status"
      )
    ) && rrp_cli_plain_safe_value(value)
  }, logical(1L)))
}

rrp_cli_validate_curated_value <- function(value, operation_id) {
  fields <- rrp_cli_value_fields(operation_id)
  if (!length(fields) || !is.list(value) || !identical(names(value), fields)) {
    stop("CLI result contains an unsupported value shape.", call. = FALSE)
  }
  if (identical(operation_id, "rrp.project-status")) {
    rrp_project_status_validate_value(value)
  } else {
    if (!rrp_cli_plain_safe_value(value) ||
        (identical(operation_id, "rrp.inspect-episode-history") &&
          !rrp_cli_validate_analytical_summaries(value$analytical_runs))) {
      stop("CLI result contains an invalid curated value.", call. = FALSE)
    }
  }
  invisible(value)
}

rrp_cli_result_with_value <- function(result, value) {
  rrp_validate_operation_result(result)
  if (!rrp_operation_succeeded(result)) return(result)
  rrp_new_operation_result(
    result$operation_id, result$status, value, result$diagnostics
  )
}

rrp_cli_disposition_summary <- function(value) list(
  operation_run_id = value$operation_run_id,
  analytical_run_id = value$analytical_run_id,
  related_analytical_run_id = value$related_analytical_run_id,
  analytical_kind = value$analytical_kind,
  analytical_time = value$analytical_time,
  outcome = value$outcome,
  outcome_code = value$outcome_code,
  provider_status = value$provider_status
)

rrp_cli_action_value <- function(action, restatement = FALSE) {
  value <- list(
    action_id = action$action_id,
    target_kind = action$target_kind,
    target_operation_run_id = action$target_operation_run_id,
    target_id = action$target_id,
    action_type = action$action_type,
    effective_time = action$effective_time,
    reason_code = action$reason_code,
    actor_category = action$actor_category
  )
  if (restatement) value <- c(value, list(
    replacement_operation_run_id = action$replacement_operation_run_id,
    replacement_analytical_run_id = action$replacement_analytical_run_id
  ))
  value
}

rrp_cli_curate_result <- function(result) {
  rrp_validate_operation_result(result)
  if (!rrp_operation_succeeded(result)) return(result)
  source <- result$value
  value <- switch(
    result$operation_id,
    "rrp.version" = source,
    "rrp.project-status" = source,
    "rrp.initialize-project" = list(
      project_id = source$project_id,
      project_version = source$project_version,
      canonical_profile_id = source$canonical_profile_id,
      canonical_profile_version = source$canonical_profile_version,
      producer_id = source$producer_id,
      provider_id = source$provider_id,
      created_path_count = as.integer(length(source$created_paths))
    ),
    "rrp.initialize-fictional-project" = list(
      project_id = source$project_id,
      project_version = source$project_version,
      canonical_profile_id = source$canonical_profile_id,
      canonical_profile_version = source$canonical_profile_version,
      producer_id = source$producer_id,
      provider_id = source$provider_id,
      created_path_count = as.integer(length(source$created_paths))
    ),
    "rrp.validate-project" = list(
      project_id = source$project_id,
      project_version = source$project_version,
      project_contract_id = source$project_contract_id,
      project_contract_version = source$project_contract_version,
      supported_rrp_api_version = source$supported_rrp_api_version,
      canonical_profile_id = source$canonical_profile$profile_id,
      canonical_profile_version = source$canonical_profile$profile_version,
      producer_id = source$producer$component_id,
      producer_version = source$producer$component_version,
      provider_id = source$provider$component_id,
      provider_version = source$provider$component_version,
      extension_library_status = source$extension_library_status,
      state_status = source$state_status
    ),
    "rrp.prepare-fictional-source" = list(
      project_id = source$project_id,
      dataset_id = source$dataset_id,
      dataset_version = source$dataset_version,
      classification = source$classification,
      source_status = source$source_status,
      reused = source$reused,
      created_path_count = as.integer(length(source$created_paths))
    ),
    "rrp.initialize-project-state" = source,
    "rrp.inspect-project-state" = source,
    "rrp.backup-project-state" = source,
    "rrp.restore-project-state" = source,
    "rrp.execute-durable-bundle" = source,
    "rrp.inspect-scope-history" = list(
      operation_run_id = source$scope$operation_run_id,
      analytical_time = source$scope$analytical_time,
      expected_episode_count = source$progress$expected_episode_count,
      dispositioned_episode_count = source$progress$dispositioned_episode_count,
      complete = source$progress$complete,
      record_count = as.integer(length(source$dispositions)),
      action_count = as.integer(length(source$actions))
    ),
    "rrp.inspect-episode-history" = list(
      record_count = as.integer(length(source$dispositions)),
      action_count = as.integer(length(source$actions)),
      analytical_runs = unname(lapply(
        source$dispositions, rrp_cli_disposition_summary
      ))
    ),
    "rrp.inspect-current-history" = if (is.null(source)) list(
      found = FALSE, operation_run_id = NULL, analytical_run_id = NULL,
      related_analytical_run_id = NULL, analytical_kind = NULL,
      analytical_time = NULL, outcome = NULL, outcome_code = NULL,
      provider_status = NULL
    ) else c(list(found = TRUE), rrp_cli_disposition_summary(source)),
    "rrp.retry-episode" = source,
    "rrp.invalidate-history" = rrp_cli_action_value(source),
    "rrp.restate-history" = rrp_cli_action_value(source$action, TRUE),
    "rrp.build-and-materialize-products" = source,
    "rrp.open-product-access" = list(
      product_set_id = source$product_set_id,
      materialization_id = source$materialization_id,
      source_operation_run_id = source$source_operation_run_id,
      source_analytical_time = source$source_analytical_time,
      source_history_cutoff = source$source_history_cutoff,
      freshness_status = source$freshness$status,
      expected_operation_run_id = source$freshness$expected_operation_run_id,
      expected_history_cutoff = source$freshness$expected_history_cutoff
    ),
    "rrp.launch-app" = source,
    stop("CLI result operation is unsupported.", call. = FALSE)
  )
  rrp_cli_result_with_value(result, value)
}

rrp_cli_result_payload <- function(result, cli_contract) {
  rrp_validate_operation_result(result)
  if ((!is.list(cli_contract) && !is.character(cli_contract)) ||
      !identical(unname(cli_contract[["Schema-ID"]]), "rrp.cli-result") ||
      !identical(unname(cli_contract[["Schema-Version"]]), "1.0.0")) {
    stop("CLI result schema authority is invalid.", call. = FALSE)
  }
  if (!result$operation_id %in% c(
    "rrp.version", "rrp.project-status", "rrp.initialize-project",
    "rrp.initialize-fictional-project", "rrp.validate-project",
    "rrp.prepare-fictional-source", "rrp.initialize-project-state",
    "rrp.inspect-project-state", "rrp.backup-project-state",
    "rrp.restore-project-state", "rrp.execute-durable-bundle",
    "rrp.inspect-scope-history", "rrp.inspect-episode-history",
    "rrp.inspect-current-history", "rrp.retry-episode",
    "rrp.invalidate-history", "rrp.restate-history",
    "rrp.build-and-materialize-products", "rrp.open-product-access",
    "rrp.launch-app", "rrp.cli", "rrp.cli-preflight"
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

rrp_cli_restatement_result <- function(parsed, context) {
  replacement_scope <- rrp_inspect_scope_history(
    context$catalog, parsed$project_root,
    parsed$replacement_operation_run_id
  )
  if (!rrp_operation_succeeded(replacement_scope)) return(
    rrp_new_operation_result(
      "rrp.restate-history", "failure", NULL,
      replacement_scope$diagnostics
    )
  )
  replacement <- if (identical(parsed$target_kind, "operational_scope")) {
    replacement_scope$value$scope
  } else {
    matches <- Filter(function(value) identical(
      value$analytical_run_id, parsed$replacement_analytical_run_id
    ), replacement_scope$value$dispositions)
    if (length(matches) != 1L) return(rrp_new_operation_result(
      "rrp.restate-history", "failure", NULL,
      list(rrp_new_diagnostic(
        "invalid_restatement", "error", "The history restatement is invalid."
      ))
    ))
    matches[[1L]]
  }
  rrp_restate_history(
    context$catalog, parsed$project_root, parsed$target_kind,
    parsed$operation_run_id, parsed$target_id, replacement,
    parsed$effective_time, parsed$reason_code, parsed$actor_category
  )
}

rrp_cli_confirmation_class <- function(command) {
  if (command %in% c(
    "state_restore", "history_retry", "history_invalidate", "history_restate"
  )) "corrective" else "read_only"
}

rrp_cli_execute <- function(parsed, context, operation_overrides = list()) {
  if (!is.list(parsed) || !identical(parsed$kind, "operation")) {
    stop("Invalid internal parsed CLI command.", call. = FALSE)
  }
  operation <- switch(
    parsed$command,
    version = function() rrp_cli_version_result(context),
    project_init = function() rrp_initialize_project(
      context$catalog, parsed$destination, parsed$project_id,
      parsed$project_version
    ),
    project_validate = function() rrp_validate_project(
      context$catalog, parsed$project_root
    ),
    project_doctor = function() rrp_project_status(
      context$catalog, parsed$project_root, parsed$operation_run_id,
      parsed$history_cutoff
    ),
    project_status = function() rrp_project_status(
      context$catalog, parsed$project_root, parsed$operation_run_id,
      parsed$history_cutoff
    ),
    reference_init = function() rrp_initialize_fictional_project(
      context$catalog, parsed$destination
    ),
    reference_prepare_source = function() rrp_prepare_fictional_source(
      context$catalog, parsed$project_root
    ),
    state_init = function() rrp_initialize_project_state(
      context$catalog, parsed$project_root
    ),
    state_inspect = function() rrp_inspect_project_state(
      context$catalog, parsed$project_root
    ),
    state_backup = function() rrp_backup_project_state(
      context$catalog, parsed$project_root, parsed$backup_path
    ),
    state_restore = function() rrp_restore_project_state(
      context$catalog, parsed$project_root, parsed$backup_path
    ),
    run = function() rrp_execute_durable_bundle(
      context$catalog, parsed$project_root, parsed$analytical_time,
      parsed$operation_key
    ),
    history_scope = function() rrp_inspect_scope_history(
      context$catalog, parsed$project_root, parsed$operation_run_id
    ),
    history_episode = function() rrp_inspect_episode_history(
      context$catalog, parsed$project_root, parsed$episode_id,
      parsed$target_id, parsed$history_cutoff
    ),
    history_current = function() rrp_inspect_current_history(
      context$catalog, parsed$project_root, parsed$episode_id,
      parsed$target_id, parsed$analytical_time, parsed$history_cutoff
    ),
    history_retry = function() rrp_retry_episode(
      context$catalog, parsed$project_root, parsed$operation_run_id,
      parsed$analytical_run_id, parsed$retry_key
    ),
    history_invalidate = function() rrp_invalidate_history(
      context$catalog, parsed$project_root, parsed$target_kind,
      parsed$operation_run_id, parsed$target_id, parsed$effective_time,
      parsed$reason_code, parsed$actor_category
    ),
    history_restate = function() rrp_cli_restatement_result(parsed, context),
    products_materialize = function() rrp_build_and_materialize_products(
      context$catalog, parsed$project_root, parsed$operation_run_id,
      parsed$history_cutoff
    ),
    products_status = function() rrp_open_product_access(
      context$catalog, parsed$project_root, parsed$operation_run_id,
      parsed$history_cutoff
    ),
    app_launch = function() rrp_launch_app(
      context$catalog, parsed$project_root, parsed$operation_run_id,
      parsed$history_cutoff, parsed$launch_browser, parsed$port
    ),
    stop("Invalid internal CLI command.", call. = FALSE)
  )
  if (!is.null(operation_overrides[[parsed$command]])) {
    operation <- operation_overrides[[parsed$command]]
  }
  if (!is.function(operation)) stop("Invalid internal CLI operation.", call. = FALSE)
  rrp_cli_curate_result(operation())
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

  confirmation_class <- rrp_cli_confirmation_class(parsed$command)
  confirmed <- if (rrp_cli_mutation_requires_confirmation(confirmation_class)) {
    tty <- if (isTRUE(parsed$json)) FALSE else tryCatch(
      isatty(stdin()), error = function(condition) FALSE
    )
    rrp_cli_confirm(
      confirmation_class, assume_yes = isTRUE(parsed$assume_yes),
      interactive_session = tty
    )
  } else TRUE
  result <- if (confirmed) {
    rrp_cli_execute_safely(parsed, context)
  } else {
    rrp_cli_confirmation_result()
  }
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
