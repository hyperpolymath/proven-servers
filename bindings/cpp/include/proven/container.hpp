// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file container.hpp
/// @brief Container protocol types for proven-servers.

#ifndef PROVEN_CONTAINER_HPP
#define PROVEN_CONTAINER_HPP

#include <cstdint>

namespace proven {

/// @brief ContainerState matching the Idris2 ABI tags.
enum class ContainerState : uint8_t {
    Creating = 0,
    Running = 1,
    Paused = 2,
    Restarting = 3,
    Stopped = 4,
    Removing = 5,
    Dead = 6
};

/// @brief ContainerOperation matching the Idris2 ABI tags.
enum class ContainerOperation : uint8_t {
    Create = 0,
    Start = 1,
    Stop = 2,
    Restart = 3,
    Pause = 4,
    Unpause = 5,
    Kill = 6,
    Remove = 7,
    Exec = 8,
    Logs = 9,
    Inspect = 10
};

/// @brief NetworkMode matching the Idris2 ABI tags.
enum class NetworkMode : uint8_t {
    Bridge = 0,
    Host = 1,
    None = 2,
    Overlay = 3,
    Macvlan = 4
};

/// @brief VolumeType matching the Idris2 ABI tags.
enum class VolumeType : uint8_t {
    Bind = 0,
    Named = 1,
    Tmpfs = 2
};

/// @brief RestartPolicy matching the Idris2 ABI tags.
enum class RestartPolicy : uint8_t {
    No = 0,
    Always = 1,
    OnFailure = 2,
    UnlessStopped = 3
};

/// @brief HealthStatus matching the Idris2 ABI tags.
enum class HealthStatus : uint8_t {
    Starting = 0,
    Healthy = 1,
    Unhealthy = 2,
    NoCheck = 3
};

} // namespace proven

#endif // PROVEN_CONTAINER_HPP
