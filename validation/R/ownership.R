rrp_governance_statuses <- function() {
  c(
    "active_global",
    "active_scoped",
    "composite",
    "legacy_callable",
    "historical_evidence",
    "replace_later",
    "retire_later"
  )
}

rrp_governance_issue <- function(code, message) {
  paste0(code, ": ", message)
}

rrp_governance_values <- function(value) {
  if (is.null(value) || length(value) == 0L) return(character())
  unname(as.character(unlist(value, use.names = FALSE)))
}

rrp_governance_scalar <- function(value, fallback = "") {
  values <- rrp_governance_values(value)
  if (length(values) == 1L && !is.na(values)) values else fallback
}

rrp_governance_named_entries <- function(entries, id_field) {
  if (!is.list(entries) || length(entries) == 0L) return(list())
  ids <- vapply(entries, function(entry) {
    value <- entry[[id_field]]
    if (is.character(value) && length(value) == 1L) value else ""
  }, character(1L))
  stats::setNames(entries, ids)
}

rrp_governance_read_registry <- function(repository_root) {
  path <- file.path(repository_root, "validation", "ownership.yml")
  if (!file.exists(path)) {
    stop("Validation ownership registry does not exist: validation/ownership.yml", call. = FALSE)
  }
  yaml::read_yaml(path)
}

rrp_governance_ledger_ids <- function(repository_root) {
  path <- file.path(repository_root, "docs", "development", "transition-ledger.md")
  if (!file.exists(path)) return(character())
  lines <- readLines(path, warn = FALSE)
  rows <- grep("^\\| `[^`]+` \\|", lines, value = TRUE)
  sub("^\\| `([^`]+)` \\|.*$", "\\1", rows)
}

rrp_governance_unknown_fields <- function(value, allowed, location) {
  fields <- names(value)
  if (is.null(fields)) return(character())
  unknown <- setdiff(fields, allowed)
  if (length(unknown) == 0L) return(character())
  rrp_governance_issue(
    "unknown_field",
    paste0(location, " contains unsupported field(s): ", paste(unknown, collapse = ", "))
  )
}

rrp_governance_missing_fields <- function(value, required, location) {
  fields <- names(value)
  missing <- setdiff(required, fields)
  if (length(missing) == 0L) return(character())
  rrp_governance_issue(
    "missing_field",
    paste0(location, " is missing field(s): ", paste(missing, collapse = ", "))
  )
}

rrp_governance_valid_id <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl("^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$", value, perl = TRUE)
}

rrp_governance_path_issue <- function(path, location, suffix = FALSE) {
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    return(rrp_governance_issue("unsafe_path", paste0(location, " must be a nonempty string.")))
  }
  unsafe_characters <- c("`", "$", ";", "|", "*", "?", "{", "}", "[", "]", "\n", "\r")
  unsafe_syntax <- any(vapply(
    unsafe_characters,
    function(character) grepl(character, path, fixed = TRUE),
    logical(1L)
  ))
  absolute <- !suffix && (startsWith(path, "/") || grepl("^[A-Za-z]:[/\\\\]", path))
  parent <- !suffix && any(strsplit(gsub("\\\\", "/", path), "/", fixed = TRUE)[[1L]] == "..")
  home <- !suffix && startsWith(path, "~")
  if (unsafe_syntax || absolute || parent || home) {
    return(rrp_governance_issue("unsafe_path", paste0(location, " is not a safe literal repository path: ", path)))
  }
  character()
}

