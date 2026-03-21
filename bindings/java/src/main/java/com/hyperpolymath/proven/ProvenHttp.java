// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Java JNI bindings for the proven-httpd protocol.
// Wraps the C-ABI functions from protocols/proven-httpd/ffi/zig/src/httpd.zig.
// Enums match Idris2 ABI tags exactly (HTTPABI.Layout).

package com.hyperpolymath.proven;

/**
 * Java bindings for the proven HTTP server protocol.
 *
 * <p>Provides a type-safe wrapper around the Zig FFI context pool for
 * HTTP request/response lifecycle management. The lifecycle follows
 * Idle -&gt; Receiving -&gt; HeadersParsed -&gt; Complete -&gt; Responding -&gt; Sent.</p>
 *
 * @author Jonathan D.A. Jewell
 * @see ProvenError
 */
public final class ProvenHttp {

    private ProvenHttp() {}

    // -----------------------------------------------------------------------
    // Enums matching Idris2 ABI tags
    // -----------------------------------------------------------------------

    /** HTTP request methods (HTTPABI.Layout.HttpMethod, tags 0-8). */
    public enum Method {
        GET(0), POST(1), PUT(2), DELETE(3), PATCH(4),
        HEAD(5), OPTIONS(6), TRACE(7), CONNECT(8);

        private final int tag;
        Method(int tag) { this.tag = tag; }

        /** @return the ABI tag value */
        public int tag() { return tag; }

        /** Decode from an ABI tag value, or null if unknown. */
        public static Method fromTag(int tag) {
            for (Method m : values()) {
                if (m.tag == tag) return m;
            }
            return null;
        }
    }

    /** HTTP version (HTTPABI.Layout, tags 0-3). */
    public enum Version {
        HTTP_1_0(0), HTTP_1_1(1), HTTP_2_0(2), HTTP_3_0(3);

        private final int tag;
        Version(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Version fromTag(int tag) {
            for (Version v : values()) {
                if (v.tag == tag) return v;
            }
            return null;
        }
    }

    /** HTTP request lifecycle phases (tags 0-6). */
    public enum RequestPhase {
        IDLE(0), RECEIVING(1), HEADERS_PARSED(2), BODY_RECEIVING(3),
        COMPLETE(4), RESPONDING(5), SENT(6);

        private final int tag;
        RequestPhase(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RequestPhase fromTag(int tag) {
            for (RequestPhase p : values()) {
                if (p.tag == tag) return p;
            }
            return null;
        }
    }

    /** HTTP status codes (ABI tags 0-26+). */
    public enum StatusCode {
        CONTINUE(0), SWITCHING_PROTOCOLS(1),
        OK(2), CREATED(3), ACCEPTED(4), NO_CONTENT(5),
        MOVED_PERMANENTLY(6), FOUND(7), NOT_MODIFIED(8),
        TEMPORARY_REDIRECT(9), PERMANENT_REDIRECT(10),
        BAD_REQUEST(11), UNAUTHORIZED(12), FORBIDDEN(13),
        NOT_FOUND(14), METHOD_NOT_ALLOWED(15), REQUEST_TIMEOUT(16),
        CONFLICT(17), GONE(18), LENGTH_REQUIRED(19),
        PAYLOAD_TOO_LARGE(20), URI_TOO_LONG(21),
        UNSUPPORTED_MEDIA_TYPE(22), TOO_MANY_REQUESTS(23),
        INTERNAL_SERVER_ERROR(24), NOT_IMPLEMENTED(25),
        BAD_GATEWAY(26), SERVICE_UNAVAILABLE(27),
        GATEWAY_TIMEOUT(28);

