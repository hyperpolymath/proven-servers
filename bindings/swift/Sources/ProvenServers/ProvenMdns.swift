// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mDNS protocol types for proven-servers.

/// MdnsRecordType matching the Idris2 ABI tags.
public enum MdnsRecordType: UInt8, CaseIterable, Sendable {
    case a = 0
    case aaaa = 1
    case ptr = 2
    case srv = 3
    case txt = 4
}

/// QueryType matching the Idris2 ABI tags.
public enum QueryType: UInt8, CaseIterable, Sendable {
    case standard = 0
    case oneShot = 1
    case continuous = 2
}

/// ConflictAction matching the Idris2 ABI tags.
public enum ConflictAction: UInt8, CaseIterable, Sendable {
    case probe = 0
    case defend = 1
    case withdraw = 2
}

/// ServiceFlag matching the Idris2 ABI tags.
public enum ServiceFlag: UInt8, CaseIterable, Sendable {
    case unique = 0
    case shared = 1
}

/// ResponderState matching the Idris2 ABI tags.
public enum ResponderState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case probing = 1
    case announcing = 2
    case running = 3
    case shuttingDown = 4
}
