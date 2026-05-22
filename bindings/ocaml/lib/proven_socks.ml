(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** SOCKS5 proxy protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-socks/ffi/zig/src/socks.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for auth methods, commands,
    address types, replies, and states. *)

(** SOCKS5 authentication methods matching [AuthMethod] in socks.zig. *)
type auth_method = No_auth | Gssapi | Username_password | No_acceptable

(** SOCKS5 commands matching [Command] in socks.zig. *)
type command = Connect | Bind | Udp_associate

(** SOCKS5 address types matching [AddressType] in socks.zig. *)
type address_type = IPv4 | Domain_name | IPv6

(** SOCKS5 reply codes matching [Reply] in socks.zig. *)
type reply =
  | Succeeded | General_failure | Not_allowed | Network_unreachable
  | Host_unreachable | Connection_refused | Ttl_expired
  | Command_not_supported | Address_type_not_supported

(** SOCKS5 connection states matching [State] in socks.zig. *)
type state =
  | Initial | Authenticating | Authenticated | Connecting
  | Established | Closed

(** Convert an auth method to its ABI tag value. *)
let auth_method_to_tag = function
  | No_auth -> 0 | Gssapi -> 1 | Username_password -> 2 | No_acceptable -> 3

(** Decode an auth method from its ABI tag value. *)
let auth_method_of_tag = function
  | 0 -> Some No_auth | 1 -> Some Gssapi | 2 -> Some Username_password
  | 3 -> Some No_acceptable | _ -> None

(** Convert a command to its ABI tag value. *)
let command_to_tag = function
  | Connect -> 0 | Bind -> 1 | Udp_associate -> 2

(** Decode a command from its ABI tag value. *)
let command_of_tag = function
  | 0 -> Some Connect | 1 -> Some Bind | 2 -> Some Udp_associate | _ -> None

(** Convert an address type to its ABI tag value. *)
let address_type_to_tag = function
  | IPv4 -> 0 | Domain_name -> 1 | IPv6 -> 2

(** Decode an address type from its ABI tag value. *)
let address_type_of_tag = function
  | 0 -> Some IPv4 | 1 -> Some Domain_name | 2 -> Some IPv6 | _ -> None

(** Convert a reply to its ABI tag value. *)
let reply_to_tag = function
  | Succeeded -> 0 | General_failure -> 1 | Not_allowed -> 2
  | Network_unreachable -> 3 | Host_unreachable -> 4
  | Connection_refused -> 5 | Ttl_expired -> 6
  | Command_not_supported -> 7 | Address_type_not_supported -> 8

(** Decode a reply from its ABI tag value. *)
let reply_of_tag = function
  | 0 -> Some Succeeded | 1 -> Some General_failure | 2 -> Some Not_allowed
  | 3 -> Some Network_unreachable | 4 -> Some Host_unreachable
  | 5 -> Some Connection_refused | 6 -> Some Ttl_expired
  | 7 -> Some Command_not_supported | 8 -> Some Address_type_not_supported
  | _ -> None

(** Convert a state to its ABI tag value. *)
let state_to_tag = function
  | Initial -> 0 | Authenticating -> 1 | Authenticated -> 2
  | Connecting -> 3 | Established -> 4 | Closed -> 5

(** Decode a state from its ABI tag value. *)
let state_of_tag = function
  | 0 -> Some Initial | 1 -> Some Authenticating | 2 -> Some Authenticated
  | 3 -> Some Connecting | 4 -> Some Established | 5 -> Some Closed | _ -> None

(* --- C FFI declarations --- *)

external c_socks_abi_version : unit -> int = "socks_abi_version"
external c_socks_create_context : unit -> int = "socks_create_context"
external c_socks_destroy_context : int -> unit = "socks_destroy_context"
external c_socks_can_transition : int -> int -> int = "socks_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_socks]. *)
let abi_version () = c_socks_abi_version ()

(** Create a new SOCKS5 context. *)
let create_context () =
  Proven_error.from_slot (c_socks_create_context ())

(** Destroy a SOCKS5 context, releasing its slot. *)
let destroy_context slot = c_socks_destroy_context slot

(** Stateless query: check whether a state transition is valid. *)
let can_transition ~from ~to_ =
  c_socks_can_transition (state_to_tag from) (state_to_tag to_) = 1
