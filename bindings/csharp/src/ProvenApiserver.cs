// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// API Server protocol types for proven-servers.

namespace Proven;

/// <summary>AuthScheme matching the Idris2 ABI tags (0-5).</summary>
public enum AuthScheme : byte
{
    ApiKey = 0,
    Bearer = 1,
    Basic = 2,
    OAuth2 = 3,
    Hmac = 4,
    Mtls = 5
}

/// <summary>RateLimitStrategy matching the Idris2 ABI tags (0-3).</summary>
public enum RateLimitStrategy : byte
{
    FixedWindow = 0,
    SlidingWindow = 1,
    TokenBucket = 2,
    LeakyBucket = 3
}

/// <summary>ApiVersion matching the Idris2 ABI tags (0-4).</summary>
public enum ApiVersion : byte
{
    V1 = 0,
    V2 = 1,
    V3 = 2,
    Latest = 3,
    Deprecated = 4
}

/// <summary>ResponseFormat matching the Idris2 ABI tags (0-3).</summary>
public enum ResponseFormat : byte
{
    Json = 0,
    Xml = 1,
    Protobuf = 2,
    MessagePack = 3
}

/// <summary>GatewayError matching the Idris2 ABI tags (0-5).</summary>
public enum GatewayError : byte
{
    Unauthorized = 0,
    RateLimited = 1,
    NotFound = 2,
    BadRequest = 3,
    ServiceUnavailable = 4,
    CircuitOpen = 5
}
