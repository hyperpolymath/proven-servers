-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-xmpp protocol (Extensible Messaging and Presence Protocol).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Xmpp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Stanza types (tags 0-2).
   type Stanza_Type is (St_Message, St_Presence, St_Iq);
   for Stanza_Type use (St_Message => 0, St_Presence => 1, St_Iq => 2);
   pragma Convention (C, Stanza_Type);

   -- Message types (tags 0-4).
   type Message_Type is (Mt_Chat, Mt_Error, Mt_Groupchat, Mt_Headline, Mt_Normal);
   for Message_Type use
     (Mt_Chat => 0, Mt_Error => 1, Mt_Groupchat => 2,
      Mt_Headline => 3, Mt_Normal => 4);
   pragma Convention (C, Message_Type);

   -- Presence types (tags 0-4).
   type Presence_Type is (Pr_Available, Pr_Away, Pr_Dnd, Pr_Xa, Pr_Unavailable);
   for Presence_Type use
     (Pr_Available => 0, Pr_Away => 1, Pr_Dnd => 2,
      Pr_Xa => 3, Pr_Unavailable => 4);
   pragma Convention (C, Presence_Type);

   -- IQ types (tags 0-3).
   type Iq_Type is (Iq_Get, Iq_Set, Iq_Result, Iq_Error);
   for Iq_Type use (Iq_Get => 0, Iq_Set => 1, Iq_Result => 2, Iq_Error => 3);
   pragma Convention (C, Iq_Type);

   -- Stream errors (tags 0-8).
   type Stream_Error is
     (Se_Bad_Format, Se_Conflict, Se_Connection_Timeout,
      Se_Host_Gone, Se_Host_Unknown, Se_Not_Authorized,
      Se_Policy_Violation, Se_Resource_Constraint, Se_System_Shutdown);
   for Stream_Error use
     (Se_Bad_Format          => 0, Se_Conflict            => 1,
      Se_Connection_Timeout  => 2, Se_Host_Gone           => 3,
      Se_Host_Unknown        => 4, Se_Not_Authorized      => 5,
      Se_Policy_Violation    => 6, Se_Resource_Constraint  => 7,
      Se_System_Shutdown     => 8);
   pragma Convention (C, Stream_Error);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "xmpp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "xmpp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "xmpp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "xmpp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "xmpp_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Xmpp;
