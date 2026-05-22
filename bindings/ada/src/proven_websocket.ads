-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-ws protocol (WebSocket server).
--
-- Wraps the C-ABI functions from protocols/proven-ws/ffi/zig/src/websocket.zig.
-- WebSocket opcodes and close codes follow RFC 6455.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Websocket is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI (RFC 6455)
   ---------------------------------------------------------------------------

   -- WebSocket frame opcodes (RFC 6455 Section 5.2).
   -- Discriminant values are the 4-bit wire values.
   type Opcode is
     (Opcode_Continuation,
      Opcode_Text,
      Opcode_Binary,
      Opcode_Close,
      Opcode_Ping,
      Opcode_Pong);
   for Opcode use
     (Opcode_Continuation => 16#0#,
      Opcode_Text         => 16#1#,
      Opcode_Binary       => 16#2#,
      Opcode_Close        => 16#8#,
      Opcode_Ping         => 16#9#,
      Opcode_Pong         => 16#A#);
   pragma Convention (C, Opcode);

   -- WebSocket close status codes (RFC 6455 Section 7.4.1).
   type Close_Code is
     (Close_Normal,
      Close_Going_Away,
      Close_Protocol_Error,
      Close_Unsupported_Data,
      Close_No_Status,
      Close_Abnormal,
      Close_Invalid_Payload,
      Close_Policy_Violation,
      Close_Message_Too_Big,
      Close_Missing_Extension,
      Close_Internal_Error,
      Close_TLS_Handshake);
   for Close_Code use
     (Close_Normal           => 1000,
      Close_Going_Away       => 1001,
      Close_Protocol_Error   => 1002,
      Close_Unsupported_Data => 1003,
      Close_No_Status        => 1005,
      Close_Abnormal         => 1006,
      Close_Invalid_Payload  => 1007,
      Close_Policy_Violation => 1008,
      Close_Message_Too_Big  => 1009,
      Close_Missing_Extension => 1010,
      Close_Internal_Error   => 1011,
      Close_TLS_Handshake    => 1015);
   pragma Convention (C, Close_Code);

   -- WebSocket connection states.
   type Ws_State is
     (State_Connecting,
      State_Open,
      State_Closing,
      State_Closed);
   for Ws_State use
     (State_Connecting => 0,
      State_Open       => 1,
      State_Closing    => 2,
      State_Closed     => 3);
   pragma Convention (C, Ws_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ws_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "ws_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "ws_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ws_state");

   function Open_Connection (Slot : int) return unsigned_char;
   pragma Import (C, Open_Connection, "ws_open");

   function Send_Frame
     (Slot    : int;
      Op      : unsigned_char;
      Data    : access unsigned_char;
      Len     : unsigned;
      Is_Fin  : unsigned_char) return unsigned_char;
   pragma Import (C, Send_Frame, "ws_send_frame");

   function Recv_Frame
     (Slot : int;
      Buf  : access unsigned_char;
      Len  : unsigned) return unsigned;
   pragma Import (C, Recv_Frame, "ws_recv_frame");

   function Close_Connection
     (Slot : int;
      Code : unsigned_short) return unsigned_char;
   pragma Import (C, Close_Connection, "ws_close");

   function Ping (Slot : int) return unsigned_char;
   pragma Import (C, Ping, "ws_ping");

   function Pong (Slot : int) return unsigned_char;
   pragma Import (C, Pong, "ws_pong");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ws_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);
   procedure Safe_Open (Slot : Proven_Error.Slot_Id);
   procedure Safe_Close
     (Slot : Proven_Error.Slot_Id;
      Code : Close_Code);

end Proven_Websocket;
