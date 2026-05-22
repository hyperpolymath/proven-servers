-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-triplestore protocol (RDF Triple Store).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Triplestore is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Statement types (tags 0-1).
   type Statement is (Stmt_Triple, Stmt_Quad);
   for Statement use (Stmt_Triple => 0, Stmt_Quad => 1);
   pragma Convention (C, Statement);

   -- Index orderings (tags 0-5).
   type Index_Order is (Idx_Spo, Idx_Pos, Idx_Osp, Idx_Gspo, Idx_Gpos, Idx_Gosp);
   for Index_Order use
     (Idx_Spo => 0, Idx_Pos => 1, Idx_Osp => 2,
      Idx_Gspo => 3, Idx_Gpos => 4, Idx_Gosp => 5);
   pragma Convention (C, Index_Order);

   -- Storage backends (tags 0-3).
   type Storage_Backend is (Sb_In_Memory, Sb_BTree, Sb_Lsm, Sb_Persistent);
   for Storage_Backend use
     (Sb_In_Memory => 0, Sb_BTree => 1, Sb_Lsm => 2, Sb_Persistent => 3);
   pragma Convention (C, Storage_Backend);

   -- Import formats (tags 0-5).
   type Import_Format is
     (Ifmt_NTriples, Ifmt_Turtle, Ifmt_Rdf_Xml,
      Ifmt_Json_Ld, Ifmt_NQuads, Ifmt_Trig);
   for Import_Format use
     (Ifmt_NTriples => 0, Ifmt_Turtle => 1, Ifmt_Rdf_Xml => 2,
      Ifmt_Json_Ld  => 3, Ifmt_NQuads => 4, Ifmt_Trig    => 5);
   pragma Convention (C, Import_Format);

   -- Transaction isolation (tags 0-2).
   type Transaction_Isolation is (Iso_Read_Committed, Iso_Serializable, Iso_Snapshot);
   for Transaction_Isolation use
     (Iso_Read_Committed => 0, Iso_Serializable => 1, Iso_Snapshot => 2);
   pragma Convention (C, Transaction_Isolation);

   -- Store states (tags 0-4).
   type Store_State is
     (State_Idle, State_Ready, State_In_Transaction, State_Importing, State_Closing);
   for Store_State use
     (State_Idle => 0, State_Ready => 1, State_In_Transaction => 2,
      State_Importing => 3, State_Closing => 4);
   pragma Convention (C, Store_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "triplestore_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "triplestore_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "triplestore_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "triplestore_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "triplestore_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Triplestore;
