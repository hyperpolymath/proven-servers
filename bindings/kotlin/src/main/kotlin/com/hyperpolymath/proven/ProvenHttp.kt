// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kotlin/JNI bindings for the proven-httpd protocol.
// Wraps the C-ABI functions from protocols/proven-httpd/ffi/zig/src/httpd.zig.
// Enum classes match Idris2 ABI tags exactly (HTTPABI.Layout).

package com.hyperpolymath.proven

/**
 * Kotlin bindings for the proven HTTP server protocol.
 *
 * Provides a type-safe wrapper around the Zig FFI context pool for
 * HTTP request/response lifecycle management.
 *
 * Lifecycle: Idle -> Receiving -> HeadersParsed -> Complete -> Responding -> Sent.
 *
 * @author Jonathan D.A. Jewell
 */
public class ProvenHttp private constructor(private val slot: Int) : AutoCloseable {

    // -----------------------------------------------------------------------
    // Enum classes matching Idris2 ABI tags
    // -----------------------------------------------------------------------

    /** HTTP request methods (HTTPABI.Layout.HttpMethod, tags 0-8). */
    public enum class Method(public val tag: Int) {
        GET(0), POST(1), PUT(2), DELETE(3), PATCH(4),
        HEAD(5), OPTIONS(6), TRACE(7), CONNECT(8);

        public companion object {
            /** Decode from an ABI tag value, or `null` if unknown. */
            @JvmStatic
            public fun fromTag(tag: Int): Method? = entries.find { it.tag == tag }
        }
    }

    /** HTTP protocol versions (tags 0-3). */
    public enum class Version(public val tag: Int) {
        HTTP_1_0(0), HTTP_1_1(1), HTTP_2_0(2), HTTP_3_0(3);

        public companion object {
            @JvmStatic
            public fun fromTag(tag: Int): Version? = entries.find { it.tag == tag }
        }
    }

    /** HTTP request lifecycle phases (tags 0-6). */
    public enum class RequestPhase(public val tag: Int) {
        IDLE(0), RECEIVING(1), HEADERS_PARSED(2), BODY_RECEIVING(3),
        COMPLETE(4), RESPONDING(5), SENT(6);

        public companion object {
            @JvmStatic
            public fun fromTag(tag: Int): RequestPhase? = entries.find { it.tag == tag }
        }
    }

    /** HTTP status codes (tags 0-28). */
    public enum class StatusCode(public val tag: Int) {
        CONTINUE(0), SWITCHING_PROTOCOLS(1),
        OK(2), CREATED(3), ACCEPTED(4), NO_CONTENT(5),
        MOVED_PERMANENTLY(6), FOUND(7), NOT_MODIFIED(8),
        TEMPORARY_REDIRECT(9), PERMANENT_REDIRECT(10),
        BAD_REQUEST(11), UNAUTHORIZED(12), FORBIDDEN(13), NOT_FOUND(14),
        METHOD_NOT_ALLOWED(15), REQUEST_TIMEOUT(16), CONFLICT(17), GONE(18),
        LENGTH_REQUIRED(19), PAYLOAD_TOO_LARGE(20), URI_TOO_LONG(21),
        UNSUPPORTED_MEDIA(22), TOO_MANY_REQUESTS(23),
        INTERNAL_ERROR(24), NOT_IMPLEMENTED(25), BAD_GATEWAY(26),
        SERVICE_UNAVAILABLE(27), GATEWAY_TIMEOUT(28);

        public companion object {
            @JvmStatic
            public fun fromTag(tag: Int): StatusCode? = entries.find { it.tag == tag }
        }
    }

    /** Result of parsing raw HTTP data. */
    public enum class ParseResult(public val tag: Int) {
        COMPLETE(0), REJECTED(1), NEED_MORE(2);

        public companion object {
            @JvmStatic
            public fun fromTag(tag: Int): ParseResult? = entries.find { it.tag == tag }
        }
    }

    // -----------------------------------------------------------------------
    // JNI native declarations
    // -----------------------------------------------------------------------

