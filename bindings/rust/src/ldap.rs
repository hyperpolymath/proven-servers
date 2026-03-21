// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! LDAP protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `LdapABI.Types` and its type definitions:
//! - `SessionState` — LDAP session state machine (4 constructors, tags 0-3)
//! - `Operation`    — LDAP operations (10 constructors, tags 0-9)
//! - `SearchScope`  — search scope levels (3 constructors, tags 0-2)
//! - `ResultCode`   — LDAP result codes (11 constructors, tags 0-10)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// LDAP Constants
// ===========================================================================

/// Standard LDAP port (RFC 4511).
pub const LDAP_PORT: u16 = 389;

/// Standard LDAPS (LDAP over TLS) port.
pub const LDAPS_PORT: u16 = 636;

// ===========================================================================
// SessionState (tags 0-3)
// ===========================================================================

/// LDAP session state machine.
///
/// Matches `SessionState` in `LdapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Connected but not authenticated (tag 0).
    Anonymous = 0,
    /// Successfully bound (authenticated) (tag 1).
    Bound = 1,
    /// Session is closed (tag 2).
    Closed = 2,
    /// Bind operation in progress (tag 3).
    Binding = 3,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Anonymous),
            1 => Some(Self::Bound),
            2 => Some(Self::Closed),
            3 => Some(Self::Binding),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: SessionState) -> bool {
        matches!(
            (self, next),
            (Self::Anonymous, Self::Binding)
                | (Self::Binding, Self::Bound)
                | (Self::Binding, Self::Anonymous) // Bind failed
                | (Self::Bound, Self::Anonymous)   // Unbind
                | (_, Self::Closed)                // Can close from any state
        )
    }

    /// Whether operations requiring authentication can be performed.
    pub fn is_authenticated(self) -> bool {
        matches!(self, Self::Bound)
    }
}

impl fmt::Display for SessionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Operation (tags 0-9)
// ===========================================================================

/// LDAP protocol operations (RFC 4511).
///
/// Matches `Operation` in `LdapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Operation {
    /// Bind (authenticate) to the directory (tag 0).
    Bind = 0,
    /// Unbind (close session) (tag 1).
    Unbind = 1,
    /// Search for directory entries (tag 2).
    Search = 2,
    /// Modify an existing entry (tag 3).
    Modify = 3,
    /// Add a new entry (tag 4).
    Add = 4,
    /// Delete an entry (tag 5).
    Delete = 5,
    /// Modify the DN (rename/move) of an entry (tag 6).
    ModDn = 6,
    /// Compare an attribute value (tag 7).
    Compare = 7,
    /// Abandon a pending operation (tag 8).
    Abandon = 8,
    /// Extended operation (tag 9).
    Extended = 9,
}

impl Operation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Bind),
            1 => Some(Self::Unbind),
            2 => Some(Self::Search),
            3 => Some(Self::Modify),
            4 => Some(Self::Add),
            5 => Some(Self::Delete),
            6 => Some(Self::ModDn),
            7 => Some(Self::Compare),
            8 => Some(Self::Abandon),
            9 => Some(Self::Extended),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this operation modifies directory data.
    pub fn is_write(self) -> bool {
        matches!(self, Self::Modify | Self::Add | Self::Delete | Self::ModDn)
    }

    /// Whether this operation requires the session to be bound.
    pub fn requires_bind(self) -> bool {
        // All operations except Bind, Unbind, and Abandon typically require auth.
        !matches!(self, Self::Bind | Self::Unbind | Self::Abandon)
    }

    /// All supported operations.
    pub const ALL: [Operation; 10] = [
        Self::Bind,
        Self::Unbind,
        Self::Search,
        Self::Modify,
        Self::Add,
        Self::Delete,
        Self::ModDn,
        Self::Compare,
        Self::Abandon,
        Self::Extended,
    ];
}

impl fmt::Display for Operation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SearchScope (tags 0-2)
// ===========================================================================

/// LDAP search scope levels (RFC 4511 Section 4.5.1.2).
///
/// Matches `SearchScope` in `LdapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SearchScope {
    /// Search only the base object itself (tag 0).
    BaseObject = 0,
    /// Search one level below the base object (tag 1).
    SingleLevel = 1,
    /// Search the entire subtree below the base object (tag 2).
    WholeSubtree = 2,
}

