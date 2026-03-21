-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-smtp protocol (SMTP server).
--
-- Wraps the C-ABI functions from protocols/proven-smtp/ffi/zig/src/smtp.zig:
--   smtp_abi_version, smtp_create_context, smtp_destroy_context,
--   smtp_get_state, smtp_greet, smtp_authenticate, smtp_auth_complete,
--   smtp_set_sender, smtp_add_recipient, smtp_start_data, smtp_append_data,
--   smtp_finish_data, smtp_reset, smtp_quit, smtp_enable_tls,
--   smtp_can_transition, smtp_get_reply_code, smtp_get_recipient_count,
--   smtp_get_data_size, smtp_get_auth_mechanism, smtp_is_authenticated,
--   smtp_is_tls_active.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Smtp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- SMTP session lifecycle states.
   type Smtp_State is
     (State_Connected,
      State_Greeted,
      State_Auth_Started,
      State_Authenticated,
      State_Mail_From,
      State_Rcpt_To,
      State_Data,
      State_Data_Done,
      State_Quit);
   for Smtp_State use
     (State_Connected     => 0,
      State_Greeted       => 1,
      State_Auth_Started  => 2,
      State_Authenticated => 3,
      State_Mail_From     => 4,
      State_Rcpt_To       => 5,
      State_Data          => 6,
      State_Data_Done     => 7,
      State_Quit          => 8);
   pragma Convention (C, Smtp_State);

   -- SMTP authentication mechanisms.
   type Auth_Mechanism is
     (Auth_None,
      Auth_Plain,
      Auth_Login,
      Auth_CRAM_MD5,
      Auth_XOAUTH2);
   for Auth_Mechanism use
     (Auth_None     => 0,
      Auth_Plain    => 1,
      Auth_Login    => 2,
      Auth_CRAM_MD5 => 3,
      Auth_XOAUTH2  => 4);
   pragma Convention (C, Auth_Mechanism);

   ---------------------------------------------------------------------------
   -- Raw FFI imports
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "smtp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "smtp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "smtp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "smtp_get_state");

   function Get_Reply_Code (Slot : int) return unsigned_char;
   pragma Import (C, Get_Reply_Code, "smtp_get_reply_code");

   function Get_Recipient_Count (Slot : int) return unsigned_char;
   pragma Import (C, Get_Recipient_Count, "smtp_get_recipient_count");

   function Get_Data_Size (Slot : int) return unsigned;
   pragma Import (C, Get_Data_Size, "smtp_get_data_size");

   function Get_Auth_Mechanism (Slot : int) return unsigned_char;
   pragma Import (C, Get_Auth_Mechanism, "smtp_get_auth_mechanism");

   function Is_Authenticated (Slot : int) return unsigned_char;
   pragma Import (C, Is_Authenticated, "smtp_is_authenticated");

   function Is_Tls_Active (Slot : int) return unsigned_char;
   pragma Import (C, Is_Tls_Active, "smtp_is_tls_active");

   function Greet
     (Slot    : int;
      Is_Ehlo : unsigned_char) return unsigned_char;
   pragma Import (C, Greet, "smtp_greet");

   function Authenticate
     (Slot : int;
      Mech : unsigned_char) return unsigned_char;
   pragma Import (C, Authenticate, "smtp_authenticate");

   function Auth_Complete
     (Slot    : int;
      Success : unsigned_char) return unsigned_char;
   pragma Import (C, Auth_Complete, "smtp_auth_complete");

   function Set_Sender (Slot : int) return unsigned_char;
   pragma Import (C, Set_Sender, "smtp_set_sender");

   function Add_Recipient (Slot : int) return unsigned_char;
   pragma Import (C, Add_Recipient, "smtp_add_recipient");

   function Start_Data (Slot : int) return unsigned_char;
   pragma Import (C, Start_Data, "smtp_start_data");

   function Append_Data
     (Slot : int;
      Len  : unsigned) return unsigned_char;
   pragma Import (C, Append_Data, "smtp_append_data");

   function Finish_Data (Slot : int) return unsigned_char;
   pragma Import (C, Finish_Data, "smtp_finish_data");

   function Reset (Slot : int) return unsigned_char;
   pragma Import (C, Reset, "smtp_reset");

   function Quit (Slot : int) return unsigned_char;
   pragma Import (C, Quit, "smtp_quit");

   function Enable_Tls (Slot : int) return unsigned_char;
   pragma Import (C, Enable_Tls, "smtp_enable_tls");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "smtp_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);
   procedure Safe_Greet (Slot : Proven_Error.Slot_Id; Is_Ehlo : Boolean);
   procedure Safe_Quit (Slot : Proven_Error.Slot_Id);

end Proven_Smtp;
