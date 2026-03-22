-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-pqc protocol (Post-Quantum Cryptography).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Pqc is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- PQC algorithms (tags 0-7).
   type Pqc_Algorithm is
     (Algo_Crystals_Kyber,
      Algo_Crystals_Dilithium,
      Algo_Falcon,
      Algo_Sphincs_Plus,
      Algo_Classic_Mceliece,
      Algo_Bike,
      Algo_Hqc,
      Algo_Frodokem);
   for Pqc_Algorithm use
     (Algo_Crystals_Kyber     => 0,
      Algo_Crystals_Dilithium => 1,
      Algo_Falcon             => 2,
      Algo_Sphincs_Plus       => 3,
      Algo_Classic_Mceliece   => 4,
      Algo_Bike               => 5,
      Algo_Hqc                => 6,
      Algo_Frodokem           => 7);
   pragma Convention (C, Pqc_Algorithm);

   -- NIST security levels (tags 0-4).
   type Nist_Level is (Nist1, Nist2, Nist3, Nist4, Nist5);
   for Nist_Level use (Nist1 => 0, Nist2 => 1, Nist3 => 2, Nist4 => 3, Nist5 => 4);
   pragma Convention (C, Nist_Level);

   -- PQC operations (tags 0-4).
   type Operation is (Op_Keygen, Op_Encapsulate, Op_Decapsulate, Op_Sign, Op_Verify);
   for Operation use
     (Op_Keygen => 0, Op_Encapsulate => 1, Op_Decapsulate => 2,
      Op_Sign   => 3, Op_Verify      => 4);
   pragma Convention (C, Operation);

   -- Hybrid modes (tags 0-2).
   type Hybrid_Mode is (Mode_Classical_Only, Mode_Pqc_Only, Mode_Hybrid);
   for Hybrid_Mode use
     (Mode_Classical_Only => 0, Mode_Pqc_Only => 1, Mode_Hybrid => 2);
   pragma Convention (C, Hybrid_Mode);

   -- Algorithm categories (tags 0-1).
   type Algorithm_Category is (Cat_Kem, Cat_Signature);
   for Algorithm_Category use (Cat_Kem => 0, Cat_Signature => 1);
   pragma Convention (C, Algorithm_Category);

   -- Key lifecycle states (tags 0-5).
   type Key_State is
     (Key_Empty, Key_Generating, Key_Generated,
      Key_Active, Key_Expired, Key_Compromised);
   for Key_State use
     (Key_Empty       => 0, Key_Generating => 1, Key_Generated => 2,
      Key_Active      => 3, Key_Expired    => 4, Key_Compromised => 5);
   pragma Convention (C, Key_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "pqc_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "pqc_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "pqc_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "pqc_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "pqc_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Pqc;
