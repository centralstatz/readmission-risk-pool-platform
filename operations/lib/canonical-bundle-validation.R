# Generic canonical-bundle conformance for the Phase 2.1 handoff foundation.
#
# This validator operates on logical declarations. The optional embedded-record
# realization exists only to exercise generic temporal invariants in tests.

rrp_canonical_bundle_specification_identity <- function() {
  list(
    specification_kind = "canonical_bundle",
    specification_id = "platform.canonical-bundle",
    specification_version = "0.1.0"
  )
}

rrp_canonical_requirement_classes <- function() {
  c("required", "conditional", "optional")
}

rrp_canonical_subject_types <- function() c("domain", "capability")

rrp_canonical_temporal_order_rules <- function() {
  c("not_before_occurrence", "no_order_constraint")
}

rrp_canonical_conformance_layers <- function() {
  c(
    "implementation_local_source",
    "domain",
    "bundle_structure",
    "cross_domain_and_capability",
    "platform_admission"
  )
}

rrp_canonical_failure_categories <- function() {
  c(
    source_local_validation_failed = "implementation_local_source",
    mapping_failed = "implementation_local_source",
    domain_specification_failed = "domain",
    bundle_structure_invalid = "bundle_structure",
    dependency_failed = "cross_domain_and_capability",
    capability_claim_failed = "cross_domain_and_capability",
    unavailable_capability = "cross_domain_and_capability",
    unsupported_capability = "cross_domain_and_capability",
    conforming_bundle = "platform_admission"
  )
}

rrp_is_named_mapping <- function(value) {
  is.list(value) && !is.null(names(value))
}

rrp_is_sequence <- function(value) {
  is.list(value) && (length(value) == 0L || is.null(names(value)))
}

rrp_is_identifier <- function(value) {
  rrp_is_scalar_character(value) &&
    grepl(rrp_identifier_pattern(), value, perl = TRUE)
}

rrp_canonical_result <- function(candidate, issues) {
  rrp_conformance_result(
    candidate,
    rrp_canonical_bundle_specification_identity(),
    rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_canonical_issue <- function(
  rule_id,
  issue_code,
  message,
  object_path,
  location = NA_character_
) {
  rrp_conformance_issue(
    rule_id,
    "error",
    issue_code,
    message,
    object_path,
    location,
    rrp_canonical_bundle_specification_identity()
  )
}

rrp_validate_canonical_specification_reference <- function(
  reference,
  object_path,
  location = NA_character_,
  expected_kind = NULL,
  expected_id = NULL,
  supported_version = NULL
) {
  issues <- list()
  if (!rrp_is_named_mapping(reference)) {
    issues[[1L]] <- rrp_canonical_issue(
      "canonical.bundle.specification_reference",
      "invalid_specification_reference",
      "Specification reference must be a named mapping.",
      object_path,
      location
    )
    return(rrp_canonical_result(reference, issues))
  }

  fields <- c("specification_kind", "specification_id", "specification_version")
  for (field in fields) {
    if (!rrp_is_scalar_character(reference[[field]])) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.bundle.specification_reference",
        paste0("invalid_", field),
        paste0("Specification reference field `", field, "` is required."),
        paste0(object_path, ".", field),
        location
      )
    }
  }

  for (field in c("specification_kind", "specification_id")) {
    if (rrp_is_scalar_character(reference[[field]]) &&
        !rrp_is_identifier(reference[[field]])) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.bundle.specification_reference",
        paste0("invalid_", field),
        paste0("Field `", field, "` must use platform identifier syntax."),
        paste0(object_path, ".", field),
        location
      )
    }
  }

  if (rrp_is_scalar_character(reference$specification_version) &&
      !rrp_is_semver(reference$specification_version)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.bundle.specification_reference",
      "invalid_specification_version",
      "Specification reference version must be Semantic Versioning.",
      paste0(object_path, ".specification_version"),
      location
    )
  }

  if (!is.null(expected_kind) &&
      rrp_is_scalar_character(reference$specification_kind) &&
      !identical(reference$specification_kind, expected_kind)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.bundle.compatibility",
      "unsupported_referenced_specification_kind",
      paste0("Expected specification kind `", expected_kind, "`."),
      paste0(object_path, ".specification_kind"),
      location
    )
  }

  if (!is.null(expected_id) &&
      rrp_is_scalar_character(reference$specification_id) &&
      !identical(reference$specification_id, expected_id)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.bundle.compatibility",
      "unsupported_referenced_specification_id",
      paste0("Expected specification ID `", expected_id, "`."),
      paste0(object_path, ".specification_id"),
      location
    )
  }

  if (!is.null(supported_version) &&
      rrp_is_semver(reference$specification_version)) {
    candidate <- rrp_semver_components(reference$specification_version)
    supported <- rrp_semver_components(supported_version)
    supported_line <- identical(candidate[["major"]], supported[["major"]]) &&
      identical(candidate[["minor"]], supported[["minor"]])
    if (!supported_line) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.bundle.compatibility",
        "unsupported_referenced_specification_version",
        paste0(
          "Only the explicit ", supported[["major"]], ".",
          supported[["minor"]], " specification line is supported."
        ),
        paste0(object_path, ".specification_version"),
        location
      )
    }
  }

  rrp_canonical_result(reference, issues)
}

