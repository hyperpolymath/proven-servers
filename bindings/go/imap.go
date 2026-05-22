// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// IMAP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Command represents the Command type (Idris2 ABI tags).
type Command uint8

const (
	CommandLogin Command = iota
	CommandLogout
	CommandSelect
	CommandExamine
	CommandCreate
	CommandDelete
	CommandRename
	CommandList
	CommandFetch
	CommandStore
	CommandSearch
	CommandCopy
	CommandNoop
	CommandCapability
)

// State represents the State type (Idris2 ABI tags).
type State uint8

const (
	StateNotAuthenticated State = iota
	StateAuthenticated
	StateSelected
	StateLogout
)

// Flag represents the Flag type (Idris2 ABI tags).
type Flag uint8

const (
	FlagSeen Flag = iota
	FlagAnswered
	Flagged
	FlagDeleted
	FlagDraft
	FlagRecent
)
