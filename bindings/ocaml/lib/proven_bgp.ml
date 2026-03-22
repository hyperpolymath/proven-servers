(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** BGP (Border Gateway Protocol) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-bgp/ffi/zig/src/bgp.zig]. *)

(** BgpState matching [BgpState] in bgp.zig. *)
type bgp_state =
  | Idle  (** Idle (tag 0). *)
  | Connect  (** Connect (tag 1). *)
  | Active  (** Active (tag 2). *)
  | OpenSent  (** OpenSent (tag 3). *)
  | OpenConfirm  (** OpenConfirm (tag 4). *)
  | Established  (** Established (tag 5). *)

let bgp_state_to_tag = function
  | Idle -> 0 | Connect -> 1 | Active -> 2 | OpenSent -> 3
  | OpenConfirm -> 4 | Established -> 5

let bgp_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Connect | 2 -> Some Active
  | 3 -> Some OpenSent | 4 -> Some OpenConfirm | 5 -> Some Established
  | _ -> None

(** BgpEvent matching [BgpEvent] in bgp.zig. *)
type bgp_event =
  | ManualStart  (** ManualStart (tag 0). *)
  | ManualStop  (** ManualStop (tag 1). *)
  | AutomaticStart  (** AutomaticStart (tag 2). *)
  | ConnectRetryTimerExpires  (** ConnectRetryTimerExpires (tag 3). *)
  | HoldTimerExpires  (** HoldTimerExpires (tag 4). *)
  | KeepaliveTimerExpires  (** KeepaliveTimerExpires (tag 5). *)
  | DelayOpenTimerExpires  (** DelayOpenTimerExpires (tag 6). *)
  | TcpConnectionValid  (** TcpConnectionValid (tag 7). *)
  | TcpCrAcked  (** TcpCrAcked (tag 8). *)
  | TcpConnectionConfirmed  (** TcpConnectionConfirmed (tag 9). *)
  | TcpConnectionFails  (** TcpConnectionFails (tag 10). *)
  | BgpOpenReceived  (** BgpOpenReceived (tag 11). *)
  | BgpHeaderErr  (** BgpHeaderErr (tag 12). *)
  | BgpOpenMsgErr  (** BgpOpenMsgErr (tag 13). *)
  | NotifMsgVerErr  (** NotifMsgVerErr (tag 14). *)
  | NotifMsg  (** NotifMsg (tag 15). *)
  | KeepaliveMsg  (** KeepaliveMsg (tag 16). *)
  | UpdateMsg  (** UpdateMsg (tag 17). *)
  | UpdateMsgErr  (** UpdateMsgErr (tag 18). *)

let bgp_event_to_tag = function
  | ManualStart -> 0 | ManualStop -> 1 | AutomaticStart -> 2
  | ConnectRetryTimerExpires -> 3 | HoldTimerExpires -> 4
  | KeepaliveTimerExpires -> 5 | DelayOpenTimerExpires -> 6
  | TcpConnectionValid -> 7 | TcpCrAcked -> 8
  | TcpConnectionConfirmed -> 9 | TcpConnectionFails -> 10
  | BgpOpenReceived -> 11 | BgpHeaderErr -> 12
  | BgpOpenMsgErr -> 13 | NotifMsgVerErr -> 14 | NotifMsg -> 15
  | KeepaliveMsg -> 16 | UpdateMsg -> 17 | UpdateMsgErr -> 18

let bgp_event_of_tag = function
  | 0 -> Some ManualStart | 1 -> Some ManualStop
  | 2 -> Some AutomaticStart | 3 -> Some ConnectRetryTimerExpires
  | 4 -> Some HoldTimerExpires | 5 -> Some KeepaliveTimerExpires
  | 6 -> Some DelayOpenTimerExpires | 7 -> Some TcpConnectionValid
  | 8 -> Some TcpCrAcked | 9 -> Some TcpConnectionConfirmed
  | 10 -> Some TcpConnectionFails | 11 -> Some BgpOpenReceived
  | 12 -> Some BgpHeaderErr | 13 -> Some BgpOpenMsgErr
  | 14 -> Some NotifMsgVerErr | 15 -> Some NotifMsg
  | 16 -> Some KeepaliveMsg | 17 -> Some UpdateMsg
  | 18 -> Some UpdateMsgErr | _ -> None

