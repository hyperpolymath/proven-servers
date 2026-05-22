-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-hardened server protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Hardened is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- System hardening levels (tags 0-3).
   type Hardening_Level is
     (Level_Minimal,
      Level_Standard,
      Level_High,
      Level_Maximum);
   for Hardening_Level use
     (Level_Minimal  => 0,
      Level_Standard => 1,
      Level_High     => 2,
      Level_Maximum  => 3);
   pragma Convention (C, Hardening_Level);

   -- Security controls (tags 0-6).
   type Security_Control is
     (Ctrl_Aslr,
      Ctrl_Dep,
      Ctrl_Stack_Canary,
      Ctrl_Cfi,
      Ctrl_Sandboxing,
      Ctrl_Secure_Boot,
      Ctrl_Audit_Log);
   for Security_Control use
     (Ctrl_Aslr         => 0,
      Ctrl_Dep          => 1,
      Ctrl_Stack_Canary => 2,
      Ctrl_Cfi          => 3,
      Ctrl_Sandboxing   => 4,
      Ctrl_Secure_Boot  => 5,
      Ctrl_Audit_Log    => 6);
   pragma Convention (C, Security_Control);

   -- Security compliance standards (tags 0-4).
   type Compliance_Standard is
     (Std_Cis,
      Std_Stig,
      Std_Nist_800_53,
      Std_Pci_Dss,
      Std_Fips_140);
   for Compliance_Standard use
     (Std_Cis        => 0,
      Std_Stig       => 1,
      Std_Nist_800_53 => 2,
      Std_Pci_Dss    => 3,
      Std_Fips_140   => 4);
   pragma Convention (C, Compliance_Standard);

   -- Audit event types (tags 0-5).
   type Audit_Event is
     (Evt_Process_Start,
      Evt_File_Access,
      Evt_Network_Conn,
      Evt_Privilege_Escalation,
      Evt_Config_Change,
      Evt_Auth_Attempt);
   for Audit_Event use
     (Evt_Process_Start        => 0,
      Evt_File_Access          => 1,
      Evt_Network_Conn         => 2,
      Evt_Privilege_Escalation => 3,
      Evt_Config_Change        => 4,
      Evt_Auth_Attempt         => 5);
   pragma Convention (C, Audit_Event);

   -- Hardened system health (tags 0-3).
   type Health_Status is
     (Health_Healthy,
      Health_Degraded,
      Health_Compromised,
      Health_Unresponsive);
   for Health_Status use
     (Health_Healthy      => 0,
      Health_Degraded     => 1,
      Health_Compromised  => 2,
      Health_Unresponsive => 3);
   pragma Convention (C, Health_Status);

   -- Hardened server states (tags 0-4).
   type Server_State is
     (State_Idle,
      State_Hardening,
      State_Active,
      State_Auditing,
      State_Shutdown);
   for Server_State use
     (State_Idle      => 0,
      State_Hardening => 1,
      State_Active    => 2,
      State_Auditing  => 3,
      State_Shutdown  => 4);
   pragma Convention (C, Server_State);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "hardened_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "hardened_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "hardened_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "hardened_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "hardened_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Hardened;
