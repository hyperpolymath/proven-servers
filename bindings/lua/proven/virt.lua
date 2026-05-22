-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Virtualization protocol types for proven-servers.

local M = {}

--- VmState matching the Idris2 ABI tags.
M.VmState = {
    CREATING = 0,
    RUNNING = 1,
    PAUSED = 2,
    SUSPENDED = 3,
    SHUTTING_DOWN = 4,
    STOPPED = 5,
    CRASHED = 6,
    MIGRATING = 7,
}

--- VirtOperation matching the Idris2 ABI tags.
M.VirtOperation = {
    CREATE = 0,
    START = 1,
    STOP = 2,
    RESTART = 3,
    PAUSE = 4,
    RESUME = 5,
    SUSPEND = 6,
    MIGRATE = 7,
    SNAPSHOT = 8,
    CLONE = 9,
    DELETE = 10,
}

--- DiskFormat matching the Idris2 ABI tags.
M.DiskFormat = {
    RAW = 0,
    QCOW2 = 1,
    VDI = 2,
    VMDK = 3,
    VHD = 4,
}

--- NetworkType matching the Idris2 ABI tags.
M.NetworkType = {
    NAT = 0,
    BRIDGED = 1,
    INTERNAL = 2,
    HOST_ONLY = 3,
}

--- BootDevice matching the Idris2 ABI tags.
M.BootDevice = {
    HARD_DISK = 0,
    CDROM = 1,
    NETWORK = 2,
    USB = 3,
}

return M
