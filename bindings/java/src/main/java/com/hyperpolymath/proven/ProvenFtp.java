// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Java JNI bindings for the proven-ftp protocol.
// Wraps the C-ABI functions from protocols/proven-ftp/ffi/zig/src/ftp.zig.

package com.hyperpolymath.proven;

/**
 * Java bindings for the proven FTP server protocol.
 *
 * <p>Session lifecycle: Connected -&gt; UserOk -&gt; Authenticated -&gt; Quit.
 * Transfer lifecycle: Idle -&gt; InProgress -&gt; Completed/Aborted.</p>
 *
 * @author Jonathan D.A. Jewell
 */
public final class ProvenFtp {

    private ProvenFtp() {}

    // -----------------------------------------------------------------------
    // Enums
    // -----------------------------------------------------------------------

    /** FTP session states (tags 0-4). */
    public enum SessionState {
        CONNECTED(0), USER_OK(1), AUTHENTICATED(2), RENAMING(3), QUIT(4);

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

    /** FTP transfer states (tags 0-3). */
    public enum TransferState {
        IDLE(0), IN_PROGRESS(1), COMPLETED(2), ABORTED(3);

        private final int tag;
        TransferState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TransferState fromTag(int tag) {
            for (TransferState s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    // -----------------------------------------------------------------------
    // JNI native methods
    // -----------------------------------------------------------------------

    private static native int nativeAbiVersion();
    private static native int nativeCreate();
    private static native void nativeDestroy(int slot);
    private static native int nativeState(int slot);
    private static native int nativeTransferType(int slot);
    private static native int nativeDataMode(int slot);
    private static native int nativeTransferState(int slot);
    private static native long nativeBytesTransferred(int slot);
    private static native int nativeFileCount(int slot);
    private static native int nativeLastReplyCode(int slot);
    private static native int nativeCwd(int slot, byte[] buf, int bufLen);
    private static native int nativeUser(int slot, byte[] name, int len);
    private static native int nativePass(int slot, byte[] pass, int len);
    private static native int nativeQuit(int slot);
    private static native int nativeCwdCmd(int slot, byte[] path, int pathLen);
    private static native int nativeCdup(int slot);
    private static native int nativeSetType(int slot, int typeTag);
    private static native int nativeSetPassive(int slot);
    private static native int nativeSetActive(int slot, int port);
    private static native int nativeBeginTransfer(int slot);
    private static native int nativeAddBytes(int slot, long count);
    private static native int nativeCompleteTransfer(int slot);
    private static native int nativeAbortTransfer(int slot);
    private static native int nativeBeginRename(int slot);
    private static native int nativeCompleteRename(int slot);
    private static native int nativeCanTransfer(int stateTag);
    private static native int nativeCanTransition(int from, int to);

    // -----------------------------------------------------------------------
    // Safe wrappers
    // -----------------------------------------------------------------------

    public static int abiVersion() { return nativeAbiVersion(); }

    public static int create() throws ProvenError {
        return ProvenError.checkSlot(nativeCreate());
    }

    public static void destroy(int slot) { nativeDestroy(slot); }

    public static SessionState state(int slot) { return SessionState.fromTag(nativeState(slot)); }

    /** @return transfer type tag (0=ASCII, 1=binary) */
    public static int transferType(int slot) { return nativeTransferType(slot); }

    /** @return data mode tag (0=active, 1=passive, 255=unset) */
    public static int dataMode(int slot) { return nativeDataMode(slot); }

    public static TransferState transferState(int slot) { return TransferState.fromTag(nativeTransferState(slot)); }

    public static long bytesTransferred(int slot) { return nativeBytesTransferred(slot); }

    public static int fileCount(int slot) { return nativeFileCount(slot); }

    public static int lastReplyCode(int slot) { return nativeLastReplyCode(slot); }

    public static int cwd(int slot, byte[] buf) { return nativeCwd(slot, buf, buf.length); }

    /** USER command. Transitions Connected -&gt; UserOk. */
    public static void user(int slot, String name) throws ProvenError {
        byte[] bytes = name.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        ProvenError.checkStatus(nativeUser(slot, bytes, bytes.length));
    }

    /** PASS command. Transitions UserOk -&gt; Authenticated. */
    public static void pass(int slot, String password) throws ProvenError {
        byte[] bytes = password.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        ProvenError.checkStatus(nativePass(slot, bytes, bytes.length));
    }

    /** QUIT command. */
    public static void quit(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeQuit(slot));
    }

    /** CWD command. Changes directory. */
    public static void changeDir(int slot, String path) throws ProvenError {
        byte[] bytes = path.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        ProvenError.checkStatus(nativeCwdCmd(slot, bytes, bytes.length));
    }

    /** CDUP command. */
    public static void changeDirUp(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeCdup(slot));
    }

    /** TYPE command. 0=ASCII, 1=binary. */
    public static void setType(int slot, int typeTag) throws ProvenError {
        ProvenError.checkStatus(nativeSetType(slot, typeTag));
    }

    /** PASV command. */
    public static void setPassive(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeSetPassive(slot));
    }

    /** PORT command. */
    public static void setActive(int slot, int port) throws ProvenError {
        ProvenError.checkStatus(nativeSetActive(slot, port));
    }

    /** Begin data transfer. */
    public static void beginTransfer(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeBeginTransfer(slot));
    }

    /** Add bytes to the transfer counter. */
    public static void addBytes(int slot, long count) throws ProvenError {
        ProvenError.checkStatus(nativeAddBytes(slot, count));
    }

    /** Complete a data transfer. */
    public static void completeTransfer(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeCompleteTransfer(slot));
    }

    /** Abort a data transfer. */
    public static void abortTransfer(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeAbortTransfer(slot));
    }

    /** RNFR: begin rename. Transitions Authenticated -&gt; Renaming. */
    public static void beginRename(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeBeginRename(slot));
    }

    /** RNTO: complete rename. Transitions Renaming -&gt; Authenticated. */
    public static void completeRename(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeCompleteRename(slot));
    }

    /** Stateless: check if transfers are allowed from the given state. */
    public static boolean canTransfer(SessionState state) {
        return nativeCanTransfer(state.tag()) == 1;
    }

    public static boolean canTransition(SessionState from, SessionState to) {
        return nativeCanTransition(from.tag(), to.tag()) == 1;
    }
}
