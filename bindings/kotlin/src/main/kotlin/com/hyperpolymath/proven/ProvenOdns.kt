// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ODNS protocol types for proven-servers.

package com.hyperpolymath.proven

/** Role matching the Idris2 ABI tags. */
enum class Role(val tag: Int) {
    CLIENT(0),
    PROXY(1),
    TARGET(2);

    companion object {
        fun fromTag(tag: Int): Role? = entries.find { it.tag == tag }
    }
}

/** OdnsMessageType matching the Idris2 ABI tags. */
enum class OdnsMessageType(val tag: Int) {
    QUERY(0),
    RESPONSE(1);

    companion object {
        fun fromTag(tag: Int): OdnsMessageType? = entries.find { it.tag == tag }
    }
}

/** OdnsErrorReason matching the Idris2 ABI tags. */
enum class OdnsErrorReason(val tag: Int) {
    PROXY_ERROR(0),
    TARGET_ERROR(1),
    DECRYPTION_FAILED(2),
    INVALID_CONFIG(3),
    PAYLOAD_TOO_LARGE(4);

    companion object {
        fun fromTag(tag: Int): OdnsErrorReason? = entries.find { it.tag == tag }
    }
}

/** EncapsulationFormat matching the Idris2 ABI tags. */
enum class EncapsulationFormat(val tag: Int) {
    HPKE(0);

    companion object {
        fun fromTag(tag: Int): EncapsulationFormat? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    KEY_EXCHANGE(1),
    READY(2),
    PROCESSING(3),
    CLOSING(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
