#!/usr/bin/env Rscript

# Validate the repository-foundation and realized source-inventory claims.
# This base-R maintainer operation is intentionally not a validation framework
# or an installed RRP command.

script_argument <- grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)
if (length(script_argument) != 1L) {
  stop("Cannot determine the repository-validation script path.", call. = FALSE)
}
script_path <- normalizePath(
  sub("^--file=", "", script_argument), mustWork = TRUE
)
repository_root <- normalizePath(
  file.path(dirname(script_path), ".."), mustWork = TRUE
)

expected_files <- c(
  ".editorconfig", ".github/workflows/package-foundation.yml", ".gitignore",
  "AGENTS.md", "CONTRIBUTING.md", "LICENSE", "NOTICE", "README.md",
  "RRP.yml", "SECURITY.md", "SUPPORT.md",
  "docs/implementation-guidance.md", "docs/platform-architecture.md",
  "docs/platform-implementation-plan.md",
  "docs/platform-implementation-record.md", "docs/platform-true-north.md",
  "packages/rrpplatform/DESCRIPTION", "packages/rrpplatform/NAMESPACE",
  "packages/rrpplatform/R/canonical-contracts.R",
  "packages/rrpplatform/R/operation-result.R",
  "packages/rrpplatform/R/project-contracts.R",
  "packages/rrpplatform/R/project-doctor.R",
  "packages/rrpplatform/R/project-initializer.R",
  "packages/rrpplatform/R/project-loader.R",
  "packages/rrpplatform/R/resource-catalog.R",
  "packages/rrpplatform/R/rrpplatform-package.R",
  "packages/rrpplatform/README.md",
  "packages/rrpplatform/man/rrp_initialize_project.Rd",
  "packages/rrpplatform/man/rrp_open_resource_catalog.Rd",
  "packages/rrpplatform/man/rrp_load_project.Rd",
  "packages/rrpplatform/man/rrp_operation_succeeded.Rd",
  "packages/rrpplatform/man/rrp_resource_path.Rd",
  "packages/rrpplatform/man/rrp_validate_project.Rd",
  "packages/rrpplatform/man/rrp_validate_software_resources.Rd",
  "packages/rrpplatform/man/rrpplatform-package.Rd",
  "packages/rrpplatform/tests/operation-results.R",
  "packages/rrpplatform/tests/canonical-contracts.R",
  "packages/rrpplatform/tests/package-foundation.R",
  "packages/rrpplatform/tests/project-contracts.R",
  "packages/rrpplatform/tests/project-doctor.R",
  "packages/rrpplatform/tests/project-initializer.R",
  "packages/rrpplatform/tests/project-loader.R",
  "packages/rrpplatform/tests/resource-access.R",
  "packages/rrpruntime/DESCRIPTION", "packages/rrpruntime/NAMESPACE",
  "packages/rrpruntime/R/rrpruntime-package.R",
  "packages/rrpruntime/README.md",
  "packages/rrpruntime/man/rrpruntime-package.Rd",
  "packages/rrpruntime/tests/package-foundation.R",
  "resources/contracts/diagnostic.dcf",
  "resources/contracts/operation-result.dcf",
  "resources/contracts/project-manifest.dcf",
  "resources/contracts/project-registration.dcf",
  "resources/contracts/canonical/canonical-bundle.dcf",
  "resources/contracts/canonical/canonical-producer.dcf",
  "resources/contracts/canonical/specification-envelope.dcf",
  "resources/contracts/canonical/domains/discharge-episode.dcf",
  "resources/contracts/canonical/domains/terminal-event.dcf",
  "resources/contracts/canonical/profiles/readmission.dcf",
  "resources/templates/project/R/register.R",
  "resources/templates/project/rrp-project.dcf",
  "resources/resource-catalog-schema.dcf", "resources/source-catalog.dcf",
  "tools/validate-packages.R", "tools/validate-repository.R"
)
expected_directories <- c(
  ".github", ".github/workflows", "docs", "packages",
  "packages/rrpplatform", "packages/rrpplatform/R",
  "packages/rrpplatform/man", "packages/rrpplatform/tests",
  "packages/rrpruntime", "packages/rrpruntime/R", "packages/rrpruntime/man",
  "packages/rrpruntime/tests", "resources", "resources/contracts",
  "resources/contracts/canonical", "resources/contracts/canonical/domains",
  "resources/contracts/canonical/profiles",
  "resources/templates", "resources/templates/project",
  "resources/templates/project/R", "tools"
)
check_ids <- c(
  "foundational_files", "local_documentation_links",
  "metadata_parseability", "development_identity",
  "legal_and_public_metadata", "hosted_workflow_policy",
  "path_and_text_hygiene",
  "generated_and_confidential_exclusions"
)
issues <- setNames(rep(list(character()), length(check_ids)), check_ids)

