-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-line printer daemon protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Lpd is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- LPD command codes (tags 1-5, per RFC 1179).
   type Command_Code is
     (Cc_Print_Job, Cc_Receive_Job, Cc_Short_Queue,
      Cc_Long_Queue, Cc_Remove_Jobs);
   for Command_Code use
     (Cc_Print_Job => 1, Cc_Receive_Job => 2, Cc_Short_Queue => 3,
      Cc_Long_Queue => 4, Cc_Remove_Jobs => 5);
   pragma Convention (C, Command_Code);

   -- LPD sub-command codes (tags 1-3).
   type Sub_Command_Code is
     (Sc_Abort_Job, Sc_Control_File, Sc_Data_File);
   for Sub_Command_Code use
     (Sc_Abort_Job => 1, Sc_Control_File => 2, Sc_Data_File => 3);
   pragma Convention (C, Sub_Command_Code);

   -- Print job status (tags 0-3).
   type Job_Status is
     (Js_Pending, Js_Printing, Js_Complete, Js_Failed);
   for Job_Status use
     (Js_Pending => 0, Js_Printing => 1, Js_Complete => 2, Js_Failed => 3);
   pragma Convention (C, Job_Status);

   -- Standard LPD port.
   Lpd_Port : constant := 515;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "lpd_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "lpd_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "lpd_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "lpd_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "lpd_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Lpd;
