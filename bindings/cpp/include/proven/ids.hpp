// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ids.hpp
/// @brief IDS protocol types for proven-servers.

#ifndef PROVEN_IDS_HPP
#define PROVEN_IDS_HPP

#include <cstdint>

namespace proven {

/// @brief AlertSeverity matching the Idris2 ABI tags.
enum class AlertSeverity : uint8_t {
    Low = 0,
    Medium = 1,
    High = 2,
    Critical = 3
};

/// @brief DetectionMethod matching the Idris2 ABI tags.
enum class DetectionMethod : uint8_t {
    Signature = 0,
    Anomaly = 1,
    Stateful = 2,
    Heuristic = 3
};

/// @brief IdsProtocol matching the Idris2 ABI tags.
enum class IdsProtocol : uint8_t {
    Tcp = 0,
    Udp = 1,
    Icmp = 2,
    Dns = 3,
    Http = 4,
    Tls = 5,
    Ssh = 6
};

/// @brief IdsAction matching the Idris2 ABI tags.
enum class IdsAction : uint8_t {
    Alert = 0,
    Drop = 1,
    Log = 2,
    Block = 3,
    Pass = 4
};

/// @brief Direction matching the Idris2 ABI tags.
enum class Direction : uint8_t {
    Inbound = 0,
    Outbound = 1,
    Both = 2
};

/// @brief ThreatLevel matching the Idris2 ABI tags.
enum class ThreatLevel : uint8_t {
    Info = 0,
    Low = 1,
    Medium = 2,
    High = 3,
    Critical = 4
};

} // namespace proven

#endif // PROVEN_IDS_HPP
