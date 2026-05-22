// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SSH Bastion protocol bindings for proven-servers.

namespace Proven;

/// <summary>BastionState matching the Idris2 ABI tags (0-5).</summary>
public enum BastionState : byte
{
    BastionConnected = 0,
    BastionKeyExchanged = 1,
    BastionAuthenticated = 2,
    BastionChannelOpen = 3,
    BastionActive = 4,
    BastionClosed = 5
}

/// <summary>KexMethod matching the Idris2 ABI tags (0-4).</summary>
public enum KexMethod : byte
{
    KexCurve25519 = 0,
    KexDhGroup14 = 1,
    KexDhGroup16 = 2,
    KexEcdhP256 = 3,
    KexEcdhP384 = 4
}

/// <summary>AuthMethod matching the Idris2 ABI tags (0-3).</summary>
public enum AuthMethod : byte
{
    AuthPublicKey = 0,
    AuthPassword = 1,
    AuthKeyboard = 2,
    AuthCertificate = 3
}

/// <summary>ChannelType matching the Idris2 ABI tags (0-3).</summary>
public enum ChannelType : byte
{
    ChannelSession = 0,
    ChannelDirectTcpIp = 1,
    ChannelForwardedTcpIp = 2,
    ChannelSubsystem = 3
}

/// <summary>ChannelState matching the Idris2 ABI tags (0-3).</summary>
public enum ChannelState : byte
{
    ChannelOpening = 0,
    ChannelOpen = 1,
    ChannelClosing = 2,
    ChannelClosed = 3
}

/// <summary>DisconnectReason matching the Idris2 ABI tags (0-6).</summary>
public enum DisconnectReason : byte
{
    DisconnectHostNotAllowed = 0,
    DisconnectProtocolError = 1,
    DisconnectKeyExchangeFailed = 2,
    DisconnectAuthFailed = 3,
    DisconnectServiceNotAvailable = 4,
    DisconnectByApplication = 5,
    DisconnectTooManyConnections = 6
}
