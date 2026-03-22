-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-chat protocol (Real-time chat server).
--
-- Wraps the C-ABI functions from protocols/proven-chat/ffi/zig/src/chat.zig:
--   chat_abi_version, chat_create_context, chat_destroy_context,
--   chat_state, chat_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Chat is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `MessageType` in `ChatABI.Types`.
   type Message_Type is
     (Text,
      Image,
      File,
      System,
      Reaction,
      Edit,
      Delete,
      Reply,
      Thread);
   pragma Convention (C, Message_Type);

   -- Matches `PresenceStatus` in `ChatABI.Types`.
   type Presence_Status is
     (Online,
      Away,
      Dnd,
      Invisible,
      Offline);
   pragma Convention (C, Presence_Status);

   -- Matches `RoomType` in `ChatABI.Types`.
   type Room_Type is
     (Direct,
      Group,
      Channel,
      Broadcast);
   pragma Convention (C, Room_Type);

   -- Matches `Permission` in `ChatABI.Types`.
   type Permission is
     (Read,
      Write,
      Admin,
      Invite,
      Kick,
      Ban,
      Pin,
      Delete_Others);
   pragma Convention (C, Permission);

   -- Matches `Event` in `ChatABI.Types`.
   type Event is
     (Message_Sent,
      Message_Delivered,
      Message_Read,
      User_Joined,
      User_Left,
      Typing,
      Room_Created);
   pragma Convention (C, Event);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "chat_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "chat_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "chat_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "chat_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "chat_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Chat;
