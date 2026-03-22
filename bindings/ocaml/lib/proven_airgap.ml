(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Air Gap protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-airgap/ffi/zig/src/airgap.zig]. *)

(** TransferDirection matching [TransferDirection] in airgap.zig. *)
type transfer_direction =
  | Import  (** Import (tag 0). *)
  | Export  (** Export (tag 1). *)

let transfer_direction_to_tag = function Import -> 0 | Export -> 1

let transfer_direction_of_tag = function
  | 0 -> Some Import | 1 -> Some Export | _ -> None

(** MediaType matching [MediaType] in airgap.zig. *)
type media_type =
  | Usb  (** USB (tag 0). *)
  | OpticalDisc  (** Optical disc (tag 1). *)
  | TapeCartridge  (** Tape cartridge (tag 2). *)
  | DiodeLink  (** Data diode link (tag 3). *)

let media_type_to_tag = function
  | Usb -> 0 | OpticalDisc -> 1 | TapeCartridge -> 2 | DiodeLink -> 3

let media_type_of_tag = function
  | 0 -> Some Usb | 1 -> Some OpticalDisc | 2 -> Some TapeCartridge
  | 3 -> Some DiodeLink | _ -> None

(** ScanResult matching [ScanResult] in airgap.zig. *)
type scan_result =
  | Clean  (** Clean (tag 0). *)
  | Suspicious  (** Suspicious (tag 1). *)
  | Malicious  (** Malicious (tag 2). *)
  | Unscannable  (** Unscannable (tag 3). *)

let scan_result_to_tag = function
  | Clean -> 0 | Suspicious -> 1 | Malicious -> 2 | Unscannable -> 3

let scan_result_of_tag = function
  | 0 -> Some Clean | 1 -> Some Suspicious | 2 -> Some Malicious
  | 3 -> Some Unscannable | _ -> None

(** TransferState matching [TransferState] in airgap.zig. *)
type transfer_state =
  | Pending  (** Pending (tag 0). *)
  | Scanning  (** Scanning (tag 1). *)
  | Approved  (** Approved (tag 2). *)
  | Rejected  (** Rejected (tag 3). *)
  | InProgress  (** InProgress (tag 4). *)
  | Complete  (** Complete (tag 5). *)
  | Failed  (** Failed (tag 6). *)

let transfer_state_to_tag = function
  | Pending -> 0 | Scanning -> 1 | Approved -> 2 | Rejected -> 3
  | InProgress -> 4 | Complete -> 5 | Failed -> 6

let transfer_state_of_tag = function
  | 0 -> Some Pending | 1 -> Some Scanning | 2 -> Some Approved
  | 3 -> Some Rejected | 4 -> Some InProgress | 5 -> Some Complete
  | 6 -> Some Failed | _ -> None

(** ValidationCheck matching [ValidationCheck] in airgap.zig. *)
type validation_check =
  | HashVerify  (** HashVerify (tag 0). *)
  | SignatureVerify  (** SignatureVerify (tag 1). *)
  | FormatCheck  (** FormatCheck (tag 2). *)
  | ContentInspection  (** ContentInspection (tag 3). *)
  | MalwareScan  (** MalwareScan (tag 4). *)

let validation_check_to_tag = function
  | HashVerify -> 0 | SignatureVerify -> 1 | FormatCheck -> 2
  | ContentInspection -> 3 | MalwareScan -> 4

let validation_check_of_tag = function
  | 0 -> Some HashVerify | 1 -> Some SignatureVerify
  | 2 -> Some FormatCheck | 3 -> Some ContentInspection
  | 4 -> Some MalwareScan | _ -> None

(* --- C FFI declarations --- *)

external c_airgap_abi_version : unit -> int = "airgap_abi_version"
external c_airgap_create_context : unit -> int = "airgap_create_context"
external c_airgap_destroy_context : int -> unit = "airgap_destroy_context"
external c_airgap_state : int -> int = "airgap_state"
external c_airgap_can_transition : int -> int -> int = "airgap_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_airgap_abi_version ()

let create_context () = Proven_error.from_slot (c_airgap_create_context ())

let destroy_context slot = c_airgap_destroy_context slot

let get_state slot = transfer_state_of_tag (c_airgap_state slot)

let can_transition ~from ~to_ =
  c_airgap_can_transition (transfer_state_to_tag from) (transfer_state_to_tag to_) = 1
