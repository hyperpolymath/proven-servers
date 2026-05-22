// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TFTP protocol types for proven-servers.

package com.hyperpolymath.proven

/** Opcode matching the Idris2 ABI tags. */
enum class Opcode(val tag: Int) {
    RRQ(0),
    WRQ(1),
    DATA(2),
    ACK(3),
    ERROR(4);

    companion object {
        fun fromTag(tag: Int): Opcode? = entries.find { it.tag == tag }
    }
}

/** TransferMode matching the Idris2 ABI tags. */
enum class TransferMode(val tag: Int) {
    NET_ASCII(0),
    OCTET(1),
    MAIL(2);

    companion object {
        fun fromTag(tag: Int): TransferMode? = entries.find { it.tag == tag }
    }
}

/** TftpError matching the Idris2 ABI tags. */
enum class TftpError(val tag: Int) {
    NOT_DEFINED(0),
    FILE_NOT_FOUND(1),
    ACCESS_VIOLATION(2),
    DISK_FULL(3),
    ILLEGAL_OPERATION(4),
    UNKNOWN_TID(5),
    FILE_EXISTS(6),
    NO_SUCH_USER(7);

    companion object {
        fun fromTag(tag: Int): TftpError? = entries.find { it.tag == tag }
    }
}

/** TransferState matching the Idris2 ABI tags. */
enum class TransferState(val tag: Int) {
    IDLE(0),
    READING(1),
    WRITING(2),
    IN_ERROR(3),
    COMPLETE(4);

    companion object {
        fun fromTag(tag: Int): TransferState? = entries.find { it.tag == tag }
    }
}
