-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-semweb protocol (Semantic Web).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Semweb is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- RDF serialization formats (tags 0-5).
   type Rdf_Format is
     (Fmt_Rdf_Xml, Fmt_Turtle, Fmt_NTriples,
      Fmt_NQuads, Fmt_Json_Ld, Fmt_Trig);
   for Rdf_Format use
     (Fmt_Rdf_Xml  => 0, Fmt_Turtle   => 1, Fmt_NTriples => 2,
      Fmt_NQuads   => 3, Fmt_Json_Ld  => 4, Fmt_Trig     => 5);
   pragma Convention (C, Rdf_Format);

   -- Semantic web resource types (tags 0-4).
   type Semweb_Resource_Type is
     (Res_Class, Res_Property, Res_Individual, Res_Ontology, Res_Named_Graph);
   for Semweb_Resource_Type use
     (Res_Class      => 0, Res_Property    => 1, Res_Individual => 2,
      Res_Ontology   => 3, Res_Named_Graph => 4);
   pragma Convention (C, Semweb_Resource_Type);

   -- HTTP methods (tags 0-4).
   type Http_Method is (Meth_Get, Meth_Post, Meth_Put, Meth_Patch, Meth_Delete);
   for Http_Method use
     (Meth_Get => 0, Meth_Post => 1, Meth_Put => 2,
      Meth_Patch => 3, Meth_Delete => 4);
   pragma Convention (C, Http_Method);

   -- Content negotiation (tags 0-3).
   type Content_Negotiation is (Neg_Rdf_Xml, Neg_Turtle, Neg_Json_Ld, Neg_Html);
   for Content_Negotiation use
     (Neg_Rdf_Xml => 0, Neg_Turtle => 1, Neg_Json_Ld => 2, Neg_Html => 3);
   pragma Convention (C, Content_Negotiation);

   -- Error codes (tags 0-4).
   type Semweb_Error_Code is
     (Err_Not_Found, Err_Invalid_Uri, Err_Malformed_Rdf,
      Err_Unsupported_Format, Err_Conflicting_Triples);
   for Semweb_Error_Code use
     (Err_Not_Found          => 0, Err_Invalid_Uri       => 1,
      Err_Malformed_Rdf      => 2, Err_Unsupported_Format => 3,
      Err_Conflicting_Triples => 4);
   pragma Convention (C, Semweb_Error_Code);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "semweb_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "semweb_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "semweb_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "semweb_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "semweb_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Semweb;
