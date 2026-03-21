//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Air Gap protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `AirgapABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// TransferDirection
// ===========================================================================

/// Air gap transfer direction.
/// 
/// Matches `TransferDirection` in `AirgapABI.Types`.
pub type TransferDirection {
  /// Import (tag 0).
  Import
  /// Export (tag 1).
  Export
}

/// Convert a `TransferDirection` to its C-ABI tag value.
pub fn transfer_direction_to_int(value: TransferDirection) -> Int {
  case value {
    Import -> 0
    Export -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn transfer_direction_from_int(tag: Int) -> Result(TransferDirection, Nil) {
  case tag {
    0 -> Ok(Import)
    1 -> Ok(Export)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// MediaType
// ===========================================================================

/// Physical transfer media types.
/// 
/// Matches `MediaType` in `AirgapABI.Types`.
pub type MediaType {
  /// USB (tag 0).
  Usb
  /// OpticalDisc (tag 1).
  OpticalDisc
  /// TapeCartridge (tag 2).
  TapeCartridge
  /// DiodeLink (tag 3).
  DiodeLink
}

/// Convert a `MediaType` to its C-ABI tag value.
pub fn media_type_to_int(value: MediaType) -> Int {
  case value {
    Usb -> 0
    OpticalDisc -> 1
    TapeCartridge -> 2
    DiodeLink -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn media_type_from_int(tag: Int) -> Result(MediaType, Nil) {
  case tag {
    0 -> Ok(Usb)
    1 -> Ok(OpticalDisc)
    2 -> Ok(TapeCartridge)
    3 -> Ok(DiodeLink)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ScanResult
// ===========================================================================

/// Content scan results.
/// 
/// Matches `ScanResult` in `AirgapABI.Types`.
pub type ScanResult {
  /// Clean (tag 0).
  Clean
  /// Suspicious (tag 1).
  Suspicious
  /// Malicious (tag 2).
  Malicious
  /// Unscannable (tag 3).
  Unscannable
}

/// Convert a `ScanResult` to its C-ABI tag value.
pub fn scan_result_to_int(value: ScanResult) -> Int {
  case value {
    Clean -> 0
    Suspicious -> 1
    Malicious -> 2
    Unscannable -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn scan_result_from_int(tag: Int) -> Result(ScanResult, Nil) {
  case tag {
    0 -> Ok(Clean)
    1 -> Ok(Suspicious)
    2 -> Ok(Malicious)
    3 -> Ok(Unscannable)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TransferState
// ===========================================================================

/// Air gap transfer lifecycle.
/// 
/// Matches `TransferState` in `AirgapABI.Types`.
pub type TransferState {
  /// Pending (tag 0).
  Pending
  /// Scanning (tag 1).
  Scanning
  /// Approved (tag 2).
  Approved
  /// Rejected (tag 3).
  Rejected
  /// InProgress (tag 4).
  InProgress
  /// Complete (tag 5).
  Complete
  /// Failed (tag 6).
  Failed
}

/// Convert a `TransferState` to its C-ABI tag value.
pub fn transfer_state_to_int(value: TransferState) -> Int {
  case value {
    Pending -> 0
    Scanning -> 1
    Approved -> 2
    Rejected -> 3
    InProgress -> 4
    Complete -> 5
    Failed -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn transfer_state_from_int(tag: Int) -> Result(TransferState, Nil) {
  case tag {
    0 -> Ok(Pending)
    1 -> Ok(Scanning)
    2 -> Ok(Approved)
    3 -> Ok(Rejected)
    4 -> Ok(InProgress)
    5 -> Ok(Complete)
    6 -> Ok(Failed)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ValidationCheck
// ===========================================================================

/// Validation check types.
/// 
/// Matches `ValidationCheck` in `AirgapABI.Types`.
pub type ValidationCheck {
  /// HashVerify (tag 0).
  HashVerify
  /// SignatureVerify (tag 1).
  SignatureVerify
  /// FormatCheck (tag 2).
  FormatCheck
  /// ContentInspection (tag 3).
  ContentInspection
  /// MalwareScan (tag 4).
  MalwareScan
}

/// Convert a `ValidationCheck` to its C-ABI tag value.
pub fn validation_check_to_int(value: ValidationCheck) -> Int {
  case value {
    HashVerify -> 0
    SignatureVerify -> 1
    FormatCheck -> 2
    ContentInspection -> 3
    MalwareScan -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn validation_check_from_int(tag: Int) -> Result(ValidationCheck, Nil) {
  case tag {
    0 -> Ok(HashVerify)
    1 -> Ok(SignatureVerify)
    2 -> Ok(FormatCheck)
    3 -> Ok(ContentInspection)
    4 -> Ok(MalwareScan)
    _ -> Error(Nil)
  }
}

