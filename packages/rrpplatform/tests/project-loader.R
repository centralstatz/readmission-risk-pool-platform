library(rrpplatform)

rrp_loader_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

rrp_loader_write_records <- function(records, path) {
  lines <- unlist(lapply(seq_along(records), function(index) {
    record <- records[[index]]
    fields <- paste0(names(record), ": ", unlist(record, use.names = FALSE))
    if (index < length(records)) c(fields, "") else fields
  }), use.names = FALSE)
  writeLines(lines, path, useBytes = TRUE)
}

rrp_loader_resource_entry <- function(id, path, owner = "rrpplatform") {
  list(
    "Record-Type" = "resource",
    "Resource-ID" = id,
    "Resource-Class" = "contract",
    "Owner-Package" = owner,
    "Installed-Path" = path,
    "Format" = "dcf"
  )
}

rrp_loader_software_fixture <- function() {
  root <- tempfile("rrp-loader-software-")
  dir.create(file.path(root, "resources", "contracts"), recursive = TRUE)
  schema <- rrp_loader_internal("rrp_resource_schema_contract")()
  manifest_contract <- rrp_loader_internal(
    "rrp_project_manifest_contract_expected"
  )()
  registration_contract <- rrp_loader_internal(
    "rrp_project_registration_contract_expected"
  )()
  canonical_definitions <- rrp_loader_internal(
    "rrp_canonical_contract_definitions"
  )()
  runtime_definitions <- rrp_loader_internal(
    "rrp_runtime_contract_definitions"
  )()
  writeLines(
    paste0(names(schema), ": ", unname(schema)),
    file.path(root, "resources", "resource-catalog-schema.dcf"),
    useBytes = TRUE
  )
  for (definition in canonical_definitions) {
    path <- file.path(root, definition$path)
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
    writeLines(
      paste0(names(definition$expected), ": ", unname(definition$expected)),
      path, useBytes = TRUE
    )
  }
  for (definition in runtime_definitions) {
    path <- file.path(root, definition$path)
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
    writeLines(
      paste0(names(definition$expected), ": ", unname(definition$expected)),
      path, useBytes = TRUE
    )
  }
  writeLines(
    paste0(names(manifest_contract), ": ", unname(manifest_contract)),
    file.path(root, "resources", "contracts", "project-manifest.dcf"),
    useBytes = TRUE
  )
  writeLines(
    paste0(names(registration_contract), ": ", unname(registration_contract)),
    file.path(root, "resources", "contracts", "project-registration.dcf"),
    useBytes = TRUE
  )
  header <- list(
    "Record-Type" = "catalog",
    "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished"
  )
  records <- list(
    header,
    rrp_loader_resource_entry(
      "rrp.contract.resource-catalog",
      "resources/resource-catalog-schema.dcf"
    ),
    rrp_loader_resource_entry(
      "rrp.contract.project-manifest",
      "resources/contracts/project-manifest.dcf"
    ),
    rrp_loader_resource_entry(
      "rrp.contract.project-registration",
      "resources/contracts/project-registration.dcf"
    )
  )
  records <- c(records, lapply(canonical_definitions, function(definition) {
    rrp_loader_resource_entry(
      definition$resource_id, definition$path, definition$owner
    )
  }))
  records <- c(records, lapply(runtime_definitions, function(definition) {
    rrp_loader_resource_entry(
      definition$resource_id, definition$path, definition$owner
    )
  }))
  rrp_loader_write_records(
    records, file.path(root, "resources", "resource-catalog.dcf")
  )
  root
}

rrp_loader_manifest <- function() {
  c(
    "Record-Type" = "rrp-project",
    "Project-Contract-ID" = "rrp.project",
    "Project-Contract-Version" = "0.3.0",
    "Project-ID" = "fictional-health-system",
    "Project-Version" = "1.0.0",
    "Project-Scope" = "one_health_system",
    "Supported-RRP-API-Version" = "0.3.0",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Producer-ID" = "fictional.producer",
    "Producer-Version" = "1.0.0",
    "Provider-ID" = "fictional.provider",
    "Provider-Version" = "1.0.0",
    "Extension-Library-Path" = "extensions/library",
    "State-Path" = "state"
  )
}

