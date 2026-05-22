// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Game Server protocol types for proven-servers.

namespace Proven;

/// <summary>SessionType matching the Idris2 ABI tags (0-4).</summary>
public enum SessionType : byte
{
    Lobby = 0,
    Match = 1,
    Practice = 2,
    Spectator = 3,
    Tournament = 4
}

/// <summary>PlayerState matching the Idris2 ABI tags (0-5).</summary>
public enum PlayerState : byte
{
    Idle = 0,
    Queuing = 1,
    Loading = 2,
    Playing = 3,
    Spectating = 4,
    Disconnected = 5
}

/// <summary>MatchState matching the Idris2 ABI tags (0-5).</summary>
public enum MatchState : byte
{
    Waiting = 0,
    Starting = 1,
    InProgress = 2,
    Paused = 3,
    Ending = 4,
    Complete = 5
}
