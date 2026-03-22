-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-monitor protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Monitor is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Monitor check types (tags 0-10).
   type Check_Type is
     (Ct_Http, Ct_Tcp, Ct_Udp, Ct_Icmp, Ct_Dns,
      Ct_Certificate, Ct_Disk, Ct_Cpu, Ct_Memory, Ct_Process, Ct_Custom);
   for Check_Type use
     (Ct_Http => 0, Ct_Tcp => 1, Ct_Udp => 2, Ct_Icmp => 3,
      Ct_Dns => 4, Ct_Certificate => 5, Ct_Disk => 6, Ct_Cpu => 7,
      Ct_Memory => 8, Ct_Process => 9, Ct_Custom => 10);
   pragma Convention (C, Check_Type);

   -- Monitor status values (tags 0-4).
   type Monitor_Status is
     (Ms_Up, Ms_Down, Ms_Degraded, Ms_Unknown, Ms_Maintenance);
   for Monitor_Status use
     (Ms_Up => 0, Ms_Down => 1, Ms_Degraded => 2,
      Ms_Unknown => 3, Ms_Maintenance => 4);
   pragma Convention (C, Monitor_Status);

   -- Alert notification channels (tags 0-4).
   type Alert_Channel is
     (Ac_Email, Ac_Sms, Ac_Webhook, Ac_Slack, Ac_Pager_Duty);
   for Alert_Channel use
     (Ac_Email => 0, Ac_Sms => 1, Ac_Webhook => 2,
      Ac_Slack => 3, Ac_Pager_Duty => 4);
   pragma Convention (C, Alert_Channel);

   -- Monitor severity levels (tags 0-3).
   type Severity is (Sev_Info, Sev_Warning, Sev_Error, Sev_Critical);
   for Severity use
     (Sev_Info => 0, Sev_Warning => 1, Sev_Error => 2, Sev_Critical => 3);
   pragma Convention (C, Severity);

   -- Monitor check execution states (tags 0-5).
   type Check_State is
     (Cst_Pending, Cst_Running, Cst_Passed,
      Cst_Failed, Cst_Timeout, Cst_Error);
   for Check_State use
     (Cst_Pending => 0, Cst_Running => 1, Cst_Passed => 2,
      Cst_Failed => 3, Cst_Timeout => 4, Cst_Error => 5);
   pragma Convention (C, Check_State);

   -- Monitor service states (tags 0-5).
   type Monitor_State is
     (State_Idle, State_Configured, State_Running,
      State_Paused, State_Alerting, State_Shutdown);
   for Monitor_State use
     (State_Idle => 0, State_Configured => 1, State_Running => 2,
      State_Paused => 3, State_Alerting => 4, State_Shutdown => 5);
   pragma Convention (C, Monitor_State);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "monitor_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "monitor_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "monitor_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "monitor_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "monitor_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Monitor;
