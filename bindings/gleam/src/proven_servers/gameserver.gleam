//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Game Server protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `GameserverABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// SessionType
// ===========================================================================

/// Game session types.
/// 
/// Matches `SessionType` in `GameserverABI.Types`.
pub type SessionType {
  /// Lobby (tag 0).
  Lobby
  /// Match (tag 1).
  Match
  /// Practice (tag 2).
  Practice
  /// Spectator (tag 3).
  Spectator
  /// Tournament (tag 4).
  Tournament
}

/// Convert a `SessionType` to its C-ABI tag value.
pub fn session_type_to_int(value: SessionType) -> Int {
  case value {
    Lobby -> 0
    Match -> 1
    Practice -> 2
    Spectator -> 3
    Tournament -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_type_from_int(tag: Int) -> Result(SessionType, Nil) {
  case tag {
    0 -> Ok(Lobby)
    1 -> Ok(Match)
    2 -> Ok(Practice)
    3 -> Ok(Spectator)
    4 -> Ok(Tournament)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PlayerState
// ===========================================================================

/// Game player states.
/// 
/// Matches `PlayerState` in `GameserverABI.Types`.
pub type PlayerState {
  /// Idle (tag 0).
  Idle
  /// Queuing (tag 1).
  Queuing
  /// Loading (tag 2).
  Loading
  /// Playing (tag 3).
  Playing
  /// Spectating (tag 4).
  Spectating
  /// Disconnected (tag 5).
  Disconnected
}

/// Convert a `PlayerState` to its C-ABI tag value.
pub fn player_state_to_int(value: PlayerState) -> Int {
  case value {
    Idle -> 0
    Queuing -> 1
    Loading -> 2
    Playing -> 3
    Spectating -> 4
    Disconnected -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn player_state_from_int(tag: Int) -> Result(PlayerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Queuing)
    2 -> Ok(Loading)
    3 -> Ok(Playing)
    4 -> Ok(Spectating)
    5 -> Ok(Disconnected)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// MatchState
// ===========================================================================

/// Game match states.
/// 
/// Matches `MatchState` in `GameserverABI.Types`.
pub type MatchState {
  /// Waiting (tag 0).
  Waiting
  /// Starting (tag 1).
  Starting
  /// InProgress (tag 2).
  InProgress
  /// Paused (tag 3).
  Paused
  /// Ending (tag 4).
  Ending
  /// Complete (tag 5).
  Complete
}

/// Convert a `MatchState` to its C-ABI tag value.
pub fn match_state_to_int(value: MatchState) -> Int {
  case value {
    Waiting -> 0
    Starting -> 1
    InProgress -> 2
    Paused -> 3
    Ending -> 4
    Complete -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn match_state_from_int(tag: Int) -> Result(MatchState, Nil) {
  case tag {
    0 -> Ok(Waiting)
    1 -> Ok(Starting)
    2 -> Ok(InProgress)
    3 -> Ok(Paused)
    4 -> Ok(Ending)
    5 -> Ok(Complete)
    _ -> Error(Nil)
  }
}

