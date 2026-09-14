rrp_validation_profile_map <- function(registry) {
  rrp_governance_named_entries(registry$profiles, "profile_id")
}

rrp_validation_validator_map <- function(registry) {
  rrp_governance_named_entries(registry$validators, "validator_id")
}

rrp_validation_load_registry <- function(repository_root) {
  registry <- rrp_governance_read_registry(repository_root)
  result <- rrp_governance_validate_registry(registry, repository_root)
  if (!result$passed) stop(
    "Validation ownership registry is invalid:\n- ",
    paste(result$issues, collapse = "\n- "),
    call. = FALSE
  )
  if (isTRUE(registry$governance_state$classification_only) ||
      !isTRUE(registry$governance_state$activated_dispatcher)) stop(
    "Named validation dispatch is not activated by the ownership registry.",
    call. = FALSE
  )
  registry
}

rrp_validation_normalize_paths <- function(paths) {
  paths <- rrp_governance_values(paths)
  if (length(paths) == 0L) return(character())
  normalized <- vapply(paths, function(path) {
    issue <- rrp_governance_path_issue(path, "changed path")
    if (length(issue) > 0L) stop(issue[[1L]], call. = FALSE)
    value <- gsub("\\\\", "/", path)
    value <- sub("^([.]/)+", "", value)
    value <- gsub("/{2,}", "/", value)
    if (!nzchar(value) || identical(value, ".") || endsWith(value, "/")) stop(
      "Changed paths must identify repository-relative files: ", path,
      call. = FALSE
    )
    value
  }, character(1L))
  sort(unique(unname(normalized)), method = "radix")
}

rrp_validation_path_matches <- function(path, trigger_paths) {
  exact <- rrp_governance_values(trigger_paths$exact)
  prefixes <- rrp_governance_values(trigger_paths$prefixes)
  suffixes <- rrp_governance_values(trigger_paths$suffixes)
  identical_match <- path %in% exact
  prefix_match <- length(prefixes) > 0L && any(startsWith(path, prefixes))
  suffix_match <- length(suffixes) > 0L && any(endsWith(path, suffixes))
  identical_match || prefix_match || suffix_match
}

rrp_validation_matching_paths <- function(validator, paths) {
  paths[vapply(
    paths,
    rrp_validation_path_matches,
    logical(1L),
    trigger_paths = validator$trigger_paths
  )]
}

rrp_validation_git <- function(repository_root, arguments, action) {
  git <- Sys.which("git")
  if (!nzchar(git)) stop("Git is required for ", action, ".", call. = FALSE)
  output <- suppressWarnings(system2(
    git,
    c("-C", shQuote(repository_root), vapply(arguments, shQuote, character(1L))),
    stdout = TRUE,
    stderr = TRUE
  ))
  status <- attr(output, "status")
  if (!is.null(status) && !identical(status, 0L)) stop(
    "Git could not complete ", action, ": ",
    paste(tail(output, 4L), collapse = " | "),
    call. = FALSE
  )
  output
}

rrp_validation_validate_base <- function(repository_root, base) {
  if (!is.character(base) || length(base) != 1L || is.na(base) ||
      !grepl("^[A-Za-z0-9][A-Za-z0-9._/-]*$", base) ||
      grepl("..", base, fixed = TRUE)) stop(
    "Base revision must be a simple branch, tag, or commit identity.",
    call. = FALSE
  )
  rrp_validation_git(
    repository_root,
    c("rev-parse", "--verify", "--quiet", paste0(base, "^{commit}")),
    "base-revision validation"
  )
  base
}

rrp_validation_changed_paths <- function(repository_root, base = "HEAD") {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  base <- rrp_validation_validate_base(repository_root, base)
  tracked <- rrp_validation_git(
    repository_root,
    c("diff", "--name-only", "--relative", "--no-ext-diff", base, "--"),
    "tracked changed-path discovery"
  )
  untracked <- rrp_validation_git(
    repository_root,
    c("ls-files", "--others", "--exclude-standard"),
    "untracked changed-path discovery"
  )
  rrp_validation_normalize_paths(c(tracked, untracked))
}

rrp_validation_add_reason <- function(state, validator_id, reason) {
  existing <- state$reasons[[validator_id]]
  state$reasons[[validator_id]] <- unique(c(existing, reason))
  invisible(NULL)
}

