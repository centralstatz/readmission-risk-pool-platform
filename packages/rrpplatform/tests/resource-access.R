library(rrpplatform)

rrp_test_schema <- function() {
  get(
    "rrp_resource_schema_contract",
    envir = asNamespace("rrpplatform"), inherits = FALSE
  )()
}

rrp_test_header <- function() {
  list(
    "Record-Type" = "catalog",
    "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished"
  )
}

rrp_test_schema_entry <- function() {
  list(
    "Record-Type" = "resource",
    "Resource-ID" = "rrp.contract.resource-catalog",
    "Resource-Class" = "contract",
    "Owner-Package" = "rrpplatform",
    "Installed-Path" = "resources/resource-catalog-schema.dcf",
    "Format" = "dcf"
  )
}

rrp_test_write_records <- function(records, path) {
  lines <- unlist(lapply(seq_along(records), function(index) {
    record <- records[[index]]
    fields <- paste0(names(record), ": ", unlist(record, use.names = FALSE))
    if (index < length(records)) c(fields, "") else fields
  }), use.names = FALSE)
  writeLines(lines, path, useBytes = TRUE)
}

rrp_test_write_catalog <- function(root, records) {
  rrp_test_write_records(
    records, file.path(root, "resources", "resource-catalog.dcf")
  )
}

rrp_test_fixture <- function() {
  root <- tempfile("rrp-resource-access-")
  dir.create(file.path(root, "resources"), recursive = TRUE)
  schema <- rrp_test_schema()
  writeLines(
    paste0(names(schema), ": ", unname(schema)),
    file.path(root, "resources", "resource-catalog-schema.dcf"),
    useBytes = TRUE
  )
  rrp_test_write_catalog(
    root, list(rrp_test_header(), rrp_test_schema_entry())
  )
  root
}

rrp_test_with_fixture <- function(callback) {
  root <- rrp_test_fixture()
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  callback(root)
}

rrp_test_extra_entry <- function(id, path) {
  entry <- rrp_test_schema_entry()
  entry[["Resource-ID"]] <- id
  entry[["Installed-Path"]] <- path
  entry
}

rrp_test_expect_error <- function(callback, code, forbidden = character()) {
  condition <- tryCatch({
    callback()
    NULL
  }, error = identity)
  stopifnot(
    !is.null(condition),
    inherits(condition, "rrp_resource_error"),
    identical(condition$code, code),
    identical(names(condition), c("message", "call", "code")),
    is.character(condition$message),
    length(condition$message) == 1L,
    nzchar(condition$message),
    nchar(condition$message, type = "bytes") <= 160L,
    !grepl("[\r\n]", condition$message),
    !grepl("[/\\\\]", condition$message)
  )
  for (value in forbidden[nzchar(forbidden)]) {
    stopifnot(!grepl(value, condition$message, fixed = TRUE))
  }
  invisible(condition)
}

