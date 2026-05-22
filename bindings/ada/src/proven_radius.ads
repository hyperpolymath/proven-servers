-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-radius protocol (RADIUS AAA).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Radius is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- RADIUS packet types (non-contiguous tags matching RFC 2865).
   type Packet_Type is
     (Pkt_Access_Request, Pkt_Access_Accept, Pkt_Access_Reject,
      Pkt_Accounting_Request, Pkt_Accounting_Response, Pkt_Access_Challenge);
   for Packet_Type use
     (Pkt_Access_Request      => 1, Pkt_Access_Accept       => 2,
      Pkt_Access_Reject       => 3, Pkt_Accounting_Request  => 4,
      Pkt_Accounting_Response => 5, Pkt_Access_Challenge    => 11);
   pragma Convention (C, Packet_Type);

   -- RADIUS attribute types (non-contiguous tags matching RFC 2865).
   type Attribute_Type is
     (Attr_User_Name, Attr_User_Password, Attr_Nas_Ip_Address,
      Attr_Nas_Port, Attr_Service_Type, Attr_Framed_Protocol,
      Attr_Framed_Ip_Address, Attr_Reply_Message, Attr_Session_Timeout);
   for Attribute_Type use
     (Attr_User_Name       => 1,  Attr_User_Password     => 2,
      Attr_Nas_Ip_Address  => 4,  Attr_Nas_Port          => 5,
      Attr_Service_Type    => 6,  Attr_Framed_Protocol   => 7,
      Attr_Framed_Ip_Address => 8, Attr_Reply_Message    => 18,
      Attr_Session_Timeout => 27);
   pragma Convention (C, Attribute_Type);

   -- Service types (tags 1-6).
   type Service_Type is
     (Svc_Login, Svc_Framed, Svc_Callback_Login,
      Svc_Callback_Framed, Svc_Outbound, Svc_Administrative);
   for Service_Type use
     (Svc_Login          => 1, Svc_Framed          => 2,
      Svc_Callback_Login => 3, Svc_Callback_Framed => 4,
      Svc_Outbound       => 5, Svc_Administrative  => 6);
   pragma Convention (C, Service_Type);

   -- Authentication methods (tags 0-4).
   type Auth_Method is (Auth_Pap, Auth_Chap, Auth_Mschap, Auth_Mschapv2, Auth_Eap);
   for Auth_Method use
     (Auth_Pap => 0, Auth_Chap => 1, Auth_Mschap => 2,
      Auth_Mschapv2 => 3, Auth_Eap => 4);
   pragma Convention (C, Auth_Method);

   -- Session states (tags 0-6).
   type Session_State is
     (State_Idle, State_Authenticating, State_Authorized,
      State_Rejected, State_Challenged, State_Accounting, State_Complete);
   for Session_State use
     (State_Idle           => 0, State_Authenticating => 1,
      State_Authorized     => 2, State_Rejected       => 3,
      State_Challenged     => 4, State_Accounting     => 5,
      State_Complete       => 6);
   pragma Convention (C, Session_State);

   -- FFI result codes (tags 0-4).
   type Radius_Result is
     (Res_Ok, Res_Err, Res_Invalid_Param, Res_Pool_Exhausted, Res_Bad_Secret);
   for Radius_Result use
     (Res_Ok => 0, Res_Err => 1, Res_Invalid_Param => 2,
      Res_Pool_Exhausted => 3, Res_Bad_Secret => 4);
   pragma Convention (C, Radius_Result);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "radius_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "radius_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "radius_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "radius_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "radius_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Radius;