        private final int tag;
        StatusCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StatusCode fromTag(int tag) {
            for (StatusCode s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    /** Parse result from feeding raw HTTP data into a context. */
    public enum ParseResult {
        COMPLETE(0), REJECTED(1), NEED_MORE(2);

        private final int tag;
        ParseResult(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ParseResult fromTag(int tag) {
            for (ParseResult p : values()) {
                if (p.tag == tag) return p;
            }
            return null;
        }
    }

    // -----------------------------------------------------------------------
    // JNI native method declarations
    // -----------------------------------------------------------------------

    private static native int nativeAbiVersion();
    private static native int nativeCreateContext();
    private static native void nativeDestroyContext(int slot);
    private static native int nativeParseRequest(int slot, byte[] data, int len);
    private static native int nativeGetMethod(int slot);
    private static native int nativeGetPath(int slot, byte[] buf, int len);
    private static native int nativeGetHeader(int slot, byte[] key, int klen, byte[] buf, int blen);
    private static native int nativeGetBody(int slot, byte[] buf, int len);
    private static native int nativeSetStatus(int slot, int statusTag);
    private static native int nativeSetHeader(int slot, byte[] key, int klen, byte[] val, int vlen);
    private static native int nativeSetBody(int slot, byte[] data, int len);
    private static native int nativeSendResponse(int slot);
    private static native int nativeKeepAliveCheck(int slot);
    private static native int nativeGetPhase(int slot);
    private static native int nativeGetVersion(int slot);
    private static native int nativeResetContext(int slot);
    private static native int nativeCanTransition(int from, int to);

    // -----------------------------------------------------------------------
    // Safe wrapper methods
    // -----------------------------------------------------------------------

    /** @return the ABI version of the linked HTTP library */
    public static int abiVersion() { return nativeAbiVersion(); }

    /**
     * Create a new HTTP context in the Idle phase.
     *
     * @return the context slot index
     * @throws ProvenError if the pool is exhausted (all 64 slots in use)
     */
    public static int createContext() throws ProvenError {
        return ProvenError.checkSlot(nativeCreateContext());
    }

    /** Release an HTTP context slot. */
    public static void destroyContext(int slot) { nativeDestroyContext(slot); }

    /**
     * Feed raw HTTP data into a context for parsing.
     *
     * @param slot context slot
     * @param data raw HTTP bytes
     * @return the parse result
     * @throws ProvenError if the slot is invalid
     */
    public static ParseResult parseRequest(int slot, byte[] data) throws ProvenError {
        int result = nativeParseRequest(slot, data, data.length);
        ParseResult pr = ParseResult.fromTag(result);
        if (pr == null) {
            throw new ProvenError("Unknown parse result: " + result, result);
        }
        return pr;
    }

    /** Get the HTTP method of the parsed request, or null if not yet parsed. */
    public static Method getMethod(int slot) {
        return Method.fromTag(nativeGetMethod(slot));
    }

    /**
     * Copy the request path into a buffer.
     *
     * @param slot context slot
     * @param buf  destination buffer
     * @return number of bytes written
     */
    public static int getPath(int slot, byte[] buf) {
        return nativeGetPath(slot, buf, buf.length);
    }

    /**
     * Look up a request header value by key.
     *
     * @param slot context slot
     * @param key  header name (case-insensitive)
     * @param buf  destination buffer for the value
     * @return number of bytes written, or 0 if not found
     */
    public static int getHeader(int slot, byte[] key, byte[] buf) {
        return nativeGetHeader(slot, key, key.length, buf, buf.length);
    }

    /**
     * Copy the request body into a buffer.
     *
     * @return number of bytes written, or 0 if no body
     */
    public static int getBody(int slot, byte[] buf) {
        return nativeGetBody(slot, buf, buf.length);
    }

    /**
     * Set the response status code.
     *
     * @throws ProvenError if the context is in the wrong phase
     */
    public static void setStatus(int slot, StatusCode status) throws ProvenError {
        ProvenError.checkStatus(nativeSetStatus(slot, status.tag()));
    }

    /**
     * Set a response header.
     *
     * @throws ProvenError if in wrong phase or header capacity exceeded
     */
    public static void setHeader(int slot, byte[] key, byte[] value) throws ProvenError {
        ProvenError.checkStatus(nativeSetHeader(slot, key, key.length, value, value.length));
    }

    /**
     * Set the response body.
     *
     * @throws ProvenError if in wrong phase or body exceeds buffer limit
     */
    public static void setBody(int slot, byte[] data) throws ProvenError {
        ProvenError.checkStatus(nativeSetBody(slot, data, data.length));
    }

    /**
     * Send the response (Responding -&gt; Sent).
     *
     * @throws ProvenError if not in Responding phase
     */
    public static void sendResponse(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeSendResponse(slot));
    }

    /** Check whether the connection uses keep-alive. */
    public static boolean keepAliveCheck(int slot) {
        return nativeKeepAliveCheck(slot) == 1;
    }

    /** Get the current request processing phase. */
    public static RequestPhase getPhase(int slot) {
        return RequestPhase.fromTag(nativeGetPhase(slot));
    }

    /** Get the HTTP version of the parsed request. */
    public static Version getVersion(int slot) {
        return Version.fromTag(nativeGetVersion(slot));
    }

    /**
     * Reset the context for keep-alive reuse (Sent -&gt; Idle).
     *
     * @throws ProvenError if not in Sent phase
     */
    public static void resetContext(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeResetContext(slot));
    }

    /**
     * Stateless: check whether a lifecycle transition is valid.
     *
     * @return true if the transition from {@code from} to {@code to} is allowed
     */
    public static boolean canTransition(RequestPhase from, RequestPhase to) {
        return nativeCanTransition(from.tag(), to.tag()) == 1;
    }
}
