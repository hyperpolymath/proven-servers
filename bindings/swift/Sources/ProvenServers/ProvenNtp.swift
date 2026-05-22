// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTP protocol types for proven-servers.

/// LeapIndicator matching the Idris2 ABI tags.
public enum LeapIndicator: UInt8, CaseIterable, Sendable {
    case noWarning = 0
    case lastMinute61 = 1
    case lastMinute59 = 2
    case unsynchronised = 3
}

/// NtpMode matching the Idris2 ABI tags.
public enum NtpMode: UInt8, CaseIterable, Sendable {
    case reserved = 0
    case symmetricActive = 1
    case symmetricPassive = 2
    case client = 3
    case server = 4
    case broadcast = 5
    case controlMessage = 6
    case `private` = 7
}

/// ExchangeState matching the Idris2 ABI tags.
public enum ExchangeState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case requestReceived = 1
    case timestampCalculated = 2
    case responseSent = 3
}

/// ClockDisciplineState matching the Idris2 ABI tags.
public enum ClockDisciplineState: UInt8, CaseIterable, Sendable {
    case unset = 0
    case spike = 1
    case freq = 2
    case sync = 3
    case panic = 4
}

/// KissCode matching the Idris2 ABI tags.
public enum KissCode: UInt8, CaseIterable, Sendable {
    case deny = 0
    case rstr = 1
    case rate = 2
    case other = 3
}

/// NtpError matching the Idris2 ABI tags.
public enum NtpError: UInt8, CaseIterable, Sendable {
    case ok = 0
    case invalidSlot = 1
    case notActive = 2
    case invalidPacket = 3
    case kissOfDeath = 4
    case stratumTooHigh = 5
}
