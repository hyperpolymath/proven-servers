// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file deception.hpp
/// @brief Deception protocol types for proven-servers.

#ifndef PROVEN_DECEPTION_HPP
#define PROVEN_DECEPTION_HPP

#include <cstdint>

namespace proven {

/// @brief DecoyType matching the Idris2 ABI tags.
enum class DecoyType : uint8_t {
    Service = 0,
    Credential = 1,
    File = 2,
    Network = 3,
    Token = 4,
    Breadcrumb = 5
};

/// @brief TriggerEvent matching the Idris2 ABI tags.
enum class TriggerEvent : uint8_t {
    Access = 0,
    Login = 1,
    Read = 2,
    Write = 3,
    Execute = 4,
    Scan = 5
};

/// @brief AlertPriority matching the Idris2 ABI tags.
enum class AlertPriority : uint8_t {
    Low = 0,
    Medium = 1,
    High = 2,
    Critical = 3
};

/// @brief DecoyState matching the Idris2 ABI tags.
enum class DecoyState : uint8_t {
    Active = 0,
    Triggered = 1,
    Disabled = 2,
    Expired = 3
};

/// @brief ResponseAction matching the Idris2 ABI tags.
enum class ResponseAction : uint8_t {
    Alert = 0,
    Redirect = 1,
    Delay = 2,
    Fingerprint = 3,
    Isolate = 4
};

/// @brief ServerState matching the Idris2 ABI tags.
enum class ServerState : uint8_t {
    Idle = 0,
    Configured = 1,
    Monitoring = 2,
    Responding = 3,
    Shutdown = 4
};

} // namespace proven

#endif // PROVEN_DECEPTION_HPP
