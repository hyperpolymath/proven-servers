//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Telnet (INSECURE) protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `TelnetABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Telnet (INSECURE) Constants
// ===========================================================================

/// Telnet Port constant.
pub const telnet_port = 23

// ===========================================================================
// Command
// ===========================================================================

/// Telnet protocol commands (RFC 854).
/// 
/// Matches `Command` in `TelnetABI.Types`.
pub type Command {
  /// SE — End of subnegotiation (tag 0).
  Se
  /// NOP — No operation (tag 1).
  Nop
  /// Data Mark (tag 2).
  DataMark
  /// Break (tag 3).
  Break
  /// Interrupt Process (tag 4).
  InterruptProcess
  /// Abort Output (tag 5).
  AbortOutput
  /// Are You There (tag 6).
  AreYouThere
  /// Erase Character (tag 7).
  EraseChar
  /// Erase Line (tag 8).
  EraseLine
  /// Go Ahead (tag 9).
  GoAhead
  /// SB — Begin subnegotiation (tag 10).
  Sb
  /// WILL — sender wants to enable option (tag 11).
  Will
  /// WONT — sender refuses to enable option (tag 12).
  Wont
  /// DO — sender wants receiver to enable option (tag 13).
  Do
  /// DONT — sender wants receiver to disable option (tag 14).
  Dont
  /// IAC — Interpret As Command escape (tag 15).
  Iac
}

/// Convert a `Command` to its C-ABI tag value.
pub fn command_to_int(value: Command) -> Int {
  case value {
    Se -> 0
    Nop -> 1
    DataMark -> 2
    Break -> 3
    InterruptProcess -> 4
    AbortOutput -> 5
    AreYouThere -> 6
    EraseChar -> 7
    EraseLine -> 8
    GoAhead -> 9
    Sb -> 10
    Will -> 11
    Wont -> 12
    Do -> 13
    Dont -> 14
    Iac -> 15
  }
}

/// Decode from a C-ABI tag value.
pub fn command_from_int(tag: Int) -> Result(Command, Nil) {
  case tag {
    0 -> Ok(Se)
    1 -> Ok(Nop)
    2 -> Ok(DataMark)
    3 -> Ok(Break)
    4 -> Ok(InterruptProcess)
    5 -> Ok(AbortOutput)
    6 -> Ok(AreYouThere)
    7 -> Ok(EraseChar)
    8 -> Ok(EraseLine)
    9 -> Ok(GoAhead)
    10 -> Ok(Sb)
    11 -> Ok(Will)
    12 -> Ok(Wont)
    13 -> Ok(Do)
    14 -> Ok(Dont)
    15 -> Ok(Iac)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TelnetOption
// ===========================================================================

/// Telnet options (RFC 854, RFC 1091, RFC 1073, etc.).
/// 
/// Matches `Option` in `TelnetABI.Types`.
pub type TelnetOption {
  /// Echo (tag 0).
  Echo
  /// Suppress Go Ahead (tag 1).
  SuppressGoAhead
  /// Status (tag 2).
  Status
  /// Timing Mark (tag 3).
  TimingMark
  /// Terminal Type (tag 4).
  TerminalType
  /// Window Size — NAWS (tag 5).
  WindowSize
  /// Terminal Speed (tag 6).
  TerminalSpeed
  /// Remote Flow Control (tag 7).
  RemoteFlowControl
  /// Linemode (tag 8).
  Linemode
  /// Environment Variables (tag 9).
  Environment
}

/// Convert a `TelnetOption` to its C-ABI tag value.
pub fn telnet_option_to_int(value: TelnetOption) -> Int {
  case value {
    Echo -> 0
    SuppressGoAhead -> 1
    Status -> 2
    TimingMark -> 3
    TerminalType -> 4
    WindowSize -> 5
    TerminalSpeed -> 6
    RemoteFlowControl -> 7
    Linemode -> 8
    Environment -> 9
  }
}

/// Decode from a C-ABI tag value.
pub fn telnet_option_from_int(tag: Int) -> Result(TelnetOption, Nil) {
  case tag {
    0 -> Ok(Echo)
    1 -> Ok(SuppressGoAhead)
    2 -> Ok(Status)
    3 -> Ok(TimingMark)
    4 -> Ok(TerminalType)
    5 -> Ok(WindowSize)
    6 -> Ok(TerminalSpeed)
    7 -> Ok(RemoteFlowControl)
    8 -> Ok(Linemode)
    9 -> Ok(Environment)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NegotiationState
// ===========================================================================

/// Telnet option negotiation state.
/// 
/// Matches `NegotiationState` in `TelnetABI.Types`.
pub type NegotiationState {
  /// Option inactive (tag 0).
  Inactive
  /// WILL sent, awaiting response (tag 1).
  WillSent
  /// DO sent, awaiting response (tag 2).
  DoSent
  /// Option active (tag 3).
  NegotiationStateActive
}

/// Convert a `NegotiationState` to its C-ABI tag value.
pub fn negotiation_state_to_int(value: NegotiationState) -> Int {
  case value {
    Inactive -> 0
    WillSent -> 1
    DoSent -> 2
    NegotiationStateActive -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn negotiation_state_from_int(tag: Int) -> Result(NegotiationState, Nil) {
  case tag {
    0 -> Ok(Inactive)
    1 -> Ok(WillSent)
    2 -> Ok(DoSent)
    3 -> Ok(NegotiationStateActive)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// Telnet session lifecycle states.
/// 
/// Matches `SessionState` in `TelnetABI.Types`.
/// **INSECURE PROTOCOL** — for legacy interoperability only.
pub type SessionState {
  /// No connection (tag 0).
  Idle
  /// Connection established, negotiation in progress (tag 1).
  Negotiating
  /// Negotiation complete, data transfer active (tag 2).
  SessionStateActive
  /// Subnegotiation in progress (tag 3).
  Subneg
  /// Connection closing (tag 4).
  Closing
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Negotiating -> 1
    SessionStateActive -> 2
    Subneg -> 3
    Closing -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Negotiating)
    2 -> Ok(SessionStateActive)
    3 -> Ok(Subneg)
    4 -> Ok(Closing)
    _ -> Error(Nil)
  }
}

