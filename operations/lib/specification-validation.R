# Common YAML specification envelope and compatibility validation.

rrp_specification_format_version <- function() "1.0.0"

rrp_specification_envelope_identity <- function() {
  list(
    specification_kind = "specification_envelope",
    specification_id = "platform.specification-envelope",
    specification_version = rrp_specification_format_version()
  )
}

rrp_semver_pattern <- function() {
  paste0(
    "^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)",
    "(?:-(?:0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*)",
    "(?:\\.(?:0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*))*)?",
    "(?:\\+[0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*)?$"
  )
}

rrp_identifier_pattern <- function() {
  "^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$"
}

rrp_is_scalar_character <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
}

rrp_is_semver <- function(value) {
  rrp_is_scalar_character(value) && grepl(rrp_semver_pattern(), value, perl = TRUE)
}

rrp_semver_components <- function(value) {
  if (!rrp_is_semver(value)) return(NULL)
  core <- sub("[-+].*$", "", value)
  # Compare numeric identifiers as strings so arbitrarily large valid SemVer
  # components do not overflow R's integer range.
  parts <- strsplit(core, ".", fixed = TRUE)[[1L]]
  names(parts) <- c("major", "minor", "patch")
  parts
}

rrp_specification_required_fields <- function() {
  c(
    "specification_kind",
    "specification_id",
    "specification_version",
    "specification_format_version",
    "identity_scope",
    "title",
    "status"
  )
}

rrp_specification_identity_scopes <- function() {
  c("platform", "reference", "implementation")
}

rrp_specification_statuses <- function() {
  c("experimental", "active", "deprecated", "retired")
}

rrp_validate_specification_envelope <- function(document, location = NA_character_) {
  target <- rrp_specification_envelope_identity()
  issues <- list()

  if (!is.list(document) || is.null(names(document))) {
    issues[[1L]] <- rrp_conformance_issue(
      "envelope.mapping", "error", "specification_not_mapping",
      "Specification document must be a named YAML mapping.",
      "$", location, target
    )
    return(rrp_conformance_result(document, target, do.call(rbind, issues)))
  }

  required <- rrp_specification_required_fields()
  missing <- required[!required %in% names(document)]
  for (field in missing) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "envelope.required_fields", "error", paste0("missing_", field),
      paste0("Required field `", field, "` is missing."),
      paste0("$.", field), location, target
    )
  }

  present <- intersect(required, names(document))
  for (field in present) {
    if (!rrp_is_scalar_character(document[[field]])) {
      issues[[length(issues) + 1L]] <- rrp_conformance_issue(
        "envelope.scalar_fields", "error", paste0("invalid_", field),
        paste0("Field `", field, "` must be one non-empty string."),
        paste0("$.", field), location, target
      )
    }
  }

  if (rrp_is_scalar_character(document$specification_kind) &&
      !grepl(rrp_identifier_pattern(), document$specification_kind, perl = TRUE)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "envelope.identifiers", "error", "invalid_specification_kind",
      "Specification kind must use the platform identifier syntax.",
      "$.specification_kind", location, target
    )
  }

  if (rrp_is_scalar_character(document$specification_id) &&
      !grepl(rrp_identifier_pattern(), document$specification_id, perl = TRUE)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "envelope.identifiers", "error", "invalid_specification_id",
      "Specification ID must use lowercase platform identifier syntax.",
      "$.specification_id", location, target
    )
  }

  for (field in c("specification_version", "specification_format_version")) {
    value <- document[[field]]
    if (rrp_is_scalar_character(value) && !rrp_is_semver(value)) {
      issues[[length(issues) + 1L]] <- rrp_conformance_issue(
        "envelope.versions", "error", paste0("invalid_", field),
        paste0("Field `", field, "` must be a quoted Semantic Versioning string."),
        paste0("$.", field), location, target
      )
    }
  }

  if (rrp_is_semver(document$specification_format_version) &&
      !identical(document$specification_format_version, rrp_specification_format_version())) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "envelope.format_support", "error", "unsupported_specification_format_version",
      paste0(
        "Unsupported specification format version `",
        document$specification_format_version,
        "`; supported version is `", rrp_specification_format_version(), "`."
      ),
      "$.specification_format_version", location, target
    )
  }

  if (rrp_is_scalar_character(document$identity_scope) &&
      !document$identity_scope %in% rrp_specification_identity_scopes()) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "envelope.identity_scope", "error", "invalid_identity_scope",
      paste0(
        "Unknown identity scope `", document$identity_scope, "`; expected one of: ",
        paste(rrp_specification_identity_scopes(), collapse = ", "), "."
      ),
      "$.identity_scope", location, target
    )
  }

  if (rrp_is_scalar_character(document$status) &&
      !document$status %in% rrp_specification_statuses()) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "envelope.status", "error", "invalid_specification_status",
      paste0(
        "Unknown specification status `", document$status, "`; expected one of: ",
        paste(rrp_specification_statuses(), collapse = ", "), "."
      ),
      "$.status", location, target
    )
  }

  if (rrp_is_scalar_character(document$specification_id) &&
      rrp_is_scalar_character(document$identity_scope)) {
    reference_id <- startsWith(document$specification_id, "reference.")
    scope_mismatch <- (reference_id && document$identity_scope != "reference") ||
      (!reference_id && document$identity_scope == "reference")
    if (scope_mismatch) {
      issues[[length(issues) + 1L]] <- rrp_conformance_issue(
        "envelope.identity_scope", "error", "identity_scope_mismatch",
        paste(
          "Reference IDs must use both the `reference.` namespace and",
          "`identity_scope: reference`; non-reference IDs must not claim reference scope."
        ),
        "$.identity_scope", location, target
      )
    }
  }

  rrp_conformance_result(
    document,
    target,
    rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_parse_yaml_specification <- function(path) {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop(
      "Package `yaml` is required. Restore this repository's renv environment.",
      call. = FALSE
    )
  }

  tryCatch(
    list(document = yaml::read_yaml(path), error = NULL),
    error = function(condition) list(document = NULL, error = conditionMessage(condition))
  )
}