rrp_loader_registration <- function(
  project_id = "fictional-health-system",
  contract_id = "rrp.project-registration",
  producer_entries = c(
    "component('zeta.producer', '2.0.0')",
    "component('fictional.producer', '1.0.0')"
  ),
  provider_entries = c(
    "component('zeta.provider', '2.0.0', 'provider')",
    "component('fictional.provider', '1.0.0', 'provider')"
  )
) {
  c(
    "rrp_register_project <- local({",
    "  calls <- 0L",
    "  function(project_root) {",
    "    calls <<- calls + 1L",
    "    component <- function(id, version, kind = 'producer') {",
    paste0(
      "      callable <- function(request) stop('selected callable executed', ",
      "call. = FALSE)"
    ),
    "      attr(callable, 'registration_calls') <- calls",
    "      if (identical(kind, 'provider')) return(list(component_id = id, component_version = version, provider_api_id = 'rrp.provider-api', provider_api_version = '0.1.0', target_id = 'rrp.risk-target.readmission-remaining-30-day', target_version = '0.1.0', state_contract_id = 'rrp.episode-state', state_contract_version = '0.1.0', request_contract_id = 'rrp.risk-request', request_contract_version = '0.1.0', estimate_contract_id = 'rrp.risk-estimate', estimate_contract_version = '0.1.0', implementation_id = paste0(sub('[.]provider$', '', id), '.implementation'), implementation_version = version, model_id = NULL, model_version = NULL, callable = callable))",
    "      prefix <- sub('[.]producer$', '', id)",
    "      list(component_id = id, component_version = version,",
    "           producer_api_id = 'rrp.producer-api', producer_api_version = '0.1.0',",
    "           canonical_bundle_id = 'rrp.canonical-bundle', canonical_bundle_version = '0.1.0',",
    "           canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0',",
    "           implementation_id = paste0(prefix, '.implementation'), implementation_version = version,",
    "           mapping_id = paste0(prefix, '.mapping'), mapping_version = version,",
    "           capabilities = list(list(capability_id = 'rrp.capability.discharge-episode', status = 'available'), list(capability_id = 'rrp.capability.terminal-event', status = 'available')),",
    "           callable = callable)",
    "    }",
    "    list(",
    paste0("      registration_contract_id = '", contract_id, "',"),
    "      registration_contract_version = '0.3.0',",
    paste0("      project_id = '", project_id, "',"),
    paste0("      producers = list(", paste(producer_entries, collapse = ", "), "),"),
    paste0("      providers = list(", paste(provider_entries, collapse = ", "), ")"),
    "    )",
    "  }",
    "})"
  )
}

rrp_loader_project_fixture <- function(
  manifest = rrp_loader_manifest(),
  registration = rrp_loader_registration()
) {
  root <- tempfile("rrp-loader-project-")
  dir.create(file.path(root, "R"), recursive = TRUE)
  writeLines(
    paste0(names(manifest), ": ", unname(manifest)),
    file.path(root, "rrp-project.dcf"), useBytes = TRUE
  )
  writeLines(registration, file.path(root, "R", "register.R"), useBytes = TRUE)
  root
}

rrp_loader_with_fixtures <- function(callback) {
  software_root <- rrp_loader_software_fixture()
  project_root <- rrp_loader_project_fixture()
  on.exit(unlink(software_root, recursive = TRUE, force = TRUE), add = TRUE)
  on.exit(unlink(project_root, recursive = TRUE, force = TRUE), add = TRUE)
  catalog <- rrp_open_resource_catalog(software_root)
  callback(catalog, project_root)
}

rrp_loader_expect_error <- function(callback, code, forbidden = character()) {
  condition <- tryCatch({
    callback()
    NULL
  }, error = identity)
  stopifnot(
    !is.null(condition),
    inherits(condition, "rrp_project_error"),
    identical(class(condition), c("rrp_project_error", "error", "condition")),
    identical(names(condition), c("message", "call", "code")),
    identical(condition$code, code),
    is.null(condition$call),
    is.character(condition$message),
    length(condition$message) == 1L,
    nzchar(condition$message),
    nchar(condition$message, type = "bytes") <= 160L,
    !grepl("[\r\n/\\\\]", condition$message)
  )
  for (value in forbidden[nzchar(forbidden)]) {
    stopifnot(!grepl(value, condition$message, fixed = TRUE))
  }
  invisible(condition)
}

