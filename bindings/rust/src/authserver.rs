// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Authentication server types for the proven-servers ABI.
//!
//! Formally verified authentication/authorization types.
//! Mirrors the Idris2 module `AuthserverABI.Types`.
//!
//! - `AuthMethod` -- Authentication methods.
//! - `TokenType` -- Authentication token types.
//! - `AuthResult` -- Authentication attempt result codes.
//! - `MfaMethod` -- Multi-factor authentication methods.
//! - `SessionState` -- Auth session lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Authentication server Constants
// ===========================================================================

/// Standard HTTPS port for auth.
pub const AUTH_HTTPS_PORT: u16 = 443;

// ===========================================================================
// AuthMethod (tags 0-7)
// ===========================================================================

/// Authentication methods.
///
/// Matches `AuthMethod` in `AuthserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthMethod {
    /// Password (tag 0).
    Password = 0,
    /// Certificate (tag 1).
    Certificate = 1,
    /// OAuth2 (tag 2).
    OAuth2 = 2,
    /// SAML (tag 3).
    Saml = 3,
    /// FIDO2/WebAuthn (tag 4).
    Fido2 = 4,
    /// Kerberos (tag 5).
    Kerberos = 5,
    /// LDAP (tag 6).
    Ldap = 6,
    /// RADIUS (tag 7).
    Radius = 7,
}

impl AuthMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Password),
            1 => Some(Self::Certificate),
            2 => Some(Self::OAuth2),
            3 => Some(Self::Saml),
            4 => Some(Self::Fido2),
            5 => Some(Self::Kerberos),
            6 => Some(Self::Ldap),
            7 => Some(Self::Radius),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this method is passwordless.
    pub fn is_passwordless(self) -> bool {
        matches!(self, Self::Certificate | Self::Fido2)
    }

    /// All variants of this type.
    pub const ALL: [AuthMethod; 8] = [
        Self::Password, Self::Certificate, Self::OAuth2, Self::Saml, Self::Fido2, Self::Kerberos, Self::Ldap, Self::Radius,
    ];
}

impl fmt::Display for AuthMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TokenType (tags 0-3)
// ===========================================================================

/// Authentication token types.
///
/// Matches `TokenType` in `AuthserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TokenType {
    /// Access (tag 0).
    Access = 0,
    /// Refresh (tag 1).
    Refresh = 1,
    /// ID token (tag 2).
    Id = 2,
    /// API key (tag 3).
    Api = 3,
}

impl TokenType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Access),
            1 => Some(Self::Refresh),
            2 => Some(Self::Id),
            3 => Some(Self::Api),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [TokenType; 4] = [
        Self::Access, Self::Refresh, Self::Id, Self::Api,
    ];
}

impl fmt::Display for TokenType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AuthResult (tags 0-5)
// ===========================================================================

/// Authentication attempt result codes.
///
/// Matches `AuthResult` in `AuthserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthResult {
    /// Success (tag 0).
    Success = 0,
    /// InvalidCredentials (tag 1).
    InvalidCredentials = 1,
    /// AccountLocked (tag 2).
    AccountLocked = 2,
    /// AccountExpired (tag 3).
    AccountExpired = 3,
    /// MFA required (tag 4).
    MfaRequired = 4,
    /// IP address blocked (tag 5).
    IpBlocked = 5,
}

impl AuthResult {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Success),
            1 => Some(Self::InvalidCredentials),
            2 => Some(Self::AccountLocked),
            3 => Some(Self::AccountExpired),
            4 => Some(Self::MfaRequired),
            5 => Some(Self::IpBlocked),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether authentication succeeded.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Success)
    }

    /// Whether the result requires further user action.
    pub fn requires_action(self) -> bool {
        matches!(self, Self::MfaRequired)
    }

    /// All variants of this type.
    pub const ALL: [AuthResult; 6] = [
        Self::Success, Self::InvalidCredentials, Self::AccountLocked, Self::AccountExpired, Self::MfaRequired, Self::IpBlocked,
    ];
}

impl fmt::Display for AuthResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// MfaMethod (tags 0-4)
// ===========================================================================

/// Multi-factor authentication methods.
///
/// Matches `MfaMethod` in `AuthserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MfaMethod {
    /// TOTP (tag 0).
    Totp = 0,
    /// SMS (tag 1).
    Sms = 1,
    /// Push (tag 2).
    Push = 2,
    /// FIDO2 MFA (tag 3).
    Fido2Mfa = 3,
    /// Email (tag 4).
    Email = 4,
}

impl MfaMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Totp),
            1 => Some(Self::Sms),
            2 => Some(Self::Push),
            3 => Some(Self::Fido2Mfa),
            4 => Some(Self::Email),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [MfaMethod; 5] = [
        Self::Totp, Self::Sms, Self::Push, Self::Fido2Mfa, Self::Email,
    ];
}

impl fmt::Display for MfaMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-3)
// ===========================================================================

/// Auth session lifecycle states.
///
/// Matches `SessionState` in `AuthserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Active (tag 0).
    Active = 0,
    /// Expired (tag 1).
    Expired = 1,
    /// Revoked (tag 2).
    Revoked = 2,
    /// Locked (tag 3).
    Locked = 3,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Active),
            1 => Some(Self::Expired),
            2 => Some(Self::Revoked),
            3 => Some(Self::Locked),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the session is still usable.
    pub fn is_valid(self) -> bool {
        matches!(self, Self::Active)
    }

    /// All variants of this type.
    pub const ALL: [SessionState; 4] = [
        Self::Active, Self::Expired, Self::Revoked, Self::Locked,
    ];
}

impl fmt::Display for SessionState {
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
    fn auth_method_roundtrip() {
        for v in AuthMethod::ALL {
            let tag = v.to_tag();
            let decoded = AuthMethod::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AuthMethod::from_tag(8).is_none());
    }

    #[test]
    fn token_type_roundtrip() {
        for v in TokenType::ALL {
            let tag = v.to_tag();
            let decoded = TokenType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(TokenType::from_tag(4).is_none());
    }

    #[test]
    fn auth_result_roundtrip() {
        for v in AuthResult::ALL {
            let tag = v.to_tag();
            let decoded = AuthResult::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AuthResult::from_tag(6).is_none());
    }

    #[test]
    fn mfa_method_roundtrip() {
        for v in MfaMethod::ALL {
            let tag = v.to_tag();
            let decoded = MfaMethod::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(MfaMethod::from_tag(5).is_none());
    }

    #[test]
    fn session_state_roundtrip() {
        for v in SessionState::ALL {
            let tag = v.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionState::from_tag(4).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(AUTH_HTTPS_PORT, 443);
    }

}
