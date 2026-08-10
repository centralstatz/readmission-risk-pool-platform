# Maintained-document validation.
#
# Markdown is parsed only far enough to validate repository-local navigation.
# This is intentionally not a general Markdown renderer or external link check.

rrp_required_governing_documents <- function() {
  c(
    "README.md",
    "AGENTS.md",
    "LICENSE-STATUS.md",
    "docs/README.md",
    "docs/START-HERE.md",
    "docs/vision/platform-true-north.md",
    "docs/architecture/platform-architecture.md",
    "docs/architecture/platform-implementation-plan.md",
    "docs/architecture/reference-asset-reconciliation.md",
    "docs/architecture/platform-implementation-record.md",
    "docs/architecture/open-decisions.md",
    "docs/development/implementation-conventions.md",
    "docs/development/repository-policies.md",
    "docs/operations/README.md",
    "docs/operations/validation.md"
  )
}

rrp_navigation_expectations <- function() {
  list(
    "README.md" = c(
      "LICENSE-STATUS.md",
      "docs/README.md",
      "docs/START-HERE.md",
      "docs/vision/platform-true-north.md",
      "docs/architecture/platform-architecture.md",
      "docs/architecture/platform-implementation-plan.md",
      "docs/architecture/reference-asset-reconciliation.md",
      "docs/architecture/platform-implementation-record.md"
    ),
    "docs/README.md" = c(
      "README.md",
      "AGENTS.md",
      "docs/START-HERE.md",
      "docs/vision/platform-true-north.md",
      "docs/architecture/platform-architecture.md",
      "docs/architecture/platform-implementation-plan.md",
      "docs/architecture/reference-asset-reconciliation.md",
      "docs/architecture/platform-implementation-record.md",
      "docs/architecture/open-decisions.md",
      "docs/development/implementation-conventions.md",
      "docs/development/repository-policies.md",
      "docs/operations/README.md"
    ),
    "docs/START-HERE.md" = c(
      "AGENTS.md",
      "docs/vision/platform-true-north.md",
      "docs/architecture/platform-architecture.md",
      "docs/architecture/platform-implementation-plan.md",
      "docs/architecture/reference-asset-reconciliation.md",
      "docs/architecture/platform-implementation-record.md",
      "docs/architecture/open-decisions.md",
      "docs/development/implementation-conventions.md",
      "docs/development/repository-policies.md",
      "docs/operations/README.md"
    ),
    "docs/vision/platform-true-north.md" = c(
      "docs/architecture/platform-architecture.md",
      "docs/architecture/platform-implementation-plan.md",
      "docs/architecture/platform-implementation-record.md",
      "docs/architecture/open-decisions.md"
    ),
    "docs/architecture/platform-architecture.md" =
      "docs/vision/platform-true-north.md",
    "docs/architecture/platform-implementation-plan.md" = c(
      "docs/vision/platform-true-north.md",
      "docs/architecture/platform-architecture.md",
      "docs/architecture/platform-implementation-record.md",
      "docs/architecture/reference-asset-reconciliation.md"
    ),
    "docs/architecture/platform-implementation-record.md" = c(
      "docs/vision/platform-true-north.md",
      "docs/architecture/platform-architecture.md",
      "docs/architecture/platform-implementation-plan.md",
      "docs/architecture/reference-asset-reconciliation.md"
    )
  )
}

rrp_markdown_files <- function(repository_root) {
  files <- list.files(
    repository_root,
    pattern = "[.]md$",
    recursive = TRUE,
    full.names = TRUE,
    all.files = TRUE
  )
  files[!grepl("(^|/)[.]git/", files)]
}

rrp_extract_markdown_links <- function(path, repository_root) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  records <- list()

  for (line_number in seq_along(lines)) {
    matches <- gregexpr("\\[[^][]+\\]\\([^)]+\\)", lines[[line_number]], perl = TRUE)
    tokens <- regmatches(lines[[line_number]], matches)[[1L]]
    if (identical(tokens, character())) next

    for (token in tokens) {
      destination <- sub("^[^(]+\\(([^)]+)\\)$", "\\1", token, perl = TRUE)
      destination <- sub("[[:space:]]+['\"].*$", "", destination)
      destination <- sub("^<", "", destination)
      destination <- sub(">$", "", destination)
      records[[length(records) + 1L]] <- data.frame(
        file = substring(path, nchar(repository_root) + 2L),
        line = line_number,
        target = destination,
        stringsAsFactors = FALSE
      )
    }
  }

  rrp_bind_rows(records, function() {
    data.frame(file = character(), line = integer(), target = character())
  })
}

rrp_is_external_or_anchor_link <- function(target) {
  startsWith(target, "#") || grepl("^[A-Za-z][A-Za-z0-9+.-]*:", target)
}

