// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LPD types for the proven-servers ABI.
//
// Mirrors the Idris2 module LpdABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard LPD port.
let lpdPort = 515

// ===========================================================================
// CommandCode (tags 0-5)
// ===========================================================================

/// Standard LPD port.
type commandCode =
  | @as(1) PrintJob
  | @as(2) ReceiveJob
  | @as(3) ShortQueue
  | @as(4) LongQueue
  | @as(5) RemoveJobs

/// Decode from the C-ABI tag value.
let commandCodeFromTag = (tag: int): option<commandCode> =>
  switch tag {
  | 1 => Some(PrintJob)
  | 2 => Some(ReceiveJob)
  | 3 => Some(ShortQueue)
  | 4 => Some(LongQueue)
  | 5 => Some(RemoveJobs)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let commandCodeToTag = (v: commandCode): int =>
  switch v {
  | PrintJob => 1
  | ReceiveJob => 2
  | ShortQueue => 3
  | LongQueue => 4
  | RemoveJobs => 5
  }

// ===========================================================================
// SubCommandCode (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type subCommandCode =
  | @as(1) AbortJob
  | @as(2) ControlFile
  | @as(3) DataFile

/// Decode from the C-ABI tag value.
let subCommandCodeFromTag = (tag: int): option<subCommandCode> =>
  switch tag {
  | 1 => Some(AbortJob)
  | 2 => Some(ControlFile)
  | 3 => Some(DataFile)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let subCommandCodeToTag = (v: subCommandCode): int =>
  switch v {
  | AbortJob => 1
  | ControlFile => 2
  | DataFile => 3
  }

// ===========================================================================
// JobStatus (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type jobStatus =
  | @as(0) Pending
  | @as(1) Printing
  | @as(2) Complete
  | @as(3) Failed

/// Decode from the C-ABI tag value.
let jobStatusFromTag = (tag: int): option<jobStatus> =>
  switch tag {
  | 0 => Some(Pending)
  | 1 => Some(Printing)
  | 2 => Some(Complete)
  | 3 => Some(Failed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let jobStatusToTag = (v: jobStatus): int =>
  switch v {
  | Pending => 0
  | Printing => 1
  | Complete => 2
  | Failed => 3
  }

