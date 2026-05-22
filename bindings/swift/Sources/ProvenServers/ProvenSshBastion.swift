// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SSH Bastion protocol types for proven-servers.

/// BastionState matching the Idris2 ABI tags.
public enum BastionState: UInt8, CaseIterable, Sendable {
    case bastionConnected = 0
    case bastionKeyExchanged = 1
    case bastionAuthenticated = 2
    case bastionChannelOpen = 3
    case bastionActive = 4
    case bastionClosed = 5
}

/// KexMethod matching the Idris2 ABI tags.
public enum KexMethod: UInt8, CaseIterable, Sendable {
    case kexCurve25519 = 0
    case kexDhGroup14 = 1
    case kexDhGroup16 = 2
    case kexEcdhP256 = 3
    case kexEcdhP384 = 4
}

/// BastionAuthMethod matching the Idris2 ABI tags.
public enum BastionAuthMethod: UInt8, CaseIterable, Sendable {
    case publicKey = 0
    case password = 1
    case keyboard = 2
    case certificate = 3
}

/// BastionChannelType matching the Idris2 ABI tags.
public enum BastionChannelType: UInt8, CaseIterable, Sendable {
    case session = 0
    case directTcpIp = 1
    case forwardedTcpIp = 2
    case subsystem = 3
}

/// BastionChannelState matching the Idris2 ABI tags.
public enum BastionChannelState: UInt8, CaseIterable, Sendable {
    case opening = 0
    case channelOpen = 1
    case closing = 2
    case channelClosed = 3
}

/// DisconnectReason matching the Idris2 ABI tags.
public enum DisconnectReason: UInt8, CaseIterable, Sendable {
    case hostNotAllowed = 0
    case protocolError = 1
    case keyExchangeFailed = 2
    case authFailed = 3
    case serviceNotAvailable = 4
    case byApplication = 5
    case tooManyConnections = 6
}
