// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Config Mgmt protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Config Mgmt protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenConfigmgmt {
    private ProvenConfigmgmt() {}

    /** ResourceType (tags 0-8). */
    public enum ResourceType {
        FILE(0),
        PACKAGE(1),
        SERVICE(2),
        USER(3),
        GROUP(4),
        CRON(5),
        MOUNT(6),
        FIREWALL(7),
        REGISTRY(8);

        private final int tag;
        ResourceType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResourceType fromTag(int tag) {
            for (ResourceType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResourceState (tags 0-5). */
    public enum ResourceState {
        PRESENT(0),
        ABSENT(1),
        RUNNING(2),
        STOPPED(3),
        ENABLED(4),
        DISABLED(5);

        private final int tag;
        ResourceState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResourceState fromTag(int tag) {
            for (ResourceState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ChangeAction (tags 0-5). */
    public enum ChangeAction {
        CREATE(0),
        MODIFY(1),
        DELETE(2),
        RESTART(3),
        RELOAD(4),
        SKIP(5);

        private final int tag;
        ChangeAction(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ChangeAction fromTag(int tag) {
            for (ChangeAction v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DriftStatus (tags 0-3). */
    public enum DriftStatus {
        IN_SYNC(0),
        DRIFTED(1),
        D_UNKNOWN(2),
        UNMANAGED(3);

        private final int tag;
        DriftStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DriftStatus fromTag(int tag) {
            for (DriftStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ApplyMode (tags 0-2). */
    public enum ApplyMode {
        ENFORCE(0),
        DRY_RUN(1),
        AUDIT(2);

        private final int tag;
        ApplyMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ApplyMode fromTag(int tag) {
            for (ApplyMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
