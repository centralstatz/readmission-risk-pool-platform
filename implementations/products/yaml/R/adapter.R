# YAML reference materializer and physical realization of the logical access
# methods. The current pointer is the only mutable publication surface.

rrp_yaml_bundle_manifest <- function(build_result, declaration) {
  member_files <- rrp_yaml_bundle_member_files()
  adapter_reference <- list(
    adapter_id = declaration$adapter_id,
    adapter_version = declaration$adapter_version
  )
  list(
    manifest_kind = "product_bundle_manifest",
    manifest_version = "0.1.0",
    materialization_id = rrp_product_deterministic_id(
      "product_materialization",
      build_result$product_set$product_set_id,
      build_result$product_set$product_generated_at,
      declaration$adapter_id,
      declaration$adapter_version
    ),
    adapter_reference = adapter_reference,
    format_reference = rrp_yaml_bundle_format_reference(),
    product_set = rrp_product_copy(build_result$product_set),
    members = stats::setNames(lapply(names(member_files), function(name) {
      product <- build_result$products[[name]]
      list(
        file = unname(member_files[[name]]),
        product_specification = product$product_specification,
        product_instance_id = product$product_instance_id,
        row_count = product$row_count,
        checksum = NULL
      )
    }), names(member_files))
  )
}

rrp_materialize_yaml_product_set <- function(
  build_result,
  store_path,
  materialization_contract,
  adapter_declaration,
  product_contracts,
  published_at = rrp_yaml_bundle_now()
) {
  if (!inherits(build_result, "rrp_product_build_result") ||
      !identical(build_result$overall_status, "succeeded")) stop(
    "Materialization requires one successful complete logical product set.",
    call. = FALSE
  )
  declaration_issues <- rrp_validate_yaml_adapter_declarations(
    materialization_contract,
    adapter_declaration
  )
  if (nrow(declaration_issues) > 0L) stop(
    "YAML product adapter declaration is incompatible with its contract.",
    call. = FALSE
  )
  conformance <- lapply(names(build_result$products), function(name) {
    rrp_validate_logical_product(
      build_result$products[[name]], product_contracts[[name]]
    )
  })
  coherent <- rrp_validate_product_set_coherence(
    build_result$product_set,
    build_result$products,
    product_contracts$product_set
  )
  if (any(!vapply(c(conformance, list(coherent)), rrp_product_conforms, logical(1)))) {
    stop("Materialization rejected a nonconforming or incoherent logical product set.",
      call. = FALSE
    )
  }
  if (!rrp_product_timestamp(published_at) ||
      rrp_product_time_number(published_at) <
        rrp_product_time_number(build_result$product_set$product_generated_at)) stop(
    "Publication time must be valid and not precede product generation.",
    call. = FALSE
  )

  store_path <- normalizePath(store_path, mustWork = FALSE)
  if (file.exists(store_path) && !dir.exists(store_path)) stop(
    "Product store path exists and is not a directory.", call. = FALSE
  )
  dir.create(store_path, recursive = TRUE, showWarnings = FALSE)
  if (rrp_yaml_bundle_is_symlink(store_path)) stop(
    "Product store path must not be a symbolic link.", call. = FALSE
  )
  sets_path <- file.path(store_path, "sets")
  dir.create(sets_path, showWarnings = FALSE)
  staging_path <- tempfile(".staging-", tmpdir = sets_path)
  dir.create(staging_path, showWarnings = FALSE)
  if (!dir.exists(staging_path)) stop(
    "Could not create product bundle staging directory.", call. = FALSE
  )
  on.exit(if (dir.exists(staging_path)) unlink(
    staging_path, recursive = TRUE, force = TRUE
  ), add = TRUE)

  manifest <- rrp_yaml_bundle_manifest(build_result, adapter_declaration)
  member_files <- rrp_yaml_bundle_member_files()
  for (name in names(member_files)) {
    path <- file.path(staging_path, member_files[[name]])
    rrp_yaml_bundle_write(build_result$products[[name]], path)
    manifest$members[[name]]$checksum <- list(
      algorithm = "md5",
      value = rrp_yaml_bundle_checksum(path)
    )
  }
  manifest_path <- file.path(staging_path, "PRODUCT_SET.yml")
  rrp_yaml_bundle_write(manifest, manifest_path)
  final_name <- rrp_yaml_bundle_directory_name(
    build_result$product_set,
    adapter_declaration
  )
  final_path <- file.path(sets_path, final_name)
  if (dir.exists(final_path)) {
    staged_files <- sort(list.files(staging_path, full.names = FALSE), method = "radix")
    existing_files <- sort(list.files(final_path, full.names = FALSE), method = "radix")
    identical_content <- identical(staged_files, existing_files) && all(vapply(
      staged_files,
      function(name) identical(
        rrp_yaml_bundle_checksum(file.path(staging_path, name)),
        rrp_yaml_bundle_checksum(file.path(final_path, name))
      ),
      logical(1)
    ))
    if (!identical_content) stop(
      "Existing immutable product materialization conflicts with staged content.",
      call. = FALSE
    )
    unlink(staging_path, recursive = TRUE, force = TRUE)
  } else if (!file.rename(staging_path, final_path)) stop(
    "Could not atomically promote the staged product bundle.", call. = FALSE
  )

  pointer <- list(
    pointer_kind = "current_product_bundle_pointer",
    pointer_version = "0.1.0",
    adapter_reference = manifest$adapter_reference,
    format_reference = manifest$format_reference,
    materialization_id = manifest$materialization_id,
    bundle_directory = file.path("sets", final_name),
    manifest_file = "PRODUCT_SET.yml",
    manifest_checksum = list(
      algorithm = "md5",
      value = rrp_yaml_bundle_checksum(file.path(final_path, "PRODUCT_SET.yml"))
    ),
    published_at = published_at
  )
  pointer_staging <- tempfile(".CURRENT-", tmpdir = store_path, fileext = ".yml")
  on.exit(if (file.exists(pointer_staging)) unlink(pointer_staging, force = TRUE), add = TRUE)
  rrp_yaml_bundle_write(pointer, pointer_staging)
  prepublication <- rrp_validate_yaml_product_bundle(
    store_path,
    materialization_contract,
    adapter_declaration,
    product_contracts,
    basename(pointer_staging)
  )
  if (!identical(prepublication$overall_status, "pass")) stop(
    "Staged product bundle failed validation before publication: ",
    paste(prepublication$issues$issue_code, collapse = ", "), ".",
    call. = FALSE
  )
  pointer_path <- file.path(store_path, "CURRENT.yml")
  if (!file.rename(pointer_staging, pointer_path)) stop(
    "Could not atomically replace CURRENT.yml; the previous product set remains visible.",
    call. = FALSE
  )
  validation <- rrp_validate_yaml_product_bundle(
    store_path,
    materialization_contract,
    adapter_declaration,
    product_contracts
  )
  if (!identical(validation$overall_status, "pass")) stop(
    "Published product bundle failed post-publication validation: ",
    paste(validation$issues$issue_code, collapse = ", "), ".",
    call. = FALSE
  )
  structure(list(
    overall_status = "succeeded",
    store_path = store_path,
    bundle_path = final_path,
    pointer_path = pointer_path,
    materialization_id = manifest$materialization_id,
    product_set_id = build_result$product_set$product_set_id,
    validation = validation
  ), class = "rrp_product_materialization_result")
}

