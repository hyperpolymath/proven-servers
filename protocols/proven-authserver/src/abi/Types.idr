-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- AuthserverABI.Types: C-ABI-compatible numeric representations of Authserver types.
--
-- Maps every constructor of the core Authserver sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/authserver.h) and the
-- Zig FFI enums (ffi/zig/src/authserver.zig) exactly.
--
-- Types covered:
--   AuthMethod   (8 constructors, tags 0-7)
--   TokenType    (4 constructors, tags 0-3)
--   AuthResult   (6 constructors, tags 0-5)
--   MFAMethod    (5 constructors, tags 0-4)
--   SessionState (4 constructors, tags 0-3)

module AuthserverABI.Types

import Authserver.Types

%default total

---------------------------------------------------------------------------
-- AuthMethod (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
authMethodSize : Nat
authMethodSize = 1

||| Encode an AuthMethod to its ABI tag value.
public export
authMethodToTag : AuthMethod -> Bits8
authMethodToTag Password    = 0
authMethodToTag Certificate = 1
authMethodToTag OAuth2      = 2
authMethodToTag SAML        = 3
authMethodToTag FIDO2       = 4
authMethodToTag Kerberos    = 5
authMethodToTag LDAP        = 6
authMethodToTag RADIUS      = 7

||| Decode an ABI tag to an AuthMethod.
public export
tagToAuthMethod : Bits8 -> Maybe AuthMethod
tagToAuthMethod 0 = Just Password
tagToAuthMethod 1 = Just Certificate
tagToAuthMethod 2 = Just OAuth2
tagToAuthMethod 3 = Just SAML
tagToAuthMethod 4 = Just FIDO2
tagToAuthMethod 5 = Just Kerberos
tagToAuthMethod 6 = Just LDAP
tagToAuthMethod 7 = Just RADIUS
tagToAuthMethod _ = Nothing

||| Roundtrip proof: decoding an encoded AuthMethod yields the original.
public export
authMethodRoundtrip : (m : AuthMethod) -> tagToAuthMethod (authMethodToTag m) = Just m
authMethodRoundtrip Password    = Refl
authMethodRoundtrip Certificate = Refl
authMethodRoundtrip OAuth2      = Refl
authMethodRoundtrip SAML        = Refl
authMethodRoundtrip FIDO2       = Refl
authMethodRoundtrip Kerberos    = Refl
authMethodRoundtrip LDAP        = Refl
authMethodRoundtrip RADIUS      = Refl

---------------------------------------------------------------------------
-- TokenType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
tokenTypeSize : Nat
tokenTypeSize = 1

||| Encode a TokenType to its ABI tag value.
public export
tokenTypeToTag : TokenType -> Bits8
tokenTypeToTag Access  = 0
tokenTypeToTag Refresh = 1
tokenTypeToTag ID      = 2
tokenTypeToTag API     = 3

||| Decode an ABI tag to a TokenType.
public export
tagToTokenType : Bits8 -> Maybe TokenType
tagToTokenType 0 = Just Access
tagToTokenType 1 = Just Refresh
tagToTokenType 2 = Just ID
tagToTokenType 3 = Just API
tagToTokenType _ = Nothing

||| Roundtrip proof: decoding an encoded TokenType yields the original.
public export
tokenTypeRoundtrip : (t : TokenType) -> tagToTokenType (tokenTypeToTag t) = Just t
tokenTypeRoundtrip Access  = Refl
tokenTypeRoundtrip Refresh = Refl
tokenTypeRoundtrip ID      = Refl
tokenTypeRoundtrip API     = Refl

---------------------------------------------------------------------------
-- AuthResult (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
authResultSize : Nat
authResultSize = 1

||| Encode an AuthResult to its ABI tag value.
public export
authResultToTag : AuthResult -> Bits8
authResultToTag Success            = 0
authResultToTag InvalidCredentials = 1
authResultToTag AccountLocked      = 2
authResultToTag AccountExpired     = 3
authResultToTag MFARequired        = 4
authResultToTag IPBlocked          = 5

||| Decode an ABI tag to an AuthResult.
public export
tagToAuthResult : Bits8 -> Maybe AuthResult
tagToAuthResult 0 = Just Success
tagToAuthResult 1 = Just InvalidCredentials
tagToAuthResult 2 = Just AccountLocked
tagToAuthResult 3 = Just AccountExpired
tagToAuthResult 4 = Just MFARequired
tagToAuthResult 5 = Just IPBlocked
tagToAuthResult _ = Nothing

||| Roundtrip proof: decoding an encoded AuthResult yields the original.
public export
authResultRoundtrip : (r : AuthResult) -> tagToAuthResult (authResultToTag r) = Just r
authResultRoundtrip Success            = Refl
authResultRoundtrip InvalidCredentials = Refl
authResultRoundtrip AccountLocked      = Refl
authResultRoundtrip AccountExpired     = Refl
authResultRoundtrip MFARequired        = Refl
authResultRoundtrip IPBlocked          = Refl

---------------------------------------------------------------------------
-- MFAMethod (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
mfaMethodSize : Nat
mfaMethodSize = 1

||| Encode an MFAMethod to its ABI tag value.
public export
mfaMethodToTag : MFAMethod -> Bits8
mfaMethodToTag TOTP      = 0
mfaMethodToTag SMS       = 1
mfaMethodToTag Push      = 2
mfaMethodToTag FIDO2_MFA = 3
mfaMethodToTag Email     = 4

||| Decode an ABI tag to an MFAMethod.
public export
tagToMFAMethod : Bits8 -> Maybe MFAMethod
tagToMFAMethod 0 = Just TOTP
tagToMFAMethod 1 = Just SMS
tagToMFAMethod 2 = Just Push
tagToMFAMethod 3 = Just FIDO2_MFA
tagToMFAMethod 4 = Just Email
tagToMFAMethod _ = Nothing

||| Roundtrip proof: decoding an encoded MFAMethod yields the original.
public export
mfaMethodRoundtrip : (m : MFAMethod) -> tagToMFAMethod (mfaMethodToTag m) = Just m
mfaMethodRoundtrip TOTP      = Refl
mfaMethodRoundtrip SMS       = Refl
mfaMethodRoundtrip Push      = Refl
mfaMethodRoundtrip FIDO2_MFA = Refl
mfaMethodRoundtrip Email     = Refl

---------------------------------------------------------------------------
-- SessionState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
sessionStateSize : Nat
sessionStateSize = 1

||| Encode a SessionState to its ABI tag value.
public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag Active  = 0
sessionStateToTag Expired = 1
sessionStateToTag Revoked = 2
sessionStateToTag Locked  = 3

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Active
tagToSessionState 1 = Just Expired
tagToSessionState 2 = Just Revoked
tagToSessionState 3 = Just Locked
tagToSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SessionState yields the original.
public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip Active  = Refl
sessionStateRoundtrip Expired = Refl
sessionStateRoundtrip Revoked = Refl
sessionStateRoundtrip Locked  = Refl
