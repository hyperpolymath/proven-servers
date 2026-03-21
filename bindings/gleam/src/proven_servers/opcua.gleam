//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// OPC UA protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `OpcuaABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// OPC UA Constants
// ===========================================================================

/// Opcua Port constant.
pub const opcua_port = 4840

/// Opcua Tls Port constant.
pub const opcua_tls_port = 4843

// ===========================================================================
// ServiceType
// ===========================================================================

/// OPC UA service types (OPC 10000 Part 4).
/// 
/// Matches `ServiceType` in `OPCUAABI.Types`.
pub type ServiceType {
  /// Read attribute values from nodes (tag 0).
  Read
  /// Write attribute values to nodes (tag 1).
  Write
  /// Browse the address space (tag 2).
  Browse
  /// Create a monitored item subscription (tag 3).
  Subscribe
  /// Publish subscription notifications (tag 4).
  Publish
  /// Call a method on a node (tag 5).
  Call
  /// Create a new session (tag 6).
  CreateSession
  /// Activate an existing session (tag 7).
  ActivateSession
  /// Close a session (tag 8).
  CloseSession
  /// Create a new subscription (tag 9).
  CreateSubscription
  /// Delete a subscription (tag 10).
  DeleteSubscription
}

/// Convert a `ServiceType` to its C-ABI tag value.
pub fn service_type_to_int(value: ServiceType) -> Int {
  case value {
    Read -> 0
    Write -> 1
    Browse -> 2
    Subscribe -> 3
    Publish -> 4
    Call -> 5
    CreateSession -> 6
    ActivateSession -> 7
    CloseSession -> 8
    CreateSubscription -> 9
    DeleteSubscription -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn service_type_from_int(tag: Int) -> Result(ServiceType, Nil) {
  case tag {
    0 -> Ok(Read)
    1 -> Ok(Write)
    2 -> Ok(Browse)
    3 -> Ok(Subscribe)
    4 -> Ok(Publish)
    5 -> Ok(Call)
    6 -> Ok(CreateSession)
    7 -> Ok(ActivateSession)
    8 -> Ok(CloseSession)
    9 -> Ok(CreateSubscription)
    10 -> Ok(DeleteSubscription)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NodeClass
// ===========================================================================

/// OPC UA node classes (OPC 10000 Part 3).
/// 
/// Matches `NodeClass` in `OPCUAABI.Types`.
pub type NodeClass {
  /// Object instance node (tag 0).
  Object
  /// Variable node holding a value (tag 1).
  Variable
  /// Method node that can be called (tag 2).
  Method
  /// Object type definition (tag 3).
  ObjectType
  /// Variable type definition (tag 4).
  VariableType
  /// Reference type definition (tag 5).
  ReferenceType
  /// Data type definition (tag 6).
  DataType
  /// View node for address space subsets (tag 7).
  View
}

/// Convert a `NodeClass` to its C-ABI tag value.
pub fn node_class_to_int(value: NodeClass) -> Int {
  case value {
    Object -> 0
    Variable -> 1
    Method -> 2
    ObjectType -> 3
    VariableType -> 4
    ReferenceType -> 5
    DataType -> 6
    View -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn node_class_from_int(tag: Int) -> Result(NodeClass, Nil) {
  case tag {
    0 -> Ok(Object)
    1 -> Ok(Variable)
    2 -> Ok(Method)
    3 -> Ok(ObjectType)
    4 -> Ok(VariableType)
    5 -> Ok(ReferenceType)
    6 -> Ok(DataType)
    7 -> Ok(View)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// StatusCode
// ===========================================================================

/// OPC UA status codes (OPC 10000 Part 4).
/// 
/// Matches `StatusCode` in `OPCUAABI.Types`.
pub type StatusCode {
  /// Good — operation succeeded (tag 0).
  Good
  /// Uncertain — result is not fully reliable (tag 1).
  Uncertain
  /// Bad — generic failure (tag 2).
  Bad
  /// NodeId does not exist (tag 3).
  BadNodeIdUnknown
  /// Attribute ID is invalid for this node (tag 4).
  BadAttributeIdInvalid
  /// Attribute is not readable (tag 5).
  BadNotReadable
  /// Attribute is not writable (tag 6).
  BadNotWritable
  /// Value is out of range (tag 7).
  BadOutOfRange
  /// Data type mismatch (tag 8).
  BadTypeMismatch
  /// Session ID is invalid (tag 9).
  BadSessionIdInvalid
  /// Subscription ID is invalid (tag 10).
  BadSubscriptionIdInvalid
  /// Operation timed out (tag 11).
  BadTimeout
}

/// Convert a `StatusCode` to its C-ABI tag value.
pub fn status_code_to_int(value: StatusCode) -> Int {
  case value {
    Good -> 0
    Uncertain -> 1
    Bad -> 2
    BadNodeIdUnknown -> 3
    BadAttributeIdInvalid -> 4
    BadNotReadable -> 5
    BadNotWritable -> 6
    BadOutOfRange -> 7
    BadTypeMismatch -> 8
    BadSessionIdInvalid -> 9
    BadSubscriptionIdInvalid -> 10
    BadTimeout -> 11
  }
}

/// Decode from a C-ABI tag value.
pub fn status_code_from_int(tag: Int) -> Result(StatusCode, Nil) {
  case tag {
    0 -> Ok(Good)
    1 -> Ok(Uncertain)
    2 -> Ok(Bad)
    3 -> Ok(BadNodeIdUnknown)
    4 -> Ok(BadAttributeIdInvalid)
    5 -> Ok(BadNotReadable)
    6 -> Ok(BadNotWritable)
    7 -> Ok(BadOutOfRange)
    8 -> Ok(BadTypeMismatch)
    9 -> Ok(BadSessionIdInvalid)
    10 -> Ok(BadSubscriptionIdInvalid)
    11 -> Ok(BadTimeout)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SecurityMode
// ===========================================================================

/// OPC UA message security modes (OPC 10000 Part 4).
/// 
/// Matches `SecurityMode` in `OPCUAABI.Types`.
pub type SecurityMode {
  /// No security (tag 0).
  SecurityModeNone
  /// Messages are signed but not encrypted (tag 1).
  Sign
  /// Messages are signed and encrypted (tag 2).
  SignAndEncrypt
}

/// Convert a `SecurityMode` to its C-ABI tag value.
pub fn security_mode_to_int(value: SecurityMode) -> Int {
  case value {
    SecurityModeNone -> 0
    Sign -> 1
    SignAndEncrypt -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn security_mode_from_int(tag: Int) -> Result(SecurityMode, Nil) {
  case tag {
    0 -> Ok(SecurityModeNone)
    1 -> Ok(Sign)
    2 -> Ok(SignAndEncrypt)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// OPC UA session lifecycle states for the FFI layer.
/// 
/// Matches `SessionState` in `OPCUAABI.Types`.
pub type SessionState {
  /// No session (tag 0).
  Idle
  /// Secure channel established (tag 1).
  Connected
  /// Session created, awaiting activation (tag 2).
  Created
  /// Session activated, ready for service requests (tag 3).
  Activated
  /// Subscription active, monitoring nodes (tag 4).
  Monitoring
  /// Session closing (tag 5).
  Closing
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Connected -> 1
    Created -> 2
    Activated -> 3
    Monitoring -> 4
    Closing -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Connected)
    2 -> Ok(Created)
    3 -> Ok(Activated)
    4 -> Ok(Monitoring)
    5 -> Ok(Closing)
    _ -> Error(Nil)
  }
}

