# Implementation-local identity and deterministic run configuration.

rrp_synthetic_implementation_specification_identity <- function() {
  list(
    specification_kind = "source_implementation",
    specification_id = "reference.synthetic-source-implementation",
    specification_version = "0.1.0"
  )
}

rrp_synthetic_source_schema_identity <- function() {
  list(
    specification_kind = "source_schema",
    specification_id = "reference.synthetic-health-system-source-schema",
    specification_version = "0.1.0"
  )
}

rrp_synthetic_expected_identities <- function() {
  list(
    implementation_identity = list(
      implementation_id = "reference.synthetic-health-system",
      implementation_version = "0.1.0"
    ),
    mapping_identity = list(
      mapping_id = "reference.synthetic-to-readmission-canonical",
      mapping_version = "0.1.0"
    ),
    generator_identity = list(
      generator_id = "reference.synthetic-health-system-generator",
      generator_version = "0.1.0"
    ),
    source_schema_identity = list(
      source_schema_id = "reference.synthetic-health-system-source-schema",
      source_schema_version = "0.1.0"
    )
  )
}

rrp_synthetic_issue <- function(
  rule_id,
  issue_code,
  message,
  object_path = NA_character_,
  location = NA_character_,
  specification = rrp_synthetic_implementation_specification_identity()
) {
  rrp_conformance_issue(
    rule_id, "error", issue_code, message, object_path, location, specification
  )
}

rrp_synthetic_result <- function(candidate, issues, specification = NULL) {
  rrp_conformance_result(
    candidate,
    specification %||% rrp_synthetic_implementation_specification_identity(),
    rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_synthetic_read_yaml <- function(path) {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("Package `yaml` is required. Restore the repository environment.", call. = FALSE)
  }
  yaml::read_yaml(path)
}

rrp_synthetic_implementation_root <- function(repository_root) {
  file.path(repository_root, "implementations", "synthetic-reference")
}

rrp_read_synthetic_implementation_specification <- function(repository_root) {
  rrp_synthetic_read_yaml(file.path(
    rrp_synthetic_implementation_root(repository_root), "implementation.yml"
  ))
}

rrp_read_synthetic_source_schema <- function(repository_root) {
  rrp_synthetic_read_yaml(file.path(
    rrp_synthetic_implementation_root(repository_root), "source-schema.yml"
  ))
}

rrp_read_synthetic_configuration <- function(repository_root, scale = "reference") {
  if (!scale %in% c("test", "reference")) {
    stop("Synthetic scale must be `test` or `reference`.", call. = FALSE)
  }
  rrp_synthetic_read_yaml(file.path(
    rrp_synthetic_implementation_root(repository_root), "config", paste0(scale, ".yml")
  ))
}

rrp_validate_synthetic_implementation_specification <- function(
  document,
  location = NA_character_
) {
  issues <- list()
  identity <- rrp_synthetic_implementation_specification_identity()
  support <- rrp_validate_specification_support(
    document,
    identity$specification_kind,
    identity$specification_id,
    identity$specification_version
  )
  issues[[length(issues) + 1L]] <- support$issues
  expected <- rrp_synthetic_expected_identities()
  for (name in names(expected)) {
    if (!identical(document[[name]], expected[[name]])) {
      issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
        "synthetic.identity.separation",
        "invalid_synthetic_identity",
        paste0("Synthetic identity does not match supported `", name, "`."),
        paste0("$.", name), location, identity
      )
    }
  }
  if (!identical(document$data_classification, "fictional_nonclinical") ||
      !identical(document$clinical_validity, "none")) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.classification", "invalid_synthetic_classification",
      "Synthetic implementation must remain fictional, nonclinical, and clinically unvalidated.",
      "$.data_classification", location, identity
    )
  }
  expected_capabilities <- list(
    discharge_episode = "available",
    baseline_risk = "available",
    episode_event = "available"
  )
  if (!identical(document$capabilities, expected_capabilities)) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.capabilities", "invalid_synthetic_capabilities",
      "Standard synthetic implementation must declare all three profile capabilities available.",
      "$.capabilities", location, identity
    )
  }
  profile <- document$canonical_profile
  if (!rrp_is_named_mapping(profile) ||
      !identical(profile$specification_kind, "canonical_profile") ||
      !identical(profile$specification_id, "platform.readmission-initial-profile") ||
      !identical(profile$specification_version, "0.1.0")) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.profile", "unsupported_synthetic_profile",
      "Synthetic implementation must target the approved initial canonical profile.",
      "$.canonical_profile", location, identity
    )
  }
  rrp_synthetic_result(document, issues, identity)
}