rrp_validate_canonical_condition <- function(
  condition,
  object_path,
  location = NA_character_
) {
  issues <- list()
  if (!rrp_is_named_mapping(condition)) {
    issues[[1L]] <- rrp_canonical_issue(
      "canonical.requirement.condition",
      "missing_requirement_condition",
      "Conditional requirement requires one declarative condition mapping.",
      object_path,
      location
    )
    return(rrp_canonical_result(condition, issues))
  }

  if (!rrp_is_scalar_character(condition$subject_type) ||
      !condition$subject_type %in% rrp_canonical_subject_types()) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.requirement.condition",
      "invalid_condition_subject_type",
      "Condition subject type must be `domain` or `capability`.",
      paste0(object_path, ".subject_type"),
      location
    )
  }
  if (!rrp_is_identifier(condition$subject_id)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.requirement.condition",
      "invalid_condition_subject_id",
      "Condition subject ID must be a stable logical identifier.",
      paste0(object_path, ".subject_id"),
      location
    )
  }
  if (!rrp_is_scalar_character(condition$required_status) ||
      !identical(condition$required_status, "available")) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.requirement.condition",
      "unsupported_condition_status",
      "The initial declarative condition supports `required_status: available` only.",
      paste0(object_path, ".required_status"),
      location
    )
  }

  rrp_canonical_result(condition, issues)
}

rrp_validate_canonical_temporal_declaration <- function(
  declaration,
  object_path,
  location = NA_character_
) {
  issues <- list()
  if (!rrp_is_named_mapping(declaration)) {
    issues[[1L]] <- rrp_canonical_issue(
      "canonical.temporal.declaration",
      "invalid_temporal_declaration",
      "Temporal declaration must be a named mapping.",
      object_path,
      location
    )
    return(rrp_canonical_result(declaration, issues))
  }

  for (field in c("occurrence_field", "availability_field")) {
    if (!rrp_is_identifier(declaration[[field]])) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.temporal.declaration",
        paste0("invalid_", field),
        paste0("Temporal `", field, "` must be a logical field identifier."),
        paste0(object_path, ".", field),
        location
      )
    }
  }
  if (!rrp_is_scalar_character(declaration$availability_order) ||
      !declaration$availability_order %in% rrp_canonical_temporal_order_rules()) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.temporal.declaration",
      "invalid_availability_order",
      paste0(
        "Availability order must be one of: ",
        paste(rrp_canonical_temporal_order_rules(), collapse = ", "), "."
      ),
      paste0(object_path, ".availability_order"),
      location
    )
  }

  rrp_canonical_result(declaration, issues)
}

