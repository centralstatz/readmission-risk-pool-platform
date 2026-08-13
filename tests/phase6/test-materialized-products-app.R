phase62_history_helpers <- new.env(parent = environment())
sys.source(file.path(
  repository_root, "tests", "phase5", "test-operational-history.R"
), envir = phase62_history_helpers)

phase62_documents <- function(repository_root) {
  rrp_read_product_materialization_documents(repository_root)
}

phase62_assert_identical <- function(actual, expected) {
  phase0_assert_true(identical(actual, expected), paste0(
    "Expected identical values; actual: ", paste(actual, collapse = ", "),
    "; expected: ", paste(expected, collapse = ", ")
  ))
}

phase62_build <- function(
  repository_root,
  fixtures,
  generated_at = "2026-02-01T12:00:00Z",
  cutoff = "2026-01-31T23:59:59Z"
) {
  port <- phase62_history_helpers$phase5_port(repository_root)
  for (fixture in fixtures) phase62_history_helpers$phase5_append_fixture(port, fixture)
  run_ids <- sort(vapply(fixtures, function(value) {
    value$terminal$runtime_run_id
  }, character(1)), method = "radix")
  list(
    port = port,
    result = rrp_build_logical_product_set(
      port,
      run_ids,
      cutoff,
      generated_at,
      rrp_read_product_contracts(repository_root)
    )
  )
}

phase62_materialize <- function(repository_root, build, store, published_at = NULL) {
  arguments <- list(build$result, repository_root, store)
  if (!is.null(published_at)) arguments$published_at <- published_at
  do.call(rrp_materialize_reference_products, arguments)
}

