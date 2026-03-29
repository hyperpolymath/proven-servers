-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AuthConn.Types: Core type definitions for authentication provider
-- connector interfaces.  Closed sum types representing authentication
-- methods, session states, token lifecycle states, credential types,
-- and error categories.  These types enforce that any authentication
-- backend connector is type-safe at the boundary — credential material
-- can never be accidentally logged or inspected when tagged as Opaque.

module AuthConn.Types

%default total

---------------------------------------------------------------------------
-- AuthMethod — the mechanism used to authenticate a principal.
---------------------------------------------------------------------------

||| Authentication mechanisms supported at the connector boundary.
public export
data AuthMethod : Type where
  ||| Password-based authentication (salted hash comparison).
  PasswordHash : AuthMethod
  ||| X.509 client certificate authentication (mutual TLS).
  Certificate  : AuthMethod
  ||| Bearer token authentication (JWT, opaque token, etc.).
  Token        : AuthMethod
  ||| Multi-factor authentication (TOTP, WebAuthn, SMS, etc.).
  MFA          : AuthMethod
  ||| Kerberos / SPNEGO ticket-based authentication.
  Kerberos     : AuthMethod
  ||| SAML 2.0 assertion-based authentication.
  SAML         : AuthMethod
  ||| OpenID Connect (OIDC) identity token authentication.
  OIDC         : AuthMethod

public export
Show AuthMethod where
  show PasswordHash = "PasswordHash"
  show Certificate  = "Certificate"
  show Token        = "Token"
  show MFA          = "MFA"
  show Kerberos     = "Kerberos"
  show SAML         = "SAML"
  show OIDC         = "OIDC"

---------------------------------------------------------------------------
-- AuthState — the authentication session state machine.
---------------------------------------------------------------------------

||| The lifecycle state of an authentication session.
public export
data AuthState : Type where
  ||| No authentication has been attempted.
  Unauthenticated : AuthState
  ||| A challenge has been issued (e.g. MFA prompt, SAML redirect).
  Challenging     : AuthState
  ||| Authentication succeeded; session is active.
  Authenticated   : AuthState
  ||| The session has expired due to inactivity or token expiry.
  Expired         : AuthState
  ||| The session has been explicitly revoked (logout or admin action).
  Revoked         : AuthState
  ||| The account has been locked due to too many failed attempts.
  Locked          : AuthState

public export
Show AuthState where
  show Unauthenticated = "Unauthenticated"
  show Challenging     = "Challenging"
  show Authenticated   = "Authenticated"
  show Expired         = "Expired"
  show Revoked         = "Revoked"
  show Locked          = "Locked"

---------------------------------------------------------------------------
-- TokenState — the lifecycle of an authentication token.
---------------------------------------------------------------------------

||| The lifecycle state of an authentication token (access or refresh).
public export
data TokenState : Type where
  ||| The token is valid and may be used for authentication.
  Valid      : TokenState
  ||| The token's expiry time has passed.
  Expired    : TokenState
  ||| The token has been explicitly revoked.
  Revoked    : TokenState
  ||| A refresh is in progress; a new token is being issued.
  Refreshing : TokenState

public export
Show TokenState where
  show Valid      = "Valid"
  show Expired    = "Expired"
  show Revoked    = "Revoked"
  show Refreshing = "Refreshing"

---------------------------------------------------------------------------
-- CredentialType — how credential material is handled.
---------------------------------------------------------------------------

||| The handling classification of credential material.
||| This type prevents accidental logging or inspection of secrets
||| by making the distinction structural rather than documentary.
public export
data CredentialType : Type where
  ||| Opaque credential — MUST NOT be logged, printed, or inspected.
  Opaque    : CredentialType
  ||| The credential is stored as a salted hash (e.g. bcrypt, argon2).
  Hashed    : CredentialType
  ||| The credential is encrypted at rest and must be decrypted to use.
  Encrypted : CredentialType
  ||| The credential is held by a remote identity provider; only a
  ||| reference or assertion is stored locally.
  Delegated : CredentialType

public export
Show CredentialType where
  show Opaque    = "Opaque"
  show Hashed    = "Hashed"
  show Encrypted = "Encrypted"
  show Delegated = "Delegated"

---------------------------------------------------------------------------
-- AuthError — authentication error categories.
---------------------------------------------------------------------------

||| Error categories that an authentication connector can report.
public export
data AuthError : Type where
  ||| The supplied credentials are incorrect.
  InvalidCredentials  : AuthError
  ||| The account has been locked due to repeated failures.
  AccountLocked       : AuthError
  ||| The presented token has expired.
  TokenExpired        : AuthError
  ||| A second factor is required but was not provided.
  MFARequired         : AuthError
  ||| The upstream identity provider is unreachable.
  ProviderUnavailable : AuthError
  ||| The token's scopes do not include the requested resource.
  InsufficientScope   : AuthError
  ||| The session has expired and must be re-established.
  SessionExpired      : AuthError

public export
Show AuthError where
  show InvalidCredentials  = "InvalidCredentials"
  show AccountLocked       = "AccountLocked"
  show TokenExpired        = "TokenExpired"
  show MFARequired         = "MFARequired"
  show ProviderUnavailable = "ProviderUnavailable"
  show InsufficientScope   = "InsufficientScope"
  show SessionExpired      = "SessionExpired"
