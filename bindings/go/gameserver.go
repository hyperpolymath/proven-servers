// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Game Server protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// SessionType represents the SessionType type (Idris2 ABI tags).
type SessionType uint8

const (
	SessionTypeLobby SessionType = iota
	SessionTypeMatch
	SessionTypePractice
	SessionTypeSpectator
	SessionTypeTournament
)

// PlayerState represents the PlayerState type (Idris2 ABI tags).
type PlayerState uint8

const (
	PlayerStateIdle PlayerState = iota
	PlayerStateQueuing
	PlayerStateLoading
	PlayerStatePlaying
	PlayerStateSpectating
	PlayerStateDisconnected
)

// MatchState represents the MatchState type (Idris2 ABI tags).
type MatchState uint8

const (
	MatchStateWaiting MatchState = iota
	MatchStateStarting
	MatchStateInProgress
	MatchStatePaused
	MatchStateEnding
	MatchStateComplete
)
