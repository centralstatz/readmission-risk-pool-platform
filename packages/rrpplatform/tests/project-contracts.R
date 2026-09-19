library(rrpplatform)

rrp_test_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

manifest_contract <- as.list(rrp_test_internal(
  "rrp_project_manifest_contract_expected"
)())
registration_contract <- as.list(rrp_test_internal(
  "rrp_project_registration_contract_expected"
)())
canonical_contracts <- lapply(
  rrp_test_internal("rrp_canonical_contract_definitions")(),
  function(definition) as.list(definition$expected)
)
runtime_contracts <- lapply(
  rrp_test_internal("rrp_runtime_contract_definitions")(),
  function(definition) as.list(definition$expected)
)
validate_manifest <- rrp_test_internal("rrp_project_validate_manifest")
validate_registration <- rrp_test_internal("rrp_project_validate_registration")

rrp_test_manifest <- function() {
  c(
    "Record-Type" = "rrp-project",
    "Project-Contract-ID" = "rrp.project",
    "Project-Contract-Version" = "0.3.0",
    "Project-ID" = "fictional-health-system",
    "Project-Version" = "1.2.3-alpha.1",
    "Project-Scope" = "one_health_system",
    "Supported-RRP-API-Version" = "0.3.0",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Producer-ID" = "fictional.producer",
    "Producer-Version" = "1.0.0",
    "Provider-ID" = "fictional.provider",
    "Provider-Version" = "2.0.0-local.1",
    "Extension-Library-Path" = "extensions/library",
    "State-Path" = "state"
  )
}

rrp_test_manifest_lines <- function(values = rrp_test_manifest()) {
  paste0(names(values), ": ", unname(values))
}

rrp_test_capabilities <- function() {
  list(
    list(
      capability_id = "rrp.capability.discharge-episode",
      status = "available"
    ),
    list(
      capability_id = "rrp.capability.terminal-event",
      status = "available"
    )
  )
}

rrp_test_producer <- function(
  id = "fictional.producer",
  version = "1.0.0",
  callable = function(request) NULL
) {
  list(
    component_id = id,
    component_version = version,
    producer_api_id = "rrp.producer-api",
    producer_api_version = "0.1.0",
    canonical_bundle_id = "rrp.canonical-bundle",
    canonical_bundle_version = "0.1.0",
    canonical_profile_id = "rrp.canonical-profile.readmission",
    canonical_profile_version = "0.1.0",
    implementation_id = sub("[.]producer$", ".implementation", id),
    implementation_version = version,
    mapping_id = sub("[.]producer$", ".mapping", id),
    mapping_version = version,
    capabilities = rrp_test_capabilities(),
    callable = callable
  )
}

rrp_test_provider <- function(
  id = "fictional.provider",
  version = "1.0.0",
  callable = function(request) NULL,
  model_id = NULL,
  model_version = NULL
) {
  list(
    component_id = id,
    component_version = version,
    provider_api_id = "rrp.provider-api",
    provider_api_version = "0.1.0",
    target_id = "rrp.risk-target.readmission-remaining-30-day",
    target_version = "0.1.0",
    state_contract_id = "rrp.episode-state",
    state_contract_version = "0.1.0",
    request_contract_id = "rrp.risk-request",
    request_contract_version = "0.1.0",
    estimate_contract_id = "rrp.risk-estimate",
    estimate_contract_version = "0.1.0",
    implementation_id = sub("[.]provider$", ".implementation", id),
    implementation_version = version,
    model_id = model_id,
    model_version = model_version,
    callable = callable
  )
}

rrp_test_registration <- function(
  producers = list(rrp_test_producer()),
  providers = list(rrp_test_provider())
) {
  list(
    registration_contract_id = "rrp.project-registration",
    registration_contract_version = "0.3.0",
    project_id = "fictional-health-system",
    producers = producers,
    providers = providers
  )
}

rrp_test_validate_registration <- function(candidate) {
  validate_registration(
    candidate, registration_contract, canonical_contracts, runtime_contracts,
    as.list(rrp_test_manifest())
  )
}

