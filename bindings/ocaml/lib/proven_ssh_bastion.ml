(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** SSH Bastion protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig]. *)

(** SSH bastion lifecycle states. *)
type bastion_state =
  | Connected      (** TCP connection established. *)
  | Key_exchanged  (** Key exchange completed. *)
  | Authenticated  (** User authenticated. *)
  | Channel_open   (** At least one channel opening. *)
  | Active         (** Session fully active. *)
  | Closed         (** Session closed. *)

(** Key exchange methods. *)
type kex_method =
  | Curve25519 | Dh_group14 | Dh_group16 | Ecdh_p256 | Ecdh_p384

(** Authentication methods. *)
type auth_method =
  | Public_key | Password | Keyboard | Certificate

(** SSH channel types. *)
type channel_type =
  | Session | Direct_tcp_ip | Forwarded_tcp_ip | Subsystem

(** SSH channel states. *)
type channel_state =
  | Ch_opening | Ch_open | Ch_closing | Ch_closed

(** SSH disconnect reasons (RFC 4253). *)
type disconnect_reason =
  | Host_not_allowed | Protocol_error | Key_exchange_failed
  | Auth_failed | Service_not_available | By_application
  | Too_many_connections

let bastion_state_to_tag = function
  | Connected -> 0 | Key_exchanged -> 1 | Authenticated -> 2
  | Channel_open -> 3 | Active -> 4 | Closed -> 5

let bastion_state_of_tag = function
  | 0 -> Some Connected | 1 -> Some Key_exchanged | 2 -> Some Authenticated
  | 3 -> Some Channel_open | 4 -> Some Active | 5 -> Some Closed
  | _ -> None

let kex_method_to_tag = function
  | Curve25519 -> 0 | Dh_group14 -> 1 | Dh_group16 -> 2
  | Ecdh_p256 -> 3 | Ecdh_p384 -> 4

let auth_method_to_tag = function
  | Public_key -> 0 | Password -> 1 | Keyboard -> 2 | Certificate -> 3

let auth_method_of_tag = function
  | 0 -> Some Public_key | 1 -> Some Password | 2 -> Some Keyboard
  | 3 -> Some Certificate | _ -> None

let channel_type_to_tag = function
  | Session -> 0 | Direct_tcp_ip -> 1 | Forwarded_tcp_ip -> 2 | Subsystem -> 3

let channel_state_of_tag = function
  | 0 -> Some Ch_opening | 1 -> Some Ch_open | 2 -> Some Ch_closing
  | 3 -> Some Ch_closed | _ -> None

let channel_type_of_tag = function
  | 0 -> Some Session | 1 -> Some Direct_tcp_ip | 2 -> Some Forwarded_tcp_ip
  | 3 -> Some Subsystem | _ -> None

let disconnect_reason_to_tag = function
  | Host_not_allowed -> 0 | Protocol_error -> 1 | Key_exchange_failed -> 2
  | Auth_failed -> 3 | Service_not_available -> 4 | By_application -> 5
  | Too_many_connections -> 6

let disconnect_reason_of_tag = function
  | 0 -> Some Host_not_allowed | 1 -> Some Protocol_error
  | 2 -> Some Key_exchange_failed | 3 -> Some Auth_failed
  | 4 -> Some Service_not_available | 5 -> Some By_application
  | 6 -> Some Too_many_connections | _ -> None

(* --- C FFI declarations --- *)

