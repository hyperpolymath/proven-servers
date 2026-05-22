(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Data Diodetypes for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-diode/ffi/zig/src/diode.zig]. *)

(** Direction matching [Direction] in diode.zig. *)
type direction =
  | HighToLow  (** HighToLow (tag 0). *)
  | LowToHigh  (** LowToHigh (tag 1). *)

let direction_to_tag = function
  | HighToLow -> 0 | LowToHigh -> 1

let direction_of_tag = function
  | 0 -> Some HighToLow
  | 1 -> Some LowToHigh
  | _ -> None

(** DiodeProtocol matching [DiodeProtocol] in diode.zig. *)
type diode_protocol =
  | Udp  (** UDP (tag 0). *)
  | Tcp  (** TCP (tag 1). *)
  | FileTransfer  (** FileTransfer (tag 2). *)
  | Syslog  (** Syslog (tag 3). *)
  | Snmp  (** SNMP (tag 4). *)

let diode_protocol_to_tag = function
  | Udp -> 0 | Tcp -> 1 | FileTransfer -> 2 | Syslog -> 3 | Snmp -> 4

let diode_protocol_of_tag = function
  | 0 -> Some Udp
  | 1 -> Some Tcp
  | 2 -> Some FileTransfer
  | 3 -> Some Syslog
  | 4 -> Some Snmp
  | _ -> None

(** TransferState matching [TransferState] in diode.zig. *)
type transfer_state =
  | Queued  (** Queued (tag 0). *)
  | Sending  (** Sending (tag 1). *)
  | Confirming  (** Confirming (tag 2). *)
  | Complete  (** Complete (tag 3). *)
  | Failed  (** Failed (tag 4). *)

let transfer_state_to_tag = function
  | Queued -> 0
  | Sending -> 1
  | Confirming -> 2
  | Complete -> 3
  | Failed -> 4

let transfer_state_of_tag = function
  | 0 -> Some Queued
  | 1 -> Some Sending
  | 2 -> Some Confirming
  | 3 -> Some Complete
  | 4 -> Some Failed
  | _ -> None

(** ValidationResult matching [ValidationResult] in diode.zig. *)
type validation_result =
  | Passed  (** Passed (tag 0). *)
  | FormatError  (** FormatError (tag 1). *)
  | SizeExceeded  (** SizeExceeded (tag 2). *)
  | PolicyBlocked  (** PolicyBlocked (tag 3). *)

let validation_result_to_tag = function
  | Passed -> 0
  | FormatError -> 1
  | SizeExceeded -> 2
  | PolicyBlocked -> 3

let validation_result_of_tag = function
  | 0 -> Some Passed
  | 1 -> Some FormatError
  | 2 -> Some SizeExceeded
  | 3 -> Some PolicyBlocked
  | _ -> None

(** IntegrityCheck matching [IntegrityCheck] in diode.zig. *)
type integrity_check =
  | Crc32  (** CRC-32 (tag 0). *)
  | Sha256  (** SHA-256 (tag 1). *)
  | Hmac  (** HMAC (tag 2). *)

let integrity_check_to_tag = function
  | Crc32 -> 0 | Sha256 -> 1 | Hmac -> 2

let integrity_check_of_tag = function
  | 0 -> Some Crc32
  | 1 -> Some Sha256
  | 2 -> Some Hmac
  | _ -> None

(** GatewayState matching [GatewayState] in diode.zig. *)
type gateway_state =
  | Idle  (** Idle (tag 0). *)
  | Configured  (** Configured (tag 1). *)
  | Transferring  (** Transferring (tag 2). *)
  | Validating  (** Validating (tag 3). *)
  | Shutdown  (** Shutdown (tag 4). *)

let gateway_state_to_tag = function
  | Idle -> 0
  | Configured -> 1
  | Transferring -> 2
  | Validating -> 3
  | Shutdown -> 4

let gateway_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Configured
  | 2 -> Some Transferring
  | 3 -> Some Validating
  | 4 -> Some Shutdown
  | _ -> None

(* --- C FFI declarations --- *)

external c_diode_abi_version : unit -> int = "diode_abi_version"
external c_diode_create_context : unit -> int = "diode_create_context"
external c_diode_destroy_context : int -> unit = "diode_destroy_context"
external c_diode_state : int -> int = "diode_state"
external c_diode_gateway_state : int -> int = "diode_gateway_state"
external c_diode_can_transition : int -> int -> int = "diode_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_diode_abi_version ()

let create_context () = Proven_error.from_slot (c_diode_create_context ())

let destroy_context slot = c_diode_destroy_context slot

let get_state slot = transfer_state_of_tag (c_diode_state slot)

let can_transition ~from ~to_ =
  c_diode_can_transition (transfer_state_to_tag from) (transfer_state_to_tag to_) = 1
