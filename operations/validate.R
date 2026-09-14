#!/usr/bin/env Rscript

repository_root <- normalizePath(
  file.path(dirname(sub("^--file=", "", grep(
    "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
  )[[1L]])), ".."),
  mustWork = TRUE
)

source(file.path(repository_root, "validation", "R", "ownership.R"))
source(file.path(repository_root, "validation", "R", "dispatcher.R"))

parsed <- tryCatch(
  rrp_validation_parse_cli(commandArgs(trailingOnly = TRUE)),
  error = function(condition) {
    message(conditionMessage(condition))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
)
registry <- tryCatch(
  rrp_validation_load_registry(repository_root),
  error = function(condition) {
    message(conditionMessage(condition))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
)

if (identical(parsed$action, "list")) {
  rrp_validation_render_profiles(registry)
  quit(save = "no", status = 0L, runLast = FALSE)
}

if (!is.null(parsed$legacy_alias)) {
  cat(
    "DEPRECATED LEGACY ALIAS: --mode ", parsed$legacy_alias,
    " maps exactly to --profile ", parsed$profile_id, ".\n",
    sep = ""
  )
}

plan <- tryCatch({
  if (!is.null(parsed$validator_id)) {
    rrp_validation_resolve_validator(registry, parsed$validator_id)
  } else {
    paths <- parsed$paths
    if (identical(parsed$profile_id, "source-changed") && length(paths) == 0L) {
      paths <- rrp_validation_changed_paths(
        repository_root,
        if (is.null(parsed$base)) "HEAD" else parsed$base
      )
    }
    rrp_validation_resolve_profile(registry, parsed$profile_id, paths)
  }
}, error = function(condition) {
  message(conditionMessage(condition))
  quit(save = "no", status = 2L, runLast = FALSE)
})

rrp_validation_render_plan(plan)
if (identical(parsed$action, "explain")) {
  cat("Explain only: no validator was executed.\n")
  quit(save = "no", status = 0L, runLast = FALSE)
}

execution <- tryCatch(
  rrp_validation_execute_plan(plan, repository_root),
  interrupt = function(condition) {
    message("Validation interrupted; the active child process was signaled by R.")
    quit(save = "no", status = 130L, runLast = FALSE)
  },
  error = function(condition) {
    message("Validation dispatch failed: ", conditionMessage(condition))
    quit(save = "no", status = 1L, runLast = FALSE)
  }
)
rrp_validation_render_execution(execution)
quit(save = "no", status = execution$status, runLast = FALSE)
