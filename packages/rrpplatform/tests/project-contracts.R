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
validate_manifest <- rrp_test_internal("rrp_project_validate_manifest")
validate_registration <- rrp_test_internal("rrp_project_validate_registration")

rrp_test_manifest <- function() {
  c(
    "Record-Type" = "rrp-project",
    "Project-Contract-ID" = "rrp.project",
    "Project-Contract-Version" = "0.1.0",
    "Project-ID" = "fictional-health-system",
    "Project-Version" = "1.2.3-alpha.1",
    "Project-Scope" = "one_health_system",
    "Supported-RRP-API-Version" = "0.1.0",
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

rrp_test_component <- function(id, version = "1.0.0", callable = function() NULL) {
  list(
    component_id = id,
    component_version = version,
    callable = callable
  )
}

rrp_test_registration <- function(
  producers = list(rrp_test_component("fictional.producer")),
  providers = list(rrp_test_component("fictional.provider"))
) {
  list(
    registration_contract_id = "rrp.project-registration",
    registration_contract_version = "0.1.0",
    project_id = "fictional-health-system",
    producers = producers,
    providers = providers
  )
}

rrp_test_expect_error <- function(callback) {
  condition <- tryCatch({
    callback()
    NULL
  }, error = identity)
  stopifnot(
    !is.null(condition),
    is.character(condition$message),
    length(condition$message) == 1L,
    nzchar(condition$message),
    !grepl("[\r\n]", condition$message)
  )
  invisible(condition)
}

rrp_test_cases <- list(
  "exact project manifest parses to canonical field order" = function() {
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
    unknown <- c(rrp_test_manifest(), "Unknown-Field" = "not-allowed")
    rrp_test_expect_error(function() {
      validate_manifest(rrp_test_manifest_lines(missing), manifest_contract)
    })
    rrp_test_expect_error(function() {
      validate_manifest(rrp_test_manifest_lines(unknown), manifest_contract)
    })
    rrp_test_expect_error(function() {
      validate_manifest(c(valid, "Project-ID: duplicate"), manifest_contract)
    })
    rrp_test_expect_error(function() {
      validate_manifest("not a DCF field", manifest_contract)
    })
    rrp_test_expect_error(function() {
      validate_manifest(c(valid, "", valid), manifest_contract)
    })
    rrp_test_expect_error(function() {
      validate_manifest(c(valid, " continuation"), manifest_contract)
    })
  },
  "manifest fixed identity and compatibility values are exact" = function() {
    changes <- list(
      "Record-Type" = "other-project",
      "Project-Contract-ID" = "other.project",
      "Project-Contract-Version" = "9.9.9",
      "Project-Scope" = "multiple_health_systems",
      "Supported-RRP-API-Version" = "9.9.9"
    )
    for (field in names(changes)) {
      candidate <- rrp_test_manifest()
      candidate[[field]] <- changes[[field]]
      rrp_test_expect_error(function() {
        validate_manifest(rrp_test_manifest_lines(candidate), manifest_contract)
      })
    }
  },
  "project and component identity rules are enforced" = function() {
    cases <- list(
      c("Project-ID", "9invalid"),
      c("Project-ID", "rrp.protected"),
      c("Project-ID", paste0("a", strrep("b", 96L))),
      c("Project-ID", "patient-123"),
      c("Producer-ID", "Bad_ID"),
      c("Provider-ID", "provider@invalid")
    )
    for (item in cases) {
      candidate <- rrp_test_manifest()
      candidate[[item[[1L]]]] <- item[[2L]]
      rrp_test_expect_error(function() {
        validate_manifest(rrp_test_manifest_lines(candidate), manifest_contract)
      })
    }
    installed_selection <- rrp_test_manifest()
    installed_selection[["Producer-ID"]] <- "rrp.producer"
    installed_selection[["Provider-ID"]] <- "rrp.provider"
    parsed <- validate_manifest(
      rrp_test_manifest_lines(installed_selection), manifest_contract
    )
    stopifnot(
      identical(parsed[["Producer-ID"]], "rrp.producer"),
      identical(parsed[["Provider-ID"]], "rrp.provider")
    )
  },
  "project and component versions use the accepted bounded grammar" = function() {
    cases <- list(
      c("Project-Version", "1.0"),
      c("Project-Version", paste0("1.0.0-", strrep("a", 59L))),
      c("Producer-Version", "v1.0.0"),
      c("Provider-Version", "1.0.0+build")
    )
    for (item in cases) {
      candidate <- rrp_test_manifest()
      candidate[[item[[1L]]]] <- item[[2L]]
      rrp_test_expect_error(function() {
        validate_manifest(rrp_test_manifest_lines(candidate), manifest_contract)
      })
    }
  },
  "project-relative path syntax is strict" = function() {
    unsafe <- c(
      "/absolute", "C:/drive", "~/home", ".", "..", "a/./b",
      "a/../b", "a//b", "a\\b", paste0("a/", "\t", "b")
    )
    for (path in unsafe) {
      candidate <- rrp_test_manifest()
      candidate[["Extension-Library-Path"]] <- path
      rrp_test_expect_error(function() {
        validate_manifest(rrp_test_manifest_lines(candidate), manifest_contract)
      })
    }
  },
  "project-relative paths cannot overlap or conflict" = function() {
    path_pairs <- list(
      c("state", "state"),
      c("state", "state/history"),
      c("State", "state/history"),
      c("rrp-project.dcf", "state"),
      c("R", "state"),
      c("R/register.R/child", "state")
    )
    for (paths in path_pairs) {
      candidate <- rrp_test_manifest()
      candidate[["Extension-Library-Path"]] <- paths[[1L]]
      candidate[["State-Path"]] <- paths[[2L]]
      rrp_test_expect_error(function() {
        validate_manifest(rrp_test_manifest_lines(candidate), manifest_contract)
      })
    }
  },
  "obvious secret connection remote and executable content is rejected" = function() {
    unsafe <- c(
      "credentials/store", "host=db;uid=user", "https://example.invalid/code",
      paste("-----BEGIN", "PRIVATE", "KEY-----"), "system(id)"
    )
    for (path in unsafe) {
      candidate <- rrp_test_manifest()
      candidate[["Extension-Library-Path"]] <- path
      rrp_test_expect_error(function() {
        validate_manifest(rrp_test_manifest_lines(candidate), manifest_contract)
      })
    }
  },
  "registration accepts empty one-entry and multiple-entry collections" = function() {
    empty <- validate_registration(
      rrp_test_registration(list(), list()), registration_contract
    )
    one <- validate_registration(rrp_test_registration(), registration_contract)
    multiple <- validate_registration(rrp_test_registration(
      list(
        rrp_test_component("fictional.producer", "1.0.0"),
        rrp_test_component("alternate.producer", "2.0.0")
      ),
      list(
        rrp_test_component("fictional.provider", "1.0.0"),
        rrp_test_component("alternate.provider", "2.0.0")
      )
    ), registration_contract)
    stopifnot(
      identical(empty$producers, list()),
      identical(empty$providers, list()),
      length(one$producers) == 1L,
      length(one$providers) == 1L,
      length(multiple$producers) == 2L,
      length(multiple$providers) == 2L,
      all(vapply(multiple$producers, function(entry) {
        is.function(entry$callable)
      }, logical(1L)))
    )
  },
  "registration result identity and closed fields are enforced" = function() {
    wrong_id <- rrp_test_registration()
    wrong_id$registration_contract_id <- "other.registration"
    wrong_version <- rrp_test_registration()
    wrong_version$registration_contract_version <- "9.9.9"
    missing <- rrp_test_registration()
    missing$providers <- NULL
    extra <- c(rrp_test_registration(), list(extra = "not-allowed"))
    bad_project <- rrp_test_registration()
    bad_project$project_id <- "rrp.protected"
    for (candidate in list(
      wrong_id, wrong_version, missing, extra, bad_project
    )) {
      rrp_test_expect_error(function() {
        validate_registration(candidate, registration_contract)
      })
    }
  },
  "registration collections and component records are closed" = function() {
    named_collection <- rrp_test_registration(
      producers = list(named = rrp_test_component("fictional.producer"))
    )
    missing <- rrp_test_component("fictional.producer")
    missing$callable <- NULL
    extra <- c(
      rrp_test_component("fictional.producer"), list(extra = "not-allowed")
    )
    for (candidate in list(
      named_collection,
      rrp_test_registration(producers = list(missing)),
      rrp_test_registration(producers = list(extra)),
      rrp_test_registration(producers = "not-a-list")
    )) {
      rrp_test_expect_error(function() {
        validate_registration(candidate, registration_contract)
      })
    }
  },
  "registration component identity version callable and duplicates are strict" = function() {
    invalid_entries <- list(
      rrp_test_component("Bad_ID"),
      rrp_test_component("rrp.protected"),
      rrp_test_component("fictional.producer", "v1.0.0"),
      rrp_test_component("fictional.producer", callable = "function-name")
    )
    for (entry in invalid_entries) {
      rrp_test_expect_error(function() {
        validate_registration(
          rrp_test_registration(producers = list(entry)), registration_contract
        )
      })
    }
    duplicate <- list(
      rrp_test_component("fictional.producer", "1.0.0"),
      rrp_test_component("fictional.producer", "1.0.0")
    )
    rrp_test_expect_error(function() {
      validate_registration(
        rrp_test_registration(producers = duplicate), registration_contract
      )
    })
  },
  "contract validation never invokes component callables" = function() {
    evidence <- new.env(parent = emptyenv())
    evidence$calls <- 0L
    callable <- function() evidence$calls <- evidence$calls + 1L
    result <- validate_registration(rrp_test_registration(
      producers = list(rrp_test_component("fictional.producer", callable = callable)),
      providers = list(rrp_test_component("fictional.provider", callable = callable))
    ), registration_contract)
    stopifnot(
      identical(evidence$calls, 0L),
      is.function(result$producers[[1L]]$callable),
      is.function(result$providers[[1L]]$callable)
    )
  },
  "project contract helpers remain internal after the 4.D doctor" = function() {
    namespace <- asNamespace("rrpplatform")
    deferred <- "rrp_register_project"
    stopifnot(
      identical(sort(getNamespaceExports("rrpplatform")), c(
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
