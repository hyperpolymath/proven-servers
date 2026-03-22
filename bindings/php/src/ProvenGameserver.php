<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Game Server protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** SessionType matching the Idris2 ABI tags. */
enum SessionType: int
{
    case Lobby = 0;
    case Match = 1;
    case Practice = 2;
    case Spectator = 3;
    case Tournament = 4;
}

/** PlayerState matching the Idris2 ABI tags. */
enum PlayerState: int
{
    case Idle = 0;
    case Queuing = 1;
    case Loading = 2;
    case Playing = 3;
    case Spectating = 4;
    case Disconnected = 5;
}

/** MatchState matching the Idris2 ABI tags. */
enum MatchState: int
{
    case Waiting = 0;
    case Starting = 1;
    case InProgress = 2;
    case Paused = 3;
    case Ending = 4;
    case Complete = 5;
}
