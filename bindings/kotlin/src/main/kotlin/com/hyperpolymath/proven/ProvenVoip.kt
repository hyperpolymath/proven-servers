// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VoIP/SIP protocol types for proven-servers.

package com.hyperpolymath.proven

/** Method matching the Idris2 ABI tags. */
enum class Method(val tag: Int) {
    INVITE(0),
    ACK(1),
    BYE(2),
    CANCEL(3),
    REGISTER(4),
    OPTIONS(5),
    INFO(6),
    UPDATE(7),
    SUBSCRIBE(8),
    NOTIFY(9),
    REFER(10),
    MESSAGE(11),
    PRACK(12);

    companion object {
        fun fromTag(tag: Int): Method? = entries.find { it.tag == tag }
    }
}

/** ResponseCode matching the Idris2 ABI tags. */
enum class ResponseCode(val tag: Int) {
    TRYING(0),
    RINGING(1),
    SESSION_PROGRESS(2),
    OK(3),
    MULTIPLE_CHOICES(4),
    MOVED_PERMANENTLY(5),
    MOVED_TEMPORARILY(6),
    BAD_REQUEST(7),
    UNAUTHORIZED(8),
    FORBIDDEN(9),
    NOT_FOUND(10),
    METHOD_NOT_ALLOWED(11),
    REQUEST_TIMEOUT(12),
    BUSY_HERE(13),
    DECLINE(14),
    SERVER_INTERNAL_ERROR(15),
    SERVICE_UNAVAILABLE(16);

    companion object {
        fun fromTag(tag: Int): ResponseCode? = entries.find { it.tag == tag }
    }
}

/** DialogState matching the Idris2 ABI tags. */
enum class DialogState(val tag: Int) {
    EARLY(0),
    CONFIRMED(1),
    TERMINATED(2);

    companion object {
        fun fromTag(tag: Int): DialogState? = entries.find { it.tag == tag }
    }
}
