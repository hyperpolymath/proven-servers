# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-sandbox protocol types.

"""Sandbox protocol types for proven-servers."""

from enum import IntEnum


class ExecutionPolicy(IntEnum):
    """ExecutionPolicy matching the Idris2 ABI tags."""
    UNRESTRICTED = 0
    READ_ONLY = 1
    NETWORK_DENIED = 2
    ISOLATED = 3
    EPHEMERAL = 4


class ResourceLimit(IntEnum):
    """ResourceLimit matching the Idris2 ABI tags."""
    CPU_TIME = 0
    MEMORY = 1
    DISK_IO = 2
    NETWORK_IO = 3
    FILE_DESCRIPTORS = 4
    PROCESSES = 5


class SandboxState(IntEnum):
    """SandboxState matching the Idris2 ABI tags."""
    CREATING = 0
    READY = 1
    RUNNING = 2
    SUSPENDED = 3
    TERMINATED = 4
    DESTROYED = 5


class ExitReason(IntEnum):
    """ExitReason matching the Idris2 ABI tags."""
    NORMAL = 0
    TIMEOUT = 1
    MEMORY_EXCEEDED = 2
    POLICY_VIOLATION = 3
    KILLED = 4
    ERROR = 5


class SyscallPolicy(IntEnum):
    """SyscallPolicy matching the Idris2 ABI tags."""
    ALLOW = 0
    DENY = 1
    LOG = 2
    TRAP = 3
