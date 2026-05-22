// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VoIP/SIP protocol types for proven-servers.

namespace Proven;

/// <summary>Method matching the Idris2 ABI tags (0-12).</summary>
public enum Method : byte
{
    Invite = 0,
    Ack = 1,
    Bye = 2,
    Cancel = 3,
    Register = 4,
    Options = 5,
    Info = 6,
    Update = 7,
    Subscribe = 8,
    Notify = 9,
    Refer = 10,
    Message = 11,
    Prack = 12
}

/// <summary>ResponseCode matching the Idris2 ABI tags (0-16).</summary>
public enum ResponseCode : byte
{
    Trying = 0,
    Ringing = 1,
    SessionProgress = 2,
    Ok = 3,
    MultipleChoices = 4,
    MovedPermanently = 5,
    MovedTemporarily = 6,
    BadRequest = 7,
    Unauthorized = 8,
    Forbidden = 9,
    NotFound = 10,
    MethodNotAllowed = 11,
    RequestTimeout = 12,
    BusyHere = 13,
    Decline = 14,
    ServerInternalError = 15,
    ServiceUnavailable = 16
}

/// <summary>DialogState matching the Idris2 ABI tags (0-2).</summary>
public enum DialogState : byte
{
    Early = 0,
    Confirmed = 1,
    Terminated = 2
}
