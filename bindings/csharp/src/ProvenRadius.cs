// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RADIUS protocol types for proven-servers.

namespace Proven;

/// <summary>PacketType matching the Idris2 ABI tags (0-5).</summary>
public enum PacketType : byte
{
    AccessRequest = 0,
    AccessAccept = 1,
    AccessReject = 2,
    AccountingRequest = 3,
    AccountingResponse = 4,
    AccessChallenge = 5
}

/// <summary>AttributeType matching the Idris2 ABI tags (0-8).</summary>
public enum AttributeType : byte
{
    UserName = 0,
    UserPassword = 1,
    NasIpAddress = 2,
    NasPort = 3,
    ServiceType = 4,
    FramedProtocol = 5,
    FramedIpAddress = 6,
    ReplyMessage = 7,
    SessionTimeout = 8
}

/// <summary>ServiceType matching the Idris2 ABI tags (0-5).</summary>
public enum ServiceType : byte
{
    Login = 0,
    Framed = 1,
    CallbackLogin = 2,
    CallbackFramed = 3,
    Outbound = 4,
    Administrative = 5
}

/// <summary>AuthMethod matching the Idris2 ABI tags (0-4).</summary>
public enum AuthMethod : byte
{
    Pap = 0,
    Chap = 1,
    Mschap = 2,
    Mschapv2 = 3,
    Eap = 4
}

/// <summary>SessionState matching the Idris2 ABI tags (0-6).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Authenticating = 1,
    Authorized = 2,
    Rejected = 3,
    Challenged = 4,
    Accounting = 5,
    Complete = 6
}

/// <summary>RadiusResult matching the Idris2 ABI tags (0-4).</summary>
public enum RadiusResult : byte
{
    Ok = 0,
    Err = 1,
    InvalidParam = 2,
    PoolExhausted = 3,
    BadSecret = 4
}
