(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** VPN/IPsec protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-vpn/ffi/zig/src/vpn.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for tunnel types, phases,
    encryption algorithms, integrity algorithms, DH groups, SA lifecycles,
    IKE versions, and error codes. *)

(** VPN tunnel types matching [TunnelType] in vpn.zig. *)
type tunnel_type = Ipsec | Wireguard | Openvpn | L2tp

(** VPN tunnel phases matching [TunnelPhase] in vpn.zig. *)
type tunnel_phase =
  | Idle | Phase1_init | Phase1_auth | Phase1_done
  | Phase2_negotiating | Established | Phase_expired

(** VPN encryption algorithms matching [EncryptionAlgorithm] in vpn.zig. *)
type encryption_algorithm =
  | Aes128_cbc | Aes256_cbc | Aes128_gcm | Aes256_gcm
  | Chacha20_poly1305 | Null_cipher

(** VPN integrity algorithms matching [IntegrityAlgorithm] in vpn.zig. *)
type integrity_algorithm =
  | Hmac_sha1 | Hmac_sha256 | Hmac_sha384 | Hmac_sha512 | No_integrity

(** Diffie-Hellman groups matching [DhGroup] in vpn.zig. *)
type dh_group = Dh14 | Ecp256 | Ecp384 | Curve25519

(** Security Association lifecycles matching [SaLifecycle] in vpn.zig. *)
type sa_lifecycle = Sa_none | Sa_active | Rekeying | Sa_expired | Deleted

(** IKE protocol versions matching [IkeVersion] in vpn.zig. *)
type ike_version = V1 | V2

(** VPN error codes matching [VpnError] in vpn.zig. *)
type vpn_error =
  | Authentication_failed | No_proposal_chosen | Lifetime_expired
  | Invalid_spi | Replay_detected | Negotiation_timeout

(** Convert a tunnel type to its ABI tag value. *)
let tunnel_type_to_tag = function
  | Ipsec -> 0 | Wireguard -> 1 | Openvpn -> 2 | L2tp -> 3

(** Decode a tunnel type from its ABI tag value. *)
let tunnel_type_of_tag = function
  | 0 -> Some Ipsec | 1 -> Some Wireguard | 2 -> Some Openvpn
  | 3 -> Some L2tp | _ -> None

(** Convert a tunnel phase to its ABI tag value. *)
let tunnel_phase_to_tag = function
  | Idle -> 0 | Phase1_init -> 1 | Phase1_auth -> 2 | Phase1_done -> 3
  | Phase2_negotiating -> 4 | Established -> 5 | Phase_expired -> 6

(** Decode a tunnel phase from its ABI tag value. *)
let tunnel_phase_of_tag = function
  | 0 -> Some Idle | 1 -> Some Phase1_init | 2 -> Some Phase1_auth
  | 3 -> Some Phase1_done | 4 -> Some Phase2_negotiating
  | 5 -> Some Established | 6 -> Some Phase_expired | _ -> None

(** Convert an encryption algorithm to its ABI tag value. *)
let encryption_algorithm_to_tag = function
  | Aes128_cbc -> 0 | Aes256_cbc -> 1 | Aes128_gcm -> 2
  | Aes256_gcm -> 3 | Chacha20_poly1305 -> 4 | Null_cipher -> 5

(** Decode an encryption algorithm from its ABI tag value. *)
let encryption_algorithm_of_tag = function
  | 0 -> Some Aes128_cbc | 1 -> Some Aes256_cbc | 2 -> Some Aes128_gcm
  | 3 -> Some Aes256_gcm | 4 -> Some Chacha20_poly1305
  | 5 -> Some Null_cipher | _ -> None

(** Convert an integrity algorithm to its ABI tag value. *)
let integrity_algorithm_to_tag = function
  | Hmac_sha1 -> 0 | Hmac_sha256 -> 1 | Hmac_sha384 -> 2
  | Hmac_sha512 -> 3 | No_integrity -> 4

(** Decode an integrity algorithm from its ABI tag value. *)
let integrity_algorithm_of_tag = function
  | 0 -> Some Hmac_sha1 | 1 -> Some Hmac_sha256 | 2 -> Some Hmac_sha384
  | 3 -> Some Hmac_sha512 | 4 -> Some No_integrity | _ -> None

(** Convert a DH group to its ABI tag value. *)
let dh_group_to_tag = function
  | Dh14 -> 0 | Ecp256 -> 1 | Ecp384 -> 2 | Curve25519 -> 3

(** Decode a DH group from its ABI tag value. *)
let dh_group_of_tag = function
  | 0 -> Some Dh14 | 1 -> Some Ecp256 | 2 -> Some Ecp384
  | 3 -> Some Curve25519 | _ -> None

(** Convert an SA lifecycle state to its ABI tag value. *)
let sa_lifecycle_to_tag = function
  | Sa_none -> 0 | Sa_active -> 1 | Rekeying -> 2
  | Sa_expired -> 3 | Deleted -> 4

(** Decode an SA lifecycle state from its ABI tag value. *)
let sa_lifecycle_of_tag = function
  | 0 -> Some Sa_none | 1 -> Some Sa_active | 2 -> Some Rekeying
  | 3 -> Some Sa_expired | 4 -> Some Deleted | _ -> None

(** Convert an IKE version to its ABI tag value. *)
let ike_version_to_tag = function
  | V1 -> 0 | V2 -> 1

(** Decode an IKE version from its ABI tag value. *)
let ike_version_of_tag = function
  | 0 -> Some V1 | 1 -> Some V2 | _ -> None

(** Convert a VPN error to its ABI tag value. *)
let vpn_error_to_tag = function
  | Authentication_failed -> 0 | No_proposal_chosen -> 1
  | Lifetime_expired -> 2 | Invalid_spi -> 3
  | Replay_detected -> 4 | Negotiation_timeout -> 5

(** Decode a VPN error from its ABI tag value. *)
let vpn_error_of_tag = function
  | 0 -> Some Authentication_failed | 1 -> Some No_proposal_chosen
  | 2 -> Some Lifetime_expired | 3 -> Some Invalid_spi
  | 4 -> Some Replay_detected | 5 -> Some Negotiation_timeout | _ -> None

(* --- C FFI declarations --- *)

external c_vpn_abi_version : unit -> int = "vpn_abi_version"
external c_vpn_create_context : unit -> int = "vpn_create_context"
external c_vpn_destroy_context : int -> unit = "vpn_destroy_context"
external c_vpn_can_transition : int -> int -> int = "vpn_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_vpn]. *)
let abi_version () = c_vpn_abi_version ()

(** Create a new VPN context. *)
let create_context () =
  Proven_error.from_slot (c_vpn_create_context ())

(** Destroy a VPN context, releasing its slot. *)
let destroy_context slot = c_vpn_destroy_context slot

(** Stateless query: check whether a tunnel phase transition is valid. *)
let can_transition ~from ~to_ =
  c_vpn_can_transition (tunnel_phase_to_tag from) (tunnel_phase_to_tag to_) = 1
