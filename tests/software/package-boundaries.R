rrp_package_dependency_values <- function(description, field) {
  if (!field %in% colnames(description)) return(character())
  values <- trimws(strsplit(description[[1L, field]], ",", fixed = TRUE)[[1L]])
  sub("[[:space:]]*[(].*$", "", values)
}

rrp_package_source_text <- function(package_root) {
  paths <- sort(list.files(
    file.path(package_root, "R"), pattern = "[.]R$", full.names = TRUE
  ), method = "radix")
  paste(unlist(lapply(paths, readLines, warn = FALSE), use.names = FALSE),
        collapse = "\n")
}

rrp_validate_package_boundaries <- function(repository_root) {
  package_root <- file.path(repository_root, "packages")
  descriptions <- sort(list.files(
    package_root, pattern = "^DESCRIPTION$", recursive = TRUE,
    full.names = TRUE
  ), method = "radix")
  expected <- sort(file.path(
    package_root, c("rrpplatform", "rrpruntime"), "DESCRIPTION"
  ), method = "radix")
  stopifnot(
    identical(descriptions, expected),
    !file.exists(file.path(repository_root, "runtime"))
  )

  runtime_root <- file.path(package_root, "rrpruntime")
  platform_root <- file.path(package_root, "rrpplatform")
  runtime <- read.dcf(file.path(runtime_root, "DESCRIPTION"))
  platform <- read.dcf(file.path(platform_root, "DESCRIPTION"))
  stopifnot(
    identical(unname(runtime[[1L, "Package"]]), "rrpruntime"),
    identical(unname(runtime[[1L, "Version"]]), "0.3.0"),
    identical(unname(platform[[1L, "Package"]]), "rrpplatform"),
    identical(unname(platform[[1L, "Version"]]), "0.1.0.9000")
  )

  runtime_dependencies <- unique(unlist(lapply(
    c("Imports", "Suggests", "LinkingTo"),
    function(field) rrp_package_dependency_values(runtime, field)
  ), use.names = FALSE))
  platform_imports <- rrp_package_dependency_values(platform, "Imports")
  stopifnot(
    length(runtime_dependencies) == 0L,
    identical(platform_imports, "rrpruntime")
  )

  runtime_namespace <- readLines(
    file.path(runtime_root, "NAMESPACE"), warn = FALSE
  )
  platform_namespace <- readLines(
    file.path(platform_root, "NAMESPACE"), warn = FALSE
  )
  runtime_namespace <- runtime_namespace[nzchar(trimws(runtime_namespace))]
  platform_namespace <- platform_namespace[nzchar(trimws(platform_namespace))]
  stopifnot(
    !any(grepl("rrpplatform", runtime_namespace, fixed = TRUE)),
    identical(platform_namespace, "importFrom(rrpruntime,runtime_conforms)")
  )

  forbidden_dependencies <- c(
    "yaml", "digest", "DBI", "duckdb", "shiny", "renv", "rsconnect"
  )
  stopifnot(length(intersect(runtime_dependencies, forbidden_dependencies)) == 0L)

  forbidden_source_patterns <- c(
    "\\.GlobalEnv", "getwd\\s*\\(", "Sys\\.getenv\\s*\\(",
    "(?:^|[^[:alnum:]_.])(?:sys\\.)?source\\s*\\(",
    "repository_root", "[.]git(?:/|\\\\|\"|')",
    "readmission-risk-pool(?:/|\\\\)"
  )
  for (root in c(runtime_root, platform_root)) {
    text <- rrp_package_source_text(root)
    matched <- forbidden_source_patterns[vapply(
      forbidden_source_patterns, grepl, logical(1L), x = text,
      perl = TRUE, ignore.case = TRUE
    )]
    if (length(matched) > 0L) stop(
      "Package code contains prohibited source-discovery coupling: ",
      paste(matched, collapse = ", "), call. = FALSE
    )
  }

  active_roots <- c("operations", "tests", "validation", "deploy")
  active_files <- unlist(lapply(active_roots, function(root) list.files(
    file.path(repository_root, root), pattern = "[.](R|yml|yaml)$",
    recursive = TRUE, full.names = TRUE
  )), use.names = FALSE)
  active_files <- setdiff(
    active_files,
    file.path(repository_root, "tests", "software", "package-boundaries.R")
  )
  active_text <- paste(unlist(lapply(
    active_files, readLines, warn = FALSE
  ), use.names = FALSE), collapse = "\n")
  stale_patterns <- c(
    "(?:^|[^[:alnum:]_])runtime/(?:DESCRIPTION|NAMESPACE|README[.]md|R/|man/|tests/)",
    "file[.]path\\(repository_root, [\"']runtime[\"']"
  )
  stale <- stale_patterns[vapply(
    stale_patterns, grepl, logical(1L), x = active_text, perl = TRUE
  )]
  if (length(stale) > 0L) stop(
    "Active code retains the former runtime package path: ",
    paste(stale, collapse = ", "), call. = FALSE
  )

  invisible(TRUE)
}