rrp_validate_specification_file <- function(path, repository_root = dirname(path)) {
  relative <- if (file.exists(path)) {
    rrp_repository_relative_path(repository_root, path)
  } else {
    path
  }
  parsed <- rrp_parse_yaml_specification(path)
  if (!is.null(parsed$error)) {
    target <- rrp_specification_envelope_identity()
    issue <- rrp_conformance_issue(
      "format.yaml", "error", "malformed_yaml",
      paste0("YAML could not be parsed: ", parsed$error),
      "$", relative, target
    )
    result <- rrp_conformance_result(list(), target, issue)
    attr(result, "document") <- NULL
    return(result)
  }

  result <- rrp_validate_specification_envelope(parsed$document, relative)
  attr(result, "document") <- parsed$document
  result
}

rrp_validate_specification_support <- function(
  document,
  supported_kind,
  supported_id,
  supported_specification_version,
  supported_format_version = rrp_specification_format_version()
) {
  if (!rrp_is_semver(supported_specification_version)) {
    stop("Supported specification version must be a Semantic Versioning string.", call. = FALSE)
  }
  envelope <- rrp_validate_specification_envelope(document)
  issues <- list(envelope$issues)
  target <- list(
    specification_kind = supported_kind,
    specification_id = supported_id,
    specification_version = supported_specification_version
  )

  if (rrp_is_scalar_character(document$specification_kind) &&
      !identical(document$specification_kind, supported_kind)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "compatibility.identity", "error", "unsupported_specification_kind",
      "Consumer does not support this specification kind.",
      "$.specification_kind", specification = target
    )
  }
  if (rrp_is_scalar_character(document$specification_id) &&
      !identical(document$specification_id, supported_id)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "compatibility.identity", "error", "unsupported_specification_id",
      "Consumer does not support this specification ID.",
      "$.specification_id", specification = target
    )
  }
  if (rrp_is_scalar_character(document$specification_format_version) &&
      !identical(document$specification_format_version, supported_format_version)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "compatibility.format", "error", "unsupported_specification_format_version",
      "Consumer does not support this specification format version.",
      "$.specification_format_version", specification = target
    )
  }

  candidate_version <- rrp_semver_components(document$specification_version)
  supported_version <- rrp_semver_components(supported_specification_version)
  same_pre1_minor <- !is.null(candidate_version) && !is.null(supported_version) &&
    candidate_version[["major"]] == supported_version[["major"]] &&
    candidate_version[["minor"]] == supported_version[["minor"]]
  if (!same_pre1_minor) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "compatibility.version", "error", "unsupported_specification_version",
      paste0(
        "Consumer supports the explicit ", supported_version[["major"]], ".",
        supported_version[["minor"]], " specification line only."
      ),
      "$.specification_version", specification = target
    )
  }

  rrp_conformance_result(
    document,
    target,
    rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}
