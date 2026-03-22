// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PQC protocol types for proven-servers.

package com.hyperpolymath.proven

/** PqcAlgorithm matching the Idris2 ABI tags. */
enum class PqcAlgorithm(val tag: Int) {
    CRYSTALS_KYBER(0),
    CRYSTALS_DILITHIUM(1),
    FALCON(2),
    SPHINCS_PLUS(3),
    CLASSIC_MCELIECE(4),
    BIKE(5),
    HQC(6),
    FRODOKEM(7);

    companion object {
        fun fromTag(tag: Int): PqcAlgorithm? = entries.find { it.tag == tag }
    }
}

/** NistLevel matching the Idris2 ABI tags. */
enum class NistLevel(val tag: Int) {
    NIST1(0),
    NIST2(1),
    NIST3(2),
    NIST4(3),
    NIST5(4);

    companion object {
        fun fromTag(tag: Int): NistLevel? = entries.find { it.tag == tag }
    }
}

/** Operation matching the Idris2 ABI tags. */
enum class Operation(val tag: Int) {
    KEYGEN(0),
    ENCAPSULATE(1),
    DECAPSULATE(2),
    SIGN(3),
    VERIFY(4);

    companion object {
        fun fromTag(tag: Int): Operation? = entries.find { it.tag == tag }
    }
}

/** HybridMode matching the Idris2 ABI tags. */
enum class HybridMode(val tag: Int) {
    CLASSICAL_ONLY(0),
    PQC_ONLY(1),
    HYBRID(2);

    companion object {
        fun fromTag(tag: Int): HybridMode? = entries.find { it.tag == tag }
    }
}

/** AlgorithmCategory matching the Idris2 ABI tags. */
enum class AlgorithmCategory(val tag: Int) {
    KEM(0),
    SIGNATURE(1);

    companion object {
        fun fromTag(tag: Int): AlgorithmCategory? = entries.find { it.tag == tag }
    }
}

/** KeyState matching the Idris2 ABI tags. */
enum class KeyState(val tag: Int) {
    EMPTY(0),
    GENERATING(1),
    GENERATED(2),
    ACTIVE(3),
    EXPIRED(4),
    COMPROMISED(5);

    companion object {
        fun fromTag(tag: Int): KeyState? = entries.find { it.tag == tag }
    }
}
