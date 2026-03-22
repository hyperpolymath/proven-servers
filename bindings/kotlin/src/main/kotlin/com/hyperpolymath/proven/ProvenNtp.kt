// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTP protocol types for proven-servers.

package com.hyperpolymath.proven

/** LeapIndicator matching the Idris2 ABI tags. */
enum class LeapIndicator(val tag: Int) {
    NO_WARNING(0),
    LAST_MINUTE61(1),
    LAST_MINUTE59(2),
    UNSYNCHRONISED(3);

    companion object {
        fun fromTag(tag: Int): LeapIndicator? = entries.find { it.tag == tag }
    }
}

/** NtpMode matching the Idris2 ABI tags. */
enum class NtpMode(val tag: Int) {
    RESERVED(0),
    SYMMETRIC_ACTIVE(1),
    SYMMETRIC_PASSIVE(2),
    CLIENT(3),
    SERVER(4),
    BROADCAST(5),
    CONTROL_MESSAGE(6),
    PRIVATE(7);

    companion object {
        fun fromTag(tag: Int): NtpMode? = entries.find { it.tag == tag }
    }
}

/** ExchangeState matching the Idris2 ABI tags. */
enum class ExchangeState(val tag: Int) {
    IDLE(0),
    REQUEST_RECEIVED(1),
    TIMESTAMP_CALCULATED(2),
    RESPONSE_SENT(3);

    companion object {
        fun fromTag(tag: Int): ExchangeState? = entries.find { it.tag == tag }
    }
}

/** ClockDisciplineState matching the Idris2 ABI tags. */
enum class ClockDisciplineState(val tag: Int) {
    UNSET(0),
    SPIKE(1),
    FREQ(2),
    SYNC(3),
    PANIC(4);

    companion object {
        fun fromTag(tag: Int): ClockDisciplineState? = entries.find { it.tag == tag }
    }
}

/** KissCode matching the Idris2 ABI tags. */
enum class KissCode(val tag: Int) {
    DENY(0),
    RSTR(1),
    RATE(2),
    OTHER(3);

    companion object {
        fun fromTag(tag: Int): KissCode? = entries.find { it.tag == tag }
    }
}

/** NtpError matching the Idris2 ABI tags. */
enum class NtpError(val tag: Int) {
    OK(0),
    INVALID_SLOT(1),
    NOT_ACTIVE(2),
    INVALID_PACKET(3),
    KISS_OF_DEATH(4),
    STRATUM_TOO_HIGH(5);

    companion object {
        fun fromTag(tag: Int): NtpError? = entries.find { it.tag == tag }
    }
}
