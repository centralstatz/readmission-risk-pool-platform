rrp_state_abort <- function(code, message) {
  if (!is.character(code) || length(code) != 1L || is.na(code) ||
      !grepl("^[a-z][a-z0-9_]*$", code) ||
      !is.character(message) || length(message) != 1L || is.na(message) ||
      !nzchar(message) || nchar(message, type = "bytes") > 160L ||
      grepl("[\r\n]", message)) {
    stop("Invalid internal project-state error definition.", call. = FALSE)
  }
  stop(structure(
    list(message = message, call = NULL, code = code),
    class = c("rrp_state_error", "error", "condition")
  ))
}

rrp_state_path_exists <- function(path) {
  target <- Sys.readlink(path)
  file.exists(path) || dir.exists(path) || (!is.na(target) && nzchar(target))
}

rrp_state_timestamp_number <- function(value) {
  if (!is.character(value) || length(value) != 1L || is.na(value) ||
      !grepl(
        "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
        value
      )) return(NA_real_)
  parsed <- as.POSIXct(value, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  if (is.na(parsed) || !identical(
    format(parsed, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), value
  )) NA_real_ else as.numeric(parsed)
}

rrp_state_identity_sequence <- local({
  sequence <- 0L
  function() {
    sequence <<- if (sequence == .Machine$integer.max) 1L else sequence + 1L
    sequence
  }
})

rrp_state_new_identity <- function() {
  now <- as.numeric(Sys.time())
  seconds <- floor(now)
  microseconds <- floor((now - seconds) * 1000000)
  values <- c(
    seconds %% .Machine$integer.max,
    microseconds,
    Sys.getpid() %% .Machine$integer.max,
    rrp_state_identity_sequence()
  )
  paste0("rrp.state.", paste(sprintf("%08x", as.integer(values)), collapse = ""))
}

rrp_state_metadata_fields <- function(contract) {
  strsplit(contract[["Fields"]], ",", fixed = TRUE)[[1L]]
}

rrp_state_new_metadata <- function(context, contracts) {
  state_contract <- contracts$state
  adapter_contract <- contracts$adapter
  values <- c(
    "Record-Type" = state_contract[["Metadata-Record-Type"]],
    "State-Contract-ID" = state_contract[["Contract-ID"]],
    "State-Contract-Version" = state_contract[["Contract-Version"]],
    "Format-Version" = state_contract[["Format-Version"]],
    "Product-ID" = state_contract[["Product-ID"]],
    "Development-Version" = state_contract[["Development-Version"]],
    "State-ID" = rrp_state_new_identity(),
    "Initializing-Package-ID" = state_contract[["Initializing-Package-ID"]],
    "Initializing-Package-Version" = as.character(
      utils::packageVersion("rrpplatform")
    ),
    "Project-ID" = context$manifest[["Project-ID"]],
    "Initializing-Project-Version" = context$manifest[["Project-Version"]],
    "Supported-RRP-API-Version" = state_contract[["Supported-RRP-API-Version"]],
    "Project-API-ID" = state_contract[["Project-API-ID"]],
    "Project-API-Version" = state_contract[["Project-API-Version"]],
    "Target-ID" = state_contract[["Target-ID"]],
    "Target-Version" = state_contract[["Target-Version"]],
    "History-Scope-Contract-ID" = state_contract[["History-Scope-Contract-ID"]],
    "History-Scope-Contract-Version" = state_contract[["History-Scope-Contract-Version"]],
    "History-Disposition-Contract-ID" = state_contract[["History-Disposition-Contract-ID"]],
    "History-Disposition-Contract-Version" = state_contract[["History-Disposition-Contract-Version"]],
    "History-Action-Contract-ID" = state_contract[["History-Action-Contract-ID"]],
    "History-Action-Contract-Version" = state_contract[["History-Action-Contract-Version"]],
    "History-Port-Contract-ID" = state_contract[["History-Port-Contract-ID"]],
    "History-Port-Contract-Version" = state_contract[["History-Port-Contract-Version"]],
    "Logical-History-Format-Version" = state_contract[["Logical-History-Format-Version"]],
    "Adapter-ID" = adapter_contract[["Adapter-ID"]],
    "Adapter-Version" = adapter_contract[["Adapter-Version"]],
    "Physical-Schema-Version" = adapter_contract[["Physical-Schema-Version"]],
    "Payload-Encoding-Version" = adapter_contract[["Payload-Encoding-Version"]],
    "Created-At" = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    "Inventory" = state_contract[["Inventory"]]
  )
  stopifnot(identical(names(values), rrp_state_metadata_fields(state_contract)))
  values
}

rrp_state_read_metadata <- function(path) {
  lines <- tryCatch(
    readLines(path, warn = FALSE, encoding = "UTF-8"),
    error = function(condition) rrp_state_abort(
      "state_malformed", "Project state metadata is malformed."
    )
  )
  valid <- length(lines) > 0L && !anyNA(lines) && all(nzchar(lines)) &&
    !any(grepl("^[[:space:]]", lines)) &&
    all(grepl(
      "^[A-Za-z][A-Za-z0-9-]*:[[:space:]]+[^[:space:]].*$", lines
    ))
  if (!valid) rrp_state_abort(
    "state_malformed", "Project state metadata is malformed."
  )
  fields <- sub(":.*$", "", lines)
  if (anyDuplicated(fields)) rrp_state_abort(
    "state_malformed", "Project state metadata is malformed."
  )
  values <- sub("^[^:]+:[[:space:]]+", "", lines)
  names(values) <- fields
  values
}

rrp_state_validate_metadata <- function(metadata, context, contracts) {
  state <- contracts$state
  adapter <- contracts$adapter
  fields <- rrp_state_metadata_fields(state)
  fixed <- c(
    "Record-Type" = state[["Metadata-Record-Type"]],
    "State-Contract-ID" = state[["Contract-ID"]],
    "State-Contract-Version" = state[["Contract-Version"]],
    "Format-Version" = state[["Format-Version"]],
    "Product-ID" = state[["Product-ID"]],
    "Development-Version" = state[["Development-Version"]],
    "Initializing-Package-ID" = state[["Initializing-Package-ID"]],
    "Supported-RRP-API-Version" = state[["Supported-RRP-API-Version"]],
    "Project-API-ID" = state[["Project-API-ID"]],
    "Project-API-Version" = state[["Project-API-Version"]],
    "Target-ID" = state[["Target-ID"]],
    "Target-Version" = state[["Target-Version"]],
    "History-Scope-Contract-ID" = state[["History-Scope-Contract-ID"]],
    "History-Scope-Contract-Version" = state[["History-Scope-Contract-Version"]],
    "History-Disposition-Contract-ID" = state[["History-Disposition-Contract-ID"]],
    "History-Disposition-Contract-Version" = state[["History-Disposition-Contract-Version"]],
    "History-Action-Contract-ID" = state[["History-Action-Contract-ID"]],
    "History-Action-Contract-Version" = state[["History-Action-Contract-Version"]],
    "History-Port-Contract-ID" = state[["History-Port-Contract-ID"]],
    "History-Port-Contract-Version" = state[["History-Port-Contract-Version"]],
    "Logical-History-Format-Version" = state[["Logical-History-Format-Version"]],
    "Adapter-ID" = adapter[["Adapter-ID"]],
    "Adapter-Version" = adapter[["Adapter-Version"]],
    "Physical-Schema-Version" = adapter[["Physical-Schema-Version"]],
    "Payload-Encoding-Version" = adapter[["Payload-Encoding-Version"]],
    "Inventory" = state[["Inventory"]]
  )
  valid <- is.character(metadata) && identical(names(metadata), fields) &&
    all(vapply(names(fixed), function(field) {
      identical(metadata[[field]], fixed[[field]])
    }, logical(1L))) &&
    grepl(state[["State-ID-Pattern"]], metadata[["State-ID"]]) &&
    identical(metadata[["Project-ID"]], context$manifest[["Project-ID"]]) &&
    identical(metadata[["Project-API-Version"]],
      context$manifest[["Supported-RRP-API-Version"]]) &&
    grepl(state[["Initializing-Package-Version-Pattern"]],
      metadata[["Initializing-Package-Version"]]) &&
    grepl(state[["Initializing-Project-Version-Pattern"]],
      metadata[["Initializing-Project-Version"]]) &&
    !is.na(rrp_state_timestamp_number(metadata[["Created-At"]]))
  if (!valid) rrp_state_abort(
    "state_incompatible", "Project state is incompatible with this project."
  )
  metadata
}

rrp_state_inventory <- function(root, contract) {
  root_link <- Sys.readlink(root)
  if (!dir.exists(root) || (!is.na(root_link) && nzchar(root_link))) {
    rrp_state_abort("state_invalid", "Project state inventory is invalid.")
  }
  files <- sort(list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = FALSE, include.dirs = FALSE
  ), method = "radix")
  directories <- list.dirs(root, recursive = TRUE, full.names = FALSE)
  directories <- directories[nzchar(directories)]
  expected <- sort(strsplit(contract[["Inventory"]], ",", fixed = TRUE)[[1L]],
    method = "radix")
  if (!identical(files, expected) || length(directories)) {
    rrp_state_abort("state_invalid", "Project state inventory is invalid.")
  }
  for (relative in expected) {
    path <- file.path(root, relative)
    link <- Sys.readlink(path)
    info <- file.info(path, extra_cols = FALSE)
    if ((!is.na(link) && nzchar(link)) || nrow(info) != 1L ||
        is.na(info$isdir[[1L]]) || isTRUE(info$isdir[[1L]])) {
      rrp_state_abort("state_invalid", "Project state inventory is invalid.")
    }
  }
  invisible(expected)
}

