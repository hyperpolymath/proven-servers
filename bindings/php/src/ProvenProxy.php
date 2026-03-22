<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Proxy protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ProxyMode matching the Idris2 ABI tags. */
enum ProxyMode: int
{
    case Forward = 0;
    case Reverse = 1;
}

/** HopByHopHeader matching the Idris2 ABI tags. */
enum HopByHopHeader: int
{
    case Connection = 0;
    case KeepAlive = 1;
    case ProxyAuth = 2;
    case ProxyAuthz = 3;
    case Te = 4;
    case Trailers = 5;
    case TransferEncoding = 6;
    case Upgrade = 7;
}

/** CacheDirective matching the Idris2 ABI tags. */
enum CacheDirective: int
{
    case NoCache = 0;
    case NoStore = 1;
    case MaxAge = 2;
    case Public = 3;
    case Private = 4;
    case MustRevalidate = 5;
}

/** ProxyError matching the Idris2 ABI tags. */
enum ProxyError: int
{
    case BadGateway = 0;
    case GatewayTimeout = 1;
    case UpstreamRefused = 2;
    case UpstreamTls = 3;
}
