-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-neurosymbolic engine protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Neurosym is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Neurosymbolic inference modes (tags 0-3).
   type Inference_Mode is
     (Im_Neural, Im_Symbolic, Im_Hybrid, Im_Cascade);
   for Inference_Mode use
     (Im_Neural => 0, Im_Symbolic => 1, Im_Hybrid => 2, Im_Cascade => 3);
   pragma Convention (C, Inference_Mode);

   -- Symbolic reasoning operations (tags 0-5).
   type Symbolic_Op is
     (Sop_Unify, Sop_Resolve, Sop_Rewrite,
      Sop_Prove, Sop_Search, Sop_Constrain);
   for Symbolic_Op use
     (Sop_Unify => 0, Sop_Resolve => 1, Sop_Rewrite => 2,
      Sop_Prove => 3, Sop_Search => 4, Sop_Constrain => 5);
   pragma Convention (C, Symbolic_Op);

   -- Neural inference operations (tags 0-5).
   type Neural_Op is
     (Nop_Embed, Nop_Classify, Nop_Generate,
      Nop_Attend, Nop_Retrieve, Nop_Finetune);
   for Neural_Op use
     (Nop_Embed => 0, Nop_Classify => 1, Nop_Generate => 2,
      Nop_Attend => 3, Nop_Retrieve => 4, Nop_Finetune => 5);
   pragma Convention (C, Neural_Op);

   -- Neural-symbolic fusion strategies (tags 0-4).
   type Fusion_Strategy is
     (Fs_Neural_Then_Symbolic, Fs_Symbolic_Then_Neural,
      Fs_Parallel, Fs_Iterative, Fs_Gated);
   for Fusion_Strategy use
     (Fs_Neural_Then_Symbolic => 0, Fs_Symbolic_Then_Neural => 1,
      Fs_Parallel => 2, Fs_Iterative => 3, Fs_Gated => 4);
   pragma Convention (C, Fusion_Strategy);

   -- Inference confidence levels (tags 0-5).
   type Confidence_Level is
     (Cl_Proven, Cl_High_Confidence, Cl_Moderate,
      Cl_Low_Confidence, Cl_Uncertain, Cl_Contradicted);
   for Confidence_Level use
     (Cl_Proven => 0, Cl_High_Confidence => 1, Cl_Moderate => 2,
      Cl_Low_Confidence => 3, Cl_Uncertain => 4, Cl_Contradicted => 5);
   pragma Convention (C, Confidence_Level);

   -- Knowledge entry types (tags 0-5).
   type Knowledge_Type is
     (Kt_Axiom, Kt_Learned, Kt_Inferred,
      Kt_Grounded, Kt_Hypothetical, Kt_Retracted);
   for Knowledge_Type use
     (Kt_Axiom => 0, Kt_Learned => 1, Kt_Inferred => 2,
      Kt_Grounded => 3, Kt_Hypothetical => 4, Kt_Retracted => 5);
   pragma Convention (C, Knowledge_Type);

   -- Neurosymbolic engine states (tags 0-5).
   type Neurosym_State is
     (State_Idle, State_Ready, State_Inferring,
      State_Reasoning, State_Fusing, State_Shutdown);
   for Neurosym_State use
     (State_Idle => 0, State_Ready => 1, State_Inferring => 2,
      State_Reasoning => 3, State_Fusing => 4, State_Shutdown => 5);
   pragma Convention (C, Neurosym_State);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "neurosym_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "neurosym_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "neurosym_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "neurosym_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "neurosym_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Neurosym;