add_issue <- function(check_id, message) {
  issues[[check_id]] <<- c(issues[[check_id]], message)
}

read_text <- function(path) {
  readLines(path, warn = FALSE, encoding = "UTF-8")
}

# Recursive traversal is explicit so linked directories are reported without
# being followed outside the repository.
repository_entries <- function(root) {
  records <- list()
  visit <- function(directory, relative_directory = "") {
    for (entry in list.files(
      directory, all.files = TRUE, full.names = TRUE, no.. = TRUE
    )) {
      relative_path <- file.path(relative_directory, basename(entry))
      relative_path <- sub("^[.]?/", "", relative_path)
      relative_path <- gsub("\\\\", "/", relative_path)
      if (identical(relative_path, ".git")) next

      target <- Sys.readlink(entry)
      is_link <- !is.na(target) && nzchar(target)
      is_directory <- dir.exists(entry)
      records[[length(records) + 1L]] <<- data.frame(
        path = relative_path,
        absolute_path = entry,
        is_directory = is_directory,
        is_link = is_link,
        stringsAsFactors = FALSE
      )
      if (is_directory && !is_link) visit(entry, relative_path)
    }
  }
  visit(root)
  do.call(rbind, records)
}

entries <- repository_entries(repository_root)
source_entries <- entries[basename(entries$path) != ".DS_Store", , drop = FALSE]
actual_files <- source_entries$path[!source_entries$is_directory]
actual_directories <- source_entries$path[source_entries$is_directory]

for (path in setdiff(expected_files, actual_files)) {
  add_issue("foundational_files", paste0("missing foundational file: ", path))
}
for (path in setdiff(actual_files, expected_files)) {
  add_issue("foundational_files", paste0("unowned repository file: ", path))
}
for (path in setdiff(actual_directories, expected_directories)) {
  add_issue(
    "foundational_files",
    paste0("unowned or speculative repository directory: ", path)
  )
}

markdown_anchor <- function(heading) {
  anchor <- tolower(trimws(heading))
  anchor <- sub("[[:space:]]+#+[[:space:]]*$", "", anchor, perl = TRUE)
  anchor <- gsub("<[^>]+>", "", anchor, perl = TRUE)
  anchor <- gsub("[^[:alnum:] _-]", "", anchor, perl = TRUE)
  gsub("[[:space:]]+", "-", anchor, perl = TRUE)
}

document_anchors <- function(path) {
  headings <- grep(
    "^#{1,6}[[:space:]]+", read_text(path), value = TRUE
  )
  headings <- sub("^#{1,6}[[:space:]]+", "", headings)
  vapply(headings, markdown_anchor, character(1))
}

markdown_files <- expected_files[
  grepl("[.]md$", expected_files) &
    file.exists(file.path(repository_root, expected_files))
]
for (markdown_file in markdown_files) {
  lines <- read_text(file.path(repository_root, markdown_file))
  for (line_number in seq_along(lines)) {
    matches <- gregexpr(
      "\\[[^][]+\\]\\([^)]+\\)", lines[[line_number]], perl = TRUE
    )
    links <- regmatches(lines[[line_number]], matches)[[1L]]
    if (identical(links, character())) next

    for (link in links) {
      destination <- sub("^[^(]+\\(([^)]+)\\)$", "\\1", link, perl = TRUE)
      destination <- sub("[[:space:]]+['\"].*$", "", destination)
      destination <- sub("^<|>$", "", destination)
      if (
        !nzchar(destination) ||
          grepl("^[A-Za-z][A-Za-z0-9+.-]*:", destination)
      ) next

      parts <- strsplit(destination, "#", fixed = TRUE)[[1L]]
      linked_path <- utils::URLdecode(parts[[1L]])
      fragment <- if (length(parts) > 1L) parts[[2L]] else ""
      target <- if (nzchar(linked_path)) {
        file.path(dirname(file.path(repository_root, markdown_file)), linked_path)
      } else {
        file.path(repository_root, markdown_file)
      }
      normalized_target <- normalizePath(target, mustWork = FALSE)
      root_prefix <- paste0(repository_root, .Platform$file.sep)

      if (
        !identical(normalized_target, repository_root) &&
          !startsWith(normalized_target, root_prefix)
      ) {
        add_issue(
          "local_documentation_links",
          sprintf("%s:%d link leaves the repository: %s", markdown_file, line_number, destination)
        )
      } else if (!file.exists(target) && !dir.exists(target)) {
        add_issue(
          "local_documentation_links",
          sprintf("%s:%d link target does not exist: %s", markdown_file, line_number, destination)
        )
      } else if (
        nzchar(fragment) && grepl("[.]md$", target, ignore.case = TRUE) &&
          !utils::URLdecode(fragment) %in% document_anchors(target)
      ) {
        add_issue(
          "local_documentation_links",
          sprintf("%s:%d heading anchor does not exist: %s", markdown_file, line_number, destination)
        )
      }
    }
  }
}

