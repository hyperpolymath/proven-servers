// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SPARQL protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * SPARQL protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSparql {
    private ProvenSparql() {}

    /** SparqlQueryType (tags 0-3). */
    public enum SparqlQueryType {
        SELECT(0),
        CONSTRUCT(1),
        ASK(2),
        DESCRIBE(3);

        private final int tag;
        SparqlQueryType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SparqlQueryType fromTag(int tag) {
            for (SparqlQueryType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** UpdateType (tags 0-5). */
    public enum UpdateType {
        INSERT(0),
        DELETE(1),
        LOAD(2),
        CLEAR(3),
        CREATE(4),
        DROP(5);

        private final int tag;
        UpdateType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static UpdateType fromTag(int tag) {
            for (UpdateType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResultFormat (tags 0-3). */
    public enum ResultFormat {
        XML(0),
        JSON(1),
        CSV(2),
        TSV(3);

        private final int tag;
        ResultFormat(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResultFormat fromTag(int tag) {
            for (ResultFormat v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SparqlErrorType (tags 0-4). */
    public enum SparqlErrorType {
        PARSE_ERROR(0),
        QUERY_TIMEOUT(1),
        RESULTS_TOO_LARGE(2),
        UNKNOWN_GRAPH(3),
        ACCESS_DENIED(4);

        private final int tag;
        SparqlErrorType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SparqlErrorType fromTag(int tag) {
            for (SparqlErrorType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
