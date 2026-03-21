//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// NTP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `NtpABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// NTP Constants
// ===========================================================================

/// Ntp Port constant.
pub const ntp_port = 123

/// Ntp Epoch Offset constant.
pub const ntp_epoch_offset = 2208988800

// ===========================================================================
// LeapIndicator
// ===========================================================================

/// NTP leap second indicator (RFC 5905 Section 7.3).
/// 
/// Matches `LeapIndicator` in `NtpABI.Types`.
/// Uses the NTP wire values (LI field, 2 bits).
pub type LeapIndicator {
  /// No warning (tag 0).
  NoWarning
  /// Last minute of the day has 61 seconds (positive leap second) (tag 1).
  LastMinute61
  /// Last minute of the day has 59 seconds (negative leap second) (tag 2).
  LastMinute59
  /// Clock not synchronised (alarm condition) (tag 3).
  Unsynchronised
}

/// Convert a `LeapIndicator` to its C-ABI tag value.
pub fn leap_indicator_to_int(value: LeapIndicator) -> Int {
  case value {
    NoWarning -> 0
    LastMinute61 -> 1
    LastMinute59 -> 2
    Unsynchronised -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn leap_indicator_from_int(tag: Int) -> Result(LeapIndicator, Nil) {
  case tag {
    0 -> Ok(NoWarning)
    1 -> Ok(LastMinute61)
    2 -> Ok(LastMinute59)
    3 -> Ok(Unsynchronised)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NtpMode
// ===========================================================================

/// NTP association mode (RFC 5905 Section 7.3, Mode field).
/// 
/// Matches `NTPMode` in `NtpABI.Types`.
/// Uses the 3-bit NTP mode values from the wire protocol.
pub type NtpMode {
  /// Reserved (tag 0).
  Reserved
  /// Symmetric active (tag 1).
  SymmetricActive
  /// Symmetric passive (tag 2).
  SymmetricPassive
  /// Client (tag 3).
  Client
  /// Server (tag 4).
  Server
  /// Broadcast (tag 5).
  Broadcast
  /// NTP control message (tag 6).
  ControlMessage
  /// Reserved for private use (tag 7).
  Private
}

/// Convert a `NtpMode` to its C-ABI tag value.
pub fn ntp_mode_to_int(value: NtpMode) -> Int {
  case value {
    Reserved -> 0
    SymmetricActive -> 1
    SymmetricPassive -> 2
    Client -> 3
    Server -> 4
    Broadcast -> 5
    ControlMessage -> 6
    Private -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn ntp_mode_from_int(tag: Int) -> Result(NtpMode, Nil) {
  case tag {
    0 -> Ok(Reserved)
    1 -> Ok(SymmetricActive)
    2 -> Ok(SymmetricPassive)
    3 -> Ok(Client)
    4 -> Ok(Server)
    5 -> Ok(Broadcast)
    6 -> Ok(ControlMessage)
    7 -> Ok(Private)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ExchangeState
// ===========================================================================

/// NTP request/response exchange state machine.
/// 
/// Matches `ExchangeState` in `NtpABI.Types`.
pub type ExchangeState {
  /// Idle, awaiting next request (tag 0).
  Idle
  /// Client request received (tag 1).
  RequestReceived
  /// Timestamps calculated for response (tag 2).
  TimestampCalculated
  /// Response sent to client (tag 3).
  ResponseSent
}

/// Convert a `ExchangeState` to its C-ABI tag value.
pub fn exchange_state_to_int(value: ExchangeState) -> Int {
  case value {
    Idle -> 0
    RequestReceived -> 1
    TimestampCalculated -> 2
    ResponseSent -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn exchange_state_from_int(tag: Int) -> Result(ExchangeState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(RequestReceived)
    2 -> Ok(TimestampCalculated)
    3 -> Ok(ResponseSent)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn exchange_state_can_transition_to(from: ExchangeState, to: ExchangeState) -> Bool {
  case from, to {
    Idle, RequestReceived -> True
    RequestReceived, TimestampCalculated -> True
    TimestampCalculated, ResponseSent -> True
    ResponseSent, Idle -> True
    _, _ -> False
  }
}

// ===========================================================================
// ClockDisciplineState
// ===========================================================================

/// Clock discipline algorithm states (RFC 5905 Section 12).
/// 
/// Matches `ClockDisciplineState` in `NtpABI.Types`.
pub type ClockDisciplineState {
  /// Clock has not been set (tag 0).
  Unset
  /// Detected a clock spike (large offset) (tag 1).
  Spike
  /// Frequency-only discipline mode (tag 2).
  Freq
  /// Fully synchronised (phase + frequency locked) (tag 3).
  Sync
  /// Panic condition — offset too large to correct (tag 4).
  Panic
}

/// Convert a `ClockDisciplineState` to its C-ABI tag value.
pub fn clock_discipline_state_to_int(value: ClockDisciplineState) -> Int {
  case value {
    Unset -> 0
    Spike -> 1
    Freq -> 2
    Sync -> 3
    Panic -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn clock_discipline_state_from_int(tag: Int) -> Result(ClockDisciplineState, Nil) {
  case tag {
    0 -> Ok(Unset)
    1 -> Ok(Spike)
    2 -> Ok(Freq)
    3 -> Ok(Sync)
    4 -> Ok(Panic)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// KissCode
// ===========================================================================

/// NTP Kiss-o'-Death codes (RFC 5905 Section 7.4).
/// 
/// Matches `KissCode` in `NtpABI.Types`.
pub type KissCode {
  /// Access denied (DENY) (tag 0).
  Deny
  /// Access restricted (RSTR) (tag 1).
  Rstr
  /// Rate exceeded (RATE) (tag 2).
  Rate
  /// Other/unknown kiss code (tag 3).
  Other
}

/// Convert a `KissCode` to its C-ABI tag value.
pub fn kiss_code_to_int(value: KissCode) -> Int {
  case value {
    Deny -> 0
    Rstr -> 1
    Rate -> 2
    Other -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn kiss_code_from_int(tag: Int) -> Result(KissCode, Nil) {
  case tag {
    0 -> Ok(Deny)
    1 -> Ok(Rstr)
    2 -> Ok(Rate)
    3 -> Ok(Other)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NtpError
// ===========================================================================

/// NTP error codes.
/// 
/// Matches `NtpError` in `NtpABI.Types`.
pub type NtpError {
  /// No error (tag 0).
  NtpErrorOk
  /// Invalid peer slot reference (tag 1).
  InvalidSlot
  /// Peer association not active (tag 2).
  NotActive
  /// Malformed NTP packet (tag 3).
  InvalidPacket
  /// Received Kiss-o'-Death from server (tag 4).
  KissOfDeath
  /// Server stratum exceeds maximum (tag 5).
  StratumTooHigh
}

/// Convert a `NtpError` to its C-ABI tag value.
pub fn ntp_error_to_int(value: NtpError) -> Int {
  case value {
    NtpErrorOk -> 0
    InvalidSlot -> 1
    NotActive -> 2
    InvalidPacket -> 3
    KissOfDeath -> 4
    StratumTooHigh -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn ntp_error_from_int(tag: Int) -> Result(NtpError, Nil) {
  case tag {
    0 -> Ok(NtpErrorOk)
    1 -> Ok(InvalidSlot)
    2 -> Ok(NotActive)
    3 -> Ok(InvalidPacket)
    4 -> Ok(KissOfDeath)
    5 -> Ok(StratumTooHigh)
    _ -> Error(Nil)
  }
}

