//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Data Diode protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `DiodeABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Direction
// ===========================================================================

/// Diode data flow direction.
/// 
/// Matches `Direction` in `DiodeABI.Types`.
pub type Direction {
  /// HighToLow (tag 0).
  HighToLow
  /// LowToHigh (tag 1).
  LowToHigh
}

/// Convert a `Direction` to its C-ABI tag value.
pub fn direction_to_int(value: Direction) -> Int {
  case value {
    HighToLow -> 0
    LowToHigh -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn direction_from_int(tag: Int) -> Result(Direction, Nil) {
  case tag {
    0 -> Ok(HighToLow)
    1 -> Ok(LowToHigh)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DiodeProtocol
// ===========================================================================

/// Diode transfer protocols.
/// 
/// Matches `DiodeProtocol` in `DiodeABI.Types`.
pub type DiodeProtocol {
  /// UDP (tag 0).
  Udp
  /// TCP (tag 1).
  Tcp
  /// FileTransfer (tag 2).
  FileTransfer
  /// Syslog (tag 3).
  Syslog
  /// SNMP (tag 4).
  Snmp
}

/// Convert a `DiodeProtocol` to its C-ABI tag value.
pub fn diode_protocol_to_int(value: DiodeProtocol) -> Int {
  case value {
    Udp -> 0
    Tcp -> 1
    FileTransfer -> 2
    Syslog -> 3
    Snmp -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn diode_protocol_from_int(tag: Int) -> Result(DiodeProtocol, Nil) {
  case tag {
    0 -> Ok(Udp)
    1 -> Ok(Tcp)
    2 -> Ok(FileTransfer)
    3 -> Ok(Syslog)
    4 -> Ok(Snmp)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TransferState
// ===========================================================================

/// Diode transfer states.
/// 
/// Matches `TransferState` in `DiodeABI.Types`.
pub type TransferState {
  /// Queued (tag 0).
  Queued
  /// Sending (tag 1).
  Sending
  /// Confirming (tag 2).
  Confirming
  /// Complete (tag 3).
  Complete
  /// Failed (tag 4).
  Failed
}

/// Convert a `TransferState` to its C-ABI tag value.
pub fn transfer_state_to_int(value: TransferState) -> Int {
  case value {
    Queued -> 0
    Sending -> 1
    Confirming -> 2
    Complete -> 3
    Failed -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn transfer_state_from_int(tag: Int) -> Result(TransferState, Nil) {
  case tag {
    0 -> Ok(Queued)
    1 -> Ok(Sending)
    2 -> Ok(Confirming)
    3 -> Ok(Complete)
    4 -> Ok(Failed)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ValidationResult
// ===========================================================================

/// Data validation results.
/// 
/// Matches `ValidationResult` in `DiodeABI.Types`.
pub type ValidationResult {
  /// Passed (tag 0).
  Passed
  /// FormatError (tag 1).
  FormatError
  /// SizeExceeded (tag 2).
  SizeExceeded
  /// PolicyBlocked (tag 3).
  PolicyBlocked
}

/// Convert a `ValidationResult` to its C-ABI tag value.
pub fn validation_result_to_int(value: ValidationResult) -> Int {
  case value {
    Passed -> 0
    FormatError -> 1
    SizeExceeded -> 2
    PolicyBlocked -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn validation_result_from_int(tag: Int) -> Result(ValidationResult, Nil) {
  case tag {
    0 -> Ok(Passed)
    1 -> Ok(FormatError)
    2 -> Ok(SizeExceeded)
    3 -> Ok(PolicyBlocked)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// IntegrityCheck
// ===========================================================================

/// Integrity verification methods.
/// 
/// Matches `IntegrityCheck` in `DiodeABI.Types`.
pub type IntegrityCheck {
  /// CRC-32 (tag 0).
  Crc32
  /// SHA-256 (tag 1).
  Sha256
  /// HMAC (tag 2).
  Hmac
}

/// Convert a `IntegrityCheck` to its C-ABI tag value.
pub fn integrity_check_to_int(value: IntegrityCheck) -> Int {
  case value {
    Crc32 -> 0
    Sha256 -> 1
    Hmac -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn integrity_check_from_int(tag: Int) -> Result(IntegrityCheck, Nil) {
  case tag {
    0 -> Ok(Crc32)
    1 -> Ok(Sha256)
    2 -> Ok(Hmac)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// GatewayState
// ===========================================================================

/// Diode gateway states.
/// 
/// Matches `GatewayState` in `DiodeABI.Types`.
pub type GatewayState {
  /// Idle (tag 0).
  Idle
  /// Configured (tag 1).
  Configured
  /// Transferring (tag 2).
  Transferring
  /// Validating (tag 3).
  Validating
  /// Shutdown (tag 4).
  Shutdown
}

/// Convert a `GatewayState` to its C-ABI tag value.
pub fn gateway_state_to_int(value: GatewayState) -> Int {
  case value {
    Idle -> 0
    Configured -> 1
    Transferring -> 2
    Validating -> 3
    Shutdown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn gateway_state_from_int(tag: Int) -> Result(GatewayState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Configured)
    2 -> Ok(Transferring)
    3 -> Ok(Validating)
    4 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

