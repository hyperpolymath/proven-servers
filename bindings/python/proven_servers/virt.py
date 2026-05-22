# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-virt protocol types.

"""Virtualization protocol types for proven-servers."""

from enum import IntEnum


class VmState(IntEnum):
    """VmState matching the Idris2 ABI tags."""
    CREATING = 0
    RUNNING = 1
    PAUSED = 2
    SUSPENDED = 3
    SHUTTING_DOWN = 4
    STOPPED = 5
    CRASHED = 6
    MIGRATING = 7


class VirtOperation(IntEnum):
    """VirtOperation matching the Idris2 ABI tags."""
    CREATE = 0
    START = 1
    STOP = 2
    RESTART = 3
    PAUSE = 4
    RESUME = 5
    SUSPEND = 6
    MIGRATE = 7
    SNAPSHOT = 8
    CLONE = 9
    DELETE = 10


class DiskFormat(IntEnum):
    """DiskFormat matching the Idris2 ABI tags."""
    RAW = 0
    QCOW2 = 1
    VDI = 2
    VMDK = 3
    VHD = 4


class NetworkType(IntEnum):
    """NetworkType matching the Idris2 ABI tags."""
    NAT = 0
    BRIDGED = 1
    INTERNAL = 2
    HOST_ONLY = 3


class BootDevice(IntEnum):
    """BootDevice matching the Idris2 ABI tags."""
    HARD_DISK = 0
    CDROM = 1
    NETWORK = 2
    USB = 3
