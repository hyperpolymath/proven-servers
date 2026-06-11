-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- KerberosABI.Types: C-ABI-compatible numeric representations of Kerberos types.
--
-- Maps every constructor of the core Kerberos sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/kerberos.zig) exactly.
--
-- Types covered:
--   MessageType               (10 constructors, tags 0-9)
--   EncryptionType            (5 constructors, tags 0-4)
--   PrincipalType             (7 constructors, tags 0-6)
--   TicketFlag                (7 constructors, tags 0-6)
--   ErrorCode                 (10 constructors, tags 0-9)
--   AuthState                 (5 constructors, tags 0-4)
--   EncStrength               (3 constructors, tags 0-2)
--   PreAuthType               (4 constructors, tags 0-3)
--   NegotiationState          (4 constructors, tags 0-3)

module KerberosABI.Types

%default total

---------------------------------------------------------------------------
-- MessageType (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
message_typeSize : Nat
message_typeSize = 1

||| MessageType sum type for ABI encoding.
public export
data MessageType : Type where
  AsReq : MessageType
  AsRep : MessageType
  TgsReq : MessageType
  TgsRep : MessageType
  ApReq : MessageType
  ApRep : MessageType
  KrbError : MessageType
  KrbSafe : MessageType
  KrbPriv : MessageType
  KrbCred : MessageType

||| Encode a MessageType to its ABI tag value.
public export
message_typeToTag : MessageType -> Bits8
message_typeToTag AsReq = 0
message_typeToTag AsRep = 1
message_typeToTag TgsReq = 2
message_typeToTag TgsRep = 3
message_typeToTag ApReq = 4
message_typeToTag ApRep = 5
message_typeToTag KrbError = 6
message_typeToTag KrbSafe = 7
message_typeToTag KrbPriv = 8
message_typeToTag KrbCred = 9

||| Decode an ABI tag to a MessageType.
public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0 = Just AsReq
tagToMessageType 1 = Just AsRep
tagToMessageType 2 = Just TgsReq
tagToMessageType 3 = Just TgsRep
tagToMessageType 4 = Just ApReq
tagToMessageType 5 = Just ApRep
tagToMessageType 6 = Just KrbError
tagToMessageType 7 = Just KrbSafe
tagToMessageType 8 = Just KrbPriv
tagToMessageType 9 = Just KrbCred
tagToMessageType _ = Nothing

||| Roundtrip proof: decoding an encoded MessageType yields the original.
public export
message_typeRoundtrip : (x : MessageType) -> tagToMessageType (message_typeToTag x) = Just x
message_typeRoundtrip AsReq = Refl
message_typeRoundtrip AsRep = Refl
message_typeRoundtrip TgsReq = Refl
message_typeRoundtrip TgsRep = Refl
message_typeRoundtrip ApReq = Refl
message_typeRoundtrip ApRep = Refl
message_typeRoundtrip KrbError = Refl
message_typeRoundtrip KrbSafe = Refl
message_typeRoundtrip KrbPriv = Refl
message_typeRoundtrip KrbCred = Refl

---------------------------------------------------------------------------
-- EncryptionType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
encryption_typeSize : Nat
encryption_typeSize = 1

||| EncryptionType sum type for ABI encoding.
public export
data EncryptionType : Type where
  Aes256CtsHmacSha1 : EncryptionType
  Aes128CtsHmacSha1 : EncryptionType
  Aes256CtsHmacSha384 : EncryptionType
  Rc4Hmac : EncryptionType
  Des3CbcSha1 : EncryptionType

||| Encode a EncryptionType to its ABI tag value.
public export
encryption_typeToTag : EncryptionType -> Bits8
encryption_typeToTag Aes256CtsHmacSha1 = 0
encryption_typeToTag Aes128CtsHmacSha1 = 1
encryption_typeToTag Aes256CtsHmacSha384 = 2
encryption_typeToTag Rc4Hmac = 3
encryption_typeToTag Des3CbcSha1 = 4

||| Decode an ABI tag to a EncryptionType.
public export
tagToEncryptionType : Bits8 -> Maybe EncryptionType
tagToEncryptionType 0 = Just Aes256CtsHmacSha1
tagToEncryptionType 1 = Just Aes128CtsHmacSha1
tagToEncryptionType 2 = Just Aes256CtsHmacSha384
tagToEncryptionType 3 = Just Rc4Hmac
tagToEncryptionType 4 = Just Des3CbcSha1
tagToEncryptionType _ = Nothing

||| Roundtrip proof: decoding an encoded EncryptionType yields the original.
public export
encryption_typeRoundtrip : (x : EncryptionType) -> tagToEncryptionType (encryption_typeToTag x) = Just x
encryption_typeRoundtrip Aes256CtsHmacSha1 = Refl
encryption_typeRoundtrip Aes128CtsHmacSha1 = Refl
encryption_typeRoundtrip Aes256CtsHmacSha384 = Refl
encryption_typeRoundtrip Rc4Hmac = Refl
encryption_typeRoundtrip Des3CbcSha1 = Refl

---------------------------------------------------------------------------
-- PrincipalType (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
principal_typeSize : Nat
principal_typeSize = 1

||| PrincipalType sum type for ABI encoding.
public export
data PrincipalType : Type where
  NtUnknown : PrincipalType
  NtPrincipal : PrincipalType
  NtSrvInst : PrincipalType
  NtSrvHst : PrincipalType
  NtUid : PrincipalType
  NtX500 : PrincipalType
  NtEnterprise : PrincipalType

||| Encode a PrincipalType to its ABI tag value.
public export
principal_typeToTag : PrincipalType -> Bits8
principal_typeToTag NtUnknown = 0
principal_typeToTag NtPrincipal = 1
principal_typeToTag NtSrvInst = 2
principal_typeToTag NtSrvHst = 3
principal_typeToTag NtUid = 4
principal_typeToTag NtX500 = 5
principal_typeToTag NtEnterprise = 6

||| Decode an ABI tag to a PrincipalType.
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

||| Roundtrip proof: decoding an encoded PrincipalType yields the original.
public export
principal_typeRoundtrip : (x : PrincipalType) -> tagToPrincipalType (principal_typeToTag x) = Just x
principal_typeRoundtrip NtUnknown = Refl
principal_typeRoundtrip NtPrincipal = Refl
principal_typeRoundtrip NtSrvInst = Refl
principal_typeRoundtrip NtSrvHst = Refl
principal_typeRoundtrip NtUid = Refl
principal_typeRoundtrip NtX500 = Refl
principal_typeRoundtrip NtEnterprise = Refl

---------------------------------------------------------------------------
-- TicketFlag (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
ticket_flagSize : Nat
ticket_flagSize = 1

||| TicketFlag sum type for ABI encoding.
public export
data TicketFlag : Type where
  Forwardable : TicketFlag
  Forwarded : TicketFlag
  Proxiable : TicketFlag
  Proxy : TicketFlag
  Renewable : TicketFlag
  PreAuthent : TicketFlag
  HwAuthent : TicketFlag

||| Encode a TicketFlag to its ABI tag value.
public export
ticket_flagToTag : TicketFlag -> Bits8
ticket_flagToTag Forwardable = 0
ticket_flagToTag Forwarded = 1
ticket_flagToTag Proxiable = 2
ticket_flagToTag Proxy = 3
ticket_flagToTag Renewable = 4
ticket_flagToTag PreAuthent = 5
ticket_flagToTag HwAuthent = 6

||| Decode an ABI tag to a TicketFlag.
public export
tagToTicketFlag : Bits8 -> Maybe TicketFlag
tagToTicketFlag 0 = Just Forwardable
tagToTicketFlag 1 = Just Forwarded
tagToTicketFlag 2 = Just Proxiable
tagToTicketFlag 3 = Just Proxy
tagToTicketFlag 4 = Just Renewable
tagToTicketFlag 5 = Just PreAuthent
tagToTicketFlag 6 = Just HwAuthent
tagToTicketFlag _ = Nothing

||| Roundtrip proof: decoding an encoded TicketFlag yields the original.
public export
ticket_flagRoundtrip : (x : TicketFlag) -> tagToTicketFlag (ticket_flagToTag x) = Just x
ticket_flagRoundtrip Forwardable = Refl
ticket_flagRoundtrip Forwarded = Refl
ticket_flagRoundtrip Proxiable = Refl
ticket_flagRoundtrip Proxy = Refl
ticket_flagRoundtrip Renewable = Refl
ticket_flagRoundtrip PreAuthent = Refl
ticket_flagRoundtrip HwAuthent = Refl

---------------------------------------------------------------------------
-- ErrorCode (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
error_codeSize : Nat
error_codeSize = 1

||| ErrorCode sum type for ABI encoding.
public export
data ErrorCode : Type where
  KdcErrNone : ErrorCode
  KdcErrNameExp : ErrorCode
  KdcErrServiceExp : ErrorCode
  KdcErrBadPvno : ErrorCode
  KdcErrCOldMastKvno : ErrorCode
  KdcErrSOldMastKvno : ErrorCode
  KdcErrCPrincipalUnknown : ErrorCode
  KdcErrSPrincipalUnknown : ErrorCode
  KdcErrPreauthFailed : ErrorCode
  KdcErrPreauthRequired : ErrorCode

||| Encode a ErrorCode to its ABI tag value.
public export
error_codeToTag : ErrorCode -> Bits8
error_codeToTag KdcErrNone = 0
error_codeToTag KdcErrNameExp = 1
error_codeToTag KdcErrServiceExp = 2
error_codeToTag KdcErrBadPvno = 3
error_codeToTag KdcErrCOldMastKvno = 4
error_codeToTag KdcErrSOldMastKvno = 5
error_codeToTag KdcErrCPrincipalUnknown = 6
error_codeToTag KdcErrSPrincipalUnknown = 7
error_codeToTag KdcErrPreauthFailed = 8
error_codeToTag KdcErrPreauthRequired = 9

||| Decode an ABI tag to a ErrorCode.
public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just KdcErrNone
tagToErrorCode 1 = Just KdcErrNameExp
tagToErrorCode 2 = Just KdcErrServiceExp
tagToErrorCode 3 = Just KdcErrBadPvno
tagToErrorCode 4 = Just KdcErrCOldMastKvno
tagToErrorCode 5 = Just KdcErrSOldMastKvno
tagToErrorCode 6 = Just KdcErrCPrincipalUnknown
tagToErrorCode 7 = Just KdcErrSPrincipalUnknown
tagToErrorCode 8 = Just KdcErrPreauthFailed
tagToErrorCode 9 = Just KdcErrPreauthRequired
tagToErrorCode _ = Nothing

||| Roundtrip proof: decoding an encoded ErrorCode yields the original.
public export
error_codeRoundtrip : (x : ErrorCode) -> tagToErrorCode (error_codeToTag x) = Just x
error_codeRoundtrip KdcErrNone = Refl
error_codeRoundtrip KdcErrNameExp = Refl
error_codeRoundtrip KdcErrServiceExp = Refl
error_codeRoundtrip KdcErrBadPvno = Refl
error_codeRoundtrip KdcErrCOldMastKvno = Refl
error_codeRoundtrip KdcErrSOldMastKvno = Refl
error_codeRoundtrip KdcErrCPrincipalUnknown = Refl
error_codeRoundtrip KdcErrSPrincipalUnknown = Refl
error_codeRoundtrip KdcErrPreauthFailed = Refl
error_codeRoundtrip KdcErrPreauthRequired = Refl

---------------------------------------------------------------------------
-- AuthState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
auth_stateSize : Nat
auth_stateSize = 1

||| AuthState sum type for ABI encoding.
public export
data AuthState : Type where
  Initial : AuthState
  TgtObtained : AuthState
  ServiceTicketObtained : AuthState
  Authenticated : AuthState
  AuthFailed : AuthState

||| Encode a AuthState to its ABI tag value.
public export
auth_stateToTag : AuthState -> Bits8
auth_stateToTag Initial = 0
auth_stateToTag TgtObtained = 1
auth_stateToTag ServiceTicketObtained = 2
auth_stateToTag Authenticated = 3
auth_stateToTag AuthFailed = 4

||| Decode an ABI tag to a AuthState.
public export
tagToAuthState : Bits8 -> Maybe AuthState
tagToAuthState 0 = Just Initial
tagToAuthState 1 = Just TgtObtained
tagToAuthState 2 = Just ServiceTicketObtained
tagToAuthState 3 = Just Authenticated
tagToAuthState 4 = Just AuthFailed
tagToAuthState _ = Nothing

||| Roundtrip proof: decoding an encoded AuthState yields the original.
public export
auth_stateRoundtrip : (x : AuthState) -> tagToAuthState (auth_stateToTag x) = Just x
auth_stateRoundtrip Initial = Refl
auth_stateRoundtrip TgtObtained = Refl
auth_stateRoundtrip ServiceTicketObtained = Refl
auth_stateRoundtrip Authenticated = Refl
auth_stateRoundtrip AuthFailed = Refl

---------------------------------------------------------------------------
-- EncStrength (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
enc_strengthSize : Nat
enc_strengthSize = 1

||| EncStrength sum type for ABI encoding.
public export
data EncStrength : Type where
  Strong : EncStrength
  Medium : EncStrength
  Weak : EncStrength

||| Encode a EncStrength to its ABI tag value.
public export
enc_strengthToTag : EncStrength -> Bits8
enc_strengthToTag Strong = 0
enc_strengthToTag Medium = 1
enc_strengthToTag Weak = 2

||| Decode an ABI tag to a EncStrength.
public export
tagToEncStrength : Bits8 -> Maybe EncStrength
tagToEncStrength 0 = Just Strong
tagToEncStrength 1 = Just Medium
tagToEncStrength 2 = Just Weak
tagToEncStrength _ = Nothing

||| Roundtrip proof: decoding an encoded EncStrength yields the original.
public export
enc_strengthRoundtrip : (x : EncStrength) -> tagToEncStrength (enc_strengthToTag x) = Just x
enc_strengthRoundtrip Strong = Refl
enc_strengthRoundtrip Medium = Refl
enc_strengthRoundtrip Weak = Refl

---------------------------------------------------------------------------
-- PreAuthType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
pre_auth_typeSize : Nat
pre_auth_typeSize = 1

||| PreAuthType sum type for ABI encoding.
public export
data PreAuthType : Type where
  PaEncTimestamp : PreAuthType
  PaEtypeInfo2 : PreAuthType
  PaFxFast : PreAuthType
  PaFxCookie : PreAuthType

||| Encode a PreAuthType to its ABI tag value.
public export
pre_auth_typeToTag : PreAuthType -> Bits8
pre_auth_typeToTag PaEncTimestamp = 0
pre_auth_typeToTag PaEtypeInfo2 = 1
pre_auth_typeToTag PaFxFast = 2
pre_auth_typeToTag PaFxCookie = 3

||| Decode an ABI tag to a PreAuthType.
public export
tagToPreAuthType : Bits8 -> Maybe PreAuthType
tagToPreAuthType 0 = Just PaEncTimestamp
tagToPreAuthType 1 = Just PaEtypeInfo2
tagToPreAuthType 2 = Just PaFxFast
tagToPreAuthType 3 = Just PaFxCookie
tagToPreAuthType _ = Nothing

||| Roundtrip proof: decoding an encoded PreAuthType yields the original.
public export
pre_auth_typeRoundtrip : (x : PreAuthType) -> tagToPreAuthType (pre_auth_typeToTag x) = Just x
pre_auth_typeRoundtrip PaEncTimestamp = Refl
pre_auth_typeRoundtrip PaEtypeInfo2 = Refl
pre_auth_typeRoundtrip PaFxFast = Refl
pre_auth_typeRoundtrip PaFxCookie = Refl

---------------------------------------------------------------------------
-- NegotiationState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
negotiation_stateSize : Nat
negotiation_stateSize = 1

||| NegotiationState sum type for ABI encoding.
public export
data NegotiationState : Type where
  NegIdle : NegotiationState
  Proposed : NegotiationState
  Selected : NegotiationState
  NegFailed : NegotiationState

||| Encode a NegotiationState to its ABI tag value.
public export
negotiation_stateToTag : NegotiationState -> Bits8
negotiation_stateToTag NegIdle = 0
negotiation_stateToTag Proposed = 1
negotiation_stateToTag Selected = 2
negotiation_stateToTag NegFailed = 3

||| Decode an ABI tag to a NegotiationState.
public export
tagToNegotiationState : Bits8 -> Maybe NegotiationState
tagToNegotiationState 0 = Just NegIdle
tagToNegotiationState 1 = Just Proposed
tagToNegotiationState 2 = Just Selected
tagToNegotiationState 3 = Just NegFailed
tagToNegotiationState _ = Nothing

||| Roundtrip proof: decoding an encoded NegotiationState yields the original.
public export
negotiation_stateRoundtrip : (x : NegotiationState) -> tagToNegotiationState (negotiation_stateToTag x) = Just x
negotiation_stateRoundtrip NegIdle = Refl
negotiation_stateRoundtrip Proposed = Refl
negotiation_stateRoundtrip Selected = Refl
negotiation_stateRoundtrip NegFailed = Refl
