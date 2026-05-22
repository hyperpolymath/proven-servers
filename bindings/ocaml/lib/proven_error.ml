(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Shared error types for all proven-servers FFI operations.

    Every protocol FFI uses the same slot-based context pool pattern with
    [int] return values (-1 = no slot, 0/1 = success/failure). This module
    maps those patterns to a descriptive OCaml variant type. *)

(** Unified error type for all proven-servers FFI operations. *)
type t =
  | Pool_exhausted
    (** No free context slots available in the pool (64-slot limit). *)
  | Invalid_slot
    (** The slot index is invalid or the context is not active. *)
  | Invalid_state
    (** The operation was rejected because the context is in the wrong
        lifecycle state for the requested transition. *)
  | Invalid_parameter
    (** A parameter value is outside the valid ABI tag range. *)
  | Capacity_exceeded
    (** The operation would exceed a fixed-size buffer or array limit. *)
  | Validation_failed
    (** Input validation failed (e.g. path traversal attack). *)
  | Unknown_error of int
    (** The FFI returned an unexpected or undocumented error code. *)

(** Convert a proven error to a human-readable string. *)
let to_string = function
  | Pool_exhausted -> "context pool exhausted (64-slot limit)"
  | Invalid_slot -> "invalid or inactive context slot"
  | Invalid_state -> "operation rejected: wrong lifecycle state"
  | Invalid_parameter -> "parameter value outside valid ABI tag range"
  | Capacity_exceeded -> "fixed-size buffer or array capacity exceeded"
  | Validation_failed -> "input validation failed"
  | Unknown_error code -> Printf.sprintf "unknown FFI error (code %d)" code

(** Interpret a slot-returning FFI call.

    Returns [Ok slot] for non-negative values, [Error Pool_exhausted] for
    negative values (typically -1). *)
let from_slot raw =
  if raw >= 0 then Ok raw
  else Error Pool_exhausted

(** Interpret a status-returning FFI call (0 = success, non-zero = error).

    - 0 -> [Ok ()]
    - 1 -> [Error Invalid_state]
    - 2 -> [Error Validation_failed]
    - other -> [Error (Unknown_error code)] *)
let from_status raw =
  match raw with
  | 0 -> Ok ()
  | 1 -> Error Invalid_state
  | 2 -> Error Validation_failed
  | n -> Error (Unknown_error n)