external c_ssh_bastion_abi_version : unit -> int = "ssh_bastion_abi_version"
external c_ssh_bastion_create : int -> int -> int = "ssh_bastion_create"
external c_ssh_bastion_destroy : int -> unit = "ssh_bastion_destroy"
external c_ssh_bastion_state : int -> int = "ssh_bastion_state"
external c_ssh_bastion_kex_method : int -> int = "ssh_bastion_kex_method"
external c_ssh_bastion_auth_method : int -> int = "ssh_bastion_auth_method"
external c_ssh_bastion_can_transfer : int -> int = "ssh_bastion_can_transfer"
external c_ssh_bastion_disconnect_reason : int -> int = "ssh_bastion_disconnect_reason"
external c_ssh_bastion_auth_failures : int -> int = "ssh_bastion_auth_failures"
external c_ssh_bastion_complete_kex : int -> int = "ssh_bastion_complete_kex"
external c_ssh_bastion_authenticate : int -> int -> int = "ssh_bastion_authenticate"
external c_ssh_bastion_record_auth_failure : int -> int = "ssh_bastion_record_auth_failure"
external c_ssh_bastion_open_channel : int -> int -> int = "ssh_bastion_open_channel"
external c_ssh_bastion_confirm_channel : int -> int -> int = "ssh_bastion_confirm_channel"
external c_ssh_bastion_close_channel : int -> int -> int = "ssh_bastion_close_channel"
external c_ssh_bastion_channel_state : int -> int -> int = "ssh_bastion_channel_state"
external c_ssh_bastion_channel_type : int -> int -> int = "ssh_bastion_channel_type"
external c_ssh_bastion_channel_count : int -> int = "ssh_bastion_channel_count"
external c_ssh_bastion_rekey : int -> int = "ssh_bastion_rekey"
external c_ssh_bastion_disconnect : int -> int -> int = "ssh_bastion_disconnect"
external c_ssh_bastion_can_transition : int -> int -> int = "ssh_bastion_can_transition"
external c_ssh_bastion_audit_count : int -> int = "ssh_bastion_audit_count"
external c_ssh_bastion_set_recording : int -> int -> int = "ssh_bastion_set_recording"
external c_ssh_bastion_is_recording : int -> int = "ssh_bastion_is_recording"

(* --- Safe wrappers --- *)

let abi_version () = c_ssh_bastion_abi_version ()

let create ~kex ~auth =
  Proven_error.from_slot
    (c_ssh_bastion_create (kex_method_to_tag kex) (auth_method_to_tag auth))

let destroy slot = c_ssh_bastion_destroy slot
let get_state slot = bastion_state_of_tag (c_ssh_bastion_state slot)

let get_kex_method slot =
  let tag = c_ssh_bastion_kex_method slot in
  if tag <= 4 then Some (match tag with
    | 0 -> Curve25519 | 1 -> Dh_group14 | 2 -> Dh_group16
    | 3 -> Ecdh_p256 | _ -> Ecdh_p384)
  else None

let get_auth_method slot = auth_method_of_tag (c_ssh_bastion_auth_method slot)
let can_transfer_data slot = c_ssh_bastion_can_transfer slot = 1
let get_disconnect_reason slot = disconnect_reason_of_tag (c_ssh_bastion_disconnect_reason slot)
let auth_failures slot = c_ssh_bastion_auth_failures slot
let complete_kex slot = Proven_error.from_status (c_ssh_bastion_complete_kex slot)
let authenticate slot = Proven_error.from_status (c_ssh_bastion_authenticate slot 0)
let record_auth_failure slot = c_ssh_bastion_record_auth_failure slot = 1

let open_channel slot ch_type =
  Proven_error.from_slot (c_ssh_bastion_open_channel slot (channel_type_to_tag ch_type))

let confirm_channel slot ch_id =
  Proven_error.from_status (c_ssh_bastion_confirm_channel slot ch_id)

let close_channel slot ch_id =
  Proven_error.from_status (c_ssh_bastion_close_channel slot ch_id)

let channel_state slot ch_id =
  channel_state_of_tag (c_ssh_bastion_channel_state slot ch_id)

let channel_type slot ch_id =
  channel_type_of_tag (c_ssh_bastion_channel_type slot ch_id)

let channel_count slot = c_ssh_bastion_channel_count slot
let rekey slot = Proven_error.from_status (c_ssh_bastion_rekey slot)

let disconnect slot reason =
  Proven_error.from_status (c_ssh_bastion_disconnect slot (disconnect_reason_to_tag reason))

let can_transition ~from ~to_ =
  c_ssh_bastion_can_transition (bastion_state_to_tag from) (bastion_state_to_tag to_) = 1

let audit_count slot = c_ssh_bastion_audit_count slot

let set_recording slot ~enabled =
  Proven_error.from_status (c_ssh_bastion_set_recording slot (if enabled then 1 else 0))

let is_recording slot = c_ssh_bastion_is_recording slot = 1
