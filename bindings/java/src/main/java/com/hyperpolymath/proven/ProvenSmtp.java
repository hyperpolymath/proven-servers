// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Java JNI bindings for the proven-smtp protocol.
// Wraps the C-ABI functions from protocols/proven-smtp/ffi/zig/src/smtp.zig.

package com.hyperpolymath.proven;

/**
 * Java bindings for the proven SMTP server protocol.
 *
 * <p>Session lifecycle (RFC 5321):
 * Connected -&gt; Greeted -&gt; [AuthStarted -&gt; Authenticated] -&gt;
 * MailFrom -&gt; RcptTo -&gt; Data -&gt; MessageReceived -&gt; Quit.</p>
 *
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSmtp {

    private ProvenSmtp() {}

    // -----------------------------------------------------------------------
    // Enums
    // -----------------------------------------------------------------------

    /** SMTP session states (tags 0-8). */
    public enum SessionState {
        CONNECTED(0), GREETED(1), AUTH_STARTED(2), AUTHENTICATED(3),
        MAIL_FROM(4), RCPT_TO(5), DATA(6), MESSAGE_RECEIVED(7), QUIT(8);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    /** SASL authentication mechanisms (tags 0-3). */
    public enum AuthMechanism {
        PLAIN(0), LOGIN(1), CRAM_MD5(2), XOAUTH2(3);

        private final int tag;
        AuthMechanism(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthMechanism fromTag(int tag) {
            for (AuthMechanism m : values()) {
                if (m.tag == tag) return m;
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
    private static native int nativeGetState(int slot);
    private static native int nativeGetReplyCode(int slot);
    private static native int nativeGetRecipientCount(int slot);
    private static native int nativeGetDataSize(int slot);
    private static native int nativeGetAuthMechanism(int slot);
    private static native int nativeIsAuthenticated(int slot);
    private static native int nativeIsTlsActive(int slot);
    private static native int nativeGreet(int slot, int isEhlo);
    private static native int nativeAuthenticate(int slot, int mech);
    private static native int nativeAuthComplete(int slot, int success);
    private static native int nativeSetSender(int slot);
    private static native int nativeAddRecipient(int slot);
    private static native int nativeStartData(int slot);
    private static native int nativeAppendData(int slot, int len);
    private static native int nativeFinishData(int slot);
    private static native int nativeReset(int slot);
    private static native int nativeQuit(int slot);
    private static native int nativeEnableTls(int slot);
    private static native int nativeCanTransition(int from, int to);

    // -----------------------------------------------------------------------
    // Safe wrappers
    // -----------------------------------------------------------------------

    public static int abiVersion() { return nativeAbiVersion(); }

    public static int createContext() throws ProvenError {
        return ProvenError.checkSlot(nativeCreateContext());
    }

    public static void destroyContext(int slot) { nativeDestroyContext(slot); }

    public static SessionState getState(int slot) { return SessionState.fromTag(nativeGetState(slot)); }

    public static int getReplyCode(int slot) { return nativeGetReplyCode(slot); }

    public static int getRecipientCount(int slot) { return nativeGetRecipientCount(slot); }

    public static int getDataSize(int slot) { return nativeGetDataSize(slot); }

    public static AuthMechanism getAuthMechanism(int slot) { return AuthMechanism.fromTag(nativeGetAuthMechanism(slot)); }

    public static boolean isAuthenticated(int slot) { return nativeIsAuthenticated(slot) == 1; }

    public static boolean isTlsActive(int slot) { return nativeIsTlsActive(slot) == 1; }

    /**
     * HELO/EHLO: greet the server. Transitions Connected -&gt; Greeted.
     *
     * @param slot context slot
     * @param ehlo true for EHLO, false for HELO
     * @throws ProvenError on invalid state
     */
    public static void greet(int slot, boolean ehlo) throws ProvenError {
        ProvenError.checkStatus(nativeGreet(slot, ehlo ? 1 : 0));
    }

    /** Begin AUTH exchange. Transitions Greeted -&gt; AuthStarted. */
    public static void authenticate(int slot, AuthMechanism mechanism) throws ProvenError {
        ProvenError.checkStatus(nativeAuthenticate(slot, mechanism.tag()));
    }

    /**
     * Complete AUTH exchange.
     *
     * @param success true transitions AuthStarted -&gt; Authenticated;
     *                false transitions AuthStarted -&gt; Greeted
     */
    public static void authComplete(int slot, boolean success) throws ProvenError {
        ProvenError.checkStatus(nativeAuthComplete(slot, success ? 1 : 0));
    }

    /** MAIL FROM. Transitions Greeted/Authenticated -&gt; MailFrom. */
    public static void setSender(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeSetSender(slot));
    }

    /** RCPT TO. Transitions MailFrom/RcptTo -&gt; RcptTo. */
    public static void addRecipient(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeAddRecipient(slot));
    }

    /** DATA. Transitions RcptTo -&gt; Data. */
    public static void startData(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeStartData(slot));
    }

    /** Append data bytes. */
    public static void appendData(int slot, int len) throws ProvenError {
        ProvenError.checkStatus(nativeAppendData(slot, len));
    }

    /** Finish data (end-of-data marker). Transitions Data -&gt; MessageReceived. */
    public static void finishData(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeFinishData(slot));
    }

    /** RSET. Returns to Greeted or Authenticated. */
    public static void reset(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeReset(slot));
    }

    /** QUIT. Transitions to Quit. */
    public static void quit(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeQuit(slot));
    }

    /** STARTTLS. Enable TLS on the connection. */
    public static void enableTls(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeEnableTls(slot));
    }

    public static boolean canTransition(SessionState from, SessionState to) {
        return nativeCanTransition(from.tag(), to.tag()) == 1;
    }
}
