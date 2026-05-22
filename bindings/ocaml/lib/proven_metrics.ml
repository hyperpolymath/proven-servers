(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Metrics/Prometheus server protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-metrics/ffi/zig/src/metrics.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for metric types, scrape results,
    alert states, aggregation operations, query errors, and collector states. *)

(** Metric types matching [MetricType] in metrics.zig. *)
type metric_type =
  | Counter | Gauge | Histogram | Summary | Info | StateSet

(** Scrape results matching [ScrapeResult] in metrics.zig. *)
type scrape_result =
  | Success | ScrapeTimeout | ConnectionRefused | InvalidResponse

(** Alert states matching [AlertState] in metrics.zig. *)
type alert_state =
  | Inactive | Pending | Firing | Resolved

(** Aggregation operations matching [AggregationOp] in metrics.zig. *)
type aggregation_op =
  | Sum | Avg | Min | Max | Count | Rate | Increase
  | P50 | P90 | P95 | P99

(** Query errors matching [QueryError] in metrics.zig. *)
type query_error =
  | ParseError | ExecutionError | QueryTimeout | TooManySeries

(** Collector states matching [CollectorState] in metrics.zig. *)
type collector_state =
  | Idle | Configured | Scraping | Alerting | Stopping

(** Convert a metric type to its ABI tag value. *)
let metric_type_to_tag = function
  | Counter -> 0 | Gauge -> 1 | Histogram -> 2 | Summary -> 3
  | Info -> 4 | StateSet -> 5

(** Decode a metric type from its ABI tag value. *)
let metric_type_of_tag = function
  | 0 -> Some Counter | 1 -> Some Gauge | 2 -> Some Histogram
  | 3 -> Some Summary | 4 -> Some Info | 5 -> Some StateSet | _ -> None

(** Convert a scrape result to its ABI tag value. *)
let scrape_result_to_tag = function
  | Success -> 0 | ScrapeTimeout -> 1 | ConnectionRefused -> 2
  | InvalidResponse -> 3

(** Decode a scrape result from its ABI tag value. *)
let scrape_result_of_tag = function
  | 0 -> Some Success | 1 -> Some ScrapeTimeout
  | 2 -> Some ConnectionRefused | 3 -> Some InvalidResponse | _ -> None

(** Convert an alert state to its ABI tag value. *)
let alert_state_to_tag = function
  | Inactive -> 0 | Pending -> 1 | Firing -> 2 | Resolved -> 3

(** Decode an alert state from its ABI tag value. *)
let alert_state_of_tag = function
  | 0 -> Some Inactive | 1 -> Some Pending | 2 -> Some Firing
  | 3 -> Some Resolved | _ -> None

(** Convert an aggregation operation to its ABI tag value. *)
let aggregation_op_to_tag = function
  | Sum -> 0 | Avg -> 1 | Min -> 2 | Max -> 3 | Count -> 4 | Rate -> 5
  | Increase -> 6 | P50 -> 7 | P90 -> 8 | P95 -> 9 | P99 -> 10

(** Decode an aggregation operation from its ABI tag value. *)
let aggregation_op_of_tag = function
  | 0 -> Some Sum | 1 -> Some Avg | 2 -> Some Min | 3 -> Some Max
  | 4 -> Some Count | 5 -> Some Rate | 6 -> Some Increase | 7 -> Some P50
  | 8 -> Some P90 | 9 -> Some P95 | 10 -> Some P99 | _ -> None

(** Convert a query error to its ABI tag value. *)
let query_error_to_tag = function
  | ParseError -> 0 | ExecutionError -> 1 | QueryTimeout -> 2
  | TooManySeries -> 3

(** Decode a query error from its ABI tag value. *)
let query_error_of_tag = function
  | 0 -> Some ParseError | 1 -> Some ExecutionError
  | 2 -> Some QueryTimeout | 3 -> Some TooManySeries | _ -> None

(** Convert a collector state to its ABI tag value. *)
let collector_state_to_tag = function
  | Idle -> 0 | Configured -> 1 | Scraping -> 2 | Alerting -> 3
  | Stopping -> 4

(** Decode a collector state from its ABI tag value. *)
let collector_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Configured | 2 -> Some Scraping
  | 3 -> Some Alerting | 4 -> Some Stopping | _ -> None

(* --- C FFI declarations --- *)

external c_metrics_abi_version : unit -> int = "metrics_abi_version"
external c_metrics_create_context : unit -> int = "metrics_create_context"
external c_metrics_destroy_context : int -> unit = "metrics_destroy_context"
external c_metrics_can_transition : int -> int -> int = "metrics_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_metrics]. *)
let abi_version () = c_metrics_abi_version ()

(** Create a new metrics context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_metrics_create_context ())

(** Destroy a metrics context, releasing its slot. *)
let destroy_context slot = c_metrics_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_metrics_can_transition (collector_state_to_tag from) (collector_state_to_tag to_) = 1
