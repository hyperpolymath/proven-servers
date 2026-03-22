// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Telnet protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
public enum Command: UInt8, CaseIterable, Sendable {
    case se = 0
    case nop = 1
    case dataMark = 2
    case `break` = 3
    case interruptProcess = 4
    case abortOutput = 5
    case areYouThere = 6
    case eraseChar = 7
    case eraseLine = 8
    case goAhead = 9
    case sb = 10
    case will = 11
    case wont = 12
    case `do` = 13
    case dont = 14
    case iac = 15
}

/// TelnetOption matching the Idris2 ABI tags.
public enum TelnetOption: UInt8, CaseIterable, Sendable {
    case echo = 0
    case suppressGoAhead = 1
    case status = 2
    case timingMark = 3
    case terminalType = 4
    case windowSize = 5
    case terminalSpeed = 6
    case remoteFlowControl = 7
    case linemode = 8
    case environment = 9
}

/// NegotiationState matching the Idris2 ABI tags.
public enum NegotiationState: UInt8, CaseIterable, Sendable {
    case inactive = 0
    case willSent = 1
    case doSent = 2
    case negotiationState_Active = 3
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case negotiating = 1
    case sessionState_Active = 2
    case subneg = 3
    case closing = 4
}
