(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Firewall protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-firewall/ffi/zig/src/firewall.zig]. *)

(** Firewall rule actions matching [Action] in firewall.zig. *)
type action =
  | Accept     (** Accept the packet. *)
  | Drop       (** Silently drop the packet. *)
  | Reject     (** Reject with ICMP error. *)
  | Log        (** Log and continue processing. *)
  | Redirect   (** Redirect to a different destination. *)
  | Dnat       (** Destination NAT. *)
  | Snat       (** Source NAT. *)
  | Masquerade (** IP masquerading. *)

(** Firewall packet lifecycle states. *)
type packet_state =
  | Pkt_idle       (** No packet classified yet. *)
  | Pkt_classified (** Packet classified. *)
  | Pkt_evaluating (** Chain evaluation in progress. *)
  | Pkt_decided    (** Decision made. *)
  | Pkt_committed  (** Committed (final). *)

(** Connection tracking states. *)
type conntrack_state =
  | Ct_none        (** No connection tracking. *)
  | Ct_tracking    (** Tracking in progress. *)
  | Ct_established (** Connection established. *)
  | Ct_related     (** Related connection. *)
  | Ct_expired     (** Connection expired. *)

let action_to_tag = function
  | Accept -> 0 | Drop -> 1 | Reject -> 2 | Log -> 3
  | Redirect -> 4 | Dnat -> 5 | Snat -> 6 | Masquerade -> 7

let action_of_tag = function
  | 0 -> Some Accept | 1 -> Some Drop | 2 -> Some Reject | 3 -> Some Log
  | 4 -> Some Redirect | 5 -> Some Dnat | 6 -> Some Snat
  | 7 -> Some Masquerade | _ -> None

let packet_state_to_tag = function
  | Pkt_idle -> 0 | Pkt_classified -> 1 | Pkt_evaluating -> 2
  | Pkt_decided -> 3 | Pkt_committed -> 4

let packet_state_of_tag = function
  | 0 -> Some Pkt_idle | 1 -> Some Pkt_classified | 2 -> Some Pkt_evaluating
  | 3 -> Some Pkt_decided | 4 -> Some Pkt_committed | _ -> None

let conntrack_state_to_tag = function
  | Ct_none -> 0 | Ct_tracking -> 1 | Ct_established -> 2
  | Ct_related -> 3 | Ct_expired -> 4

let conntrack_state_of_tag = function
  | 0 -> Some Ct_none | 1 -> Some Ct_tracking | 2 -> Some Ct_established
  | 3 -> Some Ct_related | 4 -> Some Ct_expired | _ -> None

(* --- C FFI declarations --- *)

external c_fw_abi_version : unit -> int = "fw_abi_version"
external c_fw_create_context : unit -> int = "fw_create_context"
external c_fw_destroy_context : int -> unit = "fw_destroy_context"
external c_fw_packet_state : int -> int = "fw_packet_state"
external c_fw_conntrack_state : int -> int = "fw_conntrack_state"
external c_fw_get_decision : int -> int = "fw_get_decision"
external c_fw_rule_count : int -> int = "fw_rule_count"
external c_fw_packet_proto : int -> int = "fw_packet_proto"
external c_fw_packet_chain : int -> int = "fw_packet_chain"
external c_fw_packet_src_ip : int -> int = "fw_packet_src_ip"
external c_fw_packet_dst_ip : int -> int = "fw_packet_dst_ip"
external c_fw_packet_src_port : int -> int = "fw_packet_src_port"
external c_fw_packet_dst_port : int -> int = "fw_packet_dst_port"
external c_fw_classify_packet : int -> int -> int -> int -> int -> int -> int -> int
  = "fw_classify_packet_bytecode" "fw_classify_packet"
external c_fw_begin_chain : int -> int = "fw_begin_chain"
external c_fw_add_rule : int -> int -> int -> int -> int -> int
  = "fw_add_rule_bytecode" "fw_add_rule"
external c_fw_set_default_action : int -> int -> int = "fw_set_default_action"
external c_fw_evaluate_rules : int -> int = "fw_evaluate_rules"
external c_fw_commit : int -> int = "fw_commit"
external c_fw_begin_tracking : int -> int = "fw_begin_tracking"
external c_fw_complete_tracking : int -> int -> int = "fw_complete_tracking"
external c_fw_expire_conn : int -> int = "fw_expire_conn"
external c_fw_can_transition : int -> int -> int = "fw_can_transition"
external c_fw_can_conntrack_transition : int -> int -> int = "fw_can_conntrack_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_fw_abi_version ()
let create_context () = Proven_error.from_slot (c_fw_create_context ())
let destroy_context slot = c_fw_destroy_context slot
let get_packet_state slot = packet_state_of_tag (c_fw_packet_state slot)
let get_conntrack_state slot = conntrack_state_of_tag (c_fw_conntrack_state slot)
let get_decision slot = action_of_tag (c_fw_get_decision slot)
let rule_count slot = c_fw_rule_count slot
let packet_proto slot = c_fw_packet_proto slot
let packet_chain slot = c_fw_packet_chain slot
let packet_src_ip slot = c_fw_packet_src_ip slot
let packet_dst_ip slot = c_fw_packet_dst_ip slot
let packet_src_port slot = c_fw_packet_src_port slot
let packet_dst_port slot = c_fw_packet_dst_port slot

(** Classify a packet. Transitions Idle -> Classified. *)
let classify_packet slot ~proto ~chain ~src_ip ~dst_ip ~src_port ~dst_port =
  Proven_error.from_status
    (c_fw_classify_packet slot proto chain src_ip dst_ip src_port dst_port)

(** Begin chain evaluation. Transitions Classified -> Evaluating. *)
let begin_chain slot = Proven_error.from_status (c_fw_begin_chain slot)

(** Add a rule to the evaluation chain. *)
let add_rule slot ~match_type ~match_value ~action ~priority =
  Proven_error.from_status
    (c_fw_add_rule slot match_type match_value (action_to_tag action) priority)

(** Set the default action (applied when no rules match). *)
let set_default_action slot action =
  Proven_error.from_status (c_fw_set_default_action slot (action_to_tag action))

(** Evaluate rules against the classified packet. *)
let evaluate_rules slot = Proven_error.from_status (c_fw_evaluate_rules slot)

(** Commit the decision. Transitions Decided -> Committed. *)
let commit slot = Proven_error.from_status (c_fw_commit slot)

(** Begin connection tracking. Transitions None -> Tracking. *)
let begin_tracking slot = Proven_error.from_status (c_fw_begin_tracking slot)

(** Complete connection tracking with a state. *)
let complete_tracking slot conn_state =
  Proven_error.from_status (c_fw_complete_tracking slot (conntrack_state_to_tag conn_state))

(** Expire a connection. Transitions Established/Related -> Expired. *)
let expire_conn slot = Proven_error.from_status (c_fw_expire_conn slot)

(** Stateless query: check whether a packet state transition is valid. *)
let can_transition ~from ~to_ =
  c_fw_can_transition (packet_state_to_tag from) (packet_state_to_tag to_) = 1

(** Stateless query: check whether a conntrack state transition is valid. *)
let can_conntrack_transition ~from ~to_ =
  c_fw_can_conntrack_transition (conntrack_state_to_tag from) (conntrack_state_to_tag to_) = 1
