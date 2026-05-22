//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// SNMP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `SNMPABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// SNMP Constants
// ===========================================================================

/// Snmp Port constant.
pub const snmp_port = 161

/// Snmp Trap Port constant.
pub const snmp_trap_port = 162

// ===========================================================================
// Version
// ===========================================================================

/// SNMP protocol versions.
/// 
/// Matches `Version` in `SNMPABI.Types`.
pub type Version {
  /// SNMPv1 (RFC 1157) (tag 0).
  V1
  /// SNMPv2c — community-based SNMPv2 (RFC 3584) (tag 1).
  V2c
  /// SNMPv3 — user-based security model (RFC 3414) (tag 2).
  V3
}

/// Convert a `Version` to its C-ABI tag value.
pub fn version_to_int(value: Version) -> Int {
  case value {
    V1 -> 0
    V2c -> 1
    V3 -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn version_from_int(tag: Int) -> Result(Version, Nil) {
  case tag {
    0 -> Ok(V1)
    1 -> Ok(V2c)
    2 -> Ok(V3)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PduType
// ===========================================================================

/// SNMP PDU (Protocol Data Unit) types.
/// 
/// Matches `PDUType` in `SNMPABI.Types`.
pub type PduType {
  /// Get value of specific OIDs (tag 0).
  GetRequest
  /// Get next OID in MIB tree (tag 1).
  GetNextRequest
  /// Response to a request (tag 2).
  GetResponse
  /// Set value of specific OIDs (tag 3).
  SetRequest
  /// Bulk retrieval — SNMPv2c/v3 only (tag 4).
  GetBulkRequest
  /// Manager-to-manager notification (tag 5).
  InformRequest
  /// SNMPv2 trap notification (tag 6).
  SnmpV2Trap
}

/// Convert a `PduType` to its C-ABI tag value.
pub fn pdu_type_to_int(value: PduType) -> Int {
  case value {
    GetRequest -> 0
    GetNextRequest -> 1
    GetResponse -> 2
    SetRequest -> 3
    GetBulkRequest -> 4
    InformRequest -> 5
    SnmpV2Trap -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn pdu_type_from_int(tag: Int) -> Result(PduType, Nil) {
  case tag {
    0 -> Ok(GetRequest)
    1 -> Ok(GetNextRequest)
    2 -> Ok(GetResponse)
    3 -> Ok(SetRequest)
    4 -> Ok(GetBulkRequest)
    5 -> Ok(InformRequest)
    6 -> Ok(SnmpV2Trap)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorStatus
// ===========================================================================

/// SNMP error status codes.
/// 
/// Matches `ErrorStatus` in `SNMPABI.Types`.
/// Includes both SNMPv1 errors (0-5) and SNMPv2c/v3 extensions (6-15).
pub type ErrorStatus {
  /// No error occurred (tag 0).
  NoError
  /// Response too large for transport (tag 1).
  TooBig
  /// OID not found — SNMPv1 (tag 2).
  NoSuchName
  /// Invalid value in set request — SNMPv1 (tag 3).
  BadValue
  /// Object is read-only — SNMPv1 (tag 4).
  ReadOnly
  /// Generic error (tag 5).
  GenErr
  /// No access to the object (tag 6).
  NoAccess
  /// Wrong ASN.1 type for the object (tag 7).
  WrongType
  /// Wrong value length (tag 8).
  WrongLength
  /// Wrong encoding of value (tag 9).
  WrongValue
  /// Object cannot be created (tag 10).
  NoCreation
  /// Value inconsistent with other managed objects (tag 11).
  InconsistentValue
  /// Required resource is unavailable (tag 12).
  ResourceUnavailable
  /// Set operation commit failed (tag 13).
  CommitFailed
  /// Set operation undo failed (tag 14).
  UndoFailed
  /// Authorization error (tag 15).
  AuthorizationError
}

/// Convert a `ErrorStatus` to its C-ABI tag value.
pub fn error_status_to_int(value: ErrorStatus) -> Int {
  case value {
    NoError -> 0
    TooBig -> 1
    NoSuchName -> 2
    BadValue -> 3
    ReadOnly -> 4
    GenErr -> 5
    NoAccess -> 6
    WrongType -> 7
    WrongLength -> 8
    WrongValue -> 9
    NoCreation -> 10
    InconsistentValue -> 11
    ResourceUnavailable -> 12
    CommitFailed -> 13
    UndoFailed -> 14
    AuthorizationError -> 15
  }
}

/// Decode from a C-ABI tag value.
pub fn error_status_from_int(tag: Int) -> Result(ErrorStatus, Nil) {
  case tag {
    0 -> Ok(NoError)
    1 -> Ok(TooBig)
    2 -> Ok(NoSuchName)
    3 -> Ok(BadValue)
    4 -> Ok(ReadOnly)
    5 -> Ok(GenErr)
    6 -> Ok(NoAccess)
    7 -> Ok(WrongType)
    8 -> Ok(WrongLength)
    9 -> Ok(WrongValue)
    10 -> Ok(NoCreation)
    11 -> Ok(InconsistentValue)
    12 -> Ok(ResourceUnavailable)
    13 -> Ok(CommitFailed)
    14 -> Ok(UndoFailed)
    15 -> Ok(AuthorizationError)
    _ -> Error(Nil)
  }
}

