library(rrpplatform)

arguments <- commandArgs(trailingOnly = TRUE)
software_root <- if (length(arguments) >= 1L) arguments[[1L]] else
  Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
stopifnot(nzchar(software_root), dir.exists(software_root))
software_root <- normalizePath(software_root, winslash = "/", mustWork = TRUE)
catalog <- rrp_open_resource_catalog(software_root)

suite <- tempfile("rrp-lifecycle-operations-")
dir.create(suite)
on.exit(unlink(suite, recursive = TRUE, force = TRUE), add = TRUE)
unrelated <- file.path(suite, "unrelated")
dir.create(unrelated)
old <- setwd(unrelated)
on.exit(setwd(old), add = TRUE)
stopifnot(!dir.exists(".git"), !dir.exists(file.path(software_root, ".git")))

tree_evidence <- function(root) {
  files <- sort(list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = FALSE, include.dirs = FALSE
  ), method = "radix")
  if (!length(files)) return(list(files = files, md5 = character(), size = numeric()))
  paths <- file.path(root, files)
  list(
    files = files,
    md5 = unname(tools::md5sum(paths)),
    size = unname(file.info(paths, extra_cols = FALSE)$size)
  )
}

copy_project <- function(source, destination) {
  parent <- dirname(destination)
  dir.create(parent, recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(
    source, parent, recursive = TRUE, copy.mode = FALSE, copy.date = FALSE
  ))
  copied <- file.path(parent, basename(source))
  if (!identical(copied, destination)) stopifnot(file.rename(copied, destination))
  destination
}

project <- file.path(suite, "fictional")
stopifnot(rrp_operation_succeeded(
  rrp_initialize_fictional_project(catalog, project)
))

# A fresh valid project is diagnosable without mutation or component execution.
before_fresh <- tree_evidence(project)
fresh <- rrp_project_status(catalog, project)
after_fresh <- tree_evidence(project)
stopifnot(
  rrp_operation_succeeded(fresh),
  identical(fresh$operation_id, "rrp.project-status"),
  identical(fresh$value$readiness, "ready_with_warnings"),
  identical(fresh$value$state_status, "not_initialized"),
  identical(fresh$value$history_status, "not_initialized"),
  identical(fresh$value$product_status, "absent"),
  identical(fresh$value$product_freshness, "not_available"),
  identical(fresh$value$application_status, "blocked_expected"),
  identical(before_fresh, after_fresh),
  identical(names(fresh$value), strsplit(
    getFromNamespace(
      "rrp_project_lifecycle_result_contract_expected", "rrpplatform"
    )()[["Value-Fields"]], ",", fixed = TRUE
  )[[1L]])
)

private_pattern <- paste(c(
  "FIC STAY", "FIC PERSON", "FIC ENCOUNTER", "LOCAL_", "provider_signal",
  "identity-crosswalk", "source/generated", "credential", "connection",
  normalizePath(project, winslash = "/", mustWork = TRUE)
), collapse = "|")
stopifnot(!grepl(
  private_pattern, paste(capture.output(dput(fresh)), collapse = "\n"),
  ignore.case = TRUE
))

# Preparation uses the installed generator, is deterministic, and is guarded.
prepared <- rrp_prepare_fictional_source(catalog, project)
stopifnot(
  rrp_operation_succeeded(prepared),
  identical(prepared$value$project_id, "fictional-reference-hospital"),
  identical(prepared$value$classification, "fictional_nonclinical"),
  identical(prepared$value$reused, FALSE),
  identical(prepared$value$created_paths, c(
    "source/generated/events.csv",
    "source/generated/identity-crosswalk.csv",
    "source/generated/source.dcf",
    "source/generated/stays.csv"
  ))
)
first_source <- tree_evidence(file.path(project, "source", "generated"))
reused <- rrp_prepare_fictional_source(catalog, project)
stopifnot(
  rrp_operation_succeeded(reused), identical(reused$value$reused, TRUE),
  identical(first_source, tree_evidence(file.path(project, "source", "generated")))
)

ordinary <- file.path(suite, "ordinary")
stopifnot(rrp_operation_succeeded(rrp_initialize_project(
  catalog, ordinary, "ordinary-hospital", "1.0.0"
)))
refused <- rrp_prepare_fictional_source(catalog, ordinary)
stopifnot(
  !rrp_operation_succeeded(refused),
  identical(refused$diagnostics[[1L]]$code, "fictional_project_required"),
  !dir.exists(file.path(ordinary, "source"))
)

conflict_project <- file.path(suite, "fictional-conflict")
stopifnot(rrp_operation_succeeded(
  rrp_initialize_fictional_project(catalog, conflict_project)
))
stopifnot(rrp_operation_succeeded(
  rrp_prepare_fictional_source(catalog, conflict_project)
))
writeLines("changed", file.path(
  conflict_project, "source", "generated", "stays.csv"
), useBytes = TRUE)
conflict_before <- tree_evidence(conflict_project)
conflict <- rrp_prepare_fictional_source(catalog, conflict_project)
stopifnot(
  !rrp_operation_succeeded(conflict),
  identical(conflict$diagnostics[[1L]]$code, "fictional_source_conflict"),
  identical(conflict_before, tree_evidence(conflict_project))
)

