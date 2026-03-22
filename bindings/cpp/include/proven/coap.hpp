// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file coap.hpp
/// @brief CoAP protocol types for proven-servers.

#ifndef PROVEN_COAP_HPP
#define PROVEN_COAP_HPP

#include <cstdint>

namespace proven {

/// @brief Method matching the Idris2 ABI tags.
enum class Method : uint8_t {
    Get = 0,
    Post = 1,
    Put = 2,
    Delete = 3
};

/// @brief MessageType matching the Idris2 ABI tags.
enum class MessageType : uint8_t {
    Confirmable = 0,
    NonConfirmable = 1,
    Acknowledgement = 2,
    Reset = 3
};

/// @brief ContentFormat matching the Idris2 ABI tags.
enum class ContentFormat : uint8_t {
    TextPlain = 0,
    LinkFormat = 1,
    Xml = 2,
    OctetStream = 3,
    Exi = 4,
    Json = 5,
    Cbor = 6
};

/// @brief ResponseClass matching the Idris2 ABI tags.
enum class ResponseClass : uint8_t {
    Success = 0,
    ClientError = 1,
    ServerError = 2,
    Signaling = 3,
    Empty = 4
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Bound = 1,
    Serving = 2,
    Observing = 3,
    Shutdown = 4
};

} // namespace proven

#endif // PROVEN_COAP_HPP
