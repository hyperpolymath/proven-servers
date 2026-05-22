// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CardDAV protocol types for proven-servers.

package com.hyperpolymath.proven

/** PropertyType matching the Idris2 ABI tags. */
enum class PropertyType(val tag: Int) {
    FN_NAME(0),
    N(1),
    EMAIL(2),
    TEL(3),
    ADR(4),
    ORG(5),
    PHOTO(6),
    URL(7),
    NOTE(8);

    companion object {
        fun fromTag(tag: Int): PropertyType? = entries.find { it.tag == tag }
    }
}

/** CardMethod matching the Idris2 ABI tags. */
enum class CardMethod(val tag: Int) {
    GET(0),
    PUT(1),
    DELETE(2),
    PROPFIND(3),
    PROPPATCH(4),
    REPORT(5),
    MKCOL(6);

    companion object {
        fun fromTag(tag: Int): CardMethod? = entries.find { it.tag == tag }
    }
}

/** VCardVersion matching the Idris2 ABI tags. */
enum class VCardVersion(val tag: Int) {
    VCARD3(0),
    VCARD4(1);

    companion object {
        fun fromTag(tag: Int): VCardVersion? = entries.find { it.tag == tag }
    }
}

/** CardError matching the Idris2 ABI tags. */
enum class CardError(val tag: Int) {
    VALID_ADDRESS_DATA(0),
    NO_RESOURCE_TYPE(1),
    MAX_RESOURCE_SIZE(2),
    UID_CONFLICT(3),
    SUPPORTED_ADDRESS_DATA(4),
    PRECONDITION_FAILED(5);

    companion object {
        fun fromTag(tag: Int): CardError? = entries.find { it.tag == tag }
    }
}

/** ServerState matching the Idris2 ABI tags. */
enum class ServerState(val tag: Int) {
    IDLE(0),
    BOUND(1),
    SERVING(2),
    SHUTDOWN(3);

    companion object {
        fun fromTag(tag: Int): ServerState? = entries.find { it.tag == tag }
    }
}
