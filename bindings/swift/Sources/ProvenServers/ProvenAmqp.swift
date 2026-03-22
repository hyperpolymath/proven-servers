// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// AMQP protocol types for proven-servers.

/// FrameType matching the Idris2 ABI tags.
public enum FrameType: UInt8, CaseIterable, Sendable {
    case method = 0
    case header = 1
    case body = 2
    case heartbeat = 3
}

/// MethodClass matching the Idris2 ABI tags.
public enum MethodClass: UInt8, CaseIterable, Sendable {
    case connection = 0
    case channel = 1
    case exchange = 2
    case queue = 3
    case basic = 4
    case tx = 5
    case confirm = 6
}

/// ExchangeType matching the Idris2 ABI tags.
public enum ExchangeType: UInt8, CaseIterable, Sendable {
    case direct = 0
    case fanout = 1
    case topic = 2
    case headers = 3
}

/// DeliveryMode matching the Idris2 ABI tags.
public enum DeliveryMode: UInt8, CaseIterable, Sendable {
    case nonPersistent = 0
    case persistent = 1
}

/// ErrorSeverity matching the Idris2 ABI tags.
public enum ErrorSeverity: UInt8, CaseIterable, Sendable {
    case channelLevel = 0
    case connectionLevel = 1
}

/// ConnectionState matching the Idris2 ABI tags.
public enum ConnectionState: UInt8, CaseIterable, Sendable {
    case connectionState_Idle = 0
    case negotiating = 1
    case tuningOk = 2
    case `open` = 3
    case closing = 4
}

/// ChannelState matching the Idris2 ABI tags.
public enum ChannelState: UInt8, CaseIterable, Sendable {
    case closed = 0
    case opening = 1
    case chOpen = 2
    case chClosing = 3
}

/// BrokerState matching the Idris2 ABI tags.
public enum BrokerState: UInt8, CaseIterable, Sendable {
    case brokerState_Idle = 0
    case connected = 1
    case channelOpen = 2
    case consuming = 3
    case publishing = 4
    case disconnecting = 5
}
