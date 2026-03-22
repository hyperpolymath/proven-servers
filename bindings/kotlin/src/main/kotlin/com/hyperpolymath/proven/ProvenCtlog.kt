// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CT Log protocol types for proven-servers.

package com.hyperpolymath.proven

/** LogEntryType matching the Idris2 ABI tags. */
enum class LogEntryType(val tag: Int) {
    X509_ENTRY(0),
    PRECERT_ENTRY(1);

    companion object {
        fun fromTag(tag: Int): LogEntryType? = entries.find { it.tag == tag }
    }
}

/** SignatureType matching the Idris2 ABI tags. */
enum class SignatureType(val tag: Int) {
    CERTIFICATE_TIMESTAMP(0),
    TREE_HASH(1);

    companion object {
        fun fromTag(tag: Int): SignatureType? = entries.find { it.tag == tag }
    }
}

/** MerkleLeafType matching the Idris2 ABI tags. */
enum class MerkleLeafType(val tag: Int) {
    TIMESTAMPED_ENTRY(0);

    companion object {
        fun fromTag(tag: Int): MerkleLeafType? = entries.find { it.tag == tag }
    }
}

/** SubmissionStatus matching the Idris2 ABI tags. */
enum class SubmissionStatus(val tag: Int) {
    ACCEPTED(0),
    DUPLICATE(1),
    RATE_LIMITED(2),
    REJECTED(3),
    INVALID_CHAIN(4),
    UNKNOWN_ANCHOR(5);

    companion object {
        fun fromTag(tag: Int): SubmissionStatus? = entries.find { it.tag == tag }
    }
}

/** VerificationResult matching the Idris2 ABI tags. */
enum class VerificationResult(val tag: Int) {
    VALID_PROOF(0),
    INVALID_PROOF(1),
    INCONSISTENT_TREE(2),
    STALE_STH(3);

    companion object {
        fun fromTag(tag: Int): VerificationResult? = entries.find { it.tag == tag }
    }
}

/** ServerState matching the Idris2 ABI tags. */
enum class ServerState(val tag: Int) {
    IDLE(0),
    ACTIVE(1),
    MERGING(2),
    SIGNING(3),
    SHUTDOWN(4);

    companion object {
        fun fromTag(tag: Int): ServerState? = entries.find { it.tag == tag }
    }
}
