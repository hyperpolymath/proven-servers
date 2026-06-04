// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Game Server protocol types for proven-servers.

/** SessionType matching the Idris2 ABI tags. */
export const SessionType = Object.freeze({
  LOBBY: 0,
  MATCH: 1,
  PRACTICE: 2,
  SPECTATOR: 3,
  TOURNAMENT: 4,
});

/** PlayerState matching the Idris2 ABI tags. */
export const PlayerState = Object.freeze({
  IDLE: 0,
  QUEUING: 1,
  LOADING: 2,
  PLAYING: 3,
  SPECTATING: 4,
  DISCONNECTED: 5,
});

/** MatchState matching the Idris2 ABI tags. */
export const MatchState = Object.freeze({
  WAITING: 0,
  STARTING: 1,
  IN_PROGRESS: 2,
  PAUSED: 3,
  ENDING: 4,
  COMPLETE: 5,
});
