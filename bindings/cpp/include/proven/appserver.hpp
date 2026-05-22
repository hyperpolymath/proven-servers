// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file appserver.hpp
/// @brief App Server protocol types for proven-servers.

#ifndef PROVEN_APPSERVER_HPP
#define PROVEN_APPSERVER_HPP

#include <cstdint>

namespace proven {

/// @brief RequestType matching the Idris2 ABI tags.
enum class RequestType : uint8_t {
    Http = 0,
    WebSocket = 1,
    Grpc = 2,
    GraphQl = 3
};

/// @brief LifecycleState matching the Idris2 ABI tags.
enum class LifecycleState : uint8_t {
    Initializing = 0,
    Starting = 1,
    Running = 2,
    Draining = 3,
    Stopping = 4,
    Stopped = 5
};

/// @brief HealthCheck matching the Idris2 ABI tags.
enum class HealthCheck : uint8_t {
    Liveness = 0,
    Readiness = 1,
    Startup = 2
};

/// @brief DeployStrategy matching the Idris2 ABI tags.
enum class DeployStrategy : uint8_t {
    RollingUpdate = 0,
    BlueGreen = 1,
    Canary = 2,
    Recreate = 3
};

/// @brief ErrorCategory matching the Idris2 ABI tags.
enum class ErrorCategory : uint8_t {
    ClientError = 0,
    ServerError = 1,
    Timeout = 2,
    CircuitOpen = 3,
    RateLimited = 4
};

} // namespace proven

#endif // PROVEN_APPSERVER_HPP