rrp_state_inspect_root <- function(root, context, contracts) {
  rrp_state_inventory(root, contracts$state)
  metadata <- rrp_state_read_metadata(file.path(root, "state.dcf"))
  metadata <- rrp_state_validate_metadata(metadata, context, contracts)
  rrp_duckdb_validate_file(file.path(root, "history.duckdb"), metadata, contracts)
  metadata
}

rrp_state_value <- function(metadata, status, created = NULL) {
  value <- list(
    state_status = status,
    state_id = if (is.null(metadata)) NULL else unname(metadata[["State-ID"]]),
    project_id = if (is.null(metadata)) NULL else unname(metadata[["Project-ID"]]),
    state_contract_id = if (is.null(metadata)) NULL else
      unname(metadata[["State-Contract-ID"]]),
    state_contract_version = if (is.null(metadata)) NULL else
      unname(metadata[["State-Contract-Version"]]),
    adapter_id = if (is.null(metadata)) NULL else unname(metadata[["Adapter-ID"]]),
    adapter_version = if (is.null(metadata)) NULL else
      unname(metadata[["Adapter-Version"]]),
    physical_schema_version = if (is.null(metadata)) NULL else
      unname(metadata[["Physical-Schema-Version"]]),
    payload_encoding_version = if (is.null(metadata)) NULL else
      unname(metadata[["Payload-Encoding-Version"]]),
    created_at = if (is.null(metadata)) NULL else unname(metadata[["Created-At"]])
  )
  if (!is.null(created)) value$created <- created
  value
}