rrp_resolve_link <- function(repository_root, source_file, target) {
  target_without_anchor <- sub("#.*$", "", target)
  if (!nzchar(target_without_anchor)) return(NA_character_)

  source_path <- file.path(repository_root, source_file)
  normalizePath(
    file.path(dirname(source_path), target_without_anchor),
    mustWork = FALSE
  )
}

rrp_repository_relative_path <- function(repository_root, path) {
  root <- normalizePath(repository_root, mustWork = TRUE)
  normalized <- normalizePath(path, mustWork = FALSE)
  prefix <- paste0(root, .Platform$file.sep)
  if (!startsWith(normalized, prefix)) return(normalized)
  substring(normalized, nchar(prefix) + 1L)
}

rrp_machine_path_pattern <- function() {
  unix <- paste0("/", "(Users|home)", "/[^[:space:])>]+")
  windows <- paste0("[A-Za-z]:[/\\\\]", "Users", "[/\\\\]")
  paste(unix, windows, sep = "|")
}

rrp_local_file_uri <- function() paste0("file", "://")

rrp_validate_documentation <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()

  required <- rrp_required_governing_documents()
  missing <- required[!file.exists(file.path(repository_root, required))]
  if (length(missing) > 0L) {
    issues <- c(issues, lapply(missing, function(path) {
      rrp_issue(
        "required_documents", "missing_governing_document",
        "Required governing document is missing.", path
      )
    }))
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "required_documents", length(missing) == 0L,
    paste(length(required), "required governing documents")
  )

  markdown_files <- rrp_markdown_files(repository_root)
  links <- rrp_bind_rows(
    lapply(markdown_files, rrp_extract_markdown_links, repository_root = repository_root),
    function() data.frame(file = character(), line = integer(), target = character())
  )

  local_links <- links[!vapply(links$target, rrp_is_external_or_anchor_link, logical(1)), ]
  broken_count <- 0L
  if (nrow(local_links) > 0L) {
    for (index in seq_len(nrow(local_links))) {
      link <- local_links[index, ]
      resolved <- rrp_resolve_link(repository_root, link$file, link$target)
      if (is.na(resolved) || !file.exists(resolved)) {
        broken_count <- broken_count + 1L
        issues[[length(issues) + 1L]] <- rrp_issue(
          "local_markdown_links", "broken_local_link",
          paste0("Local link target does not exist: ", link$target),
          link$file, link$line
        )
      }
    }
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "local_markdown_links", broken_count == 0L,
    paste(nrow(local_links), "repository-local links")
  )

  navigation_missing <- 0L
  expectations <- rrp_navigation_expectations()
  for (source in names(expectations)) {
    source_links <- links[links$file == source, , drop = FALSE]
    resolved_targets <- if (nrow(source_links) == 0L) {
      character()
    } else {
      vapply(source_links$target, function(target) {
        if (rrp_is_external_or_anchor_link(target)) return(NA_character_)
        rrp_repository_relative_path(
          repository_root,
          rrp_resolve_link(repository_root, source, target)
        )
      }, character(1))
    }
    resolved_targets <- resolved_targets[!is.na(resolved_targets)]

    absent <- setdiff(expectations[[source]], resolved_targets)
    for (target in absent) {
      navigation_missing <- navigation_missing + 1L
      issues[[length(issues) + 1L]] <- rrp_issue(
        "governing_navigation", "missing_navigation_target",
        paste0("Maintained navigation must link to: ", target), source
      )
    }
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "governing_navigation", navigation_missing == 0L,
    paste(length(expectations), "maintained navigation sources")
  )

  machine_path_count <- 0L
  file_uri_count <- 0L
  for (path in markdown_files) {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    relative <- substring(path, nchar(repository_root) + 2L)
    machine_lines <- grep(rrp_machine_path_pattern(), lines, perl = TRUE)
    uri_lines <- grep(rrp_local_file_uri(), lines, fixed = TRUE)

    for (line_number in machine_lines) {
      machine_path_count <- machine_path_count + 1L
      issues[[length(issues) + 1L]] <- rrp_issue(
        "portable_document_paths", "machine_specific_path",
        "Documentation contains an obvious machine-specific filesystem path.",
        relative, line_number
      )
    }
    for (line_number in uri_lines) {
      file_uri_count <- file_uri_count + 1L
      issues[[length(issues) + 1L]] <- rrp_issue(
        "portable_document_paths", "local_file_uri",
        "Documentation contains a local-file URI.", relative, line_number
      )
    }
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "portable_document_paths", machine_path_count + file_uri_count == 0L,
    "no machine-specific paths or local-file URIs"
  )

  rrp_validation_result(
    "Documentation validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}
