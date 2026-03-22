-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-bgp protocol (Border Gateway Protocol (RFC 4271)).
--
-- Wraps the C-ABI functions from protocols/proven-bgp/ffi/zig/src/bgp.zig:
--   bgp_abi_version, bgp_create_context, bgp_destroy_context,
--   bgp_state, bgp_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Bgp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `BGPState` in `BgpABI.Types`.
   type Bgp_State is
     (Idle,
      Connect,
      Active,
      Open_Sent,
      Open_Confirm,
      Established);
   pragma Convention (C, Bgp_State);

   -- Matches `BGPEvent` in `BgpABI.Types`.
   type Bgp_Event is
     (Manual_Start,
      Manual_Stop,
      Automatic_Start,
      Connect_Retry_Timer_Expires,
      Hold_Timer_Expires,
      Keepalive_Timer_Expires,
      Delay_Open_Timer_Expires,
      Tcp_Connection_Valid,
      Tcp_Cr_Acked,
      Tcp_Connection_Confirmed,
      Tcp_Connection_Fails,
      Bgp_Open_Received,
      Bgp_Header_Err,
      Bgp_Open_Msg_Err,
      Notif_Msg_Ver_Err,
      Notif_Msg,
      Keepalive_Msg,
      Update_Msg,
      Update_Msg_Err);
   pragma Convention (C, Bgp_Event);

   -- Matches `MessageType` in `BgpABI.Types`.
   type Message_Type is
     (Open,
      Update,
      Notification,
      Keepalive);
   pragma Convention (C, Message_Type);

   -- Matches `ErrorCode` in `BgpABI.Types`.
   type Error_Code is
     (Message_Header_Error,
      Open_Message_Error,
      Update_Message_Error,
      Hold_Timer_Expired,
      Fsm_Error,
      Cease);
   pragma Convention (C, Error_Code);

   -- Matches `Origin` in `BgpABI.Types`.
   type Origin is
     (Igp,
      Egp,
      Incomplete);
   pragma Convention (C, Origin);

   -- Matches `ASPathSegmentType` in `BgpABI.Types`.
   type As_Path_Segment_Type is
     (As_Set,
      As_Sequence);
   pragma Convention (C, As_Path_Segment_Type);

   -- Matches `PathAttrType` in `BgpABI.Types`.
   type Path_Attr_Type is
     (PAT_Origin,
      As_Path,
      Next_Hop,
      Med,
      Local_Pref,
      Atomic_Aggr,
      Aggregator,
      Unknown);
   pragma Convention (C, Path_Attr_Type);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "bgp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "bgp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "bgp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "bgp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "bgp_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Bgp;
