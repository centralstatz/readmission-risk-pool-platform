# History-backed logical product builders. The only executable upstream seam is
# the rrpruntime persistence port; normalized-history entry points support
# backend-independent testing without teaching this layer any adapter details.

rrp_product_contracts_conformance <- function(contracts) {
  target <- list(
    specification_kind = "product_set_contract",
    specification_id = "platform.initial-risk-product-set",
    specification_version = "0.1.0"
  )
  issues <- list()
  required <- c(
    "product_set", "current_episode_risk", "episode_risk_history",
    "operational_run_summary"
  )
  if (!is.list(contracts)) return(rrp_product_conformance_result(target, list(
    rrp_product_issue(
      "product.contracts.structure", "invalid_product_contracts",
      "Product contracts must be supplied as a named record."
    )
  )))
  missing <- setdiff(required, names(contracts))
  for (name in missing) issues[[length(issues) + 1L]] <- rrp_product_issue(
    "product.contracts.required", "missing_product_contract",
    paste0("Product contract is missing: ", name, "."), paste0("$.", name)
  )
  if (length(missing) == 0L) {
    if (!identical(rrp_product_identity(contracts$product_set), target)) {
      issues[[length(issues) + 1L]] <- rrp_product_issue(
        "product.contracts.identity", "unsupported_product_set_contract",
        "The product builder does not support this product-set contract.",
        "$.product_set"
      )
    }
    members <- contracts$product_set$required_products
    for (name in setdiff(required, "product_set")) {
      if (!identical(rrp_product_identity(contracts[[name]]), members[[name]])) {
        issues[[length(issues) + 1L]] <- rrp_product_issue(
          "product.contracts.identity", "product_contract_identity_mismatch",
          paste0("Product contract `", name, "` does not match the set declaration."),
          paste0("$.", name)
        )
      }
    }
    builder <- contracts$product_set$builder
    if (!rrp_product_scalar_string(builder$builder_id) ||
        !rrp_product_semver(builder$builder_version)) {
      issues[[length(issues) + 1L]] <- rrp_product_issue(
        "product.contracts.builder", "invalid_product_builder_identity",
        "Product-set contract requires one builder ID and semantic version.",
        "$.product_set.builder"
      )
    }
  }
  rrp_product_conformance_result(target, issues)
}

rrp_product_terminal_status <- function(history, run_id) {
  statuses <- history$operational_run
  terminal <- Filter(function(value) {
    identical(value$runtime_run_id, run_id) &&
      value$run_status %in% c("completed", "completed_with_failures")
  }, statuses)
  if (length(terminal) == 1L) terminal[[1L]] else NULL
}

