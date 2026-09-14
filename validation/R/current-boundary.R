rrp_current_boundary_common_sources <- function() {
  file.path("operations", "lib", c(
    "validation-result.R",
    "documentation-validation.R",
    "repository-validation.R"
  ))
}

rrp_current_boundary_specification_sources <- function() {
  c(
    rrp_current_boundary_common_sources(),
    file.path("operations", "lib", c(
      "conformance-result.R",
      "specification-validation.R",
      "foundation-context-validation.R"
    ))
  )
}

rrp_current_boundary_canonical_sources <- function() {
  c(
    rrp_current_boundary_specification_sources(),
    file.path("operations", "lib", c(
      "canonical-bundle-validation.R",
      "canonical-clinical-validation.R",
      "canonical-specification-validation.R"
    ))
  )
}

rrp_current_boundary_synthetic_sources <- function() {
  c(
    rrp_current_boundary_canonical_sources(),
    file.path(
      "implementations", "synthetic-reference", "R",
      c(
        "identity-configuration.R", "generate-source.R", "source-validation.R",
        "map-to-canonical.R", "producer.R"
      )
    ),
    file.path("operations", "lib", "synthetic-reference-validation.R")
  )
}

rrp_current_boundary_definitions <- function() {
  specification <- rrp_current_boundary_specification_sources()
  canonical <- rrp_current_boundary_canonical_sources()
  synthetic <- rrp_current_boundary_synthetic_sources()
  product_runtime <- c(
    file.path("products", "R", c(
      "foundation.R", "conformance.R", "builders.R", "access.R"
    )),
    file.path("implementations", "products", "yaml", "R", c(
      "foundation.R", "validation.R", "adapter.R", "access.R"
    )),
    file.path("app", "R", c("app-init.R", "view-models.R", "app.R"))
  )

  list(
    "repository.specification-foundation" = list(
      sources = specification,
      function_name = "rrp_validate_specification_repository"
    ),
    "repository.canonical" = list(
      sources = canonical,
      function_name = "rrp_validate_canonical_specification_repository"
    ),
    "repository.synthetic-reference" = list(
      sources = synthetic,
      function_name = "rrp_validate_synthetic_reference_repository"
    ),
    "repository.runtime-provider" = list(
      sources = c(
        synthetic,
        file.path("operations", "lib", c(
          "runtime-operation.R", "provider-operation.R", "runtime-validation.R"
        ))
      ),
      function_name = "rrp_validate_runtime_repository"
    ),
    "repository.history-persistence" = list(
      sources = c(
        specification,
        file.path("operations", "lib", "history-validation.R")
      ),
      function_name = "rrp_validate_history_repository"
    ),
    "repository.products-application" = list(
      sources = c(
        specification,
        file.path("operations", "lib", c(
          "history-validation.R", "product-operation.R",
          "product-materialization-operation.R"
        )),
        product_runtime,
        file.path("operations", "lib", "product-validation.R")
      ),
      function_name = "rrp_validate_product_repository"
    ),
    "repository.operations" = list(
      sources = c(
        rrp_current_boundary_common_sources(),
        file.path("operations", "lib", c(
          "conformance-result.R", "specification-validation.R",
          "operator-validation.R"
        ))
      ),
      function_name = "rrp_validate_operator_repository"
    ),
    "repository.application-artifact" = list(
      sources = c(
        specification,
        file.path("operations", "lib", "application-artifact-operation.R"),
        file.path("deploy", "application-artifact", "R", "artifact-runtime.R"),
        file.path("operations", "lib", "application-artifact-validation.R")
      ),
      function_name = "rrp_validate_application_artifact_repository"
    ),
    "repository.connect-cloud" = list(
      sources = c(
        specification,
        file.path("operations", "lib", "application-artifact-operation.R"),
        file.path("deploy", "application-artifact", "R", "artifact-runtime.R"),
        file.path("operations", "lib", "connect-cloud-operation.R"),
        file.path("deploy", "connect-cloud", "R", "realization-runtime.R"),
        file.path("operations", "lib", "connect-cloud-validation.R")
      ),
      function_name = "rrp_validate_connect_cloud_repository"
    ),
    "repository.observability" = list(
      sources = c(
        rrp_current_boundary_common_sources(),
        file.path("operations", "lib", "observability-validation.R")
      ),
      function_name = "rrp_validate_observability_repository"
    ),
    "repository.canonical-producer" = list(
      sources = c(
        canonical,
        file.path("operations", "lib", "canonical-producer-operation.R"),
        file.path(
          "implementations", "synthetic-reference", "R",
          c(
            "identity-configuration.R", "generate-source.R", "source-validation.R",
            "map-to-canonical.R", "producer.R"
          )
        ),
        file.path("operations", "compositions", "installed-producers.R"),
        file.path("operations", "lib", "canonical-producer-validation.R")
      ),
      function_name = "rrp_validate_canonical_producer_repository"
    ),
    "repository.hospital-distribution" = list(
      sources = c(
        specification,
        file.path("operations", "lib", "hospital-distribution-operation.R"),
        file.path("distribution", "hospital", "R", c(
          "distribution-runtime.R", "git-realization-runtime.R"
        )),
        file.path("operations", "lib", "hospital-distribution-validation.R")
      ),
      function_name = "rrp_validate_hospital_distribution_repository"
    )
  )
}

rrp_current_boundary_ids <- function() names(rrp_current_boundary_definitions())

rrp_current_boundary_definition <- function(validator_id) {
  definition <- rrp_current_boundary_definitions()[[validator_id]]
  if (is.null(definition)) stop(
    "Current-boundary validator is not allowlisted: ", validator_id,
    call. = FALSE
  )
  definition
}

rrp_load_current_boundary <- function(repository_root, validator_id, envir) {
  definition <- rrp_current_boundary_definition(validator_id)
  sources <- unique(definition$sources)
  for (relative in sources) {
    path <- file.path(repository_root, relative)
    if (!file.exists(path) || dir.exists(path) || nzchar(Sys.readlink(path))) stop(
      "Allowlisted current-boundary source is unavailable or unsafe: ", relative,
      call. = FALSE
    )
    sys.source(path, envir = envir)
  }
  invisible(definition)
}

rrp_run_current_boundary <- function(repository_root, validator_id) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  environment <- new.env(parent = globalenv())
  definition <- rrp_load_current_boundary(
    repository_root,
    validator_id,
    environment
  )
  validator <- get(
    definition$function_name,
    envir = environment,
    inherits = FALSE
  )
  result <- validator(repository_root)
  if (!inherits(result, "rrp_validation_result") || !is.logical(result$passed) ||
      length(result$passed) != 1L) stop(
    "Allowlisted current-boundary validator returned an invalid result: ",
    validator_id,
    call. = FALSE
  )
  result
}