metadata <- character()
metadata_path <- file.path(repository_root, "RRP.yml")
if (file.exists(metadata_path)) {
  metadata_lines <- trimws(read_text(metadata_path))
  metadata_lines <- metadata_lines[
    nzchar(metadata_lines) & !startsWith(metadata_lines, "#")
  ]
  metadata_pattern <- "^([a-z][a-z0-9_]*):[[:space:]]+([^#[:space:]][^#]*)$"
  valid_lines <- grepl(metadata_pattern, metadata_lines, perl = TRUE)
  invalid_lines <- metadata_lines[!valid_lines]
  if (length(invalid_lines) > 0L) {
    for (line in head(invalid_lines, 3L)) {
      add_issue(
        "metadata_parseability", paste0("unparseable metadata line: ", line)
      )
    }
    if (length(invalid_lines) > 3L) {
      add_issue(
        "metadata_parseability",
        sprintf("and %d additional unparseable metadata lines", length(invalid_lines) - 3L)
      )
    }
  }
  parsed_lines <- metadata_lines[valid_lines]
  keys <- sub(metadata_pattern, "\\1", parsed_lines, perl = TRUE)
  metadata <- trimws(sub(metadata_pattern, "\\2", parsed_lines, perl = TRUE))
  names(metadata) <- keys
  if (anyDuplicated(keys)) {
    add_issue("metadata_parseability", "metadata keys must be unique")
  }
}

metadata_keys <- c("product_id", "development_version", "release_status")
for (key in setdiff(metadata_keys, names(metadata))) {
  add_issue("metadata_parseability", paste0("missing metadata key: ", key))
}

for (relative_path in c(
  "resources/contracts/diagnostic.dcf",
  "resources/contracts/operation-result.dcf",
  "resources/contracts/project-manifest.dcf",
  "resources/contracts/project-registration.dcf",
  "resources/contracts/canonical/canonical-bundle.dcf",
  "resources/contracts/canonical/canonical-producer.dcf",
  "resources/contracts/canonical/specification-envelope.dcf",
  "resources/contracts/canonical/domains/discharge-episode.dcf",
  "resources/contracts/canonical/domains/terminal-event.dcf",
  "resources/contracts/canonical/profiles/readmission.dcf",
  "resources/templates/project/rrp-project.dcf",
  "resources/resource-catalog-schema.dcf", "resources/source-catalog.dcf"
)) {
  path <- file.path(repository_root, relative_path)
  if (!file.exists(path)) next
  parsed <- tryCatch(
    read.dcf(path, all = TRUE),
    error = function(condition) {
      add_issue(
        "metadata_parseability",
        paste0(relative_path, " is not valid DCF: ", conditionMessage(condition))
      )
      NULL
    }
  )
  if (!is.null(parsed) && nrow(parsed) < 1L) {
    add_issue(
      "metadata_parseability",
      paste0(relative_path, " must contain at least one DCF record")
    )
  }
}
for (key in setdiff(names(metadata), metadata_keys)) {
  add_issue("metadata_parseability", paste0("unexpected metadata key: ", key))
}

expected_identity <- c(
  product_id = "readmission-risk-pool-platform",
  development_version = "1.0.0-dev",
  release_status = "not_released"
)
for (key in names(expected_identity)) {
  if (
    !key %in% names(metadata) ||
      !identical(unname(metadata[[key]]), expected_identity[[key]])
  ) {
    add_issue(
      "development_identity",
      sprintf("RRP.yml must set %s to %s", key, expected_identity[[key]])
    )
  }
}

