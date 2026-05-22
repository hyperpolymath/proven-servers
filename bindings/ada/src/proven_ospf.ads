-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-ospf protocol (OSPF routing).
--
-- Wraps the C-ABI functions from protocols/proven-ospf/ffi/zig/src/ospf.zig.
-- Enumerations match the Idris2 ABI tag definitions from OSPFABI.Types.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ospf is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- OSPF packet types (RFC 2328 Section A.3, tags 0-4).
   type Packet_Type is
     (Pkt_Hello,
      Pkt_Database_Description,
      Pkt_Link_State_Request,
      Pkt_Link_State_Update,
      Pkt_Link_State_Ack);
   for Packet_Type use
     (Pkt_Hello                => 0,
      Pkt_Database_Description => 1,
      Pkt_Link_State_Request   => 2,
      Pkt_Link_State_Update    => 3,
      Pkt_Link_State_Ack       => 4);
   pragma Convention (C, Packet_Type);

   -- OSPF neighbor state machine (RFC 2328 Section 10.1, tags 0-7).
   type Neighbor_State is
     (Nbr_Down,
      Nbr_Attempt,
      Nbr_Init,
      Nbr_Two_Way,
      Nbr_Ex_Start,
      Nbr_Exchange,
      Nbr_Loading,
      Nbr_Full);
   for Neighbor_State use
     (Nbr_Down     => 0,
      Nbr_Attempt  => 1,
      Nbr_Init     => 2,
      Nbr_Two_Way  => 3,
      Nbr_Ex_Start => 4,
      Nbr_Exchange => 5,
      Nbr_Loading  => 6,
      Nbr_Full     => 7);
   pragma Convention (C, Neighbor_State);

   -- OSPF LSA types (RFC 2328 Section A.4, tags 0-4).
   type Lsa_Type is
     (Lsa_Router,
      Lsa_Network,
      Lsa_Summary,
      Lsa_Asbr_Summary,
      Lsa_As_External);
   for Lsa_Type use
     (Lsa_Router       => 0,
      Lsa_Network      => 1,
      Lsa_Summary      => 2,
      Lsa_Asbr_Summary => 3,
      Lsa_As_External  => 4);
   pragma Convention (C, Lsa_Type);

   -- OSPF area types (tags 0-3).
   type Area_Type is (Area_Normal, Area_Stub, Area_Totally_Stub, Area_Nssa);
   for Area_Type use
     (Area_Normal      => 0,
      Area_Stub        => 1,
      Area_Totally_Stub => 2,
      Area_Nssa        => 3);
   pragma Convention (C, Area_Type);

   -- OSPF FFI error codes (tags 0-6).
   type Ospf_Error is
     (Err_Ok,
      Err_Invalid_Slot,
      Err_Not_Active,
      Err_Invalid_Transition,
      Err_Invalid_Packet,
      Err_Area_Error,
      Err_Flood_Limit);
   for Ospf_Error use
     (Err_Ok                 => 0,
      Err_Invalid_Slot       => 1,
      Err_Not_Active         => 2,
      Err_Invalid_Transition => 3,
      Err_Invalid_Packet     => 4,
      Err_Area_Error         => 5,
      Err_Flood_Limit        => 6);
   pragma Convention (C, Ospf_Error);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ospf_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "ospf_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "ospf_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ospf_neighbor_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ospf_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Ospf;
