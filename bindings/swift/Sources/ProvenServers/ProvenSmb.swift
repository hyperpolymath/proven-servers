// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SMB protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
public enum Command: UInt8, CaseIterable, Sendable {
    case negotiate = 0
    case sessionSetup = 1
    case logoff = 2
    case treeConnect = 3
    case treeDisconnect = 4
    case create = 5
    case close = 6
    case read = 7
    case write = 8
    case lock = 9
    case ioctl = 10
    case cancel = 11
    case queryDirectory = 12
    case changeNotify = 13
    case queryInfo = 14
    case setInfo = 15
}

/// Dialect matching the Idris2 ABI tags.
public enum Dialect: UInt8, CaseIterable, Sendable {
    case smb2_0_2 = 0
    case smb2_1 = 1
    case smb3_0 = 2
    case smb3_0_2 = 3
    case smb3_1_1 = 4
}

/// ShareType matching the Idris2 ABI tags.
public enum ShareType: UInt8, CaseIterable, Sendable {
    case disk = 0
    case pipe = 1
    case print = 2
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case negotiated = 1
    case authenticated = 2
    case treeConnected = 3
    case fileOpen = 4
    case disconnecting = 5
}
