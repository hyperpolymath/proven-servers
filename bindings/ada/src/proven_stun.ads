-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-stun protocol (STUN/TURN NAT traversal).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Stun is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Message types (tags 0-11).
   type Message_Type is
     (Msg_Binding_Request, Msg_Binding_Response, Msg_Binding_Error,
      Msg_Allocate_Request, Msg_Allocate_Response, Msg_Allocate_Error,
      Msg_Refresh_Request, Msg_Refresh_Response,
      Msg_Send_Indication, Msg_Data_Indication,
      Msg_Create_Permission, Msg_Channel_Bind);
   for Message_Type use
     (Msg_Binding_Request   => 0,  Msg_Binding_Response   => 1,
      Msg_Binding_Error     => 2,  Msg_Allocate_Request   => 3,
      Msg_Allocate_Response => 4,  Msg_Allocate_Error     => 5,
      Msg_Refresh_Request   => 6,  Msg_Refresh_Response   => 7,
      Msg_Send_Indication   => 8,  Msg_Data_Indication    => 9,
      Msg_Create_Permission => 10, Msg_Channel_Bind       => 11);
   pragma Convention (C, Message_Type);

   -- Transport protocols (tags 0-3).
   type Transport_Protocol is (Tp_Udp, Tp_Tcp, Tp_Tls, Tp_Dtls);
   for Transport_Protocol use (Tp_Udp => 0, Tp_Tcp => 1, Tp_Tls => 2, Tp_Dtls => 3);
   pragma Convention (C, Transport_Protocol);

   -- Error codes (tags 0-7).
   type Stun_Error_Code is
     (Err_Try_Alternate, Err_Bad_Request, Err_Unauthorized,
      Err_Forbidden, Err_Mobility_Forbidden, Err_Stale_Nonce,
      Err_Server_Error, Err_Insufficient_Capacity);
   for Stun_Error_Code use
     (Err_Try_Alternate        => 0, Err_Bad_Request         => 1,
      Err_Unauthorized         => 2, Err_Forbidden           => 3,
      Err_Mobility_Forbidden   => 4, Err_Stale_Nonce         => 5,
      Err_Server_Error         => 6, Err_Insufficient_Capacity => 7);
   pragma Convention (C, Stun_Error_Code);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "stun_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "stun_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "stun_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "stun_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "stun_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Stun;