rrp_validate_product_source_histories <- function(histories, source_run_ids, contracts) {
  target <- rrp_product_identity(contracts$product_set)
  declarations <- contracts$product_set$supported_upstream_specifications
  issues <- list()
  if (!is.list(histories) || !identical(names(histories), source_run_ids)) return(
    rrp_product_conformance_result(target, list(rrp_product_issue(
      "product.source.structure", "invalid_source_history_collection",
      "Normalized source histories must be named by the sorted selected run IDs."
    )))
  )
  family_rules <- list(
    operational_run = list("run_status_specification", declarations$operational_run),
    episode_state = list("state_specification", declarations$episode_state),
    estimand_request = list("request_specification", declarations$estimand_request),
    provider_execution_result = list(
      "execution_result_specification",
      declarations$provider_execution_result
    ),
    estimate = list("estimate_specification", declarations$accepted_estimate)
  )
  for (run_id in source_run_ids) {
    history <- histories[[run_id]]
    terminal <- rrp_product_terminal_status(history, run_id)
    if (is.null(terminal)) issues[[length(issues) + 1L]] <- rrp_product_issue(
      "product.source.terminal", "source_run_not_validly_completed",
      paste0("Selected source run has no single valid completed terminal status: ", run_id, "."),
      paste0("$.histories.", run_id)
    )
    for (family in names(family_rules)) {
      values <- history[[family]]
      if (!is.list(values)) {
        issues[[length(issues) + 1L]] <- rrp_product_issue(
          "product.source.family", "invalid_source_history_family",
          paste0("Source history family is not a record collection: ", family, "."),
          paste0("$.histories.", run_id, ".", family)
        )
        next
      }
      field <- family_rules[[family]][[1L]]
      declaration <- family_rules[[family]][[2L]]
      for (index in seq_along(values)) {
        record <- values[[index]]
        if (!identical(record$runtime_run_id, run_id)) issues[[length(issues) + 1L]] <-
          rrp_product_issue(
            "product.source.run", "source_record_run_mismatch",
            "A normalized history record belongs to a different run.",
            paste0("$.histories.", run_id, ".", family, "[", index, "]")
          )
        if (!rrp_product_version_supported(record[[field]], declaration)) {
          issues[[length(issues) + 1L]] <- rrp_product_issue(
            "product.compatibility.version", "unsupported_upstream_specification",
            paste0("Unsupported ", family, " specification identity or version."),
            paste0("$.histories.", run_id, ".", family, "[", index, "].", field)
          )
        }
      }
    }
    requests <- history$estimand_request
    estimates <- history$estimate
    for (record in c(requests, estimates)) if (!rrp_product_version_supported(
      record$estimand_specification,
      declarations$estimand
    )) issues[[length(issues) + 1L]] <- rrp_product_issue(
      "product.compatibility.estimand", "unsupported_estimand_specification",
      "A source request or estimate exposes an unsupported estimand version.",
      paste0("$.histories.", run_id)
    )
    executions <- history$provider_execution_result
    if (any(!vapply(executions, function(record) {
      is.list(record$provider_reference) &&
        rrp_product_scalar_string(record$provider_reference$provider_id) &&
        rrp_product_semver(record$provider_reference$provider_version)
    }, logical(1)))) issues[[length(issues) + 1L]] <- rrp_product_issue(
      "product.compatibility.provider", "invalid_provider_reference",
      "Provider references exposed to products require stable IDs and versions.",
      paste0("$.histories.", run_id, ".provider_execution_result")
    )
    if (!is.null(terminal)) {
      actual <- list(
        episode_state_count = length(history$episode_state),
        estimand_request_count = length(history$estimand_request),
        provider_execution_result_count = length(history$provider_execution_result),
        successful_estimate_count = length(history$estimate),
        failed_execution_count = sum(vapply(
          history$provider_execution_result,
          function(value) !identical(value$execution_status, "successful_estimate"),
          logical(1)
        ))
      )
      actual$failed_execution_count <- as.integer(actual$failed_execution_count)
      if (!identical(terminal$status_summary, actual)) {
        issues[[length(issues) + 1L]] <- rrp_product_issue(
          "product.source.summary", "source_terminal_summary_mismatch",
          "Validity-resolved persisted counts do not match the terminal run summary.",
          paste0("$.histories.", run_id, ".operational_run")
        )
      }
    }
  }
  rrp_product_conformance_result(target, issues)
}

rrp_product_source_context <- function(histories, source_run_ids, source_cutoff_time) {
  terminals <- lapply(source_run_ids, function(run_id) {
    rrp_product_terminal_status(histories[[run_id]], run_id)
  })
  as_of_values <- vapply(terminals, function(value) {
    rrp_product_time_number(value$as_of_time)
  }, numeric(1))
  status_values <- vapply(terminals, function(value) {
    rrp_product_time_number(value$status_time)
  }, numeric(1))
  latest <- which(as_of_values == max(as_of_values))
  latest <- latest[status_values[latest] == max(status_values[latest])]
  if (length(latest) != 1L) stop(
    "Latest represented valid operational run is ambiguous.",
    call. = FALSE
  )
  if (any(as_of_values > rrp_product_time_number(source_cutoff_time))) stop(
    "Selected source history is newer than the product cutoff.",
    call. = FALSE
  )
  list(
    terminals = stats::setNames(terminals, source_run_ids),
    source_as_of_time = terminals[[latest]]$as_of_time,
    latest_source_runtime_run_id = source_run_ids[[latest]]
  )
}

rrp_product_set_identity <- function(contracts, source_run_ids, source_cutoff_time) {
  set <- contracts$product_set
  member_references <- lapply(set$required_products, function(value) {
    rrp_product_reference_key(value)
  })
  rrp_product_deterministic_id(
    "product_set",
    rrp_product_reference_key(rrp_product_identity(set)),
    set$builder$builder_id,
    set$builder$builder_version,
    source_cutoff_time,
    source_run_ids,
    unlist(member_references, use.names = FALSE)
  )
}

rrp_product_metadata <- function(
  contract,
  product_set,
  rows,
  provenance_references
) {
  list(
    product_instance_id = rrp_product_instance_id(
      contract,
      product_set$product_set_id
    ),
    product_specification = rrp_product_identity(contract),
    product_set_id = product_set$product_set_id,
    availability_status = "available",
    source_cutoff_time = product_set$source_cutoff_time,
    source_as_of_time = product_set$source_as_of_time,
    latest_source_runtime_run_id = product_set$latest_source_runtime_run_id,
    source_runtime_run_ids = product_set$source_runtime_run_ids,
    product_generated_at = product_set$product_generated_at,
    row_count = as.integer(length(rows)),
    rows = rows,
    provenance_references = provenance_references
  )
}