rrp_validate_synthetic_configuration <- function(
  config,
  implementation,
  location = NA_character_
) {
  issues <- list()
  envelope <- rrp_validate_specification_envelope(config, location)
  issues[[length(issues) + 1L]] <- envelope$issues
  supported_configuration_id <- rrp_is_scalar_character(config$specification_id) &&
    config$specification_id %in% c(
      "reference.synthetic-run-test", "reference.synthetic-run-reference"
    )
  if (!identical(config$specification_kind, "synthetic_run_configuration") ||
      !supported_configuration_id ||
      !identical(config$specification_version, "0.1.0")) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.configuration.identity", "invalid_synthetic_configuration_identity",
      "Synthetic configuration identity is unsupported.", "$", location
    )
  }
  reference <- config$implementation_specification
  expected <- rrp_synthetic_implementation_specification_identity()
  if (!rrp_is_named_mapping(reference) ||
      !identical(reference$specification_kind, expected$specification_kind) ||
      !identical(reference$specification_id, expected$specification_id) ||
      !identical(reference$specification_version, expected$specification_version)) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.configuration.implementation", "invalid_implementation_reference",
      "Run configuration must reference the supported synthetic implementation.",
      "$.implementation_specification", location
    )
  }
  if (!identical(config$data_classification, "fictional_nonclinical")) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.configuration.classification", "invalid_configuration_classification",
      "Synthetic configuration must be visibly fictional and nonclinical.",
      "$.data_classification", location
    )
  }
  if (!rrp_is_scalar_character(config$scale_id) ||
      !config$scale_id %in% c("test", "reference")) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.configuration.scale", "invalid_synthetic_scale",
      "Synthetic scale must be test or reference.", "$.scale_id", location
    )
  }
  for (field in c("seed", "patient_count", "episode_count", "followup_window_days")) {
    value <- config[[field]]
    if (!is.numeric(value) || length(value) != 1L || is.na(value) ||
        value != as.integer(value) || value <= 0) {
      issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
        "synthetic.configuration.integer", "invalid_synthetic_integer",
        paste0("Configuration field `", field, "` must be one positive integer."),
        paste0("$.", field), location
      )
    }
  }
  if (is.numeric(config$patient_count) && is.numeric(config$episode_count) &&
      config$episode_count < config$patient_count) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.configuration.relationship", "too_few_synthetic_episodes",
      "Episode count must be at least patient count so every patient has an episode.",
      "$.episode_count", location
    )
  }
  for (field in c("simulation_as_of_time", "canonical_as_of_time")) {
    if (!rrp_is_rfc3339_timestamp(config[[field]])) {
      issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
        "synthetic.configuration.time", "invalid_synthetic_as_of_time",
        paste0("Configuration field `", field, "` must be explicit-offset RFC 3339."),
        paste0("$.", field), location
      )
    }
  }
  if (!identical(config$simulation_as_of_time, config$canonical_as_of_time)) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.configuration.time_relationship", "mismatched_reference_cutoff",
      paste(
        "The reference operation deliberately uses the simulation snapshot time",
        "as its canonical cutoff; the two declared values must match."
      ),
      "$.canonical_as_of_time", location
    )
  }
  implementation_result <- rrp_validate_synthetic_implementation_specification(
    implementation, location
  )
  issues[[length(issues) + 1L]] <- implementation_result$issues
  rrp_synthetic_result(config, issues)
}
