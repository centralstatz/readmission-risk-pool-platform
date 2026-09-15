software_resource_copy <- function(value) {
  unserialize(serialize(value, NULL))
}

software_resource_documents <- function(repository_root) {
  list(
    catalog = yaml::read_yaml(file.path(
      repository_root, "distribution", "software", "resource-catalog.yml"
    )),
    schema = yaml::read_yaml(file.path(
      repository_root, "distribution", "software",
      "resource-catalog-schema.yml"
    ))
  )
}

software_resource_validate <- function(documents, repository_root) {
  rrp_validate_installed_resource_catalog(
    documents$catalog, documents$schema, repository_root
  )
}

software_resource_fixture_root <- function(repository_root, catalog) {
  fixture_root <- tempfile("rrp-resource-catalog-")
  dir.create(fixture_root)
  for (source_path in vapply(
    catalog$resources, `[[`, character(1L), "source_path"
  )) {
    destination <- file.path(fixture_root, source_path)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    copied <- file.copy(
      file.path(repository_root, source_path), destination,
      overwrite = TRUE, copy.mode = TRUE
    )
    if (!copied) stop("Could not create catalog source fixture.", call. = FALSE)
  }
  fixture_root
}

software_resource_test_cases <- function(repository_root) {
  documents <- software_resource_documents(repository_root)
  catalog <- documents$catalog
  schema <- documents$schema
  sources <- vapply(catalog$resources, `[[`, character(1L), "source_path")
  outputs <- vapply(catalog$resources, `[[`, character(1L), "output_path")
  resource_ids <- vapply(catalog$resources, `[[`, character(1L), "resource_id")

  list(
    "authoritative catalog and schema conform" = function() {
      phase0_assert_true(rrp_validate_resource_catalog_schema(schema)$passed)
      phase0_assert_true(software_resource_validate(documents, repository_root)$passed)
      phase0_assert_true(
        rrp_validate_software_resource_repository(repository_root)$passed
      )
    },

    "catalog entries contain every closed required field" = function() {
      required <- rrp_software_resource_values(
        schema$resource_entry_contract$required_fields
      )
      phase0_assert_true(all(vapply(catalog$resources, function(entry) {
        setequal(names(entry), required)
      }, logical(1L))))
    },

    "stable resource IDs and exact outputs are unique" = function() {
      phase0_assert_true(!anyDuplicated(resource_ids))
      phase0_assert_true(!anyDuplicated(outputs))
      phase0_assert_true(!anyDuplicated(tolower(outputs)))
      phase0_assert_true(length(rrp_software_resource_output_conflicts(outputs)) == 0L)
    },

    "required sources exist as regular non-linked files" = function() {
      phase0_assert_true(all(vapply(sources, function(path) {
        absolute <- file.path(repository_root, path)
        file.exists(absolute) && !isTRUE(file.info(absolute)$isdir) &&
          !rrp_software_resource_has_link(repository_root, path)
      }, logical(1L))))
    },

    "source and output paths are normalized and safe" = function() {
      phase0_assert_true(all(vapply(
        c(sources, outputs), rrp_software_resource_safe_path, logical(1L)
      )))
    },

    "accepted shipped classification is exact" = function() {
      expected <- rrp_expected_installed_resource_sources(repository_root)
      phase0_assert_true(length(sources) == 48L)
      phase0_assert_true(identical(sort(sources), sort(expected)))
      phase0_assert_true(length(catalog$excluded_resource_families) == 11L)
      phase0_assert_true(identical(
        sort(vapply(
          catalog$excluded_resource_families, `[[`, character(1L), "family_id"
        )),
        sort(rrp_expected_resource_exclusion_ids())
      ))
    },

    "roles owners formats and compatibility states are closed" = function() {
      allowed <- schema$resource_entry_contract
      phase0_assert_true(all(vapply(
        catalog$resources, `[[`, character(1L), "role"
      ) %in% rrp_software_resource_values(allowed$allowed_roles)))
      phase0_assert_true(all(vapply(
        catalog$resources, `[[`, character(1L), "owner"
      ) %in% rrp_software_resource_values(allowed$allowed_owners)))
      phase0_assert_true(all(vapply(
        catalog$resources, `[[`, character(1L), "format"
      ) %in% rrp_software_resource_values(allowed$allowed_formats)))
      phase0_assert_true(all(vapply(catalog$resources, function(entry) {
        entry$compatibility$status %in%
          rrp_software_resource_values(allowed$compatibility_status_values)
      }, logical(1L))))
    },

    "daily hazard and synthetic resources are explicitly limited" = function() {
      hazard <- vapply(catalog$resources, function(entry) {
        identical(entry$compatibility$status, "transitional_daily_hazard")
      }, logical(1L))
      fictional <- vapply(catalog$resources, function(entry) {
        identical(entry$compatibility$status, "fictional_nonclinical")
      }, logical(1L))
      phase0_assert_true(sum(hazard) >= 4L)
      phase0_assert_true(sum(fictional) == 6L)
      phase0_assert_true(all(grepl(
        "hazard|Stage 5|Stage 7|product-only|cumulative-risk",
        vapply(catalog$resources[hazard], function(entry) {
          entry$compatibility$note
        }, character(1L))
      )))
    },

    "missing required entry field fails closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$owner <- NULL
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "missing_required_field"
      )
    },

    "catalog and schema identity tampering fail closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$catalog_version <- "9.9.9"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "invalid_catalog_identity"
      )
      candidate <- software_resource_copy(documents)
      candidate$schema$specification_version <- "9.9.9"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "invalid_schema_identity"
      )
    },

    "duplicate identity and output mappings fail closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[2L]]$resource_id <-
        candidate$catalog$resources[[1L]]$resource_id
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "duplicate_resource_id"
      )
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[2L]]$output_path <-
        candidate$catalog$resources[[1L]]$output_path
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "duplicate_output_path"
      )
    },

    "output file and directory conflicts fail closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[2L]]$output_path <- paste0(
        candidate$catalog$resources[[1L]]$output_path, "/child.yml"
      )
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "output_file_directory_conflict"
      )
    },

    "absolute traversal and backslash paths fail closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$source_path <- "/tmp/resource.yml"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "unsafe_source_path"
      )
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$output_path <- "../escape.yml"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "unsafe_output_path"
      )
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$output_path <- "resources\\escape.yml"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "unsafe_output_path"
      )
    },

    "missing required source fails closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$source_path <-
        "contracts/foundation/not-present.yml"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "missing_required_source"
      )
    },

    "linked source fails closed" = function() {
      fixture_root <- software_resource_fixture_root(repository_root, catalog)
      on.exit(unlink(fixture_root, recursive = TRUE, force = TRUE), add = TRUE)
      linked_path <- file.path(fixture_root, sources[[1L]])
      unlink(linked_path)
      linked <- file.symlink(
        file.path(fixture_root, sources[[2L]]), linked_path
      )
      phase0_assert_true(linked, "Could not create linked-source fixture.")
      phase0_assert_issue(
        software_resource_validate(documents, fixture_root), "linked_source"
      )
    },

    "forbidden repository-only source fails closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$source_path <-
        "config/platform-instance.yml"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "forbidden_resource_class"
      )
    },

    "unknown role and malformed owner fail closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$role <- "unbounded_resource"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "invalid_resource_role"
      )
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$owner <- "anyone"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "invalid_resource_owner"
      )
    },

    "invalid compatibility metadata fails closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$compatibility$status <- "future"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "invalid_compatibility_status"
      )
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$compatibility$note <- ""
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "invalid_compatibility_note"
      )
    },

    "unknown catalog fields fail closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources[[1L]]$command <- "run-me"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root), "unknown_field"
      )
    },

    "incomplete shipped or excluded classification fails closed" = function() {
      candidate <- software_resource_copy(documents)
      candidate$catalog$resources <- candidate$catalog$resources[-1L]
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "classification_incomplete"
      )
      candidate <- software_resource_copy(documents)
      candidate$catalog$excluded_resource_families <-
        candidate$catalog$excluded_resource_families[-1L]
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "exclusion_classification_incomplete"
      )
    },

    "project template remains explicitly deferred" = function() {
      phase0_assert_true(identical(
        catalog$deferred_resource_roles[[1L]]$role_id,
        "rrp.deferred.project-template"
      ))
      candidate <- software_resource_copy(documents)
      candidate$catalog$deferred_resource_roles[[1L]]$planned_stage <- "stage_2"
      phase0_assert_issue(
        software_resource_validate(candidate, repository_root),
        "invalid_deferred_project_template"
      )
    }
  )
}
