// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SNMP protocol types for proven-servers.

/// Version matching the Idris2 ABI tags.
public enum Version: UInt8, CaseIterable, Sendable {
    case v1 = 0
    case v2c = 1
    case v3 = 2
}

/// PduType matching the Idris2 ABI tags.
public enum PduType: UInt8, CaseIterable, Sendable {
    case getRequest = 0
    case getNextRequest = 1
    case getResponse = 2
    case setRequest = 3
    case getBulkRequest = 4
    case informRequest = 5
    case snmpV2Trap = 6
}

/// ErrorStatus matching the Idris2 ABI tags.
public enum ErrorStatus: UInt8, CaseIterable, Sendable {
    case noError = 0
    case tooBig = 1
    case noSuchName = 2
    case badValue = 3
    case readOnly = 4
    case genErr = 5
    case noAccess = 6
    case wrongType = 7
    case wrongLength = 8
    case wrongValue = 9
    case noCreation = 10
    case inconsistentValue = 11
    case resourceUnavailable = 12
    case commitFailed = 13
    case undoFailed = 14
    case authorizationError = 15
}
