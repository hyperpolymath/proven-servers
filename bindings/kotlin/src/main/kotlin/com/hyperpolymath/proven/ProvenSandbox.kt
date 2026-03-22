// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Sandbox protocol types for proven-servers.

package com.hyperpolymath.proven

/** ExecutionPolicy matching the Idris2 ABI tags. */
enum class ExecutionPolicy(val tag: Int) {
    UNRESTRICTED(0),
    READ_ONLY(1),
    NETWORK_DENIED(2),
    ISOLATED(3),
    EPHEMERAL(4);

    companion object {
        fun fromTag(tag: Int): ExecutionPolicy? = entries.find { it.tag == tag }
    }
}

/** ResourceLimit matching the Idris2 ABI tags. */
enum class ResourceLimit(val tag: Int) {
    CPU_TIME(0),
    MEMORY(1),
    DISK_IO(2),
    NETWORK_IO(3),
    FILE_DESCRIPTORS(4),
    PROCESSES(5);

    companion object {
        fun fromTag(tag: Int): ResourceLimit? = entries.find { it.tag == tag }
    }
}

/** SandboxState matching the Idris2 ABI tags. */
enum class SandboxState(val tag: Int) {
    CREATING(0),
    READY(1),
    RUNNING(2),
    SUSPENDED(3),
    TERMINATED(4),
    DESTROYED(5);

    companion object {
        fun fromTag(tag: Int): SandboxState? = entries.find { it.tag == tag }
    }
}

/** ExitReason matching the Idris2 ABI tags. */
enum class ExitReason(val tag: Int) {
    NORMAL(0),
    TIMEOUT(1),
    MEMORY_EXCEEDED(2),
    POLICY_VIOLATION(3),
    KILLED(4),
    ERROR(5);

    companion object {
        fun fromTag(tag: Int): ExitReason? = entries.find { it.tag == tag }
    }
}

/** SyscallPolicy matching the Idris2 ABI tags. */
enum class SyscallPolicy(val tag: Int) {
    ALLOW(0),
    DENY(1),
    LOG(2),
    TRAP(3);

    companion object {
        fun fromTag(tag: Int): SyscallPolicy? = entries.find { it.tag == tag }
    }
}
