// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Graph DB protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Graph DB protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenGraphdb {
    private ProvenGraphdb() {}

    /** ElementType (tags 0-4). */
    public enum ElementType {
        NODE(0),
        EDGE(1),
        PROPERTY(2),
        LABEL(3),
        INDEX(4);

        private final int tag;
        ElementType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ElementType fromTag(int tag) {
            for (ElementType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** QueryLanguage (tags 0-3). */
    public enum QueryLanguage {
        CYPHER(0),
        GREMLIN(1),
        SPARQL(2),
        GRAPH_QL(3);

        private final int tag;
        QueryLanguage(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static QueryLanguage fromTag(int tag) {
            for (QueryLanguage v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TraversalStrategy (tags 0-4). */
    public enum TraversalStrategy {
        BFS(0),
        DFS(1),
        DIJKSTRA(2),
        A_STAR(3),
        RANDOM(4);

        private final int tag;
        TraversalStrategy(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TraversalStrategy fromTag(int tag) {
            for (TraversalStrategy v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Consistency (tags 0-3). */
    public enum Consistency {
        STRONG(0),
        EVENTUAL(1),
        SESSION(2),
        CAUSAL(3);

        private final int tag;
        Consistency(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Consistency fromTag(int tag) {
            for (Consistency v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorCode (tags 0-6). */
    public enum ErrorCode {
        SYNTAX_ERROR(0),
        NODE_NOT_FOUND(1),
        EDGE_NOT_FOUND(2),
        CONSTRAINT_VIOLATION(3),
        INDEX_EXISTS(4),
        TRANSACTION_CONFLICT(5),
        OUT_OF_MEMORY(6);

        private final int tag;
        ErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorCode fromTag(int tag) {
            for (ErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        CONNECTED(1),
        QUERYING(2),
        TRAVERSING(3),
        DISCONNECTING(4);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
