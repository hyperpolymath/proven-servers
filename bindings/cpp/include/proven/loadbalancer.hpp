// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file loadbalancer.hpp
/// @brief Load Balancer protocol types for proven-servers.

#ifndef PROVEN_LOADBALANCER_HPP
#define PROVEN_LOADBALANCER_HPP

#include <cstdint>

namespace proven {

/// @brief Algorithm matching the Idris2 ABI tags.
enum class Algorithm : uint8_t {
    RoundRobin = 0,
    LeastConnections = 1,
    IpHash = 2,
    Random = 3,
    WeightedRoundRobin = 4,
    LeastResponseTime = 5
};

/// @brief HealthCheckType matching the Idris2 ABI tags.
enum class HealthCheckType : uint8_t {
    Http = 0,
    Tcp = 1,
    Grpc = 2,
    Script = 3
};

/// @brief BackendState matching the Idris2 ABI tags.
enum class BackendState : uint8_t {
    Healthy = 0,
    Unhealthy = 1,
    Draining = 2,
    Disabled = 3
};

/// @brief SessionPersistence matching the Idris2 ABI tags.
enum class SessionPersistence : uint8_t {
    None = 0,
    Cookie = 1,
    SourceIp = 2,
    Header = 3
};

/// @brief LbProtocol matching the Idris2 ABI tags.
enum class LbProtocol : uint8_t {
    Http = 0,
    Https = 1,
    Tcp = 2,
    Udp = 3,
    Grpc = 4
};

} // namespace proven

#endif // PROVEN_LOADBALANCER_HPP
