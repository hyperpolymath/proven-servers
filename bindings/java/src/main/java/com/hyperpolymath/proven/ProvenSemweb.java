// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Semantic Web protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Semantic Web protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSemweb {
    private ProvenSemweb() {}

    /** RdfFormat (tags 0-5). */
    public enum RdfFormat {
        RDF_XML(0),
        TURTLE(1),
        N_TRIPLES(2),
        N_QUADS(3),
        JSON_LD(4),
        TRIG(5);

        private final int tag;
        RdfFormat(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RdfFormat fromTag(int tag) {
            for (RdfFormat v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SemwebResourceType (tags 0-4). */
    public enum SemwebResourceType {
        CLASS(0),
        PROPERTY(1),
        INDIVIDUAL(2),
        ONTOLOGY(3),
        NAMED_GRAPH(4);

        private final int tag;
        SemwebResourceType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SemwebResourceType fromTag(int tag) {
            for (SemwebResourceType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HttpMethod (tags 0-4). */
    public enum HttpMethod {
        GET(0),
        POST(1),
        PUT(2),
        PATCH(3),
        DELETE(4);

        private final int tag;
        HttpMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HttpMethod fromTag(int tag) {
            for (HttpMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ContentNegotiation (tags 0-3). */
    public enum ContentNegotiation {
        NEG_RDF_XML(0),
        NEG_TURTLE(1),
        NEG_JSON_LD(2),
        NEG_HTML(3);

        private final int tag;
        ContentNegotiation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ContentNegotiation fromTag(int tag) {
            for (ContentNegotiation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SemwebErrorCode (tags 0-4). */
    public enum SemwebErrorCode {
        NOT_FOUND(0),
        INVALID_URI(1),
        MALFORMED_RDF(2),
        UNSUPPORTED_FORMAT(3),
        CONFLICTING_TRIPLES(4);

        private final int tag;
        SemwebErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SemwebErrorCode fromTag(int tag) {
            for (SemwebErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
