// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// JavaScript bindings for the proven-ssh-bastion Zig FFI.

import { checkSlot, checkStatus } from "./error.js";
import { loadLibrary } from "./ffi.js";

/** @readonly @enum {number} SSH bastion session states. */
export const BastionState = Object.freeze({
    CONNECTED: 0, KEY_EXCHANGED: 1, AUTHENTICATED: 2,
    CHANNEL_OPEN: 3, ACTIVE: 4, CLOSED: 5,
});

/** @readonly @enum {number} SSH key exchange methods. */
export const KexMethod = Object.freeze({
    CURVE25519_SHA256: 0, ECDH_SHA2_NISTP256: 1, ECDH_SHA2_NISTP384: 2,
    DIFFIE_HELLMAN_GROUP14_SHA256: 3, DIFFIE_HELLMAN_GROUP16_SHA512: 4,
});

/** @readonly @enum {number} SSH authentication methods. */
export const AuthMethod = Object.freeze({
    PUBLIC_KEY: 0, PASSWORD: 1, KEYBOARD_INTERACTIVE: 2, HOST_BASED: 3,
});

/** @readonly @enum {number} SSH channel types. */
export const ChannelType = Object.freeze({
    SESSION: 0, DIRECT_TCPIP: 1, FORWARDED_TCPIP: 2, X11: 3,
});

/** @readonly @enum {number} SSH channel states. */
export const ChannelState = Object.freeze({
    OPENING: 0, OPEN: 1, CLOSED: 2,
});

/** @readonly @enum {number} SSH disconnect reasons. */
export const DisconnectReason = Object.freeze({
    BY_APPLICATION: 0, PROTOCOL_ERROR: 1, KEY_EXCHANGE_FAILED: 2,
    AUTH_CANCELLED_BY_USER: 3, TOO_MANY_CONNECTIONS: 4,
    HOST_NOT_ALLOWED: 5, ILLEGAL_USER_NAME: 6,
});

let _lib = null;

/** @param {object} [options] */
export async function init(options) {
    if (!_lib) _lib = await loadLibrary("ssh_bastion", options);
}

function lib() {
    if (!_lib) throw new Error("ssh_bastion: call init() before using the module");
    return _lib;
}

/**
 * SSH bastion session context wrapping a Zig FFI slot.
 */
export class SshBastionContext {
    constructor(slot) { this._slot = slot; this._destroyed = false; }

    /**
     * @param {number} [kex=0] - KexMethod tag.
     * @param {number} [auth=0] - AuthMethod tag.
     */
    static create(kex = KexMethod.CURVE25519_SHA256, auth = AuthMethod.PUBLIC_KEY) {
        return new SshBastionContext(checkSlot(lib().ssh_bastion_create(kex, auth)));
    }

    destroy() {
        if (!this._destroyed) { lib().ssh_bastion_destroy(this._slot); this._destroyed = true; }
    }

    /** @returns {number|null} */ state() {
        const tag = lib().ssh_bastion_state(this._slot); return tag <= 5 ? tag : null;
    }
    /** @returns {number|null} */ kexMethod() {
        const tag = lib().ssh_bastion_kex_method(this._slot); return tag <= 4 ? tag : null;
    }
    /** @returns {number|null} */ authMethod() {
        const tag = lib().ssh_bastion_auth_method(this._slot); return tag <= 3 ? tag : null;
    }
    /** @returns {boolean} */ canTransferData() { return lib().ssh_bastion_can_transfer(this._slot) === 1; }
    /** @returns {number|null} */ disconnectReason() {
        const tag = lib().ssh_bastion_disconnect_reason(this._slot); return tag <= 6 ? tag : null;
    }
    /** @returns {number} */ authFailures() { return lib().ssh_bastion_auth_failures(this._slot); }

    completeKex() { checkStatus(lib().ssh_bastion_complete_kex(this._slot)); }
    authenticate() { checkStatus(lib().ssh_bastion_authenticate(this._slot, 0)); }
    /** @returns {boolean} True if locked out. */
    recordAuthFailure() { return lib().ssh_bastion_record_auth_failure(this._slot) === 1; }

    /** @param {number} chType - ChannelType tag. @returns {number} Channel ID. */
    openChannel(chType) { return checkSlot(lib().ssh_bastion_open_channel(this._slot, chType)); }
    /** @param {number} chId */
    confirmChannel(chId) { checkStatus(lib().ssh_bastion_confirm_channel(this._slot, chId)); }
    /** @param {number} chId */
    closeChannel(chId) { checkStatus(lib().ssh_bastion_close_channel(this._slot, chId)); }
    /** @param {number} chId @returns {number|null} */
    channelState(chId) {
        const tag = lib().ssh_bastion_channel_state(this._slot, chId); return tag <= 2 ? tag : null;
    }
    /** @param {number} chId @returns {number|null} */
    channelType(chId) {
        const tag = lib().ssh_bastion_channel_type(this._slot, chId); return tag <= 3 ? tag : null;
    }
    /** @returns {number} */ channelCount() { return lib().ssh_bastion_channel_count(this._slot); }

    rekey() { checkStatus(lib().ssh_bastion_rekey(this._slot)); }
    /** @param {number} reason - DisconnectReason tag. */
    disconnect(reason) { checkStatus(lib().ssh_bastion_disconnect(this._slot, reason)); }

    /** @returns {number} */ auditCount() { return lib().ssh_bastion_audit_count(this._slot); }
    /** @param {number} index @returns {number|null} */
    auditEntryFrom(index) {
        const tag = lib().ssh_bastion_audit_entry(this._slot, index); return tag <= 5 ? tag : null;
    }
    /** @param {number} index @returns {number|null} */
    auditEntryTo(index) {
        const tag = lib().ssh_bastion_audit_entry_to(this._slot, index); return tag <= 5 ? tag : null;
    }

    /** @param {boolean} enabled */
    setRecording(enabled) { checkStatus(lib().ssh_bastion_set_recording(this._slot, enabled ? 1 : 0)); }
    /** @returns {boolean} */ isRecording() { return lib().ssh_bastion_is_recording(this._slot) === 1; }
}

/** @returns {number} */
export function abiVersion() { return lib().ssh_bastion_abi_version(); }

/** @param {number} from @param {number} to @returns {boolean} */
export function canTransition(from, to) {
    return lib().ssh_bastion_can_transition(from, to) === 1;
}
