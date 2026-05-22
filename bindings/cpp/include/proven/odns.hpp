// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file odns.hpp
/// @brief ODNS protocol types for proven-servers.

#ifndef PROVEN_ODNS_HPP
#define PROVEN_ODNS_HPP

#include <cstdint>

namespace proven {

/// @brief Role matching the Idris2 ABI tags.
enum class Role : uint8_t {
    Client = 0,
    Proxy = 1,
    Target = 2
};

/// @brief OdnsMessageType matching the Idris2 ABI tags.
enum class OdnsMessageType : uint8_t {
    Query = 0,
    Response = 1
};

/// @brief OdnsErrorReason matching the Idris2 ABI tags.
enum class OdnsErrorReason : uint8_t {
    ProxyError = 0,
    TargetError = 1,
    DecryptionFailed = 2,
    InvalidConfig = 3,
    PayloadTooLarge = 4
};

/// @brief EncapsulationFormat matching the Idris2 ABI tags.
enum class EncapsulationFormat : uint8_t {
    Hpke = 0
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    KeyExchange = 1,
    Ready = 2,
    Processing = 3,
    Closing = 4
};

} // namespace proven

#endif // PROVEN_ODNS_HPP
