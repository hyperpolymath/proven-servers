// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file socks.hpp
/// @brief SOCKS5 protocol types for proven-servers.

#ifndef PROVEN_SOCKS_HPP
#define PROVEN_SOCKS_HPP

#include <cstdint>

namespace proven {

/// @brief AuthMethod matching the Idris2 ABI tags.
enum class AuthMethod : uint8_t {
    NoAuth = 0,
    Gssapi = 1,
    UsernamePassword = 2,
    NoAcceptable = 3
};

/// @brief Command matching the Idris2 ABI tags.
enum class Command : uint8_t {
    Connect = 0,
    Bind = 1,
    UdpAssociate = 2
};

/// @brief AddressType matching the Idris2 ABI tags.
enum class AddressType : uint8_t {
    IPv4 = 0,
    DomainName = 1,
    IPv6 = 2
};

/// @brief Reply matching the Idris2 ABI tags.
enum class Reply : uint8_t {
    Succeeded = 0,
    GeneralFailure = 1,
    NotAllowed = 2,
    NetworkUnreachable = 3,
    HostUnreachable = 4,
    ConnectionRefused = 5,
    TtlExpired = 6,
    CommandNotSupported = 7,
    AddressTypeNotSupported = 8
};

/// @brief State matching the Idris2 ABI tags.
enum class State : uint8_t {
    Initial = 0,
    Authenticating = 1,
    Authenticated = 2,
    Connecting = 3,
    Established = 4,
    Closed = 5
};

} // namespace proven

#endif // PROVEN_SOCKS_HPP
