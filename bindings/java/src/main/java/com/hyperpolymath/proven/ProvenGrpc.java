// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Java JNI bindings for the proven-grpc protocol.
// Wraps the C-ABI functions from protocols/proven-grpc/ffi/zig/src/grpc.zig.

package com.hyperpolymath.proven;

/**
 * Java bindings for the proven gRPC protocol.
 *
 * <p>Models the HTTP/2 stream state machine (RFC 7540 Section 5.1):
 * Idle -&gt; Open -&gt; HalfClosedLocal/HalfClosedRemote -&gt; Closed.</p>
 *
 * @author Jonathan D.A. Jewell
 */
public final class ProvenGrpc {

    private ProvenGrpc() {}

    // -----------------------------------------------------------------------
    // Enums
    // -----------------------------------------------------------------------

    /** gRPC status codes (tags 0-16). */
    public enum StatusCode {
        OK(0), CANCELLED(1), UNKNOWN(2), INVALID_ARGUMENT(3),
        DEADLINE_EXCEEDED(4), NOT_FOUND(5), ALREADY_EXISTS(6),
        PERMISSION_DENIED(7), RESOURCE_EXHAUSTED(8),
        FAILED_PRECONDITION(9), ABORTED(10), OUT_OF_RANGE(11),
        UNIMPLEMENTED(12), INTERNAL(13), UNAVAILABLE(14),
        DATA_LOSS(15), UNAUTHENTICATED(16);

        private final int code;
        StatusCode(int code) { this.code = code; }
        public int code() { return code; }

        public static StatusCode fromCode(int code) {
            for (StatusCode s : values()) {
                if (s.code == code) return s;
            }
            return null;
        }
    }

    /** HTTP/2 stream states (RFC 7540, tags 0-5). */
    public enum StreamState {
        IDLE(0), OPEN(1), HALF_CLOSED_LOCAL(2),
        HALF_CLOSED_REMOTE(3), CLOSED(4), RESERVED(5);

        private final int tag;
        StreamState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StreamState fromTag(int tag) {
            for (StreamState s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    /** gRPC compression algorithms (tags 0-4). */
    public enum Compression {
        IDENTITY(0), GZIP(1), DEFLATE(2), SNAPPY(3), ZSTD(4);

        private final int tag;
        Compression(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Compression fromTag(int tag) {
            for (Compression c : values()) {
                if (c.tag == tag) return c;
            }
            return null;
        }
    }

    // -----------------------------------------------------------------------
    // JNI native methods
    // -----------------------------------------------------------------------

    private static native int nativeAbiVersion();
    private static native int nativeCreate(int compression);
    private static native void nativeDestroy(int slot);
    private static native int nativeStreamState(int slot);
    private static native int nativeCompression(int slot);
    private static native int nativeStatusCode(int slot);
    private static native int nativeSetStatus(int slot, int status);
    private static native int nativeStreamId(int slot);
    private static native int nativeSendHeaders(int slot);
    private static native int nativeLocalEndStream(int slot);
    private static native int nativeRemoteEndStream(int slot);
    private static native int nativeResetStream(int slot, int status);
    private static native int nativeCloseHalfLocal(int slot);
    private static native int nativeCloseHalfRemote(int slot);
    private static native int nativePushPromise(int slot);
    private static native int nativeReservedToHalf(int slot);
    private static native int nativeCanSend(int slot);
    private static native int nativeCanReceive(int slot);
    private static native int nativeSendWindow(int slot);
    private static native int nativeRecvWindow(int slot);
    private static native int nativeUpdateSendWindow(int slot, int delta);
    private static native int nativeUpdateRecvWindow(int slot, int delta);
    private static native int nativeCanTransition(int from, int to);

    // -----------------------------------------------------------------------
    // Safe wrappers
    // -----------------------------------------------------------------------

    public static int abiVersion() { return nativeAbiVersion(); }

    public static int create(Compression compression) throws ProvenError {
        return ProvenError.checkSlot(nativeCreate(compression.tag()));
    }

    public static void destroy(int slot) { nativeDestroy(slot); }

    public static StreamState streamState(int slot) { return StreamState.fromTag(nativeStreamState(slot)); }

    public static int compression(int slot) { return nativeCompression(slot); }

    public static StatusCode statusCode(int slot) { return StatusCode.fromCode(nativeStatusCode(slot)); }

    public static void setStatus(int slot, StatusCode status) throws ProvenError {
        ProvenError.checkStatus(nativeSetStatus(slot, status.code()));
    }

    public static int streamId(int slot) { return nativeStreamId(slot); }

    /** Send HEADERS frame. Transitions Idle -&gt; Open. */
    public static void sendHeaders(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeSendHeaders(slot));
    }

    /** Local END_STREAM. Transitions Open -&gt; HalfClosedLocal. */
    public static void localEndStream(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeLocalEndStream(slot));
    }

    /** Remote END_STREAM. Transitions Open -&gt; HalfClosedRemote. */
    public static void remoteEndStream(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeRemoteEndStream(slot));
    }

    /** RST_STREAM. Transitions to Closed. */
    public static void resetStream(int slot, StatusCode status) throws ProvenError {
        ProvenError.checkStatus(nativeResetStream(slot, status.code()));
    }

    /** Close from HalfClosedLocal -&gt; Closed. */
    public static void closeHalfLocal(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeCloseHalfLocal(slot));
    }

    /** Close from HalfClosedRemote -&gt; Closed. */
    public static void closeHalfRemote(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeCloseHalfRemote(slot));
    }

    /** PUSH_PROMISE. Transitions Idle -&gt; Reserved. */
    public static void pushPromise(int slot) throws ProvenError {
        ProvenError.checkStatus(nativePushPromise(slot));
    }

    /** Reserved -&gt; HalfClosedRemote. */
    public static void reservedToHalf(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeReservedToHalf(slot));
    }

    public static boolean canSend(int slot) { return nativeCanSend(slot) == 1; }

    public static boolean canReceive(int slot) { return nativeCanReceive(slot) == 1; }

    public static int sendWindow(int slot) { return nativeSendWindow(slot); }

    public static int recvWindow(int slot) { return nativeRecvWindow(slot); }

    public static void updateSendWindow(int slot, int delta) throws ProvenError {
        ProvenError.checkStatus(nativeUpdateSendWindow(slot, delta));
    }

    public static void updateRecvWindow(int slot, int delta) throws ProvenError {
        ProvenError.checkStatus(nativeUpdateRecvWindow(slot, delta));
    }

    public static boolean canTransition(StreamState from, StreamState to) {
        return nativeCanTransition(from.tag(), to.tag()) == 1;
    }
}
