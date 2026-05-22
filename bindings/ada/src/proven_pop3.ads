-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-pop3 protocol (POP3 mail retrieval).
--
-- Enumerations match the Idris2 ABI tag definitions from POP3ABI.Types.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Pop3 is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- POP3 commands (RFC 1939, tags 0-10).
   type Command is
     (Cmd_User, Cmd_Pass, Cmd_Stat, Cmd_List, Cmd_Retr,
      Cmd_Dele, Cmd_Noop, Cmd_Rset, Cmd_Quit, Cmd_Top, Cmd_Uidl);
   for Command use
     (Cmd_User => 0, Cmd_Pass => 1, Cmd_Stat => 2, Cmd_List => 3,
      Cmd_Retr => 4, Cmd_Dele => 5, Cmd_Noop => 6, Cmd_Rset => 7,
      Cmd_Quit => 8, Cmd_Top  => 9, Cmd_Uidl => 10);
   pragma Convention (C, Command);

   -- POP3 session states (RFC 1939, tags 0-2).
   type Session_State is (State_Authorization, State_Transaction, State_Update);
   for Session_State use
     (State_Authorization => 0, State_Transaction => 1, State_Update => 2);
   pragma Convention (C, Session_State);

   -- POP3 response indicators (tags 0-1).
   type Response is (Resp_Ok, Resp_Err);
   for Response use (Resp_Ok => 0, Resp_Err => 1);
   pragma Convention (C, Response);

   -- POP3 FFI error codes (tags 0-5).
   type Pop3_Error is
     (Err_Ok, Err_Invalid_Slot, Err_Not_Active,
      Err_Invalid_Transition, Err_Invalid_Command, Err_Auth_Failed);
   for Pop3_Error use
     (Err_Ok                 => 0, Err_Invalid_Slot       => 1,
      Err_Not_Active         => 2, Err_Invalid_Transition => 3,
      Err_Invalid_Command    => 4, Err_Auth_Failed        => 5);
   pragma Convention (C, Pop3_Error);

   ---------------------------------------------------------------------------
   -- Raw FFI imports
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "pop3_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "pop3_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "pop3_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "pop3_state");

   function Can_Transition
     (From : unsigned_char; To : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "pop3_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Pop3;
