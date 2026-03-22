// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Virtualization protocol types for proven-servers.

/// VmState matching the Idris2 ABI tags.
public enum VmState: UInt8, CaseIterable, Sendable {
    case creating = 0
    case running = 1
    case paused = 2
    case suspended = 3
    case shuttingDown = 4
    case stopped = 5
    case crashed = 6
    case migrating = 7
}

/// VirtOperation matching the Idris2 ABI tags.
public enum VirtOperation: UInt8, CaseIterable, Sendable {
    case create = 0
    case start = 1
    case stop = 2
    case restart = 3
    case pause = 4
    case resume = 5
    case suspend = 6
    case migrate = 7
    case snapshot = 8
    case clone = 9
    case delete = 10
}

/// DiskFormat matching the Idris2 ABI tags.
public enum DiskFormat: UInt8, CaseIterable, Sendable {
    case raw = 0
    case qcow2 = 1
    case vdi = 2
    case vmdk = 3
    case vhd = 4
}

/// NetworkType matching the Idris2 ABI tags.
public enum NetworkType: UInt8, CaseIterable, Sendable {
    case nat = 0
    case bridged = 1
    case `internal` = 2
    case hostOnly = 3
}

/// BootDevice matching the Idris2 ABI tags.
public enum BootDevice: UInt8, CaseIterable, Sendable {
    case hardDisk = 0
    case cdrom = 1
    case network = 2
    case usb = 3
}
