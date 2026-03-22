// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BGP protocol types for proven-servers.

/// BgpState matching the Idris2 ABI tags.
public enum BgpState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case connect = 1
    case active = 2
    case openSent = 3
    case openConfirm = 4
    case established = 5
}

/// BgpEvent matching the Idris2 ABI tags.
public enum BgpEvent: UInt8, CaseIterable, Sendable {
    case manualStart = 0
    case manualStop = 1
    case automaticStart = 2
    case connectRetryTimerExpires = 3
    case holdTimerExpires = 4
    case keepaliveTimerExpires = 5
    case delayOpenTimerExpires = 6
    case tcpConnectionValid = 7
    case tcpCrAcked = 8
    case tcpConnectionConfirmed = 9
    case tcpConnectionFails = 10
    case bgpOpenReceived = 11
    case bgpHeaderErr = 12
    case bgpOpenMsgErr = 13
    case notifMsgVerErr = 14
    case notifMsg = 15
    case keepaliveMsg = 16
    case updateMsg = 17
    case updateMsgErr = 18
}

/// MessageType matching the Idris2 ABI tags.
public enum MessageType: UInt8, CaseIterable, Sendable {
    case `open` = 0
    case update = 1
    case notification = 2
    case keepalive = 3
}

/// ErrorCode matching the Idris2 ABI tags.
public enum ErrorCode: UInt8, CaseIterable, Sendable {
    case messageHeaderError = 0
    case openMessageError = 1
    case updateMessageError = 2
    case holdTimerExpired = 3
    case fsmError = 4
    case cease = 5
}

/// Origin matching the Idris2 ABI tags.
public enum Origin: UInt8, CaseIterable, Sendable {
    case igp = 0
    case egp = 1
    case incomplete = 2
}

/// AsPathSegmentType matching the Idris2 ABI tags.
public enum AsPathSegmentType: UInt8, CaseIterable, Sendable {
    case asSet = 0
    case asSequence = 1
}

/// PathAttrType matching the Idris2 ABI tags.
public enum PathAttrType: UInt8, CaseIterable, Sendable {
    case origin = 0
    case asPath = 1
    case nextHop = 2
    case med = 3
    case localPref = 4
    case atomicAggr = 5
    case aggregator = 6
    case unknown = 7
}
