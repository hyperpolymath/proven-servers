// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Air Gap protocol types for proven-servers.

package com.hyperpolymath.proven

/** TransferDirection matching the Idris2 ABI tags. */
enum class TransferDirection(val tag: Int) {
    IMPORT(0),
    EXPORT(1);

    companion object {
        fun fromTag(tag: Int): TransferDirection? = entries.find { it.tag == tag }
    }
}

/** MediaType matching the Idris2 ABI tags. */
enum class MediaType(val tag: Int) {
    USB(0),
    OPTICAL_DISC(1),
    TAPE_CARTRIDGE(2),
    DIODE_LINK(3);

    companion object {
        fun fromTag(tag: Int): MediaType? = entries.find { it.tag == tag }
    }
}

/** ScanResult matching the Idris2 ABI tags. */
enum class ScanResult(val tag: Int) {
    CLEAN(0),
    SUSPICIOUS(1),
    MALICIOUS(2),
    UNSCANNABLE(3);

    companion object {
        fun fromTag(tag: Int): ScanResult? = entries.find { it.tag == tag }
    }
}

/** TransferState matching the Idris2 ABI tags. */
enum class TransferState(val tag: Int) {
    PENDING(0),
    SCANNING(1),
    APPROVED(2),
    REJECTED(3),
    IN_PROGRESS(4),
    COMPLETE(5),
    FAILED(6);

    companion object {
        fun fromTag(tag: Int): TransferState? = entries.find { it.tag == tag }
    }
}

/** ValidationCheck matching the Idris2 ABI tags. */
enum class ValidationCheck(val tag: Int) {
    HASH_VERIFY(0),
    SIGNATURE_VERIFY(1),
    FORMAT_CHECK(2),
    CONTENT_INSPECTION(3),
    MALWARE_SCAN(4);

    companion object {
        fun fromTag(tag: Int): ValidationCheck? = entries.find { it.tag == tag }
    }
}
