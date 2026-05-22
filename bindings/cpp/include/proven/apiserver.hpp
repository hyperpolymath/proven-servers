// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file apiserver.hpp
/// @brief API Server protocol types for proven-servers.

#ifndef PROVEN_APISERVER_HPP
#define PROVEN_APISERVER_HPP

#include <cstdint>

namespace proven {

/// @brief AuthScheme matching the Idris2 ABI tags.
enum class AuthScheme : uint8_t {
    ApiKey = 0,
    Bearer = 1,
    Basic = 2,
    OAuth2 = 3,
    Hmac = 4,
    Mtls = 5
};

/// @brief RateLimitStrategy matching the Idris2 ABI tags.
enum class RateLimitStrategy : uint8_t {
    FixedWindow = 0,
    SlidingWindow = 1,
    TokenBucket = 2,
    LeakyBucket = 3
};

/// @brief ApiVersion matching the Idris2 ABI tags.
enum class ApiVersion : uint8_t {
    V1 = 0,
    V2 = 1,
    V3 = 2,
    Latest = 3,
    Deprecated = 4
};

/// @brief ResponseFormat matching the Idris2 ABI tags.
enum class ResponseFormat : uint8_t {
    Json = 0,
    Xml = 1,
    Protobuf = 2,
    MessagePack = 3
};

/// @brief GatewayError matching the Idris2 ABI tags.
enum class GatewayError : uint8_t {
    Unauthorized = 0,
    RateLimited = 1,
    NotFound = 2,
    BadRequest = 3,
    ServiceUnavailable = 4,
    CircuitOpen = 5
};

} // namespace proven

#endif // PROVEN_APISERVER_HPP
