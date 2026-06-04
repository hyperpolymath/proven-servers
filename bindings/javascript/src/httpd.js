// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// JavaScript bindings for the proven-httpd Zig FFI.
//
// Wraps the C-ABI functions from protocols/proven-httpd/ffi/zig/src/httpd.zig:
//   - Context lifecycle: http_create_context, http_destroy_context
//   - Request parsing: http_parse_request
//   - Request queries: http_get_method, http_get_path, http_get_header, http_get_body
//   - Response construction: http_set_status, http_set_header, http_set_body,
//     http_send_response
//   - Phase & transition: http_get_phase, http_get_version, http_keep_alive_check,
//     http_reset_context, http_can_transition

import { checkSlot, checkStatus } from "./error.js";
import { loadLibrary } from "./ffi.js";

// ---------------------------------------------------------------------------
// Enums matching Idris2 ABI tags
// ---------------------------------------------------------------------------

/** @readonly @enum {number} HTTP request methods. */
export const Method = Object.freeze({
    GET: 0, POST: 1, PUT: 2, DELETE: 3, PATCH: 4,
    HEAD: 5, OPTIONS: 6, TRACE: 7, CONNECT: 8,
});

/** @readonly @enum {number} HTTP request lifecycle phases. */
export const RequestPhase = Object.freeze({
    IDLE: 0, RECEIVING: 1, HEADERS_PARSED: 2, BODY_RECEIVING: 3,
    COMPLETE: 4, RESPONDING: 5, SENT: 6,
});

/** @readonly @enum {number} HTTP response status code tags. */
export const StatusCode = Object.freeze({
    OK: 0, CREATED: 1, NO_CONTENT: 2, MOVED_PERMANENTLY: 3, FOUND: 4,
    NOT_MODIFIED: 5, BAD_REQUEST: 6, UNAUTHORIZED: 7, FORBIDDEN: 8,
    NOT_FOUND: 9, METHOD_NOT_ALLOWED: 10, CONFLICT: 11, GONE: 12,
    UNPROCESSABLE_ENTITY: 13, TOO_MANY_REQUESTS: 14,
    INTERNAL_SERVER_ERROR: 15, NOT_IMPLEMENTED: 16, BAD_GATEWAY: 17,
    SERVICE_UNAVAILABLE: 18, GATEWAY_TIMEOUT: 19,
});

/** @readonly @enum {number} HTTP version tags. */
export const Version = Object.freeze({
    HTTP_1_0: 0, HTTP_1_1: 1, HTTP_2: 2,
});

/** @readonly @enum {number} Parse result values. */
export const ParseResult = Object.freeze({
    COMPLETE: 0, REJECTED: 1, NEED_MORE: 2,
});

// ---------------------------------------------------------------------------
// Module state
// ---------------------------------------------------------------------------

/** @type {object|null} */
let _lib = null;

/**
 * Initialize the httpd FFI library.
 *
 * @param {object} [options] - Loading options passed to loadLibrary.
 * @returns {Promise<void>}
 */
export async function init(options) {
    if (!_lib) {
        _lib = await loadLibrary("httpd", options);
    }
}

/** @returns {object} The loaded library, throwing if not initialized. */
function lib() {
    if (!_lib) throw new Error("httpd: call init() before using the module");
    return _lib;
}

// ---------------------------------------------------------------------------
// Context class
// ---------------------------------------------------------------------------

/**
 * HTTP request/response context wrapping a Zig FFI slot.
 *
 * The slot is released when destroy() is called. Use the static create()
 * factory for async initialization.
 *
 * @example
 * await init();
 * const ctx = HttpdContext.create();
 * try {
 *   const result = ctx.parseRequest(rawData);
 *   if (result === ParseResult.COMPLETE) {
 *     ctx.setStatus(StatusCode.OK);
 *     ctx.setBody(new TextEncoder().encode("Hello"));
 *     ctx.sendResponse();
 *   }
 * } finally {
 *   ctx.destroy();
 * }
 */
export class HttpdContext {
    /** @param {number} slot */
    constructor(slot) {
        /** @type {number} */
        this._slot = slot;
        /** @type {boolean} */
        this._destroyed = false;
    }

    /**
     * Create a new HTTP context.
     * @returns {HttpdContext}
     */
    static create() {
        const slot = checkSlot(lib().http_create_context());
        return new HttpdContext(slot);
    }

