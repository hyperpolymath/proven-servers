-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-oblivious dns protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Odns is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- ODNS participant roles (tags 0-2).
   type Odns_Role is (Role_Client, Role_Proxy, Role_Target);
   for Odns_Role use (Role_Client => 0, Role_Proxy => 1, Role_Target => 2);
   pragma Convention (C, Odns_Role);

   -- ODNS message types (tags 0-1).
   type Odns_Message_Type is (Omt_Query, Omt_Response);
   for Odns_Message_Type use (Omt_Query => 0, Omt_Response => 1);
   pragma Convention (C, Odns_Message_Type);

   -- ODNS error reasons (tags 0-4).
   type Odns_Error_Reason is
     (Oer_Proxy_Error, Oer_Target_Error, Oer_Decryption_Failed,
      Oer_Invalid_Config, Oer_Payload_Too_Large);
   for Odns_Error_Reason use
     (Oer_Proxy_Error => 0, Oer_Target_Error => 1,
      Oer_Decryption_Failed => 2, Oer_Invalid_Config => 3,
      Oer_Payload_Too_Large => 4);
   pragma Convention (C, Odns_Error_Reason);

   -- ODNS encapsulation formats (tag 0).
   type Encapsulation_Format is (Ef_Hpke);
   for Encapsulation_Format use (Ef_Hpke => 0);
   pragma Convention (C, Encapsulation_Format);

   -- ODNS session states (tags 0-4).
   type Session_State is
     (State_Idle, State_Key_Exchange, State_Ready,
      State_Processing, State_Closing);
   for Session_State use
     (State_Idle => 0, State_Key_Exchange => 1, State_Ready => 2,
      State_Processing => 3, State_Closing => 4);
   pragma Convention (C, Session_State);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "odns_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "odns_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "odns_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "odns_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "odns_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Odns;
