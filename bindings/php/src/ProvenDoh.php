<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoH protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ContentType matching the Idris2 ABI tags. */
enum ContentType: int
{
    case DnsMessage = 0;
    case DnsJson = 1;
}

/** RequestMethod matching the Idris2 ABI tags. */
enum RequestMethod: int
{
    case Get = 0;
    case Post = 1;
}

/** WireFormat matching the Idris2 ABI tags. */
enum WireFormat: int
{
    case Binary = 0;
    case Json = 1;
}

/** ErrorReason matching the Idris2 ABI tags. */
enum ErrorReason: int
{
    case BadContentType = 0;
    case BadMethod = 1;
    case PayloadTooLarge = 2;
    case UpstreamTimeout = 3;
    case UpstreamError = 4;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Bound = 1;
    case Serving = 2;
    case Resolving = 3;
    case Shutdown = 4;
}
