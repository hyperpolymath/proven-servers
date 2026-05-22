// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Telnet protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module TelnetABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard Telnet port (RFC 854).
let telnetPort = 23

// ===========================================================================
// Command (tags 0-15)
// ===========================================================================

/// Standard Telnet port (RFC 854).
type command =
  | @as(0) Se
  | @as(1) Nop
  | @as(2) DataMark
  | @as(3) Break
  | @as(4) InterruptProcess
  | @as(5) AbortOutput
  | @as(6) AreYouThere
  | @as(7) EraseChar
  | @as(8) EraseLine
  | @as(9) GoAhead
  | @as(10) Sb
  | @as(11) Will
  | @as(12) Wont
  | @as(13) Do
  | @as(14) Dont
  | @as(15) Iac

/// Decode from the C-ABI tag value.
let commandFromTag = (tag: int): option<command> =>
  switch tag {
  | 0 => Some(Se)
  | 1 => Some(Nop)
  | 2 => Some(DataMark)
  | 3 => Some(Break)
  | 4 => Some(InterruptProcess)
  | 5 => Some(AbortOutput)
  | 6 => Some(AreYouThere)
  | 7 => Some(EraseChar)
  | 8 => Some(EraseLine)
  | 9 => Some(GoAhead)
  | 10 => Some(Sb)
  | 11 => Some(Will)
  | 12 => Some(Wont)
  | 13 => Some(Do)
  | 14 => Some(Dont)
  | 15 => Some(Iac)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let commandToTag = (v: command): int =>
  switch v {
  | Se => 0
  | Nop => 1
  | DataMark => 2
  | Break => 3
  | InterruptProcess => 4
  | AbortOutput => 5
  | AreYouThere => 6
  | EraseChar => 7
  | EraseLine => 8
  | GoAhead => 9
  | Sb => 10
  | Will => 11
  | Wont => 12
  | Do => 13
  | Dont => 14
  | Iac => 15
  }

/// Whether this command is a negotiation command (WILL/WONT/DO/DONT).
let commandIsNegotiation = (v: command): bool =>
  switch v {
  | Will | Wont | Do | Dont => true
  | _ => false
  }

// ===========================================================================
// TelnetOption (tags 0-9)
// ===========================================================================

/// Decode from an ABI tag value.
type telnetOption =
  | @as(0) Echo
  | @as(1) SuppressGoAhead
  | @as(2) Status
  | @as(3) TimingMark
  | @as(4) TerminalType
  | @as(5) WindowSize
  | @as(6) TerminalSpeed
  | @as(7) RemoteFlowControl
  | @as(8) Linemode
  | @as(9) Environment

/// Decode from the C-ABI tag value.
let telnetOptionFromTag = (tag: int): option<telnetOption> =>
  switch tag {
  | 0 => Some(Echo)
  | 1 => Some(SuppressGoAhead)
  | 2 => Some(Status)
  | 3 => Some(TimingMark)
  | 4 => Some(TerminalType)
  | 5 => Some(WindowSize)
  | 6 => Some(TerminalSpeed)
  | 7 => Some(RemoteFlowControl)
  | 8 => Some(Linemode)
  | 9 => Some(Environment)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let telnetOptionToTag = (v: telnetOption): int =>
  switch v {
  | Echo => 0
  | SuppressGoAhead => 1
  | Status => 2
  | TimingMark => 3
  | TerminalType => 4
  | WindowSize => 5
  | TerminalSpeed => 6
  | RemoteFlowControl => 7
  | Linemode => 8
  | Environment => 9
  }

// ===========================================================================
// NegotiationState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type negotiationState =
  | @as(0) Inactive
  | @as(1) WillSent
  | @as(2) DoSent
  | @as(3) Active

/// Decode from the C-ABI tag value.
let negotiationStateFromTag = (tag: int): option<negotiationState> =>
  switch tag {
  | 0 => Some(Inactive)
  | 1 => Some(WillSent)
  | 2 => Some(DoSent)
  | 3 => Some(Active)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let negotiationStateToTag = (v: negotiationState): int =>
  switch v {
  | Inactive => 0
  | WillSent => 1
  | DoSent => 2
  | Active => 3
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Negotiating
  | @as(2) Active
  | @as(3) Subneg
  | @as(4) Closing

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Negotiating)
  | 2 => Some(Active)
  | 3 => Some(Subneg)
  | 4 => Some(Closing)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Negotiating => 1
  | Active => 2
  | Subneg => 3
  | Closing => 4
  }

