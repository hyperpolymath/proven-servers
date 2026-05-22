(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** SSH protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ssh/ffi/zig/src/ssh.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for message types, auth methods,
    key exchange methods, channel types, bastion states, channel states,
    disconnect reasons, host key algorithms, cipher algorithms, and
    channel open failures. *)

(** SSH message types matching [SshMessageType] in ssh.zig. *)
type ssh_message_type =
  | Kexinit | Newkeys | Service_request | Userauth_request
  | Channel_open | Channel_data | Channel_close | Disconnect

(** SSH authentication methods matching [AuthMethod] in ssh.zig. *)
type auth_method = Publickey | Password | Keyboard_interactive | Auth_none

(** Key exchange methods matching [KexMethod] in ssh.zig. *)
type kex_method =
  | Diffie_hellman_group14_sha256 | Curve25519_sha256
  | Diffie_hellman_group16_sha512 | Diffie_hellman_group18_sha512
  | Ecdh_sha2_nistp256 | Ecdh_sha2_nistp384

(** SSH channel types matching [ChannelType] in ssh.zig. *)
type channel_type = Session | Direct_tcpip | Forwarded_tcpip | X11

(** SSH bastion states matching [BastionState] in ssh.zig. *)
type bastion_state =
  | Connected | Key_exchanged | Authenticated | Bastion_channel_open
  | Active | Bastion_closed

(** SSH channel states matching [ChannelState] in ssh.zig. *)
type channel_state = Opening | Open | Closing | Channel_closed

(** SSH disconnect reasons matching [DisconnectReason] in ssh.zig. *)
type disconnect_reason =
  | Host_not_allowed | Protocol_error | Key_exchange_failed
  | Host_auth_failed | Mac_error | Service_not_available
  | Version_not_supported | Host_key_not_verifiable | Connection_lost
  | By_application | Too_many_connections | Auth_cancelled

(** SSH host key algorithms matching [HostKeyAlgorithm] in ssh.zig. *)
type host_key_algorithm =
  | Ssh_ed25519 | Rsa_sha2_256 | Rsa_sha2_512 | Ecdsa_nistp256

(** SSH cipher algorithms matching [CipherAlgorithm] in ssh.zig. *)
type cipher_algorithm =
  | Chacha20_poly1305 | Aes256_gcm | Aes128_gcm
  | Aes256_ctr | Aes192_ctr | Aes128_ctr

(** SSH channel open failure reasons matching [ChannelOpenFailure] in ssh.zig. *)
type channel_open_failure =
  | Admin_prohibited | Connect_failed | Unknown_channel_type | Resource_shortage

(** Convert a message type to its ABI tag value. *)
let ssh_message_type_to_tag = function
  | Kexinit -> 0 | Newkeys -> 1 | Service_request -> 2
  | Userauth_request -> 3 | Channel_open -> 4 | Channel_data -> 5
  | Channel_close -> 6 | Disconnect -> 7

(** Decode a message type from its ABI tag value. *)
let ssh_message_type_of_tag = function
  | 0 -> Some Kexinit | 1 -> Some Newkeys | 2 -> Some Service_request
  | 3 -> Some Userauth_request | 4 -> Some Channel_open
  | 5 -> Some Channel_data | 6 -> Some Channel_close
  | 7 -> Some Disconnect | _ -> None

(** Convert an auth method to its ABI tag value. *)
let auth_method_to_tag = function
  | Publickey -> 0 | Password -> 1 | Keyboard_interactive -> 2
  | Auth_none -> 3

(** Decode an auth method from its ABI tag value. *)
let auth_method_of_tag = function
  | 0 -> Some Publickey | 1 -> Some Password
  | 2 -> Some Keyboard_interactive | 3 -> Some Auth_none | _ -> None

(** Convert a key exchange method to its ABI tag value. *)
let kex_method_to_tag = function
  | Diffie_hellman_group14_sha256 -> 0 | Curve25519_sha256 -> 1
  | Diffie_hellman_group16_sha512 -> 2 | Diffie_hellman_group18_sha512 -> 3
  | Ecdh_sha2_nistp256 -> 4 | Ecdh_sha2_nistp384 -> 5

(** Decode a key exchange method from its ABI tag value. *)
let kex_method_of_tag = function
  | 0 -> Some Diffie_hellman_group14_sha256 | 1 -> Some Curve25519_sha256
  | 2 -> Some Diffie_hellman_group16_sha512
  | 3 -> Some Diffie_hellman_group18_sha512
  | 4 -> Some Ecdh_sha2_nistp256 | 5 -> Some Ecdh_sha2_nistp384 | _ -> None

(** Convert a channel type to its ABI tag value. *)
let channel_type_to_tag = function
  | Session -> 0 | Direct_tcpip -> 1 | Forwarded_tcpip -> 2 | X11 -> 3

