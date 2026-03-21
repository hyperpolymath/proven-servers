//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Config Management protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `ConfigmgmtABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// ResourceType
// ===========================================================================

/// Managed resource types.
/// 
/// Matches `ResourceType` in `ConfigmgmtABI.Types`.
pub type ResourceType {
  /// File (tag 0).
  File
  /// Package (tag 1).
  Package
  /// Service (tag 2).
  Service
  /// User (tag 3).
  User
  /// Group (tag 4).
  Group
  /// Cron (tag 5).
  Cron
  /// Mount (tag 6).
  Mount
  /// Firewall (tag 7).
  Firewall
  /// Registry (tag 8).
  Registry
}

/// Convert a `ResourceType` to its C-ABI tag value.
pub fn resource_type_to_int(value: ResourceType) -> Int {
  case value {
    File -> 0
    Package -> 1
    Service -> 2
    User -> 3
    Group -> 4
    Cron -> 5
    Mount -> 6
    Firewall -> 7
    Registry -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn resource_type_from_int(tag: Int) -> Result(ResourceType, Nil) {
  case tag {
    0 -> Ok(File)
    1 -> Ok(Package)
    2 -> Ok(Service)
    3 -> Ok(User)
    4 -> Ok(Group)
    5 -> Ok(Cron)
    6 -> Ok(Mount)
    7 -> Ok(Firewall)
    8 -> Ok(Registry)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResourceState
// ===========================================================================

/// Desired resource states.
/// 
/// Matches `ResourceState` in `ConfigmgmtABI.Types`.
pub type ResourceState {
  /// Present (tag 0).
  Present
  /// Absent (tag 1).
  Absent
  /// Running (tag 2).
  Running
  /// Stopped (tag 3).
  Stopped
  /// Enabled (tag 4).
  Enabled
  /// Disabled (tag 5).
  Disabled
}

/// Convert a `ResourceState` to its C-ABI tag value.
pub fn resource_state_to_int(value: ResourceState) -> Int {
  case value {
    Present -> 0
    Absent -> 1
    Running -> 2
    Stopped -> 3
    Enabled -> 4
    Disabled -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn resource_state_from_int(tag: Int) -> Result(ResourceState, Nil) {
  case tag {
    0 -> Ok(Present)
    1 -> Ok(Absent)
    2 -> Ok(Running)
    3 -> Ok(Stopped)
    4 -> Ok(Enabled)
    5 -> Ok(Disabled)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ChangeAction
// ===========================================================================

/// Configuration change actions.
/// 
/// Matches `ChangeAction` in `ConfigmgmtABI.Types`.
pub type ChangeAction {
  /// Create (tag 0).
  Create
  /// Modify (tag 1).
  Modify
  /// Delete (tag 2).
  Delete
  /// Restart (tag 3).
  Restart
  /// Reload (tag 4).
  Reload
  /// Skip (tag 5).
  Skip
}

/// Convert a `ChangeAction` to its C-ABI tag value.
pub fn change_action_to_int(value: ChangeAction) -> Int {
  case value {
    Create -> 0
    Modify -> 1
    Delete -> 2
    Restart -> 3
    Reload -> 4
    Skip -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn change_action_from_int(tag: Int) -> Result(ChangeAction, Nil) {
  case tag {
    0 -> Ok(Create)
    1 -> Ok(Modify)
    2 -> Ok(Delete)
    3 -> Ok(Restart)
    4 -> Ok(Reload)
    5 -> Ok(Skip)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DriftStatus
// ===========================================================================

/// Configuration drift status.
/// 
/// Matches `DriftStatus` in `ConfigmgmtABI.Types`.
pub type DriftStatus {
  /// InSync (tag 0).
  InSync
  /// Drifted (tag 1).
  Drifted
  /// Unknown (tag 2).
  DUnknown
  /// Unmanaged (tag 3).
  Unmanaged
}

/// Convert a `DriftStatus` to its C-ABI tag value.
pub fn drift_status_to_int(value: DriftStatus) -> Int {
  case value {
    InSync -> 0
    Drifted -> 1
    DUnknown -> 2
    Unmanaged -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn drift_status_from_int(tag: Int) -> Result(DriftStatus, Nil) {
  case tag {
    0 -> Ok(InSync)
    1 -> Ok(Drifted)
    2 -> Ok(DUnknown)
    3 -> Ok(Unmanaged)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ApplyMode
// ===========================================================================

/// Configuration apply modes.
/// 
/// Matches `ApplyMode` in `ConfigmgmtABI.Types`.
pub type ApplyMode {
  /// Enforce (tag 0).
  Enforce
  /// DryRun (tag 1).
  DryRun
  /// Audit (tag 2).
  Audit
}

/// Convert a `ApplyMode` to its C-ABI tag value.
pub fn apply_mode_to_int(value: ApplyMode) -> Int {
  case value {
    Enforce -> 0
    DryRun -> 1
    Audit -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn apply_mode_from_int(tag: Int) -> Result(ApplyMode, Nil) {
  case tag {
    0 -> Ok(Enforce)
    1 -> Ok(DryRun)
    2 -> Ok(Audit)
    _ -> Error(Nil)
  }
}

