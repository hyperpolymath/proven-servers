// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenGameserver protocol bindings.

open ProvenGameserver

let test_sessionType_roundtrip = () => {
  assert(sessionTypeFromTag(0) == Some(Lobby))
  assert(sessionTypeFromTag(1) == Some(Match))
  assert(sessionTypeFromTag(2) == Some(Practice))
  assert(sessionTypeFromTag(3) == Some(Spectator))
  assert(sessionTypeFromTag(4) == Some(Tournament))
  assert(sessionTypeFromTag(5) == None)
}

let test_sessionType_toTag = () => {
  assert(sessionTypeToTag(Lobby) == 0)
  assert(sessionTypeToTag(Match) == 1)
  assert(sessionTypeToTag(Practice) == 2)
  assert(sessionTypeToTag(Spectator) == 3)
  assert(sessionTypeToTag(Tournament) == 4)
}

let test_playerState_roundtrip = () => {
  assert(playerStateFromTag(0) == Some(Idle))
  assert(playerStateFromTag(1) == Some(Queuing))
  assert(playerStateFromTag(2) == Some(Loading))
  assert(playerStateFromTag(3) == Some(Playing))
  assert(playerStateFromTag(4) == Some(Spectating))
  assert(playerStateFromTag(5) == Some(Disconnected))
  assert(playerStateFromTag(6) == None)
}

let test_playerState_toTag = () => {
  assert(playerStateToTag(Idle) == 0)
  assert(playerStateToTag(Queuing) == 1)
  assert(playerStateToTag(Loading) == 2)
  assert(playerStateToTag(Playing) == 3)
  assert(playerStateToTag(Spectating) == 4)
  assert(playerStateToTag(Disconnected) == 5)
}

let test_matchState_roundtrip = () => {
  assert(matchStateFromTag(0) == Some(Waiting))
  assert(matchStateFromTag(1) == Some(Starting))
  assert(matchStateFromTag(2) == Some(InProgress))
  assert(matchStateFromTag(3) == Some(Paused))
  assert(matchStateFromTag(4) == Some(Ending))
  assert(matchStateFromTag(5) == Some(Complete))
  assert(matchStateFromTag(6) == None)
}

let test_matchState_toTag = () => {
  assert(matchStateToTag(Waiting) == 0)
  assert(matchStateToTag(Starting) == 1)
  assert(matchStateToTag(InProgress) == 2)
  assert(matchStateToTag(Paused) == 3)
  assert(matchStateToTag(Ending) == 4)
  assert(matchStateToTag(Complete) == 5)
}

// Run all tests
test_sessionType_roundtrip()
test_sessionType_toTag()
test_playerState_roundtrip()
test_playerState_toTag()
test_matchState_roundtrip()
test_matchState_toTag()
