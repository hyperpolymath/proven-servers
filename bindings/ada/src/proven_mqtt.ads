-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-mqtt protocol (MQTT broker).
--
-- Wraps the C-ABI functions from protocols/proven-mqtt/ffi/zig/src/mqtt.zig.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Mqtt is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- MQTT broker session states.
   type Mqtt_Session_State is
     (State_Idle,
      State_Connected,
      State_Disconnected);
   for Mqtt_Session_State use
     (State_Idle         => 0,
      State_Connected    => 1,
      State_Disconnected => 2);
   pragma Convention (C, Mqtt_Session_State);

   -- MQTT Quality of Service levels.
   type QoS is (QoS_0, QoS_1, QoS_2);
   for QoS use (QoS_0 => 0, QoS_1 => 1, QoS_2 => 2);
   pragma Convention (C, QoS);

   -- MQTT protocol versions.
   type Mqtt_Version is (MQTT_3_1_1, MQTT_5_0);
   for Mqtt_Version use (MQTT_3_1_1 => 0, MQTT_5_0 => 1);
   pragma Convention (C, Mqtt_Version);

   ---------------------------------------------------------------------------
   -- Raw FFI imports
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "mqtt_abi_version");

   function Create
     (Version       : unsigned_char;
      Clean_Session : unsigned_char;
      Keep_Alive    : unsigned_short) return int;
   pragma Import (C, Create, "mqtt_create");

   procedure Destroy (Slot : int);
   pragma Import (C, Destroy, "mqtt_destroy");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "mqtt_state");

   function Get_Version (Slot : int) return unsigned_char;
   pragma Import (C, Get_Version, "mqtt_version");

   function Can_Publish (Slot : int) return unsigned_char;
   pragma Import (C, Can_Publish, "mqtt_can_publish");

   function Can_Subscribe (Slot : int) return unsigned_char;
   pragma Import (C, Can_Subscribe, "mqtt_can_subscribe");

   function Subscription_Count (Slot : int) return unsigned;
   pragma Import (C, Subscription_Count, "mqtt_subscription_count");

   function Subscribe
     (Slot      : int;
      Topic_Ptr : access unsigned_char;
      Topic_Len : unsigned;
      Qos_Level : unsigned_char) return unsigned_char;
   pragma Import (C, Subscribe, "mqtt_subscribe");

   function Unsubscribe
     (Slot      : int;
      Topic_Ptr : access unsigned_char;
      Topic_Len : unsigned) return unsigned_char;
   pragma Import (C, Unsubscribe, "mqtt_unsubscribe");

   function Publish
     (Slot        : int;
      Topic_Ptr   : access unsigned_char;
      Topic_Len   : unsigned;
      Payload_Ptr : access unsigned_char;
      Payload_Len : unsigned;
      Qos_Level   : unsigned_char;
      Retain      : unsigned_char;
      Packet_Id   : unsigned_short) return unsigned_char;
   pragma Import (C, Publish, "mqtt_publish");

   function Puback
     (Slot      : int;
      Packet_Id : unsigned_short) return unsigned_char;
   pragma Import (C, Puback, "mqtt_puback");

   function Pubrec
     (Slot      : int;
      Packet_Id : unsigned_short) return unsigned_char;
   pragma Import (C, Pubrec, "mqtt_pubrec");

   function Pubrel
     (Slot      : int;
      Packet_Id : unsigned_short) return unsigned_char;
   pragma Import (C, Pubrel, "mqtt_pubrel");

   function Pubcomp
     (Slot      : int;
      Packet_Id : unsigned_short) return unsigned_char;
   pragma Import (C, Pubcomp, "mqtt_pubcomp");

   function Qos_State
     (Slot      : int;
      Packet_Id : unsigned_short) return unsigned_char;
   pragma Import (C, Qos_State, "mqtt_qos_state");

   function Mqtt_Disconnect (Slot : int) return unsigned_char;
   pragma Import (C, Mqtt_Disconnect, "mqtt_disconnect");

   function Cleanup (Slot : int) return unsigned_char;
   pragma Import (C, Cleanup, "mqtt_cleanup");

   function Retained_Count return unsigned;
   pragma Import (C, Retained_Count, "mqtt_retained_count");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "mqtt_can_transition");

   function Qos_Can_Transition
     (Qos_Level : unsigned_char;
      From      : unsigned_char;
      To        : unsigned_char) return unsigned_char;
   pragma Import (C, Qos_Can_Transition, "mqtt_qos_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create
     (Version       : Mqtt_Version;
      Clean_Session : Boolean;
      Keep_Alive    : unsigned_short) return Proven_Error.Slot_Id;

   procedure Safe_Destroy (Slot : Proven_Error.Slot_Id);
   procedure Safe_Disconnect (Slot : Proven_Error.Slot_Id);

end Proven_Mqtt;
