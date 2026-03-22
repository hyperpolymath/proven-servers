-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-graphdb protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Graphdb is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Graph element types (tags 0-4).
   type Element_Type is
     (Elem_Node,
      Elem_Edge,
      Elem_Property,
      Elem_Label,
      Elem_Index);
   for Element_Type use
     (Elem_Node     => 0,
      Elem_Edge     => 1,
      Elem_Property => 2,
      Elem_Label    => 3,
      Elem_Index    => 4);
   pragma Convention (C, Element_Type);

   -- Graph query languages (tags 0-3).
   type Query_Language is
     (Lang_Cypher,
      Lang_Gremlin,
      Lang_Sparql,
      Lang_Graphql);
   for Query_Language use
     (Lang_Cypher  => 0,
      Lang_Gremlin => 1,
      Lang_Sparql  => 2,
      Lang_Graphql => 3);
   pragma Convention (C, Query_Language);

   -- Graph traversal strategies (tags 0-4).
   type Traversal_Strategy is
     (Trav_Bfs,
      Trav_Dfs,
      Trav_Dijkstra,
      Trav_A_Star,
      Trav_Random);
   for Traversal_Strategy use
     (Trav_Bfs      => 0,
      Trav_Dfs      => 1,
      Trav_Dijkstra => 2,
      Trav_A_Star   => 3,
      Trav_Random   => 4);
   pragma Convention (C, Traversal_Strategy);

   -- Consistency levels (tags 0-3).
   type Consistency is
     (Cons_Strong,
      Cons_Eventual,
      Cons_Session,
      Cons_Causal);
   for Consistency use
     (Cons_Strong   => 0,
      Cons_Eventual => 1,
      Cons_Session  => 2,
      Cons_Causal   => 3);
   pragma Convention (C, Consistency);

   -- Graph database error codes (tags 0-6).
   type Graphdb_Error is
     (Err_Syntax,
      Err_Node_Not_Found,
      Err_Edge_Not_Found,
      Err_Constraint_Violation,
      Err_Index_Exists,
      Err_Transaction_Conflict,
      Err_Out_Of_Memory);
   for Graphdb_Error use
     (Err_Syntax               => 0,
      Err_Node_Not_Found       => 1,
      Err_Edge_Not_Found       => 2,
      Err_Constraint_Violation => 3,
      Err_Index_Exists         => 4,
      Err_Transaction_Conflict => 5,
      Err_Out_Of_Memory        => 6);
   pragma Convention (C, Graphdb_Error);

   -- Graph database session states (tags 0-4).
   type Session_State is
     (State_Idle,
      State_Connected,
      State_Querying,
      State_Traversing,
      State_Disconnecting);
   for Session_State use
     (State_Idle          => 0,
      State_Connected     => 1,
      State_Querying      => 2,
      State_Traversing    => 3,
      State_Disconnecting => 4);
   pragma Convention (C, Session_State);

   -- Standard Bolt protocol port.
   Graphdb_Port : constant := 7687;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "graphdb_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "graphdb_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "graphdb_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "graphdb_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "graphdb_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Graphdb;
