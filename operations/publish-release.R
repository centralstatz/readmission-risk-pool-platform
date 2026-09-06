#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
for (file in c(
  "validation-result.R", "conformance-result.R", "specification-validation.R",
  "hospital-distribution-operation.R", "hospital-git-realization-operation.R",
  "release-preparation-operation.R", "github-publication-client.R",
  "release-publication-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_hospital_distribution_runtime(repository_root, .GlobalEnv)

arguments <- commandArgs(trailingOnly = TRUE)
version <- NULL
mode <- NULL
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--version")) {
    version <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (arguments[[1L]] %in% c("--preflight", "--publish", "--verify")) {
    selected <- sub("^--", "", arguments[[1L]])
    if (!is.null(mode) && !identical(mode, selected)) {
      message("Select exactly one of --preflight, --publish, or --verify.")
      quit(save = "no", status = 2L, runLast = FALSE)
    }
    mode <- selected
    arguments <- arguments[-1L]
  } else {
    message(paste(
      "Usage: Rscript operations/publish-release.R --version VERSION",
      "--preflight|--publish|--verify"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (is.null(version) || !grepl("^[0-9]+[.][0-9]+[.][0-9]+$", version) ||
    is.null(mode)) {
  message("Publication requires one semantic --version and one explicit mode.")
  quit(save = "no", status = 2L, runLast = FALSE)
}

remote_url <- tryCatch(rrp_publication_git_output(
  repository_root, c("remote", "get-url", "origin"), "Remote inspection"
), error = function(condition) condition)
if (inherits(remote_url, "condition") || length(remote_url) != 1L) {
  message("Publication failed: ", if (inherits(remote_url, "condition")) {
    conditionMessage(remote_url)
  } else "one origin URL is required")
  quit(save = "no", status = 1L, runLast = FALSE)
}
client <- tryCatch(
  rrp_github_publication_client(remote_url[[1L]]),
  error = function(condition) condition
)
if (inherits(client, "condition")) {
  message("Publication failed: ", conditionMessage(client))
  quit(save = "no", status = 1L, runLast = FALSE)
}

result <- tryCatch({
  if (identical(mode, "verify")) {
    rrp_verify_published_release(repository_root, version, client)
  } else {
    preflight <- rrp_publication_preflight(
      repository_root, version, client, run_checkpoint = TRUE
    )
    cat("Operation: platform.publish-release\n")
    cat("PUBLICATION PREFLIGHT: PASS\n")
    cat("Remote mutation: ", if (identical(mode, "publish")) {
      "AUTHORIZED"
    } else "NOT PERFORMED"
    , "\n", sep = "")
    if (identical(mode, "publish")) {
      cat("REMOTE MUTATION: AUTHORIZED\n")
      rrp_publish_release(repository_root, preflight, client)
    } else preflight
  }
}, error = function(condition) condition)
if (inherits(result, "condition")) {
  message("Publication failed: ", conditionMessage(result))
  message("No remote state is removed or rewritten. Inspect retained publication evidence before retrying.")
  quit(save = "no", status = 1L, runLast = FALSE)
}

if (identical(mode, "preflight")) {
  cat("RESULT: READY TO PUBLISH WITH EXPLICIT --publish\n")
} else if (identical(mode, "verify")) {
  cat("Operation: platform.verify-published-release\n")
  cat("RESULT: PUBLISHED RELEASES VERIFIED\n")
  cat("Platform: ", result$evidence$platform$github_release_url, "\n", sep = "")
  cat("Hospital: ", result$evidence$hospital$github_release_url, "\n", sep = "")
} else {
  cat("RESULT: BOTH v", version, " RELEASES PUBLISHED AND VERIFIED\n", sep = "")
  cat("Platform: ", result$evidence$platform$github_release_url, "\n", sep = "")
  cat("Hospital: ", result$evidence$hospital$github_release_url, "\n", sep = "")
  cat("Development transition: 0.2.0-dev changes written; commit and push after final validation.\n")
}
