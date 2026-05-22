-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-irc protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Irc is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- IRC commands (tags 0-16).
   type Irc_Command is
     (Cmd_Nick, Cmd_User, Cmd_Join, Cmd_Part, Cmd_Privmsg,
      Cmd_Notice, Cmd_Quit, Cmd_Ping, Cmd_Pong, Cmd_Mode,
      Cmd_Kick, Cmd_Topic, Cmd_Invite, Cmd_Names, Cmd_List,
      Cmd_Who, Cmd_Whois);
   for Irc_Command use
     (Cmd_Nick => 0, Cmd_User => 1, Cmd_Join => 2, Cmd_Part => 3,
      Cmd_Privmsg => 4, Cmd_Notice => 5, Cmd_Quit => 6, Cmd_Ping => 7,
      Cmd_Pong => 8, Cmd_Mode => 9, Cmd_Kick => 10, Cmd_Topic => 11,
      Cmd_Invite => 12, Cmd_Names => 13, Cmd_List => 14, Cmd_Who => 15,
      Cmd_Whois => 16);
   pragma Convention (C, Irc_Command);

   -- IRC connection states (tags 0-4).
   type Irc_State is
     (State_Disconnected, State_Connecting, State_Registered,
      State_In_Channel, State_Quitting);
   for Irc_State use
     (State_Disconnected => 0, State_Connecting => 1,
      State_Registered => 2, State_In_Channel => 3, State_Quitting => 4);
   pragma Convention (C, Irc_State);

   -- IRC channel modes (tags 0-9).
   type Channel_Mode is
     (Mode_Op, Mode_Voice, Mode_Ban, Mode_Limit, Mode_Invite_Only,
      Mode_Moderated, Mode_No_External_Msgs, Mode_Topic_Lock,
      Mode_Secret, Mode_Private);
   for Channel_Mode use
     (Mode_Op => 0, Mode_Voice => 1, Mode_Ban => 2, Mode_Limit => 3,
      Mode_Invite_Only => 4, Mode_Moderated => 5, Mode_No_External_Msgs => 6,
      Mode_Topic_Lock => 7, Mode_Secret => 8, Mode_Private => 9);
   pragma Convention (C, Channel_Mode);

   -- IRC numeric replies (tags 0-10).
   type Numeric_Reply is
     (Reply_Welcome, Reply_Your_Host, Reply_Created, Reply_My_Info,
      Reply_Bounce, Reply_Nick_In_Use, Reply_No_Such_Nick,
      Reply_No_Such_Channel, Reply_Channel_Is_Full,
      Reply_Invite_Only_Chan, Reply_Banned_From_Chan);
   for Numeric_Reply use
     (Reply_Welcome => 0, Reply_Your_Host => 1, Reply_Created => 2,
      Reply_My_Info => 3, Reply_Bounce => 4, Reply_Nick_In_Use => 5,
      Reply_No_Such_Nick => 6, Reply_No_Such_Channel => 7,
      Reply_Channel_Is_Full => 8, Reply_Invite_Only_Chan => 9,
      Reply_Banned_From_Chan => 10);
   pragma Convention (C, Numeric_Reply);

   -- IRC error categories (tags 0-5).
   type Irc_Error is
     (Err_None, Err_Nick_In_Use, Err_Channel_Full,
      Err_Invite_Only, Err_Banned, Err_Not_Registered);
   for Irc_Error use
     (Err_None => 0, Err_Nick_In_Use => 1, Err_Channel_Full => 2,
      Err_Invite_Only => 3, Err_Banned => 4, Err_Not_Registered => 5);
   pragma Convention (C, Irc_Error);

   -- Standard IRC ports.
   Irc_Port  : constant := 6667;
   Ircs_Port : constant := 6697;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "irc_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "irc_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "irc_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "irc_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "irc_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Irc;
