// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Telnet protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Command represents the Command type (Idris2 ABI tags).
type Command uint8

const (
	CommandSe Command = iota
	CommandNop
	CommandDataMark
	CommandBreak
	CommandInterruptProcess
	CommandAbortOutput
	CommandAreYouThere
	CommandEraseChar
	CommandEraseLine
	CommandGoAhead
	CommandSb
	CommandWill
	CommandWont
	CommandDo
	CommandDont
	CommandIac
)

// TelnetOption represents the TelnetOption type (Idris2 ABI tags).
type TelnetOption uint8

const (
	TelnetOptionEcho TelnetOption = iota
	TelnetOptionSuppressGoAhead
	TelnetOptionStatus
	TelnetOptionTimingMark
	TelnetOptionTerminalType
	TelnetOptionWindowSize
	TelnetOptionTerminalSpeed
	TelnetOptionRemoteFlowControl
	TelnetOptionLinemode
	TelnetOptionEnvironment
)

// NegotiationState represents the NegotiationState type (Idris2 ABI tags).
type NegotiationState uint8

const (
	NegotiationStateInactive NegotiationState = iota
	NegotiationStateWillSent
	NegotiationStateDoSent
	NegotiationStateActive
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateNegotiating
	SessionStateActive
	SessionStateSubneg
	SessionStateClosing
)
