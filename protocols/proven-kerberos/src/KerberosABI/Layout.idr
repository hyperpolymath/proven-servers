-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- KerberosABI.Layout: C-ABI-compatible numeric representations of Kerberos types.
--
-- Maps every constructor of the core Kerberos sum types to fixed Bits8 values
-- for C interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/kerberos.h) and the
-- Zig FFI enums (ffi/zig/src/kerberos.zig) exactly.
--
-- Types covered:
--   MessageType      (7 constructors, tags 0-6)
--   EncryptionType   (5 constructors, tags 0-4)
--   PrincipalType    (7 constructors, tags 0-6)
--   TicketFlag       (7 constructors, tags 0-6)
--   ErrorCode        (10 constructors, tags 0-9)
--   AuthState        (5 constructors, tags 0-4)
--   EncStrength      (3 constructors, tags 0-2)
--   PreAuthType      (4 constructors, tags 0-3)

module KerberosABI.Layout

import Kerberos.Types

%default total

---------------------------------------------------------------------------
-- MessageType (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| Size in bytes for the MessageType tag.
public export
messageTypeSize : Nat
messageTypeSize = 1

||| Encode a MessageType to its ABI tag value.
||| Tags 0-6 correspond to AS_REQ through KRB_ERROR as per RFC 4120.
public export
messageTypeToTag : MessageType -> Bits8
messageTypeToTag AS_REQ    = 0
messageTypeToTag AS_REP    = 1
messageTypeToTag TGS_REQ   = 2
messageTypeToTag TGS_REP   = 3
messageTypeToTag AP_REQ    = 4
messageTypeToTag AP_REP    = 5
messageTypeToTag KRB_ERROR = 6
messageTypeToTag KRB_SAFE  = 7
messageTypeToTag KRB_PRIV  = 8
messageTypeToTag KRB_CRED  = 9

||| Decode an ABI tag back to a MessageType.
||| Returns Nothing for tags outside the valid range.
public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0 = Just AS_REQ
tagToMessageType 1 = Just AS_REP
tagToMessageType 2 = Just TGS_REQ
tagToMessageType 3 = Just TGS_REP
tagToMessageType 4 = Just AP_REQ
tagToMessageType 5 = Just AP_REP
tagToMessageType 6 = Just KRB_ERROR
tagToMessageType 7 = Just KRB_SAFE
tagToMessageType 8 = Just KRB_PRIV
tagToMessageType 9 = Just KRB_CRED
tagToMessageType _ = Nothing

||| Roundtrip proof: decode(encode(m)) = Just m for all MessageType.
public export
messageTypeRoundtrip : (m : MessageType) -> tagToMessageType (messageTypeToTag m) = Just m
messageTypeRoundtrip AS_REQ    = Refl
messageTypeRoundtrip AS_REP    = Refl
messageTypeRoundtrip TGS_REQ   = Refl
messageTypeRoundtrip TGS_REP   = Refl
messageTypeRoundtrip AP_REQ    = Refl
messageTypeRoundtrip AP_REP    = Refl
messageTypeRoundtrip KRB_ERROR = Refl
messageTypeRoundtrip KRB_SAFE  = Refl
messageTypeRoundtrip KRB_PRIV  = Refl
messageTypeRoundtrip KRB_CRED  = Refl

---------------------------------------------------------------------------
-- EncryptionType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| Size in bytes for the EncryptionType tag.
public export
encryptionTypeSize : Nat
encryptionTypeSize = 1

||| Encode an EncryptionType to its ABI tag value.
||| AES-256 is tag 0 (preferred), legacy types have higher tags.
public export
encryptionTypeToTag : EncryptionType -> Bits8
encryptionTypeToTag AES256_CTS_HMAC_SHA1   = 0
encryptionTypeToTag AES128_CTS_HMAC_SHA1   = 1
encryptionTypeToTag AES256_CTS_HMAC_SHA384 = 2
encryptionTypeToTag RC4_HMAC               = 3
encryptionTypeToTag DES3_CBC_SHA1          = 4

||| Decode an ABI tag back to an EncryptionType.
public export
tagToEncryptionType : Bits8 -> Maybe EncryptionType
tagToEncryptionType 0 = Just AES256_CTS_HMAC_SHA1
tagToEncryptionType 1 = Just AES128_CTS_HMAC_SHA1
tagToEncryptionType 2 = Just AES256_CTS_HMAC_SHA384
tagToEncryptionType 3 = Just RC4_HMAC
tagToEncryptionType 4 = Just DES3_CBC_SHA1
tagToEncryptionType _ = Nothing

||| Roundtrip proof for EncryptionType.
public export
encryptionTypeRoundtrip : (e : EncryptionType) -> tagToEncryptionType (encryptionTypeToTag e) = Just e
encryptionTypeRoundtrip AES256_CTS_HMAC_SHA1   = Refl
encryptionTypeRoundtrip AES128_CTS_HMAC_SHA1   = Refl
encryptionTypeRoundtrip AES256_CTS_HMAC_SHA384 = Refl
encryptionTypeRoundtrip RC4_HMAC               = Refl
encryptionTypeRoundtrip DES3_CBC_SHA1          = Refl

---------------------------------------------------------------------------
-- PrincipalType (7 constructors, tags 0-6)
-- RFC 4120 Section 6.2, name-type values.
---------------------------------------------------------------------------

||| Kerberos principal name types per RFC 4120 Section 6.2.
||| Determines how the principal name components are interpreted.
public export
data PrincipalType : Type where
  ||| Unknown name type (NT-UNKNOWN, 0).
  NtUnknown     : PrincipalType
  ||| Just the name of the principal (NT-PRINCIPAL, 1).
  NtPrincipal   : PrincipalType
  ||| Service and other unique instance (NT-SRV-INST, 2).
  NtSrvInst     : PrincipalType
  ||| Service with host as instance (NT-SRV-HST, 3).
  NtSrvHst      : PrincipalType
  ||| Unique ID (NT-UID, 5).
  NtUid         : PrincipalType
  ||| Encoded X.509 Distinguished Name (NT-X500-PRINCIPAL, 6).
  NtX500        : PrincipalType
  ||| Enterprise name; can be email-style (NT-ENTERPRISE, 10).
  NtEnterprise  : PrincipalType

public export
Eq PrincipalType where
  NtUnknown    == NtUnknown    = True
  NtPrincipal  == NtPrincipal  = True
  NtSrvInst    == NtSrvInst    = True
  NtSrvHst     == NtSrvHst     = True
  NtUid        == NtUid        = True
  NtX500       == NtX500       = True
  NtEnterprise == NtEnterprise = True
  _            == _            = False

public export
Show PrincipalType where
  show NtUnknown    = "NT-UNKNOWN"
  show NtPrincipal  = "NT-PRINCIPAL"
  show NtSrvInst    = "NT-SRV-INST"
  show NtSrvHst     = "NT-SRV-HST"
  show NtUid        = "NT-UID"
  show NtX500       = "NT-X500-PRINCIPAL"
  show NtEnterprise = "NT-ENTERPRISE"

||| Size in bytes for the PrincipalType tag.
public export
principalTypeSize : Nat
principalTypeSize = 1

||| Encode a PrincipalType to its ABI tag value.
public export
principalTypeToTag : PrincipalType -> Bits8
principalTypeToTag NtUnknown    = 0
principalTypeToTag NtPrincipal  = 1
principalTypeToTag NtSrvInst    = 2
principalTypeToTag NtSrvHst     = 3
principalTypeToTag NtUid        = 4
principalTypeToTag NtX500       = 5
principalTypeToTag NtEnterprise = 6

||| Decode an ABI tag back to a PrincipalType.
public export
tagToPrincipalType : Bits8 -> Maybe PrincipalType
tagToPrincipalType 0 = Just NtUnknown
tagToPrincipalType 1 = Just NtPrincipal
tagToPrincipalType 2 = Just NtSrvInst
tagToPrincipalType 3 = Just NtSrvHst
tagToPrincipalType 4 = Just NtUid
tagToPrincipalType 5 = Just NtX500
tagToPrincipalType 6 = Just NtEnterprise
tagToPrincipalType _ = Nothing

||| Roundtrip proof for PrincipalType.
public export
principalTypeRoundtrip : (p : PrincipalType) -> tagToPrincipalType (principalTypeToTag p) = Just p
principalTypeRoundtrip NtUnknown    = Refl
principalTypeRoundtrip NtPrincipal  = Refl
principalTypeRoundtrip NtSrvInst    = Refl
principalTypeRoundtrip NtSrvHst     = Refl
principalTypeRoundtrip NtUid        = Refl
principalTypeRoundtrip NtX500       = Refl
principalTypeRoundtrip NtEnterprise = Refl

---------------------------------------------------------------------------
-- TicketFlag (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| Size in bytes for the TicketFlag tag.
public export
ticketFlagSize : Nat
ticketFlagSize = 1

||| Encode a TicketFlag to its ABI tag value.
public export
ticketFlagToTag : TicketFlag -> Bits8
ticketFlagToTag Forwardable = 0
ticketFlagToTag Forwarded   = 1
ticketFlagToTag Proxiable   = 2
ticketFlagToTag Proxy       = 3
ticketFlagToTag Renewable   = 4
ticketFlagToTag PreAuthent  = 5
ticketFlagToTag HWAuthent   = 6

||| Decode an ABI tag back to a TicketFlag.
public export
tagToTicketFlag : Bits8 -> Maybe TicketFlag
tagToTicketFlag 0 = Just Forwardable
tagToTicketFlag 1 = Just Forwarded
tagToTicketFlag 2 = Just Proxiable
tagToTicketFlag 3 = Just Proxy
tagToTicketFlag 4 = Just Renewable
tagToTicketFlag 5 = Just PreAuthent
tagToTicketFlag 6 = Just HWAuthent
tagToTicketFlag _ = Nothing

||| Roundtrip proof for TicketFlag.
public export
ticketFlagRoundtrip : (f : TicketFlag) -> tagToTicketFlag (ticketFlagToTag f) = Just f
ticketFlagRoundtrip Forwardable = Refl
ticketFlagRoundtrip Forwarded   = Refl
ticketFlagRoundtrip Proxiable   = Refl
ticketFlagRoundtrip Proxy       = Refl
ticketFlagRoundtrip Renewable   = Refl
ticketFlagRoundtrip PreAuthent  = Refl
ticketFlagRoundtrip HWAuthent   = Refl

---------------------------------------------------------------------------
-- ErrorCode (10 constructors, tags 0-9)
---------------------------------------------------------------------------

||| Size in bytes for the ErrorCode tag.
public export
errorCodeSize : Nat
errorCodeSize = 1

||| Encode an ErrorCode to its ABI tag value.
public export
errorCodeToTag : ErrorCode -> Bits8
errorCodeToTag KDC_ERR_NONE                = 0
errorCodeToTag KDC_ERR_NAME_EXP            = 1
errorCodeToTag KDC_ERR_SERVICE_EXP         = 2
errorCodeToTag KDC_ERR_BAD_PVNO            = 3
errorCodeToTag KDC_ERR_C_OLD_MAST_KVNO     = 4
errorCodeToTag KDC_ERR_S_OLD_MAST_KVNO     = 5
errorCodeToTag KDC_ERR_C_PRINCIPAL_UNKNOWN = 6
errorCodeToTag KDC_ERR_S_PRINCIPAL_UNKNOWN = 7
errorCodeToTag KDC_ERR_PREAUTH_FAILED      = 8
errorCodeToTag KDC_ERR_PREAUTH_REQUIRED    = 9

||| Decode an ABI tag back to an ErrorCode.
public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just KDC_ERR_NONE
tagToErrorCode 1 = Just KDC_ERR_NAME_EXP
tagToErrorCode 2 = Just KDC_ERR_SERVICE_EXP
tagToErrorCode 3 = Just KDC_ERR_BAD_PVNO
tagToErrorCode 4 = Just KDC_ERR_C_OLD_MAST_KVNO
tagToErrorCode 5 = Just KDC_ERR_S_OLD_MAST_KVNO
tagToErrorCode 6 = Just KDC_ERR_C_PRINCIPAL_UNKNOWN
tagToErrorCode 7 = Just KDC_ERR_S_PRINCIPAL_UNKNOWN
tagToErrorCode 8 = Just KDC_ERR_PREAUTH_FAILED
tagToErrorCode 9 = Just KDC_ERR_PREAUTH_REQUIRED
tagToErrorCode _ = Nothing

||| Roundtrip proof for ErrorCode.
public export
errorCodeRoundtrip : (e : ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip KDC_ERR_NONE                = Refl
errorCodeRoundtrip KDC_ERR_NAME_EXP            = Refl
errorCodeRoundtrip KDC_ERR_SERVICE_EXP         = Refl
errorCodeRoundtrip KDC_ERR_BAD_PVNO            = Refl
errorCodeRoundtrip KDC_ERR_C_OLD_MAST_KVNO     = Refl
errorCodeRoundtrip KDC_ERR_S_OLD_MAST_KVNO     = Refl
errorCodeRoundtrip KDC_ERR_C_PRINCIPAL_UNKNOWN = Refl
errorCodeRoundtrip KDC_ERR_S_PRINCIPAL_UNKNOWN = Refl
errorCodeRoundtrip KDC_ERR_PREAUTH_FAILED      = Refl
errorCodeRoundtrip KDC_ERR_PREAUTH_REQUIRED    = Refl

---------------------------------------------------------------------------
-- AuthState (5 constructors, tags 0-4)
-- Kerberos authentication lifecycle states.
-- The GADT in Transitions.idr uses these as indices.
---------------------------------------------------------------------------

||| Kerberos client authentication lifecycle states.
||| Models the progression from unauthenticated through to full
||| service authentication per RFC 4120.
public export
data AuthState : Type where
  ||| No credentials obtained. Initial state.
  Initial                : AuthState
  ||| AS exchange complete; client holds a TGT from the KDC.
  TGTObtained            : AuthState
  ||| TGS exchange complete; client holds a service ticket.
  ServiceTicketObtained  : AuthState
  ||| AP exchange complete; client authenticated to the service.
  Authenticated          : AuthState
  ||| Authentication failed or was explicitly revoked.
  AuthFailed             : AuthState

public export
Eq AuthState where
  Initial               == Initial               = True
  TGTObtained           == TGTObtained           = True
  ServiceTicketObtained == ServiceTicketObtained  = True
  Authenticated         == Authenticated          = True
  AuthFailed            == AuthFailed             = True
  _                     == _                      = False

public export
Show AuthState where
  show Initial               = "Initial"
  show TGTObtained           = "TGTObtained"
  show ServiceTicketObtained = "ServiceTicketObtained"
  show Authenticated         = "Authenticated"
  show AuthFailed            = "AuthFailed"

||| Size in bytes for the AuthState tag.
public export
authStateSize : Nat
authStateSize = 1

||| Encode an AuthState to its ABI tag value.
public export
authStateToTag : AuthState -> Bits8
authStateToTag Initial               = 0
authStateToTag TGTObtained           = 1
authStateToTag ServiceTicketObtained = 2
authStateToTag Authenticated         = 3
authStateToTag AuthFailed            = 4

||| Decode an ABI tag back to an AuthState.
public export
tagToAuthState : Bits8 -> Maybe AuthState
tagToAuthState 0 = Just Initial
tagToAuthState 1 = Just TGTObtained
tagToAuthState 2 = Just ServiceTicketObtained
tagToAuthState 3 = Just Authenticated
tagToAuthState 4 = Just AuthFailed
tagToAuthState _ = Nothing

||| Roundtrip proof for AuthState.
public export
authStateRoundtrip : (s : AuthState) -> tagToAuthState (authStateToTag s) = Just s
authStateRoundtrip Initial               = Refl
authStateRoundtrip TGTObtained           = Refl
authStateRoundtrip ServiceTicketObtained = Refl
authStateRoundtrip Authenticated         = Refl
authStateRoundtrip AuthFailed            = Refl

---------------------------------------------------------------------------
-- EncStrength (3 constructors, tags 0-2)
-- Classification of encryption type security strength for negotiation.
---------------------------------------------------------------------------

||| Encryption strength classification for negotiation policy.
||| Used by the FFI to select the strongest mutually-supported cipher.
public export
data EncStrength : Type where
  ||| Strong: AES-256 variants (recommended).
  Strong   : EncStrength
  ||| Medium: AES-128 variants (acceptable).
  Medium   : EncStrength
  ||| Weak: RC4, DES3, and other legacy ciphers (deprecated).
  Weak     : EncStrength

public export
Eq EncStrength where
  Strong == Strong = True
  Medium == Medium = True
  Weak   == Weak   = True
  _      == _      = False

public export
Show EncStrength where
  show Strong = "Strong"
  show Medium = "Medium"
  show Weak   = "Weak"

||| Size in bytes for the EncStrength tag.
public export
encStrengthSize : Nat
encStrengthSize = 1

||| Encode an EncStrength to its ABI tag value.
public export
encStrengthToTag : EncStrength -> Bits8
encStrengthToTag Strong = 0
encStrengthToTag Medium = 1
encStrengthToTag Weak   = 2

||| Decode an ABI tag back to an EncStrength.
public export
tagToEncStrength : Bits8 -> Maybe EncStrength
tagToEncStrength 0 = Just Strong
tagToEncStrength 1 = Just Medium
tagToEncStrength 2 = Just Weak
tagToEncStrength _ = Nothing

||| Roundtrip proof for EncStrength.
public export
encStrengthRoundtrip : (s : EncStrength) -> tagToEncStrength (encStrengthToTag s) = Just s
encStrengthRoundtrip Strong = Refl
encStrengthRoundtrip Medium = Refl
encStrengthRoundtrip Weak   = Refl

||| Classify an EncryptionType by its security strength.
||| Used during encryption negotiation to prefer stronger ciphers.
public export
encTypeStrength : EncryptionType -> EncStrength
encTypeStrength AES256_CTS_HMAC_SHA1   = Strong
encTypeStrength AES256_CTS_HMAC_SHA384 = Strong
encTypeStrength AES128_CTS_HMAC_SHA1   = Medium
encTypeStrength RC4_HMAC               = Weak
encTypeStrength DES3_CBC_SHA1          = Weak

---------------------------------------------------------------------------
-- PreAuthType (4 constructors, tags 0-3)
-- Pre-authentication method types per RFC 4120 / RFC 6113.
---------------------------------------------------------------------------

||| Kerberos pre-authentication method types.
||| PA-ENC-TIMESTAMP is mandatory; others are optional.
public export
data PreAuthType : Type where
  ||| Encrypted timestamp (PA-ENC-TIMESTAMP, RFC 4120).
  PaEncTimestamp  : PreAuthType
  ||| EtypeInfo2 (PA-ETYPE-INFO2, RFC 4120).
  PaEtypeInfo2   : PreAuthType
  ||| FAST armoring (PA-FX-FAST, RFC 6113).
  PaFxFast       : PreAuthType
  ||| FAST cookie (PA-FX-COOKIE, RFC 6113).
  PaFxCookie     : PreAuthType

public export
Eq PreAuthType where
  PaEncTimestamp == PaEncTimestamp = True
  PaEtypeInfo2  == PaEtypeInfo2  = True
  PaFxFast      == PaFxFast      = True
  PaFxCookie    == PaFxCookie    = True
  _             == _             = False

public export
Show PreAuthType where
  show PaEncTimestamp = "PA-ENC-TIMESTAMP"
  show PaEtypeInfo2  = "PA-ETYPE-INFO2"
  show PaFxFast      = "PA-FX-FAST"
  show PaFxCookie    = "PA-FX-COOKIE"

||| Size in bytes for the PreAuthType tag.
public export
preAuthTypeSize : Nat
preAuthTypeSize = 1

||| Encode a PreAuthType to its ABI tag value.
public export
preAuthTypeToTag : PreAuthType -> Bits8
preAuthTypeToTag PaEncTimestamp = 0
preAuthTypeToTag PaEtypeInfo2  = 1
preAuthTypeToTag PaFxFast      = 2
preAuthTypeToTag PaFxCookie    = 3

||| Decode an ABI tag back to a PreAuthType.
public export
tagToPreAuthType : Bits8 -> Maybe PreAuthType
tagToPreAuthType 0 = Just PaEncTimestamp
tagToPreAuthType 1 = Just PaEtypeInfo2
tagToPreAuthType 2 = Just PaFxFast
tagToPreAuthType 3 = Just PaFxCookie
tagToPreAuthType _ = Nothing

||| Roundtrip proof for PreAuthType.
public export
preAuthTypeRoundtrip : (p : PreAuthType) -> tagToPreAuthType (preAuthTypeToTag p) = Just p
preAuthTypeRoundtrip PaEncTimestamp = Refl
preAuthTypeRoundtrip PaEtypeInfo2  = Refl
preAuthTypeRoundtrip PaFxFast      = Refl
preAuthTypeRoundtrip PaFxCookie    = Refl