    private companion object {
        @JvmStatic external fun http_abi_version(): Int
        @JvmStatic external fun http_create_context(): Int
        @JvmStatic external fun http_destroy_context(slot: Int)
        @JvmStatic external fun http_parse_request(slot: Int, data: ByteArray, len: Int): Int
        @JvmStatic external fun http_get_method(slot: Int): Int
        @JvmStatic external fun http_get_path(slot: Int, buf: ByteArray, len: Int): Int
        @JvmStatic external fun http_get_header(slot: Int, key: ByteArray, klen: Int, buf: ByteArray, blen: Int): Int
        @JvmStatic external fun http_get_body(slot: Int, buf: ByteArray, len: Int): Int
        @JvmStatic external fun http_set_status(slot: Int, statusTag: Int): Int
        @JvmStatic external fun http_set_header(slot: Int, key: ByteArray, klen: Int, value: ByteArray, vlen: Int): Int
        @JvmStatic external fun http_set_body(slot: Int, data: ByteArray, len: Int): Int
        @JvmStatic external fun http_send_response(slot: Int): Int
        @JvmStatic external fun http_keep_alive_check(slot: Int): Int
        @JvmStatic external fun http_get_phase(slot: Int): Int
        @JvmStatic external fun http_get_version(slot: Int): Int
        @JvmStatic external fun http_reset_context(slot: Int): Int
        @JvmStatic external fun http_can_transition(from: Int, to: Int): Int

        /** The ABI version of the linked HTTP library. */
        @JvmStatic
        fun abiVersion(): Int = http_abi_version()

        /** Stateless query: check whether a lifecycle transition is valid. */
        @JvmStatic
        fun canTransition(from: RequestPhase, to: RequestPhase): Boolean =
            http_can_transition(from.tag, to.tag) == 1
    }

    // -----------------------------------------------------------------------
    // Kotlin-idiomatic wrapper with Result type
    // -----------------------------------------------------------------------

    override fun close() {
        http_destroy_context(slot)
    }

    /** Feed raw HTTP data into this context for parsing. */
    public fun parseRequest(data: ByteArray): Result<ParseResult> = ProvenError.runCatching {
        val result = http_parse_request(slot, data, data.size)
        ParseResult.fromTag(result)
            ?: throw ProvenError("Unknown parse result: $result", result)
    }

    /** The HTTP method of the parsed request, or `null` if not yet parsed. */
    public val method: Method?
        get() = Method.fromTag(http_get_method(slot))

    /** Copy the request path into a String. */
    public fun getPath(): Result<String> = ProvenError.runCatching {
        val buf = ByteArray(4096)
        val written = http_get_path(slot, buf, buf.size)
        String(buf, 0, written)
    }

    /** Look up a request header by key (case-insensitive). */
    public fun getHeader(key: String): Result<String?> = ProvenError.runCatching {
        val keyBytes = key.toByteArray()
        val buf = ByteArray(8192)
        val written = http_get_header(slot, keyBytes, keyBytes.size, buf, buf.size)
        if (written > 0) String(buf, 0, written) else null
    }

    /** Copy the request body. */
    public fun getBody(): Result<ByteArray> = ProvenError.runCatching {
        val buf = ByteArray(65536)
        val written = http_get_body(slot, buf, buf.size)
        buf.copyOf(written)
    }

    /** Set the response status code. */
    public fun setStatus(status: StatusCode): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(http_set_status(slot, status.tag))
    }

    /** Set a response header. */
    public fun setHeader(key: String, value: String): Result<Unit> = ProvenError.runCatching {
        val keyBytes = key.toByteArray()
        val valBytes = value.toByteArray()
        ProvenError.checkStatus(http_set_header(slot, keyBytes, keyBytes.size, valBytes, valBytes.size))
    }

    /** Set the response body. */
    public fun setBody(data: ByteArray): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(http_set_body(slot, data, data.size))
    }

    /** Send the response, transitioning Responding -> Sent. */
    public fun sendResponse(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(http_send_response(slot))
    }

    /** Check if the connection uses keep-alive. */
    public val isKeepAlive: Boolean
        get() = http_keep_alive_check(slot) == 1

    /** The current request processing phase. */
    public val phase: RequestPhase?
        get() = RequestPhase.fromTag(http_get_phase(slot))

    /** The HTTP version of the parsed request. */
    public val version: Version?
        get() = Version.fromTag(http_get_version(slot))

    /** Reset the context for keep-alive reuse (Sent -> Idle). */
    public fun reset(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(http_reset_context(slot))
    }

    public companion object {
        /**
         * Create a new HTTP context in the Idle phase.
         *
         * @return [Result] containing the context or a [ProvenError].
         */
        @JvmStatic
        public fun create(): Result<ProvenHttp> = ProvenError.runCatching {
            val slot = ProvenError.checkSlot(http_create_context())
            ProvenHttp(slot)
        }

        /** The ABI version of the linked HTTP library. */
        @JvmStatic
        public fun abiVersion(): Int = http_abi_version()

        /** Stateless query: check whether a lifecycle transition is valid. */
        @JvmStatic
        public fun canTransition(from: RequestPhase, to: RequestPhase): Boolean =
            http_can_transition(from.tag, to.tag) == 1
    }
}
