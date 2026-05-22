// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OPC UA (OPC Unified Architecture) types for the proven-servers ABI.
//
// Mirrors the Idris2 module OPCUAABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard OPC UA TCP port.
let opcuaPort = 4840

/// Standard OPC UA TCP/TLS port.
let opcuaTlsPort = 4843

// ===========================================================================
// ServiceType (tags 0-10)
// ===========================================================================

/// Standard OPC UA TCP port.
type serviceType =
  | @as(0) Read
  | @as(1) Write
  | @as(2) Browse
  | @as(3) Subscribe
  | @as(4) Publish
  | @as(5) Call
  | @as(6) CreateSession
  | @as(7) ActivateSession
  | @as(8) CloseSession
  | @as(9) CreateSubscription
  | @as(10) DeleteSubscription

/// Decode from the C-ABI tag value.
let serviceTypeFromTag = (tag: int): option<serviceType> =>
  switch tag {
  | 0 => Some(Read)
  | 1 => Some(Write)
  | 2 => Some(Browse)
  | 3 => Some(Subscribe)
  | 4 => Some(Publish)
  | 5 => Some(Call)
  | 6 => Some(CreateSession)
  | 7 => Some(ActivateSession)
  | 8 => Some(CloseSession)
  | 9 => Some(CreateSubscription)
  | 10 => Some(DeleteSubscription)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serviceTypeToTag = (v: serviceType): int =>
  switch v {
  | Read => 0
  | Write => 1
  | Browse => 2
  | Subscribe => 3
  | Publish => 4
  | Call => 5
  | CreateSession => 6
  | ActivateSession => 7
  | CloseSession => 8
  | CreateSubscription => 9
  | DeleteSubscription => 10
  }

/// Whether this service modifies server state.
let serviceTypeIsWrite = (v: serviceType): bool =>
  switch v {
  | Write | Call => true
  | _ => false
  }

/// Whether this service is a session management operation.
let serviceTypeIsSessionManagement = (v: serviceType): bool =>
  switch v {
  | CreateSession | ActivateSession | CloseSession => true
  | _ => false
  }

/// Whether this service relates to subscriptions.
let serviceTypeIsSubscriptionRelated = (v: serviceType): bool =>
  switch v {
  | Subscribe | Publish | CreateSubscription | DeleteSubscription => true
  | _ => false
  }

// ===========================================================================
// NodeClass (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type nodeClass =
  | @as(0) Object
  | @as(1) Variable
  | @as(2) Method
  | @as(3) ObjectType
  | @as(4) VariableType
  | @as(5) ReferenceType
  | @as(6) DataType
  | @as(7) View

/// Decode from the C-ABI tag value.
let nodeClassFromTag = (tag: int): option<nodeClass> =>
  switch tag {
  | 0 => Some(Object)
  | 1 => Some(Variable)
  | 2 => Some(Method)
  | 3 => Some(ObjectType)
  | 4 => Some(VariableType)
  | 5 => Some(ReferenceType)
  | 6 => Some(DataType)
  | 7 => Some(View)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let nodeClassToTag = (v: nodeClass): int =>
  switch v {
  | Object => 0
  | Variable => 1
  | Method => 2
  | ObjectType => 3
  | VariableType => 4
  | ReferenceType => 5
  | DataType => 6
  | View => 7
  }

/// Whether this node class is an instance node (not a type definition).
let nodeClassIsInstance = (v: nodeClass): bool =>
  switch v {
  | Object | Variable | Method | View => true
  | _ => false
  }

/// Whether this node class is a type definition.
let nodeClassIsType = (v: nodeClass): bool =>
  switch v {
  | ObjectType | VariableType | ReferenceType | DataType => true
  | _ => false
  }

// ===========================================================================
// StatusCode (tags 0-11)
// ===========================================================================

/// Decode from an ABI tag value.
type statusCode =
  | @as(0) Good
  | @as(1) Uncertain
  | @as(2) Bad
  | @as(3) BadNodeIdUnknown
  | @as(4) BadAttributeIdInvalid
  | @as(5) BadNotReadable
  | @as(6) BadNotWritable
  | @as(7) BadOutOfRange
  | @as(8) BadTypeMismatch
  | @as(9) BadSessionIdInvalid
  | @as(10) BadSubscriptionIdInvalid
  | @as(11) BadTimeout

/// Decode from the C-ABI tag value.
let statusCodeFromTag = (tag: int): option<statusCode> =>
  switch tag {
  | 0 => Some(Good)
  | 1 => Some(Uncertain)
  | 2 => Some(Bad)
  | 3 => Some(BadNodeIdUnknown)
  | 4 => Some(BadAttributeIdInvalid)
  | 5 => Some(BadNotReadable)
  | 6 => Some(BadNotWritable)
  | 7 => Some(BadOutOfRange)
  | 8 => Some(BadTypeMismatch)
  | 9 => Some(BadSessionIdInvalid)
  | 10 => Some(BadSubscriptionIdInvalid)
  | 11 => Some(BadTimeout)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let statusCodeToTag = (v: statusCode): int =>
  switch v {
  | Good => 0
  | Uncertain => 1
  | Bad => 2
  | BadNodeIdUnknown => 3
  | BadAttributeIdInvalid => 4
  | BadNotReadable => 5
  | BadNotWritable => 6
  | BadOutOfRange => 7
  | BadTypeMismatch => 8
  | BadSessionIdInvalid => 9
  | BadSubscriptionIdInvalid => 10
  | BadTimeout => 11
  }

/// Whether this status code indicates success.
let statusCodeIsGood = (v: statusCode): bool =>
  switch v {
  | Good => true
  | _ => false
  }

/// Whether this status code indicates a definite failure.
let statusCodeIsBad = (v: statusCode): bool =>
  switch v {
  | Good | Uncertain => false
  | _ => true
  }

/// Whether this status code relates to security/session issues.
let statusCodeIsSecurityRelated = (v: statusCode): bool =>
  switch v {
  | BadSessionIdInvalid => true
  | _ => false
  }

// ===========================================================================
// SecurityMode (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type securityMode =
  | @as(0) None
  | @as(1) Sign
  | @as(2) SignAndEncrypt

/// Decode from the C-ABI tag value.
let securityModeFromTag = (tag: int): option<securityMode> =>
  switch tag {
  | 0 => Some(None)
  | 1 => Some(Sign)
  | 2 => Some(SignAndEncrypt)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let securityModeToTag = (v: securityMode): int =>
  switch v {
  | None => 0
  | Sign => 1
  | SignAndEncrypt => 2
  }

/// Whether messages are signed.
let securityModeIsSigned = (v: securityMode): bool =>
  switch v {
  | Sign | SignAndEncrypt => true
  | _ => false
  }

/// Whether messages are encrypted.
let securityModeIsEncrypted = (v: securityMode): bool =>
  switch v {
  | SignAndEncrypt => true
  | _ => false
  }

// ===========================================================================
// SessionState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Connected
  | @as(2) Created
  | @as(3) Activated
  | @as(4) Monitoring
  | @as(5) Closing

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Connected)
  | 2 => Some(Created)
  | 3 => Some(Activated)
  | 4 => Some(Monitoring)
  | 5 => Some(Closing)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Connected => 1
  | Created => 2
  | Activated => 3
  | Monitoring => 4
  | Closing => 5
  }

/// Whether the session can accept service requests.
let sessionStateCanService = (v: sessionState): bool =>
  switch v {
  | Activated | Monitoring => true
  | _ => false
  }

/// Whether the session is in a transient state.
let sessionStateIsTransient = (v: sessionState): bool =>
  switch v {
  | Connected | Created | Closing => true
  | _ => false
  }

