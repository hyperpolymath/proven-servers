//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Auth Server protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `AuthserverABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Auth Server Constants
// ===========================================================================

/// Auth Https Port constant.
pub const auth_https_port = 443

// ===========================================================================
// AuthMethod
// ===========================================================================

/// Authentication methods.
/// 
/// Matches `AuthMethod` in `AuthserverABI.Types`.
pub type AuthMethod {
  /// Password (tag 0).
  Password
  /// Certificate (tag 1).
  Certificate
  /// OAuth2 (tag 2).
  OAuth2
  /// SAML (tag 3).
  Saml
  /// FIDO2/WebAuthn (tag 4).
  Fido2
  /// Kerberos (tag 5).
  Kerberos
  /// LDAP (tag 6).
  Ldap
  /// RADIUS (tag 7).
  Radius
}

/// Convert a `AuthMethod` to its C-ABI tag value.
pub fn auth_method_to_int(value: AuthMethod) -> Int {
  case value {
    Password -> 0
    Certificate -> 1
    OAuth2 -> 2
    Saml -> 3
    Fido2 -> 4
    Kerberos -> 5
    Ldap -> 6
    Radius -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn auth_method_from_int(tag: Int) -> Result(AuthMethod, Nil) {
  case tag {
    0 -> Ok(Password)
    1 -> Ok(Certificate)
    2 -> Ok(OAuth2)
    3 -> Ok(Saml)
    4 -> Ok(Fido2)
    5 -> Ok(Kerberos)
    6 -> Ok(Ldap)
    7 -> Ok(Radius)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TokenType
// ===========================================================================

/// Authentication token types.
/// 
/// Matches `TokenType` in `AuthserverABI.Types`.
pub type TokenType {
  /// Access (tag 0).
  Access
  /// Refresh (tag 1).
  Refresh
  /// ID token (tag 2).
  Id
  /// API key (tag 3).
  Api
}

/// Convert a `TokenType` to its C-ABI tag value.
pub fn token_type_to_int(value: TokenType) -> Int {
  case value {
    Access -> 0
    Refresh -> 1
    Id -> 2
    Api -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn token_type_from_int(tag: Int) -> Result(TokenType, Nil) {
  case tag {
    0 -> Ok(Access)
    1 -> Ok(Refresh)
    2 -> Ok(Id)
    3 -> Ok(Api)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AuthResult
// ===========================================================================

/// Authentication attempt result codes.
/// 
/// Matches `AuthResult` in `AuthserverABI.Types`.
pub type AuthResult {
  /// Success (tag 0).
  Success
  /// InvalidCredentials (tag 1).
  InvalidCredentials
  /// AccountLocked (tag 2).
  AccountLocked
  /// AccountExpired (tag 3).
  AccountExpired
  /// MFA required (tag 4).
  MfaRequired
  /// IP address blocked (tag 5).
  IpBlocked
}

/// Convert a `AuthResult` to its C-ABI tag value.
pub fn auth_result_to_int(value: AuthResult) -> Int {
  case value {
    Success -> 0
    InvalidCredentials -> 1
    AccountLocked -> 2
    AccountExpired -> 3
    MfaRequired -> 4
    IpBlocked -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn auth_result_from_int(tag: Int) -> Result(AuthResult, Nil) {
  case tag {
    0 -> Ok(Success)
    1 -> Ok(InvalidCredentials)
    2 -> Ok(AccountLocked)
    3 -> Ok(AccountExpired)
    4 -> Ok(MfaRequired)
    5 -> Ok(IpBlocked)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// MfaMethod
// ===========================================================================

/// Multi-factor authentication methods.
/// 
/// Matches `MfaMethod` in `AuthserverABI.Types`.
pub type MfaMethod {
  /// TOTP (tag 0).
  Totp
  /// SMS (tag 1).
  Sms
  /// Push (tag 2).
  Push
  /// FIDO2 MFA (tag 3).
  Fido2Mfa
  /// Email (tag 4).
  Email
}

/// Convert a `MfaMethod` to its C-ABI tag value.
pub fn mfa_method_to_int(value: MfaMethod) -> Int {
  case value {
    Totp -> 0
    Sms -> 1
    Push -> 2
    Fido2Mfa -> 3
    Email -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn mfa_method_from_int(tag: Int) -> Result(MfaMethod, Nil) {
  case tag {
    0 -> Ok(Totp)
    1 -> Ok(Sms)
    2 -> Ok(Push)
    3 -> Ok(Fido2Mfa)
    4 -> Ok(Email)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// Auth session lifecycle states.
/// 
/// Matches `SessionState` in `AuthserverABI.Types`.
pub type SessionState {
  /// Active (tag 0).
  Active
  /// Expired (tag 1).
  Expired
  /// Revoked (tag 2).
  Revoked
  /// Locked (tag 3).
  Locked
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Active -> 0
    Expired -> 1
    Revoked -> 2
    Locked -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Active)
    1 -> Ok(Expired)
    2 -> Ok(Revoked)
    3 -> Ok(Locked)
    _ -> Error(Nil)
  }
}

