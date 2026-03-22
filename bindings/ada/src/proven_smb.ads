-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-smb protocol (Server Message Block).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Smb is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- SMB2/3 commands (tags 0-15).
   type Smb_Command is
     (Cmd_Negotiate, Cmd_Session_Setup, Cmd_Logoff,
      Cmd_Tree_Connect, Cmd_Tree_Disconnect, Cmd_Create,
      Cmd_Close, Cmd_Read, Cmd_Write, Cmd_Lock, Cmd_Ioctl,
      Cmd_Cancel, Cmd_Query_Directory, Cmd_Change_Notify,
      Cmd_Query_Info, Cmd_Set_Info);
   for Smb_Command use
     (Cmd_Negotiate       => 0,  Cmd_Session_Setup   => 1,
      Cmd_Logoff          => 2,  Cmd_Tree_Connect    => 3,
      Cmd_Tree_Disconnect => 4,  Cmd_Create          => 5,
      Cmd_Close           => 6,  Cmd_Read            => 7,
      Cmd_Write           => 8,  Cmd_Lock            => 9,
      Cmd_Ioctl           => 10, Cmd_Cancel          => 11,
      Cmd_Query_Directory => 12, Cmd_Change_Notify   => 13,
      Cmd_Query_Info      => 14, Cmd_Set_Info        => 15);
   pragma Convention (C, Smb_Command);

   -- SMB dialects (tags 0-4).
   type Dialect is (Smb2_0_2, Smb2_1, Smb3_0, Smb3_0_2, Smb3_1_1);
   for Dialect use
     (Smb2_0_2 => 0, Smb2_1 => 1, Smb3_0 => 2, Smb3_0_2 => 3, Smb3_1_1 => 4);
   pragma Convention (C, Dialect);

   -- Share types (tags 0-2).
   type Share_Type is (Share_Disk, Share_Pipe, Share_Print);
   for Share_Type use (Share_Disk => 0, Share_Pipe => 1, Share_Print => 2);
   pragma Convention (C, Share_Type);

   -- Session states (tags 0-5).
   type Session_State is
     (State_Idle, State_Negotiated, State_Authenticated,
      State_Tree_Connected, State_File_Open, State_Disconnecting);
   for Session_State use
     (State_Idle           => 0, State_Negotiated     => 1,
      State_Authenticated  => 2, State_Tree_Connected => 3,
      State_File_Open      => 4, State_Disconnecting  => 5);
   pragma Convention (C, Session_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "smb_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "smb_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "smb_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "smb_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "smb_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Smb;