rrp_governance_validate_runner <- function(runner, repository_root, location) {
  issues <- c(
    rrp_governance_unknown_fields(runner, c("script", "arguments"), location),
    rrp_governance_missing_fields(runner, c("script", "arguments"), location)
  )
  script <- runner$script
  issues <- c(issues, rrp_governance_path_issue(script, paste0(location, ".script")))
  if (is.character(script) && length(script) == 1L && nzchar(script) &&
      length(rrp_governance_path_issue(script, location)) == 0L) {
    full_path <- file.path(repository_root, script)
    if (!file.exists(full_path) || dir.exists(full_path)) {
      issues <- c(issues, rrp_governance_issue(
        "missing_runner", paste0(location, " references a missing script: ", script)
      ))
    } else if (nzchar(Sys.readlink(full_path))) {
      issues <- c(issues, rrp_governance_issue(
        "linked_runner", paste0(location, " must not reference a symbolic link: ", script)
      ))
    }
    if (!grepl("[.]R$", script)) {
      issues <- c(issues, rrp_governance_issue(
        "invalid_runner", paste0(location, " must reference an R script: ", script)
      ))
    }
  }
  arguments <- rrp_governance_values(runner$arguments)
  if (any(grepl("\n", arguments, fixed = TRUE)) ||
      any(grepl("\r", arguments, fixed = TRUE))) {
    issues <- c(issues, rrp_governance_issue(
      "unsafe_argument", paste0(location, " arguments must be literal single-line values.")
    ))
  }
  issues
}

rrp_governance_cycle_issues <- function(graph, graph_name) {
  if (length(graph) == 0L) return(character())
  state <- stats::setNames(rep.int(0L, length(graph)), names(graph))
  issues <- character()
  visit <- function(node, trail) {
    if (state[[node]] == 1L) {
      cycle_start <- match(node, trail)
      cycle <- c(trail[cycle_start:length(trail)], node)
      issues <<- c(issues, rrp_governance_issue(
        "dependency_cycle",
        paste0(graph_name, " contains a cycle: ", paste(cycle, collapse = " -> "))
      ))
      return(invisible(NULL))
    }
    if (state[[node]] == 2L) return(invisible(NULL))
    state[[node]] <<- 1L
    for (dependency in graph[[node]]) {
      if (dependency %in% names(graph)) visit(dependency, c(trail, node))
    }
    state[[node]] <<- 2L
    invisible(NULL)
  }
  for (node in names(graph)) {
    if (state[[node]] == 0L) visit(node, character())
  }
  unique(issues)
}

rrp_governance_extract_current_aggregates <- function(repository_root) {
  path <- file.path(repository_root, "operations", "lib", "platform-validation.R")
  lines <- readLines(path, warn = FALSE)
  start <- grep("^rrp_validate_platform <- function", lines)
  if (length(start) != 1L) stop("Could not locate rrp_validate_platform().", call. = FALSE)
  body <- lines[start:length(lines)]
  list_start <- grep("^[[:space:]]*results <- list[(]", body)[1L]
  checkpoint_start <- grep("^[[:space:]]*if [(]identical[(]mode, \"checkpoint\"", body)[1L]
  append_after <- grep("^[[:space:]]*after = 4L", body)[1L]
  if (any(is.na(c(list_start, checkpoint_start, append_after)))) {
    stop("Could not parse current validation aggregate membership.", call. = FALSE)
  }
  extract_calls <- function(values) {
    matches <- regmatches(values, regexpr("rrp_[a-zA-Z0-9_]+(?=[(]repository_root[)])", values, perl = TRUE))
    unname(matches[nzchar(matches)])
  }
  development <- extract_calls(body[(list_start + 1L):(checkpoint_start - 1L)])
  checkpoints <- extract_calls(body[(checkpoint_start + 1L):(append_after - 1L)])
  list(
    development = development,
    checkpoint = append(development, checkpoints, after = 4L)
  )
}

rrp_governance_expected_current_checks <- function(repository_root) {
  aggregates <- rrp_governance_extract_current_aggregates(repository_root)
  phase_runners <- sort(file.path(
    "tests",
    list.files(
      file.path(repository_root, "tests"),
      pattern = "^run-phase[0-9]+-tests[.]R$"
    )
  ))
  direct_validators <- c(
    "operations/validate-documentation.R",
    "operations/validate-producer.R",
    "operations/validate-application-artifact.R",
    "operations/validate-connect-cloud-deployment.R",
    "operations/validate-hospital-distribution.R",
    "operations/validate-hospital-git-realization.R"
  )
  lifecycle_checks <- c(
    "rrp_validate_selected_canonical_producer",
    "rrp_validate_completed_application_artifact",
    "rrp_validate_completed_connect_cloud_deployment",
    "rrp_validate_completed_hospital_distribution",
    "rrp_validate_completed_hospital_git_realization",
    "rrp_validate_release_preparation",
    "rrp_release_source_revision",
    "operations/publish-release.R",
    "rrp_publication_preflight",
    "rrp_publication_checkpoint",
    "rrp_verify_published_release"
  )
  unique(c(
    aggregates$checkpoint,
    phase_runners,
    direct_validators,
    lifecycle_checks,
    "tests/run-governance-tests.R"
  ))
}

