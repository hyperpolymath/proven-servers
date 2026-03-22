-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-imap protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Imap is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- IMAP commands (tags 0-13).
   type Imap_Command is
     (Cmd_Login, Cmd_Logout, Cmd_Select, Cmd_Examine,
      Cmd_Create, Cmd_Delete, Cmd_Rename, Cmd_List,
      Cmd_Fetch, Cmd_Store, Cmd_Search, Cmd_Copy,
      Cmd_Noop, Cmd_Capability);
   for Imap_Command use
     (Cmd_Login => 0, Cmd_Logout => 1, Cmd_Select => 2, Cmd_Examine => 3,
      Cmd_Create => 4, Cmd_Delete => 5, Cmd_Rename => 6, Cmd_List => 7,
      Cmd_Fetch => 8, Cmd_Store => 9, Cmd_Search => 10, Cmd_Copy => 11,
      Cmd_Noop => 12, Cmd_Capability => 13);
   pragma Convention (C, Imap_Command);

   -- IMAP session states (tags 0-3).
   type Imap_State is
     (State_Not_Authenticated, State_Authenticated,
      State_Selected, State_Logout);
   for Imap_State use
     (State_Not_Authenticated => 0, State_Authenticated => 1,
      State_Selected => 2, State_Logout => 3);
   pragma Convention (C, Imap_State);

   -- IMAP message flags (tags 0-5).
   type Imap_Flag is
     (Flag_Seen, Flag_Answered, Flag_Flagged,
      Flag_Deleted, Flag_Draft, Flag_Recent);
   for Imap_Flag use
     (Flag_Seen => 0, Flag_Answered => 1, Flag_Flagged => 2,
      Flag_Deleted => 3, Flag_Draft => 4, Flag_Recent => 5);
   pragma Convention (C, Imap_Flag);

   -- Standard IMAP ports.
   Imap_Port  : constant := 143;
   Imaps_Port : constant := 993;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "imap_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "imap_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "imap_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "imap_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "imap_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Imap;
