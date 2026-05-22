-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-firewall protocol (stateful packet filter).
--
-- Wraps the C-ABI functions from protocols/proven-firewall/ffi/zig/src/firewall.zig.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Firewall is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Firewall rule actions.
   type Firewall_Action is
     (Action_Accept,
      Action_Drop,
      Action_Reject,
      Action_Log,
      Action_Redirect,
      Action_Dnat,
      Action_Snat,
      Action_Masquerade);
   for Firewall_Action use
     (Action_Accept    => 0,
      Action_Drop      => 1,
      Action_Reject    => 2,
      Action_Log       => 3,
      Action_Redirect  => 4,
      Action_Dnat      => 5,
      Action_Snat      => 6,
      Action_Masquerade => 7);
   pragma Convention (C, Firewall_Action);

   -- Packet processing states.
   type Packet_State is
     (Packet_New,
      Packet_Classified,
      Packet_Chain_Processing,
      Packet_Rule_Evaluating,
      Packet_Decision_Made,
      Packet_Committed);
   for Packet_State use
     (Packet_New              => 0,
      Packet_Classified       => 1,
      Packet_Chain_Processing => 2,
      Packet_Rule_Evaluating  => 3,
      Packet_Decision_Made    => 4,
      Packet_Committed        => 5);
   pragma Convention (C, Packet_State);

   -- Connection tracking states.
   type Conntrack_State is
     (Conn_None,
      Conn_New,
      Conn_Established,
      Conn_Related,
      Conn_Invalid,
      Conn_Expired);
   for Conntrack_State use
     (Conn_None        => 0,
      Conn_New         => 1,
      Conn_Established => 2,
      Conn_Related     => 3,
      Conn_Invalid     => 4,
      Conn_Expired     => 5);
   pragma Convention (C, Conntrack_State);

   -- Network protocol types.
   type Protocol is (Proto_TCP, Proto_UDP, Proto_ICMP, Proto_ICMPv6);
   for Protocol use
     (Proto_TCP    => 0,
      Proto_UDP    => 1,
      Proto_ICMP   => 2,
      Proto_ICMPv6 => 3);
   pragma Convention (C, Protocol);

   -- Firewall chains.
   type Chain is (Chain_Input, Chain_Output, Chain_Forward);
   for Chain use
     (Chain_Input   => 0,
      Chain_Output  => 1,
      Chain_Forward => 2);
   pragma Convention (C, Chain);

   ---------------------------------------------------------------------------
   -- Raw FFI imports
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "fw_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "fw_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "fw_destroy_context");

   function Get_Packet_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_Packet_State, "fw_packet_state");

   function Get_Conntrack_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_Conntrack_State, "fw_conntrack_state");

   function Get_Decision (Slot : int) return unsigned_char;
   pragma Import (C, Get_Decision, "fw_get_decision");

   function Rule_Count (Slot : int) return unsigned_short;
   pragma Import (C, Rule_Count, "fw_rule_count");

   function Get_Packet_Proto (Slot : int) return unsigned_char;
   pragma Import (C, Get_Packet_Proto, "fw_packet_proto");

   function Get_Packet_Chain (Slot : int) return unsigned_char;
   pragma Import (C, Get_Packet_Chain, "fw_packet_chain");

   function Packet_Src_Ip (Slot : int) return unsigned;
   pragma Import (C, Packet_Src_Ip, "fw_packet_src_ip");

   function Packet_Dst_Ip (Slot : int) return unsigned;
   pragma Import (C, Packet_Dst_Ip, "fw_packet_dst_ip");

   function Packet_Src_Port (Slot : int) return unsigned_short;
   pragma Import (C, Packet_Src_Port, "fw_packet_src_port");

   function Packet_Dst_Port (Slot : int) return unsigned_short;
   pragma Import (C, Packet_Dst_Port, "fw_packet_dst_port");

   function Conn_State (Slot : int) return unsigned_char;
   pragma Import (C, Conn_State, "fw_conn_state");

   function Classify_Packet
     (Slot     : int;
      Proto    : unsigned_char;
      Chain_Id : unsigned_char;
      Src_Ip   : unsigned;
      Dst_Ip   : unsigned;
      Src_Port : unsigned_short;
      Dst_Port : unsigned_short) return unsigned_char;
   pragma Import (C, Classify_Packet, "fw_classify_packet");

   function Begin_Chain (Slot : int) return unsigned_char;
   pragma Import (C, Begin_Chain, "fw_begin_chain");

   function Add_Rule
     (Slot        : int;
      Match_Type  : unsigned_char;
      Match_Value : unsigned;
      Action      : unsigned_char;
      Priority    : unsigned_short) return unsigned_char;
   pragma Import (C, Add_Rule, "fw_add_rule");

   function Set_Default_Action
     (Slot   : int;
      Action : unsigned_char) return unsigned_char;
   pragma Import (C, Set_Default_Action, "fw_set_default_action");

   function Evaluate_Rules (Slot : int) return unsigned_char;
   pragma Import (C, Evaluate_Rules, "fw_evaluate_rules");

   function Commit (Slot : int) return unsigned_char;
   pragma Import (C, Commit, "fw_commit");

   function Begin_Tracking (Slot : int) return unsigned_char;
   pragma Import (C, Begin_Tracking, "fw_begin_tracking");

   function Complete_Tracking
     (Slot           : int;
      Conn_State_Tag : unsigned_char) return unsigned_char;
   pragma Import (C, Complete_Tracking, "fw_complete_tracking");

   function Expire_Conn (Slot : int) return unsigned_char;
   pragma Import (C, Expire_Conn, "fw_expire_conn");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "fw_can_transition");

   function Can_Conntrack_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Conntrack_Transition, "fw_can_conntrack_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);
   procedure Safe_Commit (Slot : Proven_Error.Slot_Id);

end Proven_Firewall;
