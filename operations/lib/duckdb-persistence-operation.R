# Repository composition for the concrete DuckDB adapter. Generic runtime and
# language-neutral contracts never source or name this implementation.

rrp_load_duckdb_persistence_adapter <- function(repository_root) {
  directory <- file.path(
    repository_root, "implementations", "persistence", "duckdb", "R"
  )
  for (file in c("foundation.R", "schema.R", "adapter.R", "session.R")) {
    sys.source(file.path(directory, file), envir = parent.frame())
  }
  invisible(TRUE)
}

rrp_read_duckdb_configuration <- function(repository_root) {
  path <- file.path(
    repository_root, "implementations", "persistence", "duckdb", "config",
    "reference.yml"
  )
  parsed <- rrp_parse_yaml_specification(path)
  if (!is.null(parsed$error)) stop(
    "Could not read DuckDB persistence configuration: ", parsed$error,
    call. = FALSE
  )
  parsed$document
}
