// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PTP protocol types for proven-servers.

/// PtpMessageType matching the Idris2 ABI tags.
public enum PtpMessageType: UInt8, CaseIterable, Sendable {
    case sync = 0
    case delayReq = 1
    case pdelayReq = 2
    case pdelayResp = 3
    case followUp = 4
    case delayResp = 5
    case pdelayRespFollowUp = 6
    case announce = 7
    case signaling = 8
    case management = 9
}

/// ClockClass matching the Idris2 ABI tags.
public enum ClockClass: UInt8, CaseIterable, Sendable {
    case primaryClock = 0
    case applicationSpecific = 1
    case slaveOnly = 2
    case defaultClass = 3
}

/// PtpPortState matching the Idris2 ABI tags.
public enum PtpPortState: UInt8, CaseIterable, Sendable {
    case initializing = 0
    case faulty = 1
    case disabled = 2
    case listening = 3
    case preMaster = 4
    case master = 5
    case passive = 6
    case uncalibrated = 7
    case slave = 8
}

/// DelayMechanism matching the Idris2 ABI tags.
public enum DelayMechanism: UInt8, CaseIterable, Sendable {
    case e2e = 0
    case p2p = 1
    case dmDisabled = 2
}
