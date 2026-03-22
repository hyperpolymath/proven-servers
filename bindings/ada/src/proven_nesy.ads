-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-neurosymbolic AI protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Nesy is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Neurosymbolic reasoning modes (tags 0-5).
   type Reasoning_Mode is
     (Rm_Symbolic, Rm_Neural, Rm_Sym_To_Neural,
      Rm_Neural_To_Sym, Rm_Ensemble, Rm_Cascade);
   for Reasoning_Mode use
     (Rm_Symbolic => 0, Rm_Neural => 1, Rm_Sym_To_Neural => 2,
      Rm_Neural_To_Sym => 3, Rm_Ensemble => 4, Rm_Cascade => 5);
   pragma Convention (C, Reasoning_Mode);

   -- Proof verification status (tags 0-5).
   type Proof_Status is
     (Ps_Pending, Ps_Attempting, Ps_Proved,
      Ps_Failed, Ps_Assumed, Ps_Vacuous);
   for Proof_Status use
     (Ps_Pending => 0, Ps_Attempting => 1, Ps_Proved => 2,
      Ps_Failed => 3, Ps_Assumed => 4, Ps_Vacuous => 5);
   pragma Convention (C, Proof_Status);

   -- Type constraint kinds (tags 0-7).
   type Constraint_Kind is
     (Ck_Type_Equality, Ck_Subtype, Ck_Linearity, Ck_Termination,
      Ck_Totality, Ck_Invariant, Ck_Refinement, Ck_Dependent_Index);
   for Constraint_Kind use
     (Ck_Type_Equality => 0, Ck_Subtype => 1, Ck_Linearity => 2,
      Ck_Termination => 3, Ck_Totality => 4, Ck_Invariant => 5,
      Ck_Refinement => 6, Ck_Dependent_Index => 7);
   pragma Convention (C, Constraint_Kind);

   -- Neural inference backend providers (tags 0-5).
   type Neural_Backend is
     (Nb_Local_Model, Nb_Claude, Nb_Gemini,
      Nb_Mistral, Nb_Gpt, Nb_Custom_Neural);
   for Neural_Backend use
     (Nb_Local_Model => 0, Nb_Claude => 1, Nb_Gemini => 2,
      Nb_Mistral => 3, Nb_Gpt => 4, Nb_Custom_Neural => 5);
   pragma Convention (C, Neural_Backend);

   -- Inference confidence levels (tags 0-5).
   type Confidence is
     (Conf_Verified, Conf_High_Neural, Conf_Medium_Neural,
      Conf_Low_Neural, Conf_Unknown, Conf_Contradicted);
   for Confidence use
     (Conf_Verified => 0, Conf_High_Neural => 1, Conf_Medium_Neural => 2,
      Conf_Low_Neural => 3, Conf_Unknown => 4, Conf_Contradicted => 5);
   pragma Convention (C, Confidence);

   -- Knowledge drift types (tags 0-5).
   type Drift_Kind is
     (Dk_No_Drift, Dk_Semantic, Dk_Confidence,
      Dk_Factual, Dk_Temporal, Dk_Catastrophic);
   for Drift_Kind use
     (Dk_No_Drift => 0, Dk_Semantic => 1, Dk_Confidence => 2,
      Dk_Factual => 3, Dk_Temporal => 4, Dk_Catastrophic => 5);
   pragma Convention (C, Drift_Kind);

   -- NeSy engine states (tags 0-5).
   type Nesy_State is
     (State_Idle, State_Ready, State_Reasoning,
      State_Verifying, State_Drift, State_Shutdown);
   for Nesy_State use
     (State_Idle => 0, State_Ready => 1, State_Reasoning => 2,
      State_Verifying => 3, State_Drift => 4, State_Shutdown => 5);
   pragma Convention (C, Nesy_State);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "nesy_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "nesy_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "nesy_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "nesy_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "nesy_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Nesy;
