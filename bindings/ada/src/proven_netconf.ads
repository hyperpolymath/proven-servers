-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-netconf protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Netconf is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- NETCONF operations (tags 0-11).
   type Netconf_Operation is
     (Op_Get, Op_Get_Config, Op_Edit_Config, Op_Copy_Config,
      Op_Delete_Config, Op_Lock, Op_Unlock, Op_Close_Session,
      Op_Kill_Session, Op_Commit, Op_Validate, Op_Discard_Changes);
   for Netconf_Operation use
     (Op_Get => 0, Op_Get_Config => 1, Op_Edit_Config => 2,
      Op_Copy_Config => 3, Op_Delete_Config => 4, Op_Lock => 5,
      Op_Unlock => 6, Op_Close_Session => 7, Op_Kill_Session => 8,
      Op_Commit => 9, Op_Validate => 10, Op_Discard_Changes => 11);
   pragma Convention (C, Netconf_Operation);

   -- NETCONF datastores (tags 0-2).
   type Datastore is (Ds_Running, Ds_Startup, Ds_Candidate);
   for Datastore use (Ds_Running => 0, Ds_Startup => 1, Ds_Candidate => 2);
   pragma Convention (C, Datastore);

   -- NETCONF edit operations (tags 0-4).
   type Edit_Operation is
     (Eop_Merge, Eop_Replace, Eop_Create, Eop_Delete, Eop_Remove);
   for Edit_Operation use
     (Eop_Merge => 0, Eop_Replace => 1, Eop_Create => 2,
      Eop_Delete => 3, Eop_Remove => 4);
   pragma Convention (C, Edit_Operation);

   -- NETCONF error types (tags 0-3).
   type Netconf_Error_Type is
     (Net_Transport, Net_Rpc, Net_Protocol, Net_Application);
   for Netconf_Error_Type use
     (Net_Transport => 0, Net_Rpc => 1, Net_Protocol => 2,
      Net_Application => 3);
   pragma Convention (C, Netconf_Error_Type);

   -- NETCONF error severity (tags 0-1).
   type Error_Severity is (Esev_Error, Esev_Warning);
   for Error_Severity use (Esev_Error => 0, Esev_Warning => 1);
   pragma Convention (C, Error_Severity);

   -- NETCONF session states (tags 0-5).
   type Netconf_State is
     (State_Idle, State_Connected, State_Locked,
      State_Editing, State_Closing, State_Terminated);
   for Netconf_State use
     (State_Idle => 0, State_Connected => 1, State_Locked => 2,
      State_Editing => 3, State_Closing => 4, State_Terminated => 5);
   pragma Convention (C, Netconf_State);

   -- Standard NETCONF SSH port.
   Netconf_Port : constant := 830;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "netconf_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "netconf_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "netconf_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "netconf_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "netconf_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Netconf;
