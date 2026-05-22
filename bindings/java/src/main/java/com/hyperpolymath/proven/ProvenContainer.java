// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Container protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Container protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenContainer {
    private ProvenContainer() {}

    /** ContainerState (tags 0-6). */
    public enum ContainerState {
        CREATING(0),
        RUNNING(1),
        PAUSED(2),
        RESTARTING(3),
        STOPPED(4),
        REMOVING(5),
        DEAD(6);

        private final int tag;
        ContainerState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ContainerState fromTag(int tag) {
            for (ContainerState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ContainerOperation (tags 0-10). */
    public enum ContainerOperation {
        CREATE(0),
        START(1),
        STOP(2),
        RESTART(3),
        PAUSE(4),
        UNPAUSE(5),
        KILL(6),
        REMOVE(7),
        EXEC(8),
        LOGS(9),
        INSPECT(10);

        private final int tag;
        ContainerOperation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ContainerOperation fromTag(int tag) {
            for (ContainerOperation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NetworkMode (tags 0-4). */
    public enum NetworkMode {
        BRIDGE(0),
        HOST(1),
        NONE(2),
        OVERLAY(3),
        MACVLAN(4);

        private final int tag;
        NetworkMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NetworkMode fromTag(int tag) {
            for (NetworkMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** VolumeType (tags 0-2). */
    public enum VolumeType {
        BIND(0),
        NAMED(1),
        TMPFS(2);

        private final int tag;
        VolumeType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static VolumeType fromTag(int tag) {
            for (VolumeType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** RestartPolicy (tags 0-3). */
    public enum RestartPolicy {
        NO(0),
        ALWAYS(1),
        ON_FAILURE(2),
        UNLESS_STOPPED(3);

        private final int tag;
        RestartPolicy(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RestartPolicy fromTag(int tag) {
            for (RestartPolicy v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HealthStatus (tags 0-3). */
    public enum HealthStatus {
        STARTING(0),
        HEALTHY(1),
        UNHEALTHY(2),
        NO_CHECK(3);

        private final int tag;
        HealthStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HealthStatus fromTag(int tag) {
            for (HealthStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
