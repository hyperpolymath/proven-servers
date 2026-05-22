-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-graphql protocol (GraphQL server).
--
-- Wraps the C-ABI functions from protocols/proven-graphql/ffi/zig/src/graphql.zig.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Graphql is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- GraphQL request lifecycle phases.
   type Graphql_Phase is
     (Phase_Received,
      Phase_Parsed,
      Phase_Executing,
      Phase_Complete,
      Phase_Error);
   for Graphql_Phase use
     (Phase_Received  => 0,
      Phase_Parsed    => 1,
      Phase_Executing => 2,
      Phase_Complete  => 3,
      Phase_Error     => 4);
   pragma Convention (C, Graphql_Phase);

   -- GraphQL operation types.
   type Operation_Type is (Op_Query, Op_Mutation, Op_Subscription);
   for Operation_Type use
     (Op_Query        => 0,
      Op_Mutation     => 1,
      Op_Subscription => 2);
   pragma Convention (C, Operation_Type);

   -- GraphQL error categories.
   type Error_Category is
     (Err_None,
      Err_Parse,
      Err_Validation,
      Err_Execution,
      Err_Internal);
   for Error_Category use
     (Err_None       => 0,
      Err_Parse      => 1,
      Err_Validation => 2,
      Err_Execution  => 3,
      Err_Internal   => 4);
   pragma Convention (C, Error_Category);

   -- Subscription lifecycle phases.
   type Sub_Phase is
     (Sub_Initializing,
      Sub_Active,
      Sub_Emitting,
      Sub_Completed,
      Sub_Aborted);
   pragma Convention (C, Sub_Phase);

   ---------------------------------------------------------------------------
   -- Raw FFI imports
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "graphql_abi_version");

   function Create (Op_Type : unsigned_char) return int;
   pragma Import (C, Create, "graphql_create");

   procedure Destroy (Slot : int);
   pragma Import (C, Destroy, "graphql_destroy");

   function Get_Phase (Slot : int) return unsigned_char;
   pragma Import (C, Get_Phase, "graphql_phase");

   function Get_Operation_Type (Slot : int) return unsigned_char;
   pragma Import (C, Get_Operation_Type, "graphql_operation_type");

   function Get_Error_Category (Slot : int) return unsigned_char;
   pragma Import (C, Get_Error_Category, "graphql_error_category");

   function Advance (Slot : int) return unsigned_char;
   pragma Import (C, Advance, "graphql_advance");

   function Abort_Op
     (Slot    : int;
      Err_Cat : unsigned_char) return unsigned_char;
   pragma Import (C, Abort_Op, "graphql_abort");

   function Set_Query_Depth
     (Slot  : int;
      Depth : unsigned_short) return unsigned_char;
   pragma Import (C, Set_Query_Depth, "graphql_set_query_depth");

   function Get_Query_Depth (Slot : int) return unsigned_short;
   pragma Import (C, Get_Query_Depth, "graphql_query_depth");

   function Set_Complexity
     (Slot  : int;
      Score : unsigned_short) return unsigned_char;
   pragma Import (C, Set_Complexity, "graphql_set_complexity");

   function Get_Complexity (Slot : int) return unsigned_short;
   pragma Import (C, Get_Complexity, "graphql_complexity");

   function Resolve_Field
     (Slot        : int;
      Type_Kind   : unsigned_char;
      Scalar_Kind : unsigned_char) return unsigned_char;
   pragma Import (C, Resolve_Field, "graphql_resolve_field");

   function Fields_Resolved (Slot : int) return unsigned_short;
   pragma Import (C, Fields_Resolved, "graphql_fields_resolved");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "graphql_can_transition");

   function Sub_Create (Slot : int) return int;
   pragma Import (C, Sub_Create, "graphql_sub_create");

   function Sub_Get_Phase (Slot : int) return unsigned_char;
   pragma Import (C, Sub_Get_Phase, "graphql_sub_phase");

   function Sub_Advance (Slot : int) return unsigned_char;
   pragma Import (C, Sub_Advance, "graphql_sub_advance");

   function Sub_Emit_Event (Slot : int) return unsigned_char;
   pragma Import (C, Sub_Emit_Event, "graphql_sub_emit_event");

   function Sub_Abort (Slot : int) return unsigned_char;
   pragma Import (C, Sub_Abort, "graphql_sub_abort");

   function Sub_Event_Count (Slot : int) return unsigned;
   pragma Import (C, Sub_Event_Count, "graphql_sub_event_count");

   function Sub_Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Sub_Can_Transition, "graphql_sub_can_transition");

   function Introspection_Query
     (Slot        : int;
      Intro_Field : unsigned_char) return unsigned_char;
   pragma Import (C, Introspection_Query, "graphql_introspection_query");

   function Check_Depth
     (Depth     : unsigned_short;
      Max_Depth : unsigned_short) return unsigned_char;
   pragma Import (C, Check_Depth, "graphql_check_depth");

   function Check_Complexity
     (Score          : unsigned_short;
      Max_Complexity : unsigned_short) return unsigned_char;
   pragma Import (C, Check_Complexity, "graphql_check_complexity");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create
     (Op : Operation_Type) return Proven_Error.Slot_Id;
   procedure Safe_Destroy (Slot : Proven_Error.Slot_Id);
   procedure Safe_Advance (Slot : Proven_Error.Slot_Id);

end Proven_Graphql;