rrp_governance_validate_legacy_aggregates <- function(registry, repository_root) {
  issues <- character()
  validators <- registry$validators
  check_to_id <- list()
  for (validator in validators) {
    for (check in rrp_governance_values(validator$current_checks)) {
      check_to_id[[check]] <- c(check_to_id[[check]], validator$validator_id)
    }
  }
  actual <- rrp_governance_extract_current_aggregates(repository_root)
  aggregates <- rrp_governance_named_entries(registry$legacy_aggregates, "aggregate_id")
  profiles <- rrp_governance_named_entries(registry$profiles, "profile_id")
  for (mode in names(actual)) {
    ambiguous <- actual[[mode]][vapply(actual[[mode]], function(check) {
      length(unique(check_to_id[[check]])) != 1L
    }, logical(1L))]
    if (length(ambiguous) > 0L) {
      issues <- c(issues, rrp_governance_issue(
        "unclassified_current_validator",
        paste0(mode, " aggregate checks do not each have one owner: ", paste(ambiguous, collapse = ", "))
      ))
      next
    }
    actual_ids <- unname(vapply(
      actual[[mode]],
      function(check) unique(check_to_id[[check]]),
      character(1L)
    ))
    aggregate <- aggregates[[mode]]
    if (is.null(aggregate)) {
      issues <- c(issues, rrp_governance_issue(
        "missing_legacy_aggregate", paste0("Missing captured aggregate: ", mode)
      ))
      next
    }
    captured <- rrp_governance_values(aggregate$ordered_members)
    if (!identical(captured, actual_ids)) {
      issues <- c(issues, rrp_governance_issue(
        "legacy_membership_mismatch", paste0(mode, " membership does not match current executable order.")
      ))
    }
    profile_id <- paste0("legacy-v0.1-", mode)
    profile <- profiles[[profile_id]]
    if (is.null(profile) || !identical(rrp_governance_values(profile$includes), captured)) {
      issues <- c(issues, rrp_governance_issue(
        "legacy_profile_mismatch", paste0(profile_id, " does not match its captured aggregate.")
      ))
    }
  }
  issues
}

