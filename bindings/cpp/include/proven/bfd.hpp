// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file bfd.hpp
/// @brief BFD protocol types for proven-servers.

#ifndef PROVEN_BFD_HPP
#define PROVEN_BFD_HPP

#include <cstdint>

namespace proven {

/// @brief BfdState matching the Idris2 ABI tags.
enum class BfdState : uint8_t {
    AdminDown = 0,
    Down = 1,
    Init = 2,
    Up = 3
};

/// @brief Diagnostic matching the Idris2 ABI tags.
enum class Diagnostic : uint8_t {
    NoDiagnostic = 0,
    ControlDetectionTimeExpired = 1,
    EchoFunctionFailed = 2,
    NeighborSignaledSessionDown = 3,
    ForwardingPlaneReset = 4,
    PathDown = 5,
    ConcatenatedPathDown = 6,
    AdministrativelyDown = 7,
    ReverseConcatenatedPathDown = 8
};

/// @brief SessionMode matching the Idris2 ABI tags.
enum class SessionMode : uint8_t {
    AsyncMode = 0,
    DemandMode = 1
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    SsDown = 1,
    Negotiating = 2,
    Established = 3,
    Teardown = 4
};

} // namespace proven

#endif // PROVEN_BFD_HPP
