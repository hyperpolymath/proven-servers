-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-dhcp protocol (DHCP server (RFC 2131)).
--
-- Wraps the C-ABI functions from protocols/proven-dhcp/ffi/zig/src/dhcp.zig:
--   dhcp_abi_version, dhcp_create_context, dhcp_destroy_context,
--   dhcp_state, dhcp_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Dhcp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `MessageType` in `DhcpABI.Types`.
   type Message_Type is
     (Discover,
      Offer,
      Request,
      Ack,
      Nak,
      Release,
      Inform,
      Decline);
   pragma Convention (C, Message_Type);

   -- Matches `OptionCode` in `DhcpABI.Types`.
   type Option_Code is
     (Subnet_Mask,
      Router,
      Dns,
      Domain_Name,
      Lease_Time,
      Server_Id,
      Requested_Ip,
      Msg_Type);
   pragma Convention (C, Option_Code);

   -- Matches `HardwareType` in `DhcpABI.Types`.
   type Hardware_Type is
     (Ethernet,
      Ieee802,
      Arcnet,
      Frame_Relay);
   pragma Convention (C, Hardware_Type);

   -- Matches `DhcpState` in `DhcpABI.Types`.
   type Dhcp_State is
     (Idle,
      Discover_Received,
      Offer_Sent,
      Request_Received,
      Ack_Sent,
      Nak_Sent);
   pragma Convention (C, Dhcp_State);

   -- Matches `LeaseState` in `DhcpABI.Types`.
   type Lease_State is
     (Available,
      Offered,
      Bound,
      Renewing,
      Rebinding,
      Expired);
   pragma Convention (C, Lease_State);

   -- Matches `RelaySubOption` in `DhcpABI.Types`.
   type Relay_Sub_Option is
     (Circuit_Id,
      Remote_Id);
   pragma Convention (C, Relay_Sub_Option);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "dhcp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "dhcp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "dhcp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "dhcp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "dhcp_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Dhcp;
