-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-ftp protocol (FTP server).
--
-- Wraps the C-ABI functions from protocols/proven-ftp/ffi/zig/src/ftp.zig.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ftp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- FTP session states matching SessionState in ftp.zig.
   type Ftp_Session_State is
     (State_Connected,
      State_User_Ok,
      State_Authenticated,
      State_Renaming,
      State_Quit);
   for Ftp_Session_State use
     (State_Connected     => 0,
      State_User_Ok       => 1,
      State_Authenticated => 2,
      State_Renaming      => 3,
      State_Quit          => 4);
   pragma Convention (C, Ftp_Session_State);

   -- FTP transfer types.
   type Transfer_Type is (Type_ASCII, Type_Binary);
   for Transfer_Type use (Type_ASCII => 0, Type_Binary => 1);
   pragma Convention (C, Transfer_Type);

   -- FTP data connection modes.
   type Data_Mode is (Mode_None, Mode_Passive, Mode_Active);
   for Data_Mode use (Mode_None => 0, Mode_Passive => 1, Mode_Active => 2);
   pragma Convention (C, Data_Mode);

   -- FTP data transfer states.
   type Transfer_State is
     (Transfer_Idle,
      Transfer_In_Progress,
      Transfer_Complete,
      Transfer_Aborted);
   for Transfer_State use
     (Transfer_Idle        => 0,
      Transfer_In_Progress => 1,
      Transfer_Complete    => 2,
      Transfer_Aborted     => 3);
   pragma Convention (C, Transfer_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ftp_abi_version");

   function Create return int;
   pragma Import (C, Create, "ftp_create");

   procedure Destroy (Slot : int);
   pragma Import (C, Destroy, "ftp_destroy");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ftp_state");

   function Get_Transfer_Type (Slot : int) return unsigned_char;
   pragma Import (C, Get_Transfer_Type, "ftp_transfer_type");

   function Get_Data_Mode (Slot : int) return unsigned_char;
   pragma Import (C, Get_Data_Mode, "ftp_data_mode");

   function Get_Transfer_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_Transfer_State, "ftp_transfer_state");

   function Bytes_Transferred (Slot : int) return unsigned_long;
   pragma Import (C, Bytes_Transferred, "ftp_bytes_transferred");

   function File_Count (Slot : int) return unsigned;
   pragma Import (C, File_Count, "ftp_file_count");

   function Last_Reply_Code (Slot : int) return unsigned_short;
   pragma Import (C, Last_Reply_Code, "ftp_last_reply_code");

   function Cwd
     (Slot    : int;
      Buf     : access unsigned_char;
      Buf_Len : unsigned) return unsigned;
   pragma Import (C, Cwd, "ftp_cwd");

   function User_Cmd
     (Slot : int;
      Name : access unsigned_char;
      Len  : unsigned) return unsigned_char;
   pragma Import (C, User_Cmd, "ftp_user");

   function Pass_Cmd
     (Slot : int;
      Pass : access unsigned_char;
      Len  : unsigned) return unsigned_char;
   pragma Import (C, Pass_Cmd, "ftp_pass");

   function Quit_Cmd (Slot : int) return unsigned_char;
   pragma Import (C, Quit_Cmd, "ftp_quit");

   function Cwd_Cmd
     (Slot     : int;
      Path     : access unsigned_char;
      Path_Len : unsigned) return unsigned_char;
   pragma Import (C, Cwd_Cmd, "ftp_cwd_cmd");

   function Cdup (Slot : int) return unsigned_char;
   pragma Import (C, Cdup, "ftp_cdup");

   function Set_Type
     (Slot     : int;
      Type_Tag : unsigned_char) return unsigned_char;
   pragma Import (C, Set_Type, "ftp_set_type");

   function Set_Passive (Slot : int) return unsigned_char;
   pragma Import (C, Set_Passive, "ftp_set_passive");

   function Set_Active
     (Slot : int;
      Port : unsigned_short) return unsigned_char;
   pragma Import (C, Set_Active, "ftp_set_active");

   function Begin_Transfer (Slot : int) return unsigned_char;
   pragma Import (C, Begin_Transfer, "ftp_begin_transfer");

   function Add_Bytes
     (Slot  : int;
      Count : unsigned_long) return unsigned_char;
   pragma Import (C, Add_Bytes, "ftp_add_bytes");

   function Complete_Transfer (Slot : int) return unsigned_char;
   pragma Import (C, Complete_Transfer, "ftp_complete_transfer");

   function Abort_Transfer (Slot : int) return unsigned_char;
   pragma Import (C, Abort_Transfer, "ftp_abort_transfer");

   function Begin_Rename (Slot : int) return unsigned_char;
   pragma Import (C, Begin_Rename, "ftp_begin_rename");

   function Complete_Rename (Slot : int) return unsigned_char;
   pragma Import (C, Complete_Rename, "ftp_complete_rename");

   function Can_Transfer (State_Tag : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transfer, "ftp_can_transfer");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ftp_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create return Proven_Error.Slot_Id;
   procedure Safe_Destroy (Slot : Proven_Error.Slot_Id);
   procedure Safe_Quit (Slot : Proven_Error.Slot_Id);

end Proven_Ftp;