rrp_validate_canonical_domain_registration <- function(
  domain,
  index,
  location = NA_character_
) {
  path <- paste0("$.bundle_instance.domains[", index, "]")
  issues <- list()
  if (!rrp_is_named_mapping(domain)) {
    issues[[1L]] <- rrp_canonical_issue(
      "canonical.domain.registration",
      "invalid_domain_registration",
      "Domain registration must be a named mapping.",
      path,
      location
    )
    return(rrp_canonical_result(domain, issues))
  }

  if (!rrp_is_identifier(domain$domain_id)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.domain.identity",
      "invalid_domain_id",
      "Domain ID must be a stable logical identifier.",
      paste0(path, ".domain_id"),
      location
    )
  }
  specification <- rrp_validate_canonical_specification_reference(
    domain$domain_specification,
    paste0(path, ".domain_specification"),
    location,
    expected_kind = "canonical_domain"
  )
  issues[[length(issues) + 1L]] <- specification$issues

  if (!rrp_is_scalar_character(domain$requirement_class) ||
      !domain$requirement_class %in% rrp_canonical_requirement_classes()) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.requirement.class",
      "invalid_requirement_class",
      paste0(
        "Requirement class must be one of: ",
        paste(rrp_canonical_requirement_classes(), collapse = ", "), "."
      ),
      paste0(path, ".requirement_class"),
      location
    )
  }
  if (!rrp_is_scalar_character(domain$status) ||
      !domain$status %in% rrp_capability_statuses()) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.domain.status",
      "invalid_domain_status",
      "Domain status must reuse the Phase 1 capability-status vocabulary.",
      paste0(path, ".status"),
      location
    )
  }

  supplied_status <- rrp_is_scalar_character(domain$status) &&
    domain$status %in% c("available", "failed_conformance")
  if (supplied_status && !rrp_is_identifier(domain$domain_instance_id)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.domain.instance_identity",
      "missing_domain_instance_id",
      "A supplied domain requires a logical domain instance ID.",
      paste0(path, ".domain_instance_id"),
      location
    )
  }
  absent_status <- rrp_is_scalar_character(domain$status) &&
    domain$status %in% c("unavailable", "unsupported")
  if (absent_status && !is.null(domain$domain_instance_id)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.domain.absence",
      "absent_domain_has_instance",
      "Unavailable or unsupported domains must not claim a supplied instance.",
      paste0(path, ".domain_instance_id"),
      location
    )
  }

  if (!is.null(domain$capability_ids)) {
    values <- unlist(domain$capability_ids, use.names = FALSE)
    if (!is.character(values) || any(!vapply(values, rrp_is_identifier, logical(1)))) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.domain.capability_association",
        "invalid_domain_capability_ids",
        "Domain capability associations must be logical identifier strings.",
        paste0(path, ".capability_ids"),
        location
      )
    }
  }

  if (identical(domain$requirement_class, "conditional")) {
    condition <- rrp_validate_canonical_condition(
      domain$condition,
      paste0(path, ".condition"),
      location
    )
    issues[[length(issues) + 1L]] <- condition$issues
  }
  if (!is.null(domain$temporal_declaration)) {
    temporal <- rrp_validate_canonical_temporal_declaration(
      domain$temporal_declaration,
      paste0(path, ".temporal_declaration"),
      location
    )
    issues[[length(issues) + 1L]] <- temporal$issues
  }

  rrp_canonical_result(domain, issues)
}

rrp_validate_canonical_capability_declaration <- function(
  capability,
  index,
  location = NA_character_
) {
  path <- paste0("$.bundle_instance.capabilities[", index, "]")
  issues <- list()
  if (!rrp_is_named_mapping(capability)) {
    issues[[1L]] <- rrp_canonical_issue(
      "canonical.capability.declaration",
      "invalid_capability_declaration",
      "Capability declaration must be a named mapping.",
      path,
      location
    )
    return(rrp_canonical_result(capability, issues))
  }

  if (!rrp_is_identifier(capability$capability_id)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.capability.identity",
      "invalid_capability_id",
      "Capability ID must be a stable logical identifier.",
      paste0(path, ".capability_id"),
      location
    )
  }
  if (!rrp_is_scalar_character(capability$requirement_class) ||
      !capability$requirement_class %in% rrp_canonical_requirement_classes()) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.requirement.class",
      "invalid_requirement_class",
      "Capability requirement class must be required, conditional, or optional.",
      paste0(path, ".requirement_class"),
      location
    )
  }
  if (!rrp_is_scalar_character(capability$status) ||
      !capability$status %in% rrp_capability_statuses()) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.capability.status",
      "invalid_capability_status",
      "Capability status must reuse the Phase 1 controlled vocabulary.",
      paste0(path, ".status"),
      location
    )
  }
  if (!is.null(capability$domain_ids)) {
    values <- unlist(capability$domain_ids, use.names = FALSE)
    if (!is.character(values) || any(!vapply(values, rrp_is_identifier, logical(1)))) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.capability.domain_association",
        "invalid_capability_domain_ids",
        "Capability domain associations must be logical identifier strings.",
        paste0(path, ".domain_ids"),
        location
      )
    }
  }
  if (identical(capability$requirement_class, "conditional")) {
    condition <- rrp_validate_canonical_condition(
      capability$condition,
      paste0(path, ".condition"),
      location
    )
    issues[[length(issues) + 1L]] <- condition$issues
  }

  rrp_canonical_result(capability, issues)
}

