// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CoAP protocol types for proven-servers.

namespace Proven;

/// <summary>Method matching the Idris2 ABI tags (0-3).</summary>
public enum Method : byte
{
    Get = 0,
    Post = 1,
    Put = 2,
    Delete = 3
}

/// <summary>MessageType matching the Idris2 ABI tags (0-3).</summary>
public enum MessageType : byte
{
    Confirmable = 0,
    NonConfirmable = 1,
    Acknowledgement = 2,
    Reset = 3
}

/// <summary>ContentFormat matching the Idris2 ABI tags (0-6).</summary>
public enum ContentFormat : byte
{
    TextPlain = 0,
    LinkFormat = 1,
    Xml = 2,
    OctetStream = 3,
    Exi = 4,
    Json = 5,
    Cbor = 6
}

/// <summary>ResponseClass matching the Idris2 ABI tags (0-4).</summary>
public enum ResponseClass : byte
{
    Success = 0,
    ClientError = 1,
    ServerError = 2,
    Signaling = 3,
    Empty = 4
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Bound = 1,
    Serving = 2,
    Observing = 3,
    Shutdown = 4
}