(** Decode a channel type from its ABI tag value. *)
let channel_type_of_tag = function
  | 0 -> Some Session | 1 -> Some Direct_tcpip
  | 2 -> Some Forwarded_tcpip | 3 -> Some X11 | _ -> None

(** Convert a bastion state to its ABI tag value. *)
let bastion_state_to_tag = function
  | Connected -> 0 | Key_exchanged -> 1 | Authenticated -> 2
  | Bastion_channel_open -> 3 | Active -> 4 | Bastion_closed -> 5

(** Decode a bastion state from its ABI tag value. *)
let bastion_state_of_tag = function
  | 0 -> Some Connected | 1 -> Some Key_exchanged | 2 -> Some Authenticated
  | 3 -> Some Bastion_channel_open | 4 -> Some Active
  | 5 -> Some Bastion_closed | _ -> None

(** Convert a channel state to its ABI tag value. *)
let channel_state_to_tag = function
  | Opening -> 0 | Open -> 1 | Closing -> 2 | Channel_closed -> 3

(** Decode a channel state from its ABI tag value. *)
let channel_state_of_tag = function
  | 0 -> Some Opening | 1 -> Some Open | 2 -> Some Closing
  | 3 -> Some Channel_closed | _ -> None

(** Convert a disconnect reason to its ABI tag value. *)
let disconnect_reason_to_tag = function
  | Host_not_allowed -> 0 | Protocol_error -> 1 | Key_exchange_failed -> 2
  | Host_auth_failed -> 3 | Mac_error -> 4 | Service_not_available -> 5
  | Version_not_supported -> 6 | Host_key_not_verifiable -> 7
  | Connection_lost -> 8 | By_application -> 9
  | Too_many_connections -> 10 | Auth_cancelled -> 11

(** Decode a disconnect reason from its ABI tag value. *)
let disconnect_reason_of_tag = function
  | 0 -> Some Host_not_allowed | 1 -> Some Protocol_error
  | 2 -> Some Key_exchange_failed | 3 -> Some Host_auth_failed
  | 4 -> Some Mac_error | 5 -> Some Service_not_available
  | 6 -> Some Version_not_supported | 7 -> Some Host_key_not_verifiable
  | 8 -> Some Connection_lost | 9 -> Some By_application
  | 10 -> Some Too_many_connections | 11 -> Some Auth_cancelled | _ -> None

(** Convert a host key algorithm to its ABI tag value. *)
let host_key_algorithm_to_tag = function
  | Ssh_ed25519 -> 0 | Rsa_sha2_256 -> 1 | Rsa_sha2_512 -> 2
  | Ecdsa_nistp256 -> 3

(** Decode a host key algorithm from its ABI tag value. *)
let host_key_algorithm_of_tag = function
  | 0 -> Some Ssh_ed25519 | 1 -> Some Rsa_sha2_256
  | 2 -> Some Rsa_sha2_512 | 3 -> Some Ecdsa_nistp256 | _ -> None

(** Convert a cipher algorithm to its ABI tag value. *)
let cipher_algorithm_to_tag = function
  | Chacha20_poly1305 -> 0 | Aes256_gcm -> 1 | Aes128_gcm -> 2
  | Aes256_ctr -> 3 | Aes192_ctr -> 4 | Aes128_ctr -> 5

(** Decode a cipher algorithm from its ABI tag value. *)
let cipher_algorithm_of_tag = function
  | 0 -> Some Chacha20_poly1305 | 1 -> Some Aes256_gcm | 2 -> Some Aes128_gcm
  | 3 -> Some Aes256_ctr | 4 -> Some Aes192_ctr | 5 -> Some Aes128_ctr
  | _ -> None

(** Convert a channel open failure to its ABI tag value. *)
let channel_open_failure_to_tag = function
  | Admin_prohibited -> 0 | Connect_failed -> 1
  | Unknown_channel_type -> 2 | Resource_shortage -> 3

(** Decode a channel open failure from its ABI tag value. *)
let channel_open_failure_of_tag = function
  | 0 -> Some Admin_prohibited | 1 -> Some Connect_failed
  | 2 -> Some Unknown_channel_type | 3 -> Some Resource_shortage | _ -> None

(* --- C FFI declarations --- *)

external c_ssh_abi_version : unit -> int = "ssh_abi_version"
external c_ssh_create_context : unit -> int = "ssh_create_context"
external c_ssh_destroy_context : int -> unit = "ssh_destroy_context"
external c_ssh_can_transition : int -> int -> int = "ssh_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_ssh]. *)
let abi_version () = c_ssh_abi_version ()

(** Create a new SSH context. *)
let create_context () =
  Proven_error.from_slot (c_ssh_create_context ())

(** Destroy an SSH context, releasing its slot. *)
let destroy_context slot = c_ssh_destroy_context slot

(** Stateless query: check whether a bastion state transition is valid. *)
let can_transition ~from ~to_ =
  c_ssh_can_transition (bastion_state_to_tag from) (bastion_state_to_tag to_) = 1
