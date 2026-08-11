rrp_assert_provider_registry <- function(registry) {
  if (!inherits(registry, "rrp_provider_registry") || !is.environment(registry)) {
    stop("Registry must come from new_provider_registry().", call. = FALSE)
  }
}

rrp_provider_registry_key <- function(provider_id, provider_version) {
  rrp_deterministic_id("provider", provider_id, provider_version)
}

#' Create an empty controlled provider registry
#' @export
new_provider_registry <- function() {
  registry <- new.env(parent = emptyenv())
  registry$entries <- list()
  class(registry) <- c("rrp_provider_registry", "environment")
  registry
}

#' Register a conforming provider declaration and trusted callable adapter
#' @export
register_provider <- function(
  registry,
  specification,
  adapter,
  provider_contract
) {
  rrp_assert_provider_registry(registry)
  conformance <- validate_provider_specification(specification, provider_contract)
  rrp_assert_runtime_conforms(conformance, "Provider specification")
  if (!is.function(adapter)) {
    stop(
      "Provider adapter must be a trusted callable registered by code; paths are not executable providers.",
      call. = FALSE
    )
  }
  key <- rrp_provider_registry_key(
    specification$provider_id, specification$provider_version
  )
  if (!is.null(registry$entries[[key]])) {
    stop("duplicate_registered_provider: provider ID/version is already registered.", call. = FALSE)
  }
  registry$entries[[key]] <- list(
    specification = unserialize(serialize(specification, NULL)),
    adapter = adapter
  )
  invisible(registry)
}

#' List registered provider identities deterministically
#' @export
list_registered_providers <- function(registry) {
  rrp_assert_provider_registry(registry)
  if (length(registry$entries) == 0L) {
    return(data.frame(
      provider_id = character(), provider_version = character(),
      implementation_version = character(), status = character(),
      stringsAsFactors = FALSE
    ))
  }
  rows <- lapply(registry$entries, function(entry) {
    specification <- entry$specification
    data.frame(
      provider_id = specification$provider_id,
      provider_version = specification$provider_version,
      implementation_version = specification$implementation$implementation_version,
      status = specification$status,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  output[order(output$provider_id, output$provider_version), , drop = FALSE]
}

#' Resolve one exact registered provider identity
#' @export
resolve_provider <- function(registry, provider_id, provider_version) {
  rrp_assert_provider_registry(registry)
  if (!rrp_is_scalar_string(provider_id) || !rrp_is_scalar_string(provider_version)) {
    stop("Provider selection requires exact non-empty ID and version.", call. = FALSE)
  }
  key <- rrp_provider_registry_key(provider_id, provider_version)
  entry <- registry$entries[[key]]
  if (is.null(entry)) {
    stop("unknown_registered_provider: exact provider ID/version is not registered.", call. = FALSE)
  }
  entry
}

