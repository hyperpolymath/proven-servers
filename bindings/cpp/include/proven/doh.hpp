// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file doh.hpp
/// @brief DoH protocol types for proven-servers.

#ifndef PROVEN_DOH_HPP
#define PROVEN_DOH_HPP

#include <cstdint>

namespace proven {

/// @brief ContentType matching the Idris2 ABI tags.
enum class ContentType : uint8_t {
    DnsMessage = 0,
    DnsJson = 1
};

/// @brief RequestMethod matching the Idris2 ABI tags.
enum class RequestMethod : uint8_t {
    Get = 0,
    Post = 1
};

/// @brief WireFormat matching the Idris2 ABI tags.
enum class WireFormat : uint8_t {
    Binary = 0,
    Json = 1
};

/// @brief ErrorReason matching the Idris2 ABI tags.
enum class ErrorReason : uint8_t {
    BadContentType = 0,
    BadMethod = 1,
    PayloadTooLarge = 2,
    UpstreamTimeout = 3,
    UpstreamError = 4
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Bound = 1,
    Serving = 2,
    Resolving = 3,
    Shutdown = 4
};

} // namespace proven

#endif // PROVEN_DOH_HPP
