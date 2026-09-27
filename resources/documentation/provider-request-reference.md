# RRP Provider Request Reference

The normal provider callable receives a detached object with exact class
`c("rrp_risk_request", "list")`. It is one flat named list with exactly these
fields in order:

| Field | R type | Meaning |
|---|---|---|
| `request_contract_id` | scalar character | `rrp.risk-request` |
| `request_contract_version` | scalar character | `0.1.0` |
| `request_id` | scalar character | deterministic governed request identity |
| `target_id` | scalar character | singular remaining-readmission-risk target |
| `target_version` | scalar character | exact target version |
| `state_contract_id` | scalar character | episode-state contract identity |
| `state_contract_version` | scalar character | exact state-contract version |
| `state_id` | scalar character | immutable eligible episode-state identity |
| `bundle_instance_id` | scalar character | admitted canonical bundle identity |
| `project_id` | scalar character | selected project identity |
| `project_version` | scalar character | selected project version |
| `episode_id` | scalar character | canonical episode identity |
| `as_of_time` | scalar character | authoritative RFC 3339 UTC analytical time |
| `discharge_time` | scalar character | canonical RFC 3339 UTC discharge time |
| `target_interval_start` | scalar character | exactly `as_of_time` |
| `target_interval_end` | scalar character | inclusive fixed elapsed day-30 endpoint |
| `target_interval_boundary` | scalar character | exactly `(start,end]` |
| `elapsed_seconds_since_discharge` | finite unclassed double | elapsed seconds through the analytical time |
| `remaining_seconds_through_w30` | finite unclassed double | remaining seconds through day 30 |

`episode_id` is the only canonical domain identifier supplied. Before invoking
the provider, RRP has admitted canonical data, established eligibility and
immutable state at `as_of_time`, selected and compatibility-checked the exact
provider, and constructed the deterministic request. The episode is discharged,
alive, readmission-free through the cutoff, and still before the fixed endpoint
according to admitted information.

The request deliberately omits patient and encounter IDs, terminal rows, the
canonical bundle, native/source IDs and crosswalks, arbitrary predictors,
credentials, connections, callbacks, provider/model identity, prior estimates,
products, and history. `project_root` is supplied separately to the normal
callable so hospital code can resolve private model data. The hospital must
ensure every private predictor is legitimate for `request$as_of_time` and must
not redefine eligibility, target, or interval.

## Normal return and raw adaptation

On success, return one finite unclassed base-R double in `[0,1]`. For an
intentional controlled failure, return `rrpplatform::rrp_authoring_failure()`
with one admitted provider code: `provider_unavailable`,
`provider_input_unavailable`, or `provider_calculation_failed`.

RRP adapts those alternatives to the unchanged raw result with exactly
`request_id`, `status`, `estimate_value`, and `failure_code`. A declared failure
is not an invalid result. `NULL`, `NA_real_`, `NaN`, infinite, non-double,
wrong-length, or out-of-range output is invalid. A thrown condition is an
execution failure. RRP contains both detected cases and exposes only bounded,
privacy-safe diagnostics; arbitrary hospital exception text is not propagated.

This reference explains the realized interface. The installed runtime contract
resources remain semantic authority. Conformance does not establish clinical
validity or production approval.
