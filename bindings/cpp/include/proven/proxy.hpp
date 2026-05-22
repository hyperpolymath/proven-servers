// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file proxy.hpp
/// @brief Proxy protocol types for proven-servers.

#ifndef PROVEN_PROXY_HPP
#define PROVEN_PROXY_HPP

#include <cstdint>

namespace proven {

/// @brief ProxyMode matching the Idris2 ABI tags.
enum class ProxyMode : uint8_t {
    Forward = 0,
    Reverse = 1
};

/// @brief HopByHopHeader matching the Idris2 ABI tags.
enum class HopByHopHeader : uint8_t {
    Connection = 0,
    KeepAlive = 1,
    ProxyAuth = 2,
    ProxyAuthz = 3,
    Te = 4,
    Trailers = 5,
    TransferEncoding = 6,
    Upgrade = 7
};

/// @brief CacheDirective matching the Idris2 ABI tags.
enum class CacheDirective : uint8_t {
    NoCache = 0,
    NoStore = 1,
    MaxAge = 2,
    Public = 3,
    Private = 4,
    MustRevalidate = 5
};

/// @brief ProxyError matching the Idris2 ABI tags.
enum class ProxyError : uint8_t {
    BadGateway = 0,
    GatewayTimeout = 1,
    UpstreamRefused = 2,
    UpstreamTls = 3
};

} // namespace proven

#endif // PROVEN_PROXY_HPP
