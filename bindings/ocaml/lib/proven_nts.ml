(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Network Time Security (RFC 8915) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-nts/ffi/zig/src/nts.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for record types, error codes, AEAD
    algorithms, handshake states, and session states. *)

(** NTS-KE record types matching [RecordType] in nts.zig. *)
type record_type =
  | EndOfMessage | NextProtocol | Error | Warning | AeadAlgorithm
  | Cookie | CookiePlaceholder | NtskeServer | NtskePort

(** NTS error codes matching [ErrorCode] in nts.zig. *)
type error_code =
  | UnrecognizedCritical | BadRequest | InternalError

(** AEAD algorithms matching [AeadAlgorithm] in nts.zig. *)
type aead_algorithm =
  | AeadAes128Gcm | AeadAes256Gcm | AeadAesSivCmac256

(** Handshake states matching [HandshakeState] in nts.zig. *)
type handshake_state =
  | Initial | Negotiating | Established | Failed

(** Session states matching [SessionState] in nts.zig. *)
type session_state =
  | Idle | Handshaking | SessionNegotiating | SessionEstablished | Closing

(** Convert a record type to its ABI tag value. *)
let record_type_to_tag = function
  | EndOfMessage -> 0 | NextProtocol -> 1 | Error -> 2 | Warning -> 3
  | AeadAlgorithm -> 4 | Cookie -> 5 | CookiePlaceholder -> 6
  | NtskeServer -> 7 | NtskePort -> 8

(** Decode a record type from its ABI tag value. *)
let record_type_of_tag = function
  | 0 -> Some EndOfMessage | 1 -> Some NextProtocol | 2 -> Some Error
  | 3 -> Some Warning | 4 -> Some AeadAlgorithm | 5 -> Some Cookie
  | 6 -> Some CookiePlaceholder | 7 -> Some NtskeServer
  | 8 -> Some NtskePort | _ -> None

(** Convert an error code to its ABI tag value. *)
let error_code_to_tag = function
  | UnrecognizedCritical -> 0 | BadRequest -> 1 | InternalError -> 2

(** Decode an error code from its ABI tag value. *)
let error_code_of_tag = function
  | 0 -> Some UnrecognizedCritical | 1 -> Some BadRequest
  | 2 -> Some InternalError | _ -> None

(** Convert an AEAD algorithm to its ABI tag value. *)
let aead_algorithm_to_tag = function
  | AeadAes128Gcm -> 0 | AeadAes256Gcm -> 1 | AeadAesSivCmac256 -> 2

(** Decode an AEAD algorithm from its ABI tag value. *)
let aead_algorithm_of_tag = function
  | 0 -> Some AeadAes128Gcm | 1 -> Some AeadAes256Gcm
  | 2 -> Some AeadAesSivCmac256 | _ -> None

(** Convert a handshake state to its ABI tag value. *)
let handshake_state_to_tag = function
  | Initial -> 0 | Negotiating -> 1 | Established -> 2 | Failed -> 3

(** Decode a handshake state from its ABI tag value. *)
let handshake_state_of_tag = function
  | 0 -> Some Initial | 1 -> Some Negotiating | 2 -> Some Established
  | 3 -> Some Failed | _ -> None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | Handshaking -> 1 | SessionNegotiating -> 2
  | SessionEstablished -> 3 | Closing -> 4

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Handshaking | 2 -> Some SessionNegotiating
  | 3 -> Some SessionEstablished | 4 -> Some Closing | _ -> None

(* --- C FFI declarations --- *)

external c_nts_abi_version : unit -> int = "nts_abi_version"
external c_nts_create_context : unit -> int = "nts_create_context"
external c_nts_destroy_context : int -> unit = "nts_destroy_context"
external c_nts_can_transition : int -> int -> int = "nts_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_nts]. *)
let abi_version () = c_nts_abi_version ()

(** Create a new NTS context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_nts_create_context ())

(** Destroy an NTS context, releasing its slot. *)
let destroy_context slot = c_nts_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_nts_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