rrp_product_unique_references <- function(values, key_function) {
  if (length(values) == 0L) return(list())
  keys <- vapply(values, key_function, character(1))
  values[order(keys, method = "radix")][!duplicated(keys[order(keys, method = "radix")])]
}

rrp_current_product_rows <- function(
  estimates,
  states,
  current_reader,
  product_set,
  contract
) {
  if (length(estimates) == 0L) return(list())
  pairs <- unique(vapply(estimates, function(value) paste(
    value$episode_id,
    value$estimand_specification$specification_id,
    sep = "\r"
  ), character(1)))
  estimates_by_id <- stats::setNames(
    estimates,
    vapply(estimates, `[[`, character(1), "estimate_id")
  )
  states_by_id <- stats::setNames(states, vapply(states, `[[`, character(1), "state_id"))
  rows <- lapply(pairs, function(pair) {
    parts <- strsplit(pair, "\r", fixed = TRUE)[[1L]]
    estimate <- current_reader(parts[[1L]], parts[[2L]], product_set$source_cutoff_time)
    if (is.null(estimate) || is.null(estimates_by_id[[estimate$estimate_id]])) stop(
      "Current persistence read escaped the selected valid source-run scope.",
      call. = FALSE
    )
    state <- states_by_id[[estimate$state_reference$state_id]]
    if (is.null(state)) stop(
      "Current accepted estimate references no selected valid persisted state.",
      call. = FALSE
    )
    row <- list(
      product_row_id = "pending",
      episode_id = estimate$episode_id,
      estimate_id = estimate$estimate_id,
      estimate_value = as.numeric(estimate$estimate_value),
      output_type = estimate$output_type,
      estimand_id = estimate$estimand_specification$specification_id,
      estimand_version = estimate$estimand_specification$specification_version,
      provider_id = estimate$provider_reference$provider_id,
      provider_version = estimate$provider_reference$provider_version,
      model_reference = estimate$model_reference,
      target_interval_start = estimate$target_interval_start,
      target_interval_end = estimate$target_interval_end,
      interval_boundary = estimate$interval_boundary,
      state_id = state$state_id,
      state_as_of_time = state$as_of_time,
      source_runtime_run_id = estimate$runtime_run_id
    )
    row$product_row_id <- rrp_product_row_id(
      contract,
      product_set$product_set_id,
      unlist(row[unlist(contract$row_identity, use.names = FALSE)], use.names = FALSE)
    )
    row
  })
  ordering <- order(
    vapply(rows, `[[`, character(1), "episode_id"),
    vapply(rows, `[[`, character(1), "estimand_id"),
    vapply(rows, `[[`, character(1), "estimand_version"),
    method = "radix"
  )
  rows[ordering]
}

rrp_history_product_rows <- function(estimates, terminals, product_set, contract) {
  rows <- lapply(estimates, function(estimate) {
    terminal <- terminals[[estimate$runtime_run_id]]
    row <- list(
      product_row_id = "pending",
      episode_id = estimate$episode_id,
      estimate_id = estimate$estimate_id,
      estimate_value = as.numeric(estimate$estimate_value),
      output_type = estimate$output_type,
      estimand_id = estimate$estimand_specification$specification_id,
      estimand_version = estimate$estimand_specification$specification_version,
      provider_id = estimate$provider_reference$provider_id,
      provider_version = estimate$provider_reference$provider_version,
      model_reference = estimate$model_reference,
      estimate_as_of_time = estimate$as_of_time,
      target_interval_start = estimate$target_interval_start,
      target_interval_end = estimate$target_interval_end,
      interval_boundary = estimate$interval_boundary,
      state_id = estimate$state_reference$state_id,
      source_runtime_run_id = estimate$runtime_run_id,
      validity_status = "valid",
      source_run_provenance_references = terminal$provenance_references
    )
    row$product_row_id <- rrp_product_row_id(
      contract,
      product_set$product_set_id,
      unlist(row[unlist(contract$row_identity, use.names = FALSE)], use.names = FALSE)
    )
    row
  })
  if (length(rows) == 0L) return(rows)
  ordering <- order(
    vapply(rows, `[[`, character(1), "episode_id"),
    vapply(rows, `[[`, character(1), "estimand_id"),
    vapply(rows, `[[`, character(1), "estimand_version"),
    vapply(rows, `[[`, character(1), "estimate_as_of_time"),
    vapply(rows, `[[`, character(1), "source_runtime_run_id"),
    vapply(rows, `[[`, character(1), "estimate_id"),
    method = "radix"
  )
  rows[ordering]
}

