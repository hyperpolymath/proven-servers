// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Proxy protocol types for proven-servers.

namespace Proven;

/// <summary>ProxyMode matching the Idris2 ABI tags (0-1).</summary>
public enum ProxyMode : byte
{
    Forward = 0,
    Reverse = 1
}

/// <summary>HopByHopHeader matching the Idris2 ABI tags (0-7).</summary>
public enum HopByHopHeader : byte
{
    Connection = 0,
    KeepAlive = 1,
    ProxyAuth = 2,
    ProxyAuthz = 3,
    Te = 4,
    Trailers = 5,
    TransferEncoding = 6,
    Upgrade = 7
}

/// <summary>CacheDirective matching the Idris2 ABI tags (0-5).</summary>
public enum CacheDirective : byte
{
    NoCache = 0,
    NoStore = 1,
    MaxAge = 2,
    Public = 3,
    Private = 4,
    MustRevalidate = 5
}

/// <summary>ProxyError matching the Idris2 ABI tags (0-3).</summary>
public enum ProxyError : byte
{
    BadGateway = 0,
    GatewayTimeout = 1,
    UpstreamRefused = 2,
    UpstreamTls = 3
}
