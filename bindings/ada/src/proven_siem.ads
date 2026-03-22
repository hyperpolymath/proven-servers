-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-siem protocol (Security Information and Event Management).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Siem is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Event severity (tags 0-4).
   type Event_Severity is (Sev_Info, Sev_Low, Sev_Medium, Sev_High, Sev_Critical);
   for Event_Severity use
     (Sev_Info => 0, Sev_Low => 1, Sev_Medium => 2,
      Sev_High => 3, Sev_Critical => 4);
   pragma Convention (C, Event_Severity);

   -- Event categories (tags 0-6).
   type Event_Category is
     (Cat_Authentication, Cat_Network_Traffic, Cat_File_Activity,
      Cat_Process_Execution, Cat_Policy_Violation,
      Cat_Malware, Cat_Data_Exfiltration);
   for Event_Category use
     (Cat_Authentication     => 0, Cat_Network_Traffic   => 1,
      Cat_File_Activity      => 2, Cat_Process_Execution => 3,
      Cat_Policy_Violation   => 4, Cat_Malware           => 5,
      Cat_Data_Exfiltration  => 6);
   pragma Convention (C, Event_Category);

   -- Correlation rules (tags 0-4).
   type Correlation_Rule is
     (Rule_Threshold, Rule_Sequence, Rule_Aggregation,
      Rule_Absence, Rule_Statistical);
   for Correlation_Rule use
     (Rule_Threshold   => 0, Rule_Sequence    => 1,
      Rule_Aggregation => 2, Rule_Absence     => 3,
      Rule_Statistical => 4);
   pragma Convention (C, Correlation_Rule);

   -- Alert states (tags 0-4).
   type Alert_State is
     (Alert_New, Alert_Acknowledged, Alert_In_Progress,
      Alert_Resolved, Alert_False_Positive);
   for Alert_State use
     (Alert_New          => 0, Alert_Acknowledged => 1,
      Alert_In_Progress  => 2, Alert_Resolved     => 3,
      Alert_False_Positive => 4);
   pragma Convention (C, Alert_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "siem_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "siem_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "siem_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "siem_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "siem_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Siem;
