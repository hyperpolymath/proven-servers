-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-network time security protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Nts is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- NTS-KE record types (tags 0-8).
   type Nts_Record_Type is
     (Rt_End_Of_Message, Rt_Next_Protocol, Rt_Error, Rt_Warning,
      Rt_Aead_Algorithm, Rt_Cookie, Rt_Cookie_Placeholder,
      Rt_Ntske_Server, Rt_Ntske_Port);
   for Nts_Record_Type use
     (Rt_End_Of_Message => 0, Rt_Next_Protocol => 1, Rt_Error => 2,
      Rt_Warning => 3, Rt_Aead_Algorithm => 4, Rt_Cookie => 5,
      Rt_Cookie_Placeholder => 6, Rt_Ntske_Server => 7, Rt_Ntske_Port => 8);
   pragma Convention (C, Nts_Record_Type);

   -- NTS error codes (tags 0-2).
   type Nts_Error_Code is
     (Ec_Unrecognized_Critical, Ec_Bad_Request, Ec_Internal_Error);
   for Nts_Error_Code use
     (Ec_Unrecognized_Critical => 0, Ec_Bad_Request => 1,
      Ec_Internal_Error => 2);
   pragma Convention (C, Nts_Error_Code);

   -- AEAD algorithms for NTS (tags 0-2).
   type Aead_Algorithm is
     (Aead_Aes128_Gcm, Aead_Aes256_Gcm, Aead_Aes_Siv_Cmac256);
   for Aead_Algorithm use
     (Aead_Aes128_Gcm => 0, Aead_Aes256_Gcm => 1,
      Aead_Aes_Siv_Cmac256 => 2);
   pragma Convention (C, Aead_Algorithm);

   -- NTS handshake states (tags 0-3).
   type Handshake_State is
     (Hs_Initial, Hs_Negotiating, Hs_Established, Hs_Failed);
   for Handshake_State use
     (Hs_Initial => 0, Hs_Negotiating => 1,
      Hs_Established => 2, Hs_Failed => 3);
   pragma Convention (C, Handshake_State);

   -- NTS session lifecycle states (tags 0-4).
   type Session_State is
     (State_Idle, State_Handshaking, State_Negotiating,
      State_Established, State_Closing);
   for Session_State use
     (State_Idle => 0, State_Handshaking => 1, State_Negotiating => 2,
      State_Established => 3, State_Closing => 4);
   pragma Convention (C, Session_State);

   -- Standard NTS-KE port.
   Nts_Ke_Port : constant := 4460;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "nts_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "nts_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "nts_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "nts_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "nts_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Nts;
