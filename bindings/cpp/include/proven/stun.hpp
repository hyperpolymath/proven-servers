// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file stun.hpp
/// @brief STUN/TURN protocol types for proven-servers.

#ifndef PROVEN_STUN_HPP
#define PROVEN_STUN_HPP

#include <cstdint>

namespace proven {

/// @brief MessageType matching the Idris2 ABI tags.
enum class MessageType : uint8_t {
    BindingRequest = 0,
    BindingResponse = 1,
    BindingError = 2,
    AllocateRequest = 3,
    AllocateResponse = 4,
    AllocateError = 5,
    RefreshRequest = 6,
    RefreshResponse = 7,
    SendIndication = 8,
    DataIndication = 9,
    CreatePermission = 10,
    ChannelBind = 11
};

/// @brief TransportProtocol matching the Idris2 ABI tags.
enum class TransportProtocol : uint8_t {
    Udp = 0,
    Tcp = 1,
    Tls = 2,
    Dtls = 3
};

/// @brief ErrorCode matching the Idris2 ABI tags.
enum class ErrorCode : uint8_t {
    TryAlternate = 0,
    BadRequest = 1,
    Unauthorized = 2,
    Forbidden = 3,
    MobilityForbidden = 4,
    StaleNonce = 5,
    ServerError = 6,
    InsufficientCapacity = 7
};

} // namespace proven

#endif // PROVEN_STUN_HPP