identity_documents <- c(
  "README.md", "docs/platform-architecture.md",
  "docs/platform-implementation-plan.md",
  "docs/platform-implementation-record.md"
)
for (document in identity_documents) {
  path <- file.path(repository_root, document)
  if (file.exists(path) && !any(grepl("1.0.0-dev", read_text(path), fixed = TRUE))) {
    add_issue(
      "development_identity",
      paste0(document, " does not identify the development version")
    )
  }
}

required_release_text <- c(
  "README.md" = "Nothing here is a released 1.0.0",
  "SECURITY.md" = "currently unreleased",
  "SUPPORT.md" = "no executable or installable product"
)
for (document in names(required_release_text)) {
  path <- file.path(repository_root, document)
  if (
    file.exists(path) &&
      !grepl(
        required_release_text[[document]],
        paste(read_text(path), collapse = "\n"),
        fixed = TRUE
      )
  ) {
    add_issue(
      "development_identity",
      paste0(document, " is missing its current unreleased boundary")
    )
  }
}

release_claim <- paste0(
  "(?i)(^|[^a-z])(RRP[[:space:]]+)?1[.]0[.]0[[:space:]]+",
  "(is|has[[:space:]]+been)[[:space:]]+(now[[:space:]]+)?released"
)
for (path in actual_files) {
  lines <- read_text(file.path(repository_root, path))
  for (line_number in grep(release_claim, lines, perl = TRUE)) {
    add_issue(
      "development_identity",
      sprintf("unsupported 1.0.0 release claim: %s:%d", path, line_number)
    )
  }
}

public_requirements <- list(
  "LICENSE" = c(
    "Apache License", "Version 2.0, January 2004",
    "http://www.apache.org/licenses/", "END OF TERMS AND CONDITIONS"
  ),
  "NOTICE" = c(
    "Readmission Risk Pool Platform",
    "Copyright 2026 CentralStatz Statistical & Data Sciences LLC"
  ),
  "README.md" = c("Apache License 2.0", "SECURITY.md", "SUPPORT.md"),
  "CONTRIBUTING.md" = c(
    "Developer Certificate of Origin 1.1", "SECURITY.md",
    "Rscript --vanilla tools/validate-repository.R",
    "Rscript --vanilla tools/validate-packages.R"
  ),
  "SECURITY.md" = c("GitHub private vulnerability", "no security response SLA"),
  "SUPPORT.md" = c("best effort", "There is no support or response-time SLA"),
  ".editorconfig" = c(
    "root = true", "charset = utf-8", "end_of_line = lf",
    "insert_final_newline = true", "trim_trailing_whitespace = true"
  )
)
for (relative_path in names(public_requirements)) {
  path <- file.path(repository_root, relative_path)
  if (!file.exists(path)) next
  content <- paste(read_text(path), collapse = "\n")
  for (snippet in public_requirements[[relative_path]]) {
    if (!grepl(snippet, content, fixed = TRUE)) {
      add_issue(
        "legal_and_public_metadata",
        paste0(relative_path, " is missing required text: ", snippet)
      )
    }
  }
}
ignore_path <- file.path(repository_root, ".gitignore")
if (file.exists(ignore_path) && !identical(read_text(ignore_path), ".DS_Store")) {
  add_issue(
    "legal_and_public_metadata",
    ".gitignore must contain only the currently justified .DS_Store rule"
  )
}

workflow_path <- file.path(
  repository_root, ".github", "workflows", "package-foundation.yml"
)
expected_workflow <- c(
  "name: package-foundation",
  "",
  "\"on\":",
  "  push:",
  "  pull_request:",
  "",
  "permissions:",
  "  contents: read",
  "",
  "jobs:",
  "  validate:",
  "    runs-on: ubuntu-latest",
  "    steps:",
  "      - name: Check out repository",
  paste0(
    "        uses: actions/checkout@",
    "3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1"
  ),
  "        with:",
  "          persist-credentials: false",
  "      - name: Set up R 4.4",
  paste0(
    "        uses: r-lib/actions/setup-r@",
    "d3c5be51b12e724e68f33216ca3c148b66d5f0b6 # v2.12.1"
  ),
  "        with:",
  "          r-version: '4.4'",
  "      - name: Validate repository foundation",
  "        run: Rscript --vanilla tools/validate-repository.R",
  "      - name: Validate package foundation",
  "        run: Rscript --vanilla tools/validate-packages.R"
)
if (file.exists(workflow_path)) {
  workflow <- read_text(workflow_path)
  if (!identical(workflow, expected_workflow)) {
    add_issue(
      "hosted_workflow_policy",
      paste0(
        "package-foundation workflow must retain the accepted push/pull-",
        "request, read-only, pinned-action, Ubuntu/R 4.4, two-command shape"
      )
    )
  }
}

