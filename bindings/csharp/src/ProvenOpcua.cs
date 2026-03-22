// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OPC UA protocol types for proven-servers.

namespace Proven;

/// <summary>ServiceType matching the Idris2 ABI tags (0-10).</summary>
public enum ServiceType : byte
{
    Read = 0,
    Write = 1,
    Browse = 2,
    Subscribe = 3,
    Publish = 4,
    Call = 5,
    CreateSession = 6,
    ActivateSession = 7,
    CloseSession = 8,
    CreateSubscription = 9,
    DeleteSubscription = 10
}

/// <summary>NodeClass matching the Idris2 ABI tags (0-7).</summary>
public enum NodeClass : byte
{
    Object = 0,
    Variable = 1,
    Method = 2,
    ObjectType = 3,
    VariableType = 4,
    ReferenceType = 5,
    DataType = 6,
    View = 7
}

/// <summary>StatusCode matching the Idris2 ABI tags (0-11).</summary>
public enum StatusCode : byte
{
    Good = 0,
    Uncertain = 1,
    Bad = 2,
    BadNodeIdUnknown = 3,
    BadAttributeIdInvalid = 4,
    BadNotReadable = 5,
    BadNotWritable = 6,
    BadOutOfRange = 7,
    BadTypeMismatch = 8,
    BadSessionIdInvalid = 9,
    BadSubscriptionIdInvalid = 10,
    BadTimeout = 11
}

/// <summary>SecurityMode matching the Idris2 ABI tags (0-2).</summary>
public enum SecurityMode : byte
{
    None = 0,
    Sign = 1,
    SignAndEncrypt = 2
}

/// <summary>SessionState matching the Idris2 ABI tags (0-5).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Connected = 1,
    Created = 2,
    Activated = 3,
    Monitoring = 4,
    Closing = 5
}