phase62_test_cases <- function(repository_root) list(
  "materialization declaration is replaceable and complete" = function() {
    documents <- phase62_documents(repository_root)
    phase0_assert_true(nrow(rrp_validate_yaml_adapter_declarations(
      documents$contract, documents$adapter
    )) == 0L)
    phase62_assert_identical(
      documents$adapter$specification_id,
      "reference.yaml-product-bundle"
    )
    phase62_assert_identical(documents$adapter$format_reference$format_id,
      "yaml-product-bundle"
    )
    phase0_assert_true(all(unlist(documents$contract$required_methods) %in%
      unlist(documents$adapter$methods)
    ))
  },

  "complete YAML bundle round-trips through product access" = function() {
    fixture <- phase62_history_helpers$phase5_fixture(repository_root)
    build <- phase62_build(repository_root, list(fixture))
    store <- tempfile("rrp-product-store-")
    on.exit(unlink(store, recursive = TRUE, force = TRUE), add = TRUE)
    materialized <- phase62_materialize(repository_root, build, store)
    phase62_assert_identical(materialized$overall_status, "succeeded")
    opened <- rrp_open_reference_product_access(repository_root, store)
    phase62_assert_identical(opened$overall_status, "succeeded")
    logical <- new_logical_product_access(build$result)
    for (name in names(build$result$products)) {
      product <- build$result$products[[name]]
      reference <- product$product_specification
      from_memory <- logical$read_product(
        reference$specification_id,
        reference$specification_version,
        product$product_set_id
      )
      from_yaml <- opened$access$read_product(
        reference$specification_id,
        reference$specification_version,
        product$product_set_id
      )
      comparison <- all.equal(from_yaml, from_memory, check.attributes = TRUE)
      phase0_assert_true(isTRUE(comparison), paste(comparison, collapse = "; "))
    }
    phase0_assert_true(file.exists(file.path(store, "CURRENT.yml")))
    phase62_assert_identical(
      sort(list.files(materialized$bundle_path), method = "radix"),
      sort(c("PRODUCT_SET.yml", unname(rrp_yaml_bundle_member_files())), method = "radix")
    )
  },

  "replacement switches one current pointer and retains immutable prior bundle" = function() {
    first_fixture <- phase62_history_helpers$phase5_fixture(repository_root)
    first <- phase62_build(repository_root, list(first_fixture))
    second_result <- rrp_build_logical_product_set(
      first$port,
      first_fixture$terminal$runtime_run_id,
      "2026-01-31T23:59:59Z",
      "2026-02-02T12:00:00Z",
      rrp_read_product_contracts(repository_root)
    )
    second <- list(port = first$port, result = second_result)
    store <- tempfile("rrp-product-replacement-")
    on.exit(unlink(store, recursive = TRUE, force = TRUE), add = TRUE)
    one <- phase62_materialize(repository_root, first, store)
    two <- phase62_materialize(repository_root, second, store)
    phase0_assert_false(identical(one$materialization_id, two$materialization_id))
    phase62_assert_identical(
      first$result$product_set$product_set_id,
      second$result$product_set$product_set_id
    )
    phase0_assert_true(dir.exists(one$bundle_path))
    phase0_assert_true(dir.exists(two$bundle_path))
    phase62_assert_identical(length(list.files(file.path(store, "sets"))), 2L)
    opened <- rrp_open_reference_product_access(repository_root, store)
    phase62_assert_identical(
      opened$validation$manifest$product_set$product_set_id,
      second$result$product_set$product_set_id
    )
    phase0_assert_false(any(grepl("[.]staging-", list.files(
      file.path(store, "sets"), all.files = TRUE
    ))))
  },

  "corrupt and incompatible bundles fail in distinct categories" = function() {
    fixture <- phase62_history_helpers$phase5_fixture(repository_root)
    build <- phase62_build(repository_root, list(fixture))
    documents <- phase62_documents(repository_root)
    store <- tempfile("rrp-product-corrupt-")
    on.exit(unlink(store, recursive = TRUE, force = TRUE), add = TRUE)
    materialized <- phase62_materialize(repository_root, build, store)
    member <- file.path(materialized$bundle_path, "current-episode-risk.yml")
    write("tamper", member, append = TRUE)
    corrupt <- rrp_open_reference_product_access(repository_root, store)
    phase62_assert_identical(corrupt$overall_status, "failed")
    phase62_assert_identical(corrupt$failure_category, "integrity")

    store2 <- tempfile("rrp-product-incompatible-")
    on.exit(unlink(store2, recursive = TRUE, force = TRUE), add = TRUE)
    materialized2 <- phase62_materialize(repository_root, build, store2)
    pointer_path <- file.path(store2, "CURRENT.yml")
    pointer <- yaml::read_yaml(pointer_path)
    manifest_path <- file.path(materialized2$bundle_path, "PRODUCT_SET.yml")
    manifest <- yaml::read_yaml(manifest_path)
    manifest$format_reference$format_version <- "9.0.0"
    yaml::write_yaml(manifest, manifest_path)
    pointer$manifest_checksum$value <- rrp_yaml_bundle_checksum(manifest_path)
    yaml::write_yaml(pointer, pointer_path)
    incompatible <- rrp_open_reference_product_access(repository_root, store2)
    phase62_assert_identical(incompatible$overall_status, "failed")
    phase62_assert_identical(incompatible$failure_category, "compatibility")
    phase0_assert_true(is.null(incompatible$access))
    phase0_assert_true(nrow(incompatible$validation$issues) > 0L)
  },

  "old but valid bundle loads with facts and no invented stale threshold" = function() {
    fixture <- phase62_history_helpers$phase5_fixture(
      repository_root,
      as_of_time = "2026-01-10T12:00:00Z"
    )
    build <- phase62_build(
      repository_root,
      list(fixture),
      generated_at = "2026-01-11T12:00:00Z",
      cutoff = "2026-01-10T12:00:00Z"
    )
    store <- tempfile("rrp-product-stale-")
    on.exit(unlink(store, recursive = TRUE, force = TRUE), add = TRUE)
    phase62_materialize(
      repository_root, build, store, "2026-01-11T13:00:00Z"
    )
    opened <- rrp_open_reference_product_access(repository_root, store)
    phase62_assert_identical(opened$overall_status, "succeeded")
    phase62_assert_identical(
      opened$validation$categories$freshness,
      "pass"
    )
    phase62_assert_identical(
      opened$validation$freshness$staleness_assessment,
      "not_evaluated_no_platform_threshold"
    )
  },

  "app renders real empty state and safe access failure" = function() {
    failing <- phase62_history_helpers$phase5_runtime_helpers$phase42_registry(
      repository_root,
      adapter = function(...) stop("fictional failure")
    )
    fixture <- phase62_history_helpers$phase5_fixture(
      repository_root, registered = failing
    )
    build <- phase62_build(repository_root, list(fixture))
    initialized <- rrp_initialize_reference_app(new_logical_product_access(build$result))
    phase62_assert_identical(initialized$overall_status, "succeeded")
    phase62_assert_identical(
      nrow(rrp_app_current_risk_table(initialized$products$current_episode_risk)),
      0L
    )
    application <- rrp_create_reference_app(new_logical_product_access(build$result))
    phase0_assert_true(inherits(application, "shiny.appobj"))
    failed <- rrp_initialize_reference_app(list())
    phase62_assert_identical(failed$overall_status, "failed")
    phase62_assert_identical(failed$failure_category, "product_access")
    safe_app <- rrp_create_reference_app(list())
    phase0_assert_true(inherits(safe_app, "shiny.appobj"))
  },

  "irregular and same-day runs remain separate actual history points" = function() {
    fixtures <- list(
      phase62_history_helpers$phase5_fixture(
        repository_root,
        run_id = "fictional_irregular_001",
        as_of_time = "2026-01-10T08:00:00Z"
      ),
      phase62_history_helpers$phase5_fixture(
        repository_root,
        run_id = "fictional_irregular_002",
        as_of_time = "2026-01-13T08:00:00Z"
      ),
      phase62_history_helpers$phase5_fixture(
        repository_root,
        run_id = "fictional_irregular_003",
        as_of_time = "2026-01-13T16:00:00Z"
      )
    )
    build <- phase62_build(repository_root, fixtures)
    product <- build$result$products$episode_risk_history
    episode <- product$rows[[1L]]$episode_id
    table <- rrp_app_history_table(product, episode)
    phase62_assert_identical(nrow(table), 3L)
    phase62_assert_identical(length(unique(table$estimate_as_of_time)), 3L)
    dates <- substr(table$estimate_as_of_time, 1L, 10L)
    phase0_assert_true(any(table(dates) == 2L))
    phase0_assert_true(!"2026-01-11" %in% dates && !"2026-01-12" %in% dates)
  }
)

phase6_test_cases <- phase62_test_cases