rrp_governance_validate_registry <- function(registry, repository_root, ledger_ids = NULL) {
  issues <- character()
  top_fields <- c(
    "registry_version", "governance_state", "protected_invariants",
    "validators", "profiles", "legacy_aggregates"
  )
  issues <- c(
    issues,
    rrp_governance_unknown_fields(registry, top_fields, "registry"),
    rrp_governance_missing_fields(registry, top_fields, "registry")
  )
  if (!identical(registry$registry_version, 1L)) {
    issues <- c(issues, rrp_governance_issue("unsupported_registry_version", "registry_version must be 1."))
  }

  governance_fields <- c(
    "classification_only", "activated_dispatcher",
    "current_development_runner", "current_checkpoint_runner"
  )
  state <- registry$governance_state
  issues <- c(
    issues,
    rrp_governance_unknown_fields(state, governance_fields, "governance_state"),
    rrp_governance_missing_fields(state, governance_fields, "governance_state")
  )
  if (!isTRUE(state$classification_only) || !identical(state$activated_dispatcher, FALSE)) {
    issues <- c(issues, rrp_governance_issue(
      "invalid_governance_state",
      "Increment 1.A must remain classification-only with dispatcher activation false."
    ))
  }
  issues <- c(
    issues,
    rrp_governance_validate_runner(state$current_development_runner, repository_root, "governance_state.current_development_runner"),
    rrp_governance_validate_runner(state$current_checkpoint_runner, repository_root, "governance_state.current_checkpoint_runner")
  )

  invariant_fields <- c("invariant_id", "description")
  invariants <- registry$protected_invariants
  invariant_ids <- character()
  for (index in seq_along(invariants)) {
    invariant <- invariants[[index]]
    location <- paste0("protected_invariants[", index, "]")
    issues <- c(
      issues,
      rrp_governance_unknown_fields(invariant, invariant_fields, location),
      rrp_governance_missing_fields(invariant, invariant_fields, location)
    )
    if (!rrp_governance_valid_id(invariant$invariant_id)) {
      issues <- c(issues, rrp_governance_issue("invalid_id", paste0(location, " has an invalid invariant_id.")))
    }
    invariant_ids <- c(invariant_ids, invariant$invariant_id)
  }
  duplicate_invariants <- unique(invariant_ids[duplicated(invariant_ids)])
  if (length(duplicate_invariants) > 0L) {
    issues <- c(issues, rrp_governance_issue(
      "duplicate_id", paste0("Duplicate invariant IDs: ", paste(duplicate_invariants, collapse = ", "))
    ))
  }

  validator_fields <- c(
    "validator_id", "owner_boundary", "lifecycle_scope", "status", "invariant",
    "runner", "trigger_paths", "prerequisites", "transition_ledger_id", "current_checks"
  )
  trigger_fields <- c("exact", "prefixes", "suffixes")
  validator_ids <- character()
  validator_graph <- list()
  referenced_invariants <- character()
  all_current_checks <- character()
  for (index in seq_along(registry$validators)) {
    validator <- registry$validators[[index]]
    location <- paste0("validators[", index, "]")
    issues <- c(
      issues,
      rrp_governance_unknown_fields(validator, validator_fields, location),
      rrp_governance_missing_fields(validator, validator_fields, location)
    )
    id <- rrp_governance_scalar(
      validator$validator_id,
      paste0("__invalid_validator_", index)
    )
    validator_ids <- c(validator_ids, id)
    if (!rrp_governance_valid_id(id)) {
      issues <- c(issues, rrp_governance_issue("invalid_id", paste0(location, " has an invalid validator_id.")))
    }
    if (!isTRUE(validator$status %in% setdiff(rrp_governance_statuses(), "composite"))) {
      issues <- c(issues, rrp_governance_issue(
        "invalid_status",
        paste0(location, " has invalid validator status: ", rrp_governance_scalar(validator$status, "<missing>"))
      ))
    }
    references <- rrp_governance_values(validator$invariant)
    unknown_invariants <- setdiff(references, invariant_ids)
    if (length(references) == 0L || length(unknown_invariants) > 0L) {
      issues <- c(issues, rrp_governance_issue(
        "unknown_invariant", paste0(location, " references unknown/no protected invariants: ", paste(unknown_invariants, collapse = ", "))
      ))
    }
    if (!identical(validator$status, "historical_evidence")) {
      referenced_invariants <- c(referenced_invariants, references)
    }
    issues <- c(issues, rrp_governance_validate_runner(validator$runner, repository_root, paste0(location, ".runner")))
    triggers <- validator$trigger_paths
    issues <- c(
      issues,
      rrp_governance_unknown_fields(triggers, trigger_fields, paste0(location, ".trigger_paths")),
      rrp_governance_missing_fields(triggers, trigger_fields, paste0(location, ".trigger_paths"))
    )
    for (field in trigger_fields) {
      values <- rrp_governance_values(triggers[[field]])
      if (anyDuplicated(values)) {
        issues <- c(issues, rrp_governance_issue(
          "duplicate_trigger", paste0(location, ".trigger_paths.", field, " contains duplicates.")
        ))
      }
      for (value in values) {
        issues <- c(issues, rrp_governance_path_issue(
          value, paste0(location, ".trigger_paths.", field), suffix = identical(field, "suffixes")
        ))
      }
    }
    prerequisites <- rrp_governance_values(validator$prerequisites)
    validator_graph[[id]] <- prerequisites
    current_checks <- rrp_governance_values(validator$current_checks)
    if (length(current_checks) == 0L) {
      issues <- c(issues, rrp_governance_issue(
        "unclassified_current_validator", paste0(location, " has no current_checks inventory.")
      ))
    }
    all_current_checks <- c(all_current_checks, current_checks)
  }
  duplicate_validators <- unique(validator_ids[duplicated(validator_ids)])
  if (length(duplicate_validators) > 0L) {
    issues <- c(issues, rrp_governance_issue(
      "duplicate_id", paste0("Duplicate validator IDs: ", paste(duplicate_validators, collapse = ", "))
    ))
  }
  for (id in names(validator_graph)) {
    unknown <- setdiff(validator_graph[[id]], validator_ids)
    if (length(unknown) > 0L) {
      issues <- c(issues, rrp_governance_issue(
        "unknown_reference", paste0(id, " has unknown prerequisite(s): ", paste(unknown, collapse = ", "))
      ))
    }
  }
  issues <- c(issues, rrp_governance_cycle_issues(validator_graph, "validator prerequisites"))

  profile_fields <- c("profile_id", "purpose", "status", "includes")
  profile_ids <- character()
  profile_graph <- list()
  profile_includes <- list()
  for (index in seq_along(registry$profiles)) {
    profile <- registry$profiles[[index]]
    location <- paste0("profiles[", index, "]")
    issues <- c(
      issues,
      rrp_governance_unknown_fields(profile, profile_fields, location),
      rrp_governance_missing_fields(profile, profile_fields, location)
    )
    id <- rrp_governance_scalar(
      profile$profile_id,
      paste0("__invalid_profile_", index)
    )
    profile_ids <- c(profile_ids, id)
    if (!rrp_governance_valid_id(id)) {
      issues <- c(issues, rrp_governance_issue("invalid_id", paste0(location, " has an invalid profile_id.")))
    }
    if (!isTRUE(profile$status %in% c("composite", "legacy_callable"))) {
      issues <- c(issues, rrp_governance_issue(
        "invalid_status",
        paste0(location, " has invalid profile status: ", rrp_governance_scalar(profile$status, "<missing>"))
      ))
    }
    includes <- rrp_governance_values(profile$includes)
    if (length(includes) == 0L || anyDuplicated(includes)) {
      issues <- c(issues, rrp_governance_issue(
        "invalid_profile_membership", paste0(location, " must contain unique members.")
      ))
    }
    profile_includes[[id]] <- includes
  }
  duplicate_profiles <- unique(profile_ids[duplicated(profile_ids)])
  if (length(duplicate_profiles) > 0L) {
    issues <- c(issues, rrp_governance_issue(
      "duplicate_id", paste0("Duplicate profile IDs: ", paste(duplicate_profiles, collapse = ", "))
    ))
  }
  collisions <- intersect(validator_ids, profile_ids)
  if (length(collisions) > 0L) {
    issues <- c(issues, rrp_governance_issue(
      "ambiguous_id", paste0("Validator/profile ID collisions: ", paste(collisions, collapse = ", "))
    ))
  }
  all_routing_ids <- c(validator_ids, profile_ids)
  for (id in names(profile_includes)) {
    unknown <- setdiff(profile_includes[[id]], all_routing_ids)
    if (length(unknown) > 0L) {
      issues <- c(issues, rrp_governance_issue(
        "unknown_reference", paste0(id, " has unknown member(s): ", paste(unknown, collapse = ", "))
      ))
    }
    profile_graph[[id]] <- intersect(profile_includes[[id]], profile_ids)
  }
  issues <- c(issues, rrp_governance_cycle_issues(profile_graph, "profile composition"))
  expand_profile <- function(id, seen = character()) {
    if (id %in% seen || !id %in% names(profile_includes)) return(character())
    members <- profile_includes[[id]]
    nested <- unlist(lapply(
      intersect(members, profile_ids),
      expand_profile,
      seen = c(seen, id)
    ), use.names = FALSE)
    unique(c(intersect(members, validator_ids), nested))
  }
  validator_status <- stats::setNames(
    vapply(
      registry$validators,
      function(validator) rrp_governance_scalar(validator$status, "<missing>"),
      character(1L)
    ),
    validator_ids
  )
  for (profile in registry$profiles) {
    if (!identical(profile$status, "legacy_callable")) {
      resolved <- expand_profile(profile$profile_id)
      prohibited <- resolved[validator_status[resolved] %in% c(
        "legacy_callable", "historical_evidence", "retire_later"
      )]
      if (length(prohibited) > 0L) {
        issues <- c(issues, rrp_governance_issue(
          "legacy_profile_leak",
          paste0(profile$profile_id, " includes legacy/historical unit(s): ", paste(prohibited, collapse = ", "))
        ))
      }
    }
  }
  active_global <- validator_ids[validator_status == "active_global"]
  source_fast <- profile_includes[["source-fast"]]
  if (length(active_global) > 0L && !all(active_global %in% source_fast)) {
    issues <- c(issues, rrp_governance_issue(
      "unmatched_active_unit", "source-fast does not include every active_global validator."
    ))
  }

  aggregate_fields <- c("aggregate_id", "function_name", "runner", "ordered_members")
  aggregate_ids <- character()
  for (index in seq_along(registry$legacy_aggregates)) {
    aggregate <- registry$legacy_aggregates[[index]]
    location <- paste0("legacy_aggregates[", index, "]")
    issues <- c(
      issues,
      rrp_governance_unknown_fields(aggregate, aggregate_fields, location),
      rrp_governance_missing_fields(aggregate, aggregate_fields, location),
      rrp_governance_validate_runner(aggregate$runner, repository_root, paste0(location, ".runner"))
    )
    aggregate_ids <- c(aggregate_ids, aggregate$aggregate_id)
    members <- rrp_governance_values(aggregate$ordered_members)
    unknown <- setdiff(members, validator_ids)
    if (length(unknown) > 0L || anyDuplicated(members)) {
      issues <- c(issues, rrp_governance_issue(
        "invalid_legacy_membership",
        paste0(location, " has duplicate or unknown member(s): ", paste(unknown, collapse = ", "))
      ))
    }
  }
  if (anyDuplicated(aggregate_ids)) {
    issues <- c(issues, rrp_governance_issue("duplicate_id", "Legacy aggregate IDs must be unique."))
  }

  if (is.null(ledger_ids)) ledger_ids <- rrp_governance_ledger_ids(repository_root)
  if (anyDuplicated(ledger_ids)) {
    issues <- c(issues, rrp_governance_issue("duplicate_ledger_id", "Transition ledger IDs must be unique."))
  }
  linked_ledger_ids <- vapply(
    registry$validators,
    function(validator) rrp_governance_scalar(validator$transition_ledger_id),
    character(1L)
  )
  unknown_ledger <- setdiff(linked_ledger_ids, ledger_ids)
  if (length(unknown_ledger) > 0L) {
    issues <- c(issues, rrp_governance_issue(
      "unknown_ledger_reference", paste0("Unknown transition ledger IDs: ", paste(unknown_ledger, collapse = ", "))
    ))
  }

  uncovered_invariants <- setdiff(invariant_ids, unique(referenced_invariants))
  if (length(uncovered_invariants) > 0L) {
    issues <- c(issues, rrp_governance_issue(
      "orphaned_invariant", paste0("Protected invariants have no current owner: ", paste(uncovered_invariants, collapse = ", "))
    ))
  }
  expected_checks <- rrp_governance_expected_current_checks(repository_root)
  missing_checks <- setdiff(expected_checks, unique(all_current_checks))
  if (length(missing_checks) > 0L) {
    issues <- c(issues, rrp_governance_issue(
      "unclassified_current_validator", paste0("Current checks lack an owner: ", paste(missing_checks, collapse = ", "))
    ))
  }

  issues <- c(issues, rrp_governance_validate_legacy_aggregates(registry, repository_root))
  list(passed = length(issues) == 0L, issues = unique(issues))
}
