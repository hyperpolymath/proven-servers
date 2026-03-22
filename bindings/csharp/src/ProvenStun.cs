// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// STUN/TURN protocol types for proven-servers.

namespace Proven;

/// <summary>MessageType matching the Idris2 ABI tags (0-11).</summary>
public enum MessageType : byte
{
    BindingRequest = 0,
    BindingResponse = 1,
    BindingError = 2,
    AllocateRequest = 3,
    AllocateResponse = 4,
    AllocateError = 5,
    RefreshRequest = 6,
    RefreshResponse = 7,
    SendIndication = 8,
    DataIndication = 9,
    CreatePermission = 10,
    ChannelBind = 11
}

/// <summary>TransportProtocol matching the Idris2 ABI tags (0-3).</summary>
public enum TransportProtocol : byte
{
    Udp = 0,
    Tcp = 1,
    Tls = 2,
    Dtls = 3
}

/// <summary>ErrorCode matching the Idris2 ABI tags (0-7).</summary>
public enum ErrorCode : byte
{
    TryAlternate = 0,
    BadRequest = 1,
    Unauthorized = 2,
    Forbidden = 3,
    MobilityForbidden = 4,
    StaleNonce = 5,
    ServerError = 6,
    InsufficientCapacity = 7
}
