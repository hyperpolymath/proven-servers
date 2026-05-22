// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoT protocol types for proven-servers.

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case connecting = 0
    case handshaking = 1
    case established = 2
    case closing = 3
    case closed = 4
}

/// PaddingStrategy matching the Idris2 ABI tags.
public enum PaddingStrategy: UInt8, CaseIterable, Sendable {
    case noPadding = 0
    case blockPadding = 1
    case randomPadding = 2
}

/// ErrorReason matching the Idris2 ABI tags.
public enum ErrorReason: UInt8, CaseIterable, Sendable {
    case handshakeFailed = 0
    case certificateInvalid = 1
    case timeout = 2
    case upstreamError = 3
}

/// ServerState matching the Idris2 ABI tags.
public enum ServerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case bound = 1
    case listening = 2
    case processing = 3
    case shutdown = 4
}
