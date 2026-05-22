(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** OSPF protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ospf/ffi/zig/src/ospf.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for packet types, neighbor states,
    LSA types, area types, and error codes. *)

(** OSPF packet types matching [PacketType] in ospf.zig. *)
type packet_type =
  | Hello | Database_description | Link_state_request
  | Link_state_update | Link_state_ack

(** OSPF neighbor states matching [NeighborState] in ospf.zig. *)
type neighbor_state =
  | Down | Attempt | Init | Two_way | Ex_start
  | Exchange | Loading | Full

(** Link-State Advertisement types matching [LsaType] in ospf.zig. *)
type lsa_type =
  | Router_lsa | Network_lsa | Summary_lsa | Asbr_summary_lsa | As_external_lsa

(** OSPF area types matching [AreaType] in ospf.zig. *)
type area_type = Normal | Stub | Totally_stub | Nssa

(** OSPF error codes matching [OspfError] in ospf.zig. *)
type ospf_error =
  | Ok | Invalid_slot | Not_active | Invalid_transition
  | Invalid_packet | Area_error | Flood_limit

(** Convert a packet type to its ABI tag value. *)
let packet_type_to_tag = function
  | Hello -> 0 | Database_description -> 1 | Link_state_request -> 2
  | Link_state_update -> 3 | Link_state_ack -> 4

(** Decode a packet type from its ABI tag value. *)
let packet_type_of_tag = function
  | 0 -> Some Hello | 1 -> Some Database_description
  | 2 -> Some Link_state_request | 3 -> Some Link_state_update
  | 4 -> Some Link_state_ack | _ -> None

(** Convert a neighbor state to its ABI tag value. *)
let neighbor_state_to_tag = function
  | Down -> 0 | Attempt -> 1 | Init -> 2 | Two_way -> 3
  | Ex_start -> 4 | Exchange -> 5 | Loading -> 6 | Full -> 7

(** Decode a neighbor state from its ABI tag value. *)
let neighbor_state_of_tag = function
  | 0 -> Some Down | 1 -> Some Attempt | 2 -> Some Init | 3 -> Some Two_way
  | 4 -> Some Ex_start | 5 -> Some Exchange | 6 -> Some Loading
  | 7 -> Some Full | _ -> None

(** Convert an LSA type to its ABI tag value. *)
let lsa_type_to_tag = function
  | Router_lsa -> 0 | Network_lsa -> 1 | Summary_lsa -> 2
  | Asbr_summary_lsa -> 3 | As_external_lsa -> 4

(** Decode an LSA type from its ABI tag value. *)
let lsa_type_of_tag = function
  | 0 -> Some Router_lsa | 1 -> Some Network_lsa | 2 -> Some Summary_lsa
  | 3 -> Some Asbr_summary_lsa | 4 -> Some As_external_lsa | _ -> None

(** Convert an area type to its ABI tag value. *)
let area_type_to_tag = function
  | Normal -> 0 | Stub -> 1 | Totally_stub -> 2 | Nssa -> 3

(** Decode an area type from its ABI tag value. *)
let area_type_of_tag = function
  | 0 -> Some Normal | 1 -> Some Stub | 2 -> Some Totally_stub
  | 3 -> Some Nssa | _ -> None

(** Convert an error to its ABI tag value. *)
let ospf_error_to_tag = function
  | Ok -> 0 | Invalid_slot -> 1 | Not_active -> 2 | Invalid_transition -> 3
  | Invalid_packet -> 4 | Area_error -> 5 | Flood_limit -> 6

(** Decode an error from its ABI tag value. *)
let ospf_error_of_tag = function
  | 0 -> Some Ok | 1 -> Some Invalid_slot | 2 -> Some Not_active
  | 3 -> Some Invalid_transition | 4 -> Some Invalid_packet
  | 5 -> Some Area_error | 6 -> Some Flood_limit | _ -> None

(* --- C FFI declarations --- *)

external c_ospf_abi_version : unit -> int = "ospf_abi_version"
external c_ospf_create_context : unit -> int = "ospf_create_context"
external c_ospf_destroy_context : int -> unit = "ospf_destroy_context"
external c_ospf_can_transition : int -> int -> int = "ospf_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_ospf]. *)
let abi_version () = c_ospf_abi_version ()

(** Create a new OSPF context. *)
let create_context () =
  Proven_error.from_slot (c_ospf_create_context ())

(** Destroy an OSPF context, releasing its slot. *)
let destroy_context slot = c_ospf_destroy_context slot

(** Stateless query: check whether a neighbor state transition is valid. *)
let can_transition ~from ~to_ =
  c_ospf_can_transition (neighbor_state_to_tag from) (neighbor_state_to_tag to_) = 1
