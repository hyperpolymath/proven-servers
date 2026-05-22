(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Honeypot/deception protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-honeypot/ffi/zig/src/honeypot.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for service emulations, interaction
    levels, alert severities, and server states. *)

(** Service emulation types matching [ServiceEmulation] in honeypot.zig. *)
type service_emulation =
  | Ssh | Http | Ftp | Smtp | Telnet | Mysql | Rdp

(** Interaction levels matching [InteractionLevel] in honeypot.zig. *)
type interaction_level =
  | Low | Medium | High

(** Alert severity levels matching [HoneypotAlertSeverity] in honeypot.zig. *)
type alert_severity =
  | Info | AsLow | AsMedium | AsHigh | Critical

(** Attacker actions matching [AttackerAction] in honeypot.zig. *)
type attacker_action =
  | Scan | BruteForce | Exploit | Payload | Lateral | Exfiltration

(** Server lifecycle states matching [ServerState] in honeypot.zig. *)
type server_state =
  | Idle | Deployed | Engaged | Shutdown

(** Convert a service emulation to its ABI tag value. *)
let service_emulation_to_tag = function
  | Ssh -> 0 | Http -> 1 | Ftp -> 2 | Smtp -> 3 | Telnet -> 4
  | Mysql -> 5 | Rdp -> 6

(** Decode a service emulation from its ABI tag value. *)
let service_emulation_of_tag = function
  | 0 -> Some Ssh | 1 -> Some Http | 2 -> Some Ftp | 3 -> Some Smtp
  | 4 -> Some Telnet | 5 -> Some Mysql | 6 -> Some Rdp | _ -> None

(** Convert an interaction level to its ABI tag value. *)
let interaction_level_to_tag = function
  | Low -> 0 | Medium -> 1 | High -> 2

(** Decode an interaction level from its ABI tag value. *)
let interaction_level_of_tag = function
  | 0 -> Some Low | 1 -> Some Medium | 2 -> Some High | _ -> None

(** Convert an alert severity to its ABI tag value. *)
let alert_severity_to_tag = function
  | Info -> 0 | AsLow -> 1 | AsMedium -> 2 | AsHigh -> 3 | Critical -> 4

(** Decode an alert severity from its ABI tag value. *)
let alert_severity_of_tag = function
  | 0 -> Some Info | 1 -> Some AsLow | 2 -> Some AsMedium
  | 3 -> Some AsHigh | 4 -> Some Critical | _ -> None

(** Convert an attacker action to its ABI tag value. *)
let attacker_action_to_tag = function
  | Scan -> 0 | BruteForce -> 1 | Exploit -> 2 | Payload -> 3
  | Lateral -> 4 | Exfiltration -> 5

(** Decode an attacker action from its ABI tag value. *)
let attacker_action_of_tag = function
  | 0 -> Some Scan | 1 -> Some BruteForce | 2 -> Some Exploit
  | 3 -> Some Payload | 4 -> Some Lateral | 5 -> Some Exfiltration
  | _ -> None

(** Convert a server state to its ABI tag value. *)
let server_state_to_tag = function
  | Idle -> 0 | Deployed -> 1 | Engaged -> 2 | Shutdown -> 3

(** Decode a server state from its ABI tag value. *)
let server_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Deployed | 2 -> Some Engaged
  | 3 -> Some Shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_honeypot_abi_version : unit -> int = "honeypot_abi_version"
external c_honeypot_create_context : unit -> int = "honeypot_create_context"
external c_honeypot_destroy_context : int -> unit = "honeypot_destroy_context"
external c_honeypot_can_transition : int -> int -> int = "honeypot_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_honeypot]. *)
let abi_version () = c_honeypot_abi_version ()

(** Create a new honeypot context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_honeypot_create_context ())

(** Destroy a honeypot context, releasing its slot. *)
let destroy_context slot = c_honeypot_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_honeypot_can_transition (server_state_to_tag from) (server_state_to_tag to_) = 1
