// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BFD protocol types for proven-servers.

/// BfdState matching the Idris2 ABI tags.
public enum BfdState: UInt8, CaseIterable, Sendable {
    case adminDown = 0
    case down = 1
    case `init` = 2
    case up = 3
}

/// Diagnostic matching the Idris2 ABI tags.
public enum Diagnostic: UInt8, CaseIterable, Sendable {
    case noDiagnostic = 0
    case controlDetectionTimeExpired = 1
    case echoFunctionFailed = 2
    case neighborSignaledSessionDown = 3
    case forwardingPlaneReset = 4
    case pathDown = 5
    case concatenatedPathDown = 6
    case administrativelyDown = 7
    case reverseConcatenatedPathDown = 8
}

/// SessionMode matching the Idris2 ABI tags.
public enum SessionMode: UInt8, CaseIterable, Sendable {
    case asyncMode = 0
    case demandMode = 1
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case ssDown = 1
    case negotiating = 2
    case established = 3
    case teardown = 4
}
