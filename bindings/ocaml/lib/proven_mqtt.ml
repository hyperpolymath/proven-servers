(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** MQTT protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-mqtt/ffi/zig/src/mqtt.zig]. *)

(** MQTT broker session states matching the Zig FFI. *)
type session_state =
  | Idle         (** Client connected, CONNECT not yet received. *)
  | Connected    (** CONNECT received, session active. *)
  | Disconnected (** Client disconnected cleanly. *)

(** MQTT Quality of Service levels. *)
type qos =
  | QoS0 (** At most once. *)
  | QoS1 (** At least once. *)
  | QoS2 (** Exactly once. *)

let state_to_tag = function
  | Idle -> 0 | Connected -> 1 | Disconnected -> 2

let state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Connected | 2 -> Some Disconnected
  | _ -> None

let qos_to_code = function
  | QoS0 -> 0 | QoS1 -> 1 | QoS2 -> 2

(* --- Disabled native FFI declarations --- *)
(* Raw Zig C symbols are not OCaml primitives. All operations
   raise a clear exception until OCaml-compatible stubs exist. *)

let c_mqtt_abi_version : unit -> int = fun () ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_create : int -> int -> int -> int = fun _arg0 _arg1 _arg2 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_destroy : int -> unit = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_state : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_version : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_can_publish : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_can_subscribe : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_subscription_count : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_puback : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_pubrec : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_pubrel : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_pubcomp : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_qos_state : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_disconnect : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_cleanup : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_retained_count : unit -> int = fun () ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_can_transition : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_mqtt_qos_can_transition : int -> int -> int -> int = fun _arg0 _arg1 _arg2 ->
  Proven_unavailable.raise_unavailable ()

(* --- Safe wrappers --- *)

let abi_version () = c_mqtt_abi_version ()

let create ~version ~clean_session ~keep_alive =
  Proven_error.from_slot
    (c_mqtt_create version (if clean_session then 1 else 0) keep_alive)

let destroy slot = c_mqtt_destroy slot
let get_state slot = state_of_tag (c_mqtt_state slot)
let version slot = c_mqtt_version slot
let can_publish slot = c_mqtt_can_publish slot = 1
let can_subscribe slot = c_mqtt_can_subscribe slot = 1
let subscription_count slot = c_mqtt_subscription_count slot

let puback slot ~packet_id = Proven_error.from_status (c_mqtt_puback slot packet_id)
let pubrec slot ~packet_id = Proven_error.from_status (c_mqtt_pubrec slot packet_id)
let pubrel slot ~packet_id = Proven_error.from_status (c_mqtt_pubrel slot packet_id)
let pubcomp slot ~packet_id = Proven_error.from_status (c_mqtt_pubcomp slot packet_id)
let qos_state slot ~packet_id = c_mqtt_qos_state slot packet_id

let disconnect slot = Proven_error.from_status (c_mqtt_disconnect slot)
let cleanup slot = Proven_error.from_status (c_mqtt_cleanup slot)
let retained_count () = c_mqtt_retained_count ()

let can_transition ~from ~to_ =
  c_mqtt_can_transition (state_to_tag from) (state_to_tag to_) = 1

let qos_can_transition qos ~from ~to_ =
  c_mqtt_qos_can_transition (qos_to_code qos) from to_ = 1
