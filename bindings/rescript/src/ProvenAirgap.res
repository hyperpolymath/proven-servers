// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Air Gap types for the proven-servers ABI.
//
// Mirrors the Idris2 module AirgapABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// TransferDirection (tags 0-1)
// ===========================================================================

/// Air gap transfer direction.
type transferDirection =
  | @as(0) Import
  | @as(1) Export

/// Decode from the C-ABI tag value.
let transferDirectionFromTag = (tag: int): option<transferDirection> =>
  switch tag {
  | 0 => Some(Import)
  | 1 => Some(Export)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transferDirectionToTag = (v: transferDirection): int =>
  switch v {
  | Import => 0
  | Export => 1
  }

// ===========================================================================
// MediaType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type mediaType =
  | @as(0) Usb
  | @as(1) OpticalDisc
  | @as(2) TapeCartridge
  | @as(3) DiodeLink

/// Decode from the C-ABI tag value.
let mediaTypeFromTag = (tag: int): option<mediaType> =>
  switch tag {
  | 0 => Some(Usb)
  | 1 => Some(OpticalDisc)
  | 2 => Some(TapeCartridge)
  | 3 => Some(DiodeLink)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let mediaTypeToTag = (v: mediaType): int =>
  switch v {
  | Usb => 0
  | OpticalDisc => 1
  | TapeCartridge => 2
  | DiodeLink => 3
  }

// ===========================================================================
// ScanResult (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type scanResult =
  | @as(0) Clean
  | @as(1) Suspicious
  | @as(2) Malicious
  | @as(3) Unscannable

/// Decode from the C-ABI tag value.
let scanResultFromTag = (tag: int): option<scanResult> =>
  switch tag {
  | 0 => Some(Clean)
  | 1 => Some(Suspicious)
  | 2 => Some(Malicious)
  | 3 => Some(Unscannable)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let scanResultToTag = (v: scanResult): int =>
  switch v {
  | Clean => 0
  | Suspicious => 1
  | Malicious => 2
  | Unscannable => 3
  }

/// Whether the content is safe to transfer.
let scanResultIsSafe = (v: scanResult): bool =>
  switch v {
  | Clean => true
  | _ => false
  }

// ===========================================================================
// TransferState (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type transferState =
  | @as(0) Pending
  | @as(1) Scanning
  | @as(2) Approved
  | @as(3) Rejected
  | @as(4) InProgress
  | @as(5) Complete
  | @as(6) Failed

/// Decode from the C-ABI tag value.
let transferStateFromTag = (tag: int): option<transferState> =>
  switch tag {
  | 0 => Some(Pending)
  | 1 => Some(Scanning)
  | 2 => Some(Approved)
  | 3 => Some(Rejected)
  | 4 => Some(InProgress)
  | 5 => Some(Complete)
  | 6 => Some(Failed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transferStateToTag = (v: transferState): int =>
  switch v {
  | Pending => 0
  | Scanning => 1
  | Approved => 2
  | Rejected => 3
  | InProgress => 4
  | Complete => 5
  | Failed => 6
  }

// ===========================================================================
// ValidationCheck (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type validationCheck =
  | @as(0) HashVerify
  | @as(1) SignatureVerify
  | @as(2) FormatCheck
  | @as(3) ContentInspection
  | @as(4) MalwareScan

/// Decode from the C-ABI tag value.
let validationCheckFromTag = (tag: int): option<validationCheck> =>
  switch tag {
  | 0 => Some(HashVerify)
  | 1 => Some(SignatureVerify)
  | 2 => Some(FormatCheck)
  | 3 => Some(ContentInspection)
  | 4 => Some(MalwareScan)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let validationCheckToTag = (v: validationCheck): int =>
  switch v {
  | HashVerify => 0
  | SignatureVerify => 1
  | FormatCheck => 2
  | ContentInspection => 3
  | MalwareScan => 4
  }