rrp_yaml_product_access <- function(validation) {
  if (!inherits(validation, "rrp_yaml_bundle_validation_result") ||
      !identical(validation$overall_status, "pass")) stop(
    "Physical product access requires a fully validated bundle.", call. = FALSE
  )
  product_set <- rrp_product_copy(validation$manifest$product_set)
  products <- rrp_product_copy(validation$products)
  list_products <- function() lapply(products, function(product) list(
    product_specification = product$product_specification,
    product_set_id = product$product_set_id,
    availability_status = product$availability_status,
    row_count = product$row_count,
    source_as_of_time = product$source_as_of_time,
    product_generated_at = product$product_generated_at
  ))
  read_product <- function(product_id, product_version, product_set_id) {
    if (!identical(product_set_id, product_set$product_set_id)) stop(
      "Requested product set is not available through this access instance.",
      call. = FALSE
    )
    matches <- Filter(function(product) {
      identical(product$product_specification$specification_id, product_id) &&
        identical(product$product_specification$specification_version, product_version)
    }, products)
    if (length(matches) != 1L) stop(
      "Requested logical product identity/version is not available.", call. = FALSE
    )
    rrp_product_copy(matches[[1L]])
  }
  read_product_metadata <- function(product_id, product_version, product_set_id) {
    product <- read_product(product_id, product_version, product_set_id)
    product$rows <- NULL
    product
  }
  structure(list(
    list_products = list_products,
    read_product = read_product,
    read_product_metadata = read_product_metadata,
    freshness = function() rrp_product_copy(validation$freshness)
  ), class = c("rrp_yaml_product_access", "rrp_logical_product_access"))
}

rrp_open_yaml_product_access <- function(
  store_path,
  materialization_contract,
  adapter_declaration,
  product_contracts
) {
  validation <- rrp_validate_yaml_product_bundle(
    store_path,
    materialization_contract,
    adapter_declaration,
    product_contracts
  )
  if (!identical(validation$overall_status, "pass")) {
    failed <- names(Filter(function(value) identical(value, "fail"), validation$categories))
    return(structure(list(
      overall_status = "failed",
      failure_category = failed[[1L]],
      message = paste0(
        "Materialized product access failed ", failed[[1L]], " validation."
      ),
      validation = validation,
      access = NULL
    ), class = "rrp_product_access_open_result"))
  }
  structure(list(
    overall_status = "succeeded",
    failure_category = NULL,
    message = "Complete materialized product set validated and opened.",
    validation = validation,
    access = rrp_yaml_product_access(validation)
  ), class = "rrp_product_access_open_result")
}
