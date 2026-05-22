(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Log collector protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-logcollector/ffi/zig/src/logcollector.zig]. Provides
    OCaml variant types matching the Idris2 ABI enums for log levels, input
    formats, output targets, filter operations, and pipeline stages. *)

(** Log levels matching [LogLevel] in logcollector.zig. *)
type log_level =
  | Trace | Debug | Info | Warn | Err | Fatal

(** Input formats matching [InputFormat] in logcollector.zig. *)
type input_format =
  | Json | Logfmt | Syslog | Cef | Gelf | Raw

(** Output targets matching [OutputTarget] in logcollector.zig. *)
type output_target =
  | File | Elasticsearch | S3 | Kafka | Stdout

(** Filter operations matching [FilterOp] in logcollector.zig. *)
type filter_op =
  | Include | Exclude | Transform | Redact | Sample

(** Pipeline stages matching [PipelineStage] in logcollector.zig. *)
type pipeline_stage =
  | Input | Parse | Filter | PipelineTransform | Output

(** Convert a log level to its ABI tag value. *)
let log_level_to_tag = function
  | Trace -> 0 | Debug -> 1 | Info -> 2 | Warn -> 3 | Err -> 4 | Fatal -> 5

(** Decode a log level from its ABI tag value. *)
let log_level_of_tag = function
  | 0 -> Some Trace | 1 -> Some Debug | 2 -> Some Info | 3 -> Some Warn
  | 4 -> Some Err | 5 -> Some Fatal | _ -> None

(** Convert an input format to its ABI tag value. *)
let input_format_to_tag = function
  | Json -> 0 | Logfmt -> 1 | Syslog -> 2 | Cef -> 3 | Gelf -> 4 | Raw -> 5

(** Decode an input format from its ABI tag value. *)
let input_format_of_tag = function
  | 0 -> Some Json | 1 -> Some Logfmt | 2 -> Some Syslog | 3 -> Some Cef
  | 4 -> Some Gelf | 5 -> Some Raw | _ -> None

(** Convert an output target to its ABI tag value. *)
let output_target_to_tag = function
  | File -> 0 | Elasticsearch -> 1 | S3 -> 2 | Kafka -> 3 | Stdout -> 4

(** Decode an output target from its ABI tag value. *)
let output_target_of_tag = function
  | 0 -> Some File | 1 -> Some Elasticsearch | 2 -> Some S3
  | 3 -> Some Kafka | 4 -> Some Stdout | _ -> None

(** Convert a filter operation to its ABI tag value. *)
let filter_op_to_tag = function
  | Include -> 0 | Exclude -> 1 | Transform -> 2 | Redact -> 3 | Sample -> 4

(** Decode a filter operation from its ABI tag value. *)
let filter_op_of_tag = function
  | 0 -> Some Include | 1 -> Some Exclude | 2 -> Some Transform
  | 3 -> Some Redact | 4 -> Some Sample | _ -> None

(** Convert a pipeline stage to its ABI tag value. *)
let pipeline_stage_to_tag = function
  | Input -> 0 | Parse -> 1 | Filter -> 2 | PipelineTransform -> 3
  | Output -> 4

(** Decode a pipeline stage from its ABI tag value. *)
let pipeline_stage_of_tag = function
  | 0 -> Some Input | 1 -> Some Parse | 2 -> Some Filter
  | 3 -> Some PipelineTransform | 4 -> Some Output | _ -> None

(* --- C FFI declarations --- *)

external c_logcollector_abi_version : unit -> int = "logcollector_abi_version"
external c_logcollector_create_context : unit -> int = "logcollector_create_context"
external c_logcollector_destroy_context : int -> unit = "logcollector_destroy_context"
external c_logcollector_can_transition : int -> int -> int = "logcollector_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_logcollector]. *)
let abi_version () = c_logcollector_abi_version ()

(** Create a new log collector context. *)
let create_context () =
  Proven_error.from_slot (c_logcollector_create_context ())

(** Destroy a log collector context, releasing its slot. *)
let destroy_context slot = c_logcollector_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_logcollector_can_transition (pipeline_stage_to_tag from) (pipeline_stage_to_tag to_) = 1