rrp_registration_ids <- function(registrations, id_field) {
  vapply(registrations, function(registration) {
    if (!rrp_is_named_mapping(registration) ||
        !rrp_is_identifier(registration[[id_field]])) return(NA_character_)
    registration[[id_field]]
  }, character(1))
}

rrp_registration_status <- function(registrations, id_field, id) {
  ids <- rrp_registration_ids(registrations, id_field)
  index <- match(id, ids)
  if (length(index) != 1L || is.na(index)) return(NULL)
  registrations[[index]]$status
}

rrp_validate_canonical_requirement_semantics <- function(
  registrations,
  item_type,
  domains,
  capabilities,
  location = NA_character_
) {
  issues <- list()
  collection_field <- if (identical(item_type, "domain")) {
    "domains"
  } else {
    "capabilities"
  }
  for (index in seq_along(registrations)) {
    item <- registrations[[index]]
    if (!rrp_is_named_mapping(item)) next
    path <- paste0("$.bundle_instance.", collection_field, "[", index, "]")

    if (identical(item$status, "failed_conformance")) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        paste0("canonical.", item_type, ".claim"),
        paste0("failed_", item_type, "_conformance"),
        paste0("The claimed ", item_type, " failed its applicable conformance."),
        paste0(path, ".status"),
        location
      )
    }
    if (identical(item$requirement_class, "required") &&
        !identical(item$status, "available")) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.requirement.required",
        "required_item_not_available",
        paste0("Required ", item_type, " must have status `available`."),
        paste0(path, ".status"),
        location
      )
    }

    if (identical(item$requirement_class, "conditional") &&
        rrp_is_named_mapping(item$condition) &&
        rrp_is_identifier(item$condition$subject_id) &&
        item$condition$subject_type %in% rrp_canonical_subject_types()) {
      source <- if (identical(item$condition$subject_type, "domain")) {
        rrp_registration_status(domains, "domain_id", item$condition$subject_id)
      } else {
        rrp_registration_status(
          capabilities, "capability_id", item$condition$subject_id
        )
      }
      if (is.null(source)) {
        issues[[length(issues) + 1L]] <- rrp_canonical_issue(
          "canonical.requirement.condition",
          "unknown_condition_subject",
          "Conditional requirement references an undeclared subject.",
          paste0(path, ".condition.subject_id"),
          location
        )
      } else if (identical(source, item$condition$required_status) &&
                 !identical(item$status, "available")) {
        issues[[length(issues) + 1L]] <- rrp_canonical_issue(
          "canonical.requirement.conditional",
          "conditional_item_not_available",
          paste0("Active conditional ", item_type, " must be available."),
          paste0(path, ".status"),
          location
        )
      }
    }
  }

  rrp_canonical_result(registrations, issues)
}

rrp_dependency_graph_has_cycle <- function(dependencies) {
  edges <- lapply(dependencies, function(dependency) {
    if (!rrp_is_named_mapping(dependency) ||
        !rrp_is_scalar_character(dependency$subject_type) ||
        !dependency$subject_type %in% rrp_canonical_subject_types() ||
        !identical(dependency$subject_type, dependency$prerequisite_type) ||
        !rrp_is_identifier(dependency$subject_id) ||
        !rrp_is_identifier(dependency$prerequisite_id)) return(NULL)
    c(
      paste(dependency$subject_type, dependency$subject_id, sep = ":"),
      paste(dependency$prerequisite_type, dependency$prerequisite_id, sep = ":")
    )
  })
  edges <- Filter(Negate(is.null), edges)
  if (length(edges) == 0L) return(FALSE)

  nodes <- unique(unlist(edges, use.names = FALSE))
  state <- stats::setNames(rep.int(0L, length(nodes)), nodes)
  adjacency <- split(vapply(edges, `[[`, character(1), 2L),
                     vapply(edges, `[[`, character(1), 1L))

  visit <- function(node) {
    if (state[[node]] == 1L) return(TRUE)
    if (state[[node]] == 2L) return(FALSE)
    state[[node]] <<- 1L
    for (next_node in adjacency[[node]] %||% character()) {
      if (visit(next_node)) return(TRUE)
    }
    state[[node]] <<- 2L
    FALSE
  }

  any(vapply(nodes, visit, logical(1)))
}

