-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-sandbox protocol (Sandbox/Isolation).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Sandbox is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Execution policies (tags 0-4).
   type Execution_Policy is
     (Pol_Unrestricted, Pol_Read_Only, Pol_Network_Denied,
      Pol_Isolated, Pol_Ephemeral);
   for Execution_Policy use
     (Pol_Unrestricted  => 0, Pol_Read_Only    => 1,
      Pol_Network_Denied => 2, Pol_Isolated    => 3,
      Pol_Ephemeral     => 4);
   pragma Convention (C, Execution_Policy);

   -- Resource limits (tags 0-5).
   type Resource_Limit is
     (Lim_Cpu_Time, Lim_Memory, Lim_Disk_Io,
      Lim_Network_Io, Lim_File_Descriptors, Lim_Processes);
   for Resource_Limit use
     (Lim_Cpu_Time         => 0, Lim_Memory          => 1,
      Lim_Disk_Io          => 2, Lim_Network_Io      => 3,
      Lim_File_Descriptors => 4, Lim_Processes       => 5);
   pragma Convention (C, Resource_Limit);

   -- Sandbox states (tags 0-5).
   type Sandbox_State is
     (State_Creating, State_Ready, State_Running,
      State_Suspended, State_Terminated, State_Destroyed);
   for Sandbox_State use
     (State_Creating   => 0, State_Ready      => 1,
      State_Running    => 2, State_Suspended  => 3,
      State_Terminated => 4, State_Destroyed  => 5);
   pragma Convention (C, Sandbox_State);

   -- Exit reasons (tags 0-5).
   type Exit_Reason is
     (Exit_Normal, Exit_Timeout, Exit_Memory_Exceeded,
      Exit_Policy_Violation, Exit_Killed, Exit_Error);
   for Exit_Reason use
     (Exit_Normal           => 0, Exit_Timeout          => 1,
      Exit_Memory_Exceeded  => 2, Exit_Policy_Violation => 3,
      Exit_Killed           => 4, Exit_Error            => 5);
   pragma Convention (C, Exit_Reason);

   -- Syscall policies (tags 0-3).
   type Syscall_Policy is (Sys_Allow, Sys_Deny, Sys_Log, Sys_Trap);
   for Syscall_Policy use
     (Sys_Allow => 0, Sys_Deny => 1, Sys_Log => 2, Sys_Trap => 3);
   pragma Convention (C, Syscall_Policy);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "sandbox_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "sandbox_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "sandbox_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "sandbox_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "sandbox_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Sandbox;
