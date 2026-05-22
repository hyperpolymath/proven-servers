// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Semantic Web protocol types for proven-servers.

package com.hyperpolymath.proven

/** RdfFormat matching the Idris2 ABI tags. */
enum class RdfFormat(val tag: Int) {
    RDF_XML(0),
    TURTLE(1),
    N_TRIPLES(2),
    N_QUADS(3),
    JSON_LD(4),
    TRIG(5);

    companion object {
        fun fromTag(tag: Int): RdfFormat? = entries.find { it.tag == tag }
    }
}

/** SemwebResourceType matching the Idris2 ABI tags. */
enum class SemwebResourceType(val tag: Int) {
    CLASS(0),
    PROPERTY(1),
    INDIVIDUAL(2),
    ONTOLOGY(3),
    NAMED_GRAPH(4);

    companion object {
        fun fromTag(tag: Int): SemwebResourceType? = entries.find { it.tag == tag }
    }
}

/** HttpMethod matching the Idris2 ABI tags. */
enum class HttpMethod(val tag: Int) {
    GET(0),
    POST(1),
    PUT(2),
    PATCH(3),
    DELETE(4);

    companion object {
        fun fromTag(tag: Int): HttpMethod? = entries.find { it.tag == tag }
    }
}

/** ContentNegotiation matching the Idris2 ABI tags. */
enum class ContentNegotiation(val tag: Int) {
    NEG_RDF_XML(0),
    NEG_TURTLE(1),
    NEG_JSON_LD(2),
    NEG_HTML(3);

    companion object {
        fun fromTag(tag: Int): ContentNegotiation? = entries.find { it.tag == tag }
    }
}

/** SemwebErrorCode matching the Idris2 ABI tags. */
enum class SemwebErrorCode(val tag: Int) {
    NOT_FOUND(0),
    INVALID_URI(1),
    MALFORMED_RDF(2),
    UNSUPPORTED_FORMAT(3),
    CONFLICTING_TRIPLES(4);

    companion object {
        fun fromTag(tag: Int): SemwebErrorCode? = entries.find { it.tag == tag }
    }
}
