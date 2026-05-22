// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file nts.hpp
/// @brief NTS protocol types for proven-servers.

#ifndef PROVEN_NTS_HPP
#define PROVEN_NTS_HPP

#include <cstdint>

namespace proven {

/// @brief RecordType matching the Idris2 ABI tags.
enum class RecordType : uint8_t {
    EndOfMessage = 0,
    NextProtocol = 1,
    Error = 2,
    Warning = 3,
    AeadAlgorithm = 4,
    Cookie = 5,
    CookiePlaceholder = 6,
    NtskeServer = 7,
    NtskePort = 8
};

/// @brief ErrorCode matching the Idris2 ABI tags.
enum class ErrorCode : uint8_t {
    UnrecognizedCritical = 0,
    BadRequest = 1,
    InternalError = 2
};

/// @brief AeadAlgorithm matching the Idris2 ABI tags.
enum class AeadAlgorithm : uint8_t {
    AeadAes128Gcm = 0,
    AeadAes256Gcm = 1,
    AeadAesSivCmac256 = 2
};

/// @brief HandshakeState matching the Idris2 ABI tags.
enum class HandshakeState : uint8_t {
    Initial = 0,
    Negotiating = 1,
    Established = 2,
    Failed = 3
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Handshaking = 1,
    Negotiating = 2,
    Established = 3,
    Closing = 4
};

} // namespace proven

#endif // PROVEN_NTS_HPP