rrp_validation_resolve_units <- function(
  registry,
  members,
  root_reason,
  changed_paths = character()
) {
  validators <- rrp_validation_validator_map(registry)
  profiles <- rrp_validation_profile_map(registry)
  state <- new.env(parent = emptyenv())
  state$order <- character()
  state$reasons <- list()
  state$visiting_validators <- character()
  state$visiting_profiles <- character()

  add_validator <- NULL
  add_member <- NULL

  add_validator <- function(validator_id, reason) {
    validator <- validators[[validator_id]]
    if (is.null(validator)) stop("Unknown validator ID: ", validator_id, call. = FALSE)
    if (validator_id %in% state$visiting_validators) stop(
      "Validator prerequisite cycle reached while resolving: ", validator_id,
      call. = FALSE
    )
    if (!validator_id %in% state$order) {
      state$visiting_validators <- c(state$visiting_validators, validator_id)
      for (prerequisite in rrp_governance_values(validator$prerequisites)) {
        add_validator(prerequisite, paste0("prerequisite of ", validator_id))
      }
      state$visiting_validators <- setdiff(state$visiting_validators, validator_id)
      state$order <- c(state$order, validator_id)
    }
    if (identical(validator$status, "active_global")) {
      rrp_validation_add_reason(state, validator_id, "globally required")
    }
    rrp_validation_add_reason(state, validator_id, reason)
  }

  add_member <- function(member, reason) {
    if (member %in% names(validators)) {
      add_validator(member, reason)
      return(invisible(NULL))
    }
    profile <- profiles[[member]]
    if (is.null(profile)) stop("Unknown profile or validator ID: ", member, call. = FALSE)
    if (member %in% state$visiting_profiles) stop(
      "Profile composition cycle reached while resolving: ", member,
      call. = FALSE
    )
    state$visiting_profiles <- c(state$visiting_profiles, member)
    for (child in rrp_governance_values(profile$includes)) {
      add_member(child, paste0("profile-included by ", member))
    }
    state$visiting_profiles <- setdiff(state$visiting_profiles, member)
    invisible(NULL)
  }

  for (member in members) add_member(member, root_reason)

  if (length(changed_paths) > 0L) {
    eligible <- Filter(function(validator) {
      validator$status %in% c("active_scoped", "replace_later")
    }, registry$validators)
    for (validator in eligible) {
      matched <- rrp_validation_matching_paths(validator, changed_paths)
      for (path in matched) {
        add_validator(validator$validator_id, paste0("path-matched: ", path))
      }
    }
  }

  lapply(state$order, function(validator_id) list(
    validator_id = validator_id,
    status = validators[[validator_id]]$status,
    runner = validators[[validator_id]]$runner,
    reasons = state$reasons[[validator_id]]
  ))
}

rrp_validation_legacy_aggregate <- function(registry, profile_id) {
  aggregate_id <- switch(
    profile_id,
    "legacy-v0.1-development" = "development",
    "legacy-v0.1-checkpoint" = "checkpoint",
    NULL
  )
  if (is.null(aggregate_id)) return(NULL)
  aggregates <- rrp_governance_named_entries(
    registry$legacy_aggregates,
    "aggregate_id"
  )
  aggregates[[aggregate_id]]
}

rrp_validation_resolve_profile <- function(
  registry,
  profile_id,
  changed_paths = character()
) {
  profiles <- rrp_validation_profile_map(registry)
  profile <- profiles[[profile_id]]
  if (is.null(profile)) stop("Unknown validation profile: ", profile_id, call. = FALSE)

  legacy <- rrp_validation_legacy_aggregate(registry, profile_id)
  if (!is.null(legacy)) {
    validators <- rrp_validation_validator_map(registry)
    members <- rrp_governance_values(legacy$ordered_members)
    return(list(
      selection_type = "legacy",
      profile_id = profile_id,
      profile_status = profile$status,
      changed_paths = character(),
      units = lapply(members, function(id) list(
        validator_id = id,
        status = validators[[id]]$status,
        runner = validators[[id]]$runner,
        reasons = paste0("frozen ", legacy$aggregate_id, " aggregate member")
      )),
      legacy_aggregate = legacy,
      no_scoped_matches = FALSE
    ))
  }

  paths <- if (identical(profile_id, "source-changed")) {
    rrp_validation_normalize_paths(changed_paths)
  } else {
    if (length(changed_paths) > 0L) stop(
      "Changed paths are supported only by source-changed.",
      call. = FALSE
    )
    character()
  }
  units <- rrp_validation_resolve_units(
    registry,
    rrp_governance_values(profile$includes),
    paste0("profile-included by ", profile_id),
    paths
  )
  path_selected <- vapply(units, function(unit) {
    any(startsWith(unit$reasons, "path-matched:"))
  }, logical(1L))
  list(
    selection_type = "forward",
    profile_id = profile_id,
    profile_status = profile$status,
    changed_paths = paths,
    units = units,
    legacy_aggregate = NULL,
    no_scoped_matches = identical(profile_id, "source-changed") &&
      !any(path_selected)
  )
}

