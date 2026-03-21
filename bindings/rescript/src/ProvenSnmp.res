// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SNMP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module SNMPABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard SNMP agent port (RFC 3411).
let snmpPort = 161

/// Standard SNMP trap port (RFC 3411).
let snmpTrapPort = 162

// ===========================================================================
// Version (tags 0-2)
// ===========================================================================

/// Standard SNMP agent port (RFC 3411).
type version =
  | @as(0) V1
  | @as(1) V2c
  | @as(2) V3

/// Decode from the C-ABI tag value.
let versionFromTag = (tag: int): option<version> =>
  switch tag {
  | 0 => Some(V1)
  | 1 => Some(V2c)
  | 2 => Some(V3)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let versionToTag = (v: version): int =>
  switch v {
  | V1 => 0
  | V2c => 1
  | V3 => 2
  }

/// Whether this version supports the User-based Security Model (USM).
let versionHasUsm = (v: version): bool =>
  switch v {
  | V3 => true
  | _ => false
  }

/// Whether this version uses community strings for authentication.
let versionUsesCommunityStrings = (v: version): bool =>
  switch v {
  | V1 | V2c => true
  | _ => false
  }

/// Whether this version supports GetBulkRequest.
let versionSupportsGetBulk = (v: version): bool =>
  switch v {
  | V1 => false
  | _ => true
  }

// ===========================================================================
// PduType (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type pduType =
  | @as(0) GetRequest
  | @as(1) GetNextRequest
  | @as(2) GetResponse
  | @as(3) SetRequest
  | @as(4) GetBulkRequest
  | @as(5) InformRequest
  | @as(6) SnmpV2Trap

/// Decode from the C-ABI tag value.
let pduTypeFromTag = (tag: int): option<pduType> =>
  switch tag {
  | 0 => Some(GetRequest)
  | 1 => Some(GetNextRequest)
  | 2 => Some(GetResponse)
  | 3 => Some(SetRequest)
  | 4 => Some(GetBulkRequest)
  | 5 => Some(InformRequest)
  | 6 => Some(SnmpV2Trap)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let pduTypeToTag = (v: pduType): int =>
  switch v {
  | GetRequest => 0
  | GetNextRequest => 1
  | GetResponse => 2
  | SetRequest => 3
  | GetBulkRequest => 4
  | InformRequest => 5
  | SnmpV2Trap => 6
  }

/// Whether this PDU is a request from manager to agent.
let pduTypeIsRequest = (v: pduType): bool =>
  switch v {
  | GetRequest | GetNextRequest | SetRequest | GetBulkRequest => true
  | _ => false
  }

/// Whether this PDU is a notification (trap or inform).
let pduTypeIsNotification = (v: pduType): bool =>
  switch v {
  | InformRequest | SnmpV2Trap => true
  | _ => false
  }

/// Whether this PDU modifies agent state.
let pduTypeIsWrite = (v: pduType): bool =>
  switch v {
  | SetRequest => true
  | _ => false
  }

// ===========================================================================
// ErrorStatus (tags 0-15)
// ===========================================================================

/// Decode from an ABI tag value.
type errorStatus =
  | @as(0) NoError
  | @as(1) TooBig
  | @as(2) NoSuchName
  | @as(3) BadValue
  | @as(4) ReadOnly
  | @as(5) GenErr
  | @as(6) NoAccess
  | @as(7) WrongType
  | @as(8) WrongLength
  | @as(9) WrongValue
  | @as(10) NoCreation
  | @as(11) InconsistentValue
  | @as(12) ResourceUnavailable
  | @as(13) CommitFailed
  | @as(14) UndoFailed
  | @as(15) AuthorizationError

/// Decode from the C-ABI tag value.
let errorStatusFromTag = (tag: int): option<errorStatus> =>
  switch tag {
  | 0 => Some(NoError)
  | 1 => Some(TooBig)
  | 2 => Some(NoSuchName)
  | 3 => Some(BadValue)
  | 4 => Some(ReadOnly)
  | 5 => Some(GenErr)
  | 6 => Some(NoAccess)
  | 7 => Some(WrongType)
  | 8 => Some(WrongLength)
  | 9 => Some(WrongValue)
  | 10 => Some(NoCreation)
  | 11 => Some(InconsistentValue)
  | 12 => Some(ResourceUnavailable)
  | 13 => Some(CommitFailed)
  | 14 => Some(UndoFailed)
  | 15 => Some(AuthorizationError)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorStatusToTag = (v: errorStatus): int =>
  switch v {
  | NoError => 0
  | TooBig => 1
  | NoSuchName => 2
  | BadValue => 3
  | ReadOnly => 4
  | GenErr => 5
  | NoAccess => 6
  | WrongType => 7
  | WrongLength => 8
  | WrongValue => 9
  | NoCreation => 10
  | InconsistentValue => 11
  | ResourceUnavailable => 12
  | CommitFailed => 13
  | UndoFailed => 14
  | AuthorizationError => 15
  }

/// Whether this status indicates success.
let errorStatusIsSuccess = (v: errorStatus): bool =>
  switch v {
  | NoError => true
  | _ => false
  }

/// Whether this is an SNMPv1-only error code.
let errorStatusIsV1Only = (v: errorStatus): bool =>
  switch v {
  | NoSuchName | BadValue | ReadOnly => true
  | _ => false
  }

/// Whether this error relates to authorisation/access control.
let errorStatusIsAuthError = (v: errorStatus): bool =>
  switch v {
  | NoAccess | AuthorizationError => true
  | _ => false
  }

