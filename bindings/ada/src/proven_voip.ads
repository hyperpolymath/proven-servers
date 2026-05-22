-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-voip protocol (VoIP/SIP).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Voip is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- SIP methods (tags 0-12).
   type Sip_Method is
     (Meth_Invite, Meth_Ack, Meth_Bye, Meth_Cancel, Meth_Register,
      Meth_Options, Meth_Info, Meth_Update, Meth_Subscribe,
      Meth_Notify, Meth_Refer, Meth_Message, Meth_Prack);
   for Sip_Method use
     (Meth_Invite    => 0,  Meth_Ack       => 1,  Meth_Bye       => 2,
      Meth_Cancel    => 3,  Meth_Register  => 4,  Meth_Options   => 5,
      Meth_Info      => 6,  Meth_Update    => 7,  Meth_Subscribe => 8,
      Meth_Notify    => 9,  Meth_Refer     => 10, Meth_Message   => 11,
      Meth_Prack     => 12);
   pragma Convention (C, Sip_Method);

   -- SIP response codes (tags 0-16).
   type Response_Code is
     (Rc_Trying, Rc_Ringing, Rc_Session_Progress, Rc_Ok,
      Rc_Multiple_Choices, Rc_Moved_Permanently, Rc_Moved_Temporarily,
      Rc_Bad_Request, Rc_Unauthorized, Rc_Forbidden, Rc_Not_Found,
      Rc_Method_Not_Allowed, Rc_Request_Timeout, Rc_Busy_Here,
      Rc_Decline, Rc_Server_Internal_Error, Rc_Service_Unavailable);
   for Response_Code use
     (Rc_Trying              => 0,  Rc_Ringing             => 1,
      Rc_Session_Progress    => 2,  Rc_Ok                  => 3,
      Rc_Multiple_Choices    => 4,  Rc_Moved_Permanently   => 5,
      Rc_Moved_Temporarily   => 6,  Rc_Bad_Request         => 7,
      Rc_Unauthorized        => 8,  Rc_Forbidden           => 9,
      Rc_Not_Found           => 10, Rc_Method_Not_Allowed  => 11,
      Rc_Request_Timeout     => 12, Rc_Busy_Here           => 13,
      Rc_Decline             => 14, Rc_Server_Internal_Error => 15,
      Rc_Service_Unavailable => 16);
   pragma Convention (C, Response_Code);

   -- Dialog states (tags 0-2).
   type Dialog_State is (Dlg_Early, Dlg_Confirmed, Dlg_Terminated);
   for Dialog_State use (Dlg_Early => 0, Dlg_Confirmed => 1, Dlg_Terminated => 2);
   pragma Convention (C, Dialog_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "voip_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "voip_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "voip_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "voip_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "voip_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Voip;