rrp_test_cases <- list(
  "open and resolve from an unrelated working directory" = function() {
    rrp_test_with_fixture(function(root) {
      unrelated <- tempfile("rrp-unrelated-working-directory-")
      dir.create(unrelated)
      on.exit(unlink(unrelated, recursive = TRUE, force = TRUE), add = TRUE)
      old <- setwd(unrelated)
      on.exit(setwd(old), add = TRUE)
      catalog <- rrp_open_resource_catalog(root)
      path <- rrp_resource_path(catalog, "rrp.contract.resource-catalog")
      stopifnot(
        identical(class(catalog), c("rrp_resource_catalog", "list")),
        identical(
          names(catalog),
          c("software_root", "catalog_path", "schema_path", "catalog")
        ),
        identical(
          catalog$software_root,
          normalizePath(root, winslash = "/", mustWork = TRUE)
        ),
        identical(names(catalog$catalog), c("header", "entries")),
        !"Source-Path" %in% names(catalog$catalog$entries[[1L]]),
        identical(
          path,
          normalizePath(
            file.path(root, "resources", "resource-catalog-schema.dcf"),
            winslash = "/", mustWork = TRUE
          )
        ),
        !dir.exists(file.path(root, ".git")),
        !dir.exists(file.path(unrelated, ".git"))
      )
    })
  },
  "invalid, missing, and linked roots fail safely" = function() {
    rrp_test_expect_error(
      function() rrp_open_resource_catalog(character()),
      "invalid_software_root"
    )
    absent <- tempfile("rrp-secret-absent-root-")
    rrp_test_expect_error(
      function() rrp_open_resource_catalog(absent),
      "missing_software_root", absent
    )
    rrp_test_with_fixture(function(root) {
      link <- tempfile("rrp-linked-root-")
      on.exit(unlink(link, recursive = TRUE, force = TRUE), add = TRUE)
      stopifnot(file.symlink(root, link))
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(link),
        "linked_software_root", link
      )
    })
  },
  "missing, linked, and malformed catalog fail safely" = function() {
    rrp_test_with_fixture(function(root) {
      unlink(file.path(root, "resources", "resource-catalog.dcf"))
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "missing_catalog"
      )
    })
    rrp_test_with_fixture(function(root) {
      path <- file.path(root, "resources", "resource-catalog.dcf")
      target <- file.path(root, "catalog-target.dcf")
      file.copy(path, target)
      unlink(path)
      stopifnot(file.symlink(target, path))
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "linked_catalog"
      )
    })
    rrp_test_with_fixture(function(root) {
      writeLines(
        "not a DCF record",
        file.path(root, "resources", "resource-catalog.dcf")
      )
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "malformed_catalog"
      )
    })
  },
  "missing, linked, and malformed schema fail safely" = function() {
    rrp_test_with_fixture(function(root) {
      unlink(file.path(root, "resources", "resource-catalog-schema.dcf"))
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "missing_schema"
      )
    })
    rrp_test_with_fixture(function(root) {
      path <- file.path(root, "resources", "resource-catalog-schema.dcf")
      target <- file.path(root, "schema-target.dcf")
      file.copy(path, target)
      unlink(path)
      stopifnot(file.symlink(target, path))
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "linked_schema"
      )
    })
    rrp_test_with_fixture(function(root) {
      writeLines(
        "not a DCF record",
        file.path(root, "resources", "resource-catalog-schema.dcf")
      )
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "malformed_schema"
      )
    })
  },
  "missing and unknown fields fail safely" = function() {
    rrp_test_with_fixture(function(root) {
      header <- rrp_test_header()
      header[["Status"]] <- NULL
      rrp_test_write_catalog(root, list(header, rrp_test_schema_entry()))
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "invalid_catalog_fields"
      )
    })
    rrp_test_with_fixture(function(root) {
      header <- rrp_test_header()
      header[["Source-Path"]] <- "repository-only"
      rrp_test_write_catalog(root, list(header, rrp_test_schema_entry()))
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "invalid_catalog_fields"
      )
    })
    rrp_test_with_fixture(function(root) {
      schema <- rrp_test_schema()
      schema <- schema[names(schema) != "Status-Values"]
      writeLines(
        paste0(names(schema), ": ", unname(schema)),
        file.path(root, "resources", "resource-catalog-schema.dcf")
      )
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "invalid_schema_fields"
      )
    })
  },
  "unsupported catalog and schema identities fail safely" = function() {
    rrp_test_with_fixture(function(root) {
      header <- rrp_test_header()
      header[["Catalog-Version"]] <- "9.9.9"
      rrp_test_write_catalog(root, list(header, rrp_test_schema_entry()))
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "unsupported_catalog"
      )
    })
    rrp_test_with_fixture(function(root) {
      schema <- rrp_test_schema()
      schema[["Schema-Version"]] <- "9.9.9"
      writeLines(
        paste0(names(schema), ": ", unname(schema)),
        file.path(root, "resources", "resource-catalog-schema.dcf")
      )
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "unsupported_schema"
      )
    })
  },
  "malformed and unknown logical IDs fail safely" = function() {
    rrp_test_with_fixture(function(root) {
      catalog <- rrp_open_resource_catalog(root)
      rrp_test_expect_error(
        function() rrp_resource_path(catalog, "../not-an-id"),
        "invalid_resource_id", "../not-an-id"
      )
      rrp_test_expect_error(
        function() rrp_resource_path(catalog, "rrp.contract.not-declared"),
        "unknown_resource_id", "rrp.contract.not-declared"
      )
    })
  },
  "missing, linked, and nonregular resources fail safely" = function() {
    rrp_test_with_fixture(function(root) {
      extra <- rrp_test_extra_entry(
        "rrp.contract.missing", "resources/missing.dcf"
      )
      rrp_test_write_catalog(
        root, list(rrp_test_header(), rrp_test_schema_entry(), extra)
      )
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "missing_resource"
      )
    })
    rrp_test_with_fixture(function(root) {
      extra <- rrp_test_extra_entry(
        "rrp.contract.linked", "resources/linked.dcf"
      )
      writeLines("resource", file.path(root, "linked-target.dcf"))
      stopifnot(file.symlink(
        file.path(root, "linked-target.dcf"),
        file.path(root, "resources", "linked.dcf")
      ))
      rrp_test_write_catalog(
        root, list(rrp_test_header(), rrp_test_schema_entry(), extra)
      )
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "linked_resource"
      )
    })
    rrp_test_with_fixture(function(root) {
      extra <- rrp_test_extra_entry(
        "rrp.contract.nonregular", "resources/nonregular.dcf"
      )
      dir.create(file.path(root, "resources", "nonregular.dcf"))
      rrp_test_write_catalog(
        root, list(rrp_test_header(), rrp_test_schema_entry(), extra)
      )
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "nonregular_resource"
      )
    })
  },
  "unsafe, case-conflicting, and file-directory paths fail safely" = function() {
    rrp_test_with_fixture(function(root) {
      entry <- rrp_test_schema_entry()
      entry[["Installed-Path"]] <- "resources/../escape.dcf"
      rrp_test_write_catalog(root, list(rrp_test_header(), entry))
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "unsafe_resource_path"
      )
    })
    rrp_test_with_fixture(function(root) {
      extra <- rrp_test_extra_entry(
        "rrp.contract.case-conflict",
        "resources/RESOURCE-CATALOG-SCHEMA.dcf"
      )
      rrp_test_write_catalog(
        root, list(rrp_test_header(), rrp_test_schema_entry(), extra)
      )
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root),
        "case_resource_path_collision"
      )
    })
    rrp_test_with_fixture(function(root) {
      extra <- rrp_test_extra_entry(
        "rrp.contract.path-conflict",
        "resources/resource-catalog-schema.dcf/child"
      )
      rrp_test_write_catalog(
        root, list(rrp_test_header(), rrp_test_schema_entry(), extra)
      )
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root), "resource_path_conflict"
      )
    })
  },
  "undeclared files fail closed inventory validation" = function() {
    rrp_test_with_fixture(function(root) {
      writeLines("undeclared", file.path(root, "resources", "undeclared.dcf"))
      rrp_test_expect_error(
        function() rrp_open_resource_catalog(root),
        "closed_inventory_mismatch"
      )
    })
  },
  "invalid or mutated catalog objects fail safely" = function() {
    rrp_test_expect_error(
      function() rrp_resource_path(list(), "rrp.contract.resource-catalog"),
      "invalid_catalog_object"
    )
    rrp_test_with_fixture(function(root) {
      catalog <- rrp_open_resource_catalog(root)
      catalog$catalog_path <- file.path(root, "different-catalog.dcf")
      rrp_test_expect_error(
        function() rrp_resource_path(
          catalog, "rrp.contract.resource-catalog"
        ), "catalog_root_mismatch"
      )
    })
    rrp_test_with_fixture(function(root) {
      catalog <- rrp_open_resource_catalog(root)
      entry <- rrp_test_schema_entry()
      entry <- entry[c(
        "Resource-ID", "Record-Type", "Resource-Class", "Owner-Package",
        "Installed-Path", "Format"
      )]
      rrp_test_write_catalog(root, list(rrp_test_header(), entry))
      rrp_test_expect_error(
        function() rrp_resource_path(
          catalog, "rrp.contract.resource-catalog"
        ), "catalog_changed"
      )
    })
  },
  "post-open resource and schema mutation fail closed" = function() {
    rrp_test_with_fixture(function(root) {
      extra <- rrp_test_extra_entry(
        "rrp.contract.mutable", "resources/mutable.dcf"
      )
      writeLines("resource", file.path(root, "resources", "mutable.dcf"))
      rrp_test_write_catalog(
        root, list(rrp_test_header(), rrp_test_schema_entry(), extra)
      )
      catalog <- rrp_open_resource_catalog(root)
      unlink(file.path(root, "resources", "mutable.dcf"))
      rrp_test_expect_error(
        function() rrp_resource_path(catalog, "rrp.contract.mutable"),
        "missing_resource"
      )
    })
    rrp_test_with_fixture(function(root) {
      extra <- rrp_test_extra_entry(
        "rrp.contract.mutable-link", "resources/mutable-link.dcf"
      )
      path <- file.path(root, "resources", "mutable-link.dcf")
      writeLines("resource", path)
      rrp_test_write_catalog(
        root, list(rrp_test_header(), rrp_test_schema_entry(), extra)
      )
      catalog <- rrp_open_resource_catalog(root)
      unlink(path)
      stopifnot(file.symlink(
        file.path(root, "resources", "resource-catalog-schema.dcf"), path
      ))
      rrp_test_expect_error(
        function() rrp_resource_path(catalog, "rrp.contract.mutable-link"),
        "linked_resource"
      )
    })
    rrp_test_with_fixture(function(root) {
      catalog <- rrp_open_resource_catalog(root)
      schema <- rrp_test_schema()
      schema[["Schema-Version"]] <- "9.9.9"
      writeLines(
        paste0(names(schema), ": ", unname(schema)),
        file.path(root, "resources", "resource-catalog-schema.dcf")
      )
      rrp_test_expect_error(
        function() rrp_resource_path(
          catalog, "rrp.contract.resource-catalog"
        ), "unsupported_schema"
      )
    })
  }
)

for (test_name in names(rrp_test_cases)) {
  rrp_test_cases[[test_name]]()
  cat("PASS resource access: ", test_name, "\n", sep = "")
}