rrp_state_operation_failure <- function(condition, operation_id, message) {
  rrp_new_operation_result(
    operation_id = operation_id,
    status = "failure",
    value = NULL,
    diagnostics = list(rrp_new_diagnostic(
      code = condition$code, severity = "error", message = message
    ))
  )
}

rrp_state_inspect <- function(software_catalog, project_root) {
  context <- rrp_load_project(software_catalog, project_root)
  contracts <- rrp_state_contracts(software_catalog)
  if (!rrp_state_path_exists(context$state_path)) {
    return(rrp_new_operation_result(
      operation_id = "rrp.inspect-project-state",
      status = "success",
      value = rrp_state_value(NULL, "not_initialized"),
      diagnostics = list(rrp_new_diagnostic(
        code = "project_state_not_initialized", severity = "warning",
        message = "Project state has not been initialized."
      ))
    ))
  }
  metadata <- rrp_state_inspect_root(context$state_path, context, contracts)
  rrp_new_operation_result(
    operation_id = "rrp.inspect-project-state",
    status = "success",
    value = rrp_state_value(metadata, "compatible"),
    diagnostics = list()
  )
}

rrp_state_staging_directory <- function(context) {
  for (attempt in seq_len(16L)) {
    path <- tempfile(".rrp-state-staging-", tmpdir = context$project_root)
    if (rrp_state_path_exists(path)) next
    if (dir.create(path, showWarnings = FALSE) && dir.exists(path) &&
        !nzchar(Sys.readlink(path))) return(path)
  }
  rrp_state_abort("state_staging_failed", "Project state staging failed.")
}

rrp_state_create_parent <- function(context) {
  parent <- dirname(context$state_path)
  if (identical(parent, context$project_root)) return(character())
  relative <- substring(parent, nchar(context$project_root) + 2L)
  segments <- strsplit(relative, "/", fixed = TRUE)[[1L]]
  current <- context$project_root
  created <- character()
  for (segment in segments) {
    entries <- list.files(current, all.files = TRUE, no.. = TRUE)
    folded <- entries[tolower(entries) == tolower(segment)]
    if (length(folded) > 1L ||
        (length(folded) == 1L && !identical(folded[[1L]], segment))) {
      rrp_state_abort("state_parent_invalid", "Project state parent is invalid.")
    }
    current <- file.path(current, segment)
    if (rrp_state_path_exists(current)) {
      if (!dir.exists(current) || nzchar(Sys.readlink(current))) {
        rrp_state_abort("state_parent_invalid", "Project state parent is invalid.")
      }
    } else {
      if (!dir.create(current, showWarnings = FALSE)) {
        rrp_state_abort("state_parent_invalid", "Project state parent is invalid.")
      }
      created <- c(created, current)
    }
  }
  created
}