impl SearchScope {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::BaseObject),
            1 => Some(Self::SingleLevel),
            2 => Some(Self::WholeSubtree),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for SearchScope {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::BaseObject => "base",
            Self::SingleLevel => "one",
            Self::WholeSubtree => "sub",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// ResultCode (tags 0-10)
// ===========================================================================

/// LDAP result codes (RFC 4511 Appendix A).
///
/// Matches `ResultCode` in `LdapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResultCode {
    /// Operation completed successfully (tag 0).
    Success = 0,
    /// An internal error occurred (tag 1).
    OperationsError = 1,
    /// Protocol violation detected (tag 2).
    ProtocolError = 2,
    /// Time limit for the operation was exceeded (tag 3).
    TimeLimitExceeded = 3,
    /// Size limit for the operation was exceeded (tag 4).
    SizeLimitExceeded = 4,
    /// Requested auth method not supported (tag 5).
    AuthMethodNotSupported = 5,
    /// The target entry does not exist (tag 6).
    NoSuchObject = 6,
    /// Provided credentials are invalid (tag 7).
    InvalidCredentials = 7,
    /// Caller lacks sufficient access rights (tag 8).
    InsufficientAccessRights = 8,
    /// Server is too busy to handle the request (tag 9).
    Busy = 9,
    /// Server is unavailable (tag 10).
    Unavailable = 10,
}

impl ResultCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Success),
            1 => Some(Self::OperationsError),
            2 => Some(Self::ProtocolError),
            3 => Some(Self::TimeLimitExceeded),
            4 => Some(Self::SizeLimitExceeded),
            5 => Some(Self::AuthMethodNotSupported),
            6 => Some(Self::NoSuchObject),
            7 => Some(Self::InvalidCredentials),
            8 => Some(Self::InsufficientAccessRights),
            9 => Some(Self::Busy),
            10 => Some(Self::Unavailable),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this result code indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Success)
    }

    /// Whether this result code indicates an authentication/authorisation failure.
    pub fn is_auth_failure(self) -> bool {
        matches!(
            self,
            Self::AuthMethodNotSupported
                | Self::InvalidCredentials
                | Self::InsufficientAccessRights
        )
    }

    /// Whether this is a transient error that may succeed on retry.
    pub fn is_transient(self) -> bool {
        matches!(self, Self::Busy | Self::Unavailable)
    }
}

impl fmt::Display for ResultCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn session_state_roundtrip() {
        for tag in 0u8..=3 {
            let state = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(state.to_tag(), tag);
        }
        assert!(SessionState::from_tag(4).is_none());
    }

    #[test]
    fn session_state_transitions() {
        assert!(SessionState::Anonymous.can_transition_to(SessionState::Binding));
        assert!(SessionState::Binding.can_transition_to(SessionState::Bound));
        assert!(SessionState::Binding.can_transition_to(SessionState::Anonymous));
        assert!(SessionState::Bound.can_transition_to(SessionState::Anonymous));
        assert!(SessionState::Anonymous.can_transition_to(SessionState::Closed));
        assert!(SessionState::Bound.can_transition_to(SessionState::Closed));
        assert!(!SessionState::Anonymous.can_transition_to(SessionState::Bound));
    }

    #[test]
    fn session_state_authentication() {
        assert!(!SessionState::Anonymous.is_authenticated());
        assert!(SessionState::Bound.is_authenticated());
        assert!(!SessionState::Closed.is_authenticated());
        assert!(!SessionState::Binding.is_authenticated());
    }

    #[test]
    fn operation_roundtrip() {
        for op in Operation::ALL {
            let tag = op.to_tag();
            let decoded = Operation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, op);
        }
        assert!(Operation::from_tag(10).is_none());
    }

    #[test]
    fn operation_classification() {
        assert!(Operation::Modify.is_write());
        assert!(Operation::Add.is_write());
        assert!(Operation::Delete.is_write());
        assert!(Operation::ModDn.is_write());
        assert!(!Operation::Search.is_write());
        assert!(!Operation::Bind.is_write());

        assert!(!Operation::Bind.requires_bind());
        assert!(!Operation::Unbind.requires_bind());
        assert!(!Operation::Abandon.requires_bind());
        assert!(Operation::Search.requires_bind());
        assert!(Operation::Modify.requires_bind());
    }

    #[test]
    fn search_scope_roundtrip() {
        for tag in 0u8..=2 {
            let scope = SearchScope::from_tag(tag).expect("valid tag");
            assert_eq!(scope.to_tag(), tag);
        }
        assert!(SearchScope::from_tag(3).is_none());
    }

    #[test]
    fn result_code_roundtrip() {
        for tag in 0u8..=10 {
            let rc = ResultCode::from_tag(tag).expect("valid tag");
            assert_eq!(rc.to_tag(), tag);
        }
        assert!(ResultCode::from_tag(11).is_none());
    }

    #[test]
    fn result_code_classification() {
        assert!(ResultCode::Success.is_success());
        assert!(!ResultCode::OperationsError.is_success());

        assert!(ResultCode::InvalidCredentials.is_auth_failure());
        assert!(ResultCode::InsufficientAccessRights.is_auth_failure());
        assert!(!ResultCode::Success.is_auth_failure());

        assert!(ResultCode::Busy.is_transient());
        assert!(ResultCode::Unavailable.is_transient());
        assert!(!ResultCode::ProtocolError.is_transient());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(LDAP_PORT, 389);
        assert_eq!(LDAPS_PORT, 636);
    }
}