rrp_run_summary_rows <- function(histories, terminals, product_set, contract) {
  rows <- lapply(product_set$source_runtime_run_ids, function(run_id) {
    history <- histories[[run_id]]
    terminal <- terminals[[run_id]]
    providers <- lapply(history$provider_execution_result, `[[`, "provider_reference")
    providers <- rrp_product_unique_references(providers, function(value) paste(
      value$provider_id,
      value$provider_version,
      sep = "@"
    ))
    estimands <- lapply(history$estimand_request, `[[`, "estimand_specification")
    estimands <- rrp_product_unique_references(estimands, rrp_product_reference_key)
    summary <- terminal$status_summary
    row <- list(
      product_row_id = "pending",
      runtime_run_id = run_id,
      run_as_of_time = terminal$as_of_time,
      terminal_status_time = terminal$status_time,
      terminal_status = terminal$run_status,
      episode_state_count = as.integer(summary$episode_state_count),
      estimand_request_count = as.integer(summary$estimand_request_count),
      provider_execution_result_count = as.integer(summary$provider_execution_result_count),
      successful_estimate_count = as.integer(summary$successful_estimate_count),
      failed_execution_count = as.integer(summary$failed_execution_count),
      provider_references = providers,
      estimand_specifications = estimands,
      implementation_reference = terminal$implementation_reference,
      mapping_reference = terminal$mapping_reference,
      provenance_references = terminal$provenance_references
    )
    row$product_row_id <- rrp_product_row_id(
      contract,
      product_set$product_set_id,
      unlist(row[unlist(contract$row_identity, use.names = FALSE)], use.names = FALSE)
    )
    row
  })
  ordering <- order(
    vapply(rows, `[[`, character(1), "run_as_of_time"),
    vapply(rows, `[[`, character(1), "terminal_status_time"),
    vapply(rows, `[[`, character(1), "runtime_run_id"),
    method = "radix"
  )
  rows[ordering]
}

rrp_product_source_index <- function(histories, source_run_ids, source_cutoff_time) {
  states <- unlist(lapply(histories, `[[`, "episode_state"), recursive = FALSE)
  estimates <- unlist(lapply(histories, `[[`, "estimate"), recursive = FALSE)
  estimates <- Filter(function(value) {
    rrp_product_time_number(value$as_of_time) <= rrp_product_time_number(source_cutoff_time)
  }, estimates)
  list(
    states = states,
    estimates = estimates,
    runtime_run_ids = source_run_ids,
    state_ids = vapply(states, `[[`, character(1), "state_id"),
    estimate_ids = vapply(estimates, `[[`, character(1), "estimate_id")
  )
}

