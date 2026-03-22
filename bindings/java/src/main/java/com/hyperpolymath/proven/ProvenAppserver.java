// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// App Server protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * App Server protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenAppserver {
    private ProvenAppserver() {}

    /** RequestType (tags 0-3). */
    public enum RequestType {
        HTTP(0),
        WEB_SOCKET(1),
        GRPC(2),
        GRAPH_QL(3);

        private final int tag;
        RequestType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RequestType fromTag(int tag) {
            for (RequestType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** LifecycleState (tags 0-5). */
    public enum LifecycleState {
        INITIALIZING(0),
        STARTING(1),
        RUNNING(2),
        DRAINING(3),
        STOPPING(4),
        STOPPED(5);

        private final int tag;
        LifecycleState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LifecycleState fromTag(int tag) {
            for (LifecycleState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HealthCheck (tags 0-2). */
    public enum HealthCheck {
        LIVENESS(0),
        READINESS(1),
        STARTUP(2);

        private final int tag;
        HealthCheck(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HealthCheck fromTag(int tag) {
            for (HealthCheck v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DeployStrategy (tags 0-3). */
    public enum DeployStrategy {
        ROLLING_UPDATE(0),
        BLUE_GREEN(1),
        CANARY(2),
        RECREATE(3);

        private final int tag;
        DeployStrategy(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DeployStrategy fromTag(int tag) {
            for (DeployStrategy v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorCategory (tags 0-4). */
    public enum ErrorCategory {
        CLIENT_ERROR(0),
        SERVER_ERROR(1),
        TIMEOUT(2),
        CIRCUIT_OPEN(3),
        RATE_LIMITED(4);

        private final int tag;
        ErrorCategory(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorCategory fromTag(int tag) {
            for (ErrorCategory v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
