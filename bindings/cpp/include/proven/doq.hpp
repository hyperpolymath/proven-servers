// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file doq.hpp
/// @brief DoQ protocol types for proven-servers.

#ifndef PROVEN_DOQ_HPP
#define PROVEN_DOQ_HPP

#include <cstdint>

namespace proven {

/// @brief StreamType matching the Idris2 ABI tags.
enum class StreamType : uint8_t {
    Unidirectional = 0,
    Bidirectional = 1
};

/// @brief ErrorCode matching the Idris2 ABI tags.
enum class ErrorCode : uint8_t {
    NoError = 0,
    InternalError = 1,
    ExcessiveLoad = 2,
    ProtocolError = 3
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Initial = 0,
    Handshaking = 1,
    Ready = 2,
    Draining = 3,
    Closed = 4
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

#endif // PROVEN_DOQ_HPP
