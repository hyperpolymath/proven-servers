// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Game Server types for the proven-servers ABI.
//
// Mirrors the Idris2 module GameserverABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// SessionType (tags 0-4)
// ===========================================================================

/// Game session types.
type sessionType =
  | @as(0) Lobby
  | @as(1) Match
  | @as(2) Practice
  | @as(3) Spectator
  | @as(4) Tournament

/// Decode from the C-ABI tag value.
let sessionTypeFromTag = (tag: int): option<sessionType> =>
  switch tag {
  | 0 => Some(Lobby)
  | 1 => Some(Match)
  | 2 => Some(Practice)
  | 3 => Some(Spectator)
  | 4 => Some(Tournament)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionTypeToTag = (v: sessionType): int =>
  switch v {
  | Lobby => 0
  | Match => 1
  | Practice => 2
  | Spectator => 3
  | Tournament => 4
  }

// ===========================================================================
// PlayerState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type playerState =
  | @as(0) Idle
  | @as(1) Queuing
  | @as(2) Loading
  | @as(3) Playing
  | @as(4) Spectating
  | @as(5) Disconnected

/// Decode from the C-ABI tag value.
let playerStateFromTag = (tag: int): option<playerState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Queuing)
  | 2 => Some(Loading)
  | 3 => Some(Playing)
  | 4 => Some(Spectating)
  | 5 => Some(Disconnected)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let playerStateToTag = (v: playerState): int =>
  switch v {
  | Idle => 0
  | Queuing => 1
  | Loading => 2
  | Playing => 3
  | Spectating => 4
  | Disconnected => 5
  }

// ===========================================================================
// MatchState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type matchState =
  | @as(0) Waiting
  | @as(1) Starting
  | @as(2) InProgress
  | @as(3) Paused
  | @as(4) Ending
  | @as(5) Complete

/// Decode from the C-ABI tag value.
let matchStateFromTag = (tag: int): option<matchState> =>
  switch tag {
  | 0 => Some(Waiting)
  | 1 => Some(Starting)
  | 2 => Some(InProgress)
  | 3 => Some(Paused)
  | 4 => Some(Ending)
  | 5 => Some(Complete)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let matchStateToTag = (v: matchState): int =>
  switch v {
  | Waiting => 0
  | Starting => 1
  | InProgress => 2
  | Paused => 3
  | Ending => 4
  | Complete => 5
  }

