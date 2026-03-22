// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file gameserver.hpp
/// @brief Game Server protocol types for proven-servers.

#ifndef PROVEN_GAMESERVER_HPP
#define PROVEN_GAMESERVER_HPP

#include <cstdint>

namespace proven {

/// @brief SessionType matching the Idris2 ABI tags.
enum class SessionType : uint8_t {
    Lobby = 0,
    Match = 1,
    Practice = 2,
    Spectator = 3,
    Tournament = 4
};

/// @brief PlayerState matching the Idris2 ABI tags.
enum class PlayerState : uint8_t {
    Idle = 0,
    Queuing = 1,
    Loading = 2,
    Playing = 3,
    Spectating = 4,
    Disconnected = 5
};

/// @brief MatchState matching the Idris2 ABI tags.
enum class MatchState : uint8_t {
    Waiting = 0,
    Starting = 1,
    InProgress = 2,
    Paused = 3,
    Ending = 4,
    Complete = 5
};

} // namespace proven

#endif // PROVEN_GAMESERVER_HPP
