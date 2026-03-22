-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-rtsp protocol (Real Time Streaming Protocol).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Rtsp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- RTSP methods (tags 0-10).
   type Method is
     (Meth_Describe, Meth_Setup, Meth_Play, Meth_Pause, Meth_Teardown,
      Meth_Get_Parameter, Meth_Set_Parameter, Meth_Options,
      Meth_Announce, Meth_Record, Meth_Redirect);
   for Method use
     (Meth_Describe      => 0, Meth_Setup         => 1,
      Meth_Play          => 2, Meth_Pause         => 3,
      Meth_Teardown      => 4, Meth_Get_Parameter => 5,
      Meth_Set_Parameter => 6, Meth_Options       => 7,
      Meth_Announce      => 8, Meth_Record        => 9,
      Meth_Redirect      => 10);
   pragma Convention (C, Method);

   -- Transport protocols (tags 0-2).
   type Transport_Protocol is (Tp_Rtp_Avp_Udp, Tp_Rtp_Avp_Tcp, Tp_Rtp_Avp_Udp_Multicast);
   for Transport_Protocol use
     (Tp_Rtp_Avp_Udp => 0, Tp_Rtp_Avp_Tcp => 1, Tp_Rtp_Avp_Udp_Multicast => 2);
   pragma Convention (C, Transport_Protocol);

   -- Session states (tags 0-3).
   type Session_State is (State_Init, State_Ready, State_Playing, State_Recording);
   for Session_State use
     (State_Init => 0, State_Ready => 1, State_Playing => 2, State_Recording => 3);
   pragma Convention (C, Session_State);

   -- Status codes (tags 0-11).
   type Status_Code is
     (Sc_Ok, Sc_Moved_Permanently, Sc_Moved_Temporarily,
      Sc_Bad_Request, Sc_Unauthorized, Sc_Not_Found,
      Sc_Method_Not_Allowed, Sc_Not_Acceptable,
      Sc_Session_Not_Found, Sc_Internal_Server_Error,
      Sc_Not_Implemented, Sc_Service_Unavailable);
   for Status_Code use
     (Sc_Ok                    => 0,  Sc_Moved_Permanently     => 1,
      Sc_Moved_Temporarily     => 2,  Sc_Bad_Request           => 3,
      Sc_Unauthorized          => 4,  Sc_Not_Found             => 5,
      Sc_Method_Not_Allowed    => 6,  Sc_Not_Acceptable        => 7,
      Sc_Session_Not_Found     => 8,  Sc_Internal_Server_Error => 9,
      Sc_Not_Implemented       => 10, Sc_Service_Unavailable   => 11);
   pragma Convention (C, Status_Code);

   -- FFI error codes (tags 0-6).
   type Rtsp_Error is
     (Err_Ok, Err_Invalid_Slot, Err_Not_Active,
      Err_Invalid_Transition, Err_Method_Not_Allowed,
      Err_Transport_Error, Err_Session_Expired);
   for Rtsp_Error use
     (Err_Ok                 => 0, Err_Invalid_Slot       => 1,
      Err_Not_Active         => 2, Err_Invalid_Transition => 3,
      Err_Method_Not_Allowed => 4, Err_Transport_Error    => 5,
      Err_Session_Expired    => 6);
   pragma Convention (C, Rtsp_Error);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "rtsp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "rtsp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "rtsp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "rtsp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "rtsp_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Rtsp;
