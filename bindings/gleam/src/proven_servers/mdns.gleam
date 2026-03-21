//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// mDNS protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `MdnsABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// mDNS Constants
// ===========================================================================

/// Mdns Port constant.
pub const mdns_port = 5353

// ===========================================================================
// MdnsRecordType
// ===========================================================================

/// mDNS record types.
/// 
/// Matches `MdnsRecordType` in `MdnsABI.Types`.
pub type MdnsRecordType {
  /// IPv4 address (tag 0).
  A
  /// IPv6 address (tag 1).
  Aaaa
  /// Pointer (tag 2).
  Ptr
  /// Service (tag 3).
  Srv
  /// Text (tag 4).
  Txt
}

/// Convert a `MdnsRecordType` to its C-ABI tag value.
pub fn mdns_record_type_to_int(value: MdnsRecordType) -> Int {
  case value {
    A -> 0
    Aaaa -> 1
    Ptr -> 2
    Srv -> 3
    Txt -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn mdns_record_type_from_int(tag: Int) -> Result(MdnsRecordType, Nil) {
  case tag {
    0 -> Ok(A)
    1 -> Ok(Aaaa)
    2 -> Ok(Ptr)
    3 -> Ok(Srv)
    4 -> Ok(Txt)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// QueryType
// ===========================================================================

/// mDNS query types.
/// 
/// Matches `QueryType` in `MdnsABI.Types`.
pub type QueryType {
  /// Standard (tag 0).
  Standard
  /// OneShot (tag 1).
  OneShot
  /// Continuous (tag 2).
  Continuous
}

/// Convert a `QueryType` to its C-ABI tag value.
pub fn query_type_to_int(value: QueryType) -> Int {
  case value {
    Standard -> 0
    OneShot -> 1
    Continuous -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn query_type_from_int(tag: Int) -> Result(QueryType, Nil) {
  case tag {
    0 -> Ok(Standard)
    1 -> Ok(OneShot)
    2 -> Ok(Continuous)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ConflictAction
// ===========================================================================

/// mDNS conflict resolution actions.
/// 
/// Matches `ConflictAction` in `MdnsABI.Types`.
pub type ConflictAction {
  /// Probe (tag 0).
  Probe
  /// Defend (tag 1).
  Defend
  /// Withdraw (tag 2).
  Withdraw
}

/// Convert a `ConflictAction` to its C-ABI tag value.
pub fn conflict_action_to_int(value: ConflictAction) -> Int {
  case value {
    Probe -> 0
    Defend -> 1
    Withdraw -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn conflict_action_from_int(tag: Int) -> Result(ConflictAction, Nil) {
  case tag {
    0 -> Ok(Probe)
    1 -> Ok(Defend)
    2 -> Ok(Withdraw)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServiceFlag
// ===========================================================================

/// mDNS service flags.
/// 
/// Matches `ServiceFlag` in `MdnsABI.Types`.
pub type ServiceFlag {
  /// Unique (tag 0).
  Unique
  /// Shared (tag 1).
  Shared
}

/// Convert a `ServiceFlag` to its C-ABI tag value.
pub fn service_flag_to_int(value: ServiceFlag) -> Int {
  case value {
    Unique -> 0
    Shared -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn service_flag_from_int(tag: Int) -> Result(ServiceFlag, Nil) {
  case tag {
    0 -> Ok(Unique)
    1 -> Ok(Shared)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResponderState
// ===========================================================================

/// mDNS responder states.
/// 
/// Matches `ResponderState` in `MdnsABI.Types`.
pub type ResponderState {
  /// Idle (tag 0).
  Idle
  /// Probing (tag 1).
  Probing
  /// Announcing (tag 2).
  Announcing
  /// Running (tag 3).
  Running
  /// ShuttingDown (tag 4).
  ShuttingDown
}

/// Convert a `ResponderState` to its C-ABI tag value.
pub fn responder_state_to_int(value: ResponderState) -> Int {
  case value {
    Idle -> 0
    Probing -> 1
    Announcing -> 2
    Running -> 3
    ShuttingDown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn responder_state_from_int(tag: Int) -> Result(ResponderState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Probing)
    2 -> Ok(Announcing)
    3 -> Ok(Running)
    4 -> Ok(ShuttingDown)
    _ -> Error(Nil)
  }
}

