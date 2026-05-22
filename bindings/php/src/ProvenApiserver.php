<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// API Server protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** AuthScheme matching the Idris2 ABI tags. */
enum AuthScheme: int
{
    case ApiKey = 0;
    case Bearer = 1;
    case Basic = 2;
    case OAuth2 = 3;
    case Hmac = 4;
    case Mtls = 5;
}

/** RateLimitStrategy matching the Idris2 ABI tags. */
enum RateLimitStrategy: int
{
    case FixedWindow = 0;
    case SlidingWindow = 1;
    case TokenBucket = 2;
    case LeakyBucket = 3;
}

/** ApiVersion matching the Idris2 ABI tags. */
enum ApiVersion: int
{
    case V1 = 0;
    case V2 = 1;
    case V3 = 2;
    case Latest = 3;
    case Deprecated = 4;
}

/** ResponseFormat matching the Idris2 ABI tags. */
enum ResponseFormat: int
{
    case Json = 0;
    case Xml = 1;
    case Protobuf = 2;
    case MessagePack = 3;
}

/** GatewayError matching the Idris2 ABI tags. */
enum GatewayError: int
{
    case Unauthorized = 0;
    case RateLimited = 1;
    case NotFound = 2;
    case BadRequest = 3;
    case ServiceUnavailable = 4;
    case CircuitOpen = 5;
}
