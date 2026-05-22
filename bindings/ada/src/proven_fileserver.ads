-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-fileserver protocol (File server).
--
-- Wraps the C-ABI functions from protocols/proven-fileserver/ffi/zig/src/fileserver.zig:
--   fileserver_abi_version, fileserver_create_context, fileserver_destroy_context,
--   fileserver_state, fileserver_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Fileserver is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `FileOperation` in `FileserverABI.Types`.
   type File_Operation is
     (Read,
      Write,
      Create,
      Delete,
      Rename,
      List,
      Stat,
      Lock,
      Unlock,
      Watch);
   pragma Convention (C, File_Operation);

   -- Matches `FileType` in `FileserverABI.Types`.
   type File_Type is
     (Regular,
      Directory,
      Symlink,
      Block_Device,
      Char_Device,
      Fifo,
      Socket);
   pragma Convention (C, File_Type);

   -- Matches `FilePermission` in `FileserverABI.Types`.
   type File_Permission is
     (Owner_Read,
      Owner_Write,
      Owner_Execute,
      Group_Read,
      Group_Write,
      Group_Execute,
      Other_Read,
      Other_Write,
      Other_Execute);
   pragma Convention (C, File_Permission);

   -- Matches `LockType` in `FileserverABI.Types`.
   type Lock_Type is
     (Shared,
      Exclusive,
      Advisory,
      Mandatory);
   pragma Convention (C, Lock_Type);

   -- Matches `FileErrorCode` in `FileserverABI.Types`.
   type File_Error_Code is
     (Not_Found,
      Permission_Denied,
      Already_Exists,
      Not_Empty,
      Is_Directory,
      Not_Directory,
      No_Space,
      Read_Only,
      Locked,
      Io_Error);
   pragma Convention (C, File_Error_Code);

   -- Matches `SessionState` in `FileserverABI.Types`.
   type Session_State is
     (Idle,
      Connected,
      Operating,
      Fs_Locked,
      Disconnecting);
   pragma Convention (C, Session_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "fileserver_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "fileserver_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "fileserver_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "fileserver_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "fileserver_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Fileserver;