rrp_build_logical_products_from_histories <- function(
  histories,
  current_reader,
  source_run_ids,
  source_cutoff_time,
  product_generated_at,
  contracts
) {
  contract_result <- rrp_product_contracts_conformance(contracts)
  if (!rrp_product_conforms(contract_result)) return(rrp_product_build_result(
    "failed", "compatibility", "Product contract suite is unsupported.",
    conformance_results = list(contracts = contract_result)
  ))
  compatibility <- rrp_validate_product_source_histories(
    histories,
    source_run_ids,
    contracts
  )
  if (!rrp_product_conforms(compatibility)) return(rrp_product_build_result(
    "failed", "compatibility", "Selected history is incompatible with the product suite.",
    conformance_results = list(source_compatibility = compatibility)
  ))
  context <- tryCatch(
    rrp_product_source_context(histories, source_run_ids, source_cutoff_time),
    error = function(condition) condition
  )
  if (inherits(context, "condition")) return(rrp_product_build_result(
    "failed", "source_history", conditionMessage(context)
  ))
  if (!rrp_product_timestamp(product_generated_at) ||
      rrp_product_time_number(product_generated_at) <
        rrp_product_time_number(context$source_as_of_time)) return(rrp_product_build_result(
    "failed", "compatibility",
    "Product generation time must be a valid timestamp at or after source as-of."
  ))
  product_set_id <- rrp_product_set_identity(
    contracts,
    source_run_ids,
    source_cutoff_time
  )
  provenance <- lapply(source_run_ids, function(run_id) list(
    provenance_type = "operational_run",
    provenance_id = run_id,
    relationship = "derived_from"
  ))
  product_set <- list(
    product_set_id = product_set_id,
    product_build_id = rrp_product_deterministic_id(
      "product_build",
      product_set_id,
      contracts$product_set$builder$builder_id,
      contracts$product_set$builder$builder_version
    ),
    product_set_specification = rrp_product_identity(contracts$product_set),
    builder_reference = rrp_product_builder_reference(contracts$product_set),
    product_specifications = contracts$product_set$required_products,
    source_runtime_run_ids = source_run_ids,
    source_cutoff_time = source_cutoff_time,
    source_as_of_time = context$source_as_of_time,
    latest_source_runtime_run_id = context$latest_source_runtime_run_id,
    product_generated_at = product_generated_at,
    provenance_references = provenance,
    build_status = "succeeded"
  )
  source <- rrp_product_source_index(histories, source_run_ids, source_cutoff_time)
  row_result <- tryCatch(list(
    current_episode_risk = rrp_current_product_rows(
      source$estimates,
      source$states,
      current_reader,
      product_set,
      contracts$current_episode_risk
    ),
    episode_risk_history = rrp_history_product_rows(
      source$estimates,
      context$terminals,
      product_set,
      contracts$episode_risk_history
    ),
    operational_run_summary = rrp_run_summary_rows(
      histories,
      context$terminals,
      product_set,
      contracts$operational_run_summary
    )
  ), error = function(condition) condition)
  if (inherits(row_result, "condition")) return(rrp_product_build_result(
    "failed", "source_history", conditionMessage(row_result)
  ))
  products <- list(
    current_episode_risk = rrp_product_metadata(
      contracts$current_episode_risk,
      product_set,
      row_result$current_episode_risk,
      provenance
    ),
    episode_risk_history = rrp_product_metadata(
      contracts$episode_risk_history,
      product_set,
      row_result$episode_risk_history,
      provenance
    ),
    operational_run_summary = rrp_product_metadata(
      contracts$operational_run_summary,
      product_set,
      row_result$operational_run_summary,
      provenance
    )
  )
  conformance <- lapply(names(products), function(name) {
    rrp_validate_logical_product(products[[name]], contracts[[name]], source)
  })
  names(conformance) <- names(products)
  conformance$product_set <- rrp_validate_product_set_coherence(
    product_set,
    products,
    contracts$product_set
  )
  if (any(!vapply(conformance, rrp_product_conforms, logical(1)))) {
    product_set$build_status <- "failed"
    return(rrp_product_build_result(
      "failed", "conformance",
      "One or more required logical products failed conformance.",
      product_set = product_set,
      products = list(),
      conformance_results = conformance
    ))
  }
  rrp_product_build_result(
    "succeeded",
    message = "Complete core logical product set built and conformed.",
    product_set = product_set,
    products = products,
    conformance_results = conformance
  )
}

rrp_build_logical_product_set <- function(
  persistence_port,
  source_run_ids,
  source_cutoff_time,
  product_generated_at,
  contracts
) {
  if (!inherits(persistence_port, "rrp_persistence_port")) return(
    rrp_product_build_result(
      "failed", "source_history", "A validated rrpruntime persistence port is required."
    )
  )
  if (!is.character(source_run_ids) || length(source_run_ids) == 0L ||
      anyNA(source_run_ids) || any(!nzchar(source_run_ids)) ||
      !rrp_product_timestamp(source_cutoff_time)) return(rrp_product_build_result(
    "failed", "source_history",
    "At least one source run ID and an explicit valid source cutoff are required."
  ))
  source_run_ids <- sort(unique(source_run_ids), method = "radix")
  histories <- tryCatch(lapply(source_run_ids, function(run_id) {
    rrpruntime::read_run_history(persistence_port, run_id, "valid")
  }), error = function(condition) condition)
  if (inherits(histories, "condition")) return(rrp_product_build_result(
    "failed", "source_history_read",
    paste0("Could not read selected valid operational history: ", conditionMessage(histories))
  ))
  names(histories) <- source_run_ids
  current_reader <- function(episode_id, estimand_id, cutoff) {
    rrpruntime::read_current_estimate(
      persistence_port,
      episode_id,
      estimand_id,
      cutoff
    )
  }
  rrp_build_logical_products_from_histories(
    histories,
    current_reader,
    source_run_ids,
    source_cutoff_time,
    product_generated_at,
    contracts
  )
}

