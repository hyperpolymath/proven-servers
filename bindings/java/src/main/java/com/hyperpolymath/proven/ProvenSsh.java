// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Java JNI bindings for the proven-ssh-bastion protocol.
// Wraps the C-ABI functions from protocols/proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig.

package com.hyperpolymath.proven;

/**
 * Java bindings for the proven SSH Bastion protocol.
 *
 * <p>Bastion lifecycle: Connected -&gt; KeyExchanged -&gt; Authenticated -&gt;
 * ChannelOpen -&gt; Active -&gt; Closed. Supports up to 10 channels per session,
 * audit logging, and session recording.</p>
 *
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSsh {

    private ProvenSsh() {}

    // -----------------------------------------------------------------------
    // Enums
    // -----------------------------------------------------------------------

    /** SSH bastion connection states (tags 0-5). */
    public enum BastionState {
        CONNECTED(0), KEY_EXCHANGED(1), AUTHENTICATED(2),
        CHANNEL_OPEN(3), ACTIVE(4), CLOSED(5);

        private final int tag;
        BastionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static BastionState fromTag(int tag) {
            for (BastionState s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    /** SSH authentication methods (tags 0-3). */
    public enum AuthMethod {
        PUBLICKEY(0), PASSWORD(1), KEYBOARD_INTERACTIVE(2), NONE(3);

        private final int tag;
        AuthMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthMethod fromTag(int tag) {
            for (AuthMethod m : values()) {
                if (m.tag == tag) return m;
            }
            return null;
        }
    }

    /** SSH key exchange methods (tags 0-5). */
    public enum KexMethod {
        DIFFIE_HELLMAN_GROUP14_SHA256(0), CURVE25519_SHA256(1),
        DIFFIE_HELLMAN_GROUP16_SHA512(2), DIFFIE_HELLMAN_GROUP18_SHA512(3),
        ECDH_SHA2_NISTP256(4), ECDH_SHA2_NISTP384(5);

        private final int tag;
        KexMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static KexMethod fromTag(int tag) {
            for (KexMethod m : values()) {
                if (m.tag == tag) return m;
            }
            return null;
        }
    }

    /** SSH channel types (tags 0-3). */
    public enum ChannelType {
        SESSION(0), DIRECT_TCPIP(1), FORWARDED_TCPIP(2), X11(3);

        private final int tag;
        ChannelType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ChannelType fromTag(int tag) {
            for (ChannelType t : values()) {
                if (t.tag == tag) return t;
            }
            return null;
        }
    }

    /** SSH channel states (tags 0-3). */
    public enum ChannelState {
        OPENING(0), OPEN(1), CLOSING(2), CLOSED(3);

        private final int tag;
        ChannelState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ChannelState fromTag(int tag) {
            for (ChannelState s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    /** SSH disconnect reason codes (tags 0-11). */
    public enum DisconnectReason {
        HOST_NOT_ALLOWED(0), PROTOCOL_ERROR(1), KEY_EXCHANGE_FAILED(2),
        HOST_AUTH_FAILED(3), MAC_ERROR(4), SERVICE_NOT_AVAILABLE(5),
        VERSION_NOT_SUPPORTED(6), HOST_KEY_NOT_VERIFIABLE(7),
        CONNECTION_LOST(8), BY_APPLICATION(9),
        TOO_MANY_CONNECTIONS(10), AUTH_CANCELLED(11);

        private final int tag;
        DisconnectReason(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DisconnectReason fromTag(int tag) {
            for (DisconnectReason r : values()) {
                if (r.tag == tag) return r;
            }
            return null;
        }
    }

    // -----------------------------------------------------------------------
    // JNI native methods
    // -----------------------------------------------------------------------

    private static native int nativeAbiVersion();
    private static native int nativeCreate(int kexMethod, int authMethod);
    private static native void nativeDestroy(int slot);
    private static native int nativeState(int slot);
    private static native int nativeKexMethod(int slot);
    private static native int nativeAuthMethod(int slot);
    private static native int nativeCanTransfer(int slot);
    private static native int nativeDisconnectReason(int slot);
    private static native int nativeAuthFailures(int slot);
    private static native int nativeCompleteKex(int slot);
    private static native int nativeAuthenticate(int slot, int userLen);
    private static native int nativeRecordAuthFailure(int slot);
    private static native int nativeOpenChannel(int slot, int chType);
    private static native int nativeConfirmChannel(int slot, int chId);
    private static native int nativeCloseChannel(int slot, int chId);
    private static native int nativeChannelState(int slot, int chId);
    private static native int nativeChannelType(int slot, int chId);
    private static native int nativeChannelCount(int slot);
    private static native int nativeRekey(int slot);
    private static native int nativeDisconnect(int slot, int reason);
    private static native int nativeCanTransition(int from, int to);
    private static native int nativeAuditCount(int slot);
    private static native int nativeAuditEntry(int slot, int entryIdx);
    private static native int nativeAuditEntryTo(int slot, int entryIdx);
    private static native int nativeSetRecording(int slot, int enabled);
    private static native int nativeIsRecording(int slot);

    // -----------------------------------------------------------------------
    // Safe wrappers
    // -----------------------------------------------------------------------

    public static int abiVersion() { return nativeAbiVersion(); }

    /**
     * Create a new SSH bastion session.
     *
     * @param kex  key exchange method
     * @param auth authentication method
     * @return context slot index
     * @throws ProvenError if pool exhausted
     */
    public static int create(KexMethod kex, AuthMethod auth) throws ProvenError {
        return ProvenError.checkSlot(nativeCreate(kex.tag(), auth.tag()));
    }

    public static void destroy(int slot) { nativeDestroy(slot); }

    public static BastionState state(int slot) { return BastionState.fromTag(nativeState(slot)); }

    public static KexMethod kexMethod(int slot) { return KexMethod.fromTag(nativeKexMethod(slot)); }

    public static AuthMethod authMethod(int slot) { return AuthMethod.fromTag(nativeAuthMethod(slot)); }

    public static boolean canTransferData(int slot) { return nativeCanTransfer(slot) == 1; }

    public static DisconnectReason disconnectReason(int slot) { return DisconnectReason.fromTag(nativeDisconnectReason(slot)); }

    public static int authFailures(int slot) { return nativeAuthFailures(slot); }

    /** Complete key exchange. Transitions Connected -&gt; KeyExchanged. */
    public static void completeKex(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeCompleteKex(slot));
    }

    /** Authenticate user. Transitions KeyExchanged -&gt; Authenticated. */
    public static void authenticate(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeAuthenticate(slot, 0));
    }

    /**
     * Record a failed auth attempt.
     *
     * @return true if locked out (3+ failures)
     */
    public static boolean recordAuthFailure(int slot) {
        return nativeRecordAuthFailure(slot) == 1;
    }

    /**
     * Open a channel.
     *
     * @param slot   session slot
     * @param chType channel type
     * @return channel ID (0-9)
     * @throws ProvenError if too many channels or wrong state
     */
    public static int openChannel(int slot, ChannelType chType) throws ProvenError {
        return ProvenError.checkSlot(nativeOpenChannel(slot, chType.tag()));
    }

    /** Confirm a channel (Opening -&gt; Open). */
    public static void confirmChannel(int slot, int chId) throws ProvenError {
        ProvenError.checkStatus(nativeConfirmChannel(slot, chId));
    }

    /** Close a channel. */
    public static void closeChannel(int slot, int chId) throws ProvenError {
        ProvenError.checkStatus(nativeCloseChannel(slot, chId));
    }

    public static ChannelState channelState(int slot, int chId) { return ChannelState.fromTag(nativeChannelState(slot, chId)); }

    public static ChannelType channelType(int slot, int chId) { return ChannelType.fromTag(nativeChannelType(slot, chId)); }

    public static int channelCount(int slot) { return nativeChannelCount(slot); }

    /** Re-key the session. Only valid in Active state. */
    public static void rekey(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeRekey(slot));
    }

    /** Disconnect with a reason. Transitions any non-Closed -&gt; Closed. */
    public static void disconnect(int slot, DisconnectReason reason) throws ProvenError {
        ProvenError.checkStatus(nativeDisconnect(slot, reason.tag()));
    }

    public static boolean canTransition(BastionState from, BastionState to) {
        return nativeCanTransition(from.tag(), to.tag()) == 1;
    }

    public static int auditCount(int slot) { return nativeAuditCount(slot); }

    public static BastionState auditEntryFrom(int slot, int index) { return BastionState.fromTag(nativeAuditEntry(slot, index)); }

    public static BastionState auditEntryTo(int slot, int index) { return BastionState.fromTag(nativeAuditEntryTo(slot, index)); }

    /** Enable or disable session recording. */
    public static void setRecording(int slot, boolean enabled) throws ProvenError {
        ProvenError.checkStatus(nativeSetRecording(slot, enabled ? 1 : 0));
    }

    public static boolean isRecording(int slot) { return nativeIsRecording(slot) == 1; }
}
