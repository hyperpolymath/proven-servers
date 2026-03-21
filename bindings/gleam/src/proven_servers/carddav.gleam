//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// CardDAV protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `CarddavABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// CardDAV Constants
// ===========================================================================

/// Carddav Port constant.
pub const carddav_port = 443

// ===========================================================================
// PropertyType
// ===========================================================================

/// vCard property types.
/// 
/// Matches `PropertyType` in `CarddavABI.Types`.
pub type PropertyType {
  /// FN (full name) (tag 0).
  FnName
  /// Structured name (tag 1).
  N
  /// Email (tag 2).
  Email
  /// Telephone (tag 3).
  Tel
  /// Address (tag 4).
  Adr
  /// Organization (tag 5).
  Org
  /// Photo (tag 6).
  Photo
  /// URL (tag 7).
  Url
  /// Note (tag 8).
  Note
}

/// Convert a `PropertyType` to its C-ABI tag value.
pub fn property_type_to_int(value: PropertyType) -> Int {
  case value {
    FnName -> 0
    N -> 1
    Email -> 2
    Tel -> 3
    Adr -> 4
    Org -> 5
    Photo -> 6
    Url -> 7
    Note -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn property_type_from_int(tag: Int) -> Result(PropertyType, Nil) {
  case tag {
    0 -> Ok(FnName)
    1 -> Ok(N)
    2 -> Ok(Email)
    3 -> Ok(Tel)
    4 -> Ok(Adr)
    5 -> Ok(Org)
    6 -> Ok(Photo)
    7 -> Ok(Url)
    8 -> Ok(Note)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CardMethod
// ===========================================================================

/// CardDAV methods.
/// 
/// Matches `CardMethod` in `CarddavABI.Types`.
pub type CardMethod {
  /// Get (tag 0).
  Get
  /// Put (tag 1).
  Put
  /// Delete (tag 2).
  Delete
  /// PROPFIND (tag 3).
  Propfind
  /// PROPPATCH (tag 4).
  Proppatch
  /// REPORT (tag 5).
  Report
  /// MKCOL (tag 6).
  Mkcol
}

/// Convert a `CardMethod` to its C-ABI tag value.
pub fn card_method_to_int(value: CardMethod) -> Int {
  case value {
    Get -> 0
    Put -> 1
    Delete -> 2
    Propfind -> 3
    Proppatch -> 4
    Report -> 5
    Mkcol -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn card_method_from_int(tag: Int) -> Result(CardMethod, Nil) {
  case tag {
    0 -> Ok(Get)
    1 -> Ok(Put)
    2 -> Ok(Delete)
    3 -> Ok(Propfind)
    4 -> Ok(Proppatch)
    5 -> Ok(Report)
    6 -> Ok(Mkcol)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// VCardVersion
// ===========================================================================

/// vCard versions.
/// 
/// Matches `VCardVersion` in `CarddavABI.Types`.
pub type VCardVersion {
  /// vCard 3.0 (tag 0).
  Vcard3
  /// vCard 4.0 (tag 1).
  Vcard4
}

/// Convert a `VCardVersion` to its C-ABI tag value.
pub fn v_card_version_to_int(value: VCardVersion) -> Int {
  case value {
    Vcard3 -> 0
    Vcard4 -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn v_card_version_from_int(tag: Int) -> Result(VCardVersion, Nil) {
  case tag {
    0 -> Ok(Vcard3)
    1 -> Ok(Vcard4)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CardError
// ===========================================================================

/// CardDAV error codes.
/// 
/// Matches `CardError` in `CarddavABI.Types`.
pub type CardError {
  /// ValidAddressData (tag 0).
  ValidAddressData
  /// NoResourceType (tag 1).
  NoResourceType
  /// MaxResourceSize (tag 2).
  MaxResourceSize
  /// UidConflict (tag 3).
  UidConflict
  /// SupportedAddressData (tag 4).
  SupportedAddressData
  /// PreconditionFailed (tag 5).
  PreconditionFailed
}

/// Convert a `CardError` to its C-ABI tag value.
pub fn card_error_to_int(value: CardError) -> Int {
  case value {
    ValidAddressData -> 0
    NoResourceType -> 1
    MaxResourceSize -> 2
    UidConflict -> 3
    SupportedAddressData -> 4
    PreconditionFailed -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn card_error_from_int(tag: Int) -> Result(CardError, Nil) {
  case tag {
    0 -> Ok(ValidAddressData)
    1 -> Ok(NoResourceType)
    2 -> Ok(MaxResourceSize)
    3 -> Ok(UidConflict)
    4 -> Ok(SupportedAddressData)
    5 -> Ok(PreconditionFailed)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServerState
// ===========================================================================

/// CardDAV server lifecycle states.
/// 
/// Matches `ServerState` in `CarddavABI.Types`.
pub type ServerState {
  /// Idle (tag 0).
  Idle
  /// Bound (tag 1).
  Bound
  /// Serving (tag 2).
  Serving
  /// Shutdown (tag 3).
  Shutdown
}

/// Convert a `ServerState` to its C-ABI tag value.
pub fn server_state_to_int(value: ServerState) -> Int {
  case value {
    Idle -> 0
    Bound -> 1
    Serving -> 2
    Shutdown -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn server_state_from_int(tag: Int) -> Result(ServerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Bound)
    2 -> Ok(Serving)
    3 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

