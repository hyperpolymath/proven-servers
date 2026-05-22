// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoH protocol types for proven-servers.

namespace Proven;

/// <summary>ContentType matching the Idris2 ABI tags (0-1).</summary>
public enum ContentType : byte
{
    DnsMessage = 0,
    DnsJson = 1
}

/// <summary>RequestMethod matching the Idris2 ABI tags (0-1).</summary>
public enum RequestMethod : byte
{
    Get = 0,
    Post = 1
}

/// <summary>WireFormat matching the Idris2 ABI tags (0-1).</summary>
public enum WireFormat : byte
{
    Binary = 0,
    Json = 1
}

/// <summary>ErrorReason matching the Idris2 ABI tags (0-4).</summary>
public enum ErrorReason : byte
{
    BadContentType = 0,
    BadMethod = 1,
    PayloadTooLarge = 2,
    UpstreamTimeout = 3,
    UpstreamError = 4
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Bound = 1,
    Serving = 2,
    Resolving = 3,
    Shutdown = 4
}
