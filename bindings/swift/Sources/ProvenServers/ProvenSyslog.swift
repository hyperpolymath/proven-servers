// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Syslog protocol types for proven-servers.

/// Severity matching the Idris2 ABI tags.
public enum Severity: UInt8, CaseIterable, Sendable {
    case emergency = 0
    case severity_Alert = 1
    case critical = 2
    case error = 3
    case warning = 4
    case notice = 5
    case informational = 6
    case debug = 7
}

/// Facility matching the Idris2 ABI tags.
public enum Facility: UInt8, CaseIterable, Sendable {
    case kern = 0
    case user = 1
    case mail = 2
    case daemon = 3
    case auth = 4
    case syslog = 5
    case lpr = 6
    case news = 7
    case uucp = 8
    case cron = 9
    case authPriv = 10
    case ftp = 11
    case ntp = 12
    case audit = 13
    case facility_Alert = 14
    case clock = 15
    case local0 = 16
    case local1 = 17
    case local2 = 18
    case local3 = 19
    case local4 = 20
    case local5 = 21
    case local6 = 22
    case local7 = 23
}

/// Transport matching the Idris2 ABI tags.
public enum Transport: UInt8, CaseIterable, Sendable {
    case udp514 = 0
    case tcp514 = 1
    case tls6514 = 2
}
