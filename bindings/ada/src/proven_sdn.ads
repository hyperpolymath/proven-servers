-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-sdn protocol (Software-Defined Networking).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Sdn is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- SDN/OpenFlow message types (tags 0-11).
   type Sdn_Message_Type is
     (Msg_Hello, Msg_Error, Msg_Echo_Request, Msg_Echo_Reply,
      Msg_Features_Request, Msg_Features_Reply, Msg_Flow_Mod,
      Msg_Packet_In, Msg_Packet_Out, Msg_Port_Status,
      Msg_Barrier_Request, Msg_Barrier_Reply);
   for Sdn_Message_Type use
     (Msg_Hello            => 0,  Msg_Error            => 1,
      Msg_Echo_Request     => 2,  Msg_Echo_Reply       => 3,
      Msg_Features_Request => 4,  Msg_Features_Reply   => 5,
      Msg_Flow_Mod         => 6,  Msg_Packet_In        => 7,
      Msg_Packet_Out       => 8,  Msg_Port_Status      => 9,
      Msg_Barrier_Request  => 10, Msg_Barrier_Reply    => 11);
   pragma Convention (C, Sdn_Message_Type);

   -- Flow actions (tags 0-6).
   type Flow_Action is
     (Act_Output, Act_Set_Field, Act_Drop, Act_Push_Vlan,
      Act_Pop_Vlan, Act_Set_Queue, Act_Group);
   for Flow_Action use
     (Act_Output    => 0, Act_Set_Field => 1, Act_Drop      => 2,
      Act_Push_Vlan => 3, Act_Pop_Vlan  => 4, Act_Set_Queue => 5,
      Act_Group     => 6);
   pragma Convention (C, Flow_Action);

   -- Match fields (tags 0-10).
   type Match_Field is
     (Fld_In_Port, Fld_Eth_Dst, Fld_Eth_Src, Fld_Eth_Type,
      Fld_Vlan_Id, Fld_Ip_Src, Fld_Ip_Dst, Fld_Tcp_Src,
      Fld_Tcp_Dst, Fld_Udp_Src, Fld_Udp_Dst);
   for Match_Field use
     (Fld_In_Port  => 0,  Fld_Eth_Dst  => 1,  Fld_Eth_Src  => 2,
      Fld_Eth_Type => 3,  Fld_Vlan_Id  => 4,  Fld_Ip_Src   => 5,
      Fld_Ip_Dst   => 6,  Fld_Tcp_Src  => 7,  Fld_Tcp_Dst  => 8,
      Fld_Udp_Src  => 9,  Fld_Udp_Dst  => 10);
   pragma Convention (C, Match_Field);

   -- Port states (tags 0-2).
   type Port_State is (Port_Up, Port_Down, Port_Blocked);
   for Port_State use (Port_Up => 0, Port_Down => 1, Port_Blocked => 2);
   pragma Convention (C, Port_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "sdn_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "sdn_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "sdn_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "sdn_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "sdn_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Sdn;
