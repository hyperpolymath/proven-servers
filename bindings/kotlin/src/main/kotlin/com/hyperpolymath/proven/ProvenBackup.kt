// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Backup protocol types for proven-servers.

package com.hyperpolymath.proven

/** BackupType matching the Idris2 ABI tags. */
enum class BackupType(val tag: Int) {
    FULL(0),
    INCREMENTAL(1),
    DIFFERENTIAL(2),
    SNAPSHOT(3),
    MIRROR(4);

    companion object {
        fun fromTag(tag: Int): BackupType? = entries.find { it.tag == tag }
    }
}

/** ScheduleFreq matching the Idris2 ABI tags. */
enum class ScheduleFreq(val tag: Int) {
    HOURLY(0),
    DAILY(1),
    WEEKLY(2),
    MONTHLY(3),
    ON_DEMAND(4);

    companion object {
        fun fromTag(tag: Int): ScheduleFreq? = entries.find { it.tag == tag }
    }
}

/** CompressionAlg matching the Idris2 ABI tags. */
enum class CompressionAlg(val tag: Int) {
    NONE(0),
    GZIP(1),
    ZSTD(2),
    LZ4(3),
    XZ(4);

    companion object {
        fun fromTag(tag: Int): CompressionAlg? = entries.find { it.tag == tag }
    }
}

/** EncryptionAlg matching the Idris2 ABI tags. */
enum class EncryptionAlg(val tag: Int) {
    NO_ENCRYPTION(0),
    AES256_GCM(1),
    CHA_CHA20_POLY1305(2);

    companion object {
        fun fromTag(tag: Int): EncryptionAlg? = entries.find { it.tag == tag }
    }
}

/** BackupState matching the Idris2 ABI tags. */
enum class BackupState(val tag: Int) {
    IDLE(0),
    RUNNING(1),
    VERIFYING(2),
    COMPLETE(3),
    FAILED(4),
    CANCELLED(5);

    companion object {
        fun fromTag(tag: Int): BackupState? = entries.find { it.tag == tag }
    }
}

/** RetentionPolicy matching the Idris2 ABI tags. */
enum class RetentionPolicy(val tag: Int) {
    KEEP_ALL(0),
    KEEP_LAST(1),
    KEEP_DAILY(2),
    KEEP_WEEKLY(3),
    KEEP_MONTHLY(4);

    companion object {
        fun fromTag(tag: Int): RetentionPolicy? = entries.find { it.tag == tag }
    }
}
