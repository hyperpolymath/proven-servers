-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-configmgmt protocol (Configuration management).
--
-- Wraps the C-ABI functions from protocols/proven-configmgmt/ffi/zig/src/configmgmt.zig:
--   configmgmt_abi_version, configmgmt_create_context, configmgmt_destroy_context,
--   configmgmt_state, configmgmt_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Configmgmt is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `ResourceType` in `ConfigmgmtABI.Types`.
   type Resource_Type is
     (File,
      Package,
      Service,
      User,
      Group,
      Cron,
      Mount,
      Firewall,
      Registry);
   pragma Convention (C, Resource_Type);

   -- Matches `ResourceState` in `ConfigmgmtABI.Types`.
   type Resource_State is
     (Present,
      Absent,
      Running,
      Stopped,
      Enabled,
      Disabled);
   pragma Convention (C, Resource_State);

   -- Matches `ChangeAction` in `ConfigmgmtABI.Types`.
   type Change_Action is
     (Create,
      Modify,
      Delete,
      Restart,
      Reload,
      Skip);
   pragma Convention (C, Change_Action);

   -- Matches `DriftStatus` in `ConfigmgmtABI.Types`.
   type Drift_Status is
     (In_Sync,
      Drifted,
      D_Unknown,
      Unmanaged);
   pragma Convention (C, Drift_Status);

   -- Matches `ApplyMode` in `ConfigmgmtABI.Types`.
   type Apply_Mode is
     (Enforce,
      Dry_Run,
      Audit);
   pragma Convention (C, Apply_Mode);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "configmgmt_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "configmgmt_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "configmgmt_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "configmgmt_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "configmgmt_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Configmgmt;
