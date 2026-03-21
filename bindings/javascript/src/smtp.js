// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// JavaScript bindings for the proven-smtp Zig FFI.

import { checkSlot, checkStatus } from "./error.js";
import { loadLibrary } from "./ffi.js";

/** @readonly @enum {number} SMTP session states. */
export const SmtpSessionState = Object.freeze({
    CONNECTED: 0, GREETED: 1, AUTH_STARTED: 2, AUTHENTICATED: 3,
    MAIL_FROM: 4, RCPT_TO: 5, DATA: 6, MESSAGE_RECEIVED: 7, QUIT: 8,
});

/** @readonly @enum {number} SMTP AUTH mechanisms. */
export const AuthMechanism = Object.freeze({
    PLAIN: 0, LOGIN: 1, CRAM_MD5: 2, XOAUTH2: 3,
});

let _lib = null;

/** @param {object} [options] */
export async function init(options) {
    if (!_lib) _lib = await loadLibrary("smtp", options);
}

function lib() {
    if (!_lib) throw new Error("smtp: call init() before using the module");
    return _lib;
}

/**
 * SMTP session context wrapping a Zig FFI slot.
 */
export class SmtpContext {
    constructor(slot) { this._slot = slot; this._destroyed = false; }

    static create() {
        return new SmtpContext(checkSlot(lib().smtp_create_context()));
    }

    destroy() {
        if (!this._destroyed) { lib().smtp_destroy_context(this._slot); this._destroyed = true; }
    }

    /** @returns {number|null} */ getState() {
        const tag = lib().smtp_get_state(this._slot); return tag <= 8 ? tag : null;
    }
    /** @returns {number} */ getReplyCode() { return lib().smtp_get_reply_code(this._slot); }
    /** @returns {number} */ getRecipientCount() { return lib().smtp_get_recipient_count(this._slot); }
    /** @returns {number} */ getDataSize() { return lib().smtp_get_data_size(this._slot); }
    /** @returns {number|null} */ getAuthMechanism() {
        const tag = lib().smtp_get_auth_mechanism(this._slot); return tag <= 3 ? tag : null;
    }
    /** @returns {boolean} */ isAuthenticated() { return lib().smtp_is_authenticated(this._slot) === 1; }
    /** @returns {boolean} */ isTlsActive() { return lib().smtp_is_tls_active(this._slot) === 1; }

    /** @param {boolean} [ehlo=true] */
    greet(ehlo = true) { checkStatus(lib().smtp_greet(this._slot, ehlo ? 1 : 0)); }
    /** @param {number} mechanism - AuthMechanism tag. */
    authenticate(mechanism) { checkStatus(lib().smtp_authenticate(this._slot, mechanism)); }
    /** @param {boolean} success */
    authComplete(success) { checkStatus(lib().smtp_auth_complete(this._slot, success ? 1 : 0)); }
    setSender() { checkStatus(lib().smtp_set_sender(this._slot)); }
    addRecipient() { checkStatus(lib().smtp_add_recipient(this._slot)); }
    startData() { checkStatus(lib().smtp_start_data(this._slot)); }
    /** @param {number} length */
    appendData(length) { checkStatus(lib().smtp_append_data(this._slot, length)); }
    finishData() { checkStatus(lib().smtp_finish_data(this._slot)); }
    reset() { checkStatus(lib().smtp_reset(this._slot)); }
    quit() { checkStatus(lib().smtp_quit(this._slot)); }
    enableTls() { checkStatus(lib().smtp_enable_tls(this._slot)); }
}

/** @returns {number} */
export function abiVersion() { return lib().smtp_abi_version(); }

/** @param {number} from @param {number} to @returns {boolean} */
export function canTransition(from, to) {
    return lib().smtp_can_transition(from, to) === 1;
}
