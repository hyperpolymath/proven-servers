// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Virtualization protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Virtualization protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenVirt {
    private ProvenVirt() {}

    /** VmState (tags 0-7). */
    public enum VmState {
        CREATING(0),
        RUNNING(1),
        PAUSED(2),
        SUSPENDED(3),
        SHUTTING_DOWN(4),
        STOPPED(5),
        CRASHED(6),
        MIGRATING(7);

        private final int tag;
        VmState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static VmState fromTag(int tag) {
            for (VmState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** VirtOperation (tags 0-10). */
    public enum VirtOperation {
        CREATE(0),
        START(1),
        STOP(2),
        RESTART(3),
        PAUSE(4),
        RESUME(5),
        SUSPEND(6),
        MIGRATE(7),
        SNAPSHOT(8),
        CLONE(9),
        DELETE(10);

        private final int tag;
        VirtOperation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static VirtOperation fromTag(int tag) {
            for (VirtOperation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DiskFormat (tags 0-4). */
    public enum DiskFormat {
        RAW(0),
        QCOW2(1),
        VDI(2),
        VMDK(3),
        VHD(4);

        private final int tag;
        DiskFormat(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DiskFormat fromTag(int tag) {
            for (DiskFormat v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NetworkType (tags 0-3). */
    public enum NetworkType {
        NAT(0),
        BRIDGED(1),
        INTERNAL(2),
        HOST_ONLY(3);

        private final int tag;
        NetworkType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NetworkType fromTag(int tag) {
            for (NetworkType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** BootDevice (tags 0-3). */
    public enum BootDevice {
        HARD_DISK(0),
        CDROM(1),
        NETWORK(2),
        USB(3);

        private final int tag;
        BootDevice(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static BootDevice fromTag(int tag) {
            for (BootDevice v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
