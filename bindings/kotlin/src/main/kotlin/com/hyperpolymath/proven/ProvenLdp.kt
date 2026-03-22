// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDP protocol types for proven-servers.

package com.hyperpolymath.proven

/** ContainerType matching the Idris2 ABI tags. */
enum class ContainerType(val tag: Int) {
    BASIC(0),
    DIRECT(1),
    INDIRECT(2);

    companion object {
        fun fromTag(tag: Int): ContainerType? = entries.find { it.tag == tag }
    }
}

/** LdpResourceType matching the Idris2 ABI tags. */
enum class LdpResourceType(val tag: Int) {
    RDF_SOURCE(0),
    NON_RDF_SOURCE(1),
    CONTAINER(2);

    companion object {
        fun fromTag(tag: Int): LdpResourceType? = entries.find { it.tag == tag }
    }
}

/** Preference matching the Idris2 ABI tags. */
enum class Preference(val tag: Int) {
    MINIMAL_CONTAINER(0),
    INCLUDE_CONTAINMENT(1),
    INCLUDE_MEMBERSHIP(2),
    OMIT_CONTAINMENT(3),
    OMIT_MEMBERSHIP(4);

    companion object {
        fun fromTag(tag: Int): Preference? = entries.find { it.tag == tag }
    }
}

/** InteractionModel matching the Idris2 ABI tags. */
enum class InteractionModel(val tag: Int) {
    LDPR(0),
    LDPC(1),
    LDP_BASIC_CONTAINER(2),
    LDP_DIRECT_CONTAINER(3),
    LDP_INDIRECT_CONTAINER(4);

    companion object {
        fun fromTag(tag: Int): InteractionModel? = entries.find { it.tag == tag }
    }
}

/** ConstraintViolation matching the Idris2 ABI tags. */
enum class ConstraintViolation(val tag: Int) {
    MEMBERSHIP_CONSTANT(0),
    CONTAINS_TRIPLES_MODIFIED(1),
    SERVER_MANAGED(2),
    TYPE_CONFLICT(3);

    companion object {
        fun fromTag(tag: Int): ConstraintViolation? = entries.find { it.tag == tag }
    }
}
