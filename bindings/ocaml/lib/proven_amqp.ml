(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** AMQP 0-9-1 protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-amqp/ffi/zig/src/amqp.zig]. *)

(** FrameType matching [FrameType] in amqp.zig. *)
type frame_type =
  | Method  (** Method (tag 0). *)
  | Header  (** Header (tag 1). *)
  | Body  (** Body (tag 2). *)
  | Heartbeat  (** Heartbeat (tag 3). *)

let frame_type_to_tag = function
  | Method -> 0 | Header -> 1 | Body -> 2 | Heartbeat -> 3

let frame_type_of_tag = function
  | 0 -> Some Method | 1 -> Some Header | 2 -> Some Body
  | 3 -> Some Heartbeat | _ -> None

(** MethodClass matching [MethodClass] in amqp.zig. *)
type method_class =
  | Connection  (** Connection (tag 0). *)
  | Channel  (** Channel (tag 1). *)
  | Exchange  (** Exchange (tag 2). *)
  | Queue  (** Queue (tag 3). *)
  | Basic  (** Basic (tag 4). *)
  | Tx  (** Tx (tag 5). *)
  | Confirm  (** Confirm (tag 6). *)

let method_class_to_tag = function
  | Connection -> 0 | Channel -> 1 | Exchange -> 2 | Queue -> 3
  | Basic -> 4 | Tx -> 5 | Confirm -> 6

let method_class_of_tag = function
  | 0 -> Some Connection | 1 -> Some Channel | 2 -> Some Exchange
  | 3 -> Some Queue | 4 -> Some Basic | 5 -> Some Tx | 6 -> Some Confirm
  | _ -> None

(** ExchangeType matching [ExchangeType] in amqp.zig. *)
type exchange_type =
  | Direct  (** Direct (tag 0). *)
  | Fanout  (** Fanout (tag 1). *)
  | Topic  (** Topic (tag 2). *)
  | Headers  (** Headers (tag 3). *)

let exchange_type_to_tag = function
  | Direct -> 0 | Fanout -> 1 | Topic -> 2 | Headers -> 3

let exchange_type_of_tag = function
  | 0 -> Some Direct | 1 -> Some Fanout | 2 -> Some Topic
  | 3 -> Some Headers | _ -> None

(** DeliveryMode matching [DeliveryMode] in amqp.zig. *)
type delivery_mode =
  | NonPersistent  (** NonPersistent (tag 0). *)
  | Persistent  (** Persistent (tag 1). *)

let delivery_mode_to_tag = function NonPersistent -> 0 | Persistent -> 1

let delivery_mode_of_tag = function
  | 0 -> Some NonPersistent | 1 -> Some Persistent | _ -> None

(** ErrorSeverity matching [ErrorSeverity] in amqp.zig. *)
type error_severity =
  | ChannelLevel  (** ChannelLevel (tag 0). *)
  | ConnectionLevel  (** ConnectionLevel (tag 1). *)

let error_severity_to_tag = function ChannelLevel -> 0 | ConnectionLevel -> 1

let error_severity_of_tag = function
  | 0 -> Some ChannelLevel | 1 -> Some ConnectionLevel | _ -> None

(** ConnectionState matching [ConnectionState] in amqp.zig. *)
type connection_state =
  | ConnectionState_Idle  (** Idle (tag 0). *)
  | Negotiating  (** Negotiating (tag 1). *)
  | TuningOk  (** TuningOk (tag 2). *)
  | Open  (** Open (tag 3). *)
  | Closing  (** Closing (tag 4). *)

let connection_state_to_tag = function
  | ConnectionState_Idle -> 0 | Negotiating -> 1 | TuningOk -> 2
  | Open -> 3 | Closing -> 4

let connection_state_of_tag = function
  | 0 -> Some ConnectionState_Idle | 1 -> Some Negotiating
  | 2 -> Some TuningOk | 3 -> Some Open | 4 -> Some Closing | _ -> None

(** ChannelState matching [ChannelState] in amqp.zig. *)
type channel_state =
  | Closed  (** Closed (tag 0). *)
  | Opening  (** Opening (tag 1). *)
  | ChOpen  (** ChOpen (tag 2). *)
  | ChClosing  (** ChClosing (tag 3). *)

let channel_state_to_tag = function
  | Closed -> 0 | Opening -> 1 | ChOpen -> 2 | ChClosing -> 3

let channel_state_of_tag = function
  | 0 -> Some Closed | 1 -> Some Opening | 2 -> Some ChOpen
  | 3 -> Some ChClosing | _ -> None

(** BrokerState matching [BrokerState] in amqp.zig. *)
type broker_state =
  | BrokerState_Idle  (** Idle (tag 0). *)
  | Connected  (** Connected (tag 1). *)
  | ChannelOpen  (** ChannelOpen (tag 2). *)
  | Consuming  (** Consuming (tag 3). *)
  | Publishing  (** Publishing (tag 4). *)
  | Disconnecting  (** Disconnecting (tag 5). *)

let broker_state_to_tag = function
  | BrokerState_Idle -> 0 | Connected -> 1 | ChannelOpen -> 2
  | Consuming -> 3 | Publishing -> 4 | Disconnecting -> 5

let broker_state_of_tag = function
  | 0 -> Some BrokerState_Idle | 1 -> Some Connected | 2 -> Some ChannelOpen
  | 3 -> Some Consuming | 4 -> Some Publishing | 5 -> Some Disconnecting
  | _ -> None

(* --- C FFI declarations --- *)

external c_amqp_abi_version : unit -> int = "amqp_abi_version"
external c_amqp_create_context : unit -> int = "amqp_create_context"
external c_amqp_destroy_context : int -> unit = "amqp_destroy_context"
external c_amqp_state : int -> int = "amqp_state"
external c_amqp_can_transition : int -> int -> int = "amqp_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_amqp_abi_version ()

let create_context () = Proven_error.from_slot (c_amqp_create_context ())

let destroy_context slot = c_amqp_destroy_context slot

let get_state slot = broker_state_of_tag (c_amqp_state slot)

let can_transition ~from ~to_ =
  c_amqp_can_transition (broker_state_to_tag from) (broker_state_to_tag to_) = 1
