// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Authentication server types for the proven-servers ABI.
//
// Mirrors the Idris2 module AuthserverABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard HTTPS port for auth.
let authHttpsPort = 443

// ===========================================================================
// AuthMethod (tags 0-7)
// ===========================================================================

/// Standard HTTPS port for auth.
type authMethod =
  | @as(0) Password
  | @as(1) Certificate
  | @as(2) OAuth2
  | @as(3) Saml
  | @as(4) Fido2
  | @as(5) Kerberos
  | @as(6) Ldap
  | @as(7) Radius

/// Decode from the C-ABI tag value.
let authMethodFromTag = (tag: int): option<authMethod> =>
  switch tag {
  | 0 => Some(Password)
  | 1 => Some(Certificate)
  | 2 => Some(OAuth2)
  | 3 => Some(Saml)
  | 4 => Some(Fido2)
  | 5 => Some(Kerberos)
  | 6 => Some(Ldap)
  | 7 => Some(Radius)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authMethodToTag = (v: authMethod): int =>
  switch v {
  | Password => 0
  | Certificate => 1
  | OAuth2 => 2
  | Saml => 3
  | Fido2 => 4
  | Kerberos => 5
  | Ldap => 6
  | Radius => 7
  }

/// Whether this method is passwordless.
let authMethodIsPasswordless = (v: authMethod): bool =>
  switch v {
  | Certificate | Fido2 => true
  | _ => false
  }

// ===========================================================================
// TokenType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type tokenType =
  | @as(0) Access
  | @as(1) Refresh
  | @as(2) Id
  | @as(3) Api

/// Decode from the C-ABI tag value.
let tokenTypeFromTag = (tag: int): option<tokenType> =>
  switch tag {
  | 0 => Some(Access)
  | 1 => Some(Refresh)
  | 2 => Some(Id)
  | 3 => Some(Api)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let tokenTypeToTag = (v: tokenType): int =>
  switch v {
  | Access => 0
  | Refresh => 1
  | Id => 2
  | Api => 3
  }

// ===========================================================================
// AuthResult (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type authResult =
  | @as(0) Success
  | @as(1) InvalidCredentials
  | @as(2) AccountLocked
  | @as(3) AccountExpired
  | @as(4) MfaRequired
  | @as(5) IpBlocked

/// Decode from the C-ABI tag value.
let authResultFromTag = (tag: int): option<authResult> =>
  switch tag {
  | 0 => Some(Success)
  | 1 => Some(InvalidCredentials)
  | 2 => Some(AccountLocked)
  | 3 => Some(AccountExpired)
  | 4 => Some(MfaRequired)
  | 5 => Some(IpBlocked)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authResultToTag = (v: authResult): int =>
  switch v {
  | Success => 0
  | InvalidCredentials => 1
  | AccountLocked => 2
  | AccountExpired => 3
  | MfaRequired => 4
  | IpBlocked => 5
  }

/// Whether authentication succeeded.
let authResultIsSuccess = (v: authResult): bool =>
  switch v {
  | Success => true
  | _ => false
  }

/// Whether the result requires further user action.
let authResultRequiresAction = (v: authResult): bool =>
  switch v {
  | MfaRequired => true
  | _ => false
  }

// ===========================================================================
// MfaMethod (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type mfaMethod =
  | @as(0) Totp
  | @as(1) Sms
  | @as(2) Push
  | @as(3) Fido2Mfa
  | @as(4) Email

/// Decode from the C-ABI tag value.
let mfaMethodFromTag = (tag: int): option<mfaMethod> =>
  switch tag {
  | 0 => Some(Totp)
  | 1 => Some(Sms)
  | 2 => Some(Push)
  | 3 => Some(Fido2Mfa)
  | 4 => Some(Email)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let mfaMethodToTag = (v: mfaMethod): int =>
  switch v {
  | Totp => 0
  | Sms => 1
  | Push => 2
  | Fido2Mfa => 3
  | Email => 4
  }

// ===========================================================================
// SessionState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Active
  | @as(1) Expired
  | @as(2) Revoked
  | @as(3) Locked

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Active)
  | 1 => Some(Expired)
  | 2 => Some(Revoked)
  | 3 => Some(Locked)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Active => 0
  | Expired => 1
  | Revoked => 2
  | Locked => 3
  }

/// Whether the session is still usable.
let sessionStateIsValid = (v: sessionState): bool =>
  switch v {
  | Active => true
  | _ => false
  }