rrp_loader_copy_project <- function(project_root) {
  parent <- tempfile("rrp-loader-copy-parent-")
  dir.create(parent)
  copied <- file.copy(project_root, parent, recursive = TRUE, copy.mode = FALSE)
  stopifnot(copied)
  file.path(parent, basename(project_root))
}

rrp_loader_install_fixture_package <- function(library_root, package_name) {
  source_root <- tempfile(paste0(package_name, "-source-"))
  dir.create(file.path(source_root, "R"), recursive = TRUE)
  writeLines(c(
    paste0("Package: ", package_name),
    "Type: Package",
    "Title: Temporary Project Extension Fixture",
    "Version: 0.1.0",
    "Authors@R: person('RRP', 'Fixture', email='fixture@example.invalid', role=c('aut','cre'))",
    "Description: Temporary package used only by project-loader tests.",
    "License: Apache License (>= 2)",
    "Encoding: UTF-8"
  ), file.path(source_root, "DESCRIPTION"))
  writeLines("export(fixture_callable)", file.path(source_root, "NAMESPACE"))
  writeLines(
    "fixture_callable <- function(...) stop('fixture callable executed', call. = FALSE)",
    file.path(source_root, "R", "fixture.R")
  )
  dir.create(library_root, recursive = TRUE, showWarnings = FALSE)
  output <- system2(
    file.path(R.home("bin"), "R"),
    c("CMD", "INSTALL", paste0("--library=", shQuote(library_root)),
      shQuote(source_root)),
    stdout = TRUE, stderr = TRUE
  )
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  stopifnot(identical(status, 0L))
  invisible(source_root)
}

