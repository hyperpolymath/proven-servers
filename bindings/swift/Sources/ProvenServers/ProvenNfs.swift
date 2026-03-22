// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NFS protocol types for proven-servers.

/// Operation matching the Idris2 ABI tags.
public enum Operation: UInt8, CaseIterable, Sendable {
    case operation_Access = 0
    case close = 1
    case commit = 2
    case create = 3
    case getAttr = 4
    case operation_Link = 5
    case lock = 6
    case lookup = 7
    case `open` = 8
    case read = 9
    case readDir = 10
    case remove = 11
    case rename = 12
    case setAttr = 13
    case write = 14
}

/// FileType matching the Idris2 ABI tags.
public enum FileType: UInt8, CaseIterable, Sendable {
    case regular = 0
    case directory = 1
    case blockDevice = 2
    case charDevice = 3
    case fileType_Link = 4
    case socket = 5
    case fifo = 6
}

/// Status matching the Idris2 ABI tags.
public enum Status: UInt8, CaseIterable, Sendable {
    case ok = 0
    case perm = 1
    case noEnt = 2
    case io = 3
    case nxIo = 4
    case status_Access = 5
    case exist = 6
    case notDir = 7
    case isDir = 8
    case fBig = 9
    case noSpc = 10
    case rOfs = 11
    case notEmpty = 12
    case stale = 13
}

/// NfsState matching the Idris2 ABI tags.
public enum NfsState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case mounted = 1
    case fileOpen = 2
    case locked = 3
    case busy = 4
    case unmounting = 5
}
