// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// File Server protocol types for proven-servers.

/// FileOperation matching the Idris2 ABI tags.
public enum FileOperation: UInt8, CaseIterable, Sendable {
    case read = 0
    case write = 1
    case create = 2
    case delete = 3
    case rename = 4
    case list = 5
    case stat = 6
    case lock = 7
    case unlock = 8
    case watch = 9
}

/// FileType matching the Idris2 ABI tags.
public enum FileType: UInt8, CaseIterable, Sendable {
    case regular = 0
    case directory = 1
    case symlink = 2
    case blockDevice = 3
    case charDevice = 4
    case fifo = 5
    case socket = 6
}

/// FilePermission matching the Idris2 ABI tags.
public enum FilePermission: UInt8, CaseIterable, Sendable {
    case ownerRead = 0
    case ownerWrite = 1
    case ownerExecute = 2
    case groupRead = 3
    case groupWrite = 4
    case groupExecute = 5
    case otherRead = 6
    case otherWrite = 7
    case otherExecute = 8
}

/// LockType matching the Idris2 ABI tags.
public enum LockType: UInt8, CaseIterable, Sendable {
    case shared = 0
    case exclusive = 1
    case advisory = 2
    case mandatory = 3
}

/// FileErrorCode matching the Idris2 ABI tags.
public enum FileErrorCode: UInt8, CaseIterable, Sendable {
    case notFound = 0
    case permissionDenied = 1
    case alreadyExists = 2
    case notEmpty = 3
    case isDirectory = 4
    case notDirectory = 5
    case noSpace = 6
    case readOnly = 7
    case locked = 8
    case ioError = 9
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case connected = 1
    case operating = 2
    case fsLocked = 3
    case disconnecting = 4
}
