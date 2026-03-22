// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Honeypot protocol types for proven-servers.

/// ServiceEmulation matching the Idris2 ABI tags.
public enum ServiceEmulation: UInt8, CaseIterable, Sendable {
    case ssh = 0
    case http = 1
    case ftp = 2
    case smtp = 3
    case telnet = 4
    case mysql = 5
    case rdp = 6
}

/// InteractionLevel matching the Idris2 ABI tags.
public enum InteractionLevel: UInt8, CaseIterable, Sendable {
    case low = 0
    case medium = 1
    case high = 2
}

/// HoneypotAlertSeverity matching the Idris2 ABI tags.
public enum HoneypotAlertSeverity: UInt8, CaseIterable, Sendable {
    case info = 0
    case asLow = 1
    case asMedium = 2
    case asHigh = 3
    case critical = 4
}

/// AttackerAction matching the Idris2 ABI tags.
public enum AttackerAction: UInt8, CaseIterable, Sendable {
    case scan = 0
    case bruteForce = 1
    case exploit = 2
    case payload = 3
    case lateral = 4
    case exfiltration = 5
}

/// ServerState matching the Idris2 ABI tags.
public enum ServerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case deployed = 1
    case engaged = 2
    case shutdown = 3
}
