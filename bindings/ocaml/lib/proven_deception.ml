(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Deception Platform types for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-deception/ffi/zig/src/deception.zig]. *)

(** DecoyType matching [DecoyType] in deception.zig. *)
type decoy_type =
  | Service  (** Service (tag 0). *)
  | Credential  (** Credential (tag 1). *)
  | File  (** File (tag 2). *)
  | Network  (** Network (tag 3). *)
  | Token  (** Token (tag 4). *)
  | Breadcrumb  (** Breadcrumb (tag 5). *)

let decoy_type_to_tag = function
  | Service -> 0
  | Credential -> 1
  | File -> 2
  | Network -> 3
  | Token -> 4
  | Breadcrumb -> 5

let decoy_type_of_tag = function
  | 0 -> Some Service
  | 1 -> Some Credential
  | 2 -> Some File
  | 3 -> Some Network
  | 4 -> Some Token
  | 5 -> Some Breadcrumb
  | _ -> None

(** TriggerEvent matching [TriggerEvent] in deception.zig. *)
type trigger_event =
  | Access  (** Access (tag 0). *)
  | Login  (** Login (tag 1). *)
  | Read  (** Read (tag 2). *)
  | Write  (** Write (tag 3). *)
  | Execute  (** Execute (tag 4). *)
  | Scan  (** Scan (tag 5). *)

let trigger_event_to_tag = function
  | Access -> 0
  | Login -> 1
  | Read -> 2
  | Write -> 3
  | Execute -> 4
  | Scan -> 5

let trigger_event_of_tag = function
  | 0 -> Some Access
  | 1 -> Some Login
  | 2 -> Some Read
  | 3 -> Some Write
  | 4 -> Some Execute
  | 5 -> Some Scan
  | _ -> None

(** AlertPriority matching [AlertPriority] in deception.zig. *)
type alert_priority =
  | Low  (** Low (tag 0). *)
  | Medium  (** Medium (tag 1). *)
  | High  (** High (tag 2). *)
  | Critical  (** Critical (tag 3). *)

let alert_priority_to_tag = function
  | Low -> 0 | Medium -> 1 | High -> 2 | Critical -> 3

let alert_priority_of_tag = function
  | 0 -> Some Low
  | 1 -> Some Medium
  | 2 -> Some High
  | 3 -> Some Critical
  | _ -> None

(** DecoyState matching [DecoyState] in deception.zig. *)
type decoy_state =
  | Active  (** Active (tag 0). *)
  | Triggered  (** Triggered (tag 1). *)
  | Disabled  (** Disabled (tag 2). *)
  | Expired  (** Expired (tag 3). *)

let decoy_state_to_tag = function
  | Active -> 0 | Triggered -> 1 | Disabled -> 2 | Expired -> 3

let decoy_state_of_tag = function
  | 0 -> Some Active
  | 1 -> Some Triggered
  | 2 -> Some Disabled
  | 3 -> Some Expired
  | _ -> None

(** ResponseAction matching [ResponseAction] in deception.zig. *)
type response_action =
  | Alert  (** Alert (tag 0). *)
  | Redirect  (** Redirect (tag 1). *)
  | Delay  (** Delay (tag 2). *)
  | Fingerprint  (** Fingerprint (tag 3). *)
  | Isolate  (** Isolate (tag 4). *)

let response_action_to_tag = function
  | Alert -> 0
  | Redirect -> 1
  | Delay -> 2
  | Fingerprint -> 3
  | Isolate -> 4

let response_action_of_tag = function
  | 0 -> Some Alert
  | 1 -> Some Redirect
  | 2 -> Some Delay
  | 3 -> Some Fingerprint
  | 4 -> Some Isolate
  | _ -> None

(** ServerState matching [ServerState] in deception.zig. *)
type server_state =
  | Idle  (** Idle (tag 0). *)
  | Configured  (** Configured (tag 1). *)
  | Monitoring  (** Monitoring (tag 2). *)
  | Responding  (** Responding (tag 3). *)
  | Shutdown  (** Shutdown (tag 4). *)

let server_state_to_tag = function
  | Idle -> 0
  | Configured -> 1
  | Monitoring -> 2
  | Responding -> 3
  | Shutdown -> 4

let server_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Configured
  | 2 -> Some Monitoring
  | 3 -> Some Responding
  | 4 -> Some Shutdown
  | _ -> None

(* --- C FFI declarations --- *)

external c_deception_abi_version : unit -> int = "deception_abi_version"
external c_deception_create_context : unit -> int = "deception_create_context"
external c_deception_destroy_context : int -> unit = "deception_destroy_context"
external c_deception_state : int -> int = "deception_state"
external c_deception_server_state : int -> int = "deception_server_state"
external c_deception_can_transition : int -> int -> int = "deception_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_deception_abi_version ()

let create_context () = Proven_error.from_slot (c_deception_create_context ())

let destroy_context slot = c_deception_destroy_context slot

let get_state slot = decoy_state_of_tag (c_deception_state slot)

let can_transition ~from ~to_ =
  c_deception_can_transition (decoy_state_to_tag from) (decoy_state_to_tag to_) = 1
