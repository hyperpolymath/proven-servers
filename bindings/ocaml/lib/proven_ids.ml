(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Intrusion Detection System protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ids/ffi/zig/src/ids.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for alert severities, detection methods,
    protocols, actions, and threat levels. *)

(** Alert severity levels matching [AlertSeverity] in ids.zig. *)
type alert_severity =
  | AlertSeverity_Low | AlertSeverity_Medium
  | AlertSeverity_High | AlertSeverity_Critical

(** Detection methods matching [DetectionMethod] in ids.zig. *)
type detection_method =
  | Signature | Anomaly | Stateful | Heuristic

(** Network protocols matching [IdsProtocol] in ids.zig. *)
type ids_protocol =
  | Tcp | Udp | Icmp | Dns | Http | Tls | Ssh

(** IDS response actions matching [IdsAction] in ids.zig. *)
type ids_action =
  | Alert | Drop | Log | Block | Pass

(** Traffic direction matching [Direction] in ids.zig. *)
type direction =
  | Inbound | Outbound | Both

(** Threat levels matching [ThreatLevel] in ids.zig. *)
type threat_level =
  | Info | ThreatLevel_Low | ThreatLevel_Medium
  | ThreatLevel_High | ThreatLevel_Critical

(** Convert an alert severity to its ABI tag value. *)
let alert_severity_to_tag = function
  | AlertSeverity_Low -> 0 | AlertSeverity_Medium -> 1
  | AlertSeverity_High -> 2 | AlertSeverity_Critical -> 3

(** Decode an alert severity from its ABI tag value. *)
let alert_severity_of_tag = function
  | 0 -> Some AlertSeverity_Low | 1 -> Some AlertSeverity_Medium
  | 2 -> Some AlertSeverity_High | 3 -> Some AlertSeverity_Critical
  | _ -> None

(** Convert a detection method to its ABI tag value. *)
let detection_method_to_tag = function
  | Signature -> 0 | Anomaly -> 1 | Stateful -> 2 | Heuristic -> 3

(** Decode a detection method from its ABI tag value. *)
let detection_method_of_tag = function
  | 0 -> Some Signature | 1 -> Some Anomaly | 2 -> Some Stateful
  | 3 -> Some Heuristic | _ -> None

(** Convert an IDS protocol to its ABI tag value. *)
let ids_protocol_to_tag = function
  | Tcp -> 0 | Udp -> 1 | Icmp -> 2 | Dns -> 3 | Http -> 4
  | Tls -> 5 | Ssh -> 6

(** Decode an IDS protocol from its ABI tag value. *)
let ids_protocol_of_tag = function
  | 0 -> Some Tcp | 1 -> Some Udp | 2 -> Some Icmp | 3 -> Some Dns
  | 4 -> Some Http | 5 -> Some Tls | 6 -> Some Ssh | _ -> None

(** Convert an IDS action to its ABI tag value. *)
let ids_action_to_tag = function
  | Alert -> 0 | Drop -> 1 | Log -> 2 | Block -> 3 | Pass -> 4

(** Decode an IDS action from its ABI tag value. *)
let ids_action_of_tag = function
  | 0 -> Some Alert | 1 -> Some Drop | 2 -> Some Log
  | 3 -> Some Block | 4 -> Some Pass | _ -> None

(** Convert a direction to its ABI tag value. *)
let direction_to_tag = function
  | Inbound -> 0 | Outbound -> 1 | Both -> 2

(** Decode a direction from its ABI tag value. *)
let direction_of_tag = function
  | 0 -> Some Inbound | 1 -> Some Outbound | 2 -> Some Both | _ -> None

(** Convert a threat level to its ABI tag value. *)
let threat_level_to_tag = function
  | Info -> 0 | ThreatLevel_Low -> 1 | ThreatLevel_Medium -> 2
  | ThreatLevel_High -> 3 | ThreatLevel_Critical -> 4

(** Decode a threat level from its ABI tag value. *)
let threat_level_of_tag = function
  | 0 -> Some Info | 1 -> Some ThreatLevel_Low | 2 -> Some ThreatLevel_Medium
  | 3 -> Some ThreatLevel_High | 4 -> Some ThreatLevel_Critical | _ -> None

(* --- C FFI declarations --- *)

external c_ids_abi_version : unit -> int = "ids_abi_version"
external c_ids_create_context : unit -> int = "ids_create_context"
external c_ids_destroy_context : int -> unit = "ids_destroy_context"
external c_ids_can_transition : int -> int -> int = "ids_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_ids]. *)
let abi_version () = c_ids_abi_version ()

(** Create a new IDS context. *)
let create_context () =
  Proven_error.from_slot (c_ids_create_context ())

(** Destroy an IDS context, releasing its slot. *)
let destroy_context slot = c_ids_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_ids_can_transition (threat_level_to_tag from) (threat_level_to_tag to_) = 1
