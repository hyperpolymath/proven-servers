// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// C# P/Invoke bindings for the proven-firewall protocol.
// Wraps the C-ABI functions from protocols/proven-firewall/ffi/zig/src/firewall.zig.

using System;
using System.Runtime.InteropServices;

namespace ProvenServers
{
    /// <summary>Firewall rule actions (tags 0-7).</summary>
    public enum FirewallAction : byte
    {
        Accept = 0, Drop = 1, Reject = 2, Log = 3,
        Redirect = 4, Dnat = 5, Snat = 6, Masquerade = 7
    }

    /// <summary>Packet lifecycle states (tags 0-4).</summary>
    public enum PacketState : byte
    {
        Idle = 0, Classified = 1, Evaluating = 2, Decided = 3, Committed = 4
    }

    /// <summary>Connection tracking states (tags 0-4).</summary>
    public enum ConntrackState : byte
    {
        None = 0, Tracking = 1, Established = 2, Related = 3, Expired = 4
    }

    /// <summary>
    /// C# bindings for the proven firewall protocol.
    /// Packet lifecycle: Idle -> Classified -> Evaluating -> Decided -> Committed.
    /// </summary>
    public static class ProvenFirewall
    {
        private const string Lib = "proven_firewall";

        [DllImport(Lib)] private static extern uint fw_abi_version();
        [DllImport(Lib)] private static extern int fw_create_context();
        [DllImport(Lib)] private static extern void fw_destroy_context(int slot);
        [DllImport(Lib)] private static extern byte fw_packet_state(int slot);
        [DllImport(Lib)] private static extern byte fw_conntrack_state(int slot);
        [DllImport(Lib)] private static extern byte fw_get_decision(int slot);
        [DllImport(Lib)] private static extern ushort fw_rule_count(int slot);
        [DllImport(Lib)] private static extern byte fw_packet_proto(int slot);
        [DllImport(Lib)] private static extern byte fw_packet_chain(int slot);
        [DllImport(Lib)] private static extern uint fw_packet_src_ip(int slot);
        [DllImport(Lib)] private static extern uint fw_packet_dst_ip(int slot);
        [DllImport(Lib)] private static extern ushort fw_packet_src_port(int slot);
        [DllImport(Lib)] private static extern ushort fw_packet_dst_port(int slot);
        [DllImport(Lib)] private static extern byte fw_classify_packet(int slot, byte proto, byte chain, uint srcIp, uint dstIp, ushort srcPort, ushort dstPort);
        [DllImport(Lib)] private static extern byte fw_begin_chain(int slot);
        [DllImport(Lib)] private static extern byte fw_add_rule(int slot, byte matchType, uint matchValue, byte action, ushort priority);
        [DllImport(Lib)] private static extern byte fw_set_default_action(int slot, byte action);
        [DllImport(Lib)] private static extern byte fw_evaluate_rules(int slot);
        [DllImport(Lib)] private static extern byte fw_commit(int slot);
        [DllImport(Lib)] private static extern byte fw_begin_tracking(int slot);
        [DllImport(Lib)] private static extern byte fw_complete_tracking(int slot, byte connStateTag);
        [DllImport(Lib)] private static extern byte fw_expire_conn(int slot);
        [DllImport(Lib)] private static extern byte fw_can_transition(byte from, byte to);
        [DllImport(Lib)] private static extern byte fw_can_conntrack_transition(byte from, byte to);

        public static uint AbiVersion() => fw_abi_version();

        /// <exception cref="ProvenError">If the pool is exhausted.</exception>
        public static int CreateContext() => ProvenError.CheckSlot(fw_create_context());

        public static void DestroyContext(int slot) => fw_destroy_context(slot);

        public static PacketState? GetPacketState(int slot)
        {
            byte tag = fw_packet_state(slot);
            return tag <= 4 ? (PacketState)tag : null;
        }

        public static ConntrackState? GetConntrackState(int slot)
        {
            byte tag = fw_conntrack_state(slot);
            return tag <= 4 ? (ConntrackState)tag : null;
        }

        public static FirewallAction? GetDecision(int slot)
        {
            byte tag = fw_get_decision(slot);
            return tag <= 7 ? (FirewallAction)tag : null;
        }

        public static ushort RuleCount(int slot) => fw_rule_count(slot);
        public static byte PacketProto(int slot) => fw_packet_proto(slot);
        public static byte PacketChain(int slot) => fw_packet_chain(slot);
        public static uint PacketSrcIp(int slot) => fw_packet_src_ip(slot);
        public static uint PacketDstIp(int slot) => fw_packet_dst_ip(slot);
        public static ushort PacketSrcPort(int slot) => fw_packet_src_port(slot);
        public static ushort PacketDstPort(int slot) => fw_packet_dst_port(slot);

        /// <summary>Classify a packet. Transitions Idle -> Classified.</summary>
        public static void ClassifyPacket(int slot, byte proto, byte chain,
                                           uint srcIp, uint dstIp, ushort srcPort, ushort dstPort) =>
            ProvenError.CheckStatus(fw_classify_packet(slot, proto, chain, srcIp, dstIp, srcPort, dstPort));

        /// <summary>Begin chain evaluation. Transitions Classified -> Evaluating.</summary>
        public static void BeginChain(int slot) => ProvenError.CheckStatus(fw_begin_chain(slot));

        /// <summary>Add a rule to the evaluation chain.</summary>
        public static void AddRule(int slot, byte matchType, uint matchValue, FirewallAction action, ushort priority) =>
            ProvenError.CheckStatus(fw_add_rule(slot, matchType, matchValue, (byte)action, priority));

        /// <summary>Set the default action (when no rules match).</summary>
        public static void SetDefaultAction(int slot, FirewallAction action) =>
            ProvenError.CheckStatus(fw_set_default_action(slot, (byte)action));

        /// <summary>Evaluate rules. Transitions Evaluating -> Decided.</summary>
        public static void EvaluateRules(int slot) => ProvenError.CheckStatus(fw_evaluate_rules(slot));

        /// <summary>Commit decision. Transitions Decided -> Committed.</summary>
        public static void Commit(int slot) => ProvenError.CheckStatus(fw_commit(slot));

        /// <summary>Begin connection tracking. Transitions None -> Tracking.</summary>
        public static void BeginTracking(int slot) => ProvenError.CheckStatus(fw_begin_tracking(slot));

        /// <summary>Complete tracking with a target state.</summary>
        public static void CompleteTracking(int slot, ConntrackState connState) =>
            ProvenError.CheckStatus(fw_complete_tracking(slot, (byte)connState));

        /// <summary>Expire a connection.</summary>
        public static void ExpireConn(int slot) => ProvenError.CheckStatus(fw_expire_conn(slot));

        public static bool CanTransition(PacketState from, PacketState to) =>
            fw_can_transition((byte)from, (byte)to) == 1;

        public static bool CanConntrackTransition(ConntrackState from, ConntrackState to) =>
            fw_can_conntrack_transition((byte)from, (byte)to) == 1;
    }
}