rrp_loader_tests <- list(
  "explicit roots return one exact deterministic context" = function() {
    rrp_loader_with_fixtures(function(catalog, project_root) {
      unrelated <- tempfile("rrp-loader-unrelated-")
      dir.create(unrelated)
      on.exit(unlink(unrelated, recursive = TRUE, force = TRUE), add = TRUE)
      previous_directory <- getwd()
      previous_globals <- ls(.GlobalEnv, all.names = TRUE)
      setwd(unrelated)
      on.exit(setwd(previous_directory), add = TRUE)
      context <- rrp_load_project(catalog, project_root)
      stopifnot(
        identical(class(context), c("rrp_project_context", "list")),
        identical(names(context), c(
          "software_catalog", "project_root", "manifest", "registration",
          "canonical_profile", "producer", "provider",
          "extension_library_path", "state_path"
        )),
        identical(context$software_catalog, catalog),
        identical(
          context$project_root,
          normalizePath(project_root, winslash = "/", mustWork = TRUE)
        ),
        identical(context$manifest[["Project-ID"]], "fictional-health-system"),
        identical(
          vapply(context$registration$producers, `[[`, character(1L),
                 "component_id"),
          c("fictional.producer", "zeta.producer")
        ),
        identical(
          vapply(context$registration$providers, `[[`, character(1L),
                 "component_id"),
          c("fictional.provider", "zeta.provider")
        ),
        identical(names(context$producer), c(
          "component_id", "component_version", "producer_api_id",
          "producer_api_version", "canonical_bundle_id",
          "canonical_bundle_version", "canonical_profile_id",
          "canonical_profile_version", "implementation_id",
          "implementation_version", "mapping_id", "mapping_version",
          "capabilities", "callable", "origin"
        )),
        identical(context$canonical_profile, list(
          profile_id = "rrp.canonical-profile.readmission",
          profile_version = "0.1.0"
        )),
        identical(context$producer$origin, "project"),
        identical(context$provider$origin, "project"),
        identical(attr(context$producer$callable, "registration_calls"), 1L),
        identical(attr(context$provider$callable, "registration_calls"), 1L),
        !dir.exists(context$extension_library_path),
        !dir.exists(context$state_path),
        identical(getwd(), normalizePath(unrelated, winslash = "/")),
        identical(ls(.GlobalEnv, all.names = TRUE), previous_globals),
        !dir.exists(file.path(unrelated, ".git")),
        !dir.exists(file.path(project_root, ".git"))
      )
    })
  },

  "copied projects retain identity but derive new physical paths" = function() {
    rrp_loader_with_fixtures(function(catalog, project_root) {
      original <- rrp_load_project(catalog, project_root)
      copy_root <- rrp_loader_copy_project(project_root)
      on.exit(unlink(dirname(copy_root), recursive = TRUE, force = TRUE), add = TRUE)
      copied <- rrp_load_project(catalog, copy_root)
      project_files <- c("rrp-project.dcf", file.path("R", "register.R"))
      copied_text <- paste(unlist(lapply(
        file.path(copy_root, project_files), readLines, warn = FALSE
      ), use.names = FALSE), collapse = "\n")
      stopifnot(
        identical(copied$manifest, original$manifest),
        identical(copied$producer$component_id, original$producer$component_id),
        identical(copied$provider$component_id, original$provider$component_id),
        !identical(copied$project_root, original$project_root),
        !identical(copied$extension_library_path,
                   original$extension_library_path),
        !identical(copied$state_path, original$state_path),
        startsWith(copied$extension_library_path,
                   paste0(copied$project_root, "/")),
        startsWith(copied$state_path, paste0(copied$project_root, "/")),
        !grepl(original$project_root, copied_text, fixed = TRUE)
      )
    })
  },

  "registration source and entry point execute exactly once per load" = function() {
    rrp_loader_with_fixtures(function(catalog, project_root) {
      evaluation_marker <- tempfile("rrp-registration-evaluation-")
      on.exit(unlink(evaluation_marker), add = TRUE)
      writeLines(c(
        paste0(
          "cat('evaluated\\n', file = ",
          encodeString(evaluation_marker, quote = "\""),
          ", append = TRUE)"
        ),
        rrp_loader_registration()
      ), file.path(project_root, "R", "register.R"))
      context <- rrp_load_project(catalog, project_root)
      stopifnot(
        identical(readLines(evaluation_marker, warn = FALSE), "evaluated"),
        identical(attr(context$producer$callable, "registration_calls"), 1L),
        identical(attr(context$provider$callable, "registration_calls"), 1L)
      )
    })
  },

  "project root is explicit and never discovered" = function() {
    rrp_loader_with_fixtures(function(catalog, project_root) {
      child <- file.path(project_root, "nested")
      dir.create(child)
      old_option <- Sys.getenv("RRP_PROJECT_ROOT", unset = NA_character_)
      Sys.setenv(RRP_PROJECT_ROOT = project_root)
      on.exit({
        if (is.na(old_option)) Sys.unsetenv("RRP_PROJECT_ROOT") else
          Sys.setenv(RRP_PROJECT_ROOT = old_option)
      }, add = TRUE)
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, child),
        "missing_project_manifest", project_root
      )
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, tempfile("rrp-missing-root-")),
        "missing_project_root", project_root
      )
      root_file <- tempfile("rrp-root-file-")
      writeLines("not a project", root_file)
      on.exit(unlink(root_file), add = TRUE)
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, root_file),
        "non_directory_project_root", root_file
      )
      root_link <- tempfile("rrp-root-link-")
      on.exit(unlink(root_link), add = TRUE)
      stopifnot(file.symlink(project_root, root_link))
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, root_link),
        "linked_project_root", root_link
      )
    })
  },

  "declarative project failures occur before registration code" = function() {
    software_root <- rrp_loader_software_fixture()
    on.exit(unlink(software_root, recursive = TRUE, force = TRUE), add = TRUE)
    catalog <- rrp_open_resource_catalog(software_root)
    cases <- list(
      malformed_project_manifest = c("not a DCF record"),
      incompatible_project_api = {
        value <- rrp_loader_manifest()
        value[["Supported-RRP-API-Version"]] <- "9.9.9"
        paste0(names(value), ": ", unname(value))
      },
      unsafe_project_path = {
        value <- rrp_loader_manifest()
        value[["State-Path"]] <- "../outside"
        paste0(names(value), ": ", unname(value))
      }
    )
    for (code in names(cases)) {
      project_root <- rrp_loader_project_fixture()
      sentinel <- tempfile("rrp-registration-sentinel-")
      writeLines(c(
        paste0(
          "writeLines('executed', ",
          encodeString(sentinel, quote = "\""), ")"
        ),
        rrp_loader_registration()
      ), file.path(project_root, "R", "register.R"))
      writeLines(cases[[code]], file.path(project_root, "rrp-project.dcf"))
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, project_root), code,
        c(project_root, "sensitive-manifest-value")
      )
      stopifnot(!file.exists(sentinel))
      unlink(project_root, recursive = TRUE, force = TRUE)
      unlink(sentinel)
    }
  },

  "manifest and registration files must be ordinary fixed files" = function() {
    rrp_loader_with_fixtures(function(catalog, project_root) {
      unlink(file.path(project_root, "rrp-project.dcf"))
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, project_root),
        "missing_project_manifest"
      )
    })
    rrp_loader_with_fixtures(function(catalog, project_root) {
      manifest <- file.path(project_root, "rrp-project.dcf")
      target <- file.path(project_root, "manifest-target")
      file.copy(manifest, target)
      unlink(manifest)
      stopifnot(file.symlink(target, manifest))
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, project_root),
        "linked_project_manifest"
      )
    })
    rrp_loader_with_fixtures(function(catalog, project_root) {
      unlink(file.path(project_root, "R", "register.R"))
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, project_root),
        "missing_project_registration"
      )
    })
    rrp_loader_with_fixtures(function(catalog, project_root) {
      registration <- file.path(project_root, "R", "register.R")
      target <- file.path(project_root, "registration-target")
      file.copy(registration, target)
      unlink(registration)
      stopifnot(file.symlink(target, registration))
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, project_root),
        "linked_project_registration"
      )
    })
  },

  "registration evaluation and result fail closed" = function() {
    cases <- list(
      malformed_syntax = list("this is not R", "malformed_project_registration"),
      extra_binding = list(c("extra <- 1L", rrp_loader_registration()),
                           "malformed_project_registration"),
      missing_function = list("invisible(NULL)", "malformed_project_registration"),
      non_function = list("rrp_register_project <- 'not a function'",
                          "malformed_project_registration"),
      thrown_error = list(c(
        "rrp_register_project <- function(project_root) {",
        "  stop('secret registration detail', call. = FALSE)",
        "}"
      ), "invalid_registration_result"),
      wrong_contract = list(
        rrp_loader_registration(contract_id = "other.registration"),
        "invalid_registration_result"
      ),
      wrong_project = list(
        rrp_loader_registration(project_id = "different-project"),
        "project_identity_mismatch"
      ),
      protected = list(rrp_loader_registration(
        producer_entries = "component('rrp.producer', '1.0.0')"
      ), "protected_registration"),
      duplicate = list(rrp_loader_registration(
        producer_entries = rep("component('fictional.producer', '1.0.0')", 2L)
      ), "duplicate_registration"),
      non_callable = list(c(
        "rrp_register_project <- function(project_root) list(",
        "  registration_contract_id = 'rrp.project-registration',",
        "  registration_contract_version = '0.3.0',",
        "  project_id = 'fictional-health-system',",
        paste0(
          "  producers = list(list(component_id = 'fictional.producer', ",
          "component_version = '1.0.0', callable = 'named')),"
        ),
        paste0(
          "  providers = list(list(component_id = 'fictional.provider', ",
          "component_version = '1.0.0', callable = function(...) NULL))"
        ),
        ")"
      ), "invalid_producer_declaration")
    )
    for (case in cases) {
      rrp_loader_with_fixtures(function(catalog, project_root) {
        writeLines(case[[1L]], file.path(project_root, "R", "register.R"))
        rrp_loader_expect_error(
          function() rrp_load_project(catalog, project_root), case[[2L]],
          c(project_root, "secret registration detail")
        )
      })
    }
  },

  "selection is exact deterministic and has no fallback" = function() {
    rrp_loader_with_fixtures(function(catalog, project_root) {
      reversed <- rrp_loader_registration(
        producer_entries = c(
          "component('fictional.producer', '1.0.0')",
          "component('zeta.producer', '2.0.0')"
        ),
        provider_entries = c(
          "component('fictional.provider', '1.0.0', 'provider')",
          "component('zeta.provider', '2.0.0', 'provider')"
        )
      )
      writeLines(reversed, file.path(project_root, "R", "register.R"))
      context <- rrp_load_project(catalog, project_root)
      stopifnot(
        identical(context$producer$component_id, "fictional.producer"),
        identical(context$producer$component_version, "1.0.0"),
        identical(context$provider$component_id, "fictional.provider"),
        identical(context$provider$component_version, "1.0.0"),
        identical(attr(context$producer$callable, "registration_calls"), 1L),
        identical(attr(context$provider$callable, "registration_calls"), 1L)
      )
      manifest <- rrp_loader_manifest()
      manifest[["Producer-ID"]] <- "missing.producer"
      writeLines(
        paste0(names(manifest), ": ", unname(manifest)),
        file.path(project_root, "rrp-project.dcf")
      )
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, project_root),
        "unknown_producer_selection"
      )
      manifest[["Producer-ID"]] <- "fictional.producer"
      manifest[["Provider-ID"]] <- "missing.provider"
      writeLines(
        paste0(names(manifest), ": ", unname(manifest)),
        file.path(project_root, "rrp-project.dcf")
      )
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, project_root),
        "unknown_provider_selection"
      )
    })
  },

  "composition preserves origin and rejects collisions and ambiguity" = function() {
    compose <- rrp_loader_internal("rrp_project_compose_kind")
    resolve <- rrp_loader_internal("rrp_project_resolve_component")
    installed <- list(
      component_id = "rrp.producer",
      component_version = "1.0.0",
      callable = function(...) NULL
    )
    project <- list(
      component_id = "project.producer",
      component_version = "1.0.0",
      callable = function(...) NULL
    )
    combined <- compose(list(installed), list(project))
    stopifnot(
      identical(vapply(combined, `[[`, character(1L), "component_id"),
                c("project.producer", "rrp.producer")),
      identical(combined[[1L]]$origin, "project"),
      identical(combined[[2L]]$origin, "installed"),
      identical(
        resolve(combined, "rrp.producer", "1.0.0", "producer")$origin,
        "installed"
      )
    )
    rrp_loader_expect_error(
      function() compose(list(installed), list(installed)),
      "component_collision"
    )
    rrp_loader_expect_error(
      function() resolve(c(combined[1L], combined[1L]),
                         "project.producer", "1.0.0", "producer"),
      "ambiguous_producer_selection"
    )
  },

  "declared extension and state filesystem boundaries are structural" = function() {
    rrp_loader_with_fixtures(function(catalog, project_root) {
      dir.create(file.path(project_root, "extensions", "library"), recursive = TRUE)
      dir.create(file.path(project_root, "state"))
      context <- rrp_load_project(catalog, project_root)
      stopifnot(
        dir.exists(context$extension_library_path),
        dir.exists(context$state_path)
      )
    })
    for (field in c("Extension-Library-Path", "State-Path")) {
      rrp_loader_with_fixtures(function(catalog, project_root) {
        manifest <- rrp_loader_manifest()
        target <- file.path(project_root, manifest[[field]])
        dir.create(dirname(target), recursive = TRUE)
        writeLines("not a directory", target)
        code <- if (identical(field, "Extension-Library-Path")) {
          "invalid_extension_library"
        } else {
          "invalid_state_location"
        }
        rrp_loader_expect_error(
          function() rrp_load_project(catalog, project_root), code
        )
      })
    }
    for (item in list(
      c("extensions/library", "invalid_extension_library"),
      c("state", "invalid_state_location")
    )) {
      rrp_loader_with_fixtures(function(catalog, project_root) {
        outside <- tempfile("rrp-linked-project-path-target-")
        dir.create(outside)
        on.exit(unlink(outside, recursive = TRUE, force = TRUE), add = TRUE)
        linked_path <- file.path(project_root, item[[1L]])
        dir.create(dirname(linked_path), recursive = TRUE, showWarnings = FALSE)
        stopifnot(file.symlink(outside, linked_path))
        rrp_loader_expect_error(
          function() rrp_load_project(catalog, project_root), item[[2L]]
        )
      })
    }
    rrp_loader_with_fixtures(function(catalog, project_root) {
      dir.create(file.path(project_root, "State"))
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, project_root),
        "invalid_state_location"
      )
    })
  },

  "extension libraries cannot shadow RRP-owned packages" = function() {
    for (package_name in c("rrpplatform", "rrpruntime")) {
      rrp_loader_with_fixtures(function(catalog, project_root) {
        path <- file.path(project_root, "extensions", "library", package_name)
        dir.create(path, recursive = TRUE)
        rrp_loader_expect_error(
          function() rrp_load_project(catalog, project_root),
          "invalid_extension_library"
        )
      })
    }
    rrp_loader_with_fixtures(function(catalog, project_root) {
      path <- file.path(project_root, "extensions", "library", "renamed")
      dir.create(path, recursive = TRUE)
      writeLines(c(
        "Package: rrpplatform", "Version: 9.9.9"
      ), file.path(path, "DESCRIPTION"))
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, project_root),
        "invalid_extension_library"
      )
    })
  },

  "declared project packages resolve and ambient-only packages do not" = function() {
    rrp_loader_with_fixtures(function(catalog, project_root) {
      extension_library <- file.path(project_root, "extensions", "library")
      source_root <- rrp_loader_install_fixture_package(
        extension_library, "rrpfixtureextension"
      )
      on.exit(unlink(source_root, recursive = TRUE, force = TRUE), add = TRUE)
      registration <- c(
        "rrp_register_project <- function(project_root) {",
        "  callable <- getExportedValue('rrpfixtureextension', 'fixture_callable')",
        "  attr(callable, 'observed_libraries') <- .libPaths()",
        "  component <- function(id, kind) {",
        "    if (identical(kind, 'provider')) return(list(component_id = id, component_version = '1.0.0', provider_api_id = 'rrp.provider-api', provider_api_version = '0.1.0', target_id = 'rrp.risk-target.readmission-remaining-30-day', target_version = '0.1.0', state_contract_id = 'rrp.episode-state', state_contract_version = '0.1.0', request_contract_id = 'rrp.risk-request', request_contract_version = '0.1.0', estimate_contract_id = 'rrp.risk-estimate', estimate_contract_version = '0.1.0', implementation_id = 'fictional.implementation', implementation_version = '1.0.0', model_id = NULL, model_version = NULL, callable = function(request) callable(request)))",
        "    list(component_id = id, component_version = '1.0.0', producer_api_id = 'rrp.producer-api', producer_api_version = '0.1.0', canonical_bundle_id = 'rrp.canonical-bundle', canonical_bundle_version = '0.1.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', implementation_id = 'fictional.implementation', implementation_version = '1.0.0', mapping_id = 'fictional.mapping', mapping_version = '1.0.0', capabilities = list(list(capability_id = 'rrp.capability.discharge-episode', status = 'available'), list(capability_id = 'rrp.capability.terminal-event', status = 'available')), callable = callable)",
        "  }",
        "  list(registration_contract_id = 'rrp.project-registration',",
        "       registration_contract_version = '0.3.0',",
        "       project_id = 'fictional-health-system',",
        "       producers = list(component('fictional.producer', 'producer')),",
        "       providers = list(component('fictional.provider', 'provider')))",
        "}"
      )
      writeLines(registration, file.path(project_root, "R", "register.R"))
      previous <- .libPaths()
      context <- rrp_load_project(catalog, project_root)
      observed <- attr(context$producer$callable, "observed_libraries")
      rrp_libraries <- unique(dirname(normalizePath(c(
        find.package("rrpplatform"), find.package("rrpruntime")
      ), winslash = "/", mustWork = TRUE)))
      stopifnot(
        identical(.libPaths(), previous),
        is.function(context$producer$callable),
        identical(environmentName(environment(context$producer$callable)),
                  "rrpfixtureextension"),
        all(rrp_libraries %in% observed),
        normalizePath(extension_library, winslash = "/", mustWork = TRUE) %in%
          observed,
        max(match(rrp_libraries, observed)) <
          match(normalizePath(extension_library, winslash = "/",
                              mustWork = TRUE), observed)
      )
    })

    rrp_loader_with_fixtures(function(catalog, project_root) {
      ambient_library <- tempfile("rrp-ambient-library-")
      source_root <- rrp_loader_install_fixture_package(
        ambient_library, "rrpambientfixture"
      )
      on.exit(unlink(ambient_library, recursive = TRUE, force = TRUE), add = TRUE)
      on.exit(unlink(source_root, recursive = TRUE, force = TRUE), add = TRUE)
      registration <- c(
        "rrp_register_project <- function(project_root) {",
        "  callable <- getExportedValue('rrpambientfixture', 'fixture_callable')",
        "  component <- function(id, kind) {",
        "    if (identical(kind, 'provider')) return(list(component_id = id, component_version = '1.0.0', provider_api_id = 'rrp.provider-api', provider_api_version = '0.1.0', target_id = 'rrp.risk-target.readmission-remaining-30-day', target_version = '0.1.0', state_contract_id = 'rrp.episode-state', state_contract_version = '0.1.0', request_contract_id = 'rrp.risk-request', request_contract_version = '0.1.0', estimate_contract_id = 'rrp.risk-estimate', estimate_contract_version = '0.1.0', implementation_id = 'fictional.implementation', implementation_version = '1.0.0', model_id = NULL, model_version = NULL, callable = function(request) callable(request)))",
        "    list(component_id = id, component_version = '1.0.0', producer_api_id = 'rrp.producer-api', producer_api_version = '0.1.0', canonical_bundle_id = 'rrp.canonical-bundle', canonical_bundle_version = '0.1.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', implementation_id = 'fictional.implementation', implementation_version = '1.0.0', mapping_id = 'fictional.mapping', mapping_version = '1.0.0', capabilities = list(list(capability_id = 'rrp.capability.discharge-episode', status = 'available'), list(capability_id = 'rrp.capability.terminal-event', status = 'available')), callable = callable)",
        "  }",
        "  list(registration_contract_id = 'rrp.project-registration',",
        "       registration_contract_version = '0.3.0',",
        "       project_id = 'fictional-health-system',",
        "       producers = list(component('fictional.producer', 'producer')),",
        "       providers = list(component('fictional.provider', 'provider')))",
        "}"
      )
      writeLines(registration, file.path(project_root, "R", "register.R"))
      previous <- .libPaths()
      .libPaths(c(ambient_library, previous), include.site = FALSE)
      ambient_paths <- .libPaths()
      on.exit(.libPaths(previous, include.site = FALSE), add = TRUE)
      rrp_loader_expect_error(
        function() rrp_load_project(catalog, project_root),
        "invalid_registration_result", c(project_root, "rrpambientfixture")
      )
      stopifnot(identical(.libPaths(), ambient_paths))
    })
  },

  "software resources are revalidated before project code" = function() {
    rrp_loader_with_fixtures(function(catalog, project_root) {
      sentinel <- tempfile("rrp-software-revalidation-sentinel-")
      writeLines(c(
        paste0(
          "writeLines('executed', ",
          encodeString(sentinel, quote = "\""), ")"
        ),
        rrp_loader_registration()
      ), file.path(project_root, "R", "register.R"))
      unlink(file.path(
        catalog$software_root, "resources", "contracts", "project-manifest.dcf"
      ))
      condition <- tryCatch({
        rrp_load_project(catalog, project_root)
        NULL
      }, error = identity)
      stopifnot(
        inherits(condition, "rrp_resource_error"),
        !file.exists(sentinel)
      )
      unlink(sentinel)
    })
  },

  "project loading retains the current public API" = function() {
    stopifnot(
      identical(sort(getNamespaceExports("rrpplatform")), c(
        "rrp_execute_producer", "rrp_initialize_project", "rrp_load_project",
        "rrp_open_resource_catalog",
        "rrp_operation_succeeded", "rrp_resource_path",
        "rrp_validate_project",
        "rrp_validate_software_resources"
      ))
    )
  }
)

for (test_name in names(rrp_loader_tests)) {
  tryCatch(
    rrp_loader_tests[[test_name]](),
    error = function(condition) stop(
      "project-loader test failed: ", test_name, ": ",
      conditionMessage(condition), call. = FALSE
    )
  )
}

cat("rrpplatform project-loader tests passed\n")
