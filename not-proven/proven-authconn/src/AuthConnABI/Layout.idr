-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AuthConnABI.Layout: C-ABI-compatible numeric representations of each type.
--
-- Maps every constructor of the five core sum types (AuthMethod, AuthState,
-- TokenState, CredentialType, AuthError) to a fixed Bits8 value for C interop.
-- Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- The roundtrip proofs are formal verification: they guarantee at compile time
-- that encoding/decoding never loses information.  These proofs compile away
-- to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/authconn.h) and the
-- Zig FFI enums (ffi/zig/src/authconn.zig) exactly.

module AuthConnABI.Layout

import AuthConn.Types

%default total

---------------------------------------------------------------------------
-- AuthMethod (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| C-ABI representation size for AuthMethod (1 byte).
public export
authMethodSize : Nat
authMethodSize = 1

||| Map AuthMethod to its C-ABI byte value.
|||
||| Tag assignments:
|||   PasswordHash = 0
|||   Certificate  = 1
|||   Token        = 2
|||   MFA          = 3
|||   Kerberos     = 4
|||   SAML         = 5
|||   OIDC         = 6
public export
authMethodToTag : AuthMethod -> Bits8
authMethodToTag PasswordHash = 0
authMethodToTag Certificate  = 1
authMethodToTag Token        = 2
authMethodToTag MFA          = 3
authMethodToTag Kerberos     = 4
authMethodToTag SAML         = 5
authMethodToTag OIDC         = 6

||| Recover AuthMethod from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-6.
public export
tagToAuthMethod : Bits8 -> Maybe AuthMethod
tagToAuthMethod 0 = Just PasswordHash
tagToAuthMethod 1 = Just Certificate
tagToAuthMethod 2 = Just Token
tagToAuthMethod 3 = Just MFA
tagToAuthMethod 4 = Just Kerberos
tagToAuthMethod 5 = Just SAML
tagToAuthMethod 6 = Just OIDC
tagToAuthMethod _ = Nothing

||| Proof: encoding then decoding AuthMethod is the identity.
||| This is exhaustive over all seven constructors — the type checker
||| verifies that (tagToAuthMethod (authMethodToTag m)) reduces to (Just m)
||| for every possible value of m.
public export
authMethodRoundtrip : (m : AuthMethod) -> tagToAuthMethod (authMethodToTag m) = Just m
authMethodRoundtrip PasswordHash = Refl
authMethodRoundtrip Certificate  = Refl
authMethodRoundtrip Token        = Refl
authMethodRoundtrip MFA          = Refl
authMethodRoundtrip Kerberos     = Refl
authMethodRoundtrip SAML         = Refl
authMethodRoundtrip OIDC         = Refl

---------------------------------------------------------------------------
-- AuthState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for AuthState (1 byte).
public export
authStateSize : Nat
authStateSize = 1

||| Map AuthState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Unauthenticated = 0
|||   Challenging     = 1
|||   Authenticated   = 2
|||   Expired         = 3
|||   Revoked         = 4
|||   Locked          = 5
public export
authStateToTag : AuthState -> Bits8
authStateToTag Unauthenticated = 0
authStateToTag Challenging     = 1
authStateToTag Authenticated   = 2
authStateToTag Expired         = 3
authStateToTag Revoked         = 4
authStateToTag Locked          = 5

||| Recover AuthState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-5.
public export
tagToAuthState : Bits8 -> Maybe AuthState
tagToAuthState 0 = Just Unauthenticated
tagToAuthState 1 = Just Challenging
tagToAuthState 2 = Just Authenticated
tagToAuthState 3 = Just Expired
tagToAuthState 4 = Just Revoked
tagToAuthState 5 = Just Locked
tagToAuthState _ = Nothing

||| Proof: encoding then decoding AuthState is the identity.
public export
authStateRoundtrip : (s : AuthState) -> tagToAuthState (authStateToTag s) = Just s
authStateRoundtrip Unauthenticated = Refl
authStateRoundtrip Challenging     = Refl
authStateRoundtrip Authenticated   = Refl
authStateRoundtrip Expired         = Refl
authStateRoundtrip Revoked         = Refl
authStateRoundtrip Locked          = Refl

---------------------------------------------------------------------------
-- TokenState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for TokenState (1 byte).
public export
tokenStateSize : Nat
tokenStateSize = 1

||| Map TokenState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Valid      = 0
|||   Expired    = 1
|||   Revoked    = 2
|||   Refreshing = 3
public export
tokenStateToTag : TokenState -> Bits8
tokenStateToTag Valid      = 0
tokenStateToTag Expired    = 1
tokenStateToTag Revoked    = 2
tokenStateToTag Refreshing = 3

||| Recover TokenState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToTokenState : Bits8 -> Maybe TokenState
tagToTokenState 0 = Just Valid
tagToTokenState 1 = Just Expired
tagToTokenState 2 = Just Revoked
tagToTokenState 3 = Just Refreshing
tagToTokenState _ = Nothing

||| Proof: encoding then decoding TokenState is the identity.
public export
tokenStateRoundtrip : (ts : TokenState) -> tagToTokenState (tokenStateToTag ts) = Just ts
tokenStateRoundtrip Valid      = Refl
tokenStateRoundtrip Expired    = Refl
tokenStateRoundtrip Revoked    = Refl
tokenStateRoundtrip Refreshing = Refl

---------------------------------------------------------------------------
-- CredentialType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for CredentialType (1 byte).
public export
credentialTypeSize : Nat
credentialTypeSize = 1

||| Map CredentialType to its C-ABI byte value.
|||
||| Tag assignments:
|||   Opaque    = 0
|||   Hashed    = 1
|||   Encrypted = 2
|||   Delegated = 3
public export
credentialTypeToTag : CredentialType -> Bits8
credentialTypeToTag Opaque    = 0
credentialTypeToTag Hashed    = 1
credentialTypeToTag Encrypted = 2
credentialTypeToTag Delegated = 3

||| Recover CredentialType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToCredentialType : Bits8 -> Maybe CredentialType
tagToCredentialType 0 = Just Opaque
tagToCredentialType 1 = Just Hashed
tagToCredentialType 2 = Just Encrypted
tagToCredentialType 3 = Just Delegated
tagToCredentialType _ = Nothing

||| Proof: encoding then decoding CredentialType is the identity.
public export
credentialTypeRoundtrip : (ct : CredentialType) -> tagToCredentialType (credentialTypeToTag ct) = Just ct
credentialTypeRoundtrip Opaque    = Refl
credentialTypeRoundtrip Hashed    = Refl
credentialTypeRoundtrip Encrypted = Refl
credentialTypeRoundtrip Delegated = Refl

---------------------------------------------------------------------------
-- AuthError (7 constructors, tags 1-7; 0 = no error)
---------------------------------------------------------------------------

||| C-ABI representation size for AuthError (1 byte).
||| Note: tag 0 is reserved for "no error" in the C header (AUTHCONN_ERR_NONE).
||| The Idris2 type has no "None" constructor — the absence of an error
||| is represented by the absence of an AuthError value.
public export
authErrorSize : Nat
authErrorSize = 1

||| Map AuthError to its C-ABI byte value.
|||
||| Tag assignments (tag 0 reserved for AUTHCONN_ERR_NONE):
|||   InvalidCredentials  = 1
|||   AccountLocked       = 2
|||   TokenExpired        = 3
|||   MFARequired         = 4
|||   ProviderUnavailable = 5
|||   InsufficientScope   = 6
|||   SessionExpired      = 7
public export
authErrorToTag : AuthError -> Bits8
authErrorToTag InvalidCredentials  = 1
authErrorToTag AccountLocked       = 2
authErrorToTag TokenExpired        = 3
authErrorToTag MFARequired         = 4
authErrorToTag ProviderUnavailable = 5
authErrorToTag InsufficientScope   = 6
authErrorToTag SessionExpired      = 7

||| Recover AuthError from its C-ABI byte value.
||| Returns Nothing for tag 0 (no error) and for values > 7.
public export
tagToAuthError : Bits8 -> Maybe AuthError
tagToAuthError 1 = Just InvalidCredentials
tagToAuthError 2 = Just AccountLocked
tagToAuthError 3 = Just TokenExpired
tagToAuthError 4 = Just MFARequired
tagToAuthError 5 = Just ProviderUnavailable
tagToAuthError 6 = Just InsufficientScope
tagToAuthError 7 = Just SessionExpired
tagToAuthError _ = Nothing

||| Proof: encoding then decoding AuthError is the identity.
public export
authErrorRoundtrip : (e : AuthError) -> tagToAuthError (authErrorToTag e) = Just e
authErrorRoundtrip InvalidCredentials  = Refl
authErrorRoundtrip AccountLocked       = Refl
authErrorRoundtrip TokenExpired        = Refl
authErrorRoundtrip MFARequired         = Refl
authErrorRoundtrip ProviderUnavailable = Refl
authErrorRoundtrip InsufficientScope   = Refl
authErrorRoundtrip SessionExpired      = Refl