rrp_test_expect_error <- function(callback, code = NULL) {
  condition <- tryCatch({
    callback()
    NULL
  }, error = identity)
  stopifnot(
    !is.null(condition),
    inherits(condition, "rrp_project_error"),
    is.character(condition$message),
    length(condition$message) == 1L,
    nzchar(condition$message),
    !grepl("[\r\n]", condition$message),
    is.null(code) || identical(condition$code, code)
  )
  invisible(condition)
}

rrp_test_cases <- list(
  "exact 0.3.0 project manifest parses to canonical field order" = function() {
    parsed <- validate_manifest(rrp_test_manifest_lines(), manifest_contract)
    stopifnot(
      identical(names(parsed), names(rrp_test_manifest())),
      identical(unlist(parsed, use.names = TRUE), rrp_test_manifest())
    )
  },
  "manifest DCF is one strict closed record" = function() {
    valid <- rrp_test_manifest_lines()
    missing <- rrp_test_manifest()
    missing <- missing[names(missing) != "State-Path"]
    missing_profile_id <- rrp_test_manifest()
    missing_profile_id <- missing_profile_id[
      names(missing_profile_id) != "Canonical-Profile-ID"
    ]
    missing_profile_version <- rrp_test_manifest()
    missing_profile_version <- missing_profile_version[
      names(missing_profile_version) != "Canonical-Profile-Version"
    ]
    unknown <- c(rrp_test_manifest(), "Unknown-Field" = "not-allowed")
    candidates <- list(
      rrp_test_manifest_lines(missing),
      rrp_test_manifest_lines(missing_profile_id),
      rrp_test_manifest_lines(missing_profile_version),
      rrp_test_manifest_lines(unknown),
      c(valid, "Project-ID: duplicate"), "not a DCF field",
      c(valid, "", valid), c(valid, " continuation")
    )
    for (candidate in candidates) {
      rrp_test_expect_error(function() {
        validate_manifest(candidate, manifest_contract)
      })
    }
  },
  "manifest identity API and canonical profile values are exact" = function() {
    changes <- list(
      "Record-Type" = "other-project",
      "Project-Contract-ID" = "other.project",
      "Project-Contract-Version" = "0.2.0",
      "Project-Scope" = "multiple_health_systems",
      "Supported-RRP-API-Version" = "0.2.0",
      "Canonical-Profile-ID" = "other.profile",
      "Canonical-Profile-Version" = "9.9.9"
    )
    for (field in names(changes)) {
      candidate <- rrp_test_manifest()
      candidate[[field]] <- changes[[field]]
      rrp_test_expect_error(function() {
        validate_manifest(rrp_test_manifest_lines(candidate), manifest_contract)
      })
    }
  },
  "project identity version path and content rules remain strict" = function() {
    field_values <- list(
      c("Project-ID", "9invalid"), c("Project-ID", "rrp.protected"),
      c("Project-ID", paste0("a", strrep("b", 96L))),
      c("Project-ID", "patient-123"), c("Producer-ID", "Bad_ID"),
      c("Provider-ID", "provider@invalid"), c("Project-Version", "1.0"),
      c("Producer-Version", "v1.0.0"),
      c("Provider-Version", "1.0.0+build")
    )
    for (item in field_values) {
      candidate <- rrp_test_manifest()
      candidate[[item[[1L]]]] <- item[[2L]]
      rrp_test_expect_error(function() {
        validate_manifest(rrp_test_manifest_lines(candidate), manifest_contract)
      })
    }
    unsafe <- c(
      "/absolute", "C:/drive", "~/home", ".", "..", "a/./b",
      "a/../b", "a//b", "a\\b", "credentials/store",
      "host=db;uid=user", "https://example.invalid/code", "system(id)"
    )
    for (path in unsafe) {
      candidate <- rrp_test_manifest()
      candidate[["Extension-Library-Path"]] <- path
      rrp_test_expect_error(function() {
        validate_manifest(rrp_test_manifest_lines(candidate), manifest_contract)
      })
    }
    for (paths in list(
      c("state", "state"), c("state", "state/history"),
      c("State", "state/history"), c("rrp-project.dcf", "state"),
      c("R", "state"), c("R/register.R/child", "state")
    )) {
      candidate <- rrp_test_manifest()
      candidate[["Extension-Library-Path"]] <- paths[[1L]]
      candidate[["State-Path"]] <- paths[[2L]]
      rrp_test_expect_error(function() {
        validate_manifest(rrp_test_manifest_lines(candidate), manifest_contract)
      })
    }
  },
  "registration accepts closed kind-specific collections" = function() {
    empty <- rrp_test_validate_registration(rrp_test_registration(list(), list()))
    one <- rrp_test_validate_registration(rrp_test_registration())
    multiple <- rrp_test_validate_registration(rrp_test_registration(
      list(
        rrp_test_producer(),
        rrp_test_producer("alternate.producer", "2.0.0")
      ),
      list(
        rrp_test_provider(),
        rrp_test_provider("alternate.provider", "2.0.0")
      )
    ))
    stopifnot(
      identical(empty$producers, list()), identical(empty$providers, list()),
      length(one$producers) == 1L, length(one$providers) == 1L,
      identical(names(one$producers[[1L]]), c(
        "component_id", "component_version", "producer_api_id",
        "producer_api_version", "canonical_bundle_id",
        "canonical_bundle_version", "canonical_profile_id",
        "canonical_profile_version", "implementation_id",
        "implementation_version", "mapping_id", "mapping_version",
        "capabilities", "callable"
      )),
      identical(
        names(one$providers[[1L]]),
        c(
          "component_id", "component_version", "provider_api_id",
          "provider_api_version", "target_id", "target_version",
          "state_contract_id", "state_contract_version",
          "request_contract_id", "request_contract_version",
          "estimate_contract_id", "estimate_contract_version",
          "implementation_id", "implementation_version", "model_id",
          "model_version", "callable"
        )
      ),
      length(multiple$producers) == 2L,
      length(multiple$providers) == 2L,
      identical(multiple$producers[[1L]]$capabilities, rrp_test_capabilities())
    )
  },
  "registration result and provider records remain closed" = function() {
    wrong_id <- rrp_test_registration()
    wrong_id$registration_contract_id <- "other.registration"
    wrong_version <- rrp_test_registration()
    wrong_version$registration_contract_version <- "0.2.0"
    missing <- rrp_test_registration()
    missing$providers <- NULL
    extra <- c(rrp_test_registration(), list(extra = "not-allowed"))
    bad_project <- rrp_test_registration()
    bad_project$project_id <- "rrp.protected"
    named <- rrp_test_registration(providers = list(named = rrp_test_provider()))
    bad_provider <- c(rrp_test_provider(), list(extra = "not-allowed"))
    for (candidate in list(
      wrong_id, wrong_version, missing, extra, bad_project, named,
      rrp_test_registration(providers = list(bad_provider))
    )) {
      rrp_test_expect_error(function() rrp_test_validate_registration(candidate))
    }
  },
  "provider declarations enforce semantics and nullable model identity" = function() {
    valid_model <- rrp_test_provider(
      model_id = "fictional.model", model_version = "1.0.0"
    )
    validated <- rrp_test_validate_registration(rrp_test_registration(
      providers = list(valid_model)
    ))
    stopifnot(
      identical(validated$providers[[1L]]$model_id, "fictional.model"),
      identical(validated$providers[[1L]]$model_version, "1.0.0")
    )
    changes <- list(
      provider_api_id = "other.provider-api", target_version = "9.9.9",
      state_contract_id = "other.state", request_contract_version = "9.9.9",
      estimate_contract_id = "other.estimate",
      implementation_id = "rrp.protected", implementation_version = "v1",
      callable = function(...) NULL
    )
    for (field in names(changes)) {
      candidate <- rrp_test_provider()
      candidate[[field]] <- changes[[field]]
      rrp_test_expect_error(function() rrp_test_validate_registration(
        rrp_test_registration(providers = list(candidate))
      ))
    }
    for (candidate in list(
      rrp_test_provider(model_id = "fictional.model"),
      rrp_test_provider(model_version = "1.0.0")
    )) {
      rrp_test_expect_error(function() rrp_test_validate_registration(
        rrp_test_registration(providers = list(candidate))
      ), "invalid_provider_declaration")
    }
  },
  "producer declaration identity and semantic references fail closed" = function() {
    fields <- list(
      component_id = "Bad_ID", component_version = "v1.0.0",
      producer_api_id = "other.producer-api", producer_api_version = "9.9.9",
      canonical_bundle_id = "other.bundle", canonical_bundle_version = "9.9.9",
      canonical_profile_id = "other.profile",
      canonical_profile_version = "9.9.9",
      implementation_id = "rrp.protected", implementation_version = "v1.0.0",
      mapping_id = "Bad_ID", mapping_version = "v1.0.0",
      callable = "function-name"
    )
    for (field in names(fields)) {
      producer <- rrp_test_producer()
      producer[[field]] <- fields[[field]]
      rrp_test_expect_error(function() {
        rrp_test_validate_registration(
          rrp_test_registration(producers = list(producer))
        )
      })
    }
    missing <- rrp_test_producer()
    missing$mapping_id <- NULL
    extra <- c(rrp_test_producer(), list(extra = "not-allowed"))
    for (producer in list(missing, extra)) {
      rrp_test_expect_error(function() {
        rrp_test_validate_registration(
          rrp_test_registration(producers = list(producer))
        )
      }, "invalid_producer_declaration")
    }
  },
  "producer capabilities are exact available and unique" = function() {
    cases <- list(
      list(), list(rrp_test_capabilities()[[1L]]),
      c(rrp_test_capabilities(), rrp_test_capabilities()[1L]),
      list(
        rrp_test_capabilities()[[1L]],
        list(capability_id = "other.capability", status = "available")
      ),
      list(
        rrp_test_capabilities()[[1L]],
        list(
          capability_id = "rrp.capability.terminal-event",
          status = "unavailable"
        )
      )
    )
    for (capabilities in cases) {
      producer <- rrp_test_producer()
      producer$capabilities <- capabilities
      rrp_test_expect_error(function() {
        rrp_test_validate_registration(
          rrp_test_registration(producers = list(producer))
        )
      })
    }
  },
  "duplicate producer identity and version is prohibited" = function() {
    rrp_test_expect_error(function() {
      rrp_test_validate_registration(rrp_test_registration(producers = list(
        rrp_test_producer(), rrp_test_producer()
      )))
    }, "duplicate_registration")
  },
  "contract validation never invokes component callables" = function() {
    evidence <- new.env(parent = emptyenv())
    evidence$calls <- 0L
    producer_callable <- function(...) evidence$calls <- evidence$calls + 1L
    provider_callable <- function(request) evidence$calls <- evidence$calls + 1L
    result <- rrp_test_validate_registration(rrp_test_registration(
      producers = list(rrp_test_producer(callable = producer_callable)),
      providers = list(rrp_test_provider(callable = provider_callable))
    ))
    stopifnot(
      identical(evidence$calls, 0L),
      is.function(result$producers[[1L]]$callable),
      is.function(result$providers[[1L]]$callable)
    )
  },
  "contract validation exposes only the current public API" = function() {
    namespace <- asNamespace("rrpplatform")
    deferred <- "rrp_register_project"
    stopifnot(
      identical(sort(getNamespaceExports("rrpplatform")), c(
        "rrp_execute_producer", "rrp_execute_risk",
        "rrp_initialize_project", "rrp_load_project",
        "rrp_open_resource_catalog", "rrp_operation_succeeded",
        "rrp_resource_path", "rrp_validate_project",
        "rrp_validate_software_resources"
      )),
      !any(vapply(deferred, exists, logical(1L), envir = namespace,
                  inherits = FALSE))
    )
  }
)

for (test_name in names(rrp_test_cases)) {
  tryCatch(
    rrp_test_cases[[test_name]](),
    error = function(condition) stop(
      "project-contract test failed: ", test_name, ": ",
      conditionMessage(condition), call. = FALSE
    )
  )
}

cat("rrpplatform project-contract tests passed\n")
