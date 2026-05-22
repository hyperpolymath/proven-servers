-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-sparql protocol (SPARQL endpoint).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Sparql is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Query types (tags 0-3).
   type Query_Type is (Qt_Select, Qt_Construct, Qt_Ask, Qt_Describe);
   for Query_Type use
     (Qt_Select => 0, Qt_Construct => 1, Qt_Ask => 2, Qt_Describe => 3);
   pragma Convention (C, Query_Type);

   -- Update types (tags 0-5).
   type Update_Type is
     (Upd_Insert, Upd_Delete, Upd_Load, Upd_Clear, Upd_Create, Upd_Drop);
   for Update_Type use
     (Upd_Insert => 0, Upd_Delete => 1, Upd_Load => 2,
      Upd_Clear  => 3, Upd_Create => 4, Upd_Drop => 5);
   pragma Convention (C, Update_Type);

   -- Result formats (tags 0-3).
   type Result_Format is (Fmt_Xml, Fmt_Json, Fmt_Csv, Fmt_Tsv);
   for Result_Format use (Fmt_Xml => 0, Fmt_Json => 1, Fmt_Csv => 2, Fmt_Tsv => 3);
   pragma Convention (C, Result_Format);

   -- Error types (tags 0-4).
   type Sparql_Error_Type is
     (Err_Parse, Err_Query_Timeout, Err_Results_Too_Large,
      Err_Unknown_Graph, Err_Access_Denied);
   for Sparql_Error_Type use
     (Err_Parse            => 0, Err_Query_Timeout     => 1,
      Err_Results_Too_Large => 2, Err_Unknown_Graph    => 3,
      Err_Access_Denied    => 4);
   pragma Convention (C, Sparql_Error_Type);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "sparql_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "sparql_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "sparql_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "sparql_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "sparql_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Sparql;