rrp_state_initialize <- function(
  software_catalog, project_root, failure_stage = NULL
) {
  allowed_failures <- c(
    "after_metadata", "after_database", "before_promotion", "after_promotion"
  )
  if (!is.null(failure_stage) && !failure_stage %in% allowed_failures) {
    stop("Invalid internal state-initialization interruption stage.", call. = FALSE)
  }
  inject <- function(stage) {
    if (!is.null(failure_stage) && identical(failure_stage, stage)) {
      rrp_state_abort(
        "injected_interruption", "Injected project state interruption."
      )
    }
  }
  context <- rrp_load_project(software_catalog, project_root)
  contracts <- rrp_state_contracts(software_catalog)
  if (rrp_state_path_exists(context$state_path)) {
    metadata <- rrp_state_inspect_root(context$state_path, context, contracts)
    return(rrp_new_operation_result(
      operation_id = "rrp.initialize-project-state", status = "success",
      value = rrp_state_value(metadata, "compatible", created = FALSE),
      diagnostics = list()
    ))
  }

  staging <- rrp_state_staging_directory(context)
  staging_owned <- TRUE
  final_owned <- FALSE
  created_parents <- character()
  completed <- FALSE
  on.exit({
    if (!completed && final_owned && rrp_state_path_exists(context$state_path)) {
      unlink(context$state_path, recursive = TRUE, force = TRUE)
    }
    if (staging_owned && rrp_state_path_exists(staging)) {
      unlink(staging, recursive = TRUE, force = TRUE)
    }
    if (!completed && length(created_parents)) {
      for (path in rev(created_parents)) {
        if (dir.exists(path) && !length(list.files(path, all.files = TRUE, no.. = TRUE))) {
          unlink(path, recursive = FALSE, force = TRUE)
        }
      }
    }
  }, add = TRUE)

  metadata <- rrp_state_new_metadata(context, contracts)
  tryCatch(
    writeLines(
      paste0(names(metadata), ": ", unname(metadata)),
      file.path(staging, "state.dcf"), useBytes = TRUE
    ),
    error = function(condition) rrp_state_abort(
      "state_initialization_failed", "Project state initialization failed."
    )
  )
  inject("after_metadata")
  rrp_duckdb_initialize_file(
    file.path(staging, "history.duckdb"), metadata, contracts
  )
  inject("after_database")
  rrp_state_inspect_root(staging, context, contracts)

  created_parents <- rrp_state_create_parent(context)
  inject("before_promotion")
  if (rrp_state_path_exists(context$state_path) ||
      !file.rename(staging, context$state_path)) {
    rrp_state_abort("state_promotion_failed", "Project state promotion failed.")
  }
  staging_owned <- FALSE
  final_owned <- TRUE
  inject("after_promotion")
  metadata <- rrp_state_inspect_root(context$state_path, context, contracts)
  completed <- TRUE
  rrp_new_operation_result(
    operation_id = "rrp.initialize-project-state", status = "success",
    value = rrp_state_value(metadata, "compatible", created = TRUE),
    diagnostics = list()
  )
}

#' Inspect explicit project-owned RRP state
#'
#' @param software_catalog A validated `rrp_resource_catalog`.
#' @param project_root One explicit existing independent project directory.
#' @return One validated `rrp_operation_result`.
#' @export
rrp_inspect_project_state <- function(software_catalog, project_root) {
  tryCatch(
    rrp_state_inspect(software_catalog, project_root),
    rrp_resource_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.inspect-project-state", "Project state inspection failed."
    ),
    rrp_project_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.inspect-project-state", "Project state inspection failed."
    ),
    rrp_state_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.inspect-project-state", "Project state inspection failed."
    )
  )
}

#' Initialize explicit project-owned RRP state
#'
#' @param software_catalog A validated `rrp_resource_catalog`.
#' @param project_root One explicit existing independent project directory.
#' @return One validated `rrp_operation_result`.
#' @export
rrp_initialize_project_state <- function(software_catalog, project_root) {
  tryCatch(
    rrp_state_initialize(software_catalog, project_root),
    rrp_resource_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.initialize-project-state",
      "Project state initialization failed."
    ),
    rrp_project_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.initialize-project-state",
      "Project state initialization failed."
    ),
    rrp_state_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.initialize-project-state",
      "Project state initialization failed."
    )
  )
}
