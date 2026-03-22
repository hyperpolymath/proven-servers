-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-ocsp protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ocsp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Certificate status (tags 0-2).
   type Cert_Status is (Cs_Good, Cs_Revoked, Cs_Unknown);
   for Cert_Status use (Cs_Good => 0, Cs_Revoked => 1, Cs_Unknown => 2);
   pragma Convention (C, Cert_Status);

   -- OCSP response status (tags 0-5).
   type Response_Status is
     (Rs_Successful, Rs_Malformed_Request, Rs_Internal_Error,
      Rs_Try_Later, Rs_Sig_Required, Rs_Unauthorized);
   for Response_Status use
     (Rs_Successful => 0, Rs_Malformed_Request => 1,
      Rs_Internal_Error => 2, Rs_Try_Later => 3,
      Rs_Sig_Required => 4, Rs_Unauthorized => 5);
   pragma Convention (C, Response_Status);

   -- OCSP hash algorithms (tags 0-3).
   type Hash_Algorithm is (Ha_Sha1, Ha_Sha256, Ha_Sha384, Ha_Sha512);
   for Hash_Algorithm use
     (Ha_Sha1 => 0, Ha_Sha256 => 1, Ha_Sha384 => 2, Ha_Sha512 => 3);
   pragma Convention (C, Hash_Algorithm);

   -- OCSP responder states (tags 0-4).
   type Responder_State is
     (State_Idle, State_Ready, State_Processing, State_Signing, State_Closing);
   for Responder_State use
     (State_Idle => 0, State_Ready => 1, State_Processing => 2,
      State_Signing => 3, State_Closing => 4);
   pragma Convention (C, Responder_State);

   -- Standard OCSP HTTP port.
   Ocsp_Port : constant := 80;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ocsp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "ocsp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "ocsp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ocsp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ocsp_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Ocsp;
