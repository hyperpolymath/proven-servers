-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-log collector protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Logcollector is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Log severity levels (tags 0-5).
   type Log_Level is
     (Log_Trace, Log_Debug, Log_Info, Log_Warn, Log_Err, Log_Fatal);
   for Log_Level use
     (Log_Trace => 0, Log_Debug => 1, Log_Info => 2,
      Log_Warn => 3, Log_Err => 4, Log_Fatal => 5);
   pragma Convention (C, Log_Level);

   -- Log input formats (tags 0-5).
   type Input_Format is
     (Fmt_Json, Fmt_Logfmt, Fmt_Syslog, Fmt_Cef, Fmt_Gelf, Fmt_Raw);
   for Input_Format use
     (Fmt_Json => 0, Fmt_Logfmt => 1, Fmt_Syslog => 2,
      Fmt_Cef => 3, Fmt_Gelf => 4, Fmt_Raw => 5);
   pragma Convention (C, Input_Format);

   -- Log output targets (tags 0-4).
   type Output_Target is
     (Tgt_File, Tgt_Elasticsearch, Tgt_S3, Tgt_Kafka, Tgt_Stdout);
   for Output_Target use
     (Tgt_File => 0, Tgt_Elasticsearch => 1, Tgt_S3 => 2,
      Tgt_Kafka => 3, Tgt_Stdout => 4);
   pragma Convention (C, Output_Target);

   -- Log filter operations (tags 0-4).
   type Filter_Op is
     (Fop_Include, Fop_Exclude, Fop_Transform, Fop_Redact, Fop_Sample);
   for Filter_Op use
     (Fop_Include => 0, Fop_Exclude => 1, Fop_Transform => 2,
      Fop_Redact => 3, Fop_Sample => 4);
   pragma Convention (C, Filter_Op);

   -- Log pipeline stages (tags 0-4).
   type Pipeline_Stage is
     (Stg_Input, Stg_Parse, Stg_Filter, Stg_Transform, Stg_Output);
   for Pipeline_Stage use
     (Stg_Input => 0, Stg_Parse => 1, Stg_Filter => 2,
      Stg_Transform => 3, Stg_Output => 4);
   pragma Convention (C, Pipeline_Stage);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "logcollector_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "logcollector_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "logcollector_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "logcollector_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "logcollector_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Logcollector;
