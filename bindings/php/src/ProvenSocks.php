<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SOCKS5 protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** AuthMethod matching the Idris2 ABI tags. */
enum AuthMethod: int
{
    case NoAuth = 0;
    case Gssapi = 1;
    case UsernamePassword = 2;
    case NoAcceptable = 3;
}

/** Command matching the Idris2 ABI tags. */
enum Command: int
{
    case Connect = 0;
    case Bind = 1;
    case UdpAssociate = 2;
}

/** AddressType matching the Idris2 ABI tags. */
enum AddressType: int
{
    case IPv4 = 0;
    case DomainName = 1;
    case IPv6 = 2;
}

/** Reply matching the Idris2 ABI tags. */
enum Reply: int
{
    case Succeeded = 0;
    case GeneralFailure = 1;
    case NotAllowed = 2;
    case NetworkUnreachable = 3;
    case HostUnreachable = 4;
    case ConnectionRefused = 5;
    case TtlExpired = 6;
    case CommandNotSupported = 7;
    case AddressTypeNotSupported = 8;
}

/** State matching the Idris2 ABI tags. */
enum State: int
{
    case Initial = 0;
    case Authenticating = 1;
    case Authenticated = 2;
    case Connecting = 3;
    case Established = 4;
    case Closed = 5;
}
