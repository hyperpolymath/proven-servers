// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Java JNI bindings for the proven-dns protocol.
// Wraps the C-ABI functions from protocols/proven-dns/ffi/zig/src/dns.zig.
// Enums match Idris2 ABI tags exactly.

package com.hyperpolymath.proven;

/**
 * Java bindings for the proven DNS server protocol.
 *
 * <p>Lifecycle: Idle -&gt; QueryReceived -&gt; Lookup -&gt; ResponseBuilding -&gt; Sent.
 * Supports DNSSEC signing and validation via a parallel state machine.</p>
 *
 * @author Jonathan D.A. Jewell
 */
public final class ProvenDns {

    private ProvenDns() {}

    // -----------------------------------------------------------------------
    // Enums
    // -----------------------------------------------------------------------

    /** DNS query lifecycle states (tags 0-4). */
    public enum DnsState {
        IDLE(0), QUERY_RECEIVED(1), LOOKUP(2), RESPONSE_BUILDING(3), SENT(4);

        private final int tag;
        DnsState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DnsState fromTag(int tag) {
            for (DnsState s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    /** DNSSEC states (tags 0-3). */
    public enum DnssecState {
        DISABLED(0), ENABLED(1), KEY_LOADED(2), VALIDATED(3);

        private final int tag;
        DnssecState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DnssecState fromTag(int tag) {
            for (DnssecState s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    /** DNSSEC signing algorithms (tags 0-4). */
    public enum DnssecAlgorithm {
        RSA_SHA256(0), RSA_SHA512(1), ECDSA_P256_SHA256(2),
        ECDSA_P384_SHA384(3), ED25519(4);

        private final int tag;
        DnssecAlgorithm(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DnssecAlgorithm fromTag(int tag) {
            for (DnssecAlgorithm a : values()) {
                if (a.tag == tag) return a;
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
    private static native int nativeState(int slot);
    private static native int nativeDnssecState(int slot);
    private static native int nativeRcode(int slot);
    private static native int nativeAnswerCount(int slot);
    private static native int nativeAuthorityCount(int slot);
    private static native int nativeAdditionalCount(int slot);
    private static native int nativeQueryRtype(int slot);
    private static native int nativeQueryClass(int slot);
    private static native int nativeParseQuery(int slot, byte[] buf, int len);
    private static native int nativeBeginLookup(int slot);
    private static native int nativeBeginResponse(int slot);
    private static native int nativeAddAnswer(int slot, int rtype, int rclass, int ttl, byte[] rdata, int rdlen);
    private static native int nativeAddAuthority(int slot, int rtype, int rclass, int ttl, byte[] rdata, int rdlen);
    private static native int nativeAddAdditional(int slot, int rtype, int rclass, int ttl, byte[] rdata, int rdlen);
    private static native int nativeSetRcode(int slot, int rcodeTag);
    private static native int nativeBuildResponse(int slot, byte[] out, int[] outLen);
    private static native int nativeEnableDnssec(int slot);
    private static native int nativeLoadDnssecKey(int slot, int algo);
    private static native int nativeSignResponse(int slot);
    private static native int nativeValidateDnssec(int slot);
    private static native int nativeCanTransition(int from, int to);
    private static native int nativeCanDnssecTransition(int from, int to);

    // -----------------------------------------------------------------------
    // Safe wrappers
    // -----------------------------------------------------------------------

    public static int abiVersion() { return nativeAbiVersion(); }

    /**
     * Create a new DNS context in the Idle state.
     *
     * @return context slot index
     * @throws ProvenError if the pool is exhausted
     */
    public static int createContext() throws ProvenError {
        return ProvenError.checkSlot(nativeCreateContext());
    }

    public static void destroyContext(int slot) { nativeDestroyContext(slot); }

    public static DnsState state(int slot) { return DnsState.fromTag(nativeState(slot)); }

    public static DnssecState dnssecState(int slot) { return DnssecState.fromTag(nativeDnssecState(slot)); }

    public static int rcode(int slot) { return nativeRcode(slot); }

    public static int answerCount(int slot) { return nativeAnswerCount(slot); }

    public static int authorityCount(int slot) { return nativeAuthorityCount(slot); }

    public static int additionalCount(int slot) { return nativeAdditionalCount(slot); }

    public static int queryRtype(int slot) { return nativeQueryRtype(slot); }

    public static int queryClass(int slot) { return nativeQueryClass(slot); }

    /**
     * Parse a DNS query. Transitions Idle -&gt; QueryReceived.
     *
     * @throws ProvenError on parse failure or invalid state
     */
    public static void parseQuery(int slot, byte[] data) throws ProvenError {
        ProvenError.checkStatus(nativeParseQuery(slot, data, data.length));
    }

    /** Begin lookup. Transitions QueryReceived -&gt; Lookup. */
    public static void beginLookup(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeBeginLookup(slot));
    }

    /** Begin response building. Transitions Lookup -&gt; ResponseBuilding. */
    public static void beginResponse(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeBeginResponse(slot));
    }

    /** Add a resource record to the answer section. */
    public static void addAnswer(int slot, int rtype, int rclass, int ttl, byte[] rdata) throws ProvenError {
        ProvenError.checkStatus(nativeAddAnswer(slot, rtype, rclass, ttl, rdata, rdata.length));
    }

    /** Add a resource record to the authority section. */
    public static void addAuthority(int slot, int rtype, int rclass, int ttl, byte[] rdata) throws ProvenError {
        ProvenError.checkStatus(nativeAddAuthority(slot, rtype, rclass, ttl, rdata, rdata.length));
    }

    /** Add a resource record to the additional section. */
    public static void addAdditional(int slot, int rtype, int rclass, int ttl, byte[] rdata) throws ProvenError {
        ProvenError.checkStatus(nativeAddAdditional(slot, rtype, rclass, ttl, rdata, rdata.length));
    }

    /** Set the response code. */
    public static void setRcode(int slot, int rcodeTag) throws ProvenError {
        ProvenError.checkStatus(nativeSetRcode(slot, rcodeTag));
    }

    /**
     * Build the DNS response. Transitions ResponseBuilding -&gt; Sent.
     *
     * @param slot   context slot
     * @param outBuf output buffer (at least 512 bytes)
     * @return number of bytes written
     * @throws ProvenError on failure
     */
    public static int buildResponse(int slot, byte[] outBuf) throws ProvenError {
        int[] outLen = new int[1];
        ProvenError.checkStatus(nativeBuildResponse(slot, outBuf, outLen));
        return outLen[0];
    }

    /** Enable DNSSEC. Transitions Disabled -&gt; Enabled. */
    public static void enableDnssec(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeEnableDnssec(slot));
    }

    /** Load a DNSSEC signing key. Transitions Enabled -&gt; KeyLoaded. */
    public static void loadDnssecKey(int slot, DnssecAlgorithm algo) throws ProvenError {
        ProvenError.checkStatus(nativeLoadDnssecKey(slot, algo.tag()));
    }

    /** Sign the response. Transitions KeyLoaded -&gt; Validated. */
    public static void signResponse(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeSignResponse(slot));
    }

    /** Check DNSSEC validation result. */
    public static boolean validateDnssec(int slot) {
        return nativeValidateDnssec(slot) == 0;
    }

    /** Stateless: check whether a DNS lifecycle transition is valid. */
    public static boolean canTransition(DnsState from, DnsState to) {
        return nativeCanTransition(from.tag(), to.tag()) == 1;
    }

    /** Stateless: check whether a DNSSEC state transition is valid. */
    public static boolean canDnssecTransition(DnssecState from, DnssecState to) {
        return nativeCanDnssecTransition(from.tag(), to.tag()) == 1;
    }
}
