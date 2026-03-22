// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Triplestore protocol types for proven-servers.

package com.hyperpolymath.proven

/** Statement matching the Idris2 ABI tags. */
enum class Statement(val tag: Int) {
    TRIPLE(0),
    QUAD(1);

    companion object {
        fun fromTag(tag: Int): Statement? = entries.find { it.tag == tag }
    }
}

/** IndexOrder matching the Idris2 ABI tags. */
enum class IndexOrder(val tag: Int) {
    SPO(0),
    POS(1),
    OSP(2),
    GSPO(3),
    GPOS(4),
    GOSP(5);

    companion object {
        fun fromTag(tag: Int): IndexOrder? = entries.find { it.tag == tag }
    }
}

/** StorageBackend matching the Idris2 ABI tags. */
enum class StorageBackend(val tag: Int) {
    IN_MEMORY(0),
    B_TREE(1),
    LSM(2),
    PERSISTENT(3);

    companion object {
        fun fromTag(tag: Int): StorageBackend? = entries.find { it.tag == tag }
    }
}

/** ImportFormat matching the Idris2 ABI tags. */
enum class ImportFormat(val tag: Int) {
    N_TRIPLES(0),
    TURTLE(1),
    RDF_XML(2),
    JSON_LD(3),
    N_QUADS(4),
    TRIG(5);

    companion object {
        fun fromTag(tag: Int): ImportFormat? = entries.find { it.tag == tag }
    }
}

/** TransactionIsolation matching the Idris2 ABI tags. */
enum class TransactionIsolation(val tag: Int) {
    READ_COMMITTED(0),
    SERIALIZABLE(1),
    SNAPSHOT(2);

    companion object {
        fun fromTag(tag: Int): TransactionIsolation? = entries.find { it.tag == tag }
    }
}

/** StoreState matching the Idris2 ABI tags. */
enum class StoreState(val tag: Int) {
    IDLE(0),
    READY(1),
    IN_TRANSACTION(2),
    IMPORTING(3),
    CLOSING(4);

    companion object {
        fun fromTag(tag: Int): StoreState? = entries.find { it.tag == tag }
    }
}
