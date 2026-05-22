// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// POP3 protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Command represents the Command type (Idris2 ABI tags).
type Command uint8

const (
	CommandUser Command = iota
	CommandPass
	CommandStat
	CommandList
	CommandRetr
	CommandDele
	CommandNoop
	CommandRset
	CommandQuit
	CommandTop
	CommandUidl
)

// State represents the State type (Idris2 ABI tags).
type State uint8

const (
	StateAuthorization State = iota
	StateTransaction
	StateUpdate
)

// Response represents the Response type (Idris2 ABI tags).
type Response uint8

const (
	ResponseOk Response = iota
	ResponseErr
)

// Pop3Error represents the Pop3Error type (Idris2 ABI tags).
type Pop3Error uint8

const (
	Pop3ErrorOk Pop3Error = iota
	Pop3ErrorInvalidSlot
	Pop3ErrorNotActive
	Pop3ErrorInvalidTransition
	Pop3ErrorInvalidCommand
	Pop3ErrorAuthFailed
)