(** MessageType matching [MessageType] in bgp.zig. *)
type message_type =
  | Open  (** Open (tag 0). *)
  | Update  (** Update (tag 1). *)
  | Notification  (** Notification (tag 2). *)
  | Keepalive  (** Keepalive (tag 3). *)

let message_type_to_tag = function
  | Open -> 0 | Update -> 1 | Notification -> 2 | Keepalive -> 3

let message_type_of_tag = function
  | 0 -> Some Open | 1 -> Some Update | 2 -> Some Notification
  | 3 -> Some Keepalive | _ -> None

(** ErrorCode matching [ErrorCode] in bgp.zig. *)
type error_code =
  | MessageHeaderError  (** MessageHeaderError (tag 0). *)
  | OpenMessageError  (** OpenMessageError (tag 1). *)
  | UpdateMessageError  (** UpdateMessageError (tag 2). *)
  | HoldTimerExpired  (** HoldTimerExpired (tag 3). *)
  | FsmError  (** FsmError (tag 4). *)
  | Cease  (** Cease (tag 5). *)

let error_code_to_tag = function
  | MessageHeaderError -> 0 | OpenMessageError -> 1
  | UpdateMessageError -> 2 | HoldTimerExpired -> 3
  | FsmError -> 4 | Cease -> 5

let error_code_of_tag = function
  | 0 -> Some MessageHeaderError | 1 -> Some OpenMessageError
  | 2 -> Some UpdateMessageError | 3 -> Some HoldTimerExpired
  | 4 -> Some FsmError | 5 -> Some Cease | _ -> None

(** Origin matching [Origin] in bgp.zig. *)
type origin =
  | Igp  (** IGP (tag 0). *)
  | Egp  (** EGP (tag 1). *)
  | Incomplete  (** Incomplete (tag 2). *)

let origin_to_tag = function Igp -> 0 | Egp -> 1 | Incomplete -> 2

let origin_of_tag = function
  | 0 -> Some Igp | 1 -> Some Egp | 2 -> Some Incomplete | _ -> None

(** AsPathSegmentType matching [AsPathSegmentType] in bgp.zig. *)
type as_path_segment_type =
  | AsSet  (** AsSet (tag 0). *)
  | AsSequence  (** AsSequence (tag 1). *)

let as_path_segment_type_to_tag = function AsSet -> 0 | AsSequence -> 1

let as_path_segment_type_of_tag = function
  | 0 -> Some AsSet | 1 -> Some AsSequence | _ -> None

(** PathAttrType matching [PathAttrType] in bgp.zig. *)
type path_attr_type =
  | PaOrigin  (** Origin (tag 0). *)
  | AsPath  (** AsPath (tag 1). *)
  | NextHop  (** NextHop (tag 2). *)
  | Med  (** MED (tag 3). *)
  | LocalPref  (** LocalPref (tag 4). *)
  | AtomicAggr  (** AtomicAggr (tag 5). *)
  | Aggregator  (** Aggregator (tag 6). *)
  | Unknown  (** Unknown (tag 7). *)

let path_attr_type_to_tag = function
  | PaOrigin -> 0 | AsPath -> 1 | NextHop -> 2 | Med -> 3
  | LocalPref -> 4 | AtomicAggr -> 5 | Aggregator -> 6 | Unknown -> 7

let path_attr_type_of_tag = function
  | 0 -> Some PaOrigin | 1 -> Some AsPath | 2 -> Some NextHop
  | 3 -> Some Med | 4 -> Some LocalPref | 5 -> Some AtomicAggr
  | 6 -> Some Aggregator | 7 -> Some Unknown | _ -> None

(* --- C FFI declarations --- *)

external c_bgp_abi_version : unit -> int = "bgp_abi_version"
external c_bgp_create_context : unit -> int = "bgp_create_context"
external c_bgp_destroy_context : int -> unit = "bgp_destroy_context"
external c_bgp_state : int -> int = "bgp_state"
external c_bgp_can_transition : int -> int -> int = "bgp_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_bgp_abi_version ()

let create_context () = Proven_error.from_slot (c_bgp_create_context ())

let destroy_context slot = c_bgp_destroy_context slot

let get_state slot = bgp_state_of_tag (c_bgp_state slot)

let can_transition ~from ~to_ =
  c_bgp_can_transition (bgp_state_to_tag from) (bgp_state_to_tag to_) = 1