rrp_validate_canonical_dependencies <- function(
  dependencies,
  domains,
  capabilities,
  location = NA_character_
) {
  issues <- list()
  dependency_ids <- character()

  for (index in seq_along(dependencies)) {
    dependency <- dependencies[[index]]
    path <- paste0("$.bundle_instance.dependencies[", index, "]")
    if (!rrp_is_named_mapping(dependency)) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.dependency.declaration",
        "invalid_dependency_declaration",
        "Dependency declaration must be a named mapping.",
        path,
        location
      )
      next
    }

    if (!rrp_is_identifier(dependency$dependency_id)) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.dependency.identity",
        "invalid_dependency_id",
        "Dependency ID must be a stable logical identifier.",
        paste0(path, ".dependency_id"),
        location
      )
    } else {
      dependency_ids <- c(dependency_ids, dependency$dependency_id)
    }
    for (field in c("subject_type", "prerequisite_type")) {
      if (!rrp_is_scalar_character(dependency[[field]]) ||
          !dependency[[field]] %in% rrp_canonical_subject_types()) {
        issues[[length(issues) + 1L]] <- rrp_canonical_issue(
          "canonical.dependency.type",
          paste0("invalid_", field),
          paste0("Dependency `", field, "` must be domain or capability."),
          paste0(path, ".", field),
          location
        )
      }
    }
    for (field in c("subject_id", "prerequisite_id")) {
      if (!rrp_is_identifier(dependency[[field]])) {
        issues[[length(issues) + 1L]] <- rrp_canonical_issue(
          "canonical.dependency.identity",
          paste0("invalid_", field),
          paste0("Dependency `", field, "` must be a logical identifier."),
          paste0(path, ".", field),
          location
        )
      }
    }
    valid_subject_type <- rrp_is_scalar_character(dependency$subject_type) &&
      dependency$subject_type %in% rrp_canonical_subject_types()
    valid_prerequisite_type <-
      rrp_is_scalar_character(dependency$prerequisite_type) &&
      dependency$prerequisite_type %in% rrp_canonical_subject_types()
    if (valid_subject_type && valid_prerequisite_type &&
        !identical(dependency$subject_type, dependency$prerequisite_type)) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.dependency.type",
        "cross_type_dependency_not_supported",
        "Initial dependencies must be domain-to-domain or capability-to-capability.",
        path,
        location
      )
      next
    }

    registrations <- if (identical(dependency$subject_type, "domain")) {
      domains
    } else {
      capabilities
    }
    id_field <- if (identical(dependency$subject_type, "domain")) {
      "domain_id"
    } else {
      "capability_id"
    }
    subject_status <- rrp_registration_status(
      registrations, id_field, dependency$subject_id
    )
    prerequisite_status <- rrp_registration_status(
      registrations, id_field, dependency$prerequisite_id
    )
    if (is.null(subject_status)) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.dependency.reference",
        "unknown_dependency_subject",
        "Dependency subject is not declared in the bundle.",
        paste0(path, ".subject_id"),
        location
      )
    }
    if (is.null(prerequisite_status)) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.dependency.reference",
        "unknown_dependency_prerequisite",
        "Dependency prerequisite is not declared in the bundle.",
        paste0(path, ".prerequisite_id"),
        location
      )
    }
    if (!is.null(subject_status) && identical(subject_status, "available") &&
        !identical(prerequisite_status, "available")) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.dependency.satisfaction",
        "missing_available_prerequisite",
        "An available subject requires its declared prerequisite to be available.",
        paste0(path, ".prerequisite_id"),
        location
      )
    }
  }

  duplicate_ids <- unique(dependency_ids[duplicated(dependency_ids)])
  for (id in duplicate_ids) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.dependency.identity",
      "duplicate_dependency_id",
      paste0("Dependency ID is registered more than once: ", id, "."),
      "$.bundle_instance.dependencies",
      location
    )
  }
  if (rrp_dependency_graph_has_cycle(dependencies)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.dependency.graph",
      "circular_dependency",
      "Canonical dependency declarations must be acyclic.",
      "$.bundle_instance.dependencies",
      location
    )
  }

  rrp_canonical_result(dependencies, issues)
}

