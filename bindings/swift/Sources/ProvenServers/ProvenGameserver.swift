// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Game Server protocol types for proven-servers.

/// SessionType matching the Idris2 ABI tags.
public enum SessionType: UInt8, CaseIterable, Sendable {
    case lobby = 0
    case match = 1
    case practice = 2
    case spectator = 3
    case tournament = 4
}

/// PlayerState matching the Idris2 ABI tags.
public enum PlayerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case queuing = 1
    case loading = 2
    case playing = 3
    case spectating = 4
    case disconnected = 5
}

/// MatchState matching the Idris2 ABI tags.
public enum MatchState: UInt8, CaseIterable, Sendable {
    case waiting = 0
    case starting = 1
    case inProgress = 2
    case paused = 3
    case ending = 4
    case complete = 5
}