for (path in source_entries$path[source_entries$is_link]) {
  add_issue("path_and_text_hygiene", paste0("symbolic links are not allowed: ", path))
}
unsafe_paths <- source_entries$path[
  startsWith(source_entries$path, "/") |
    grepl("(^|/)[.]{1,2}(/|$)", source_entries$path) |
    grepl("[[:cntrl:]\\\\]", source_entries$path)
]
for (path in unsafe_paths) {
  add_issue("path_and_text_hygiene", paste0("unsafe repository path: ", path))
}
portable_paths <- tolower(source_entries$path)
for (path in unique(portable_paths[duplicated(portable_paths)])) {
  add_issue("path_and_text_hygiene", paste0("case-insensitive path collision: ", path))
}

text_entries <- source_entries[
  !source_entries$is_directory & !source_entries$is_link, , drop = FALSE
]
for (index in seq_len(nrow(text_entries))) {
  path <- text_entries$absolute_path[[index]]
  relative_path <- text_entries$path[[index]]
  bytes <- readBin(path, what = "raw", n = file.info(path)$size)
  if (length(bytes) > 0L && !identical(tail(bytes, 1L), charToRaw("\n"))) {
    add_issue(
      "path_and_text_hygiene",
      paste0("text file lacks a final newline: ", relative_path)
    )
  }
  if (any(bytes == as.raw(13L))) {
    add_issue(
      "path_and_text_hygiene",
      paste0("text file contains CR line endings: ", relative_path)
    )
  }
  for (line_number in which(grepl("[[:blank:]]+$", read_text(path)))) {
    add_issue(
      "path_and_text_hygiene",
      sprintf("trailing whitespace: %s:%d", relative_path, line_number)
    )
  }
}

lower_paths <- tolower(source_entries$path)
generated_paths <- source_entries$path[
  grepl("(^|/)(build|dist|tmp|[.]tmp|cache|[.]cache|coverage)(/|$)", lower_paths) |
    grepl("[.](rdata|rhistory|rds|duckdb|sqlite|wal)$", lower_paths)
]
sensitive_paths <- source_entries$path[
  grepl("(^|/)[.]env([.]|$)", lower_paths) |
    grepl("(^|/)[.]renviron$", lower_paths) |
    grepl("(^|/)(credentials?|secrets?)([._-]|/|$)", lower_paths) |
    grepl("[.](pem|p12|pfx|key)$", lower_paths)
]
for (path in generated_paths) {
  add_issue(
    "generated_and_confidential_exclusions",
    paste0("obvious generated content is present: ", path)
  )
}
for (path in sensitive_paths) {
  add_issue(
    "generated_and_confidential_exclusions",
    paste0("sensitive-looking file is present: ", path)
  )
}

secret_patterns <- c(
  private_key = paste("BEGIN", ".*PRIVATE KEY"),
  aws_access_key = paste0("AK", "IA[0-9A-Z]{16}"),
  github_token = paste0("gh", "[pousr]_[A-Za-z0-9]{20,}")
)
for (index in seq_len(nrow(text_entries))) {
  lines <- read_text(text_entries$absolute_path[[index]])
  for (pattern_name in names(secret_patterns)) {
    for (line_number in grep(secret_patterns[[pattern_name]], lines, perl = TRUE)) {
      add_issue(
        "generated_and_confidential_exclusions",
        sprintf(
          "possible %s content: %s:%d",
          pattern_name, text_entries$path[[index]], line_number
        )
      )
    }
  }
}

cat("RRP repository foundation validation\n")
cat("====================================\n")
for (check_id in check_ids) {
  check_issues <- issues[[check_id]]
  status <- if (length(check_issues) == 0L) "PASS" else "FAIL"
  cat(sprintf("%-4s %s\n", status, check_id))
  if (length(check_issues) > 0L) {
    cat(paste0("     - ", check_issues, "\n"), sep = "")
  }
}

issue_count <- sum(lengths(issues))
passed <- issue_count == 0L
cat(sprintf(
  "\nResult: %s (%d checks, %d issues)\n",
  if (passed) "PASS" else "FAIL", length(check_ids), issue_count
))
cat(
  "Scope: repository structure and static policy only; package lifecycle ",
  "evidence is separate, and human review remains required for confidential ",
  "or patient-level content.\n",
  sep = ""
)
if (!passed) quit(save = "no", status = 1L, runLast = FALSE)
