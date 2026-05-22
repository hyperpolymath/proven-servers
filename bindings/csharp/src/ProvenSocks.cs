// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SOCKS5 protocol types for proven-servers.

namespace Proven;

/// <summary>AuthMethod matching the Idris2 ABI tags (0-3).</summary>
public enum AuthMethod : byte
{
    NoAuth = 0,
    Gssapi = 1,
    UsernamePassword = 2,
    NoAcceptable = 3
}

/// <summary>Command matching the Idris2 ABI tags (0-2).</summary>
public enum Command : byte
{
    Connect = 0,
    Bind = 1,
    UdpAssociate = 2
}

/// <summary>AddressType matching the Idris2 ABI tags (0-2).</summary>
public enum AddressType : byte
{
    IPv4 = 0,
    DomainName = 1,
    IPv6 = 2
}

/// <summary>Reply matching the Idris2 ABI tags (0-8).</summary>
public enum Reply : byte
{
    Succeeded = 0,
    GeneralFailure = 1,
    NotAllowed = 2,
    NetworkUnreachable = 3,
    HostUnreachable = 4,
    ConnectionRefused = 5,
    TtlExpired = 6,
    CommandNotSupported = 7,
    AddressTypeNotSupported = 8
}

/// <summary>State matching the Idris2 ABI tags (0-5).</summary>
public enum State : byte
{
    Initial = 0,
    Authenticating = 1,
    Authenticated = 2,
    Connecting = 3,
    Established = 4,
    Closed = 5
}
