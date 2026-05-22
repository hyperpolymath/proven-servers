// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Load Balancer protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Load Balancer protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenLoadbalancer {
    private ProvenLoadbalancer() {}

    /** Algorithm (tags 0-5). */
    public enum Algorithm {
        ROUND_ROBIN(0),
        LEAST_CONNECTIONS(1),
        IP_HASH(2),
        RANDOM(3),
        WEIGHTED_ROUND_ROBIN(4),
        LEAST_RESPONSE_TIME(5);

        private final int tag;
        Algorithm(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Algorithm fromTag(int tag) {
            for (Algorithm v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HealthCheckType (tags 0-3). */
    public enum HealthCheckType {
        HTTP(0),
        TCP(1),
        GRPC(2),
        SCRIPT(3);

        private final int tag;
        HealthCheckType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HealthCheckType fromTag(int tag) {
            for (HealthCheckType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** BackendState (tags 0-3). */
    public enum BackendState {
        HEALTHY(0),
        UNHEALTHY(1),
        DRAINING(2),
        DISABLED(3);

        private final int tag;
        BackendState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static BackendState fromTag(int tag) {
            for (BackendState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionPersistence (tags 0-3). */
    public enum SessionPersistence {
        NONE(0),
        COOKIE(1),
        SOURCE_IP(2),
        HEADER(3);

        private final int tag;
        SessionPersistence(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionPersistence fromTag(int tag) {
            for (SessionPersistence v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** LbProtocol (tags 0-4). */
    public enum LbProtocol {
        HTTP(0),
        HTTPS(1),
        TCP(2),
        UDP(3),
        GRPC(4);

        private final int tag;
        LbProtocol(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LbProtocol fromTag(int tag) {
            for (LbProtocol v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
