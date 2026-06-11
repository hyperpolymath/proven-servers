// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// JavaScript bindings for the proven-ftp Zig FFI.

import { checkSlot, checkStatus } from "./error.js";
import { loadLibrary } from "./ffi.js";

/** @readonly @enum {number} FTP session states. */
export const FtpSessionState = Object.freeze({
    CONNECTED: 0, USER_OK: 1, AUTHENTICATED: 2, RENAMING: 3, QUIT: 4,
});

/** @readonly @enum {number} FTP transfer states. */
export const TransferState = Object.freeze({
    IDLE: 0, IN_PROGRESS: 1, COMPLETED: 2, ABORTED: 3,
});

let _lib = null;

/** @param {object} [options] */
export async function init(options) {
    if (!_lib) _lib = await loadLibrary("ftp", options);
}

function lib() {
    if (!_lib) throw new Error("ftp: call init() before using the module");
    return _lib;
}

/**
 * FTP session context wrapping a Zig FFI slot.
 */
export class FtpContext {
    constructor(slot) { this._slot = slot; this._destroyed = false; }

    static create() {
        return new FtpContext(checkSlot(lib().ftp_create()));
    }

    destroy() {
        if (!this._destroyed) { lib().ftp_destroy(this._slot); this._destroyed = true; }
    }

    /** @returns {number|null} */ state() {
        const tag = lib().ftp_state(this._slot); return tag <= 4 ? tag : null;
    }
    /** @returns {number} */ transferType() { return lib().ftp_transfer_type(this._slot); }
    /** @returns {number} */ dataMode() { return lib().ftp_data_mode(this._slot); }
    /** @returns {number|null} */ transferState() {
        const tag = lib().ftp_transfer_state(this._slot); return tag <= 3 ? tag : null;
    }
    /** @returns {number} */ bytesTransferred() { return lib().ftp_bytes_transferred(this._slot); }
    /** @returns {number} */ fileCount() { return lib().ftp_file_count(this._slot); }
    /** @returns {number} */ lastReplyCode() { return lib().ftp_last_reply_code(this._slot); }

    /**
     * Get the current working directory.
     * @param {number} [maxLen=4096]
     * @returns {string}
     */
    cwd(maxLen = 4096) {
        const buf = new Uint8Array(maxLen);
        const written = lib().ftp_cwd(this._slot, buf, maxLen);
        return new TextDecoder().decode(buf.subarray(0, written));
    }

    /** @param {string} name */
    user(name) {
        const data = new TextEncoder().encode(name);
        checkStatus(lib().ftp_user(this._slot, data, data.length));
    }

    /** @param {string} password */
    pass(password) {
        const data = new TextEncoder().encode(password);
        checkStatus(lib().ftp_pass(this._slot, data, data.length));
    }

    quitSession() { checkStatus(lib().ftp_quit(this._slot)); }

    /** @param {string} path */
    changeDir(path) {
        const data = new TextEncoder().encode(path);
        checkStatus(lib().ftp_cwd_cmd(this._slot, data, data.length));
    }

    changeDirUp() { checkStatus(lib().ftp_cdup(this._slot)); }
    /** @param {number} typeTag - 0=ASCII, 1=binary */
    setType(typeTag) { checkStatus(lib().ftp_set_type(this._slot, typeTag)); }
    setPassive() { checkStatus(lib().ftp_set_passive(this._slot)); }
    /** @param {number} port */
    setActive(port) { checkStatus(lib().ftp_set_active(this._slot, port)); }
    beginTransfer() { checkStatus(lib().ftp_begin_transfer(this._slot)); }
    /** @param {number} count */
    addBytes(count) { checkStatus(lib().ftp_add_bytes(this._slot, count)); }
    completeTransfer() { checkStatus(lib().ftp_complete_transfer(this._slot)); }
    abortTransfer() { checkStatus(lib().ftp_abort_transfer(this._slot)); }
    beginRename() { checkStatus(lib().ftp_begin_rename(this._slot)); }
    completeRename() { checkStatus(lib().ftp_complete_rename(this._slot)); }
}

/** @returns {number} */
export function abiVersion() { return lib().ftp_abi_version(); }

/** @param {number} stateTag @returns {boolean} */
export function canTransfer(stateTag) { return lib().ftp_can_transfer(stateTag) === 1; }

/** @param {number} from @param {number} to @returns {boolean} */
export function canTransition(from, to) {
    return lib().ftp_can_transition(from, to) === 1;
}
