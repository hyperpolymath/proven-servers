// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebSocket protocol types for proven-servers.

/// Opcode matching the Idris2 ABI tags.
public enum Opcode: UInt8, CaseIterable, Sendable {
    case continuation = 0
    case text = 0
    case binary = 0
    case close = 0
    case ping = 0
    case pong = 0
}

/// CloseCode matching the Idris2 ABI tags.
public enum CloseCode: UInt8, CaseIterable, Sendable {
    case normal = 1000
    case goingAway = 1001
    case protocolError = 1002
    case unsupportedData = 1003
    case noStatus = 1005
    case abnormal = 1006
    case invalidPayload = 1007
    case policyViolation = 1008
    case messageTooBig = 1009
    case mandatoryExtension = 1010
    case internalError = 1011
}
