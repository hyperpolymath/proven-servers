//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// LDAP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `LdapABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// LDAP Constants
// ===========================================================================

/// Ldap Port constant.
pub const ldap_port = 389

/// Ldaps Port constant.
pub const ldaps_port = 636

// ===========================================================================
// SessionState
// ===========================================================================

/// LDAP session state machine.
/// 
/// Matches `SessionState` in `LdapABI.Types`.
pub type SessionState {
  /// Connected but not authenticated (tag 0).
  Anonymous
  /// Successfully bound (authenticated) (tag 1).
  Bound
  /// Session is closed (tag 2).
  Closed
  /// Bind operation in progress (tag 3).
  Binding
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Anonymous -> 0
    Bound -> 1
    Closed -> 2
    Binding -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Anonymous)
    1 -> Ok(Bound)
    2 -> Ok(Closed)
    3 -> Ok(Binding)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn session_state_can_transition_to(from: SessionState, to: SessionState) -> Bool {
  case from, to {
    Anonymous, Binding -> True
    Binding, Bound -> True
    Binding, Anonymous -> True
    Bound, Anonymous -> True
    Anonymous, Closed -> True
    Bound, Closed -> True
    Closed, Closed -> True
    Binding, Closed -> True
    _, _ -> False
  }
}

// ===========================================================================
// Operation
// ===========================================================================

/// LDAP protocol operations (RFC 4511).
/// 
/// Matches `Operation` in `LdapABI.Types`.
pub type Operation {
  /// Bind (authenticate) to the directory (tag 0).
  Bind
  /// Unbind (close session) (tag 1).
  Unbind
  /// Search for directory entries (tag 2).
  Search
  /// Modify an existing entry (tag 3).
  Modify
  /// Add a new entry (tag 4).
  Add
  /// Delete an entry (tag 5).
  Delete
  /// Modify the DN (rename/move) of an entry (tag 6).
  ModDn
  /// Compare an attribute value (tag 7).
  Compare
  /// Abandon a pending operation (tag 8).
  Abandon
  /// Extended operation (tag 9).
  Extended
}

/// Convert a `Operation` to its C-ABI tag value.
pub fn operation_to_int(value: Operation) -> Int {
  case value {
    Bind -> 0
    Unbind -> 1
    Search -> 2
    Modify -> 3
    Add -> 4
    Delete -> 5
    ModDn -> 6
    Compare -> 7
    Abandon -> 8
    Extended -> 9
  }
}

/// Decode from a C-ABI tag value.
pub fn operation_from_int(tag: Int) -> Result(Operation, Nil) {
  case tag {
    0 -> Ok(Bind)
    1 -> Ok(Unbind)
    2 -> Ok(Search)
    3 -> Ok(Modify)
    4 -> Ok(Add)
    5 -> Ok(Delete)
    6 -> Ok(ModDn)
    7 -> Ok(Compare)
    8 -> Ok(Abandon)
    9 -> Ok(Extended)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SearchScope
// ===========================================================================

/// LDAP search scope levels (RFC 4511 Section 4.5.1.2).
/// 
/// Matches `SearchScope` in `LdapABI.Types`.
pub type SearchScope {
  /// Search only the base object itself (tag 0).
  BaseObject
  /// Search one level below the base object (tag 1).
  SingleLevel
  /// Search the entire subtree below the base object (tag 2).
  WholeSubtree
}

/// Convert a `SearchScope` to its C-ABI tag value.
pub fn search_scope_to_int(value: SearchScope) -> Int {
  case value {
    BaseObject -> 0
    SingleLevel -> 1
    WholeSubtree -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn search_scope_from_int(tag: Int) -> Result(SearchScope, Nil) {
  case tag {
    0 -> Ok(BaseObject)
    1 -> Ok(SingleLevel)
    2 -> Ok(WholeSubtree)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResultCode
// ===========================================================================

/// LDAP result codes (RFC 4511 Appendix A).
/// 
/// Matches `ResultCode` in `LdapABI.Types`.
pub type ResultCode {
  /// Operation completed successfully (tag 0).
  Success
  /// An internal error occurred (tag 1).
  OperationsError
  /// Protocol violation detected (tag 2).
  ProtocolError
  /// Time limit for the operation was exceeded (tag 3).
  TimeLimitExceeded
  /// Size limit for the operation was exceeded (tag 4).
  SizeLimitExceeded
  /// Requested auth method not supported (tag 5).
  AuthMethodNotSupported
  /// The target entry does not exist (tag 6).
  NoSuchObject
  /// Provided credentials are invalid (tag 7).
  InvalidCredentials
  /// Caller lacks sufficient access rights (tag 8).
  InsufficientAccessRights
  /// Server is too busy to handle the request (tag 9).
  Busy
  /// Server is unavailable (tag 10).
  Unavailable
}

/// Convert a `ResultCode` to its C-ABI tag value.
pub fn result_code_to_int(value: ResultCode) -> Int {
  case value {
    Success -> 0
    OperationsError -> 1
    ProtocolError -> 2
    TimeLimitExceeded -> 3
    SizeLimitExceeded -> 4
    AuthMethodNotSupported -> 5
    NoSuchObject -> 6
    InvalidCredentials -> 7
    InsufficientAccessRights -> 8
    Busy -> 9
    Unavailable -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn result_code_from_int(tag: Int) -> Result(ResultCode, Nil) {
  case tag {
    0 -> Ok(Success)
    1 -> Ok(OperationsError)
    2 -> Ok(ProtocolError)
    3 -> Ok(TimeLimitExceeded)
    4 -> Ok(SizeLimitExceeded)
    5 -> Ok(AuthMethodNotSupported)
    6 -> Ok(NoSuchObject)
    7 -> Ok(InvalidCredentials)
    8 -> Ok(InsufficientAccessRights)
    9 -> Ok(Busy)
    10 -> Ok(Unavailable)
    _ -> Error(Nil)
  }
}

