phase0_assert_true <- function(value, message = "Expected condition to be true.") {
  if (!isTRUE(value)) stop(message, call. = FALSE)
  invisible(TRUE)
}

phase0_assert_false <- function(value, message = "Expected condition to be false.") {
  if (!identical(value, FALSE)) stop(message, call. = FALSE)
  invisible(TRUE)
}

phase0_assert_issue <- function(result, code) {
  phase0_assert_true(
    code %in% result$issues$code,
    paste0("Expected issue code `", code, "` but found: ",
      paste(result$issues$code, collapse = ", "))
  )
}

phase0_assert_error <- function(expression, pattern) {
  message <- tryCatch(
    {
      force(expression)
      NA_character_
    },
    error = function(condition) conditionMessage(condition)
  )
  phase0_assert_true(!is.na(message), "Expected expression to fail.")
  phase0_assert_true(
    grepl(pattern, message, fixed = TRUE),
    paste0("Expected error containing `", pattern, "`; got: ", message)
  )
}

phase0_copy_repository_fixture <- function(repository_root) {
  fixture_root <- tempfile("rrp-phase0-fixture-")
  dir.create(fixture_root, recursive = TRUE)

  files <- rrp_repository_files(repository_root)
  for (file in files) {
    source <- file.path(repository_root, file)
    destination <- file.path(fixture_root, file)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    copied <- file.copy(source, destination, overwrite = TRUE, copy.mode = TRUE)
    if (!copied) stop("Could not copy test fixture file: ", file, call. = FALSE)
  }
  fixture_root
}

phase0_append_lines <- function(path, lines) {
  write(lines, file = path, append = TRUE)
}
