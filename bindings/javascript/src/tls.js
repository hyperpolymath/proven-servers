// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// JavaScript bindings for the proven-tls Zig FFI.

import { checkSlot, checkStatus } from "./error.js";
import { loadLibrary } from "./ffi.js";

/** @readonly @enum {number} TLS handshake lifecycle states. */
export const TlsState = Object.freeze({
    IDLE: 0, CLIENT_HELLO: 1, SERVER_HELLO: 2, NEGOTIATED: 3,
    HANDSHAKE_COMPLETE: 4, APPLICATION_DATA: 5, SHUTDOWN: 6, CLOSED: 7,
});

/** @readonly @enum {number} TLS protocol versions. */
export const TlsVersion = Object.freeze({ TLS_1_2: 0, TLS_1_3: 1 });

/** @readonly @enum {number} TLS cipher suites. */
export const CipherSuite = Object.freeze({
    AES_128_GCM_SHA256: 0, AES_256_GCM_SHA384: 1,
    CHACHA20_POLY1305_SHA256: 2, AES_128_CCM_SHA256: 3,
});

/** @readonly @enum {number} Certificate validation status. */
export const CertStatus = Object.freeze({
    UNCHECKED: 0, VALID: 1, EXPIRED: 2, REVOKED: 3,
    SELF_SIGNED: 4, UNKNOWN_CA: 5, HOSTNAME_MISMATCH: 6,
});

/** @readonly @enum {number} TLS alert levels. */
export const AlertLevel = Object.freeze({ WARNING: 0, FATAL: 1 });

let _lib = null;

/** @param {object} [options] */
export async function init(options) {
    if (!_lib) _lib = await loadLibrary("tls", options);
}

function lib() {
    if (!_lib) throw new Error("tls: call init() before using the module");
    return _lib;
}

/**
 * TLS session context wrapping a Zig FFI slot.
 */
export class TlsContext {
    constructor(slot) { this._slot = slot; this._destroyed = false; }

    /**
     * @param {number} [version=1] - TlsVersion tag.
     * @param {number} [cipherSuite=1] - CipherSuite tag.
     */
    static create(version = TlsVersion.TLS_1_3, cipherSuite = CipherSuite.AES_256_GCM_SHA384) {
        return new TlsContext(checkSlot(lib().tls_create(version, cipherSuite)));
    }

    destroy() {
        if (!this._destroyed) { lib().tls_destroy(this._slot); this._destroyed = true; }
    }

    /** @returns {number|null} */ state() {
        const tag = lib().tls_state(this._slot); return tag <= 7 ? tag : null;
    }
    /** @returns {number|null} */ version() {
        const tag = lib().tls_version(this._slot); return tag <= 1 ? tag : null;
    }
    /** @returns {number|null} */ cipherSuite() {
        const tag = lib().tls_cipher_suite(this._slot); return tag <= 3 ? tag : null;
    }
    /** @returns {number|null} */ certStatus() {
        const tag = lib().tls_cert_status(this._slot); return tag <= 6 ? tag : null;
    }
    /** @returns {boolean} */ isResumed() { return lib().tls_is_resumed(this._slot) === 1; }
    /** @returns {number} */ bytesSent() { return lib().tls_bytes_sent(this._slot); }
    /** @returns {number} */ bytesReceived() { return lib().tls_bytes_received(this._slot); }

    clientHello() { checkStatus(lib().tls_client_hello(this._slot)); }
    serverHello() { checkStatus(lib().tls_server_hello(this._slot)); }
    /** @param {number} cipherSuite - CipherSuite tag. */
    negotiate(cipherSuite) { checkStatus(lib().tls_negotiate(this._slot, cipherSuite)); }
    /** @param {number} status - CertStatus tag. */
    validateCert(status) { checkStatus(lib().tls_validate_cert(this._slot, status)); }
    completeHandshake() { checkStatus(lib().tls_complete_handshake(this._slot)); }

    /** @param {number} length */
    sendData(length) { checkStatus(lib().tls_send_data(this._slot, length)); }
    /** @param {number} length */
    receiveData(length) { checkStatus(lib().tls_receive_data(this._slot, length)); }
    rekey() { checkStatus(lib().tls_rekey(this._slot)); }

    shutdown() { checkStatus(lib().tls_shutdown(this._slot)); }
    /** @param {number} level - AlertLevel tag. */
    sendAlert(level) { checkStatus(lib().tls_send_alert(this._slot, level)); }
}

/** @returns {number} */
export function abiVersion() { return lib().tls_abi_version(); }

/** @param {number} from @param {number} to @returns {boolean} */
export function canTransition(from, to) {
    return lib().tls_can_transition(from, to) === 1;
}
