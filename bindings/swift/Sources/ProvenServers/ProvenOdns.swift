// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ODNS protocol types for proven-servers.

/// Role matching the Idris2 ABI tags.
public enum Role: UInt8, CaseIterable, Sendable {
    case client = 0
    case proxy = 1
    case target = 2
}

/// OdnsMessageType matching the Idris2 ABI tags.
public enum OdnsMessageType: UInt8, CaseIterable, Sendable {
    case query = 0
    case response = 1
}

/// OdnsErrorReason matching the Idris2 ABI tags.
public enum OdnsErrorReason: UInt8, CaseIterable, Sendable {
    case proxyError = 0
    case targetError = 1
    case decryptionFailed = 2
    case invalidConfig = 3
    case payloadTooLarge = 4
}

/// EncapsulationFormat matching the Idris2 ABI tags.
public enum EncapsulationFormat: UInt8, CaseIterable, Sendable {
    case hpke = 0
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case keyExchange = 1
    case ready = 2
    case processing = 3
    case closing = 4
}