# State without products is an expected warning state and remains read-only.
stopifnot(rrp_operation_succeeded(
  rrp_initialize_project_state(catalog, project)
))
before_state_status <- tree_evidence(project)
state_status <- rrp_project_status(catalog, project)
stopifnot(
  rrp_operation_succeeded(state_status),
  identical(state_status$value$state_status, "compatible"),
  identical(state_status$value$history_status, "compatible"),
  identical(state_status$value$product_status, "absent"),
  identical(before_state_status, tree_evidence(project))
)

first_time <- "2026-01-19T12:00:00Z"
second_time <- "2026-01-20T12:00:00Z"
first_run <- rrp_execute_durable_bundle(
  catalog, project, first_time, "lifecycle-first"
)
second_run <- rrp_execute_durable_bundle(
  catalog, project, second_time, "lifecycle-second"
)
stopifnot(
  rrp_operation_succeeded(first_run), rrp_operation_succeeded(second_run)
)

# The composed operation is equivalent to the accepted two-call path.
old_path <- copy_project(project, file.path(suite, "equivalence", "old"))
new_path <- copy_project(project, file.path(suite, "equivalence", "new"))
old_built <- rrp_build_product_set(
  catalog, old_path, first_run$value$operation_run_id, first_time
)
stopifnot(rrp_operation_succeeded(old_built))
old_published <- rrp_materialize_product_set(catalog, old_path, old_built$value)
new_published <- rrp_build_and_materialize_products(
  catalog, new_path, first_run$value$operation_run_id, first_time
)
stopifnot(
  rrp_operation_succeeded(old_published),
  rrp_operation_succeeded(new_published),
  identical(
    old_published$value$product_set_id, new_published$value$product_set_id
  ),
  identical(
    old_published$value$materialization_id,
    new_published$value$materialization_id
  ),
  identical(old_published$value$adapter_id, new_published$value$adapter_id),
  identical(
    old_published$value$physical_format_id,
    new_published$value$physical_format_id
  )
)

# A focused injected failure before publication changes neither products nor history.
failure_path <- copy_project(project, file.path(suite, "failure", "project"))
existing <- rrp_build_and_materialize_products(
  catalog, failure_path, first_run$value$operation_run_id, first_time
)
stopifnot(rrp_operation_succeeded(existing))
products_before <- tree_evidence(file.path(failure_path, "state", "products"))
history_before <- unname(tools::md5sum(file.path(
  failure_path, "state", "history.duckdb"
)))
internal_compose <- getFromNamespace("rrp_build_and_materialize", "rrpplatform")
failed <- tryCatch(
  internal_compose(
    catalog, failure_path, second_run$value$operation_run_id, second_time,
    failure_stage = "after_members"
  ),
  error = identity
)
stopifnot(
  inherits(failed, "rrp_materialization_error"),
  identical(products_before, tree_evidence(file.path(
    failure_path, "state", "products"
  ))),
  identical(history_before, unname(tools::md5sum(file.path(
    failure_path, "state", "history.duckdb"
  ))))
)

# Current products and optional freshness are reported without mutation.
before_product_status <- tree_evidence(new_path)
current <- rrp_project_status(catalog, new_path)
fresh_status <- rrp_project_status(
  catalog, new_path, first_run$value$operation_run_id, first_time
)
unpaired <- rrp_project_status(
  catalog, new_path, expected_operation_run_id = first_run$value$operation_run_id
)
stopifnot(
  rrp_operation_succeeded(current),
  identical(current$value$product_status, "valid"),
  identical(current$value$product_freshness, "not_evaluated"),
  identical(current$value$application_status, "ready"),
  rrp_operation_succeeded(fresh_status),
  identical(fresh_status$value$product_freshness, "fresh"),
  !rrp_operation_succeeded(unpaired),
  identical(before_product_status, tree_evidence(new_path))
)

status_text <- paste(capture.output(dput(fresh_status)), collapse = "\n")
stopifnot(
  !grepl(private_pattern, status_text, ignore.case = TRUE),
  !grepl("callable|environment|duckdb|[.]csv", status_text, ignore.case = TRUE)
)

# Exact authority closure is exercised in the installed package namespace.
contracts <- getFromNamespace("rrp_lifecycle_contracts", "rrpplatform")(catalog)
stopifnot(
  identical(names(contracts), c(
    "distribution", "dependencies", "installation", "activation",
    "installed_diagnosis", "project_lifecycle", "cli_json"
  )),
  identical(
    contracts$distribution[["Payload-Closure"]], "rrp_owned_members_only"
  ),
  identical(
    contracts$dependencies[["Bundled-Transitive-Artifacts"]], "not_required"
  ),
  identical(
    contracts$installation[["Project-Fields"]], "prohibited"
  ),
  identical(
    contracts$project_lifecycle[["Mutation-Or-Repair"]], "prohibited"
  ),
  identical(
    contracts$cli_json[["Internal-Object-Serialization"]], "prohibited"
  )
)

guide <- rrp_resource_path(
  catalog, "rrp.documentation.lifecycle-operations-reference"
)
guide_text <- paste(readLines(guide, warn = FALSE, encoding = "UTF-8"),
  collapse = "\n")
stopifnot(
  grepl("rrp_project_status", guide_text, fixed = TRUE),
  grepl("rrp_build_and_materialize_products", guide_text, fixed = TRUE),
  grepl("rrp_prepare_fictional_source", guide_text, fixed = TRUE),
  !grepl("devtools::|setwd\\s*\\(|:::", guide_text)
)
