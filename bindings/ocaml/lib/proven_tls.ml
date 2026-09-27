(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** TLS protocol bindings for proven-servers.

    Models the TLS handshake lifecycle state machine (ClientHello ->
    ServerHello -> ... -> Established) and provides cipher suite and
    protocol version negotiation. *)

(** TLS handshake lifecycle states. *)
type tls_state =
  | Idle           (** No handshake initiated. *)
  | Client_hello   (** ClientHello sent/received. *)
  | Server_hello   (** ServerHello sent/received. *)
  | Negotiating    (** Certificate and key exchange in progress. *)
  | Established    (** Handshake complete, secure channel active. *)
  | Renegotiating  (** Renegotiation in progress. *)
  | Shutdown       (** TLS shutdown (close_notify sent). *)

(** TLS protocol versions. *)
type tls_version =
  | Tls12 (** TLS 1.2 (RFC 5246). *)
  | Tls13 (** TLS 1.3 (RFC 8446). *)

(** TLS cipher suites (subset of common suites). *)
type cipher_suite =
  | Aes_gcm_128_sha256        (** TLS_AES_128_GCM_SHA256. *)
  | Aes_gcm_256_sha384        (** TLS_AES_256_GCM_SHA384. *)
  | Chacha20_poly1305_sha256  (** TLS_CHACHA20_POLY1305_SHA256. *)
  | Aes_ccm_128_sha256        (** TLS_AES_128_CCM_SHA256. *)

let tls_state_to_tag = function
  | Idle -> 0 | Client_hello -> 1 | Server_hello -> 2 | Negotiating -> 3
  | Established -> 4 | Renegotiating -> 5 | Shutdown -> 6

let tls_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Client_hello | 2 -> Some Server_hello
  | 3 -> Some Negotiating | 4 -> Some Established
  | 5 -> Some Renegotiating | 6 -> Some Shutdown | _ -> None

let tls_version_to_tag = function
  | Tls12 -> 0 | Tls13 -> 1

let tls_version_of_tag = function
  | 0 -> Some Tls12 | 1 -> Some Tls13 | _ -> None

let cipher_suite_to_tag = function
  | Aes_gcm_128_sha256 -> 0 | Aes_gcm_256_sha384 -> 1
  | Chacha20_poly1305_sha256 -> 2 | Aes_ccm_128_sha256 -> 3

let cipher_suite_of_tag = function
  | 0 -> Some Aes_gcm_128_sha256 | 1 -> Some Aes_gcm_256_sha384
  | 2 -> Some Chacha20_poly1305_sha256 | 3 -> Some Aes_ccm_128_sha256
  | _ -> None

(* --- Disabled native FFI declarations --- *)
(* Raw Zig C symbols are not OCaml primitives. All operations
   raise a clear exception until OCaml-compatible stubs exist. *)

let c_tls_abi_version : unit -> int = fun () ->
  Proven_unavailable.raise_unavailable ()
let c_tls_create_context : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_tls_destroy_context : int -> unit = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_tls_state : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_tls_version : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_tls_cipher_suite : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_tls_is_handshake_complete : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_tls_begin_handshake : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_tls_complete_handshake : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_tls_renegotiate : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_tls_shutdown : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_tls_can_transition : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked TLS library. *)
let abi_version () = c_tls_abi_version ()

(** Create a new TLS context with the given version and cipher suite. *)
let create_context ~version ~cipher =
  Proven_error.from_slot
    (c_tls_create_context (tls_version_to_tag version) (cipher_suite_to_tag cipher))

(** Destroy a TLS context, releasing its slot. *)
let destroy_context slot = c_tls_destroy_context slot

(** Get the current handshake state. *)
let get_state slot = tls_state_of_tag (c_tls_state slot)

(** Get the negotiated TLS version. *)
let get_version slot = tls_version_of_tag (c_tls_version slot)

(** Get the negotiated cipher suite. *)
let get_cipher_suite slot = cipher_suite_of_tag (c_tls_cipher_suite slot)

(** Check if the handshake is complete and a secure channel is active. *)
let is_handshake_complete slot = c_tls_is_handshake_complete slot = 1

(** Begin the TLS handshake. Transitions Idle -> Client_hello. *)
let begin_handshake slot =
  Proven_error.from_status (c_tls_begin_handshake slot)

(** Complete the TLS handshake. Transitions Negotiating -> Established. *)
let complete_handshake slot =
  Proven_error.from_status (c_tls_complete_handshake slot)

(** Initiate renegotiation. Transitions Established -> Renegotiating. *)
let renegotiate slot =
  Proven_error.from_status (c_tls_renegotiate slot)

(** Send close_notify and shut down the TLS session. *)
let shutdown slot =
  Proven_error.from_status (c_tls_shutdown slot)

(** Stateless query: check whether a TLS state transition is valid. *)
let can_transition ~from ~to_ =
  c_tls_can_transition (tls_state_to_tag from) (tls_state_to_tag to_) = 1