    /** Release the context slot back to the pool. */
    destroy() {
        if (!this._destroyed) {
            lib().http_destroy_context(this._slot);
            this._destroyed = true;
        }
    }

    /**
     * Feed raw HTTP data into the context for parsing.
     * @param {Uint8Array} data - Raw HTTP request bytes.
     * @returns {number} ParseResult value.
     */
    parseRequest(data) {
        return lib().http_parse_request(this._slot, data, data.length);
    }

    /**
     * Get the HTTP method of the parsed request.
     * @returns {number|null} Method tag, or null if not parsed (255).
     */
    getMethod() {
        const tag = lib().http_get_method(this._slot);
        return tag === 255 ? null : tag;
    }

    /**
     * Get the request path.
     * @param {number} [maxLen=4096] - Maximum path length.
     * @returns {string} The request path.
     */
    getPath(maxLen = 4096) {
        const buf = new Uint8Array(maxLen);
        const written = lib().http_get_path(this._slot, buf, maxLen);
        return new TextDecoder().decode(buf.subarray(0, written));
    }

    /**
     * Look up a request header by key (case-insensitive).
     * @param {string} key - Header name.
     * @param {number} [maxLen=4096] - Maximum value length.
     * @returns {string} Header value, or empty string if not found.
     */
    getHeader(key, maxLen = 4096) {
        const keyBuf = new TextEncoder().encode(key);
        const valBuf = new Uint8Array(maxLen);
        const written = lib().http_get_header(
            this._slot, keyBuf, keyBuf.length, valBuf, maxLen,
        );
        return new TextDecoder().decode(valBuf.subarray(0, written));
    }

    /**
     * Get the request body.
     * @param {number} [maxLen=65536] - Maximum body length.
     * @returns {Uint8Array} The request body bytes.
     */
    getBody(maxLen = 65536) {
        const buf = new Uint8Array(maxLen);
        const written = lib().http_get_body(this._slot, buf, maxLen);
        return buf.subarray(0, written);
    }

    /**
     * Set the response status code.
     * @param {number} status - StatusCode tag.
     */
    setStatus(status) {
        checkStatus(lib().http_set_status(this._slot, status));
    }

    /**
     * Set a response header.
     * @param {string} key - Header name.
     * @param {string} value - Header value.
     */
    setHeader(key, value) {
        const k = new TextEncoder().encode(key);
        const v = new TextEncoder().encode(value);
        checkStatus(lib().http_set_header(this._slot, k, k.length, v, v.length));
    }

    /**
     * Set the response body.
     * @param {Uint8Array} data - Response body bytes.
     */
    setBody(data) {
        checkStatus(lib().http_set_body(this._slot, data, data.length));
    }

    /** Send the response. Transitions Responding -> Sent. */
    sendResponse() {
        checkStatus(lib().http_send_response(this._slot));
    }

    /**
     * Check if the connection uses keep-alive.
     * @returns {boolean}
     */
    keepAliveCheck() {
        return lib().http_keep_alive_check(this._slot) === 1;
    }

    /**
     * Get the current request processing phase.
     * @returns {number|null} RequestPhase tag, or null if unknown.
     */
    getPhase() {
        const tag = lib().http_get_phase(this._slot);
        return tag <= 6 ? tag : null;
    }

    /**
     * Get the HTTP version.
     * @returns {number|null} Version tag, or null if unknown.
     */
    getVersion() {
        const tag = lib().http_get_version(this._slot);
        return tag <= 2 ? tag : null;
    }

    /** Reset context for keep-alive reuse (Sent -> Idle). */
    reset() {
        checkStatus(lib().http_reset_context(this._slot));
    }
}

// ---------------------------------------------------------------------------
// Module-level functions
// ---------------------------------------------------------------------------

/**
 * Return the ABI version of the linked libproven_httpd.
 * @returns {number}
 */
export function abiVersion() {
    return lib().http_abi_version();
}

/**
 * Stateless query: check whether a lifecycle transition is valid.
 * @param {number} from - Source RequestPhase tag.
 * @param {number} to - Target RequestPhase tag.
 * @returns {boolean}
 */
export function canTransition(from, to) {
    return lib().http_can_transition(from, to) === 1;
}
