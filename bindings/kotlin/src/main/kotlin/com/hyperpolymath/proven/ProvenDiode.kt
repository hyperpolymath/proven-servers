// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Data Diode protocol types for proven-servers.

package com.hyperpolymath.proven

/** Direction matching the Idris2 ABI tags. */
enum class Direction(val tag: Int) {
    HIGH_TO_LOW(0),
    LOW_TO_HIGH(1);

    companion object {
        fun fromTag(tag: Int): Direction? = entries.find { it.tag == tag }
    }
}

/** DiodeProtocol matching the Idris2 ABI tags. */
enum class DiodeProtocol(val tag: Int) {
    UDP(0),
    TCP(1),
    FILE_TRANSFER(2),
    SYSLOG(3),
    SNMP(4);

    companion object {
        fun fromTag(tag: Int): DiodeProtocol? = entries.find { it.tag == tag }
    }
}

/** TransferState matching the Idris2 ABI tags. */
enum class TransferState(val tag: Int) {
    QUEUED(0),
    SENDING(1),
    CONFIRMING(2),
    COMPLETE(3),
    FAILED(4);

    companion object {
        fun fromTag(tag: Int): TransferState? = entries.find { it.tag == tag }
    }
}

/** ValidationResult matching the Idris2 ABI tags. */
enum class ValidationResult(val tag: Int) {
    PASSED(0),
    FORMAT_ERROR(1),
    SIZE_EXCEEDED(2),
    POLICY_BLOCKED(3);

    companion object {
        fun fromTag(tag: Int): ValidationResult? = entries.find { it.tag == tag }
    }
}

/** IntegrityCheck matching the Idris2 ABI tags. */
enum class IntegrityCheck(val tag: Int) {
    CRC32(0),
    SHA256(1),
    HMAC(2);

    companion object {
        fun fromTag(tag: Int): IntegrityCheck? = entries.find { it.tag == tag }
    }
}

/** GatewayState matching the Idris2 ABI tags. */
enum class GatewayState(val tag: Int) {
    IDLE(0),
    CONFIGURED(1),
    TRANSFERRING(2),
    VALIDATING(3),
    SHUTDOWN(4);

    companion object {
        fun fromTag(tag: Int): GatewayState? = entries.find { it.tag == tag }
    }
}
