// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file dot.hpp
/// @brief DoT protocol types for proven-servers.

#ifndef PROVEN_DOT_HPP
#define PROVEN_DOT_HPP

#include <cstdint>

namespace proven {

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Connecting = 0,
    Handshaking = 1,
    Established = 2,
    Closing = 3,
    Closed = 4
};

/// @brief PaddingStrategy matching the Idris2 ABI tags.
enum class PaddingStrategy : uint8_t {
    NoPadding = 0,
    BlockPadding = 1,
    RandomPadding = 2
};

/// @brief ErrorReason matching the Idris2 ABI tags.
enum class ErrorReason : uint8_t {
    HandshakeFailed = 0,
    CertificateInvalid = 1,
    Timeout = 2,
    UpstreamError = 3
};

/// @brief ServerState matching the Idris2 ABI tags.
enum class ServerState : uint8_t {
    Idle = 0,
    Bound = 1,
    Listening = 2,
    Processing = 3,
    Shutdown = 4
};

} // namespace proven

#endif // PROVEN_DOT_HPP
