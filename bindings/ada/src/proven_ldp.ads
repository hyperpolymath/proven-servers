-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-linked data platform protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ldp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- LDP container types (tags 0-2).
   type Container_Type is (Ct_Basic, Ct_Direct, Ct_Indirect);
   for Container_Type use (Ct_Basic => 0, Ct_Direct => 1, Ct_Indirect => 2);
   pragma Convention (C, Container_Type);

   -- LDP resource types (tags 0-2).
   type Ldp_Resource_Type is (Rt_Rdf_Source, Rt_Non_Rdf_Source, Rt_Container);
   for Ldp_Resource_Type use
     (Rt_Rdf_Source => 0, Rt_Non_Rdf_Source => 1, Rt_Container => 2);
   pragma Convention (C, Ldp_Resource_Type);

   -- LDP prefer header values (tags 0-4).
   type Preference is
     (Pref_Minimal_Container, Pref_Include_Containment,
      Pref_Include_Membership, Pref_Omit_Containment,
      Pref_Omit_Membership);
   for Preference use
     (Pref_Minimal_Container => 0, Pref_Include_Containment => 1,
      Pref_Include_Membership => 2, Pref_Omit_Containment => 3,
      Pref_Omit_Membership => 4);
   pragma Convention (C, Preference);

   -- LDP interaction models (tags 0-4).
   type Interaction_Model is
     (Im_Ldpr, Im_Ldpc, Im_Basic_Container,
      Im_Direct_Container, Im_Indirect_Container);
   for Interaction_Model use
     (Im_Ldpr => 0, Im_Ldpc => 1, Im_Basic_Container => 2,
      Im_Direct_Container => 3, Im_Indirect_Container => 4);
   pragma Convention (C, Interaction_Model);

   -- LDP constraint violations (tags 0-3).
   type Constraint_Violation is
     (Cv_Membership_Constant, Cv_Contains_Triples_Modified,
      Cv_Server_Managed, Cv_Type_Conflict);
   for Constraint_Violation use
     (Cv_Membership_Constant => 0, Cv_Contains_Triples_Modified => 1,
      Cv_Server_Managed => 2, Cv_Type_Conflict => 3);
   pragma Convention (C, Constraint_Violation);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ldp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "ldp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "ldp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ldp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ldp_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Ldp;