rrp_timestamp_number <- function(value) {
  normalized <- sub("Z$", "+0000", value)
  normalized <- sub("([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", normalized, perl = TRUE)
  as.numeric(as.POSIXct(
    strptime(normalized, format = "%Y-%m-%dT%H:%M:%OS%z", tz = "UTC")
  ))
}

rrp_validate_canonical_temporal_realization <- function(
  bundle,
  domains,
  location = NA_character_
) {
  realization <- bundle$reference_test_realization
  if (is.null(realization)) return(rrp_canonical_result(bundle, list()))
  issues <- list()
  path <- "$.bundle_instance.reference_test_realization"

  if (!rrp_is_named_mapping(realization) ||
      !identical(realization$realization_kind, "embedded_records") ||
      !rrp_is_sequence(realization$domain_payloads)) {
    issues[[1L]] <- rrp_canonical_issue(
      "canonical.reference_realization.structure",
      "invalid_reference_test_realization",
      "Reference realization must declare embedded_records and domain_payloads.",
      path,
      location
    )
    return(rrp_canonical_result(bundle, issues))
  }

  domain_instance_ids <- vapply(domains, function(domain) {
    if (!rrp_is_named_mapping(domain) ||
        !rrp_is_identifier(domain$domain_instance_id)) return(NA_character_)
    domain$domain_instance_id
  }, character(1))
  payload_ids <- character()
  as_of <- bundle$run_context$as_of_time %||% NULL
  as_of_number <- if (rrp_is_rfc3339_timestamp(as_of)) {
    rrp_timestamp_number(as_of)
  } else {
    NA_real_
  }

  for (payload_index in seq_along(realization$domain_payloads)) {
    payload <- realization$domain_payloads[[payload_index]]
    payload_path <- paste0(path, ".domain_payloads[", payload_index, "]")
    if (!rrp_is_named_mapping(payload) ||
        !rrp_is_identifier(payload$domain_instance_id) ||
        !rrp_is_sequence(payload$records)) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.reference_realization.structure",
        "invalid_domain_payload",
        "Domain payload requires an instance ID and a record sequence.",
        payload_path,
        location
      )
      next
    }
    payload_ids <- c(payload_ids, payload$domain_instance_id)
    domain_index <- match(payload$domain_instance_id, domain_instance_ids)
    if (is.na(domain_index)) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.reference_realization.identity",
        "unknown_payload_domain_instance",
        "Embedded payload does not match a supplied domain instance.",
        paste0(payload_path, ".domain_instance_id"),
        location
      )
      next
    }

    declaration <- domains[[domain_index]]$temporal_declaration
    if (!rrp_is_named_mapping(declaration)) next
    occurrence_field <- declaration$occurrence_field
    availability_field <- declaration$availability_field

    for (record_index in seq_along(payload$records)) {
      record <- payload$records[[record_index]]
      record_path <- paste0(payload_path, ".records[", record_index, "]")
      if (!rrp_is_named_mapping(record)) {
        issues[[length(issues) + 1L]] <- rrp_canonical_issue(
          "canonical.temporal.record",
          "invalid_temporal_record",
          "Embedded temporal record must be a named mapping.",
          record_path,
          location
        )
        next
      }
      occurred_at <- record[[occurrence_field]]
      available_at <- record[[availability_field]]
      for (field in c(occurrence_field, availability_field)) {
        if (!rrp_is_rfc3339_timestamp(record[[field]])) {
          issues[[length(issues) + 1L]] <- rrp_canonical_issue(
            "canonical.temporal.timestamp",
            "invalid_temporal_timestamp",
            paste0("Temporal field `", field, "` must be explicit-offset RFC 3339."),
            paste0(record_path, ".", field),
            location
          )
        }
      }
      if (!rrp_is_rfc3339_timestamp(occurred_at) ||
          !rrp_is_rfc3339_timestamp(available_at)) next

      occurred_number <- rrp_timestamp_number(occurred_at)
      available_number <- rrp_timestamp_number(available_at)
      if (identical(declaration$availability_order, "not_before_occurrence") &&
          available_number < occurred_number) {
        issues[[length(issues) + 1L]] <- rrp_canonical_issue(
          "canonical.temporal.occurrence_availability",
          "availability_before_occurrence",
          "Availability precedes occurrence although the domain prohibits it.",
          paste0(record_path, ".", availability_field),
          location
        )
      }
      if (!is.na(as_of_number) && available_number > as_of_number) {
        issues[[length(issues) + 1L]] <- rrp_canonical_issue(
          "canonical.temporal.as_of",
          "information_after_as_of",
          "Information was not available by the bundle's authoritative as-of time.",
          paste0(record_path, ".", availability_field),
          location
        )
      }
    }
  }

  duplicate_payloads <- unique(payload_ids[duplicated(payload_ids)])
  for (id in duplicate_payloads) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.reference_realization.identity",
      "duplicate_domain_payload",
      paste0("Domain instance has more than one embedded payload: ", id, "."),
      paste0(path, ".domain_payloads"),
      location
    )
  }

  rrp_canonical_result(bundle, issues)
}

