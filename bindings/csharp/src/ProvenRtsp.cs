// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RTSP protocol types for proven-servers.

namespace Proven;

/// <summary>Method matching the Idris2 ABI tags (0-10).</summary>
public enum Method : byte
{
    Describe = 0,
    Setup = 1,
    Play = 2,
    Pause = 3,
    Teardown = 4,
    GetParameter = 5,
    SetParameter = 6,
    Options = 7,
    Announce = 8,
    Record = 9,
    Redirect = 10
}

/// <summary>TransportProtocol matching the Idris2 ABI tags (0-2).</summary>
public enum TransportProtocol : byte
{
    RtpAvpUdp = 0,
    RtpAvpTcp = 1,
    RtpAvpUdpMulticast = 2
}

/// <summary>SessionState matching the Idris2 ABI tags (0-3).</summary>
public enum SessionState : byte
{
    Init = 0,
    Ready = 1,
    Playing = 2,
    Recording = 3
}

/// <summary>StatusCode matching the Idris2 ABI tags (0-11).</summary>
public enum StatusCode : byte
{
    Ok = 0,
    MovedPermanently = 1,
    MovedTemporarily = 2,
    BadRequest = 3,
    Unauthorized = 4,
    NotFound = 5,
    MethodNotAllowed = 6,
    NotAcceptable = 7,
    SessionNotFound = 8,
    InternalServerError = 9,
    NotImplemented = 10,
    ServiceUnavailable = 11
}

/// <summary>RtspError matching the Idris2 ABI tags (0-6).</summary>
public enum RtspError : byte
{
    Ok = 0,
    InvalidSlot = 1,
    NotActive = 2,
    InvalidTransition = 3,
    MethodNotAllowed = 4,
    TransportError = 5,
    SessionExpired = 6
}
