// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SPARQL protocol types for proven-servers.

package com.hyperpolymath.proven

/** SparqlQueryType matching the Idris2 ABI tags. */
enum class SparqlQueryType(val tag: Int) {
    SELECT(0),
    CONSTRUCT(1),
    ASK(2),
    DESCRIBE(3);

    companion object {
        fun fromTag(tag: Int): SparqlQueryType? = entries.find { it.tag == tag }
    }
}

/** UpdateType matching the Idris2 ABI tags. */
enum class UpdateType(val tag: Int) {
    INSERT(0),
    DELETE(1),
    LOAD(2),
    CLEAR(3),
    CREATE(4),
    DROP(5);

    companion object {
        fun fromTag(tag: Int): UpdateType? = entries.find { it.tag == tag }
    }
}

/** ResultFormat matching the Idris2 ABI tags. */
enum class ResultFormat(val tag: Int) {
    XML(0),
    JSON(1),
    CSV(2),
    TSV(3);

    companion object {
        fun fromTag(tag: Int): ResultFormat? = entries.find { it.tag == tag }
    }
}

/** SparqlErrorType matching the Idris2 ABI tags. */
enum class SparqlErrorType(val tag: Int) {
    PARSE_ERROR(0),
    QUERY_TIMEOUT(1),
    RESULTS_TOO_LARGE(2),
    UNKNOWN_GRAPH(3),
    ACCESS_DENIED(4);

    companion object {
        fun fromTag(tag: Int): SparqlErrorType? = entries.find { it.tag == tag }
    }
}
