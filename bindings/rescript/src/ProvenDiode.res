// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Data Diode types for the proven-servers ABI.
//
// Mirrors the Idris2 module DiodeABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Direction (tags 0-1)
// ===========================================================================

/// Diode data flow direction.
type direction =
  | @as(0) HighToLow
  | @as(1) LowToHigh

/// Decode from the C-ABI tag value.
let directionFromTag = (tag: int): option<direction> =>
  switch tag {
  | 0 => Some(HighToLow)
  | 1 => Some(LowToHigh)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let directionToTag = (v: direction): int =>
  switch v {
  | HighToLow => 0
  | LowToHigh => 1
  }

// ===========================================================================
// DiodeProtocol (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type diodeProtocol =
  | @as(0) Udp
  | @as(1) Tcp
  | @as(2) FileTransfer
  | @as(3) Syslog
  | @as(4) Snmp

/// Decode from the C-ABI tag value.
let diodeProtocolFromTag = (tag: int): option<diodeProtocol> =>
  switch tag {
  | 0 => Some(Udp)
  | 1 => Some(Tcp)
  | 2 => Some(FileTransfer)
  | 3 => Some(Syslog)
  | 4 => Some(Snmp)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let diodeProtocolToTag = (v: diodeProtocol): int =>
  switch v {
  | Udp => 0
  | Tcp => 1
  | FileTransfer => 2
  | Syslog => 3
  | Snmp => 4
  }

// ===========================================================================
// TransferState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type transferState =
  | @as(0) Queued
  | @as(1) Sending
  | @as(2) Confirming
  | @as(3) Complete
  | @as(4) Failed

/// Decode from the C-ABI tag value.
let transferStateFromTag = (tag: int): option<transferState> =>
  switch tag {
  | 0 => Some(Queued)
  | 1 => Some(Sending)
  | 2 => Some(Confirming)
  | 3 => Some(Complete)
  | 4 => Some(Failed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transferStateToTag = (v: transferState): int =>
  switch v {
  | Queued => 0
  | Sending => 1
  | Confirming => 2
  | Complete => 3
  | Failed => 4
  }

// ===========================================================================
// ValidationResult (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type validationResult =
  | @as(0) Passed
  | @as(1) FormatError
  | @as(2) SizeExceeded
  | @as(3) PolicyBlocked

/// Decode from the C-ABI tag value.
let validationResultFromTag = (tag: int): option<validationResult> =>
  switch tag {
  | 0 => Some(Passed)
  | 1 => Some(FormatError)
  | 2 => Some(SizeExceeded)
  | 3 => Some(PolicyBlocked)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let validationResultToTag = (v: validationResult): int =>
  switch v {
  | Passed => 0
  | FormatError => 1
  | SizeExceeded => 2
  | PolicyBlocked => 3
  }

// ===========================================================================
// IntegrityCheck (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type integrityCheck =
  | @as(0) Crc32
  | @as(1) Sha256
  | @as(2) Hmac

/// Decode from the C-ABI tag value.
let integrityCheckFromTag = (tag: int): option<integrityCheck> =>
  switch tag {
  | 0 => Some(Crc32)
  | 1 => Some(Sha256)
  | 2 => Some(Hmac)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let integrityCheckToTag = (v: integrityCheck): int =>
  switch v {
  | Crc32 => 0
  | Sha256 => 1
  | Hmac => 2
  }

// ===========================================================================
// GatewayState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type gatewayState =
  | @as(0) Idle
  | @as(1) Configured
  | @as(2) Transferring
  | @as(3) Validating
  | @as(4) Shutdown

/// Decode from the C-ABI tag value.
let gatewayStateFromTag = (tag: int): option<gatewayState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Configured)
  | 2 => Some(Transferring)
  | 3 => Some(Validating)
  | 4 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let gatewayStateToTag = (v: gatewayState): int =>
  switch v {
  | Idle => 0
  | Configured => 1
  | Transferring => 2
  | Validating => 3
  | Shutdown => 4
  }

