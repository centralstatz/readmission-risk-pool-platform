#!/usr/bin/env Rscript

# Distribution-local base-R bootstrap. All installation semantics live in the
# shared engine used by this entry and by `rrp software install`.

script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_argument) != 1L) stop("Cannot determine installer path.", call. = FALSE)
script_path <- normalizePath(sub("^--file=", "", script_argument), mustWork = TRUE)
distribution_root <- dirname(script_path)
source(file.path(distribution_root, "verify-distribution.R"), local = TRUE)
source(file.path(distribution_root, "install-engine.R"), local = TRUE)

rrp_install_bootstrap_arguments <- function(arguments) {
  values <- list(repository = NULL, installation_root = NULL)
  index <- 1L
  while (index <= length(arguments)) {
    argument <- arguments[[index]]
    name <- switch(argument,
      "--repository" = "repository",
      "--installation-root" = "installation_root",
      NULL
    )
    if (is.null(name) || index == length(arguments) ||
        startsWith(arguments[[index + 1L]], "--") || !is.null(values[[name]])) {
      stop(
        "Usage: Rscript --vanilla install.R --repository HTTPS_URL [--installation-root ABSOLUTE_PATH]",
        call. = FALSE
      )
    }
    values[[name]] <- arguments[[index + 1L]]
    index <- index + 2L
  }
  if (is.null(values$repository)) stop(
    "Usage: Rscript --vanilla install.R --repository HTTPS_URL [--installation-root ABSOLUTE_PATH]",
    call. = FALSE
  )
  values
}

rrp_install_bootstrap <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  values <- rrp_install_bootstrap_arguments(arguments)
  host_r <- normalizePath(file.path(R.home("bin"), "R"), winslash = "/", mustWork = TRUE)
  step <- 0L
  result <- rrp_install_distribution(
    distribution_root = distribution_root,
    repository = values$repository,
    host_r_executable = host_r,
    installation_root = values$installation_root,
    progress = function(message) {
      step <<- step + 1L
      cat(sprintf("[%d] %s\n", step, message))
    }
  )
  cat(sprintf(
    "PASS installation %s\nLocation: %s\nReused: %s\n",
    result$installation_id, result$installation_root,
    if (result$reused) "yes" else "no"
  ))
  invisible(result)
}

if (sys.nframe() == 0L) {
  status <- tryCatch({ rrp_install_bootstrap(); 0L }, error = function(condition) {
    cat("FAIL installation\n", conditionMessage(condition), "\n", file = stderr())
    1L
  })
  quit(save = "no", status = status, runLast = FALSE)
}
