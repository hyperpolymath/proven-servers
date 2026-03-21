// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Java JNI bindings for the proven-firewall protocol.
// Wraps the C-ABI functions from protocols/proven-firewall/ffi/zig/src/firewall.zig.

package com.hyperpolymath.proven;

/**
 * Java bindings for the proven firewall protocol.
 *
 * <p>Packet lifecycle: Idle -&gt; Classified -&gt; Evaluating -&gt; Decided -&gt; Committed.
 * Connection tracking: None -&gt; Tracking -&gt; Established/Related -&gt; Expired.</p>
 *
 * @author Jonathan D.A. Jewell
 */
public final class ProvenFirewall {

    private ProvenFirewall() {}

    // -----------------------------------------------------------------------
    // Enums
    // -----------------------------------------------------------------------

    /** Firewall rule actions (tags 0-7). */
    public enum Action {
        ACCEPT(0), DROP(1), REJECT(2), LOG(3),
        REDIRECT(4), DNAT(5), SNAT(6), MASQUERADE(7);

        private final int tag;
        Action(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Action fromTag(int tag) {
            for (Action a : values()) {
                if (a.tag == tag) return a;
            }
            return null;
        }
    }

    /** Packet lifecycle states (tags 0-4). */
    public enum PacketState {
        IDLE(0), CLASSIFIED(1), EVALUATING(2), DECIDED(3), COMMITTED(4);

        private final int tag;
        PacketState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PacketState fromTag(int tag) {
            for (PacketState s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    /** Connection tracking states (tags 0-4). */
    public enum ConntrackState {
        NONE(0), TRACKING(1), ESTABLISHED(2), RELATED(3), EXPIRED(4);

        private final int tag;
        ConntrackState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ConntrackState fromTag(int tag) {
            for (ConntrackState s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    // -----------------------------------------------------------------------
    // JNI native methods
    // -----------------------------------------------------------------------

    private static native int nativeAbiVersion();
    private static native int nativeCreateContext();
    private static native void nativeDestroyContext(int slot);
    private static native int nativePacketState(int slot);
    private static native int nativeConntrackState(int slot);
    private static native int nativeGetDecision(int slot);
    private static native int nativeRuleCount(int slot);
    private static native int nativePacketProto(int slot);
    private static native int nativePacketChain(int slot);
    private static native int nativePacketSrcIp(int slot);
    private static native int nativePacketDstIp(int slot);
    private static native int nativePacketSrcPort(int slot);
    private static native int nativePacketDstPort(int slot);
    private static native int nativeClassifyPacket(int slot, int proto, int chain,
                                                    int srcIp, int dstIp, int srcPort, int dstPort);
    private static native int nativeBeginChain(int slot);
    private static native int nativeAddRule(int slot, int matchType, int matchValue, int action, int priority);
    private static native int nativeSetDefaultAction(int slot, int action);
    private static native int nativeEvaluateRules(int slot);
    private static native int nativeCommit(int slot);
    private static native int nativeBeginTracking(int slot);
    private static native int nativeCompleteTracking(int slot, int connStateTag);
    private static native int nativeExpireConn(int slot);
    private static native int nativeCanTransition(int from, int to);
    private static native int nativeCanConntrackTransition(int from, int to);

    // -----------------------------------------------------------------------
    // Safe wrappers
    // -----------------------------------------------------------------------

    public static int abiVersion() { return nativeAbiVersion(); }

    public static int createContext() throws ProvenError {
        return ProvenError.checkSlot(nativeCreateContext());
    }

    public static void destroyContext(int slot) { nativeDestroyContext(slot); }

    public static PacketState packetState(int slot) { return PacketState.fromTag(nativePacketState(slot)); }

    public static ConntrackState conntrackState(int slot) { return ConntrackState.fromTag(nativeConntrackState(slot)); }

    public static Action getDecision(int slot) { return Action.fromTag(nativeGetDecision(slot)); }

    public static int ruleCount(int slot) { return nativeRuleCount(slot); }

    public static int packetProto(int slot) { return nativePacketProto(slot); }

    public static int packetChain(int slot) { return nativePacketChain(slot); }

    public static int packetSrcIp(int slot) { return nativePacketSrcIp(slot); }

    public static int packetDstIp(int slot) { return nativePacketDstIp(slot); }

    public static int packetSrcPort(int slot) { return nativePacketSrcPort(slot); }

    public static int packetDstPort(int slot) { return nativePacketDstPort(slot); }

    /**
     * Classify a packet. Transitions Idle -&gt; Classified.
     *
     * @param slot    context slot
     * @param proto   protocol tag
     * @param chain   chain tag
     * @param srcIp   source IP (network byte order)
     * @param dstIp   destination IP (network byte order)
     * @param srcPort source port
     * @param dstPort destination port
     * @throws ProvenError on invalid state
     */
    public static void classifyPacket(int slot, int proto, int chain,
                                       int srcIp, int dstIp, int srcPort, int dstPort) throws ProvenError {
        ProvenError.checkStatus(nativeClassifyPacket(slot, proto, chain, srcIp, dstIp, srcPort, dstPort));
    }

    /** Begin chain evaluation. Transitions Classified -&gt; Evaluating. */
    public static void beginChain(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeBeginChain(slot));
    }

    /** Add a rule to the evaluation chain. */
    public static void addRule(int slot, int matchType, int matchValue, Action action, int priority) throws ProvenError {
        ProvenError.checkStatus(nativeAddRule(slot, matchType, matchValue, action.tag(), priority));
    }

    /** Set the default action (when no rules match). */
    public static void setDefaultAction(int slot, Action action) throws ProvenError {
        ProvenError.checkStatus(nativeSetDefaultAction(slot, action.tag()));
    }

    /** Evaluate rules. Transitions Evaluating -&gt; Decided. */
    public static void evaluateRules(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeEvaluateRules(slot));
    }

    /** Commit decision. Transitions Decided -&gt; Committed. */
    public static void commit(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeCommit(slot));
    }

    /** Begin connection tracking. Transitions None -&gt; Tracking. */
    public static void beginTracking(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeBeginTracking(slot));
    }

    /** Complete tracking with a target state. */
    public static void completeTracking(int slot, ConntrackState connState) throws ProvenError {
        ProvenError.checkStatus(nativeCompleteTracking(slot, connState.tag()));
    }

    /** Expire a connection. Transitions Established/Related -&gt; Expired. */
    public static void expireConn(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeExpireConn(slot));
    }

    public static boolean canTransition(PacketState from, PacketState to) {
        return nativeCanTransition(from.tag(), to.tag()) == 1;
    }

    public static boolean canConntrackTransition(ConntrackState from, ConntrackState to) {
        return nativeCanConntrackTransition(from.tag(), to.tag()) == 1;
    }
}
