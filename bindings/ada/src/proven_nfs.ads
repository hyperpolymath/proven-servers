-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-nfs protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Nfs is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- NFS operations (tags 0-14).
   type Nfs_Operation is
     (Op_Access, Op_Close, Op_Commit, Op_Create, Op_Get_Attr,
      Op_Link, Op_Lock, Op_Lookup, Op_Open, Op_Read,
      Op_Read_Dir, Op_Remove, Op_Rename, Op_Set_Attr, Op_Write);
   for Nfs_Operation use
     (Op_Access => 0, Op_Close => 1, Op_Commit => 2, Op_Create => 3,
      Op_Get_Attr => 4, Op_Link => 5, Op_Lock => 6, Op_Lookup => 7,
      Op_Open => 8, Op_Read => 9, Op_Read_Dir => 10, Op_Remove => 11,
      Op_Rename => 12, Op_Set_Attr => 13, Op_Write => 14);
   pragma Convention (C, Nfs_Operation);

   -- NFS file types (tags 0-6).
   type File_Type is
     (Ft_Regular, Ft_Directory, Ft_Block_Device, Ft_Char_Device,
      Ft_Link, Ft_Socket, Ft_Fifo);
   for File_Type use
     (Ft_Regular => 0, Ft_Directory => 1, Ft_Block_Device => 2,
      Ft_Char_Device => 3, Ft_Link => 4, Ft_Socket => 5, Ft_Fifo => 6);
   pragma Convention (C, File_Type);

   -- NFS status codes (tags 0-13).
   type Nfs_Status is
     (Nfs_Ok, Nfs_Perm, Nfs_No_Ent, Nfs_Io, Nfs_Nx_Io,
      Nfs_Access, Nfs_Exist, Nfs_Not_Dir, Nfs_Is_Dir,
      Nfs_F_Big, Nfs_No_Spc, Nfs_R_Ofs, Nfs_Not_Empty, Nfs_Stale);
   for Nfs_Status use
     (Nfs_Ok => 0, Nfs_Perm => 1, Nfs_No_Ent => 2, Nfs_Io => 3,
      Nfs_Nx_Io => 4, Nfs_Access => 5, Nfs_Exist => 6, Nfs_Not_Dir => 7,
      Nfs_Is_Dir => 8, Nfs_F_Big => 9, Nfs_No_Spc => 10,
      Nfs_R_Ofs => 11, Nfs_Not_Empty => 12, Nfs_Stale => 13);
   pragma Convention (C, Nfs_Status);

   -- NFS server lifecycle states (tags 0-5).
   type Nfs_State is
     (State_Idle, State_Mounted, State_File_Open,
      State_Locked, State_Busy, State_Unmounting);
   for Nfs_State use
     (State_Idle => 0, State_Mounted => 1, State_File_Open => 2,
      State_Locked => 3, State_Busy => 4, State_Unmounting => 5);
   pragma Convention (C, Nfs_State);

   -- Standard NFS port.
   Nfs_Port : constant := 2049;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "nfs_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "nfs_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "nfs_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "nfs_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "nfs_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Nfs;
