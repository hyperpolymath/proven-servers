// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// JavaScript bindings for the proven-dns Zig FFI.

import { checkSlot, checkStatus } from "./error.js";
import { loadLibrary } from "./ffi.js";

/** @readonly @enum {number} DNS query lifecycle states. */
export const DnsState = Object.freeze({
    IDLE: 0, QUERY_RECEIVED: 1, LOOKUP: 2, RESPONSE_BUILDING: 3, SENT: 4,
});

/** @readonly @enum {number} DNSSEC states. */
export const DnssecState = Object.freeze({
    DISABLED: 0, ENABLED: 1, KEY_LOADED: 2, VALIDATED: 3,
});

/** @readonly @enum {number} DNSSEC signing algorithms. */
export const DnssecAlgorithm = Object.freeze({
    RSA_SHA256: 0, RSA_SHA512: 1, ECDSA_P256_SHA256: 2,
    ECDSA_P384_SHA384: 3, ED25519: 4,
});

/** @type {object|null} */
let _lib = null;

/** @param {object} [options] */
export async function init(options) {
    if (!_lib) _lib = await loadLibrary("dns", options);
}

function lib() {
    if (!_lib) throw new Error("dns: call init() before using the module");
    return _lib;
}

/**
 * DNS query/response context wrapping a Zig FFI slot.
 */
export class DnsContext {
    /** @param {number} slot */
    constructor(slot) {
        this._slot = slot;
        this._destroyed = false;
    }

    static create() {
        return new DnsContext(checkSlot(lib().dns_create_context()));
    }

    destroy() {
        if (!this._destroyed) {
            lib().dns_destroy_context(this._slot);
            this._destroyed = true;
        }
    }

    /** @returns {number|null} DnsState tag. */
    state() {
        const tag = lib().dns_state(this._slot);
        return tag <= 4 ? tag : null;
    }

    /** @returns {number|null} DnssecState tag. */
    dnssecState() {
        const tag = lib().dns_dnssec_state(this._slot);
        return tag <= 3 ? tag : null;
    }

    /** @returns {number} Response code tag. */
    rcode() { return lib().dns_rcode(this._slot); }

    /** @returns {number} */ answerCount() { return lib().dns_answer_count(this._slot); }
    /** @returns {number} */ authorityCount() { return lib().dns_authority_count(this._slot); }
    /** @returns {number} */ additionalCount() { return lib().dns_additional_count(this._slot); }
    /** @returns {number} */ queryRtype() { return lib().dns_query_rtype(this._slot); }
    /** @returns {number} */ queryClass() { return lib().dns_query_class(this._slot); }

    /** @param {Uint8Array} data */
    parseQuery(data) {
        checkStatus(lib().dns_parse_query(this._slot, data, data.length));
    }

    beginLookup() { checkStatus(lib().dns_begin_lookup(this._slot)); }
    beginResponse() { checkStatus(lib().dns_begin_response(this._slot)); }

    /**
     * @param {number} rtype
     * @param {number} rclass
     * @param {number} ttl
     * @param {Uint8Array} rdata
     */
    addAnswer(rtype, rclass, ttl, rdata) {
        checkStatus(lib().dns_add_answer(this._slot, rtype, rclass, ttl, rdata, rdata.length));
    }

    /** @param {number} rtype @param {number} rclass @param {number} ttl @param {Uint8Array} rdata */
    addAuthority(rtype, rclass, ttl, rdata) {
        checkStatus(lib().dns_add_authority(this._slot, rtype, rclass, ttl, rdata, rdata.length));
    }

    /** @param {number} rtype @param {number} rclass @param {number} ttl @param {Uint8Array} rdata */
    addAdditional(rtype, rclass, ttl, rdata) {
        checkStatus(lib().dns_add_additional(this._slot, rtype, rclass, ttl, rdata, rdata.length));
    }

    /** @param {number} rcodeTag */
    setRcode(rcodeTag) { checkStatus(lib().dns_set_rcode(this._slot, rcodeTag)); }

    /**
     * Build the DNS response. Transitions ResponseBuilding -> Sent.
     * @param {number} [maxLen=512]
     * @returns {Uint8Array} Serialized DNS response.
     */
    buildResponse(maxLen = 512) {
        const buf = new Uint8Array(maxLen);
        const outLen = new Uint16Array(1);
        checkStatus(lib().dns_build_response(this._slot, buf, outLen));
        return buf.subarray(0, outLen[0]);
    }

    enableDnssec() { checkStatus(lib().dns_enable_dnssec(this._slot)); }

    /** @param {number} algo - DnssecAlgorithm tag. */
    loadDnssecKey(algo) { checkStatus(lib().dns_load_dnssec_key(this._slot, algo)); }

    signResponse() { checkStatus(lib().dns_sign_response(this._slot)); }

    /** @returns {boolean} */
    validateDnssec() { return lib().dns_validate_dnssec(this._slot) === 0; }
}

/** @returns {number} */
export function abiVersion() { return lib().dns_abi_version(); }

/** @param {number} from @param {number} to @returns {boolean} */
export function canTransition(from, to) {
    return lib().dns_can_transition(from, to) === 1;
}

/** @param {number} from @param {number} to @returns {boolean} */
export function canDnssecTransition(from, to) {
    return lib().dns_can_dnssec_transition(from, to) === 1;
}
