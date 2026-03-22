-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-key management protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Kms is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Managed object types (tags 0-5).
   type Object_Type is
     (Obj_Symmetric_Key, Obj_Public_Key, Obj_Private_Key,
      Obj_Secret_Data, Obj_Certificate, Obj_Opaque_Data);
   for Object_Type use
     (Obj_Symmetric_Key => 0, Obj_Public_Key => 1, Obj_Private_Key => 2,
      Obj_Secret_Data => 3, Obj_Certificate => 4, Obj_Opaque_Data => 5);
   pragma Convention (C, Object_Type);

   -- KMS operations (tags 0-14).
   type Kms_Operation is
     (Op_Create, Op_Get, Op_Activate, Op_Revoke, Op_Destroy,
      Op_Locate, Op_Register, Op_Rekey, Op_Encrypt, Op_Decrypt,
      Op_Sign, Op_Verify, Op_Wrap, Op_Unwrap, Op_Mac);
   for Kms_Operation use
     (Op_Create => 0, Op_Get => 1, Op_Activate => 2, Op_Revoke => 3,
      Op_Destroy => 4, Op_Locate => 5, Op_Register => 6, Op_Rekey => 7,
      Op_Encrypt => 8, Op_Decrypt => 9, Op_Sign => 10, Op_Verify => 11,
      Op_Wrap => 12, Op_Unwrap => 13, Op_Mac => 14);
   pragma Convention (C, Kms_Operation);

   -- Key lifecycle states (tags 0-5).
   type Key_State is
     (Key_Pre_Active, Key_Active, Key_Deactivated,
      Key_Compromised, Key_Destroyed, Key_Destroyed_Compromised);
   for Key_State use
     (Key_Pre_Active => 0, Key_Active => 1, Key_Deactivated => 2,
      Key_Compromised => 3, Key_Destroyed => 4,
      Key_Destroyed_Compromised => 5);
   pragma Convention (C, Key_State);

   -- Cryptographic algorithms (tags 0-8).
   type Kms_Algorithm is
     (Algo_Aes128, Algo_Aes256, Algo_Rsa2048, Algo_Rsa4096,
      Algo_Ecdsa_P256, Algo_Ecdsa_P384, Algo_Ed25519,
      Algo_Chacha20_Poly1305, Algo_Hmac_Sha256);
   for Kms_Algorithm use
     (Algo_Aes128 => 0, Algo_Aes256 => 1, Algo_Rsa2048 => 2,
      Algo_Rsa4096 => 3, Algo_Ecdsa_P256 => 4, Algo_Ecdsa_P384 => 5,
      Algo_Ed25519 => 6, Algo_Chacha20_Poly1305 => 7,
      Algo_Hmac_Sha256 => 8);
   pragma Convention (C, Kms_Algorithm);

   -- Standard KMIP port.
   Kms_Port : constant := 5696;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "kms_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "kms_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "kms_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "kms_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "kms_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Kms;