rrp_validate_canonical_bundle_instance <- function(
  bundle,
  location = NA_character_
) {
  issues <- list()
  if (!rrp_is_named_mapping(bundle)) {
    issues[[1L]] <- rrp_canonical_issue(
      "canonical.bundle.structure",
      "invalid_bundle_instance",
      "Canonical bundle instance must be a named mapping.",
      "$.bundle_instance",
      location
    )
    return(rrp_canonical_result(bundle, issues))
  }

  if (!rrp_is_identifier(bundle$bundle_instance_id)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.bundle.instance_identity",
      "missing_or_invalid_bundle_instance_id",
      "Bundle instance ID must be a stable logical identifier.",
      "$.bundle_instance.bundle_instance_id",
      location
    )
  }
  expected <- rrp_canonical_bundle_specification_identity()
  bundle_specification <- rrp_validate_canonical_specification_reference(
    bundle$bundle_specification,
    "$.bundle_instance.bundle_specification",
    location,
    expected_kind = expected$specification_kind,
    expected_id = expected$specification_id,
    supported_version = expected$specification_version
  )
  issues[[length(issues) + 1L]] <- bundle_specification$issues

  run_context <- rrp_validate_run_context(bundle$run_context, location)
  implementation <- rrp_validate_versioned_identity(
    bundle$implementation_identity,
    "implementation_id",
    "implementation_version",
    "$.bundle_instance.implementation_identity",
    location
  )
  mapping <- rrp_validate_versioned_identity(
    bundle$mapping_identity,
    "mapping_id",
    "mapping_version",
    "$.bundle_instance.mapping_identity",
    location
  )
  issues <- c(issues, list(
    run_context$issues,
    implementation$issues,
    mapping$issues
  ))

  sequence_fields <- c("domains", "capabilities", "dependencies", "provenance_references")
  for (field in sequence_fields) {
    if (!rrp_is_sequence(bundle[[field]])) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.bundle.structure",
        paste0("invalid_", field),
        paste0("Bundle field `", field, "` must be a YAML sequence."),
        paste0("$.bundle_instance.", field),
        location
      )
    }
  }
  domains <- if (rrp_is_sequence(bundle$domains)) bundle$domains else list()
  capabilities <- if (rrp_is_sequence(bundle$capabilities)) bundle$capabilities else list()
  dependencies <- if (rrp_is_sequence(bundle$dependencies)) bundle$dependencies else list()

  domain_results <- lapply(seq_along(domains), function(index) {
    rrp_validate_canonical_domain_registration(domains[[index]], index, location)
  })
  capability_results <- lapply(seq_along(capabilities), function(index) {
    rrp_validate_canonical_capability_declaration(
      capabilities[[index]], index, location
    )
  })
  issues <- c(
    issues,
    lapply(domain_results, `[[`, "issues"),
    lapply(capability_results, `[[`, "issues")
  )

  for (definition in list(
    list(items = domains, field = "domain_id", type = "domain"),
    list(items = capabilities, field = "capability_id", type = "capability")
  )) {
    ids <- rrp_registration_ids(definition$items, definition$field)
    duplicate_ids <- unique(ids[!is.na(ids) & duplicated(ids)])
    for (id in duplicate_ids) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        paste0("canonical.", definition$type, ".identity"),
        paste0("duplicate_", definition$type, "_registration"),
        paste0("Logical ", definition$type, " is registered more than once: ", id, "."),
        paste0("$.bundle_instance.", definition$type, "s"),
        location
      )
    }
  }

  domain_instance_ids <- vapply(domains, function(domain) {
    if (!rrp_is_named_mapping(domain) ||
        !rrp_is_identifier(domain$domain_instance_id)) return(NA_character_)
    domain$domain_instance_id
  }, character(1))
  duplicate_instances <- unique(domain_instance_ids[
    !is.na(domain_instance_ids) & duplicated(domain_instance_ids)
  ])
  for (id in duplicate_instances) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.domain.instance_identity",
      "duplicate_domain_instance_id",
      paste0("Domain instance ID is used more than once: ", id, "."),
      "$.bundle_instance.domains",
      location
    )
  }

  domain_requirements <- rrp_validate_canonical_requirement_semantics(
    domains, "domain", domains, capabilities, location
  )
  capability_requirements <- rrp_validate_canonical_requirement_semantics(
    capabilities, "capability", domains, capabilities, location
  )
  dependency_result <- rrp_validate_canonical_dependencies(
    dependencies, domains, capabilities, location
  )
  issues <- c(issues, list(
    domain_requirements$issues,
    capability_requirements$issues,
    dependency_result$issues
  ))

  domain_ids <- rrp_registration_ids(domains, "domain_id")
  capability_ids <- rrp_registration_ids(capabilities, "capability_id")
  for (index in seq_along(domains)) {
    if (!rrp_is_named_mapping(domains[[index]])) next
    associations <- unlist(domains[[index]]$capability_ids, use.names = FALSE)
    unknown <- setdiff(associations, capability_ids[!is.na(capability_ids)])
    for (id in unknown) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.domain.capability_association",
        "unknown_associated_capability",
        paste0("Domain references undeclared capability: ", id, "."),
        paste0("$.bundle_instance.domains[", index, "].capability_ids"),
        location
      )
    }
  }
  for (index in seq_along(capabilities)) {
    if (!rrp_is_named_mapping(capabilities[[index]])) next
    associations <- unlist(capabilities[[index]]$domain_ids, use.names = FALSE)
    unknown <- setdiff(associations, domain_ids[!is.na(domain_ids)])
    for (id in unknown) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.capability.domain_association",
        "unknown_associated_domain",
        paste0("Capability references undeclared domain: ", id, "."),
        paste0("$.bundle_instance.capabilities[", index, "].domain_ids"),
        location
      )
    }
    if (identical(capabilities[[index]]$status, "available")) {
      for (id in intersect(associations, domain_ids)) {
        if (!identical(rrp_registration_status(domains, "domain_id", id), "available")) {
          issues[[length(issues) + 1L]] <- rrp_canonical_issue(
            "canonical.capability.domain_association",
            "capability_domain_not_available",
            "Available capability requires every associated domain to be available.",
            paste0("$.bundle_instance.capabilities[", index, "].domain_ids"),
            location
          )
        }
      }
    }
  }

  provenance <- if (rrp_is_sequence(bundle$provenance_references)) {
    bundle$provenance_references
  } else {
    list()
  }
  for (reference in provenance) {
    result <- rrp_validate_provenance_reference(reference, location)
    issues[[length(issues) + 1L]] <- result$issues
  }
  if (!is.null(bundle$conformance_result_references)) {
    if (!rrp_is_sequence(bundle$conformance_result_references)) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.bundle.conformance_reference",
        "invalid_conformance_result_references",
        "Conformance result references must be a sequence.",
        "$.bundle_instance.conformance_result_references",
        location
      )
    } else {
      for (reference in bundle$conformance_result_references) {
        result <- rrp_validate_provenance_reference(reference, location)
        issues[[length(issues) + 1L]] <- result$issues
      }
    }
  }

  temporal <- rrp_validate_canonical_temporal_realization(bundle, domains, location)
  issues[[length(issues) + 1L]] <- temporal$issues
  rrp_canonical_result(bundle, issues)
}
