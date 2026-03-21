// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// JavaScript bindings for the proven-grpc Zig FFI.

import { checkSlot, checkStatus } from "./error.js";
import { loadLibrary } from "./ffi.js";

/** @readonly @enum {number} HTTP/2 stream states. */
export const StreamState = Object.freeze({
    IDLE: 0, RESERVED: 1, OPEN: 2, HALF_CLOSED_LOCAL: 3,
    HALF_CLOSED_REMOTE: 4, CLOSED: 5,
});

/** @readonly @enum {number} gRPC compression algorithms. */
export const Compression = Object.freeze({
    NONE: 0, GZIP: 1, DEFLATE: 2, SNAPPY: 3, ZSTD: 4,
});

/** @readonly @enum {number} gRPC status codes. */
export const StatusCode = Object.freeze({
    OK: 0, CANCELLED: 1, UNKNOWN: 2, INVALID_ARGUMENT: 3,
    DEADLINE_EXCEEDED: 4, NOT_FOUND: 5, ALREADY_EXISTS: 6,
    PERMISSION_DENIED: 7, RESOURCE_EXHAUSTED: 8,
    FAILED_PRECONDITION: 9, ABORTED: 10, OUT_OF_RANGE: 11,
    UNIMPLEMENTED: 12, INTERNAL: 13, UNAVAILABLE: 14,
    DATA_LOSS: 15, UNAUTHENTICATED: 16,
});

let _lib = null;

/** @param {object} [options] */
export async function init(options) {
    if (!_lib) _lib = await loadLibrary("grpc", options);
}

function lib() {
    if (!_lib) throw new Error("grpc: call init() before using the module");
    return _lib;
}

/**
 * gRPC stream context wrapping a Zig FFI slot.
 */
export class GrpcContext {
    constructor(slot) { this._slot = slot; this._destroyed = false; }

    /** @param {number} [compression=0] - Compression tag. */
    static create(compression = Compression.NONE) {
        return new GrpcContext(checkSlot(lib().grpc_create(compression)));
    }

    destroy() {
        if (!this._destroyed) { lib().grpc_destroy(this._slot); this._destroyed = true; }
    }

    /** @returns {number|null} */ streamState() {
        const tag = lib().grpc_stream_state(this._slot); return tag <= 5 ? tag : null;
    }
    /** @returns {number} */ compression() { return lib().grpc_compression(this._slot); }
    /** @returns {number|null} */ statusCode() {
        const tag = lib().grpc_status_code(this._slot); return tag <= 16 ? tag : null;
    }
    /** @returns {number} */ streamId() { return lib().grpc_stream_id(this._slot); }
    /** @returns {boolean} */ canSend() { return lib().grpc_can_send(this._slot) === 1; }
    /** @returns {boolean} */ canReceive() { return lib().grpc_can_receive(this._slot) === 1; }
    /** @returns {number} */ sendWindow() { return lib().grpc_send_window(this._slot); }
    /** @returns {number} */ recvWindow() { return lib().grpc_recv_window(this._slot); }

    /** @param {number} status - StatusCode tag. */
    setStatus(status) { checkStatus(lib().grpc_set_status(this._slot, status)); }
    sendHeaders() { checkStatus(lib().grpc_send_headers(this._slot)); }
    localEndStream() { checkStatus(lib().grpc_local_end_stream(this._slot)); }
    remoteEndStream() { checkStatus(lib().grpc_remote_end_stream(this._slot)); }
    /** @param {number} status - StatusCode tag. */
    resetStream(status) { checkStatus(lib().grpc_reset_stream(this._slot, status)); }
    closeHalfLocal() { checkStatus(lib().grpc_close_half_local(this._slot)); }
    closeHalfRemote() { checkStatus(lib().grpc_close_half_remote(this._slot)); }
    pushPromise() { checkStatus(lib().grpc_push_promise(this._slot)); }
    reservedToHalf() { checkStatus(lib().grpc_reserved_to_half(this._slot)); }
    /** @param {number} delta */
    updateSendWindow(delta) { checkStatus(lib().grpc_update_send_window(this._slot, delta)); }
    /** @param {number} delta */
    updateRecvWindow(delta) { checkStatus(lib().grpc_update_recv_window(this._slot, delta)); }
}

/** @returns {number} */
export function abiVersion() { return lib().grpc_abi_version(); }

/** @param {number} from @param {number} to @returns {boolean} */
export function canTransition(from, to) {
    return lib().grpc_can_transition(from, to) === 1;
}
