// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Sandbox protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Sandbox protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSandbox {
    private ProvenSandbox() {}

    /** ExecutionPolicy (tags 0-4). */
    public enum ExecutionPolicy {
        UNRESTRICTED(0),
        READ_ONLY(1),
        NETWORK_DENIED(2),
        ISOLATED(3),
        EPHEMERAL(4);

        private final int tag;
        ExecutionPolicy(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ExecutionPolicy fromTag(int tag) {
            for (ExecutionPolicy v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResourceLimit (tags 0-5). */
    public enum ResourceLimit {
        CPU_TIME(0),
        MEMORY(1),
        DISK_IO(2),
        NETWORK_IO(3),
        FILE_DESCRIPTORS(4),
        PROCESSES(5);

        private final int tag;
        ResourceLimit(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResourceLimit fromTag(int tag) {
            for (ResourceLimit v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SandboxState (tags 0-5). */
    public enum SandboxState {
        CREATING(0),
        READY(1),
        RUNNING(2),
        SUSPENDED(3),
        TERMINATED(4),
        DESTROYED(5);

        private final int tag;
        SandboxState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SandboxState fromTag(int tag) {
            for (SandboxState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ExitReason (tags 0-5). */
    public enum ExitReason {
        NORMAL(0),
        TIMEOUT(1),
        MEMORY_EXCEEDED(2),
        POLICY_VIOLATION(3),
        KILLED(4),
        ERROR(5);

        private final int tag;
        ExitReason(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ExitReason fromTag(int tag) {
            for (ExitReason v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SyscallPolicy (tags 0-3). */
    public enum SyscallPolicy {
        ALLOW(0),
        DENY(1),
        LOG(2),
        TRAP(3);

        private final int tag;
        SyscallPolicy(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SyscallPolicy fromTag(int tag) {
            for (SyscallPolicy v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
