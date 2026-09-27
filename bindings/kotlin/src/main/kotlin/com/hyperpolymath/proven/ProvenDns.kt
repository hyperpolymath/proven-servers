// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kotlin/JNI bindings for the bounded proven-dns message-builder FFI.
// Only exact 17-byte standard queries with one root-name question are accepted;
// responses are capped at 512 bytes. DNSSEC cryptographic operations fail closed.
// Enum classes match Idris2 ABI tags exactly (DnsABI.Layout).

package com.hyperpolymath.proven

/**
 * Kotlin bindings for the bounded proven DNS message-builder FFI.
 *
 * Bounded message builder, not a general resolver. DNSSEC key loading, signing,
 * and validation are unavailable; exposed DNSSEC transitions are model tags only.
 *
 * @author Jonathan D.A. Jewell
 */
public class ProvenDns private constructor(private val slot: Int) : AutoCloseable {

    /** DNS query lifecycle states (tags 0-4). */
    public enum class State(public val tag: Int) {
        IDLE(0), QUERY_RECEIVED(1), LOOKUP(2), RESPONSE_BUILDING(3), SENT(4);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): State? = entries.find { it.tag == tag }
        }
    }

    /** DNSSEC states (tags 0-3). */
    public enum class DnssecState(public val tag: Int) {
        DISABLED(0), ENABLED(1), KEY_LOADED(2), VALIDATED(3);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): DnssecState? = entries.find { it.tag == tag }
        }
    }

    /** DNSSEC signing algorithms (tags 0-4). */
    public enum class DnssecAlgorithm(public val tag: Int) {
        RSA_SHA256(0), RSA_SHA512(1), ECDSA_P256_SHA256(2), ECDSA_P384_SHA384(3), ED25519(4);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): DnssecAlgorithm? = entries.find { it.tag == tag }
        }
    }

    private companion object {
        @JvmStatic external fun dns_abi_version(): Int
        @JvmStatic external fun dns_create_context(): Int
        @JvmStatic external fun dns_destroy_context(slot: Int)
        @JvmStatic external fun dns_state(slot: Int): Int
        @JvmStatic external fun dns_dnssec_state(slot: Int): Int
        @JvmStatic external fun dns_rcode(slot: Int): Int
        @JvmStatic external fun dns_answer_count(slot: Int): Int
        @JvmStatic external fun dns_authority_count(slot: Int): Int
        @JvmStatic external fun dns_additional_count(slot: Int): Int
        @JvmStatic external fun dns_query_rtype(slot: Int): Int
        @JvmStatic external fun dns_query_class(slot: Int): Int
        @JvmStatic external fun dns_parse_query(slot: Int, buf: ByteArray, len: Int): Int
        @JvmStatic external fun dns_begin_lookup(slot: Int): Int
        @JvmStatic external fun dns_begin_response(slot: Int): Int
        @JvmStatic external fun dns_add_answer(slot: Int, rtype: Int, rclass: Int, ttl: Int, rdata: ByteArray, rdlen: Int): Int
        @JvmStatic external fun dns_add_authority(slot: Int, rtype: Int, rclass: Int, ttl: Int, rdata: ByteArray, rdlen: Int): Int
        @JvmStatic external fun dns_add_additional(slot: Int, rtype: Int, rclass: Int, ttl: Int, rdata: ByteArray, rdlen: Int): Int
        @JvmStatic external fun dns_set_rcode(slot: Int, rcodeTag: Int): Int
        @JvmStatic external fun dns_build_response(slot: Int, out: ByteArray, outLen: IntArray): Int
        @JvmStatic external fun dns_enable_dnssec(slot: Int): Int
        @JvmStatic external fun dns_load_dnssec_key(slot: Int, algo: Int): Int
        @JvmStatic external fun dns_sign_response(slot: Int): Int
        @JvmStatic external fun dns_validate_dnssec(slot: Int): Int
        @JvmStatic external fun dns_can_transition(from: Int, to: Int): Int
        @JvmStatic external fun dns_can_dnssec_transition(from: Int, to: Int): Int
    }

    override fun close() { dns_destroy_context(slot) }

    public val state: State? get() = State.fromTag(dns_state(slot))
    public val dnssecState: DnssecState? get() = DnssecState.fromTag(dns_dnssec_state(slot))
    public val rcode: Int get() = dns_rcode(slot)
    public val answerCount: Int get() = dns_answer_count(slot)
    public val authorityCount: Int get() = dns_authority_count(slot)
    public val additionalCount: Int get() = dns_additional_count(slot)
    public val queryRtype: Int get() = dns_query_rtype(slot)
    public val queryClass: Int get() = dns_query_class(slot)

    /** Parse only the exact 17-byte standard root-question query subset. */
    public fun parseQuery(data: ByteArray): Result<Unit> = ProvenError.runCatching {
        require(data.size == 17) { "DNS query must be exactly 17 bytes" }
        ProvenError.checkStatus(dns_parse_query(slot, data, 17))
    }

    /** Begin DNS lookup. Transitions QueryReceived -> Lookup. */
    public fun beginLookup(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(dns_begin_lookup(slot))
    }

    /** Begin building the response. Transitions Lookup -> ResponseBuilding. */
    public fun beginResponse(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(dns_begin_response(slot))
    }

    /** Add a resource record to the answer section. */
    public fun addAnswer(rtype: Int, rclass: Int, ttl: Int, rdata: ByteArray): Result<Unit> = ProvenError.runCatching {
        require(rdata.size <= 256) { "DNS RDATA must be at most 256 bytes" }
        ProvenError.checkStatus(dns_add_answer(slot, rtype, rclass, ttl, rdata, rdata.size))
    }

    /** Add a resource record to the authority section. */
    public fun addAuthority(rtype: Int, rclass: Int, ttl: Int, rdata: ByteArray): Result<Unit> = ProvenError.runCatching {
        require(rdata.size <= 256) { "DNS RDATA must be at most 256 bytes" }
        ProvenError.checkStatus(dns_add_authority(slot, rtype, rclass, ttl, rdata, rdata.size))
    }

    /** Add a resource record to the additional section. */
    public fun addAdditional(rtype: Int, rclass: Int, ttl: Int, rdata: ByteArray): Result<Unit> = ProvenError.runCatching {
        require(rdata.size <= 256) { "DNS RDATA must be at most 256 bytes" }
        ProvenError.checkStatus(dns_add_additional(slot, rtype, rclass, ttl, rdata, rdata.size))
    }

    /** Set the response code (RCODE). */
    public fun setRcode(rcodeTag: Int): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(dns_set_rcode(slot, rcodeTag))
    }

    /** Build a root-question response; output is capped at 512 bytes. */
    public fun buildResponse(): Result<ByteArray> = ProvenError.runCatching {
        val buf = ByteArray(65536)
        val outLen = IntArray(1)
        ProvenError.checkStatus(dns_build_response(slot, buf, outLen))
        buf.copyOf(outLen[0])
    }

    /** Enable mode only; response construction then rejects because no signer exists. */
    public fun enableDnssec(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(dns_enable_dnssec(slot))
    }

    /** Always fails closed: the ABI accepts no private-key material. */
    public fun loadDnssecKey(algorithm: DnssecAlgorithm): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(dns_load_dnssec_key(slot, algorithm.tag))
    }

    /** Always fails closed because no DNSSEC signing backend exists. */
    public fun signResponse(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(dns_sign_response(slot))
    }

    /** Always false because no DNSSEC validator exists. */
    public val isDnssecValid: Boolean get() = dns_validate_dnssec(slot) == 0

    public companion object {
        @JvmStatic public fun create(): Result<ProvenDns> = ProvenError.runCatching {
            ProvenDns(ProvenError.checkSlot(dns_create_context()))
        }

        @JvmStatic public fun abiVersion(): Int = dns_abi_version()

        @JvmStatic public fun canTransition(from: State, to: State): Boolean =
            dns_can_transition(from.tag, to.tag) == 1

        @JvmStatic public fun canDnssecTransition(from: DnssecState, to: DnssecState): Boolean =
            dns_can_dnssec_transition(from.tag, to.tag) == 1
    }
}
