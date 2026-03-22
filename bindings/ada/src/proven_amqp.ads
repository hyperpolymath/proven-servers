-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-amqp protocol (AMQP 0-9-1 message broker).
--
-- Wraps the C-ABI functions from protocols/proven-amqp/ffi/zig/src/amqp.zig:
--   amqp_abi_version, amqp_create_context, amqp_destroy_context,
--   amqp_state, amqp_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Amqp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `FrameType` in `AmqpABI.Types`.
   type Frame_Type is
     (Method,
      Header,
      Body,
      Heartbeat);
   pragma Convention (C, Frame_Type);

   -- Matches `MethodClass` in `AmqpABI.Types`.
   type Method_Class is
     (Connection,
      Channel,
      Exchange,
      Queue,
      Basic,
      Tx,
      Confirm);
   pragma Convention (C, Method_Class);

   -- Matches `ExchangeType` in `AmqpABI.Types`.
   type Exchange_Type is
     (Direct,
      Fanout,
      Topic,
      Headers);
   pragma Convention (C, Exchange_Type);

   -- Matches `DeliveryMode` in `AmqpABI.Types`.
   type Delivery_Mode is
     (Non_Persistent,
      Persistent);
   pragma Convention (C, Delivery_Mode);

   -- Matches `ErrorSeverity` in `AmqpABI.Types`.
   type Error_Severity is
     (Channel_Level,
      Connection_Level);
   pragma Convention (C, Error_Severity);

   -- Matches `ConnectionState` in `AmqpABI.Types`.
   type Connection_State is
     (CS_Idle,
      Negotiating,
      Tuning_Ok,
      Open,
      Closing);
   pragma Convention (C, Connection_State);

   -- Matches `ChannelState` in `AmqpABI.Types`.
   type Channel_State is
     (Closed,
      Opening,
      Ch_Open,
      Ch_Closing);
   pragma Convention (C, Channel_State);

   -- Matches `BrokerState` in `AmqpABI.Types`.
   type Broker_State is
     (BS_Idle,
      Connected,
      Channel_Open,
      Consuming,
      Publishing,
      Disconnecting);
   pragma Convention (C, Broker_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "amqp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "amqp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "amqp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "amqp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "amqp_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Amqp;
