// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// STUN/TURN protocol types for proven-servers.

/// MessageType matching the Idris2 ABI tags.
public enum MessageType: UInt8, CaseIterable, Sendable {
    case bindingRequest = 0
    case bindingResponse = 1
    case bindingError = 2
    case allocateRequest = 3
    case allocateResponse = 4
    case allocateError = 5
    case refreshRequest = 6
    case refreshResponse = 7
    case sendIndication = 8
    case dataIndication = 9
    case createPermission = 10
    case channelBind = 11
}

/// TransportProtocol matching the Idris2 ABI tags.
public enum TransportProtocol: UInt8, CaseIterable, Sendable {
    case udp = 0
    case tcp = 1
    case tls = 2
    case dtls = 3
}

/// ErrorCode matching the Idris2 ABI tags.
public enum ErrorCode: UInt8, CaseIterable, Sendable {
    case tryAlternate = 0
    case badRequest = 1
    case unauthorized = 2
    case forbidden = 3
    case mobilityForbidden = 4
    case staleNonce = 5
    case serverError = 6
    case insufficientCapacity = 7
}
