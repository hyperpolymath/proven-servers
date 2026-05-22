// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Virtualization protocol types for proven-servers.

package com.hyperpolymath.proven

/** VmState matching the Idris2 ABI tags. */
enum class VmState(val tag: Int) {
    CREATING(0),
    RUNNING(1),
    PAUSED(2),
    SUSPENDED(3),
    SHUTTING_DOWN(4),
    STOPPED(5),
    CRASHED(6),
    MIGRATING(7);

    companion object {
        fun fromTag(tag: Int): VmState? = entries.find { it.tag == tag }
    }
}

/** VirtOperation matching the Idris2 ABI tags. */
enum class VirtOperation(val tag: Int) {
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

    companion object {
        fun fromTag(tag: Int): VirtOperation? = entries.find { it.tag == tag }
    }
}

/** DiskFormat matching the Idris2 ABI tags. */
enum class DiskFormat(val tag: Int) {
    RAW(0),
    QCOW2(1),
    VDI(2),
    VMDK(3),
    VHD(4);

    companion object {
        fun fromTag(tag: Int): DiskFormat? = entries.find { it.tag == tag }
    }
}

/** NetworkType matching the Idris2 ABI tags. */
enum class NetworkType(val tag: Int) {
    NAT(0),
    BRIDGED(1),
    INTERNAL(2),
    HOST_ONLY(3);

    companion object {
        fun fromTag(tag: Int): NetworkType? = entries.find { it.tag == tag }
    }
}

/** BootDevice matching the Idris2 ABI tags. */
enum class BootDevice(val tag: Int) {
    HARD_DISK(0),
    CDROM(1),
    NETWORK(2),
    USB(3);

    companion object {
        fun fromTag(tag: Int): BootDevice? = entries.find { it.tag == tag }
    }
}
