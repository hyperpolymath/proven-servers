//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// LPD (Line Printer) protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `LpdABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// LPD (Line Printer) Constants
// ===========================================================================

/// Lpd Port constant.
pub const lpd_port = 515

// ===========================================================================
// CommandCode
// ===========================================================================

/// LPD command codes (RFC 1179).
/// 
/// Matches `CommandCode` in `LpdABI.Types`.
pub type CommandCode {
  /// Print any waiting jobs  (tag 1).
  PrintJob
  /// Receive a print job  (tag 2).
  ReceiveJob
  /// Short queue listing  (tag 3).
  ShortQueue
  /// Long queue listing  (tag 4).
  LongQueue
  /// Remove jobs  (tag 5).
  RemoveJobs
}

/// Convert a `CommandCode` to its C-ABI tag value.
pub fn command_code_to_int(value: CommandCode) -> Int {
  case value {
    PrintJob -> 1
    ReceiveJob -> 2
    ShortQueue -> 3
    LongQueue -> 4
    RemoveJobs -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn command_code_from_int(tag: Int) -> Result(CommandCode, Nil) {
  case tag {
    1 -> Ok(PrintJob)
    2 -> Ok(ReceiveJob)
    3 -> Ok(ShortQueue)
    4 -> Ok(LongQueue)
    5 -> Ok(RemoveJobs)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SubCommandCode
// ===========================================================================

/// LPD sub-command codes.
/// 
/// Matches `SubCommandCode` in `LpdABI.Types`.
pub type SubCommandCode {
  /// Abort job  (tag 1).
  AbortJob
  /// Receive control file  (tag 2).
  ControlFile
  /// Receive data file  (tag 3).
  DataFile
}

/// Convert a `SubCommandCode` to its C-ABI tag value.
pub fn sub_command_code_to_int(value: SubCommandCode) -> Int {
  case value {
    AbortJob -> 1
    ControlFile -> 2
    DataFile -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn sub_command_code_from_int(tag: Int) -> Result(SubCommandCode, Nil) {
  case tag {
    1 -> Ok(AbortJob)
    2 -> Ok(ControlFile)
    3 -> Ok(DataFile)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// JobStatus
// ===========================================================================

/// Print job status.
/// 
/// Matches `JobStatus` in `LpdABI.Types`.
pub type JobStatus {
  /// Pending (tag 0).
  Pending
  /// Printing (tag 1).
  Printing
  /// Complete (tag 2).
  Complete
  /// Failed (tag 3).
  Failed
}

/// Convert a `JobStatus` to its C-ABI tag value.
pub fn job_status_to_int(value: JobStatus) -> Int {
  case value {
    Pending -> 0
    Printing -> 1
    Complete -> 2
    Failed -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn job_status_from_int(tag: Int) -> Result(JobStatus, Nil) {
  case tag {
    0 -> Ok(Pending)
    1 -> Ok(Printing)
    2 -> Ok(Complete)
    3 -> Ok(Failed)
    _ -> Error(Nil)
  }
}

