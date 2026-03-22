-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-tftp protocol (Trivial File Transfer Protocol).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Tftp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Opcodes (tags 0-4).
   type Opcode is (Op_Rrq, Op_Wrq, Op_Data, Op_Ack, Op_Error);
   for Opcode use (Op_Rrq => 0, Op_Wrq => 1, Op_Data => 2, Op_Ack => 3, Op_Error => 4);
   pragma Convention (C, Opcode);

   -- Transfer modes (tags 0-2).
   type Transfer_Mode is (Mode_Net_Ascii, Mode_Octet, Mode_Mail);
   for Transfer_Mode use (Mode_Net_Ascii => 0, Mode_Octet => 1, Mode_Mail => 2);
   pragma Convention (C, Transfer_Mode);

   -- TFTP error codes (tags 0-7).
   type Tftp_Error is
     (Err_Not_Defined, Err_File_Not_Found, Err_Access_Violation,
      Err_Disk_Full, Err_Illegal_Operation, Err_Unknown_Tid,
      Err_File_Exists, Err_No_Such_User);
   for Tftp_Error use
     (Err_Not_Defined       => 0, Err_File_Not_Found   => 1,
      Err_Access_Violation  => 2, Err_Disk_Full        => 3,
      Err_Illegal_Operation => 4, Err_Unknown_Tid      => 5,
      Err_File_Exists       => 6, Err_No_Such_User     => 7);
   pragma Convention (C, Tftp_Error);

   -- Transfer states (tags 0-4).
   type Transfer_State is
     (State_Idle, State_Reading, State_Writing, State_In_Error, State_Complete);
   for Transfer_State use
     (State_Idle => 0, State_Reading => 1, State_Writing => 2,
      State_In_Error => 3, State_Complete => 4);
   pragma Convention (C, Transfer_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "tftp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "tftp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "tftp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "tftp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "tftp_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Tftp;