rrp_validation_resolve_validator <- function(registry, validator_id) {
  validators <- rrp_validation_validator_map(registry)
  validator <- validators[[validator_id]]
  if (is.null(validator)) stop("Unknown validator ID: ", validator_id, call. = FALSE)
  if (!validator$status %in% c("active_global", "active_scoped", "replace_later")) stop(
    "Validator is not directly executable in forward validation: ", validator_id,
    call. = FALSE
  )
  units <- rrp_validation_resolve_units(
    registry,
    validator_id,
    "direct validator selection"
  )
  list(
    selection_type = "direct",
    profile_id = NULL,
    profile_status = validator$status,
    changed_paths = character(),
    units = units,
    legacy_aggregate = NULL,
    no_scoped_matches = FALSE
  )
}

rrp_validation_render_profiles <- function(registry) {
  cat("Validation profiles\n-------------------\n")
  for (profile in registry$profiles) {
    cat(profile$profile_id, " [", profile$status, "]\n", sep = "")
    cat("  ", profile$purpose, "\n", sep = "")
  }
  cat("\nDefault local profile: source-changed\n")
  invisible(TRUE)
}

rrp_validation_render_plan <- function(plan) {
  label <- if (is.null(plan$profile_id)) "direct validator" else plan$profile_id
  cat("Validation selection: ", label, "\n", sep = "")
  cat("Selection type: ", plan$selection_type, "\n", sep = "")
  if (length(plan$changed_paths) > 0L) {
    cat("Changed paths:\n")
    for (path in plan$changed_paths) cat("  - ", path, "\n", sep = "")
  } else if (identical(plan$profile_id, "source-changed")) {
    cat("Changed paths: none\n")
  }
  if (!is.null(plan$legacy_aggregate)) {
    cat("Legacy aggregate: ", plan$legacy_aggregate$aggregate_id, "\n", sep = "")
    cat("Execution strategy: exact eager legacy compatibility process\n")
  } else {
    cat("Execution strategy: independent validator processes\n")
  }
  cat("Resolved validators (", length(plan$units), "):\n", sep = "")
  for (index in seq_along(plan$units)) {
    unit <- plan$units[[index]]
    cat(sprintf("  %02d. %s [%s]\n", index, unit$validator_id, unit$status))
    for (reason in unit$reasons) cat("      - ", reason, "\n", sep = "")
  }
  if (isTRUE(plan$no_scoped_matches)) {
    cat("No scoped validator matched; source-fast remains selected.\n")
  }
  invisible(TRUE)
}

rrp_validation_process_environment <- function() {
  paste0("R_LIBS=", shQuote(paste(.libPaths(), collapse = .Platform$path.sep)))
}

rrp_validation_run_process <- function(runner, repository_root) {
  issues <- rrp_governance_validate_runner(runner, repository_root, "selected runner")
  if (length(issues) > 0L) stop(
    "Selected runner is unsafe:\n- ", paste(issues, collapse = "\n- "),
    call. = FALSE
  )
  output_path <- tempfile("rrp-validation-process-", fileext = ".log")
  on.exit(unlink(output_path, force = TRUE), add = TRUE)
  previous <- setwd(repository_root)
  on.exit(setwd(previous), add = TRUE)
  arguments <- c(
    shQuote(file.path(repository_root, runner$script)),
    vapply(rrp_governance_values(runner$arguments), shQuote, character(1L))
  )
  status <- system2(
    file.path(R.home("bin"), "Rscript"),
    arguments,
    stdout = output_path,
    stderr = output_path,
    env = rrp_validation_process_environment(),
    wait = TRUE
  )
  output <- if (file.exists(output_path)) readLines(output_path, warn = FALSE) else character()
  list(status = as.integer(status), output = output)
}

rrp_validation_execute_plan <- function(
  plan,
  repository_root,
  executor = rrp_validation_run_process
) {
  if (!is.null(plan$legacy_aggregate)) {
    result <- executor(plan$legacy_aggregate$runner, repository_root)
    return(list(
      passed = identical(result$status, 0L),
      status = if (identical(result$status, 0L)) 0L else 1L,
      results = list(list(
        validator_id = paste0("legacy.", plan$legacy_aggregate$aggregate_id),
        status = result$status,
        output = result$output
      ))
    ))
  }

  results <- lapply(plan$units, function(unit) {
    result <- executor(unit$runner, repository_root)
    list(
      validator_id = unit$validator_id,
      status = result$status,
      output = result$output
    )
  })
  passed <- all(vapply(results, function(result) {
    identical(result$status, 0L)
  }, logical(1L)))
  list(passed = passed, status = if (passed) 0L else 1L, results = results)
}

