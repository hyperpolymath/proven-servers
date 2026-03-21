//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// NETCONF protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `NetconfABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// NETCONF Constants
// ===========================================================================

/// Netconf Port constant.
pub const netconf_port = 830

// ===========================================================================
// NetconfOperation
// ===========================================================================

/// NETCONF operations.
/// 
/// Matches `NetconfOperation` in `NetconfABI.Types`.
pub type NetconfOperation {
  /// Get (tag 0).
  Get
  /// GetConfig (tag 1).
  GetConfig
  /// EditConfig (tag 2).
  EditConfig
  /// CopyConfig (tag 3).
  CopyConfig
  /// DeleteConfig (tag 4).
  DeleteConfig
  /// Lock (tag 5).
  Lock
  /// Unlock (tag 6).
  Unlock
  /// CloseSession (tag 7).
  CloseSession
  /// KillSession (tag 8).
  KillSession
  /// Commit (tag 9).
  Commit
  /// Validate (tag 10).
  Validate
  /// DiscardChanges (tag 11).
  DiscardChanges
}

/// Convert a `NetconfOperation` to its C-ABI tag value.
pub fn netconf_operation_to_int(value: NetconfOperation) -> Int {
  case value {
    Get -> 0
    GetConfig -> 1
    EditConfig -> 2
    CopyConfig -> 3
    DeleteConfig -> 4
    Lock -> 5
    Unlock -> 6
    CloseSession -> 7
    KillSession -> 8
    Commit -> 9
    Validate -> 10
    DiscardChanges -> 11
  }
}

/// Decode from a C-ABI tag value.
pub fn netconf_operation_from_int(tag: Int) -> Result(NetconfOperation, Nil) {
  case tag {
    0 -> Ok(Get)
    1 -> Ok(GetConfig)
    2 -> Ok(EditConfig)
    3 -> Ok(CopyConfig)
    4 -> Ok(DeleteConfig)
    5 -> Ok(Lock)
    6 -> Ok(Unlock)
    7 -> Ok(CloseSession)
    8 -> Ok(KillSession)
    9 -> Ok(Commit)
    10 -> Ok(Validate)
    11 -> Ok(DiscardChanges)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Datastore
// ===========================================================================

/// NETCONF datastores.
/// 
/// Matches `Datastore` in `NetconfABI.Types`.
pub type Datastore {
  /// Running (tag 0).
  Running
  /// Startup (tag 1).
  Startup
  /// Candidate (tag 2).
  Candidate
}

/// Convert a `Datastore` to its C-ABI tag value.
pub fn datastore_to_int(value: Datastore) -> Int {
  case value {
    Running -> 0
    Startup -> 1
    Candidate -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn datastore_from_int(tag: Int) -> Result(Datastore, Nil) {
  case tag {
    0 -> Ok(Running)
    1 -> Ok(Startup)
    2 -> Ok(Candidate)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// EditOperation
// ===========================================================================

/// NETCONF edit operations.
/// 
/// Matches `EditOperation` in `NetconfABI.Types`.
pub type EditOperation {
  /// Merge (tag 0).
  Merge
  /// Replace (tag 1).
  Replace
  /// Create (tag 2).
  Create
  /// Delete (tag 3).
  Delete
  /// Remove (tag 4).
  Remove
}

/// Convert a `EditOperation` to its C-ABI tag value.
pub fn edit_operation_to_int(value: EditOperation) -> Int {
  case value {
    Merge -> 0
    Replace -> 1
    Create -> 2
    Delete -> 3
    Remove -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn edit_operation_from_int(tag: Int) -> Result(EditOperation, Nil) {
  case tag {
    0 -> Ok(Merge)
    1 -> Ok(Replace)
    2 -> Ok(Create)
    3 -> Ok(Delete)
    4 -> Ok(Remove)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NetconfErrorType
// ===========================================================================

/// NETCONF error types.
/// 
/// Matches `NetconfErrorType` in `NetconfABI.Types`.
pub type NetconfErrorType {
  /// Transport (tag 0).
  Transport
  /// RPC (tag 1).
  Rpc
  /// Protocol (tag 2).
  Protocol
  /// Application (tag 3).
  Application
}

/// Convert a `NetconfErrorType` to its C-ABI tag value.
pub fn netconf_error_type_to_int(value: NetconfErrorType) -> Int {
  case value {
    Transport -> 0
    Rpc -> 1
    Protocol -> 2
    Application -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn netconf_error_type_from_int(tag: Int) -> Result(NetconfErrorType, Nil) {
  case tag {
    0 -> Ok(Transport)
    1 -> Ok(Rpc)
    2 -> Ok(Protocol)
    3 -> Ok(Application)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorSeverity
// ===========================================================================

/// NETCONF error severity.
/// 
/// Matches `ErrorSeverity` in `NetconfABI.Types`.
pub type ErrorSeverity {
  /// Error (tag 0).
  ErrorSeverityError
  /// Warning (tag 1).
  Warning
}

/// Convert a `ErrorSeverity` to its C-ABI tag value.
pub fn error_severity_to_int(value: ErrorSeverity) -> Int {
  case value {
    ErrorSeverityError -> 0
    Warning -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn error_severity_from_int(tag: Int) -> Result(ErrorSeverity, Nil) {
  case tag {
    0 -> Ok(ErrorSeverityError)
    1 -> Ok(Warning)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NetconfState
// ===========================================================================

/// NETCONF session states.
/// 
/// Matches `NetconfState` in `NetconfABI.Types`.
pub type NetconfState {
  /// Idle (tag 0).
  Idle
  /// Connected (tag 1).
  Connected
  /// Locked (tag 2).
  Locked
  /// Editing (tag 3).
  Editing
  /// Closing (tag 4).
  Closing
  /// Terminated (tag 5).
  Terminated
}

/// Convert a `NetconfState` to its C-ABI tag value.
pub fn netconf_state_to_int(value: NetconfState) -> Int {
  case value {
    Idle -> 0
    Connected -> 1
    Locked -> 2
    Editing -> 3
    Closing -> 4
    Terminated -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn netconf_state_from_int(tag: Int) -> Result(NetconfState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Connected)
    2 -> Ok(Locked)
    3 -> Ok(Editing)
    4 -> Ok(Closing)
    5 -> Ok(Terminated)
    _ -> Error(Nil)
  }
}

