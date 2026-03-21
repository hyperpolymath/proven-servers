// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module NtpABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard NTP port (RFC 5905).
let ntpPort = 123

/// Offset from Unix epoch (1 January 1970) in seconds.
let ntpEpochOffset = 2208988800.0

// ===========================================================================
// LeapIndicator (tags 0-3)
// ===========================================================================

/// Standard NTP port (RFC 5905).
type leapIndicator =
  | @as(0) NoWarning
  | @as(1) LastMinute61
  | @as(2) LastMinute59
  | @as(3) Unsynchronised

/// Decode from the C-ABI tag value.
let leapIndicatorFromTag = (tag: int): option<leapIndicator> =>
  switch tag {
  | 0 => Some(NoWarning)
  | 1 => Some(LastMinute61)
  | 2 => Some(LastMinute59)
  | 3 => Some(Unsynchronised)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let leapIndicatorToTag = (v: leapIndicator): int =>
  switch v {
  | NoWarning => 0
  | LastMinute61 => 1
  | LastMinute59 => 2
  | Unsynchronised => 3
  }

/// Whether the clock is considered synchronised.
let leapIndicatorIsSynchronised = (v: leapIndicator): bool =>
  switch v {
  | Unsynchronised => false
  | _ => true
  }

/// Whether a leap second adjustment is pending.
let leapIndicatorHasLeapSecond = (v: leapIndicator): bool =>
  switch v {
  | LastMinute61 | LastMinute59 => true
  | _ => false
  }

// ===========================================================================
// NtpMode (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type ntpMode =
  | @as(0) Reserved
  | @as(1) SymmetricActive
  | @as(2) SymmetricPassive
  | @as(3) Client
  | @as(4) Server
  | @as(5) Broadcast
  | @as(6) ControlMessage
  | @as(7) Private

/// Decode from the C-ABI tag value.
let ntpModeFromTag = (tag: int): option<ntpMode> =>
  switch tag {
  | 0 => Some(Reserved)
  | 1 => Some(SymmetricActive)
  | 2 => Some(SymmetricPassive)
  | 3 => Some(Client)
  | 4 => Some(Server)
  | 5 => Some(Broadcast)
  | 6 => Some(ControlMessage)
  | 7 => Some(Private)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ntpModeToTag = (v: ntpMode): int =>
  switch v {
  | Reserved => 0
  | SymmetricActive => 1
  | SymmetricPassive => 2
  | Client => 3
  | Server => 4
  | Broadcast => 5
  | ControlMessage => 6
  | Private => 7
  }

/// (as opposed to control or reserved).
let ntpModeIsTimeSync = (v: ntpMode): bool =>
  switch v {
  | SymmetricActive | SymmetricPassive | Client | Server | Broadcast => true
  | _ => false
  }

// ===========================================================================
// ExchangeState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type exchangeState =
  | @as(0) Idle
  | @as(1) RequestReceived
  | @as(2) TimestampCalculated
  | @as(3) ResponseSent

/// Decode from the C-ABI tag value.
let exchangeStateFromTag = (tag: int): option<exchangeState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(RequestReceived)
  | 2 => Some(TimestampCalculated)
  | 3 => Some(ResponseSent)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let exchangeStateToTag = (v: exchangeState): int =>
  switch v {
  | Idle => 0
  | RequestReceived => 1
  | TimestampCalculated => 2
  | ResponseSent => 3
  }

/// Validate whether a state transition is allowed.
let exchangeStateCanTransitionTo = (from: exchangeState, to: exchangeState): bool =>
  switch (from, to) {
  | _ => false
  }

// ===========================================================================
// ClockDisciplineState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type clockDisciplineState =
  | @as(0) Unset
  | @as(1) Spike
  | @as(2) Freq
  | @as(3) Sync
  | @as(4) Panic

/// Decode from the C-ABI tag value.
let clockDisciplineStateFromTag = (tag: int): option<clockDisciplineState> =>
  switch tag {
  | 0 => Some(Unset)
  | 1 => Some(Spike)
  | 2 => Some(Freq)
  | 3 => Some(Sync)
  | 4 => Some(Panic)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let clockDisciplineStateToTag = (v: clockDisciplineState): int =>
  switch v {
  | Unset => 0
  | Spike => 1
  | Freq => 2
  | Sync => 3
  | Panic => 4
  }

/// Whether the clock is in a healthy state.
let clockDisciplineStateIsHealthy = (v: clockDisciplineState): bool =>
  switch v {
  | Freq | Sync => true
  | _ => false
  }

/// Whether the clock requires operator intervention.
let clockDisciplineStateNeedsIntervention = (v: clockDisciplineState): bool =>
  switch v {
  | Panic => true
  | _ => false
  }

// ===========================================================================
// KissCode (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type kissCode =
  | @as(0) Deny
  | @as(1) Rstr
  | @as(2) Rate
  | @as(3) Other

/// Decode from the C-ABI tag value.
let kissCodeFromTag = (tag: int): option<kissCode> =>
  switch tag {
  | 0 => Some(Deny)
  | 1 => Some(Rstr)
  | 2 => Some(Rate)
  | 3 => Some(Other)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let kissCodeToTag = (v: kissCode): int =>
  switch v {
  | Deny => 0
  | Rstr => 1
  | Rate => 2
  | Other => 3
  }

/// Whether the client should stop querying this server.
let kissCodeShouldStop = (v: kissCode): bool =>
  switch v {
  | Deny | Rstr => true
  | _ => false
  }

// ===========================================================================
// NtpError (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type ntpError =
  | @as(0) Ok
  | @as(1) InvalidSlot
  | @as(2) NotActive
  | @as(3) InvalidPacket
  | @as(4) KissOfDeath
  | @as(5) StratumTooHigh

/// Decode from the C-ABI tag value.
let ntpErrorFromTag = (tag: int): option<ntpError> =>
  switch tag {
  | 0 => Some(Ok)
  | 1 => Some(InvalidSlot)
  | 2 => Some(NotActive)
  | 3 => Some(InvalidPacket)
  | 4 => Some(KissOfDeath)
  | 5 => Some(StratumTooHigh)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ntpErrorToTag = (v: ntpError): int =>
  switch v {
  | Ok => 0
  | InvalidSlot => 1
  | NotActive => 2
  | InvalidPacket => 3
  | KissOfDeath => 4
  | StratumTooHigh => 5
  }

/// Whether this represents a successful outcome.
let ntpErrorIsOk = (v: ntpError): bool =>
  switch v {
  | Ok => true
  | _ => false
  }

/// Whether this error indicates a problem with the remote server.
let ntpErrorIsRemoteError = (v: ntpError): bool =>
  switch v {
  | KissOfDeath | StratumTooHigh => true
  | _ => false
  }