rrp_validation_render_execution <- function(execution) {
  for (result in execution$results) {
    cat("\n== ", result$validator_id, " ==\n", sep = "")
    if (length(result$output) > 0L) cat(paste(result$output, collapse = "\n"), "\n")
    cat("Exit status: ", result$status, "\n", sep = "")
  }
  cat("\nValidation result: ", if (execution$passed) "PASS" else "FAIL", "\n", sep = "")
  invisible(execution)
}

rrp_validation_usage <- function() paste(
  "Usage:",
  "  Rscript operations/validate.R --profile PROFILE [--explain]",
  "  Rscript operations/validate.R --profile source-changed [--base REVISION|--paths PATH...] [--explain]",
  "  Rscript operations/validate.R --validator VALIDATOR_ID [--explain]",
  "  Rscript operations/validate.R --list",
  "  Rscript operations/validate.R --mode development|checkpoint",
  sep = "\n"
)

rrp_validation_parse_cli <- function(arguments) {
  if (length(arguments) == 0L) stop(rrp_validation_usage(), call. = FALSE)
  if (length(arguments) %in% c(1L, 2L) && any(startsWith(arguments, "--mode"))) {
    mode <- if (length(arguments) == 1L && startsWith(arguments[[1L]], "--mode=")) {
      sub("^--mode=", "", arguments[[1L]])
    } else if (length(arguments) == 2L && identical(arguments[[1L]], "--mode")) {
      arguments[[2L]]
    } else {
      stop(rrp_validation_usage(), call. = FALSE)
    }
    if (!mode %in% c("development", "checkpoint")) stop(
      "Unknown validation mode: ", mode,
      call. = FALSE
    )
    return(list(
      action = "execute",
      profile_id = paste0("legacy-v0.1-", mode),
      validator_id = NULL,
      paths = character(),
      base = NULL,
      legacy_alias = mode
    ))
  }

  parsed <- list(
    action = "execute", profile_id = NULL, validator_id = NULL,
    paths = character(), base = NULL, legacy_alias = NULL
  )
  index <- 1L
  while (index <= length(arguments)) {
    argument <- arguments[[index]]
    if (identical(argument, "--list")) {
      if (length(arguments) != 1L) stop("--list cannot be combined with other arguments.", call. = FALSE)
      parsed$action <- "list"
      return(parsed)
    } else if (identical(argument, "--explain")) {
      parsed$action <- "explain"
      index <- index + 1L
    } else if (identical(argument, "--profile") || identical(argument, "--validator") ||
               identical(argument, "--base")) {
      if (index == length(arguments)) stop("Missing value after ", argument, ".", call. = FALSE)
      field <- switch(argument, "--profile" = "profile_id", "--validator" = "validator_id", "--base" = "base")
      if (!is.null(parsed[[field]])) stop(argument, " was supplied more than once.", call. = FALSE)
      parsed[[field]] <- arguments[[index + 1L]]
      index <- index + 2L
    } else if (startsWith(argument, "--profile=") || startsWith(argument, "--validator=") ||
               startsWith(argument, "--base=")) {
      field <- if (startsWith(argument, "--profile=")) "profile_id" else {
        if (startsWith(argument, "--validator=")) "validator_id" else "base"
      }
      if (!is.null(parsed[[field]])) stop("Selector was supplied more than once.", call. = FALSE)
      parsed[[field]] <- sub("^[^=]+=[ ]*", "", argument)
      index <- index + 1L
    } else if (identical(argument, "--paths")) {
      end <- index + 1L
      while (end <= length(arguments) && !startsWith(arguments[[end]], "--")) end <- end + 1L
      if (end == index + 1L) stop("--paths requires at least one path.", call. = FALSE)
      values <- arguments[(index + 1L):(end - 1L)]
      if (any(is.na(values))) stop("--paths requires valid path values.", call. = FALSE)
      parsed$paths <- c(parsed$paths, values)
      index <- end
    } else {
      stop("Unknown validation argument: ", argument, "\n", rrp_validation_usage(), call. = FALSE)
    }
  }

  if (is.null(parsed$profile_id) == is.null(parsed$validator_id)) stop(
    "Select exactly one --profile or --validator.",
    call. = FALSE
  )
  if (!is.null(parsed$validator_id) && (length(parsed$paths) > 0L || !is.null(parsed$base))) stop(
    "--paths and --base require --profile source-changed.",
    call. = FALSE
  )
  if (!is.null(parsed$profile_id) &&
      (!identical(parsed$profile_id, "source-changed")) &&
      (length(parsed$paths) > 0L || !is.null(parsed$base))) stop(
    "--paths and --base are supported only by source-changed.",
    call. = FALSE
  )
  if (length(parsed$paths) > 0L && !is.null(parsed$base)) stop(
    "Select either explicit --paths or --base discovery, not both.",
    call. = FALSE
  )
  parsed
}
