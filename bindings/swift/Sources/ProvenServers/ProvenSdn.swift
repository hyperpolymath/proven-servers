// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SDN protocol types for proven-servers.

/// SdnMessageType matching the Idris2 ABI tags.
public enum SdnMessageType: UInt8, CaseIterable, Sendable {
    case hello = 0
    case error = 1
    case echoRequest = 2
    case echoReply = 3
    case featuresRequest = 4
    case featuresReply = 5
    case flowMod = 6
    case packetIn = 7
    case packetOut = 8
    case portStatus = 9
    case barrierRequest = 10
    case barrierReply = 11
}

/// FlowAction matching the Idris2 ABI tags.
public enum FlowAction: UInt8, CaseIterable, Sendable {
    case output = 0
    case setField = 1
    case drop = 2
    case pushVlan = 3
    case popVlan = 4
    case setQueue = 5
    case group = 6
}

/// MatchField matching the Idris2 ABI tags.
public enum MatchField: UInt8, CaseIterable, Sendable {
    case inPort = 0
    case ethDst = 1
    case ethSrc = 2
    case ethType = 3
    case vlanId = 4
    case ipSrc = 5
    case ipDst = 6
    case tcpSrc = 7
    case tcpDst = 8
    case udpSrc = 9
    case udpDst = 10
}

/// PortState matching the Idris2 ABI tags.
public enum PortState: UInt8, CaseIterable, Sendable {
    case up = 0
    case down = 1
    case blocked = 2
}
